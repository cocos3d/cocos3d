/*
 * CC3CALNode.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3CALNode.h for full API documentation.
 */

#import "CC3CALNode.h"
#import "CC3NodeAnimation.h"
#import "CC3VertexSkinning.h"


@implementation CC3CALNode

@synthesize calIndex=_calIndex, calParentIndex=_calParentIndex;
@synthesize isAnimationCorrectedForScale=_isAnimationCorrectedForScale;

-(BOOL) isBaseCALNode { return self.calParentIndex < 0; }

-(void) linkToCALNodes: (NSArray*) nodeArray {
	if ( !self.isBaseCALNode ) {
		LogTrace(@"Linking %@ with parent index %i", self, self.calParentIndex);
		CC3Node* parentNode = [nodeArray objectAtIndex: (GLuint)self.calParentIndex];
		[parentNode addChild: self];
	}
}

-(CC3CALNode*) getNodeWithCALIndex: (GLint) calIndex {
	if (_calIndex == calIndex) return self;
	for (CC3Node* child in _children) {
		CC3CALNode* childResult = [(CC3CALNode*)child getNodeWithCALIndex: calIndex];
		if (childResult) return childResult;
	}
	return nil;
}

-(void)	correctAnimationToSkeletalScale: (CC3Vector) aScale {
	if (self.isAnimationCorrectedForScale) return;
	if ( CC3VectorsAreEqual(aScale, kCC3VectorUnitCube) ) return;
	
	CC3Vector invScale = CC3VectorInvert(aScale);
	for (CC3NodeAnimationState* animState in _animationStates) {
		CC3ArrayNodeAnimation* anim = (CC3ArrayNodeAnimation*)animState.animation;
		CC3Vector* locations = anim.animatedLocations;
		if (locations) {
			GLuint fCnt = anim.frameCount;
			for (GLuint fIdx = 0; fIdx < fCnt; fIdx++)
				locations[fIdx] = CC3VectorScale(locations[fIdx], invScale);
		}
	}
	_isAnimationCorrectedForScale = YES;
}


#pragma mark Allocation and initialization

/** Start with null calIndex & calParentIndex properties. */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_calIndex = -1;
		_calParentIndex = -1;
		_isAnimationCorrectedForScale = NO;
	}
	return self;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (CAL index: %i)", [super description], _calIndex];
}

@end
