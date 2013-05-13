/*
 * CC3RenderSurfaces.m
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
 * 
 * See header file CC3RenderSurfaces.h for full API documentation.
 */

#import "CC3RenderSurfaces.h"
#import "CC3OpenGL.h"


#pragma mark -
#pragma mark CC3FramebufferRenderSurface

@implementation CC3FramebufferRenderSurface

-(void) dealloc {
	[self deleteGLFramebuffer];
	[super dealloc];
}

-(GLuint) framebufferID {
	[self ensureGLFramebuffer];
	return _fbID;
}

-(void) ensureGLFramebuffer { if (!_fbID) _fbID = CC3OpenGL.sharedGL.generateFramebufferID; }

-(void) deleteGLFramebuffer {
	[CC3OpenGL.sharedGL deleteFramebuffer: _fbID];
	_fbID = 0;
}

-(NSObject<CC3FramebufferAttachment>*) colorAttachment { return _colorAttachment; }

-(void) setColorAttachment: (NSObject<CC3FramebufferAttachment>*) colorAttachment {
	if (_colorAttachment == colorAttachment) return;
	[_colorAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
	[_colorAttachment release];
	_colorAttachment = [colorAttachment retain];
	[_colorAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
}

-(NSObject<CC3FramebufferAttachment>*) depthAttachment { return _depthAttachment; }

-(void) setDepthAttachment: (NSObject<CC3FramebufferAttachment>*) depthAttachment {
	if (_depthAttachment == depthAttachment) return;
	[_depthAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_DEPTH_ATTACHMENT];
	[_depthAttachment release];
	_depthAttachment = [depthAttachment retain];
	[_depthAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_DEPTH_ATTACHMENT];
}

-(NSObject<CC3FramebufferAttachment>*) stencilAttachment { return _stencilAttachment; }

-(void) setStencilAttachment: (NSObject<CC3FramebufferAttachment>*) stencilAttachment {
	if (_stencilAttachment == stencilAttachment) return;
	[_stencilAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_STENCIL_ATTACHMENT];
	[_stencilAttachment release];
	_stencilAttachment = [stencilAttachment retain];
	[_stencilAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_STENCIL_ATTACHMENT];
}

-(BOOL) validate { return [CC3OpenGL.sharedGL checkFramebufferStatus: self.framebufferID]; }


#pragma mark Drawing

-(void) activateWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl bindFramebuffer: self.framebufferID];
}

-(void) activate { [CC3OpenGL.sharedGL bindFramebuffer: self.framebufferID]; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_fbID = 0;
		_colorAttachment = nil;
		_depthAttachment = nil;
		_stencilAttachment = nil;
	}
	return self;
}

+(id) surface { return [[[self alloc] init] autorelease]; }

@end


#pragma mark -
#pragma mark CC3RetrievedFramebufferRenderSurface

@implementation CC3RetrievedFramebufferRenderSurface

-(id) init {
	if ( (self = [super init]) ) {
		_fbID = [CC3OpenGL.sharedGL getInteger: GL_FRAMEBUFFER_BINDING];
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3GLRenderbuffer

@implementation CC3GLRenderbuffer

@synthesize size=_size, format=_format;

-(void) dealloc {
	[self deleteGLRenderbuffer];
	[super dealloc];
}

-(GLuint) renderbufferID {
	[self ensureGLRenderbuffer];
	return _rbID;
}

-(void) ensureGLRenderbuffer { if (!_rbID) _rbID = CC3OpenGL.sharedGL.generateRenderbufferID; }

-(void) deleteGLRenderbuffer {
	[CC3OpenGL.sharedGL deleteRenderbuffer: _rbID];
	_rbID = 0;
}

-(void) allocateStorageForSize: (CC3IntSize) size andPixelFormat: (GLenum) format {
	_size = size;
	_format = format;
	[CC3OpenGL.sharedGL allocateStorageForRenderbuffer: self.renderbufferID ofSize: size andFormat: format];
}


#pragma mark Framebuffer attachment

-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindRenderbuffer: self.renderbufferID toFrameBuffer: framebufferID asAttachment: attachment];
}

-(void) unbindFromFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindRenderbuffer: 0 toFrameBuffer: framebufferID asAttachment: attachment];
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_rbID = 0;
		_size = CC3IntSizeMake(0, 0);
		_format = GL_ZERO;
	}
	return self;
}

+(id) renderbuffer { return [[[self alloc] init] autorelease]; }

-(id) initWithStorageForSize: (CC3IntSize) size andPixelFormat: (GLenum) format {
	if ( (self = [super init]) ) {
		_rbID = 0;		// Ensure starts at zero to be auto-generated
		[self allocateStorageForSize: size andPixelFormat: format];
	}
	return self;
}

+(id) renderbufferWithStorageForSize: (CC3IntSize) size andPixelFormat: (GLenum) format {
	return [[[self alloc] initWithStorageForSize: size andPixelFormat: format] autorelease];
}

@end


#pragma mark -
#pragma mark CC3GLTextureFramebufferAttachment

@implementation CC3GLTextureFramebufferAttachment

@synthesize texture=_texture, face=_face, mipmapLevel=_mipmapLevel;

-(void) dealloc {
	[_texture release];
	[super dealloc];
}


#pragma mark Framebuffer attachment

-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindTexture2D: _texture.textureID
								 face: _face
						  mipmapLevel: _mipmapLevel
						toFrameBuffer: framebufferID
						 asAttachment: attachment];
}

-(void) unbindFromFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindTexture2D: 0
								 face: _face
						  mipmapLevel: _mipmapLevel
						toFrameBuffer: framebufferID
						 asAttachment: attachment];
}


#pragma mark Allocation and initialization

-(id) init { return [self initWithTexture: nil]; }

-(id) initWithTexture: (CC3GLTexture*) texture {
	return [self initWithTexture: texture usingFace: GL_TEXTURE_2D];
}

+(id) attachmentWithTexture: (CC3GLTexture*) texture {
	return [[((CC3GLTextureFramebufferAttachment*)[self alloc]) initWithTexture: texture] autorelease];
}

-(id) initWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face {
	return [self initWithTexture: texture usingFace: face andLevel: 0];
}

+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face {
	return [[[self alloc] initWithTexture: texture usingFace: face ] autorelease];
}

-(id) initWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	if ( (self = [super init]) ) {
		_texture = [texture retain];
		_face = face;
		_mipmapLevel = mipmapLevel;
	}
	return self;
}

+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	return [[[self alloc] initWithTexture: texture usingFace: face andLevel: mipmapLevel] autorelease];
}

@end


