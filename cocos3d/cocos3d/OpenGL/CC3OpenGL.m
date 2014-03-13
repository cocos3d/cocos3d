/*
 * CC3OpenGL.m
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
 * See header file CC3OpenGL.h for full API documentation.
 */

#import "CC3OpenGL.h"
#import "CC3OpenGLES2.h"
#import "CC3OpenGLES1.h"
#import "CC3OpenGL2.h"

#import "CC3OSExtensions.h"
#import "CC3CC2Extensions.h"
#import "CC3GLSLVariable.h"
#import "CC3ShaderMatcher.h"
#import "CC3Backgrounder.h"
#import "CC3Resource.h"
#import "CC3Texture.h"
#import "CC3Shaders.h"


/** Extension to keep the compiler happy for dynamic classes. */
@interface NSObject(CC3ModelSampleFactory)
+ (void) deleteFactory;
@end


#pragma mark CC3OpenGL

@implementation CC3OpenGL

@synthesize context=_context, deletionDelay=_deletionDelay;

-(void) dealloc {
	LogInfo(@"Deallocating %@ and closing OpenGL on %@.", self, NSThread.currentThread);

	[_context release];
	[_extensions release];
	[value_GL_VENDOR release];
	[value_GL_RENDERER release];
	[value_GL_VERSION release];
	
	free(vertexAttributes);
	free(value_GL_TEXTURE_BINDING_2D);
	free(value_GL_TEXTURE_BINDING_CUBE_MAP);
	
	[super dealloc];
}

static NSObject<CC3OpenGLDelegate>* _delegate = nil;

+(NSObject<CC3OpenGLDelegate>*) delegate { return _delegate; }

+(void) setDelegate: (NSObject<CC3OpenGLDelegate>*) delegate {
	if (delegate == _delegate) return;

	[_delegate release];
	_delegate = [delegate retain];
}


#pragma mark Capabilities

-(void) enableAlphaTesting: (BOOL) onOff {}

-(void) enableBlend: (BOOL) onOff { cc3_SetGLCap(GL_BLEND, onOff, valueCap_GL_BLEND, isKnownCap_GL_BLEND); }

-(void) enableClipPlane: (BOOL) onOff at: (GLuint) clipIdx {}

-(void) enableColorLogicOp: (BOOL) onOff {}

-(void) enableColorMaterial: (BOOL) onOff {}

-(void) enableCullFace: (BOOL) onOff { cc3_SetGLCap(GL_CULL_FACE, onOff, valueCap_GL_CULL_FACE, isKnownCap_GL_CULL_FACE); }

-(void) enableDepthTest: (BOOL) onOff { cc3_SetGLCap(GL_DEPTH_TEST, onOff, valueCap_GL_DEPTH_TEST, isKnownCap_GL_DEPTH_TEST); }

-(void) enableDither: (BOOL) onOff { cc3_SetGLCap(GL_DITHER, onOff, valueCap_GL_DITHER, isKnownCap_GL_DITHER); }

-(void) enableFog: (BOOL) onOff {}

-(void) enableLineSmoothing: (BOOL) onOff {}

-(void) enableMatrixPalette: (BOOL) onOff {}

-(void) enableMultisampling: (BOOL) onOff {}

-(void) enableNormalize: (BOOL) onOff {}

-(void) enablePointSmoothing: (BOOL) onOff {}

-(void) enablePointSprites: (BOOL) onOff {}

-(void) enableShaderPointSize: (BOOL) onOff {}

-(void) enablePolygonOffset: (BOOL) onOff { cc3_SetGLCap(GL_POLYGON_OFFSET_FILL, onOff, valueCap_GL_POLYGON_OFFSET_FILL, isKnownCap_GL_POLYGON_OFFSET_FILL); }

-(void) enableRescaleNormal: (BOOL) onOff {}

-(void) enableSampleAlphaToCoverage: (BOOL) onOff { cc3_SetGLCap(GL_SAMPLE_ALPHA_TO_COVERAGE, onOff, valueCap_GL_SAMPLE_ALPHA_TO_COVERAGE, isKnownCap_GL_SAMPLE_ALPHA_TO_COVERAGE); }

-(void) enableSampleAlphaToOne: (BOOL) onOff {}

-(void) enableSampleCoverage: (BOOL) onOff { cc3_SetGLCap(GL_SAMPLE_COVERAGE, onOff, valueCap_GL_SAMPLE_COVERAGE, isKnownCap_GL_SAMPLE_COVERAGE); }

-(void) enableScissorTest: (BOOL) onOff { cc3_SetGLCap(GL_SCISSOR_TEST, onOff, valueCap_GL_SCISSOR_TEST, isKnownCap_GL_SCISSOR_TEST); }

-(void) enableStencilTest: (BOOL) onOff { cc3_SetGLCap(GL_STENCIL_TEST, onOff, valueCap_GL_STENCIL_TEST, isKnownCap_GL_STENCIL_TEST); }


#pragma mark Vertex attribute arrays

-(void) bindMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) bindVertexAttribute: (CC3GLSLAttribute*) attribute withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) enableVertexAttribute: (BOOL) onOff at: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	
	// If we know the state and it is not changing, do nothing.
	if (vaPtr->isEnabledKnown && CC3BooleansAreEqual(vaPtr->isEnabled, onOff)) return;
	
	vaPtr->isEnabled = onOff;
	vaPtr->isEnabledKnown = YES;
	
	[self setVertexAttributeEnablementAt: vaIdx];
}

-(void) setVertexAttributeEnablementAt: (GLint) vaIdx {
	CC3AssertUnimplemented(@"setVertexAttributeEnablementAt:");
}

-(void) bindVertexContent: (GLvoid*) pData
				 withSize: (GLint) elemSize
				 withType: (GLenum) elemType
			   withStride: (GLsizei) vtxStride
	  withShouldNormalize: (BOOL) shldNorm
			toAttributeAt: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	
	BOOL shouldSetGL = YES;		// TODO - fix errors drawing multiple line strips when not bound every time (eg teapots)
//	BOOL shouldSetGL = !vaPtr->isKnown;
	shouldSetGL |= (pData != vaPtr->vertices);
	shouldSetGL |= (elemSize != vaPtr->elementSize);
	shouldSetGL |= (elemType != vaPtr->elementType);
	shouldSetGL |= (vtxStride != vaPtr->vertexStride);
	shouldSetGL |= (shldNorm != vaPtr->shouldNormalize);
	if (shouldSetGL) {
		vaPtr->vertices = pData;
		vaPtr->elementSize = elemSize;
		vaPtr->elementType = elemType;
		vaPtr->vertexStride = vtxStride;
		vaPtr->shouldNormalize = shldNorm;
		vaPtr->isKnown = YES;
		[self bindVertexContentToAttributeAt: vaIdx];
	}
	vaPtr->wasBound = YES;
	value_MaxVertexAttribsUsed = MAX(value_MaxVertexAttribsUsed, vaIdx + 1);
}

-(void) bindVertexContentToAttributeAt: (GLint) vaIdx { CC3AssertUnimplemented(@"bindVertexContentToAttributeAt:"); }

-(void) clearUnboundVertexAttributes {
	for (GLuint vaIdx = 0; vaIdx < value_MaxVertexAttribsUsed; vaIdx++)
		vertexAttributes[vaIdx].wasBound = NO;
}

-(void) enableBoundVertexAttributes {
	for (GLuint vaIdx = 0; vaIdx < value_MaxVertexAttribsUsed; vaIdx++)
		[self enableVertexAttribute: (vertexAttributes[vaIdx].wasBound) at: vaIdx];
}

-(void) enable2DVertexAttributes { CC3AssertUnimplemented(@"enable2DVertexAttributes"); }

-(GLuint) generateBuffer {
	GLuint buffID;
	glGenBuffers(1, &buffID);
	LogGLErrorTrace(@"glGenBuffers(%i, %u)", 1, buffID);
	return buffID;
}

-(void) deleteBuffer: (GLuint) buffID  {
	if ( !buffID ) return;		// Silently ignore zero ID
	glDeleteBuffers(1, &buffID);
	LogGLErrorTrace(@"glDeleteBuffers(%i, %u)", 1, buffID);

	// If the deleted buffer is currently bound, the GL engine will automatically
	// bind to the empty buffer ID (0). Update the state tracking accordingly.
	if (value_GL_ARRAY_BUFFER_BINDING == buffID)
		value_GL_ARRAY_BUFFER_BINDING = 0;
	if (value_GL_ELEMENT_ARRAY_BUFFER_BINDING == buffID)
		value_GL_ELEMENT_ARRAY_BUFFER_BINDING = 0;
}

-(void) bindBuffer: (GLuint) buffId  toTarget: (GLenum) target {
	if (target == GL_ELEMENT_ARRAY_BUFFER) {
		cc3_CheckGLPrim(buffId, value_GL_ELEMENT_ARRAY_BUFFER_BINDING, isKnown_GL_ELEMENT_ARRAY_BUFFER_BINDING);
		if ( !needsUpdate ) return;
	} else {
		cc3_CheckGLPrim(buffId, value_GL_ARRAY_BUFFER_BINDING, isKnown_GL_ARRAY_BUFFER_BINDING);
		if ( !needsUpdate ) return;
	}
	[self bindVertexArrayObject: 0];	// Ensure that a VAO was not left in place by cocos2d
	glBindBuffer(target, buffId);
	LogGLErrorTrace(@"glBindBuffer(%@, %u)", NSStringFromGLEnum(target), buffId);
}

-(void) unbindBufferTarget: (GLenum) target { [self bindBuffer: 0 toTarget: target]; }

-(void) loadBufferTarget: (GLenum) target
				withData: (GLvoid*) buffPtr
				ofLength: (GLsizeiptr) buffLen
				  forUse: (GLenum) buffUsage {
	glBufferData(target, buffLen, buffPtr, buffUsage);
	LogGLErrorTrace(@"glBufferData(%@, %i, %p, %@)", NSStringFromGLEnum(target), buffLen, buffPtr, NSStringFromGLEnum(buffUsage));
}

-(void) updateBufferTarget: (GLenum) target
				  withData: (GLvoid*) buffPtr
				startingAt: (GLintptr) offset
				 forLength: (GLsizeiptr) length {
	glBufferSubData(target, offset, length, buffPtr);
	LogGLErrorTrace(@"glBufferSubData(%@, %i, %i, %p)", NSStringFromGLEnum(target), offset, length, buffPtr);
}

-(void) bindVertexArrayObject: (GLuint) vaoId {
	// Binding to VAO's is not supported on a background thread.
	// iOS & OSX do support background VAO's, but they are not shared across contexts.
	// Android seems to share the VAO binding state across contexts, which causes
	// interference between threads.
	if ( !self.isRenderingContext ) return;

#if COCOS2D_VERSION >= 0x020100
	// If available, use cocos2d state management. This method can be invoked from outside
	// the main rendering path (ie- during buffer loading), so cocos2d state must be honoured.
	ccGLBindVAO(vaoId);

#else
	cc3_CheckGLPrim(vaoId, value_GL_VERTEX_ARRAY_BINDING, isKnown_GL_VERTEX_ARRAY_BINDING);
	if ( !needsUpdate ) return;
	glBindVertexArray(vaoId);
	LogGLErrorTrace(@"glBindVertexArray(%u)", vaoId);

#endif	// COCOS2D_VERSION >= 0x020100
}

-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len {
	glDrawArrays(drawMode, start, len);
	LogGLErrorTrace(@"glDrawArrays(%@, %u, %u)", NSStringFromGLEnum(drawMode), start, len);
	CC_INCREMENT_GL_DRAWS(1);
}

-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode {
#if CC3_OGLES
	CC3Assert((type == GL_UNSIGNED_SHORT || type == GL_UNSIGNED_BYTE),
			  @"OpenGL ES permits drawing a maximum of 65536 indexed vertices, and supports only"
			  @" GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE types for vertex indices");
#endif
	glDrawElements(drawMode, len, type, indicies);
	LogGLErrorTrace(@"glDrawElements(%@, %u, %@, %p)", NSStringFromGLEnum(drawMode), len, NSStringFromGLEnum(type), indicies);
	CC_INCREMENT_GL_DRAWS(1);
}


#pragma mark State

-(void) setClearColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, value_GL_COLOR_CLEAR_VALUE),
					 value_GL_COLOR_CLEAR_VALUE, isKnown_GL_COLOR_CLEAR_VALUE);
	if ( !needsUpdate ) return;
	glClearColor(color.r, color.g, color.b, color.a);
	LogGLErrorTrace(@"glClearColor%@", NSStringFromCCC4F(color));
}

-(void) setClearDepth: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_DEPTH_CLEAR_VALUE, isKnown_GL_DEPTH_CLEAR_VALUE);
	if ( !needsUpdate ) return;
	glClearDepth(val);
	LogGLErrorTrace(@"glClearDepth(%.3f)", val);
}

-(void) setClearStencil: (GLint) val {
	cc3_CheckGLPrim(val, value_GL_STENCIL_CLEAR_VALUE, isKnown_GL_STENCIL_CLEAR_VALUE);
	if ( !needsUpdate ) return;
	glClearStencil(val);
	LogGLErrorTrace(@"glClearStencil(%i)", val);
}

-(void) setColor: (ccColor4F) color {}

-(void) setColorMask: (ccColor4B) mask {
	// Normalize the mask to strictly 0 or 1 in each component.
	ccColor4B maskBools = ccc4(mask.r != 0, mask.g != 0, mask.b != 0, mask.a != 0);
	cc3_CheckGLValue(maskBools, CCC4BAreEqual(maskBools, value_GL_COLOR_WRITEMASK),
					 value_GL_COLOR_WRITEMASK, isKnown_GL_COLOR_WRITEMASK);
	if ( !needsUpdate ) return;
	glColorMask(maskBools.r, maskBools.g, maskBools.b, maskBools.a);
	LogGLErrorTrace(@"glColorMask%@", NSStringFromCCC4B(mask));
}

-(void) setCullFace: (GLenum) val {
	cc3_CheckGLPrim(val, value_GL_CULL_FACE_MODE, isKnown_GL_CULL_FACE_MODE);
	if ( !needsUpdate ) return;
	glCullFace(val);
	LogGLErrorTrace(@"glCullFace(%@)", NSStringFromGLEnum(val));
}

-(void) setDepthFunc: (GLenum) val {
	cc3_CheckGLPrim(val, value_GL_DEPTH_FUNC, isKnown_GL_DEPTH_FUNC);
	if ( !needsUpdate ) return;
	glDepthFunc(val);
	LogGLErrorTrace(@"glDepthFunc(%@)", NSStringFromGLEnum(val));
}

-(void) setDepthMask: (BOOL) writable {
	cc3_CheckGLValue(writable, CC3BooleansAreEqual(writable, value_GL_DEPTH_WRITEMASK),
					 value_GL_DEPTH_WRITEMASK, isKnown_GL_DEPTH_WRITEMASK);
	if ( !needsUpdate ) return;
	glDepthMask(writable);
	LogGLErrorTrace(@"glDepthMask(%@)", NSStringFromBoolean(writable));
}

-(void) setFrontFace: (GLenum) val {
	cc3_CheckGLPrim(val, value_GL_FRONT_FACE, isKnown_GL_FRONT_FACE);
	if ( !needsUpdate ) return;
	glFrontFace(val);
	LogGLErrorTrace(@"glFrontFace(%@)", NSStringFromGLEnum(val));
}

-(void) setLineWidth: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_LINE_WIDTH, isKnown_GL_LINE_WIDTH);
	if ( !needsUpdate ) return;
	glLineWidth(val);
	LogGLErrorTrace(@"glLineWidth(%.3f)", val);
}

-(void) setPointSize: (GLfloat) val {}

-(void) setPointSizeAttenuation: (CC3AttenuationCoefficients) ac {}

-(void) setPointSizeFadeThreshold: (GLfloat) val {}

-(void) setPointSizeMinimum: (GLfloat) val {}

-(void) setPointSizeMaximum: (GLfloat) val {}

-(void) setPolygonOffsetFactor: (GLfloat) factor units: (GLfloat) units {
	if ((factor != value_GL_POLYGON_OFFSET_FACTOR) ||
		(units != value_GL_POLYGON_OFFSET_UNITS) ||
		!isKnownPolygonOffset) {
		value_GL_POLYGON_OFFSET_FACTOR = factor;
		value_GL_POLYGON_OFFSET_UNITS = units;
		isKnownPolygonOffset = YES;
		glPolygonOffset(factor, units);
		LogGLErrorTrace(@"glPolygonOffset(%.3f, %.3f)", factor, units);
	}
}

-(void) setScissor: (CC3Viewport) vp {
	cc3_CheckGLValue(vp, CC3ViewportsAreEqual(vp, value_GL_SCISSOR_BOX),
					 value_GL_SCISSOR_BOX, isKnown_GL_SCISSOR_BOX);
	if ( !needsUpdate ) return;
	glScissor(vp.x, vp.y, vp.w, vp.h);
	LogGLErrorTrace(@"glScissor%@", NSStringFromCC3Viewport(vp));
}

-(void) setShadeModel: (GLenum) val {}

-(void) setStencilFunc: (GLenum) func reference: (GLint) ref mask: (GLuint) mask {
	if ((func != value_GL_STENCIL_FUNC) ||
		(ref != value_GL_STENCIL_REF) ||
		(mask != value_GL_STENCIL_VALUE_MASK) ||
		!isKnownStencilFunc) {
		value_GL_STENCIL_FUNC = func;
		value_GL_STENCIL_REF = ref;
		value_GL_STENCIL_VALUE_MASK = mask;
		isKnownStencilFunc = YES;
		glStencilFunc(func, ref, mask);
		LogGLErrorTrace(@"glStencilFunc(%@, %i, %u)",
						NSStringFromGLEnum(func), ref, mask);
	}
}

-(void) setStencilMask: (GLuint) mask {
	cc3_CheckGLPrim(mask, value_GL_STENCIL_WRITEMASK, isKnown_GL_STENCIL_WRITEMASK);
	if ( !needsUpdate ) return;
	glStencilMask(mask);
	LogGLErrorTrace(@"glStencilMask(%x)", mask);
}

-(void) setOpOnStencilFail: (GLenum) sFail onDepthFail: (GLenum) zFail onDepthPass: (GLenum) zPass {
	if ((sFail != value_GL_STENCIL_FAIL) ||
		(zFail != value_GL_STENCIL_PASS_DEPTH_FAIL) ||
		(zPass != value_GL_STENCIL_PASS_DEPTH_PASS) ||
		!isKnownStencilOp) {
		value_GL_STENCIL_FAIL = sFail;
		value_GL_STENCIL_PASS_DEPTH_FAIL = zFail;
		value_GL_STENCIL_PASS_DEPTH_PASS = zPass;
		isKnownStencilOp = YES;
		glStencilOp(sFail, zFail, zPass);
		LogGLErrorTrace(@"glStencilOp(%@, %@, %@)", NSStringFromGLEnum(sFail), NSStringFromGLEnum(zFail), NSStringFromGLEnum(zPass));
	}
}

-(void) setViewport: (CC3Viewport) vp {
	cc3_CheckGLValue(vp, CC3ViewportsAreEqual(vp, value_GL_VIEWPORT),
					 value_GL_VIEWPORT, isKnown_GL_VIEWPORT);
	if ( !needsUpdate ) return;
	glViewport(vp.x, vp.y, vp.w, vp.h);
	LogGLErrorTrace(@"glViewport%@", NSStringFromCC3Viewport(vp));
}


#pragma mark Lighting

-(void) enableLighting: (BOOL) onOff {}

-(void) enableTwoSidedLighting: (BOOL) onOff {}

-(void) setSceneAmbientLightColor: (ccColor4F) color {}

-(void) enableLight: (BOOL) onOff at: (GLuint) ltIdx {}

-(void) setLightAmbientColor: (ccColor4F) color at: (GLuint) ltIdx {}

-(void) setLightDiffuseColor: (ccColor4F) color at: (GLuint) ltIdx {}

-(void) setLightSpecularColor: (ccColor4F) color at: (GLuint) ltIdx {}

-(void) setLightPosition: (CC3Vector4) pos at: (GLuint) ltIdx {}

-(void) setLightAttenuation: (CC3AttenuationCoefficients) ac at: (GLuint) ltIdx {}

-(void) setSpotlightDirection: (CC3Vector) dir at: (GLuint) ltIdx {}

-(void) setSpotlightFadeExponent: (GLfloat) val at: (GLuint) ltIdx {}

-(void) setSpotlightCutoffAngle: (GLfloat) val at: (GLuint) ltIdx {}

-(void) bindFog: (CC3Fog*) fog withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) setFogColor: (ccColor4F) color {}

-(void) setFogMode: (GLenum) mode {}

-(void) setFogDensity: (GLfloat) val {}

-(void) setFogStart: (GLfloat) val {}

-(void) setFogEnd: (GLfloat) val {}


#pragma mark Materials

-(void) setMaterialAmbientColor: (ccColor4F) color {}

-(void) setMaterialDiffuseColor: (ccColor4F) color {}

-(void) setMaterialSpecularColor: (ccColor4F) color {}

-(void) setMaterialEmissionColor: (ccColor4F) color {}

-(void) setMaterialShininess: (GLfloat) val {}

-(void) setAlphaFunc: (GLenum) func reference: (GLfloat) ref {}

-(void) setBlendFuncSrc: (GLenum) src dst: (GLenum) dst {
	[self setBlendFuncSrcRGB: src dstRGB: dst srcAlpha: src dstAlpha: dst];
}

-(void) setBlendFuncSrcRGB: (GLenum) srcRGB dstRGB: (GLenum) dstRGB
				  srcAlpha: (GLenum) srcAlpha dstAlpha: (GLenum) dstAlpha {
	if ((srcRGB == value_GL_BLEND_SRC_RGB) &&
		(dstRGB == value_GL_BLEND_DST_RGB) &&
		(srcAlpha == value_GL_BLEND_SRC_ALPHA) &&
		(dstAlpha == value_GL_BLEND_DST_ALPHA) &&
		isKnownBlendFunc) return;
	
	value_GL_BLEND_SRC_RGB = srcRGB;
	value_GL_BLEND_DST_RGB = dstRGB;
	value_GL_BLEND_SRC_ALPHA = srcAlpha;
	value_GL_BLEND_DST_ALPHA = dstAlpha;
	isKnownBlendFunc = YES;
	glBlendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
	LogGLErrorTrace(@"glBlendFuncSeparate(%@, %@, %@, %@)",
					NSStringFromGLEnum(srcRGB), NSStringFromGLEnum(dstRGB),
					NSStringFromGLEnum(srcAlpha), NSStringFromGLEnum(dstAlpha));
}


#pragma mark Textures

-(GLuint) generateTexture {
	GLuint texID;
	glGenTextures(1, &texID);
	LogGLErrorTrace(@"glGenTextures(%i, %u)", 1, texID);
	return texID;
}

-(void) deleteTexture: (GLuint) texID {
	if ( !texID ) return;		// Silently ignore zero texture ID
	glDeleteTextures(1, &texID);
	LogGLErrorTrace(@"glDeleteTextures(%i, %u)", 1, texID);

    // If the deleted texture is currently bound to a texture unit, the GL engine will automatically
	// bind the default texture ID (0) to that texture unit. Update the state tracking accordingly.
    [self clearTextureBinding: texID];
}

-(void) clearTextureBinding: (GLuint) texID {
	GLuint maxTexUnits = value_MaxTextureUnitsUsed;
	for (GLuint tuIdx = 0; tuIdx < maxTexUnits; tuIdx++) {
		if (value_GL_TEXTURE_BINDING_2D[tuIdx] == texID)
			value_GL_TEXTURE_BINDING_2D[tuIdx] = 0;
		if (value_GL_TEXTURE_BINDING_CUBE_MAP[tuIdx] == texID)
			value_GL_TEXTURE_BINDING_CUBE_MAP[tuIdx] = 0;
	}
}

-(void) loadTexureImage: (const GLvoid*) imageData
			 intoTarget: (GLenum) target
		  onMipmapLevel: (GLint) mipmapLevel
			   withSize: (CC3IntSize) size
			 withFormat: (GLenum) texelFormat
			   withType: (GLenum) texelType
	  withByteAlignment: (GLint) byteAlignment
					 at: (GLuint) tuIdx {

	CC3Assert(size.width <= [self maxTextureSizeForTarget: target] && size.height <= [self maxTextureSizeForTarget: target],
			  @"%@ exceeds the maximum texture size, %u per side, for target %@",
			  NSStringFromCC3IntSize(size), [self maxTextureSizeForTarget: target], NSStringFromGLEnum(target));

	[self activateTextureUnit: tuIdx];
	[self setPixelUnpackingAlignment: byteAlignment];
	glTexImage2D(target, mipmapLevel, texelFormat, size.width, size.height, 0, texelFormat, texelType, imageData);
	LogGLErrorTrace(@"glTexImage2D(%@, %i, %@, %i, %i, %i, %@, %@, %p)",
					NSStringFromGLEnum(target), mipmapLevel, NSStringFromGLEnum(texelFormat), size.width, size.height,
					0, NSStringFromGLEnum(texelFormat), NSStringFromGLEnum(texelType), imageData);
}

-(void) loadTexureSubImage: (const GLvoid*) imageData
				intoTarget: (GLenum) target
			 onMipmapLevel: (GLint) mipmapLevel
			 intoRectangle: (CC3Viewport) rect
				withFormat: (GLenum) texelFormat
				  withType: (GLenum) texelType
		 withByteAlignment: (GLint) byteAlignment
						at: (GLuint) tuIdx {

	[self activateTextureUnit: tuIdx];
	[self setPixelUnpackingAlignment: byteAlignment];
	glTexSubImage2D(target, mipmapLevel, rect.x, rect.y, rect.w, rect.h, texelFormat, texelType, imageData);
	LogGLErrorTrace(@"glTexSubImage2D(%@, %i, %i, %i, %i, %i, %@, %@, %p)",
					NSStringFromGLEnum(target), mipmapLevel, rect.x, rect.y, rect.w, rect.h,
					NSStringFromGLEnum(texelFormat), NSStringFromGLEnum(texelType), imageData);
}

// Activate the current texture unit, and keep track of the maximum
// number of texture units that have been concurrently activated.
-(void) activateTextureUnit: (GLuint) tuIdx {
	cc3_CheckGLPrim(tuIdx, value_GL_ACTIVE_TEXTURE, isKnown_GL_ACTIVE_TEXTURE);
	if ( !needsUpdate ) return;
	glActiveTexture(GL_TEXTURE0 + tuIdx);
	LogGLErrorTrace(@"glActiveTexture(%@)", NSStringFromGLEnum(GL_TEXTURE0 + tuIdx));
	value_MaxTextureUnitsUsed = MAX(value_MaxTextureUnitsUsed, tuIdx + 1);
}

-(void) activateClientTextureUnit: (GLuint) tuIdx {}

-(void) enableTexturing: (BOOL) onOff inTarget: (GLenum) target at: (GLuint) tuIdx {}

-(void) disableTexturingAt: (GLuint) tuIdx { CC3AssertUnimplemented(@"disableTexturingAt:"); }

-(void) disableTexturingFrom: (GLuint) startTexUnitIdx {
	GLuint maxTexUnits = value_MaxTextureUnitsUsed;
	for (GLuint tuIdx = startTexUnitIdx; tuIdx < maxTexUnits; tuIdx++)
		[self disableTexturingAt: tuIdx];
}

-(void) bindTexture: (GLuint) texID toTarget: (GLenum) target at: (GLuint) tuIdx {
	GLuint* stateArray;
	GLbitfield* isKnownBits;

	switch (target) {
		case GL_TEXTURE_2D:
			stateArray = value_GL_TEXTURE_BINDING_2D;
			isKnownBits = &isKnown_GL_TEXTURE_BINDING_2D;
			break;
		case GL_TEXTURE_CUBE_MAP:
			stateArray = value_GL_TEXTURE_BINDING_CUBE_MAP;
			isKnownBits = &isKnown_GL_TEXTURE_BINDING_CUBE_MAP;
			break;
		default:
			CC3Assert(NO, @"Texture target %@ is not a valid binding target.", NSStringFromGLEnum(target));
			return;
	}

	if (CC3CheckGLuintAt(tuIdx, texID, stateArray, isKnownBits)) {
		[self activateTextureUnit: tuIdx];
		glBindTexture(target, texID);
		LogGLErrorTrace(@"glBindTexture(%@, %u)", NSStringFromGLEnum(target), texID);
	}
}

/** Sets the specified texture parameter for the specified texture unit, without checking a cache. */
-(void) setTexParamEnum: (GLenum) pName inTarget: (GLenum) target to: (GLenum) val at: (GLuint) tuIdx {
	[self activateTextureUnit: tuIdx];
	glTexParameteri(target, pName, val);
	LogGLErrorTrace(@"glTexParameteri(%@, %@, %@)", NSStringFromGLEnum(target),
					NSStringFromGLEnum(pName), NSStringFromGLEnum(val));
}

-(void) setTextureMinifyFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx {
	[self setTexParamEnum: GL_TEXTURE_MIN_FILTER inTarget: target to: func at: tuIdx];
}

-(void) setTextureMagnifyFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx {
	[self setTexParamEnum: GL_TEXTURE_MAG_FILTER inTarget: target to: func at: tuIdx];
}

-(void) setTextureHorizWrapFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx {
	[self setTexParamEnum: GL_TEXTURE_WRAP_S inTarget: target to: func at: tuIdx];
}

-(void) setTextureVertWrapFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx {
	[self setTexParamEnum: GL_TEXTURE_WRAP_T inTarget: target to: func at: tuIdx];
}

-(void) generateMipmapForTarget: (GLenum)target at: (GLuint) tuIdx {
	[self activateTextureUnit: tuIdx];
	glGenerateMipmap(target);
	LogGLErrorTrace(@"glGenerateMipmap(%@)", NSStringFromGLEnum(target));
}

-(void) setTextureEnvMode: (GLenum) mode at: (GLuint) tuIdx {}

-(void) setTextureEnvColor: (ccColor4F) color at: (GLuint) tuIdx {}

-(void) enablePointSpriteCoordReplace: (BOOL) onOff at: (GLuint) tuIdx {}


#pragma mark Matrices

-(void) activateMatrixStack: (GLenum) mode {}

-(void) activatePaletteMatrixStack: (GLuint) pmIdx {}

-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx {}

-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx {}

-(void) loadPaletteMatrix: (CC3Matrix4x3*) mtx at: (GLuint) pmIdx {}

-(void) pushModelviewMatrixStack {}

-(void) popModelviewMatrixStack {}

-(void) pushProjectionMatrixStack {}

-(void) popProjectionMatrixStack {}


#pragma mark Hints

-(void) setFogHint: (GLenum) hint {}

-(void) setGenerateMipmapHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_GENERATE_MIPMAP_HINT, isKnown_GL_GENERATE_MIPMAP_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_GENERATE_MIPMAP_HINT, hint);
	LogGLErrorTrace(@"glHint(%@, %@)", NSStringFromGLEnum(GL_GENERATE_MIPMAP_HINT), NSStringFromGLEnum(hint));
}

-(void) setLineSmoothingHint: (GLenum) hint {}

-(void) setPerspectiveCorrectionHint: (GLenum) hint {}

-(void) setPointSmoothingHint: (GLenum) hint {}


#pragma mark Framebuffers

-(GLuint) generateFramebuffer {
	GLuint fbID;
	glGenFramebuffers(1, &fbID);
	LogGLErrorTrace(@"glGenFramebuffers(%i, %u)", 1, fbID);
	return fbID;
}

-(void) deleteFramebuffer: (GLuint) fbID {
	if ( !fbID ) return;		// Silently ignore zero ID
	glDeleteFramebuffers(1, &fbID);
	LogGLErrorTrace(@"glDeleteFramebuffers(%i, %u)", 1,fbID);
	
	// If the deleted buffer is currently bound, the GL engine will automatically
	// bind to the empty buffer ID (0). Update the state tracking accordingly.
	if (value_GL_FRAMEBUFFER_BINDING == fbID) value_GL_FRAMEBUFFER_BINDING = 0;
}

/** Returns whether the specified framebuffer ID is the currently bound value. */
-(BOOL) checkGLFramebuffer: (GLuint) fbID {
	cc3_CheckGLPrim(fbID, value_GL_FRAMEBUFFER_BINDING, isKnown_GL_FRAMEBUFFER_BINDING);
	return !needsUpdate;
}

/** Returns whether the specified framebuffer target is the currently bound value. */
-(BOOL) checkGLFramebufferTarget: (GLenum) fbTarg {
	cc3_CheckGLPrim(fbTarg, value_GL_FRAMEBUFFER_Target, isKnown_GL_FRAMEBUFFER_Target);
	return !needsUpdate;
}

-(void) bindFramebuffer: (GLuint) fbID toTarget: (GLenum) fbTarget {
	if ( [self checkGLFramebuffer: fbID] && [self checkGLFramebufferTarget: fbTarget] ) return;
	glBindFramebuffer(fbTarget, fbID);
	LogGLErrorTrace(@"glBindFramebuffer(%@, %u)", NSStringFromGLEnum(fbTarget), fbID);
}

-(void) bindFramebuffer: (GLuint) fbID { [self bindFramebuffer: fbID toTarget: GL_FRAMEBUFFER]; }

-(void) resolveMultisampleFramebuffer: (GLuint) fbSrcID intoFramebuffer: (GLuint) fbDstID {
	[self bindFramebuffer: fbSrcID toTarget: GL_FRAMEBUFFER];
}

-(void) discard: (GLsizei) count attachments: (const GLenum*) attachments fromFramebuffer: (GLuint) fbID {}

-(GLuint) generateRenderbuffer {
	GLuint rbID;
	glGenRenderbuffers(1, &rbID);
	LogGLErrorTrace(@"glGenRenderbuffers(%i, %u)", 1, rbID);
	return rbID;
}

-(void) deleteRenderbuffer: (GLuint) rbID {
	if ( !rbID ) return;		// Silently ignore zero ID
	glDeleteRenderbuffers(1, &rbID);
	LogGLErrorTrace(@"glDeleteRenderbuffers(%i, %u)", 1,rbID);
	
	// If the deleted buffer is currently bound, the GL engine will automatically
	// bind to the empty buffer ID (0). Update the state tracking accordingly.
	if (value_GL_RENDERBUFFER_BINDING == rbID) value_GL_RENDERBUFFER_BINDING = 0;
}

-(void) bindRenderbuffer: (GLuint) rbID {
	cc3_CheckGLPrim(rbID, value_GL_RENDERBUFFER_BINDING, isKnown_GL_RENDERBUFFER_BINDING);
	if ( !needsUpdate ) return;
	glBindRenderbuffer(GL_RENDERBUFFER, rbID);
	LogGLErrorTrace(@"glBindRenderbuffer(%@, %u)", NSStringFromGLEnum(GL_RENDERBUFFER), rbID);
}

-(void) allocateStorageForRenderbuffer: (GLuint) rbID
							  withSize: (CC3IntSize) size
							 andFormat: (GLenum) format
							andSamples: (GLuint) pixelSamples {
	
	CC3Assert(size.width <= self.maxRenderbufferSize && size.height <= self.maxRenderbufferSize,
			  @"%@ exceeds the maximum renderbuffer size, %u per side",
			  NSStringFromCC3IntSize(size), self.maxRenderbufferSize);
	
	[self bindRenderbuffer: rbID];
	glRenderbufferStorage(GL_RENDERBUFFER, format, size.width, size.height);
	LogGLErrorTrace(@"glRenderbufferStorage(%@, %@, %i, %i)", NSStringFromGLEnum(GL_RENDERBUFFER),
					NSStringFromGLEnum(format), size.width, size.height);
}

-(GLint) getRenderbufferParameterInteger: (GLenum) param {
	GLint val;
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, param, &val);
	LogGLErrorTrace(@"glGetRenderbufferParameteriv(%@, %@, %@)",
					NSStringFromGLEnum(GL_RENDERBUFFER), NSStringFromGLEnum(param),
					(param == GL_RENDERBUFFER_INTERNAL_FORMAT) ? NSStringFromGLEnum(val) : [NSString stringWithFormat: @"%i", val]);
	return val;
}

-(void) bindRenderbuffer: (GLuint) rbID toFrameBuffer: (GLuint) fbID asAttachment: (GLenum) attachment {
	[self bindFramebuffer: fbID];
	[self bindRenderbuffer: rbID];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, attachment, GL_RENDERBUFFER, rbID);
	LogGLErrorTrace(@"glFramebufferRenderbuffer(%@, %@, %@, %u)", NSStringFromGLEnum(GL_FRAMEBUFFER),
					NSStringFromGLEnum(attachment), NSStringFromGLEnum(GL_RENDERBUFFER), rbID);
}

-(void) bindTexture2D: (GLuint) texID
				 face: (GLenum) face
		  mipmapLevel: (GLint) mipmapLevel
		toFrameBuffer: (GLuint) fbID
		 asAttachment: (GLenum) attachment {
	[self bindFramebuffer: fbID];
	glFramebufferTexture2D(GL_FRAMEBUFFER, attachment, face, texID, mipmapLevel);
	LogGLErrorTrace(@"glFramebufferTexture2D(%@, %@, %@, %u, %i)", NSStringFromGLEnum(GL_FRAMEBUFFER),
					NSStringFromGLEnum(attachment), NSStringFromGLEnum(face), texID, mipmapLevel);
}

-(BOOL) checkFramebufferStatus: (GLuint) fbID {
	[self bindFramebuffer: fbID];
	GLenum fbStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	LogGLErrorTrace(@"glCheckFramebufferStatus(%@)", NSStringFromGLEnum(GL_FRAMEBUFFER));
	if (fbStatus == GL_FRAMEBUFFER_COMPLETE) return YES;
	LogError(@"%@", [NSString stringWithFormat: @"Framebuffer %u is incomplete: %@", fbID, NSStringFromGLEnum(fbStatus)]);
	CC3Assert(!GL_ERROR_ASSERTION_ENABLED,
			   @"%@ To disable this assertion and just log the GL error, set the preprocessor macro GL_ERROR_ASSERTION_ENABLED=0 in your project build settings.\n",
			   [NSString stringWithFormat: @"Framebuffer %u is incomplete: %@", fbID, NSStringFromGLEnum(fbStatus)]);
	return NO;
}

-(void) clearBuffers: (GLbitfield) mask {
	glClear(mask);
	LogGLErrorTrace(@"glClear(%x)", mask);
}

-(void) readPixelsIn: (CC3Viewport) rect  fromFramebuffer: (GLuint) fbID into: (ccColor4B*) colorArray {
	GLuint currFB = value_GL_FRAMEBUFFER_BINDING;
	[self bindFramebuffer: fbID];
	[self setPixelPackingAlignment: 1];
	glReadPixels(rect.x, rect.y, rect.w, rect.h, GL_RGBA, GL_UNSIGNED_BYTE, colorArray);
	LogGLErrorTrace(@"glReadPixels(%i, %i, %i, %i, %@, %@, %@)", rect.x, rect.y, rect.w, rect.h,
					NSStringFromGLEnum(GL_RGBA), NSStringFromGLEnum(GL_UNSIGNED_BYTE), NSStringFromCCC4B(colorArray[0]));
	[self bindFramebuffer: currFB];
}

-(void) setPixelPackingAlignment: (GLint) byteAlignment {
	cc3_CheckGLPrim(byteAlignment, value_GL_PACK_ALIGNMENT, isKnown_GL_PACK_ALIGNMENT);
	if ( !needsUpdate ) return;
	glPixelStorei(GL_PACK_ALIGNMENT, byteAlignment);
	LogGLErrorTrace(@"glPixelStorei(%@, %i)", NSStringFromGLEnum(GL_PACK_ALIGNMENT), byteAlignment);
}

-(void) setPixelUnpackingAlignment: (GLint) byteAlignment {
	cc3_CheckGLPrim(byteAlignment, value_GL_UNPACK_ALIGNMENT, isKnown_GL_UNPACK_ALIGNMENT);
	if ( !needsUpdate ) return;
	glPixelStorei(GL_UNPACK_ALIGNMENT, byteAlignment);
	LogGLErrorTrace(@"glPixelStorei(%@, %i)", NSStringFromGLEnum(GL_UNPACK_ALIGNMENT), byteAlignment);
}


#pragma mark Platform limits & info

-(void) flush { glFlush(); }

-(void) finish { glFinish(); }

-(GLint) getInteger: (GLenum) param {
	GLint val;
	glGetIntegerv(param, &val);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(param), val);
	return val;
}

-(GLfloat) getFloat: (GLenum) param {
	GLfloat val;
	glGetFloatv(param, &val);
	LogGLErrorTrace(@"glGetFloatv(%@, %.6f)", NSStringFromGLEnum(param), val);
	return val;
}

-(NSString*) getString: (GLenum) param {
	NSString* val = [NSString stringWithUTF8String: (char*)glGetString(param)];
	LogGLErrorTrace(@"glGetString(%@, %@)", NSStringFromGLEnum(param), val);
	return val;
}

-(GLuint) maxNumberOfLights { return value_GL_MAX_LIGHTS; }

-(GLuint) maxNumberOfClipPlanes { return value_GL_MAX_CLIP_PLANES; }

-(GLuint) maxNumberOfPaletteMatrices { return value_GL_MAX_PALETTE_MATRICES; }

-(GLuint) maxNumberOfTextureUnits { return value_GL_MAX_TEXTURE_UNITS; }

-(GLuint) maxNumberOfVertexAttributes { return value_GL_MAX_VERTEX_ATTRIBS; }

-(GLuint) maxNumberOfBoneInfluencesPerVertex { return valueMaxBoneInfluencesPerVertex; }
	
-(GLuint) maxNumberOfVertexUnits { return self.maxNumberOfBoneInfluencesPerVertex; }

-(GLuint) maxNumberOfPixelSamples { return value_GL_MAX_SAMPLES; }

-(GLuint) maxTextureSize { return value_GL_MAX_TEXTURE_SIZE; }

-(GLuint) maxRenderbufferSize { return value_GL_MAX_RENDERBUFFER_SIZE; }

-(GLuint) maxCubeMapTextureSize { return value_GL_MAX_CUBE_MAP_TEXTURE_SIZE; }

-(GLuint) maxTextureSizeForTarget: (GLenum) target {
	switch (target) {
		case GL_TEXTURE_CUBE_MAP_POSITIVE_X:
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_X:
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Y:
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Y:
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Z:
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Z:
			return self.maxCubeMapTextureSize;
		case GL_TEXTURE_2D:
		default:
			return self.maxTextureSize;
	}
}

-(GLuint) maxNumberOfVertexShaderUniformVectors { return 0; }

-(GLuint) maxNumberOfFragmentShaderUniformVectors { return 0; }

-(GLuint) maxNumberOfShaderProgramVaryingVectors { return 0; }

-(GLfloat) vertexShaderVarRangeMin: (GLenum) precisionType { return 0.0f; }

-(GLfloat) vertexShaderVarRangeMax: (GLenum) precisionType { return 0.0f; }

-(GLfloat) vertexShaderVarPrecision: (GLenum) precisionType { return 0.0f; }

-(GLfloat) fragmentShaderVarRangeMin: (GLenum) precisionType { return 0.0f; }

-(GLfloat) fragmentShaderVarRangeMax: (GLenum) precisionType { return 0.0f; }

-(GLfloat) fragmentShaderVarPrecision: (GLenum) precisionType { return 0.0f; }


#pragma mark GL Extensions

/** Returns the specified extension name, stripped of any optional GL_ prefix. */
-(NSString*) trimGLPrefix: (NSString*) extensionName {
	NSString* extPfx = @"GL_";
	return ([extensionName hasPrefix: extPfx]
			? [extensionName substringFromIndex: extPfx.length]
			: extensionName);
}

-(NSSet*) extensions {
	if ( !_extensions ) {
		_extensions = [NSMutableSet new];		// retained
		NSArray* rawExts = [[self getString: GL_EXTENSIONS]
							componentsSeparatedByCharactersInSet:
							[NSCharacterSet whitespaceCharacterSet]];
		for (NSString* extName in rawExts) {
			NSString* trimmedName = [self trimGLPrefix: extName];
			if (trimmedName.length > 0) [_extensions addObject: trimmedName];
		}
	}
	return _extensions;
}

-(BOOL) supportsExtension: (NSString*) extensionName {
	return [_extensions containsObject: [self trimGLPrefix: extensionName]];
}

// Dummy implementation to keep compiler happy with @selector(caseInsensitiveCompare:)
// in implementation of extensionsDescription property.
-(NSComparisonResult) caseInsensitiveCompare: (NSString*) string { return NSOrderedSame; }

/** Returns a description of the available extensions. */
-(NSString*) extensionsDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 1000];
	NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey: @"description"
															 ascending: YES
															  selector: @selector(caseInsensitiveCompare:)];
	NSArray* sorted = [self.extensions sortedArrayUsingDescriptors: [NSArray arrayWithObject: sorter]];
	for (NSString* ext in sorted) [desc appendFormat: @"\n\t%@", ext];
	return desc;
}


#pragma mark Shaders

-(CC3ShaderPrewarmer*) shaderProgramPrewarmer { return nil; }

-(void) setShaderProgramPrewarmer: (CC3ShaderPrewarmer*) shaderProgramPrewarmer {}

-(id<CC3ShaderSemanticsDelegate>) semanticDelegate { return nil; }

-(void) setSemanticDelegate: (id<CC3ShaderSemanticsDelegate>) semanticDelegate {}

-(GLuint) createShader: (GLenum) shaderType { return 0; }

-(void) deleteShader: (GLuint) shaderID  {}

-(void) compileShader: (GLuint) shaderID fromSourceCodeStrings: (NSArray*) glslSources {
	GLuint shSrcCnt = (GLuint)glslSources.count;
	const GLchar* shSrcs[shSrcCnt];
	for (GLuint shSrcIdx = 0; shSrcIdx < shSrcCnt; shSrcIdx++) {
		shSrcs[shSrcIdx] = ((NSString*)[glslSources objectAtIndex: shSrcIdx]).UTF8String;
	}
	[self compileShader: shaderID from: shSrcCnt sourceCodeStrings: shSrcs];
}

-(void) compileShader: (GLuint) shaderID from: (GLuint) srcStrCount sourceCodeStrings: (const GLchar**) srcCodeStrings {}

-(BOOL) getShaderWasCompiled: (GLuint) shaderID { return NO; }

-(GLint) getIntegerParameter: (GLenum) param forShader: (GLuint) shaderID { return 0; }

-(NSString*) getLogForShader: (GLuint) shaderID { return nil; }

-(NSString*) getSourceCodeForShader: (GLuint) shaderID { return nil; }

-(NSString*) defaultShaderPreamble { return @""; }

-(GLuint) createShaderProgram { return 0; }

-(void) deleteShaderProgram: (GLuint) programID {}

-(void) attachShader: (GLuint) shaderID toShaderProgram: (GLuint) programID {}

-(void) detachShader: (GLuint) shaderID fromShaderProgram: (GLuint) programID {}

-(void) linkShaderProgram: (GLuint) programID {}

-(BOOL) getShaderProgramWasLinked: (GLuint) programID { return NO; }

-(GLint) getIntegerParameter: (GLenum) param forShaderProgram: (GLuint) programID { return 0; }

-(void) useShaderProgram: (GLuint) programID {}

-(NSString*) getLogForShaderProgram: (GLuint) programID { return nil; }

-(void) populateShaderProgramVariable: (CC3GLSLVariable*) var {}

-(void) setShaderProgramUniformValue: (CC3GLSLUniform*) uniform {}

-(void) releaseShaderCompiler {}


#pragma mark Aligning 2D & 3D state

-(void) alignFor2DDrawing {
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	
	// Restore 2D standard blending
	[self enableBlend: YES];	// if director setAlphaBlending: NO, needs to be overridden
	[self setBlendFuncSrc: CC_BLEND_SRC dst: CC_BLEND_DST];
	[self enableAlphaTesting: NO];
	
	// Enable vertex attributes needed for 2D, disable all others, unbind GL buffers.
	[self enable2DVertexAttributes];
	[self unbindBufferTarget: GL_ARRAY_BUFFER];
	[self unbindBufferTarget: GL_ELEMENT_ARRAY_BUFFER];
	
	// Disable, and remove both 2D & cube texture bindings from, all texture units.
	// Then enable texture unit 0 for 2D textures only, and default texture unit blending.
	[self disableTexturingFrom: 0];
	[self enableTexturing: YES inTarget: GL_TEXTURE_2D at: 0];
	[self setTextureEnvMode: GL_MODULATE at: 0];
	[self setTextureEnvColor: kCCC4FBlackTransparent at: 0];
	
	// Ensure texture unit zero is the active texture unit. Code above might leave another active.
	[self activateTextureUnit: 0];
	[self activateClientTextureUnit: 0];
	
	// Ensure GL_MODELVIEW matrix is active under OGLES 1.1.
	[self activateMatrixStack: GL_MODELVIEW];
	
	[self align2DStateCache];		// Align the 2D GL state cache with current settings
}

-(void) align2DStateCache {}

-(void) alignFor3DDrawing {
	[self bindVertexArrayObject: 0];	// Ensure that a VAO was not left in place by cocos2d
	[self align3DStateCache];
}

-(void) align3DStateCache {
	isKnownCap_GL_BLEND = NO;
	isKnownBlendFunc = NO;
	isKnown_GL_ARRAY_BUFFER_BINDING = NO;
	isKnown_GL_ELEMENT_ARRAY_BUFFER_BINDING = NO;
	CC3SetBit(&isKnown_GL_TEXTURE_BINDING_2D, 0, NO);	// Unknown texture in tex unit zero

	[self align3DVertexAttributeState];
}

-(void) align3DVertexAttributeState {}


#pragma mark OpenGL resources

-(void) clearOpenGLResourceCaches {
	LogInfo(@"Clearing resource caches on thread %@.", NSThread.currentThread);
	
	self.shaderProgramPrewarmer = nil;
	
	[CC3Resource removeAllResources];
	[CC3Texture removeAllTextures];
	[CC3ShaderProgram removeAllPrograms];
	[CC3Shader removeAllShaders];
	[CC3ShaderSourceCode removeAllShaderSourceCode];

	// Dynamically reference model factory class, as it might not be present.
	[NSClassFromString(@"CC3ModelSampleFactory") deleteFactory];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		LogInfoIfPrimary(@"Third dimension provided by %@", NSStringFromCC3Version());
		LogInfo(@"Starting GL context %@ on %@", self, NSThread.currentThread);
		[self initDeletionDelay];
		[self initGLContext];
		[self initPlatformLimits];
		[self initSurfaces];
		[self initVertexAttributes];
		[self initTextureUnits];
		[self initExtensions];
	}
	return self;
}

/** Template method to establish the initial value of the deletionDelay property. */
-(void) initDeletionDelay { _deletionDelay = self.isRenderingContext ? 0.0 : 0.25; }

/** Template method to establish the OpenGL engine context. */
-(void) initGLContext {
	self.context = self.isRenderingContext ? [self makeRenderingGLContext] : [self makeBackgroundGLContext];
	[_context ensureCurrentContext];
}

/** Template method to create and return the primary rendering OpenGL context. */
-(CC3GLContext*) makeRenderingGLContext {
	CC3AssertUnimplemented(@"makeRenderingGLContext");
	return nil;
}

/**
 * Template method to create and return the background OpenGL context.
 *
 * This implementation creates the background GL context from the primary rendering context,
 * using a sharegroup, so that the two can share GL objects.
 */
-(CC3GLContext*) makeBackgroundGLContext { return [_renderGL.context asSharedContext]; }

/** Template method to retrieve the GL platform limits. */
-(void) initPlatformLimits {
	value_GL_VENDOR = [[self getString: GL_VENDOR] retain];
	LogInfoIfPrimary(@"GL vendor: %@", value_GL_VENDOR);

	value_GL_RENDERER = [[self getString: GL_RENDERER] retain];
	LogInfoIfPrimary(@"GL engine: %@", value_GL_RENDERER);
	
	value_GL_VERSION = [[self getString: GL_VERSION] retain];
	LogInfoIfPrimary(@"GL version: %@", value_GL_VERSION);
	
	value_GL_MAX_TEXTURE_SIZE = [self getInteger: GL_MAX_TEXTURE_SIZE];
	LogInfoIfPrimary(@"Maximum texture size: %u", value_GL_MAX_TEXTURE_SIZE);
	
	value_GL_MAX_RENDERBUFFER_SIZE = [self getInteger: GL_MAX_RENDERBUFFER_SIZE];
	LogInfoIfPrimary(@"Maximum renderbuffer size: %u", value_GL_MAX_RENDERBUFFER_SIZE);

}

/** Initializes surfaces frameworks. */
-(void) initSurfaces {}

/** Initializes vertex attributes. This must be invoked after the initPlatformLimits. */
-(void) initVertexAttributes {
	vertexAttributes = calloc(value_GL_MAX_VERTEX_ATTRIBS, sizeof(CC3VertexAttr));
}

/** Initializes the texture units. This must be invoked after the initPlatformLimits. */
-(void) initTextureUnits {
	value_MaxTextureUnitsUsed = 0;

	value_GL_TEXTURE_BINDING_2D = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(GLuint));
	value_GL_TEXTURE_BINDING_CUBE_MAP = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(GLuint));
}

/** Performs any required initialization for GL extensions supported by this platform. */
-(void) initExtensions {
	LogInfoIfPrimary(@"GL extensions supported by this platform: %@", self.extensionsDescription);
}

/** Returns the appropriate class cluster subclass instance. */
+(id) alloc {
	if (self == [CC3OpenGL class]) return [CC3OpenGLClass alloc];
	return [super alloc];
}

static CC3OpenGL* _renderGL = nil;
static CC3OpenGL* _bgGL = nil;

-(BOOL) isRenderingContext { return (self == _renderGL); }

+(CC3OpenGL*) sharedGL {
	// The unconventional separation of alloc & init here is required so the static var is set
	// before the init is run, since several init operations require access to the static var.
	if (self.isRenderThread) {
		if (!_renderGL) {
			_renderGL = [self alloc];		// retained
			[_renderGL initWithName: @"Rendering Engine"];
		}
		return _renderGL;
	} else {
		if (!_bgGL) {
			_bgGL = [self alloc];			// retained
			[_bgGL initWithName: @"Background Engine"];
		}
		return _bgGL;
	}
}

static NSThread* _renderThread = nil;

+(NSThread*) renderThread {
	// Retrieve from CCDirector, and cache for fast access, and to allow CCDirector to be shut
	// down, but the render thread to still be accessible for any outstanding background loading
	// that occurs before GL is shut down.
	if (!_renderThread) _renderThread = CCDirector.sharedDirector.runningThread;	// weak reference
	return _renderThread;
}

+(BOOL) isRenderThread {
	if (!_renderThread) [self renderThread];
	return (NSThread.currentThread == _renderThread) || NSThread.isMainThread;
}

+(void) terminateOpenGL {
	CC3Texture.shouldCacheAssociatedCCTextures = NO;
	[_renderGL terminate];
	[_bgGL terminate];
}

-(void) terminate {
	if (self.isRenderingContext) {
		[self.class.renderThread runBlockAsync: ^{ [self clearOpenGLResourceCaches]; } ];
		[self.class.renderThread runBlockAsync: ^{ [self terminateSoon]; } ];
	} else {
		[CC3Backgrounder.sharedBackgrounder runBlock: ^{ [self clearOpenGLResourceCaches]; }];
		[CC3Backgrounder.sharedBackgrounder runBlock: ^{ [self terminateSoon]; }];
	}
}

-(void) terminateSoon {
	LogInfo(@"Requesting deletion of %@ on thread %@.", self, NSThread.currentThread);
	if (self.isRenderingContext) {
		[self.class.renderThread runBlock: ^{ [self terminateNow]; } after: _deletionDelay ];
	} else {
		[CC3Backgrounder.sharedBackgrounder runBlock: ^{ [self terminateNow]; } after: _deletionDelay];
	}
}

-(void) terminateNow {
	LogInfo(@"Deleting %@ now on thread %@.", self, NSThread.currentThread);
	[self finish];
	
	if (self == _renderGL) {
		[_renderGL release];
		_renderGL = nil;
	}
	if (self == _bgGL) {
		[_bgGL release];
		_bgGL = nil;
	}
	
	[self.class checkClearRenderThread];
	[self.class checkTerminationNotify];
}

/** If BOTH the render context AND the background context have been deleted, release the render thread. */
+(void) checkClearRenderThread {
	if (!_renderGL && !_bgGL) _renderThread = nil;		// weak reference
}

/** If BOTH the render context AND the background context have been deleted, notify the delegate. */
+(void) checkTerminationNotify {
	if (!_renderGL && !_bgGL)
		[self notifyDelegateOf: @selector(didTerminateOpenGL) withObject: nil];
}

/** 
 * Notifies the delegate by invoking the specified method, with the specified optional argument.
 * If the method does not take an argument, the arg value should be nil. If the delegate does
 * not support the method, then the notification is not sent.
 *
 * The notification is queued to the main thread for execution, and is processed asynchronously.
 */
+(void) notifyDelegateOf: (SEL) selector withObject: (id) arg {
	if ([_delegate respondsToSelector: selector])
		[_delegate performSelectorOnMainThread: selector withObject: arg waitUntilDone: NO];
}

@end


#pragma mark -
#pragma mark State management functions

BOOL CC3CheckGLBooleanAt(GLuint idx, BOOL val, GLbitfield* stateBits, GLbitfield* isKnownBits) {
	BOOL needsUpdate = (!CC3BooleansAreEqual(CC3IsBitSet(*stateBits, idx), val)) || CC3IsBitClear(*isKnownBits, idx);
	if (needsUpdate) {
		CC3SetBit(stateBits, idx, val);
		CC3SetBit(isKnownBits, idx, YES);
	}
	return needsUpdate;
}

BOOL CC3CheckGLuintAt(GLuint idx, GLuint val, GLuint* stateArray, GLbitfield* isKnownBits) {
	BOOL needsUpdate = (stateArray[idx] != val) || CC3IsBitClear(*isKnownBits, idx);
	if (needsUpdate) {
		stateArray[idx] = val;
		CC3SetBit(isKnownBits, idx, YES);
	}
	return needsUpdate;
}

BOOL CC3CheckGLfloatAt(GLuint idx, GLfloat val, GLfloat* stateArray, GLbitfield* isKnownBits) {
	BOOL needsUpdate = (stateArray[idx] != val) || CC3IsBitClear(*isKnownBits, idx);
	if (needsUpdate) {
		stateArray[idx] = val;
		CC3SetBit(isKnownBits, idx, YES);
	}
	return needsUpdate;
}

BOOL CC3CheckGLVectorAt(GLuint idx, CC3Vector val, CC3Vector* stateArray, GLbitfield* isKnownBits) {
	BOOL needsUpdate = !CC3VectorsAreEqual(stateArray[idx], val) || CC3IsBitClear(*isKnownBits, idx);
	if (needsUpdate) {
		stateArray[idx] = val;
		CC3SetBit(isKnownBits, idx, YES);
	}
	return needsUpdate;
}

BOOL CC3CheckGLVector4At(GLuint idx, CC3Vector4 val, CC3Vector4* stateArray, GLbitfield* isKnownBits) {
	BOOL needsUpdate = !CC3Vector4sAreEqual(stateArray[idx], val) || CC3IsBitClear(*isKnownBits, idx);
	if (needsUpdate) {
		stateArray[idx] = val;
		CC3SetBit(isKnownBits, idx, YES);
	}
	return needsUpdate;
}

BOOL CC3CheckGLColorAt(GLuint idx, ccColor4F val, ccColor4F* stateArray, GLbitfield* isKnownBits) {
	BOOL needsUpdate = !CCC4FAreEqual(stateArray[idx], val) || CC3IsBitClear(*isKnownBits, idx);
	if (needsUpdate) {
		stateArray[idx] = val;
		CC3SetBit(isKnownBits, idx, YES);
	}
	return needsUpdate;
}

void CC3SetGLCapAt(GLenum cap, GLuint idx, BOOL onOff, GLbitfield* stateBits, GLbitfield* isKnownBits) {
	if (CC3CheckGLBooleanAt(idx, onOff, stateBits, isKnownBits)) {
		if (onOff)
			glEnable(cap + idx);
		else
			glDisable(cap + idx);
		LogGLErrorTrace(@"gl%@able(%@)", (onOff ? @"En" : @"Dis"), NSStringFromGLEnum(cap + idx));
	}
}

