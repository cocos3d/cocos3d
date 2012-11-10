/*
 * CC3OpenGLES11Matrices.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLES11Matrices.h for full API documentation.
 */

#import "CC3OpenGLES11Matrices.h"
#import "CC3OpenGLES11Engine.h"


#pragma mark -
#pragma mark CC3OpenGLES11MatrixStack

@implementation CC3OpenGLES11MatrixStack

-(void) dealloc {
	[modeTracker release];
	[super dealloc];
}

-(void) activate { modeTracker.value = mode; }

-(void) push {
	[self activate];
	glPushMatrix();
	LogGLErrorTrace(@"while pushing %@", self);
}

-(void) pop {
	[self activate];
	glPopMatrix();
	LogGLErrorTrace(@"while popping %@", self);
}

-(GLuint) getDepth {
	[self activate];
	GLuint depth;
	glGetIntegerv(depthName, (GLint*)&depth);
	LogGLErrorTrace(@"while reading GL stack depth %u of %@", depth, self);
	return depth;
}

-(void) identity {
	[self activate];
	glLoadIdentity();
	LogGLErrorTrace(@"while loading identity into %@", self);
}

-(void) load: (GLvoid*) glMatrix {
	[self activate];
	glLoadMatrixf(glMatrix);
	LogGLErrorTrace(@"while loading matrix at %p into %@", glMatrix, self);
}

-(void) getTop: (GLvoid*) glMatrix {
	[self activate];
	glGetFloatv(topName, glMatrix);
	LogGLErrorTrace(@"while reading top of %@ into matrix at %p", self, glMatrix);
}

-(void) multiply: (GLvoid*) glMatrix {
	[self activate];
	glMultMatrixf(glMatrix);
	LogGLErrorTrace(@"while multiplied matrix at %p into %@", glMatrix, self);
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			withMode: (GLenum) matrixMode
		  andTopName: (GLenum) tName
		andDepthName: (GLenum) dName
	  andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		mode = matrixMode;
		topName = tName;
		depthName = dName;
		modeTracker = [aModeTracker retain];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   withMode: (GLenum) matrixMode
			 andTopName: (GLenum) tName
		   andDepthName: (GLenum) dName
		 andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker {
	return [[[self alloc] initWithParent: aTracker
								withMode: matrixMode
							  andTopName: tName
							andDepthName: dName
						  andModeTracker: aModeTracker] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", [super description], NSStringFromGLEnum(mode)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11MatrixPalette

@implementation CC3OpenGLES11MatrixPalette

-(CC3OpenGLES11Matrices*) matricesState { return (CC3OpenGLES11Matrices*)parent; }

-(void) activatePalette { self.matricesState.activePalette.value = index; }

-(void) activate {
	[super activate];
	[self activatePalette];
}

-(void) push { NSAssert1(NO, @"%@ can't be pushed", self); }

-(void) pop { NSAssert1(NO, @"%@ can't be popped", self); }

-(GLuint) getDepth {
	NSAssert1(NO, @"Can't get depth of %@", self);
	return 0;
}

-(void) getTop: (GLvoid*) glMatrix { NSAssert1(NO, @"Can't retrieve top of %@", self); }

-(void) loadFromModelView {
	[self activate];
	glLoadPaletteFromModelViewMatrixOES();
	LogTrace(@"%@ loaded matrix from modelview matrix", self);
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
		  forPalette: (GLint) paletteIndex
	  andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker {
	if ( (self = [super initWithParent: aTracker
							  withMode: GL_MATRIX_PALETTE_OES
							andTopName: GL_ZERO
						  andDepthName: GL_ZERO
						andModeTracker: aModeTracker]) ) {
		index = paletteIndex;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			 forPalette: (GLint) paletteIndex
		 andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) aModeTracker {
	return [[[self alloc] initWithParent: aTracker
							  forPalette: paletteIndex
						  andModeTracker: aModeTracker] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for palette %i", [super description], index];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Matrices

@implementation CC3OpenGLES11Matrices

@synthesize mode;
@synthesize modelview;
@synthesize projection;
@synthesize activePalette;
@synthesize paletteMatrices;

-(void) dealloc {
	[mode release];
	[modelview release];
	[projection release];
	[activePalette release];
	[paletteMatrices release];

	[super dealloc];
}

-(void) initializeTrackers {
	// Matrix mode tracker needs to read and restore
	self.mode = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
															   forState: GL_MATRIX_MODE
													   andGLSetFunction: glMatrixMode
											   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.modelview = [CC3OpenGLES11MatrixStack trackerWithParent: self
														withMode: GL_MODELVIEW 
													  andTopName: GL_MODELVIEW_MATRIX
													andDepthName: GL_MODELVIEW_STACK_DEPTH
												  andModeTracker: mode];

	self.projection = [CC3OpenGLES11MatrixStack trackerWithParent: self
														 withMode: GL_PROJECTION 
													   andTopName: GL_PROJECTION_MATRIX
													 andDepthName: GL_PROJECTION_STACK_DEPTH
												   andModeTracker: mode];

	self.activePalette = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																		forState: GL_ZERO
																andGLSetFunction: glCurrentPaletteMatrixOES
														andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];

	self.paletteMatrices = nil;
}

-(GLuint) paletteMatrixCount { return paletteMatrices ? paletteMatrices.count : 0; }

/** Template method returns an autoreleased instance of a palette matrix tracker. */
-(CC3OpenGLES11MatrixPalette*) makePaletteMatrix: (GLuint) index {
	return [CC3OpenGLES11MatrixPalette trackerWithParent: self forPalette: index andModeTracker: mode];
}

-(CC3OpenGLES11MatrixPalette*) paletteAt: (GLuint) index {
	// If the requested palette matrix hasn't been allocated yet, add it.
	if (index >= self.paletteMatrixCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		NSAssert2(index < self.engine.platform.maxPaletteMatrices.value,
				  @"Request for palette matrix index %u exceeds maximum palette size of %u matrices",
				  index, self.engine.platform.maxPaletteMatrices.value);
		
		// Add all palette matrices between the current count and the requested index.
		for (GLuint i = self.paletteMatrixCount; i <= index; i++) {
			CC3OpenGLES11MatrixPalette* pm = [self makePaletteMatrix: i];
			[pm open];		// Read the initial values
			if (!paletteMatrices) self.paletteMatrices = [CCArray array];
			[paletteMatrices addObject: pm];
			LogTrace(@"%@ added palette matrix %u:\n%@", [self class], i, pm);
		}
	}
	return [paletteMatrices objectAtIndex: index];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", mode];
	[desc appendFormat: @"\n    %@ ", modelview];
	[desc appendFormat: @"\n    %@ ", projection];
	[desc appendFormat: @"\n    %@ ", activePalette];
	for (id pm in paletteMatrices) [desc appendFormat: @"\n%@", pm];
	return desc;
}

@end
