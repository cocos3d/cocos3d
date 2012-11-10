/*
 * CC3Texture.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CCTextureCache.h"
#import "CC3OpenGLES11Engine.h"
#import "CCFileUtils.h"
#import "CCTexturePVR.h"
#import "cocos2d.h"


#pragma mark -
#pragma mark CC3Texture 

@interface CC3Texture (TemplateMethods)
-(void) markTextureParametersDirty;
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindTextureParametersTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit
					withVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindTextureEnvironmentTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit
					 withVisitor: (CC3NodeDrawingVisitor*) visitor;
@end


@implementation CC3Texture

@synthesize texture=_texture, textureUnit=_textureUnit;

-(void) dealloc {
	[_texture release];
	[_textureUnit release];
	[super dealloc];
}

-(CGSize) mapSize { return _texture ? CGSizeMake(_texture.maxS, _texture.maxT) : CGSizeZero; }

-(CC3Vector) lightDirection { return _textureUnit ? _textureUnit.lightDirection : kCC3VectorZero; }

-(void) setLightDirection: (CC3Vector) aDirection { _textureUnit.lightDirection = aDirection; }

-(BOOL) isBumpMap { return (_textureUnit && _textureUnit.isBumpMap); }

-(BOOL) hasPremultipliedAlpha { return (_texture && _texture.hasPremultipliedAlpha); }

-(BOOL) hasMipmap { return (_texture && _texture.hasMipmap); }

-(BOOL) isFlippedVertically { return (_texture && _texture.isFlippedVertically); }

/** Indicates whether Mipmaps should automatically be generated for any loaded textures. */
static BOOL shouldGenerateMipmaps = YES;

+(BOOL) shouldGenerateMipmaps { return shouldGenerateMipmaps; }

+(void) setShouldGenerateMipmaps: (BOOL) shouldMipmap  { shouldGenerateMipmaps = shouldMipmap; }

-(GLenum) minifyingFunction {
	if (self.hasMipmap) return _minifyingFunction;
	
	switch (_minifyingFunction) {

		case GL_LINEAR:
		case GL_LINEAR_MIPMAP_NEAREST:
		case GL_LINEAR_MIPMAP_LINEAR:
			return GL_LINEAR;

		default:
		case GL_NEAREST:
		case GL_NEAREST_MIPMAP_NEAREST:
		case GL_NEAREST_MIPMAP_LINEAR:
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

-(GLenum) horizontalWrappingFunction { return _horizontalWrappingFunction; }

-(void) setHorizontalWrappingFunction: (GLenum) horizontalWrappingFunction {
	_horizontalWrappingFunction = horizontalWrappingFunction;
	[self markTextureParametersDirty];
}

-(GLenum) verticalWrappingFunction { return _verticalWrappingFunction; }

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
static ccTexParams defaultTextureParameters = { GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR, GL_REPEAT, GL_REPEAT };

+(ccTexParams) defaultTextureParameters { return defaultTextureParameters; }

+(void) setDefaultTextureParameters: (ccTexParams) texParams { defaultTextureParameters = texParams; }


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
	
	if (!name) self.name = absFilePath.lastPathComponent;
	
#if LOGGING_LEVEL_TRACE
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
#endif
	
	[CCTexture2D setInstantiationClass: [CC3Texture2D class]];
	self.texture = [[CCTextureCache sharedTextureCache] addImage: absFilePath];
	[CCTexture2D setInstantiationClass: nil];
	
	if (shouldGenerateMipmaps) [self generateMipmap];
	if (_texture) {
		LogTrace(@"%@ loaded texture from file %@ in %.4f seconds",
				 self, aFilePath, ([NSDate timeIntervalSinceReferenceDate] - startTime));
		return YES;
	} else {
		LogError(@"%@ could not load texture from file %@", self, absFilePath);
		return NO;
	}
}

-(void) generateMipmap { [_texture generateMipmapIfNeeded]; }

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
	CC3OpenGLES11TextureUnit* gles11TexUnit = [[CC3OpenGLES11Engine engine].textures textureUnitAt: visitor.textureUnit];
	[gles11TexUnit.texture2D enable];
	gles11TexUnit.textureBinding.value = _texture.name;
	[self bindTextureParametersTo: gles11TexUnit withVisitor: visitor];
	[self bindTextureEnvironmentTo: gles11TexUnit withVisitor: visitor];
	
	LogTrace(@"%@ bound to %@", self, gles11TexUnit);
}

/** If the texture parameters are dirty, binds them to the GL texture unit state. */
-(void) bindTextureParametersTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit
					withVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( !_texParametersAreDirty ) return;

	LogTrace(@"Setting parameters for %@ minifying: %@, magnifying: %@, horiz wrap: %@, vert wrap: %@, ",
			 self.fullDescription,
			 NSStringFromGLEnum(self.minifyingFunction),
			 NSStringFromGLEnum(self.magnifyingFunction),
			 NSStringFromGLEnum(self.horizontalWrappingFunction),
			 NSStringFromGLEnum(self.verticalWrappingFunction));
	
	// Use property access to allow adjustments from the raw values
	gles11TexUnit.minifyingFunction.value = self.minifyingFunction;
	gles11TexUnit.magnifyingFunction.value = self.magnifyingFunction;
	gles11TexUnit.horizontalWrappingFunction.value = self.horizontalWrappingFunction;
	gles11TexUnit.verticalWrappingFunction.value = self.verticalWrappingFunction;

	_texParametersAreDirty = NO;
}

/** Binds the texture unit environment to the specified GL texture unit state. */
-(void) bindTextureEnvironmentTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit
					 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_textureUnit) {
		[_textureUnit bindTo: gles11TexUnit withVisitor: visitor];
	} else {
		[CC3TextureUnit bindDefaultTo: gles11TexUnit];
	}
}

+(void) unbind: (GLuint) texUnit {
	[[[CC3OpenGLES11Engine engine].textures textureUnitAt: texUnit].texture2D disable];
}

+(void) unbindRemainingFrom: (GLuint)texUnit {
	GLuint maxTexUnits = [CC3OpenGLES11Engine engine].textures.textureUnitCount;
	for (int tu = texUnit; tu < maxTexUnits; tu++) {
		[self unbind: tu];
	}
}

+(void) unbind { [self unbindRemainingFrom: 0]; }


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Textures.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedTextureTag;

-(GLuint) nextTag { return ++lastAssignedTextureTag; }

+(void) resetTagAllocation { lastAssignedTextureTag = 0; }

@end


#pragma mark CCTexture2D extension category

@implementation CCTexture2D (CC3Texture)

#pragma mark Allocation and initialization

/** The CC3Texture2D cluster class to be instantiated when the alloc method is invoked. */
static Class instantiationClass = nil;

+(Class) instantiationClass { return instantiationClass; }

+(void) setInstantiationClass: (Class) aClass  {
	NSAssert(aClass == nil || [aClass isSubclassOfClass: [CCTexture2D class]],
			 @"The specified instantiationClass must be a subclass of CCTexture2D.");
	instantiationClass = aClass;
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
+(id) alloc {
	return instantiationClass ? [instantiationClass alloc] : [self allocBase];
}

-(BOOL) generateMipmapIfNeeded {
	if (self.hasMipmap) return NO;
	
	[self generateMipmap];
	self.hasMipmap = YES;
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
+(BOOL) hasMipmap: (GLuint) glTexName {
	return [self cc3StateAt: glTexName]->hasMipmap;
}

/** Sets whether the specified GL texture name has been marked as containing a mipmap. */
+(void) setHasMipmap: (GLuint) glTexName to: (BOOL) hasMm {
	[self cc3StateAt: glTexName]->hasMipmap = hasMm;
}

/** Returns whether the specified GL texture name is vertically flipped. */
+(BOOL) isFlippedVertically: (GLuint) glTexName {
	return [self cc3StateAt: glTexName]->isFlippedVertically;
}

/** Sets whether the specified GL texture name is vertically flipped. */
+(void) setIsFlippedVertically: (GLuint) glTexName to: (BOOL) isFlipped {
	[self cc3StateAt: glTexName]->isFlippedVertically = isFlipped;
}

-(BOOL) hasMipmap { return [self.class hasMipmap: self.name]; }

-(void) setHasMipmap: (BOOL) hasMm { [self.class setHasMipmap: self.name to: hasMm]; }

-(BOOL) isFlippedVertically { return [self.class isFlippedVertically: self.name]; }

-(void) setIsFlippedVertically: (BOOL) isFlipped {
	[self.class setIsFlippedVertically: self.name to: isFlipped];
}

@end


#pragma mark CCTexturePVR extension category

/** Extension to support testing for mipmaps. */
@interface CCTexturePVR (CC3Texture)
/** Returns whether this instance contains mipmaps. */
-(BOOL) hasMipmap;
@end

@implementation CCTexturePVR (CC3Texture)
-(BOOL) hasMipmap { return (numberOfMipmaps_ > 1); }
@end


#pragma mark CC3Texture2D

@implementation CC3Texture2D

/** Overridden to clear the tracking of the mipmap from the global status array. */
-(void) dealloc {
	self.hasMipmap = NO;				// Set global marker back to default
	self.isFlippedVertically = YES;		// Set global marker back to default
	[super dealloc];
}

/**
 * Overridden to bypass the superclass alloc, which can redirect back here,
 * potentially causing an infinite loop.
 */
+(id) alloc { return [self allocBase]; }

#if COCOS2D_VERSION < 0x010100

/**
 * Overridden to mark whether the texture contains a mipmap and is flipped vertically.
 * Since this method is monolithic, this is simply a cut-and-paste of the superclass
 * method, with the extra functionality added.
 */
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
			
			self.hasMipmap = pvr.hasMipmap;		// Added to support cocos3d texture loading
			self.isFlippedVertically = NO;		// Added to support cocos3d texture loading
			
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

#else

/**
 * Overridden to mark whether the texture contains a mipmap and is flipped vertically.
 * Since this method is monolithic, this is simply a cut-and-paste of the superclass
 * method, with the extra functionality added.
 */
-(id) initWithPVRFile: (NSString*) relPath {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	ccResolutionType resolution;
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:relPath resolutionType:&resolution];
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
			
			self.hasMipmap = pvr.hasMipmap;		// Added to support cocos3d texture loading
			self.isFlippedVertically = NO;		// Added to support cocos3d texture loading
			
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
#endif

// By default PVR images are treated as if they don't have the alpha channel premultiplied
static BOOL PVRHaveAlphaPremultiplied_ = NO;

+(BOOL) PVRImagesHavePremultipliedAlpha { return PVRHaveAlphaPremultiplied_; }

+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied {
	PVRHaveAlphaPremultiplied_ = haveAlphaPremultiplied;
}

@end
