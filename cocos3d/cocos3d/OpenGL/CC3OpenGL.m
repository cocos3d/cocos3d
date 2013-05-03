/*
 * CC3OpenGL.m
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
 * See header file CC3OpenGL.h for full API documentation.
 */

#import "CC3OpenGL.h"
#import "CC3CC2Extensions.h"

#if CC3_OGLES_2
#	import "CC3OpenGLES2.h"
#	define CC3OpenGLClass	CC3OpenGLES2
#elif CC3_OGLES_1
#	import "CC3OpenGLES1.h"
#	define CC3OpenGLClass	CC3OpenGLES1
#elif CC3_OGL
#	import "CC3OpenGL2.h"
#	define CC3OpenGLClass	CC3OpenGL2
#endif


@implementation CC3OpenGL

-(void) dealloc {
	[value_GL_VENDOR release];
	[value_GL_RENDERER release];
	[value_GL_VERSION release];
	free(vertexAttributes);
	free(value_GL_TEXTURE_BINDING_2D);
	free(value_GL_TEXTURE_BINDING_CUBE_MAP);
	[super dealloc];
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
	glDeleteBuffers(1, &buffID);
	LogGLErrorTrace(@"glDeleteBuffers(%i, %u)", 1, buffID);
}

-(void) bindBuffer: (GLuint) buffId  toTarget: (GLenum) target {
	if (target == GL_ELEMENT_ARRAY_BUFFER) {
		cc3_CheckGLPrim(buffId, value_GL_ELEMENT_ARRAY_BUFFER_BINDING, isKnown_GL_ELEMENT_ARRAY_BUFFER_BINDING);
		if ( !needsUpdate ) return;
	} else {
		cc3_CheckGLPrim(buffId, value_GL_ARRAY_BUFFER_BINDING, isKnown_GL_ARRAY_BUFFER_BINDING);
		if ( !needsUpdate ) return;
	}
	ccGLBindVAO(0);		// Ensure that a VAO was not left in place by cocos2d
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

-(void) clearBuffers: (GLbitfield) mask {
	glClear(mask);
	LogGLErrorTrace(@"glClear(%x)", mask);
}

-(void) clearColorBuffer { [self clearBuffers: GL_COLOR_BUFFER_BIT]; }

-(void) clearDepthBuffer { [self clearBuffers: GL_DEPTH_BUFFER_BIT]; }

-(void) clearStencilBuffer { [self clearBuffers: GL_STENCIL_BUFFER_BIT]; }

-(ccColor4B) readPixelAt: (CGPoint) pixelPos {
	ccColor4B pixColor;
	glReadPixels((GLint)pixelPos.x, (GLint)pixelPos.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &pixColor);
	LogGLErrorTrace(@"glReadPixels(%i, %i, %i, %i, %@, %@, %@)", (GLint)pixelPos.x, (GLint)pixelPos.y, 1, 1,
					NSStringFromGLEnum(GL_RGBA), NSStringFromGLEnum(GL_UNSIGNED_BYTE), NSStringFromCCC4B(pixColor));
	return pixColor;
}


#pragma mark Lighting

-(void) enableLighting: (BOOL) onOff {}

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
	if ((src != value_GL_BLEND_SRC) || (dst != value_GL_BLEND_DST) || !isKnownBlendFunc) {
		value_GL_BLEND_SRC = src;
		value_GL_BLEND_DST = dst;
		isKnownBlendFunc = YES;
		glBlendFunc(src, dst);
		LogGLErrorTrace(@"glBlendFunc(%@, %@)", NSStringFromGLEnum(src), NSStringFromGLEnum(dst));
	}
}


#pragma mark Textures

-(GLuint) generateTextureID {
	GLuint texID;
	glGenTextures(1, &texID);
	LogGLErrorTrace(@"glGenTextures(%i, %u)", 1, texID);
	return texID;
}

-(void) deleteTextureID: (GLuint) texID {
	if ( !texID ) return;		// Silently ignore zero texture ID
	glDeleteTextures(1, &texID);
	LogGLErrorTrace(@"glDeleteTextures(%i, %u)", 1, texID);
}

-(void) loadTexureImage: (const GLvoid*) imageData
			 intoTarget: (GLenum) target
			   withSize: (CC3IntSize) size
			 withFormat: (GLenum) texelFormat
			   withType: (GLenum) texelType
	  withByteAlignment: (GLint) byteAlignment
					 at: (GLuint) tuIdx {
	[self activateTextureUnit: tuIdx];
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, byteAlignment);
	LogGLErrorTrace(@"glPixelStorei(%@, %i)", NSStringFromGLEnum(GL_UNPACK_ALIGNMENT), byteAlignment);
	
	glTexImage2D(target, 0, texelFormat, size.width, size.height, 0, texelFormat, texelType, imageData);
	LogGLErrorTrace(@"glTexImage2D(%@, %i, %@, %i, %i, %i, %@, %@, %p)",
					NSStringFromGLEnum(target), 0, NSStringFromGLEnum(texelFormat), size.width, size.height,
					0, NSStringFromGLEnum(texelFormat), NSStringFromGLEnum(texelType), imageData);
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

-(void) disableTexturingFrom: (GLuint) tuIdx { CC3AssertUnimplemented(@"disableTexturingFrom:"); }

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
		LogGLErrorTrace(@"glBindTexture(%@, %u)", NSStringFromGLEnum(target), tuIdx);
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


#pragma mark Platform limits

-(GLuint) maxNumberOfLights { return value_GL_MAX_LIGHTS; }

-(GLuint) maxNumberOfClipPlanes { return value_GL_MAX_CLIP_PLANES; }

-(GLuint) maxNumberOfPaletteMatrices { return value_GL_MAX_PALETTE_MATRICES; }

-(GLuint) maxNumberOfTextureUnits { return value_GL_MAX_TEXTURE_UNITS; }

-(GLuint) maxNumberOfVertexAttributes { return value_GL_MAX_VERTEX_ATTRIBS; }

-(GLuint) maxNumberOfVertexUnits { return value_GL_MAX_VERTEX_UNITS; }

-(GLuint) maxNumberOfPixelSamples { return value_GL_MAX_SAMPLES; }


#pragma mark Shaders

-(CC3GLProgram*) selectProgramForMeshNode: (CC3MeshNode*) aMeshNode { return nil; }

-(void) bindProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) bindProgram: (CC3GLProgram*) program withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(NSString*) defaultShaderPreamble { return @""; }


#pragma mark Aligning 2D & 3D caches

-(void) align2DStateCache {}

-(void) align3DStateCache {
	isKnownCap_GL_BLEND = NO;
	isKnownBlendFunc = NO;
	isKnown_GL_ARRAY_BUFFER_BINDING = NO;
	isKnown_GL_ELEMENT_ARRAY_BUFFER_BINDING = NO;
	CC3SetBit(&isKnown_GL_TEXTURE_BINDING_2D, 0, NO);	// Unknown texture in tex unit zero

	[self align3DVertexAttributeState];
}

-(void) align3DVertexAttributeState {
	CC3AssertUnimplemented(@"align3DVertexAttributeState");
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		LogInfo(@"Third dimension provided by %@", NSStringFromCC3Version());
		[self initPlatformLimits];
		[self initVertexAttributes];
		[self initTextureUnits];
	}
	return self;
}

/** Template method to retrieve the GL platform limits. */
-(void) initPlatformLimits {
	value_GL_VENDOR = [[NSString alloc] initWithUTF8String: (char*)glGetString(GL_VENDOR)];
	LogGLErrorTrace(@"glGetString(%@)", NSStringFromGLEnum(GL_VENDOR));
	LogInfo(@"GL vendor: %@", value_GL_VENDOR);

	value_GL_RENDERER = [[NSString alloc] initWithUTF8String: (char*)glGetString(GL_RENDERER)];
	LogGLErrorTrace(@"glGetString(%@)", NSStringFromGLEnum(GL_RENDERER));
	LogInfo(@"GL engine: %@", value_GL_RENDERER);
	
	value_GL_VERSION = [[NSString alloc] initWithUTF8String: (char*)glGetString(GL_VERSION)];
	LogGLErrorTrace(@"glGetString(%@)", NSStringFromGLEnum(GL_VERSION));
	LogInfo(@"GL version: %@", value_GL_VERSION);
}

/** Allocates and initializes the vertex attributes. This must be invoked after the initPlatformLimits. */
-(void) initVertexAttributes {
	vertexAttributes = calloc(value_GL_MAX_VERTEX_ATTRIBS, sizeof(CC3VertexAttr));
}

/** Allocates and initializes the texture units. This must be invoked after the initPlatformLimits. */
-(void) initTextureUnits {
	value_MaxTextureUnitsUsed = 0;

	value_GL_TEXTURE_BINDING_2D = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(GLuint));
	value_GL_TEXTURE_BINDING_CUBE_MAP = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(GLuint));
}

/** Returns the appropriate class cluster subclass instance. */
+(id) alloc {
	if (self == [CC3OpenGL class]) return [CC3OpenGLClass alloc];
	return [super alloc];
}

static CC3OpenGL* _sharedGL;

+(CC3OpenGL*) sharedGL {
	if (!_sharedGL) {
		_sharedGL = [self alloc];
		[_sharedGL init];
	}
	return _sharedGL;
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

