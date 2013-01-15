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

#if CC3_OGLES_2

#import "kazmath/GL/matrix.h"

/** The depth of the modelview matrix stack when the view matrix is at the top. */
#define kCC3ViewMatrixDepth			2


#pragma mark -
#pragma mark CC3OpenGLES2MatrixStack

@implementation CC3OpenGLES2MatrixStack

-(void) dealloc {
	free(_mtxStack);
	[super dealloc];
}

-(GLuint) maxDepth { return _maxDepth; }

-(void) setMaxDepth: (GLuint) maxDepth {
	if (maxDepth == _maxDepth) return;
	CC3Assert(maxDepth > 0, @"%@ maxDepth property must be greater than zero.", self);
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
	CC3Assert(_depth < _maxDepth, @"%@ attempted to push beyond the maximum stack depth.", self);
	[self copyTop];
	_depth++;	// Move the stack index to the new top
	[self wasChanged];
	[self push2D];
}

-(void) copyTop { CC3Assert(NO, @"%@ does not implement the copyTop method.", self); }

-(void) pop {
	CC3Assert(_depth > 1, @"%@ attempted to pop beyond the bottom of the stack.", self);
	_depth--;
	[self wasChanged];
	[self pop2D];
}

-(GLuint) depth { return _depth; }

-(void) identity {
	[self wasChanged];
	[self load2D];
}

-(void) load: (CC3Matrix*) mtx {
	[self wasChanged];
	[self load2D];
}

-(void) multiply: (CC3Matrix*) mtx {
	[self wasChanged];
	[self load2D];
}


#pragma mark Managing 2D matrices for CC3Billboards

/** 
 * Pushes the cocos2d matrix stack to keep it aligned with this stack.
 * This ensures that the correct 3D matrices will be applied to CC3Billboards.
 */
-(void) push2D { kmGLPushMatrix(); }

/**
 * Pops the cocos2d matrix stack to keep it aligned with this stack.
 * This ensures that the correct 3D matrices will be applied to CC3Billboards.
 */
-(void) pop2D { kmGLPopMatrix(); }

/**
 * Loads the top of the cocos2d matrix stack with the top of this matrix, to keep it aligned
 * with this stack. This ensures that the correct 3D matrices will be applied to CC3Billboards.
 */
-(void) load2D { kmGLLoadMatrix((kmMat4*)self.top); }


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
#pragma mark CC3OpenGLES2ModelviewMatrixStack

@implementation CC3OpenGLES2ModelviewMatrixStack

-(CC3Matrix4x3*) top4x3 { return (CC3Matrix4x3*)self.top; }

-(void) copyTop { CC3Matrix4x3PopulateFrom4x3((CC3Matrix4x3*)&_mtxStack[_depth], (CC3Matrix4x3*)self.top); }

-(void) identity {
	CC3Matrix4x3PopulateIdentity(self.top4x3);
	[super identity];
}

-(void) load: (CC3Matrix*) mtx {
	[mtx populateCC3Matrix4x3: self.top4x3];
	[super load: mtx];
}

-(void) multiply: (CC3Matrix*) mtx {
	CC3Matrix4x3 mRslt, mAffine;
	[mtx populateCC3Matrix4x3: &mAffine];
	CC3Matrix4x3Multiply(&mRslt, self.top4x3, &mAffine);
	CC3Matrix4x3PopulateFrom4x3(self.top4x3, &mRslt);
	[super multiply: mtx];
}


#pragma mark Managing 2D matrices for CC3Billboards

/** Convert 4x3 matrix to a 4x4 matrix before loading 2D stack. */
-(void) load2D {
	CC3Matrix4x4 mat4;
	CC3Matrix4x4PopulateFrom4x3(&mat4, self.top4x3);
	kmGLLoadMatrix((kmMat4*)&mat4);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2ProjectionMatrixStack

@implementation CC3OpenGLES2ProjectionMatrixStack

-(void) copyTop { CC3Matrix4x4PopulateFrom4x4(&_mtxStack[_depth], self.top); }

-(void) identity {
	CC3Matrix4x4PopulateIdentity(self.top);
	[super identity];
}

-(void) load: (CC3Matrix*) mtx {
	[mtx populateCC3Matrix4x4: self.top];
	[super load: mtx];
}

-(void) multiply: (CC3Matrix*) mtx {
	CC3Matrix4x4 mRslt, mat4;
	[mtx populateCC3Matrix4x4: &mat4];
	CC3Matrix4x4Multiply(&mRslt, self.top, &mat4);
	CC3Matrix4x4PopulateFrom4x4(self.top, &mRslt);
	[super multiply: mtx];
}


#pragma mark Managing 2D matrices for CC3Billboards

/** Temporarily switch to the projection stack. */
-(void) push2D {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super push2D];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

/** Temporarily switch to the projection stack. */
-(void) pop2D {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super pop2D];
	kmGLMatrixMode(KM_GL_MODELVIEW);
}

/** Temporarily switch to the projection stack. */
-(void) load2D {
	kmGLMatrixMode(KM_GL_PROJECTION);
	[super load2D];
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
	self.paletteMatrices = nil;
}

/** Template method returns an autoreleased instance of a palette matrix tracker. */
-(CC3OpenGLESMatrixStack*) makePaletteMatrix: (GLuint) index {
	return [CC3OpenGLES2MatrixStack trackerWithParent: self];
}


#pragma mark Accessing matrices

-(void) stackChanged: (CC3OpenGLES2MatrixStack*) stack {
	GLuint stackDepth = stack.depth;
	if (stack == modelview) {
		// Populate the modelview matrix and mark everything that depends on it dirty.
		CC3Matrix4x3PopulateFrom4x3([self matrix4x3ForSemantic: kCC3MatrixSemanticModelView],
									(CC3Matrix4x3*)stack.top);
		CC3MatrixSemantic dirtySemantics[] = {
			kCC3MatrixSemanticModelViewInv,
			kCC3MatrixSemanticModelViewInvTran,
			
			kCC3MatrixSemanticModelLocal,
			kCC3MatrixSemanticModelLocalInv,
			kCC3MatrixSemanticModelLocalInvTran,
			
			kCC3MatrixSemanticModel,
			kCC3MatrixSemanticModelInv,
			kCC3MatrixSemanticModelInvTran,
			
			kCC3MatrixSemanticModelViewProj,
			kCC3MatrixSemanticModelViewProjInv,
			kCC3MatrixSemanticModelViewProjInvTran,
		};
		[self mark: 11 matricesDirty: dirtySemantics];

		if (stackDepth <= kCC3ViewMatrixDepth) {
			// Populate the view matrix and mark everything that depends on it dirty.
			CC3Matrix4x3PopulateFrom4x3([self matrix4x3ForSemantic: kCC3MatrixSemanticView],
										(CC3Matrix4x3*)stack.top);
			CC3MatrixSemantic dirtySemantics[] = {
				kCC3MatrixSemanticViewInv,
				kCC3MatrixSemanticViewInvTran,
				
				kCC3MatrixSemanticViewProj,
				kCC3MatrixSemanticViewProjInv,
				kCC3MatrixSemanticViewProjInvTran,
			};
			[self mark: 5 matricesDirty: dirtySemantics];
		}
	}
	if (stack == projection) {
		// Populate the projection matrix and mark everything that depends on it dirty.
		CC3Matrix4x4PopulateFrom4x4([self matrix4x4ForSemantic: kCC3MatrixSemanticProj], stack.top);
		CC3MatrixSemantic dirtySemantics[] = {
			kCC3MatrixSemanticProjInv,
			kCC3MatrixSemanticProjInvTran,
			
			kCC3MatrixSemanticViewProj,
			kCC3MatrixSemanticViewProjInv,
			kCC3MatrixSemanticViewProjInvTran,
			
			kCC3MatrixSemanticModelViewProj,
			kCC3MatrixSemanticModelViewProjInv,
			kCC3MatrixSemanticModelViewProjInvTran,
		};
		[self mark: 8 matricesDirty: dirtySemantics];
	}
}

/** Marks the matrix cache dirty for all of the specified matrix semantics. */
-(void) mark: (GLuint) count matricesDirty: (CC3MatrixSemantic[]) semantics {
	for (GLuint i = 0; i < count; i++) _mtxCacheIsDirty[semantics[i]] = YES;
}

-(CC3Matrix3x3*) matrix3x3ForSemantic: (CC3MatrixSemantic) semantic {
	CC3Assert(CC3MatrixSemanticIs3x3(semantic), @"Request for 3x3 matrix of semantic %@, which is not a 3x3 matrix.",
			  NSStringFromCC3MatrixSemantic(semantic));
	[self ensureMatrixForSemantic: semantic];
	return (CC3Matrix3x3*)&_mtxCache[semantic];
}

-(CC3Matrix4x3*) matrix4x3ForSemantic: (CC3MatrixSemantic) semantic {
	CC3Assert(CC3MatrixSemanticIs4x3(semantic), @"Request for 4x3 matrix of semantic %@, which is not a 4x3 matrix.",
			  NSStringFromCC3MatrixSemantic(semantic));
	[self ensureMatrixForSemantic: semantic];
	return (CC3Matrix4x3*)&_mtxCache[semantic];
}

-(CC3Matrix4x4*) matrix4x4ForSemantic: (CC3MatrixSemantic) semantic {
	CC3Assert(CC3MatrixSemanticIs4x4(semantic), @"Request for 4x4 matrix of semantic %@, which is not a 4x4 matrix.",
			  NSStringFromCC3MatrixSemantic(semantic));
	[self ensureMatrixForSemantic: semantic];
	return &_mtxCache[semantic];
}

/**
 * Ensures that the matrix for the specific semantic is up to date.
 *
 * The basic kCC3MatrixSemanticView, kCC3MatrixSemanticModelView and kCC3MatrixSemanticProj
 * matrices are populated outside this method, and so are not handled here.
 */
-(void) ensureMatrixForSemantic: (CC3MatrixSemantic) semantic {
	if ( !_mtxCacheIsDirty[semantic] ) return;

	// Pointers to the source and destination matrices
	CC3Matrix4x4 mat4;
	CC3Matrix4x4* pMtx4x4 = &_mtxCache[semantic];
	CC3Matrix4x3* pMtx4x3 = (CC3Matrix4x3*)pMtx4x4;
	CC3Matrix3x3* pMtx3x3 = (CC3Matrix3x3*)pMtx4x4;

	_mtxCacheIsDirty[semantic] = NO;	// Mark as clean up front

	switch (semantic) {
		case kCC3MatrixSemanticModelLocal:
			CC3Assert(NO, @"Matrix of type %@ is not available.", NSStringFromCC3MatrixSemantic(kCC3MatrixSemanticModelLocal));
			return;
		case kCC3MatrixSemanticModelLocalInv:
			CC3Matrix4x3PopulateFrom4x3(pMtx4x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticModelLocal]);
			CC3Matrix4x3InvertAdjoint(pMtx4x3);
			return;
		case kCC3MatrixSemanticModelLocalInvTran:
			CC3Matrix3x3PopulateFrom4x3(pMtx3x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticModelLocal]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		case kCC3MatrixSemanticModel:
			CC3Matrix4x3Multiply(pMtx4x3,
								 [self matrix4x3ForSemantic: kCC3MatrixSemanticViewInv],
								 [self matrix4x3ForSemantic: kCC3MatrixSemanticModelView]);
			return;
		case kCC3MatrixSemanticModelInv:
			CC3Matrix4x3PopulateFrom4x3(pMtx4x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticModel]);
			CC3Matrix4x3InvertAdjoint(pMtx4x3);
			return;
		case kCC3MatrixSemanticModelInvTran:
			CC3Matrix3x3PopulateFrom4x3(pMtx3x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticModel]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		case kCC3MatrixSemanticView:			// Fundamental - populated outside
			return;
		case kCC3MatrixSemanticViewInv:
			CC3Matrix4x3PopulateFrom4x3(pMtx4x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticView]);
			CC3Matrix4x3InvertAdjoint(pMtx4x3);
			return;
		case kCC3MatrixSemanticViewInvTran:
			CC3Matrix3x3PopulateFrom4x3(pMtx3x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticView]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		case kCC3MatrixSemanticModelView:		// Fundamental - populated outside
			return;
		case kCC3MatrixSemanticModelViewInv:
			CC3Matrix4x3PopulateFrom4x3(pMtx4x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticModelView]);
			CC3Matrix4x3InvertAdjoint(pMtx4x3);
			return;
		case kCC3MatrixSemanticModelViewInvTran:
			CC3Matrix3x3PopulateFrom4x3(pMtx3x3, [self matrix4x3ForSemantic: kCC3MatrixSemanticModelView]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		case kCC3MatrixSemanticProj:			// Fundamental - populated outside
			return;
		case kCC3MatrixSemanticProjInv:
			CC3Matrix4x4PopulateFrom4x4(pMtx4x4, [self matrix4x4ForSemantic: kCC3MatrixSemanticProj]);
			CC3Matrix4x4InvertAdjoint(pMtx4x4);
			return;
		case kCC3MatrixSemanticProjInvTran:
			CC3Matrix3x3PopulateFrom4x4(pMtx3x3, [self matrix4x4ForSemantic: kCC3MatrixSemanticProj]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		case kCC3MatrixSemanticViewProj:
			CC3Matrix4x4PopulateFrom4x3(&mat4, [self matrix4x3ForSemantic: kCC3MatrixSemanticView]);
			CC3Matrix4x4Multiply(pMtx4x4, [self matrix4x4ForSemantic: kCC3MatrixSemanticProj], &mat4);
			return;
		case kCC3MatrixSemanticViewProjInv:
			CC3Matrix4x4PopulateFrom4x4(pMtx4x4, [self matrix4x4ForSemantic: kCC3MatrixSemanticViewProj]);
			CC3Matrix4x4InvertAdjoint(pMtx4x4);
			return;
		case kCC3MatrixSemanticViewProjInvTran:
			CC3Matrix3x3PopulateFrom4x4(pMtx3x3, [self matrix4x4ForSemantic: kCC3MatrixSemanticViewProj]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		case kCC3MatrixSemanticModelViewProj:
			CC3Matrix4x4PopulateFrom4x3(&mat4, [self matrix4x3ForSemantic: kCC3MatrixSemanticModelView]);
			CC3Matrix4x4Multiply(pMtx4x4, [self matrix4x4ForSemantic: kCC3MatrixSemanticProj], &mat4);
			return;
		case kCC3MatrixSemanticModelViewProjInv:
			CC3Matrix4x4PopulateFrom4x4(pMtx4x4, [self matrix4x4ForSemantic: kCC3MatrixSemanticModelViewProj]);
			CC3Matrix4x4InvertAdjoint(pMtx4x4);
			return;
		case kCC3MatrixSemanticModelViewProjInvTran:
			CC3Matrix3x3PopulateFrom4x4(pMtx3x3, [self matrix4x4ForSemantic: kCC3MatrixSemanticModelViewProj]);
			CC3Matrix3x3InvertAdjoint(pMtx3x3);
			CC3Matrix3x3Transpose(pMtx3x3);
			return;

		default: return;
	}
}

@end

#endif


