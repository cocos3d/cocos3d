/*
 * CC3OpenGLES1.m
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
 * See header file CC3OpenGLES1.h for full API documentation.
 */

#import "CC3OpenGLES1.h"
#import "CC3GLProgramSemantics.h"

#if CC3_OGLES_1

@interface CC3OpenGL (TemplateMethods)
-(void) setTexParamEnum: (GLenum) pName inTarget: (GLenum) target to: (GLenum) val at: (GLuint) tuIdx;
-(void) bindVertexContentToAttributeAt: (GLint) vaIdx;
-(void) initPlatformLimits;
-(void) initVertexAttributes;
@end

@implementation CC3OpenGLES1


#pragma mark Capabilities

-(void) enableMatrixPalette: (BOOL) onOff { cc3_SetGLCap(GL_MATRIX_PALETTE_OES, onOff, valueCap_GL_MATRIX_PALETTE, isKnownCap_GL_MATRIX_PALETTE); }

-(void) enablePointSprites: (BOOL) onOff { cc3_SetGLCap(GL_POINT_SPRITE_OES, onOff, valueCap_GL_POINT_SPRITE, isKnownCap_GL_POINT_SPRITE); }


#pragma mark Vertex attribute arrays

-(void) bindVertexContentToAttributeAt: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	switch (vaPtr->semantic) {
		case kCC3SemanticVertexWeights:
			glWeightPointerOES(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glWeightPointerOES(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexMatrixIndices:
			glMatrixIndexPointerOES(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glMatrixIndexPointerOES(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexPointSize:
			glPointSizePointerOES(vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glPointSizePointerOES(%@, %i, %p)", NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		default:
			[super bindVertexContentToAttributeAt: vaIdx];
			break;
	}
}


#pragma mark Lighting

-(void) setFogMode: (GLenum) mode {
	cc3_CheckGLPrim(mode, value_GL_FOG_MODE, isKnown_GL_FOG_MODE);
	if ( !needsUpdate ) return;
	glFogx(GL_FOG_MODE, mode);
	LogGLErrorTrace(@"glFogfv(%@, %@)", NSStringFromGLEnum(GL_FOG_MODE), NSStringFromGLEnum(mode));
}


#pragma mark Textures

/** 
 * If target is not GL_TEXTURE_2D, we're trying to bind the texture to an illegal target.
 * In that case, just bind the GL_TEXTURE_2D to no texture.
 */
-(void) bindTexture: (GLuint) texID toTarget: (GLenum) target at: (GLuint) tuIdx {
	if (target != GL_TEXTURE_2D) {
		target = GL_TEXTURE_2D;
		texID = 0;
	}
	[super bindTexture: texID toTarget: target at: tuIdx];
}

/** Ensure target is GL_TEXTURE_2D. */
-(void) loadTexureImage: (const GLvoid*) imageData
			 intoTarget: (GLenum) target
			   withSize: (CC3IntSize) size
			 withFormat: (GLenum) texelFormat
			   withType: (GLenum) texelType
	  withByteAlignment: (GLint) byteAlignment
					 at: (GLuint) tuIdx {
	if (target == GL_TEXTURE_2D)
		[super loadTexureImage: imageData
					intoTarget: target
					  withSize: size
					withFormat: texelFormat
					  withType: texelType
			 withByteAlignment: byteAlignment
							at: tuIdx];
}

/** Ensure target is GL_TEXTURE_2D. */
-(void) setTexParamEnum: (GLenum) pName inTarget: (GLenum) target to: (GLenum) val at: (GLuint) tuIdx {
	if (target == GL_TEXTURE_2D) [super setTexParamEnum: pName inTarget: target to: val at: tuIdx];
}

/** Ensure target is GL_TEXTURE_2D. */
-(void) generateMipmapForTarget: (GLenum)target at: (GLuint) tuIdx {
	if (target == GL_TEXTURE_2D) [super generateMipmapForTarget: target at: tuIdx];
}

-(void) enablePointSpriteCoordReplace: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_COORD_REPLACE, &isKnownCap_GL_COORD_REPLACE)) {
		[self activateTextureUnit: tuIdx];
		glTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, (onOff ? GL_TRUE : GL_FALSE));
		LogGLErrorTrace(@"glTexEnvi(%@, %@, %@)", NSStringFromGLEnum(GL_POINT_SPRITE_OES), NSStringFromGLEnum(GL_COORD_REPLACE_OES), (onOff ? @"GL_TRUE" : @"GL_FALSE"));
	}
}


#pragma mark Matrices

-(void) activatePaletteMatrixStack: (GLuint) pmIdx {
	CC3Assert(pmIdx < value_GL_MAX_PALETTE_MATRICES, @"The palette index %u exceeds the maximum number of"
			  @" %u palette matrices available on this platform", pmIdx, value_GL_MAX_PALETTE_MATRICES);
	[self activateMatrixStack: GL_MATRIX_PALETTE_OES];
	cc3_CheckGLPrim(pmIdx, value_GL_MATRIX_PALETTE, isKnown_GL_MATRIX_PALETTE);
	if ( !needsUpdate ) return;
	glCurrentPaletteMatrixOES(pmIdx);
	LogGLErrorTrace(@"glCurrentPaletteMatrixOES(%u)", pmIdx);
}


#pragma mark Allocation and initialization

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	glGetIntegerv(GL_MAX_PALETTE_MATRICES_OES, &value_GL_MAX_PALETTE_MATRICES);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_PALETTE_MATRICES_OES), value_GL_MAX_PALETTE_MATRICES);
	LogInfo(@"Maximum palette matrices (max bones per mesh): %u", value_GL_MAX_PALETTE_MATRICES);
	
	glGetIntegerv(GL_MAX_SAMPLES_APPLE, &value_GL_MAX_SAMPLES);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_SAMPLES_APPLE), value_GL_MAX_SAMPLES);
	LogInfo(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
	
	glGetIntegerv(GL_MAX_VERTEX_UNITS_OES, &value_GL_MAX_VERTEX_UNITS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_VERTEX_UNITS_OES), value_GL_MAX_VERTEX_UNITS);
	LogInfo(@"Available anti-aliasing samples: %u", value_GL_MAX_VERTEX_UNITS);
}

/**
 * Under OGLES 1.1, the vertex attribute arrays each have a fixed purpose. Invokes super
 * to allocate the trackers and initialize the semantic and GL name of each common tracker.
 * Then adds semantics and GL names for trackers that are specific to OGLES 1.1.
 *
 * This method updates the value_GL_MAX_VERTEX_ATTRIBS property.
 */
-(void) initVertexAttributes {
	[super initVertexAttributes];
	
	GLuint vaIdx = value_GL_MAX_VERTEX_ATTRIBS;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexWeights;
	vertexAttributes[vaIdx].glName = GL_WEIGHT_ARRAY_OES;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexMatrixIndices;
	vertexAttributes[vaIdx].glName = GL_MATRIX_INDEX_ARRAY_OES;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexPointSize;
	vertexAttributes[vaIdx].glName = GL_POINT_SIZE_ARRAY_OES;
	vaIdx++;
	
	value_GL_MAX_VERTEX_ATTRIBS = vaIdx;
}

@end

#endif	// CC3_OGLES_1