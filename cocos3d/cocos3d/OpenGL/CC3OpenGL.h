/*
 * CC3OpenGL.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Identifiable.h"
#import "CC3OSExtensions.h"
#import "CC3Matrix4x4.h"

@class CC3NodeDrawingVisitor, CC3Mesh, CC3Fog;
@class CC3GLSLVariable, CC3GLSLUniform, CC3GLSLAttribute;
@class CC3ShaderProgram, CC3ShaderPrewarmer;
@protocol CC3OpenGLDelegate;


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
@interface CC3OpenGL : CC3Identifiable {
	CC3GLContext* _context;
	NSMutableSet* _extensions;
	NSTimeInterval _deletionDelay;

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
	
	GLenum value_GL_BLEND_SRC_RGB;
	GLenum value_GL_BLEND_DST_RGB;
	GLenum value_GL_BLEND_SRC_ALPHA;
	GLenum value_GL_BLEND_DST_ALPHA;
	
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
	GLint valueMaxBoneInfluencesPerVertex;
	GLint value_GL_MAX_TEXTURE_SIZE;
	GLint value_GL_MAX_CUBE_MAP_TEXTURE_SIZE;
	GLint value_GL_MAX_RENDERBUFFER_SIZE;

	GLuint value_GL_ARRAY_BUFFER_BINDING;
	GLuint value_GL_ELEMENT_ARRAY_BUFFER_BINDING;
	GLuint value_GL_VERTEX_ARRAY_BINDING;

	GLuint value_GL_ACTIVE_TEXTURE;
	GLuint value_MaxTextureUnitsUsed;
	
	GLuint value_GL_FRAMEBUFFER_BINDING;
	GLenum value_GL_FRAMEBUFFER_Target;
	GLuint value_GL_RENDERBUFFER_BINDING;
	GLuint value_GL_PACK_ALIGNMENT;
	GLuint value_GL_UNPACK_ALIGNMENT;

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
	BOOL isKnown_GL_VERTEX_ARRAY_BINDING : 1;

	BOOL isKnown_GL_ACTIVE_TEXTURE : 1;
	
	BOOL isKnown_GL_FRAMEBUFFER_BINDING : 1;
	BOOL isKnown_GL_FRAMEBUFFER_Target : 1;
	BOOL isKnown_GL_RENDERBUFFER_BINDING : 1;
	BOOL isKnown_GL_PACK_ALIGNMENT : 1;
	BOOL isKnown_GL_UNPACK_ALIGNMENT : 1;

}

/** 
 * The OpenGL engine context.
 *
 * The initial value of this property depends on the platform. Under iOS, this property 
 * will be initialized to an appropriate OpenGL ES context during instance initialization.
 * Under OSX, this property will be set by the CC3GLView for the primary rendering context
 * (isRenderingContext property is YES), and will be initialized to a shared GL context
 * for background instances (isRenderingContext property is NO).
 */
@property(nonatomic, retain) CC3GLContext* context;

/**
 * Returns whether this instance is tracking state for the primary rendering GL context
 * on the rendering thread.
 */
@property(nonatomic, readonly) BOOL isRenderingContext;

/**
 * Returns the CC3OpenGLDelegate delegate that will receive callback notifications for
 * asynchronous OpenGL activities.
 */
+(NSObject<CC3OpenGLDelegate>*) delegate;

/**
 * Sets the CC3OpenGLDelegate delegate that will receive callback notifications for
 * asynchronous OpenGL activities.
 */
+(void) setDelegate: (NSObject<CC3OpenGLDelegate>*) delegate;


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

/** Binds the VAO with the specified ID. */
-(void) bindVertexArrayObject: (GLuint) vaoId;

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


#pragma mark Lighting

/** Enable/disable lighting. */
-(void) enableLighting: (BOOL) onOff;

/** Enable/disable two-sided lighting. */
-(void) enableTwoSidedLighting: (BOOL) onOff;

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

/** Binds the specified fog configuration to the GL engine. */
-(void) bindFog: (CC3Fog*) fog withVisitor: (CC3NodeDrawingVisitor*) visitor;

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

/** Sets the blend function, forcing RGB and alpha blending to use the same blending function. */
-(void) setBlendFuncSrc: (GLenum) src dst: (GLenum) dst;

/** Sets the blend function, allowing RGB and alpha blending to be set separately. */
-(void) setBlendFuncSrcRGB: (GLenum) srcRGB dstRGB: (GLenum) dstRGB
				  srcAlpha: (GLenum) srcAlpha dstAlpha: (GLenum) dstAlpha;


#pragma mark Textures

/** Generates a new texture and returns its ID. */
-(GLuint) generateTexture;

/** Deletes the texture with the specified ID from the GL engine. */
-(void) deleteTexture: (GLuint) texID;

/** 
 * Clears the tracking of the specified texture.
 *
 * For each texture unit whose state tracking indicates that it is bound to the specified
 * texture, sets the tracking state for that texture unit to the default texture ID (0),
 * to ensure that the state tracking no longer expects to be bound to that texture.
 *
 * This method is invoked automatically whenever a GL texture is deleted, or whenever a 
 * GL texture is removed from cocos3d, but may still be in use by cocos2d.
 */
-(void) clearTextureBinding: (GLuint) texID;

/**
 * Loads the specified texture image data, with the specified characteristics,
 * into the specified target at the specified texture unit, in GL memory.
 */
-(void) loadTexureImage: (const GLvoid*) imageData
			 intoTarget: (GLenum) target
		  onMipmapLevel: (GLint) mipmapLevel
			   withSize: (CC3IntSize) size
			 withFormat: (GLenum) texelFormat
			   withType: (GLenum) texelType
	  withByteAlignment: (GLint) byteAlignment
					 at: (GLuint) tuIdx;

/**
 * Loads the specified texture image data, with the specified characteristics, into the
 * specified rectangular area within the texture at the specified target and texture unit,
 * in GL memory. The image data replaces the texture data within the specified bounds.
 */
-(void) loadTexureSubImage: (const GLvoid*) imageData
				intoTarget: (GLenum) target
			 onMipmapLevel: (GLint) mipmapLevel
			 intoRectangle: (CC3Viewport) rect
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
 * Disables texturing for all targets in the specified texture unit index, which must be a value
 * between zero and the maximum number of texture units supported by the platform.
 */
-(void) disableTexturingAt: (GLuint) tuIdx;

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


#pragma mark Framebuffers

/** Generates and returns a new framebuffer ID. */
-(GLuint) generateFramebuffer;

/** Deletes the framebuffer with the specified ID from the GL engine. */
-(void) deleteFramebuffer: (GLuint) fbID;

/** Makes the framebuffer with the specified ID the current framebuffer in the GL engine. */
-(void) bindFramebuffer: (GLuint) fbID;

/** 
 * Resolves the content in the specified multisample framebuffer into the specified framebuffer,
 * and leaves the multisample framebuffer bound to the GL_FRAMEBUFFER target for further rendering.
 */
-(void) resolveMultisampleFramebuffer: (GLuint) fbSrcID intoFramebuffer: (GLuint) fbDstID;

/**
 * Discards the specified attachments from the specified framebuffer.
 *
 * The attachments parameter is an array of framebuffer attachments enums that is may include:
 *  - GL_COLOR_ATTACHMENT0
 *  - GL_DEPTH_ATTACHMENT
 *  - GL_STENCIL_ATTACHMENT
 *
 * The count parameter indicates the length of this array.
 */
-(void) discard: (GLsizei) count attachments: (const GLenum*) attachments fromFramebuffer: (GLuint) fbID;

/** Generates and returns a new renderbuffer ID. */
-(GLuint) generateRenderbuffer;

/** Deletes the renderbuffer with the specified ID from the GL engine. */
-(void) deleteRenderbuffer: (GLuint) rbID;

/** Makes the renderbuffer with the specified ID the current renderbuffer in the GL engine. */
-(void) bindRenderbuffer: (GLuint) rbID;

/** 
 * Allocates storage for the specified renderbuffer, sufficient to render an image of the
 * specified size, in the specified pixel format, and with the specified number of samples
 * per pixel, which will be a value larger than one if antialiasing multisampling is in use.
 * If multi-sampling is not supported by the platform, the pixelSamples value is ignored.
 */
-(void) allocateStorageForRenderbuffer: (GLuint) rbID
							  withSize: (CC3IntSize) size
							 andFormat: (GLenum) format
							andSamples: (GLuint) pixelSamples;

/** Returns the current value in the GL engine of the specified integer renderbuffer parameter. */
-(GLint) getRenderbufferParameterInteger: (GLenum) param;

/** Binds the specified renderbuffer to the specified framebuffer as the specified attachement. */
-(void) bindRenderbuffer: (GLuint) rbID toFrameBuffer: (GLuint) fbID asAttachment: (GLenum) attachment;

/** 
 * Binds the specified mipmap level of the specified face of the specified texture to the
 * specified framebuffer as the specified attachement.
 */
-(void) bindTexture2D: (GLuint) texID
				 face: (GLenum) face
		  mipmapLevel: (GLint) mipmapLevel
		toFrameBuffer: (GLuint) fbID
		 asAttachment: (GLenum) attachment;

/**
 * Checks the completeness status of the specified framebuffer, and returns YES if the framebuffer
 * is complete and ready to be drawn to, or NO if the framebuffer is not ready to be drawn to.
 *
 * If the framebuffer is not complete, an error is logged, and, if the GL_ERROR_ASSERTION_ENABLED
 * compiler build setting is set, an assertion error is raised.
 */
-(BOOL) checkFramebufferStatus: (GLuint) fbID;

/**
 * Clears the buffers identified by the specified bitmask, which is a bitwise OR
 * combination of one or more of the following masks: GL_COLOR_BUFFER_BIT,
 * GL_DEPTH_BUFFER_BIT, and GL_STENCIL_BUFFER_BIT
 */
-(void) clearBuffers: (GLbitfield) mask;

/**
 * Reads the color content of the range of pixels defined by the specified rectangle from the
 * GL color buffer of the currently bound framebuffer, into the specified array, which must be
 * large enough to accommodate the number of pixels covered by the specified rectangle.
 *
 * Content is written to memory left to right across each row, starting at the row at the bottom
 * of the image, and ending at the row at the top of the image. The pixel content is packed
 * tightly into the specified array, with no gaps left at the end of each row. In memory, the
 * last pixel of one row is immediately followed by the first pixel of the next row.
 *
 * If the specified framebuffer is not the active framebuffer, it is temporarily activated,
 * long enough to read the contents, then the current framebuffer is reactivated. This allows
 * pixels to be read from a secondary framebuffer while rendering to the active framebuffer.
 *
 * This method should be used with care, since it involves making a synchronous call to
 * query the state of the GL engine. This method will not return until the GL engine has
 * executed all previous drawing commands in the pipeline. Excessive use of this method
 * will reduce GL throughput and performance.
 */
-(void) readPixelsIn: (CC3Viewport) rect  fromFramebuffer: (GLuint) fbID into: (ccColor4B*) colorArray;

/**
 * Sets the packing alignment when writing pixel content from the GL engine into application
 * memory to the specified alignment, which may be 1, 2, 4 or 8.
 *
 * This value indicates whether each row of pixels should start at a 1, 2, 4 or 8 byte boundary.
 * Depending on the width of the image, a value other than 1 may result in additional bytes being
 * added at the end of each row of pixels, in order to maintain the specified byte alignment.
 * The contents of those additional bytes is undefined.
 */
-(void) setPixelPackingAlignment: (GLint) byteAlignment;

/**
 * Sets the unpacking alignment when reading pixel content from application memory for copying
 * into the GL engine to the specified alignment, which may be 1, 2, 4 or 8.
 *
 * This value indicates whether each row of pixels should start at a 1, 2, 4 or 8 byte boundary.
 * Depending on the width of the image, a value other than 1 may require that the application
 * add additional bytes to the end of each row of pixels, in order to maintain the specified
 * byte alignment. The contents of those additional bytes is not copied into the GL engine.
 */
-(void) setPixelUnpackingAlignment: (GLint) byteAlignment;


#pragma mark Platform & GL info

/** Flushes the GL buffer to the GL hardware. */
-(void) flush;

/** Flushes the GL buffer to the GL hardware, and returns only when all GL commands have finished. */
-(void) finish;

/** Returns the current value in the GL engine of the specified integer parameter. */
-(GLint) getInteger: (GLenum) param;

/** Returns the current value in the GL engine of the specified float parameter. */
-(GLfloat) getFloat: (GLenum) param;

/** Returns the current value in the GL engine of the specified string parameter. */
-(NSString*) getString: (GLenum) param;

/** Returns the maximum number of lights supported by the platform. */
@property(nonatomic, readonly) GLuint maxNumberOfLights;

/** Returns the maximum number of clip planes supported by the platform. */
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
@property(nonatomic, readonly) GLuint maxNumberOfBoneInfluencesPerVertex;

/** @deprecated Renamed to maxNumberOfBoneInfluencesPerVertex. */
@property(nonatomic, readonly) GLuint maxNumberOfVertexUnits DEPRECATED_ATTRIBUTE;

/**
 * Returns the maximum number of pixel samples supported by the platform,
 * or zero if the platform does not impose a limit.
 */
@property(nonatomic, readonly) GLuint maxNumberOfPixelSamples;

/** Returns the maximum size for a renderbuffer supported by the platform. */
@property(nonatomic, readonly) GLuint maxRenderbufferSize;

/** Returns the maximum size for a 2D texture supported by the platform. */
@property(nonatomic, readonly) GLuint maxTextureSize;

/** Returns the maximum size for a cube-map texture supported by the platform. */
@property(nonatomic, readonly) GLuint maxCubeMapTextureSize;

/** Returns the maximum size for a texture used for the specified target supported by the platform. */
-(GLuint) maxTextureSizeForTarget: (GLenum) target;

/** Returns the maximum number of GLSL uniform vectors allowed in each vertex shader. */
@property(nonatomic, readonly) GLuint maxNumberOfVertexShaderUniformVectors;

/** Returns the maximum number of GLSL uniform vectors allowed in each fragment shader. */
@property(nonatomic, readonly) GLuint maxNumberOfFragmentShaderUniformVectors;

/** Returns the maximum number of GLSL varying vectors allowed in each shader program. */
@property(nonatomic, readonly) GLuint maxNumberOfShaderProgramVaryingVectors;

/**
 * Returns the minimum precision value of the shader variable of the specified type for a
 * vertex shader, or returns zero if the platform does not support shader precision modifiers.
 *
 * For float variable types, this value is the (+/-) minimum resolvable value.
 * For int variable types, this is the absolute minimum negative value.
 * 
 * The precisionType argument must be one of:
 *  - GL_LOW_FLOAT
 *  - GL_MEDIUM_FLOAT
 *  - GL_HIGH_FLOAT
 *  - GL_LOW_INT
 *  - GL_MEDIUM_INT
 *  - GL_HIGH_INT
 */
-(GLfloat) vertexShaderVarRangeMin: (GLenum) precisionType;

/**
 * Returns the maximum precision value of the shader variable of the specified type for a
 * vertex shader, or returns zero if the platform does not support shader precision modifiers.
 *
 * For float variable types, this value is the (+/-) maximum value.
 * For int variable types, this is the absolute maximum positive value.
 *
 * The precisionType argument must be one of:
 *  - GL_LOW_FLOAT
 *  - GL_MEDIUM_FLOAT
 *  - GL_HIGH_FLOAT
 *  - GL_LOW_INT
 *  - GL_MEDIUM_INT
 *  - GL_HIGH_INT
 */
-(GLfloat) vertexShaderVarRangeMax: (GLenum) precisionType;

/**
 * Returns the resolvable precision of the shader variable of the specified type within a
 * vertex shader, or returns zero if the platform does not support shader precision modifiers.
 *
 * The precisionType argument must be one of:
 *  - GL_LOW_FLOAT
 *  - GL_MEDIUM_FLOAT
 *  - GL_HIGH_FLOAT
 *  - GL_LOW_INT
 *  - GL_MEDIUM_INT
 *  - GL_HIGH_INT
 */
-(GLfloat) vertexShaderVarPrecision: (GLenum) precisionType;

/**
 * Returns the minimum precision value of the shader variable of the specified type for a
 * fragment shader, or returns zero if the platform does not support shader precision modifiers.
 *
 * For float variable types, this value is the (+/-) minimum resolvable value.
 * For int variable types, this is the absolute minimum negative value.
 *
 * The precisionType argument must be one of:
 *  - GL_LOW_FLOAT
 *  - GL_MEDIUM_FLOAT
 *  - GL_HIGH_FLOAT
 *  - GL_LOW_INT
 *  - GL_MEDIUM_INT
 *  - GL_HIGH_INT
 */
-(GLfloat) fragmentShaderVarRangeMin: (GLenum) precisionType;

/**
 * Returns the maximum precision value of the shader variable of the specified type for a
 * fragment shader, or returns zero if the platform does not support shader precision modifiers.
 *
 * For float variable types, this value is the (+/-) maximum value.
 * For int variable types, this is the absolute maximum positive value.
 *
 * The precisionType argument must be one of:
 *  - GL_LOW_FLOAT
 *  - GL_MEDIUM_FLOAT
 *  - GL_HIGH_FLOAT
 *  - GL_LOW_INT
 *  - GL_MEDIUM_INT
 *  - GL_HIGH_INT
 */
-(GLfloat) fragmentShaderVarRangeMax: (GLenum) precisionType;

/**
 * Returns the resolvable precision of the shader variable of the specified type within a
 * fragment shader, or returns zero if the platform does not support shader precision modifiers.
 *
 * The precisionType argument must be one of:
 *  - GL_LOW_FLOAT
 *  - GL_MEDIUM_FLOAT
 *  - GL_HIGH_FLOAT
 *  - GL_LOW_INT
 *  - GL_MEDIUM_INT
 *  - GL_HIGH_INT
 */
-(GLfloat) fragmentShaderVarPrecision: (GLenum) precisionType;


#pragma mark GL Extensions

/** Returns a collection of names of the GL extensions supported by the platform. */
@property(nonatomic, retain, readonly) NSSet* extensions;

/**
 * Returns whether this platform supports the GL extension with the specified name, which
 * should be the name of the GL extension, as registered with the OpenGL standards bodies,
 * or as specified by the GPU driver manufacturer. 
 *
 * You may specify the name either with or without a "GL_" prefix 
 * (eg. both @"OES_packed_depth_stencil" and @"GL_OES_packed_depth_stencil" will work if
 * that extension is supported).
 *
 * This method checks the extensions collection for the presence of the specified name.
 * Although this is an optimized hash test, you should generally not use this test in 
 * time-critical code. If you need to frequently test for the presence of an extension
 * (for example, within the render loop), you should invoke this method once at the 
 * beginning of your app, and cache the resulting boolean value elsewhere in your code.
 */
-(BOOL) supportsExtension: (NSString*) extensionName;


#pragma mark Shaders

/** 
 * Creates a new shader of the specifed type and returns its ID.
 *
 * The shaderType parameter must be one of the following values:
 *   - GL_VERTEX_SHADER
 *   - GL_FRAGMENT_SHADER
 */
-(GLuint) createShader: (GLenum) shaderType;

/** Deletes the shader with the specified ID from the GL engine. */
-(void) deleteShader: (GLuint) shaderID;

/** @deprecated Use the compileShader:from:sourceCodeStrings: method instead. */
-(void) compileShader: (GLuint) shaderID fromSourceCodeStrings: (NSArray*) glslSources DEPRECATED_ATTRIBUTE;

/**
 * Compiles the specified shader from the specified number of GLSL source code strings, 
 * which is an array of null-terminated UTF8 strings. The number of source strings in 
 * the source string array must be at least as large as the specified count.
 *
 * You can use the getShaderWasCompiled: method to determine whether compilation was successful,
 * and the getLogForShader: method to retrieve the reason for any unsuccessful compilation.
 */
-(void) compileShader: (GLuint) shaderID
				 from: (GLuint) srcStrCount
	sourceCodeStrings: (const GLchar**) srcCodeStrings;

/** Returns whether the specified shader was successfully compiled. */
-(BOOL) getShaderWasCompiled: (GLuint) shaderID;

/** Returns the integer value of the specified GL engine parameter for the specified shader. */
-(GLint) getIntegerParameter: (GLenum) param forShader: (GLuint) shaderID;

/** Returns the GL status info log for the specified shader. */
-(NSString*) getLogForShader: (GLuint) shaderID;

/** Returns the GLSL source code for the specified shader. */
-(NSString*) getSourceCodeForShader: (GLuint) shaderID;

/**
 * Returns a string containing platform-specific GLSL source code to be used as a
 * preamble for the vertex and fragment shader source code when compiling the shaders.
 */
-(NSString*) defaultShaderPreamble;

/** Creates a new GLSL program and returns its ID. */
-(GLuint) createShaderProgram;

/** Deletes the shader program with the specified ID from the GL engine. */
-(void) deleteShaderProgram: (GLuint) programID;

/** Attaches the specified shader to the specified shader program. */
-(void) attachShader: (GLuint) shaderID toShaderProgram: (GLuint) programID;

/** Detaches the specified shader from the specified shader program. */
-(void) detachShader: (GLuint) shaderID fromShaderProgram: (GLuint) programID;

/** 
 * Links the specified shader program.
 *
 * You can use the getShaderProgramWasLinked: method to determine whether linking was successful,
 * and the getLogForShaderProgram: method to retrieve the reason for any unsuccessful link attempt.
 */
-(void) linkShaderProgram: (GLuint) programID;

/**
 * The shader prewarmer for this context.
 *
 * When loading, compiling and linking a shader program, some of the steps are deferred,
 * within the GL engine, until the shader is first used to draw a mesh. This can result
 * in a significant, unexpected, and undesired pause during the GL draw call.
 *
 * This prewarmer can be used to force that first draw call to be made immediately,
 * and to an off-screen surface, so it won't be visible.
 */
@property(nonatomic, retain) CC3ShaderPrewarmer* shaderProgramPrewarmer;

/** Returns whether the specified shader was successfully linked. */
-(BOOL) getShaderProgramWasLinked: (GLuint) programID;

/** Returns the integer value of the specified GL engine parameter for the specified shader program. */
-(GLint) getIntegerParameter: (GLenum) param forShaderProgram: (GLuint) programID;

/** Binds the specified GLSL program as the program to be used for subsequent rendering. */
-(void) useShaderProgram: (GLuint) programID;

/** Returns the GL status info log for the GL program. */
-(NSString*) getLogForShaderProgram: (GLuint) programID;

/** Populates the specified GLSL variable with info retrieved from the GL engine. */
-(void) populateShaderProgramVariable: (CC3GLSLVariable*) var;

/** 
 * Ensures that the shader program for the specified GLSL uniform is active, 
 * then sets the value of the uniform into the GL engine.
 */
-(void) setShaderProgramUniformValue: (CC3GLSLUniform*) uniform;

/**
 * Releases the shader compiler and its resources from the GL engine.
 *
 * It will be restored automatically on the next shader compilation request.
 */
-(void) releaseShaderCompiler;


#pragma mark Aligning 2D & 3D state

/**
 * Aligns the state within the GL engine to be suitable for 2D drawing by cocos2d.
 *
 * This is invoked automatically during the transition from 3D to 2D drawing. You can also  invoke
 * this method if you perform 3D activities outside of the normal drawing loop, and you find that
 * it interferes with subsequent 2D rendering by cocos2d. However, such occurrances should be rare,
 * and in most circumstances you should never need to invoke this method.
 */
-(void) alignFor2DDrawing;

/**
 * Aligns the state within the GL engine to be suitable for 3D drawing by cocos3d.
 *
 * This is invoked automatically during the transition from 2D to 3D drawing.
 */
-(void) alignFor3DDrawing;


#pragma mark OpenGL resources

/**
 * Clears content and resource caches that use OpenGL, including the CC3ShaderPrewarmer
 * instance in the shaderProgramPrewarmer property, and the following OpenGL resource caches:
 *
 * 	 - CC3Resource
 *   - CC3Texture
 *   - CC3ShaderProgram
 *   - CC3Shader
 *   - CC3ShaderSourceCode
 *   - CC3ShaderSourceCode
 */
-(void) clearOpenGLResourceCaches;


#pragma mark Allocation and initialization

/** 
 * Returns the shared singleton instance for the currently running thread, creating it if necessary.
 *
 * Within OpenGL, the state of the GL engine is tracked per thread. To support this, although the
 * interface is as a singleton, this implementation actually keeps track of a CC3OpenGL instance
 * per thread, and will return the appropriate instance according to which thread the invocation
 * of this method is occuring.
 *
 * Currently, a maximum of two instances are supported, one for the primary rendering thread, and
 * one for a single background thread that can be used for loading resources, textures, and shaders.
 */
+(CC3OpenGL*) sharedGL;

/** Returns the thread that is being used for primary rendering. */
+(NSThread*) renderThread;

/** Returns whether the current thread is being used for primary rendering. */
+(BOOL) isRenderThread;

/** 
 * Terminates the current use of OpenGL by this application.
 *
 * Terminates OpenGL and deletes all GL contexts, serving all threads. Also clears all caches
 * that contain content that uses OpenGL, including:
 * 	 - CC3Resource
 *   - CC3Texture
 *   - CC3ShaderProgram
 *   - CC3Shader
 *   - CC3ShaderSourceCode
 *
 * To ensure that further OpenGL calls are not attempted, before invoking this method, you 
 * should release all CC3Scenes and CC3ViewControllers that you have created or loaded, along
 * with any cocos2d components, and that the CCDirector singleton has been ended.
 *
 * CC3ViewController also provides a terminateOpenGL convenience method that will take care of
 * all of that for you, and then will invoke this method. Unless you have special requirements,
 * use that CC3ViewController terminateOpenGL method, instead of invoking this method directly.
 *
 * You can invoke this method (or preferrably the CC3ViewController terminateOpenGL method) 
 * when your app no longer needs support for OpenGL, or will not use OpenGL for a significant
 * amount of time, in order to free up app and OpenGL memory used by your application.
 *
 * To ensure that that the current GL activity has finished before pulling the rug out from
 * under it, this request is queued for each existing context, on the thread for which the
 * context was created, and will only be executed once any currently running tasks on the 
 * queue have been completed.
 *
 * In addition, once dequeued, a short delay is imposed, before the context instance is 
 * actually released and deallocated, to provide time for object deallocation and cleanup 
 * after the caches have been cleared, and autorelease pools have been drained. The length
 * of this delay may be different for each context instance, and is specified by the 
 * deletionDelay property of each instance.
 *
 * Since much of the processing of this method is handled through queued operations, as 
 * described above, this method will return as soon as the requests are queued, and well
 * before the operations have completed, and OpenGL has been terminated. 
 *
 * You can choose to be notified once all operations triggered by this method have completed,
 * and OpenGL has been terminated, by registering a delegate object using the setDelegate: 
 * class method. The delegate object will be sent the didTerminateOpenGL method once  all 
 * operations triggered by this method have completed, and OpenGL has been terminated. 
 * You should use this delegate notification if you intend to make use of OpenGL again, 
 * as you must wait for one OpenGL session to terminate before starting another.
 *
 * Note that, in order to ensure that OpenGL is free to shutdown, this method forces the
 * CC3Texture shouldCacheAssociatedCCTextures class-side property to NO, so that any
 * background loading that is currently occurring will not cache cocos2d textures.
 * If you had set this property to YES, and intend to restart OpenGL at some point, then
 * you might want to set it back to YES before reloading 3D resources again.
 *
 * Use this method with caution, as creating the GL contexts again will require significant overhead.
 */
+(void) terminateOpenGL;

/**
 * Indicates the length of time, in seconds, that this instance will wait after the terminateOpenGL
 * method is invoked, before this instance is actually deleted. This delay is intended to provide
 * time for object deallocation and cleanup after the caches have been cleared, and autorelease
 * pools have been drained.
 *
 * The value of this property is specified in seconds. The initial value of this is 0 for the
 * instance that is used on the primary rendering thread, and 0.25 for the instance that is used
 * for loading resources in the background.
 */
@property(nonatomic, assign) NSTimeInterval deletionDelay;

@end


#pragma mark CC3OpenGLDelegate

/**
 * This protocol specifies methods that will be invoked by certain asynchronous operations
 * performed by instances of CC3OpenGL.
 *
 * All callback notification methods are invoked on the main application thread.
 */
@protocol CC3OpenGLDelegate <CC3Object>

@optional

/** 
 * This method is invoked once all of the operations triggered by invoking the CC3OpenGL
 * terminateOpenGL class method have completed, and OpenGL has been terminated.
 */
-(void) didTerminateOpenGL;

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

/**
 * If info logging is enabled AND this is the primary rendering context, logs the specified
 * info message, otherwise does nothing.
 */
#define LogInfoIfPrimary(fmt, ...)	LogInfoIf(self.isRenderingContext, fmt, ##__VA_ARGS__)
