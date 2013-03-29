/*
 * CC3NodeAnimation.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Node.h"

@class CC3NodeAnimationState;


#pragma mark -
#pragma mark CC3NodeAnimation

/** 
 * A CC3NodeAnimation manages the animation of a node.
 *
 * An instance is held in the animation property of the node itself, and the node delegates
 * to its CC3NodeAnimation when the establishAnimationFrameAt: method is invoked on the node.
 *
 * Animations define animated content in in a series of frames (often called key-frames),
 * and can be configured to interpolate the animated state between these frames if necessary,
 * ensuring smooth animation, regardless of how many, or how widely spaced, the frames of
 * actual animated content are.
 *
 * A single CC3NodeAnimation instance can be shared by multiple nodes. This is a typical
 * situation when creating many copies of a node that is animated.
 *
 * CC3NodeAnimation is an abstract class. Subclasses define concrete animation data storage.
 */
@interface CC3NodeAnimation : NSObject {
	GLuint _frameCount;
	BOOL _shouldInterpolate : 1;
}

/**
 * The number of frames of animated content.
 *
 * This property indicates the number of frames for which animated content is available (often
 * called key-frames). Because animations can be configured to interpolate between frames, it
 * is quite common for the effective number of animated frames to be substantially higher than
 * the number of frames of available animated content.
 *
 * As an extreme example, this property might indicate only two frames of animated content
 * (a beginning and end state). If that animation played out over 10 seconds, it would interpolate
 * several hundred "tween-frames", creating a smooth transition from the beginning to end state.
 * More commonly, animations will specify a number of frames of content, to ensure sophisticated
 * and realistic animation.
 */
@property(nonatomic, readonly) GLuint frameCount;

/**
 * Indicates whether this animation should interpolate between frames, to ensure smooth
 * transitions between frame content.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldInterpolate;

/** Indicates whether location animated content is available and is enabled.  */
@property(nonatomic, readonly) BOOL isAnimatingLocation;

/** Indicates whether rotation quaternion animated content is available and is enabled. */
@property(nonatomic, readonly) BOOL isAnimatingQuaternion;

/** Indicates whether scale animated content is available and is enabled. */
@property(nonatomic, readonly) BOOL isAnimatingScale;

/** 
 * Indicates whether animation is enabled and any animated content (location, quaternion,
 * or scale) is available and enabled.
 */
@property(nonatomic, readonly) BOOL isAnimating;

/**
 * Indicates whether the time interval between frames can vary from frame to frame, or whether
 * the time interval between frames is constant across all frames.
 *
 * If this property returns NO, the frames of this animation are equally spaced in time.
 */
@property(nonatomic, readonly) BOOL hasVariableFrameTiming;

/**
 * Indicates a fractional value of a frame below which interpolation will not be performed.
 *
 * If an animation time is within this fraction above or below an exact frame time (relative to
 * the previous or next frame), the frame time itself is used, instead of interpolating between
 * that frame time and the next or previous frame time. This allows the animation to avoid an
 * interpolation calculation if the difference will be unnoticable when compared to simply using
 * the values for that specific frame.
 *
 * This value is specified as a fraction of a frame (between zero and one). The initial value is
 * set at 0.1, indicating that no interpolation will be performed if the animation time is within
 * 10% of the duration between the frame and the frame before or after it.
 *
 * Setting the value of this property to zero will cause interpolation to always be performed,
 * and setting the value to one will cause interpolation to never be performed.
 *
 * The value of this class-side property affects all animation.
 */
+(ccTime) interpolationEpsilon;

/**
 * Indicates a fractional value of a frame below which interpolation will not be performed.
 *
 * If an animation time is within this fraction above or below an exact frame time (relative to
 * the previous or next frame), the frame time itself is used, instead of interpolating between
 * that frame time and the next or previous frame time. This allows the animation to avoid an
 * interpolation calculation if the difference will be unnoticable when compared to simply using
 * the values for that specific frame.
 *
 * This value is specified as a fraction of a frame (between zero and one). The initial value is
 * set at 0.1, indicating that no interpolation will be performed if the animation time is within
 * 10% of the duration between the frame and the frame before or after it.
 *
 * Setting the value of this property to zero will cause interpolation to always be performed,
 * and setting the value to one will cause interpolation to never be performed.
 *
 * The value of this class-side property affects all animation.
 */
+(void) setInterpolationEpsilon: (ccTime) epsilon;


#pragma mark Allocation and initialization

/** Initializes this instance to animate with the specified number of animation frames. */
-(id) initWithFrameCount: (GLuint) numFrames;

/**
 * Allocates and initializes an autoreleased instance to animate
 * with the specified number of animation frames.
 */
+(id) animationWithFrameCount: (GLuint) numFrames;


#pragma mark Updating

/**
 * Updates the location, quaternion, and scale of the specified animation state based on the
 * animation frame located at the specified time, which should be a value between zero and one,
 * with zero indicating the first animation frame, and one indicating the last animation frame.
 *
 * Only those properties of the animation state for which there is animation data will be changed.
 * If the shouldInterpolate property is set to YES, linear interpolation of the frame
 * data is performed, based on the frameCount and the specified time.
 */
-(void) establishFrameAt: (ccTime) t inNodeAnimationState: (CC3NodeAnimationState*) animState;

/** @deprecated Use establishFrameAt:inNodeAnimationState: instead. */
-(void) establishFrameAt: (ccTime) t forNode: (CC3Node*) aNode DEPRECATED_ATTRIBUTE;

/**
 * Returns the time at which the frame at the specified index occurs. The returned time
 * value will be between zero and one, where zero represents the time of the first frame
 * and one represents the time of the last frame.
 *
 * This base implementation assumes a constant time between each frame and the next, so the
 * returned value is calculated as (frameIndex / (frameCount - 1)), which is then clamped to
 * the range between zero and one. Subclasses that allow variable times between frames will
 * override to return the appropriate value.
 */
-(ccTime) timeAtFrame: (GLuint) frameIndex;

@end


#pragma mark -
#pragma mark CC3ArrayNodeAnimation

/** 
 * A concrete CC3NodeAnimation that holds animation data in simple arrays.
 * The arrays can be allocated and managed either by the instance, or externally.
 *
 * There are three properties that hold the animated content:
 *   - animatedLocations - location animation content
 *   - animatedQuaternions - rotation quaternion animation content
 *   - animatedScales - scale animation content
 *
 * You do not need to use all of these properties. You can choose to animate any subset of
 * these animation data properties, and leave the remaining animation data properties set to
 * NULL (the default). If you do not set an animation data property, the corresponding property
 * on the node will not be animated, and will retain its originally set value.
 *
 * For example, if you set only the animatedLocations property, and run a CC3Animate on the node,
 * only the location of the node will move around during the animation. The remaining node
 * properties (quaternion & scale) will remain unchanged by the animation. The effect will be
 * that the node moves around, but remains at a fixed size, and oriented in a fixed rotation.
 *
 * This animation can be configured so that time interval between frames can vary from frame
 * to frame, or that the time interval between frames is constant. To configure for variable
 * frame timing, use the frameTimes property to assign a specific time to each frame. To
 * configure for equally-spaced frames, set the frameTimes property to NULL.
 *
 * You can work with these animation content properties in one of two ways:
 *   - Allocate the arrays outside this class and simply assign them to this instance using the
 *     property accessors. In this case, it is up to you to allocate and deallocate the memory
 *     used by the arrays.
 *   - Invoke one or more of the methods allocateFrameTimes, allocateLocations, allocateQuaternions,
 *     and allocateScales to instruct this instance to allocate and manage the memory for the content
 *     array. You can then access the associated array via the frameTimes, animatedLocations,
 *     animatedQuaternions, and animatedScales properties respectively. This instance will take
 *     care of releasing the arrays when appropriate.
 */
@interface CC3ArrayNodeAnimation : CC3NodeAnimation {
	ccTime* _frameTimes;
	CC3Vector* _animatedLocations;
	CC3Quaternion* _animatedQuaternions;
	CC3Vector* _animatedScales;
	BOOL _frameTimesAreRetained : 1;
	BOOL _locationsAreRetained : 1;
	BOOL _quaternionsAreRetained : 1;
	BOOL _scalesAreRetained : 1;
}

/**
 * An array of frame times. Each ccTime in the array indicates the time for one frame. All values
 * must be within the range from zero and one inclusive. For accurate animation, the value of
 * the first element of this array should be zero, and the value of the last element should be one.
 * The array must have at least frameCount elements.
 *
 * This property can be set to NULL to indicate that the duration of all of the frames is the same.
 *
 * The hasVariableFrameTiming property will return YES if this property is not NULL, and NO otherwise.
 *
 * Setting this property will safely free any memory allocated by the allocateFrameTimes method.
 *
 * The initial value of this property is NULL, indicating that the frames are equally spaced.
 */
@property(nonatomic, assign) ccTime* frameTimes;

/**
 * An array of animated location content. Each CC3Vector in the array holds the location content
 * for one frame of animation. The array must have at least frameCount elements.
 *
 * This property can be set to NULL to indicate that the location is not animated.
 *
 * The isAnimatingLocation property will return YES if this property is not NULL, and NO otherwise.
 *
 * Setting this property will safely free any memory allocated by the allocateLocations method.
 *
 * The initial value of this property is NULL.
 */
@property(nonatomic, assign) CC3Vector* animatedLocations;

/**
 * An array of animated rotation quaternion content. Each CC3Quaternion in the array holds the
 * rotation content for one frame of animation. The array must have at least frameCount elements.
 *
 * This property can be set to NULL to indicate that the rotation is not animated.
 *
 * The isAnimatingQuaternion property will return YES if this property is not NULL, and NO otherwise.
 *
 * Setting this property will safely free any memory allocated by the allocateQuaternions method.
 *
 * The initial value of this property is NULL.
 */
@property(nonatomic, assign) CC3Quaternion* animatedQuaternions;

/**
 * An array of animated scale content. Each CC3Vector in the array holds the scale content
 * for one frame of animation. The array must have at least frameCount elements.
 *
 * This property can be set to NULL to indicate that the scale is not animated.
 *
 * The isAnimatingScale property will return YES if this property is not NULL, and NO otherwise.
 *
 * Setting this property will safely free any memory allocated by the allocateScales method.
 *
 * The initial value of this property is NULL.
 */
@property(nonatomic, assign) CC3Vector* animatedScales;

/**
 * Allocates underlying memory for an array of frame times.
 * All elements of the array are initialized to zero.
 * The amount of memory allocated will be (frameCount * sizeof(ccTime)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(ccTime*) allocateFrameTimes;

/**
 * Allocates underlying memory for an array of location vectors.
 * All elements of the array are initialized to zero location.
 * The amount of memory allocated will be (frameCount * sizeof(CC3Vector)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(CC3Vector*) allocateLocations;

/**
 * Allocates underlying memory for an array of quaternions vectors.
 * All elements of the array are initialized to the identity quaternion.
 * The amount of memory allocated will be (frameCount * sizeof(CC3Quaternion)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(CC3Quaternion*) allocateQuaternions;

/**
 * Allocates underlying memory for an array of scale vectors.
 * All elements of the array are initialized to unity scale.
 * The amount of memory allocated will be (frameCount * sizeof(CC3Vector)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(CC3Vector*) allocateScales;

/**
 * Deallocates the underlying frame times array allocated with the allocateFrameTimes method.
 * It is safe to invoke this method more than once, or even if allocateFrameTimes was not
 * previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateFrameTimes;

/**
 * Deallocates the underlying location array allocated with the allocateLocations method.
 * It is safe to invoke this method more than once, or even if allocateLocations was not
 * previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateLocations;

/**
 * Deallocates the underlying quaternion array allocated with the allocateQuaternions method.
 * It is safe to invoke this method more than once, or even if allocateQuaternions was not
 * previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateQuaternions;

/**
 * Deallocates the underlying scale array allocated with the allocateScales method.
 * It is safe to invoke this method more than once, or even if allocateScales was not
 * previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateScales;

@end


#pragma mark -
#pragma mark CC3NodeAnimationState

/**
 * CC3NodeAnimationState holds the state associated with the animation of a single node on a single track.
 *
 * Each node can participate in multiple tracks of animation, and during animation, these tracks
 * can be mixed to perform sophisticated animation blending techniques.
 *
 * Each instance of this class bridges a single CC3Node with an CC3NodeAnimation running on
 * on a particular track, and keeps track of the animation state on behalf of the node.
 */
@interface CC3NodeAnimationState : NSObject {
	CC3Node* _node;
	CC3NodeAnimation* _animation;
	ccTime _animationTime;
	CC3Vector _location;
	CC3Quaternion _quaternion;
	CC3Vector _scale;
	GLuint _trackID;
	GLfloat _blendingWeight;
	BOOL _isEnabled : 1;
	BOOL _isLocationAnimationEnabled : 1;
	BOOL _isQuaternionAnimationEnabled : 1;
	BOOL _isScaleAnimationEnabled : 1;
}

/** The node whose animation state is being tracked by this instance.  */
@property (nonatomic, assign, readonly) CC3Node* node;

/** The animation whose state is being tracked by this instance. */
@property (nonatomic, retain, readonly) CC3NodeAnimation* animation;

/** The animation track on which the animation runs. */
@property (nonatomic, assign, readonly) GLuint trackID;

/** 
 * The relative weight to use when blending this animation track with the other tracks.
 * For each animation state in a node, this value can be set to a value between zero and one.
 * During animation, the animated node properties (location, quaternion, scale) are derived
 * from a weighted average of the contributions from each animation track, as determined by
 * the relative weights assigned to each animation track, as specified by this property.
 *
 * For each track, the blending weight is relative to the blending weights of the other tracks,
 * and the absolute values used for this property are unimportant. So, for instance, setting the
 * value of this property to 0.2 on one track and 0.1 on another is equivalent to setting the value
 * of this property to 1.0 and 0.5 respectively. In both cases, the first animation track will
 * contribute twice the effect on the node's animated properties than the second animation track.
 *
 * It is important to understand that with multi-track animation, each animation track will
 * contribute to the node's animated properties according to its weight even in the absence of
 * a CC3Animate action running on that track. This is to ensure smooth transitions before and
 * after a CC3Animate is run. To stop a track from contributing to the animated properties of
 * the node, either set the value of this property to zero, or set the isEnabled property to NO.
 *
 * The initial value of this property is one.
 */
@property (nonatomic, assign) GLfloat blendingWeight;

/**
 * Indicates whether this animation is enabled, and will participate in animating the
 * contained node if an animate action is run on the node.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL isEnabled;

/**
 * Indicates whether animation of the location property of the node is enabled.
 *
 * The initial value of this property is YES. Setting this property to NO will disable animation
 * of the node's location property, but will permit other properties to be animated.
 */
@property(nonatomic, assign) BOOL isLocationAnimationEnabled;

/**
 * Indicates whether animation of the quaternion property of the node is enabled.
 *
 * The initial value of this property is YES. Setting this property to NO will disable animation
 * of the node's quaternion property, but will permit other properties to be animated.
 */
@property(nonatomic, assign) BOOL isQuaternionAnimationEnabled;

/**
 * Indicates whether animation of the scale property of the node is enabled.
 *
 * The initial value of this property is YES. Setting this property to NO will disable animation
 * of the node's scale property, but will permit other properties to be animated.
 */
@property(nonatomic, assign) BOOL isScaleAnimationEnabled;

/** Sets the isEnabled property to YES. */
-(void) enable;

/** Sets the isEnabled property to NO. */
-(void) disable;

/**
 * Returns the current animation time. This is the value submitted to the most recent invocation
 * of the establishFrameAt: method, or zero if that method has not yet been invoked.
 */
@property(nonatomic, readonly) ccTime animationTime;

/**
 * The current animated location.
 *
 * The value of this property is updated by the animation when the establishFrameAt: is invoked.
 */
@property(nonatomic, assign) CC3Vector location;

/**
 * The current animated rotation quaternion.
 *
 * The value of this property is updated by the animation when the establishFrameAt: is invoked.
 */
@property(nonatomic, assign) CC3Quaternion quaternion;

/**
 * The current animated scale.
 *
 * The value of this property is updated by the animation when the establishFrameAt: is invoked.
 */
@property(nonatomic, assign) CC3Vector scale;

/**
 * The number of frames of animated content.
 *
 * The value of this property is retrieved from the same property on the contained animation instance.
 */
@property(nonatomic, readonly) GLuint frameCount;

/** 
 * Indicates whether the location property of the node is being animated. It is if both the
 * isLocationAnimationEnabled property of this instance, and the isAnimatingLocation property
 * of the contained animation, are set to YES.
 */
@property(nonatomic, readonly) BOOL isAnimatingLocation;

/**
 * Indicates whether the quaternion property of the node is being animated. It is if both the
 * isQuaternionAnimationEnabled property of this instance, and the isAnimatingQuaternion property
 * of the contained animation, are set to YES.
 */
@property(nonatomic, readonly) BOOL isAnimatingQuaternion;

/**
 * Indicates whether the scale property of the node is being animated. It is if both the
 * isScaleAnimationEnabled property of this instance, and the isAnimatingScale property
 * of the contained animation, are set to YES.
 */
@property(nonatomic, readonly) BOOL isAnimatingScale;

/**
 * Indicates whether any of the properties of the node are being animated. Returns YES if any of
 * the isAnimatingLocation, isAnimatingQuaternion or isAnimatingScale properties returns YES.
 */
@property(nonatomic, readonly) BOOL isAnimating;

/**
 * Indicates whether the time interval between frames can vary from frame to frame, or whether
 * the time interval between frames is constant across all frames.
 *
 * If this property returns NO, the frames of this animation are equally spaced in time.
 *
 * The value of this property is retrieved from the same property on the contained animation instance.
 */
@property(nonatomic, readonly) BOOL hasVariableFrameTiming;


#pragma mark Updating

/**
 * Updates the currentFrame, location, quaternion, and scale of this instance based on the
 * animation content found in the contained animation at the specified time, which should
 * be a value between zero and one, with zero indicating the first animation frame, and one
 * indicating the last animation frame.
 */
-(void) establishFrameAt: (ccTime) t;


#pragma mark Allocation and initialization

/**
 * Initializes this instance tracking the animation state for the specified animation running on
 * the specified track for the specified node.
 *
 * Returns nil if either the animation or the node are nil.
 */
-(id) initWithAnimation: (CC3NodeAnimation*) animation onTrack: (GLuint) trackID forNode: (CC3Node*) node;

/**
 * Allocates and initializes an autoreleased instance tracking the animation state for the
 * specified animation running on the specified track for the specified node.
 *
 * Returns nil if either the animation or the node are nil.
 */
+(id) animationStateWithAnimation: (CC3NodeAnimation*) animation onTrack: (GLuint) trackID forNode: (CC3Node*) node;

/**
 * Returns the next available trackID value. The value returned is guaranteed to be different
 * each time this method is invoked.
 *
 * When using multi-track animation in a node assembly, the trackID identifies a particular
 * animation track within that node assembly. Since any particular track may only affect a
 * few nodes within the entire node assembly, when adding a new animation track to the node
 * assembly, it can be difficult to know how to select a track ID that will not conflict with
 * any existing tracks within that node assembly. This method can be used to generate a unique
 * track ID to use when adding a new track of animation to a node assembly.
 */
+(GLuint) generateTrackID;


#pragma mark Descriptions

/** Returns a description of the current state, including time and animated location, quaternion and scale. */
-(NSString*) describeCurrentState;

/** Returns a description of the state at each of frameCount frames over the entire animation. */
-(NSString*) describeStateForFrames: (GLuint) frameCount;

/**
 * Returns a description of the state at each of frameCount frames between the specified
 * start and end times, which should each be in the range between zero and one.
 */
-(NSString*) describeStateForFrames: (GLuint) frameCount fromTime: (ccTime) startTime toTime: (ccTime) endTime;

@end


