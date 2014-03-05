/*
 * CC3OpenGLProgPipeline.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://en.wikipedia.org/wiki/MIT_License
 *
 * See header file CC3OpenGLProgPipeline.h for full API documentation.
 */

#import "CC3OpenGLProgPipeline.h"
#import "CC3ShaderMatcher.h"
#import "CC3NodeVisitor.h"
#import "CC3MeshNode.h"

#if CC3_GLSL

#import "kazmath/GL/matrix.h"	// Only cocos2d 2.x
#import "CC3Shaders.h"

@interface CC3OpenGL (TemplateMethods)
-(void) initPlatformLimits;
-(void) initVertexAttributes;
-(void) align3DVertexAttributeState;
-(void) align2DStateCache;
-(void) align3DStateCache;
@end

@interface CC3GLSLVariable (ProgPipeline)
-(void) populateFromGL;
@end

@interface CC3GLSLUniform (ProgPipeline)
-(void) setGLValue;
@end


@implementation CC3OpenGLProgPipeline

-(void) dealloc {
	[value_GL_SHADING_LANGUAGE_VERSION release];
	[_shaderProgramPrewarmer release];
	[super dealloc];
}


#pragma mark Vertex attribute arrays

/** Only need to bind vertex indices. All vertex attributes are bound when program is bound. */
-(void) bindMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[mesh.vertexIndices bindContentToAttributeAt: kCC3VertexAttributeIndexUnavailable withVisitor: visitor];
}

-(void) bindVertexAttribute: (CC3GLSLAttribute*) attribute withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3Assert(attribute.semantic != kCC3SemanticNone || !visitor.currentMeshNode.shaderContext.shouldEnforceVertexAttributes,
			  @"Cannot bind the attribute named %@ to the GL engine because its semantic meaning"
			  @" is unknown. Check the attribute name. If the attribute name is correct, but is"
			  @" not a standard cocos3d attribute name, assign a semantic value to the attribute"
			  @" in the configureVariable: method of your semantic delegate implementation, or use"
			  @" a PFX file to define the semantic for the attribute name.", attribute.name);
	CC3VertexArray* va = [self vertexArrayForAttribute: attribute withVisitor: visitor];
	[va bindContentToAttributeAt: attribute.location withVisitor: visitor];
}

/** 
 * Returns the vertex array that should be bound to the specified attribute, or nil if the
 * mesh does not contain a vertex array that matches the specified attribute.
 */
-(CC3VertexArray*) vertexArrayForAttribute: (CC3GLSLAttribute*) attribute
							   withVisitor: (CC3NodeDrawingVisitor*) visitor {
	return [visitor.currentMesh vertexArrayForSemantic: attribute.semantic at: attribute.semanticIndex];
}

-(void) setVertexAttributeEnablementAt: (GLint) vaIdx {
	if (vertexAttributes[vaIdx].isEnabled)
		glEnableVertexAttribArray(vaIdx);
	else
		glDisableVertexAttribArray(vaIdx);
	LogGLErrorTrace(@"gl%@ableVertexAttribArray(%u)", (vertexAttributes[vaIdx].isEnabled ? @"En" : @"Dis"), vaIdx);
}

-(void) bindVertexContentToAttributeAt: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	glVertexAttribPointer(vaIdx, vaPtr->elementSize, vaPtr->elementType,
						  vaPtr->shouldNormalize, vaPtr->vertexStride, vaPtr->vertices);
	LogGLErrorTrace(@"glVertexAttribPointer(%i, %i, %@, %@, %i, %p)", vaIdx, vaPtr->elementSize,
					NSStringFromGLEnum(vaPtr->elementType), NSStringFromBoolean(vaPtr->shouldNormalize),
					vaPtr->vertexStride, vaPtr->vertices);
}

-(void) enable2DVertexAttributes {
	for (GLuint vaIdx = 0; vaIdx < value_MaxVertexAttribsUsed; vaIdx++) {
		switch (vaIdx) {
			case kCCVertexAttrib_Position:
			case kCCVertexAttrib_Color:
			case kCCVertexAttrib_TexCoords:
				[self enableVertexAttribute: YES at: vaIdx];
				break;
			default:
				[self enableVertexAttribute: NO at: vaIdx];
				break;
		}
	}
}

-(void) align3DVertexAttributeState {
	[super align3DVertexAttributeState];

	// Mark position, color & tex coords as unknown
	for (GLuint vaIdx = 0; vaIdx < value_MaxVertexAttribsUsed; vaIdx++) {
		switch (vaIdx) {
			case kCCVertexAttrib_Position:
			case kCCVertexAttrib_Color:
			case kCCVertexAttrib_TexCoords:
				vertexAttributes[vaIdx].isEnabledKnown = NO;
				vertexAttributes[vaIdx].isKnown = NO;
				break;
			default:
				break;
		}
	}
}


#pragma mark Matrices

// Don't change matrix state on background thread (which can occur during shader prewarming),
// because it messes with the concurrent rendering of cocos2d components on the rendering thread.
	
-(void) activateMatrixStack: (GLenum) mode {
	if ( !self.isRenderingContext ) return;
	
	kmGLMatrixMode(mode);
}

-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx {
	if ( !self.isRenderingContext ) return;

	[self activateMatrixStack: GL_MODELVIEW];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	kmGLLoadMatrix((kmMat4*)&glMtx);
}

-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_PROJECTION];
	kmGLLoadMatrix((kmMat4*)mtx);
}

-(void) pushModelviewMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_MODELVIEW];
	kmGLPushMatrix();
}

-(void) popModelviewMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_MODELVIEW];
	kmGLPopMatrix();
}

-(void) pushProjectionMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_PROJECTION];
	kmGLPushMatrix();
}

-(void) popProjectionMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_PROJECTION];
	kmGLPopMatrix();
}


#pragma mark Shaders

-(CC3ShaderPrewarmer*) shaderProgramPrewarmer { return _shaderProgramPrewarmer; }

-(void) setShaderProgramPrewarmer: (CC3ShaderPrewarmer*) shaderProgramPrewarmer {
	if (shaderProgramPrewarmer == _shaderProgramPrewarmer) return;
	[_shaderProgramPrewarmer release];
	_shaderProgramPrewarmer = [shaderProgramPrewarmer retain];
}

-(GLuint) createShader: (GLenum) shaderType {
    GLuint shaderID = glCreateShader(shaderType);
	LogGLErrorTrace(@"glCreateShader(%@) = %u", NSStringFromGLEnum(shaderType), shaderID);
	return shaderID;
}

-(void) deleteShader: (GLuint) shaderID {
	if ( !shaderID ) return;		// Silently ignore zero ID
	glDeleteShader(shaderID);
	LogGLErrorTrace(@"glDeleteShader(%u)", shaderID);
}

-(void) compileShader: (GLuint) shaderID
				 from: (GLuint) srcStrCount
	sourceCodeStrings: (const GLchar**) srcCodeStrings {
	
	glShaderSource(shaderID, srcStrCount, srcCodeStrings, NULL);
	LogGLErrorTrace(@"glShaderSource(%u, %u, %p, %p)", shaderID, srcStrCount, srcCodeStrings, NULL);
	
	glCompileShader(shaderID);
	LogGLErrorTrace(@"glCompileShader(%u)", shaderID);
}

-(BOOL) getShaderWasCompiled: (GLuint) shaderID {
	if ( !shaderID ) return NO;
    return ([self getIntegerParameter: GL_COMPILE_STATUS forShader: shaderID] > 0);
}

-(GLint) getIntegerParameter: (GLenum) param forShader: (GLuint) shaderID {
	GLint val;
    glGetShaderiv(shaderID, param, &val);
	LogGLErrorTrace(@"glGetShaderiv(%u, %@, %i)", shaderID, NSStringFromGLEnum(param), val);
	return val;
}

-(NSString*) getLogForShader: (GLuint) shaderID {
	GLint strLen = [self getIntegerParameter: GL_INFO_LOG_LENGTH forShader: shaderID];
	if (strLen < 1) return nil;
	
	GLint charsRetrieved = 0;
	GLchar contentBytes[strLen];
	glGetShaderInfoLog(shaderID, strLen, &charsRetrieved, contentBytes);
	LogGLErrorTrace(@"glGetShaderInfoLog(%u, %i, %i, \"%s\")", shaderID, strLen, charsRetrieved, contentBytes);
	
	return [NSString stringWithUTF8String: contentBytes];
}

-(NSString*) getSourceCodeForShader: (GLuint) shaderID {
	GLint strLen = [self getIntegerParameter: GL_SHADER_SOURCE_LENGTH forShader: shaderID];
	if (strLen < 1) return nil;
	
	GLint charsRetrieved = 0;
	GLchar contentBytes[strLen];
	glGetShaderSource(shaderID, strLen, &charsRetrieved, contentBytes);
	LogGLErrorTrace(@"glGetShaderSource(%u, %i, %i, \"%s\")", shaderID, strLen, charsRetrieved, contentBytes);
	
	return [NSString stringWithUTF8String: contentBytes];
}

-(GLuint) createShaderProgram {
    GLuint programID = glCreateProgram();
	LogGLErrorTrace(@"glCreateProgram() = %u", programID);
	return programID;
}

-(void) deleteShaderProgram: (GLuint) programID {
	if ( !programID ) return;		// Silently ignore zero ID

	// If the program to be deleted is currently bound, force it to unbind first. Program deletion
	// is deferred by the GL engine until the program is no longer in use. If the GL state is not
	// updated, the program will not actually be deleted in the GL engine. This can occur, for
	// instance, when closing 3D rendering temporarily within an app. The currently bound program
	// will actually never be deleted. In addition, this state engine will continue to think it is
	// bound, which can cause problems if a new shader program is later created with the same ID.
	if (value_GL_CURRENT_PROGRAM == programID) [self useShaderProgram: 0];
	
	glDeleteProgram(programID);
	LogGLErrorTrace(@"glDeleteProgram(%u)", programID);
}

-(void) attachShader: (GLuint) shaderID toShaderProgram: (GLuint) programID {
	if ( !shaderID || !programID ) return;		// Silently ignore zero IDs
	glAttachShader(programID, shaderID);
	LogGLErrorTrace(@"glAttachShader(%u, %u)", programID, shaderID);
}

-(void) detachShader: (GLuint) shaderID fromShaderProgram: (GLuint) programID {
	if ( !shaderID || !programID ) return;		// Silently ignore zero IDs
	glDetachShader(programID, shaderID);
	LogGLErrorTrace(@"glDetachShader(%u, %u)", programID, shaderID);
}

-(void) linkShaderProgram: (GLuint) programID {
	if ( !programID ) return;		// Silently ignore zero ID
	glLinkProgram(programID);
	LogGLErrorTrace(@"glLinkProgram(%u)", programID);
}

-(BOOL) getShaderProgramWasLinked: (GLuint) programID {
	if ( !programID ) return NO;
    return ([self getIntegerParameter: GL_LINK_STATUS forShaderProgram: programID] > 0);
}

-(GLint) getIntegerParameter: (GLenum) param forShaderProgram: (GLuint) programID {
	GLint val;
    glGetProgramiv(programID, param, &val);
	LogGLErrorTrace(@"glGetProgramiv(%u, %@, %i)", programID, NSStringFromGLEnum(param), val);
	return val;
}

-(void) useShaderProgram: (GLuint) programID {
	cc3_CheckGLPrim(programID, value_GL_CURRENT_PROGRAM, isKnown_GL_CURRENT_PROGRAM);
	if ( !needsUpdate ) return;
	glUseProgram(programID);
	LogGLErrorTrace(@"glUseProgram(%u)", programID);
}

-(NSString*) getLogForShaderProgram: (GLuint) programID {
	GLint strLen = [self getIntegerParameter: GL_INFO_LOG_LENGTH forShaderProgram: programID];
	if (strLen < 1) return nil;
	
	GLint charsRetrieved = 0;
	GLchar contentBytes[strLen];
	glGetProgramInfoLog(programID, strLen, &charsRetrieved, contentBytes);
	LogGLErrorTrace(@"glGetProgramInfoLog(%u, %i, %i, \"%s\")", programID, strLen, charsRetrieved, contentBytes);
	
	return [NSString stringWithUTF8String: contentBytes];
}

-(void) populateShaderProgramVariable: (CC3GLSLVariable*) var { [var populateFromGL]; }

-(void) setShaderProgramUniformValue: (CC3GLSLUniform*) uniform {
	[self useShaderProgram: uniform.program.programID];
	[uniform setGLValue];
}


#pragma mark Platform limits & info

-(GLuint) maxNumberOfVertexShaderUniformVectors { return value_GL_MAX_VERTEX_UNIFORM_VECTORS; }

-(GLuint) maxNumberOfFragmentShaderUniformVectors { return value_GL_MAX_FRAGMENT_UNIFORM_VECTORS; }

-(GLuint) maxNumberOfShaderProgramVaryingVectors { return value_GL_MAX_VARYING_VECTORS; }


#pragma mark Aligning 2D & 3D state

-(void) align2DStateCache {
	[super align2DStateCache];
	
	ccGLBlendFunc(value_GL_BLEND_SRC_RGB, value_GL_BLEND_DST_RGB);
	ccGLBindTexture2DN(value_GL_ACTIVE_TEXTURE, value_GL_TEXTURE_BINDING_2D[value_GL_ACTIVE_TEXTURE]);
	
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_None);
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
	
	ccGLUseProgram(0);
	
#if COCOS2D_VERSION < 0x020100
	if (valueCap_GL_BLEND) ccGLEnable(CC_GL_BLEND);
	else ccGLEnable(0);
#endif
}

-(void) align3DStateCache {
	[super align3DStateCache];
	
	isKnown_GL_CURRENT_PROGRAM = NO;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		[self initShaderProgramPrewarmer];
	}
	return self;
}

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_TEXTURE_UNITS = [self getInteger: GL_MAX_TEXTURE_IMAGE_UNITS];
	LogInfoIfPrimary(@"Maximum texture units: %u", value_GL_MAX_TEXTURE_UNITS);
	
	value_GL_MAX_VERTEX_ATTRIBS = [self getInteger: GL_MAX_VERTEX_ATTRIBS];
	LogInfoIfPrimary(@"Maximum vertex attributes: %u", value_GL_MAX_VERTEX_ATTRIBS);

	value_GL_SHADING_LANGUAGE_VERSION = [[self getString: GL_SHADING_LANGUAGE_VERSION] retain];
	LogInfoIfPrimary(@"GLSL version: %@", value_GL_SHADING_LANGUAGE_VERSION);
	
	value_GL_MAX_CLIP_PLANES = kCC3MaxGLSLClipPlanes;

	value_GL_MAX_LIGHTS = kCC3MaxGLSLLights;
	
	value_GL_MAX_PALETTE_MATRICES = kCC3MaxGLSLPaletteMatrices;
	
	value_GL_MAX_SAMPLES = 1;				// Assume no multi-sampling support
	
	valueMaxBoneInfluencesPerVertex = kCC3MaxGLSLBoneInfluencesPerVertex;
}

// Start with at least the cocos2d attributes so they can be enabled and disabled
-(void) initVertexAttributes {
	[super initVertexAttributes];
	value_MaxVertexAttribsUsed = kCCVertexAttrib_MAX;
}

-(void) initShaderProgramPrewarmer {
	self.shaderProgramPrewarmer = [CC3ShaderPrewarmer prewarmerWithName: self.name];
}

@end


#pragma mark -
#pragma mark CC3GLSLVariable

/** Extension for GL engine interaction */
@implementation CC3GLSLVariable (ProgPipeline)
-(void) populateFromGL { CC3AssertUnimplemented(@"populateFromGL"); }
@end


#pragma mark -
#pragma mark CC3GLSLAttribute

/** Extension for GL engine interaction */
@implementation CC3GLSLAttribute (ProgPipeline)

-(void) populateFromGL {

	GLint maxNameLen = [_program maxAttributeNameLength];
	char cName[maxNameLen];

	glGetActiveAttrib(_program.programID, _index, maxNameLen, NULL, &_size, &_type, cName);
	LogGLErrorTrace(@"glGetActiveAttrib(%u, %u, %i, NULL, %i, %@, \"%s\")", _program.programID, _index, maxNameLen, _size, NSStringFromGLEnum(_type), cName);

	_location = glGetAttribLocation(_program.programID, cName);
	LogGLErrorTrace(@"glGetAttribLocation(%u, \"%s\")", _program.programID, cName);

	_name = [[NSString stringWithUTF8String: cName] retain];
}

@end


#pragma mark -
#pragma mark CC3GLSLUniform

/** Extension for GL engine interaction */
@implementation CC3GLSLUniform (ProgPipeline)

-(void) populateFromGL {
	
	GLint maxNameLen = [_program maxUniformNameLength];
	char cName[maxNameLen];
	
	glGetActiveUniform(_program.programID, _index, maxNameLen, NULL, &_size, &_type, cName);
	LogGLErrorTrace(@"glGetActiveUniform(%u, %u, %i, NULL, %i, %@, \"%s\")", _program.programID, _index, maxNameLen, _size, NSStringFromGLEnum(_type), cName);
	
	_location = glGetUniformLocation(_program.programID, cName);
	LogGLErrorTrace(@"glGetUniformLocation(%u, \"%s\")", _program.programID, cName);
	
	_name = [[NSString stringWithUTF8String: cName] retain];
}

/** Set the value of this uniform in the GL engine, based on the content type. */
-(void) setGLValue {
	
	switch (_type) {
		
		case GL_FLOAT:
			glUniform1fv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform1fv(%i, %i, %.3f) setting %@", _location, _size, *(GLfloat*)_glVarValue, self.name);
			break;
		case GL_FLOAT_VEC2:
			glUniform2fv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform2fv(%i, %i, %@) setting %@", _location, _size, NSStringFromCGPoint(*(CGPoint*)_glVarValue), self.name);
			break;
		case GL_FLOAT_VEC3:
			glUniform3fv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform3fv(%i, %i, %@) setting %@", _location, _size, NSStringFromCC3Vector(*(CC3Vector*)_glVarValue), self.name);
			break;
		case GL_FLOAT_VEC4:
			glUniform4fv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform4fv(%i, %i, %@) setting %@", _location, _size, NSStringFromCC3Vector4(*(CC3Vector4*)_glVarValue), self.name);
			break;
		
		case GL_FLOAT_MAT2:
			glUniformMatrix2fv(_location, _size, GL_FALSE, _glVarValue);
			LogGLErrorTrace(@"glUniformMatrix2fv(%i, %i, GL_FALSE, %@) setting %@", _location, _size, NSStringFromCC3Vector4(*(CC3Vector4*)_glVarValue), self.name);
			break;
		case GL_FLOAT_MAT3:
			glUniformMatrix3fv(_location, _size, GL_FALSE, _glVarValue);
			LogGLErrorTrace(@"glUniformMatrix3fv(%i, %i, GL_FALSE, %@) setting %@", _location, _size, NSStringFromCC3Matrix3x3((CC3Matrix3x3*)_glVarValue), self.name);
			break;
		case GL_FLOAT_MAT4:
			glUniformMatrix4fv(_location, _size, GL_FALSE, _glVarValue);
			LogGLErrorTrace(@"glUniformMatrix4fv(%i, %i, GL_FALSE, %@) setting %@", _location, _size, NSStringFromCC3Matrix4x4((CC3Matrix4x4*)_glVarValue), self.name);
			break;
		
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
		case GL_BOOL:
			glUniform1iv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform1iv(%i, %i, %i) setting %@", _location, _size, *(GLint*)_glVarValue, self.name);
			break;
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
			glUniform2iv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform2iv(%i, %i, %@) setting %@", _location, _size, NSStringFromCC3IntPoint(*(CC3IntPoint*)_glVarValue), self.name);
			break;
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
			glUniform3iv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform3iv(%i, %i, %@) setting %@", _location, _size, NSStringFromCC3IntVector(*(CC3IntVector*)_glVarValue), self.name);
			break;
		case GL_INT_VEC4:
		case GL_BOOL_VEC4:
			glUniform4iv(_location, _size, _glVarValue);
			LogGLErrorTrace(@"glUniform4iv(%i, %i, %@) setting %@", _location, _size, NSStringFromCC3IntVector4(*(CC3IntVector4*)_glVarValue), self.name);
			break;
		
		default:
			CC3Assert(NO, @"%@ could not set GL engine state value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
		break;
	}
}

@end


#pragma mark -
#pragma mark CC3GLSLUniformOverride

/** Extension for GL engine interaction */
@implementation CC3GLSLUniformOverride (ProgPipeline)
-(void) setGLValue {}
@end

#endif	// CC3_GLSL