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
#import "CC3GLView.h"
#import "CC3Backgrounder.h"
#import "CC3OSExtensions.h"


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

-(void) ensureGLRenderbuffer { if (!_rbID) _rbID = CC3OpenGL.sharedGL.generateRenderbuffer; }

-(void) deleteGLRenderbuffer {
	[CC3OpenGL.sharedGL deleteRenderbuffer: _rbID];
	_rbID = 0;
}

-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	CC3AssertUnimplemented(@"replacePixels:withContent:");
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
#pragma mark CC3IOSOnScreenGLRenderbuffer

@implementation CC3IOSOnScreenGLRenderbuffer

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
#pragma mark CC3SystemOnScreenGLRenderbuffer

@implementation CC3SystemOnScreenGLRenderbuffer

-(GLuint) renderbufferID { return 0; }

-(void) ensureGLRenderbuffer {}

-(void) deleteGLRenderbuffer {}

-(void) resizeTo: (CC3IntSize) size { _size = size; }

-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {}

-(void) unbindFromFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {}

@end


#pragma mark -
#pragma mark CC3OSXOnScreenGLRenderbuffer

@implementation CC3OSXOnScreenGLRenderbuffer
@end


#pragma mark -
#pragma mark CC3AndroidOnScreenGLRenderbuffer

@implementation CC3AndroidOnScreenGLRenderbuffer
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

-(void) resizeTo: (CC3IntSize) size { [self.texture resizeTo: size]; }

-(GLenum) pixelFormat { return self.texture.pixelFormat; }

-(void) bindToFramebuffer: (GLuint) framebufferID asAttachment: (GLenum) attachment {
	[CC3OpenGL.sharedGL bindTexture2D: self.texture.textureID
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

-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	[self.texture replacePixels: rect inTarget: _face withContent: colorArray];
}


#pragma mark Allocation and initialization

-(id) init { return [self initWithTexture: nil]; }

+(id) attachment { return [[[self alloc] init] autorelease]; }

-(id) initWithTexture: (CC3Texture*) texture {
	return [self initWithTexture: texture usingFace: texture.initialAttachmentFace];
}

+(id) attachmentWithTexture: (CC3Texture*) texture {
	return [[((CC3TextureFramebufferAttachment*)[self alloc]) initWithTexture: texture] autorelease];
}

-(id) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face {
	return [self initWithTexture: texture usingFace: face andLevel: 0];
}

+(id) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face {
	return [[[self alloc] initWithTexture: texture usingFace: face] autorelease];
}

-(id) initWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	if ( (self = [super init]) ) {
		_face = face;
		_mipmapLevel = mipmapLevel;
		_shouldUseStrongReferenceToTexture = YES;
		self.texture = texture;
	}
	return self;
}

+(id) attachmentWithTexture: (CC3Texture*) texture usingFace: (GLenum) face andLevel: (GLint) mipmapLevel {
	return [[[self alloc] initWithTexture: texture usingFace: face andLevel: mipmapLevel] autorelease];
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ on %@", self.class, self.texture]; }

@end


#pragma mark -
#pragma mark CC3GLFramebuffer

@implementation CC3GLFramebuffer

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

-(void) ensureGLFramebuffer { if (!_fbID) _fbID = CC3OpenGL.sharedGL.generateFramebuffer; }

-(void) deleteGLFramebuffer {
	[CC3OpenGL.sharedGL deleteFramebuffer: _fbID];
	_fbID = 0;
}

-(id<CC3FramebufferAttachment>) colorAttachment { return _colorAttachment; }

-(void) setColorAttachment: (id<CC3FramebufferAttachment>) colorAttachment {
	if (colorAttachment == _colorAttachment) return;
		
	[self ensureSizeOfAttachment: colorAttachment];		// must be done before attaching

	[_colorAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
	
	[_colorAttachment release];
	_colorAttachment = [colorAttachment retain];
	
	[_colorAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
}

-(id<CC3FramebufferAttachment>) depthAttachment { return _depthAttachment; }

-(void) setDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	if (depthAttachment == _depthAttachment) return;
	
	[self ensureSizeOfAttachment: depthAttachment];		// must be done before attaching
	
	[_depthAttachment unbindFromFramebuffer: self.framebufferID asAttachment: GL_DEPTH_ATTACHMENT];

	[_depthAttachment release];
	_depthAttachment = [depthAttachment retain];
	
	[_depthAttachment bindToFramebuffer: self.framebufferID asAttachment: GL_DEPTH_ATTACHMENT];

	// Check for combined depth and stencil buffer
	if ( CC3DepthFormatIncludesStencil(_depthAttachment.pixelFormat) )
		self.stencilAttachment = _depthAttachment;
}

-(id<CC3FramebufferAttachment>) stencilAttachment { return _stencilAttachment; }

-(void) setStencilAttachment: (id<CC3FramebufferAttachment>) stencilAttachment {
	if (stencilAttachment == _stencilAttachment) return;
	
	[self ensureSizeOfAttachment: stencilAttachment];		// must be done before attaching
		
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

-(CC3IntSize) size {
	if (_colorAttachment) return _colorAttachment.size;
	if (_depthAttachment) return _depthAttachment.size;
	if (_stencilAttachment) return _stencilAttachment.size;
	return _size;
}

-(BOOL) isOffScreen { return YES; }

-(BOOL) validate {
	CC3Assert(!CC3IntSizesAreEqual(self.size, kCC3IntSizeZero), @"%@ cannot have a zero size.", self);
	return [CC3OpenGL.sharedGL checkFramebufferStatus: self.framebufferID];
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

-(BOOL) isColorContentReadable { return YES; }

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

-(CGImageRef) createCGImage {
	return [self createCGImageFrom: CC3ViewportFromOriginAndSize(CC3IntPointMake(0, 0), self.size)];
}


#pragma mark Drawing

-(void) activate { [CC3OpenGL.sharedGL bindFramebuffer: self.framebufferID]; }


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
#pragma mark CC3IOSOnScreenGLFramebuffer

@implementation CC3IOSOnScreenGLFramebuffer

-(BOOL) isOffScreen { return NO; }

@end


#pragma mark -
#pragma mark CC3SystemOnScreenGLFramebuffer

@implementation CC3SystemOnScreenGLFramebuffer

-(BOOL) isOffScreen { return NO; }

-(GLuint) framebufferID { return 0; }

-(void) ensureGLFramebuffer {}

-(void) deleteGLFramebuffer {}

-(BOOL) validate { return YES; }

@end


#pragma mark -
#pragma mark CC3OSXOnScreenGLFramebuffer

@implementation CC3OSXOnScreenGLFramebuffer
@end


#pragma mark -
#pragma mark CC3AndroidOnScreenGLFramebuffer

@implementation CC3AndroidOnScreenGLFramebuffer

-(BOOL) isColorContentReadable { return NO; }

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
		[fbAtt bindToFramebuffer: _renderSurface.framebufferID asAttachment: GL_COLOR_ATTACHMENT0];
		
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

-(id) initCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [self initCubeWithColorPixelFormat: GL_RGBA
							andColorPixelType: GL_UNSIGNED_BYTE
						   andDepthAttachment: depthAttachment];
}

+(id) textureCubeWithDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [[[self alloc] initCubeWithDepthAttachment: depthAttachment] autorelease];
}

-(id) initCubeWithColorPixelFormat: (GLenum) colorFormat
				 andColorPixelType: (GLenum) colorType
				andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	if ( (self = [super initCubeWithPixelFormat: colorFormat andPixelType: colorType]) ) {
		_faceCount = 0.0f;
		_numberOfFacesPerSnapshot = 1.0f;
		_currentFace = GL_ZERO;
		_renderSurface = [CC3GLFramebuffer new];			// retained
		_renderSurface.depthAttachment = depthAttachment;

		// Create the texture attachment, based on this texture. Since this texture holds the rendering surface,
		// it must be attached to the surface attachment with a weak reference, to avoid a retain cycle.
		CC3TextureFramebufferAttachment* ta = [CC3TextureFramebufferAttachment attachmentWithTexture: self];
		ta.shouldUseStrongReferenceToTexture = NO;
		_renderSurface.colorAttachment = ta;

		[_renderSurface validate];
	}
	return self;
}

+(id) textureCubeWithColorPixelFormat: (GLenum) colorFormat
					andColorPixelType: (GLenum) colorType
				   andDepthAttachment: (id<CC3FramebufferAttachment>) depthAttachment {
	return [[[self alloc] initCubeWithColorPixelFormat: colorFormat
									 andColorPixelType: colorType
									andDepthAttachment: depthAttachment] autorelease];
}

@end


#pragma mark -
#pragma mark CC3GLViewSurfaceManager

@implementation CC3GLViewSurfaceManager

@synthesize view=_view, shouldUseDedicatedPickingSurface=__shouldUseDedicatedPickingSurface;

-(void) dealloc {
	_view = nil;					// weak reference
	[_resizeableSurfaces release];
	[_viewSurface release];
	[_multisampleSurface release];
	[_pickingSurface release];
	
	[super dealloc];
}

-(CC3GLFramebuffer*) viewSurface { return _viewSurface; }

-(void) setViewSurface: (CC3GLFramebuffer*) surface {
	if (surface == _viewSurface) return;
	
	[self removeSurface: _viewSurface];
	
	[_viewSurface release];
	_viewSurface = [surface retain];
	
	[self addSurface: _viewSurface];
}

-(CC3GLFramebuffer*) multisampleSurface { return _multisampleSurface; }

-(void) setMultisampleSurface: (CC3GLFramebuffer*) surface {
	if (surface == _multisampleSurface) return;
	
	[self removeSurface: _multisampleSurface];
	
	[_multisampleSurface release];
	_multisampleSurface = [surface retain];
	
	[self addSurface: _multisampleSurface];
}

-(CC3GLFramebuffer*) renderingSurface {
	return _multisampleSurface ? _multisampleSurface : _viewSurface;
}

-(CC3GLFramebuffer*) pickingSurface {
	if ( !_pickingSurface ) {
		if (self.shouldUseDedicatedPickingSurface) {
			
			// Create a new surface, using the color buffer from viewSurface if it is
			// readable, or a new framebuffer if not, and with a new non-multisampling
			// and non-stencilling depth buffer.
			CC3GLFramebuffer* pickSurf = [CC3GLFramebuffer surfaceWithSize: _viewSurface.size];
			pickSurf.colorAttachment = _viewSurface.isColorContentReadable
											? _viewSurface.colorAttachment
											: [CC3GLRenderbuffer renderbufferWithPixelFormat: _viewSurface.colorAttachment.pixelFormat];
			
			// Don't need stencil for picking, but otherwise match the rendering depth format
			GLenum depthFormat = self.depthFormat;
			if (depthFormat) {
				if ( CC3DepthFormatIncludesStencil(depthFormat) ) depthFormat = GL_DEPTH_COMPONENT16;
				pickSurf.depthAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: depthFormat];
			}

			LogInfo(@"Creating picking surface of size %@ with %@ color format %@ and depth format %@.",
					 NSStringFromCC3IntSize(pickSurf.size),
					 (_viewSurface.isColorContentReadable ? @"existing" : @"new"),
					 NSStringFromGLEnum(pickSurf.colorAttachment.pixelFormat),
					 NSStringFromGLEnum(depthFormat));
			
			if ( [pickSurf validate] ) self.pickingSurface = pickSurf;
			
		} else {
			LogInfo(@"Reusing view surface as picking surface.");
			self.pickingSurface = self.viewSurface;		// Use the viewSurface
		}
	}
	return _pickingSurface;
}

-(void) setPickingSurface: (CC3GLFramebuffer*) surface {
	if (surface == _pickingSurface) return;
	
	[self removeSurface: _pickingSurface];
	
	[_pickingSurface release];
	_pickingSurface = [surface retain];
	
	[self addSurface: _pickingSurface];
}

-(void) resetPickingSurface { self.pickingSurface = nil; }

-(BOOL) shouldUseDedicatedPickingSurface {
	return (_shouldUseDedicatedPickingSurface ||
			_multisampleSurface ||
			!_viewSurface.isColorContentReadable);
}

-(void) setShouldUseDedicatedPickingSurface: (BOOL) shouldUseDedicatedPickingSurface {
	if (_shouldUseDedicatedPickingSurface == shouldUseDedicatedPickingSurface) return;
	_shouldUseDedicatedPickingSurface = shouldUseDedicatedPickingSurface;
	[self resetPickingSurface];
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

// Deprecated
-(CC3Backgrounder*) backgrounder { return CC3Backgrounder.sharedBackgrounder; }
-(void) setBackgrounder: (CC3Backgrounder*) backgrounder {}


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

	// Resize all attachments on registered surfaces, except the viewSurface color buffer,
	// which was resized above, and validate each surface.
	NSMutableArray* resizedAttachments = [NSMutableArray array];
	for (id<CC3RenderSurface> surface in _resizeableSurfaces) {
		[self resizeAttachment: surface.colorAttachment to: size ifNotIn: resizedAttachments];
		[self resizeAttachment: surface.depthAttachment to: size ifNotIn: resizedAttachments];
		[self resizeAttachment: surface.stencilAttachment to: size ifNotIn: resizedAttachments];
		[surface validate];
	}

	LogInfo(@"View surface size set to: %@, %@.", NSStringFromCC3IntSize(self.size),
			(self.isMultisampling ? [NSString stringWithFormat: @"multisampling from %@",
									 NSStringFromCC3IntSize(self.multisamplingSize)]
								  : @"with no multisampling"));

	// After validating each surface, ensure we leave the rendering surface active for cocos2d
	[self.renderingSurface activate];
}

-(void) resizeAttachment: (id<CC3RenderSurfaceAttachment>) attachment
					  to: (CC3IntSize) size
				 ifNotIn: (NSMutableArray*) alreadyResized {
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
		_resizeableSurfaces = [NSMutableArray new];		// retained
	}
    return self;
}

-(id) initWithView: (CC3GLView*) view {
    if ( (self = [self init]) ) {
		
		_view = view;		// weak reference
		
		// Limit pixel samples to what the platform will support
		GLuint requestedSamples = _view.requestedSamples;
		GLuint samples = MIN(requestedSamples, CC3OpenGL.sharedGL.maxNumberOfPixelSamples);
		
		// Set up the view surface and color render buffer
		GLenum colorFormat = _view.colorFormat;
		CC3GLFramebuffer* vSurf = [CC3ViewFramebufferClass surface];
		vSurf.colorAttachment = [CC3ViewColorRenderbufferClass renderbufferWithPixelFormat: colorFormat];
		self.viewSurface = vSurf;					// retained
		
		// If using multisampling, also set up off-screen multisample frame and render buffers
		if (samples > 1) {
			CC3GLFramebuffer* msSurf = [CC3GLFramebuffer surface];
			msSurf.colorAttachment = [CC3GLRenderbuffer renderbufferWithPixelFormat: colorFormat
																	andPixelSamples: samples];
			self.multisampleSurface = msSurf;
		}
		
		// If using depth testing, attach a depth buffer to the rendering surface.
		GLenum depthFormat = _view.depthFormat;
		if (depthFormat)
			self.renderingSurface.depthAttachment = [CC3ViewDepthRenderbufferClass renderbufferWithPixelFormat: depthFormat
																							   andPixelSamples: samples];
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
