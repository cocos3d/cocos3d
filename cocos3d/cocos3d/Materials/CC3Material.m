/*
 * CC3Material.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3Material.h for full API documentation.
 */

#import "CC3Material.h"
#import "CC3ShaderMatcher.h"
#import "CC3CC2Extensions.h"


@implementation CC3Material

@synthesize ambientColor=_ambientColor, diffuseColor=_diffuseColor;
@synthesize specularColor=_specularColor, emissionColor=_emissionColor;
@synthesize shininess=_shininess, reflectivity=_reflectivity;
@synthesize shouldUseLighting=_shouldUseLighting;
@synthesize blendFuncRGB=_blendFuncRGB, blendFuncAlpha=_blendFuncAlpha;
@synthesize alphaTestFunction=_alphaTestFunction, alphaTestReference=_alphaTestReference;

-(void) dealloc {
	[_texture release];
	[_textureOverlays release];

	[super dealloc];
}

-(NSString*) nameSuffix { return @"Material"; }

// Clamp to allowed range
-(void) setShininess: (GLfloat) shininess { _shininess = CLAMP(shininess, 0.0, kCC3MaximumMaterialShininess); }

// Clamp to allowed range
-(void) setReflectivity: (GLfloat) reflectivity { _reflectivity = CLAMP(reflectivity, 0.0, 1.0); }

-(GLenum) sourceBlend { return self.sourceBlendRGB; }

-(void) setSourceBlend: (GLenum) aBlend {
	self.sourceBlendRGB = aBlend;
	self.sourceBlendAlpha = aBlend;
}

-(GLenum) destinationBlend { return self.destinationBlendRGB; }

-(void) setDestinationBlend: (GLenum) aBlend {
	self.destinationBlendRGB = aBlend;
	self.destinationBlendAlpha = aBlend;
}

-(GLenum) sourceBlendRGB { return _blendFuncRGB.src; }

-(void) setSourceBlendRGB: (GLenum) aBlend { _blendFuncRGB.src = aBlend; }

-(GLenum) destinationBlendRGB { return _blendFuncRGB.dst; }

-(void) setDestinationBlendRGB: (GLenum) aBlend { _blendFuncRGB.dst = aBlend; }

-(GLenum) sourceBlendAlpha { return _blendFuncAlpha.src; }

-(void) setSourceBlendAlpha: (GLenum) aBlend { _blendFuncAlpha.src = aBlend; }

-(GLenum) destinationBlendAlpha { return _blendFuncAlpha.dst; }

-(void) setDestinationBlendAlpha: (GLenum) aBlend { _blendFuncAlpha.dst = aBlend; }

-(BOOL) shouldBlendAtFullOpacity { return _shouldBlendAtFullOpacity; }

-(void) setShouldBlendAtFullOpacity: (BOOL) shouldBlendAtFullOpacity {
	_shouldBlendAtFullOpacity = shouldBlendAtFullOpacity;
	self.isOpaque = self.isOpaque;
}

-(BOOL) isOpaque { return (self.sourceBlendRGB == GL_ONE && self.destinationBlendRGB == GL_ZERO); }

/**
 * If I should be opaque, turn off alpha blending. If I should not be opaque and I
 * already have a blend, leave it alone. Otherwise, set an appropriate standard blend.
 */
-(void) setIsOpaque: (BOOL) shouldBeOpaque {
	if (shouldBeOpaque) {
		// I should be opaque, so turn off alpha blending altogether.
		self.sourceBlend = GL_ONE;
		self.destinationBlend = GL_ZERO;
	} else {
		// If a source blend has not yet been set AND the texture does NOT contain pre-multiplied
		// alpha, set a source alpha blend. If the texture contains pre-multiplied alpha, leave the
		// source blend at GL_ONE and apply the opacity to the color of the material instead.
		BOOL noPreMultAlpha = !self.hasTexturePremultipliedAlpha;
		if ( (self.sourceBlendRGB == GL_ONE) && noPreMultAlpha ) self.sourceBlendRGB = GL_SRC_ALPHA;
		if ( (self.sourceBlendAlpha == GL_ONE) && noPreMultAlpha ) self.sourceBlendAlpha = GL_SRC_ALPHA;
		
		// If destination blend has not yet been set, set it a destination alpha blend.
		if (self.destinationBlendRGB == GL_ZERO) self.destinationBlendRGB = GL_ONE_MINUS_SRC_ALPHA;
		if (self.destinationBlendAlpha == GL_ZERO) self.destinationBlendAlpha = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(BOOL) shouldDrawLowAlpha {
	switch (_alphaTestFunction) {
		case GL_ALWAYS:
		case GL_LESS:
		case GL_LEQUAL:
			return YES;
		default:
			return NO;
	}
}

-(void) setShouldDrawLowAlpha: (BOOL) shouldDraw {
	_alphaTestFunction = shouldDraw ? GL_ALWAYS : GL_GREATER;
}

-(BOOL) shouldApplyOpacityToColor { return self.sourceBlendRGB == GL_ONE && self.hasTexturePremultipliedAlpha; }

-(ccColor4F) effectiveAmbientColor {
	return self.shouldApplyOpacityToColor ? CCC4FBlendAlpha(self.ambientColor) : self.ambientColor;
}

-(ccColor4F) effectiveDiffuseColor {
	return self.shouldApplyOpacityToColor ? CCC4FBlendAlpha(self.diffuseColor) : self.diffuseColor;
}

-(ccColor4F) effectiveSpecularColor {
	return self.shouldApplyOpacityToColor ? CCC4FBlendAlpha(self.specularColor) : self.specularColor;
}

-(ccColor4F) effectiveEmissionColor {
	return self.shouldApplyOpacityToColor ? CCC4FBlendAlpha(self.emissionColor) : self.emissionColor;
}

-(CC3ShaderContext*) shaderContext {
	CC3Assert(NO, @"The shaderProgram and shaderContext properties have moved to CC3MeshNode.");
	return nil;
}

-(void) setShaderContext:(CC3ShaderContext *)shaderContext {
	CC3Assert(NO, @"The shaderProgram and shaderContext properties have moved to CC3MeshNode.");
}

-(CC3ShaderProgram*) shaderProgram {
	CC3Assert(NO, @"The shaderProgram and shaderContext properties have moved to CC3MeshNode.");
	return nil;
}

-(void) setShaderProgram: (CC3ShaderProgram*) shaderProgram {
	CC3Assert(NO, @"The shaderProgram and shaderContext properties have moved to CC3MeshNode.");
}


#pragma mark CCRGBAProtocol & CCBlendProtocol support

-(ccColor3B) color { return CCC3BFromCCC4F(_diffuseColor); }

// Set both diffuse and ambient colors, retaining the alpha of each
-(void) setColor: (ccColor3B) color {
	GLfloat rf = CCColorFloatFromByte(color.r);
	GLfloat gf = CCColorFloatFromByte(color.g);
	GLfloat bf = CCColorFloatFromByte(color.b);
	
	_ambientColor.r = rf;
	_ambientColor.g = gf;
	_ambientColor.b = bf;
	
	_diffuseColor.r = rf;
	_diffuseColor.g = gf;
	_diffuseColor.b = bf;
}

-(GLubyte) opacity { return CCColorByteFromFloat(_diffuseColor.a); }

/**
 * Set opacity of all colors, retaining the colors of each, and sets the isOpaque property
 * to the appropriate value. This is a convenience that ensures that a previously opaque node
 * can be faded without having to turn isOpaque off separately.
 */
-(void) setOpacity: (GLubyte) opacity {
	GLfloat af = CCColorFloatFromByte(opacity);
	_ambientColor.a = af;
	_diffuseColor.a = af;
	_specularColor.a = af;
	_emissionColor.a = af;

	// As a convenience, set the blending to be compatible with the opacity level.
	// If the opacity has been reduced below full, set isOpaque to NO to ensure alpha
	// blending will occur. If the opacity is full, set isOpaque to YES only if if the
	// shouldBlendAtFullOpacity flag is set to YES. This ensures that a texture
	// with transparency will still blend, even when this material is at full opacity.
	self.isOpaque = (opacity == 255 && !self.shouldBlendAtFullOpacity);
}

-(ccColor3B) displayedColor { return self.color; }

-(BOOL) isCascadeColorEnabled { return NO; }

-(void) setCascadeColorEnabled:(BOOL)cascadeColorEnabled {}

-(void) updateDisplayedColor: (ccColor3B) color {}

-(GLubyte) displayedOpacity { return self.opacity; }

-(BOOL) isCascadeOpacityEnabled { return NO; }

-(void) setCascadeOpacityEnabled: (BOOL) cascadeOpacityEnabled {}

-(void) updateDisplayedOpacity: (GLubyte) opacity {}

-(ccBlendFunc) blendFunc { return self.blendFuncRGB; }

-(void) setBlendFunc: (ccBlendFunc) blendFunc {
	self.blendFuncRGB = blendFunc;
	self.blendFuncAlpha = blendFunc;
}

static ccBlendFunc _defaultBlendFunc = {GL_ONE, GL_ZERO};

+(ccBlendFunc) defaultBlendFunc { return _defaultBlendFunc; }

+(void) setDefaultBlendFunc: (ccBlendFunc) aBlendFunc { _defaultBlendFunc = aBlendFunc; }


#pragma mark Textures

-(GLuint) textureCount { return (_textureOverlays ? (GLuint)_textureOverlays.count : 0) + (_texture ? 1 : 0); }

-(CC3Texture*) texture { return _texture; }

-(void) setTexture: (CC3Texture*) aTexture {
	if (aTexture == _texture) return;
	
	[_texture release];
	_texture = [aTexture retain];
	
	[self texturesHaveChanged];
}

// If the texture property has not been set yet, set it. Otherwise add as an overlay.
-(void) addTexture: (CC3Texture*) aTexture {
	LogTrace(@"Adding %@ to %@", aTexture, self);
	if (!_texture) {
		self.texture = aTexture;
	} else {
		CC3Assert(aTexture, @"%@ cannot add a nil overlay texture", self);
		if(!_textureOverlays) _textureOverlays = [NSMutableArray new];		// retained

		GLuint maxTexUnits = CC3OpenGL.sharedGL.maxNumberOfTextureUnits;
		if (self.textureCount < maxTexUnits) {
			[_textureOverlays addObject: aTexture];
		} else {
			LogInfo(@"Attempt to add texture %@ to %@ ignored because platform supports only %i texture units.",
					aTexture, self, maxTexUnits);
		}
		[self texturesHaveChanged];
	}
}

// If it's the texture property, clear it, otherwise remove the overlay.
-(void) removeTexture: (CC3Texture*) aTexture {
	LogTrace(@"Removing %@ from %@", aTexture, self);
	if (aTexture == _texture) {
		self.texture = nil;
	} else {
		if (_textureOverlays && aTexture) {
			[_textureOverlays removeObjectIdenticalTo: aTexture];
			[self texturesHaveChanged];
			if (_textureOverlays.count == 0) {
				[_textureOverlays release];
				_textureOverlays = nil;
			}
		}
	}
}

-(void) removeAllTextures {
	// Remove the first texture
	[self removeTexture: _texture];

	// Remove the overlay textures
	if (_textureOverlays) {
		NSArray* myOTs = [_textureOverlays copy];
		for (CC3Texture* ot in myOTs) [self removeTexture: ot];
		[myOTs release];
	}
}

-(CC3Texture*) textureForTextureUnit: (GLuint) texUnit {
	if (texUnit == 0) return _texture;
	
	texUnit--;	// Remaining texture units are indexed into the overlays array
	if (texUnit < _textureOverlays.count) return [_textureOverlays objectAtIndex: texUnit];

	return nil;
}

-(void) setTexture: (CC3Texture*) aTexture forTextureUnit: (GLuint) texUnit {
	if (texUnit == 0) {
		self.texture = aTexture;
	} else if (texUnit < self.textureCount) {
		CC3Assert(aTexture, @"%@ cannot set an overlay texture to nil", self);
		GLuint overlayIdx = texUnit - 1;
		if ( aTexture != [_textureOverlays objectAtIndex: overlayIdx]) {
			[_textureOverlays replaceObjectAtIndex: overlayIdx withObject: aTexture];
			[self texturesHaveChanged];
		}
	} else {
		[self addTexture: aTexture];
	}
}

// Returns a texture if name is equal or both are nil.
-(CC3Texture*) getTextureNamed: (NSString*) aName {
	NSString* tcName;
	
	// First check if the first texture is the one
	if (_texture) {
		tcName = _texture.name;
		if ([tcName isEqual: aName] || (!tcName && !aName)) return _texture;
	}
	// Then look for it in the overlays array
	if (_textureOverlays) {
		for (CC3Texture* ot in _textureOverlays) {
			tcName = ot.name;
			if ([tcName isEqual: aName] || (!tcName && !aName)) return ot;
		}
	}
	return nil;
}

/**
 * The textures have changed in some way.
 *
 * Updates the blend, by setting the shouldBlendAtFullOpacity property, based on whether
 * any textures have an alpha channel, which in turn will update the isOpaque property.
 */
-(void) texturesHaveChanged {
	self.shouldBlendAtFullOpacity = self.hasTextureAlpha;
}

-(BOOL) hasTextureAlpha {
	// Check the first texture.
	if (_texture && _texture.hasAlpha) return YES;
	
	// Then check in the overlays array
	for (CC3Texture* ot in _textureOverlays) if (ot.hasAlpha) return YES;
	
	return NO;
}

-(BOOL) hasTexturePremultipliedAlpha {
	// Check the first texture.
	if (_texture && _texture.hasPremultipliedAlpha) return YES;
	
	// Then check in the overlays array
	for (CC3Texture* ot in _textureOverlays) if (ot.hasPremultipliedAlpha) return YES;
	
	return NO;
}

// Deprecated
-(BOOL) hasPremultipliedAlpha { return self.hasTexturePremultipliedAlpha; }

// Check the first texture, hen check in the overlays array
-(CC3Texture*) textureCube {
	if (_texture && _texture.isTextureCube) return _texture;
	for (CC3Texture* ot in _textureOverlays) if (ot.isTextureCube) return ot;
	return NO;
}

-(BOOL) hasTextureCube { return (self.textureCube != nil); }

// Check the first texture, hen check in the overlays array
-(BOOL) hasBumpMap {
	if (_texture && _texture.isBumpMap) return YES;
	for (CC3Texture* ot in _textureOverlays) if (ot.isBumpMap) return YES;
	return NO;
}

-(CC3Vector) lightDirection {
	// Check the first texture.
	if (_texture && _texture.isBumpMap) return _texture.lightDirection;
	
	// Then check in the overlays array
	for (CC3Texture* ot in _textureOverlays) if (ot.isBumpMap) return ot.lightDirection;
	
	return kCC3VectorZero;
}

-(void) setLightDirection: (CC3Vector) aDirection {
	// Set the first texture.
	_texture.lightDirection = aDirection;
	
	// Then set in the overlays array
	for (CC3Texture* ot in _textureOverlays) ot.lightDirection = aDirection;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_texture = nil;
		_textureOverlays = nil;
		_ambientColor = kCC3DefaultMaterialColorAmbient;
		_diffuseColor = kCC3DefaultMaterialColorDiffuse;
		_specularColor = kCC3DefaultMaterialColorSpecular;
		_emissionColor = kCC3DefaultMaterialColorEmission;
		_shininess = kCC3DefaultMaterialShininess;
		_reflectivity = kCC3DefaultMaterialReflectivity;
		self.blendFunc = [[self class] defaultBlendFunc];
		_shouldBlendAtFullOpacity = NO;
		_alphaTestFunction = GL_ALWAYS;
		_alphaTestReference = 0.0f;
		_shouldUseLighting = YES;
	}
	return self;
}

+(id) material { return [[[self alloc] init] autorelease]; }

+(id) materialWithTag: (GLuint) aTag { return [[[self alloc] initWithTag: aTag] autorelease]; }

+(id) materialWithName: (NSString*) aName { return [[[self alloc] initWithName: aName] autorelease]; }

+(id) materialWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

+(id) shiny {
	CC3Material* mat = [self material];
	mat.specularColor = kCCC4FWhite;
	mat.shininess = 75.0f;
	return mat;
}

+(id) shinyWhite {
	CC3Material* mat = [self shiny];
	mat.diffuseColor = kCCC4FWhite;
	return mat;
}

// Protected properties for copying
-(NSArray*) textureOverlays { return _textureOverlays; }

-(void) populateFrom: (CC3Material*) another {
	[super populateFrom: another];

	_ambientColor = another.ambientColor;
	_diffuseColor = another.diffuseColor;
	_specularColor = another.specularColor;
	_emissionColor = another.emissionColor;
	_shininess = another.shininess;
	_reflectivity = another.reflectivity;
	_blendFuncRGB = another.blendFuncRGB;
	_blendFuncAlpha = another.blendFuncAlpha;
	_alphaTestFunction = another.alphaTestFunction;
	_alphaTestReference = another.alphaTestReference;
	_shouldUseLighting = another.shouldUseLighting;
	
	[_texture release];
	_texture = [another.texture retain];	// retained - don't want to trigger texturesHaveChanged
	
	// Remove any existing overlays and add the overlays from the other material.
	[_textureOverlays removeAllObjects];
	NSArray* otherOTs = another.textureOverlays;
	for (CC3Texture* ot in otherOTs) [self addTexture: ot];		// retained by collection
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@using lighting, ambient: %@, diffuse: %@, specular: %@,"
			@" emission: %@, shininess: %.2f, reflectivity: %.3f, blendRGB: (%@, %@), blendAlpha: (%@, %@),"
			@" alpha test: (%@, %.3f), with %u textures",
			[super fullDescription], (_shouldUseLighting ? @"" : @"not"),
			NSStringFromCCC4F(_ambientColor), NSStringFromCCC4F(_diffuseColor),
			NSStringFromCCC4F(_specularColor), NSStringFromCCC4F(_emissionColor),
			_shininess, _reflectivity,
			NSStringFromGLEnum(self.sourceBlendRGB), NSStringFromGLEnum(self.destinationBlendRGB),
			NSStringFromGLEnum(self.sourceBlendAlpha), NSStringFromGLEnum(self.destinationBlendAlpha),
			NSStringFromGLEnum(_alphaTestFunction), _alphaTestReference,
			self.textureCount];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Materials.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedMaterialTag;

-(GLuint) nextTag { return ++lastAssignedMaterialTag; }

+(void) resetTagAllocation { lastAssignedMaterialTag = 0; }


#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	[self applyAlphaTestWithVisitor: visitor];
	[self applyBlendWithVisitor: visitor];
	[self applyColorsWithVisitor: visitor];
	[self drawTexturesWithVisitor: visitor];
}

/**
 * Enables or disables alpha testing in the GL engine, depending on the whether or not
 * the alphaTestFunction indicates that alpha testing should occur, and applies the
 * alphaTestFunction and alphaTestReference properties.
 */
-(void) applyAlphaTestWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	BOOL shouldAlphaTest = (_alphaTestFunction != GL_ALWAYS);
	[gl enableAlphaTesting: shouldAlphaTest];
	if (shouldAlphaTest) [gl setAlphaFunc: _alphaTestFunction reference: _alphaTestReference];
}

/**
 * Enables or disables blending in the GL engine, depending on the whether or not this
 * instance is opaque or not, and applies the sourceBlend and destinationBlend properties.
 */
-(void) applyBlendWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	BOOL shouldBlend = !self.isOpaque;
	[gl enableBlend: shouldBlend];
	if (shouldBlend) [gl setBlendFuncSrcRGB: _blendFuncRGB.src
									 dstRGB: _blendFuncRGB.dst
								   srcAlpha: _blendFuncAlpha.src
								   dstAlpha: _blendFuncAlpha.dst];
}

/**
 * If the shouldUseLighting property is YES, applies the color and shininess properties to
 * the GL engine, otherwise turns lighting off and applies diffuse color as a flat color.
 */
-(void) applyColorsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	if (_shouldUseLighting) {
		[gl enableLighting: YES];
		gl.materialAmbientColor = self.effectiveAmbientColor;
		gl.materialDiffuseColor = self.effectiveDiffuseColor;
		gl.materialSpecularColor = self.effectiveSpecularColor;
		gl.materialEmissionColor = self.effectiveEmissionColor;
		gl.materialShininess = self.shininess;
	} else {
		[gl enableLighting: NO];
	}
	visitor.currentColor = self.effectiveDiffuseColor;
}

/**
 * Draws the texture property and the texture overlays using separate GL texture units. 
 * The visitor keeps track of which texture unit is being processed, with each texture 
 * incrementing the appropriate texture unit index as it draws.
 *
 * The 2D texture are assigned to the lower texture units, and cube-map textures are assigned
 * to texture units above all the 2D textures. This ensures that the same texture types are
 * consistently assigned to the shader samplers, to avoid the shaders recompiling on the
 * fly to adapt to changing texture types.
 *
 * GL texture units of each type that were not used by the textures are disabled by the
 * mesh node after this method is complete.
 */
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[_texture drawWithVisitor: visitor];
	for (CC3Texture* ot in _textureOverlays) [ot drawWithVisitor: visitor];
}

+(void) unbindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	[gl enableLighting: NO];
	[gl enableBlend: NO];
	[gl enableAlphaTesting: NO];
}

@end
