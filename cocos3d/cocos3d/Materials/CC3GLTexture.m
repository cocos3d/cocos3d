/*
 * CC3GLTexture.m
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
 * See header file CC3GLTexture.h for full API documentation.
 */

#import "CC3GLTexture.h"
#import "CC3PVRGLTexture.h"


#pragma mark -
#pragma mark CC3GLTexture 


@implementation CC3GLTexture

@synthesize textureID=_textureID, size=_size, coverage=_coverage, hasMipmap=_hasMipmap;
@synthesize pixelFormat=_pixelFormat, pixelType=_pixelType;
@synthesize hasPremultipliedAlpha=_hasPremultipliedAlpha;
@synthesize isUpsideDown=_isUpsideDown, shouldFlipVerticallyOnLoad=_shouldFlipVerticallyOnLoad;

-(void) dealloc {
	[self deleteGLTexture];
	[super dealloc];
}

-(void) ensureGLTexture { if (!_textureID) _textureID = CC3OpenGL.sharedGL.generateTextureID; }

-(void) deleteGLTexture {
	[CC3OpenGL.sharedGL deleteTexture: _textureID];
	_textureID = 0;
}

-(BOOL) isPOTWidth { return (_size.width == ccNextPOT(_size.width)); }

-(BOOL) isPOTHeight { return (_size.height == ccNextPOT(_size.height)); }

-(BOOL) isPOT { return self.isPOTWidth && self.isPOTHeight; }

-(BOOL) isTexture2D { return NO; }

-(BOOL) isTextureCube { return NO; }

-(GLenum) textureTarget {
	CC3AssertUnimplemented(@"textureTarget");
	return GL_ZERO;
}

+(BOOL) defaultShouldFlipVerticallyOnLoad { return NO; }

+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip {}


#pragma mark Binding content

-(void) resizeTo: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, _size) ) return;
	_size = size;
	[self bindEmptyContent];
}

-(void) bindEmptyContent { CC3AssertUnimplemented(@"bindEmptyContent"); }

-(void) bindTextureContent: (CC3Texture2DContent*) texContent toTarget: (GLenum) target {
	
	if (texContent.isUpsideDown && self.shouldFlipVerticallyOnLoad)
		[self flipTextureContentVertically: texContent];
	
	[self ensureGLTexture];
	
	_size = CC3IntSizeMake((GLint)texContent.pixelsWide, (GLint)texContent.pixelsHigh);
	_coverage = CGSizeMake(texContent.maxS, texContent.maxT);
	_pixelFormat = texContent.pixelGLFormat;
	_pixelType = texContent.pixelGLType;
	_hasPremultipliedAlpha = texContent.hasPremultipliedAlpha;
	_isUpsideDown = texContent.isUpsideDown;
		
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint tuIdx = 0;		// Choose the texture unit to work in
	
	[gl bindTexture: _textureID toTarget: self.textureTarget at: tuIdx];
	[gl loadTexureImage: texContent.imageData
			 intoTarget: target
			   withSize: _size
			 withFormat: _pixelFormat
			   withType: _pixelType
	  withByteAlignment: self.byteAlignment
					 at: tuIdx];
}

-(GLuint) byteAlignment {

	// First see if we can figure it out based on pixel type
	switch (_pixelType) {
		case GL_UNSIGNED_SHORT:
		case GL_UNSIGNED_SHORT_4_4_4_4:
		case GL_UNSIGNED_SHORT_5_5_5_1:
		case GL_UNSIGNED_SHORT_5_6_5:
			return CC3IntIsEven(_size.width) ? 4 : 2;

		case GL_UNSIGNED_INT:
		case GL_UNSIGNED_INT_24_8:
			return 4;
	}

	// Pixel type at this point is GL_UNSIGNED_BYTE.
	// See if we can figure it out based on pixel format.
	switch (_pixelFormat) {
		case GL_RGBA: return 4;
		case GL_LUMINANCE_ALPHA: return CC3IntIsEven(_size.width) ? 4 : 2;
	}

	// Boundary is at byte level, so check it based on whether
	// texture width is divisible by either 4 or 2.
	return CC3IntIsEven(_size.width) ? (CC3IntIsEven(_size.width / 2) ? 4 : 2) : 1;
}


#pragma mark Mipmaps

-(void) generateMipmap {
	if ( self.hasMipmap || !self.isPOT) return;
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint tuIdx = 0;	// Choose the texture unit to work in
	GLenum target = self.textureTarget;
	[gl bindTexture: _textureID toTarget: target at: tuIdx];
	[gl generateMipmapForTarget: target at: tuIdx];
	_hasMipmap = YES;
}

/** Indicates whether Mipmaps should automatically be generated for any loaded textures. */
static BOOL _shouldGenerateMipmaps = YES;

+(BOOL) shouldGenerateMipmaps { return _shouldGenerateMipmaps; }

+(void) setShouldGenerateMipmaps: (BOOL) shouldMipmap  { _shouldGenerateMipmaps = shouldMipmap; }


#pragma mark Texture parameters

-(GLenum) minifyingFunction {
	if (self.hasMipmap) return _minifyingFunction;
	
	switch (_minifyingFunction) {

		case GL_LINEAR:
		case GL_LINEAR_MIPMAP_NEAREST:
		case GL_LINEAR_MIPMAP_LINEAR:
			return GL_LINEAR;

		case GL_NEAREST:
		case GL_NEAREST_MIPMAP_NEAREST:
		case GL_NEAREST_MIPMAP_LINEAR:
		default:
			return GL_NEAREST;
	}
}

-(void) setMinifyingFunction: (GLenum) minifyingFunction {
	_minifyingFunction = minifyingFunction;
	[self markTextureParametersDirty];
}

-(GLenum) magnifyingFunction { return _magnifyingFunction; }

-(void) setMagnifyingFunction: (GLenum) magnifyingFunction {
	_magnifyingFunction = magnifyingFunction;
	[self markTextureParametersDirty];
}

-(GLenum) horizontalWrappingFunction {
	return self.isPOTWidth ? _horizontalWrappingFunction : GL_CLAMP_TO_EDGE;
}

-(void) setHorizontalWrappingFunction: (GLenum) horizontalWrappingFunction {
	_horizontalWrappingFunction = horizontalWrappingFunction;
	[self markTextureParametersDirty];
}

-(GLenum) verticalWrappingFunction {
	return self.isPOTHeight ? _verticalWrappingFunction : GL_CLAMP_TO_EDGE;
}

-(void) setVerticalWrappingFunction: (GLenum) verticalWrappingFunction {
	_verticalWrappingFunction = verticalWrappingFunction;
	[self markTextureParametersDirty];
}

-(ccTexParams) textureParameters {
	ccTexParams texParams;
	texParams.minFilter = self.minifyingFunction;		// Must use property
	texParams.magFilter = self.magnifyingFunction;
	texParams.wrapS = self.horizontalWrappingFunction;
	texParams.wrapT = self.verticalWrappingFunction;
	return texParams;
}

-(void) setTextureParameters: (ccTexParams) texParams {
	_minifyingFunction = texParams.minFilter;
	_magnifyingFunction = texParams.magFilter;
	_horizontalWrappingFunction = texParams.wrapS;
	_verticalWrappingFunction = texParams.wrapT;
	[self markTextureParametersDirty];
}

-(void) markTextureParametersDirty { _texParametersAreDirty = YES; }

/** Default texture parameters. */
static ccTexParams _defaultTextureParameters = { GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR, GL_REPEAT, GL_REPEAT };

+(ccTexParams) defaultTextureParameters { return _defaultTextureParameters; }

+(void) setDefaultTextureParameters: (ccTexParams) texParams { _defaultTextureParameters = texParams; }


#pragma mark Drawing

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3Assert(_textureID, @"%@ cannot be bound to the GL engine because it has not been loaded.", self);

	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.currentTextureUnitIndex;
	GLenum target = self.textureTarget;

	[gl enableTexturing: YES inTarget: target at: tuIdx];
	[gl bindTexture: _textureID toTarget: target at: tuIdx];
	[self bindTextureParametersWithVisitor: visitor];
	
	LogTrace(@"%@ bound to texture unit %u", self, tuIdx);
}

/** If the texture parameters are dirty, binds them to the GL texture unit state. */
-(void) bindTextureParametersWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( !_texParametersAreDirty ) return;

	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.currentTextureUnitIndex;
	GLenum target = self.textureTarget;
	
	// Use property access to allow adjustments from the raw values
	[gl setTextureMinifyFunc: self.minifyingFunction inTarget: target at: tuIdx];
	[gl setTextureMagnifyFunc: self.magnifyingFunction inTarget: target at: tuIdx];
	[gl setTextureHorizWrapFunc: self.horizontalWrappingFunction inTarget: target at: tuIdx];
	[gl setTextureVertWrapFunc: self.verticalWrappingFunction inTarget: target at: tuIdx];
	
	LogTrace(@"Setting parameters for %@ minifying: %@, magnifying: %@, horiz wrap: %@, vert wrap: %@, ",
			 self.fullDescription,
			 NSStringFromGLEnum(self.minifyingFunction),
			 NSStringFromGLEnum(self.magnifyingFunction),
			 NSStringFromGLEnum(self.horizontalWrappingFunction),
			 NSStringFromGLEnum(self.verticalWrappingFunction));
	
	_texParametersAreDirty = NO;
}


#pragma mark Texture file loading

-(BOOL) loadTarget: (GLenum) target fromFile: (NSString*) aFilePath {
	
	if (!_name) self.name = aFilePath.lastPathComponent;
	
#if LOGGING_REZLOAD
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
#endif
	
	id content = [[self.textureContentClass alloc] initFromFile: aFilePath];
	if ( !content ) {
		LogError(@"%@ could not load texture from file %@", self, CC3EnsureAbsoluteFilePath(aFilePath));
		return NO;
	}
	
	[self bindTextureContent: content toTarget: target];
	
	[content release];		// Could be big, so get rid of it immediately
	
	LogRez(@"%@ loaded from file %@ in %.4f seconds",
		   self, aFilePath, ([NSDate timeIntervalSinceReferenceDate] - startTime));
	return YES;
}

-(BOOL) loadFromFile: (NSString*) aFilePath {
	BOOL wasLoaded = [self loadTarget: self.textureTarget fromFile: aFilePath];
	if (wasLoaded && self.class.shouldGenerateMipmaps) [self generateMipmap];
	return wasLoaded;
}

-(Class) textureContentClass {
	CC3AssertUnimplemented(@"textureContentClass");
	return nil;
}

-(void) flipTextureContentVertically: (CC3Texture2DContent*) texContent {
	[texContent flipVertically];
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_textureID = 0;
		_size = CC3IntSizeMake(0, 0);
		_coverage = CGSizeZero;
		_pixelFormat = kCCTexture2DPixelFormat_Default;
		_hasMipmap = NO;
		_hasPremultipliedAlpha = NO;
		_isUpsideDown = NO;
		_shouldFlipVerticallyOnLoad = self.class.defaultShouldFlipVerticallyOnLoad;
		self.textureParameters = [[self class] defaultTextureParameters];
	}
	return self;
}

-(void) populateFrom: (CC3GLTexture*) another { CC3Assert(NO, @"%@ should not be copied.", self.class); }

-(id) initWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	if ( (self = [self init]) ) {
		self.shouldFlipVerticallyOnLoad = NO;	// Nothing to flip
		_pixelFormat = format;
		_pixelType = type;
	}
	return self;
}

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	if ( (self = [self initWithPixelFormat: format andPixelType: type]) ) {
		[self resizeTo: size];
	}
	return self;
}

/**
 * Determine the correct class in this cluster for loading the specified file. If this is not
 * the correct class, release this instance and instantiate and return an instance of the correct
 * class. If this IS the correct class, perform normal init and load the specified file.
 */
-(id) initFromFile: (NSString*) aFilePath {
	Class texClz = [self.class textureClassForFile: aFilePath];
	if (self.class != texClz) {
		[self release];
		return [[texClz alloc] initFromFile: aFilePath];
	}
	
	if ( (self = [self init]) ) {
		if ( ![self loadFromFile: aFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureFromFile: (NSString*) aFilePath {
	id tex = [self getGLTextureNamed: aFilePath.lastPathComponent];
	if (tex) return tex;
	
	tex = [[self alloc] initFromFile: aFilePath];
	[self addGLTexture: tex];
	[tex release];
	return tex;
}

+(Class) textureClassForFile: (NSString*) aFilePath {
	NSString* lcPath = aFilePath.lowercaseString;
	if ([lcPath hasSuffix: @".pvr"] ||
		[lcPath hasSuffix: @".pvr.gz"] ||
		[lcPath hasSuffix: @".pvr.ccz"] ) {
		return CC3PVRGLTexture.class;
	}
	return CC3GLTexture2D.class;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ is %@flipped vertically and has %@ mipmap",
			[super description], (self.isUpsideDown ? @"" : @"not "),
			(self.hasMipmap ? @"a" : @"no")];
}

// Class variable tracking the most recent tag value assigned for CC3GLTextures.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint _lastAssignedGLTextureTag;

-(GLuint) nextTag { return ++_lastAssignedGLTextureTag; }

+(void) resetTagAllocation { _lastAssignedGLTextureTag = 0; }


#pragma mark GL Texture cache

static NSMutableDictionary* _texturesByName = nil;

+(void) addGLTexture: (CC3GLTexture*) texture {
	if ( !texture ) return;
	CC3Assert(texture.name, @"%@ cannot be added to the texture cache because its name property is nil.", texture);
	if ( !_texturesByName ) _texturesByName = [NSMutableDictionary new];		// retained
	[_texturesByName setObject: texture forKey: texture.name];
}

+(CC3GLTexture*) getGLTextureNamed: (NSString*) name { return [_texturesByName objectForKey: name]; }

+(void) removeGLTexture: (CC3GLTexture*) texture { [self removeGLTextureNamed: texture.name]; }

+(void) removeGLTextureNamed: (NSString*) name { [_texturesByName removeObjectForKey: name]; }

@end


#pragma mark -
#pragma mark CC3GLTexture2D

@implementation CC3GLTexture2D

-(BOOL) isTexture2D { return YES; }

-(GLenum) textureTarget { return GL_TEXTURE_2D; }

-(Class) textureContentClass { return CC3Texture2DContent.class; }

-(void) bindEmptyContent {
	id texContent = [[self.textureContentClass alloc] initWithSize: self.size
													andPixelFormat: self.pixelFormat
													  andPixelType: self.pixelType];
	[self bindTextureContent: texContent toTarget: self.textureTarget];
	[texContent release];
	_hasMipmap = NO;
}


#pragma mark Allocation and initialization

-(id) initWithCGImage: (CGImageRef) cgImg {
	if ( (self = [self init]) ) {
		id texContent = [[self.textureContentClass alloc] initWithCGImage: cgImg];
		[self bindTextureContent: texContent toTarget: self.textureTarget];
		[texContent release];		// Could be big, so get rid of it immediately
		if (self.class.shouldGenerateMipmaps) [self generateMipmap];
	}
	return self;
}

-(id) initWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [super initWithPixelFormat: format andPixelType: type];
}

+(id) textureWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initWithPixelFormat: format andPixelType: type] autorelease];
}

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [super initWithSize: size andPixelFormat: format andPixelType: type];
}

+(id) textureWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initWithSize: size andPixelFormat: format andPixelType: type] autorelease];
}

static BOOL _defaultShouldFlip2DVerticallyOnLoad = YES;

+(BOOL) defaultShouldFlipVerticallyOnLoad { return _defaultShouldFlip2DVerticallyOnLoad; }

+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip {
	_defaultShouldFlip2DVerticallyOnLoad = shouldFlip;
}

@end


#pragma mark -
#pragma mark CC3GLTextureCube

@implementation CC3GLTextureCube

-(BOOL) isTextureCube { return YES; }

-(GLenum) textureTarget { return GL_TEXTURE_CUBE_MAP; }

-(Class) textureContentClass { return CC3Texture2DContent.class; }

/** Default texture parameters for cube maps are different. */
static ccTexParams _defaultCubeMapTextureParameters = { GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };

+(ccTexParams) defaultTextureParameters { return _defaultCubeMapTextureParameters; }

+(void) setDefaultTextureParameters: (ccTexParams) texParams { _defaultCubeMapTextureParameters = texParams; }

-(void) bindEmptyContent {
	id texContent = [[self.textureContentClass alloc] initWithSize: self.size
													andPixelFormat: self.pixelFormat
													  andPixelType: self.pixelType];
	[self bindTextureContent: texContent toTarget: GL_TEXTURE_CUBE_MAP_POSITIVE_X];
	[self bindTextureContent: texContent toTarget: GL_TEXTURE_CUBE_MAP_NEGATIVE_X];
	[self bindTextureContent: texContent toTarget: GL_TEXTURE_CUBE_MAP_POSITIVE_Y];
	[self bindTextureContent: texContent toTarget: GL_TEXTURE_CUBE_MAP_NEGATIVE_Y];
	[self bindTextureContent: texContent toTarget: GL_TEXTURE_CUBE_MAP_POSITIVE_Z];
	[self bindTextureContent: texContent toTarget: GL_TEXTURE_CUBE_MAP_NEGATIVE_Z];
	[texContent release];
	_hasMipmap = NO;
}


#pragma mark Texture file loading

-(BOOL) loadFromFile: (NSString*) aFilePath {
	CC3Assert(NO, @"%@ is used to load six cube textures. It cannot load a single texture.", self);
	return NO;
}

-(BOOL) loadCubeFace: (GLenum) faceTarget fromFile: (NSString*) aFilePath {
	return [self loadTarget: faceTarget fromFile: aFilePath];
}

-(BOOL) loadFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
					 posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
					 posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	BOOL success = YES;

	success &= [self loadCubeFace: GL_TEXTURE_CUBE_MAP_POSITIVE_X fromFile: posXFilePath];
	success &= [self loadCubeFace: GL_TEXTURE_CUBE_MAP_NEGATIVE_X fromFile: negXFilePath];
	success &= [self loadCubeFace: GL_TEXTURE_CUBE_MAP_POSITIVE_Y fromFile: posYFilePath];
	success &= [self loadCubeFace: GL_TEXTURE_CUBE_MAP_NEGATIVE_Y fromFile: negYFilePath];
	success &= [self loadCubeFace: GL_TEXTURE_CUBE_MAP_POSITIVE_Z fromFile: posZFilePath];
	success &= [self loadCubeFace: GL_TEXTURE_CUBE_MAP_NEGATIVE_Z fromFile: negZFilePath];

	if (success && self.class.shouldGenerateMipmaps) [self generateMipmap];
	return success;
}

-(BOOL) loadFromFilePattern: (NSString*) aFilePathPattern {
	
	if (!_name) self.name = ((NSString*)[NSString stringWithFormat: aFilePathPattern, @""]).lastPathComponent;

	return [self loadFromFilesPosX: [NSString stringWithFormat: aFilePathPattern, @"PosX"]
							  negX: [NSString stringWithFormat: aFilePathPattern, @"NegX"]
							  posY: [NSString stringWithFormat: aFilePathPattern, @"PosY"]
							  negY: [NSString stringWithFormat: aFilePathPattern, @"NegY"]
							  posZ: [NSString stringWithFormat: aFilePathPattern, @"PosZ"]
							  negZ: [NSString stringWithFormat: aFilePathPattern, @"NegZ"]];
}

-(void) setCubeFace: (GLenum) faceTarget toCGImage: (CGImageRef) cgImg {
	id texContent = [[self.textureContentClass alloc] initWithCGImage: cgImg];
	[self bindTextureContent: texContent toTarget: faceTarget];
	[texContent release];		// Could be big, so get rid of it immediately
}


#pragma mark Allocation and initialization

-(id) initFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
				   posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
				   posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	
	if ( (self = [self init]) ) {
		if ( ![self loadFromFilesPosX: posXFilePath negX: negXFilePath
								 posY: posYFilePath negY: negYFilePath
								 posZ: posZFilePath negZ: negZFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
					  posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
					  posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {

	id tex = [self getGLTextureNamed: posXFilePath.lastPathComponent];
	if (tex) return tex;
	
	tex = [[self alloc] initFromFilesPosX: posXFilePath negX: negXFilePath
									 posY: posYFilePath negY: negYFilePath
									 posZ: posZFilePath negZ: negZFilePath];
	[self addGLTexture: tex];
	[tex release];
	return tex;
}

-(id) initFromFilePattern: (NSString*) aFilePathPattern {
	if ( (self = [self init]) ) {
		if ( ![self loadFromFilePattern: aFilePathPattern] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureFromFilePattern: (NSString*) aFilePathPattern {
	NSString* texName = ((NSString*)[NSString stringWithFormat: aFilePathPattern, @""]).lastPathComponent;

	id tex = [self getGLTextureNamed: texName];
	if (tex) return tex;
	
	tex = [[self alloc] initFromFilePattern: aFilePathPattern];
	[self addGLTexture: tex];
	[tex release];
	return tex;
}

-(id) initWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [super initWithPixelFormat: format andPixelType: type];
}

+(id) textureWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initWithPixelFormat: format andPixelType: type] autorelease];
}

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [super initWithSize: size andPixelFormat: format andPixelType: type];
}

+(id) textureWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initWithSize: size andPixelFormat: format andPixelType: type] autorelease];
}

static BOOL _defaultShouldFlipCubeVerticallyOnLoad = YES;

+(BOOL) defaultShouldFlipVerticallyOnLoad { return _defaultShouldFlipCubeVerticallyOnLoad; }

+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip {
	_defaultShouldFlipCubeVerticallyOnLoad = shouldFlip;
}

@end


#pragma mark -
#pragma mark CC3Texture2DContent

#if COCOS2D_VERSION < 0x020100
#	define CC2_TEX_SIZE size_
#	define CC2_TEX_WIDTH width_
#	define CC2_TEX_HEIGHT height_
#	define CC2_TEX_FORMAT format_
#	define CC2_TEX_MAXS maxS_
#	define CC2_TEX_MAXT maxT_
#	define CC2_TEX_HAS_PREMULT_ALPHA hasPremultipliedAlpha_
#else
#	define CC2_TEX_SIZE _size
#	define CC2_TEX_WIDTH _width
#	define CC2_TEX_HEIGHT _height
#	define CC2_TEX_FORMAT _format
#	define CC2_TEX_MAXS _maxS
#	define CC2_TEX_MAXT _maxT
#	define CC2_TEX_HAS_PREMULT_ALPHA _hasPremultipliedAlpha
#endif

@implementation CC3Texture2DContent

@synthesize imageData=_imageData, isUpsideDown=_isUpsideDown;
@synthesize pixelGLFormat=_pixelGLFormat, pixelGLType=_pixelGLType;

-(void) dealloc {
	[self deleteImageData];
	[super dealloc];
}

/** Deletes the texture content from main memory. */
-(void) deleteImageData {
	free((GLvoid*)_imageData);
	_imageData = NULL;
}

/** Overridden to do nothing so that texture data is retained until bound to the GL engine. */
-(void) releaseData: (void*) data {}

-(void) flipVertically {
	if ( !_imageData ) return;		// If no data, nothing to flip!
	
	GLuint bytesPerTexel = 0;
	switch(self.pixelFormat) {
		case kCCTexture2DPixelFormat_RGBA8888:
			bytesPerTexel = 4;
			break;
		case kCCTexture2DPixelFormat_RGB565:
		case kCCTexture2DPixelFormat_RGBA4444:
		case kCCTexture2DPixelFormat_RGB5A1:
			bytesPerTexel = 2;
			break;
		case kCCTexture2DPixelFormat_RGB888:
			bytesPerTexel = 3;
			break;
		case kCCTexture2DPixelFormat_AI88:
			bytesPerTexel = 2;
			break;
		case kCCTexture2DPixelFormat_A8:
			bytesPerTexel = 1;
			break;
		default:
			CC3Assert(NO, @"Couldn't flip texture data in unexpected format %u", self.pixelFormat);
	}

	GLuint bytesPerRow = (GLuint)self.pixelsWide * bytesPerTexel;
	GLubyte tmpRow[bytesPerRow];
	
	GLuint rowCnt = (GLuint)CC2_TEX_HEIGHT;
	GLuint lastRowIdx = rowCnt - 1;
	GLuint halfRowCnt = rowCnt / 2;
	for (GLuint rowIdx = 0; rowIdx < halfRowCnt; rowIdx++) {
		GLubyte* lowerRow = (GLubyte*)_imageData + (bytesPerRow * rowIdx);
		GLubyte* upperRow = (GLubyte*)_imageData + (bytesPerRow * (lastRowIdx - rowIdx));
		memcpy(tmpRow, upperRow, bytesPerRow);
		memcpy(upperRow, lowerRow, bytesPerRow);
		memcpy(lowerRow, tmpRow, bytesPerRow);
		LogTrace(@"Swapped %u bytes in %p between row %u at %p and row %u at %p",
				 bytesPerRow, _imageData, rowIdx, lowerRow, (lastRowIdx - rowIdx), upperRow);
	}
	
	_isUpsideDown = !_isUpsideDown;		// Orientation has changed
}


#pragma mark Allocation and Initialization

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	LogTrace(@"Creating empty texture width %u height %u content size %@ format %i data %p",
			 size.width, size.height, NSStringFromCGSize(size), pixelFormat, data);
	if( (self = [super init]) ) {
		CC2_TEX_SIZE = CGSizeFromCC3IntSize(size);
		CC2_TEX_WIDTH = size.width;
		CC2_TEX_HEIGHT = size.height;
		CC2_TEX_FORMAT = kCCTexture2DPixelFormat_Default;	// Unused
		CC2_TEX_MAXS = 1.0f;
		CC2_TEX_MAXT = 1.0f;
		CC2_TEX_HAS_PREMULT_ALPHA = NO;
		_imageData = NULL;
		_pixelGLFormat = format;
		_pixelGLType = type;
		_isUpsideDown = NO;		// Empty texture is not upside down!
	}
	return self;
}

/** Overridden to set content parameters, but postpone loading the content into the GL engine. */
-(id) initWithData: (const GLvoid*) data
	   pixelFormat: (CCTexture2DPixelFormat) pixelFormat
		pixelsWide: (NSUInteger) width
		pixelsHigh: (NSUInteger) height
	   contentSize: (CGSize) size {

	LogTrace(@"Loading texture width %u height %u content size %@ format %i data %p",
			 width, height, NSStringFromCGSize(size), pixelFormat, data);
	if( (self = [super init]) ) {
		CC2_TEX_SIZE = size;
		CC2_TEX_WIDTH = width;
		CC2_TEX_HEIGHT = height;
		CC2_TEX_FORMAT = pixelFormat;
		CC2_TEX_MAXS = width ? (size.width / (float)width) : 1.0f;
		CC2_TEX_MAXT = height ? (size.height / (float)height) : 1.0f;
		CC2_TEX_HAS_PREMULT_ALPHA = NO;
		_imageData = data;
		_isUpsideDown = YES;			// Assume upside down
		[self updateFromPixelFormat];
	}
	return self;
}

-(void) updateFromPixelFormat {
	switch(self.pixelFormat) {
		case kCCTexture2DPixelFormat_RGBA8888:
			_pixelGLFormat = GL_RGBA;
			_pixelGLType = GL_UNSIGNED_BYTE;
			break;
		case kCCTexture2DPixelFormat_RGBA4444:
			_pixelGLFormat = GL_RGBA;
			_pixelGLType = GL_UNSIGNED_SHORT_4_4_4_4;
			break;
		case kCCTexture2DPixelFormat_RGB5A1:
			_pixelGLFormat = GL_RGBA;
			_pixelGLType = GL_UNSIGNED_SHORT_5_5_5_1;
			break;
		case kCCTexture2DPixelFormat_RGB565:
			_pixelGLFormat = GL_RGB;
			_pixelGLType = GL_UNSIGNED_SHORT_5_6_5;
			break;
		case kCCTexture2DPixelFormat_RGB888:
			_pixelGLFormat = GL_RGB;
			_pixelGLType = GL_UNSIGNED_BYTE;
			break;
		case kCCTexture2DPixelFormat_AI88:
			_pixelGLFormat = GL_LUMINANCE_ALPHA;
			_pixelGLType = GL_UNSIGNED_BYTE;
			break;
		case kCCTexture2DPixelFormat_A8:
			_pixelGLFormat = GL_ALPHA;
			_pixelGLType = GL_UNSIGNED_BYTE;
			break;
		default:
			_pixelGLFormat = GL_ZERO;
			_pixelGLType = GL_ZERO;
			CC3Assert(NO, @"Couldn't bind texture data in unexpected format %u", self.pixelFormat);
	}
}

-(id) initWithCGImage: (CGImageRef) cgImg {
#if CC3_IOS

#if CC3_CC2_2
	return [self initWithCGImage: cgImg resolutionType: kCCResolutionUnknown];
#endif	// CC3_CC2_2

#if CC3_CC2_1
	UIImage* uiImg = [UIImage imageWithCGImage: cgImg];
	return [self initWithImage: uiImg resolutionType: kCCResolutionUnknown];
#endif	// CC3_CC2_1

#endif	// CC_IOS

#if CC3_OSX

#if CC3_CC2_2
#if (COCOS2D_VERSION < 0x020100)
	return [super initWithCGImage: cgImg];
#else
	return [self initWithCGImage: cgImg resolutionType: kCCResolutionUnknown];
#endif	// (COCOS2D_VERSION < 0x020100)
#endif	// CC3_CC2_2

#if CC3_CC2_1
	return [self initWithImage: cgImg];
#endif	// CC3_CC2_1

#endif	// CC_OSX

}

-(id) initFromFile: (NSString*) aFilePath {
#if CC3_IOS
	UIImage* uiImg = [UIImage imageWithContentsOfFile: CC3EnsureAbsoluteFilePath(aFilePath)];
	
#if CC3_CC2_2
	return [self initWithCGImage: uiImg.CGImage];
#endif	// CC3_CC2_2
	
#if CC3_CC2_1
	return [self initWithImage: uiImg resolutionType: kCCResolutionUnknown];
#endif	// CC3_CC2_1
	
#endif	// CC_IOS
	
#if CC3_OSX
	NSData* imgData = [NSData dataWithContentsOfFile: CC3EnsureAbsoluteFilePath(aFilePath)];
	NSBitmapImageRep* image = [NSBitmapImageRep imageRepWithData: imgData];
	return [self initWithCGImage: image.CGImage];
#endif	// CC_OSX
}

@end
