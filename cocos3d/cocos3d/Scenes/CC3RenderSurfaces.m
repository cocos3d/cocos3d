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
#import "CC3CC2Extensions.h"


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
	if ( CC3IntSizesAreEqual(size, _size) ) return;

	_size = size;
	[CC3OpenGL.sharedGL allocateStorageForRenderbuffer: self.renderbufferID
											  withSize: _size
											 andFormat: _format
											andSamples: _samples];
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

-(NSString*) description { return [NSString stringWithFormat: @"%@ %u", self.class, _rbID]; }

@end


#pragma mark -
#pragma mark CC3SystemGLRenderbuffer

@implementation CC3SystemGLRenderbuffer

-(GLuint) renderbufferID { return 0; }

-(void) ensureGLRenderbuffer {}

-(void) deleteGLRenderbuffer {}

-(void) resizeTo: (CC3IntSize) size { _size = size; }


#pragma mark Framebuffer attachment

-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {}

-(void) unbindFromFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {}

@end


#pragma mark -
#pragma mark CC3OnScreenGLRenderbuffer

@implementation CC3OnScreenGLRenderbuffer

/** Sets the size and retreives the pixelFormat property from the GL engine. */
-(void) resizeTo: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, _size) ) return;

	_size = size;
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	[gl bindRenderbuffer: self.renderbufferID];
	_format = [gl getRenderbufferParameterInteger: GL_RENDERBUFFER_INTERNAL_FORMAT];
	_samples = 1;
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

-(CC3IntSize) size { return _texture.size; }

-(void) resizeTo: (CC3IntSize) size { [_texture resizeTo: size]; }

-(GLenum) pixelFormat { return _texture.pixelFormat; }

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
		_face = face;
		_mipmapLevel = mipmapLevel;
		_texture = [texture retain];
		_texture.horizontalWrappingFunction = GL_CLAMP_TO_EDGE;
		_texture.verticalWrappingFunction = GL_CLAMP_TO_EDGE;
	}
	return self;
}

+(id) attachmentWithTexture: (CC3GLTexture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	return [[[self alloc] initWithTexture: texture usingFace: face andLevel: mipmapLevel] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ on %@", self.class, _texture]; }

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

-(id<CC3FramebufferAttachment>) colorAttachment { return _colorAttachment; }

-(void) setColorAttachment: (id<CC3FramebufferAttachment>) colorAttachment {
	if (_colorAttachment == colorAttachment) return;
	[self ensureSizeOfAttachment: colorAttachment];
	[_colorAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
	[_colorAttachment release];
	_colorAttachment = [colorAttachment retain];
	[_colorAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
}

-(id<CC3FramebufferAttachment>) depthAttachment { return _depthAttachment; }

-(void) setDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	if (_depthAttachment == depthAttachment) return;
	[self ensureSizeOfAttachment: depthAttachment];
	[_depthAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_DEPTH_ATTACHMENT];
	[_depthAttachment release];
	_depthAttachment = [depthAttachment retain];
	[_depthAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_DEPTH_ATTACHMENT];

	if ( CC3DepthFormatIncludesStencil(_depthAttachment.pixelFormat) )
		self.stencilAttachment = _depthAttachment;
}

-(id<CC3FramebufferAttachment>) stencilAttachment { return _stencilAttachment; }

-(void) setStencilAttachment: (id<CC3FramebufferAttachment>) stencilAttachment {
	if (_stencilAttachment == stencilAttachment) return;
	[self ensureSizeOfAttachment: stencilAttachment];
	[_stencilAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_STENCIL_ATTACHMENT];
	[_stencilAttachment release];
	_stencilAttachment = [stencilAttachment retain];
	[_stencilAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_STENCIL_ATTACHMENT];
}

-(void) ensureSizeOfAttachment: (id<CC3FramebufferAttachment>) attachment {
	CC3IntSize mySize = self.size;
	if ( CC3IntSizesAreEqual(mySize, kCC3IntSizeZero) ) return;
	if ( CC3IntSizesAreEqual(mySize, attachment.size) ) return;
	[attachment resizeTo: mySize];
}

-(CC3GLTexture*) colorTexture {
	return ((CC3GLTextureFramebufferAttachment*)self.colorAttachment).texture;
}

-(void) setColorTexture: (CC3GLTexture*) colorTexture {
	self.colorAttachment = [CC3GLTextureFramebufferAttachment attachmentWithTexture: colorTexture];
}

-(CC3GLTexture*) depthTexture {
	return ((CC3GLTextureFramebufferAttachment*)self.depthAttachment).texture;
}

-(void) setDepthTexture: (CC3GLTexture*) depthTexture {
	self.depthAttachment = [CC3GLTextureFramebufferAttachment attachmentWithTexture: depthTexture];
}

-(CC3IntSize) size {
	if (_colorAttachment) return _colorAttachment.size;
	if (_depthAttachment) return _depthAttachment.size;
	if (_stencilAttachment) return _stencilAttachment.size;
	return _size;
}

-(BOOL) validate { return [CC3OpenGL.sharedGL checkFramebufferStatus: self.framebufferID]; }


#pragma mark Drawing

-(void) activateWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl bindFramebuffer: self.framebufferID];
}


#pragma mark Allocation and initialization

-(id) init { return [self initWithSize: CC3IntSizeMake(0, 0)]; }

-(id) initWithSize: (CC3IntSize) size {
	if ( (self = [super init]) ) {
		_fbID = 0;
		_colorAttachment = nil;
		_depthAttachment = nil;
		_stencilAttachment = nil;
		_size = size;
	}
	return self;
}

+(id) surface { return [[[self alloc] init] autorelease]; }

+(id) surfaceWithSize: (CC3IntSize) size {
	return [[((CC3GLFramebuffer*)[self alloc]) initWithSize: size] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ %u", self.class, _fbID]; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@ of size %@", [self description], NSStringFromCC3IntSize(self.size)];
	if (_colorAttachment || _depthAttachment || _stencilAttachment) {
		[desc appendFormat: @" with attachments:"];
		if (_colorAttachment) [desc appendFormat: @"\n\tColor: %@", _colorAttachment];
		if (_depthAttachment) [desc appendFormat: @"\n\tDepth: %@", _depthAttachment];
		if (_stencilAttachment) [desc appendFormat: @"\n\tStencil: %@", _stencilAttachment];
	}
	return desc;
}

@end


#pragma mark -
#pragma mark CC3SystemGLFramebuffer

@implementation CC3SystemGLFramebuffer

-(GLuint) framebufferID { return 0; }

-(void) ensureGLFramebuffer {}

-(void) deleteGLFramebuffer {}

-(BOOL) validate { return YES; }

@end


#pragma mark -
#pragma mark CC3GLViewSurfaceManager

@implementation CC3GLViewSurfaceManager

-(void) dealloc {
	[_viewSurface release];
	[_multisampleSurface release];
	[_pickingSurface release];
	[_resizeableSurfaces release];
	[super dealloc];
}

-(CC3GLFramebuffer*) viewSurface { return _viewSurface; }

-(void) setViewSurface: (CC3GLFramebuffer*) surface {
	if (surface == _viewSurface) return;
	[self removeSurface: _viewSurface];
	[_viewSurface release];
	_viewSurface = [surface retain];
	[self addSurface: surface];
}

-(CC3GLFramebuffer*) multisampleSurface { return _multisampleSurface; }

-(void) setMultisampleSurface: (CC3GLFramebuffer*) surface {
	if (surface == _multisampleSurface) return;
	[self removeSurface: _multisampleSurface];
	[_multisampleSurface release];
	_multisampleSurface = [surface retain];
	[self addSurface: surface];
}

-(CC3GLFramebuffer*) renderingSurface {
	return _multisampleSurface ? _multisampleSurface : _viewSurface;
}

-(CC3GLFramebuffer*) pickingSurface {
	if ( !_pickingSurface ) {
		if ( !_multisampleSurface )
			self.pickingSurface = _viewSurface;		// If not multisampling, use the viewSurface
		else {
			// If multisampling, create a new surface using the color buffer from viewSurface,
			// and with a new non-multisampling and non-stencilling depth buffer.
			CC3GLFramebuffer* pickSurf = [CC3GLFramebuffer surface];
			pickSurf.colorAttachment = _viewSurface.colorAttachment;

			// Don't need stencil for picking, but otherwise match the rendering depth format
			GLenum depthFormat = self.depthFormat;
			if (depthFormat) {
				if ( CC3DepthFormatIncludesStencil(depthFormat) ) depthFormat = GL_DEPTH_COMPONENT16;
				pickSurf.depthAttachment = [CC3GLRenderbuffer renderbufferWithSize: pickSurf.colorAttachment.size
																	andPixelFormat: depthFormat];
			}
			if ( [pickSurf validate] ) self.pickingSurface = pickSurf;
		}
	}
	return _pickingSurface;
}

-(void) setPickingSurface: (CC3GLFramebuffer*) surface {
	if (surface == _pickingSurface) return;
	[self removeSurface: _pickingSurface];
	[_pickingSurface release];
	_pickingSurface = [surface retain];
	[self addSurface: surface];
}

-(CC3GLRenderbuffer*) viewColorBuffer { return (CC3GLRenderbuffer*)_viewSurface.colorAttachment; }

-(CC3IntSize) size { return self.renderingSurface.colorAttachment.size; }

-(GLenum) colorFormat { return self.renderingSurface.colorAttachment.pixelFormat; }

-(GLenum) depthFormat { return self.renderingSurface.depthAttachment.pixelFormat; }

-(GLenum) stencilFormat { return self.renderingSurface.stencilAttachment.pixelFormat; }

-(GLenum) colorTexelFormat { return CC3TexelFormatFromRenderbufferColorFormat(self.colorFormat); }

-(GLenum) colorTexelType { return CC3TexelTypeFromRenderbufferColorFormat(self.colorFormat); }

-(GLenum) depthTexelFormat { return CC3TexelFormatFromRenderbufferDepthFormat(self.depthFormat); }

-(GLenum) depthTexelType { return CC3TexelTypeFromRenderbufferDepthFormat(self.depthFormat); }

-(GLuint) pixelSamples { return ((CC3GLRenderbuffer*)self.renderingSurface.colorAttachment).pixelSamples; }

-(BOOL) isMultisampling { return self.pixelSamples > 1; }

-(CC3IntSize) multisamplingSize {
	CC3IntSize baseSize = self.size;
	switch (self.pixelSamples) {
		case 2:
		case 4:
			return CC3IntSizeMake(baseSize.width * 2, baseSize.height * 2);
		case 6:
		case 8:
		case 9:
			return CC3IntSizeMake(baseSize.width * 3, baseSize.height * 3);
		case 16:
			return CC3IntSizeMake(baseSize.width * 4, baseSize.height * 4);
		default:
			return baseSize;
	}
}


#pragma mark Resizing surfaces

-(void) addSurface: (id<CC3RenderSurface>) surface {
	if ( surface && ![_resizeableSurfaces containsObject: surface] )
		[_resizeableSurfaces addObject: surface];
}

-(void) removeSurface: (id<CC3RenderSurface>) surface {
	if (surface) [_resizeableSurfaces removeObjectIdenticalTo: surface];
}

-(void) resizeTo: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, self.size) ) return;

	LogInfo(@"Screen rendering surface size changed to: %@", NSStringFromCC3IntSize(size));
	
	// Resize all attachments on registered surfaces, except the viewSurface color buffer,
	// which was resized above, and validate each surface.
	CCArray* resizedAttachments = [CCArray new];
	for (id<CC3RenderSurface> surface in _resizeableSurfaces) {
		[self resizeAttachment: surface.colorAttachment to: size ifNotIn: resizedAttachments];
		[self resizeAttachment: surface.depthAttachment to: size ifNotIn: resizedAttachments];
		[self resizeAttachment: surface.stencilAttachment to: size ifNotIn: resizedAttachments];
		[surface validate];
	}
	[resizedAttachments release];
}

-(void) resizeAttachment: (id<CC3RenderSurfaceAttachment>) attachment
					  to: (CC3IntSize) size
				 ifNotIn: (CCArray*) alreadyResized {
	if ( !attachment || [alreadyResized containsObject: attachment] ) return;
	[attachment resizeTo: size];
	[alreadyResized addObject: attachment];
	LogTrace(@"Resizing %@ to: %@", attachment, NSStringFromCC3IntSize(size));
}


#pragma mark Drawing

-(void) resolveMultisampling {
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	
	// If it exists, resolve the multisample buffer into the screen buffer
	if (_multisampleSurface)
		[gl resolveMultisampleFramebuffer: _multisampleSurface.framebufferID
						  intoFramebuffer: _viewSurface.framebufferID];
	
	// Discard used buffers by assembling an array of framebuffer attachments to discard.
	// If multisampling, discard multisampling color buffer.
	// If using depth buffer, discard it from the rendering buffer (either multisampling or screen)
	GLenum fbAtts[3];			// Make room for color, depth & stencil attachments
	GLuint fbAttCount = 0;
	CC3GLFramebuffer* rendSurf = self.renderingSurface;
	if (_multisampleSurface) fbAtts[fbAttCount++] = GL_COLOR_ATTACHMENT0;
	if (rendSurf.depthAttachment) fbAtts[fbAttCount++] = GL_DEPTH_ATTACHMENT;
	if (rendSurf.stencilAttachment) fbAtts[fbAttCount++] = GL_STENCIL_ATTACHMENT;
	[gl discard: fbAttCount attachments: fbAtts fromFramebuffer: rendSurf.framebufferID];
	
	[gl bindRenderbuffer: self.viewColorBuffer.renderbufferID];
}


#pragma mark Allocation and initialization

-(id) init {
    if ( (self = [super init]) ) {
		_resizeableSurfaces = [CCArray new];		// retained
	}
    return self;
}

-(id) initWithColorFormat: (GLenum) colorFormat
		   andDepthFormat: (GLenum) depthFormat
		  andPixelSamples: (GLuint) requestedSamples {
    if ( (self = [self init]) ) {
		
		// Limit pixel samples to what the platform will support
		GLuint samples = MIN(requestedSamples, CC3OpenGL.sharedGL.maxNumberOfPixelSamples);
		
		// Set up the view surface and color render buffer
		CC3GLFramebuffer* vSurf = [CC3GLFramebuffer surface];
		vSurf.colorAttachment = [CC3OnScreenGLRenderbuffer renderbufferWithPixelFormat: colorFormat];
		self.viewSurface = vSurf;					// retained
		
		// If using multisampling, also set up off-screen multisample frame and render buffers
		if (samples > 1) {
			CC3GLFramebuffer* msSurf = [CC3GLFramebuffer surface];
			msSurf.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: colorFormat
																	andPixelSamples: samples];
			self.multisampleSurface = msSurf;		// retained
		}
		
		// If using depth testing, attach a depth buffer to the rendering surface.
		if (depthFormat)
			self.renderingSurface.depthAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: depthFormat
																				   andPixelSamples: samples];
	}
    return self;
}

-(id) initSystemColorFormat: (GLenum) colorFormat
			 andDepthFormat: (GLenum) depthFormat
			andPixelSamples: (GLuint) samples {
    if ( (self = [self init]) ) {
		
		// Set up the view surface and color render buffer
		CC3GLFramebuffer* vSurf = [CC3SystemGLFramebuffer surface];
		vSurf.colorAttachment = [CC3SystemGLRenderbuffer renderbufferWithPixelFormat: colorFormat
																	 andPixelSamples: samples];
		
		// If using depth testing, attach a depth buffer to the rendering surface.
		if (depthFormat) {
			vSurf.depthAttachment = [CC3SystemGLRenderbuffer renderbufferWithPixelFormat: depthFormat
																		 andPixelSamples: samples];
		}

		self.viewSurface = vSurf;		// retained
	}
    return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %li surfaces",
			self.class, (unsigned long)_resizeableSurfaces.count]; }

@end

GLenum CC3TexelFormatFromRenderbufferColorFormat(GLenum rbFormat) {
	switch (rbFormat) {
		case GL_RGB565:
		case GL_RGB8:
			return GL_RGB;
		case GL_RGBA4:
		case GL_RGB5_A1:
		case GL_RGBA8:
		default:
			return GL_RGBA;
	}
}

GLenum CC3TexelTypeFromRenderbufferColorFormat(GLenum rbFormat) {
	switch (rbFormat) {
		case GL_RGB565:
			return GL_UNSIGNED_SHORT_5_6_5;
		case GL_RGBA4:
			return GL_UNSIGNED_SHORT_4_4_4_4;
		case GL_RGB5_A1:
			return GL_UNSIGNED_SHORT_5_5_5_1;
		case GL_RGB8:
		case GL_RGBA8:
		default:
			return GL_UNSIGNED_BYTE;
	}
}

GLenum CC3TexelFormatFromRenderbufferDepthFormat(GLenum rbFormat) {
	switch (rbFormat) {
		case GL_DEPTH24_STENCIL8:
			return GL_DEPTH_STENCIL;
		case GL_DEPTH_COMPONENT16:
		case GL_DEPTH_COMPONENT24:
		case GL_DEPTH_COMPONENT32:
		default:
			return GL_DEPTH_COMPONENT;
	}
}

GLenum CC3TexelTypeFromRenderbufferDepthFormat(GLenum rbFormat) {
	switch (rbFormat) {
		case GL_DEPTH24_STENCIL8:
			return GL_UNSIGNED_INT_24_8;
		case GL_DEPTH_COMPONENT24:
		case GL_DEPTH_COMPONENT32:
			return GL_UNSIGNED_INT;
		case GL_DEPTH_COMPONENT16:
		default:
			return GL_UNSIGNED_SHORT;
	}
}
