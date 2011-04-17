/*
 * CC3OpenGLES11Textures.m
 *
 * cocos3d 0.5.4
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLES11Textures.h for full API documentation.
 */

#import "CC3OpenGLES11Textures.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureBinding

@implementation CC3OpenGLES11StateTrackerTextureBinding

-(void) setGLValue {
	glBindTexture(GL_TEXTURE_2D, value);
}

-(void) unbind {
	self.value = 0;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerActiveTexture

@implementation CC3OpenGLES11StateTrackerActiveTexture

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(GLenum) glEnumValue {
	return GL_TEXTURE0 + value;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(self.glEnumValue);
	}
}

-(void) logSetValue: (BOOL) wasSet {
	LogTrace("%@ %@ %@ = %@", [self class], (wasSet ? @"set" : @"reused"),
			 NSStringFromGLEnum(name), NSStringFromGLEnum(self.glEnumValue));
}

-(void) getGLValue {
	glGetIntegerv(name, (GLint*)&originalValue);
	originalValue -= GL_TEXTURE0;
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %@ (was tracking %@)",
			 [self class], NSStringFromGLEnum(name), NSStringFromGLEnum(GL_TEXTURE0 + originalValue),
			 (valueIsKnown ? NSStringFromGLEnum(self.glEnumValue) : @"UNKNOWN"));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Textures

@implementation CC3OpenGLES11Textures

@synthesize activeTexture;
@synthesize clientActiveTexture;
@synthesize textureBinding;

-(void) dealloc {
	[activeTexture release];
	[clientActiveTexture release];
	[textureBinding release];

	[super dealloc];
}

-(void) initializeTrackers {
	self.activeTexture = [CC3OpenGLES11StateTrackerActiveTexture trackerForState: GL_ACTIVE_TEXTURE
																andGLSetFunction: glActiveTexture];
	self.clientActiveTexture = [CC3OpenGLES11StateTrackerActiveTexture trackerForState: GL_CLIENT_ACTIVE_TEXTURE
																	  andGLSetFunction: glClientActiveTexture];
	self.textureBinding = [CC3OpenGLES11StateTrackerTextureBinding trackerForState: GL_TEXTURE_BINDING_2D];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[activeTexture open];
	[clientActiveTexture open];
	[textureBinding open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[activeTexture close];
	[clientActiveTexture close];
	[textureBinding close];
}



@end
