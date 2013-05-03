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
@synthesize isFlippedVertically=_isFlippedVertically, hasPremultipliedAlpha=_hasPremultipliedAlpha;

-(void) dealloc {
	[self deleteGLTexture];
	[super dealloc];
}

-(void) ensureGLTexture { if (!_textureID) _textureID = CC3OpenGL.sharedGL.generateTextureID; }

-(void) deleteGLTexture {
	[CC3OpenGL.sharedGL deleteTextureID: _textureID];
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

#pragma mark Binding content

-(void) bindTextureContent: (CC3Texture2DContent*) texContent toTarget: (GLenum) target {

	_size = CC3IntSizeMake((GLint)texContent.pixelsWide, (GLint)texContent.pixelsHigh);
	_coverage = CGSizeMake(texContent.maxS, texContent.maxT);
	_hasPremultipliedAlpha = texContent.hasPremultipliedAlpha;

	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLenum texelFormat = GL_ZERO;
	GLenum texelType = GL_ZERO;
	GLuint byteAlignment = 1;
	
	switch(texContent.pixelFormat) {
		case kCCTexture2DPixelFormat_RGBA8888:
			texelFormat = GL_RGBA;
			texelType = GL_UNSIGNED_BYTE;
			byteAlignment = 4;
			break;
		case kCCTexture2DPixelFormat_RGBA4444:
			texelFormat = GL_RGBA;
			texelType = GL_UNSIGNED_SHORT_4_4_4_4;
			byteAlignment = CC3IntIsEven(_size.width) ? 4 : 2;
			break;
		case kCCTexture2DPixelFormat_RGB5A1:
			texelFormat = GL_RGBA;
			texelType = GL_UNSIGNED_SHORT_5_5_5_1;
			byteAlignment = CC3IntIsEven(_size.width) ? 4 : 2;
			break;
		case kCCTexture2DPixelFormat_RGB565:
			texelFormat = GL_RGB;
			texelType = GL_UNSIGNED_SHORT_5_6_5;
			byteAlignment = CC3IntIsEven(_size.width) ? 4 : 2;
			break;
		case kCCTexture2DPixelFormat_RGB888:
			texelFormat = GL_RGB;
			texelType = GL_UNSIGNED_BYTE;
			byteAlignment = CC3IntIsEven(_size.width) ? 2 : 1;
			break;
		case kCCTexture2DPixelFormat_AI88:
			texelFormat = GL_LUMINANCE_ALPHA;
			texelType = GL_UNSIGNED_BYTE;
			byteAlignment = CC3IntIsEven(_size.width) ? 4 : 2;
			break;
		case kCCTexture2DPixelFormat_A8:
			texelFormat = GL_ALPHA;
			texelType = GL_UNSIGNED_BYTE;
			byteAlignment = CC3IntIsEven(_size.width) ? 2 : 1;
			break;
		default:
			CC3Assert(NO, @"Couldn't bind texture data in unexpected format %u", texContent.pixelFormat);
	}
	
	GLuint tuIdx = 0;		// Choose the texture unit to work in
	[gl bindTexture: _textureID toTarget: self.textureTarget at: tuIdx];

	[gl loadTexureImage: texContent.imageData
			 intoTarget: target
			   withSize: _size
			 withFormat: texelFormat
			   withType: texelType
	  withByteAlignment: byteAlignment
					 at: tuIdx];
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
	return [self loadTarget: self.textureTarget fromFile: aFilePath];
}

-(Class) textureContentClass {
	CC3AssertUnimplemented(@"textureContentClass");
	return nil;
}

-(void) flipTextureContentVertically: (CC3Texture2DContent*) texContent {
	[texContent flipVertically];
	_isFlippedVertically = NO;
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_textureID = 0;
		_size = CC3IntSizeMake(0, 0);
		_coverage = CGSizeZero;
		_hasMipmap = NO;
		_isFlippedVertically = YES;		// All but PVR textures start out flipped
		_hasPremultipliedAlpha = NO;
		self.textureParameters = [[self class] defaultTextureParameters];
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

-(void) populateFrom: (CC3GLTexture*) another { CC3Assert(NO, @"%@ should not be copied.", self.class); }

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ is %@flipped vertically and has %@ mipmap",
			[super description], (self.isFlippedVertically ? @"" : @"not "),
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

-(void) bindTextureContent: (CC3Texture2DContent*) texContent toTarget: (GLenum) target {
	if (self.shouldFlipVerticallyOnLoad) [self flipTextureContentVertically: texContent];
	[self ensureGLTexture];
	[super bindTextureContent: texContent toTarget: target];
	if (self.class.shouldGenerateMipmaps) [self generateMipmap];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_shouldFlipVerticallyOnLoad = self.class.defaultShouldFlipVerticallyOnLoad;
	}
	return self;
}

-(BOOL) shouldFlipVerticallyOnLoad { return _shouldFlipVerticallyOnLoad; }

-(void) setShouldFlipVerticallyOnLoad:(BOOL)shouldFlipVerticallyOnLoad {
	_shouldFlipVerticallyOnLoad = shouldFlipVerticallyOnLoad;
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

-(void) bindTextureContent: (CC3Texture2DContent*) texContent toTarget: (GLenum) target {
	if (self.shouldFlipVerticallyOnLoad) [self flipTextureContentVertically: texContent];
	[self ensureGLTexture];
	[super bindTextureContent: texContent toTarget: target];
}

/** Default texture parameters for cube maps are different. */
static ccTexParams _defaultCubeMapTextureParameters = { GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };

+(ccTexParams) defaultTextureParameters { return _defaultCubeMapTextureParameters; }

+(void) setDefaultTextureParameters: (ccTexParams) texParams { _defaultCubeMapTextureParameters = texParams; }


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

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_shouldFlipVerticallyOnLoad = self.class.defaultShouldFlipVerticallyOnLoad;
	}
	return self;
}

-(BOOL) shouldFlipVerticallyOnLoad { return _shouldFlipVerticallyOnLoad; }

-(void) setShouldFlipVerticallyOnLoad:(BOOL)shouldFlipVerticallyOnLoad {
	_shouldFlipVerticallyOnLoad = shouldFlipVerticallyOnLoad;
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

@synthesize imageData=_imageData;

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
}


#pragma mark Allocation and Initialization

/** Overridden to set content parameters, but postpone loading the content into the GL engine. */
-(id) initWithData: (const GLvoid*) data
	   pixelFormat: (CCTexture2DPixelFormat) pixelFormat
		pixelsWide: (NSUInteger) width
		pixelsHigh: (NSUInteger) height
	   contentSize: (CGSize) size {

	LogTrace(@"Loading texture width %u height %u content size %@ format %i data %p",
			 width, height, NSStringFromCGSize(size), pixelFormat, data);
	if((self = [super init])) {
		_imageData = data;
		CC2_TEX_SIZE = size;
		CC2_TEX_WIDTH = width;
		CC2_TEX_HEIGHT = height;
		CC2_TEX_FORMAT = pixelFormat;
		CC2_TEX_MAXS = size.width / (float)width;
		CC2_TEX_MAXT = size.height / (float)height;
		CC2_TEX_HAS_PREMULT_ALPHA = NO;		// will be set by invoking method after
	}
	return self;
}

-(id) initFromFile: (NSString*) aFilePath {
#if CC3_IOS
	UIImage* uiImg = [UIImage imageWithContentsOfFile: CC3EnsureAbsoluteFilePath(aFilePath)];

#if CC3_CC2_2
	return [self initWithCGImage: uiImg.CGImage resolutionType: kCCResolutionUnknown];
#endif	// CC3_CC2_2

#if CC3_CC2_1
	return [self initWithImage: uiImg resolutionType: kCCResolutionUnknown];
#endif	// CC3_CC2_1

#endif	// CC_IOS

#if CC3_OSX
	NSData *imgData = [NSData dataWithContentsOfFile: CC3EnsureAbsoluteFilePath(aFilePath)];
	NSBitmapImageRep* image = [NSBitmapImageRep imageRepWithData: imgData];
	CGImageRef cgImg = image.CGImage;

#if CC3_CC2_2
#if (COCOS2D_VERSION >= 0x020100)
	return [self initWithCGImage: cgImg resolutionType: kCCResolutionUnknown];
#else
	return [self initWithCGImage: cgImg];
#endif	// (COCOS2D_VERSION >= 0x020100)
#endif	// CC3_CC2_2

#if CC3_CC2_1
	return [self initWithImage: cgImg];
#endif	// CC3_CC2_1

#endif	// CC_OSX

}

@end
