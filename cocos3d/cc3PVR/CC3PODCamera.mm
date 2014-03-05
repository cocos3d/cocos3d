/*
 * CC3PODCamera.mm
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
 * See header file CC3PODCamera.h for full API documentation.
 */

#import "CC3PODCamera.h"
#import "CC3PVRTModelPOD.h"
#import "CC3Math.h"


@implementation CC3PODCamera

-(GLint) podIndex { return _podIndex; }

-(void) setPodIndex: (GLint) aPODIndex { _podIndex = aPODIndex; }

-(GLint) podContentIndex { return _podContentIndex; }

-(void) setPodContentIndex: (GLint) aPODIndex { _podContentIndex = aPODIndex; }

-(GLint) podParentIndex { return _podParentIndex; }

-(void) setPodParentIndex: (GLint) aPODIndex { _podParentIndex = aPODIndex; }

-(GLint) podTargetIndex { return _podTargetIndex; }

-(void) setPodTargetIndex: (GLint) aPODIndex { _podTargetIndex = aPODIndex; }

-(id) initAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {

	// Adjust the quaternions to compensate for different camera orientation axis in the exporter.
	SPODNode* psn = (SPODNode*)[self nodePODStructAtIndex: aPODIndex fromPODResource: aPODRez];
	[self adjustQuaternionsIn: psn withAnimationFrameCount: aPODRez.animationFrameCount];

	// Remove all scaling animation content, since it affects the effective FOV of the camera.
	[self clearScaleContentIn: psn];

	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		// Get the camera content
		if (self.podContentIndex >= 0) {
			SPODCamera* psc = (SPODCamera*)[aPODRez cameraPODStructAtIndex: self.podContentIndex];
			LogRez(@"Setting %@ parameters from %@", [self class], NSStringFromSPODCamera(psc));
			self.podTargetIndex = psc->nIdxTarget;
			self.fieldOfView = CC3RadToDeg(psc->fFOV);
			self.fieldOfViewOrientation = CC3FieldOfViewOrientationHorizontal;
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
 * In cocos3d, scaling a camera affects the effective field of view. In a POD file, scale
 * info is meaningless and should be ignored. This is handled here by clearing the scale
 * animation flag, and clearing the scale animation content before building the camera node.
 */
-(void) clearScaleContentIn: (SPODNode*) psn {
	
	psn->nAnimFlags &= ~ePODHasScaleAni;	// Clear the scale animation flag

	free(psn->pfAnimScale);
	psn->pfAnimScale = NULL;

	free(psn->pnAnimScaleIdx);
	psn->pnAnimScaleIdx = NULL;
}

/**
 * Cameras in cocos3d are oriented to the OpenGL standard of pointing down the -Z axis, with
 * the UP direction pointing up the +Y axis. However, the camera is a POD file is oriented
 * so that it points down the -Y axis, with the up direction pointing down the -Z axis.
 *
 * The POD orientation can be aligned with the OpenGL orientation by rotating the camera
 * -90 degrees around the +X axis.
 *
 * This method runs through the quaternions in the rotation animation array (including the
 * initial rotation setting in the first element, even if rotation animation is not used),
 * and prepreds a fixed -90 degrees rotation around the X-axis to each quaternion. This is
 * done by creating a -90 degree +X axis rotation quaternion, multiplying it by each of the
 * quaternions in the rotation animation array, and placing eac of the results back in the
 * rotation animation array.
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
	
	// Offset each quaternion by a -90 degree rotation around X-axis.
	CC3Vector4 axisAngle = CC3Vector4FromCC3Vector(kCC3VectorUnitXPositive, -90.0f);
	CC3Quaternion offsetQuat = CC3QuaternionFromAxisAngle(axisAngle);
	
	CC3Quaternion* quaternions = (CC3Quaternion*)psn->pfAnimRotation;
	for (GLuint qIdx = 0; qIdx < qCnt; qIdx++)
		// Rotate first by offset rotation, then by animation rotation
		quaternions[qIdx] = CC3QuaternionMultiply(offsetQuat, quaternions[qIdx]);
	
	LogRez(@"%@ adjusted %i rotation quaternions by %@", self, qCnt, NSStringFromCC3Quaternion(offsetQuat));
}

-(void) populateFrom: (CC3PODCamera*) another {
	[super populateFrom: another];

	_podIndex = another.podIndex;
	_podContentIndex = another.podContentIndex;
	_podParentIndex = another.podParentIndex;
	_podTargetIndex = another.podTargetIndex;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (POD index: %i)", [super description], _podIndex];
}

@end
