/*
 * CC3Material.m
 *
 * cocos3d 0.5.4
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
-(void) apply;
-(void) applyColors;
-(void) applyBlend;
-(void) drawTexture;
-(void) checkIsOpaque;
-(BOOL) switchingMaterial;
@end


@implementation CC3Material

@synthesize ambientColor, diffuseColor, specularColor, emissionColor, shininess;
@synthesize texture, sourceBlend, destinationBlend, isOpaque;

-(void) dealloc {
	[texture release];
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


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		ambientColor = kCC3DefaultMaterialColorAmbient;
		diffuseColor = kCC3DefaultMaterialColorDiffuse;
		specularColor = kCC3DefaultMaterialColorSpecular;
		emissionColor = kCC3DefaultMaterialColorEmission;
		shininess = kCC3DefaultMaterialShininess;
		sourceBlend = [[self class] defaultSourceBlend];
		destinationBlend = [[self class] defaultDestinationBlend];
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

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Material*) another {
	[super populateFrom: another];
	
	[texture release];
	texture = [another.texture copy];			// retained

	ambientColor = another.ambientColor;
	diffuseColor = another.diffuseColor;
	specularColor = another.specularColor;
	emissionColor = another.emissionColor;
	shininess = another.shininess;
	sourceBlend = another.sourceBlend;
	destinationBlend = another.destinationBlend;
	isOpaque = another.isOpaque;
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
	return [NSString stringWithFormat: @"%@, ambient: %@, diffuse: %@, specular: %@, emission: %@, shininess: %.2f, blend: (%@, %@)",
			[super fullDescription], NSStringFromCCC4F(ambientColor),
			NSStringFromCCC4F(diffuseColor), NSStringFromCCC4F(specularColor),
			NSStringFromCCC4F(emissionColor), shininess,
			NSStringFromGLEnum(sourceBlend), NSStringFromGLEnum(destinationBlend)];
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

-(void) draw {
	if ([self switchingMaterial]) {
		[self apply];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
}

/** Applies this material to the GL engine. */
-(void) apply {
	LogTrace(@"Applying %@", self);
	[self applyBlend];
	[self applyColors];
	[self drawTexture];
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

/** Applies the color and shininess properties to the GL engine. */
-(void) applyColors {
	CC3OpenGLES11Materials* gles11Materials = [CC3OpenGLES11Engine engine].materials;
	gles11Materials.ambientColor.value = ambientColor;
	gles11Materials.diffuseColor.value = diffuseColor;
	gles11Materials.specularColor.value = specularColor;
	gles11Materials.emissionColor.value = emissionColor;
	gles11Materials.shininess.value = shininess;
}

/** If this instance has a texture, draw it, otherwise unbind all textures from the GL engine. */
-(void) drawTexture {
	if (texture) {
		[texture draw];
	} else {
		[CC3Texture unbind];
	}
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
