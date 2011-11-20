/*
 * CC3OpenGLES11Lighting.m
 *
 * cocos3d 0.6.4
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
 * See header file CC3OpenGLES11Lighting.h for full API documentation.
 */

#import "CC3OpenGLES11Lighting.h"
#import "CC3OpenGLES11Engine.h" 


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightFloat

@implementation CC3OpenGLES11StateTrackerLightFloat

@synthesize lightIndex;

-(GLenum) glLightIndex {
	return GL_LIGHT0 + lightIndex;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx {
	if ( (self = [super initWithParent: aTracker forState: qName]) ) {
		lightIndex = ltIndx;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithParent: aTracker
								forState: qName
						   andLightIndex: ltIndx] autorelease];
}

-(void) getGLValue {
	glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ %@ read GL value %.2f (was tracking %@)",
			 [self class], NSStringFromGLEnum(self.glLightIndex), NSStringFromGLEnum(name),
			 originalValue, (valueIsKnown ? [NSString stringWithFormat: @"%.2f", value] : @"UNKNOWN"));
}

-(void) setGLValue {
	glLightf(self.glLightIndex, name, value);
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ %@ = %.2f", [self class], NSStringFromGLEnum(self.glLightIndex),
			 (wasSet ? @"set" : @"reused"), NSStringFromGLEnum(name), value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightColor

@implementation CC3OpenGLES11StateTrackerLightColor

@synthesize lightIndex;

-(GLenum) glLightIndex {
	return GL_LIGHT0 + lightIndex;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx {
	if ( (self = [super initWithParent: aTracker forState: qName]) ) {
		lightIndex = ltIndx;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithParent: aTracker
								forState: qName
						   andLightIndex: ltIndx] autorelease];
}

-(void) getGLValue {
	glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(self.glLightIndex), NSStringFromGLEnum(name),
			 NSStringFromCCC4F(originalValue), (valueIsKnown ? NSStringFromCCC4F(value) : @"UNKNOWN"));
}

-(void) setGLValue {
	glLightfv(self.glLightIndex, name, (GLfloat*)&value);
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ %@ = %@", [self class], NSStringFromGLEnum(self.glLightIndex),
			 (wasSet ? @"set" : @"reused"), NSStringFromGLEnum(name), NSStringFromCCC4F(value));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightVector

@implementation CC3OpenGLES11StateTrackerLightVector

@synthesize lightIndex;

-(GLenum) glLightIndex {
	return GL_LIGHT0 + lightIndex;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx {
	if ( (self = [super initWithParent: aTracker forState: qName]) ) {
		lightIndex = ltIndx;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithParent: aTracker
								forState: qName
						   andLightIndex: ltIndx] autorelease];
}

-(void) getGLValue {
	glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(self.glLightIndex), NSStringFromGLEnum(name),
			 NSStringFromCC3Vector(originalValue), (valueIsKnown ? NSStringFromCC3Vector(value) : @"UNKNOWN"));
}

-(void) setGLValue {
	glLightfv(self.glLightIndex, name, (GLfloat*)&value);
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ %@ = %@", [self class], NSStringFromGLEnum(self.glLightIndex),
			 (wasSet ? @"set" : @"reused"), NSStringFromGLEnum(name), NSStringFromCC3Vector(value));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightVector4

@implementation CC3OpenGLES11StateTrackerLightVector4

@synthesize lightIndex;

-(GLenum) glLightIndex {
	return GL_LIGHT0 + lightIndex;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx {
	if ( (self = [super initWithParent: aTracker forState: qName]) ) {
		lightIndex = ltIndx;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithParent: aTracker
								forState: qName
						   andLightIndex: ltIndx] autorelease];
}

-(void) getGLValue {
	glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ %@ read GL value %@ (was tracking %@)", 
			 [self class], NSStringFromGLEnum(self.glLightIndex), NSStringFromGLEnum(name),
			 NSStringFromCC3Vector4(originalValue), (valueIsKnown ? NSStringFromCC3Vector4(value) : @"UNKNOWN"));
}

-(void) setGLValue {
	glLightfv(self.glLightIndex, name, (GLfloat*)&value);
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ %@ = %@", [self class], NSStringFromGLEnum(self.glLightIndex),
			 (wasSet ? @"set" : @"reused"), NSStringFromGLEnum(name), NSStringFromCC3Vector4(value));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Light

@implementation CC3OpenGLES11Light

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

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker withLightIndex: (GLuint) ltIndx {
	if ( (self = [super initMinimalWithParent: aTracker]) ) {
		lightIndex = ltIndx;
		[self initializeTrackers];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker withLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithParent: aTracker withLightIndex: ltIndx] autorelease];
}

-(void) initializeTrackers {
	self.light = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																	 forState: GL_LIGHT0 + lightIndex];
	self.ambientColor = [CC3OpenGLES11StateTrackerLightColor trackerWithParent: self
																	  forState: GL_AMBIENT
																 andLightIndex: lightIndex];
	self.diffuseColor = [CC3OpenGLES11StateTrackerLightColor trackerWithParent: self
																	  forState: GL_DIFFUSE
																 andLightIndex: lightIndex];
	self.specularColor = [CC3OpenGLES11StateTrackerLightColor trackerWithParent: self
																	   forState: GL_SPECULAR
																  andLightIndex: lightIndex];
	self.position = [CC3OpenGLES11StateTrackerLightVector4 trackerWithParent: self
																	forState: GL_POSITION
															   andLightIndex: lightIndex];
	self.spotDirection = [CC3OpenGLES11StateTrackerLightVector trackerWithParent: self
																		forState: GL_SPOT_DIRECTION
																   andLightIndex: lightIndex];
	self.spotExponent = [CC3OpenGLES11StateTrackerLightFloat trackerWithParent: self
																	  forState: GL_SPOT_EXPONENT
																 andLightIndex: lightIndex];
	self.spotCutoffAngle = [CC3OpenGLES11StateTrackerLightFloat trackerWithParent: self
																		 forState: GL_SPOT_CUTOFF
																	andLightIndex: lightIndex];
	self.constantAttenuation = [CC3OpenGLES11StateTrackerLightFloat trackerWithParent: self
																			 forState: GL_CONSTANT_ATTENUATION
																		andLightIndex: lightIndex];
	self.linearAttenuation = [CC3OpenGLES11StateTrackerLightFloat trackerWithParent: self
																		   forState: GL_LINEAR_ATTENUATION
																	  andLightIndex: lightIndex];
	self.quadraticAttenuation = [CC3OpenGLES11StateTrackerLightFloat trackerWithParent: self
																			  forState: GL_QUADRATIC_ATTENUATION
																		 andLightIndex: lightIndex];
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
#pragma mark CC3OpenGLES11StateTrackerWorldLightColor

@implementation CC3OpenGLES11StateTrackerWorldLightColor

-(void) setGLValue {
	glLightModelfv(name, (GLfloat*)&value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Lighting

@implementation CC3OpenGLES11Lighting

@synthesize worldAmbientLight, lights;

-(void) dealloc {
	[worldAmbientLight release];
	[lights release];
	[super dealloc];
}

-(GLuint) lightCount {
	return lights ? lights.count : 0;
}

-(CC3OpenGLES11Light*) lightAt: (GLuint) ltIndx {
	// If the requested light hasn't been allocated yet, add it.
	if (ltIndx >= self.lightCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		GLuint platformMaxLights = self.engine.platform.maxLights.value;
		GLuint ltMax = MIN(ltIndx, platformMaxLights);
		
		// Add all lights between the current count and the requested texture unit.
		for (GLuint i = self.lightCount; i <= ltMax; i++) {
			CC3OpenGLES11Light* lt = [CC3OpenGLES11Light trackerWithParent: self withLightIndex: i];
			[lt open];		// Read the initial values
			[lights addObject: lt];
			LogTrace(@"%@ added light %u: %@", [self class], i, lt);
		}
	}
	return [lights objectAtIndex: ltIndx];
}

-(void) initializeTrackers {
	self.worldAmbientLight = [CC3OpenGLES11StateTrackerWorldLightColor trackerWithParent: self
																				forState: GL_LIGHT_MODEL_AMBIENT];
	self.lights = [CCArray array];		// Start with none. Add them as requested.
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", worldAmbientLight];
	for (id t in lights) {
		[desc appendFormat: @"\n    %@ ", t];
	}
	return desc;
}

@end
