/*
 * CC3OpenGLES1.m
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
 * See header file CC3OpenGLES1.h for full API documentation.
 */

#import "CC3OpenGLES1.h"
#import "CC3ShaderSemantics.h"

#if CC3_OGLES_1

// Assertion macro to ensure only 2D textures are used
#define CC3Assert2DTexture(TARGET) CC3Assert((TARGET) == GL_TEXTURE_2D, @"Texture target %@ is"	\
			@" not available. OpenGLES 1.1 supports only 2D textures.", NSStringFromGLEnum(TARGET))


@interface CC3OpenGL (TemplateMethods)
-(void) setTexParamEnum: (GLenum) pName inTarget: (GLenum) target to: (GLenum) val at: (GLuint) tuIdx;
-(void) bindVertexContentToAttributeAt: (GLint) vaIdx;
-(void) initPlatformLimits;
-(void) initSurfaces;
-(void) initNonTextureVertexAttributes;
-(void) bindFramebuffer: (GLuint) fbID toTarget: (GLenum) fbTarget;
@end


#pragma mark CC3OpenGLES1

@implementation CC3OpenGLES1


#pragma mark Capabilities

-(void) enableMatrixPalette: (BOOL) onOff { cc3_SetGLCap(GL_MATRIX_PALETTE_OES, onOff, valueCap_GL_MATRIX_PALETTE, isKnownCap_GL_MATRIX_PALETTE); }

-(void) enablePointSprites: (BOOL) onOff { cc3_SetGLCap(GL_POINT_SPRITE_OES, onOff, valueCap_GL_POINT_SPRITE, isKnownCap_GL_POINT_SPRITE); }


#pragma mark Vertex attribute arrays

-(void) bindVertexContentToAttributeAt: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	switch (vaPtr->semantic) {
		case kCC3SemanticVertexBoneWeights:
			glWeightPointerOES(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glWeightPointerOES(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexBoneIndices:
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

/** Ensure target is GL_TEXTURE_2D. */
-(void) bindTexture: (GLuint) texID toTarget: (GLenum) target at: (GLuint) tuIdx {
	CC3Assert2DTexture(target);
	[super bindTexture: texID toTarget: target at: tuIdx];
}

/** Ensure target is GL_TEXTURE_2D. */
-(void) loadTexureImage: (const GLvoid*) imageData
			 intoTarget: (GLenum) target
		  onMipmapLevel: (GLint) mipmapLevel
			   withSize: (CC3IntSize) size
			 withFormat: (GLenum) texelFormat
			   withType: (GLenum) texelType
	  withByteAlignment: (GLint) byteAlignment
					 at: (GLuint) tuIdx {
	CC3Assert2DTexture(target);
	[super loadTexureImage: (const GLvoid*) imageData
				intoTarget: target
			 onMipmapLevel: mipmapLevel
				  withSize: size
				withFormat: texelFormat
				  withType: texelType
		 withByteAlignment: byteAlignment
						at: tuIdx];
}

/** Ensure target is GL_TEXTURE_2D. */
-(void) setTexParamEnum: (GLenum) pName inTarget: (GLenum) target to: (GLenum) val at: (GLuint) tuIdx {
	CC3Assert2DTexture(target);
	[super setTexParamEnum: pName inTarget: target to: val at: tuIdx];
}

/** Ensure target is GL_TEXTURE_2D. */
-(void) generateMipmapForTarget: (GLenum)target at: (GLuint) tuIdx {
	CC3Assert2DTexture(target);
	[super generateMipmapForTarget: target at: tuIdx];
}

-(void) enablePointSpriteCoordReplace: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_COORD_REPLACE, &isKnownCap_GL_COORD_REPLACE)) {
		[self activateTextureUnit: tuIdx];
		glTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, (onOff ? GL_TRUE : GL_FALSE));
		LogGLErrorTrace(@"glTexEnvi(%@, %@, %@)", NSStringFromGLEnum(GL_POINT_SPRITE_OES), NSStringFromGLEnum(GL_COORD_REPLACE_OES), (onOff ? @"GL_TRUE" : @"GL_FALSE"));
	}
}

-(void) disableTexturingAt: (GLuint) tuIdx {
	[self enableTexturing: NO inTarget: GL_TEXTURE_2D at: tuIdx];
	[self bindTexture: 0 toTarget: GL_TEXTURE_2D at: tuIdx];
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


#pragma mark Framebuffers

-(void) resolveMultisampleFramebuffer: (GLuint) fbSrcID intoFramebuffer: (GLuint) fbDstID {
	[self bindFramebuffer: fbSrcID toTarget: GL_READ_FRAMEBUFFER_APPLE];
	[self bindFramebuffer: fbDstID toTarget: GL_DRAW_FRAMEBUFFER_APPLE];
	glResolveMultisampleFramebufferAPPLE();
	LogGLErrorTrace(@"glResolveMultisampleFramebufferAPPLE()");
	[self bindFramebuffer: fbSrcID toTarget: GL_FRAMEBUFFER];
}

-(void) discard: (GLsizei) count attachments: (const GLenum*) attachments fromFramebuffer: (GLuint) fbID {
	[self bindFramebuffer: fbID];
	glDiscardFramebufferEXT(GL_FRAMEBUFFER, count, attachments);
	LogGLErrorTrace(@"glDiscardFramebufferEXT(%@. %i, %@, %@, %@)",
					NSStringFromGLEnum(GL_FRAMEBUFFER), count,
					NSStringFromGLEnum(count > 0 ? attachments[0] : 0),
					NSStringFromGLEnum(count > 1 ? attachments[1] : 0),
					NSStringFromGLEnum(count > 2 ? attachments[2] : 0));
}

-(void) allocateStorageForRenderbuffer: (GLuint) rbID
							  withSize: (CC3IntSize) size
							 andFormat: (GLenum) format
							andSamples: (GLuint) pixelSamples {
	[self bindRenderbuffer: rbID];
	if (pixelSamples > 1) {
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, pixelSamples, format, size.width, size.height);
		LogGLErrorTrace(@"glRenderbufferStorageMultisampleAPPLE(%@, %i, %@, %i, %i)",
						NSStringFromGLEnum(GL_RENDERBUFFER), pixelSamples,
						NSStringFromGLEnum(format), size.width, size.height);
	} else {
		glRenderbufferStorage(GL_RENDERBUFFER, format, size.width, size.height);
		LogGLErrorTrace(@"glRenderbufferStorage(%@, %@, %i, %i)", NSStringFromGLEnum(GL_RENDERBUFFER),
						NSStringFromGLEnum(format), size.width, size.height);
	}
}


#pragma mark Allocation and initialization

-(CC3GLContext*) makeRenderingGLContext {
	CC3GLContext* context = [[CC3GLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES1 sharegroup: nil];
	CC3Assert(context, @"Could not create CC3GLContext. OpenGL ES 1.1 is required.");
	return [context autorelease];
}

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_PALETTE_MATRICES = [self getInteger: GL_MAX_PALETTE_MATRICES_OES];
	LogInfoIfPrimary(@"Maximum palette matrices (max bones per mesh): %u", value_GL_MAX_PALETTE_MATRICES);
	
	valueMaxBoneInfluencesPerVertex = [self getInteger: GL_MAX_VERTEX_UNITS_OES];
	LogInfoIfPrimary(@"Available anti-aliasing samples: %u", valueMaxBoneInfluencesPerVertex);
}

/** Initialize the vertex attributes that are not texture coordinates. */
-(void) initNonTextureVertexAttributes {
	[super initNonTextureVertexAttributes];
	
	GLuint vaIdx = value_GL_MAX_VERTEX_ATTRIBS;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexBoneWeights;
	vertexAttributes[vaIdx].glName = GL_WEIGHT_ARRAY_OES;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexBoneIndices;
	vertexAttributes[vaIdx].glName = GL_MATRIX_INDEX_ARRAY_OES;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexPointSize;
	vertexAttributes[vaIdx].glName = GL_POINT_SIZE_ARRAY_OES;
	vaIdx++;
	
	value_GL_MAX_VERTEX_ATTRIBS = vaIdx;
}

@end


#pragma mark CC3OpenGLES1IOS

@implementation CC3OpenGLES1IOS

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_SAMPLES = [self getInteger: GL_MAX_SAMPLES_APPLE];
	LogInfoIfPrimary(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
}

@end


#pragma mark CC3OpenGLES1Android

@implementation CC3OpenGLES1Android

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_SAMPLES = 1;
	LogInfoIfPrimary(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
}

-(void) initSurfaces {
	[super initSurfaces];
	
	// Under Android, the on-screen surface is hardwired to framebuffer 0 and renderbuffer 0.
	// Apportable assumes that the first allocation of each is for the on-screen surface, and
	// therefore ignores that first allocation. We force that ignored allocation here, so that
	// off-screen surfaces can be allocated before the primary on-screen surface.
	[self generateRenderbuffer];
	[self generateFramebuffer];
}

@end

#endif	// CC3_OGLES_1