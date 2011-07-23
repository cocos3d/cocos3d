/*
 * CC3Material.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

@interface CC3Material (TemplateMethods)
-(void) applyColors;
-(void) applyBlend;
-(void) drawTexturesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) checkIsOpaque;
-(BOOL) switchingMaterial;
@end

@implementation CC3Material

@synthesize ambientColor, diffuseColor, specularColor, emissionColor, shininess;
@synthesize texture, sourceBlend, destinationBlend, shouldUseLighting, isOpaque;

-(void) dealloc {
	[texture release];
	[textureOverlays release];
	[super dealloc];
}

-(void) setAmbientColor: (ccColor4F) aColor {
	ambientColor = aColor;
	[self checkIsOpaque];
}

-(void) setDiffuseColor: (ccColor4F) aColor {
	diffuseColor = aColor;
	[self checkIsOpaque];
}

-(void) setSpecularColor: (ccColor4F) aColor {
	specularColor = aColor;
	[self checkIsOpaque];
}

-(void) setEmissionColor: (ccColor4F) aColor {
	emissionColor = aColor;
	[self checkIsOpaque];
}

-(void) setShininess: (GLfloat) aValue {
	shininess = CLAMP(aValue, 0.0, kCC3MaximumMaterialShininess);		// clamp to allowed range
}

-(void) setSourceBlend: (GLenum) aBlend {
	sourceBlend = aBlend;
	[self checkIsOpaque];
}

-(void) setDestinationBlend: (GLenum) aBlend {
	destinationBlend = aBlend;
	[self checkIsOpaque];
}

-(void) setIsOpaque: (BOOL) opaque {
	if (opaque) {
		// If we're forcing full opacity, set no alpha blending
		sourceBlend = GL_ONE;
		destinationBlend = GL_ZERO;
	} else {
		// Enable alpha blending. Set destination blend to (1-SRC_ALPHA).
		// Set source blend to SRC_ALPHA unless texture has pre-multiplied alpha AND
		// material is at full opacity. If material is not at full opacity, we must
		// enable source alpha blending even if texture has pre-multiplied alpha.
		BOOL texHasPreMultAlpha = texture && texture.hasPremultipliedAlpha;
		sourceBlend = (texHasPreMultAlpha && self.opacity == 255) ? GL_ONE : GL_SRC_ALPHA;
		destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
	}
	[self checkIsOpaque];
}


#pragma mark CCRGBAProtocol support

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

// Return diffuse color
-(ccColor3B) color {
	return ccc3(CCColorByteFromFloat(diffuseColor.r),
				CCColorByteFromFloat(diffuseColor.g),
				CCColorByteFromFloat(diffuseColor.b));
}

// Return diffuse alpha
-(GLubyte) opacity {
	return CCColorByteFromFloat(diffuseColor.a);
}

/**
 * Set opacity of all colors, retaining the colors of each.
 * If the opacity is less than full, make sure that the isOpaque property
 * is set appropriately. This is a convenience that ensures that a previously
 * opaque node can be faded without having to turn isOpaque off separately.
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
	if (opacity < 255) {
		self.isOpaque = NO;
	}
}

/**
 * Check if this material is opaque, and set the isOpaque flag accordingly.
 *
 * This method is called whenever any of the relevant properties are changed.
 *
 * This implementation is the minimal test of whether destination completely replaces
 * source, by checking that sourceBlend is GL_ONE and destinationBlend is GL_ZERO.
 * Subclasses may choose to implement tests for more sophisticated combinations.
 */
-(void) checkIsOpaque {
	isOpaque = (sourceBlend == GL_ONE && destinationBlend == GL_ZERO);
}


#pragma mark Textures

-(GLuint) textureCount {
	return (textureOverlays ? textureOverlays.count : 0) + (texture ? 1 : 0);
}

-(BOOL) hasBumpMap {
	// Check the first texture.
	if (texture && texture.isBumpMap) {
		return YES;
	}

	// Then check in the overlays array
	if (textureOverlays) {
		for (CC3Texture* ot in textureOverlays) {
			if (ot.isBumpMap) {
				return YES;
			}
		}
	}
	return NO;
}

-(CC3Vector) lightDirection {
	// Check the first texture.
	if (texture && texture.isBumpMap) {
		return texture.lightDirection;
	}
	
	// Then check in the overlays array
	if (textureOverlays) {
		for (CC3Texture* ot in textureOverlays) {
			if (ot.isBumpMap) {
				return ot.lightDirection;
			}
		}
	}
	return kCC3VectorZero;
}

-(void) setLightDirection: (CC3Vector) aDirection {
	// Set the first texture.
	texture.lightDirection = aDirection;
	
	// Then check in the overlays array
	if (textureOverlays) {
		for (CC3Texture* ot in textureOverlays) {
			ot.lightDirection = aDirection;
		}
	}
}

// If the texture property has not been set yet, set it. Otherwise add as an overlay.
-(void) addTexture: (CC3Texture*) aTexture {
	LogTrace(@"Adding %@ to %@", aTexture, self);
	if (aTexture) {
		if (!texture) {
			self.texture = aTexture;
		} else {
			if(!textureOverlays) {
				textureOverlays = [[NSMutableArray array] retain];
			}
			GLint maxTexUnits = [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value;
			if (self.textureCount < maxTexUnits) {
				[textureOverlays addObject: aTexture];
			} else {
				LogInfo(@"Attempt to add texture %@ to %@ ignored because platform supports only %i texture units.",
						aTexture, self, maxTexUnits);
			}
		}
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
		NSArray* myOTs = [textureOverlays copyAutoreleased];
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
	NSAssert(aTexture, @"Overlay texture cannot be nil");
	if (texUnit == 0) {
		self.texture = aTexture;
	} else if (texUnit < self.textureCount) {
		[textureOverlays replaceObjectAtIndex: (texUnit - 1) withObject: aTexture];
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
		sourceBlend = [[self class] defaultSourceBlend];
		destinationBlend = [[self class] defaultDestinationBlend];
		shouldUseLighting = YES;
		[self checkIsOpaque];
	}
	return self;
}

+(id) material {
	return [[[self alloc] init] autorelease];
}

+(id) materialWithTag: (GLuint) aTag {
	return [[[self alloc] initWithTag: aTag] autorelease];
}

+(id) materialWithName: (NSString*) aName {
	return [[[self alloc] initWithName: aName] autorelease];
}

+(id) materialWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

+(id) shiny {
	CC3Material* mat = [self material];
	if (mat) {
		mat.specularColor = kCCC4FWhite;
		mat.shininess = 75.0f;
	}
	return mat;
}

+(id) shinyWhite {
	CC3Material* mat = [self shiny];
	if (mat) {
		mat.diffuseColor = kCCC4FWhite;
	}
	return mat;
}

// Protected properties for copying
-(NSArray*) textureOverlays { return textureOverlays; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Material*) another {
	[super populateFrom: another];

	ambientColor = another.ambientColor;
	diffuseColor = another.diffuseColor;
	specularColor = another.specularColor;
	emissionColor = another.emissionColor;
	shininess = another.shininess;
	sourceBlend = another.sourceBlend;
	destinationBlend = another.destinationBlend;
	shouldUseLighting = another.shouldUseLighting;
	isOpaque = another.isOpaque;
	
	[texture release];
	texture = [another.texture copy];			// retained
	
	// Remove any existing overlays and add the overlays from the other material.
	[textureOverlays removeAllObjects];
	NSArray* otherOTs = another.textureOverlays;
	if (otherOTs) {
		for (CC3Texture* ot in otherOTs) {
			[self addTexture: [ot copyAutoreleased]];	// retained by collection
		}
	}

}

static GLenum defaultSourceBlend = GL_ONE;

+(GLenum) defaultSourceBlend {
	return defaultSourceBlend;
}

+(void) setDefaultSourceBlend: (GLenum) srcBlend {
	defaultSourceBlend = srcBlend;
}

static GLenum defaultDestinationBlend = GL_ZERO;

+(GLenum) defaultDestinationBlend {
	return defaultDestinationBlend;
}

+(void) setDefaultDestinationBlend: (GLenum) destBlend {
	defaultDestinationBlend = destBlend;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, ambient: %@, diffuse: %@, specular: %@, emission: %@, shininess: %.2f, blend: (%@, %@), with %u textures",
			[super fullDescription], NSStringFromCCC4F(ambientColor),
			NSStringFromCCC4F(diffuseColor), NSStringFromCCC4F(specularColor),
			NSStringFromCCC4F(emissionColor), shininess,
			NSStringFromGLEnum(sourceBlend), NSStringFromGLEnum(destinationBlend),
			self.textureCount];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Materials.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedMaterialTag;

-(GLuint) nextTag {
	return ++lastAssignedMaterialTag;
}

+(void) resetTagAllocation {
	lastAssignedMaterialTag = 0;
}


#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ([self switchingMaterial]) {
		[self applyBlend];
		[self applyColors];
		[self drawTexturesWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
}

/**
 * Enables or disables blending in the GL engine, depending on the whether or not this
 * instance is opaque or not, and applies the sourceBlend and destinationBlend properties.
 */
-(void) applyBlend {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	gles11Engine.serverCapabilities.blend.value = !self.isOpaque;
	[gles11Engine.materials.blend applySource: sourceBlend andDestination: destinationBlend];
}

/**
 * If the shouldUseLighting property is YES, applies the color and shininess properties to
 * the GL engine, otherwise turns lighting off and applies emission color as a flat color.
 */
-(void) applyColors {
	if (shouldUseLighting) {
		CC3OpenGLES11Materials* gles11Materials = [CC3OpenGLES11Engine engine].materials;
		gles11Materials.ambientColor.value = ambientColor;
		gles11Materials.diffuseColor.value = diffuseColor;
		gles11Materials.specularColor.value = specularColor;
		gles11Materials.emissionColor.value = emissionColor;
		gles11Materials.shininess.value = shininess;
	} else {
		CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
		[gles11Engine.serverCapabilities.lighting disable];
		gles11Engine.state.color.value = emissionColor;
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

-(void) unbind {
	[[self class] unbind];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].serverCapabilities.blend disable];
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
