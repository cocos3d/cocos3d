/*
 * CC3DemoMashUpParticles.m
 *
 * cocos3d 0.6.2
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
 * See header file CC3DemoMashUpParticles.h for full API documentation.
 */

#import "CC3DemoMashUpParticles.h"


#pragma mark -
#pragma mark HangingParticle

@implementation HangingParticle

/**
 * Uses the index of the particle to determine its location relative to the origin of
 * the emitter. The particles are laid out in a simple rectangular grid in the X-Z plane,
 * with kParticlesPerSide particles on each side of the grid.
 *
 * Each particle is assigned a random color and size.
 */
-(void) initializeParticle {
	GLint zIndex = index / kParticlesPerSide;
	GLint xIndex = index % kParticlesPerSide;
	
	GLfloat xStart = -kParticlesPerSide * kParticlesSpacing / 2.0f;
	GLfloat zStart = -kParticlesPerSide * kParticlesSpacing / 2.0f;

	self.location = cc3v(xStart + (xIndex * kParticlesSpacing),
						 0.0,
						 zStart + (zIndex * kParticlesSpacing) );
	
	self.color4F = RandomCCC4FBetween(kCCC4FDarkGray, kCCC4FWhite);
	
	GLfloat avgSize = emitter.particleSize;
	self.size = RandomFloatBetween(avgSize * 0.75, avgSize * 1.25);
}

@end
