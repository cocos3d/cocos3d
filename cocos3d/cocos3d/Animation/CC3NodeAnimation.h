/*
 * CC3NodeAnimation.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Node.h"


#pragma mark -
#pragma mark CC3NodeAnimation

/** 
 * An instance of a subclass of CC3NodeAnimation manages the animation of nodes.
 * It is held in the animation property of the node itself, and is activated
 * when the establishAnimationFrameAt: method is invoked on the node.
 *
 * A single CC3NodeAnimation instance can be shared by multiple nodes.
 * This is a typical situation when creating many copies of a node that is animated.
 *
 * CC3NodeAnimation is an abstract class. Subclasses define concrete animation data storage.
 */
@interface CC3NodeAnimation : NSObject {
	GLuint frameCount;
	ccTime currentFrame;
	BOOL shouldInterpolate : 1;
}

/** The number of frames of animation. */
@property(nonatomic, readonly) GLuint frameCount;

/**
 * Indicates whether this animation should interpolate between frames, for accuracy.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldInterpolate;

/**
 * Indicates whether location data is available for animation.
 * Default returns NO. Subclasses with data should override appropriately.
 */
@property(nonatomic, readonly) BOOL isAnimatingLocation;

/**
 * Indicates whether rotation data is available for animation.
 * Default returns NO. Subclasses with data should override appropriately.
 */
@property(nonatomic, readonly) BOOL isAnimatingRotation;

/**
 * Indicates whether rotation quaternion data is available for animation.
 * Default returns NO. Subclasses with data should override appropriately.
 */
@property(nonatomic, readonly) BOOL isAnimatingQuaternion;

/**
 * Indicates whether scale data is available for animation.
 * Default returns NO. Subclasses with data should override appropriately.
 */
@property(nonatomic, readonly) BOOL isAnimatingScale;

/**
 * Returns the current frame. This is the value submitted to the most recent invocation of
 * the establishFrameAt:forNode: method, or zero if that method has not yet been invoked.
 */
@property (assign,readonly) ccTime currentFrame;

/** Initializes this instance to animate with the specified number of animation frames. */
-(id) initWithFrameCount: (GLuint) numFrames;

/**
 * Allocates and initializes an autoreleased instance to animate
 * with the specified number of animation frames.
 */
+(id) animationWithFrameCount: (GLuint) numFrames;

/** 
 * Updates the location, rotation, quaternion, and scale of the specified node based
 * on the animation frame located at the specified time, which should be a value between
 * zero and one, with zero indicating the first animation frame, and one indicating the
 * last animation frame.
 *
 * Only those properties of the node for which there is animation data will be changed.
 * If the shouldInterpolate property is set to YES, linear interpolation of the frame
 * data is performed, based on the frameCount and the specified time.
 */
-(void) establishFrameAt: (ccTime) t forNode: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3ArrayNodeAnimation

/** 
 * A concrete CC3NodeAnimation that holds animation data in simple arrays.
 * The arrays can be allocated and managed either by the instance, or externally.
 *
 * There are four properties that hold the animated data:
 *   - animatedLocations - location animation data
 *   - animatedRotations - rotation animation data
 *   - animatedQuaternions - rotation quaternion animation data
 *   - animatedScales - scale animation data
 *
 * You do not need to use all of these properties. You can choose to animate any
 * subset of these animation data properties, and leave the remaining animation data
 * properties set to NULL (the default). If you do not set an animation data property,
 * the corresponding property on the node will not be animated, and will retain its
 * originally set value.
 *
 * For instance, if you set only the animatedLocations property, and run a CC3Animate
 * on the node, only the location of the node will move around during the animation.
 * The remaining node properties (rotation, quaternion, scale) will remain unchanged
 * by the animation. The effect will be that the node moves around, but remains at
 * a fixed size, and oriented in a fixed rotation.
 
 * You can work with these animation data properties in one of two ways:
 *   - Allocate the arrays outside this class and simply assign them to this instance
 *     using the property accessors. In this case, it is up to you to allocate and
 *     deallocate the memory used by the arrays.
 *   - Invoke one or more of the methods allocateLocations, allocateRotations,
 *     allocateQuaternions, and allocateScales to instruct this instance to allocate
 *     and manage the memory for the data array. You can then access the associated
 *     array via the animatedLocations, animatedRotations, animatedQuaternions, and
 *     animatedScales properties respectively. This instance will take care of
 *     releasing the arrays when appropriate. 
 */
@interface CC3ArrayNodeAnimation : CC3NodeAnimation {
	CC3Vector* animatedLocations;
	CC3Vector* animatedRotations;
	CC3Vector4* animatedQuaternions;
	CC3Vector* animatedScales;
	BOOL locationsAreRetained;
	BOOL rotationsAreRetained;
	BOOL quaternionsAreRetained;
	BOOL scalesAreRetained;
}

/**
 * An array of location data. Each CC3Vector in the array holds the location datum
 * for one frame of animation. The array must have at least frameCount elements.
 * The property can be set to NULL to indicate that location is not animated.
 *
 * Setting this property will safely free any memory allocated by the
 * allocateLocations method.
 */
@property(nonatomic, assign) CC3Vector* animatedLocations;

/**
 * An array of rotation data. Each CC3Vector in the array holds the rotation datum
 * for one frame of animation. The array must have at least frameCount elements.
 * The property can be set to NULL to indicate that rotation is not animated.
 *
 * Setting this property will safely free any memory allocated by the
 * allocateRotations method.
 */
@property(nonatomic, assign) CC3Vector* animatedRotations;

/**
 * An array of rotation quaternion data. Each CC3Vector4 in the array holds the
 * location datum for one frame of animation. The array must have at least frameCount
 * elements. The property can be set to NULL to indicate that quaternion rotation
 * is not animated.
 *
 * Setting this property will safely free any memory allocated by the
 * allocateQuaternions method.
 */
@property(nonatomic, assign) CC3Vector4* animatedQuaternions;

/**
 * An array of scale data. Each CC3Vector in the array holds the scale datum
 * for one frame of animation. The array must have at least frameCount elements.
 * The property can be set to NULL to indicate that scale is not animated.
 *
 * Setting this property will safely free any memory allocated by the
 * allocateScales method.
 */
@property(nonatomic, assign) CC3Vector* animatedScales;

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
 * Allocates underlying memory for an array of rotation vectors.
 * All elements of the array are initialized to zero rotation.
 * The amount of memory allocated will be (frameCount * sizeof(CC3Vector)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(CC3Vector*) allocateRotations;

/**
 * Allocates underlying memory for an array of quaternions vectors.
 * All elements of the array are initialized to the identity quaternion.
 * The amount of memory allocated will be (frameCount * sizeof(CC3Vector4)) bytes.
 *
 * It is safe to invoke this method more than once, but understand that any previously
 * allocated memory will be safely freed prior to the allocation of the new memory.
 * The memory allocated earlier will therefore be lost and should not be referenced.
 */
-(CC3Vector4*) allocateQuaternions;

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
 * Deallocates the underlying location array allocated with the allocateLocations.
 * It is safe to invoke this method more than once, or even if allocateLocations
 * was not previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateLocations;

/**
 * Deallocates the underlying rotation array allocated with the allocateRotations.
 * It is safe to invoke this method more than once, or even if allocateRotations
 * was not previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateRotations;

/**
 * Deallocates the underlying quaternion array allocated with the allocateQuaternions.
 * It is safe to invoke this method more than once, or even if allocateQuaternions
 * was not previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateQuaternions;

/**
 * Deallocates the underlying scale array allocated with the allocateScales.
 * It is safe to invoke this method more than once, or even if allocateScales
 * was not previously invoked.
 *
 * This method is invoked automatically when this instance is deallocated.
 */
-(void) deallocateScales;

@end

