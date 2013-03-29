/*
 * CC3Texture.m
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
 * See header file CC3Texture.h for full API documentation.
 */

#import "CC3Texture.h"
#import "CC3CC2Extensions.h"
#import "CCTextureCache.h"
#import "CCFileUtils.h"
#import "CCTexturePVR.h"


#pragma mark -
#pragma mark CC3Texture 


@implementation CC3Texture

@synthesize textureUnit=_textureUnit;

-(void) dealloc {
	[_texture release];
	[_textureUnit release];
	[super dealloc];
}

-(CCTexture2D*) texture { return _texture; }

-(void) setTexture:(CCTexture2D *)texture {
	if (texture == _texture) return;
	[_texture release];
	_texture = [texture retain];
	[self markTextureParametersDirty];		// params depend on texture POT/NPOT
}

-(CGSize) mapSize { return _texture ? CGSizeMake(_texture.maxS, _texture.maxT) : CGSizeZero; }

-(CC3Vector) lightDirection { return _textureUnit ? _textureUnit.lightDirection : kCC3VectorZero; }

-(void) setLightDirection: (CC3Vector) aDirection { _textureUnit.lightDirection = aDirection; }

-(BOOL) isBumpMap { return (_textureUnit && _textureUnit.isBumpMap); }

-(BOOL) hasPremultipliedAlpha { return (_texture && _texture.hasPremultipliedAlpha); }

-(BOOL) hasMipmap { return (_texture && _texture.cc3HasMipmap); }

-(BOOL) isFlippedVertically { return (_texture && _texture.cc3IsFlippedVertically); }

/** Indicates whether Mipmaps should automatically be generated for any loaded textures. */
static BOOL _shouldGenerateMipmaps = YES;

+(BOOL) shouldGenerateMipmaps { return _shouldGenerateMipmaps; }

+(void) setShouldGenerateMipmaps: (BOOL) shouldMipmap  { _shouldGenerateMipmaps = shouldMipmap; }

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
	return _texture.cc3IsNPOT ? GL_CLAMP_TO_EDGE : _horizontalWrappingFunction;
}

-(void) setHorizontalWrappingFunction: (GLenum) horizontalWrappingFunction {
	_horizontalWrappingFunction = horizontalWrappingFunction;
	[self markTextureParametersDirty];
}

-(GLenum) verticalWrappingFunction {
	return _texture.cc3IsNPOT ? GL_CLAMP_TO_EDGE : _verticalWrappingFunction;
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


#pragma mark Allocation and Initialization

-(id) initFromFile: (NSString*) aFilePath { return [self initWithName: nil fromFile: aFilePath]; }

+(id) textureFromFile: (NSString*) aFilePath { return [[[self alloc] initFromFile: aFilePath] autorelease]; }

-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath {
	return [self initWithTag: aTag withName: nil fromFile: aFilePath];
}

+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath {
	return [[[self alloc] initWithTag: aTag fromFile: aFilePath] autorelease];
}

-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilePath {
	return [self initWithTag: [self nextTag] withName: aName fromFile: aFilePath];
}

+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFilePath {
	return [[[self alloc] initWithName: aName fromFile: aFilePath] autorelease];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFilePath {
	if ( (self = [self initWithTag: aTag withName: aName]) ) {
		if ( ![self loadTextureFile: aFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFilePath {
	return [[[self alloc] initWithTag: aTag withName: aName fromFile: aFilePath] autorelease];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_texture = nil;
		_textureUnit = nil;
		self.textureParameters = [[self class] defaultTextureParameters];
	}
	return self;
}

-(BOOL) loadTextureFile: (NSString*) aFilePath {
	
	// Ensure the path is absolute, converting it if needed.
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	
	if (!_name) self.name = absFilePath.lastPathComponent;
	
#if LOGGING_LEVEL_TRACE
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
#endif
	
	CCTexture2D.instantiationClass = CC3Texture2D.class;
	self.texture = [[CCTextureCache sharedTextureCache] addImage: absFilePath];
	CCTexture2D.instantiationClass = nil;
	
	if (_shouldGenerateMipmaps) [self generateMipmap];
	if (_texture) {
		LogTrace(@"%@ loaded texture from file %@ in %.4f seconds",
				 self, aFilePath, ([NSDate timeIntervalSinceReferenceDate] - startTime));
		return YES;
	} else {
		LogError(@"%@ could not load texture from file %@", self, absFilePath);
		return NO;
	}
}

-(void) generateMipmap { [_texture cc3GenerateMipmapIfNeeded]; }

// Protected methods for copying
-(GLenum) rawMinifyingFunction { return _minifyingFunction; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Texture*) another {
	[super populateFrom: another];
	
	// The 2D texture is not copied, but instead retained by reference, and shared between instances.
	[_texture release];
	_texture = [another.texture retain];				// retained

	[_textureUnit release];
	_textureUnit = [another.textureUnit copy];		// retained
	
	_minifyingFunction = another.rawMinifyingFunction;	// Bypass property
	_magnifyingFunction = another.magnifyingFunction;
	_horizontalWrappingFunction = another.horizontalWrappingFunction;
	_verticalWrappingFunction = another.verticalWrappingFunction;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ is %@flipped vertically and has %@mipmaps",
			[super description], (self.isFlippedVertically ? @"" : @"not "),
			(self.hasMipmap ? @"" : @"no ")]; 
}

#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_texture) {
		[self bindGLWithVisitor: visitor];
		visitor.textureUnit += 1;
	}
}

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.textureUnit;
	[gl enableTexture2D: YES at: tuIdx];
	[gl bindTexture: _texture.name at: tuIdx];

	[self bindTextureParametersWithVisitor: visitor];
	[self bindTextureEnvironmentWithVisitor: visitor];
	
	LogTrace(@"%@ bound to texture unit %u", self, tuIdx);
}

/** If the texture parameters are dirty, binds them to the GL texture unit state. */
-(void) bindTextureParametersWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( !_texParametersAreDirty ) return;

	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.textureUnit;
	
	// Use property access to allow adjustments from the raw values
	[gl setTextureMinifyFunc: self.minifyingFunction at: tuIdx];
	[gl setTextureMagnifyFunc: self.magnifyingFunction at: tuIdx];
	[gl setTextureHorizWrapFunc: self.horizontalWrappingFunction at: tuIdx];
	[gl setTextureVertWrapFunc: self.verticalWrappingFunction at: tuIdx];
	
	LogTrace(@"Setting parameters for %@ minifying: %@, magnifying: %@, horiz wrap: %@, vert wrap: %@, ",
			 self.fullDescription,
			 NSStringFromGLEnum(self.minifyingFunction),
			 NSStringFromGLEnum(self.magnifyingFunction),
			 NSStringFromGLEnum(self.horizontalWrappingFunction),
			 NSStringFromGLEnum(self.verticalWrappingFunction));
	
	_texParametersAreDirty = NO;
}

/** Binds the texture unit environment to the specified GL texture unit state. */
-(void) bindTextureEnvironmentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_textureUnit)
		[_textureUnit bindWithVisitor: visitor];
	else
		[CC3TextureUnit bindDefaultWithVisitor: visitor];
}

+(void) unbindRemainingFrom: (GLuint) texUnit withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	GLuint maxTexUnits = gl.maxNumberOfTextureUnits;
	for (GLuint tuIdx = texUnit; tuIdx < maxTexUnits; tuIdx++) [gl enableTexture2D: NO at: tuIdx];
}

+(void) unbindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self unbindRemainingFrom: 0 withVisitor: visitor];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Textures.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedTextureTag;

-(GLuint) nextTag { return ++lastAssignedTextureTag; }

+(void) resetTagAllocation { lastAssignedTextureTag = 0; }

@end


#pragma mark CCTexture2D extension category

#if COCOS2D_VERSION < 0x020100
#	define CC2_HAS_MIPMAPS hasMipmaps_
#else
#	define CC2_HAS_MIPMAPS _hasMipmaps
#endif

@implementation CCTexture2D (CC3Texture)

#pragma mark Allocation and initialization

/** The CC3Texture2D cluster class to be instantiated when the alloc method is invoked. */
static Class _instantiationClass = nil;

+(Class) instantiationClass { return _instantiationClass; }

+(void) setInstantiationClass: (Class) aClass  {
	CC3Assert(aClass == nil || [aClass isSubclassOfClass: [CCTexture2D class]],
			  @"%@ is not a subclass of CCTexture2D.", aClass);
	_instantiationClass = aClass;
}

/** Invoke the superclass alloc method, bypassing the alloc method of this class. */
+(id) allocBase { return [super alloc]; }

/** 
 * If the instantiationClass property is not nil, allocates an instance of that
 * subclass, so that additional state and behaviour can be added to 2D textures,
 * without having to change where they are instantiated.
 *
 * If the instantiationClass property is nil, allocates an instance of this class.
 */
+(id) alloc { return _instantiationClass ? [_instantiationClass alloc] : [self allocBase]; }

-(BOOL) cc3GenerateMipmapIfNeeded {
	if (self.cc3HasMipmap || self.cc3IsNPOT) return NO;
	
	[self generateMipmap];
	self.cc3HasMipmap = YES;
	return YES;
}

#pragma mark Additional CCTexture2D state to support cocos3d

/** Additional CCTexture2D state. */
typedef struct {
	BOOL hasMipmap;				/**< Indicates whether CCTextrure2D has a mipmap. */
	BOOL isFlippedVertically;	/**< Indicates whether CCTextrure2D is flipped vertically. */
} CC3CCTexture2DState;

/** Dynamic array tracks additional state for each CCTexture2D instance. */
static CC3CCTexture2DState* cc3State = NULL;
static uint cc3StateSize = 0;
static CC3CCTexture2DState kCC3InitialCCTexture2DState = { NO, YES };

/**
 * Returns a pointer to the CC3CCTexture2DState structure that is tracking the
 * additional cocos3d state for the CCTexture2D with the specified GL texture name.
 * 
 * Ensures that enough memory has been allocated to track state at the specified
 * index. If additional memory is required, enough to track 100 sequentially-assigned
 * texture names is allocated. The newly allocated memory is zeroed, and then the
 * existing tracking data is copied into the new space.
 *
 * This scheme depends on the fact that GL texture names (integers) are sequentially
 * assigned by the GL engine, so that the value of any texture name is proportional
 * to the number of textures that have been loaded. This is convenient because it
 * allows for the state to be tracked in a simple array of structures, which makes
 * for fast look-up. A disorganized allocation of texture names would mean that some
 * sort of expensive hash lookup would be required.
 */
+(CC3CCTexture2DState*) cc3StateAt: (GLuint) glTexName {
	if (glTexName >= cc3StateSize) {
		GLuint newSize = glTexName + 100;
		CC3CCTexture2DState* newState = realloc(cc3State, (newSize * sizeof(CC3CCTexture2DState)));
		if (newState) {
			// Set the initial state for the new state markers
			for (uint i = cc3StateSize; i < newSize; i++) {
				newState[i] = kCC3InitialCCTexture2DState;
			}
			cc3State = newState;
			cc3StateSize = newSize;
		} else {
			LogError(@"%@ could not reallocate memory for CC3CCTexture2DState", self);
			return (cc3State + cc3StateSize - 1);		// Return pointer to the last marker
		}
	}
	return (cc3State + glTexName);
}

/** Returns whether the specified GL texture name has been marked as containing a mipmap. */
+(BOOL) cc3HasMipmap: (GLuint) glTexName {
	return [self cc3StateAt: glTexName]->hasMipmap;
}

/** Sets whether the specified GL texture name has been marked as containing a mipmap. */
+(void) setCc3HasMipmap: (GLuint) glTexName to: (BOOL) hasMm {
	[self cc3StateAt: glTexName]->hasMipmap = hasMm;
}

/** Returns whether the specified GL texture name is vertically flipped. */
+(BOOL) cc3IsFlippedVertically: (GLuint) glTexName {
	return [self cc3StateAt: glTexName]->isFlippedVertically;
}

/** Sets whether the specified GL texture name is vertically flipped. */
+(void) setCc3IsFlippedVertically: (GLuint) glTexName to: (BOOL) isFlipped {
	[self cc3StateAt: glTexName]->isFlippedVertically = isFlipped;
}

-(BOOL) cc3HasMipmap {
#if CC3_CC2_1
	return [self.class cc3HasMipmap: self.name];
#else
	return CC2_HAS_MIPMAPS;
#endif
}

-(void) setCc3HasMipmap: (BOOL) hasMm {
#if CC3_CC2_1
	[self.class setCc3HasMipmap: self.name to: hasMm];
#else
	CC2_HAS_MIPMAPS = hasMm;
#endif
}

-(BOOL) cc3IsFlippedVertically { return [self.class cc3IsFlippedVertically: self.name]; }

-(void) setCc3IsFlippedVertically: (BOOL) isFlipped {
	[self.class setCc3IsFlippedVertically: self.name to: isFlipped];
}

-(BOOL) cc3WidthIsNPOT { return (self.pixelsWide != ccNextPOT(self.pixelsWide)); }

-(BOOL) cc3HeightIsNPOT { return (self.pixelsHigh != ccNextPOT(self.pixelsHigh)); }

-(BOOL) cc3IsNPOT { return self.cc3WidthIsNPOT || self.cc3HeightIsNPOT; }

@end


#pragma mark CCTexturePVR extension category

/** Extension to support testing for mipmaps. */
@interface CCTexturePVR (CC3Texture)
/** Returns whether this instance contains mipmaps. */
-(BOOL) cc3HasMipmap;
@end

@implementation CCTexturePVR (CC3Texture)
-(BOOL) cc3HasMipmap {
#if CC3_CC2_1
	return (numberOfMipmaps_ > 1);
#else
	return (self.numberOfMipmaps > 1);
#endif
}
@end


#pragma mark CC3Texture2D

@implementation CC3Texture2D

/** Overridden to clear the tracking of the mipmap from the global status array. */
-(void) dealloc {
	self.cc3HasMipmap = NO;					// Set global marker back to default
	self.cc3IsFlippedVertically = YES;		// Set global marker back to default
	[super dealloc];
}

/** Bypass the superclass alloc, which can redirect back here, causing an infinite loop. */
+(id) alloc { return [self allocBase]; }

/**
 * Overridden to mark whether the texture contains a mipmap and is flipped vertically.
 * Since this method is monolithic, this is simply a cut-and-paste of the superclass
 * method, with the extra functionality added.
 */
#if COCOS2D_VERSION < 0x010100		// cocos2d 1.0
-(id) initWithPVRFile: (NSString*) file {
	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:file];
		if( pvr ) {
			pvr.retainName = YES;	// don't dealloc texture on release
			
			name_ = pvr.name;	// texture id
			maxS_ = 1;			// only POT texture are supported
			maxT_ = 1;
			width_ = pvr.width;
			height_ = pvr.height;
			size_ = CGSizeMake(width_, height_);
			hasPremultipliedAlpha_ = [[self class] PVRImagesHavePremultipliedAlpha];
			format_ = pvr.format;
			
			self.cc3HasMipmap = pvr.cc3HasMipmap;		// Added to support cocos3d texture loading
			self.cc3IsFlippedVertically = NO;		// Added to support cocos3d texture loading
			
			[pvr release];
			
			[self setAntiAliasTexParameters];
		} else {
			
			CCLOG(@"cocos2d: Couldn't load PVR image: %@", file);
			[self release];
			return nil;
		}
	}
	return self;
}

#elif CC3_CC2_1	// cocos2d 1.1+
-(id) initWithPVRFile: (NSString*) relPath {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	ccResolutionType resolution;
	NSString *fullpath = [CCFileUtils.sharedFileUtils fullPathFromRelativePath:relPath resolutionType:&resolution];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:relPath];
#endif 
	
	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:fullpath];
		if( pvr ) {
			pvr.retainName = YES;	// don't dealloc texture on release
			
			name_ = pvr.name;	// texture id
			maxS_ = 1;			// only POT texture are supported
			maxT_ = 1;
			width_ = pvr.width;
			height_ = pvr.height;
			size_ = CGSizeMake(width_, height_);
			hasPremultipliedAlpha_ = PVRHaveAlphaPremultiplied_;
			format_ = pvr.format;
			
			self.cc3HasMipmap = pvr.cc3HasMipmap;	// Added to support cocos3d texture loading
			self.cc3IsFlippedVertically = NO;		// Added to support cocos3d texture loading
			
			[pvr release];
			
			[self setAntiAliasTexParameters];
		} else {
			
			CCLOG(@"cocos2d: Couldn't load PVR image: %@", relPath);
			[self release];
			return nil;
		}
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		resolutionType_ = resolution;
#endif
	}
	return self;
}
#else	// cocos2d 2.x...
-(id) initWithPVRFile: (NSString*) relPath {
	if( (self = [super initWithPVRFile: relPath]) ) {
		self.cc3IsFlippedVertically = NO;
	}
	return self;
}
#endif

// By default PVR images are treated as if they don't have the alpha channel premultiplied
static BOOL PVRHaveAlphaPremultiplied_ = NO;

+(BOOL) PVRImagesHavePremultipliedAlpha { return PVRHaveAlphaPremultiplied_; }

+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied {
	PVRHaveAlphaPremultiplied_ = haveAlphaPremultiplied;
}

@end
