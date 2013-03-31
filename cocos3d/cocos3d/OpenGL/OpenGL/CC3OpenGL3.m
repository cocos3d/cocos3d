/*
 * CC3OpenGL3.m
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

#import "CC3OpenGL3.h"
#import "CC3GLProgram.h"
#import "CC3NodeVisitor.h"

#if CC3_OGL

#import "kazmath/GL/matrix.h"	// Only OGL
#import "CC3GLProgram.h"

@interface CC3OpenGL (TemplateMethods)
-(void) clearUnboundVertexAttributes;
@end

@implementation CC3OpenGL3


#pragma mark Vertex attribute arrays

/**
 * Retrieve the program attribute that matches the specified semantic. Return the special
 * value kCC3VertexAttributeIndexUnavailable if either the program has no attribute with
 * the specified semantic or the attribute location is not valid.
 */
-(GLint) vertexAttributeIndexForSemantic: (GLenum) semantic
							 withVisitor: (CC3NodeDrawingVisitor*) visitor {

	GLuint semIdx = (semantic == kCC3SemanticVertexTexture) ? visitor.textureUnit : 0;
	CC3GLSLAttribute* attribute = [visitor.currentShaderProgram attributeForSemantic: semantic at: semIdx];
	
	if ( !attribute ) return kCC3VertexAttributeIndexUnavailable;

	GLint vaIdx = attribute.location;
	return (vaIdx < 0) ? kCC3VertexAttributeIndexUnavailable : vaIdx;
}

-(void) setVertexAttributeEnablementAt: (GLint) vaIdx {
	if (vertexAttributes[vaIdx].isEnabled)
		glEnableVertexAttribArray(vaIdx);
	else
		glDisableVertexAttribArray(vaIdx);
	LogGLErrorTrace(@"gl%@ableVertexAttribArray(%u)", (vertexAttributes[vaIdx].isEnabled ? @"En" : @"Dis"), vaIdx);
}

-(void) bindVertexAttributesAt: (GLint) vaIdx {
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
	for (GLuint vaIdx = 0; vaIdx < value_GL_MAX_VERTEX_ATTRIBS; vaIdx++) {
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


#pragma mark State

-(void) setClearDepth: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_DEPTH_CLEAR_VALUE, isKnown_GL_DEPTH_CLEAR_VALUE);
	if ( !needsUpdate ) return;
	glClearDepth(val);
	LogGLErrorTrace(@"glClearDepth(%.3f)", val);
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


#pragma mark Aligning 2D & 3D caches

-(void) align2DStateCache {
	ccGLBlendFunc(value_GL_BLEND_SRC, value_GL_BLEND_DST);
	ccGLBindTexture2DN(0, 0);
	
#if COCOS2D_VERSION < 0x020100
	if (valueCap_GL_BLEND) ccGLEnable(CC_GL_BLEND);
	else ccGLEnable(0);
#endif

	ccGLEnableVertexAttribs(kCCVertexAttribFlag_None);
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
	}
	return self;
}

-(void) initPlatformLimits {
	value_GL_MAX_CLIP_PLANES = kCC3MaxGLClipPlanes;

	value_GL_MAX_LIGHTS = kCC3MaxGLLights;
	
	value_GL_MAX_PALETTE_MATRICES = kCC3MaxGLPaletteMatrices;
	
	glGetIntegerv(GL_MAX_SAMPLES, &value_GL_MAX_SAMPLES);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_SAMPLES), value_GL_MAX_SAMPLES);
	LogInfo(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
	
	glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &value_GL_MAX_TEXTURE_UNITS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS), value_GL_MAX_TEXTURE_UNITS);
	LogInfo(@"Maximum texture units: %u", value_GL_MAX_TEXTURE_UNITS);

	glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &value_GL_MAX_VERTEX_ATTRIBS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_VERTEX_ATTRIBS), value_GL_MAX_VERTEX_ATTRIBS);
	LogInfo(@"Maximum vertex attributes: %u", value_GL_MAX_VERTEX_ATTRIBS);
	
	value_GL_MAX_VERTEX_UNITS = kCC3MaxGLVertexUnits;
}



@end

#endif