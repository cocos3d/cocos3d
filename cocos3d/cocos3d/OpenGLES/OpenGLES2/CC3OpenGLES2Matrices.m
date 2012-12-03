/*
 * CC3OpenGLES2Matrices.m
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
 * See header file CC3OpenGLESMatrices.h for full API documentation.
 */

#import "CC3OpenGLES2Matrices.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2Matrices

@implementation CC3OpenGLES2Matrices

-(void) initializeTrackers {
	// Matrix mode tracker needs to read and restore
	self.mode = nil;
	self.modelview = nil;
	self.projection = nil;
	self.activePalette = nil;
	self.paletteMatrices = nil;
}

/** Template method returns an autoreleased instance of a palette matrix tracker. */
-(CC3OpenGLESMatrixStack*) makePaletteMatrix: (GLuint) index {
	return [CC3OpenGLESMatrixStack trackerWithParent: self
											withMode: GL_ZERO
										  andTopName: GL_ZERO
										andDepthName: GL_ZERO
									  andModeTracker: mode];
}

@end

#endif
