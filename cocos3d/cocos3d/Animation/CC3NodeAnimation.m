/*
 * CC3NodeAnimation.m
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
 * See header file CC3NodeAnimation.h for full API documentation.
 */

#import "CC3NodeAnimation.h"


#pragma mark -
#pragma mark CC3NodeAnimation

@implementation CC3NodeAnimation

@synthesize frameCount=_frameCount, shouldInterpolate=_shouldInterpolate;

-(BOOL) isAnimatingLocation { return NO; }

-(BOOL) isAnimatingQuaternion { return NO; }

-(BOOL) isAnimatingScale { return NO; }

-(BOOL) isAnimating { return (self.isAnimatingLocation ||
							  self.isAnimatingQuaternion ||
							  self.isAnimatingScale); }

-(BOOL) hasVariableFrameTiming { return NO; }

static ccTime _interpolationEpsilon = 0.1f;

+(ccTime) interpolationEpsilon { return _interpolationEpsilon; }

+(void) setInterpolationEpsilon: (ccTime) epsilon { _interpolationEpsilon = epsilon; }


#pragma mark Allocation and initialization

-(id) init {
	CC3Assert(NO, @"%@ cannot be initialized without a frame count", self);
	return nil;
}

-(id) initWithFrameCount: (GLuint) numFrames {
	if ( (self = [super init]) ) {
		_frameCount = numFrames;
		_shouldInterpolate = YES;
	}
	return self;
}

+(id) animationWithFrameCount: (GLuint) numFrames {
	return [[[self alloc] initWithFrameCount: numFrames] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with %u frames", [self class], _frameCount];
}


#pragma mark Updating

// Deprecated
-(void) establishFrameAt: (ccTime) t forNode: (CC3Node*) aNode { [aNode.animationState establishFrameAt: t]; }

-(void) establishFrameAt: (ccTime) t inNodeAnimationState: (CC3NodeAnimationState*) animState {
	LogTrace(@"%@ animating frame at %.4f", self, t);
	CC3Assert(t >= 0.0 && t <= 1.0, @"%@ animation frame time %f must be between 0.0 and 1.0", self, t);
	
	// Get the index of the frame within which the given time appears,
	// and declare a possible fractional interpolation within that frame.
	GLuint frameIndex = [self frameIndexAt: t];
	GLfloat frameInterpolation = 0.0;
	
	// If we should interpolate, and we're not at the last frame, calc the interpolation amount.
	// We only bother interpolating if difference is large enough. If close enough to this frame
	// or the next frame, just use the appropriate frame outright.
	if (_shouldInterpolate && (frameIndex < _frameCount - 1)) {
		ccTime frameTime = [self timeAtFrame: frameIndex];
		ccTime nextFrameTime = [self timeAtFrame: frameIndex + 1];
		ccTime frameDur = nextFrameTime - frameTime;
		if (frameDur != 0.0f) frameInterpolation = (t - frameTime) / frameDur;
		if (frameInterpolation < _interpolationEpsilon) {
			frameInterpolation = 0.0f;		// use this frame
		} else if ((1.0f - frameInterpolation) < _interpolationEpsilon) {
			frameInterpolation = 0.0f;
			frameIndex++;					// use next frame
		}
		LogTrace(@"%@ animating at time %.3f between frame %u at %.3f and next frame at %.3f with interpolation fraction %.3f",
				 self, t, frameIndex, frameTime, nextFrameTime, frameInterpolation);
	}
	[self establishFrame: frameIndex plusInterpolation: frameInterpolation inNodeAnimationState: animState];
}

/**
 * Updates the location, quaternion, and scale of the specified node animation state based on the
 * animation frame located at the specified frame, plus an interpolation amount towards the next frame.
 */
-(void) establishFrame: (GLuint) frameIndex
	 plusInterpolation: (GLfloat) frameInterpolation
  inNodeAnimationState: (CC3NodeAnimationState*) animState {
	[self establishLocationAtFrame: frameIndex plusInterpolation: frameInterpolation inNodeAnimationState: animState];
	[self establishQuaternionAtFrame: frameIndex plusInterpolation: frameInterpolation inNodeAnimationState: animState];
	[self establishScaleAtFrame: frameIndex plusInterpolation: frameInterpolation inNodeAnimationState: animState];
}

/**
 * Updates the location of the node animation state by interpolating between the animation
 * content at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one.
 */
-(void) establishLocationAtFrame: (GLuint) frameIndex
			   plusInterpolation: (GLfloat) frameInterpolation
			inNodeAnimationState: (CC3NodeAnimationState*) animState {
	if(animState.isAnimatingLocation) {
		// If frameInterpolation is zero, Lerp function will immediately return first frame.
		animState.location = CC3VectorLerp([self locationAtFrame: frameIndex],
										   [self locationAtFrame: frameIndex + 1],
										   frameInterpolation);
	}
}

/**
 * Updates the rotation quaternion of the node animation state by interpolating between the
 * animation content at the specified frame index and that at the next frame index, using
 * the specified interpolation fraction value, which will be between zero and one.
 */
-(void) establishQuaternionAtFrame: (GLuint) frameIndex
				 plusInterpolation: (GLfloat) frameInterpolation
			  inNodeAnimationState: (CC3NodeAnimationState*) animState {
	if(animState.isAnimatingQuaternion) {
		// If frameInterpolation is zero, Slerp function will immediately return first frame.
		animState.quaternion = CC3QuaternionSlerp([self quaternionAtFrame: frameIndex],
												  [self quaternionAtFrame: frameIndex + 1],
												  frameInterpolation);
	}
}

/**
 * Updates the scale of the node animation state by interpolating between the the animation
 * content at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one.
 */
-(void) establishScaleAtFrame: (GLuint) frameIndex
			plusInterpolation: (GLfloat) frameInterpolation
		 inNodeAnimationState: (CC3NodeAnimationState*) animState {
	if(animState.isAnimatingScale) {
		// If frameInterpolation is zero, Lerp function will immediately return first frame.
		animState.scale = CC3VectorLerp([self scaleAtFrame: frameIndex],
										[self scaleAtFrame: frameIndex + 1],
										frameInterpolation);
	}
}

-(ccTime) timeAtFrame: (GLuint) frameIndex {
	GLfloat currIdx = frameIndex;
	GLfloat lastIdx = _frameCount - 1;
	return CLAMP(currIdx / lastIdx, 0.0f, 1.0f);
}

/**
 * Template method that returns the index of the frame within which the specified time occurs.
 * The specified time will lie between the time of the animation frame at the returned index
 * and the time of the animation frame following that frame.
 */
-(GLuint) frameIndexAt: (ccTime) t { return (_frameCount - 1) * t; }

/**
 * Template method that returns the location at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns zero location. Subclasses with animation data should override.
 * Subclasses should ensure that if frameIndex is larger than (frameCount - 1),
 * the last frame will be returned.
 */
-(CC3Vector) locationAtFrame: (GLuint) frameIndex { return kCC3VectorZero; }

/**
 * Template method that returns the location at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns the identity quaternion. Subclasses with animation data should override.
 * Subclasses should ensure that if frameIndex is larger than (frameCount - 1), the last
 * frame will be returned.
 */
-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex { return kCC3QuaternionIdentity; }

/**
 * Template method that returns the scale at the specified animation frame.
 * Frame index numbering starts at zero.
 *
 * Default returns unit scale. Subclasses with animation data should override.
 * Subclasses should ensure that if frameIndex is larger than (frameCount - 1),
 * the last frame will be returned.
 */
-(CC3Vector) scaleAtFrame: (GLuint) frameIndex { return kCC3VectorUnitCube; }

@end


#pragma mark -
#pragma mark CC3ArrayNodeAnimation

@implementation CC3ArrayNodeAnimation

@synthesize frameTimes=_frameTimes, animatedLocations=_animatedLocations;
@synthesize animatedQuaternions=_animatedQuaternions, animatedScales=_animatedScales;

-(void) dealloc {
	[self deallocateFrameTimes];
	[self deallocateLocations];
	[self deallocateQuaternions];
	[self deallocateScales];
	[super dealloc];
}

-(BOOL) isAnimatingLocation { return _animatedLocations != NULL; }

-(BOOL) isAnimatingQuaternion { return _animatedQuaternions != NULL; }

-(BOOL) isAnimatingScale { return _animatedScales != NULL; }

-(BOOL) hasVariableFrameTiming { return _frameTimes != NULL; }

-(id) initWithFrameCount: (GLuint) numFrames {
	if ( (self = [super initWithFrameCount: numFrames]) ) {
		_frameTimes = NULL;
		_animatedLocations = NULL;
		_animatedQuaternions = NULL;
		_animatedScales = NULL;
		_frameTimesAreRetained = NO;
		_locationsAreRetained = NO;
		_quaternionsAreRetained = NO;
		_scalesAreRetained = NO;
	}
	return self;
}


#pragma mark Accessing frame data

// All times should be in range between zero and one
-(ccTime) timeAtFrame: (GLuint) frameIndex {
	if (!_frameTimes) return [super timeAtFrame: frameIndex];
	return _frameTimes[MIN(frameIndex, _frameCount - 1)];
}

// Iterate backwards through the frames looking for the first frame whose time is at or before
// the specified frame time, and return that frame. If the specified frame is before the first
// frame, return the first frame.
-(GLuint) frameIndexAt: (ccTime) t {
	if (!_frameTimes) return [super frameIndexAt: t];
	for (GLint fIdx = _frameCount - 1; fIdx >= 0; fIdx--)	// start at last frame
		if (_frameTimes[fIdx] <= t) return fIdx;			// return frame
	return 0;
}

-(CC3Vector) locationAtFrame: (GLuint) frameIndex {
	if (!_animatedLocations) return [super locationAtFrame: frameIndex];
	return _animatedLocations[MIN(frameIndex, _frameCount - 1)];
}

-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex {
	if (!_animatedQuaternions) return [super quaternionAtFrame: frameIndex];
	return _animatedQuaternions[MIN(frameIndex, _frameCount - 1)];
}

-(CC3Vector) scaleAtFrame: (GLuint) frameIndex {
	if (!_animatedScales) return [super scaleAtFrame: frameIndex];
	return _animatedScales[MIN(frameIndex, _frameCount - 1)];
}

-(void) setFrameTimes: (ccTime*) frameTimes {
	[self deallocateFrameTimes];			// get rid of any existing array
	_frameTimes = frameTimes;
}

-(void) setAnimatedLocations:(CC3Vector*) vectorArray {
	[self deallocateLocations];				// get rid of any existing array
	_animatedLocations = vectorArray;
}

-(void) setAnimatedQuaternions:(CC3Quaternion*) vectorArray {
	[self deallocateQuaternions];			// get rid of any existing array
	_animatedQuaternions = vectorArray;
}

-(void) setAnimatedScales:(CC3Vector*) vectorArray {
	[self deallocateScales];				// get rid of any existing array
	_animatedScales= vectorArray;
}


#pragma mark Allocation of managed arrays

-(ccTime*) allocateFrameTimes {
	if (_frameCount) {
		self.frameTimes = calloc(_frameCount, sizeof(ccTime));
		_frameTimesAreRetained = YES;
		LogTrace(@"%@ allocated space for %u frame times", self, _frameCount);
	}
	return _frameTimes;
}

-(void) deallocateFrameTimes {
	if (_frameTimesAreRetained) {
		free(_frameTimes);
		_frameTimes = NULL;
		_frameTimesAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated frame times", self, _frameCount);
	}
}

-(CC3Vector*) allocateLocations {
	if (_frameCount) {
		self.animatedLocations = calloc(_frameCount, sizeof(CC3Vector));
		_locationsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u locations", self, _frameCount);
	}
	return _animatedLocations;
}

-(void) deallocateLocations {
	if (_locationsAreRetained) {
		free(_animatedLocations);
		_animatedLocations = NULL;
		_locationsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated locations", self, _frameCount);
	}
}

-(CC3Quaternion*) allocateQuaternions {
	if (_frameCount) {
		self.animatedQuaternions = calloc(_frameCount, sizeof(CC3Quaternion));
		for (int i = 0; i < _frameCount; i++) _animatedQuaternions[i] = kCC3QuaternionIdentity;
		_quaternionsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u quaternions", self, _frameCount);
	}
	return _animatedQuaternions;
}

-(void) deallocateQuaternions {
	if (_quaternionsAreRetained) {
		free(_animatedQuaternions);
		_animatedQuaternions = NULL;
		_quaternionsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated quaternions", self, _frameCount);
	}
}

-(CC3Vector*) allocateScales {
	if (_frameCount) {
		self.animatedScales =calloc(_frameCount, sizeof(CC3Vector));
		for (int i = 0; i < _frameCount; i++) _animatedScales[i] = kCC3VectorUnitCube;
		_scalesAreRetained = YES;
		LogTrace(@"%@ allocated space for %u scales", self, _frameCount);
	}
	return _animatedScales;
}

-(void) deallocateScales {
	if (_scalesAreRetained) {
		free(_animatedScales);
		_animatedScales = NULL;
		_scalesAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated animated scales", self, _frameCount);
	}
}

@end


#pragma mark -
#pragma mark CC3NodeAnimationState

@implementation CC3NodeAnimationState

@synthesize node=_node, animation=_animation, trackID=_trackID, animationTime=_animationTime;
@synthesize isLocationAnimationEnabled=_isLocationAnimationEnabled;
@synthesize isQuaternionAnimationEnabled=_isQuaternionAnimationEnabled;
@synthesize isScaleAnimationEnabled=_isScaleAnimationEnabled;

-(void) dealloc {
	_node = nil;			// not retained
	[_animation release];
	[super dealloc];
}

-(BOOL) isEnabled { return _isEnabled; }

-(void) setIsEnabled: (BOOL) isEnabled {
	_isEnabled = isEnabled;
	[self markDirty];
}

-(void) enable { self.isEnabled = YES; }

-(void) disable { self.isEnabled = NO; }

-(GLfloat) blendingWeight { return _blendingWeight; }

-(void) setBlendingWeight: (GLfloat) blendingWeight {
	_blendingWeight = CLAMP(blendingWeight, 0.0f, 1.0f);
	[self markDirty];
}

-(CC3Vector) location { return _location; }

-(void) setLocation: (CC3Vector) location {
	_location = location;
	[self markDirty];
}

-(CC3Quaternion) quaternion { return _quaternion; }

-(void) setQuaternion: (CC3Quaternion) quaternion {
	_quaternion = quaternion;
	[self markDirty];
}

-(CC3Vector) scale { return _scale; }

-(void) setScale: (CC3Vector) scale {
	_scale = scale;
	[self markDirty];
}

-(void) markDirty { [_node markAnimationDirty]; }

-(GLuint) frameCount { return _animation.frameCount; }

-(BOOL) isAnimatingLocation { return _isLocationAnimationEnabled && _animation.isAnimatingLocation; }

-(BOOL) isAnimatingQuaternion { return _isQuaternionAnimationEnabled && _animation.isAnimatingQuaternion; }

-(BOOL) isAnimatingScale { return _isScaleAnimationEnabled && _animation.isAnimatingScale; }

-(BOOL) isAnimating { return (self.isEnabled && (self.isAnimatingLocation ||
												 self.isAnimatingQuaternion ||
												 self.isAnimatingScale)); }

-(BOOL) hasVariableFrameTiming { return _animation.hasVariableFrameTiming; }

  
#pragma mark Updating

-(void) establishFrameAt: (ccTime) t {
	_animationTime = t;
	if (self.isEnabled) [_animation establishFrameAt: t inNodeAnimationState: self];
}


#pragma mark Allocation and initialization

-(id) init {
	CC3Assert(NO, @"%@ cannot be initialized without a node and animation", self);
	return nil;
}

-(id) initWithAnimation: (CC3NodeAnimation*) animation onTrack: (GLuint) trackID forNode: (CC3Node*) node {
	CC3Assert(animation, @"%@ must be created with a valid animation.", [self class]);
	CC3Assert(node, @"%@ must be created with a valid node.", [self class]);
	if ( (self = [super init]) ) {
		_node = node;						// not retained
		_animation = [animation retain];
		_trackID = trackID;
		_blendingWeight = 1.0f;
		_animationTime = 0.0f;
		_location = kCC3VectorZero;
		_quaternion = kCC3QuaternionIdentity;
		_scale = kCC3VectorUnitCube;
		_isEnabled = YES;
		_isLocationAnimationEnabled = YES;
		_isQuaternionAnimationEnabled = YES;
		_isScaleAnimationEnabled = YES;
		[self establishFrameAt: 0.0f];		// Start on the initial frame
	}
	return self;
}

+(id) animationStateWithAnimation: (CC3NodeAnimation*) animation onTrack: (GLuint) trackID forNode: (CC3Node*) node {
	return [[[self alloc] initWithAnimation: animation onTrack: trackID forNode: node] autorelease];
}

static GLuint _lastTrackID = 0;

// Pre-increment to start with one. Zero reserved for default track.
+(GLuint) generateTrackID { return ++_lastTrackID; }


#pragma mark Descriptions

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for node %@ with animation %@ on track %u",
			[self class], _node, _animation, _trackID];
}

#define kAnimStateDescLen 100

-(NSString*) describeCurrentState {
	NSMutableString* desc = [NSMutableString stringWithCapacity: kAnimStateDescLen];
	[desc appendFormat: @"Time: %.4f", _animationTime];
	if (self.isAnimatingLocation) [desc appendFormat: @" Loc: %@", NSStringFromCC3Vector(self.location)];
	if (self.isAnimatingQuaternion) [desc appendFormat: @" Quat: %@", NSStringFromCC3Quaternion(self.quaternion)];
	if (self.isAnimatingScale) [desc appendFormat: @" Scale: %@", NSStringFromCC3Vector(self.scale)];
	if ( !self.isAnimating) [desc appendFormat: @" No animation enabled."];
	return desc;
}

-(NSString*) describeStateForFrames: (GLuint) frameCount fromTime: (ccTime) startTime toTime: (ccTime) endTime {
	startTime = CLAMP(startTime, 0.0f, 1.0f);
	endTime = CLAMP(endTime, 0.0f, 1.0f);

	// Generating the description changes current state, so cache it for resortation below
	ccTime currTime = _animationTime;
	BOOL wasCurrentlyEnabled = self.isEnabled;
	self.isEnabled = YES;
	
	ccTime frameDur = 0.0f;
	if (frameCount > 1) frameDur = (endTime - startTime) / (GLfloat)(frameCount - 1);
	NSMutableString* desc = [NSMutableString stringWithCapacity: (kAnimStateDescLen * frameCount + 200)];
	[desc appendFormat: @"%@ animated state on track %u over %u frames from %.4f to %.4f:", _node, _trackID, frameCount, startTime, endTime];
	if (self.isAnimating && frameCount > 0)
		for (GLuint fIdx = 0; fIdx < frameCount; fIdx++) {
			[self establishFrameAt: (startTime + (frameDur * fIdx))];
			[desc appendFormat: @"\n\t%@", self.describeCurrentState];
		}
	else
		[desc appendFormat: @" No animation enabled."];
	
	// Return to where we were before the description was generated
	[self establishFrameAt: currTime];
	self.isEnabled = wasCurrentlyEnabled;

	return desc;
}

-(NSString*) describeStateForFrames: (GLuint) frameCount {
	return [self describeStateForFrames: frameCount fromTime: 0.0f toTime: 1.0f];
}

@end
