/*
 * CC3RenderSurfaces.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3GLTexture.h"


#pragma mark -
#pragma mark CC3RenderSurface

/** A CC3RenderSurface is a surface on which rendering or drawing can occur. */
@protocol CC3RenderSurface <NSObject>

/**
 * Activates this surface using the CC3OpenGL instance in the specified visitor.
 * Subsequent GL drawing activity will be rendered to this surface.
 */
-(void) activateWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** 
 * Activates this surface using the CC3OpenGL sharedGL instance.
 * Subsequent GL drawing activity will be rendered to this surface.
 */
-(void) activate;

/** Returns whether this surface is a multisampling surface. */
@property(nonatomic, readonly) BOOL isMultisampling;

@end


#pragma mark -
#pragma mark CC3FramebufferAttachment

/**
 * An instance of CC3FramebufferAttachment can be attached to a CC3GLFramebuffer to
 * provide a buffer to which drawing can occur. The type of data that is drawn to the buffer
 * depends on how it is attached to the CC3GLFramebuffer, and can include color data,
 * depth data, or stencil data.
 */
@protocol CC3FramebufferAttachment <NSObject>

/** Binds this buffer to the specified framebuffer, as the specified type of attachment. */
-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment;

/** 
 * Unbinds this buffer from the specified framebuffer, as the specified type of attachment,
 * and leaves the framebuffer with no attachement of the specified type.
 */
-(void) unbindFromFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment;

@end

	
#pragma mark -
#pragma mark CC3GLRenderbuffer

/** 
 * Represents an OpenGL renderbuffer.
 *
 * You can configure a CC3GLRenderbuffer instance for either on-screen or off-screen rendering.
 */
@interface CC3GLRenderbuffer : NSObject <CC3FramebufferAttachment> {
	GLuint _rbID;
	CC3IntSize _size;
	GLenum _format;
	GLuint _samples;
}

/** The ID used to identify the underlying renderbuffer to the GL engine. */
@property(nonatomic, readonly) GLuint renderbufferID;

/** The size of the rendering surface of this renderbuffer in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/** The format of each pixel in this renderbuffer. */
@property(nonatomic, readonly) GLenum pixelFormat;

/** Returns the number of samples used to define each pixel. */
@property(nonatomic, readonly) GLuint pixelSamples;

/**
 * Resizes this instance to the specified size by allocating off-screen storage space within GL
 * memory for this buffer, sufficient to render an image of the specified size, in the pixel
 * format and number of samples indicated by the pixelFormat and pixelSamples properties.
 *
 * The size property is updated to reflect the new size.
 */
-(void) resizeTo: (CC3IntSize) size;

/**
 * Resizes this instance by using the specified core animation layer as the underlying
 * storage for this buffer.
 *
 * The size and format properties are updated to reflect the size and format of the
 * specified core animation layer, and the pixelSamples property is set to one, since
 * multisampling does not apply to the underlying core animation layer.
 */
-(void) resizeFromCALayer: (CAEAGLLayer*) layer withContext: (EAGLContext*) context;

/** Presents the contents of this renderbuffer to the screen via the specified context. */
-(void) presentToContext: (EAGLContext*) context;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance with one sample per pixel.
 *
 * The size and pixel format of this renderbuffer can be set by invoking the
 * resizeFromCALayer:withContext: method.
 */
+(id) renderbuffer;

/**
 * Initializes this instance and allocates off-screen storage space within GL memory for this
 * buffer, sufficient to render an image of the specified size in the  specified pixel format.
 *
 * The size and pixelFormat properties of this instance are set to the specified values.
 * The pixelSamples property will be set to one.
 *
 * If this renderbuffer is rendering to the primary on-screen view, this method should not be invoked.
 * Instead, initialize using the init method, and then use the allocateStorageFromCALayer:withContext:
 * method to attach the instance to an underlying CALayer.
 */
-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance and allocates off-screen storage space
 * within GL memory for this buffer, sufficient to render an image of the specified size in
 * the specified pixel format.
 *
 * The size and pixelFormat properties of this instance are set to the specified values.
 * The pixelSamples property will be set to one.
 *
 * If this renderbuffer is rendering to the primary on-screen view, this method should not
 * be invoked. Instead, allocate and initialize using the renderbuffer method, and then use the
 * allocateStorageFromCALayer:withContext: method to attach the instance to an underlying CALayer.
 */
+(id) renderbufferWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with one sample per pixel.
 *
 * The size of this renderbuffer can be set by invoking either the resizeTo: or 
 * resizeFromCALayer:withContext: methods.
 */
-(id) initWithPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * with one sample per pixel.
 *
 * The size of this renderbuffer can be set by invoking either the resizeTo: or
 * resizeFromCALayer:withContext: methods.
 */
+(id) renderbufferWithPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with number of samples per pixel.
 *
 * The size of this renderbuffer can be set by invoking either the resizeTo: or
 * resizeFromCALayer:withContext: methods.
 */
-(id) initWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * number of samples per pixel.
 *
 * The size of this renderbuffer can be set by invoking either the resizeTo: or
 * resizeFromCALayer:withContext: methods.
 */
+(id) renderbufferWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples;

@end


#pragma mark -
#pragma mark CC3GLTextureFramebufferAttachment

/**
 * CC3GLTextureFramebufferAttachment is a framebuffer attachment that uses a texture
 * as the rendering surface.
 */
@interface CC3GLTextureFramebufferAttachment : NSObject <CC3FramebufferAttachment> {
	CC3GLTexture*  _texture;
	GLenum _face;
	GLint _mipmapLevel;
}

/** 
 * The texture to bind as an attachment to the framebuffer, and into which rendering will occur.
 *
 * This property must be set prior to invoking the bindToFramebuffer:asAttachment: method.
 *
 * The initial value is set during initialization.
 */
@property(nonatomic, retain, readonly) CC3GLTexture* texture;

/** 
 * The target face within the texture into which rendering is to occur.
 *
 * This property must be set prior to invoking the bindToFramebuffer:asAttachment: method.
 *
 * For 2D textures, there is only one face, and this property should be set to GL_TEXTURE_2D.
 *
 * For cube-map textures, this should be set to one of:
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_X
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_X
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Z
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
 *
 * The initial value is set during initialization.
 */
@property(nonatomic, assign) GLenum face;

/**
 * The mipmap level of the texture into which rendering is to occur.
 *
 * This property must be set prior to invoking the bindToFramebuffer:asAttachment: method.
 *
 * The initial value is set during initialization.
 */
@property(nonatomic, assign) GLint  mipmapLevel;


#pragma mark Allocation and initialization

/** Initializes this instance to render to mipmap level zero of the specified 2D texture. */
-(id) initWithTexture: (CC3GLTexture*) texture;

/** 
 * Allocates and initializes an autoreleased instance to render to mipmap level zero
 * of the specified 2D texture. 
 */
+(id) attachmentWithTexture: (CC3GLTexture*) texture;

/**
 * Initializes this instance to render to mipmap level zero of the specified face of the
 * specified texture.
 */
-(id) initWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face;

/**
 * Allocates and initializes an autoreleased instance to render to mipmap level zero of the
 * specified face of the specified texture.
 */
+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face;

/**
 * Initializes this instance to render to the specified mipmap level of the specified face
 * of the specified texture.
 */
-(id) initWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

/**
 * Allocates and initializes an autoreleased instance to render to the specified mipmap level
 * of the specified face of the specified texture.
 */
+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

@end


#pragma mark -
#pragma mark CC3GLFramebuffer

/**
 * Represents an OpenGL framebuffer.
 *
 * Framebuffers hold between one and three attachments. Each attachment represents a rendering
 * surface that holds a particular type of drawn content: color content, depth content, or
 * stencil content. Typically, each of these attachments will be either a renderbuffer, a
 * texture (to support rendering to a texture, or nil, indicating that that type of content
 * is not being rendered.
 */
@interface CC3GLFramebuffer : NSObject <CC3RenderSurface> {
	GLuint _fbID;
	NSObject<CC3FramebufferAttachment>* _colorAttachment;
	NSObject<CC3FramebufferAttachment>* _depthAttachment;
	NSObject<CC3FramebufferAttachment>* _stencilAttachment;
}

/** The ID used to identify the underlying framebuffer to the GL engine. */
@property(nonatomic, readonly) GLuint framebufferID;

/**
 * The attachment to which color data is rendered.
 *
 * Setting this property binds the attachment to the underlying framebuffer in the GL engine.
 */
@property(nonatomic, retain) NSObject<CC3FramebufferAttachment>* colorAttachment;

/**
 * The attachment to which depth data is rendered.
 *
 * Setting this property binds the attachment to the underlying framebuffer in the GL engine.
 */
@property(nonatomic, retain) NSObject<CC3FramebufferAttachment>* depthAttachment;

/**
 * The attachment to which stencil data is rendered.
 *
 * Setting this property binds the attachment to the underlying framebuffer in the GL engine.
 */
@property(nonatomic, retain) NSObject<CC3FramebufferAttachment>* stencilAttachment;

/**
 * The attachment to which color data is rendered, cast as a CC3GLRenderbuffer.
 *
 * This is a convenience property for the common case of retrieving an attachement
 * that is a renderbuffer. It is the responsibility of the invoker to ensure that
 * the returned value actually is a CC3GLRenderbuffer.
 */
@property(nonatomic, readonly) CC3GLRenderbuffer* colorBuffer;

/**
 * The attachment to which depth data is rendered, cast as a CC3GLRenderbuffer.
 *
 * This is a convenience property for the common case of retrieving an attachement
 * that is a renderbuffer. It is the responsibility of the invoker to ensure that
 * the returned value actually is a CC3GLRenderbuffer.
 */
@property(nonatomic, readonly) CC3GLRenderbuffer* depthBuffer;

/**
 * The attachment to which stencil data is rendered, cast as a CC3GLRenderbuffer.
 *
 * This is a convenience property for the common case of retrieving an attachement
 * that is a renderbuffer. It is the responsibility of the invoker to ensure that
 * the returned value actually is a CC3GLRenderbuffer.
 */
@property(nonatomic, readonly) CC3GLRenderbuffer* stencilBuffer;

/**
 * Validates that this framebuffer has a valid configuration in the GL engine.
 *
 * This property can be used to validate the configuration, once the attachments have been set.
 * If the configuration is not valid, an error is logged, and, if the GL_ERROR_ASSERTION_ENABLED
 * compiler build setting is set, an assertion error is raised.
 */
-(BOOL) validate;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased intance. */
+(id) surface;

@end


#pragma mark -
#pragma mark CC3GLViewSurfaceManager

/**
 * Manages the render surfaces used to render content to the OS view on the screen.
 *
 * Wraps the CC3GLFramebuffer that represents the view surface, an optional anti-aliasing
 * multisampling CC3GLFramebuffer surface, and an optional separate surface for rendering
 * during node picking from touch events.
 *
 * If multisampling is not in use, rendering is directed to the framebuffer in the the
 * viewSurface property, which is attached to the underlying core animation layer.
 * 
 * If multisampling is used, rendering is directed to the framebuffer in the the
 * multisampleSurface property, and then once rendering is complete, the multisampled
 * surface is resolved into the view surface.
 */
@interface CC3GLViewSurfaceManager : NSObject {
	CC3GLFramebuffer* _viewSurface;
	CC3GLFramebuffer* _multisampleSurface;
	CC3GLFramebuffer* _renderingSurface;
	CC3GLFramebuffer* _pickingSurface;
}

/** The on-screen surface attached to the underlying core animation layer. */
@property(nonatomic, retain) CC3GLFramebuffer* viewSurface;

/**
 * The surface used for off-screen multisample rendering.
 *
 * The value of this property may be nil if multisampleing is not in use.
 */
@property(nonatomic, retain) CC3GLFramebuffer* multisampleSurface;

/**
 * The surface to which rendering should be directed.
 *
 * If multisampling is in use, this property is initialized to the surface in the multisampleSurface
 * property, otherwise it is initialized to the value of the viewSurface property.
 */
@property(nonatomic, retain) CC3GLFramebuffer* renderingSurface;

/**
 * The surface to which rendering for picking should be directed.
 *
 * In order for pixel colors to be read precisely, the surface in this property cannot use
 * multisamplig. If multisampling is in use, this property is lazily initialized to a specialized
 * non-multisampling surface. Otherwise, this property is lazily initialized to the surface in the
 * viewSurface property.
 *
 * Lazy initialization is used in case touch picking is never actually used by the app.
 */
@property(nonatomic, retain) CC3GLFramebuffer* pickingSurface;

/** The size of the rendering surface in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/** Returns the color format of the pixels. */
@property(nonatomic, readonly) GLenum colorFormat;

/** Returns the depth format of the pixels. */
@property(nonatomic, readonly) GLenum depthFormat;

/** 
 * Returns the number of samples used to define each pixel.
 *
 * If this value is larger than one, then multisampling is in use.
 */
@property(nonatomic, readonly) GLuint pixelSamples;

/** Resizes the framebuffers in this instance from the specified core animation layer. */
-(BOOL) resizeFromCALayer: (CAEAGLLayer*) layer withContext: (EAGLContext*) context;

/** 
 * Presents the content of the viewSurface framebuffer to the screen, by swapping the
 * buffers in the specified GL context in the underlying core animation layer.
 *
 * If multisampling is in use, the contents in the multisamplingSurface framebuffer are
 * first resolved into the viewSurface framebuffer.
 */
-(void) presentToContext: (EAGLContext*) context;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified color and depth format, and with the specified
 * number of samples per pixel. If anti-aliasing multisampling is to be used, the value of
 * requestedSamples should be larger than one, but below the maximum number of samples per pixel
 * defined by the platform, which can be retrieved from CC3OpenGL.sharedGL.maxNumberOfPixelSamples.
 */
-(id) initWithColorFormat: (GLenum) colorFormat
		   andDepthFormat: (GLenum) depthFormat
		  andPixelSamples: (GLuint) requestedSamples;

@end




