/*
 * CC3OpenGLES1Matrices.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLESMatrices.h for full API documentation.
 */

#import "CC3OpenGLES1Matrices.h"
#import "CC3OpenGLESEngine.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1MatrixStack

@implementation CC3OpenGLES1MatrixStack

-(void) dealloc {
	[_modeTracker release];
	[super dealloc];
}

-(void) activate { _modeTracker.value = _mode; }

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

-(GLuint) depth {
	[self activate];
	GLuint depth;
	glGetIntegerv(_depthName, (GLint*)&depth);
	LogGLErrorTrace(@"while reading GL stack depth %u of %@", depth, self);
	return depth;
}

-(void) identity {
	[self activate];
	glLoadIdentity();
	LogGLErrorTrace(@"while loading identity into %@", self);
}

-(void) load: (CC3Matrix*) mtx {
	[self activate];

	CC3Matrix4x4 glMtx;
	[mtx populateCC3Matrix4x4: &glMtx];

	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"while loading matrix at %@ into %@", mtx, self);
}

-(void) multiply: (CC3Matrix*) mtx {
	[self activate];

	CC3Matrix4x4 glMtx;
	[mtx populateCC3Matrix4x4: &glMtx];

	glMultMatrixf(glMtx.elements);
	LogGLErrorTrace(@"while multiplied matrix %@ into %@", mtx, self);
}


#pragma mark Allocation and initialization

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			withMode: (GLenum) matrixMode
		  andTopName: (GLenum) tName
		andDepthName: (GLenum) dName
	  andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		_mode = matrixMode;
		_topName = tName;
		_depthName = dName;
		_modeTracker = [aModeTracker retain];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   withMode: (GLenum) matrixMode
			 andTopName: (GLenum) tName
		   andDepthName: (GLenum) dName
		 andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker {
	return [[[self alloc] initWithParent: aTracker
								withMode: matrixMode
							  andTopName: tName
							andDepthName: dName
						  andModeTracker: aModeTracker] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", [super description], NSStringFromGLEnum(_mode)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1MatrixPalette

@implementation CC3OpenGLES1MatrixPalette

-(CC3OpenGLESMatrices*) matricesState { return (CC3OpenGLESMatrices*)parent; }

-(void) activatePalette { self.matricesState.activePalette.value = _index; }

-(void) activate {
	[super activate];
	[self activatePalette];
}

-(void) push { CC3Assert(NO, @"%@ can't be pushed", self); }

-(void) pop { CC3Assert(NO, @"%@ can't be popped", self); }

-(GLuint) depth {
	CC3Assert(NO, @"Can't get depth of %@", self);
	return 0;
}

-(void) loadFromModelView {
	[self activate];
	glLoadPaletteFromModelViewMatrixOES();
	LogTrace(@"%@ loaded matrix from modelview matrix", self);
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
		  forPalette: (GLint) paletteIndex
	  andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker {
	if ( (self = [super initWithParent: aTracker
							  withMode: GL_MATRIX_PALETTE_OES
							andTopName: GL_ZERO
						  andDepthName: GL_ZERO
						andModeTracker: aModeTracker]) ) {
		_index = paletteIndex;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			 forPalette: (GLint) paletteIndex
		 andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker {
	return [[[self alloc] initWithParent: aTracker
							  forPalette: paletteIndex
						  andModeTracker: aModeTracker] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for palette %i", [super description], _index];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1Matrices

@implementation CC3OpenGLES1Matrices

-(void) initializeTrackers {
	// Matrix mode tracker needs to read and restore
	self.mode = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
															 forState: GL_MATRIX_MODE
													 andGLSetFunction: glMatrixMode
											 andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];

	self.modelview = [CC3OpenGLES1MatrixStack trackerWithParent: self
													   withMode: GL_MODELVIEW
													 andTopName: GL_MODELVIEW_MATRIX
												   andDepthName: GL_MODELVIEW_STACK_DEPTH
												 andModeTracker: self.mode];

	self.projection = [CC3OpenGLES1MatrixStack trackerWithParent: self
														withMode: GL_PROJECTION
													  andTopName: GL_PROJECTION_MATRIX
													andDepthName: GL_PROJECTION_STACK_DEPTH
												  andModeTracker: self.mode];

	self.activePalette = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	  forState: GL_ZERO
															  andGLSetFunction: glCurrentPaletteMatrixOES
													  andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];

	_paletteMatrices = nil;
	
	_maxPaletteSize = self.engine.platform.maxPaletteMatrices.value;
}

/** Template method returns an autoreleased instance of a palette matrix tracker. */
-(CC3OpenGLESMatrixStack*) makePaletteMatrix: (GLuint) index {
	return [CC3OpenGLES1MatrixPalette trackerWithParent: self forPalette: index andModeTracker: self.mode];
}

-(CC3OpenGLESMatrixStack*) paletteMatrixAt: (GLuint) index {
	// If the requested palette matrix hasn't been allocated yet, add it.
	if (index >= self.paletteMatrixCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		CC3Assert(index < _maxPaletteSize,
				  @"Request for palette matrix index %u exceeds maximum palette size of %u matrices",
				  index, _maxPaletteSize);
		
		// Add all palette matrices between the current count and the requested index.
		for (GLuint i = self.paletteMatrixCount; i <= index; i++) {
			CC3OpenGLESMatrixStack* pm = [self makePaletteMatrix: i];
			[pm open];		// Read the initial values
			if (!_paletteMatrices) _paletteMatrices = [[CCArray array] retain];		// retained
			[_paletteMatrices addObject: pm];
			LogTrace(@"%@ added palette matrix %u:\n%@", [self class], i, pm);
		}
	}
	return [_paletteMatrices objectAtIndex: index];
}

@end

#endif
