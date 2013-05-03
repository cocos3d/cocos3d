/*
 * CC3OpenGLProgPipeline.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3GLProgramMatchers.h"
#import "CC3NodeVisitor.h"
#import "CC3MeshNode.h"

#if CC3_GLSL

#import "kazmath/GL/matrix.h"	// Only cocos2d 2.x
#import "CC3GLProgram.h"

@interface CC3OpenGL (TemplateMethods)
-(void) clearUnboundVertexAttributes;
-(void) initPlatformLimits;
-(void) initVertexAttributes;
@end

@implementation CC3OpenGLProgPipeline

-(void) dealloc {
	[value_GL_SHADING_LANGUAGE_VERSION release];
	[super dealloc];
}

#pragma mark Vertex attribute arrays

/** Only need to bind vertex indices. All vertex attributes are bound when program is bound. */
-(void) bindMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[mesh.vertexIndices bindContentToAttributeAt: kCC3VertexAttributeIndexUnavailable withVisitor: visitor];
}

-(void) bindVertexAttribute: (CC3GLSLAttribute*) attribute withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3Assert(attribute.semantic != kCC3SemanticNone, @"Cannot bind the attribute named %@ to the GL engine because"
			  @"its semantic meaning is unknown. If the attribute name is correct, assign a semantic value to the"
			  @" attribute in the configureVariable: method of your semantic delegate implementation.", self);
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
	LogGLErrorTrace(@"glVertexAttribPointer(%i, %i, %@, %i, %p)", vaIdx, vaPtr->elementSize,
					NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
}

-(void) clearUnboundVertexAttributes {
	[super clearUnboundVertexAttributes];
	ccGLBindVAO(0);		// Ensure that a VAO was not left in place by cocos2d
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

// Mark position, color & tex coords as unknown
-(void) align3DVertexAttributeState {
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

-(void) activateMatrixStack: (GLenum) mode { kmGLMatrixMode(mode); }

-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx {
	[self activateMatrixStack: GL_MODELVIEW];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	kmGLLoadMatrix((kmMat4*)&glMtx);
}

-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx {
	[self activateMatrixStack: GL_PROJECTION];
	kmGLLoadMatrix((kmMat4*)mtx);
}

-(void) pushModelviewMatrixStack {
	[self activateMatrixStack: GL_MODELVIEW];
	kmGLPushMatrix();
}

-(void) popModelviewMatrixStack {
	[self activateMatrixStack: GL_MODELVIEW];
	kmGLPopMatrix();
}

-(void) pushProjectionMatrixStack {
	[self activateMatrixStack: GL_PROJECTION];
	kmGLPushMatrix();
}

-(void) popProjectionMatrixStack {
	[self activateMatrixStack: GL_PROJECTION];
	kmGLPopMatrix();
}


#pragma mark Shaders

-(CC3GLProgram*) selectProgramForMeshNode: (CC3MeshNode*) aMeshNode {
	return [CC3GLProgram.programMatcher programForMeshNode: aMeshNode];
}

-(void) bindProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3GLProgram* shaderProgram;
	if (visitor.shouldDecorateNode)
		shaderProgram = [self selectProgramForMeshNode: visitor.currentMeshNode];
	else
		shaderProgram = CC3GLProgram.programMatcher.pureColorProgram;
	[self bindProgram: shaderProgram  withVisitor: visitor];
}

-(void) bindProgram: (CC3GLProgram*) program withVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@ with %@", visitor.currentMeshNode, program);
	[program bindWithVisitor: visitor];

	[self clearUnboundVertexAttributes];
	[program populateVertexAttributesWithVisitor: visitor];
	[self enableBoundVertexAttributes];
	
	[program populateNodeScopeUniformsWithVisitor: visitor];
}


#pragma mark Aligning 2D & 3D caches

-(void) align2DStateCache {
	ccGLBlendFunc(value_GL_BLEND_SRC, value_GL_BLEND_DST);
	ccGLBindTexture2DN(value_GL_ACTIVE_TEXTURE, value_GL_TEXTURE_BINDING_2D);
	
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_None);
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
	
#if COCOS2D_VERSION < 0x020100
	if (valueCap_GL_BLEND) ccGLEnable(CC_GL_BLEND);
	else ccGLEnable(0);
#endif
}


#pragma mark Allocation and initialization

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &value_GL_MAX_TEXTURE_UNITS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_TEXTURE_IMAGE_UNITS), value_GL_MAX_TEXTURE_UNITS);
	LogInfo(@"Maximum texture units: %u", value_GL_MAX_TEXTURE_UNITS);
	
	glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &value_GL_MAX_VERTEX_ATTRIBS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_VERTEX_ATTRIBS), value_GL_MAX_VERTEX_ATTRIBS);
	LogInfo(@"Maximum vertex attributes: %u", value_GL_MAX_VERTEX_ATTRIBS);

	value_GL_SHADING_LANGUAGE_VERSION = [[NSString alloc] initWithUTF8String: (char*)glGetString(GL_SHADING_LANGUAGE_VERSION)];
	LogGLErrorTrace(@"glGetString(%@)", NSStringFromGLEnum(GL_SHADING_LANGUAGE_VERSION));
	LogInfo(@"GLSL version: %@", value_GL_SHADING_LANGUAGE_VERSION);
	
	value_GL_MAX_CLIP_PLANES = kCC3MaxGLSLClipPlanes;

	value_GL_MAX_LIGHTS = kCC3MaxGLSLLights;
	
	value_GL_MAX_PALETTE_MATRICES = kCC3MaxGLSLPaletteMatrices;
	
	value_GL_MAX_SAMPLES = 1;				// Assume no multi-sampling support
	
	value_GL_MAX_VERTEX_UNITS = kCC3MaxGLSLVertexUnits;
}

// Start with at least the cocos2d attributes so they can be enabled and disabled
-(void) initVertexAttributes {
	[super initVertexAttributes];
	value_MaxVertexAttribsUsed = kCCVertexAttrib_MAX;
}

@end

#endif	// CC3_GLSL