/*
 * CC3NodeAnimation.h
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
+(CCTime) interpolationEpsilon;

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
+(void) setInterpolationEpsilon: (CCTime) epsilon;


#pragma mark Allocation and initialization

/** Initializes this instance to animate with the specified number of animation frames. */
-(id) initWithFrameCount: (GLuint) numFrames;

/**
 * Allocates and initializes an autoreleased instance to animate
 * with the specified number of animation frames.
 */
+(id) animationWithFrameCount: (GLuint) numFrames;


#pragma mark Animating

/**
 * Updates the location, quaternion, and scale of the specified animation state based on the
 * animation frame located at the specified time, which should be a value between zero and one,
 * with zero indicating the first animation frame, and one indicating the last animation frame.
 *
 * Only those properties of the animation state for which there is animation data will be changed.
 * If the shouldInterpolate property is set to YES, linear interpolation of the frame
 * data is performed, based on the frameCount and the specified time.
 */
-(void) establishFrameAt: (CCTime) t inNodeAnimationState: (CC3NodeAnimationState*) animState;

/** @deprecated Use establishFrameAt:inNodeAnimationState: instead. */
-(void) establishFrameAt: (CCTime) t forNode: (CC3Node*) aNode DEPRECATED_ATTRIBUTE;

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
-(CCTime) timeAtFrame: (GLuint) frameIndex;

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
	CCTime* _frameTimes;
	CC3Vector* _animatedLocations;
	CC3Quaternion* _animatedQuaternions;
	CC3Vector* _animatedScales;
	BOOL _frameTimesAreRetained : 1;
	BOOL _locationsAreRetained : 1;
	BOOL _quaternionsAreRetained : 1;
	BOOL _scalesAreRetained : 1;
}

/**
 * An array of frame times. Each CCTime in the array indicates the time for one frame. All values
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
@property(nonatomic, assign) CCTime* frameTimes;

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
 * The amount of memory allocated will be (frameCount * sizeof(CCTime)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(CCTime*) allocateFrameTimes;

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
#pragma mark CC3FrozenNodeAnimation

/**
 * A concrete CC3NodeAnimation that holds animation a single, frozen animation frame.
 *
 * A node containing a CC3FrozenNodeAnimation will have its location, quaternion, and scale
 * properties frozen to the values of the corresponding properties of this instance, and
 * every frame of animation will use the same values.
 *
 * This freezing behaviour is different than if the node had no animation at all. A node with
 * no animation content can have its location, quaternion, and scale properties freely set,
 * even while animation is running. By contrast, while an animation is running on the node
 * containing instance of CC3FrozenNodeAnimation, the values of the location, quaternion,
 * and scale properties will each be locked to a single value.
 *
 * Instances of this class can be useful if a node is not really animated, but you want to
 * ensure that, when a particular animation is playing on a node assembly, the node is forced
 * to a particular location, rotation, and scale.
 *
 * You do not need to use all of these animation properties. If you don't want to force an
 * animation component to a particular value, set the corresponding property to a null value
 * (kCC3VectorNull or kCC3QuaternionNull). The corresponding isAnimatingLocation, 
 * isAnimatingQuaternion or isAnimatingScale will thereafter return NO.
 *
 * The frameCount property will always return 1. The shouldInterpolate property is ignored.
 */
@interface CC3FrozenNodeAnimation : CC3NodeAnimation {
	CC3Vector _location;
	CC3Quaternion _quaternion;
	CC3Vector _scale;
}

/**
 * A single location to which the node will be frozen throughout the animation.
 *
 * If you don't want to force the node to a particular location during the animation, set this
 * property to kCC3VectorNull. The corresponding isAnimatingLocation property will thereafter
 * return NO, and the location of the node will be left unchanged during animation.
 *
 * The initial value of this property is kCC3VectorNull.
 */
@property(nonatomic, assign) CC3Vector location;

/**
 * A single rotation quaterion to which the node will be frozen throughout the animation.
 *
 * If you don't want to force the node to a particular rotation during the animation, set this
 * property to kCC3QuaternionNull. The corresponding isAnimatingQuaternion property will thereafter
 * return NO, and the rotation of the node will be left unchanged during animation.
 *
 * The initial value of this property is kCC3QuaternionNull.
 */
@property(nonatomic, assign) CC3Quaternion quaternion;

/**
 * A single scale to which the node will be frozen throughout the animation.
 *
 * If you don't want to force the node to a particular scale during the animation, set this
 * property to kCC3VectorNull. The corresponding isAnimatingScale property will thereafter
 * return NO, and the scale of the node will be left unchanged during animation.
 *
 * The initial value of this property is kCC3VectorNull.
 */
@property(nonatomic, assign) CC3Vector scale;

/**
 * Populates the location, quaternion and scale properties from the current values of the 
 * corresponding properties of the specfied node.
 */
-(void) populateFromNodeState: (CC3Node*) aNode;


#pragma mark Allocation and initialization

/** Allocates and initializes an instance with null location, quaternion and scale properties. */
+(id) animation;

/**
 * Initializes this instance with location, quaternion and scale properties set
 * from the current values of the corresponding properties of the specfied node.
 */
-(id) initFromNodeState: (CC3Node*) aNode;

/** 
 * Allocates and initializes an instance with location, quaternion and scale properties set
 * from the current values of the corresponding properties of the specfied node. 
 */
+(id) animationFromNodeState: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodeAnimationSegment

/**
 * A CC3NodeAnimationSegment plays a segment of the animation data contained within another
 * CC3NodeAnimation.
 *
 * An instance of CC3NodeAnimationSegment is constructed with a reference to an underlying
 * base animation, along with references to start and end times within that underlying animation.
 *
 * The CC3NodeAnimationSegment maps its standard zero-to-one animation range to the segment
 * of the base animation defined by the start and end times of the CC3NodeAnimationSegment.
 *
 * As an example, a CC3NodeAnimationSegment with a startTime of 0.2 and endTime of 0.5 maps
 * the full 0.0 - 1.0 animation range to the frames contained within the range of 0.2 - 0.5
 * in the base animation. In this case, requesting the animation of frames at times 0.0, 0.4
 * and 1.0 from the CC3NodeAnimationSegment instance will result in the animation of the
 * frames at times 0.2, 0.32, 0.5 from the base animation (0.32 = 0.2 + (0.5 - 0.2) * 0.4).
 *
 * The values of all read-only properties and methods are retrieved from the underlying base animation.
 */
@interface CC3NodeAnimationSegment : CC3NodeAnimation {
	CC3NodeAnimation* _baseAnimation;
	CCTime _startTime;
	CCTime _endTime;
}

/** The CC3NodeAnimation containing the underlying animation data. */
@property(nonatomic, strong, readonly) CC3NodeAnimation* baseAnimation;

/**
 * The time within the underlying animation data that corresponds to the first frame of animation
 * that will be animated by this instance.
 *
 * The value of this property must be between zero and one, with zero and one indicating the
 * beginning and end of the underlying animation data, respectively.
 *
 * See the class notes for more information about how to set the values of the startTime and
 * endTime properties to create an animation segment from the underlying animation data.
 */
@property(nonatomic, assign) CCTime startTime;

/**
 * The time within the underlying animation data that corresponds to the last frame of animation
 * that will be animated by this instance.
 *
 * The value of this property must be between zero and one, with zero and one indicating the
 * beginning and end of the underlying animation data, respectively.
 *
 * See the class notes for more information about how to set the values of the startTime and
 * endTime properties to create an animation segment from the underlying animation data.
 */
@property(nonatomic, assign) CCTime endTime;

/**
 * The index of the first frame that will be animated from the underlying animation data.
 *
 * The value of this property will be between zero and one less than the value of the frameCount
 * property.
 *
 * This is a convenience property. Setting the value of this property sets the value of the 
 * startTime property by determining the time of the frame in the underlying base animation 
 * data corresponding to the frame index. The value derived depends on the number of frames
 * of animation in the underlying animation data, and whether it has linear or variable frame
 * timing. The use of this property makes most sense when the frame timing is linear (a constant
 * time between each pair of consecutive frames).
 *
 * See the class notes for more information about how to set the values of the startTime and
 * endTime properties to create an animation segment from the underlying animation data.
 */
@property(nonatomic, assign) GLuint startFrameIndex;

/**
 * The index of the last frame that will be animated from the underlying animation data.
 *
 * The value of this property will be between zero and one less than the value of the frameCount
 * property.
 *
 * This is a convenience property. Setting the value of this property sets the value of the
 * endTime property by determining the time of the frame in the underlying base animation
 * data corresponding to the frame index. The value derived depends on the number of frames
 * of animation in the underlying animation data, and whether it has linear or variable frame
 * timing. The use of this property makes most sense when the frame timing is linear (a constant
 * time between each pair of consecutive frames).
 *
 * See the class notes for more information about how to set the values of the startTime and
 * endTime properties to create an animation segment from the underlying animation data.
 */
@property(nonatomic, assign) GLuint endFrameIndex;


#pragma mark Allocation and initialization

/** 
 * Initializes this instance to animate a segment of the specified base animation.
 *
 * Initially, this animation will use the entire base animation. You can limit the range
 * to a segment of the full animation by setting the startTime and endTime properties.
 */
-(id) initOnAnimation: (CC3NodeAnimation*) baseAnimation;

/**
 * Allocates and initializes an autoreleased instance to animate a segment of the specified
 * base animation.
 *
 * Initially, this animation will use the entire base animation. You can limit the range
 * to a segment of the full animation by setting the startTime and endTime properties.
 */
+(id) animationOnAnimation: (CC3NodeAnimation*) baseAnimation;

/**
 * Initializes this instance to animate a segment of the specified base animation, and with
 * the startTime and endTime properties set to the specified value.
 */
-(id) initOnAnimation: (CC3NodeAnimation*) baseAnimation
				 from: (CCTime) startTime
				   to: (CCTime) endTime;

/**
 * Allocates and initializes an autoreleased instance to animate a segment of the specified
 * base animation, and with the startTime and endTime properties set to the specified value.
 */
+(id) animationOnAnimation: (CC3NodeAnimation*) baseAnimation
					  from: (CCTime) startTime
						to: (CCTime) endTime;

/**
 * Initializes this instance to animate a segment of the specified base animation, and with
 * the startFrameIndex and endFrameIndex properties set to the specified value.
 */
-(id) initOnAnimation: (CC3NodeAnimation*) baseAnimation
			fromFrame: (GLuint) startFrameIndex
			  toFrame: (GLuint) endFrameIndex;

/**
 * Allocates and initializes an autoreleased instance to animate a segment of the specified
 * animation, and with the startTime and endTime properties to the specified value.
 */
+(id) animationOnAnimation: (CC3NodeAnimation*) baseAnimation
				 fromFrame: (GLuint) startFrameIndex
				   toFrame: (GLuint) endFrameIndex;

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
	CCTime _animationTime;
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
@property (nonatomic, strong, readonly) CC3NodeAnimation* animation;

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
@property(nonatomic, readonly) CCTime animationTime;

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


#pragma mark Animating

/**
 * Updates the currentFrame, location, quaternion, and scale of this instance based on the
 * animation content found in the contained animation at the specified time, which should
 * be a value between zero and one, with zero indicating the first animation frame, and one
 * indicating the last animation frame.
 */
-(void) establishFrameAt: (CCTime) t;


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
-(NSString*) describeStateForFrames: (GLuint) frameCount fromTime: (CCTime) startTime toTime: (CCTime) endTime;

@end


#pragma mark -
#pragma mark CC3Node animation

/** Extension category to add animation capabilities. */
@interface CC3Node (Animation)


#pragma mark Adding and accessing animation

/**
 * Returns the animation state wrapper on the specified animation track, or nil if no
 * animation has been defined for this node on that animation track.
 */
-(CC3NodeAnimationState*) getAnimationStateOnTrack: (GLuint) trackID;

/**
 * Adds the specified animation state wrapper, containing animation and track information.
 *
 * A node may contain only one animation per animation track. If an animation already exists
 * for the track represented in the specified animation state, it is replaced with the animation
 * in the specified animation state.
 *
 * Typically, to add animation to a node, the application would use the addAnimation:asTrack:
 * method, rather than this method.
 */
-(void) addAnimationState: (CC3NodeAnimationState*) animationState;

/**
 * Removes the specified animation state wrapper from this node.
 *
 * Typically, to remove animation from a node, the application would use the removeAnimation:
 * or removeAnimationTrack: methods, rather than this method.
 */
-(void) removeAnimationState: (CC3NodeAnimationState*) animationState;

/**
 * The animation state wrapper for animation track zero. This is a convenience property
 * for accessing the animation when only a single animation track is used.
 *
 * This wrapper is created automatically when the animation property is set.
 */
@property(nonatomic, strong, readonly) CC3NodeAnimationState* animationState;

/**
 * Returns the animation for the specified animation track, or nil if no animation
 * has been defined for this node on that animation track.
 */
-(CC3NodeAnimation*) getAnimationOnTrack: (GLuint) trackID;

/**
 * Adds the specified animation as the specified animation track.
 *
 * A node may contain only one animation per animation track. If an animation already
 * exists on the specified track, it is replaced with the specified animation.
 *
 * To animate this node, use this method to add one or more instances of a subclass of the
 * abstract CC3NodeAnimation class, populated with animation content, and then create an
 * instance of a CC3Animate action for each track, and selectively run them on this node.
 */
-(void) addAnimation: (CC3NodeAnimation*) animation asTrack: (GLuint) trackID;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation in track zero, which is the default track used during animation loading. A new
 * animation track ID is assigned, the new animation is added to this node on that animation
 * track, and the track ID is returned.
 *
 * The start and end times of the animation segment are defined by startTime and endTime,
 * each of which are specified as a fraction of the total animation contained in the base
 * animation track. Each of startTime and endTime must therefore be between zero and one.
 *
 * For example, if you wish to create a new animation track that plays the middle third of
 * an existing animation track, you would pass 0.3333 and 0.6667 as the startTime and endTime
 * parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(GLuint) addAnimationFrom: (CCTime) startTime
						to: (CCTime) endTime;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation track specified by baseTrackID. A new animation track ID is assigned, the new animation
 * is added to this node on that animation track, and the track ID is returned.
 *
 * The start and end times of the animation segment are defined by startTime and endTime,
 * each of which are specified as a fraction of the total animation contained in the base
 * animation track. Each of startTime and endTime must therefore be between zero and one.
 *
 * For example, if you wish to create a new animation track that plays the middle third of
 * an existing animation track, you would pass 0.3333 and 0.6667 as the startTime and endTime
 * parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(GLuint) addAnimationFrom: (CCTime) startTime
						to: (CCTime) endTime
			   ofBaseTrack: (GLuint) baseTrackID;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation in track zero, which is the default track used during animation loading. The new
 * animation is added to this node on the animation track specified by trackID.
 *
 * The start and end times of the animation segment are defined by startTime and endTime,
 * each of which are specified as a fraction of the total animation contained in the base
 * animation track. Each of startTime and endTime must therefore be between zero and one.
 *
 * For example, if you wish to create a new animation track that plays the middle third of
 * an existing animation track, you would pass 0.3333 and 0.6667 as the startTime and endTime
 * parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(void) addAnimationFrom: (CCTime) startTime
					  to: (CCTime) endTime
				 asTrack: (GLuint) trackID;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation track specified by baseTrackID. The new animation is added to this node on the
 * animation track specified by trackID.
 *
 * The start and end times of the animation segment are defined by startTime and endTime,
 * each of which are specified as a fraction of the total animation contained in the base
 * animation track. Each of startTime and endTime must therefore be between zero and one.
 *
 * For example, if you wish to create a new animation track that plays the middle third of
 * an existing animation track, you would pass 0.3333 and 0.6667 as the startTime and endTime
 * parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(void) addAnimationFrom: (CCTime) startTime
					  to: (CCTime) endTime
			 ofBaseTrack: (GLuint) baseTrackID
				 asTrack: (GLuint) trackID;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation in track zero, which is the default track used during animation loading. A new
 * animation track ID is assigned, the new animation is added to this node on that animation
 * track, and the track ID is returned.
 *
 * The start and end frames of the animation segment are defined by startFrameIndex and
 * endFrameIndex, each of which identify a frame in the base animation track, inclusively.
 * Frame indexing is zero-based, so the first frame is identified as frame index zero.
 *
 * For example, if you wish to create a new animation track that plays frames 10 through 20,
 * inclusively, of an existing animation track, you would pass 10 and 20 as the startFrameIndex
 * and endFrameIndex parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(GLuint) addAnimationFromFrame: (GLuint) startFrameIndex
						toFrame: (GLuint) endFrameIndex;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation track specified by baseTrackID. A new animation track ID is assigned, the new animation
 * is added to this node on that animation track, and the track ID is returned.
 *
 * The start and end frames of the animation segment are defined by startFrameIndex and
 * endFrameIndex, each of which identify a frame in the base animation track, inclusively.
 * Frame indexing is zero-based, so the first frame is identified as frame index zero.
 *
 * For example, if you wish to create a new animation track that plays frames 10 through 20,
 * inclusively, of an existing animation track, you would pass 10 and 20 as the startFrameIndex
 * and endFrameIndex parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(GLuint) addAnimationFromFrame: (GLuint) startFrameIndex
						toFrame: (GLuint) endFrameIndex
					ofBaseTrack: (GLuint) baseTrackID;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation in track zero, which is the default track used during animation loading. The new
 * animation is added to this node on the animation track specified by trackID.
 *
 * The start and end frames of the animation segment are defined by startFrameIndex and
 * endFrameIndex, each of which identify a frame in the base animation track, inclusively.
 * Frame indexing is zero-based, so the first frame is identified as frame index zero.
 *
 * For example, if you wish to create a new animation track that plays frames 10 through 20,
 * inclusively, of an existing animation track, you would pass 10 and 20 as the startFrameIndex
 * and endFrameIndex parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(void) addAnimationFromFrame: (GLuint) startFrameIndex
					  toFrame: (GLuint) endFrameIndex
					  asTrack: (GLuint) trackID;

/**
 * Many animated characters require the animation of multiple distinct movements. For example, a
 * bird character might have distinct flapping, landing, and pecking movements. A human character
 * might have distinct running, crouching and shooting movements.
 *
 * It is often useful to provide all of these movements as one long animation, and to play the
 * animation segments for specific movements as required by the application. Our human character
 * might run for a while, then crouch, take a few shots, and then start running again, all under
 * control of the application, by extracting and playing the animation segment for each movement,
 * in turn, from the single long animation that contains all the movements.
 *
 * To support this behaviour, you can load the entire long animation into one track of animation,
 * and then use this method to create a separate animation track that contains only the animation
 * for a single movement. You can then animate only that movement, or repeat only that movement
 * in a loop (such as running or flying), or blend that movement with other animation tracks to
 * allow your human character to run and shoot at the same time, or smoothly transition your bird
 * from the flapping movement to the landing movement.
 *
 * This method creates and adds a new animation track that plays only a segment of the existing
 * animation track specified by baseTrackID. The new animation is added to this node on the
 * animation track specified by trackID.
 *
 * The start and end frames of the animation segment are defined by startFrameIndex and
 * endFrameIndex, each of which identify a frame in the base animation track, inclusively.
 * Frame indexing is zero-based, so the first frame is identified as frame index zero.
 *
 * For example, if you wish to create a new animation track that plays frames 10 through 20,
 * inclusively, of an existing animation track, you would pass 10 and 20 as the startFrameIndex
 * and endFrameIndex parameters, respectively.
 *
 * This method is automatically propagated to all descendant nodes, so you only need to invoke
 * this method on a single ancestor node (eg- the root node of your character).
 */
-(void) addAnimationFromFrame: (GLuint) startFrameIndex
					  toFrame: (GLuint) endFrameIndex
				  ofBaseTrack: (GLuint) baseTrackID
					  asTrack: (GLuint) trackID;

/** Removes the specified animation from this node. */
-(void) removeAnimation: (CC3NodeAnimation*) animation;

/** Removes the animation on the specified animation track from this node and all descendant nodes. */
-(void) removeAnimationTrack: (GLuint) trackID;

/**
 * The animation content of animation track zero of this node.
 *
 * Setting this property is the same as invoking addAnimation:asTrack: and specifying track zero.
 * Querying this property is the same as invoking getAnimationOnTrack: and specifying track zero.
 *
 * To animate this node, set this property to an instance of a subclass of the abstract
 * CC3NodeAnimation class, populated with animation content, and then create an instance
 * of a CC3Animate action, and run it on this node.
 */
@property(nonatomic, strong) CC3NodeAnimation* animation;

/** Indicates whether this node, or any of its descendants, contains animation on the specified animation track. */
-(BOOL) containsAnimationOnTrack: (GLuint) trackID;

/** Indicates whether this node, or any of its descendants, contains animation on any tracks. */
@property(nonatomic, readonly) BOOL containsAnimation;

/**
 * Returns the current elapsed animation time for the animation on the specified track,
 * as a value between zero and one.
 *
 * If this node does not contain animation, returns the animation time from the first descendant
 * node that contains animation and has a non-zero animation time. Returns zero if no descendant
 * nodes contain animation, or all descendant animation times are zero.
 */
-(CCTime) animationTimeOnTrack: (GLuint) trackID;

/**
 * Returns the animation blending weight for the animation on the specified track.
 *
 * If this node does not contain animation, returns the blending weight from the first descendant
 * node that contains animation and has a non-zero blending weight. Returns zero if no descendant
 * nodes contain animation, or all descendant blending weights are zero.
 */
-(GLfloat) animationBlendingWeightOnTrack: (GLuint) trackID;

/**
 * Sets the animation blending weight for the animation on the specified track, and sets the
 * same weight into all descendants.
 *
 * When multiple animation tracks are active, the blending weight of a track determines the
 * relative influence the animation track has on the properties of this node. Animation tracks
 * with larger weights relative to the other tracks will have a proportionally larger influence
 * on the transform properties of the node. An animation track with a blending weight of zero
 * will have no influence on the properties of the node.
 *
 * The absolute value of the weights does not matter, nor do the weights across all animation
 * tracks have to add up to unity. Therefore, a blending weight of 0.2 on one track and a blending
 * weight of 0.1 on a second track will have exactly the same affect as a weight of 1.2 on the
 * first track and a weight of 0.6 on the second track. In both cases, the first animation track
 * will have twice the influence as the second animation track.
 *
 * When only one animation track is active, the blending weight has no effect unless it is zero.
 */
-(void) setAnimationBlendingWeight: (GLfloat) blendWeight onTrack: (GLuint) trackID;

/**
 * If this node does not currently contain animation on the specified track, the animation
 * on that track is set to an instance of CC3FrozenNodeAnimation, populated from the current
 * location, quaternion, and scale properties of this node, to effectively freeze this node
 * to its current location, rotation, and scale, throughout the animation of the specified track.
 *
 * If this node already contains a CC3FrozenNodeAnimation on the specified track (from a
 * prior invocation of this method), it is populated from the current location, quaternion,
 * and scale properties of this node, to effectively freeze this node to its current location,
 * rotation, and scale, throughout the animation of the specified track. It is safe, therefore,
 * to invoke this method more than once.
 *
 * If this node already contains animation of any other kind, this method does nothing.
 *
 * This freezing behaviour is different than if the node had no animation at all. A node with
 * no animation content can have its location, quaternion, and scale properties freely set,
 * even while animation is running. By contrast, while an animation is running on the node
 * containing instance of CC3FrozenNodeAnimation, the values of the location, quaternion,
 * and scale properties will each be locked to a single value.
 *
 * Invoking this method can be useful if this node is not really animated, but you want to ensure
 * that when animation is playing on a node assembly, that this node is forced to a particular
 * location, rotation, and scale.
 */
-(void) freezeIfInanimateOnTrack: (GLuint) trackID;

/**
 * Invokes the freezeIfInanimateOnTrack: method on this node and all descendant nodes, to
 * freeze each node that does not contain animation on the specified track, to its current
 * location, rotation, and scale, whenever animation is playing on the specified track.
 *
 * Invoking this method can be useful if any descendant nodes are not animated, and you want
 * to ensure that when animation is playing on the specified track, that those nodes will
 * be forced to their current location, quaternion, and scale values.
 *
 * It is safe to invoke this method more than once. Each time it is invoked, any inanimate
 * descendant nodes will be frozen to the location, quaternion, and scale values at the time
 * this method is invoked, whenever animation is playing on the specified track.
 */
-(void) freezeAllInanimatesOnTrack: (GLuint) trackID;


#pragma mark Enabling and disabling animation

/**
 * Enables the animation on all animation tracks of this node.
 *
 * This will not enable animation of child nodes.
 */
-(void) enableAnimation;

/**
 * Disables the animation on all animation tracks of this node.
 *
 * This will not disable animation of child nodes.
 */
-(void) disableAnimation;

/**
 * Indicates whether the animation on any animation track in this node is enabled.
 *
 * The value of this property applies only to this node, not the descendant nodes. Descendant nodes
 * that return YES to this method will be animated even if this node returns NO, and vice-versa.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL isAnimationEnabled;

/**
 * Enables the animation on the specified track of this node.
 *
 * This will not enable animation of child nodes.
 */
-(void) enableAnimationOnTrack: (GLuint) trackID;

/**
 * Disables the animation on the specified track of this node.
 *
 * This will not disable animation of child nodes.
 */
-(void) disableAnimationOnTrack: (GLuint) trackID;

/**
 * Indicates whether the animation on the specified animation track is enabled.
 *
 * The value returned by this method applies only to this node, not its child nodes. Child nodes
 * that return YES to this method will be animated even if this node returns NO, and vice-versa.
 *
 * The initial value of this property is YES.
 */
-(BOOL) isAnimationEnabledOnTrack: (GLuint) trackID;

/** Enables the animation on the specified track of this node, and all descendant nodes. */
-(void) enableAllAnimationOnTrack: (GLuint) trackID;

/** Disables the animation on the specified track of this node, and all descendant nodes. */
-(void) disableAllAnimationOnTrack: (GLuint) trackID;

/** Enables all animation tracks of this node, and all descendant nodes. */
-(void) enableAllAnimation;

/** Disables all animation tracks of this node, and all descendant nodes. */
-(void) disableAllAnimation;

/**
 * Enables the animation of the location property, without affecting the animation of the
 * other properties.
 *
 * This method works together with the enable/disableAnimation methods. For the location
 * property to be animated, both location animation and node animation must be enabled.
 * Both are enabled by default.
 *
 * This will not affect the animation of the location property of child nodes.
 */
-(void) enableLocationAnimation;

/**
 * Disables the animation of the location property, without affecting the animation of the
 * other properties.
 *
 * This method works together with the enable/disableAnimation methods. For the location
 * property to be animated, both location animation and node animation must be enabled.
 * Both are enabled by default.
 *
 * This will not affect the animation of the location property of child nodes.
 */
-(void) disableLocationAnimation;

/**
 * Enables the animation of the quaternion property, without affecting the animation of the
 * other properties.
 *
 * This method works together with the enable/disableAnimation methods. For the quaternion
 * property to be animated, both quaternion animation and node animation must be enabled.
 * Both are enabled by default.
 *
 * This will not affect the animation of the quaternion property of child nodes.
 */
-(void) enableQuaternionAnimation;

/**
 * Disables the animation of the quaternion property, without affecting the animation of the
 * other properties.
 *
 * This method works together with the enable/disableAnimation methods. For the quaternion
 * property to be animated, both quaternion animation and node animation must be enabled.
 * Both are enabled by default.
 *
 * This will not affect the animation of the quaternion property of child nodes.
 */
-(void) disableQuaternionAnimation;

/**
 * Enables the animation of the scale property, without affecting the animation of the
 * other properties.
 *
 * This method works together with the enable/disableAnimation methods. For the scale
 * property to be animated, both scale animation and node animation must be enabled.
 * Both are enabled by default.
 *
 * This will not affect the animation of the scale property of child nodes.
 */
-(void) enableScaleAnimation;

/**
 * Disables the animation of the scale property, without affecting the animation of the
 * other properties.
 *
 * This method works together with the enable/disableAnimation methods. For the scale
 * property to be animated, both scale animation and node animation must be enabled.
 * Both are enabled by default.
 *
 * This will not affect the animation of the scale property of child nodes.
 */
-(void) disableScaleAnimation;

/**
 * Enables the animation of the location property, without affecting the animation of the
 * other properties, on this node and all descendant nodes.
 *
 * This method works together with the enable/disableAnimation methods. For the location
 * property to be animated, both location animation and node animation must be enabled.
 * Both are enabled by default.
 */
-(void) enableAllLocationAnimation;

/**
 * Disables the animation of the location property, without affecting the animation of the
 * other properties, on this node and all descendant nodes.
 *
 * This method works together with the enable/disableAnimation methods. For the location
 * property to be animated, both location animation and node animation must be enabled.
 * Both are enabled by default.
 */
-(void) disableAllLocationAnimation;

/**
 * Enables the animation of the quaternion property, without affecting the animation of the
 * other properties, on this node and all descendant nodes.
 *
 * This method works together with the enable/disableAnimation methods. For the quaternion
 * property to be animated, both quaternion animation and node animation must be enabled.
 * Both are enabled by default.
 */
-(void) enableAllQuaternionAnimation;

/**
 * Disables the animation of the quaternion property, without affecting the animation of the
 * other properties, on this node and all descendant nodes.
 *
 * This method works together with the enable/disableAnimation methods. For the quaternion
 * property to be animated, both quaternion animation and node animation must be enabled.
 * Both are enabled by default.
 */
-(void) disableAllQuaternionAnimation;

/**
 * Enables the animation of the scale property, without affecting the animation of the
 * other properties, on this node and all descendant nodes.
 *
 * This method works together with the enable/disableAnimation methods. For the scale
 * property to be animated, both scale animation and node animation must be enabled.
 * Both are enabled by default.
 */
-(void) enableAllScaleAnimation;

/**
 * Disables the animation of the scale property, without affecting the animation of the
 * other properties, on this node and all descendant nodes.
 *
 * This method works together with the enable/disableAnimation methods. For the scale
 * property to be animated, both scale animation and node animation must be enabled.
 * Both are enabled by default.
 */
-(void) disableAllScaleAnimation;

/**
 * Marks the animation state of this node as dirty, indicating that the animated properties
 * of this node should be updated on the next update cycle.
 *
 * This method is invoked automatically if a animated property has been changed on any
 * animation track as a result of the invocation of the establishAnimationFrameAt:onTrack:
 * method. Normally, the application never needs to invoke this method.
 */
-(void) markAnimationDirty;


#pragma mark Establishing an animation frame

/**
 * Updates the location, quaternion and scale properties on the animation state wrapper associated
 * with the animation on the specified track, based on the animation frame located at the specified
 * time, which should be a value between zero and one, with zero indicating the first animation frame,
 * and one indicating the last animation frame. Only those transform properties for which there
 * is animation content will be changed.
 *
 * This method is usually invoked automatically from an active CC3Animate action during each update
 * cycle. Once all animation tracks have been updated accordingly, the node automatically blends
 * the weighted animation from each track to determine the corresponding values of the location,
 * quaternion and scale properties of this node.
 *
 * This implementation delegates to the CC3NodeAnimationState instance that is managing the animation
 * for the specified track, then passes this notification along to child nodes to align them with the
 * same animation time. Linear interpolation of the frame content may be performed, based on the
 * number of frames and the specified time.
 *
 * If disableAnimation or disableAllAnimation has been invoked on this node, it will be excluded
 * from animation, and this method will not have any affect on this node. However, this method will
 * be propagated to child nodes.
 *
 * This method is invoked automatically from an instance of CC3Animate that is animating
 * this node. Usually, the application never needs to invoke this method directly.
 */
-(void) establishAnimationFrameAt: (CCTime) t onTrack: (GLuint) trackID;


#pragma mark Developer support

/** Returns a description of the current animation state, including time and animated location, quaternion and scale. */
-(NSString*) describeCurrentAnimationState;

/** Returns a description of the state at each of frameCount animation frames over the entire animation. */
-(NSString*) describeAnimationStateForFrames: (GLuint) frameCount;

/**
 * Returns a description of the state at each of frameCount animation frames between the
 * specified start and end times, which should each be in the range between zero and one.
 */
-(NSString*) describeAnimationStateForFrames: (GLuint) frameCount fromTime: (CCTime) startTime toTime: (CCTime) endTime;


#pragma mark Deprecated functionality

/** @deprecated Instead of accessing this property, retrieve the appropriate animation using the
 * animation property or the getAnimationOnTrack: method, and access the frameCount property.
 */
@property(nonatomic, readonly) GLuint animationFrameCount DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced with establishAnimationFrameAt:onTrack:. */
-(void) establishAnimationFrameAt: (CCTime) t DEPRECATED_ATTRIBUTE;

@end
