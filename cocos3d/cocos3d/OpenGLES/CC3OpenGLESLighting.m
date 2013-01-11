/*
 * CC3OpenGLESLighting.m
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
 * See header file CC3OpenGLESLighting.h for full API documentation.
 */

#import "CC3OpenGLESLighting.h"
#import "CC3OpenGLESEngine.h" 


#pragma mark -
#pragma mark CC3OpenGLESLight

@implementation CC3OpenGLESLight

@synthesize lightIndex=_lightIndex;
@synthesize light;
@synthesize ambientColor;
@synthesize diffuseColor;
@synthesize specularColor;
@synthesize position;
@synthesize spotDirection;
@synthesize spotExponent;
@synthesize spotCutoffAngle;
@synthesize constantAttenuation;
@synthesize linearAttenuation;
@synthesize quadraticAttenuation;

-(void) dealloc {
	[light release];
	[ambientColor release];
	[diffuseColor release];
	[specularColor release];
	[position release];
	[spotDirection release];
	[spotExponent release];
	[spotCutoffAngle release];
	[constantAttenuation release];
	[linearAttenuation release];
	[quadraticAttenuation release];
	[super dealloc];
}

-(BOOL) isEnabled { return self.light.value; }

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker withLightIndex: (GLuint) ltIndx {
	if ( (self = [super initMinimalWithParent: aTracker]) ) {
		_lightIndex = ltIndx;
		[self initializeTrackers];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker withLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithParent: aTracker withLightIndex: ltIndx] autorelease];
}

/**
 * Since this class can be instantiated dynamically, when opened,
 * open each contained primitive tracker.
 */
-(void) open {
	[super open];
	[light open];
	[ambientColor open];
	[diffuseColor open];
	[specularColor open];
	[position open];
	[spotDirection open];
	[spotExponent open];
	[spotCutoffAngle open];
	[constantAttenuation open];
	[linearAttenuation open];
	[quadraticAttenuation open];
}

@end


#pragma mark -
#pragma mark CC3OpenGLESLighting

@implementation CC3OpenGLESLighting

@synthesize sceneAmbientLight, lights;

-(void) dealloc {
	[sceneAmbientLight release];
	[lights release];
	[super dealloc];
}

-(GLuint) lightCount { return lights ? lights.count : 0; }

-(Class) lightTrackerClass {
	CC3Assert(NO, @"%@ does not implement the lightTrackerClass method.", self);
	return nil;
}

-(CC3OpenGLESLight*) lightAt: (GLuint) ltIndx {
	// If the requested light hasn't been allocated yet, add it.
	if (ltIndx >= self.lightCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		GLuint platformMaxLights = self.engine.platform.maxLights.value;
		GLuint ltMax = MIN(ltIndx, platformMaxLights);
		
		// Add all lights between the current count and the requested texture unit.
		for (GLuint i = self.lightCount; i <= ltMax; i++) {
			CC3OpenGLESLight* lt = [self.lightTrackerClass trackerWithParent: self withLightIndex: i];
			[lt open];		// Read the initial values
			[lights addObject: lt];
			LogTrace(@"%@ added light %u: %@", [self class], i, lt);
		}
	}
	return [lights objectAtIndex: ltIndx];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", sceneAmbientLight];
	for (id t in lights) {
		[desc appendFormat: @"\n    %@ ", t];
	}
	return desc;
}

@end
