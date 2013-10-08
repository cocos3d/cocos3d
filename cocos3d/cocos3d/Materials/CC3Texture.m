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
#import "CC3PVRTexture.h"
#import "CC3CC2Extensions.h"
#import "CC3ShaderProgramSemantics.h"


#pragma mark -
#pragma mark CC3Texture 


@implementation CC3Texture

@synthesize textureID=_textureID, size=_size, coverage=_coverage, hasMipmap=_hasMipmap;
@synthesize pixelFormat=_pixelFormat, pixelType=_pixelType;
@synthesize hasPremultipliedAlpha=_hasPremultipliedAlpha, isUpsideDown=_isUpsideDown;
@synthesize shouldFlipVerticallyOnLoad=_shouldFlipVerticallyOnLoad;
@synthesize shouldFlipHorizontallyOnLoad=_shouldFlipHorizontallyOnLoad;

-(void) dealloc {
	[self remove];		// remove this instance from the cache
	[self deleteGLTexture];
	[super dealloc];
}

-(void) ensureGLTexture { if (!_textureID) _textureID = CC3OpenGL.sharedGL.generateTexture; }

-(void) deleteGLTexture {
	[CC3OpenGL.sharedGL deleteTexture: _textureID];
	_textureID = 0;
}

-(BOOL) isPOTWidth { return (_size.width == ccNextPOT(_size.width)); }

-(BOOL) isPOTHeight { return (_size.height == ccNextPOT(_size.height)); }

-(BOOL) isPOT { return self.isPOTWidth && self.isPOTHeight; }

-(GLenum) samplerSemantic {
	CC3AssertUnimplemented(@"samplerSemantic");
	return kCC3SemanticNone;
}

-(BOOL) isTexture2D { return NO; }

-(BOOL) isTextureCube { return NO; }

-(GLenum) textureTarget {
	CC3AssertUnimplemented(@"textureTarget");
	return GL_ZERO;
}

-(GLenum) initialAttachmentFace {
	CC3AssertUnimplemented(@"initialAttachmentFace");
	return GL_ZERO;
}

-(CC3TextureUnit*) textureUnit { return nil; }

-(void) setTextureUnit: (CC3TextureUnit*) textureUnit {}

-(CC3Vector) lightDirection { return kCC3VectorZero; }

-(void) setLightDirection: (CC3Vector) aDirection {}

-(BOOL) isBumpMap { return NO; }

-(CC3Texture*) texture { return self; }

-(CCTexture2D*) asCCTexture2D { return [CC3UnmanagedTexture2D textureFromCC3Texture: self]; }


#pragma mark Texture transformations

+(BOOL) defaultShouldFlipVerticallyOnLoad { return NO; }

+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip {}

+(BOOL) defaultShouldFlipHorizontallyOnLoad { return NO; }

+(void) setDefaultShouldFlipHorizontallyOnLoad: (BOOL) shouldFlip {}


#pragma mark Binding content

-(void) bindEmptyContent { CC3AssertUnimplemented(@"bindEmptyContent"); }

-(void) bindTextureContent: (CC3Texture2DContent*) texContent toTarget: (GLenum) target {
	
	[self checkTextureOrientation: texContent];
	
	[self ensureGLTexture];
	
	_size = CC3IntSizeMake((GLint)texContent.pixelsWide, (GLint)texContent.pixelsHigh);
	_coverage = CGSizeMake(texContent.maxS, texContent.maxT);
	_pixelFormat = texContent.pixelGLFormat;
	_pixelType = texContent.pixelGLType;
	_hasPremultipliedAlpha = texContent.hasPremultipliedAlpha;
	_isUpsideDown = texContent.isUpsideDown;
		
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint tuIdx = 0;		// Choose the texture unit in which to work
	
	[gl bindTexture: _textureID toTarget: self.textureTarget at: tuIdx];
	[gl loadTexureImage: texContent.imageData
			 intoTarget: target
		  onMipmapLevel: 0
			   withSize: _size
			 withFormat: _pixelFormat
			   withType: _pixelType
	  withByteAlignment: self.byteAlignment
					 at: tuIdx];
	[self bindTextureParametersAt: tuIdx usingGL: gl];
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
	
	MarkRezActivityStart();

	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint tuIdx = 0;	// Choose the texture unit in which to work
	GLenum target = self.textureTarget;
	[gl bindTexture: _textureID toTarget: target at: tuIdx];
	[gl generateMipmapForTarget: target at: tuIdx];
	_hasMipmap = YES;

	LogRez(@"%@ generated mipmap in %.3f ms", self, GetRezActivityDuration() * 1000);
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
	return self.isPOT ? _horizontalWrappingFunction : GL_CLAMP_TO_EDGE;
}

-(void) setHorizontalWrappingFunction: (GLenum) horizontalWrappingFunction {
	_horizontalWrappingFunction = horizontalWrappingFunction;
	[self markTextureParametersDirty];
}

-(GLenum) verticalWrappingFunction {
	return self.isPOT ? _verticalWrappingFunction : GL_CLAMP_TO_EDGE;
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

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3Assert(_textureID, @"%@ cannot be bound to the GL engine because it has not been loaded.", self);

	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.currentTextureUnitIndex;
	GLenum target = self.textureTarget;

	[gl enableTexturing: YES inTarget: target at: tuIdx];
	[gl bindTexture: _textureID toTarget: target at: tuIdx];
	[self bindTextureParametersAt: tuIdx usingGL: gl];
	[self bindTextureEnvironmentWithVisitor: visitor];

	LogTrace(@"%@ bound to texture unit %u", self, tuIdx);
}

/** If the texture parameters are dirty, binds them to the GL texture unit state. */
-(void) bindTextureParametersAt: (GLuint) tuIdx usingGL: (CC3OpenGL*) gl {
	if ( !_texParametersAreDirty ) return;
		
	// Use property accessors to allow adjustments from the raw values
	GLenum target = self.textureTarget;
	[gl setTextureMinifyFunc: self.minifyingFunction inTarget: target at: tuIdx];
	[gl setTextureMagnifyFunc: self.magnifyingFunction inTarget: target at: tuIdx];
	[gl setTextureHorizWrapFunc: self.horizontalWrappingFunction inTarget: target at: tuIdx];
	[gl setTextureVertWrapFunc: self.verticalWrappingFunction inTarget: target at: tuIdx];
	
	_texParametersAreDirty = NO;
}

/** Binds the default texture unit environment to the GL engine. */
-(void) bindTextureEnvironmentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[CC3TextureUnit bindDefaultWithVisitor: visitor];
}


#pragma mark Texture content and sizing

-(BOOL) loadTarget: (GLenum) target fromFile: (NSString*) aFilePath {
	
	if (!_name) self.name = [self.class textureNameFromFilePath: aFilePath];
	
	MarkRezActivityStart();
	
	id content = [[self.textureContentClass alloc] initFromFile: aFilePath];
	if ( !content ) {
		LogError(@"%@ could not load texture from file %@", self, CC3EnsureAbsoluteFilePath(aFilePath));
		return NO;
	}
	
	[self bindTextureContent: content toTarget: target];
	
	[content release];		// Could be big, so get rid of it immediately
	
	LogRez(@"%@ loaded from file %@ in %.3f ms", self, aFilePath, GetRezActivityDuration() * 1000);
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

-(void) checkTextureOrientation: (CC3Texture2DContent*) texContent {
	BOOL flipHorz = self.shouldFlipHorizontallyOnLoad;
	BOOL flipVert = texContent.isUpsideDown && self.shouldFlipVerticallyOnLoad;
	
	if (flipHorz && flipVert)
		[texContent rotateHalfCircle];		// Do both in one pass
	else if (flipHorz)
		[texContent flipHorizontally];
	else if (flipVert)
		[texContent flipVertically];
}

-(void) replacePixels: (CC3Viewport) rect
			 inTarget: (GLenum) target
		  withContent: (ccColor4B*) colorArray {
	
	// If needed, convert the contents of the array to the format and type of this texture
	[self convertContent: colorArray ofLength: (rect.w * rect.h)];
	
	CC3OpenGL* gl = CC3OpenGL.sharedGL;
	GLuint tuIdx = 0;		// Choose the texture unit in which to work
	[gl bindTexture: _textureID toTarget: self.textureTarget at: tuIdx];
	[gl loadTexureSubImage: (const GLvoid*) colorArray
				intoTarget: target
			 onMipmapLevel: 0
			 intoRectangle: rect
				withFormat: _pixelFormat
				  withType: _pixelType
		 withByteAlignment: 1
						at: tuIdx];
}

/**
 * Converts the pixels in the specified array to the format and type used by this texture.
 * Upon completion, the specified pixel array will contain the converted pixels.
 *
 * Since the pixels in any possible converted format will never consume more memory than
 * the pixels in the incoming 32-bit RGBA format, the conversion is perfomed in-place.
 */
-(void) convertContent: (ccColor4B*) colorArray ofLength: (GLuint) pixCount {
	switch (_pixelType) {
		case GL_UNSIGNED_BYTE:
			switch (_pixelFormat) {
				case GL_RGB: {
					ccColor3B* rgbArray = (ccColor3B*)colorArray;
					for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++)
						rgbArray[pixIdx] = CCC3BFromCCC4B(colorArray[pixIdx]);
					break;
				}
				case GL_ALPHA: {
					GLubyte* bArray = (GLubyte*)colorArray;
					for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++)
						bArray[pixIdx] = colorArray[pixIdx].a;
					break;
				}
				case GL_LUMINANCE: {
					GLubyte* bArray = (GLubyte*)colorArray;
					for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++) {
						ccColor4B* pRGBA = colorArray + pixIdx;
						GLfloat luma = CC3LuminosityBT709(CCColorFloatFromByte(pRGBA->r),
														  CCColorFloatFromByte(pRGBA->g),
														  CCColorFloatFromByte(pRGBA->b));
						bArray[pixIdx] = CCColorByteFromFloat(luma);
					}
					break;
				}
				case GL_LUMINANCE_ALPHA: {
					GLushort* usArray = (GLushort*)colorArray;
					for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++) {
						ccColor4B* pRGBA = colorArray + pixIdx;
						GLfloat luma = CC3LuminosityBT709(CCColorFloatFromByte(pRGBA->r),
														  CCColorFloatFromByte(pRGBA->g),
														  CCColorFloatFromByte(pRGBA->b));
						usArray[pixIdx] = (((GLushort)CCColorByteFromFloat(luma)  << 8) |
										   ((GLushort)pRGBA->a));
					}
					break;
				}
				case GL_RGBA:		// Already in RGBA format so do nothing!
				default:
					break;
			}
			break;
		case GL_UNSIGNED_SHORT_5_6_5: {
			GLushort* usArray = (GLushort*)colorArray;
			for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++) {
				ccColor4B* pRGBA = colorArray + pixIdx;
				usArray[pixIdx] = ((((GLushort)pRGBA->r >> 3) << 11) |
								   (((GLushort)pRGBA->g >> 2) <<  5) |
								   (((GLushort)pRGBA->b >> 3)));
			}
			break;
		}
		case GL_UNSIGNED_SHORT_4_4_4_4: {
			GLushort* usArray = (GLushort*)colorArray;
			for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++) {
				ccColor4B* pRGBA = colorArray + pixIdx;
				usArray[pixIdx] = ((((GLushort)pRGBA->r >> 4) << 12) |
								   (((GLushort)pRGBA->g >> 4) <<  8) |
								   (((GLushort)pRGBA->b >> 4) <<  4) |
								   (((GLushort)pRGBA->a >> 4)));
			}
			break;
		}
		case GL_UNSIGNED_SHORT_5_5_5_1: {
			GLushort* usArray = (GLushort*)colorArray;
			for (GLuint pixIdx = 0; pixIdx < pixCount; pixIdx++) {
				ccColor4B* pRGBA = colorArray + pixIdx;
				usArray[pixIdx] = ((((GLushort)pRGBA->r >> 3) << 11) |
								   (((GLushort)pRGBA->g >> 3) <<  6) |
								   (((GLushort)pRGBA->b >> 3) <<  1) |
								   (((GLushort)pRGBA->a >> 7)));
			}
			break;
		}
		default:
			break;
	}
}

-(void) resizeTo: (CC3IntSize) size {
	if ( CC3IntSizesAreEqual(size, _size) ) return;
	_size = size;
	[self bindEmptyContent];
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
		_shouldFlipHorizontallyOnLoad = self.class.defaultShouldFlipHorizontallyOnLoad;
		self.textureParameters = self.class.defaultTextureParameters;	// Marks params dirty
	}
	return self;
}

-(void) populateFrom: (CC3Texture*) another { CC3Assert(NO, @"%@ should not be copied.", self.class); }

+(Class) textureClassForFile: (NSString*) aFilePath {
	NSString* lcPath = aFilePath.lowercaseString;
	if ([lcPath hasSuffix: @".pvr"] ||
		[lcPath hasSuffix: @".pvr.gz"] ||
		[lcPath hasSuffix: @".pvr.ccz"] ) {
		return CC3PVRTexture.class;
	}
	return CC3Texture2D.class;
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
	id tex = [self getTextureNamed: [self textureNameFromFilePath: aFilePath]];
	if (tex) return tex;
	
	Class texClz = [self textureClassForFile: aFilePath];
	tex = [[texClz alloc] initFromFile: aFilePath];
	[self addTexture: tex];
	return [tex autorelease];
}

+(NSString*) textureNameFromFilePath: (NSString*) aFilePath { return aFilePath.lastPathComponent; }

+(Class) textureClassForCGImage { return CC3Texture2D.class; }

-(id) initWithCGImage: (CGImageRef) cgImg {
	return [[[self.class textureClassForCGImage] alloc] initWithCGImage: cgImg];
}

+(id) textureWithCGImage: (CGImageRef) cgImg {
	return [[[[self textureClassForCGImage] alloc] initWithCGImage: cgImg] autorelease];
}

+(Class) textureClassForEmpty2D { return CC3Texture2D.class; }

-(id) initWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self.class textureClassForEmpty2D] alloc] initWithPixelFormat: format andPixelType: type];
}

+(id) textureWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[[self textureClassForEmpty2D] alloc] initWithPixelFormat: format andPixelType: type] autorelease];
}

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	if ( (self = [self initWithPixelFormat: format andPixelType: type]) ) {
		[self resizeTo: size];
	}
	return self;
}

+(id) textureWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[[self textureClassForEmpty2D] alloc] initWithSize: size andPixelFormat: format andPixelType: type] autorelease];
}

+(Class) textureClassForCube { return CC3TextureCube.class; }

-(id) initCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
					   posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
					   posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {

	Class texClz = [self.class textureClassForCube];
	return [[[texClz alloc] initCubeFromFilesPosX: posXFilePath negX: negXFilePath
											 posY: posYFilePath negY: negYFilePath
											 posZ: posZFilePath negZ: negZFilePath] autorelease];
}

+(id) textureCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
						  posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
						  posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	
	id tex = [self getTextureNamed: [self textureNameFromFilePath: posXFilePath]];
	if (tex) return tex;
	
	Class texClz = [self.class textureClassForCube];
	tex = [[texClz alloc] initCubeFromFilesPosX: posXFilePath negX: negXFilePath
										   posY: posYFilePath negY: negYFilePath
										   posZ: posZFilePath negZ: negZFilePath];
	[self addTexture: tex];
	return [tex autorelease];
}

-(id) initCubeFromFilePattern: (NSString*) aFilePathPattern {
	return [[[self.class textureClassForCube] alloc] initCubeFromFilePattern: aFilePathPattern];
}

+(id) textureCubeFromFilePattern: (NSString*) aFilePathPattern {
	NSString* texName = [self textureNameFromFilePath: aFilePathPattern];
	
	id tex = [self getTextureNamed: texName];
	if (tex) return tex;
	
	tex = [[[self textureClassForCube] alloc] initCubeFromFilePattern: aFilePathPattern];
	[self addTexture: tex];
	return [tex autorelease];
}

-(id) initCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	Class texClz = [self.class textureClassForCube];
	return [[texClz alloc] initCubeWithPixelFormat: format andPixelType: type];
}

+(id) textureCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	Class texClz = [self.class textureClassForCube];
	return [[[texClz alloc] initCubeWithPixelFormat: format andPixelType: type] autorelease];
}

-(id) initCubeWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	if ( (self = [self initCubeWithPixelFormat: format andPixelType: type]) ) {
		[self resizeTo: size];
	}
	return self;
}

+(id) textureCubeWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	Class texClz = [self.class textureClassForCube];
	return [[[texClz alloc] initCubeWithSize: size andPixelFormat: format andPixelType: type] autorelease];
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" (ID: %u)", self.textureID];
	[desc appendFormat: @" of type %@", (self.isTextureCube ? @"cube" : @"2D")];
	[desc appendFormat: @", size: %@", NSStringFromCC3IntSize(self.size)];
	[desc appendFormat: @", coverage: %@", NSStringFromCGSize(self.coverage)];
	[desc appendFormat: @", pixel format/type: %@/%@", NSStringFromGLEnum(self.pixelFormat),
															NSStringFromGLEnum(self.pixelType)];
	[desc appendFormat: @", is %@upside down", (self.isUpsideDown ? @"" : @"not ")];
	[desc appendFormat: @", has %@ mipmap", (self.hasMipmap ? @"a" : @"no")];
	[desc appendFormat: @", alpha is %@pre-multiplied", (self.hasPremultipliedAlpha ? @"" : @"not ")];
	[desc appendFormat: @", minifying: %@", NSStringFromGLEnum(self.minifyingFunction)];
	[desc appendFormat: @", magnifying: %@", NSStringFromGLEnum(self.magnifyingFunction)];
	[desc appendFormat: @", horz wrap: %@", NSStringFromGLEnum(self.horizontalWrappingFunction)];
	[desc appendFormat: @", vert wrap: %@", NSStringFromGLEnum(self.verticalWrappingFunction)];
	return desc;
}

-(NSString*) constructorDescription {
	return [NSString stringWithFormat: @"[%@ textureFromFile: @\"%@\"];", [self class], self.name];
}

// Class variable tracking the most recent tag value assigned for CC3Textures.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint _lastAssignedTextureTag;

-(GLuint) nextTag { return ++_lastAssignedTextureTag; }

+(void) resetTagAllocation { _lastAssignedTextureTag = 0; }


#pragma mark Texture cache

-(void) remove { [self.class removeTexture: self]; }

static CC3Cache* _textureCache = nil;

+(void) ensureCache {
	if ( !_textureCache ) _textureCache = [[CC3Cache weakCacheForType: @"texture"] retain];	// retained
}

+(void) addTexture: (CC3Texture*) texture {
	[self ensureCache];
	[_textureCache addObject: texture];
}

+(CC3Texture*) getTextureNamed: (NSString*) name {
	return (CC3Texture*)[_textureCache getObjectNamed: name];
}

+(void) removeTexture: (CC3Texture*) texture { [_textureCache removeObject: texture]; }

+(void) removeTextureNamed: (NSString*) name { [_textureCache removeObjectNamed: name]; }

+(void) removeAllTextures { [_textureCache removeAllObjectsOfType: self];}

+(BOOL) isPreloading { return _textureCache ? !_textureCache.isWeak : NO; }

+(void) setIsPreloading: (BOOL) isPreloading {
	[self ensureCache];
	_textureCache.isWeak = !isPreloading;
}

+(NSString*) cachedTexturesDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[_textureCache enumerateObjectsUsingBlock: ^(CC3Texture* tex, BOOL* stop) {
		if ( [tex isKindOfClass: self] ) [desc appendFormat: @"\n\t%@", tex.constructorDescription];
	}];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3Texture2D

@implementation CC3Texture2D

-(GLenum) samplerSemantic { return kCC3SemanticTexture2DSampler; }

-(BOOL) isTexture2D { return YES; }

-(GLenum) textureTarget { return GL_TEXTURE_2D; }

-(GLenum) initialAttachmentFace { return GL_TEXTURE_2D; }

-(Class) textureContentClass { return CC3Texture2DContent.class; }

-(void) bindEmptyContent {
	id texContent = [[self.textureContentClass alloc] initWithSize: self.size
													andPixelFormat: self.pixelFormat
													  andPixelType: self.pixelType];
	[self bindTextureContent: texContent toTarget: self.textureTarget];
	[texContent release];
	_hasMipmap = NO;
}


#pragma mark Texture content and sizing


-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray {
	[self replacePixels: rect inTarget: self.textureTarget withContent: colorArray];
}


#pragma mark Texture transformations

static BOOL _defaultShouldFlip2DVerticallyOnLoad = YES;

+(BOOL) defaultShouldFlipVerticallyOnLoad { return _defaultShouldFlip2DVerticallyOnLoad; }

+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip {
	_defaultShouldFlip2DVerticallyOnLoad = shouldFlip;
}

static BOOL _defaultShouldFlip2DHorizontallyOnLoad = NO;

+(BOOL) defaultShouldFlipHorizontallyOnLoad { return _defaultShouldFlip2DHorizontallyOnLoad; }

+(void) setDefaultShouldFlipHorizontallyOnLoad: (BOOL) shouldFlip {
	_defaultShouldFlip2DHorizontallyOnLoad = shouldFlip;
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
	if ( (self = [self init]) ) {
		self.shouldFlipVerticallyOnLoad = NO;	// Nothing to flip
		_pixelFormat = format;
		_pixelType = type;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3TextureCube

@implementation CC3TextureCube

-(GLenum) samplerSemantic { return kCC3SemanticTextureCubeSampler; }

-(BOOL) isTextureCube { return YES; }

-(GLenum) textureTarget { return GL_TEXTURE_CUBE_MAP; }

-(GLenum) initialAttachmentFace { return GL_TEXTURE_CUBE_MAP_POSITIVE_X; }

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

-(void) loadCubeFace: (GLenum) faceTarget fromCGImage: (CGImageRef) cgImg {
	id texContent = [[self.textureContentClass alloc] initWithCGImage: cgImg];
	[self bindTextureContent: texContent toTarget: faceTarget];
	[texContent release];		// Could be big, so get rid of it immediately
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
	
	if (!_name) self.name = [self.class textureNameFromFilePath: aFilePathPattern];

	return [self loadFromFilesPosX: [NSString stringWithFormat: aFilePathPattern, @"PosX"]
							  negX: [NSString stringWithFormat: aFilePathPattern, @"NegX"]
							  posY: [NSString stringWithFormat: aFilePathPattern, @"PosY"]
							  negY: [NSString stringWithFormat: aFilePathPattern, @"NegY"]
							  posZ: [NSString stringWithFormat: aFilePathPattern, @"PosZ"]
							  negZ: [NSString stringWithFormat: aFilePathPattern, @"NegZ"]];
}


#pragma mark Texture content and sizing

-(void) replacePixels: (CC3Viewport) rect
		   inCubeFace: (GLenum) faceTarget
		  withContent: (ccColor4B*) colorArray {
	[self replacePixels: rect inTarget: faceTarget withContent: colorArray];
}


#pragma mark Texture transformations

static BOOL _defaultShouldFlipCubeVerticallyOnLoad = NO;

+(BOOL) defaultShouldFlipVerticallyOnLoad { return _defaultShouldFlipCubeVerticallyOnLoad; }

+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip {
	_defaultShouldFlipCubeVerticallyOnLoad = shouldFlip;
}

static BOOL _defaultShouldFlipCubeHorizontallyOnLoad = YES;

+(BOOL) defaultShouldFlipHorizontallyOnLoad { return _defaultShouldFlipCubeHorizontallyOnLoad; }

+(void) setDefaultShouldFlipHorizontallyOnLoad: (BOOL) shouldFlip {
	_defaultShouldFlipCubeHorizontallyOnLoad = shouldFlip;
}


#pragma mark Allocation and initialization

-(id) initCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
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

-(id) initCubeFromFilePattern: (NSString*) aFilePathPattern {
	if ( (self = [self init]) ) {
		if ( ![self loadFromFilePattern: aFilePathPattern] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

-(id) initCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	if ( (self = [self init]) ) {
		self.shouldFlipVerticallyOnLoad = NO;	// Nothing to flip
		_pixelFormat = format;
		_pixelType = type;
	}
	return self;
}

-(NSString*) constructorDescription {
	return [NSString stringWithFormat: @"[%@ textureCubeFromFilePattern: @\"%@\"];", [self class], self.name];
}

@end


#pragma mark -
#pragma mark CC3TextureUnitTexture

@implementation CC3TextureUnitTexture

@synthesize textureUnit=_textureUnit;

-(void) dealloc {
	[_texture release];
	[_textureUnit release];
	[super dealloc];
}

-(CC3Texture*) texture { return _texture; }

-(void) setTexture: (CC3Texture*) texture {
	if (texture == _texture) return;
	[_texture release];
	_texture = [texture retain];
	if (!_name) self.name = texture.name;
}

-(GLuint) textureID { return _texture.textureID; }

-(CC3IntSize) size { return _texture.size; }

-(BOOL) isPOTWidth { return _texture.isPOTWidth; }

-(BOOL) isPOTHeight { return _texture.isPOTHeight; }

-(BOOL) isPOT { return _texture.isPOT; }

-(GLenum) samplerSemantic { return _texture.samplerSemantic; }

-(BOOL) isTexture2D { return _texture.isTexture2D; }

-(BOOL) isTextureCube { return _texture.isTextureCube; }

-(CGSize) coverage { return _texture.coverage; }

-(GLenum) pixelFormat { return _texture.pixelFormat; }

-(GLenum) pixelType { return _texture.pixelType; }

-(BOOL) hasPremultipliedAlpha { return _texture.hasPremultipliedAlpha; }

-(void) setHasPremultipliedAlpha: (BOOL) hasPremultipliedAlpha {
	_texture.hasPremultipliedAlpha = hasPremultipliedAlpha;
}

-(BOOL) isUpsideDown { return _texture.isUpsideDown; }

-(void) setIsUpsideDown: (BOOL) isUpsideDown { _texture.isUpsideDown = isUpsideDown; }

-(GLenum) textureTarget { return _texture.textureTarget; }

-(GLenum) initialAttachmentFace { return _texture.initialAttachmentFace; }

-(BOOL) shouldFlipVerticallyOnLoad { return _texture.shouldFlipVerticallyOnLoad; }

-(void) setShouldFlipVerticallyOnLoad: (BOOL) shouldFlipVerticallyOnLoad {
	_texture.shouldFlipVerticallyOnLoad = shouldFlipVerticallyOnLoad;
}

-(BOOL) shouldFlipHorizontallyOnLoad { return _texture.shouldFlipHorizontallyOnLoad; }

-(void) setShouldFlipHorizontallyOnLoad: (BOOL) shouldFlipHorizontallyOnLoad {
	_texture.shouldFlipHorizontallyOnLoad = shouldFlipHorizontallyOnLoad;
}

-(BOOL) hasMipmap { return _texture.hasMipmap; }

-(void) generateMipmap { [_texture generateMipmap]; }

-(GLenum) minifyingFunction { return _texture.minifyingFunction; }

-(void) setMinifyingFunction: (GLenum) minifyingFunction {
	_texture.minifyingFunction = minifyingFunction;
}

-(GLenum) magnifyingFunction { return _texture.magnifyingFunction; }

-(void) setMagnifyingFunction: (GLenum) magnifyingFunction {
	_texture.magnifyingFunction = magnifyingFunction;
}

-(GLenum) horizontalWrappingFunction { return _texture.horizontalWrappingFunction; }

-(void) setHorizontalWrappingFunction: (GLenum) horizontalWrappingFunction {
	_texture.horizontalWrappingFunction = horizontalWrappingFunction;
}

-(GLenum) verticalWrappingFunction { return _texture.verticalWrappingFunction; }

-(void) setVerticalWrappingFunction: (GLenum) verticalWrappingFunction {
	_texture.verticalWrappingFunction = verticalWrappingFunction;
}

-(ccTexParams) textureParameters { return _texture.textureParameters; }

-(void) setTextureParameters: (ccTexParams) textureParameters {
	_texture.textureParameters = textureParameters;
}


#pragma mark Texture content and sizing

-(void) replacePixels: (CC3Viewport) rect
			 inTarget: (GLenum) target
		  withContent: (ccColor4B*) colorArray {
	[_texture replacePixels: rect inTarget: target withContent: colorArray];
}

-(void) resizeTo: (CC3IntSize) size { [_texture resizeTo: size]; }

-(CC3Vector) lightDirection { return _textureUnit ? _textureUnit.lightDirection : kCC3VectorZero; }

-(void) setLightDirection: (CC3Vector) aDirection { _textureUnit.lightDirection = aDirection; }

-(BOOL) isBumpMap { return (_textureUnit && _textureUnit.isBumpMap); }


#pragma mark Drawing

/**
 * Draw wrapped texture, then draw texture unit.
 * Wrapped texture resets texture unit bindings to default, so if no texture unit,
 * will behave with default behaviour.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[_texture drawWithVisitor: visitor];
	[_textureUnit bindWithVisitor: visitor];	// If no textureUnit, default set by texture
}


#pragma mark Allocation and Initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_texture = nil;
		_textureUnit = nil;
	}
	return self;
}

-(id) initWithTexture: (CC3Texture*) texture {
	if ( (self = [self init]) ) {
		self.texture = texture;
	}
	return self;
}

+(id) textureWithTexture: (CC3Texture*) texture {
	return [[((CC3TextureUnitTexture*)[self alloc]) initWithTexture: texture] autorelease];
}

-(id) initFromFile: (NSString*) aFilePath {
	return [self initWithTexture: [CC3Texture textureFromFile: aFilePath]];
}

+(id) textureFromFile: (NSString*) aFilePath {
	return [[[self alloc] initFromFile: aFilePath] autorelease];
}

-(id) initWithCGImage: (CGImageRef) cgImg {
	return [self initWithTexture: [CC3Texture textureWithCGImage: cgImg]];
}

+(id) textureWithCGImage: (CGImageRef) cgImg {
	return [[[self alloc] initWithCGImage: cgImg] autorelease];
}

-(id) initWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [self initWithTexture: [CC3Texture textureWithPixelFormat: format andPixelType: type]];
}

+(id) textureWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initWithPixelFormat: format andPixelType: type] autorelease];
}

-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [self initWithTexture: [CC3Texture textureWithSize: size andPixelFormat: format andPixelType: type]];
}

+(id) textureWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initWithSize: size andPixelFormat: format andPixelType: type] autorelease];
}

-(id) initCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
					   posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
					   posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	return [self initWithTexture: [CC3Texture textureCubeFromFilesPosX: posXFilePath negX: negXFilePath
																  posY: posYFilePath negY: negYFilePath
																  posZ: posZFilePath negZ: negZFilePath]];
}

+(id) textureCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
						  posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
						  posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	return [[[self alloc] initCubeFromFilesPosX: posXFilePath negX: negXFilePath
										   posY: posYFilePath negY: negYFilePath
										   posZ: posZFilePath negZ: negZFilePath] autorelease];
}

-(id) initCubeFromFilePattern: (NSString*) aFilePathPattern {
	return [self initWithTexture: [CC3Texture textureCubeFromFilePattern: aFilePathPattern]];
}

+(id) textureCubeFromFilePattern: (NSString*) aFilePathPattern {
	return [[[self alloc] initCubeFromFilePattern: aFilePathPattern] autorelease];
}

-(id) initCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [self initWithTexture: [CC3Texture textureCubeWithPixelFormat: format andPixelType: type]];
}

+(id) textureCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initCubeWithPixelFormat: format andPixelType: type] autorelease];
}

-(id) initCubeWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [self initWithTexture: [CC3Texture textureCubeWithSize: size andPixelFormat: format andPixelType: type]];
}

+(id) textureCubeWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type {
	return [[[self alloc] initCubeWithSize: size andPixelFormat: format andPixelType: type] autorelease];
}


/** Don't invoke super, because normal textures are not copyable */
-(void) populateFrom: (CC3TextureUnitTexture*) another {
	[self copyUserDataFrom: another];	// From CC3Identifiable
	
	[_texture release];
	_texture = [another.texture retain];		// retained & shared across copies
	
	[_textureUnit release];
	_textureUnit = [another.textureUnit copy];	// retained
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ with texture %@ in %@", self,
			_texture.fullDescription, _textureUnit.fullDescription];
}

@end


#pragma mark -
#pragma mark CC3Texture2DContent

#if COCOS2D_VERSION < 0x020100
#	define CC2_TEX_NAME name_
#	define CC2_TEX_SIZE size_
#	define CC2_TEX_WIDTH width_
#	define CC2_TEX_HEIGHT height_
#	define CC2_TEX_FORMAT format_
#	define CC2_TEX_MAXS maxS_
#	define CC2_TEX_MAXT maxT_
#	define CC2_TEX_HAS_PREMULT_ALPHA hasPremultipliedAlpha_
#	define CC2_TEX_HAS_MIPMAP hasMipmaps_
#else
#	define CC2_TEX_NAME _name
#	define CC2_TEX_SIZE _size
#	define CC2_TEX_WIDTH _width
#	define CC2_TEX_HEIGHT _height
#	define CC2_TEX_FORMAT _format
#	define CC2_TEX_MAXS _maxS
#	define CC2_TEX_MAXT _maxT
#	define CC2_TEX_HAS_PREMULT_ALPHA _hasPremultipliedAlpha
#	define CC2_TEX_HAS_MIPMAP _hasMipmaps
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

-(GLuint) bytesPerPixel {
	GLuint pixFmt = self.pixelFormat;	// Not all versions of cocos2d contain all enum values.
	switch(pixFmt) {
		case kCCTexture2DPixelFormat_RGBA8888:
			return 4;
		case kCCTexture2DPixelFormat_RGB888:
			return 3;
		case kCCTexture2DPixelFormat_RGB565:
		case kCCTexture2DPixelFormat_RGBA4444:
		case kCCTexture2DPixelFormat_RGB5A1:
		case kCCTexture2DPixelFormat_AI88:
			return 2;
			break;
		case kCCTexture2DPixelFormat_A8:
			return 1;
			break;
		default:
			CC3Assert(NO, @"%@ encountered unexpected format %u", self, self.pixelFormat);
			return 0;
	}
}

-(void) flipVertically {
	if ( !_imageData ) return;		// If no data, nothing to flip!

	CC3FlipVertically((GLubyte*)_imageData,
					  (GLuint)self.pixelsHigh,
					  (GLuint)self.pixelsWide * self.bytesPerPixel);
	
	_isUpsideDown = !_isUpsideDown;		// Orientation has changed
}

-(void) flipHorizontally {
	if ( !_imageData ) return;		// If no data, nothing to flip!

	GLuint rowCnt = (GLuint)self.pixelsHigh;
	GLuint colCnt = (GLuint)self.pixelsWide;
	GLuint lastColIdx = colCnt - 1;
	GLuint halfColCnt = colCnt / 2;

	GLubyte* rowStart = (GLubyte*)_imageData;
	GLuint bytesPerPixel = self.bytesPerPixel;
	GLuint bytesPerRow = bytesPerPixel * colCnt;
	GLubyte tmpPixel[bytesPerPixel];
	
	for (GLuint rowIdx = 0; rowIdx < rowCnt; rowIdx++) {
		for (GLuint colIdx = 0; colIdx < halfColCnt; colIdx++) {
			GLubyte* firstPixel = rowStart + (bytesPerPixel * colIdx);
			GLubyte* lastPixel = rowStart + (bytesPerPixel * (lastColIdx - colIdx));
			memcpy(tmpPixel, firstPixel, bytesPerPixel);
			memcpy(firstPixel, lastPixel, bytesPerPixel);
			memcpy(lastPixel, tmpPixel, bytesPerPixel);
		}
		rowStart += bytesPerRow;
	}
}

-(void) rotateHalfCircle {
	if ( !_imageData ) return;		// If no data, nothing to rotate!
	
	GLuint rowCnt = (GLuint)self.pixelsHigh;
	GLuint lastRowIdx = rowCnt - 1;
	GLuint halfRowCnt = (rowCnt + 1) / 2;		// Use ceiling to capture any middle row: (A+B-1)/B
	GLuint colCnt = (GLuint)self.pixelsWide;
	GLuint lastColIdx = colCnt - 1;
	
	GLubyte* pixData = (GLubyte*)_imageData;
	GLuint bytesPerPixel = self.bytesPerPixel;
	GLuint bytesPerRow = bytesPerPixel * colCnt;
	GLubyte tmpPixel[bytesPerPixel];
	
	for (GLuint rowIdx = 0; rowIdx < halfRowCnt; rowIdx++) {
		GLubyte* lowerRow = pixData + (bytesPerRow * rowIdx);
		GLubyte* upperRow = pixData + (bytesPerRow * (lastRowIdx - rowIdx));
		for (GLuint colIdx = 0; colIdx < colCnt; colIdx++) {
			GLubyte* firstPixel = lowerRow + (bytesPerPixel * colIdx);
			GLubyte* lastPixel = upperRow + (bytesPerPixel * (lastColIdx - colIdx));
			memcpy(tmpPixel, firstPixel, bytesPerPixel);
			memcpy(firstPixel, lastPixel, bytesPerPixel);
			memcpy(lastPixel, tmpPixel, bytesPerPixel);
		}
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
	GLuint pixFmt = self.pixelFormat;	// Not all versions of cocos2d contain all enum values.
	switch(pixFmt) {
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
#if COCOS2D_VERSION < 0x010100
	return [self initWithImage: uiImg];
#else
	return [self initWithImage: uiImg resolutionType: kCCResolutionUnknown];
#endif // COCOS2D_VERSION < 0x010100
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
#if COCOS2D_VERSION < 0x010100
	return [self initWithImage: uiImg];
#else
	return [self initWithImage: uiImg resolutionType: kCCResolutionUnknown];
#endif // COCOS2D_VERSION < 0x010100
#endif	// CC3_CC2_1
	
#endif	// CC_IOS
	
#if CC3_OSX
	NSData* imgData = [NSData dataWithContentsOfFile: CC3EnsureAbsoluteFilePath(aFilePath)];
	NSBitmapImageRep* image = [NSBitmapImageRep imageRepWithData: imgData];
	return [self initWithCGImage: image.CGImage];
#endif	// CC_OSX
}

@end


#pragma mark -
#pragma mark CC3UnmanagedTexture2D

@implementation CC3UnmanagedTexture2D

/** Clear the name so that  */
-(void) dealloc {
	CC2_TEX_NAME = 0;
	LogTrace(@"Deallocating %@ (GL ID = %u)", self, CC2_TEX_NAME);
	[super dealloc];
}

-(id) initFromCC3Texture: (CC3Texture*) texture {
	if( (self = [super init]) ) {
		CC2_TEX_NAME = texture.textureID;
		CC2_TEX_WIDTH = texture.size.width;
		CC2_TEX_HEIGHT = texture.size.height;
		CC2_TEX_MAXS = texture.coverage.width;
		CC2_TEX_MAXT = texture.coverage.height;
		CC2_TEX_SIZE = CGSizeMake((CGFloat)CC2_TEX_WIDTH * CC2_TEX_MAXS, (CGFloat)CC2_TEX_HEIGHT * CC2_TEX_MAXT);
		CC2_TEX_FORMAT = kCCTexture2DPixelFormat_Default;
		CC2_TEX_HAS_PREMULT_ALPHA = texture.hasPremultipliedAlpha;
#if CC3_CC2_2
		CC2_TEX_HAS_MIPMAP = texture.hasMipmap;
#endif
	}
	return self;
}

+(id) textureFromCC3Texture: (CC3Texture*) texture {
	return [[[self alloc] initFromCC3Texture: texture] autorelease];
}

@end
