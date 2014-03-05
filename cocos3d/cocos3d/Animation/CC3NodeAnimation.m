/*
 * CC3NodeAnimation.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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

static CCTime _interpolationEpsilon = 0.1f;

+(CCTime) interpolationEpsilon { return _interpolationEpsilon; }

+(void) setInterpolationEpsilon: (CCTime) epsilon { _interpolationEpsilon = epsilon; }


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
	return [NSString stringWithFormat: @"%@ with %u frames", [self class], self.frameCount];
}


#pragma mark Animating

// Deprecated
-(void) establishFrameAt: (CCTime) t forNode: (CC3Node*) aNode { [aNode.animationState establishFrameAt: t]; }

-(void) establishFrameAt: (CCTime) t inNodeAnimationState: (CC3NodeAnimationState*) animState {
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
		CCTime frameTime = [self timeAtFrame: frameIndex];
		CCTime nextFrameTime = [self timeAtFrame: frameIndex + 1];
		CCTime frameDur = nextFrameTime - frameTime;
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
 * If frameInterpolation is zero, the lerp function will immediately return first frame.
 */
-(void) establishLocationAtFrame: (GLuint) frameIndex
			   plusInterpolation: (GLfloat) frameInterpolation
			inNodeAnimationState: (CC3NodeAnimationState*) animState {
	if( !animState.isAnimatingLocation ) return;
	animState.location = CC3VectorLerp([self locationAtFrame: frameIndex],
									   [self locationAtFrame: frameIndex + 1],
									   frameInterpolation);
}

/**
 * Updates the rotation quaternion of the node animation state by interpolating between the
 * animation content at the specified frame index and that at the next frame index, using
 * the specified interpolation fraction value, which will be between zero and one.
 * If frameInterpolation is zero, the slerp function will immediately return first frame.
 */
-(void) establishQuaternionAtFrame: (GLuint) frameIndex
				 plusInterpolation: (GLfloat) frameInterpolation
			  inNodeAnimationState: (CC3NodeAnimationState*) animState {
	if( !animState.isAnimatingQuaternion ) return;
	animState.quaternion = CC3QuaternionSlerp([self quaternionAtFrame: frameIndex],
											  [self quaternionAtFrame: frameIndex + 1],
											  frameInterpolation);
}

/**
 * Updates the scale of the node animation state by interpolating between the the animation
 * content at the specified frame index and that at the next frame index, using the specified
 * interpolation fraction value, which will be between zero and one.
 * If frameInterpolation is zero, the lerp function will immediately return first frame.
 */
-(void) establishScaleAtFrame: (GLuint) frameIndex
			plusInterpolation: (GLfloat) frameInterpolation
		 inNodeAnimationState: (CC3NodeAnimationState*) animState {
	if( !animState.isAnimatingScale ) return;
	animState.scale = CC3VectorLerp([self scaleAtFrame: frameIndex],
									[self scaleAtFrame: frameIndex + 1],
									frameInterpolation);
}

-(CCTime) timeAtFrame: (GLuint) frameIndex {
	GLfloat thisIdx = frameIndex;					// floatify
	GLfloat lastIdx = MAX(_frameCount - 1, 1);		// floatify & ensure not zero
	return CLAMP(thisIdx / lastIdx, 0.0f, 1.0f);
}

/**
 * Template method that returns the index of the frame within which the specified time occurs.
 * The specified time will lie between the time of the animation frame at the returned index
 * and the time of the animation frame following that frame.
 */
-(GLuint) frameIndexAt: (CCTime) t { return (_frameCount - 1) * t; }

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
-(CCTime) timeAtFrame: (GLuint) frameIndex {
	if (!_frameTimes) return [super timeAtFrame: frameIndex];
	return _frameTimes[MIN(frameIndex, _frameCount - 1)];
}

// Iterate backwards through the frames looking for the first frame whose time is at or before
// the specified frame time, and return that frame. If the specified frame is before the first
// frame, return the first frame.
-(GLuint) frameIndexAt: (CCTime) t {
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

-(void) setFrameTimes: (CCTime*) frameTimes {
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

-(CCTime*) allocateFrameTimes {
	if (_frameCount) {
		self.frameTimes = calloc(_frameCount, sizeof(CCTime));
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
#pragma mark CC3FrozenNodeAnimation

@implementation CC3FrozenNodeAnimation : CC3NodeAnimation

@synthesize location=_location, quaternion=_quaternion, scale=_scale;

-(BOOL) isAnimatingLocation { return !CC3VectorIsNull(_location); }

-(BOOL) isAnimatingQuaternion { return !CC3QuaternionIsNull(_quaternion); }

-(BOOL) isAnimatingScale { return !CC3VectorIsNull(_scale); }

-(void) populateFromNodeState: (CC3Node*) node {
	_location = node.location;
	_quaternion = node.quaternion;
	_scale = node.scale;
}


#pragma mark Animating

-(void) establishFrameAt: (CCTime) t inNodeAnimationState: (CC3NodeAnimationState*) animState {
	CC3Assert(t >= 0.0 && t <= 1.0, @"%@ animation frame time %f must be between 0.0 and 1.0", self, t);

	if(animState.isAnimatingLocation) animState.location = self.location;
	if(animState.isAnimatingQuaternion) animState.quaternion = self.quaternion;
	if(animState.isAnimatingScale) animState.scale = self.scale;
}


#pragma mark Allocation and initialization

-(id) init { return [self initWithFrameCount: 1]; }

-(id) initWithFrameCount: (GLuint) numFrames {
	if ( (self = [super initWithFrameCount: 1]) ) {
		_shouldInterpolate = NO;
		_location = kCC3VectorNull;
		_quaternion = kCC3QuaternionNull;
		_scale = kCC3VectorNull;
	}
	return self;
}

+(id) animation { return [[[self alloc] init] autorelease]; }

-(id) initFromNodeState: (CC3Node*) aNode {
	if ( (self = [self init]) ) {
		[self populateFromNodeState: aNode];
	}
	return self;
}

+(id) animationFromNodeState: (CC3Node*) aNode { return [[[self alloc] initFromNodeState: aNode] autorelease]; }

@end


#pragma mark -
#pragma mark CC3NodeAnimationSegment

@implementation CC3NodeAnimationSegment

@synthesize baseAnimation=_baseAnimation, startTime=_startTime, endTime=_endTime;

-(void) dealloc {
	[_baseAnimation release];
	[super dealloc];
}
	
-(GLuint) frameCount { return _baseAnimation.frameCount; }

-(BOOL) shouldInterpolate { return _baseAnimation.shouldInterpolate; }

-(void) setShouldInterpolate: (BOOL)shouldInterpolate {
	_baseAnimation.shouldInterpolate = shouldInterpolate;
}

-(BOOL) isAnimatingLocation { return _baseAnimation.isAnimatingLocation; }

-(BOOL) isAnimatingQuaternion { return _baseAnimation.isAnimatingQuaternion; }

-(BOOL) isAnimatingScale { return _baseAnimation.isAnimatingScale; }

-(BOOL) hasVariableFrameTiming { return _baseAnimation.hasVariableFrameTiming; }

-(GLuint) startFrameIndex { return [_baseAnimation frameIndexAt: self.startTime]; }

-(void) setStartFrameIndex: (GLuint) startFrameIndex {
	self.startTime = [_baseAnimation timeAtFrame: startFrameIndex];
}

-(GLuint) endFrameIndex { return [_baseAnimation frameIndexAt: self.endTime]; }

-(void) setEndFrameIndex: (GLuint) endFrameIndex {
	self.endTime = [_baseAnimation timeAtFrame: endFrameIndex];
}


#pragma mark Allocation and initialization

// Will raise assertion because base animation cannot be nil.
-(id) init { return [self initOnAnimation: nil]; }

-(id) initOnAnimation: (CC3NodeAnimation*) baseAnimation {
	return [self initOnAnimation: baseAnimation from: 0.0f to: 1.0f];
}

+(id) animationOnAnimation: (CC3NodeAnimation*) baseAnimation {
	return [[[self alloc] initOnAnimation: baseAnimation] autorelease];
}

-(id) initOnAnimation: (CC3NodeAnimation*) baseAnimation from: (CCTime) startTime to: (CCTime) endTime {
	CC3Assert(baseAnimation, @"%@ cannot be initialized without a base animation", self);
	if ( (self = [super initWithFrameCount: 0]) ) {
		_baseAnimation = [baseAnimation retain];
		_startTime = startTime;
		_endTime = endTime;
	}
	return self;
}

+(id) animationOnAnimation: (CC3NodeAnimation*) baseAnimation from: (CCTime) startTime to: (CCTime) endTime {
	return [[[self alloc] initOnAnimation: baseAnimation from: startTime to: endTime] autorelease];
}

-(id) initOnAnimation: (CC3NodeAnimation*) baseAnimation
			fromFrame: (GLuint) startFrameIndex
			  toFrame: (GLuint) endFrameIndex {
	if ( (self = [self initOnAnimation: baseAnimation]) ) {
		self.startFrameIndex = startFrameIndex;
		self.endFrameIndex = endFrameIndex;
	}
	return self;
}

+(id) animationOnAnimation: (CC3NodeAnimation*) baseAnimation
				 fromFrame: (GLuint) startFrameIndex
				   toFrame: (GLuint) endFrameIndex {
	return [[[self alloc] initOnAnimation: baseAnimation
								fromFrame: startFrameIndex
								  toFrame: endFrameIndex] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ on %@", [self class], _baseAnimation];
}


#pragma mark Animating

/**
 * Overridden to interpret the specified time as within the range specified by the startTime
 * and endTime properties, and then to retrieve the corresponding frame index from the base
 * animation.
 */
-(GLuint) frameIndexAt: (CCTime) t {
	CCTime adjTime = _startTime + ((_endTime - _startTime) * t);
	return [_baseAnimation frameIndexAt: adjTime];
}

-(CCTime) timeAtFrame: (GLuint) frameIndex { return [_baseAnimation timeAtFrame: frameIndex]; }

-(CC3Vector) locationAtFrame: (GLuint) frameIndex {
	return [_baseAnimation locationAtFrame: frameIndex];
}

-(CC3Quaternion) quaternionAtFrame: (GLuint) frameIndex {
	return [_baseAnimation quaternionAtFrame: frameIndex];
}

-(CC3Vector) scaleAtFrame: (GLuint) frameIndex  {
	return [_baseAnimation scaleAtFrame: frameIndex];
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
	_node = nil;		// weak reference
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

  
#pragma mark Animating

-(void) establishFrameAt: (CCTime) t {
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
		_node = node;						// weak reference
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

-(NSString*) describeStateForFrames: (GLuint) frameCount fromTime: (CCTime) startTime toTime: (CCTime) endTime {
	startTime = CLAMP(startTime, 0.0f, 1.0f);
	endTime = CLAMP(endTime, 0.0f, 1.0f);

	// Generating the description changes current state, so cache it for resortation below
	CCTime currTime = _animationTime;
	BOOL wasCurrentlyEnabled = self.isEnabled;
	self.isEnabled = YES;
	
	CCTime frameDur = 0.0f;
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


#pragma mark -
#pragma mark CC3Node animation

@implementation CC3Node (Animation)


#pragma mark Adding and accessing animation

-(CC3NodeAnimationState*) getAnimationStateOnTrack: (GLuint) trackID {
	for (CC3NodeAnimationState* as in _animationStates) if (as.trackID == trackID) return as;
	return nil;
}

-(void) addAnimationState: (CC3NodeAnimationState*) animationState {
	CC3NodeAnimationState* currAnim = [self getAnimationStateOnTrack: animationState.trackID];
	if ( !animationState || animationState == currAnim ) return;		// leave if not changing
	
	if (!_animationStates) _animationStates = [NSMutableArray new];		// ensure array exists - retained
	[_animationStates removeObject: currAnim];							// remove existing
	[_animationStates addObject: animationState];						// add to array
}

-(void) removeAnimationState: (CC3NodeAnimationState*) animationState {
	[_animationStates removeObject: animationState];
	if (_animationStates.count == 0) {
		[_animationStates release];
		_animationStates = nil;
	}
	
}

-(CC3NodeAnimationState*) animationState { return [self getAnimationStateOnTrack: 0]; }

-(CC3NodeAnimation*) getAnimationOnTrack: (GLuint) trackID {
	return [self getAnimationStateOnTrack: trackID].animation;
}

-(void) addAnimation: (CC3NodeAnimation*) animation asTrack: (GLuint) trackID {
	CC3NodeAnimation* currAnim = [self getAnimationOnTrack: trackID];
	if ( !animation || animation == currAnim) return;		// leave if not changing
	[self addAnimationState: [CC3NodeAnimationState animationStateWithAnimation: animation
																		onTrack: trackID
																		forNode: self]];
}

-(GLuint) addAnimationFrom: (CCTime) startTime to: (CCTime) endTime {
	return [self addAnimationFrom: startTime to: endTime ofBaseTrack: 0];
}

-(GLuint) addAnimationFrom: (CCTime) startTime
						to: (CCTime) endTime
			   ofBaseTrack: (GLuint) baseTrackID {
	GLuint trackID = [CC3NodeAnimationState generateTrackID];
	[self addAnimationFrom: startTime to: endTime ofBaseTrack: baseTrackID asTrack: trackID];
	return trackID;
}

-(void) addAnimationFrom: (CCTime) startTime to: (CCTime) endTime asTrack: (GLuint) trackID {
	[self addAnimationFrom: startTime to: endTime ofBaseTrack: 0 asTrack: trackID];
}

-(void) addAnimationFrom: (CCTime) startTime
					  to: (CCTime) endTime
			 ofBaseTrack: (GLuint) baseTrackID
				 asTrack: (GLuint) trackID {
	
	// Retrieve the base animation, and contruct a partial animation on it
	CC3NodeAnimation* baseAnim = [self getAnimationOnTrack: baseTrackID];
	if (baseAnim) {
		[self addAnimation: [CC3NodeAnimationSegment animationOnAnimation: baseAnim
																	 from: startTime
																	   to: endTime]
				   asTrack: trackID];
	}
	
	// Propagate to children
	for (CC3Node* child in self.children) {
		[child addAnimationFrom: startTime
							 to: endTime
					ofBaseTrack: baseTrackID
						asTrack: trackID];
	}
}

-(GLuint) addAnimationFromFrame: (GLuint) startFrameIndex
						toFrame: (GLuint) endFrameIndex {
	return [self addAnimationFromFrame: startFrameIndex
							   toFrame: endFrameIndex
						   ofBaseTrack: 0];
}

-(GLuint) addAnimationFromFrame: (GLuint) startFrameIndex
						toFrame: (GLuint) endFrameIndex
					ofBaseTrack: (GLuint) baseTrackID {
	GLuint trackID = [CC3NodeAnimationState generateTrackID];
	[self addAnimationFromFrame: startFrameIndex
						toFrame: endFrameIndex
					ofBaseTrack: baseTrackID
						asTrack: trackID];
	return trackID;
}

-(void) addAnimationFromFrame: (GLuint) startFrameIndex
					  toFrame: (GLuint) endFrameIndex
					  asTrack: (GLuint) trackID {
	[self addAnimationFromFrame: startFrameIndex
						toFrame: endFrameIndex
					ofBaseTrack: 0
						asTrack: trackID];
}

-(void) addAnimationFromFrame: (GLuint) startFrameIndex
					  toFrame: (GLuint) endFrameIndex
				  ofBaseTrack: (GLuint) baseTrackID
					  asTrack: (GLuint) trackID {
	
	// Retrieve the base animation, and contruct a partial animation on it
	CC3NodeAnimation* baseAnim = [self getAnimationOnTrack: baseTrackID];
	if (baseAnim) {
		[self addAnimation: [CC3NodeAnimationSegment animationOnAnimation: baseAnim
																fromFrame: startFrameIndex
																  toFrame: endFrameIndex]
				   asTrack: trackID];
	}
	
	// Propagate to children
	for (CC3Node* child in self.children) {
		[child addAnimationFromFrame: startFrameIndex
							 toFrame: endFrameIndex
						 ofBaseTrack: baseTrackID
							 asTrack: trackID];
	}
}

-(CC3NodeAnimationState*) getAnimationStateForAnimation: (CC3NodeAnimation*) animation {
	for (CC3NodeAnimationState* as in _animationStates) if (as.animation == animation) return as;
	return nil;
}

-(void) removeAnimation: (CC3NodeAnimation*) animation {
	[self removeAnimationState: [self getAnimationStateForAnimation: animation]];
}

-(void) removeAnimationTrack: (GLuint) trackID {
	[self removeAnimationState: [self getAnimationStateOnTrack: trackID]];
	for (CC3Node* child in _children) [child removeAnimationTrack: trackID];
}

-(CC3NodeAnimation*) animation { return [self getAnimationOnTrack: 0]; }

-(void) setAnimation: (CC3NodeAnimation*) animation { [self addAnimation: animation asTrack: 0]; }

-(BOOL) containsAnimationOnTrack: (GLuint) trackID {
	if ([self getAnimationStateOnTrack: trackID] != nil) return YES;
	for (CC3Node* child in _children) if ( [child containsAnimationOnTrack: trackID] ) return YES;
	return NO;
}

-(BOOL) containsAnimation {
	if (_animationStates && _animationStates.count > 0) return YES;
	for (CC3Node* child in _children) if (child.containsAnimation) return YES;
	return NO;
}

-(CCTime) animationTimeOnTrack: (GLuint) trackID {
	CC3NodeAnimationState* as = [self getAnimationStateOnTrack: trackID];
	if (as) return as.animationTime;
	for (CC3Node* child in _children) {
		CCTime animTime = [child animationTimeOnTrack: trackID];
		if (animTime) return animTime;
	}
	return 0.0f;
}

-(GLfloat) animationBlendingWeightOnTrack: (GLuint) trackID {
	CC3NodeAnimationState* as = [self getAnimationStateOnTrack: trackID];
	if (as) return as.blendingWeight;
	for (CC3Node* child in _children) {
		GLfloat animBlend = [child animationBlendingWeightOnTrack: trackID];
		if (animBlend) return animBlend;
	}
	return 0.0f;
}

-(void) setAnimationBlendingWeight: (GLfloat) blendWeight onTrack: (GLuint) trackID {
	[self getAnimationStateOnTrack: trackID].blendingWeight = blendWeight;
	for (CC3Node* child in _children) [child setAnimationBlendingWeight: blendWeight onTrack: trackID];
}

-(void) freezeIfInanimateOnTrack: (GLuint) trackID {
	CC3NodeAnimation* anim = [self getAnimationOnTrack: trackID];
	if ( [anim isKindOfClass: CC3FrozenNodeAnimation.class] )
		[((CC3FrozenNodeAnimation*)anim) populateFromNodeState: self];
	else if ( !anim )
		[self addAnimation: [CC3FrozenNodeAnimation animationFromNodeState: self] asTrack: trackID];
}

-(void) freezeAllInanimatesOnTrack: (GLuint) trackID {
	[self freezeIfInanimateOnTrack: trackID];
	for (CC3Node* child in _children) [child freezeAllInanimatesOnTrack: trackID];
}


#pragma mark Enabling and disabling animation

-(void) enableAnimation { self.isAnimationEnabled = YES; }

-(void) disableAnimation { self.isAnimationEnabled = NO; }

-(BOOL) isAnimationEnabled {
	for (CC3NodeAnimationState* as in _animationStates) if (as.isEnabled) return YES;
	return NO;
}

-(void) setIsAnimationEnabled: (BOOL) isAnimationEnabled {
	for (CC3NodeAnimationState* as in _animationStates) as.isEnabled = isAnimationEnabled;
}

-(void) enableAnimationOnTrack: (GLuint) trackID {
	[[self getAnimationStateOnTrack: trackID] enable];
}

-(void) disableAnimationOnTrack: (GLuint) trackID {
	[[self getAnimationStateOnTrack: trackID] disable];
}

-(BOOL) isAnimationEnabledOnTrack: (GLuint) trackID {
	CC3NodeAnimationState* as = [self getAnimationStateOnTrack: trackID];
	return as ? as.isEnabled : NO;
}
-(void) enableAllAnimationOnTrack: (GLuint) trackID {
	[self enableAnimationOnTrack: trackID];
	for (CC3Node* child in _children) [child enableAllAnimationOnTrack: trackID];
}

-(void) disableAllAnimationOnTrack: (GLuint) trackID {
	[self disableAnimationOnTrack: trackID];
	for (CC3Node* child in _children) [child disableAllAnimationOnTrack: trackID];
}

-(void) enableAllAnimation {
	[self enableAnimation];
	for (CC3Node* child in _children) [child enableAllAnimation];
}

-(void) disableAllAnimation {
	[self disableAnimation];
	for (CC3Node* child in _children) [child disableAllAnimation];
}

-(void) enableLocationAnimation {
	for (CC3NodeAnimationState* as in _animationStates) as.isLocationAnimationEnabled = YES;
}

-(void) disableLocationAnimation {
	for (CC3NodeAnimationState* as in _animationStates) as.isLocationAnimationEnabled = NO;
}

-(void) enableQuaternionAnimation {
	for (CC3NodeAnimationState* as in _animationStates) as.isQuaternionAnimationEnabled = YES;
}

-(void) disableQuaternionAnimation {
	for (CC3NodeAnimationState* as in _animationStates) as.isQuaternionAnimationEnabled = NO;
}

-(void) enableScaleAnimation {
	for (CC3NodeAnimationState* as in _animationStates) as.isScaleAnimationEnabled = YES;
}

-(void) disableScaleAnimation {
	for (CC3NodeAnimationState* as in _animationStates) as.isScaleAnimationEnabled = NO;
}

-(void) enableAllLocationAnimation {
	[self enableLocationAnimation];
	for (CC3Node* child in _children) [child enableAllLocationAnimation];
}

-(void) disableAllLocationAnimation {
	[self disableLocationAnimation];
	for (CC3Node* child in _children) [child disableAllLocationAnimation];
}

-(void) enableAllQuaternionAnimation {
	[self enableQuaternionAnimation];
	for (CC3Node* child in _children) [child enableAllQuaternionAnimation];
}

-(void) disableAllQuaternionAnimation {
	[self disableQuaternionAnimation];
	for (CC3Node* child in _children) [child disableAllQuaternionAnimation];
}

-(void) enableAllScaleAnimation {
	[self enableScaleAnimation];
	for (CC3Node* child in _children) [child enableAllScaleAnimation];
}

-(void) disableAllScaleAnimation {
	[self disableScaleAnimation];
	for (CC3Node* child in _children) [child disableAllScaleAnimation];
}

-(void) markAnimationDirty { _isAnimationDirty = YES; }


#pragma mark Establishing an animation frame

-(void) establishAnimationFrameAt: (CCTime) t onTrack: (GLuint) trackID {
	[[self getAnimationStateOnTrack: trackID] establishFrameAt: t];
	for (CC3Node* child in _children) [child establishAnimationFrameAt: t onTrack: trackID];
}

/** Updates this node from a blending of any contained animation. */
-(void) updateFromAnimationState {
	if ( !_isAnimationDirty ) return;
	
	// Start with identity transforms
	CC3Vector blendedLoc = kCC3VectorZero;
	CC3Vector blendedRot = kCC3VectorZero;
	CC3Quaternion blendedQuat = kCC3QuaternionIdentity;
	CC3Vector blendedScale = kCC3VectorUnitCube;
	
	// Accumulated weights
	GLfloat totWtL = 0.0f;		// Accumulated location weight
	GLfloat totWtR = 0.0f;		// Accumulated rotation weight
	GLfloat totWtQ = 0.0f;		// Accumulated quaternion weight
	GLfloat totWtS = 0.0f;		// Accumulated scale weight
	
	for (CC3NodeAnimationState* as in _animationStates) {
		GLfloat currWt = as.blendingWeight;
		if (currWt && as.isEnabled) {		// Don't blend if disabled or zero weight
			
			// Blend the location
			if (as.isAnimatingLocation) {
				totWtL += currWt;
				blendedLoc = CC3VectorLerp(blendedLoc, as.location, (currWt / totWtL));
			}
			
			// Blend the quaternion
			if (as.isAnimatingQuaternion) {
				totWtQ += currWt;
				blendedQuat = CC3QuaternionSlerp(blendedQuat, as.quaternion, (currWt / totWtQ));
			}
			
			// Blend the scale
			if (as.isAnimatingScale) {
				totWtS += currWt;
				blendedScale = CC3VectorLerp(blendedScale, as.scale, (currWt / totWtS));
			}
		}
	}
	
	if (totWtL) self.location = blendedLoc;
	if (totWtR) self.rotation = blendedRot;
	if (totWtQ) self.quaternion = blendedQuat;
	if (totWtS) self.scale = blendedScale;
	
	_isAnimationDirty = NO;
}


#pragma mark Developer support

#define kAnimStateDescLen 100

-(NSString*) describeCurrentAnimationState {
	NSMutableString* desc = [NSMutableString stringWithCapacity: (_animationStates.count * kAnimStateDescLen)];
	for (CC3NodeAnimationState* as in _animationStates) [desc appendFormat: @"\n%@ ", as.describeCurrentState];
	return desc;
}

-(NSString*) describeAnimationStateForFrames: (GLuint) frameCount fromTime: (CCTime) startTime toTime: (CCTime) endTime {
	NSMutableString* desc = [NSMutableString stringWithCapacity: (_animationStates.count * kAnimStateDescLen * frameCount + 200)];
	for (CC3NodeAnimationState* as in _animationStates)
		[desc appendFormat: @"\n%@ ", [as describeStateForFrames: frameCount fromTime: startTime toTime: endTime]];
	return desc;
}

-(NSString*) describeAnimationStateForFrames: (GLuint) frameCount {
	return [self describeAnimationStateForFrames: frameCount fromTime: 0.0f toTime: 1.0f];
}


#pragma mark Deprecated functionality

-(GLuint) animationFrameCount { return self.animation.frameCount; }
-(void) establishAnimationFrameAt: (CCTime) t { [self establishAnimationFrameAt: t onTrack: 0]; }

@end