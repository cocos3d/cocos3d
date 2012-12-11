/*
 * CC3GLProgram.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3GLProgram.h for full API documentation.
 */

#import "CC3GLProgram.h"
#import "CC3OpenGLESEngine.h"

#pragma mark -
#pragma mark CC3GLProgram

#if CC3_OGLES_2

@interface CC3OpenGLESShaders (TemplateMethods)
-(void) setActiveProgram: (CC3GLProgram*) aProgram;
@end

@implementation CC3GLProgram

@synthesize semanticDelegate=_semanticDelegate;
@synthesize maxUniformNameLength=_maxUniformNameLength;
@synthesize maxAttributeNameLength=_maxAttributeNameLength;

-(void) dealloc {
	[_uniforms release];
	[_attributes release];
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) initWithVertexShaderByteArray: (const GLchar*) vShaderByteArray
			fragmentShaderByteArray: (const GLchar*) fShaderByteArray {
	if ( (self = [super initWithVertexShaderByteArray: vShaderByteArray
							  fragmentShaderByteArray: fShaderByteArray]) ) {
		_uniforms = [CCArray new];		// retained
		_attributes = [CCArray new];	// retained
		_maxUniformNameLength = 0;
		_maxAttributeNameLength = 0;
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ GL program: %i, GL vtx shader: %i, GL frag shader: %i",
			[self class], program_, vertShader_, fragShader_];
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	for (id var in _uniforms) [desc appendFormat: @"\n\t %@", var];
	for (id var in _attributes) [desc appendFormat: @"\n\t %@", var];
	return desc;
}


#pragma mark Variables

-(CC3GLSLUniform*) uniformWithSemantic: (GLenum) semantic {
	for (CC3GLSLUniform* var in _uniforms) {
		if (var.semantic == semantic) return var;
	}
	return nil;
}

-(CC3GLSLAttribute*) attributeWithSemantic: (GLenum) semantic {
	for (CC3GLSLAttribute* var in _attributes) {
		if (var.semantic == semantic) return var;
	}
	return nil;
}

-(void) extractVariables {
	[self extractUniforms];
	[self extractAttributes];
}

-(void) extractUniforms {
	[_uniforms removeAllObjects];

	GLint varCnt;
	glGetProgramiv(program_, GL_ACTIVE_UNIFORMS, &varCnt);
	LogGLErrorTrace(@"while retrieving number of active uniforms in %@", self);
	glGetProgramiv(program_, GL_ACTIVE_UNIFORM_MAX_LENGTH, &_maxUniformNameLength);
	LogGLErrorTrace(@"while retrieving max uniform name length in %@", self);
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLUniform* var = [CC3GLSLUniform variableInProgram: self atIndex: varIdx];
		[_semanticDelegate assignUniformSemantic: var];
		[_uniforms addObject: var];
	}
}

-(void) extractAttributes {
	[_attributes removeAllObjects];
	
	GLint varCnt;
	glGetProgramiv(program_, GL_ACTIVE_ATTRIBUTES, &varCnt);
	LogGLErrorTrace(@"while retrieving number of active attributes in %@", self);
	glGetProgramiv(program_, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &_maxAttributeNameLength);
	LogGLErrorTrace(@"while retrieving max attribute name length in %@", self);
	for (GLint varIdx = 0; varIdx < varCnt; varIdx++) {
		CC3GLSLAttribute* var = [CC3GLSLAttribute variableInProgram: self atIndex: varIdx];
		[_semanticDelegate assignAttributeSemantic: var];
		[_attributes addObject: var];
	}
}

// Overridden to do nothing
-(void) updateUniforms {}


#pragma mark Binding

// Cache this program in the GL state tracker, bind the program to the GL engine,
// and populate the uniforms into the GL engine.
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLESEngine.engine.shaders.activeProgram = self;
	[self use];
	for (CC3GLSLUniform* var in _uniforms)
		[_semanticDelegate populateUniform: var withVisitor: visitor];
}


#pragma mark Compiling and linking


-(BOOL) compileShader: (GLuint*) shader type: (GLenum) type byteArray: (const GLchar*) source {
    GLint status;
	
    if (!source) return NO;
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
	LogGLErrorTrace(@"while specifying %@ shader source in %@", NSStringFromGLEnum(type), self);

    glCompileShader(*shader);
	LogGLErrorTrace(@"while compiling %@ shader in %@", NSStringFromGLEnum(type), self);
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	LogGLErrorTrace(@"while retrieving %@ shader status in %@", NSStringFromGLEnum(type), self);
	
	if( !status ) {
		GLsizei length;
		glGetShaderiv(*shader, GL_SHADER_SOURCE_LENGTH, &length);
		LogGLErrorTrace(@"while retrieving %@ shader source length in %@", NSStringFromGLEnum(type), self);

		GLchar src[length];
		glGetShaderSource(*shader, length, NULL, src);
		LogGLErrorTrace(@"while retrieving %@ shader source in %@", NSStringFromGLEnum(type), self);

		LogError(@"Failed to compile %@ shader in %@:\n%s", NSStringFromGLEnum(type), self, src);
		LogError(@"Compilation error log: %@",
				 (type == GL_VERTEX_SHADER ? [self vertexShaderLog] : [self fragmentShaderLog]));
	}
	 NSAssert2(status, @"Error compiling %@ shader in %@", NSStringFromGLEnum(type), self);
	return (status == GL_TRUE);
}


@end

#endif

#if CC3_OGLES_1

@implementation CC3GLProgram

-(GLint) maxUniformNameLength { return 0; }

-(GLint) maxAttributeNameLength { return 0; }

-(void) extractVariables {}

-(CC3GLSLUniform*) uniformWithSemantic: (GLenum) semantic { return nil; }

-(CC3GLSLAttribute*) attributeWithSemantic: (GLenum) semantic { return nil; }

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	for (id var in _uniforms) [desc appendFormat: @"\n\t %@", var];
	for (id var in _attributes) [desc appendFormat: @"\n\t %@", var];
	return desc;
}

@end

#endif
