/*
 * CC3OpenGL2.m
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
 * See header file CC3OpenGLES2.h for full API documentation.
 */

#import "CC3OpenGL2.h"
#import "CC3GLProgram.h"
#import "CC3NodeVisitor.h"
#import "CC3Mesh.h"

#if CC3_OGL

@interface CC3OGL2_SUPERCLASS (TemplateMethods)
-(void) initPlatformLimits;
-(CC3VertexArray*) vertexArrayForAttribute: (CC3GLSLAttribute*) attribute
							   withVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@implementation CC3OpenGL2


#pragma mark Capabilities

-(void) enableShaderPointSize: (BOOL) onOff { cc3_SetGLCap(GL_VERTEX_PROGRAM_POINT_SIZE, onOff,
														   valueCap_GL_VERTEX_PROGRAM_POINT_SIZE,
														   isKnownCap_GL_VERTEX_PROGRAM_POINT_SIZE); }

-(void) enablePointSprites: (BOOL) onOff { cc3_SetGLCap(GL_POINT_SPRITE, onOff, valueCap_GL_POINT_SPRITE, isKnownCap_GL_POINT_SPRITE); }


#pragma mark Vertex attribute arrays

#if CC3_GLSL
/**
 * Returns the vertex array that should be bound to the specified attribute.
 *
 * Overridden to return the vertex locations array as a default if the real vertex array is
 * not available. This is to bypass failures in GLSL under OSX when attribute content is not
 * bound, even if the attribute is not accessed during the execution of the shader.
 */
-(CC3VertexArray*) vertexArrayForAttribute: (CC3GLSLAttribute*) attribute
							   withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3VertexArray* va = [super vertexArrayForAttribute: attribute withVisitor: visitor];
	return va ? va : visitor.currentMesh.vertexLocations;
}
#endif	// CC3_OGL


#pragma mark State

-(void) setClearDepth: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_DEPTH_CLEAR_VALUE, isKnown_GL_DEPTH_CLEAR_VALUE);
	if ( !needsUpdate ) return;
	glClearDepth(val);
	LogGLErrorTrace(@"glClearDepth(%.3f)", val);
}


#pragma mark Textures

-(void) enablePointSpriteCoordReplace: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_COORD_REPLACE, &isKnownCap_GL_COORD_REPLACE)) {
		[self activateTextureUnit: tuIdx];
		glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, (onOff ? GL_TRUE : GL_FALSE));
		LogGLErrorTrace(@"glTexEnvi(%@, %@, %@)", NSStringFromGLEnum(GL_POINT_SPRITE), NSStringFromGLEnum(GL_COORD_REPLACE), (onOff ? @"GL_TRUE" : @"GL_FALSE"));
	}
}


#pragma mark Shaders

-(NSString*) defaultShaderPreamble {
	return
		@"#version 120\n"
		@"#define precision //precision\n"
		@"#define highp\n"
		@"#define mediump\n"
		@"#define lowp\n";
}


#pragma mark Allocation and initialization

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	glGetIntegerv(GL_MAX_SAMPLES, &value_GL_MAX_SAMPLES);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_SAMPLES), value_GL_MAX_SAMPLES);
	LogInfo(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
}

@end

#endif	// CC3_OGL && CC3_GLSL