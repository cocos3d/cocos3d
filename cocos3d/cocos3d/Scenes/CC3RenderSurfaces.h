/*
 * CC3RenderSurfaces.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Texture.h"

@class CC3GLView, CC3Backgrounder;


#pragma mark -
#pragma mark CC3RenderSurfaceAttachment

/**
 * An implementation of CC3RenderSurfaceAttachment can be attached to a CC3RenderSurface
 * to provide a buffer to which drawing can occur. The type of data that is drawn to the
 * attachment depends on how it is attached to the CC3RenderSurface, and can include
 * color data, depth data, or stencil data.
 */
@protocol CC3RenderSurfaceAttachment <CC3Object>

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
@protocol CC3RenderSurface <CC3Object>

/** The size of this surface in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/** 
 * Returns whether this surface is an off-screen surface.
 *
 * Returns YES if this surface is rendering to off-screen memory, such as textures or
 * off-screen renderbuffers. Returns NO if this surface is rendering directly to the screen.
 */
@property(nonatomic, readonly) BOOL isOffScreen;

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

/**
 * Validates that this surface has a valid configuration in the GL engine.
 *
 * This method should be invoked to validate the surface once all attachments
 * have been set or resized.
 */
-(BOOL) validate;


#pragma mark Content

/**
 * Clears the color content of this surface, activating this surface and enabling
 * color writing if needed.
 */
-(void) clearColorContent;

/**
 * Clears the depth content of this surface, activating this surface and enabling
 * depth writing if needed.
 */
-(void) clearDepthContent;

/**
 * Clears the stencil content of this surface, activating this surface and enabling
 * stencil writing if needed.
 */
-(void) clearStencilContent;

/**
 * Clears the color and depth content of this surface, activating this surface and enabling
 * color and depth writing if needed.
 */
-(void) clearColorAndDepthContent;

/** Returns whether this surface supports reading the pixel content. */
@property(nonatomic, readonly) BOOL isColorContentReadable;

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
 * Not all surfaces have readable color content. If the isColorContentReadable returns NO,
 * the content read using this method may be unpredictable and inaccurate.
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

/**
 * Returns a newly created CGImageRef from the contents of this surface that are contained
 * within the specified rectangle. The size of the returned image will be the same as the
 * size of the rectangle.
 *
 * You are responsible for releasing the returned image by calling the CGImageRelease function.
 */
-(CGImageRef) createCGImageFrom: (CC3Viewport) rect;

/**
 * Returns a newly created CGImageRef from the contents of this surface. 
 * The size of the returned image will be the same as the size of this surface.
 *
 * You are responsible for releasing the returned image by calling the CGImageRelease function.
 */
-(CGImageRef) createCGImage;


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
 * CC3IOSOnScreenGLRenderbuffer subclass.
 */
@interface CC3GLRenderbuffer : NSObject <CC3FramebufferAttachment> {
	GLuint _rbID;
	CC3IntSize _size;
	GLenum _format;
	GLuint _samples;
}

/** The ID used to identify the renderbuffer to the GL engine. */
@property(nonatomic, readonly) GLuint renderbufferID;

/** 
 * Returns the format of each pixel in the buffer.
 *
 * The returned value may be one of the following:
 *   - GL_RGB8
 *   - GL_RGBA8
 *   - GL_RGBA4
 *   - GL_RGB5_A1
 *   - GL_RGB565
 *   - GL_DEPTH_COMPONENT16
 *   - GL_DEPTH_COMPONENT24
 *   - GL_DEPTH24_STENCIL8
 *   - GL_STENCIL_INDEX8
 */
@property(nonatomic, readonly) GLenum pixelFormat;

/** Returns the number of samples used to define each pixel. */
@property(nonatomic, readonly) GLuint pixelSamples;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance with one sample per pixel.
 *
 * The size and pixel format of this renderbuffer can be set by invoking the resizeTo: method.
 */
+(id) renderbuffer;

/**
 * Initializes this instance and allocates off-screen storage space within GL memory for this
 * buffer, sufficient to render an image of the specified size in the  specified pixel format.
 *
 * The size and pixelFormat properties of this instance are set to the specified values.
 * The pixelSamples property is set to one. 
 * 
 * See the pixelFormat property for allowable values for the format parameter.
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
 * See the pixelFormat property for allowable values for the format parameter.
 */
+(id) renderbufferWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with one sample per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The size of this renderbuffer can be set by invoking the resizeTo: method.
 */
-(id) initWithPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * with one sample per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The size of the renderbuffer can be set by invoking the resizeTo: method.
 */
+(id) renderbufferWithPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with number of samples per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The size of this renderbuffer can be set by invoking the resizeTo: method.
 */
-(id) initWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * number of samples per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The size of the renderbuffer can be set by invoking the resizeTo: method.
 */
+(id) renderbufferWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples;

@end


#pragma mark -
#pragma mark CC3IOSOnScreenGLRenderbuffer

/**
 * CC3IOSOnScreenGLRenderbuffer is a specialized renderbuffer whose contents are presented
 * to the screen, and whose storage is provided by the view under iOS.
 *
 * In this class, the implementation of the resizeTo: method does not allocate storage within
 * the GL engine, and sets the pixelFormat property by retrieving the value from the GL engine.
 */
@interface CC3IOSOnScreenGLRenderbuffer : CC3GLRenderbuffer

/**
 * Sets the size and retreives the pixelFormat property from the GL engine.
 *
 * As storage for renderbuffers of this class is provided by the view, this implementation
 * does not allocate storage space within GL memory.
 */
-(void) resizeTo: (CC3IntSize) size;

@end


#pragma mark -
#pragma mark CC3SystemOnScreenGLRenderbuffer

/** 
 * Represents the virtual OpenGL framebuffer attachments with renderbufferID = 0,
 * used by some systems to present to a window.
 */
@interface CC3SystemOnScreenGLRenderbuffer : CC3GLRenderbuffer

/** The ID used to identify the renderbuffer to the GL engine. Always returns zero. */
@property(nonatomic, readonly) GLuint renderbufferID;

@end


#pragma mark -
#pragma mark CC3OSXOnScreenGLRenderbuffer

/** Represents the virtual OpenGL framebuffer attachments used by OSX to present to a window. */
@interface CC3OSXOnScreenGLRenderbuffer : CC3SystemOnScreenGLRenderbuffer
@end


#pragma mark -
#pragma mark CC3AndroidOnScreenGLRenderbuffer

/** Represents the virtual OpenGL framebuffer attachments used by Android to present to a window. */
@interface CC3AndroidOnScreenGLRenderbuffer : CC3SystemOnScreenGLRenderbuffer
@end


#pragma mark -
#pragma mark CC3TextureFramebufferAttachment

/**
 * CC3TextureFramebufferAttachment is a framebuffer attachment that uses a texture
 * as the rendering buffer.
 */
@interface CC3TextureFramebufferAttachment : NSObject <CC3FramebufferAttachment> {
	NSObject* _texObj;
	GLenum _face;
	GLint _mipmapLevel;
	BOOL _shouldUseStrongReferenceToTexture : 1;
}

/** 
 * Indicates whether this attachment should create a strong reference to the texture in the
 * texture property.
 *
 * The initial value of this property is YES, indicating that the texture will be held as a strong
 * reference, and in most cases, this is sufficient. However, in the case where this attachment is
 * part of a surface that is, in turn, being held by the texture that is being rendered to (the
 * contained texture), this attachment should maintain a weak reference to the texture, to avoid
 * a retain cycle. Such a retain cycle would occur if this attachment holds a texture, that holds
 * a surface, that, in turn, holds this attachment. 
 *
 * CC3EnvironmentMapTexture is an example of this design. CC3EnvironmentMapTexture holds a
 * render surface that in turns holds the CC3EnvironmentMapTexture as the color attachment.
 * CC3EnvironmentMapTexture automatically sets the shouldUseStrongReferenceToTexture property
 * of the color texture attachment to NO, avoiding the retain cycle that would arise if the
 * reference from the attachment to the texture was left as a strong reference.
 *
 * If the texture property has already been set when this property is changed, the texture
 * reference type is modified to comply with the new setting.
 */
@property(nonatomic, assign) BOOL shouldUseStrongReferenceToTexture;

/** 
 * The texture to bind as an attachment to the framebuffer, and into which rendering will occur. 
 *
 * When the value of this property is set, both the horizontalWrappingFunction and
 * verticalWrappingFunction properties of the texture will be set to GL_CLAMP_TO_EDGE,
 * as required when using a texture as a rendering target.
 *
 * The shouldUseStrongReferenceToTexture property determines whether the texture in this 
 * property will be held by a strong, or weak, reference.
 */
@property(nonatomic, assign) CC3Texture* texture;

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
 * Allocates and initializes an autoreleased instance to render to mipmap level zero
 * of an unspecified 2D texture. 
 *
 * The texture must be set using the texure property before rendering.
 */
+(id) attachment;

/** Initializes this instance to render to mipmap level zero of the specified 2D texture. */
-(id) initWithTexture: (CC3Texture*) texture;

/** 
 * Allocates and initializes an autoreleased instance to render to mipmap level zero
 * of the specified 2D texture. 
 */
+(id) attachmentWithTexture: (CC3Texture*) texture;

/**
 * Initializes this instance to render to mipmap level zero of the specified face of the
 * specified texture.
 */
-(id) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face;

/**
 * Allocates and initializes an autoreleased instance to render to mipmap level zero of the
 * specified face of the specified texture.
 */
+(id) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face;

/**
 * Initializes this instance to render to the specified mipmap level of the specified face
 * of the specified texture.
 */
-(id) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

/**
 * Allocates and initializes an autoreleased instance to render to the specified mipmap level
 * of the specified face of the specified texture.
 */
+(id) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

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
 * Setting this property wraps the specified texture in a CC3TextureFramebufferAttachment
 * instance and sets it into the colorAttachment property.
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * texture has no size, or has a size that is different than the size of this surface,
 * the texture is resized.
 *
 * Reading this property returns the texture within the CC3TextureFramebufferAttachment
 * in the colorAttachment property. It is an error to attempt to read this property if the
 * depthAttachment property does not contain an instance of CC3TextureFramebufferAttachment.
 *
 * To save memory, textures can be shared between surfaces of the same size, if the contents
 * of the texture are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) CC3Texture* colorTexture;

/**
 * If depth content is being rendered to a texture, this property can be used to access
 * that texture.
 *
 * Setting this property wraps the specified texture in a CC3TextureFramebufferAttachment
 * instance and sets it into the depthAttachment property, as well as the stencilAttachment
 * property, if the depth format of the texture includes a stencil component.
 *
 * When this property is set, if the size propery of this surface is not zero, and the
 * texture has no size, or has a size that is different than the size of this surface,
 * the texture is resized.
 *
 * Reading this property returns the texture within the CC3TextureFramebufferAttachment
 * in the depthAttachment property. It is an error to attempt to read this property if the
 * depthAttachment property does not contain an instance of CC3TextureFramebufferAttachment.
 *
 * To save memory, textures can be shared between surfaces of the same size, if the contents
 * of the texture are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) CC3Texture* depthTexture;

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
 * Returns whether this surface is an off-screen surface.
 *
 * Always returns YES. Subclasses that are used for on-screen rendering will override.
 */
@property(nonatomic, readonly) BOOL isOffScreen;

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

/** 
 * Returns whether this surface supports reading the pixel content.
 *
 * In general, the color content within a framebuffer is readable, and so this property always
 * returns YES. Specialized subclasses with unreadable color content may override to return NO.
 */
@property(nonatomic, readonly) BOOL isColorContentReadable;


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
#pragma mark CC3IOSOnScreenGLFramebuffer

/** Represents a framebuffer used by iOS to present to a window. */
@interface CC3IOSOnScreenGLFramebuffer : CC3GLFramebuffer
@end


#pragma mark -
#pragma mark CC3SystemOnScreenGLFramebuffer

/**
 * Represents the virtual OpenGL framebuffer with framebufferID = 0,
 * used by some systems to present to a window.
 */
@interface CC3SystemOnScreenGLFramebuffer : CC3GLFramebuffer

/** The ID used to identify the framebuffer to the GL engine. Always returns zero. */
@property(nonatomic, readonly) GLuint framebufferID;

@end


#pragma mark -
#pragma mark CC3OSXOnScreenGLFramebuffer

/**
 * Represents the virtual OpenGL framebuffer used by OSX to present to a window.
 *
 * Each of the attachments should be a CC3OSXOnScreenGLRenderbuffer.
 */
@interface CC3OSXOnScreenGLFramebuffer : CC3SystemOnScreenGLFramebuffer
@end


#pragma mark -
#pragma mark CC3AndroidOnScreenGLFramebuffer

/** Represents the virtual OpenGL framebuffer used by Android to present to a window. */
@interface CC3AndroidOnScreenGLFramebuffer : CC3SystemOnScreenGLFramebuffer

/**
 * Returns whether this surface supports reading the pixel content.
 *
 * The on-screen color content is not readable in the Android platform, 
 * and so this property always returns NO.
 */
@property(nonatomic, readonly) BOOL isColorContentReadable;

@end


#pragma mark -
#pragma mark CC3EnvironmentMapTexture

/** 
 * A texture that supports an environment map created by rendering the scene from the
 * node's perspective in all six axis directions.
 */
@interface CC3EnvironmentMapTexture : CC3TextureCube {
	CC3GLFramebuffer* _renderSurface;
	GLfloat _numberOfFacesPerSnapshot;
	GLfloat _faceCount;
	GLenum _currentFace;
}


#pragma mark Drawing

/**
 * Indicates the number of faces of the cube-map that will be generated on each invocation
 * of the generateSnapshotOfScene:fromGlobalLocation:withVisitor: method.
 * 
 * Generating each face in the cube-map requires rendering the scene from the perspective of
 * a camera facing towards that face, and generating a full cube-map requires six separate
 * scene renderings. Depending on the complexity of the scene, this can be quite costly.
 *
 * However, in most situations, an environment map does not require high-fideility, and the
 * workload can be spread over time by not generating all of the cube-map faces on every snapshot.
 *
 * You can use this property to control the number of cube-map faces that will be generated each
 * time a snapshot is taken using the generateSnapshotOfScene:fromGlobalLocation:withVisitor: method.
 *
 * The maximum value of this property is 6, indicating that all six faces should be generated
 * each time the generateSnapshotOfScene:fromGlobalLocation:withVisitor: method is invoked.
 * Setting this property to a smaller value will cause fewer faces to be generated on each
 * snapshot, thereby spreading the workload out over time. On each invocation, a different set
 * of faces will be generated, in a cycle, ensuring that each face will be generated at some point.
 *
 * As an example, setting this value to 2 will cause only 2 of the 6 faces of the cube-map to
 * be generated each time the generateSnapshotOfScene:fromGlobalLocation:withVisitor: is invoked.
 * Therefore, it would take 3 snapshot invocations to generate all 6 sides of the cube-map.
 *
 * You can even set this property to a fractional value less than one to spread the updating
 * of the faces out even further. For example, if the value of this property is set to 0.25,
 * the generateSnapshotOfScene:fromGlobalLocation:withVisitor: method will only generate one
 * face of this cube-map texture every fourth time it is invoked. On the other three invocations,
 * the generateSnapshotOfScene:fromGlobalLocation:withVisitor: method will do nothing. Therefore,
 * with the value of this property set to 0.25, it would take 24 snapshot invocations to generate
 * all 6 sides of this cube-map.
 *
 * The initial value of this property is 1, indicating that one face of the cube-map will be
 * generated on each invocation of the generateSnapshotOfScene:fromGlobalLocation:withVisitor:
 * method. With this value, it will take six invocations to generate all six sides of the cube-map.
 */
@property(nonatomic, assign) GLfloat numberOfFacesPerSnapshot;

/**
 * Generates up to six faces of this cube-map, by creating a view of the specified scene,
 * from the specified global location, once for each face of this cube-mapped texture.
 *
 * The scene's drawSceneContentForEnvironmentMapWithVisitor: method is invoked to render the
 * scene as an environment map, using the visitor in the scene's envMapDrawingVisitor property.
 *
 * Typcally, you invoke this method on each frame rendering loop, and use the 
 * numberOfFacesPerSnapshot property to control how often the texture is updated.
 */
-(void) generateSnapshotOfScene: (CC3Scene*) scene fromGlobalLocation: (CC3Vector) location;

/** Returns the surface to which the environment will be rendered. */
@property(nonatomic, retain, readonly) CC3GLFramebuffer* renderSurface;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with a rendering surface constructed from a new cube-map texture
 * with the economical 16-bit GL_RGB/GL_UNSIGNED_SHORT_5_6_5 pixelFormat/pixelType, and the
 * specified depth attachment, which must not be nil and must have a square size.
 *
 * The cube-map texture will have the same size as the specified depth attachment.
 */
-(id) initCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Allocates and initializes an autoreleased instance with a rendering surface constructed
 * from a new cube-map texture with whose pixelFormat and pixelType properties are set to
 * GL_RGBA and GL_UNSIGNED_BYTE, respectively, and the specified depth attachment, which
 * must not be nil and must have a square size.
 *
 * The cube-map texture will have the same size as the specified depth attachment.
 */
+(id) textureCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Initializes this instance with a rendering surface constructed from a new cube-map texture
 * with the specified pixel format and type, and the specified depth attachment, which must
 * not be nil and must have a square size.
 *
 * The cube-map texture will have the same size as the specified depth attachment.
 *
 * Be aware that the possible combinations of color and depth pixel formats is quite limited
 * with cube-mapped framebuffer attachments. If you have trouble finding a suitable combination,
 * you can use the initWithDepthAttachment: method, which invokes this method with GL_RGBA as
 * the colorFormat and GL_UNSIGNED_BYTE as the colorType.
 */
-(id) initCubeWithColorPixelFormat: (GLenum) colorFormat
				 andColorPixelType: (GLenum) colorType
				andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Allocates and initializes an autoreleased instance with a rendering surface constructed
 * from a new cube-map texture with the specified pixel format and type, and the specified
 * depth attachment, which must not be nil and must have a square size.
 *
 * The cube-map texture will have the same size as the specified depth attachment.
 *
 * Be aware that the possible combinations of color and depth pixel formats is quite limited
 * with cube-mapped framebuffer attachments. If you have trouble finding a suitable combination,
 * you can use the textureWithDepthAttachment: method, which invokes this method with GL_RGBA
 * as the colorFormat and GL_UNSIGNED_BYTE as the colorType.
 */
+(id) textureCubeWithColorPixelFormat: (GLenum) colorFormat
					andColorPixelType: (GLenum) colorType
				   andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

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
 * surface is resolved onto the view surface.
 */
@interface CC3GLViewSurfaceManager : NSObject {
	CC3GLView* _view;
	NSMutableArray* _resizeableSurfaces;
	CC3GLFramebuffer* _viewSurface;
	CC3GLFramebuffer* _multisampleSurface;
	CC3GLFramebuffer* _pickingSurface;
	BOOL _shouldUseDedicatedPickingSurface : 1;
}

/** The GL view whose surface is being managed by this instance. */
@property(nonatomic, assign, readonly) CC3GLView* view;

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
@property(nonatomic, retain, readonly) CC3GLFramebuffer* renderingSurface;

/**
 * The surface to which rendering for picking should be directed.
 *
 * If the shouldUseDedicatedPickingSurface property returns NO, this property returns the 
 * surface in the viewSurface property. However, if the shouldUseDedicatedPickingSurface 
 * returns YES, this property returns a dedicated surface created just for picking.
 *
 * Lazy initialization is used in case touch picking is never actually used by the app.
 */
@property(nonatomic, retain) CC3GLFramebuffer* pickingSurface;

/**
 * Returns whether a dedicated surface should be created by the pickingSurface property.
 *
 * If this property returns NO, the pickingSurface property will return the surface in
 * the viewSurface property. However, if this property returns YES, the pickingSufrace
 * property will return a dedicated surface created just for picking.
 *
 * For economy, if multisampling is not active and the viewSurface is readable, the 
 * viewSurface can also be used as the picking surface. For that reason, if both of those
 * conditions hold, and this property has not been set to YES directly, this property will
 * return NO. Otherwise, this property will return YES.
 *
 * You can force the use of a dedicated picking surface, even if multisampling is not in
 * use and the viewSurface is readable, by directly setting this property to YES. There
 * are situations where this may be preferrable, such as if there is no backdrop, and
 * some of the objects contain transparency. In that situation, using the viewSurface
 * for both view rendering and node picking rendering may result in unwanted visual
 * artifacts on the transparent nodes during node picking resulting from touch events.
 * To avoid these artifacts, you can set this property to YES.
 */
@property(nonatomic, assign) BOOL shouldUseDedicatedPickingSurface;

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
@property(nonatomic, retain, readonly) CC3GLRenderbuffer* viewColorBuffer;

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

/** @deprecated Property moved to [CC3Backgrounder sharedBackgrounder] singleton. */
@property(nonatomic, retain) CC3Backgrounder* backgrounder DEPRECATED_ATTRIBUTE;


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

/** Initializes this instance for the specified view. */
-(id) initWithView: (CC3GLView*) view;

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
