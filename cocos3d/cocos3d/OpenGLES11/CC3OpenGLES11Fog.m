/*
 * CC3OpenGLES11Hints.m
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
 * See header file CC3OpenGLES11Hints.h for full API documentation.
 */

#import "CC3OpenGLES11Fog.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFogColor

@implementation CC3OpenGLES11StateTrackerFogColor

-(void) setGLValue {
	glFogfv(name, (GLfloat*)&value);
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFogFloat

@implementation CC3OpenGLES11StateTrackerFogFloat

-(void) setGLValue {
	glFogf(name, value);
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFogEnumeration

@implementation CC3OpenGLES11StateTrackerFogEnumeration

-(void) setGLValue {
	glFogx(name, value);
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Fog

@implementation CC3OpenGLES11Fog

@synthesize color;
@synthesize mode;
@synthesize density;
@synthesize start;
@synthesize end;

-(void) dealloc {
	[color release];
	[mode release];
	[density release];
	[start release];
	[end release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.color = [CC3OpenGLES11StateTrackerFogColor trackerWithParent: self
															 forState: GL_FOG_COLOR];
	self.mode = [CC3OpenGLES11StateTrackerFogEnumeration trackerWithParent: self
																  forState: GL_FOG_MODE];
	self.density = [CC3OpenGLES11StateTrackerFogFloat trackerWithParent: self
															   forState: GL_FOG_DENSITY];
	self.start = [CC3OpenGLES11StateTrackerFogFloat trackerWithParent: self
															 forState: GL_FOG_START];
	self.end = [CC3OpenGLES11StateTrackerFogFloat trackerWithParent: self
														   forState: GL_FOG_END];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", color];
	[desc appendFormat: @"\n    %@ ", mode];
	[desc appendFormat: @"\n    %@ ", density];
	[desc appendFormat: @"\n    %@ ", start];
	[desc appendFormat: @"\n    %@ ", end];
	return desc;
}

@end
