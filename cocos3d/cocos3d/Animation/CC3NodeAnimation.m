/*
 * CC3NodeAnimation.m
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
 * See header file CC3NodeAnimation.h for full API documentation.
 */

#import "CC3NodeAnimation.h"


#pragma mark -
#pragma mark CC3NodeAnimation

@interface CC3NodeAnimation(TemplateMethods)
-(void) establishFrame: (GLuint) frameIndex plusInterpolation: (GLfloat) frameInterpolation forNode: (CC3Node*) aNode;
-(void) establishLocationAtFrame: (GLuint) frameIndex plusInterpolation: (GLfloat) frameInterpolation forNode: (CC3Node*) aNode;
-(void) establishRotationAtFrame: (GLuint) frameIndex plusInterpolation: (GLfloat) frameInterpolation forNode: (CC3Node*) aNode;
-(void) establishQuaternionAtFrame: (GLuint) frameIndex plusInterpolation: (GLfloat) frameInterpolation forNode: (CC3Node*) aNode;
-(void) establishScaleAtFrame: (GLuint) frameIndex plusInterpolation: (GLfloat) frameInterpolation forNode: (CC3Node*) aNode;
-(CC3Vector) locationAtFrame: (GLuint) frameIndex;
-(CC3Vector) rotationAtFrame: (GLuint) frameIndex;
-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex;
-(CC3Vector) scaleAtFrame: (GLuint) frameIndex;
@end

@implementation CC3NodeAnimation

@synthesize frameCount, shouldInterpolate, currentFrame;

-(void) dealloc {
	[super dealloc];
}

-(BOOL) isAnimatingLocation { return NO; }

-(BOOL) isAnimatingRotation { return NO; }

-(BOOL) isAnimatingQuaternion { return NO; }

-(BOOL) isAnimatingScale { return NO; }

/**
 * Template method that returns the location at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns zero location. Subclasses with animation data should override.
 * Subclasses should ensure that if frameIndex is larger than frameCount,
 * the last frame will be returned.
 */
-(CC3Vector) locationAtFrame: (GLuint) frameIndex {
	return kCC3VectorZero;
}

/**
 * Template method that returns the rotation at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns zero rotation. Subclasses with animation data should override.
 * Subclasses should ensure that if frameIndex is larger than frameCount,
 * the last frame will be returned.
 */
-(CC3Vector) rotationAtFrame: (GLuint) frameIndex {
	return kCC3VectorZero;
}

/**
 * Template method that returns the location at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns the identity quaternion. Subclasses with animation data should
 * override. Subclasses should ensure that if frameIndex is larger than frameCount,
 * the last frame will be returned.
 */
-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex {
	return kCC3QuaternionIdentity;
}

/**
 * Template method that returns the scale at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns unit scale. Subclasses with animation data should override.
 * Subclasses should ensure that if frameIndex is larger than frameCount,
 * the last frame will be returned.
 */
-(CC3Vector) scaleAtFrame: (GLuint) frameIndex {
	return kCC3VectorUnitCube;
}

-(id) init {
	NSAssert1(NO, @"%@ cannot be initialized without a frame count", self);
	return nil;
}

-(id) initWithFrameCount: (GLuint) numFrames {
	if ( (self = [super init]) ) {
		frameCount = numFrames;
		shouldInterpolate = YES;
	}
	return self;
}

+(id) animationWithFrameCount: (GLuint) numFrames {
	return [[[self alloc] initWithFrameCount: numFrames] autorelease];
}

// If the animation time is less than this fractional distance from a concrete frame,
// interpolation will not be performed, and the data from that single frame will be
// used outright.
#define kCC3AnimationLerpEpsilon 0.1

-(void) establishFrameAt: (ccTime) t forNode: (CC3Node*) aNode {
	LogTrace(@"%@ animating frame at %.3f ms", self, t);
	NSAssert2(t >= 0.0 && t <= 1.0, @"%@ animation frame time %f must be between 0.0 and 1.0", self, t);
	currentFrame = t;
	
	// Determine the virtual frame index, based on proportional time.
	// This is a float to allow interpolating between frames.
	GLfloat virtualFrameIndex = MIN(t * frameCount, frameCount - 1);
	
	// Separate the virtual frame index into a concrete frame index,
	// plus a fractional interpolation component.
	GLuint frameIndex = (GLuint)virtualFrameIndex;
	GLfloat frameInterpolation = 0.0;
	
	// If we should interpolate, and we're not at the last frame, calc interpolation amount.
	// But only bother interpolating if difference is large enough.
	// If close enough to this frame or next frame, just use the appropriate frame outright.
	if (shouldInterpolate && (frameIndex < frameCount - 1)) {
		frameInterpolation = virtualFrameIndex - frameIndex;
		if (frameInterpolation < kCC3AnimationLerpEpsilon) {
			frameInterpolation = 0.0f;		// use this frame
		} else if ((1.0f - frameInterpolation) < kCC3AnimationLerpEpsilon) {
			frameInterpolation = 0.0f;
			frameIndex++;					// use next frame
		}
		LogTrace(@"%@ separating virtual frame %.3f into concrete frame %u plus interpolation fraction %.3f",
				 self, virtualFrameIndex, frameIndex, frameInterpolation);
	}
	[self establishFrame: frameIndex plusInterpolation: frameInterpolation forNode: aNode];
}

/** 
 * Updates the location, rotation, quaternion, and scale of the specified node based
 * on the animation frame located at the specified frame, plus an interpolation amount
 * towards the next frame.
 */
-(void) establishFrame: (GLuint) frameIndex
	 plusInterpolation: (GLfloat) frameInterpolation
			   forNode: (CC3Node*) aNode {
	[self establishLocationAtFrame: frameIndex plusInterpolation: frameInterpolation forNode: aNode];
	[self establishRotationAtFrame: frameIndex plusInterpolation: frameInterpolation forNode: aNode];
	[self establishQuaternionAtFrame: frameIndex plusInterpolation: frameInterpolation forNode: aNode];
	[self establishScaleAtFrame: frameIndex plusInterpolation: frameInterpolation forNode: aNode];
}

/**
 * Updates the location of the node by interpolating between the the animation data
 * at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one.
 */
-(void) establishLocationAtFrame: (GLuint) frameIndex
			   plusInterpolation: (GLfloat) frameInterpolation
						 forNode: (CC3Node*) aNode {
	if(self.isAnimatingLocation) {
		// If frameInterpolation is zero, Lerp function will immediately return first frame.
		aNode.location = CC3VectorLerp([self locationAtFrame: frameIndex],
									  [self locationAtFrame: frameIndex + 1],
									  frameInterpolation);
	}
}

/**
 * Updates the rotation of the node by interpolating between the the animation data
 * at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one. 
 */
-(void) establishRotationAtFrame: (GLuint) frameIndex
			   plusInterpolation: (GLfloat) frameInterpolation
						 forNode: (CC3Node*) aNode {
	if(self.isAnimatingRotation) {
		// If frameInterpolation is zero, Lerp function will immediately return first frame.
		aNode.rotation = CC3VectorLerp([self rotationAtFrame: frameIndex],
									  [self rotationAtFrame: frameIndex + 1],
									  frameInterpolation);
	}
}

/**
 * Updates the rotation quaternion of the node by interpolating between the the animation
 * data at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one. 
 */
-(void) establishQuaternionAtFrame: (GLuint) frameIndex
				 plusInterpolation: (GLfloat) frameInterpolation
						   forNode: (CC3Node*) aNode {
	if(self.isAnimatingQuaternion) {
		// If frameInterpolation is zero, Slerp function will immediately return first frame.
		aNode.quaternion = CC3QuaternionSlerp([self quaternionAtFrame: frameIndex],
											  [self quaternionAtFrame: frameIndex + 1],
											  frameInterpolation);
	}
}

/**
 * Updates the scale of the node by interpolating between the the animation data
 * at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one. 
 */
-(void) establishScaleAtFrame: (GLuint) frameIndex
			plusInterpolation: (GLfloat) frameInterpolation
					  forNode: (CC3Node*) aNode {
	if(self.isAnimatingScale) {
		// If frameInterpolation is zero, Lerp function will immediately return first frame.
		aNode.scale = CC3VectorLerp([self scaleAtFrame: frameIndex],
								   [self scaleAtFrame: frameIndex + 1],
								   frameInterpolation);
	}
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %u frames", [self class], frameCount];
}

@end


#pragma mark -
#pragma mark CC3ArrayNodeAnimation

@implementation CC3ArrayNodeAnimation

@synthesize animatedLocations, animatedRotations, animatedQuaternions, animatedScales;

-(void) dealloc {
	[self deallocateLocations];
	[self deallocateRotations];
	[self deallocateQuaternions];
	[self deallocateScales];
	[super dealloc];
}

-(BOOL) isAnimatingLocation {
	return animatedLocations != NULL;
}

-(BOOL) isAnimatingRotation {
	return animatedRotations != NULL;
}

-(BOOL) isAnimatingQuaternion {
	return animatedQuaternions != NULL;
}

-(BOOL) isAnimatingScale {
	return animatedScales != NULL;
}

-(BOOL) locationsAreRetained { return locationsAreRetained; }
-(BOOL) rotationsAreRetained { return rotationsAreRetained; }
-(BOOL) quaternionsAreRetained { return quaternionsAreRetained; }
-(BOOL) scalesAreRetained { return scalesAreRetained; }

-(id) initWithFrameCount: (GLuint) numFrames {
	if ( (self = [super initWithFrameCount: numFrames]) ) {
		animatedLocations = NULL;
		animatedRotations = NULL;
		animatedQuaternions = NULL;
		animatedScales = NULL;
		locationsAreRetained = NO;
		rotationsAreRetained = NO;
		quaternionsAreRetained = NO;
		scalesAreRetained = NO;
	}
	return self;
}


#pragma mark Accessing frame data

-(CC3Vector) locationAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	return animatedLocations[frameIndex];
}

-(CC3Vector) rotationAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	return animatedRotations[frameIndex];
}

-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	return animatedQuaternions[frameIndex];
}

-(CC3Vector) scaleAtFrame: (GLuint) frameIndex {
	frameIndex = MIN(frameIndex, frameCount - 1);
	return animatedScales[frameIndex];
}

-(void) setAnimatedLocations:(CC3Vector*) vectorArray {
	[self deallocateLocations];			// get rid of any existing array
	animatedLocations = vectorArray;
}

-(void) setAnimatedRotations:(CC3Vector*) vectorArray {
	[self deallocateRotations];			// get rid of any existing array
	animatedRotations = vectorArray;
}

-(void) setAnimatedQuaternions:(CC3Vector4*) vectorArray {
	[self deallocateQuaternions];			// get rid of any existing array
	animatedQuaternions = vectorArray;
}

-(void) setAnimatedScales:(CC3Vector*) vectorArray {
	[self deallocateScales];			// get rid of any existing array
	animatedScales= vectorArray;
}


#pragma mark Allocation of managed arrays

-(CC3Vector*) allocateLocations {
	if (frameCount) {
		self.animatedLocations = calloc(frameCount, sizeof(CC3Vector));
		locationsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u locations", self, frameCount);
	}
	return animatedLocations;
}

-(void) deallocateLocations {
	if (locationsAreRetained && animatedLocations) {
		free(animatedLocations);
		animatedLocations = NULL;
		locationsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated locations", self, frameCount);
	}
}

-(CC3Vector*) allocateRotations {
	if (frameCount) {
		self.animatedRotations = calloc(frameCount, sizeof(CC3Vector));
		rotationsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u rotations", self, frameCount);
	}
	return animatedRotations;
}

-(void) deallocateRotations {
	if (rotationsAreRetained && animatedRotations) {
		free(animatedRotations);
		animatedRotations = NULL;
		rotationsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated rotations", self, frameCount);
	}
}

-(CC3Vector4*) allocateQuaternions {
	if (frameCount) {
		self.animatedQuaternions = calloc(frameCount, sizeof(CC3Vector4));
		for (int i = 0; i < frameCount; i++) {
			animatedQuaternions[i] = kCC3QuaternionIdentity;
		}
		quaternionsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u quaternions", self, frameCount);
	}
	return animatedQuaternions;
}

-(void) deallocateQuaternions {
	if (quaternionsAreRetained && animatedQuaternions) {
		free(animatedQuaternions);
		animatedQuaternions = NULL;
		quaternionsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated quaternions", self, frameCount);
	}
}

-(CC3Vector*) allocateScales {
	if (frameCount) {
		self.animatedScales =calloc(frameCount, sizeof(CC3Vector));
		for (int i = 0; i < frameCount; i++) {
			animatedScales[i] = kCC3VectorUnitCube;
		}
		scalesAreRetained = YES;
		LogTrace(@"%@ allocated space for %u scales", self, frameCount);
	}
	return animatedScales;
}

-(void) deallocateScales {
	if (scalesAreRetained && animatedScales) {
		free(animatedScales);
		animatedScales = NULL;
		scalesAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated scales", self, frameCount);
	}
}

@end

