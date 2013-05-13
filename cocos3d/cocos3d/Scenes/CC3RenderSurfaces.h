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

@end


#pragma mark -
#pragma mark CC3FramebufferAttachment

/**
 * An instance of CC3FramebufferAttachment can be attached to a CC3FramebufferRenderSurface to
 * provide a buffer to which drawing can occur. The type of data that is drawn to the buffer
 * depends on how it is attached to the CC3FramebufferRenderSurface, and can include color data,
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
#pragma mark CC3FramebufferRenderSurface

/**
 * Represents a rendering surface that uses an underlying framebuffer.
 *
 * Framebuffers hold between one and three attachments. Each attachment represents a rendering
 * surface that holds a particular type of drawn content: color content, depth content, or
 * stencil content. Typically, each of these attachments will be either a renderbuffer, a
 * texture (to support rendering to a texture, or nil, indicating that that type of content
 * is not being rendered.
 */
@interface CC3FramebufferRenderSurface : NSObject <CC3RenderSurface> {
	GLuint _fbID;
	NSObject<CC3FramebufferAttachment>* _colorAttachment;
	NSObject<CC3FramebufferAttachment>* _depthAttachment;
	NSObject<CC3FramebufferAttachment>* _stencilAttachment;
}

/** The ID used to identify the underlying framebuffer to the GL engine. */
@property(nonatomic, readonly) GLuint framebufferID;

/** 
 * The rendering surface to which color data is rendered.
 *
 * Setting this property binds the attachment to the underlying framebuffer in the GL engine.
 */
@property(nonatomic, retain) NSObject<CC3FramebufferAttachment>* colorAttachment;

/**
 * The rendering surface to which depth data is rendered.
 *
 * Setting this property binds the attachment to the underlying framebuffer in the GL engine.
 */
@property(nonatomic, retain) NSObject<CC3FramebufferAttachment>* depthAttachment;

/**
 * The rendering surface to which stencil data is rendered.
 *
 * Setting this property binds the attachment to the underlying framebuffer in the GL engine.
 */
@property(nonatomic, retain) NSObject<CC3FramebufferAttachment>* stencilAttachment;

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
#pragma mark CC3RetrievedFramebufferRenderSurface

/**
 * CC3RetrievedFramebufferRenderSurface is a specialized framebuffer surface that initializes
 * the value of the framebufferID property from the framebuffer that is currently bound to the
 * GL engine at the time the CC3RetrievedFramebufferRenderSurface instance is created.
 *
 * An instance of this class can be used to represent the default screen rendering framebuffer
 * when that framebuffer was created externally.
 */
@interface CC3RetrievedFramebufferRenderSurface : CC3FramebufferRenderSurface
@end

	
#pragma mark -
#pragma mark CC3GLRenderbuffer

/** CC3GLRenderbuffer represents an OpenGL renderbuffer. */
@interface CC3GLRenderbuffer : NSObject <CC3FramebufferAttachment> {
	GLuint _rbID;
	CC3IntSize _size;
	GLenum _format;
}

/** The ID used to identify the underlying renderbuffer to the GL engine. */
@property(nonatomic, readonly) GLuint renderbufferID;

/**
 * The size of the rendering surface of this renderbuffer in pixels.
 *
 * The initial value of this propery is (0, 0). If the allocateStorageForSize:andPixelFormat:
 * method is invoked, this property will be set to the value specified in that method. 
 * Otherwise, this property can be set directly if space is allocated elsewhere.
 */
@property(nonatomic, assign) CC3IntSize size;

/** 
 * The format of each pixel in this renderbuffer.
 *
 * The initial value of this propery is GL_ZERO. If the allocateStorageForSize:andPixelFormat:
 * method is invoked, this property will be set to the value specified in that method.
 * Otherwise, this property can be set directly if space is allocated elsewhere.
 */
@property(nonatomic, assign) GLenum format;

/**
 * Allocates storage space within GL memory for this buffer, sufficient to render an image of
 * the specified size in the  specified pixel format. The size and format properties of this
 * instance are set to the specified values.
 *
 * If this renderbuffer is rendering to the primary on-screen view, this method should not
 * be invoked.
 */
-(void) allocateStorageForSize: (CC3IntSize) size andPixelFormat: (GLenum) format;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased intance. */
+(id) renderbuffer;

/**
 * Initializes this instance and allocates storage space within GL memory for this buffer,
 * sufficient to render an image of the specified size in the  specified pixel format.
 * The size and format properties of this instance are set to the specified values.
 *
 * If this renderbuffer is rendering to the primary on-screen view, this method should not
 * be invoked. Instead, the instance should be initialized with the init method.
 */
-(id) initWithStorageForSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

/**
 * Allocates and initializes an autoreleased instance and allocates storage space within GL memory
 * for this buffer, sufficient to render an image of the specified size in the specified pixel
 * format. The size and format properties of this instance are set to the specified values.
 *
 * If this renderbuffer is rendering to the primary on-screen view, this method should not be 
 * invoked. Instead, the instance should be allocated nad initialized with the renderbuffer method.
 */
+(id) renderbufferWithStorageForSize: (CC3IntSize) size andPixelFormat: (GLenum) format;

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



