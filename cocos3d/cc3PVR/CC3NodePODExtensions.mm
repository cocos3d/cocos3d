/*
 * CC3NodePODExtensions.mm
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
-(GLint) podContentIndex { return kCC3PODNilIndex; }

// Subclasses must override to use instance variable.
-(void) setPodContentIndex: (GLint) aPODIndex {}

// Subclasses must override to use instance variable.
-(GLint) podParentIndex { return kCC3PODNilIndex; }

// Subclasses must override to use instance variable.
-(void) setPodParentIndex: (GLint) aPODIndex {}

// Subclasses must override to use instance variable.
-(GLint) podTargetIndex {return kCC3PODNilIndex;}

// Subclasses must override to use instance variable.
-(void) setPodTargetIndex: (GLint) aPODIndex {}

-(GLuint) podUserDataSize { return (GLuint)((NSData*)self.userData).length; }

-(void) setPodUserDataSize: (GLuint) podUserDataSize {}

-(BOOL) isBasePODNode { return self.podParentIndex < 0; }


#pragma mark Allocation and initialization

-(id) initAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	CC3Assert(![self isMemberOfClass:[CC3Node class]], @"%@ is an abstract class and should not be instantiated directly. Use a subclass instead.", [self class]);
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		SPODNode* psn = (SPODNode*)[self nodePODStructAtIndex: aPODIndex fromPODResource: aPODRez];
		LogRez(@"Creating %@ at index %i from: %@", [self class], aPODIndex, NSStringFromSPODNode(psn));
		self.name = [NSString stringWithUTF8String: psn->pszName];
		self.podContentIndex = psn->nIdx;
		self.podParentIndex = psn->nIdxParent;

		if (psn->pfAnimPosition) self.location = *(CC3Vector*)psn->pfAnimPosition;
		if (psn->pfAnimRotation) self.quaternion = *(CC3Quaternion*)psn->pfAnimRotation;
		if (psn->pfAnimScale) self.scale = *(CC3Vector*)psn->pfAnimScale;

		if ([CC3PODNodeAnimation sPODNodeDoesContainAnimation: (PODStructPtr)psn])
			self.animation = [CC3PODNodeAnimation animationFromSPODNode: (PODStructPtr)psn
														 withFrameCount: aPODRez.animationFrameCount];
		else if (aPODRez.shouldFreezeInanimateNodes)
			self.animation = [CC3FrozenNodeAnimation animationFromNodeState: self];
		
		// Assign any user data and take ownership of managing its memory
		if (psn->pUserData && psn->nUserDataSize > 0) {
			self.userData = [NSData dataWithBytesNoCopy: psn->pUserData length: psn->nUserDataSize];
			psn->pUserData = NULL;		// Clear reference so SPODNode won't try to free it.
		}
	}
	return self; 
}

+(id) nodeAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [[[self alloc] initAtIndex: aPODIndex fromPODResource: aPODRez] autorelease];
}

-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [aPODRez nodePODStructAtIndex: aPODIndex];
}

-(void) linkToPODNodes: (NSArray*) nodeArray {
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
	free(_animatedLocations);
	free(_animatedLocationIndices);
	free(_animatedQuaternions);
	free(_animatedQuaternionsIndices);
	free(_animatedScales);
	free(_animatedScaleIndices);
	
	[super dealloc];
}

// For each type of animation content, this instance assumes responsiblity for managing
// the memory of 
-(id) initFromSPODNode: (PODStructPtr) pSPODNode withFrameCount: (GLuint) numFrames {
	if ( (self = [super initWithFrameCount: numFrames]) ) {
		
		// Start with no animation
		_animatedLocations = _animatedQuaternions = _animatedScales = NULL;
		_animatedLocationIndices = _animatedQuaternionsIndices = _animatedScaleIndices = NULL;
		
		SPODNode* psn = (SPODNode*)pSPODNode;
		
		if (psn->pfAnimPosition && (psn->nAnimFlags & ePODHasPositionAni)) {
			_animatedLocations = psn->pfAnimPosition;
			_animatedLocationIndices = psn->pnAnimPositionIdx;
			psn->pfAnimPosition = NULL;		// Clear reference so SPODNode won't try to free it.
			psn->pnAnimPositionIdx = NULL;	// Clear reference so SPODNode won't try to free it.
		}
		
		if (psn->pfAnimRotation && (psn->nAnimFlags & ePODHasRotationAni)) {
			_animatedQuaternions = psn->pfAnimRotation;
			_animatedQuaternionsIndices = psn->pnAnimRotationIdx;
			psn->pfAnimRotation = NULL;		// Clear reference so SPODNode won't try to free it.
			psn->pnAnimRotationIdx = NULL;	// Clear reference so SPODNode won't try to free it.
		}
		
		if (psn->pfAnimScale && (psn->nAnimFlags & ePODHasScaleAni)) {
			_animatedScales = psn->pfAnimScale;
			_animatedScaleIndices = psn->pnAnimScaleIdx;
			psn->pfAnimScale = NULL;		// Clear reference so SPODNode won't try to free it.
			psn->pnAnimScaleIdx = NULL;		// Clear reference so SPODNode won't try to free it.
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

-(BOOL) isAnimatingLocation { return _animatedLocations != NULL; }

-(BOOL) isAnimatingQuaternion { return _animatedQuaternions != NULL; }

-(BOOL) isAnimatingScale { return _animatedScales != NULL; }


-(CC3Vector) locationAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, _frameCount - 1);
	GLint currFrameOffset = _animatedLocationIndices
								? _animatedLocationIndices[frameIndex]
								: (frameIndex * kPODAnimationLocationStride);
	return *(CC3Vector*)&_animatedLocations[currFrameOffset];
}

-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, _frameCount - 1);
	GLint currFrameOffset = _animatedQuaternionsIndices
								? _animatedQuaternionsIndices[frameIndex]
								: (frameIndex * kPODAnimationQuaternionStride);
	return *(CC3Quaternion*)&_animatedQuaternions[currFrameOffset];
}

-(CC3Vector) scaleAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, _frameCount - 1);
	GLint currFrameOffset = _animatedScaleIndices
								? _animatedScaleIndices[frameIndex]
								: (frameIndex * kPODAnimationScaleStride);
	return *(CC3Vector*)&_animatedScales[currFrameOffset];
}

@end
