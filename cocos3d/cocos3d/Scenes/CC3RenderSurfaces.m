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
#pragma mark CC3GLRenderbuffer

@implementation CC3GLRenderbuffer

@synthesize size=_size, pixelFormat=_format, pixelSamples=_samples;

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

-(void) resizeTo: (CC3IntSize) size {
	_size = size;
	[CC3OpenGL.sharedGL allocateStorageForRenderbuffer: self.renderbufferID
											  withSize: _size
											 andFormat: _format
											andSamples: _samples];
}

-(void) resizeFromCALayer: (CAEAGLLayer*) layer withContext: (EAGLContext*) context {
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	[gl bindRenderbuffer: self.renderbufferID];
	
	if( ![context renderbufferStorage: GL_RENDERBUFFER fromDrawable: layer] ) {
		LogError(@"Failed to allocate renderbuffer storage in GL context.");
		return;
	}
	
	_size.width = [gl getRenderbufferParameterInteger: GL_RENDERBUFFER_WIDTH];
	_size.height = [gl getRenderbufferParameterInteger: GL_RENDERBUFFER_HEIGHT];
	_format = [gl getRenderbufferParameterInteger: GL_RENDERBUFFER_INTERNAL_FORMAT];
	_samples = 1;
}

-(void) presentToContext: (EAGLContext*) context {
	[CC3OpenGL.sharedGL bindRenderbuffer: self.renderbufferID];
	if( ![context presentRenderbuffer: GL_RENDERBUFFER] )
		LogError(@"Failed to swap renderbuffer to screen.");
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
		_samples = 1;
	}
	return self;
}

+(id) renderbuffer { return [[[self alloc] init] autorelease]; }

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format {
	if ( (self = [self initWithPixelFormat: format]) ) {
		[self resizeTo: size];
	}
	return self;
}

+(id) renderbufferWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format {
	return [[((CC3GLRenderbuffer*)[self alloc]) initWithSize: size andPixelFormat: format] autorelease];
}

-(id) initWithPixelFormat: (GLenum) format {
	return [self initWithPixelFormat: format andPixelSamples: 1];
}

+(id) renderbufferWithPixelFormat: (GLenum) format {
	return [[[self alloc] initWithPixelFormat: format] autorelease];
}

-(id) initWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples {
	if ( (self = [self init]) ) {
		_format = format;
		_samples = samples;
	}
	return self;
}

+(id) renderbufferWithPixelFormat: (GLenum) format andPixelSamples: (GLuint) samples {
	return [[[self alloc] initWithPixelFormat: format andPixelSamples: samples] autorelease];
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


#pragma mark -
#pragma mark CC3GLFramebuffer

@implementation CC3GLFramebuffer

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

-(CC3GLRenderbuffer*) colorBuffer { return (CC3GLRenderbuffer*)_colorAttachment; }

-(CC3GLRenderbuffer*) depthBuffer { return (CC3GLRenderbuffer*)_depthAttachment; }

-(CC3GLRenderbuffer*) stencilBuffer { return (CC3GLRenderbuffer*)_stencilAttachment; }

-(BOOL) isMultisampling {
	CC3GLRenderbuffer* colAtt = self.colorBuffer;
	if ( [colAtt isKindOfClass: [CC3GLRenderbuffer class]] ) return (colAtt.pixelSamples > 1);
	return NO;
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
#pragma mark CC3GLViewSurfaceManager

@implementation CC3GLViewSurfaceManager

@synthesize viewSurface=_viewSurface, multisampleSurface=_multisampleSurface;
@synthesize renderingSurface=_renderingSurface, pickingSurface=_pickingSurface;

-(void) dealloc {
	[_viewSurface release];
	[_multisampleSurface release];
	[_renderingSurface release];
	[_pickingSurface release];
	[super dealloc];
}

-(CC3GLFramebuffer*) pickingSurface {
	if ( !_pickingSurface ) {
		if ( !_multisampleSurface )
			self.pickingSurface = _viewSurface;		// If not multisampling, use the viewSurface
		else {
			// If multisampling, create a new surface using the color buffer from viewSurface,
			// and with a new non-multisampling and non-stencilling depth buffer.
			CC3GLFramebuffer* pickSurf = [CC3GLFramebuffer new];
			pickSurf.colorAttachment = _viewSurface.colorAttachment;

			// Don't need stencil for picking, but otherwise match the rendering depth format
			GLenum depthFormat = self.depthFormat;
			if (depthFormat) {
				if ( CC3DepthFormatIncludesStencil(depthFormat) ) depthFormat = GL_DEPTH_COMPONENT16;
				pickSurf.depthAttachment = [CC3GLRenderbuffer renderbufferWithSize: pickSurf.colorBuffer.size
																	andPixelFormat: depthFormat];
			}
			if ( [pickSurf validate] ) self.pickingSurface = pickSurf;
			[pickSurf release];
		}
	}
	return _pickingSurface;
}

-(CC3IntSize) size { return self.renderingSurface.colorBuffer.size; }

-(GLenum) colorFormat { return self.renderingSurface.colorBuffer.pixelFormat; }

-(GLenum) depthFormat { return self.renderingSurface.depthBuffer.pixelFormat; }

-(GLuint) pixelSamples { return self.renderingSurface.colorBuffer.pixelSamples; }

-(BOOL) isMultisampling { return self.renderingSurface.isMultisampling; }


#pragma mark Drawing

-(BOOL) resizeFromCALayer: (CAEAGLLayer*) layer withContext: (EAGLContext*) context {
	
	// Attach the view color buffer to the CALayer
	[_viewSurface.colorBuffer resizeFromCALayer: layer withContext: context];
	
	// Retreive the new size of the screen buffer
	CC3IntSize vsSize = _viewSurface.colorBuffer.size;
	LogInfo(@"Screen rendering surface size changed to: %@", NSStringFromCC3IntSize(vsSize));
	
	// Resize the view depth buffer and validate the view surface.
	// If multisampling, the screen depth buffer will be nil, and will be ignored.
	[_viewSurface.depthBuffer resizeTo: vsSize];
	if ( ![_viewSurface validate] ) return NO;
	
	// Re-allocate storage for the multisampling buffers and validate the multisampling surface.
	if (_multisampleSurface) {
		[_multisampleSurface.colorBuffer resizeTo: vsSize];
		[_multisampleSurface.depthBuffer resizeTo: vsSize];
		if ( ![_multisampleSurface validate] ) return NO;
	}
	
	// If a distinct picking surface is in use, resize its depth buffer.
	if (_pickingSurface != _viewSurface) [_pickingSurface.depthBuffer resizeTo: vsSize];
	
	return YES;
}

-(void) presentToContext: (EAGLContext*) context {
	CC3OpenGL* gl = CC3OpenGL.sharedGL;

	// If it exists, resolve the multisample buffer into the screen buffer
	if (_multisampleSurface)
		[gl resolveMultisampleFramebuffer: _multisampleSurface.framebufferID
						  intoFramebuffer: _viewSurface.framebufferID];

	// Discard used buffers by assembling an array of framebuffer attachments to discard.
	// If multisampling, discard multisampling color buffer.
	// If using depth buffer, discard it from the rendering buffer (either multisampling or screen)
	GLenum fbAtts[3];		// Make room for color, depth & stencil attachments
	GLuint fbAttCount = 0;
	CC3GLFramebuffer* rendSurf = self.renderingSurface;
	if (_multisampleSurface) fbAtts[fbAttCount++] = GL_COLOR_ATTACHMENT0;
	if (rendSurf.depthBuffer) fbAtts[fbAttCount++] = GL_DEPTH_ATTACHMENT;
	if (rendSurf.stencilBuffer) fbAtts[fbAttCount++] = GL_STENCIL_ATTACHMENT;
	[gl discard: fbAttCount attachments: fbAtts fromFramebuffer: rendSurf.framebufferID];
	
	// Swap the renderbuffer onto the screen
	[_viewSurface.colorBuffer presentToContext: context];
}


#pragma mark Allocation and initialization

-(id) initWithColorFormat: (GLenum) colorFormat
		   andDepthFormat: (GLenum) depthFormat
		  andPixelSamples: (GLuint) requestedSamples {

    if ( (self = [super init]) ) {
		
		GLuint samples = MIN(requestedSamples, CC3OpenGL.sharedGL.maxNumberOfPixelSamples);
		
		// Set up the view surface and color render buffer
		_viewSurface = [CC3GLFramebuffer new];				// retained
		_viewSurface.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: colorFormat];
		
		// If using multisampling, also set up off-screen multisample frame and render buffers
		if (samples > 1) {
			_multisampleSurface = [CC3GLFramebuffer new];		// retained
			_multisampleSurface.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: colorFormat
																				 andPixelSamples: samples];
		}
		
		// Set the rendering surface to multisampleSurface if it exists, otherwise viewSurface.
		self.renderingSurface = _multisampleSurface ? _multisampleSurface : _viewSurface;
		
		// If using depth testing, attach a depth buffer to the rendering surface.
		// And if stencil buffer is combined with depth buffer, set it too.
		if (depthFormat) {
			CC3GLFramebuffer* rendSurf = self.renderingSurface;
			rendSurf.depthAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: depthFormat
																	  andPixelSamples: samples];
			if ( CC3DepthFormatIncludesStencil(depthFormat) )
				rendSurf.stencilAttachment = rendSurf.depthAttachment;
		}
	}
    return self;
}

@end


