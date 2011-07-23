/*
 * CC3Light.m
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
 * See header file CC3Light.h for full API documentation.
 */

#import "CC3Light.h"
#import "CC3OpenGLES11Engine.h"


#pragma mark CC3Light 

@interface CC3Node (TemplateMethods)
-(void) updateGlobalLocation;
-(void) updateGlobalScale;
-(void) populateFrom: (CC3Node*) another;
@end

@interface CC3Light (TemplateMethods)
-(void) applyLocation;
-(void) applyDirection;
-(void) applyAttenuation;
-(void) applyColor;
-(GLuint) nextLightIndex;
-(void) returnLightIndex: (GLuint) aLightIndex;
+(BOOL*) lightIndexPool;
@end


@implementation CC3Light

@synthesize lightIndex, ambientColor, diffuseColor, specularColor;
@synthesize spotCutoffAngle, isDirectionalOnly, homogeneousLocation, attenuationCoefficients;

-(void) dealloc {
	[gles11Light release];
	[self returnLightIndex: lightIndex];
	[super dealloc];
}

/** Since scale is not used by lights, only consider ancestors. */
-(BOOL) isTransformRigid {
	return (parent ? parent.isTransformRigid : YES);
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		lightIndex = [self nextLightIndex];
		if (lightIndex == UINT_MAX) {		// All the lights have been used already.
			[self release];
			return nil;
		}
		gles11Light = [[[CC3OpenGLES11Engine engine].lighting lightAt: lightIndex] retain];
		homogeneousLocation = CC3Vector4Make(0.0, 0.0, 0.0, 0.0);
		ambientColor = kCC3DefaultLightColorAmbient;
		diffuseColor = kCC3DefaultLightColorDiffuse;
		specularColor = kCC3DefaultLightColorSpecular;
		spotCutoffAngle = kCC3SpotCutoffNone;
		attenuationCoefficients = kCC3DefaultLightAttenuationCoefficients;
		isDirectionalOnly = YES;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Light*) another {
	[super populateFrom: another];
	
	homogeneousLocation = another.homogeneousLocation;
	ambientColor = another.ambientColor;
	diffuseColor = another.diffuseColor;
	specularColor = another.specularColor;
	spotCutoffAngle = another.spotCutoffAngle;
	attenuationCoefficients = another.attenuationCoefficients;
	isDirectionalOnly = another.isDirectionalOnly;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, homoLoc: %@, ambient: %@, diffuse: %@, specular: %@, spotAngle: %.2f, attenuation: %@",
			[super fullDescription], NSStringFromCC3Vector4(homogeneousLocation), NSStringFromCCC4F(ambientColor),
			NSStringFromCCC4F(diffuseColor), NSStringFromCCC4F(specularColor), spotCutoffAngle,
			NSStringFromCC3AttenuationCoefficients(attenuationCoefficients)];
}


#pragma mark Transformations

/** Scaling does not apply to lights. */
-(void) applyScaling {
	[self updateGlobalScale];
}

/**
 * Overridden to determine the overall absolute location (taking into consideration
 * ancestor location) in the 4D homogeneous coordinates used by GL lights. The w component
 * of the homogeneous location is determined by the value of the isDirectionalOnly property.
 */
-(void) updateGlobalLocation {
	[super updateGlobalLocation];
	GLfloat w = isDirectionalOnly ? 0.0 : 1.0;
	homogeneousLocation = CC3Vector4FromCC3Vector(globalLocation, w);
}

/**
 * Scaling does not apply to lights. Sets the globalScale to that of the parent node,
 * or to unit scaling if no parent.
 */
-(void) updateGlobalScale {
	globalScale = parent ? parent.globalScale : kCC3VectorUnitCube;
}


#pragma mark Drawing

-(void) turnOn {
	if (self.visible) {
		LogTrace(@"Turning on %@", self);
		[gles11Light.light enable];
		[self applyLocation];
		[self applyDirection];
		[self applyAttenuation];
		[self applyColor];
	} else {
		[gles11Light.light disable];
	}
}

/**
 * Template method that sets the position of this light in the GL engine to the value of
 * the homogeneousLocation property of this node.
 */	
-(void) applyLocation {
	gles11Light.position.value = homogeneousLocation;
}

/**
 * Template method that sets the spot direction and spot cutoff angle of this light
 * in the GL engine to the values of the globalForwardDirection and spotCutoffAngle
 * properties of this node, respectively.
 */
-(void) applyDirection {
	gles11Light.spotDirection.value = self.globalForwardDirection;
	gles11Light.spotCutoffAngle.value = spotCutoffAngle;
}

/**
 * Template method that sets the light intensity attenuation characteristics
 * in the GL engine from the attenuationCoefficients property of this light.
 */
-(void) applyAttenuation {
	gles11Light.constantAttenuation.value = attenuationCoefficients.a;
	gles11Light.linearAttenuation.value = attenuationCoefficients.b;
	gles11Light.quadraticAttenuation.value = attenuationCoefficients.c;
}

/**
 * Template method that sets the ambient, diffuse and specular colors of this light
 * in the GL engine to the values of the ambientColor, diffuseColor and specularColor
 * properties of this node, respectively.
 */
-(void) applyColor {
	gles11Light.ambientColor.value = ambientColor;
	gles11Light.diffuseColor.value = diffuseColor;
	gles11Light.specularColor.value = specularColor;
}


#pragma mark Managing the pool of available GL lights

// Class variable that tracks the indexes of the lights that are in use.
// When a new instance is instantiated, it's lightIndex property is assigned from the pool
// of indexes. When the instance is deallocated, its index is returned to the pool for use
// by any subsequently instantiated lights.
static BOOL* _lightIndexPool = NULL;

+(BOOL*) lightIndexPool {
	if (!_lightIndexPool) {
		GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
		_lightIndexPool = calloc(platformMaxLights, sizeof(BOOL));
	}
	return _lightIndexPool;
}

// Indicates the staring index to use when instantiating new lights.
static GLuint lightPoolStartIndex = 0;

/**
 * Assigns and returns the next available light index from the pool.
 * If no more lights are available, returns UINT_MAX.
 */
-(GLenum) nextLightIndex {
	BOOL* indexPool = [[self class] lightIndexPool];
	GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
	for (int i = lightPoolStartIndex; i < platformMaxLights; i++) {
		if (!indexPool[i]) {
			indexPool[i] = YES;
			return i;
		}
	}
	NSAssert1(NO, @"Too many lights. Only %u lights may be created.", platformMaxLights);
	return UINT_MAX;
}

/** Returns the specified light index to the pool. */
-(void) returnLightIndex: (GLenum) aLightIndex {
	LogTrace(@"Returning light index %u", aLightIndex);
	BOOL* indexPool = [[self class] lightIndexPool];
	indexPool[aLightIndex] = NO;
	[gles11Light.light disable];
}

+(GLuint) lightCount {
	GLuint count = 0;
	BOOL* indexPool = [self lightIndexPool];
	GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
	for (int i = lightPoolStartIndex; i < platformMaxLights; i++) {
		if (indexPool[i]) {
			count++;
		}
	}
	return lightPoolStartIndex + count;
}

+(GLuint) lightPoolStartIndex {
	return lightPoolStartIndex;
}

+(void) setLightPoolStartIndex: (GLuint) newStartIndex {
	lightPoolStartIndex = newStartIndex;
}

+(void) disableReservedLights {
	for (int i = 0; i < lightPoolStartIndex; i++) {
		[[[CC3OpenGLES11Engine engine].lighting lightAt: i].light disable];
	}
}

@end
