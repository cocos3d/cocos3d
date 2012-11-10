/*
 * CC3Material.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3OpenGLES11Engine.h"
#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"


@interface CC3Material (TemplateMethods)
-(void) texturesHaveChanged;
-(void) applyAlphaTest;
-(void) applyBlend;
-(void) applyColors;
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(BOOL) switchingMaterial;
@end

@implementation CC3Material

@synthesize ambientColor, diffuseColor, specularColor, emissionColor, shininess, blendFunc;
@synthesize shouldUseLighting, alphaTestFunction, alphaTestReference;

-(void) dealloc {
	[texture release];
	[textureOverlays release];
	[super dealloc];
}

-(NSString*) nameSuffix { return @"Material"; }

// Clamp to allowed range
-(void) setShininess: (GLfloat) aValue { shininess = CLAMP(aValue, 0.0, kCC3MaximumMaterialShininess); }

-(GLenum) sourceBlend { return blendFunc.src; }

-(void) setSourceBlend: (GLenum) aBlend { blendFunc.src = aBlend; }

-(GLenum) destinationBlend { return blendFunc.dst; }

-(void) setDestinationBlend: (GLenum) aBlend { blendFunc.dst = aBlend; }

-(BOOL) isOpaque { return (blendFunc.src == GL_ONE && blendFunc.dst == GL_ZERO); }

/**
 * If I should be opaque, turn off alpha blending. If I should not be opaque and I
 * already have a blend, leave it alone. Otherwise, set an appropriate standard blend.
 */
-(void) setIsOpaque: (BOOL) shouldBeOpaque {
	if (shouldBeOpaque) {
		// I should be opaque, so turn off alpha blending altogether.
		blendFunc.src = GL_ONE;
		blendFunc.dst = GL_ZERO;
	} else {
		// If a source blend has not yet been set AND the texture does NOT contain pre-multiplied
		// alpha, set a source alpha blend. If the texture contains pre-multiplied alpha, leave the
		// source blend at GL_ONE and apply the opacity to the color of the material instead.
		if ( (blendFunc.src == GL_ONE) && !self.hasPremultipliedAlpha ) blendFunc.src = GL_SRC_ALPHA;
		
		// If destination blend has not yet been set, set it a destination alpha blend.
		if (blendFunc.dst == GL_ZERO) blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(BOOL) shouldDrawLowAlpha {
	switch (alphaTestFunction) {
		case GL_ALWAYS:
		case GL_LESS:
		case GL_LEQUAL:
			return YES;
		default:
			return NO;
	}
}

-(void) setShouldDrawLowAlpha: (BOOL) shouldDraw {
	alphaTestFunction = shouldDraw ? GL_ALWAYS : GL_GREATER;
}


#pragma mark CCRGBAProtocol & CCBlendProtocol support

-(ccColor3B) color { return CCC3BFromCCC4F(diffuseColor); }

// Set both diffuse and ambient colors, retaining the alpha of each
-(void) setColor: (ccColor3B) color {
	GLfloat rf = CCColorFloatFromByte(color.r);
	GLfloat gf = CCColorFloatFromByte(color.g);
	GLfloat bf = CCColorFloatFromByte(color.b);
	
	ambientColor.r = rf;
	ambientColor.g = gf;
	ambientColor.b = bf;
	
	diffuseColor.r = rf;
	diffuseColor.g = gf;
	diffuseColor.b = bf;
}

-(GLubyte) opacity { return CCColorByteFromFloat(diffuseColor.a); }

/**
 * Set opacity of all colors, retaining the colors of each, and sets the isOpaque property
 * to the appropriate value. This is a convenience that ensures that a previously opaque node
 * can be faded without having to turn isOpaque off separately.
 */
-(void) setOpacity: (GLubyte) opacity {
	GLfloat af = CCColorFloatFromByte(opacity);
	ambientColor.a = af;
	diffuseColor.a = af;
	specularColor.a = af;
	emissionColor.a = af;

	// As a convenience, if we're trying to reduce opacity, make sure the isOpaque
	// flag is compatible with that. We do NOT force it the other way, because the
	// texture may contain translucency, even if the material colors are fully opaque.
	if (opacity < 255) self.isOpaque = NO;
}

static ccBlendFunc defaultBlendFunc = {GL_ONE, GL_ZERO};

+(ccBlendFunc) defaultBlendFunc { return defaultBlendFunc; }

+(void) setDefaultBlendFunc: (ccBlendFunc) aBlendFunc { defaultBlendFunc = aBlendFunc; }


#pragma mark Textures

-(GLuint) textureCount {
	return (textureOverlays ? textureOverlays.count : 0) + (texture ? 1 : 0);
}

-(CC3Texture*) texture { return texture; }

-(void) setTexture: (CC3Texture*) aTexture {
	if (aTexture == texture) return;
	[texture release];
	texture = [aTexture retain];
	[self texturesHaveChanged];
}

// If the texture property has not been set yet, set it. Otherwise add as an overlay.
-(void) addTexture: (CC3Texture*) aTexture {
	LogTrace(@"Adding %@ to %@", aTexture, self);
	if (!texture) {
		self.texture = aTexture;
	} else {
		NSAssert1(aTexture, @"%@ cannot add a nil overlay texture", self);
		if(!textureOverlays) {
			textureOverlays = [[CCArray array] retain];
		}
		GLint maxTexUnits = [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value;
		if (self.textureCount < maxTexUnits) {
			[textureOverlays addObject: aTexture];
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
	if (texture == aTexture) {
		self.texture = nil;
	} else {
		if (textureOverlays && aTexture) {
			[textureOverlays removeObjectIdenticalTo: aTexture];
			[self texturesHaveChanged];
			if (textureOverlays.count == 0) {
				[textureOverlays release];
				textureOverlays = nil;
			}
		}
	}
}

-(void) removeAllTextures {
	// Remove the first texture
	[self removeTexture: texture];

	// Remove the overlay textures
	if (textureOverlays) {
		CCArray* myOTs = [textureOverlays autoreleasedCopy];
		for (CC3Texture* ot in myOTs) {
			[self removeTexture: ot];
		}
	}
}

-(CC3Texture*) textureForTextureUnit: (GLuint) texUnit {
	// If first texture unit, return texture property, otherwise retrieve from overlay array
	if (texUnit == 0) {
		return texture;
	} else {
		return [textureOverlays objectAtIndex: (texUnit - 1)];
	}
}

-(void) setTexture: (CC3Texture*) aTexture forTextureUnit: (GLuint) texUnit {
	if (texUnit == 0) {
		self.texture = aTexture;
	} else if (texUnit < self.textureCount) {
		NSAssert1(aTexture, @"%@ cannot set an overlay texture to nil", self);
		[textureOverlays fastReplaceObjectAtIndex: (texUnit - 1) withObject: aTexture];
		[self texturesHaveChanged];
	} else {
		[self addTexture: aTexture];
	}
}

-(CC3Texture*) getTextureNamed: (NSString*) aName {
	NSString* tcName;
	
	// First check if the first texture is the one
	if (texture) {
		tcName = texture.name;
		if ([tcName isEqual: aName] || (!tcName && !aName)) {		// Name equal or both nil.
			return texture;
		}
	}
	// Then look for it in the overlays array
	if (textureOverlays) {
		for (CC3Texture* ot in textureOverlays) {
			tcName = ot.name;
			if ([tcName isEqual: aName] || (!tcName && !aName)) {		// Name equal or both nil.
				return ot;
			}
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
	if (texture && texture.hasPremultipliedAlpha) return YES;
	
	// Then check in the overlays array
	for (CC3Texture* ot in textureOverlays) if (ot.hasPremultipliedAlpha) return YES;
	
	return NO;
}

-(BOOL) shouldApplyOpacityToColor {
	return blendFunc.src == GL_ONE && self.hasPremultipliedAlpha;
}

-(BOOL) hasBumpMap {
	// Check the first texture.
	if (texture && texture.isBumpMap) return YES;
	
	// Then check in the overlays array
	for (CC3Texture* ot in textureOverlays) if (ot.isBumpMap) return YES;
	
	return NO;
}

-(CC3Vector) lightDirection {
	// Check the first texture.
	if (texture && texture.isBumpMap) return texture.lightDirection;
	
	// Then check in the overlays array
	for (CC3Texture* ot in textureOverlays) if (ot.isBumpMap) return ot.lightDirection;
	
	return kCC3VectorZero;
}

-(void) setLightDirection: (CC3Vector) aDirection {
	// Set the first texture.
	texture.lightDirection = aDirection;
	
	// Then set in the overlays array
	for (CC3Texture* ot in textureOverlays) ot.lightDirection = aDirection;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		texture = nil;
		textureOverlays = nil;
		ambientColor = kCC3DefaultMaterialColorAmbient;
		diffuseColor = kCC3DefaultMaterialColorDiffuse;
		specularColor = kCC3DefaultMaterialColorSpecular;
		emissionColor = kCC3DefaultMaterialColorEmission;
		shininess = kCC3DefaultMaterialShininess;
		blendFunc = [[self class] defaultBlendFunc];
		alphaTestFunction = GL_ALWAYS;
		alphaTestReference = 0.0f;
		shouldUseLighting = YES;
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
-(CCArray*) textureOverlays { return textureOverlays; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Material*) another {
	[super populateFrom: another];

	ambientColor = another.ambientColor;
	diffuseColor = another.diffuseColor;
	specularColor = another.specularColor;
	emissionColor = another.emissionColor;
	shininess = another.shininess;
	blendFunc = another.blendFunc;
	alphaTestFunction = another.alphaTestFunction;
	alphaTestReference = another.alphaTestReference;
	shouldUseLighting = another.shouldUseLighting;
	
	[texture release];
	texture = [another.texture copy];			// retained
	
	// Remove any existing overlays and add the overlays from the other material.
	[textureOverlays removeAllObjects];
	CCArray* otherOTs = another.textureOverlays;
	if (otherOTs) {
		for (CC3Texture* ot in otherOTs) {
			[self addTexture: [ot autoreleasedCopy]];	// retained by collection
		}
	}

}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@using lighting, ambient: %@, diffuse: %@, specular: %@, emission: %@, shininess: %.2f, blend: (%@, %@), alpha test: (%@, %.3f), with %u textures",
			[super fullDescription], (shouldUseLighting ? @"" : @"not"),
			NSStringFromCCC4F(ambientColor), NSStringFromCCC4F(diffuseColor),
			NSStringFromCCC4F(emissionColor), NSStringFromCCC4F(specularColor), shininess,
			NSStringFromGLEnum(blendFunc.src), NSStringFromGLEnum(blendFunc.dst),
			NSStringFromGLEnum(alphaTestFunction), alphaTestReference,
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
		[self applyColors];
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
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	BOOL shouldAlphaTest = (alphaTestFunction != GL_ALWAYS);

	gles11Engine.serverCapabilities.alphaTest.value = shouldAlphaTest;

	if (shouldAlphaTest) {
		[gles11Engine.materials.alphaFunc applyFunction: alphaTestFunction
										   andReference: alphaTestReference];
	}
}

/**
 * Enables or disables blending in the GL engine, depending on the whether or not this
 * instance is opaque or not, and applies the sourceBlend and destinationBlend properties.
 */
-(void) applyBlend {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	BOOL shouldBlend = !self.isOpaque;

	gles11Engine.serverCapabilities.blend.value = shouldBlend;

	if (shouldBlend) {
		[gles11Engine.materials.blendFunc applySource: blendFunc.src
									   andDestination: blendFunc.dst];
	}
}

/**
 * If the shouldUseLighting property is YES, applies the color and shininess properties to
 * the GL engine, otherwise turns lighting off and applies diffuse color as a flat color.
 */
-(void) applyColors {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	if (shouldUseLighting) {
		[gles11Engine.serverCapabilities.lighting enable];

		ccColor4F ambColor = ambientColor;
		ccColor4F difColor = diffuseColor;
		ccColor4F spcColor = specularColor;
		ccColor4F emsColor = emissionColor;
		if (self.shouldApplyOpacityToColor) {
			ambColor = CCC4FBlendAlpha(ambColor);
			difColor = CCC4FBlendAlpha(difColor);
			spcColor = CCC4FBlendAlpha(spcColor);
			emsColor = CCC4FBlendAlpha(emsColor);
		}

		CC3OpenGLES11Materials* gles11Materials = gles11Engine.materials;
		gles11Materials.ambientColor.value = ambColor;
		gles11Materials.diffuseColor.value = difColor;
		gles11Materials.specularColor.value = spcColor;
		gles11Materials.emissionColor.value = emsColor;
		gles11Materials.shininess.value = shininess;
	} else {
		ccColor4F difColor = diffuseColor;
		if (self.shouldApplyOpacityToColor) difColor = CCC4FBlendAlpha(difColor);

		[gles11Engine.serverCapabilities.lighting disable];
		gles11Engine.state.color.value = difColor;
	}
}

/**
 * Draw the texture property and the texture overlays using separate GL texture units
 * The visitor keeps track of which texture unit is being processed, with each texture
 * incrementing the texture unit index as it draws.
 */
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	visitor.textureUnit = 0;
	if (texture) {
		[texture drawWithVisitor: visitor];
	}
	if (textureOverlays) {
		for (CC3Texture* ot in textureOverlays) {
			[ot drawWithVisitor: visitor];
		}
	}
	[CC3Texture	unbindRemainingFrom: visitor.textureUnit];
	visitor.textureUnitCount = visitor.textureUnit;
}

-(void) unbind { [[self class] unbind]; }

+(void) unbind {
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = [CC3OpenGLES11Engine engine].serverCapabilities;
	[gles11ServCaps.lighting disable];
	[gles11ServCaps.blend disable];
	[gles11ServCaps.alphaTest disable];
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
	BOOL shouldSwitch = currentMaterialTag != tag;
	currentMaterialTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

@end
