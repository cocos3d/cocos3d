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

@protocol CC3RenderSurfaceAttachment;


#pragma mark -
#pragma mark CC3RenderSurface

/** A CC3RenderSurface is a surface on which rendering or drawing can occur. */
@protocol CC3RenderSurface <NSObject>

/** The surface attachment to which color data is rendered. */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> colorAttachment;

/** The surface attachment to which depth data is rendered. */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> depthAttachment;

/** The surface attachment to which stencil data is rendered. */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> stencilAttachment;

/**
 * Validates that this surface has a valid configuration in the GL engine.
 *
 * This method should be invoked to validate the surface once all attachments
 * have been set or resized.
 */
-(BOOL) validate;


#pragma mark Drawing

/**
 * Activates this surface using the CC3OpenGL instance in the specified visitor.
 * Subsequent GL drawing activity will be rendered to this surface.
 */
-(void) activateWithVisitor: (CC3NodeDrawingVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3RenderSurfaceAttachment

/**
 * An implementation of CC3RenderSurfaceAttachment can be attached to a CC3RenderSurface
 * to provide a buffer to which drawing can occur. The type of data that is drawn to the
 * attachment depends on how it is attached to the CC3RenderSurface, and can include
 * color data, depth data, or stencil data.
 */
@protocol CC3RenderSurfaceAttachment <NSObject>

/** The size of this attachment in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/**
 * Resizes this attachment to the specified size by allocating off-screen storage space
 * within GL memory.
 *
 * The size property is updated to reflect the new size.
 */
-(void) resizeTo: (CC3IntSize) size;

@end


#pragma mark -
#pragma mark CC3FramebufferAttachment

/**
 * An implementation of CC3FramebufferAttachment can be attached to a CC3GLFramebuffer 
 * to provide a buffer to which drawing can occur. 
 *
 * This protocol extends the CC3RenderSurfaceAttachment protocol to add the ability to bind
 * the attachment to the framebuffer within the GL engine. Different implementations will
 * supply different types of binding.
 */
@protocol CC3FramebufferAttachment <CC3RenderSurfaceAttachment>

/** Binds this attachment to the specified framebuffer, as the specified attachment type. */
-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment;

/** 
 * Unbinds this buffer from the specified framebuffer, as the specified attachment type,
 * and leaves the framebuffer with no attachment of that type.
 */
-(void) unbindFromFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment;

@end

	
#pragma mark -
#pragma mark CC3GLRenderbuffer

/** 
 * Represents an OpenGL renderbuffer.
 *
 * You can configure a CC3GLRenderbuffer instance for either on-screen or off-screen rendering.
 *
 * CC3GLRenderbuffer implements the CC3FramebufferAttachment, allowing it to be attached to a
 * framebuffer.
 */
@interface CC3GLRenderbuffer : NSObject <CC3FramebufferAttachment> {
	GLuint _rbID;
	CC3IntSize _size;
	GLenum _format;
	GLuint _samples;
}

/** The ID used to identify the renderbuffer to the GL engine. */
@property(nonatomic, readonly) GLuint renderbufferID;

/** The format of each pixel. */
@property(nonatomic, readonly) GLenum pixelFormat;

/** Returns the number of samples used to define each pixel. */
@property(nonatomic, readonly) GLuint pixelSamples;

/**
 * Resizes this instance by using the specified core animation layer as the underlying
 * storage for this buffer.
 *
 * The size and pixelFormat properties are updated to reflect the size and format of the
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
 * The pixelSamples property is set to one.
 *
 * If this renderbuffer is rendering to the primary on-screen view, this method should not be invoked.
 * Instead, initialize using the init method, and then use the resizeFromCALayer:withContext: method
 * to attach the instance to an underlying CALayer.
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
 * If this renderbuffer is rendering to the primary on-screen view, this method should not be invoked.
 * Instead, initialize using the renderbuffer method, and then use the resizeFromCALayer:withContext:
 * method to attach the instance to an underlying CALayer.
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
 * as the rendering buffer.
 */
@interface CC3GLTextureFramebufferAttachment : NSObject <CC3FramebufferAttachment> {
	CC3GLTexture* _texture;
	GLenum _face;
	GLint _mipmapLevel;
}

/** The texture to bind as an attachment to the framebuffer, and into which rendering will occur. */
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

/** 
 * Initializes this instance to render to mipmap level zero of the specified 2D texture.
 *
 * Both the horizontalWrappingFunction and verticalWrappingFunction properties of the specified
 * texture will be set to GL_CLAMP_TO_EDGE, as required when using a texture as a rendering target.
 */
-(id) initWithTexture: (CC3GLTexture*) texture;

/** 
 * Allocates and initializes an autoreleased instance to render to mipmap level zero
 * of the specified 2D texture. 
 *
 * Both the horizontalWrappingFunction and verticalWrappingFunction properties of the specified
 * texture will be set to GL_CLAMP_TO_EDGE, as required when using a texture as a rendering target.
 */
+(id) attachmentWithTexture: (CC3GLTexture*) texture;

/**
 * Initializes this instance to render to mipmap level zero of the specified face of the
 * specified texture.
 *
 * Both the horizontalWrappingFunction and verticalWrappingFunction properties of the specified
 * texture will be set to GL_CLAMP_TO_EDGE, as required when using a texture as a rendering target.
 */
-(id) initWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face;

/**
 * Allocates and initializes an autoreleased instance to render to mipmap level zero of the
 * specified face of the specified texture.
 *
 * Both the horizontalWrappingFunction and verticalWrappingFunction properties of the specified
 * texture will be set to GL_CLAMP_TO_EDGE, as required when using a texture as a rendering target.
 */
+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face;

/**
 * Initializes this instance to render to the specified mipmap level of the specified face
 * of the specified texture.
 *
 * Both the horizontalWrappingFunction and verticalWrappingFunction properties of the specified
 * texture will be set to GL_CLAMP_TO_EDGE, as required when using a texture as a rendering target.
 */
-(id) initWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

/**
 * Allocates and initializes an autoreleased instance to render to the specified mipmap level
 * of the specified face of the specified texture.
 *
 * Both the horizontalWrappingFunction and verticalWrappingFunction properties of the specified
 * texture will be set to GL_CLAMP_TO_EDGE, as required when using a texture as a rendering target.
 */
+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

@end


#pragma mark -
#pragma mark CC3GLFramebuffer

/**
 * Represents an OpenGL framebuffer.
 *
 * Framebuffers hold between one and three attachments. Each attachment represents a rendering
 * surface that holds a particular type of drawn content: color, depth, or stencil content.
 * Typically, each of these attachments will be either a renderbuffer, a texture (to support
 * rendering to a texture, or nil, indicating that that type of content is not being rendered.
 */
@interface CC3GLFramebuffer : NSObject <CC3RenderSurface> {
	GLuint _fbID;
	id<CC3FramebufferAttachment> _colorAttachment;
	id<CC3FramebufferAttachment> _depthAttachment;
	id<CC3FramebufferAttachment> _stencilAttachment;
}

/** The ID used to identify the framebuffer to the GL engine. */
@property(nonatomic, readonly) GLuint framebufferID;

/**
 * The attachment to which color data is rendered.
 *
 * Implementation of the CC3RenderSurface colorAttachment property. Framebuffer attachments
 * must also support the CC3FramebufferAttachment protocol.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> colorAttachment;

/**
 * The attachment to which depth data is rendered.
 *
 * Implementation of the CC3RenderSurface depthAttachment property. Framebuffer attachments
 * must also support the CC3FramebufferAttachment protocol.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> depthAttachment;

/**
 * The attachment to which stencil data is rendered.
 *
 * Implementation of the CC3RenderSurface stencilAttachment property. Framebuffer attachments
 * must also support the CC3FramebufferAttachment protocol.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> stencilAttachment;

/**
 * Implementation of the CC3RenderSurface validate method.
 *
 * Validates that this framebuffer has a valid configuration in the GL engine.
 *
 * This method should be invoked to validate the surface, once all attachments have been
 * set or resized. If the configuration is not valid, an error is logged, and, if the
 * GL_ERROR_ASSERTION_ENABLED compiler build setting is set, an assertion error is raised.
 */
-(BOOL) validate;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
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
	CCArray* _resizeableSurfaces;
	CC3GLFramebuffer* _viewSurface;
	CC3GLFramebuffer* _multisampleSurface;
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
 * If multisampling is in use, this property returns the framebuffer in the multisampleSurface
 * property, otherwise it returns the framebuffer in the viewSurface property.
 */
@property(nonatomic, readonly) CC3GLFramebuffer* renderingSurface;

/**
 * The surface to which rendering for picking should be directed.
 *
 * In order for pixel colors to be read precisely, the surface in this property cannot use
 * multisampling. If multisampling is in use, this property is lazily initialized to a specialized
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

/** Returns whether multisampling is in use. */
@property(nonatomic, readonly) BOOL isMultisampling;

/**
 * Returns the size of this surface in multisampling pixels.
 *
 * The value of this property will be larger than the value of the size property if
 * multisampling is in use. For example, if the value of the pixelSamples property
 * is 4, then the width and height returned by this property will be twice that
 * of the width and height of returned by the size property.
 */
@property(nonatomic, readonly) CC3IntSize multisamplingSize;

/** 
 * Presents the content of the viewSurface framebuffer to the screen, by swapping the
 * buffers in the specified GL context in the underlying core animation layer.
 *
 * If multisampling is in use, the contents in the multisamplingSurface framebuffer are
 * first resolved into the viewSurface framebuffer.
 */
-(void) presentToContext: (EAGLContext*) context;


#pragma mark Surface resizing

/** Resizes the framebuffers in this instance from the specified core animation layer. */
-(BOOL) resizeFromCALayer: (CAEAGLLayer*) layer withContext: (EAGLContext*) context;

/**
 * Registers the specified surface to be automatically resized when the view is resized.
 *
 * The attachments of the specified surface will have the resizeTo: method invoked whenever
 * the view is resized.
 *
 * If you have created an off-screen surface, and you want it to be resized automatically
 * whenever the view is resized, you can register it using this method.
 *
 * It is safe to register the same surface more than once, and it is safe to register two
 * surfaces that share one or more attachments. This implementation will ensure that each
 * attachment is resized only once for each view resizing.
 */
-(void) addResizingSurface: (id<CC3RenderSurface>) surface;

/**
 * Removes the specified surface previously added with the addResizingSurface: method.
 *
 * It is safe to invoke this method even if the specified surface has never been added,
 * or has already been removed.
 */
-(void) removeResizingSurface: (id<CC3RenderSurface>) surface;


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




