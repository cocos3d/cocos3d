/*
 * CC3OpenGL.h
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
 */

/** @file */	// Doxygen marker

#import "CC3OpenGLFoundation.h"
#import "CC3Matrix4x4.h"

@class CC3NodeDrawingVisitor, CC3Mesh, CC3MeshNode, CC3GLProgram, CC3GLSLAttribute;

/** Indicates that vertex attribute array is not available. */
#define kCC3VertexAttributeIndexUnavailable		-1

/** GL state tracking for vertex attributes. */
typedef struct {
	GLenum semantic;			/**< The cocos3d semantic of this content array, under OGLES 1.1. */
	GLenum glName;				/**< The GL content name, used to enable a vertex array under OGLES 1.1. */
	GLenum elementType;			/**< The data type of each element. */
	GLint elementSize;			/**< The number of elements in each vertex. */
	GLsizei vertexStride;		/**< The stride in bytes between vertices. */
	GLvoid* vertices;			/**< A pointer to the vertex content. */
	BOOL shouldNormalize : 1;	/**< Indicates whether the vertex content should be normalized by the GL engine. */
	BOOL isKnown : 1;			/**< Indicates whether the GL state value are known. */
	BOOL isEnabled : 1;			/**< Indicates whether these attributes are enabled in the GL engine. */
	BOOL isEnabledKnown : 1;	/**< Indicates whether it is known if these attributes are enabled in the GL engine. */
	BOOL wasBound : 1;			/**< Indicates whether the attributes have been bound to the GL engine. */
} CC3VertexAttr;

/**
 * CC3OpenGL manages the OpenGL or OpenGL ES state for a single GL context.
 *
 * CC3OpenGL is implemented as a class cluster. The abstract CC3OpenGL class supports
 * a superset of functionality for OpenGL, OpenGL ES 1.1, or OpenGL ES 2.0. Concrete subclass
 * implementations provide functionality tailored to each specific GL implementation.
 *
 * OpenGL is designed to be a state machine that operates asynchronously from the application
 * code that calls its functions. Calls to most gl* functions queue up commands to the GL engine
 * that are processed by the GL engine asynchronously from the gl* call.
 *
 * This design allows GL command execution to be run on a different processor than the application
 * is running on, specifically a hardware-assisted GPU.
 *
 * To maximize the throughput and performance of this design, it is important that GL state is
 * changed only when necessary, and that querying of the GL state machine is avoided wherever possible.
 * 
 * By routing all GL requests through CC3OpenGL, this class can keep track of the GL state
 * change requests made to the GL engine, and will only forward such requests to the GL engine
 * if the state really is changing.
 */
@interface CC3OpenGL : NSObject {
@public

	NSString* value_GL_VENDOR;
	NSString* value_GL_RENDERER;
	NSString* value_GL_VERSION;
	
	CC3VertexAttr* vertexAttributes;
	GLuint value_MaxVertexAttribsUsed;
	
	GLuint* value_GL_TEXTURE_BINDING_2D;
	GLbitfield isKnown_GL_TEXTURE_BINDING_2D;		// Track up to 32 texture units
	
	GLuint* value_GL_TEXTURE_BINDING_CUBE_MAP;
	GLbitfield isKnown_GL_TEXTURE_BINDING_CUBE_MAP;	// Track up to 32 texture units
	
	GLbitfield value_GL_COORD_REPLACE;				// Track up to 32 texture units
	GLbitfield isKnownCap_GL_COORD_REPLACE;			// Track up to 32 texture units
	
	GLenum value_GL_BLEND_SRC;
	GLenum value_GL_BLEND_DST;
	
	ccColor4F value_GL_COLOR_CLEAR_VALUE;
	GLfloat value_GL_DEPTH_CLEAR_VALUE;
	GLint value_GL_STENCIL_CLEAR_VALUE;
	ccColor4B value_GL_COLOR_WRITEMASK;
	GLenum value_GL_CULL_FACE_MODE;
	GLenum value_GL_DEPTH_FUNC;
	GLenum value_GL_FRONT_FACE;
	GLfloat value_GL_LINE_WIDTH;
	GLfloat value_GL_POLYGON_OFFSET_FACTOR;
	GLfloat value_GL_POLYGON_OFFSET_UNITS;
	CC3Viewport value_GL_SCISSOR_BOX;
	GLenum value_GL_STENCIL_FUNC;
	GLint value_GL_STENCIL_REF;
	GLuint value_GL_STENCIL_VALUE_MASK;
	GLuint value_GL_STENCIL_WRITEMASK;
	GLenum value_GL_STENCIL_FAIL;
	GLenum value_GL_STENCIL_PASS_DEPTH_FAIL;
	GLenum value_GL_STENCIL_PASS_DEPTH_PASS;
	CC3Viewport value_GL_VIEWPORT;

	GLenum value_GL_GENERATE_MIPMAP_HINT;

	GLint value_GL_MAX_CLIP_PLANES;
	GLint value_GL_MAX_LIGHTS;
	GLint value_GL_MAX_PALETTE_MATRICES;
	GLint value_GL_MAX_SAMPLES;
	GLint value_GL_MAX_TEXTURE_UNITS;
	GLint value_GL_MAX_VERTEX_ATTRIBS;
	GLint value_GL_MAX_VERTEX_UNITS;

	GLuint value_GL_ARRAY_BUFFER_BINDING;
	GLuint value_GL_ELEMENT_ARRAY_BUFFER_BINDING;
	
	GLuint value_GL_ACTIVE_TEXTURE;
	GLuint value_MaxTextureUnitsUsed;

	BOOL valueCap_GL_BLEND : 1;
	BOOL valueCap_GL_CULL_FACE : 1;
	BOOL valueCap_GL_DEPTH_TEST : 1;
	BOOL valueCap_GL_DITHER : 1;
	BOOL valueCap_GL_POLYGON_OFFSET_FILL : 1;
	BOOL valueCap_GL_SAMPLE_ALPHA_TO_COVERAGE : 1;
	BOOL valueCap_GL_SAMPLE_COVERAGE : 1;
	BOOL valueCap_GL_SCISSOR_TEST : 1;
	BOOL valueCap_GL_STENCIL_TEST : 1;
	BOOL valueCap_GL_POINT_SPRITE : 1;

	BOOL value_GL_DEPTH_WRITEMASK : 1;

	BOOL isKnownBlendFunc : 1;
	BOOL isKnownCap_GL_BLEND : 1;
	BOOL isKnownCap_GL_CULL_FACE : 1;
	BOOL isKnownCap_GL_DEPTH_TEST : 1;
	BOOL isKnownCap_GL_DITHER : 1;
	BOOL isKnownCap_GL_POLYGON_OFFSET_FILL : 1;
	BOOL isKnownCap_GL_SAMPLE_ALPHA_TO_COVERAGE : 1;
	BOOL isKnownCap_GL_SAMPLE_COVERAGE : 1;
	BOOL isKnownCap_GL_SCISSOR_TEST : 1;
	BOOL isKnownCap_GL_STENCIL_TEST : 1;
	BOOL isKnownCap_GL_POINT_SPRITE : 1;

	BOOL isKnown_GL_COLOR_CLEAR_VALUE : 1;
	BOOL isKnown_GL_DEPTH_CLEAR_VALUE : 1;
	BOOL isKnown_GL_STENCIL_CLEAR_VALUE : 1;
	BOOL isKnown_GL_COLOR_WRITEMASK : 1;
	BOOL isKnown_GL_CULL_FACE_MODE : 1;
	BOOL isKnown_GL_DEPTH_FUNC : 1;
	BOOL isKnown_GL_DEPTH_WRITEMASK : 1;
	BOOL isKnown_GL_FRONT_FACE : 1;
	BOOL isKnown_GL_LINE_WIDTH : 1;
	BOOL isKnownPolygonOffset : 1;
	BOOL isKnown_GL_SCISSOR_BOX : 1;
	BOOL isKnownStencilFunc : 1;
	BOOL isKnown_GL_STENCIL_WRITEMASK : 1;
	BOOL isKnownStencilOp : 1;
	BOOL isKnown_GL_VIEWPORT : 1;

	BOOL isKnownMat_GL_AMBIENT : 1;
	BOOL isKnownMat_GL_DIFFUSE : 1;

	BOOL isKnown_GL_GENERATE_MIPMAP_HINT : 1;
	
	BOOL isKnown_GL_ARRAY_BUFFER_BINDING : 1;
	BOOL isKnown_GL_ELEMENT_ARRAY_BUFFER_BINDING : 1;
	
	BOOL isKnown_GL_ACTIVE_TEXTURE : 1;

}


#pragma mark Capabilities

/** Enable/disable alpha testing. */
-(void) enableAlphaTesting: (BOOL) onOff;

/** Enable/disable blending. */
-(void) enableBlend: (BOOL) onOff;

/**
 * Enable/disable the user clipping plane at the specified index, which must be a value
 * between zero and the maximum number of clipping planes supported by the platform.
 */
-(void) enableClipPlane: (BOOL) onOff at: (GLuint) clipIdx;

/** Enable/disable the current color logic operation. */
-(void) enableColorLogicOp: (BOOL) onOff;

/** Enable/disable the ambient & diffuse material colors to track vertex color. */
-(void) enableColorMaterial: (BOOL) onOff;

/** Enable/disable polygon face culling. */
-(void) enableCullFace: (BOOL) onOff;

/** Enable/disable depth testing. */
-(void) enableDepthTest: (BOOL) onOff;

/** Enable/disable dithering. */
-(void) enableDither: (BOOL) onOff;

/** Enable/disable fogging. */
-(void) enableFog: (BOOL) onOff;

/** Enable/disable line smoothing. */
-(void) enableLineSmoothing: (BOOL) onOff;

/** Enable/disable bone skinning using matrix palettes. */
-(void) enableMatrixPalette: (BOOL) onOff;

/** Enable/disable sampling multiple fragments per pixel. */
-(void) enableMultisampling: (BOOL) onOff;

/** Enable/disable the re-normalizing of normals when they are transformed. */
-(void) enableNormalize: (BOOL) onOff;

/** Enable/disable point smoothing. */
-(void) enablePointSmoothing: (BOOL) onOff;

/** Enable/disable displaying points as textured point sprites. */
-(void) enablePointSprites: (BOOL) onOff;

/** Enable/disable displaying points as textured point sprites. */
-(void) enableShaderPointSize: (BOOL) onOff;

/** Enable/disable offsetting fragment depth when comparing depths. */
-(void) enablePolygonOffset: (BOOL) onOff;

/** Enable/disable the re-scaling of normals when they are transformed. */
-(void) enableRescaleNormal: (BOOL) onOff;

/** Enable/disable alpha coverage in multisampling. */
-(void) enableSampleAlphaToCoverage: (BOOL) onOff;

/** Enable/disable setting alpha to one when multisampling. */
-(void) enableSampleAlphaToOne: (BOOL) onOff;

/** Enable/disable sample coverage. */
-(void) enableSampleCoverage: (BOOL) onOff;

/** Enable/disable discarding pixels that are outside to a scissor rectangle. */
-(void) enableScissorTest: (BOOL) onOff;

/** Enable/disable discarding pixels that are not part of a defined stencil. */
-(void) enableStencilTest: (BOOL) onOff;


#pragma mark Vertex attribute arrays

/** Binds the vertex attributes in the specified mesh to the GL engine. */
-(void) bindMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Retrieves the vertex array that should be bound to the specified attribute from the mesh
 * of the current node and binds the content of the vertex array to the GLSL attribute. Does
 * nothing if the mesh does not contain vertex content for the specified attribute.
 */
-(void) bindVertexAttribute: (CC3GLSLAttribute*) attribute withVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Enable/disable the vertex attributes at the specified index, which must be a value
 * between zero and the maximum number of vertex attributes supported by the platform.
 *
 * It is safe to submit a negative index. It will be ignored, and no changes will be made.
 */
-(void) enableVertexAttribute: (BOOL) onOff at: (GLint) vaIdx;

/**
 * Binds the content pointer, size, type, stride, and normalization requirements value together
 * for the vertex attribute at the specified index, which should be below the maximum number of
 * vertex attributes supported by the platform.
 *
 * The values will be set in the GL engine only if at least one of the values has actually changed.
 *
 * It is safe to submit a negative index. It will be ignored, and no changes will be made.
 */
-(void) bindVertexContent: (GLvoid*) pData
				 withSize: (GLint) elemSize
				 withType: (GLenum) elemType
			   withStride: (GLsizei) vtxStride
	  withShouldNormalize: (BOOL) shldNorm
			toAttributeAt: (GLint) vaIdx;

/** Clears the tracking of unbound vertex attribute arrays. */
-(void) clearUnboundVertexAttributes;

/** Enables the vertex attributes that have been bound and disables the rest. */
-(void) enableBoundVertexAttributes;

/** Enables the vertex attribute needed for drawing cocos2d 2D artifacts, and disables all the rest. */
-(void) enable2DVertexAttributes;

/**
 * Generates and returns a GL buffer ID.
 *
 * This is a wrapper for the GL function glGenBuffers.
 */
-(GLuint) generateBuffer;

/**
 * Deletes the GL buffer with the specifid buffer ID.
 *
 * This is a wrapper for the GL function glDeleteBuffers.
 */
-(void) deleteBuffer: (GLuint) buffID;

/** Binds the buffer with the specified ID to the specified buffer target. */
-(void) bindBuffer: (GLuint) buffId  toTarget: (GLenum) target;

/** 
 * Unbinds all buffers from the specified buffer target. 
 *
 * This is equivalent to invoking the bindBuffer:toTarget: method with a zero buffID parameter.
 */
-(void) unbindBufferTarget: (GLenum) target;

/**
 * Loads data into the GL buffer currently bound to the specified target, starting at the
 * specified buffer pointer, and extending for the specified length. The buffer usage is a
 * hint for the GL engine, and must be a valid GL buffer usage enumeration value.
 */
-(void) loadBufferTarget: (GLenum) target
				withData: (GLvoid*) buffPtr
				ofLength: (GLsizeiptr) buffLen
				  forUse: (GLenum) buffUsage;

/**
 * Updates data in the GL buffer currently bound to the specified target, from data starting
 * at the specified offset to the specified pointer, and extending for the specified length.
 */
-(void) updateBufferTarget: (GLenum) target
				  withData: (GLvoid*) buffPtr
				startingAt: (GLintptr) offset
				 forLength: (GLsizeiptr) length;

/**
 * Draws vertices bound by the vertex pointers using the specified draw mode,
 * starting at the specified index, and drawing the specified number of verticies.
 *
 * This is a wrapper for the GL function glDrawArrays.
 */
-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len;

/**
 * Draws the vertices indexed by the specified indices, to the specified number of indices,
 * each of the specified GL type, and using the specified draw mode.
 *
 * This is a wrapper for the GL function glDrawElements.
 */
-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode;


#pragma mark State

/** Sets the color used to clear the color buffer. */
-(void) setClearColor: (ccColor4F) color;

/** Sets the value used to clear the depth buffer. */
-(void) setClearDepth: (GLfloat) val;

/** Sets the value used to clear the stencil buffer. */
-(void) setClearStencil: (GLint) val;

/** Sets the color used to paint in the absence of materials and textures. */
-(void) setColor: (ccColor4F) color;

/** Sets the color mask indicating which of R, G, B & A should be written to the color buffer. */
-(void) setColorMask: (ccColor4B) mask;

/** Sets the faces to cull. */
-(void) setCullFace: (GLenum) val;

/** Sets the depth function to use when comparing depths. */
-(void) setDepthFunc: (GLenum) val;

/** Sets whether the depth buffer is enabled for writing. */
-(void) setDepthMask: (BOOL) writable;

/** Sets which face winding is considered to be the front face. */
-(void) setFrontFace: (GLenum) val;

/** Sets the width used to draw lines. */
-(void) setLineWidth: (GLfloat) val;

/** Sets the size used to draw points. */
-(void) setPointSize: (GLfloat) val;

/** Sets the point size attenuation coefficients. */
-(void) setPointSizeAttenuation: (CC3AttenuationCoefficients) ac;

/** Sets the point size below which points will be faded away. */
-(void) setPointSizeFadeThreshold: (GLfloat) val;

/** Sets the minimum size at which points will be drawn. */
-(void) setPointSizeMinimum: (GLfloat) val;

/** Sets the maximum size at which points will be drawn. */
-(void) setPointSizeMaximum: (GLfloat) val;

/** Sets the polygon offset factor and units. */
-(void) setPolygonOffsetFactor: (GLfloat) factor units: (GLfloat) units;

/** Sets the scissor clipping rectangle. */
-(void) setScissor: (CC3Viewport) vp;

/** Sets the shading model. */
-(void) setShadeModel: (GLenum) val;

/** Sets the stencil function parameters. */
-(void) setStencilFunc: (GLenum) func reference: (GLint) ref mask: (GLuint) mask;

/** Sets mask for enabling writing of individual bits in the stencil buffer. */
-(void) setStencilMask: (GLuint) mask;

/** Sets the operations when the stencil fails, the depth test fails, or the depth test passes. */
-(void) setOpOnStencilFail: (GLenum) sFail onDepthFail: (GLenum) dFail onDepthPass: (GLenum) dPass;

/** Sets the viewport rectangle. */
-(void) setViewport: (CC3Viewport) vp;

/**
 * Clears the buffers identified by the specified bitmask, which is a bitwise OR
 * combination of one or more of the following masks: GL_COLOR_BUFFER_BIT,
 * GL_DEPTH_BUFFER_BIT, and GL_STENCIL_BUFFER_BIT
 */
-(void) clearBuffers: (GLbitfield) mask;

/**
 * Clears the color buffer.
 *
 * This is a convenience method. To clear more than one buffer, use the clearBuffers:
 * method, passing in the buffers to clear, instead of invoking several distinct
 * clear*Buffer methods.
 */
-(void) clearColorBuffer;

/**
 * Clears the depth buffer.
 *
 * This is a convenience method. To clear more than one buffer, use the clearBuffers:
 * method, passing in the buffers to clear, instead of invoking several distinct
 * clear*Buffer methods.
 */
-(void) clearDepthBuffer;

/**
 * Clears the stencil buffer.
 *
 * This is a convenience method. To clear more than one buffer, use the clearBuffers:
 * method, passing in the buffers to clear, instead of invoking several distinct
 * clear*Buffer methods.
 */
-(void) clearStencilBuffer;

/**
 * Returns the color value of the pixel at the specified position in the GL color buffer.
 *
 * This method should be used with care, since it involves making a synchronous call to
 * query the state of the GL engine. This method will not return until the GL engine has
 * executed all previous drawing commands in the pipeline. Excessive use of this method
 * will reduce GL throughput and performance.
 */
-(ccColor4B) readPixelAt: (CGPoint) pixelPos;


#pragma mark Lighting

/** Enable/disable lighting. */
-(void) enableLighting: (BOOL) onOff;

/** Sets the color of the ambient scene lighting. */
-(void) setSceneAmbientLightColor: (ccColor4F) color;

/**
 * Enable/disable the light at the specified index, which must be a value
 * between zero and the maximum number of lights supported by the platform.
 */
-(void) enableLight: (BOOL) onOff at: (GLuint) ltIdx;

/**
 * Sets the ambient color of the light at the specified index, which must be a
 * value between zero and the maximum number of lights supported by the platform.
 */
-(void) setLightAmbientColor: (ccColor4F) color at: (GLuint) ltIdx;

/**
 * Sets the diffuse color of the light at the specified index, which must be a
 * value between zero and the maximum number of lights supported by the platform.
 */
-(void) setLightDiffuseColor: (ccColor4F) color at: (GLuint) ltIdx;

/**
 * Sets the specular color of the light at the specified index, which must be a
 * value between zero and the maximum number of lights supported by the platform.
 */
-(void) setLightSpecularColor: (ccColor4F) color at: (GLuint) ltIdx;

/**
 * Sets the homogeneous position of the light at the specified index, which must be a
 * value between zero and the maximum number of lights supported by the platform.
 */
-(void) setLightPosition: (CC3Vector4) pos at: (GLuint) ltIdx;

/**
 * Sets the distance attenuation coefficients of the light at the specified index, which 
 * must be a value between zero and the maximum number of lights supported by the platform.
 */
-(void) setLightAttenuation: (CC3AttenuationCoefficients) ac at: (GLuint) ltIdx;

/**
 * Sets the direction of the spot light at the specified index, which must be a
 * value between zero and the maximum number of lights supported by the platform.
 */
-(void) setSpotlightDirection: (CC3Vector) dir at: (GLuint) ltIdx;

/**
 * Sets the angular fading exponent of the spot light at the specified index, which must
 * be a value between zero and the maximum number of lights supported by the platform.
 */
-(void) setSpotlightFadeExponent: (GLfloat) val at: (GLuint) ltIdx;

/**
 * Sets the cutoff angle of the spot light at the specified index, which must be a
 * value between zero and the maximum number of lights supported by the platform.
 */
-(void) setSpotlightCutoffAngle: (GLfloat) val at: (GLuint) ltIdx;

/** Sets the color of the fog. */
-(void) setFogColor: (ccColor4F) color;

/** Sets the type of the fog. */
-(void) setFogMode: (GLenum) mode;

/** Sets the density of the fog. */
-(void) setFogDensity: (GLfloat) val;

/** Sets the start distance of the fog. */
-(void) setFogStart: (GLfloat) val;

/** Sets the end distance of the fog. */
-(void) setFogEnd: (GLfloat) val;


#pragma mark Materials

/** Sets the ambient color of the material. */
-(void) setMaterialAmbientColor: (ccColor4F) color;

/** Sets the diffuse color of the material. */
-(void) setMaterialDiffuseColor: (ccColor4F) color;

/** Sets the specular color of the material. */
-(void) setMaterialSpecularColor: (ccColor4F) color;

/** Sets the emission color of the material. */
-(void) setMaterialEmissionColor: (ccColor4F) color;

/** Sets the shininess of the material. */
-(void) setMaterialShininess: (GLfloat) val;

/** Sets the alpha function and reference value. */
-(void) setAlphaFunc: (GLenum) func reference: (GLfloat) ref;

/** Sets the blend function. */
-(void) setBlendFuncSrc: (GLenum) src dst: (GLenum) dst;


#pragma mark Textures

/** Generates and returns a new texture ID. */
-(GLuint) generateTextureID;

/** Deletes the texture with the specified texture ID from the GL engine. */
-(void) deleteTextureID: (GLuint) texID;

/**
 * Loads the specified texture image data, with the specified characteristics,
 * into the specified target at the specified texture unit, in GL memory.
 */
-(void) loadTexureImage: (const GLvoid*) imageData
			 intoTarget: (GLenum) target
			   withSize: (CC3IntSize) size
			 withFormat: (GLenum) texelFormat
			   withType: (GLenum) texelType
	  withByteAlignment: (GLint) byteAlignment
					 at: (GLuint) tuIdx;

/** 
 * Sets the specified texture unit as the active texture unit. Subsequent changes made to
 * texture unit properties will affect only this texture unit. The specified texture unit must
 * be a value between zero and the maximum number of texture units supported by the platform.
 *
 * This method is invoked automatically for any texture action method that identifies the
 * texture unit on which the action should be made. Normally, this method does not need to
 * be invoked directly.
 */
-(void) activateTextureUnit: (GLuint) tuIdx;

/**
 * Sets the specified texture unit as the active texture unit for client actions. 
 * Subsequent changes made to texture unit client properties will affect only this texture unit.
 * The specified texture unit must be a value between zero and the maximum number of texture
 * units supported by the platform.
 *
 * This method is invoked automatically for any texture action method that identifies the
 * texture unit on which the action should be made. Normally, this method does not need to
 * be invoked directly.
 */
-(void) activateClientTextureUnit: (GLuint) tuIdx;

/**
 * Enable/disable texturing for the specified target in the specified texture unit index, which
 * must be a value between zero and the maximum number of texture units supported by the platform.
 */
-(void) enableTexturing: (BOOL) onOff inTarget: (GLenum) target at: (GLuint) tuIdx;

/**
 * Disables texturing for all targets in all texture units starting at, and above, the specified
 * texture unit index, which must be a value between zero and the maximum number of texture units
 * supported by the platform.
 */
-(void) disableTexturingFrom: (GLuint) tuIdx;

/**
 * Binds the texture with the specified ID to the specified target at the specified texture
 * unit index, which must be a value between zero and the maximum number of texture units
 * supported by the platform.
 */
-(void) bindTexture: (GLuint) texID toTarget: (GLenum) target at: (GLuint) tuIdx;

/** 
 * Sets the texture minifying function in the specified target of the specified texture
 * unit index, which must be a value between zero and the maximum number of texture units
 * supported by the platform.
 */
-(void) setTextureMinifyFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx;

/**
 * Sets the texture magnifying function in the specified target of the specified texture
 * unit index, which must be a value between zero and the maximum number of texture units 
 * supported by the platform.
 */
-(void) setTextureMagnifyFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx;

/**
 * Sets the texture horizontal wrapping function in the specified target of the specified
 * texture unit index, which must be a value between zero and the maximum number of texture
 * units supported by the platform.
 */
-(void) setTextureHorizWrapFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx;

/**
 * Sets the texture vertical wrapping function in the specified target of the specified
 * texture unit index, which must be a value between zero and the maximum number of texture
 * units supported by the platform.
 */
-(void) setTextureVertWrapFunc: (GLenum) func inTarget: (GLenum) target at: (GLuint) tuIdx;

/** Generates a mipmap for the specified target for the texture bound to the specified texture unit. */
-(void) generateMipmapForTarget: (GLenum)target  at: (GLuint) tuIdx;

/**
 * Sets the texture environment mode of the specified texture unit index, which must
 * be a value between zero and the maximum number of texture units supported by the platform.
 */
-(void) setTextureEnvMode: (GLenum) mode at: (GLuint) tuIdx;

/**
 * Sets the texture environment color of the specified texture unit index, which must
 * be a value between zero and the maximum number of texture units supported by the platform.
 */
-(void) setTextureEnvColor: (ccColor4F) color at: (GLuint) tuIdx;

/**
 * Enable/disable point sprite texture coordinate replacement for the specified texture unit index,
 * which must be a value between zero and the maximum number of texture units supported by the platform.
 */
-(void) enablePointSpriteCoordReplace: (BOOL) onOff at: (GLuint) tuIdx;


#pragma mark Matrices

/** Activates the specified matrix stack to make it the current matrix stack. */
-(void) activateMatrixStack: (GLenum) mode;

/** Activates the specified palette matrix stack to make it the current matrix stack. */
-(void) activatePaletteMatrixStack: (GLuint) pmIdx;

/** Activates the modelview matrix stack and replaces the current matrix with the specified matrix. */
-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx;

/** Activates the projection matrix stack and replaces the current matrix with the specified matrix. */
-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx;

/** Activates the specified palette matrix stack and replaces the current matrix with the specified matrix. */
-(void) loadPaletteMatrix: (CC3Matrix4x3*) mtx at: (GLuint) pmIdx;

/** Activates the modelview matrix stack, pushes it down one level, and copies the old top to the new top. */
-(void) pushModelviewMatrixStack;

/** Activates the modelview matrix stack and pops off the current top level. */
-(void) popModelviewMatrixStack;

/** Activates the projection matrix stack, pushes it down one level, and copies the old top to the new top. */
-(void) pushProjectionMatrixStack;

/** Activates the projection matrix stack and pops off the current top level. */
-(void) popProjectionMatrixStack;


#pragma mark Hints

/** Sets the fog hint. */
-(void) setFogHint: (GLenum) hint;

/** Sets the mipmap generation hint. */
-(void) setGenerateMipmapHint: (GLenum) hint;

/** Sets the line smooting hint. */
-(void) setLineSmoothingHint: (GLenum) hint;

/** Sets the perspective correction hint. */
-(void) setPerspectiveCorrectionHint: (GLenum) hint;

/** Sets the point smooting hint. */
-(void) setPointSmoothingHint: (GLenum) hint;


#pragma mark Platform limits

/** 
 * Returns the maximum number of lights supported by the platform,
 * or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfLights;

/**
 * Returns the maximum number of clip planes supported by the platform,
 * or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfClipPlanes;

/**
 * Returns the maximum number of vertex skinning palette matrices supported by
 * the platform, or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfPaletteMatrices;

/**
 * Returns the maximum number of texture units supported by
 * the platform, or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfTextureUnits;

/**
 * Returns the maximum number of vertex attributes supported by
 * the platform, or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfVertexAttributes;

/**
 * Returns the maximum number of vertex skinning bone influences per vertex
 * supported by the platform, or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfVertexUnits;

/**
 * Returns the maximum number of pixel samples supported by the platform,
 * or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfPixelSamples;


#pragma mark Shaders

/** Selects and returns the shader program suitable for drawing the specified mesh node. */
-(CC3GLProgram*) selectProgramForMeshNode: (CC3MeshNode*) aMeshNode;

/** Binds the GL program associated with the mesh node being drawn by the specified visitor. */
-(void) bindProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Binds the specified GLSL program. */
-(void) bindProgram: (CC3GLProgram*) program withVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Returns a string containing platform-specific GLSL source code to be used as a
 * preamble for the vertex and fragment shader source code when compiling the shaders.
 */
-(NSString*) defaultShaderPreamble;


#pragma mark Aligning 2D & 3D caches

/**
 * Aligns the 2D state cache to that of this 3D cache.
 *
 * This is invoked durin the transition from 3D back to 2D drawing.
 */
-(void) align2DStateCache;

/**
 * Aligns the 3D state cache to the GL state left by the 2D drawing.
 *
 * This is invoked during the transition from 2D drawing to 3D drawing.
 */
-(void) align3DStateCache;


#pragma mark Allocation and initialization

/** Returns the shared singleton instance, creating it if necessary. */
+(CC3OpenGL*) sharedGL;

@end


#pragma mark -
#pragma mark State management functions

/**
 * Checks whether the specified boolean value changes the state of the GL engine for the state
 * tracked at the specified index in the specified stateBits. The isKnownBits bitfield keeps
 * track of whether or not the GL state is known at this time.
 *
 * If either the GL state is not known, or the specified value is different than the value currently
 * being tracked, this method updates the new value in the state cache, and marks the state value
 * as known, and returns YES, indicating that the state in the GL engine should be updated.
 * If the specified value is the same as the currently tracked state, this method returns NO.
 */
BOOL CC3CheckGLBooleanAt(GLuint idx, BOOL val, GLbitfield* stateBits, GLbitfield* isKnownBits);

/**
 * Checks whether the specified uint value changes the state of the GL engine for the state
 * tracked at the specified index in the specified stateArray. The isKnownBits bitfield keeps
 * track of whether or not the GL state is known at this time.
 *
 * If either the GL state is not known, or the specified value is different than the value currently
 * being tracked, this method updates the new value in the state cache, and marks the state value
 * as known, and returns YES, indicating that the state in the GL engine should be updated.
 * If the specified value is the same as the currently tracked state, this method returns NO.
 */
BOOL CC3CheckGLuintAt(GLuint idx, GLuint val, GLuint* stateArray, GLbitfield* isKnownBits);

/**
 * Checks whether the specified float value changes the state of the GL engine for the state
 * tracked at the specified index in the specified stateArray. The isKnownBits bitfield keeps
 * track of whether or not the GL state is known at this time.
 *
 * If either the GL state is not known, or the specified value is different than the value currently
 * being tracked, this method updates the new value in the state cache, and marks the state value
 * as known, and returns YES, indicating that the state in the GL engine should be updated.
 * If the specified value is the same as the currently tracked state, this method returns NO.
 */
BOOL CC3CheckGLfloatAt(GLuint idx, GLfloat val, GLfloat* stateArray, GLbitfield* isKnownBits);

/**
 * Checks whether the specified vector value changes the state of the GL engine for the state
 * tracked at the specified index in the specified stateArray. The isKnownBits bitfield keeps
 * track of whether or not the GL state is known at this time.
 *
 * If either the GL state is not known, or the specified value is different than the value currently
 * being tracked, this method updates the new value in the state cache, and marks the state value
 * as known, and returns YES, indicating that the state in the GL engine should be updated.
 * If the specified value is the same as the currently tracked state, this method returns NO.
 */
BOOL CC3CheckGLVectorAt(GLuint idx, CC3Vector val, CC3Vector* stateArray, GLbitfield* isKnownBits);

/**
 * Checks whether the specified 4D vector value changes the state of the GL engine for the state
 * tracked at the specified index in the specified stateArray. The isKnownBits bitfield keeps
 * track of whether or not the GL state is known at this time.
 *
 * If either the GL state is not known, or the specified value is different than the value currently
 * being tracked, this method updates the new value in the state cache, and marks the state value
 * as known, and returns YES, indicating that the state in the GL engine should be updated.
 * If the specified value is the same as the currently tracked state, this method returns NO.
 */
BOOL CC3CheckGLVector4At(GLuint idx, CC3Vector4 val, CC3Vector4* stateArray, GLbitfield* isKnownBits);

/**
 * Checks whether the specified color value changes the state of the GL engine for the state
 * tracked at the specified index in the specified stateArray. The isKnownBits bitfield keeps
 * track of whether or not the GL state is known at this time.
 *
 * If either the GL state is not known, or the specified value is different than the value currently
 * being tracked, this method updates the new value in the state cache, and marks the state value
 * as known, and returns YES, indicating that the state in the GL engine should be updated.
 * If the specified value is the same as the currently tracked state, this method returns NO.
 */
BOOL CC3CheckGLColorAt(GLuint idx, ccColor4F val, ccColor4F* stateArray, GLbitfield* isKnownBits);

/**
 * Checks whether the specified value changes the state of the GL engine for the capability
 * tracked at the specified index in the specified stateBits, and updates the GL engine with
 * the new value if it has changed. The isKnownBits bitfield keeps track of whether or not
 * the GL state is known at this time.
 */
void CC3SetGLCapAt(GLenum cap, GLuint idx, BOOL val, GLbitfield* stateBits, GLbitfield* isKnownBits);

/**
 * Macro for checking the state of a single state value and updating the cached value if needed.
 *
 * - val is the value to test.
 * - var is the instance variable used to cache the state value. May be updated.
 * - isKnown is the boolean instance variable that indicates whether the value is known. May be updated.
 * - equal contains a logical expression that determines whether val and var are equal.
 *
 * Defines and sets a local variable called  needsUpdate, to indicate whether the GL engine state
 * should be updated by the method or function that invoked this macro. This needsUpdate flag is
 * set to YES if the equal expression evaluates to NO, or the isKnown variable is set to NO.
 *
 * Both the var and isKnown instance variables are updated.
 *
 * This macro does not update the GL engine state. The calling function or method should do so
 * if the needsUpdate local variable is YES.
 */
#define cc3_CheckGLValue(val, equal, var, isKnown)		\
	BOOL needsUpdate = NO;								\
	if ( !(equal) || !isKnown) {						\
		var = (val);									\
		isKnown = YES;									\
		needsUpdate = YES;								\
}

/**
 * Macro for checking the state of a single state primitive variable and updating the cached
 * value if needed. Evaluates the cc3_CheckGLValue macro, passing a simple ((var) == (val))
 * test as the equal expression.
 */
#define cc3_CheckGLPrim(val, var, isKnown)  cc3_CheckGLValue((val), ((var) == (val)), var, isKnown)

/** Macro for checking the state of a single capability and setting it in GL engine if needed. */
#define cc3_SetGLCap(cap, val, var, isKnown)				\
	if ( !CC3BooleansAreEqual(val, var) || !isKnown) {		\
		isKnown = YES;										\
		var = val;											\
		if (val) glEnable(cap);								\
		else glDisable(cap);								\
		LogGLErrorTrace(@"gl%@able(%@)", (onOff ? @"En" : @"Dis"), NSStringFromGLEnum(cap));	\
	}

/** Macro for returning the state of a capability, retriving it from the GL engine if needed. */
#define cc3_GetGLCap(cap, var, isKnown)			\
	if (!isKnown) var = glIsEnabled(cap);		\
	return var;

/**
 * Macro for checking the state of a single state primitive value contained with an indexed
 * array of structs, and updating the cached value if needed. The sArray parameter is an array
 * of structs, and the VAR and IS_KNOWN parameters are the names of the struct elements holding
 * the value and isKnown indicator for the state, respectively. The idx parameter indexes into
 * a particualr struct in the array.
 *
 * Defines and sets a local variable called  needsUpdate, to indicate whether the GL engine state
 * should be updated by the method or function that invoked this macro. This needsUpdate flag is
 * set to YES if the equal expression evaluates to NO, or the isKnown variable is set to NO.
 *
 * Both the var and isKnown instance variables are updated.
 *
 * This macro does not update the GL engine state. The calling function or method should do so
 * if the needsUpdate local variable is YES.
 */
#define cc3_CheckGLStructValue(sArray, idx, val, VAR, IS_KNOWN)		\
	BOOL needsUpdate = NO;											\
	if ( !((sArray[idx].VAR) == (val)) || !sArray[idx].IS_KNOWN) {	\
		sArray[idx].VAR = (val);									\
		sArray[idx].IS_KNOWN = YES;									\
		needsUpdate = YES;											\
	}

