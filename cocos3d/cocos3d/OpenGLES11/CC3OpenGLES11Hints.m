/*
 * CC3OpenGLES11Hints.m
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
	self.fog = [CC3OpenGLES11StateTrackerHintEnumeration trackerForState: GL_FOG_HINT];
	self.generateMipMap = [CC3OpenGLES11StateTrackerHintEnumeration trackerForState: GL_GENERATE_MIPMAP_HINT];
	self.lineSmooth = [CC3OpenGLES11StateTrackerHintEnumeration trackerForState: GL_LINE_SMOOTH_HINT];
	self.perspectiveCorrection = [CC3OpenGLES11StateTrackerHintEnumeration trackerForState: GL_PERSPECTIVE_CORRECTION_HINT];
	self.pointSmooth = [CC3OpenGLES11StateTrackerHintEnumeration trackerForState: GL_POINT_SMOOTH_HINT];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[fog open];
	[generateMipMap open];
	[lineSmooth open];
	[perspectiveCorrection open];
	[pointSmooth open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[fog close];
	[generateMipMap close];
	[lineSmooth close];
	[perspectiveCorrection close];
	[pointSmooth close];
}

@end
