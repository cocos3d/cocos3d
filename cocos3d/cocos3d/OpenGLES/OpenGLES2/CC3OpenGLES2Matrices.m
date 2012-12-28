/*
 * CC3OpenGLES2Matrices.m
 *
 * cocos3d 2.0.0
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
#pragma mark CC3OpenGLES2MatrixStack

/** The depth of the modelview matrix stack when the view matrix is at the top. */
#define kCC3ViewMatrixDepth			2


@implementation CC3OpenGLES2MatrixStack

-(void) dealloc {
	free(_mtxStack);
	[super dealloc];
}

-(GLuint) maxDepth { return _maxDepth; }

-(void) setMaxDepth: (GLuint) maxDepth {
	if (maxDepth == _maxDepth) return;
	NSAssert1(maxDepth > 0, @"%@ maxDepth property must be greater than zero.", self);
	GLvoid* newStack = realloc(_mtxStack, (maxDepth * sizeof(CC3Matrix4x4)));
	if (newStack) {
		_mtxStack = newStack;
		_maxDepth = maxDepth;
		if (_depth > _maxDepth) _depth = _maxDepth;
	} else {
		LogError(@"%@ could not allocate space for a matrix stack of depth %u ", self, maxDepth);
	}
}

-(CC3Matrix4x4*) top { return &_mtxStack[_depth - 1]; }

-(void) push {
	NSAssert1(_depth < _maxDepth, @"%@ attempted to push beyond the maximum stack depth.", self);
	CC3Matrix4x4PopulateFrom4x4(&_mtxStack[_depth], self.top);
	_depth++;	// Move the stack index to the new top
	[self wasChanged];
}

-(void) pop {
	NSAssert1(_depth > 1, @"%@ attempted to pop beyond the bottom of the stack.", self);
	_depth--;
	[self wasChanged];
}

-(GLuint) depth { return _depth; }

-(void) identity {
	CC3Matrix4x4PopulateIdentity(self.top);
	[self wasChanged];
}

-(void) load: (CC3Matrix4x4*) mtx {
	CC3Matrix4x4PopulateFrom4x4(self.top, mtx);
	[self wasChanged];
}

-(void) getTop: (CC3Matrix4x4*) mtx { CC3Matrix4x4PopulateFrom4x4(mtx, self.top); }

-(void) multiply: (CC3Matrix4x4*) mtx {
	CC3Matrix4x4 mRslt;
	CC3Matrix4x4Multiply(&mRslt, self.top, mtx);
	CC3Matrix4x4PopulateFrom4x4(self.top, &mRslt);
	[self wasChanged];
}


#pragma mark Allocation and initialization

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
	if ( (self = [super	initWithParent: aTracker]) ) {
		_maxDepth = 0;										// Ensure stack will be set
		self.maxDepth = kCC3OpenGLES2MatrixStackMaxDepth;	// Allocate the stack
		_depth = 1;
		[self identity];
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with maximum depth %u", [super description], _maxDepth];
}

@end

#pragma mark -
#pragma mark CC3OpenGLES2Matrices

@implementation CC3OpenGLES2Matrices

-(void) initializeTrackers {
	// Matrix mode tracker needs to read and restore
	self.mode = nil;
	self.modelview = [CC3OpenGLES2MatrixStack trackerWithParent: self];
	self.projection = [CC3OpenGLES2MatrixStack trackerWithParent: self];
	self.activePalette = nil;
	self.paletteMatrices = nil;
}

/** Template method returns an autoreleased instance of a palette matrix tracker. */
-(CC3OpenGLESMatrixStack*) makePaletteMatrix: (GLuint) index {
	return [CC3OpenGLES2MatrixStack trackerWithParent: self];
}


#pragma mark Accessing matrices

-(void) stackChanged: (CC3OpenGLESMatrixStack*) stack {
	GLuint stackDepth = stack.depth;
	
	if (stack == modelview) {
		[stack getTop: &_modelViewMatrix];
		if (stackDepth <= kCC3ViewMatrixDepth) [stack getTop: &_viewMatrix];
		_modelViewInverseTransposeMatrixIsDirty = YES;
		_modelViewProjectionMatrixIsDirty = YES;
	}

	if (stack == projection) {
		[stack getTop: &_projectionMatrix];
		_modelViewProjectionMatrixIsDirty = YES;
	}

}

-(CC3Matrix4x4*) viewMatrix { return &_viewMatrix; }

-(CC3Matrix4x4*) modelViewMatrix { return &_modelViewMatrix; }

-(CC3Matrix3x3*) modelViewInverseTransposeMatrix {
	CC3Matrix3x3* pMVIT = &_modelViewInverseTransposeMatrix;
	if (_modelViewInverseTransposeMatrixIsDirty) {
		CC3Matrix3x3PopulateFrom4x4(pMVIT, &_modelViewMatrix);
		CC3Matrix3x3InvertAdjoint(pMVIT);
		CC3Matrix3x3Transpose(pMVIT);
		_modelViewInverseTransposeMatrixIsDirty = NO;
	}
	return pMVIT;
}

-(CC3Matrix4x4*) projectionMatrix { return &_projectionMatrix; }

-(CC3Matrix4x4*) modelViewProjectionMatrix {
	if (_modelViewProjectionMatrixIsDirty) {
		CC3Matrix4x4Multiply(&_modelViewProjectionMatrix, &_projectionMatrix, &_modelViewMatrix);
		_modelViewProjectionMatrixIsDirty = NO;
	}
	return &_modelViewProjectionMatrix;
}

@end

#endif
