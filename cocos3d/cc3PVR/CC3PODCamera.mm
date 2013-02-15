/*
 * CC3PODCamera.mm
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3PODCamera.h for full API documentation.
 */

#import "CC3PODCamera.h"
#import "CC3PVRTModelPOD.h"
#import "CC3Math.h"


@implementation CC3PODCamera

-(int) podIndex { return podIndex; }

-(void) setPodIndex: (int) aPODIndex { podIndex = aPODIndex; }

-(int) podContentIndex { return podContentIndex; }

-(void) setPodContentIndex: (int) aPODIndex { podContentIndex = aPODIndex; }

-(int) podParentIndex { return podParentIndex; }

-(void) setPodParentIndex: (int) aPODIndex { podParentIndex = aPODIndex; }

-(int) podTargetIndex { return podTargetIndex; }

-(void) setPodTargetIndex: (int) aPODIndex { podTargetIndex = aPODIndex; }

-(id) initAtIndex: (int) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {

	// Adjust the quaternions to compensate for different camera orientation axis in the exporter.
	SPODNode* psn = (SPODNode*)[self nodePODStructAtIndex: aPODIndex fromPODResource: aPODRez];
	[self adjustQuaternionsIn: psn withAnimationFrameCount: aPODRez.animationFrameCount];

	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		// Get the camera content
		if (self.podContentIndex >= 0) {
			SPODCamera* psc = (SPODCamera*)[aPODRez cameraPODStructAtIndex: self.podContentIndex];
			LogRez(@"Setting %@ parameters from %@", [self class], NSStringFromSPODCamera(psc));
			self.podTargetIndex = psc->nIdxTarget;
			self.fieldOfView = RadiansToDegrees(psc->fFOV);
			self.nearClippingDistance = psc->fNear;
			self.farClippingDistance = psc->fFar;
		}
	}
	return self; 
}

-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [aPODRez cameraNodePODStructAtIndex: aPODIndex];
}

/**
 * The camera is aligned along a different axis in the exporter than in cocos3d. This method runs
 * through the quaternions in the rotation animation array (including the initial rotation setting
 * in the first element even if rotation animation is not used), and rotates each by a fixed offset
 * (90 degrees around the X-axis).
 */
-(void) adjustQuaternionsIn: (SPODNode*) psn withAnimationFrameCount: (GLuint) numFrames {
	if ( !psn->pfAnimRotation ) return;
	
	// Determine how many quaternions we need to convert. This depends on whether they are animated.
	GLuint qCnt = 1;	// Assume no animation. The first quaternion is just the initial rotation.
	
	// If rotation is animated, determine how many quaternions it includes
	if (psn->nAnimFlags & ePODHasRotationAni) {
		qCnt = numFrames;		// Assume animation not index and uses numFrames frames

		// If using indexed animation, find the largest index to determine number of quaternions.
		// Animation indices are by floats, not quaternions.
		if(psn->pnAnimRotationIdx) {
			GLuint maxFloatIdx = 0;
			for (GLuint frameIdx = 0; frameIdx < numFrames; frameIdx++)
				maxFloatIdx = MAX(maxFloatIdx, psn->pnAnimRotationIdx[frameIdx]);
			
			// Quaternion count is one more than the largest float index found
			// divided by the quaternion stride.
			qCnt = (maxFloatIdx / kPODAnimationQuaternionStride) +  1;
		}
	}
	
	// Offset each quaternion by a 90 degree rotation around X-axis.
	CC3Vector4 axisAngle = CC3Vector4FromCC3Vector(kCC3VectorUnitXPositive, 90.0f);
	CC3Quaternion offsetQuat = CC3QuaternionFromAxisAngle(axisAngle);
	
	CC3Quaternion* quaternions = (CC3Quaternion*)psn->pfAnimRotation;
	for (GLuint qIdx = 0; qIdx < qCnt; qIdx++)
		quaternions[qIdx] = CC3QuaternionMultiply(quaternions[qIdx], offsetQuat);
	
	LogRez(@"%@ adjusted %i rotation quaternions by %@", self, qCnt, NSStringFromCC3Quaternion(offsetQuat));
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PODCamera*) another {
	[super populateFrom: another];

	podIndex = another.podIndex;
	podContentIndex = another.podContentIndex;
	podParentIndex = another.podParentIndex;
	podTargetIndex = another.podTargetIndex;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (POD index: %i)", [super description], podIndex];
}

@end
