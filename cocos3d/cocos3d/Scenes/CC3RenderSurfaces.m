/*
 * CC3RenderSurfaces.m
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
 * 
 * See header file CC3RenderSurfaces.h for full API documentation.
 */

#import "CC3RenderSurfaces.h"
#import "CC3OpenGL.h"
#import "CC3CC2Extensions.h"
#import "CC3Scene.h"
#import "CC3Backgrounder.h"
#import "CC3OSExtensions.h"


#pragma mark -
#pragma mark CC3GLRenderbuffer

@implementation CC3GLRenderbuffer

@synthesize pixelFormat=_format, pixelSamples=_samples, isManagingGL=_isManagingGL;

-(void) dealloc {
	[self deleteGLRenderbuffer];
	[super dealloc];
}

-(GLuint) renderbufferID {
	[self ensureGLRenderbuffer];
	return _rbID;
}

-(void) ensureGLRenderbuffer {
	if (_isManagingGL && !_rbID) _rbID = CC3OpenGL.sharedGL.generateRenderbuffer;
}

-(void) deleteGLRenderbuffer {
	if (_isManagingGL && _rbID) [CC3OpenGL.sharedGL deleteRenderbuffer: _rbID];
	_rbID = 0;
}

/** If the renderbuffer has been created, set its debug label as well. */
-(void) setName: (NSString*) name {
	[super setName: name];
	if (name && _rbID) [CC3OpenGL.sharedGL setDebugLabel: name forRenderbuffer: _rbID];
}

-(CC3IntSize) size { return _size; }

-(void) setSize: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, _size) ) return;

	_size = size;

	if (self.isManagingGL) {
		[CC3OpenGL.sharedGL allocateStorageForRenderbuffer: self.renderbufferID
												  withSize: _size
												 andFormat: _format
												andSamples: _samples];
	}
}

-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	CC3Assert(NO, @"%@ does not support replaing pixel content.", self);
}

-(void) bind { [CC3OpenGL.sharedGL bindRenderbuffer: self.renderbufferID]; }



#pragma mark Framebuffer attachment

-(void) bindToFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindRenderbuffer: self.renderbufferID
						   toFrameBuffer: framebuffer.framebufferID
							asAttachment: attachment];
}

-(void) unbindFromFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindRenderbuffer: 0
						   toFrameBuffer: framebuffer.framebufferID
							asAttachment: attachment];
}

-(void) deriveNameFromFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment {
	if( !_name ) self.name = CC3FramebufferAttachmentName(framebuffer, attachment);
}


#pragma mark Allocation and initialization

-(instancetype) initWithTag:(GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_rbID = 0;
		_size = CC3IntSizeMake(0, 0);
		_format = GL_ZERO;
		_samples = 1;
		_isManagingGL = YES;
	}
	return self;
}

+(instancetype) renderbuffer { return [[[self alloc] init] autorelease]; }

-(instancetype) initWithPixelFormat: (GLenum) format {
	return [self initWithPixelFormat: format withPixelSamples: 1];
}

+(instancetype) renderbufferWithPixelFormat: (GLenum) format {
	return [[[self alloc] initWithPixelFormat: format] autorelease];
}

-(instancetype) initWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples {
	if ( (self = [self init]) ) {
		_format = format;
		_samples = samples;
	}
	return self;
}

+(instancetype) renderbufferWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples {
	return [[[self alloc] initWithPixelFormat: format withPixelSamples: samples] autorelease];
}

-(instancetype) initWithPixelFormat: (GLenum) format withRenderbufferID: (GLuint) rbID {
	return [self initWithPixelFormat: format withPixelSamples: 1  withRenderbufferID: rbID];
}

+(instancetype) renderbufferWithPixelFormat: (GLenum) format withRenderbufferID: (GLuint) rbID {
	return [[[self alloc] initWithPixelFormat: format withRenderbufferID: rbID] autorelease];
}

-(instancetype) initWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples withRenderbufferID: (GLuint) rbID {
	if ( (self = [self initWithPixelFormat: format withPixelSamples: samples]) ) {
		_rbID = rbID;
		_isManagingGL = NO;
	}
	return self;
}

+(instancetype) renderbufferWithPixelFormat: (GLenum) format withPixelSamples: (GLuint) samples withRenderbufferID: (GLuint) rbID {
	return [[[self alloc] initWithPixelFormat: format withPixelSamples: samples withRenderbufferID: rbID] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ (GLID: %u)", super.description, _rbID]; }

@end


#pragma mark -
#pragma mark CC3TextureFramebufferAttachment

@implementation CC3TextureFramebufferAttachment

@synthesize face=_face, mipmapLevel=_mipmapLevel;
@synthesize shouldUseStrongReferenceToTexture=_shouldUseStrongReferenceToTexture;

-(void) dealloc {
	[_texObj release];
	[super dealloc];
}

-(CC3Texture*) texture { return (CC3Texture*)_texObj.resolveWeakReference; }

-(void) setTexture: (CC3Texture*) texture {
	if (texture == self.texture) return;
	texture.horizontalWrappingFunction = GL_CLAMP_TO_EDGE;
	texture.verticalWrappingFunction = GL_CLAMP_TO_EDGE;
	[self setTexObj: texture];
}

-(BOOL) shouldUseStrongReferenceToTexture { return _shouldUseStrongReferenceToTexture; }

-(void) setShouldUseStrongReferenceToTexture: (BOOL) shouldUseStrongRef {
	if (shouldUseStrongRef == _shouldUseStrongReferenceToTexture) return;
	_shouldUseStrongReferenceToTexture = shouldUseStrongRef;
	[self setTexObj: self.texture];		// Update the reference type of the texture
}

/**
 * Sets the _texObj instance variable from the specified texture.
 *
 * If the value of the shouldUseStrongReferenceToTexture property is YES, the texture
 * is held directly in the strongly referenced _texObj iVar. If the value of the
 * shouldUseStrongReferenceToTexture property is NO, the texture is first wrapped in
 * a weak reference, which is then assigned to the strongly referenced _texObj iVar.
 */
-(void) setTexObj: (CC3Texture*) texture {
	NSObject* newTexObj = self.shouldUseStrongReferenceToTexture ? texture : [texture asWeakReference];
	if (newTexObj == _texObj) return;
	
	[_texObj release];
	_texObj = [newTexObj retain];
}

-(CC3IntSize) size { return self.texture.size; }

-(void) setSize: (CC3IntSize) size { [self.texture resizeTo: size]; }

-(GLenum) pixelFormat { return self.texture.pixelFormat; }

-(void) bindToFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindTexture2D: self.texture.textureID
								 face: _face
						  mipmapLevel: _mipmapLevel
						toFrameBuffer: framebuffer.framebufferID
						 asAttachment: attachment];
}

-(void) unbindFromFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindTexture2D: 0
								 face: _face
						  mipmapLevel: _mipmapLevel
						toFrameBuffer: framebuffer.framebufferID
						 asAttachment: attachment];
}

/** Only update the texture if it has not already been given a name, and if the framebuffer does have a name. */
-(void) deriveNameFromFramebuffer: (CC3GLFramebuffer*) framebuffer asAttachment: (GLenum) attachment {
	CC3Texture* tex = self.texture;
	if ( !tex.name ) tex.name = CC3FramebufferAttachmentName(framebuffer, attachment);
}

-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	[self.texture replacePixels: rect inTarget: _face withContent: colorArray];
}


#pragma mark Allocation and initialization

-(instancetype) init { return [self initWithTexture: nil]; }

+(instancetype) attachment { return [[[self alloc] init] autorelease]; }

-(instancetype) initWithTexture: (CC3Texture*) texture {
	return [self initWithTexture: texture usingFace: texture.initialAttachmentFace];
}

+(instancetype) attachmentWithTexture: (CC3Texture*) texture {
	return [[((CC3TextureFramebufferAttachment*)[self alloc]) initWithTexture: texture] autorelease];
}

-(instancetype) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face {
	return [self initWithTexture: texture usingFace: face andLevel: 0];
}

+(instancetype) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face {
	return [[[self alloc] initWithTexture: texture usingFace: face] autorelease];
}

-(instancetype) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	if ( (self = [super init]) ) {
		_face = face;
		_mipmapLevel = mipmapLevel;
		_shouldUseStrongReferenceToTexture = YES;
		self.texture = texture;
	}
	return self;
}

+(instancetype) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	return [[[self alloc] initWithTexture: texture usingFace: face andLevel: mipmapLevel] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ on %@", self.class, self.texture]; }

@end


#pragma mark -
#pragma mark CC3SurfaceSection

@implementation CC3SurfaceSection

-(void) dealloc {
	[_baseSurface release];
	[super dealloc];
}

-(id<CC3RenderSurface>) baseSurface { return _baseSurface; }

-(void) setBaseSurface: (id<CC3RenderSurface>) baseSurface {
	if (baseSurface == _baseSurface) return;
	
	[_baseSurface release];
	_baseSurface = [baseSurface retain];
	
	if (CC3IntSizeIsZero(_size)) self.size = baseSurface.size;
	
	[self checkCoverage];
}

-(CC3IntSize) size { return _size; }

-(void) setSize: (CC3IntSize) size {
	_size = size;
	[self checkCoverage];
}

-(CC3IntPoint) origin { return _origin; }

-(void) setOrigin: (CC3IntPoint) origin {
	_origin = origin;
	[self checkCoverage];
}

/** Checks if this surface section covers the entire base surface. */
-(void) checkCoverage {
	_isFullCoverage = (CC3IntPointIsZero(self.origin) &&
					   CC3IntSizesAreEqual(self.size, _baseSurface.size));
}

-(BOOL) isFullCoverage { return _isFullCoverage && _baseSurface.isFullCoverage; }

-(CC3Viewport) viewport { return CC3ViewportFromOriginAndSize(self.origin, self.size); }

-(BOOL) isOnScreen { return _baseSurface.isOnScreen; }

-(void) setIsOnScreen: (BOOL) isOnScreen {}

-(id<CC3RenderSurfaceAttachment>) colorAttachment { return _baseSurface.colorAttachment; }

-(void) setColorAttachment: (id<CC3RenderSurfaceAttachment>) colorAttachment {}

-(id<CC3RenderSurfaceAttachment>) depthAttachment { return _baseSurface.depthAttachment; }

-(void) setDepthAttachment: (id<CC3RenderSurfaceAttachment>) depthAttachment {}

-(id<CC3RenderSurfaceAttachment>) stencilAttachment { return _baseSurface.stencilAttachment; }

-(void) setStencilAttachment: (id<CC3RenderSurfaceAttachment>) stencilAttachment {}


#pragma mark Content

-(void) clearColorContent {
	[self openScissors];
	[_baseSurface clearColorContent];
	[self closeScissors];
}

-(void) clearDepthContent {
	[self openScissors];
	[_baseSurface clearDepthContent];
	[self closeScissors];
}

-(void) clearStencilContent {
	[self openScissors];
	[_baseSurface clearStencilContent];
	[self closeScissors];
}

-(void) clearColorAndDepthContent {
	[self openScissors];
	[_baseSurface clearColorAndDepthContent];
	[self closeScissors];
}

-(void) openScissors {
	BOOL shouldClip = !self.isFullCoverage;
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	[gl enableScissorTest: shouldClip];
	if (shouldClip) gl.scissor = self.viewport;
}

-(void) closeScissors { [CC3OpenGL.sharedGL enableScissorTest: NO]; }

-(void) readColorContentFrom: (CC3Viewport) rect into: (ccColor4B*) colorArray {
	[_baseSurface readColorContentFrom: [self transformRect: rect] into: colorArray];
}

-(void) replaceColorPixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	[_baseSurface replaceColorPixels: [self transformRect: rect] withContent: colorArray];
}

-(CGImageRef) createCGImageFrom: (CC3Viewport) rect {
	return [_baseSurface createCGImageFrom: [self transformRect: rect]];
}

-(CGImageRef) createCGImage { return [_baseSurface createCGImageFrom: self.viewport]; }

/** Offsets the specified rectangle by the value of origin property. */
-(CC3Viewport) transformRect: (CC3Viewport) rect { return CC3ViewportTranslate(rect, _origin); }


#pragma mark Drawing

-(void) activate {
	[_baseSurface activate];
	[self openScissors];
}


#pragma mark Allocation and initialization

-(instancetype) initWithTag: (GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_baseSurface = nil;
		_origin = kCC3IntPointZero;
		_size = kCC3IntSizeZero;
		_isFullCoverage = NO;
	}
	return self;
}

-(instancetype) initOnSurface: (id<CC3RenderSurface>) baseSurface {
	if ( (self = [super init]) ) {
		self.baseSurface = baseSurface;
	}
	return self;
}

+(instancetype) surfaceOnSurface: (id<CC3RenderSurface>) baseSurface {
	return [[[self alloc] initOnSurface: baseSurface] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ on %@", self.class, _baseSurface]; }

@end



#pragma mark -
#pragma mark CC3GLFramebuffer

@implementation CC3GLFramebuffer

@synthesize isOnScreen=_isOnScreen, isManagingGL=_isManagingGL;
@synthesize shouldBindGLAttachments=_shouldBindGLAttachments;

-(void) dealloc {
	[self deleteGLFramebuffer];
	
	[_colorAttachment release];
	[_depthAttachment release];
	[_stencilAttachment release];
	
	[super dealloc];
}

-(GLuint) framebufferID {
	[self ensureGLFramebuffer];
	return _fbID;
}

-(void) ensureGLFramebuffer {
	if (_isManagingGL && !_fbID) _fbID = CC3OpenGL.sharedGL.generateFramebuffer;
}

-(void) deleteGLFramebuffer {
	if (_isManagingGL && _fbID) [CC3OpenGL.sharedGL deleteFramebuffer: _fbID];
	_fbID = 0;
}

/** 
 * If the framebuffer has been created, set its debug label as well.
 * And update the names of the attachments.
 */
-(void) setName: (NSString*) name {
	[super setName: name];
	if (name && _fbID) [CC3OpenGL.sharedGL setDebugLabel: name forFramebuffer: _fbID];

	[_colorAttachment deriveNameFromFramebuffer: self asAttachment: GL_COLOR_ATTACHMENT0];
	[_depthAttachment deriveNameFromFramebuffer: self asAttachment: GL_DEPTH_ATTACHMENT];
	[_stencilAttachment deriveNameFromFramebuffer: self asAttachment: GL_STENCIL_ATTACHMENT];
}

-(CC3IntSize) size { return _size; }

-(void) setSize: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, _size) ) return;
	
	_size = size;

	// Set the size of each attachment. After changing the size, we rebind each attachment because
	// texture attachments require the texture to be the correct size at the time of binding, and
	// changing the size of the texture itself is not enough.
	_colorAttachment.size = size;
	[self bind: _colorAttachment asAttachment: GL_COLOR_ATTACHMENT0];
	
	_depthAttachment.size = size;
	[self bind: _depthAttachment asAttachment: GL_DEPTH_ATTACHMENT];

	_stencilAttachment.size = size;
	[self bind: _stencilAttachment asAttachment: GL_STENCIL_ATTACHMENT];
	
	[self validate];
}

-(BOOL) isFullCoverage { return YES; }

-(CC3Viewport) viewport { return CC3ViewportFromOriginAndSize(kCC3IntPointZero, self.size); }


#pragma mark Attachments

-(id<CC3FramebufferAttachment>) colorAttachment { return _colorAttachment; }

-(void) setColorAttachment: (id<CC3FramebufferAttachment>) colorAttachment {
	if (colorAttachment == _colorAttachment) return;
	
	[self unbind: _colorAttachment asAttachment: GL_COLOR_ATTACHMENT0];
	[_colorAttachment release];

	_colorAttachment = [colorAttachment retain];
	[self alignSizeOfAttachment: _colorAttachment];		// After attaching, as may change size of attachments.
	[self bind: _colorAttachment asAttachment: GL_COLOR_ATTACHMENT0];
	
	[self validate];
}

-(id<CC3FramebufferAttachment>) depthAttachment { return _depthAttachment; }

-(void) setDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	if (depthAttachment == _depthAttachment) return;
	
	[self unbind: _depthAttachment asAttachment: GL_DEPTH_ATTACHMENT];
	[_depthAttachment release];

	_depthAttachment = [depthAttachment retain];
	[self alignSizeOfAttachment: _depthAttachment];		// After attaching, as may change size of attachments.
	[self bind: _depthAttachment asAttachment: GL_DEPTH_ATTACHMENT];

	// Check for combined depth and stencil buffer
	if ( CC3DepthFormatIncludesStencil(_depthAttachment.pixelFormat) )
		self.stencilAttachment = _depthAttachment;
	
	[self validate];
}

-(id<CC3FramebufferAttachment>) stencilAttachment { return _stencilAttachment; }

-(void) setStencilAttachment: (id<CC3FramebufferAttachment>) stencilAttachment {
	if (stencilAttachment == _stencilAttachment) return;
	
	[self unbind: _stencilAttachment asAttachment: GL_STENCIL_ATTACHMENT];
	[_stencilAttachment release];

	_stencilAttachment = [stencilAttachment retain];
	[self alignSizeOfAttachment: _stencilAttachment];		// After attaching, as may change size of attachments.
	[self bind: _stencilAttachment asAttachment: GL_STENCIL_ATTACHMENT];

	[self validate];
}

/**
 * Aligns the size of the specified attachment with this framebuffer. Does nothing if the
 * sizes are the same. If they sizes are different, then if this framebuffer has no size
 * yet, set it from the attachment, otherwise resize the attachment to match this surface.
 */
-(void) alignSizeOfAttachment: (id<CC3FramebufferAttachment>) attachment {
	CC3IntSize mySize = self.size;
	CC3IntSize attSize = attachment.size;

	if ( CC3IntSizesAreEqual(mySize, attSize) ) return;
	
	if ( CC3IntSizeIsZero(mySize) )
		self.size = attSize;
	else
		attachment.size = mySize;
}

/** 
 * If appropriate, binds the specified framebuffer attachment to this framebuffer in the GL engine,
 * and derives the name of the framebuffer attachment from the framebuffer and attachment names.
 * Don't bind if this framebuffer has no size. Binding will occur once the size is set.
 */
-(void) bind: (id<CC3FramebufferAttachment>) fbAttachment asAttachment: (GLenum) attachment {
	if (self.shouldBindGLAttachments && !CC3IntSizeIsZero(self.size))
		[fbAttachment bindToFramebuffer: self asAttachment: attachment];
	
	[fbAttachment deriveNameFromFramebuffer: self asAttachment: attachment];
}

/** If appropriate, unbinds the specified framebuffer attachment from this framebuffer in the GL engine.*/
-(void) unbind: (id<CC3FramebufferAttachment>) fbAttachment asAttachment: (GLenum) attachment {
	if (self.shouldBindGLAttachments) [fbAttachment unbindFromFramebuffer: self asAttachment: attachment];
}

-(CC3Texture*) colorTexture {
	return ((CC3TextureFramebufferAttachment*)self.colorAttachment).texture;
}

-(void) setColorTexture: (CC3Texture*) colorTexture {
	self.colorAttachment = [CC3TextureFramebufferAttachment attachmentWithTexture: colorTexture];
}

-(CC3Texture*) depthTexture {
	return ((CC3TextureFramebufferAttachment*)self.depthAttachment).texture;
}

-(void) setDepthTexture: (CC3Texture*) depthTexture {
	self.depthAttachment = [CC3TextureFramebufferAttachment attachmentWithTexture: depthTexture];
}

-(void) validate {
	// Validate only if this framebuffer has a size, and at least one attachment
	if ( !(_colorAttachment || _depthAttachment || _stencilAttachment) ) return;
	if (CC3IntSizeIsZero(self.size)) return;
	
	CC3Assert([CC3OpenGL.sharedGL checkFramebufferStatus: self.framebufferID], @"%@ is incomplete.", self);
	[self checkGLDebugLabel];
}

/** Sets the GL debug label for the framebuffer, if required. */
-(void) checkGLDebugLabel {
	if (_fbID && !_glLabelWasSet) {
		[CC3OpenGL.sharedGL setDebugLabel: self.name forFramebuffer: _fbID];
		_glLabelWasSet = YES;
	}
}


#pragma mark Content

-(void) clearColorContent {
	[self activate];

	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	gl.colorMask = ccc4(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	[gl clearBuffers: GL_COLOR_BUFFER_BIT];
}

-(void) clearDepthContent {
	[self activate];
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	gl.depthMask = YES;
	[gl clearBuffers: GL_DEPTH_BUFFER_BIT];
}

-(void) clearStencilContent {
	[self activate];
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	gl.stencilMask = ~0;
	[gl clearBuffers: GL_STENCIL_BUFFER_BIT];
}

-(void) clearColorAndDepthContent {
	[self activate];
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	gl.depthMask = YES;
	gl.colorMask = ccc4(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	[gl clearBuffers: (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)];
}

-(void) readColorContentFrom: (CC3Viewport) rect into: (ccColor4B*) colorArray {
	[CC3OpenGL.sharedGL readPixelsIn: rect fromFramebuffer: self.framebufferID into: colorArray];
}

-(void) replaceColorPixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	[_colorAttachment replacePixels: rect withContent: colorArray];
}

-(CGImageRef) createCGImageFrom: (CC3Viewport) rect {
	
	// Get the image specs
	size_t imgWidth = rect.w;
	size_t imgHeight = rect.h;
	size_t bitsPerComponent		= 8;
	size_t bytesPerRow			= sizeof(ccColor4B) * imgWidth;
	CGColorSpaceRef colorSpace	= CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo		= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
	
	// Fill a temporary array of pixels from the content of this surface
	ccColor4B* pixels = malloc(bytesPerRow * imgHeight);
	CC3Assert(pixels, @"%@ couldn't allocate enough memory to create CGImage.", self)
	[self readColorContentFrom: rect into: pixels];
	
	// Flip the image content vertically to convert from OpenGL to CGImageRef coordinate systems.
	CC3FlipVertically((GLubyte*)pixels, (GLuint)imgHeight, (GLuint)bytesPerRow);
	
	// Create a CGImageRef by creating a bitmap context from the pixels, and extracing a
	// CGImageRef from it. We deliberately don't use CGImageCreate, because it does not copy
	// the data out of the pixels array, which means we couldn't free the pixels array in
	// this method, resulting in a memory leak.
	CGContextRef drawCtx = CGBitmapContextCreate(pixels, imgWidth, imgHeight,
												 bitsPerComponent, bytesPerRow,
												 colorSpace, bitmapInfo);
	CGImageRef image = CGBitmapContextCreateImage(drawCtx);

	CGContextRelease(drawCtx);
	CGColorSpaceRelease(colorSpace);
	free(pixels);

	return image;
}

-(CGImageRef) createCGImage { return [self createCGImageFrom: self.viewport]; }


#pragma mark Drawing

-(void) activate { [CC3OpenGL.sharedGL bindFramebuffer: self.framebufferID]; }


#pragma mark Allocation and initialization

-(instancetype) initWithTag: (GLuint) tag withName: (NSString*) name {
	if ( (self = [super initWithTag: tag withName: name]) ) {
		_fbID = 0;
		_size = CC3IntSizeMake(0, 0);
		_isManagingGL = YES;
		_shouldBindGLAttachments = YES;
		_isOnScreen = NO;
		_colorAttachment = nil;
		_depthAttachment = nil;
		_stencilAttachment = nil;
		_glLabelWasSet = NO;
	}
	return self;
}

-(instancetype) init { return [super init]; }		// Keep compiler happy

+(instancetype) surface { return [[[self alloc] init] autorelease]; }

-(instancetype) initAsColorTextureIsOpaque: (BOOL) isOpaque {
	return [self initAsColorTextureIsOpaque: isOpaque withDepthFormat: GL_DEPTH_COMPONENT16];
}

+(instancetype) colorTextureSurfaceIsOpaque: (BOOL) isOpaque {
	return [[[self alloc] initAsColorTextureIsOpaque: isOpaque] autorelease];
}

-(instancetype) initAsColorTextureIsOpaque: (BOOL) isOpaque
						   withDepthFormat: (GLenum) depthFormat {
	return [self initAsColorTextureIsOpaque: isOpaque
						withDepthAttachment: [CC3GLRenderbuffer renderbufferWithPixelFormat: depthFormat]];
}

+(instancetype) colorTextureSurfaceIsOpaque: (BOOL) isOpaque
							withDepthFormat: (GLenum) depthFormat {
	return [[[self alloc] initAsColorTextureIsOpaque: isOpaque
									 withDepthFormat: depthFormat] autorelease];
}

-(instancetype) initAsColorTextureIsOpaque: (BOOL) isOpaque
					   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self initAsColorTextureWithPixelFormat: (isOpaque ? GL_RGB : GL_RGBA)
									 withPixelType: (isOpaque ? GL_UNSIGNED_SHORT_5_6_5 : GL_UNSIGNED_BYTE)
							   withDepthAttachment: depthAttachment];
}

+(instancetype) colorTextureSurfaceIsOpaque: (BOOL) isOpaque
						withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [[[self alloc] initAsColorTextureIsOpaque: (BOOL) isOpaque
								 withDepthAttachment: depthAttachment] autorelease];
}

-(instancetype) initAsColorTextureWithPixelFormat: (GLenum) pixelFormat
									withPixelType: (GLenum) pixelType
							  withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	if ( (self = [self init]) ) {
		self.colorTexture = [CC3Texture textureWithPixelFormat: pixelFormat withPixelType: pixelType];
		self.depthAttachment = depthAttachment;
	}
	return self;
}

+(instancetype) colorTextureSurfaceWithPixelFormat: (GLenum) pixelFormat
									 withPixelType: (GLenum) pixelType
							   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [[[self alloc] initAsColorTextureWithPixelFormat: pixelFormat
											  withPixelType: pixelType
										withDepthAttachment: depthAttachment] autorelease];
}

-(instancetype) initWithFramebufferID: (GLuint) fbID {
	if ( (self = [self init]) ) {
		_fbID = fbID;
		_isManagingGL = NO;
	}
	return self;
}

+(instancetype) surfaceWithFramebufferID: (GLuint) fbID {
	return [[[self alloc] initWithFramebufferID: fbID] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ (GLID: %u)", super.description, _fbID]; }

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
#pragma mark CC3EnvironmentMapTexture

@implementation CC3EnvironmentMapTexture

@synthesize renderSurface=_renderSurface;
@synthesize numberOfFacesPerSnapshot=_numberOfFacesPerSnapshot;

-(void) dealloc {
	[_renderSurface release];
	[super dealloc];
}

/** Set name of internal framebuffer. */
-(void) setName: (NSString*) name {
	[super setName: name];
	_renderSurface.name = [NSString stringWithFormat: @"%@ surface", name];
}


#pragma mark Drawing

// Clamp to between zero and six
-(void) setNumberOfFacesPerSnapshot: (GLfloat) numberOfFacesPerSnapshot {
	_numberOfFacesPerSnapshot = CLAMP(numberOfFacesPerSnapshot, 0.0, 6.0);
}

-(void) generateSnapshotOfScene: (CC3Scene*) scene fromGlobalLocation: (CC3Vector) location {

	LogTrace(@"%@ generating snapshot", self);

	// Determine how many cube-map faces to render on this snapshot
	GLuint facesToGenerate = self.facesToGenerate;
	if ( !facesToGenerate ) return;
	
	// Get the scene and the cube-map visitor, and set the render surface to that of this texture.
	CC3NodeDrawingVisitor* envMapVisitor = scene.envMapDrawingVisitor;
	envMapVisitor.renderSurface = self.renderSurface;

	// Locate the camera of the cube-map visitor at the specified location,
	CC3Camera* envMapCam = envMapVisitor.camera;
	envMapCam.location = location;
	
	// If the scene has an active camera, match the near and far clip distances, in an attempt
	// to capture the same scene content that is being viewed by the active camera.
	CC3Camera* sceneCam = scene.activeCamera;
	if (sceneCam) {
		envMapCam.nearClippingDistance = sceneCam.nearClippingDistance;
		envMapCam.farClippingDistance = sceneCam.farClippingDistance;
	}
	
	for (GLuint faceIdx = 0; faceIdx < facesToGenerate; faceIdx++) {

		[self moveToNextFace];
		
		// Bind the texture face to the framebuffer
		CC3TextureFramebufferAttachment* fbAtt = (CC3TextureFramebufferAttachment*)_renderSurface.colorAttachment;
		fbAtt.face = _currentFace;
		[fbAtt bindToFramebuffer: _renderSurface asAttachment: GL_COLOR_ATTACHMENT0];
		
		// Point the camera towards the face
		envMapCam.forwardDirection = self.cameraDirection;
		envMapCam.referenceUpDirection = self.upDirection;

		LogTrace(@"%@ rendering face %@ by looking to %@", self, NSStringFromGLEnum(_currentFace),
				 NSStringFromCC3Vector(envMapCam.forwardDirection));

		// Draw the scene to the texture face
		[scene drawSceneContentForEnvironmentMapWithVisitor: envMapVisitor];

//		[self paintFace];		// Uncomment to identify the faces
	}
}

/** 
 * Paints the entire face a solid color. Each face will have a ditinct color,
 * as determined by the faceColor method.
 *
 * This can be useful during testing to diagnose which face is which.
 */
-(void) paintFace {
	CC3IntSize faceSize = _renderSurface.size;
	GLuint pixCnt = faceSize.width * faceSize.height;
	ccColor4B canvas[pixCnt];
	ccColor4B faceColor = self.faceColor;
	for (GLuint pixIdx = 0; pixIdx < pixCnt; pixIdx++) canvas[pixIdx] = faceColor;
	[_renderSurface replaceColorPixels: CC3ViewportFromOriginAndSize(kCC3IntPointZero, faceSize)
						   withContent: canvas];
}

/** Returns the color to paint the current face, using the diagnostic paintFace method. */
-(ccColor4B) faceColor {
	switch (_currentFace) {
		case GL_TEXTURE_CUBE_MAP_POSITIVE_X:
			return CCC4BFromCCC4F(kCCC4FRed);
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_X:
			return CCC4BFromCCC4F(kCCC4FCyan);
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Y:
			return CCC4BFromCCC4F(kCCC4FGreen);
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Y:
			return CCC4BFromCCC4F(kCCC4FMagenta);
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Z:
			return CCC4BFromCCC4F(kCCC4FBlue);
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Z:
			return CCC4BFromCCC4F(kCCC4FYellow);
		default:
			break;
	}
	CC3Assert(NO, @"%@ encountered unknown cube-map face %@", self, NSStringFromGLEnum(_currentFace));
	return CCC4BFromCCC4F(kCCC4FWhite);
}

/**
 * Returns the number of faces to generate on this snapshot.
 *
 * Updates the face count by adding the number of faces to generate on this snapshot,
 * and returns the count as an integer. Subtract the number that will be generated on
 * this snapshot from the running count. This math means that even if the number of
 * faces per snapshot does not divide evenly into an integer number, over time the rate
 * will average out to the value of the numberOfFacesPerSnapshot property.
 */
-(GLuint) facesToGenerate {
	_faceCount += _numberOfFacesPerSnapshot;
	GLuint facesToGenerate = _faceCount;		// Convert to int (rounding down)
	_faceCount -= facesToGenerate;				// Reduce by number that will be done now
	return facesToGenerate;
}

/** 
 * Update the reference to the current face.
 *
 * GL face enums are guaranteed to be consecutive integers. 
 * Increment until we get to the end, then cycle back to the beginning.
 * If we're just starting out, start at the beginning.
 */
-(void) moveToNextFace {
	switch (_currentFace) {
		case GL_TEXTURE_CUBE_MAP_POSITIVE_X:
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_X:
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Y:
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Y:
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Z:
			_currentFace++;
			break;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Z:
		case GL_ZERO:
		default:
			_currentFace = GL_TEXTURE_CUBE_MAP_POSITIVE_X;
			break;
	}
}

/** Returns the direction to point the camera in order to render the current cube-map face. */
-(CC3Vector) cameraDirection {
	switch (_currentFace) {
		case GL_TEXTURE_CUBE_MAP_POSITIVE_X:
			return kCC3VectorUnitXPositive;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_X:
			return kCC3VectorUnitXNegative;
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Y:
			return kCC3VectorUnitYPositive;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Y:
			return kCC3VectorUnitYNegative;
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Z:
			return kCC3VectorUnitZPositive;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Z:
			return kCC3VectorUnitZNegative;
		default:
			break;
	}
	CC3Assert(NO, @"%@ encountered unknown cube-map face %@", self, NSStringFromGLEnum(_currentFace));
	return kCC3VectorNull;
}

/** Returns the direction to orient the top of the camera to render the current cube-map face. */
-(CC3Vector) upDirection {
	switch (_currentFace) {
		case GL_TEXTURE_CUBE_MAP_POSITIVE_X:
			return kCC3VectorUnitYNegative;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_X:
			return kCC3VectorUnitYNegative;
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Y:
			return kCC3VectorUnitZPositive;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Y:
			return kCC3VectorUnitZNegative;
		case GL_TEXTURE_CUBE_MAP_POSITIVE_Z:
			return kCC3VectorUnitYNegative;
		case GL_TEXTURE_CUBE_MAP_NEGATIVE_Z:
			return kCC3VectorUnitYNegative;
		default:
			break;
	}
	CC3Assert(NO, @"%@ encountered unknown cube-map face %@", self, NSStringFromGLEnum(_currentFace));
	return kCC3VectorNull;
}


#pragma mark Allocation and initialization

-(instancetype) initCubeWithSideLength: (GLuint) sideLength {
	return [self initCubeWithSideLength: sideLength withDepthFormat: GL_DEPTH_COMPONENT16];
}

+(instancetype) textureCubeWithSideLength: (GLuint) sideLength {
	return [[[self alloc] initCubeWithSideLength: (GLuint) sideLength] autorelease];
}

-(instancetype) initCubeWithSideLength: (GLuint) sideLength withDepthFormat: (GLenum) depthFormat {
	CC3GLRenderbuffer* depthBuff = [CC3GLRenderbuffer renderbufferWithPixelFormat: depthFormat];
	return [self initCubeWithSideLength: sideLength withDepthAttachment: depthBuff];
}

+(instancetype) textureCubeWithSideLength: (GLuint) sideLength withDepthFormat: (GLenum) depthFormat {
	return [[[self alloc] initCubeWithSideLength: (GLuint) sideLength withDepthFormat: depthFormat] autorelease];
}

-(instancetype) initCubeWithSideLength: (GLuint) sideLength
				   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self initCubeWithSideLength: sideLength
				   withColorPixelFormat: GL_RGBA
					 withColorPixelType: GL_UNSIGNED_BYTE
					withDepthAttachment: depthAttachment];
}

+(instancetype) textureCubeWithSideLength: (GLuint) sideLength
					  withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [[[self alloc] initCubeWithSideLength: sideLength withDepthAttachment: depthAttachment] autorelease];
}

-(instancetype) initCubeWithSideLength: (GLuint) sideLength
				  withColorPixelFormat: (GLenum) colorFormat
					withColorPixelType: (GLenum) colorType
				   withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	if ( (self = [self initCubeWithSideLength: sideLength withPixelFormat: colorFormat withPixelType: colorType]) ) {
		_faceCount = 0.0f;
		_numberOfFacesPerSnapshot = 1.0f;
		_currentFace = GL_ZERO;
		_renderSurface = [[CC3GLFramebuffer alloc] init];	// retained

		// Create the texture attachment, based on this texture. Since this texture holds the rendering surface,
		// it must be attached to the surface attachment with a weak reference, to avoid a retain cycle.
		CC3TextureFramebufferAttachment* ta = [CC3TextureFramebufferAttachment attachmentWithTexture: self];
		ta.shouldUseStrongReferenceToTexture = NO;
		_renderSurface.colorAttachment = ta;
		_renderSurface.depthAttachment = depthAttachment;
		
		_renderSurface.size = CC3IntSizeMake(sideLength, sideLength);

		[_renderSurface validate];
	}
	return self;
}

+(instancetype) textureCubeWithSideLength: (GLuint) sideLength
					 withColorPixelFormat: (GLenum) colorFormat
					   withColorPixelType: (GLenum) colorType
					  withDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [[[self alloc] initCubeWithSideLength: sideLength
							withColorPixelFormat: colorFormat
							  withColorPixelType: colorType
							 withDepthAttachment: depthAttachment] autorelease];
}


#pragma mark Deprecated

-(instancetype) initCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self initCubeWithSideLength: depthAttachment.size.width withDepthAttachment: depthAttachment ];
}

+(instancetype) textureCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self textureCubeWithSideLength: depthAttachment.size.width withDepthAttachment: depthAttachment ];
}

-(instancetype) initCubeWithColorPixelFormat: (GLenum) colorFormat
						   andColorPixelType: (GLenum) colorType
						  andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self initCubeWithSideLength: depthAttachment.size.width
				   withColorPixelFormat: colorFormat
					 withColorPixelType: colorType
					withDepthAttachment: depthAttachment ];
}

+(instancetype) textureCubeWithColorPixelFormat: (GLenum) colorFormat
							  andColorPixelType: (GLenum) colorType
							 andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self textureCubeWithSideLength: depthAttachment.size.width
					  withColorPixelFormat: colorFormat
						withColorPixelType: colorType
					   withDepthAttachment: depthAttachment ];
}

@end


#pragma mark -
#pragma mark CC3SurfaceManager

@implementation CC3SurfaceManager

-(void) dealloc {
	[_resizeableSurfaces release];
	[super dealloc];
}

-(void) addSurface: (id<CC3RenderSurface>) surface {
	if ( !surface || [_resizeableSurfaces containsObject: surface] ) return;
	
	[_resizeableSurfaces addObject: surface];
	[self alignSizeOfSurface: surface];
}

-(void) removeSurface: (id<CC3RenderSurface>) surface {
	if (surface) [_resizeableSurfaces removeObjectIdenticalTo: surface];
}

-(CC3IntSize) size { return _size; }

-(void) setSize: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, _size) ) return;
	
	_size = size;
	for (id<CC3RenderSurface> surface in _resizeableSurfaces) surface.size = size;
}

/**
 * Aligns the size of the specified surface with this instance. Does nothing if the sizes 
 * are the same. If they sizes are different, then if this instance has no size yet, set 
 * it from the surface, otherwise resize the surface to match this instance.
 */
-(void) alignSizeOfSurface: (id<CC3RenderSurface>) surface {
	CC3IntSize mySize = self.size;
	CC3IntSize surfSize = surface.size;
	
	if ( CC3IntSizesAreEqual(mySize, surfSize) ) return;
	
	if ( CC3IntSizeIsZero(mySize) )
		self.size = surfSize;
	else
		surface.size = mySize;
}

-(void) retainSurface: (id<CC3RenderSurface>) surface inIvar: (NSString*) ivarName {
	id<CC3RenderSurface> currSurf = [self valueForKey: ivarName];
	if (surface == currSurf) return;
	
	[self removeSurface: currSurf];
	[currSurf release];

	[self setValue: surface forKey: ivarName];		// Retained
	[self addSurface: surface];
}


#pragma mark Allocation and initialization

-(instancetype) init {
    if ( (self = [super init]) ) {
		_resizeableSurfaces = [NSMutableArray new];		// retained
		_size = CC3IntSizeMake(0, 0);
	}
    return self;
}

+(instancetype) surfaceManager { return [[[self alloc] init] autorelease]; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %li surfaces",
			self.class, (unsigned long)_resizeableSurfaces.count]; }

@end


#pragma mark -
#pragma mark CC3SceneDrawingSurfaceManager

@implementation CC3SceneDrawingSurfaceManager

-(void) dealloc {
	[_viewSurface release];
	[_pickingSurface release];
	[super dealloc];
}

/** Lazily create a surface section on the renderingSurface from the CC3ViewSurfaceManager singleton. */
-(id<CC3RenderSurface>) viewSurface {
	if ( !_viewSurface ) self.viewSurface = [CC3SurfaceSection surfaceOnSurface: CC3ViewSurfaceManager.sharedViewSurfaceManager.renderingSurface];
	return _viewSurface;
}

-(void) setViewSurface: (CC3SurfaceSection*) surface {
	[self retainSurface: surface inIvar: @"_viewSurface"];
}

-(CC3IntPoint) viewSurfaceOrigin { return _viewSurface.origin; }

-(void) setViewSurfaceOrigin: (CC3IntPoint) viewSurfaceOrigin {
	((CC3SurfaceSection*)self.viewSurface).origin = viewSurfaceOrigin;
}

/**
 * Lazily create a surface, using the color format of the view's color surface,
 * and with a new non-multisampling and non-stencilling depth buffer.
 */
-(id<CC3RenderSurface>) pickingSurface {
	if ( !_pickingSurface ) {
		CC3ViewSurfaceManager* viewSurfMgr = CC3ViewSurfaceManager.sharedViewSurfaceManager;
		GLenum viewColorFormat = viewSurfMgr.colorFormat;
		GLenum viewDepthFormat = viewSurfMgr.depthFormat;
		
		CC3GLFramebuffer* pickSurf = [CC3GLFramebuffer surface];
		pickSurf.name = @"Picking surface";
		
		pickSurf.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: viewColorFormat];
		
		// Don't need stencil for picking, but otherwise match the rendering depth format
		if (viewDepthFormat) {
			if ( CC3DepthFormatIncludesStencil(viewDepthFormat) ) viewDepthFormat = GL_DEPTH_COMPONENT16;
			pickSurf.depthAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: viewDepthFormat];
		}
		
		self.pickingSurface = pickSurf;
		
		LogInfo(@"Created picking surface of size %@ with color format %@ and depth format %@.",
				NSStringFromCC3IntSize(pickSurf.size),
				NSStringFromGLEnum(pickSurf.colorAttachment.pixelFormat),
				NSStringFromGLEnum(pickSurf.depthAttachment.pixelFormat));
	}
	return _pickingSurface;
}

-(void) setPickingSurface: (id<CC3RenderSurface>) surface {
	[self retainSurface: surface inIvar: @"_pickingSurface"];
}

@end


#pragma mark -
#pragma mark CC3ViewSurfaceManager

@implementation CC3ViewSurfaceManager

@synthesize shouldUseDedicatedPickingSurface=__shouldUseDedicatedPickingSurface;

-(void) dealloc {
	[_viewSurface release];
	[_multisampleSurface release];
	
	[super dealloc];
}

-(CC3GLFramebuffer*) viewSurface { return _viewSurface; }

-(void) setViewSurface: (CC3GLFramebuffer*) surface {
	[self retainSurface: surface inIvar: @"_viewSurface"];
}

-(CC3GLFramebuffer*) multisampleSurface { return _multisampleSurface; }

-(void) setMultisampleSurface: (CC3GLFramebuffer*) surface {
	[self retainSurface: surface inIvar: @"_multisampleSurface"];
}

-(CC3GLFramebuffer*) renderingSurface {
	return _multisampleSurface ? _multisampleSurface : _viewSurface;
}

-(BOOL) shouldUseDedicatedPickingSurface { return YES; }

-(void) setShouldUseDedicatedPickingSurface: (BOOL) shouldUseDedicatedPickingSurface {}

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

-(void) setSize: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, self.size) ) return;
	
	[super setSize: size];
	
	LogInfo(@"View surface size set to: %@, %@.", NSStringFromCC3IntSize(self.size),
			(self.isMultisampling ? [NSString stringWithFormat: @"multisampling from %@",
									 NSStringFromCC3IntSize(self.multisamplingSize)]
			 : @"with no multisampling"));
	
	// After validating each surface, ensure we leave the rendering surface active for Cocos2D
	[self.renderingSurface activate];
}

// Deprecated
-(CC3Backgrounder*) backgrounder { return CC3Backgrounder.sharedBackgrounder; }
-(void) setBackgrounder: (CC3Backgrounder*) backgrounder {}


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
	id<CC3RenderSurface> rendSurf = self.renderingSurface;
	if (_multisampleSurface) fbAtts[fbAttCount++] = GL_COLOR_ATTACHMENT0;
	if (rendSurf.depthAttachment) fbAtts[fbAttCount++] = GL_DEPTH_ATTACHMENT;
	if (rendSurf.stencilAttachment) fbAtts[fbAttCount++] = GL_STENCIL_ATTACHMENT;
	[gl discard: fbAttCount attachments: fbAtts fromFramebuffer: ((CC3GLFramebuffer*)rendSurf).framebufferID];
	
	[(CC3GLRenderbuffer*)_viewSurface.colorAttachment bind];
}


#pragma mark Allocation and initialization

-(instancetype) initFromView: (CCGLView*) view {
    if ( (self = [super init]) ) {
		self.size = CC3IntSizeFromCGSize(view.surfaceSize);
		GLenum colorFormat = view.pixelColorFormat;
		GLenum depthFormat = view.pixelDepthFormat;
		GLuint viewFramebufferID = view.defaultFrameBuffer;
		GLuint msaaFramebufferID = view.msaaFrameBuffer;
		BOOL isMultiSampling = (msaaFramebufferID > 0);
		
		CC3GLFramebuffer* vSurf = [CC3GLFramebuffer surfaceWithFramebufferID: viewFramebufferID];
		vSurf.name = @"Display surface";
		vSurf.shouldBindGLAttachments = NO;			// Attachments are bound already
		vSurf.isOnScreen = !isMultiSampling;		// View surface is off-screen when multisampling
		vSurf.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: colorFormat
															withRenderbufferID: view.colorRenderBuffer];
		self.viewSurface = vSurf;
		
		if (isMultiSampling) {
			CC3GLFramebuffer* msSurf = [CC3GLFramebuffer surfaceWithFramebufferID: msaaFramebufferID];
			msSurf.name = @"Multisampling surface";
			vSurf.shouldBindGLAttachments = NO;			// Attachments are bound already
			vSurf.isOnScreen = isMultiSampling;			// View surface is off-screen when multisampling
			msSurf.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: colorFormat
																 withRenderbufferID: view.msaaColorBuffer];
			self.multisampleSurface = msSurf;
		}
		if (depthFormat)
			self.renderingSurface.depthAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: depthFormat
																				withRenderbufferID: view.depthBuffer];
	}
    return self;
}

static CC3ViewSurfaceManager* _sharedViewSurfaceManager = nil;

+(CC3ViewSurfaceManager*) sharedViewSurfaceManager {
	if ( !_sharedViewSurfaceManager ) {
		CCGLView* view = CCDirector.sharedDirector.ccGLView;
		CC3Assert(view, @"OpenGL view not available. Be sure to install the CCGLView in"
				  @" the CCDirector before attempting to create the surface manager.");
		_sharedViewSurfaceManager = [[CC3ViewSurfaceManager alloc] initFromView: view];		// retained
	}
	return _sharedViewSurfaceManager;
}

@end


#pragma mark -
#pragma mark Support functions

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

NSString* CC3FramebufferAttachmentName(CC3GLFramebuffer* framebuffer, GLenum attachment) {
	NSString* fbName = framebuffer.name;
	if ( !fbName ) return nil;
	
	NSString* attachmentName = nil;
	switch (attachment) {
		case GL_COLOR_ATTACHMENT0:
			attachmentName = @"color";
			break;
		case GL_DEPTH_ATTACHMENT:
			attachmentName = @"depth";
			break;
		case GL_STENCIL_ATTACHMENT:
			attachmentName = @"stencil";
			break;
			
		default:
			attachmentName = @"unknown";
			break;
	}
	return [NSString stringWithFormat: @"%@-%@", fbName, attachmentName];
}
