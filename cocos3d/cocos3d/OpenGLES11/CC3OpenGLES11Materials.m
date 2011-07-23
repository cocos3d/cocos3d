/*
 * CC3OpenGLES11Materials.m
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
 * See header file CC3OpenGLES11Materials.h for full API documentation.
 */

#import "CC3OpenGLES11Materials.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerMaterialColor

@implementation CC3OpenGLES11StateTrackerMaterialColor

-(void) getGLValue {
	glGetMaterialfv(GL_FRONT, name, (GLfloat*)&originalValue);
}

-(void) setGLValue {
	glMaterialfv(GL_FRONT_AND_BACK, name, (GLfloat*)&value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerMaterialFloat

@implementation CC3OpenGLES11StateTrackerMaterialFloat

-(void) getGLValue {
	glGetMaterialfv(GL_FRONT, name, (GLfloat*)&originalValue);
}

-(void) setGLValue {
	glMaterialf(GL_FRONT_AND_BACK, name, value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerMaterialBlend

@implementation CC3OpenGLES11StateTrackerMaterialBlend

@synthesize sourceBlend, destinationBlend;

-(void) dealloc {
	[sourceBlend release];
	[destinationBlend release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.sourceBlend = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_BLEND_SRC];
	self.destinationBlend = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_BLEND_DST];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	sourceBlend.originalValueHandling = origValueHandling;
	destinationBlend.originalValueHandling = origValueHandling;
	[super setOriginalValueHandling: origValueHandling];
} 

-(BOOL) valueIsKnown {
	return sourceBlend.valueIsKnown && destinationBlend.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	sourceBlend.valueIsKnown = aBoolean;
	destinationBlend.valueIsKnown = aBoolean;
}

-(void) open {
	[sourceBlend open];
	[destinationBlend open];
}

-(void) restoreOriginalValue {
	[self applySource: sourceBlend.originalValue
	   andDestination: destinationBlend.originalValue];
}

-(void) applySource: (GLenum) srcBlend andDestination: (GLenum) dstBlend {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= [sourceBlend attemptSetValue: srcBlend];
	shouldSetGL |= [destinationBlend attemptSetValue: dstBlend];
	if (shouldSetGL) {
		glBlendFunc(sourceBlend.value, destinationBlend.value);
	}
	LogTrace("%@ %@ %@ = %@ and %@ = %@", [self class], (shouldSetGL ? @"applied" : @"reused"),
			 NSStringFromGLEnum(sourceBlend.name), NSStringFromGLEnum(sourceBlend.value),
			 NSStringFromGLEnum(destinationBlend.name), NSStringFromGLEnum(destinationBlend.value));
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@:\n    %@\n    %@",
			[self class], sourceBlend, destinationBlend];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Materials

@implementation CC3OpenGLES11Materials

@synthesize ambientColor;
@synthesize diffuseColor;
@synthesize specularColor;
@synthesize emissionColor;
@synthesize shininess;
@synthesize blend;

-(void) dealloc {
	[ambientColor release];
	[diffuseColor release];
	[specularColor release];
	[emissionColor release];
	[shininess release];
	[blend release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.ambientColor = [CC3OpenGLES11StateTrackerMaterialColor trackerForState: GL_AMBIENT];
	self.diffuseColor = [CC3OpenGLES11StateTrackerMaterialColor trackerForState: GL_DIFFUSE];
	self.specularColor = [CC3OpenGLES11StateTrackerMaterialColor trackerForState: GL_SPECULAR];
	self.emissionColor = [CC3OpenGLES11StateTrackerMaterialColor trackerForState: GL_EMISSION];
	self.shininess = [CC3OpenGLES11StateTrackerMaterialFloat trackerForState: GL_SHININESS];
	self.blend = [CC3OpenGLES11StateTrackerMaterialBlend tracker];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[ambientColor open];
	[diffuseColor open];
	[specularColor open];
	[emissionColor open];
	[shininess open];
	[blend open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[ambientColor close];
	[diffuseColor close];
	[specularColor close];
	[emissionColor close];
	[shininess close];
	[blend close];
}

@end
