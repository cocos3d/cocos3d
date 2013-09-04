/*
 * CC3Material.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3ShaderProgramMatcher.h"
#import "CC3CC2Extensions.h"


@implementation CC3Material

@synthesize ambientColor=_ambientColor, diffuseColor=_diffuseColor;
@synthesize specularColor=_specularColor, emissionColor=_emissionColor;
@synthesize shininess=_shininess, reflectivity=_reflectivity;
@synthesize blendFunc=_blendFunc, shouldUseLighting=_shouldUseLighting;
@synthesize alphaTestFunction=_alphaTestFunction, alphaTestReference=_alphaTestReference;
@synthesize shaderContext=_shaderContext;
@synthesize shouldBlendAtFullOpacity=_shouldBlendAtFullOpacity;

-(void) dealloc {
	[_texture release];
	[_textureOverlays release];
	[_shaderContext release];
	[super dealloc];
}

-(NSString*) nameSuffix { return @"Material"; }

// Clamp to allowed range
-(void) setShininess: (GLfloat) shininess { _shininess = CLAMP(shininess, 0.0, kCC3MaximumMaterialShininess); }

// Clamp to allowed range
-(void) setReflectivity: (GLfloat) reflectivity { _reflectivity = CLAMP(reflectivity, 0.0, 1.0); }

-(GLenum) sourceBlend { return _blendFunc.src; }

-(void) setSourceBlend: (GLenum) aBlend { _blendFunc.src = aBlend; }

-(GLenum) destinationBlend { return _blendFunc.dst; }

-(void) setDestinationBlend: (GLenum) aBlend { _blendFunc.dst = aBlend; }

-(BOOL) isOpaque { return (_blendFunc.src == GL_ONE && _blendFunc.dst == GL_ZERO); }

/**
 * If I should be opaque, turn off alpha blending. If I should not be opaque and I
 * already have a blend, leave it alone. Otherwise, set an appropriate standard blend.
 */
-(void) setIsOpaque: (BOOL) shouldBeOpaque {
	if (shouldBeOpaque) {
		// I should be opaque, so turn off alpha blending altogether.
		_blendFunc.src = GL_ONE;
		_blendFunc.dst = GL_ZERO;
	} else {
		// If a source blend has not yet been set AND the texture does NOT contain pre-multiplied
		// alpha, set a source alpha blend. If the texture contains pre-multiplied alpha, leave the
		// source blend at GL_ONE and apply the opacity to the color of the material instead.
		if ( (_blendFunc.src == GL_ONE) && !self.hasPremultipliedAlpha ) _blendFunc.src = GL_SRC_ALPHA;
		
		// If destination blend has not yet been set, set it a destination alpha blend.
		if (_blendFunc.dst == GL_ZERO) _blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
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

-(BOOL) shouldApplyOpacityToColor {
	return _blendFunc.src == GL_ONE && self.hasPremultipliedAlpha;
}

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

-(CC3ShaderProgram*) shaderProgram { return _shaderContext.program; }

-(void) setShaderProgram: (CC3ShaderProgram*) shaderProgram {

	// Do nothing if not changing
	if (shaderProgram == self.shaderProgram) return;

	// If the shader program is being cleared, clear the context as well
	if (!shaderProgram) {
		self.shaderContext = nil;
		return;
	}
	
	// If the shader context exists, set the specified program into it
	if (_shaderContext) {
		_shaderContext.program = shaderProgram;
		return;
	}
	
	// Shader program does not exist, so create a new one on the program
	self.shaderContext = [CC3ShaderProgramContext contextForProgram: shaderProgram];
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
		if(!_textureOverlays) _textureOverlays = [[CCArray array] retain];

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
	if (_texture == aTexture) {
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
		CCArray* myOTs = [_textureOverlays autoreleasedCopy];
		for (CC3Texture* ot in myOTs) [self removeTexture: ot];
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
		[_textureOverlays fastReplaceObjectAtIndex: (texUnit - 1) withObject: aTexture];
		[self texturesHaveChanged];
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
 * Updates the blend, by setting the isOpaque property from the current value.
 * If something has changed that affects the effective blend, the blend will be updated.
 */
-(void) texturesHaveChanged { self.isOpaque = self.isOpaque; }

-(BOOL) hasPremultipliedAlpha {
	// Check the first texture.
	if (_texture && _texture.hasPremultipliedAlpha) return YES;
	
	// Then check in the overlays array
	for (CC3Texture* ot in _textureOverlays) if (ot.hasPremultipliedAlpha) return YES;
	
	return NO;
}

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
		_shaderContext = nil;
		_ambientColor = kCC3DefaultMaterialColorAmbient;
		_diffuseColor = kCC3DefaultMaterialColorDiffuse;
		_specularColor = kCC3DefaultMaterialColorSpecular;
		_emissionColor = kCC3DefaultMaterialColorEmission;
		_shininess = kCC3DefaultMaterialShininess;
		_reflectivity = kCC3DefaultMaterialReflectivity;
		_blendFunc = [[self class] defaultBlendFunc];
		_shouldBlendAtFullOpacity = NO;
		_alphaTestFunction = GL_ALWAYS;
		_alphaTestReference = 0.0f;
		_shouldUseLighting = YES;
		_shaderContext = nil;
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
-(CCArray*) textureOverlays { return _textureOverlays; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Material*) another {
	[super populateFrom: another];

	_ambientColor = another.ambientColor;
	_diffuseColor = another.diffuseColor;
	_specularColor = another.specularColor;
	_emissionColor = another.emissionColor;
	_shininess = another.shininess;
	_reflectivity = another.reflectivity;
	_blendFunc = another.blendFunc;
	_alphaTestFunction = another.alphaTestFunction;
	_alphaTestReference = another.alphaTestReference;
	_shouldUseLighting = another.shouldUseLighting;
	
	self.shaderContext = another.shaderContext;		// retained
	
	[_texture release];
	_texture = [another.texture retain];			// retained - don't want to trigger texturesHaveChanged
	
	// Remove any existing overlays and add the overlays from the other material.
	[_textureOverlays removeAllObjects];
	CCArray* otherOTs = another.textureOverlays;
	for (CC3Texture* ot in otherOTs) [self addTexture: ot];	// retained by collection
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@using lighting, ambient: %@, diffuse: %@, specular: %@, emission: %@, shininess: %.2f, reflectivity: %.3f, blend: (%@, %@), alpha test: (%@, %.3f), with %u textures",
			[super fullDescription], (_shouldUseLighting ? @"" : @"not"),
			NSStringFromCCC4F(_ambientColor), NSStringFromCCC4F(_diffuseColor),
			NSStringFromCCC4F(_specularColor), NSStringFromCCC4F(_emissionColor),
			_shininess, _reflectivity,
			NSStringFromGLEnum(_blendFunc.src), NSStringFromGLEnum(_blendFunc.dst),
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
	if (shouldBlend) [gl setBlendFuncSrc: _blendFunc.src dst: _blendFunc.dst];
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
 * Draws the texture property and the texture overlays using separate GL texture units
 * The visitor keeps track of which texture unit is being processed, with each texture
 * incrementing the current texture unit index as it draws. GL texture units that were
 * not used by the texture and texture overlays are disabled.
 */
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	visitor.currentTextureUnitIndex = 0;

	[self drawTexture: _texture withVisitor: visitor];

	for (CC3Texture* ot in _textureOverlays) [self drawTexture: ot withVisitor: visitor];
	
	[visitor disableUnusedTextureUnits];
}

/** Draws the specified texture to the GL engine, and then increments the texture unit. */
-(void) drawTexture: (CC3Texture*) texture withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[texture drawWithVisitor: visitor];
	if (texture) visitor.currentTextureUnitIndex += 1;	// Move to next texture unit
}

-(void) unbindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self.class unbindWithVisitor: visitor];
}

+(void) unbindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	[gl enableLighting: NO];
	[gl enableBlend: NO];
	[gl enableAlphaTesting: NO];
	[gl disableTexturingFrom: 0];
}

@end
