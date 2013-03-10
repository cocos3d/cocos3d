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
#import "CC3OpenGLESEngine.h"
#import "CC3GLProgramMatchers.h"
#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"


@interface CC3Material (TemplateMethods)
-(void) texturesHaveChanged;
-(void) applyAlphaTest;
-(void) applyBlend;
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(BOOL) switchingMaterial;
@end

@implementation CC3Material

@synthesize ambientColor=_ambientColor, diffuseColor=_diffuseColor;
@synthesize specularColor=_specularColor, emissionColor=_emissionColor;
@synthesize shininess=_shininess, blendFunc=_blendFunc, shouldUseLighting=_shouldUseLighting;
@synthesize alphaTestFunction=_alphaTestFunction, alphaTestReference=_alphaTestReference;
@synthesize shaderContext=_shaderContext;

-(void) dealloc {
	[_texture release];
	[_textureOverlays release];
	[_shaderContext release];
	[super dealloc];
}

-(NSString*) nameSuffix { return @"Material"; }

// Clamp to allowed range
-(void) setShininess: (GLfloat) aValue { _shininess = CLAMP(aValue, 0.0, kCC3MaximumMaterialShininess); }

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

-(CC3GLProgram*) shaderProgram { return _shaderContext.program; }

-(void) setShaderProgram: (CC3GLProgram*) shaderProgram {

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
	self.shaderContext = [CC3GLProgramContext contextForProgram: shaderProgram];
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

	// As a convenience, if we're trying to reduce opacity, make sure the isOpaque
	// flag is compatible with that. We do NOT force it the other way, because the
	// texture may contain translucency, even if the material colors are fully opaque.
	if (opacity < 255) self.isOpaque = NO;
}

-(ccColor3B) displayedColor { return self.color; }

-(BOOL) isCascadeColorEnabled { return NO; }

-(void) setCascadeColorEnabled:(BOOL)cascadeColorEnabled {}

-(void) updateDisplayedColor: (ccColor3B) color {}

-(GLubyte) displayedOpacity { return self.opacity; }

-(BOOL) isCascadeOpacityEnabled { return NO; }

-(void) setCascadeOpacityEnabled: (BOOL) cascadeOpacityEnabled {}

-(void) updateDisplayedOpacity: (GLubyte) opacity {}

static ccBlendFunc defaultBlendFunc = {GL_ONE, GL_ZERO};

+(ccBlendFunc) defaultBlendFunc { return defaultBlendFunc; }

+(void) setDefaultBlendFunc: (ccBlendFunc) aBlendFunc { defaultBlendFunc = aBlendFunc; }


#pragma mark Textures

-(GLuint) textureCount { return (_textureOverlays ? _textureOverlays.count : 0) + (_texture ? 1 : 0); }

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

		GLint maxTexUnits = [CC3OpenGLESEngine engine].platform.maxTextureUnits.value;
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

// If first texture unit, return texture property, otherwise retrieve from overlay array
-(CC3Texture*) textureForTextureUnit: (GLuint) texUnit {
	return (texUnit == 0) ? _texture : [_textureOverlays objectAtIndex: (texUnit - 1)];
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

-(BOOL) hasBumpMap {
	// Check the first texture.
	if (_texture && _texture.isBumpMap) return YES;
	
	// Then check in the overlays array
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
		_blendFunc = [[self class] defaultBlendFunc];
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
	_blendFunc = another.blendFunc;
	_alphaTestFunction = another.alphaTestFunction;
	_alphaTestReference = another.alphaTestReference;
	_shouldUseLighting = another.shouldUseLighting;
	
	self.shaderContext = another.shaderContext;		// retained
	
	[_texture release];
	_texture = [another.texture copy];			// retained - don't want to trigger texturesHaveChanged
	
	// Remove any existing overlays and add the overlays from the other material.
	[_textureOverlays removeAllObjects];
	CCArray* otherOTs = another.textureOverlays;
	for (CC3Texture* ot in otherOTs) {
		[self addTexture: [ot autoreleasedCopy]];	// retained by collection
	}
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@using lighting, ambient: %@, diffuse: %@, specular: %@, emission: %@, shininess: %.2f, blend: (%@, %@), alpha test: (%@, %.3f), with %u textures",
			[super fullDescription], (_shouldUseLighting ? @"" : @"not"),
			NSStringFromCCC4F(_ambientColor), NSStringFromCCC4F(_diffuseColor),
			NSStringFromCCC4F(_specularColor), NSStringFromCCC4F(_emissionColor), _shininess,
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
	if ([self switchingMaterial]) {
		LogTrace(@"Drawing %@", self);
		[self applyAlphaTest];
		[self applyBlend];
		[self applyColorsWithVisitor: visitor];
		[self drawTexturesWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
}

/**
 * Enables or disables alpha testing in the GL engine, depending on the whether or not
 * the alphaTestFunction indicates that alpha testing should occur, and applies the
 * alphaTestFunction and alphaTestReference properties.
 */
-(void) applyAlphaTest {
	CC3OpenGLESEngine* glesEngine = [CC3OpenGLESEngine engine];
	BOOL shouldAlphaTest = (_alphaTestFunction != GL_ALWAYS);
	glesEngine.capabilities.alphaTest.value = shouldAlphaTest;
	if (shouldAlphaTest) [glesEngine.materials.alphaFunc applyFunction: _alphaTestFunction
														  andReference: _alphaTestReference];
}

/**
 * Enables or disables blending in the GL engine, depending on the whether or not this
 * instance is opaque or not, and applies the sourceBlend and destinationBlend properties.
 */
-(void) applyBlend {
	CC3OpenGLESEngine* glesEngine = [CC3OpenGLESEngine engine];
	BOOL shouldBlend = !self.isOpaque;
	glesEngine.capabilities.blend.value = shouldBlend;
	if (shouldBlend) [glesEngine.materials.blendFunc applySource: _blendFunc.src
												  andDestination: _blendFunc.dst];
}

/**
 * If the shouldUseLighting property is YES, applies the color and shininess properties to
 * the GL engine, otherwise turns lighting off and applies diffuse color as a flat color.
 */
-(void) applyColorsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLESEngine* glesEngine = CC3OpenGLESEngine.engine;
	if (_shouldUseLighting) {
		[glesEngine.capabilities.lighting enable];
		CC3OpenGLESMaterials* glesMaterials = glesEngine.materials;
		glesMaterials.ambientColor.value = self.effectiveAmbientColor;
		glesMaterials.diffuseColor.value = self.effectiveDiffuseColor;
		glesMaterials.specularColor.value = self.effectiveSpecularColor;
		glesMaterials.emissionColor.value = self.effectiveEmissionColor;
		glesMaterials.shininess.value = self.shininess;
	} else {
		[glesEngine.capabilities.lighting disable];
		visitor.currentColor = self.effectiveDiffuseColor;
	}
}

/**
 * Draw the texture property and the texture overlays using separate GL texture units
 * The visitor keeps track of which texture unit is being processed, with each texture
 * incrementing the texture unit index as it draws.
 */
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	visitor.textureUnit = 0;

	[_texture drawWithVisitor: visitor];

	for (CC3Texture* ot in _textureOverlays) [ot drawWithVisitor: visitor];
	
	[CC3Texture	unbindRemainingFrom: visitor.textureUnit];
	visitor.textureUnitCount = visitor.textureUnit;
}

-(void) unbind { [[self class] unbind]; }

+(void) unbind {
	CC3OpenGLESCapabilities* glesServCaps = CC3OpenGLESEngine.engine.capabilities;
	[glesServCaps.lighting disable];
	[glesServCaps.blend disable];
	[glesServCaps.alphaTest disable];
	[self resetSwitching];
	[CC3Texture unbind];
}


#pragma mark Material context switching

// The tag of the material that was most recently drawn to the GL engine.
// The GL engine is only updated when a material with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with the
// same material are drawn together, to minimize context switching within the GL engine.
static GLuint currentMaterialTag = 0;

+(void) resetSwitching {
	currentMaterialTag = 0;
}

-(BOOL) switchingMaterial {
	BOOL shouldSwitch = currentMaterialTag != _tag;
	currentMaterialTag = _tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

@end
