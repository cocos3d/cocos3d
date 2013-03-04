/*
 * CC3OpenGLES2Matrices.m
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

#import "CC3OpenGLES2Matrices.h"
#import "CC3OpenGLESEngine.h"

#if CC3_OGLES_2

#import "kazmath/GL/matrix.h"	// Only OGLES 2
#import "CC3GLProgram.h"

#pragma mark -
#pragma mark CC3OpenGLES2MatrixStack

@implementation CC3OpenGLES2MatrixStack

-(void) push { kmGLPushMatrix(); }

-(void) pop { kmGLPopMatrix(); }

-(void) identity { kmGLLoadIdentity(); }

-(void) load: (CC3Matrix*) mtx {
	CC3Matrix4x4 m4x4;
	[mtx populateCC3Matrix4x4: &m4x4];
	kmGLLoadMatrix((kmMat4*)&m4x4);
}

-(void) multiply: (CC3Matrix*) mtx {
	CC3Matrix4x4 m4x4;
	[mtx populateCC3Matrix4x4: &m4x4];
	kmGLMultMatrix((kmMat4*)&m4x4);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2ModelviewMatrixStack

@implementation CC3OpenGLES2ModelviewMatrixStack
@end


#pragma mark -
#pragma mark CC3OpenGLES2ProjectionMatrixStack

@implementation CC3OpenGLES2ProjectionMatrixStack

-(void) push {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super push];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

-(void) pop {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super pop];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

-(void) identity {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super identity];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

-(void) load: (CC3Matrix*) mtx {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super load: mtx];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

-(void) multiply: (CC3Matrix*) mtx {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super multiply: mtx];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2Matrices

@implementation CC3OpenGLES2Matrices

-(void) initializeTrackers {
	self.mode = nil;
	self.modelview = [CC3OpenGLES2ModelviewMatrixStack trackerWithParent: self];
	self.projection = [CC3OpenGLES2ProjectionMatrixStack trackerWithParent: self];
	self.activePalette = nil;
	_paletteMatrices = nil;
}

@end

#endif


