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


#pragma mark -
#pragma mark CC3Texture 


@implementation CC3Texture

@synthesize textureUnit=_textureUnit;

-(void) dealloc {
	[_texture release];
	[_textureUnit release];
	[super dealloc];
}

-(CC3GLTexture*) texture { return _texture; }

-(void) setTexture: (CC3GLTexture*) texture {
	if (texture == _texture) return;
	[_texture release];
	_texture = [texture retain];
	if (!_name) self.name = texture.name;
}

-(BOOL) hasPremultipliedAlpha { return (_texture && _texture.hasPremultipliedAlpha); }

-(BOOL) isFlippedVertically { return (_texture && _texture.isFlippedVertically); }

-(BOOL) isTexture2D { return (_texture && _texture.isTexture2D); }

-(BOOL) isTextureCube { return (_texture && _texture.isTextureCube); }

-(CGSize) coverage { return _texture ? _texture.coverage : CGSizeZero; }

-(CC3Vector) lightDirection { return _textureUnit ? _textureUnit.lightDirection : kCC3VectorZero; }

-(void) setLightDirection: (CC3Vector) aDirection { _textureUnit.lightDirection = aDirection; }

-(BOOL) isBumpMap { return (_textureUnit && _textureUnit.isBumpMap); }


#pragma mark Texture file loading

-(BOOL) loadTextureFile: (NSString*) aFilePath {
	self.texture = [CC3GLTexture textureFromFile: aFilePath];
	return (_texture != nil);
}

-(BOOL) loadCubeMapFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
							posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
							posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	self.texture = [CC3GLTextureCube textureFromFilesPosX: posXFilePath negX: negXFilePath
													 posY: posYFilePath negY: negYFilePath
													 posZ: posZFilePath negZ: negZFilePath];
	return (_texture != nil);
}

-(BOOL) loadCubeMapFromFilePattern: (NSString*) aFilePathPattern {
	self.texture = [CC3GLTextureCube textureFromFilePattern: aFilePathPattern];
	return (_texture != nil);
}


#pragma mark Allocation and Initialization

-(id) initFromFile: (NSString*) aFilePath { return [self initWithName: nil fromFile: aFilePath]; }

+(id) textureFromFile: (NSString*) aFilePath { return [[[self alloc] initFromFile: aFilePath] autorelease]; }

-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilePath {
	if ( (self = [self initWithName: aName]) ) {
		if ( ![self loadTextureFile: aFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFilePath {
	return [[[self alloc] initWithName: aName fromFile: aFilePath] autorelease];
}

-(id) initCubeMapFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
				   posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
				   posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	
	if ( (self = [self init]) ) {
		if ( ![self loadCubeMapFromFilesPosX: posXFilePath negX: negXFilePath
								 posY: posYFilePath negY: negYFilePath
								 posZ: posZFilePath negZ: negZFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureCubeMapFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
					  posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
					  posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath {
	return [[[self alloc] initCubeMapFromFilesPosX: posXFilePath negX: negXFilePath
											  posY: posYFilePath negY: negYFilePath
											  posZ: posZFilePath negZ: negZFilePath] autorelease];
}

-(id) initCubeMapFromFilePattern: (NSString*) aFilePathPattern {
	if ( (self = [self init]) ) {
		if ( ![self loadCubeMapFromFilePattern: aFilePathPattern] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureCubeMapFromFilePattern: (NSString*) aFilePathPattern {
	return [[[self alloc] initCubeMapFromFilePattern: aFilePathPattern] autorelease];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_texture = nil;
		_textureUnit = nil;
	}
	return self;
}

-(void) populateFrom: (CC3Texture*) another {
	[super populateFrom: another];
	
	[_texture release];
	_texture = [another.texture retain];		// retained & shared across copies

	[_textureUnit release];
	_textureUnit = [another.textureUnit copy];	// retained
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ for %@", super.description, _texture];
}

#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_texture) {
		[self bindGLWithVisitor: visitor];
		[self bindTextureEnvironmentWithVisitor: visitor];
		
		visitor.currentTextureUnitIndex += 1;
	}
}

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[_texture bindGLWithVisitor: visitor];
	LogTrace(@"%@ bound to texture unit %u", self, tuIdx);
}

/** Binds the texture unit environment to the specified GL texture unit state. */
-(void) bindTextureEnvironmentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_textureUnit)
		[_textureUnit bindWithVisitor: visitor];
	else
		[CC3TextureUnit bindDefaultWithVisitor: visitor];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Textures.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedTextureTag;

-(GLuint) nextTag { return ++lastAssignedTextureTag; }

+(void) resetTagAllocation { lastAssignedTextureTag = 0; }

@end


#pragma mark -
#pragma mark Deprecated functionality

@implementation CC3Texture (Deprecated)
-(GLuint) textureID { return _texture ? _texture.textureID : 0; }
-(CGSize) mapSize { return self.coverage; }
-(BOOL) hasMipmap { return (_texture && _texture.hasMipmap); }
+(BOOL) shouldGenerateMipmaps { return CC3GLTexture.shouldGenerateMipmaps; }
+(void) setShouldGenerateMipmaps: (BOOL) shouldMipmap  { CC3GLTexture.shouldGenerateMipmaps = shouldMipmap; }
-(GLenum) minifyingFunction { return _texture ? _texture.minifyingFunction : CC3GLTexture.defaultTextureParameters.minFilter; }
-(void) setMinifyingFunction: (GLenum) minifyingFunction { _texture.minifyingFunction = minifyingFunction; }
-(GLenum) magnifyingFunction { return _texture ? _texture.magnifyingFunction : CC3GLTexture.defaultTextureParameters.magFilter; }
-(void) setMagnifyingFunction: (GLenum) magnifyingFunction { _texture.magnifyingFunction = magnifyingFunction; }
-(GLenum) horizontalWrappingFunction { return _texture ? _texture.horizontalWrappingFunction : CC3GLTexture.defaultTextureParameters.wrapS; }
-(void) setHorizontalWrappingFunction: (GLenum) horizontalWrappingFunction { _texture.horizontalWrappingFunction = horizontalWrappingFunction; }
-(GLenum) verticalWrappingFunction { return _texture ? _texture.verticalWrappingFunction : CC3GLTexture.defaultTextureParameters.wrapT; }
-(void) setVerticalWrappingFunction: (GLenum) verticalWrappingFunction { _texture.verticalWrappingFunction = verticalWrappingFunction; }
-(ccTexParams) textureParameters { return _texture ? _texture.textureParameters : CC3GLTexture.defaultTextureParameters; }
-(void) setTextureParameters: (ccTexParams) texParams { _texture.textureParameters = texParams; }
+(ccTexParams) defaultTextureParameters { return CC3GLTexture.defaultTextureParameters; }
+(void) setDefaultTextureParameters: (ccTexParams) texParams { CC3GLTexture.defaultTextureParameters = texParams; }
-(void) generateMipmap { [_texture generateMipmap]; }

-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath {
	return [self initWithTag: aTag withName: nil fromFile: aFilePath];
}
+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath {
	return [[[self alloc] initWithTag: aTag fromFile: aFilePath] autorelease];
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
@end

