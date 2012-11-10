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

#import "CC3OpenGLES11Hints.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerHintEnumeration

@implementation CC3OpenGLES11StateTrackerHintEnumeration

-(void) setGLValue {
	glHint(name, value);
}

-(void) useNicest {
	value = GL_NICEST;
}

-(void) useFastest {
	value = GL_FASTEST;
}

-(void) useDontCare {
	value = GL_DONT_CARE;
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Hints

@implementation CC3OpenGLES11Hints

@synthesize fog;
@synthesize generateMipMap;
@synthesize lineSmooth;
@synthesize perspectiveCorrection;
@synthesize pointSmooth;

-(void) dealloc {
	[fog release];
	[generateMipMap release];
	[lineSmooth release];
	[perspectiveCorrection release];
	[pointSmooth release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.fog = [CC3OpenGLES11StateTrackerHintEnumeration trackerWithParent: self
																  forState: GL_FOG_HINT];

	// OpenGL Analyzer reports illegal GL enum when trying to read GL value.
	self.generateMipMap = [CC3OpenGLES11StateTrackerHintEnumeration trackerWithParent: self
																			 forState: GL_GENERATE_MIPMAP_HINT
															 andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
				
	self.lineSmooth = [CC3OpenGLES11StateTrackerHintEnumeration trackerWithParent: self
																		 forState: GL_LINE_SMOOTH_HINT];
	self.perspectiveCorrection = [CC3OpenGLES11StateTrackerHintEnumeration trackerWithParent: self
																					forState: GL_PERSPECTIVE_CORRECTION_HINT];
	self.pointSmooth = [CC3OpenGLES11StateTrackerHintEnumeration trackerWithParent: self
																		  forState: GL_POINT_SMOOTH_HINT];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", fog];
	[desc appendFormat: @"\n    %@ ", generateMipMap];
	[desc appendFormat: @"\n    %@ ", lineSmooth];
	[desc appendFormat: @"\n    %@ ", perspectiveCorrection];
	[desc appendFormat: @"\n    %@ ", pointSmooth];
	return desc;
}

@end
