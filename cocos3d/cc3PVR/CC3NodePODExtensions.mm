/*
 * CC3NodePODExtensions.mm
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
 * See header file CC3NodePODExtensions.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#import "CC3NodePODExtensions.h"
#import "CC3IdentifiablePODExtensions.h"
#import "CC3PVRTModelPOD.h"


#pragma mark CC3Node extensions for PVR POD data

@implementation CC3Node (PVRPOD)

// Subclasses must override to use instance variable.
-(int) podContentIndex { return kCC3PODNilIndex; }

// Subclasses must override to use instance variable.
-(void) setPodContentIndex: (int) aPODIndex {}

// Subclasses must override to use instance variable.
-(int) podParentIndex { return kCC3PODNilIndex; }

// Subclasses must override to use instance variable.
-(void) setPodParentIndex: (int) aPODIndex {}

-(BOOL) isBasePODNode { return self.podParentIndex < 0; }

// Subclasses must override to use instance variable.
-(int) podTargetIndex {return kCC3PODNilIndex;}

// Subclasses must override to use instance variable.
-(void) setPodTargetIndex: (int) aPODIndex {}


#pragma mark Allocation and initialization

-(id) initAtIndex: (int) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	NSAssert1(![self isMemberOfClass:[CC3Node class]], @"%@ is an abstract class and should not be instantiated directly. Use a subclass instead.", [self class]);
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		SPODNode* psn = (SPODNode*)[self nodePODStructAtIndex: aPODIndex
											fromPODResource: (CC3PODResource*) aPODRez];
		LogRez(@"Creating %@ at index %i from: %@", [self class], aPODIndex, NSStringFromSPODNode(psn));
		self.name = [NSString stringWithUTF8String: psn->pszName];
		self.podContentIndex = psn->nIdx;
		self.podParentIndex = psn->nIdxParent;
		if (psn->pfAnimPosition) {
			self.location = *(CC3Vector*)psn->pfAnimPosition;
		}
		if (psn->pfAnimRotation) {
			self.quaternion = *(CC3Vector4*)psn->pfAnimRotation;
		}
		if (psn->pfAnimScale) {
			self.scale = *(CC3Vector*)psn->pfAnimScale;
		}
		if ([CC3PODNodeAnimation sPODNodeDoesContainAnimation: (PODStructPtr)psn]) {
			self.animation = [CC3PODNodeAnimation animationFromSPODNode: (PODStructPtr)psn
														 withFrameCount: aPODRez.animationFrameCount];
		}
	}
	return self; 
}

+(id) nodeAtIndex: (int) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [[[self alloc] initAtIndex: aPODIndex fromPODResource: aPODRez] autorelease];
}

-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [aPODRez nodePODStructAtIndex: aPODIndex];
}

-(void) linkToPODNodes: (CCArray*) nodeArray {
	if (!self.isBasePODNode) {
		LogTrace(@"Linking %@ with parent index %i", self, self.podParentIndex);
		CC3Node* parentNode = [nodeArray objectAtIndex: self.podParentIndex];
		[parentNode addChild: self];
	}
	if (self.podTargetIndex >= 0) {
		LogTrace(@"Linking %@ with target index %i", self, self.podTargetIndex);
		self.target = [nodeArray objectAtIndex: self.podTargetIndex];
	}
}

@end


#pragma mark -
#pragma mark CC3PODNodeAnimation

@implementation CC3PODNodeAnimation

-(void) dealloc {
	[super dealloc];
}

-(id) initFromSPODNode: (PODStructPtr) pSPODNode withFrameCount: (GLuint) numFrames {
	if ( (self = [super initWithFrameCount: numFrames]) ) {

		// Start with no animation
		animatedLocations = animatedQuaternions = animatedScales = NULL;
		
		SPODNode* psn = (SPODNode*)pSPODNode;

		if (psn->pfAnimPosition && (psn->nAnimFlags & ePODHasPositionAni)) {
			animatedLocations = psn->pfAnimPosition;
			animatedLocationIndices = psn->pnAnimPositionIdx;
		}
		
		if (psn->pfAnimRotation && (psn->nAnimFlags & ePODHasRotationAni)) {
			animatedQuaternions = psn->pfAnimRotation;
			animatedQuaternionsIndices = psn->pnAnimRotationIdx;
		}
		
		if (psn->pfAnimScale && (psn->nAnimFlags & ePODHasScaleAni)) {
			animatedScales = psn->pfAnimScale;
			animatedScaleIndices = psn->pnAnimScaleIdx;
		}
	}
	return self; 
}

+(id) animationFromSPODNode: (PODStructPtr) pSPODNode withFrameCount: (GLuint) numFrames {
	return [[[self alloc] initFromSPODNode: pSPODNode withFrameCount: numFrames] autorelease];
}

+(BOOL) sPODNodeDoesContainAnimation: (PODStructPtr) pSPODNode {
	SPODNode* psn = (SPODNode*)pSPODNode;
	return psn->nAnimFlags & (ePODHasPositionAni | ePODHasRotationAni | ePODHasScaleAni);
}

-(BOOL) isAnimatingLocation {
	return animatedLocations != NULL;
}

-(BOOL) isAnimatingQuaternion {
	return animatedQuaternions != NULL;
}

-(BOOL) isAnimatingScale {
	return animatedScales != NULL;
}


#define kPODAnimationLocationStride 3
-(CC3Vector) locationAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	int currFrameOffset = animatedLocationIndices
								? animatedLocationIndices[frameIndex]
								: (frameIndex * kPODAnimationLocationStride);
	return *(CC3Vector*)&animatedLocations[currFrameOffset];
}

#define kPODAnimationQuaternionStride 4
-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	int currFrameOffset = animatedQuaternionsIndices
								? animatedQuaternionsIndices[frameIndex]
								: (frameIndex * kPODAnimationQuaternionStride);
	return *(CC3Quaternion*)&animatedQuaternions[currFrameOffset];
}

#define kPODAnimationScaleStride 7
-(CC3Vector) scaleAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	int currFrameOffset = animatedScaleIndices
								? animatedScaleIndices[frameIndex]
								: (frameIndex * kPODAnimationScaleStride);
	return *(CC3Vector*)&animatedScales[currFrameOffset];
}

@end
