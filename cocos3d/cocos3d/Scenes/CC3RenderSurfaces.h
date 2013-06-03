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

/** The format of each pixel in the buffer. */
@property(nonatomic, readonly) GLenum pixelFormat;

/**
 * Resizes this attachment to the specified size by allocating off-screen storage space
 * within GL memory.
 *
 * The size property is updated to reflect the new size.
 */
-(void) resizeTo: (CC3IntSize) size;

/**
 * If this attachment supports pixel replacement, replaces a portion of the content of this
 * attachment by writing the specified array of pixels into the specified rectangular area
 * within this attachment, The specified content replaces the pixel data within the specified
 * rectangle. The specified content array must be large enough to contain content for the
 * number of pixels in the specified rectangle.
 *
 * Not all attachments support pixel replacement. In particular, pixel replacement is 
 * available only for color attachments whose content is provided by an underlying texture.
 * Attachments that do not support pixel replacement will simply ignore this method.
 *
 * Content is read from the specified array left to right across each row of pixels within
 * the specified image rectangle, starting at the row at the bottom of the rectangle, and
 * ending at the row at the top of the rectangle.
 *
 * Within the specified array, the pixel content should be packed tightly, with no gaps left
 * at the end of each row. The last pixel of one row should immediately be followed by the
 * first pixel of the next row.
 *
 * The pixels in the specified array are in standard 32-bit RGBA. If the format of the
 * underlying storage does not match this format, the specified array will be converted
 * to the format of the underlying storage before being inserted. Be aware that this
 * conversion will reduce the performance of this method. For maximum performance, match
 * the format of the underlying storage to the 32-bit RGBA format of the specified array.
 * However, keep in mind that the 32-bit RGBA format consumes more memory than most other
 * formats, so if performance is of lesser concern, you may choose to minimize the memory
 * requirements of this texture by choosing a more memory efficient storage format.
 */
-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray;

@end


#pragma mark -
#pragma mark CC3RenderSurface

/** A CC3RenderSurface is a surface on which rendering or drawing can occur. */
@protocol CC3RenderSurface <NSObject>

/** The size of this surface in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/** 
 * The surface attachment to which color data is rendered.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> colorAttachment;

/**
 * The surface attachment to which depth data is rendered.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface. For
 * instance, the same depth attachment might be used when rendering to several different color
 * attachments of different surfaces.
 */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> depthAttachment;

/**
 * The surface attachment to which stencil data is rendered.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> stencilAttachment;

/** Clears the color content of this surface, activating this surface if needed. */
-(void) clearColorContent;

/** Clears the depth content of this surface, activating this surface if needed. */
-(void) clearDepthContent;

/** Clears the stencil content of this surface, activating this surface if needed. */
-(void) clearStencilContent;

/** Clears the color and depth content of this surface, activating this surface if needed. */
-(void) clearColorAndDepthContent;

/**
 * Validates that this surface has a valid configuration in the GL engine.
 *
 * This method should be invoked to validate the surface once all attachments
 * have been set or resized.
 */
-(BOOL) validate;


#pragma mark Content

/**
 * Reads the content of the range of pixels defined by the specified rectangle from the
 * color attachment of this surface, into the specified array, which must be large enough
 * to accommodate the number of pixels covered by the specified rectangle.
 *
 * Content is written to the specified array left to right across each row, starting at the
 * row at the bottom of the image, and ending at the row at the top of the image. The pixel
 * content is packed tightly into the specified array, with no gaps left at the end of each
 * row. The last pixel of one row is immediately followed by the first pixel of the next row.
 *
 * This surface does not have to be the active surface to invoke this method. If this surface
 * is not the active surface, it will temporarily be made active, and when pixel reading has
 * finished, the currently active surface will be restored. This allows color to be read from
 * one surface while rendering to another surface.
 *
 * This method should be used with care, since it involves making a synchronous call to
 * query the state of the GL engine. This method will not return until the GL engine has
 * executed all previous drawing commands in the pipeline. Excessive use of this method
 * will reduce GL throughput and performance.
 */
-(void) readColorContentFrom: (CC3Viewport) rect into: (ccColor4B*) colorArray;

/**
 * If the colorAttachment of this surface supports pixel replacement, replaces a portion
 * of the content of the color attachment by writing the specified array of pixels into
 * the specified rectangular area within the attachment, The specified content replaces
 * the pixel data within the specified rectangle. The specified content array must be
 * large enough to contain content for the number of pixels in the specified rectangle.
 *
 * Not all color attachments support pixel replacement. In particular, pixel replacement is
 * available only for color attachments whose content is provided by an underlying texture.
 * If the color attachment does not support pixel replacement, this method will do nothing.
 *
 * Content is read from the specified array left to right across each row of pixels within
 * the specified image rectangle, starting at the row at the bottom of the rectangle, and
 * ending at the row at the top of the rectangle.
 *
 * Within the specified array, the pixel content should be packed tightly, with no gaps left
 * at the end of each row. The last pixel of one row should immediately be followed by the
 * first pixel of the next row.
 *
 * The pixels in the specified array are in standard 32-bit RGBA. If the format of the
 * underlying storage does not match this format, the specified array will be converted
 * to the format of the underlying storage before being inserted. Be aware that this
 * conversion will reduce the performance of this method. For maximum performance, match
 * the format of the underlying storage to the 32-bit RGBA format of the specified array.
 * However, keep in mind that the 32-bit RGBA format consumes more memory than most other
 * formats, so if performance is of lesser concern, you may choose to minimize the memory
 * requirements of this texture by choosing a more memory efficient storage format.
 */
-(void) replaceColorPixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray;


#pragma mark Drawing

/**
 * Activates this surface in the GL engine.
 *
 * Subsequent GL drawing activity will be rendered to this surface.
 */
-(void) activate;

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
 * CC3GLRenderbuffer implements the CC3FramebufferAttachment, allowing it to be attached to a
 * framebuffer.
 *
 * This class represents a general off-screen renderbuffer, whose storage is allocated from
 * GL memory. For the on-screen renderbuffer whose storage is shared by the view, use the
 * CC3OnScreenGLRenderbuffer subclass.
 */
@interface CC3GLRenderbuffer : NSObject <CC3FramebufferAttachment> {
	GLuint _rbID;
	CC3IntSize _size;
	GLenum _format;
	GLuint _samples;
}

/** The ID used to identify the renderbuffer to the GL engine. */
@property(nonatomic, readonly) GLuint renderbufferID;

/** Returns the number of samples used to define each pixel. */
@property(nonatomic, readonly) GLuint pixelSamples;


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
 */
-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance and allocates off-screen storage space
 * within GL memory for this buffer, sufficient to render an image of the specified size in
 * the specified pixel format.
 *
 * The size and pixelFormat properties of this instance are set to the specified values.
 * The pixelSamples property will be set to one.
 */
+(id) renderbufferWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with one sample per pixel.
 *
 * The size of this renderbuffer can be set by invoking the resizeTo: method.
 */
-(id) initWithPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * with one sample per pixel.
 *
 * The size of the renderbuffer can be set by invoking the resizeTo: method.
 */
+(id) renderbufferWithPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with number of samples per pixel.
 *
 * The size of this renderbuffer can be set by invoking the resizeTo: method.
 */
-(id) initWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * number of samples per pixel.
 *
 * The size of the renderbuffer can be set by invoking the resizeTo: method.
 */
+(id) renderbufferWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples;

@end


#pragma mark -
#pragma mark CC3OnScreenGLRenderbuffer

/**
 * CC3OnScreenGLRenderbuffer is a specialized renderbuffer whose contents are presented
 * to the screen, and whose storage is provided by the view under iOS.
 *
 * In this class, the implementation of the resizeTo: method does not allocate storage
 * within the GL engine, and sets the pixelFormat property by retrieving the value from
 * the GL engine.
 */
@interface CC3OnScreenGLRenderbuffer : CC3GLRenderbuffer {}

/**
 * Sets the size and retreives the pixelFormat property from the GL engine.
 *
 * As storage for renderbuffers of this class is provided by the view, this implementation
 * does not allocate storage space within GL memory.
 */
-(void) resizeTo: (CC3IntSize) size;

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
	CC3IntSize _size;
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
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * attachment has no size, or has a size that is different than the size of this surface,
 * the attachment is resized.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> colorAttachment;

/**
 * The attachment to which depth data is rendered.
 *
 * Implementation of the CC3RenderSurface depthAttachment property. Framebuffer attachments
 * must also support the CC3FramebufferAttachment protocol.
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * attachment has no size, or has a size that is different than the size of this surface,
 * the attachment is resized.
 *
 * When this property is set, if the depth format of the attachment includes a stencil component,
 * the stencilAttachment property is set to the this attachment as well.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface. For
 * instance, the same depth attachment might be used when rendering to several different color
 * attachments on different surfaces.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> depthAttachment;

/**
 * The attachment to which stencil data is rendered.
 *
 * Implementation of the CC3RenderSurface stencilAttachment property. Framebuffer attachments
 * must also support the CC3FramebufferAttachment protocol.
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * attachment has no size, or has a size that is different than the size of this surface,
 * the attachment is resized.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> stencilAttachment;

/**
 * If color content is being rendered to a texture, this property can be used to access
 * that texture.
 *
 * Setting this property wraps the specified texture in a CC3GLTextureFramebufferAttachment
 * instance and sets it into the colorAttachment property.
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * texture has no size, or has a size that is different than the size of this surface,
 * the texture is resized.
 *
 * Reading this property returns the texture within the CC3GLTextureFramebufferAttachment
 * in the colorAttachment property. It is an error to attempt to read this property if the
 * depthAttachment property does not contain an instance of CC3GLTextureFramebufferAttachment.
 *
 * To save memory, textures can be shared between surfaces of the same size, if the contents
 * of the texture are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) CC3GLTexture* colorTexture;

/**
 * If depth content is being rendered to a texture, this property can be used to access
 * that texture.
 *
 * Setting this property wraps the specified texture in a CC3GLTextureFramebufferAttachment
 * instance and sets it into the depthAttachment property, as well as the stencilAttachment
 * property, if the depth format of the texture includes a stencil component.
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * texture has no size, or has a size that is different than the size of this surface,
 * the texture is resized.
 *
 * Reading this property returns the texture within the CC3GLTextureFramebufferAttachment
 * in the depthAttachment property. It is an error to attempt to read this property if the
 * depthAttachment property does not contain an instance of CC3GLTextureFramebufferAttachment.
 *
 * To save memory, textures can be shared between surfaces of the same size, if the contents
 * of the texture are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) CC3GLTexture* depthTexture;

/** 
 * The size of this framebuffer surface in pixels.
 *
 * Returns the value of the same properties retrieved from any of the attachments (which
 * must all have the same size for this framebuffer to be valid), or, if no attachments
 * have been set, returns the value set during initialization.
 *
 * It is not possible to resize the surface directly. To do so, resize each of the
 * attachments separately. Because attachments may be shared between surfaces, management
 * of attachment sizing is left to the application, to avoid resizing the same attachment
 * more than once, during any single resizing activity.
 */
@property(nonatomic, readonly) CC3IntSize size;

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

/** Initializes this instance with zero size. */
-(id) init;

/** Allocates and initializes an autoreleased instance with zero size. */
+(id) surface;

/**
 * Initializes this instance with the specified size.
 *
 * When attachments are assigned to this surface, each will be resized to the specified size.
 */
-(id) initWithSize: (CC3IntSize) size;

/**
 * Allocations and initializes an autoreleased instance with the specified size.
 *
 * When attachments are assigned to the instance, each will be resized to the specified size.
 */
+(id) surfaceWithSize: (CC3IntSize) size;

@end


#pragma mark -
#pragma mark CC3SystemGLFramebuffer

/**
 * Represents the virtual OpenGL framebuffer used by the OSX system to present to a window. 
 *
 * Each of the attachements should be a CC3SystemGLRenderbuffer.
 */
@interface CC3SystemGLFramebuffer : CC3GLFramebuffer
@end


#pragma mark -
#pragma mark CC3SystemGLRenderbuffer

/** Represents the virtual OpenGL framebuffer attachments used by the OSX system to present to a window. */
@interface CC3SystemGLRenderbuffer : CC3GLRenderbuffer {}
@end


#pragma mark -
#pragma mark CC3GLViewSurfaceManager

/**
 * Manages the render surfaces used to render content to the OS view on the screen.
 *
 * Wraps the view's surface, an optional anti-aliasing multisampling surface, and an
 * optional separate surface for rendering during node picking from touch events.
 *
 * If multisampling is not in use, rendering is directed to the surface in the the
 * viewSurface property, which is attached to the underlying core animation layer.
 * 
 * If multisampling is used, rendering is directed to the surface in the the 
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

/** Returns the stencil format of the pixels. */
@property(nonatomic, readonly) GLenum stencilFormat;

/** 
 * Returns the texture pixel format that matches the format of the color attachment
 * of the view's rendering surface.
 *
 * Under OpenGL, textures use different formatting than renderbuffers. When creating an
 * off-screen surface that uses a texture as its color attachment, you can use the values
 * returned by this property and the colorTexelType property to create a texture that
 * matches the format of the color buffer of the view's rendering surface.
 */
@property(nonatomic, readonly) GLenum colorTexelFormat;

/**
 * Returns the texture pixel type that matches the format of the color attachment
 * of the view's rendering surface.
 *
 * Under OpenGL, textures use different formatting than renderbuffers. When creating an
 * off-screen surface that uses a texture as its color attachment, you can use the values
 * returned by this property and the colorTexelFormat property to create a texture that
 * matches the format of the color buffer of the view's rendering surface.
 */
@property(nonatomic, readonly) GLenum colorTexelType;

/**
 * Returns the texture pixel format that matches the format of the depth attachment
 * of the view's rendering surface.
 *
 * Under OpenGL, textures use different formatting than renderbuffers. When creating an
 * off-screen surface that uses a texture as its depth attachment, you can use the values
 * returned by this property and the depthTexelType property to create a texture that
 * matches the format of the depth buffer of the view's rendering surface.
 */
@property(nonatomic, readonly) GLenum depthTexelFormat;

/**
 * Returns the texture pixel type that matches the format of the depth attachment
 * of the view's rendering surface.
 *
 * Under OpenGL, textures use different formatting than renderbuffers. When creating an
 * off-screen surface that uses a texture as its depth attachment, you can use the values
 * returned by this property and the depthTexelFormat property to create a texture that
 * matches the format of the depth buffer of the view's rendering surface.
 */
@property(nonatomic, readonly) GLenum depthTexelType;

/** The renderbuffer that is the colorAttachment to the framebuffer in the viewSurface property. */
@property(nonatomic, readonly) CC3GLRenderbuffer* viewColorBuffer;

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
 * multisampling is in use. For example, if the value of the pixelSamples property is 4,
 * then the width and height returned by this property will be twice that of the width
 * and height of returned by the size property.
 */
@property(nonatomic, readonly) CC3IntSize multisamplingSize;

/**
 * If the view supports multisampling, resolve the multisampling surface into the view surface.
 *
 * If framebuffer discarding is supported, this method also instructs the GL engine to allow the
 * discarding of any framebuffers that are not needed for presenting the final image to the screen.
 *
 * Upon completion, this method leaves the renderbuffer that is attached to the view (in the
 * viewColorBuffer property) bound to the GL engine, so that it can be presented to the view.
 */
-(void) resolveMultisampling;


#pragma mark Resizing surfaces

/**
 * Registers the specified surface to be automatically resized when the view is resized.
 *
 * The attachments of the specified surface will have the resizeTo: method invoked whenever
 * the view is resized.
 *
 * If you have created an off-screen surface, and you want it to be resized automatically
 * whenever the view is resized, you can register it using this method. Do not register a
 * surface that you do not want resized when the view is resized.
 *
 * You can use the addSurfaceWithColorAttachmentType:andDepthAttachmentType: method to
 * create and register a surface in one step.
 *
 * It is safe to register the same surface more than once, and it is safe to register two
 * surfaces that share one or more attachments. This implementation will ensure that each
 * attachment is resized only once for each view resizing.
 */
-(void) addSurface: (id<CC3RenderSurface>) surface;

/**
 * Removes the specified surface previously added with the addSurface: method.
 *
 * It is safe to invoke this method even if the specified surface has never been added,
 * or has already been removed.
 */
-(void) removeSurface: (id<CC3RenderSurface>) surface;

/** Resizes the framebuffers in this instance to the specified size. */
-(void) resizeTo: (CC3IntSize) size;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified color and depth format, and with the specified
 * number of samples per pixel. If anti-aliasing multisampling is to be used, the value of
 * requestedSamples should be larger than one, but below the maximum number of samples per pixel
 * defined by the platform, which can be retrieved from CC3OpenGL.sharedGL.maxNumberOfPixelSamples.
 *
 * This initialization method should only be used with iOS.
 */
-(id) initWithColorFormat: (GLenum) colorFormat
		   andDepthFormat: (GLenum) depthFormat
		  andPixelSamples: (GLuint) requestedSamples;

/**
 * Initializes this instance to match the OSX window surface, with the specified color, depth,
 * and stencil format, and with the specified number of samples per pixel.
 *
 * This initialization method should only be used with OSX.
 */
-(id) initSystemColorFormat: (GLenum) colorFormat
			 andDepthFormat: (GLenum) depthFormat
			andPixelSamples: (GLuint) samples;
@end

/** 
 * Returns the texture format that matches the specified color renderbuffer format.
 *
 * Use this function along with the CC3TexelTypeFromRenderBufferColorFormat to determine
 * the format and type of texture to create to match the specified renderbuffer format.
 */
GLenum CC3TexelFormatFromRenderbufferColorFormat(GLenum rbFormat);

/**
 * Returns the texture type that matches the specified color renderbuffer format.
 *
 * Use this function along with the CC3TexelFormatFromRenderBufferColorFormat to determine
 * the format and type of texture to create to match the specified renderbuffer format.
 */
GLenum CC3TexelTypeFromRenderbufferColorFormat(GLenum rbFormat);

/**
 * Returns the texture format that matches the specified depth renderbuffer format.
 *
 * Use this function along with the CC3TexelTypeFromRenderBufferColorFormat to determine
 * the format and type of texture to create to match the specified renderbuffer format.
 */
GLenum CC3TexelFormatFromRenderbufferDepthFormat(GLenum rbFormat);

/**
 * Returns the texture type that matches the specified depth renderbuffer format.
 *
 * Use this function along with the CC3TexelFormatFromRenderBufferColorFormat to determine
 * the format and type of texture to create to match the specified renderbuffer format.
 */
GLenum CC3TexelTypeFromRenderbufferDepthFormat(GLenum rbFormat);
