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

@class CC3Backgrounder, CC3GLFramebuffer;


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
@property(nonatomic, assign) CC3IntSize size;

/** The format of each pixel in the buffer. */
@property(nonatomic, readonly) GLenum pixelFormat;

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
-(void) bindToFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment;

/** 
 * Unbinds this buffer from the specified framebuffer, as the specified attachment type,
 * and leaves the framebuffer with no attachment of that type.
 */
-(void) unbindFromFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment;

/**
 * If this attachment does not have a name assigned yet, it is derived from a combination
 * of the name of the specified framebuffer and the type of attachment.
 */
-(void) deriveNameFromFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment;

@end

	
#pragma mark -
#pragma mark CC3GLRenderbuffer

/**
 * Represents an OpenGL renderbuffer.
 *
 * CC3GLRenderbuffer implements the CC3FramebufferAttachment, allowing it to be attached to
 * a framebuffer. This class represents a general off-screen or on-screen GL renderbuffer, 
 * whose storage is allocated from GL memory.
 *
 * Broadly speaking, there are two ways to instantiate an instance and manage the lifespan
 * of the corresponding renderbuffer in the GL engine, these are described as follows.
 *
 * If you instantiate an instance without explicitly providing the ID of an existing OpenGL
 * renderbuffer, a renderbuffer will automatically be created within the GL engine, as needed,
 * and will automatically be deleted from the GL engine when the instance is deallocated.
 *
 * To map to an existing OpenGL renderbuffer, you can provide the value of the renderbufferID
 * property during instance instantiation. In this case, the instance will not delete the
 * renderbuffer from the GL engine when the instance is deallocated, and it is up to you to
 * coordinate the lifespan of the instance and the GL renderbuffer. Do not use the instance
 * once you have deleted the renderbuffer from the GL engine.
 */
@interface CC3GLRenderbuffer : CC3Identifiable <CC3FramebufferAttachment> {
	GLuint _rbID;
	CC3IntSize _size;
	GLenum _format;
	GLuint _samples;
	BOOL _isManagingGL : 1;
}

/**
 * The ID used to identify the renderbuffer to the GL engine.
 *
 * If the value of this property is not explicitly set during instance initialization, then the
 * first time this property is accessed a renderbuffer will automatically be generated in the GL
 * engine, and its ID set into this property.
 */
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

/**
 * Returns whether the renderbuffer in the GL engine is being managed by this instance.
 *
 * If the value of this property is YES, this instance is managing the renderbuffer in the GL
 * engine, and when this instance is deallocated, the renderbuffer will automatically be deleted
 * from the GL engine.
 *
 * If the value of this property is NO, this instance is NOT managing the renderbuffer in the
 * GL engine, and when this instance is deallocated, the renderbuffer will NOT automatically
 * be deleted from the GL engine.
 *
 * If the value of this property is NO, indicating the lifespan of the GL renderbuffer is not
 * managed by this instance, it is up to you to coordinate the lifespan of this instance and
 * the GL renderbuffer. Do not use this instance once you have deleted the renderbuffer from
 * the GL engine.
 *
 * The value of this property also has an effect on the behaviour of the size property.
 * If this property returns YES, setting the size property will also resize the memory 
 * allocation in the GL engine. If this property returns NO, setting the size property
 * has no effect on the memory allocation in the GL engine.
 *
 * If this instance is initialized with with a specific value for the renderbufferID property,
 * the value of this property will be NO, otherwise, the value of this property will be YES.
 */
@property(nonatomic, readonly) BOOL isManagingGL;

/** 
 * The size of this renderbuffer in pixels.
 *
 * When the value of this property is changed, if the isManagingGL property returns YES, 
 * storage space within GL memory is allocated or reallocated. If the isManagingGL property
 * returns NO, the memory allocation in the GL engine remains unchanged, but the value of
 * this property will reflect the new value.
 */
@property(nonatomic, assign) CC3IntSize size;

/** Binds this renderbuffer as the active renderbuffer in the GL engine. */
-(void) bind;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance with one sample per pixel. */
+(instancetype) renderbuffer;

/**
 * Initializes this instance with the specified pixel format and with one sample per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 */
-(instancetype) initWithPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * with one sample per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 */
+(instancetype) renderbufferWithPixelFormat: (GLenum) format;

/**
 * Initializes this instance with the specified pixel format and with number of samples per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 */
-(instancetype) initWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format and
 * number of samples per pixel.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 */
+(instancetype) renderbufferWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples;

/**
 * Initializes this instance with the specified pixel format and renderbuffer ID.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The value of the isManagingGL property will be set to NO, indicating that this instance will
 * not delete the renderbuffer from the GL engine when this instance is deallocated. It is up
 * to you to coordinate the lifespan of this instance and the GL renderbuffer. Do not use this
 * instance once you have deleted the renderbuffer from the GL engine.
 */
-(instancetype) initWithPixelFormat: (GLenum) format withRenderbufferID: (GLuint) rbID;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format,
 * and renderbuffer ID.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The value of the isManagingGL property of the returned instance will be set to NO, indicating that
 * the instance will not delete the renderbuffer from the GL engine when the returned instance is
 * deallocated. It is up to you to coordinate the lifespan of the returned instance and the GL 
 * renderbuffer. Do not use the returned instance once you have deleted the renderbuffer from the GL engine.
 */
+(instancetype) renderbufferWithPixelFormat: (GLenum) format withRenderbufferID: (GLuint) rbID;

/**
 * Initializes this instance with the specified pixel format, number of samples per pixel,
 * and renderbuffer ID.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The value of the isManagingGL property will be set to NO, indicating that this instance will
 * not delete the renderbuffer from the GL engine when this instance is deallocated. It is up
 * to you to coordinate the lifespan of this instance and the GL renderbuffer. Do not use this
 * instance once you have deleted the renderbuffer from the GL engine.
 */
-(instancetype) initWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples withRenderbufferID: (GLuint) rbID;

/**
 * Allocates and initializes an autoreleased instance with the specified pixel format,
 * number of samples per pixel, and renderbuffer ID.
 *
 * See the pixelFormat property for allowable values for the format parameter.
 *
 * The value of the isManagingGL property of the returned instance will be set to NO, indicating that
 * the instance will not delete the renderbuffer from the GL engine when the returned instance is
 * deallocated. It is up to you to coordinate the lifespan of the returned instance and the GL
 * renderbuffer. Do not use the returned instance once you have deleted the renderbuffer from the GL engine.
 */
+(instancetype) renderbufferWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples withRenderbufferID: (GLuint) rbID;

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
+(instancetype) attachment;

/** Initializes this instance to render to mipmap level zero of the specified 2D texture. */
-(instancetype) initWithTexture: (CC3Texture*) texture;

/** 
 * Allocates and initializes an autoreleased instance to render to mipmap level zero
 * of the specified 2D texture. 
 */
+(instancetype) attachmentWithTexture: (CC3Texture*) texture;

/**
 * Initializes this instance to render to mipmap level zero of the specified face of the
 * specified texture.
 */
-(instancetype) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face;

/**
 * Allocates and initializes an autoreleased instance to render to mipmap level zero of the
 * specified face of the specified texture.
 */
+(instancetype) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face;

/**
 * Initializes this instance to render to the specified mipmap level of the specified face
 * of the specified texture.
 */
-(instancetype) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

/**
 * Allocates and initializes an autoreleased instance to render to the specified mipmap level
 * of the specified face of the specified texture.
 */
+(instancetype) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel;

@end


#pragma mark -
#pragma mark CC3RenderSurface

/** A CC3RenderSurface is a surface on which rendering or drawing can occur. */
@protocol CC3RenderSurface <CC3Object>

/** Returns the size of this surface in pixels. */
@property(nonatomic, assign) CC3IntSize size;

/** Returns a viewport suitable for rendering to this surface. */
@property(nonatomic, readonly) CC3Viewport viewport;

/** Returns whether this surface section covers the entire renderable area of a view. */
@property(nonatomic, readonly) BOOL isFullCoverage;

/**
 * Returns whether this surface is an on-screen surface.
 *
 * The initial value of this property is NO. For instances that represent on-screen
 * framebuffers, set this property to YES.
 */
@property(nonatomic, assign) BOOL isOnScreen;

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
 * Not all surfaces have readable color content. In particular, content cannot be read from
 * some system framebuffers.
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
 * Subsequent GL activity will be rendered to this surface.
 */
-(void) activate;

@end


#pragma mark -
#pragma mark CC3SurfaceSection

/**
 * CC3SurfaceSection is a surface that is a section of another underlying base surface.
 *
 * As a surface, the surface section uses the attachments of the base surface, and all rendering
 * activities performed on the surface section will be passed along to the base surface.
 *
 * The size of the surface section can be set to a value different from the size of the base
 * surface, and rendering to the surface section will be restricted to this size on the base
 * surface. In addition, a surface section supports a origin property. The combination of the
 * origin and size properties constrains all rendering activity to a rectangle somewhere on 
 * the base surface, as described by the viewport property of the surface section.
 */
@interface CC3SurfaceSection : CC3Identifiable <CC3RenderSurface> {
	id<CC3RenderSurface> _baseSurface;
	CC3IntSize _size;
	CC3IntPoint _origin;
	BOOL _isFullCoverage : 1;
}

/**
 * The base surface of which this surface is a part.
 *
 * Activating this surface activates the base surface, and all rendering occurs on
 * the base surface, within the viewport defined by the viewport of this surface.
 *
 * If the size property of this surface has not been set when this property is set,
 * the size property of this instance will be set to that of the base surface. However,
 * once set, the size property is not changed if this property is changed. This allows
 * the base surface to be changed, while retaining a defined viewport through the size
 * and origin properties.
 */
@property(nonatomic, retain) id<CC3RenderSurface> baseSurface;

/**
 * The size of this surface in pixels.
 *
 * Changing the value of this property does not affect the size of any attachments.
 * Instead, changing the value of this property changes the value returned by the viewport
 * property, which causes rendering to occur only within the section of the base surface
 * defined by the viewport property.
 *
 * The initial value of this property is the size of the base surface at the time the
 * baseSurface property is set for the first time.
 */
@property(nonatomic, assign) CC3IntSize size;

/**
 * The origin of this surface section, relative to the base surface.
 *
 * Changing the value of this property changes the value returned by the viewport property,
 * which causes rendering to occur only within the section of the base surface defined by
 * the viewport property.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) CC3IntPoint origin;

/**
 * Returns a viewport whose origin is at the point specified by the origin property, 
 * and whose width and height match the size property.
 *
 * Initially, this property will return a viewport that covers the entire baseSurface. Changing
 * the origin and size properties of this instance will change the value returned by this property.
 */
@property(nonatomic, readonly) CC3Viewport viewport;

/**
 * Returns whether this surface section covers the entire base surface.
 *
 * Returns YES if the same property on the base surface returns YES, the origin property is
 * zero, and the size property of this section is equal to the size property of the base surface.
 */
@property(nonatomic, readonly) BOOL isFullCoverage;

/**
 * Returns whether this surface is an on-screen surface.
 *
 * Returns the value of the same property on the baseSurface.
 * Setting the value of this property has no effect.
 */
@property(nonatomic, assign) BOOL isOnScreen;

/**
 * The surface attachment to which color data is rendered.
 *
 * Returns the value of the same property on the baseSurface.
 * Setting the value of this property has no effect.
 */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> colorAttachment;

/**
 * The surface attachment to which depth data is rendered.
 *
 * Returns the value of the same property on the baseSurface.
 * Setting the value of this property has no effect.
 */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> depthAttachment;

/**
 * The surface attachment to which stencil data is rendered.
 *
 * Returns the value of the same property on the baseSurface.
 * Setting the value of this property has no effect.
 */
@property(nonatomic, retain) id<CC3RenderSurfaceAttachment> stencilAttachment;


#pragma mark Content

/** Clears the color content of the base surface, within the bounds of the viewport of this instance. */
-(void) clearColorContent;

/** Clears the depth content of the base surface, within the bounds of the viewport of this instance. */
-(void) clearDepthContent;

/** Clears the stencil content of the base surface, within the bounds of the viewport of this instance. */
-(void) clearStencilContent;

/** Clears the color and depth content of the base surface, within the bounds of the viewport of this instance. */
-(void) clearColorAndDepthContent;

/**
 * Reads the content of the range of pixels defined by the specified rectangle from the color
 * attachment of the base surface, into the specified array, which must be large enough to
 * accommodate the number of pixels covered by the specified rectangle.
 *
 * The rectangle is first offset by the origin of this surface section.
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
 * Not all surfaces have readable color content. In particular, content cannot be read from
 * some system framebuffers.
 *
 * This method should be used with care, since it involves making a synchronous call to
 * query the state of the GL engine. This method will not return until the GL engine has
 * executed all previous drawing commands in the pipeline. Excessive use of this method
 * will reduce GL throughput and performance.
 */
-(void) readColorContentFrom: (CC3Viewport) rect into: (ccColor4B*) colorArray;

/**
 * If the colorAttachment of the base surface supports pixel replacement, replaces a portion
 * of the content of the color attachment by writing the specified array of pixels into the
 * specified rectangular area within the attachment, The specified content replaces the pixel
 * data within the specified rectangle. The specified content array must be large enough to
 * contain content for the number of pixels in the specified rectangle.
 *
 * The rectangle is first offset by the origin of this surface section.
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
 * The rectangle is first offset by the origin of this surface section.
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
 * If the isFullCoverage property returns NO, this method applies a scissor function to 
 * the GL engine, so that subsequent GL activity while this surface is active will be 
 * constrained to the viewport of this surface.
 */
-(void) activate;


#pragma mark Allocation and initialization

/**
 * Initializes this instance as a section of the specified surface.
 *
 * The initial size of this instance will be set to that of the specified surface.
 */
-(instancetype) initOnSurface: (id<CC3RenderSurface>) baseSurface;

/**
 * Allocates and initializes an instance as a section of the specified surface.
 *
 * The initial size of the returned instance will be set to that of the specified surface.
 */
+(instancetype) surfaceOnSurface: (id<CC3RenderSurface>) baseSurface;

@end


#pragma mark -
#pragma mark CC3GLFramebuffer

/**
 * Represents an OpenGL framebuffer.
 *
 * Framebuffers hold between one and three attachments. Each attachment represents a rendering
 * buffer that holds a particular type of drawn content: color, depth, or stencil content.
 * Typically, each of these attachments will be either a renderbuffer, a texture (to support
 * rendering to a texture), or nil, indicating that that type of content is not being rendered.
 *
 * Broadly speaking, there are two ways to instantiate an instance and manage the lifespan 
 * of the corresponding framebuffer in the GL engine, these are described as follows.
 *
 * If you instantiate an instance without explicitly providing the ID of an existing OpenGL
 * framebuffer, a framebuffer will automatically be created within the GL engine, as needed,
 * and will automatically be deleted from the GL engine when the instance is deallocated.
 *
 * To map to an existing OpenGL framebuffer, you can provide the value of the framebufferID 
 * property during instance instantiation. In this case, the instance will not delete the 
 * framebuffer from the GL engine when the instance is deallocated, and it is up to you to 
 * coordinate the lifespan of the instance and the GL framebuffer. Do not use the instance 
 * once you have deleted the framebuffer from the GL engine. 
 *
 * When creating an instance to map to an existing OpenGL framebuffer, the shouldBindGLAttachments
 * property can be used to indicate whether or not attachments should be automatically bound to
 * the framebuffer within the GL engine, as they are attached to an instance.
 *
 * You should consider setting the name property of each instance, to distinguish them.
 * The name will also appear in the debugger when capturing OpenGL frames. If you set the
 * name before adding attachments, it will propagate to those attachments.
 */
@interface CC3GLFramebuffer : CC3Identifiable <CC3RenderSurface> {
	GLuint _fbID;
	CC3IntSize _size;
	id<CC3FramebufferAttachment> _colorAttachment;
	id<CC3FramebufferAttachment> _depthAttachment;
	id<CC3FramebufferAttachment> _stencilAttachment;
	BOOL _isOnScreen : 1;
	BOOL _isManagingGL : 1;
	BOOL _shouldBindGLAttachments : 1;
	BOOL _glLabelWasSet : 1;
}

/** 
 * The ID used to identify the framebuffer to the GL engine.
 *
 * If the value of this property is not explicitly set during instance initialization, then the
 * first time this property is accessed a framebuffer will automatically be generated in the GL
 * engine, and its ID set into this property.
 */
@property(nonatomic, readonly) GLuint framebufferID;

/**
 * Returns whether the framebuffer in the GL engine is being managed by this instance.
 *
 * If the value of this property is YES, this instance is managing the framebuffer in the
 * GL engine, and when this instance is deallocated, the framebuffer will automatically be
 * deleted from the GL engine. 
 * 
 * If the value of this property is NO, this instance is NOT managing the framebuffer in the
 * GL engine, and when this instance is deallocated, the framebuffer will NOT automatically 
 * be deleted from the GL engine.
 *
 * If the value of this property is NO, indicating the lifespan of the GL framebuffer is not 
 * managed by this instance, it is up to you to coordinate the lifespan of this instance and 
 * the GL framebuffer. Do not use this instance once you have deleted the framebuffer from 
 * the GL engine.
 *
 * If this instance is initialized with with a specific value for the framebufferID property,
 * the value of this property will be NO, otherwise, the value of this property will be YES.
 */
@property(nonatomic, readonly) BOOL isManagingGL;

/**
 * Indicates whether the attachments should be bound to this framebuffer within the GL 
 * engine when they are attached to this framebuffer.
 *
 * If this property is set to YES, when an attachment is added to this framebuffer, within
 * the GL engine, the existing attachment will be unbound from this framebuffer and the
 * new attachment will be bound to this framebuffer. This is typically the desired behaviour
 * when working with framebuffers and their attachments.
 *
 * If this property is set to NO, when an attachment is added to this framebuffer, no changes
 * are made within the GL engine. Setting this property to NO can be useful when you want to
 * construct an instance that matches an existing GL framebuffer and its attachments, that
 * may have been created outside of Cocos3D. A key example of this is the framebuffers and
 * renderbuffers used to display the content of the view.
 *
 * The initial value of this property is YES, indicating that any attachments added to this
 * framebuffer will also be bound to this framebuffer within the GL engine.
 *
 * This property affects the behaviour colorAttachment, depthAttachment, stencilAttachment,
 * colorTexture and depthTexture properties.
 *
 * This property affects different behaviour than the isManagingGL property, and does not
 * depend on that property.
 */
@property(nonatomic, assign) BOOL shouldBindGLAttachments;

/**
 * Returns whether this framebuffer is an on-screen surface.
 *
 * The initial value of this property is NO. For instances that represent on-screen
 * framebuffers, set this property to YES.
 */
@property(nonatomic, assign) BOOL isOnScreen;

/**
 * The size of this framebuffer surface in pixels.
 *
 * Changing the value of this property changes the size of each attachment, rebinds each 
 * attachment to this framebuffer, and invokes the validate method. 
 *
 * When creating a framebuffer instance, it is slightly more efficient to set the size of
 * the framebuffer after all attachments have been added.
 */
@property(nonatomic, assign) CC3IntSize size;

/** Returns a viewport with zero origin and width and height matching the size property. */
@property(nonatomic, readonly) CC3Viewport viewport;

/** 
 * Returns whether this surface section covers the entire renderable area of a view.
 *
 * Always returns YES.
 */
@property(nonatomic, readonly) BOOL isFullCoverage;

/**
 * The attachment to which color data is rendered.
 *
 * Implementation of the CC3RenderSurface colorAttachment property. Framebuffer attachments
 * must also support the CC3FramebufferAttachment protocol.
 *
 * When this property is set:
 *  - If the size property of this surface is not zero, and the attachment has no size, or 
 *    has a size that is different than the size of this surface, the attachment is resized.
 *  - If the size property of this surface is zero, and the attachment already has a size, 
 *    the size of this framebuffer is set to that of the attachment.
 *  - If the shouldBindGLAttachments property is set to YES, the existing attachment is
 *    unbound from this framebuffer in the GL engine, and the new attachment is bound to 
 *    this framebuffer in the GL engine.
 *  - The validate method is invoked to validate the framebuffer structure.
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
 * When this property is set:
 *  - If the size property of this surface is not zero, and the attachment has no size, or
 *    has a size that is different than the size of this surface, the attachment is resized.
 *  - If the size property of this surface is zero, and the attachment already has a size,
 *    the size of this framebuffer is set to that of the attachment.
 *  - If the shouldBindGLAttachments property is set to YES, the existing attachment is
 *    unbound from this framebuffer in the GL engine, and the new attachment is bound to
 *    this framebuffer in the GL engine.
 *  - If the depth format of the attachment includes a stencil component, the stencilAttachment
 *    property is set to the this attachment as well.
 *  - The validate method is invoked to validate the framebuffer structure.
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
 * When this property is set:
 *  - If the size property of this surface is not zero, and the attachment has no size, or
 *    has a size that is different than the size of this surface, the attachment is resized.
 *  - If the size property of this surface is zero, and the attachment already has a size,
 *    the size of this framebuffer is set to that of the attachment.
 *  - If the shouldBindGLAttachments property is set to YES, the existing attachment is
 *    unbound from this framebuffer in the GL engine, and the new attachment is bound to
 *    this framebuffer in the GL engine.
 *  - The validate method is invoked to validate the framebuffer structure.
 *
 * To save memory, attachments can be shared between surfaces of the same size, if the contents
 * of the attachment are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) id<CC3FramebufferAttachment> stencilAttachment;

/**
 * If color content is being rendered to a texture, this property can be used to access
 * that texture.
 *
 * This is a convenience property. Setting this property wraps the specified texture in a 
 * CC3TextureFramebufferAttachment instance and sets it into the colorAttachment property. 
 * Reading this property returns the texture within the CC3TextureFramebufferAttachment
 * in the colorAttachment property. It is an error to attempt to read this property if the
 * colorAttachment property does not contain an instance of CC3TextureFramebufferAttachment.
 *
 * To save memory, textures can be shared between surfaces of the same size, if the contents
 * of the texture are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) CC3Texture* colorTexture;

/**
 * If depth content is being rendered to a texture, this property can be used to access
 * that texture.
 *
 * This is a convenience property. Setting this property wraps the specified texture in a
 * CC3TextureFramebufferAttachment instance and sets it into the depthAttachment property.
 * Reading this property returns the texture within the CC3TextureFramebufferAttachment
 * in the depthAttachment property. It is an error to attempt to read this property if the
 * depthAttachment property does not contain an instance of CC3TextureFramebufferAttachment.
 *
 * To save memory, textures can be shared between surfaces of the same size, if the contents
 * of the texture are only required for the duration of the rendering to each surface.
 */
@property(nonatomic, retain) CC3Texture* depthTexture;

/**
 * Validates that this framebuffer has a valid configuration in the GL engine, and raises
 * an assertion exception if the configuration is not valid.
 *
 * Does nothing if this framebuffer has no attachments or no size.
 *
 * This method is automatically invoked when an attachment is added, or the size property 
 * is changed. Normally, the application never needs to invoke this method.
 */
-(void) validate;


#pragma mark Allocation and initialization

/** Initializes this instance to zero size. */
-(instancetype) init;

/** Allocates and initializes an autoreleased instance with zero size. */
+(instancetype) surface;

/**
 * Initializes this instance, sets the colorTexture property to a new blank 2D texture, and
 * sets the depthAttachment property to a new renderbuffer configured with the standard 
 * GL_DEPTH_COMPONENT16 depth format.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The isOpaque parameter indicates whether or not the colorTexture should support transparency,
 * by including or excluding an alpha component in each pixel. The colorTexture will support
 * transparency if isOpaque is set to NO, otherwise the texture will not support transparency.
 * Specifically, the pixelFormat / pixelType properties of the texture are configured as follows:
 *   - GL_RGB / GL_UNSIGNED_SHORT_5_6_5 if isOpaque is YES.
 *   - GL_RGBA / GL_UNSIGNED_BYTE if isOpaque is NO.
 *
 * Note that, with these texture formats, a texture that supports transparency requires twice
 * the memory space of an opaque texture.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces. In this case, consider using
 * the initAsColorTextureIsOpaque:withDepthAttachment: method instead.
 */
-(instancetype) initAsColorTextureIsOpaque: (BOOL) isOpaque;

/**
 * Allocates and initializes an instance, sets the colorTexture property to a new blank 2D
 * texture, and sets the depthAttachment property to a new renderbuffer configured with the
 * standard GL_DEPTH_COMPONENT16 depth format.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The isOpaque parameter indicates whether or not the colorTexture should support transparency,
 * by including or excluding an alpha component in each pixel. The colorTexture will support
 * transparency if isOpaque is set to NO, otherwise the texture will not support transparency.
 * Specifically, the pixelFormat / pixelType properties of the texture are configured as follows:
 *   - GL_RGB / GL_UNSIGNED_SHORT_5_6_5 if isOpaque is YES.
 *   - GL_RGBA / GL_UNSIGNED_BYTE if isOpaque is NO.
 *
 * Note that, with these texture formats, a texture that supports transparency requires twice
 * the memory space of an opaque texture.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces. In this case, consider using
 * the colorTextureSurfaceIsOpaque:withDepthAttachment: method instead.
 */
+(instancetype) colorTextureSurfaceIsOpaque: (BOOL) isOpaque;

/**
 * Initializes this instance, sets the colorTexture property to a new blank 2D texture, and sets
 * the depthAttachment property to a new renderbuffer configured with the specified depth format.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The depthFormat argument may be one of the following values:
 *   - GL_DEPTH_COMPONENT16
 *   - GL_DEPTH_COMPONENT24
 *   - GL_DEPTH24_STENCIL8
 *
 * The isOpaque parameter indicates whether or not the colorTexture should support transparency,
 * by including or excluding an alpha component in each pixel. The colorTexture will support
 * transparency if isOpaque is set to NO, otherwise the texture will not support transparency.
 * Specifically, the pixelFormat / pixelType properties of the texture are configured as follows:
 *   - GL_RGB / GL_UNSIGNED_SHORT_5_6_5 if isOpaque is YES.
 *   - GL_RGBA / GL_UNSIGNED_BYTE if isOpaque is NO.
 *
 * Note that, with these texture formats, a texture that supports transparency requires twice
 * the memory space of an opaque texture.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces. In this case, consider using
 * the initAsColorTextureIsOpaque:withDepthAttachment: method instead.
 */
-(instancetype) initAsColorTextureIsOpaque: (BOOL) isOpaque
						   withDepthFormat: (GLenum) depthFormat;

/**
 * Allocates and initializes an instance, sets the colorTexture property to a new blank 2D
 * texture, and sets the depthAttachment property to a new renderbuffer configured with the
 * specified depth format.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The depthFormat argument may be one of the following values:
 *   - GL_DEPTH_COMPONENT16
 *   - GL_DEPTH_COMPONENT24
 *   - GL_DEPTH24_STENCIL8
 *
 * The isOpaque parameter indicates whether or not the colorTexture should support transparency,
 * by including or excluding an alpha component in each pixel. The colorTexture will support
 * transparency if isOpaque is set to NO, otherwise the texture will not support transparency.
 * Specifically, the pixelFormat / pixelType properties of the texture are configured as follows:
 *   - GL_RGB / GL_UNSIGNED_SHORT_5_6_5 if isOpaque is YES.
 *   - GL_RGBA / GL_UNSIGNED_BYTE if isOpaque is NO.
 *
 * Note that, with these texture formats, a texture that supports transparency requires twice
 * the memory space of an opaque texture.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces. In this case, consider using
 * the colorTextureSurfaceIsOpaque:withDepthAttachment: method instead.
 */
+(instancetype) colorTextureSurfaceIsOpaque: (BOOL) isOpaque
							withDepthFormat: (GLenum) depthFormat;

/**
 * Initializes this instance, sets the colorTexture property to a new blank 2D texture, and
 * sets the depthAttachment property to the specified depth attachment.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The isOpaque parameter indicates whether or not the colorTexture should support transparency,
 * by including or excluding an alpha component in each pixel. The colorTexture will support
 * transparency if isOpaque is set to NO, otherwise the texture will not support transparency.
 * Specifically, the pixelFormat / pixelType properties of the texture are configured as follows:
 *   - GL_RGB / GL_UNSIGNED_SHORT_5_6_5 if isOpaque is YES.
 *   - GL_RGBA / GL_UNSIGNED_BYTE if isOpaque is NO.
 *
 * Note that, with these texture formats, a texture that supports transparency requires twice
 * the memory space of an opaque texture.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces.
 */
-(instancetype) initAsColorTextureIsOpaque: (BOOL) isOpaque
					   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Allocates and initializes an instance, sets the colorTexture property to a new blank 2D 
 * texture, and sets the depthAttachment property to the specified depth attachment.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The isOpaque parameter indicates whether or not the colorTexture should support transparency,
 * by including or excluding an alpha component in each pixel. The colorTexture will support
 * transparency if isOpaque is set to NO, otherwise the texture will not support transparency.
 * Specifically, the pixelFormat / pixelType properties of the texture are configured as follows:
 *   - GL_RGB / GL_UNSIGNED_SHORT_5_6_5 if isOpaque is YES.
 *   - GL_RGBA / GL_UNSIGNED_BYTE if isOpaque is NO.
 *
 * Note that, with these texture formats, a texture that supports transparency requires twice
 * the memory space of an opaque texture.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces.
 */
+(instancetype) colorTextureSurfaceIsOpaque: (BOOL) isOpaque
						withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Initializes this instance, sets the colorTexture property to a new blank 2D texture, and
 * sets the depthAttachment property to the specified depth attachment.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The empty colorTexture is configured with the specified pixel format and pixel type.
 * See the notes for the CC3Texture pixelFormat and pixelType properties for the range
 * of values permitted for these parameters.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces.
 */
-(instancetype) initAsColorTextureWithPixelFormat: (GLenum) pixelFormat
									withPixelType: (GLenum) pixelType
							  withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Allocates and initializes an instance, sets the colorTexture property to a new blank 2D
 * texture, and sets the depthAttachment property to the specified depth attachment.
 *
 * To define the shape of the surface, you should either set the size property of the returned
 * instance, or add it to a CC3SurfaceManager instance.
 *
 * The empty colorTexture is configured with the specified pixel format and pixel type.
 * See the notes for the CC3Texture pixelFormat and pixelType properties for the range
 * of values permitted for these parameters.
 *
 * The depthAttachment is used only during the rendering of content to the color texture.
 * If you are creating many color texture surfaces of the same size, you can save memory
 * by using the same depthAttachment for all such surfaces.
 */
+(instancetype) colorTextureSurfaceWithPixelFormat: (GLenum) pixelFormat
									 withPixelType: (GLenum) pixelType
							   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Initializes this instance with the specified existing framebuffer ID.
 *
 * You can use this method to create an instance to interact with an existin GL framebuffer
 * that has been created outside Cocos3D.
 *
 * The value of the isManagingGL property will be set to NO, indicating that this instance will
 * not delete the framebuffer from the GL engine when this instance is deallocated. It is up
 * to you to coordinate the lifespan of this instance and the GL framebuffer. Do not use this
 * instance once you have deleted the framebuffer from the GL engine.
 */
-(instancetype) initWithFramebufferID: (GLuint) fbID;

/**
 * Allocates and initializes an instance with the specified existing framebuffer ID.
 *
 * You can use this method to create an instance to interact with an existin GL framebuffer
 * that has been created outside Cocos3D.
 *
 * The value of the isManagingGL property of the returned instance will be set to NO, indicating that
 * the instance will not delete the framebuffer from the GL engine when the returned instance is
 * deallocated. It is up to you to coordinate the lifespan of the returned instance and the GL
 * framebuffer. Do not use the returned instance once you have deleted the framebuffer from the GL engine.
 */
+(instancetype) surfaceWithFramebufferID: (GLuint) fbID;

@end


#pragma mark -
#pragma mark CC3EnvironmentMapTexture

/** 
 * A texture that supports an environment map created by rendering the scene from the
 * node's perspective in all six axis directions.
 *
 * You can use this texture in any model object, wherever you use any cube-map texture.
 * The generateSnapshotOfScene:fromGlobalLocation: method is used to capture the scene
 * images to this texture. You can trigger this as often as you need, to keep the image
 * current with the scene contents.
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
 * Initializes this instance with the specified side length, with the standard
 * GL_RGBA/GL_UNSIGNED_BYTE pixelFormat/pixelType, and backed by a new depth buffer
 * with the standard GL_DEPTH_COMPONENT16 depth format.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The internal depth buffer is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects, you
 * can save memory by using the same depth buffer for all such environment textures. In this case,
 * consider using the initCubeWithSideLength:WithDepthAttachment: method instead.
 */
-(instancetype) initCubeWithSideLength: (GLuint) sideLength;

/**
 * Allocates and initializes an autoreleased instance with the specified side length, with
 * the standard GL_RGBA/GL_UNSIGNED_BYTE pixelFormat/pixelType, and backed by a new depth
 * buffer with the standard GL_DEPTH_COMPONENT16 depth format.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The internal depth buffer is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects, you
 * can save memory by using the same depth buffer for all such environment textures. In this case,
 * consider using the textureCubeWithSideLength:WithDepthAttachment: method instead.
 */
+(instancetype) textureCubeWithSideLength: (GLuint) sideLength;

/**
 * Initializes this instance with the specified side length, with the standard
 * GL_RGBA/GL_UNSIGNED_BYTE pixelFormat/pixelType, and backed by a new depth buffer
 * of the specified depth format. 
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The depthFormat argument may be one of the following values:
 *   - GL_DEPTH_COMPONENT16
 *   - GL_DEPTH_COMPONENT24
 *   - GL_DEPTH24_STENCIL8
 *
 * The internal depth buffer is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects, you
 * can save memory by using the same depth buffer for all such environment textures. In this case,
 * consider using the initCubeWithSideLength:WithDepthAttachment: method instead.
 */
-(instancetype) initCubeWithSideLength: (GLuint) sideLength withDepthFormat: (GLenum) depthFormat;

/**
 * Allocates and initializes an autoreleased instance with the specified side length, with
 * the standard GL_RGBA/GL_UNSIGNED_BYTE pixelFormat/pixelType, and backed by a new depth
 * buffer of the specified depth format.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The depthFormat argument may be one of the following values:
 *   - GL_DEPTH_COMPONENT16
 *   - GL_DEPTH_COMPONENT24
 *   - GL_DEPTH24_STENCIL8
 *
 * The internal depth buffer is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects, you
 * can save memory by using the same depth buffer for all such environment textures. In this case,
 * consider using the textureCubeWithSideLength:WithDepthAttachment: method instead.
 */
+(instancetype) textureCubeWithSideLength: (GLuint) sideLength withDepthFormat: (GLenum) depthFormat;

/**
 * Initializes this instance with the specified side length, with the standard GL_RGBA/GL_UNSIGNED_BYTE 
 * pixelFormat/pixelType, and backed by the specified depth attachment.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The depthAttachment argument must not be nil.
 *
 * The depth attachment is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects,
 * you can save memory by using the same depth attachment for all such environment textures.
 */
-(instancetype) initCubeWithSideLength: (GLuint) sideLength
				   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Allocates and initializes an autoreleased instance with the specified side length, with 
 * the standard GL_RGBA/GL_UNSIGNED_BYTE pixelFormat/pixelType, and backed by the specified
 * depth attachment.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The depthAttachment argument must not be nil.
 *
 * The depth attachment is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects,
 * you can save memory by using the same depth attachment for all such environment textures.
 */
+(instancetype) textureCubeWithSideLength: (GLuint) sideLength
					  withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Initializes this instance with the specified side length, with the specified pixel format
 * and type, and backed by the specified depth attachment.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The depthAttachment argument must not be nil.
 *
 * Be aware that the possible combinations of color and depth pixel formats is quite limited
 * with cube-mapped framebuffer attachments. If you have trouble finding a suitable combination,
 * you can use the initWithDepthAttachment: method, which invokes this method with GL_RGBA as
 * the colorFormat and GL_UNSIGNED_BYTE as the colorType.
 *
 * The depth attachment is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects,
 * you can save memory by using the same depth attachment for all such environment textures.
 */
-(instancetype) initCubeWithSideLength: (GLuint) sideLength
				  withColorPixelFormat: (GLenum) colorFormat
					withColorPixelType: (GLenum) colorType
				   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;

/**
 * Allocates and initializes an autoreleased instance with the specified side length, with
 * the specified pixel format and type, and backed by the specified depth attachment.
 *
 * The sideLength argument indicates the length, in pixels, of each side of the texture.
 *
 * The depthAttachment argument must not be nil.
 *
 * Be aware that the possible combinations of color and depth pixel formats is quite limited
 * with cube-mapped framebuffer attachments. If you have trouble finding a suitable combination,
 * you can use the initWithDepthAttachment: method, which invokes this method with GL_RGBA as
 * the colorFormat and GL_UNSIGNED_BYTE as the colorType.
 *
 * The depth attachment is used only during the rendering of the environment to this texture.
 * If you are creating many environmental textures of the same size, for different objects,
 * you can save memory by using the same depth attachment for all such environment textures.
 */
+(instancetype) textureCubeWithSideLength: (GLuint) sideLength
					 withColorPixelFormat: (GLenum) colorFormat
					   withColorPixelType: (GLenum) colorType
					  withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment;


#pragma mark Deprecated

/** @deprecated Use initCubeWithSideLength:withDepthAttachment: instead. */
-(instancetype) initCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment __deprecated;

/** @deprecated Use textureCubeWithSideLength:withDepthAttachment: instead. */
+(instancetype) textureCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment __deprecated;

/** @deprecated Use initCubeWithSideLength:withColorPixelFormat:withColorPixelType:withDepthAttachment: instead. */
-(instancetype) initCubeWithColorPixelFormat: (GLenum) colorFormat
						   andColorPixelType: (GLenum) colorType
						  andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment __deprecated;

/** @deprecated Use textureCubeWithSideLength:withColorPixelFormat:withColorPixelType:withDepthAttachment: instead. */
+(instancetype) textureCubeWithColorPixelFormat: (GLenum) colorFormat
							  andColorPixelType: (GLenum) colorType
							 andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment __deprecated;

@end


#pragma mark -
#pragma mark CC3SurfaceManager

/**
 * CC3SurfaceManager manages a collection of related resizable surfaces, and ensures that
 * all surfaces are resized together.
 *
 * A sophisticated app may use a number of renderable surfaces, and in many cases, several
 * surfaces may be related, and should all have the same size. In a dynamic app (such as one
 * that supports resizing a layer or view, there will be the requirement to resize all of
 * the related surfaces together. 
 *
 * For example, post-processing techniques might be used, where one surface is rendered to 
 * another, and for best fidelity, both surfaces should be the same size. If these surfaces
 * can be resized, they should be resized together.
 *
 * Another example is the surfaces used to render for the primary view. Under OSX, the view
 * will be resized as the containing window is resized. Under iOS, the view will be resized
 * if the device rotates between Landscape and Portrait orientation. In either cases, all
 * surfaces that are sized to the view's size, must be resized.
 *
 * In both of these cases, a CC3SurfaceManager can be used to ensure that all of the related
 * surfaces are resized together.
 *
 * You can add surfaces to an instance of this manager, using the addSurface: method, and 
 * then invoke the size property on this instance to resize all of the surfaces together.
 *
 * Specialized subclasses include CC3SceneDrawingSurfaceManager, for managing surfaces used
 * by a CC3Layer to render a CC3Scene, and CC3ViewSurfaceManager, used by the system to manage
 * the surfaces used to render to the OS view.
 *
 * You can create your own subclasses of this class to manage off-screen surfaces used by
 * your application, if you have several surfaces whose sizes can change dynamically, and
 * you want to ensure that they all retain consistent sizing. In doing so, you can use the
 * retainSurface:inIvar: method as a convenient way of creating property accessors for your
 * surfaces, while ensuring that they will also be resized automatically.
 */
@interface CC3SurfaceManager : NSObject {
	NSMutableArray* _resizeableSurfaces;
	CC3IntSize _size;
}

/**
 * Registers the specified surface to be resized when the resizeTo: method of this surface
 * manager is invoked.
 *
 * It is safe to register the same surface more than once, and it is safe to register two
 * surfaces that share one or more attachments. This implementation will ensure that each
 * attachment is resized only once during each resizing action.
 */
-(void) addSurface: (id<CC3RenderSurface>) surface;

/**
 * Removes the specified surface previously added with the addSurface: method.
 *
 * It is safe to invoke this method even if the specified surface has never been added,
 * or has already been removed.
 */
-(void) removeSurface: (id<CC3RenderSurface>) surface;

/**
 * Sets the specified surface into the instance variable with the specified name.
 *
 * This is a convenience method that performs the following operations:
 *   - Retieives the surface currently in the instance variable with the specified name.
 *   - Invokes the removeSurface: method, passing that existing surface.
 *   - Sets the specified surface into the instance variable with the specified name.
 *   - Invokes the addSurface: method, passing the specified surface.
 *   - Ensures that the old surface is released and the new surface is retained.
 *
 * Subclasses that hold a reference to a surface in an instance variable can use this method
 * to conveniently set the surface in the instance variable, while ensuring that the old
 * surface is removed from the collection of surfaces, and the new surface is added.
 */
-(void) retainSurface: (id<CC3RenderSurface>) surface inIvar: (NSString*) ivarName;

/** 
 * The size of the rendering surfaces contained in this manager, in pixels.
 *
 * Setting the value of this property resizes all of the surfaces managed by this
 * instance to the specified size.
 */
@property(nonatomic, assign) CC3IntSize size;


#pragma mark Allocation and initialization

/** Returns an instance initialized with an empty collection of surfaces. */
+(instancetype) surfaceManager;

@end


#pragma mark -
#pragma mark CC3SceneDrawingSurfaceManager

/**
 * Manages the render surfaces that are tied to the size of a CC3Layer. Each CC3Layer contains
 * an instance of this class, and resizes that instance whenever the size of the CC3Layer
 * is changed, which, in turn, resizes all managed surfaces.
 *
 * Wraps the view surface and picking surface. The viewSurface represents a surface section on 
 * the primary on-screen view surface. The picking surface is a (typically) off-screen surface 
 * used to render the CC3Scene for node picking.
 *
 * You can add additional surfaces that should be tied to the size of the CC3Layer. Typically,
 * this may include any post-processing surfaces used to render effects within the CC3Layer. 
 * If doing so, you should consider subclassing this class in order to provide convenient 
 * property access to the additional surfaces added to your customized CC3Layer's surface manager.
 */
@interface CC3SceneDrawingSurfaceManager : CC3SurfaceManager {
	CC3SurfaceSection* _viewSurface;
	id<CC3RenderSurface> _pickingSurface;
}

/** 
 * Returns the surface to which on-screen rendering to the view should be directed.
 *
 * This surface represents a section on the primary on-screen view surface retrieved from
 * CC3ViewSurfaceManager.sharedViewSurfaceManager.renderingSurface. The bounds of this surface
 * section are determined by the viewSurfaceOrigin and size properties of this instance.
 */
@property(nonatomic, retain, readonly) id<CC3RenderSurface> viewSurface;

/**
 * The origin of the view surface for the CC3Layer, relative to the OS view.
 *
 * Changing the value of this property changes the value returned by the viewport property,
 * of the surface in the viewSurface property, which causes rendering to occur only within
 * the section of the OS view surface defined by the viewport property.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) CC3IntPoint viewSurfaceOrigin;

/** 
 * Returns the surface to which rendering for picking should be directed.
 *
 * If not set directly, this property will be lazily initialized to an off-screen surface
 * with the same size and color format as the surface in the viewSurface property, and with
 * a new non-multisampling and non-stencilling depth buffer.
 */
@property(nonatomic, readonly, retain) id<CC3RenderSurface> pickingSurface;

@end


#pragma mark -
#pragma mark CC3ViewSurfaceManager

/**
 * Manages the render surfaces used to render content to the OS view on the screen.
 *
 * Wraps the view's surface, and an optional anti-aliasing multisampling surface.
 *
 * If multisampling is not in use, rendering is directed to the surface in the the
 * viewSurface property, which is attached to the underlying core animation layer.
 *
 * If multisampling is used, rendering is directed to the surface in the the
 * multisampleSurface property, and then once rendering is complete, the multisampled
 * surface can be resolved onto the view surface.
 */
@interface CC3ViewSurfaceManager : CC3SurfaceManager {
	CC3GLFramebuffer* _viewSurface;
	CC3GLFramebuffer* _multisampleSurface;
}

/** Returns the on-screen surface attached to the underlying core animation layer. */
@property(nonatomic, retain, readonly) id<CC3RenderSurface> viewSurface;

/**
 * Returns the surface used for off-screen multisample rendering.
 *
 * The value of this property may be nil if multisampling is not in use.
 */
@property(nonatomic, retain, readonly) id<CC3RenderSurface> multisampleSurface;

/**
 * Returns the surface to which rendering should be directed.
 *
 * If multisampling is in use, this property returns the framebuffer in the multisampleSurface
 * property, otherwise it returns the framebuffer in the viewSurface property.
 */
@property(nonatomic, retain, readonly) id<CC3RenderSurface> renderingSurface;

/** 
 * Returns the color format of the pixels.
 *
 * This is a convenience property that helps you create off-screen surfaces that match
 * the fromat of the on-screen surface.
 */
@property(nonatomic, readonly) GLenum colorFormat;

/**
 * Returns the depth format of the pixels.
 *
 * This is a convenience property that helps you create off-screen surfaces that match 
 * the fromat of the on-screen surface.
 */
@property(nonatomic, readonly) GLenum depthFormat;

/**
 * Returns the stencil format of the pixels.
 *
 * This is a convenience property that helps you create off-screen surfaces that match
 * the fromat of the on-screen surface.
 */
@property(nonatomic, readonly) GLenum stencilFormat;

/**
 * Returns the texture pixel format that matches the format of the color attachment
 * of the view's rendering surface.
 *
 * This is a convenience property that helps you create off-screen texture rendering
 * surfaces that match the fromat of the on-screen surface.
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
 * This is a convenience property that helps you create off-screen texture rendering
 * surfaces that match the fromat of the on-screen surface.
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
 * This is a convenience property that helps you create off-screen texture rendering
 * surfaces that match the fromat of the on-screen surface.
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
 * This is a convenience property that helps you create off-screen texture rendering
 * surfaces that match the fromat of the on-screen surface.
 *
 * Under OpenGL, textures use different formatting than renderbuffers. When creating an
 * off-screen surface that uses a texture as its depth attachment, you can use the values
 * returned by this property and the depthTexelFormat property to create a texture that
 * matches the format of the depth buffer of the view's rendering surface.
 */
@property(nonatomic, readonly) GLenum depthTexelType;

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
 * This method should only be used if multisampling is not being resolved already within
 * the CCGLView. Under normal operation, CCGLView manages the resolution of multisampling.
 *
 * If the view supports multisampling, resolve the multisampling surface into the view surface.
 *
 * If framebuffer discarding is supported, this method also instructs the GL engine to allow the
 * discarding of any framebuffers that are not needed for presenting the final image to the screen.
 *
 * Upon completion, this method leaves the renderbuffer that is attached to the view bound 
 * to the GL engine, so that it can be presented to the view.
 */
-(void) resolveMultisampling;

/** @deprecated Property moved to [CC3Backgrounder sharedBackgrounder] singleton. */
@property(nonatomic, retain) CC3Backgrounder* backgrounder __deprecated;

/**
 * @deprecated The picking surface is always dedicated.
 * This property always returns YES. Setting this property has no effect.
 */
@property(nonatomic, assign) BOOL shouldUseDedicatedPickingSurface __deprecated;


#pragma mark Allocation and initialization

/** Initializes this instance for the specified view. */
-(instancetype) initFromView: (CCGLView*) view;

/**
 * Returns a singleton instance.
 *
 * This method must be invoked after the view has been established in the CCDirector.
 */
+(CC3ViewSurfaceManager*) sharedViewSurfaceManager;

@end


#pragma mark -
#pragma mark Support functions

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

/** 
 * Returns a string combination of the framebuffer name and the attachment type, 
 * or nil if the framebuffer does not have name.
 */
NSString* CC3FramebufferAttachmentName(CC3GLFramebuffer* framebuffer, GLenum attachment);

// Legacy naming
#define CC3GLViewSurfaceManager CC3ViewSurfaceManager
