/*
 * CC3Actions.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Node.h"
#import "CCActionEase.h"


/**
 * Constants for use as action tags to identify an action of a particular type on a node.
 *
 * Assigning a tag to an action allows one type of action on a node to be stopped, while allowing
 * other actions on that node to continue. For instance, a node might be both moving and fading
 * in concurrently. If the movement is altered by a user interaction, it might be desirable to
 * stop the movement action and replace it, without affecting the fade action. Using a tag to
 * identify the movement action allows it to be retrieved and stopped (via stopActionByTag:)
 * without affecting the fade action.
 *
 * You can use the CC3Node convenience method  to stop any existing action on a node with a
 * particular tag, assign the tag to the new action, and run that action instead.
 */
typedef enum {							// Don't start at zero to avoid possible confusion with defaults or other action tags
	kCC3ActionTagAnimation = 314,		/**< Use for animation that may combine move, rotate, and scale type actions. */
	kCC3ActionTagAnimationBlending,		/**< Use for changes to animation track blending. */
	kCC3ActionTagMove,					/**< Use for movement type actions. */
	kCC3ActionTagRotation,				/**< Use for rotation type actions. */
	kCC3ActionTagScale,					/**< Use for scaling type actions. */
	kCC3ActionTagFade,					/**< Use for fading type actions. */
	kCC3ActionTagTint,					/**< Use for general tinting type actions. */
	kCC3ActionTagTintAmbient,			/**< Use for tinting ambient color type actions. */
	kCC3ActionTagTintDiffuse,			/**< Use for tinting diffuse color type actions. */
	kCC3ActionTagTintSpecular,			/**< Use for tinting specular color type actions. */
	kCC3ActionTagTintEmission,			/**< Use for tinting emission color type actions. */
} CC3ActionTag;


#pragma mark -
#pragma mark CCAction

/** Extension category to support cocos3d. */
@interface CCAction (CC3)

/** The action target cast as a CC3Node. */
@property(nonatomic, readonly) CC3Node* targetCC3Node;

@end


#pragma mark -
#pragma mark CC3TransformVectorAction

/**
 * CC3TransformVectorAction is an abstract subclass of CCActionInterval that is the
 * parent of subclasses that transform a vector component of a target CC3Node (such
 * as the location, rotation, or scale) by some amount, or to some value over time.
 */
@interface CC3TransformVectorAction : CCActionInterval <NSCopying> {
	CC3Vector _startVector;
	CC3Vector _diffVector;
}

/**
 * Initializes this instance to transform the target property of the node
 * by the specified vector within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t differenceVector: (CC3Vector) aVector;

/**
 * Allocates and initializes an autoreleased instance to transform the target
 * property of the node by the specified vector within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t differenceVector: (CC3Vector) aVector;

@end


#pragma mark -
#pragma mark CC3TransformBy

/**
 * CC3TransformBy is an abstract subclass of CC3TransformVectorAction that is the
 * parent of subclasses that transform the location, rotation, or scale of a target
 * CC3Node by some amount in some way.
 */
@interface CC3TransformBy : CC3TransformVectorAction
@end


#pragma mark -
#pragma mark CC3MoveBy

/** CC3MoveBy is a CCActionInterval that moves a target CC3Node by a specific translation amount. */
@interface CC3MoveBy : CC3TransformBy

/**
 * Initializes this instance to move the target node
 * by the specified translation amount, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t moveBy: (CC3Vector) aTranslation;

/**
 * Allocates and initializes an autoreleased instance to move the target node
 * by the specified translation amount, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t moveBy: (CC3Vector) aTranslation;

@end


#pragma mark -
#pragma mark CC3RotateBy

/** CC3RotateBy is a CCActionInterval that rotates a target CC3Node by a specific rotation amount. */
@interface CC3RotateBy : CC3TransformBy

/**
 * Initializes this instance to rotate the target node
 * by the specified rotation amount, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t rotateBy: (CC3Vector) aRotation;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * by the specified rotation amount, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t rotateBy: (CC3Vector) aRotation;

@end


#pragma mark -
#pragma mark CC3ScaleBy

/** CC3ScaleBy is a CCActionInterval that scales a target CC3Node by a specific scale factor. */
@interface CC3ScaleBy : CC3TransformBy {
	CC3Vector _scaledDiffVector;
}

/**
 * Initializes this instance to scale the target node
 * by the specified scale factor, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t scaleBy: (CC3Vector) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the target node
 * by the specified scale factor, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t scaleBy: (CC3Vector) aScale;

/**
 * Initializes this instance to scale the target node uniformly in all dimensions 
 * by the specified scale factor, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t scaleUniformlyBy: (GLfloat) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the target node uniformly
 * in all dimensions by the specified scale factor, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t scaleUniformlyBy: (GLfloat) aScale;

@end


#pragma mark -
#pragma mark CC3RotateByAngle

/**
 * CC3RotateByAngle is a CCActionInterval that rotates a target CC3Node by a specific
 * amount, by repeatedly invoking the rotateByAngle:aroundAxis: method on the target
 * node as the action runs.
 */
@interface CC3RotateByAngle : CCActionInterval <NSCopying> {
	CC3Vector _rotationAxis;
	CC3Vector _activeRotationAxis;
	GLfloat _diffAngle;
	CCTime _prevTime;
}

/**
 * Initializes this instance to rotate the target node by the specified angle
 * around the existing rotationAxis of the node, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * by the specified angle around the existing rotationAxis of the node, within
 * the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle;

/**
 * Initializes this instance to rotate the target node by the specified angle
 * around the specified axis, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node by
 * the specified angle around the specified axis, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis;

@end


#pragma mark -
#pragma mark CC3TransformTo

/**
 * CC3TransformTo is an abstract subclass of CC3TransformVectorAction that is the
 * parent of subclasses that transform the location, rotation, or scale of a target
 * CC3Node to some end value in some way.
 */
@interface CC3TransformTo : CC3TransformVectorAction {
	CC3Vector _endVector;
}

/**
 * Initializes this instance to transform the target property of the node
 * to the specified vector, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t endVector: (CC3Vector) aVector;

/**
 * Allocates and initializes an autoreleased instance to transform the target
 * property of the node to the specified vector, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t endVector: (CC3Vector) aVector;

@end


#pragma mark -
#pragma mark CC3MoveTo

/** CC3MoveTo is a CCActionInterval that moves a target CC3Node to a specific location. */
@interface CC3MoveTo : CC3TransformTo

/**
 * Initializes this instance to move the target node
 * to the specified location, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t moveTo: (CC3Vector) aLocation;

/**
 * Allocates and initializes an autoreleased instance to move the target node
 * to the specified location, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t moveTo: (CC3Vector) aLocation;

@end


#pragma mark -
#pragma mark CC3RotateTo

/**
 * CC3RotateTo is a CCActionInterval that rotates a target CC3Node to a specific orientation.
 *
 * The rotational travel will be minimized, taking into consideration the cyclical nature
 * of rotation. For exmaple, a rotation from 10 degrees to 350 degrees in any axis should
 * travel -20 degrees, not the +340 degrees that would result from simple subtraction.
 */
@interface CC3RotateTo : CC3TransformTo

/**
 * Initializes this instance to move the target node
 * to the specified rotation, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t rotateTo: (CC3Vector) aRotation;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to the specified rotation, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t rotateTo: (CC3Vector) aRotation;

@end


#pragma mark -
#pragma mark CC3ScaleTo

/** CC3ScaleTo is a CCActionInterval that scales a target CC3Node to a specific scale. */
@interface CC3ScaleTo : CC3TransformTo

/**
 * Initializes this instance to scale the target node
 * to the specified scale, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t scaleTo: (CC3Vector) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the target node
 * to the specified scale, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t scaleTo: (CC3Vector) aScale;

/**
 * Initializes this instance to scale the target node uniformly in all
 * dimensions to the specified uniformScale, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t scaleUniformlyTo: (GLfloat) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the target node uniformly
 * in all dimensions to the specified uniformScale, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t scaleUniformlyTo: (GLfloat) aScale;

@end


#pragma mark -
#pragma mark CC3RotateToAngle

/**
 * CC3RotateToAngle is a CCActionInterval that rotates a target CC3Node to a specific
 * rotationAngle, by updating the rotationAngle propety.
 *
 * The rotationAngle property rotates the node around the axis set in the rotationAxis
 * property of the node. Make sure that you set the rotationAxis property on the node
 * appropriately prior to running this action.
 *
 * The rotational travel will be minimized, taking into consideration the cyclical nature
 * of rotation. For exmaple, a rotation from 10 degrees to 350 degrees in any axis should
 * travel -20 degrees, not the +340 degrees that would result from simple subtraction.
 */
@interface CC3RotateToAngle : CCActionInterval <NSCopying> {
	GLfloat _startAngle;
	GLfloat _endAngle;
	GLfloat _diffAngle;
}

/**
 * Initializes this instance to move the target node to the
 * specified rotation angle, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t rotateToAngle: (GLfloat) anAngle;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to the specified rotation angle, within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t rotateToAngle: (GLfloat) anAngle;

@end


#pragma mark -
#pragma mark CC3RotateToLookTowards

/**
 * CC3RotateToLookTowards is a CCActionInterval that rotates a target CC3Node
 * to look towards a specific direction.
 */
@interface CC3RotateToLookTowards : CC3TransformTo

/**
 * Initializes this instance to rotate the target node to look towards
 * the specified dirction. within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t forwardDirection: (CC3Vector) aDirection;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to look towards the specified dirction. within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t forwardDirection: (CC3Vector) aDirection;

@end


#pragma mark -
#pragma mark CC3RotateToLookAt

/**
 * CC3RotateToLookAt is a CCActionInterval that rotates a target CC3Node
 * to look at a specific location.
 */
@interface CC3RotateToLookAt : CC3RotateToLookTowards

/**
 * Initializes this instance to rotate the target node to look at
 * the specified location. within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t targetLocation: (CC3Vector) aLocation;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to look at the specified location. within the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t targetLocation: (CC3Vector) aLocation;

@end


#pragma mark -
#pragma mark CC3MoveDirectionallyBy

/**
 * CC3MoveDirectionallyBy is an abstract subclass of CCActionInterval that is
 * the parent of subclasses that move a target CC3Node by a specific translation
 * distance in a direction relative to the orientation of the node.
 *
 * The direction of movement is evaluated on each update frame. If the node
 * is also being rotated over time, this action will follow the change in
 * orientation of the node, and adjust the direction of movement.
 *
 * This is an abstract class. Subclasses define the actual direction of
 * movement by overriding the targetDirection property.
 */
@interface CC3MoveDirectionallyBy : CCActionInterval <NSCopying> {
	CCTime _prevTime;
	GLfloat	_distance;
}

/**
 * Initializes this instance to move the target node by the specified distance in
 * the direction, as indicated by the subclass, within the specified time duration.
 *
 * The specified distance may be positive or negative, indicating whether the
 * node should move forward or backward, relative to the direction of movement.
 *
 * The direction of movement is evaluated on each update frame. If the node
 * is also being rotated over time, this action will follow the change in
 * direction of movement of the node.
 */
-(id) initWithDuration: (CCTime) t moveBy: (GLfloat) aDistance;

/**
 * Allocates and initializes an autoreleased instance  to move the target node
 * by the specified distance in the direction, as indicated by the subclass,
 * within the specified time duration.
 *
 * The specified distance may be positive or negative, indicating whether the
 * node should move forward or backward, relative to the direction of movement.
 *
 * The direction of movement is evaluated on each update frame. If the node
 * is also being rotated over time, this action will follow the change in
 * direction of movement of the node.
 */
+(id) actionWithDuration: (CCTime) t moveBy: (GLfloat) aDistance;

/**
 * The direction of movement.
 *
 * This property is accessed on each update frame to determine the current
 * direction of movement. If the node is also being rotated while this
 * action is active, this direction will be different for each frame.
 *
 * The abstract implementation simply returns kCC3VectorZero. Subclasses
 * will override this property to return the current direction of movement.
 */
@property(nonatomic, readonly) CC3Vector targetDirection;

@end


#pragma mark -
#pragma mark CC3MoveForwardBy

/**
 * CC3MoveForwardBy moves a target CC3Node forward by a specific distance.
 *
 * The direction of movement is taken from the forwardDirection property 
 * of the node, and is evaluated on each update frame. If the node is being
 * separately rotated while this action is active, this action will follow
 * the changes to the forwardDirection property of the node, and the resulting
 * path of the node will be a curve instead of a staight line.
 *
 * The specified distance may be negative, indicating the node should move
 * backward, relative to the direction indicated by the forwardDirection property.
 */
@interface CC3MoveForwardBy : CC3MoveDirectionallyBy
@end


#pragma mark -
#pragma mark CC3MoveRightBy

/**
 * CC3MoveRightBy moves a target CC3Node to the right by a specific distance.
 *
 * The direction of movement is taken from the rightDirection property of the
 * node, and is evaluated on each update frame. If the node is being separately
 * rotated while this action is active, this action will follow the changes to
 * the rightDirection property of the node, and the resulting path of the node
 * will be a curve instead of a staight line.
 *
 * The specified distance may be negative, indicating the node should move
 * backward, relative to the direction indicated by the rightDirection property.
 */
@interface CC3MoveRightBy : CC3MoveDirectionallyBy
@end


#pragma mark -
#pragma mark CC3MoveUpBy

/**
 * CC3MoveUpBy moves a target CC3Node up by a specific distance.
 *
 * The direction of movement is taken from the upDirection property of the node,
 * and is evaluated on each update frame. If the node is being separately rotated
 * while this action is active, this action will follow the changes to the
 * upDirection property of the node, and the resulting path of the node will be
 * a curve instead of a staight line.
 *
 * The specified distance may be negative, indicating the node should move
 * backward, relative to the direction indicated by the upDirection property.
 */
@interface CC3MoveUpBy : CC3MoveDirectionallyBy
@end


#pragma mark -
#pragma mark CC3TintTo

/**
 * CC3TintTo is an abstract CCActionInterval whose subclasses changes one
 * of the color properties of a target CC3Node to a particular color.
 * Each subclass is dedicated to changing one particular color property.
 *
 * This class is abstract and should not be instantiated directly.
 * Instead, use one of the concrete subclasses.
 */
@interface CC3TintTo : CCActionInterval <NSCopying> {
	ccColor4F _startColor;
	ccColor4F _endColor;
}

/**
 * Initializes this instance to change a color property of the target
 * node to the specified color, within the specified time duration.
 */
-(id) initWithDuration: (CCTime) t colorTo: (ccColor4F) aColor;

/**
 * Allocates and initializes an autoreleased instance to change a color property
 * of the target node to the specified color, within the specified time duration.
 */
+(id) actionWithDuration:(CCTime) t colorTo: (ccColor4F) aColor;

@end


#pragma mark -
#pragma mark CC3TintAmbientTo

/** A concrete subclass of CC3TintTo that changes the ambient color of the target CC3Node. */
@interface CC3TintAmbientTo : CC3TintTo
@end


#pragma mark -
#pragma mark CC3TintDiffuseTo

/** A concrete subclass of CC3TintTo that changes the diffuse color of the target CC3Node. */
@interface CC3TintDiffuseTo : CC3TintTo
@end


#pragma mark -
#pragma mark CC3TintSpecularTo

/** A concrete subclass of CC3TintTo that changes the specular color of the target CC3Node. */
@interface CC3TintSpecularTo : CC3TintTo
@end


#pragma mark -
#pragma mark CC3TintEmissionTo

/** A concrete subclass of CC3TintTo that changes the emission color of the target CC3Node. */
@interface CC3TintEmissionTo : CC3TintTo
@end


#pragma mark -
#pragma mark CC3Animate

/**
 * A CCActionInterval that animates a single track of animation on a CC3Node and its descendants.
 *
 * To animate a node, CC3Animate invokes the establishAnimationFrameAt:onTrack: method of the
 * target CC3Node. The heavy lifting is performed by the CC3NodeAnimation instance held in the
 * animation property of the node.
 *
 * The establishAnimationFrameAt:onTrack: method of the CC3Node also takes care of propagating
 * the animation to its descendant nodes. A complete assembly of nodes can therefore be animated
 * in concert for one track of information using a single CC3Animate instance.
 *
 * It is possible to animate only a fraction of the full animation. This can be done using
 * either the actionWithDuration:onTrack:limitFrom:to: or asActionLimitedFrom:to: methods.
 *
 * Doing so will result is an animation action that will perform only part of the animation.
 * This is very useful for an node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without having
 * to run the full animation. To do this, set the startOfRange and endOfRange values to the
 * fractional positions (between zero and one) of the start and end frames of the sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */
@interface CC3Animate : CCActionInterval <NSCopying> {
	GLuint _trackID;
	BOOL _isReversed : 1;
}

/** The animation track on which the animation runs. */
@property (nonatomic, assign, readonly) GLuint trackID;

/**
 * Indicates whether this action is running in reverse. Setting this to YES
 * will cause the animation to run in reverse.
 * 
 * Generally, this is set when creating a reverse action using the reverse
 * method of a normal CCActionInterval instance to create its compliment.
 * The application will generally not set this property directly.
 */
@property(nonatomic, assign) BOOL isReversed;

/**
 * Initializes this instance to animate animation track zero on the target node,
 * over the specified time duration.
 */
-(id) initWithDuration: (CCTime) t;

/**
 * Allocates and initializes an autoreleased instance to animate animation track zero
 * on the target node, over the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t;

/**
 * Initializes this instance to animate the specified animation track on the target node,
 * over the specified time duration.
 */
-(id) initWithDuration: (CCTime) t onTrack: (GLuint) trackID;

/**
 * Allocates and initializes an autoreleased instance to animate the specified animation
 * track on the target node, over the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t onTrack: (GLuint) trackID;

/**
 * Allocates and initializes an autoreleased instance to animate animation track zero on the
 * target node, over the specified time duration, then wraps that instance in an autoreleased
 * CC3ActionRangeLimit instance that maps the normal zero-to-one update range to the specified
 * range, and returns the CC3ActionRangeLimit instance.
 *
 * The effective result is an animation action that will perform only part of the animation.
 * This is very useful for a node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without having
 * to run the full animation. To do this, set the startOfRange and endOfRange values
 * to the fractional positions (between zero and one) of the start and end frames of the sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */
+(id) actionWithDuration: (CCTime) t limitFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange;

/**
 * Allocates and initializes an autoreleased instance to animate the specified animation track on
 * the target node, over the specified time duration, then wraps that instance in an autoreleased
 * CC3ActionRangeLimit instance that maps the normal zero-to-one update range to the specified
 * range, and returns the CC3ActionRangeLimit instance.
 *
 * The effective result is an animation action that will perform only part of the animation.
 * This is very useful for a node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without having
 * to run the full animation. To do this, set the startOfRange and endOfRange values
 * to the fractional positions (between zero and one) of the start and end frames of the sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */
+(id) actionWithDuration: (CCTime) t onTrack: (GLuint) trackID limitFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange;

/**
 * Wraps this instance in an autoreleased CC3ActionRangeLimit instance that maps the normal
 * zero-to-one update range to the specified range, and returns the CC3ActionRangeLimit instance
 *
 * The effective result is an animation action that will perform only part of the animation.
 * This is very useful for an node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without having
 * to run the full animation. To do this, set the startOfRange and endOfRange values of the
 * fractional positions (between zero and one) of the start and end frames of the sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */
-(CCActionInterval*) asActionLimitedFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange;

@end


#pragma mark -
#pragma mark CC3AnimationBlendingFadeTrackTo

/**
 * CC3AnimationBlendingFadeTrackTo fades the animation blending weight of an animation track in the
 * target CC3Node from its current value to an end value. This allows the animation track to
 * be faded in or out smoothly.
 */
@interface CC3AnimationBlendingFadeTrackTo : CCActionInterval <NSCopying> {
	GLfloat _startWeight;
	GLfloat _endWeight;
	GLuint _trackID;
}

/** The animation track on which the animation runs. */
@property (nonatomic, assign, readonly) GLuint trackID;

/**
 * Initializes this instance to fade the animation blending weight of the specified animation
 * track on the target node to the specified value, over the specified time duration.
 */
-(id) initWithDuration: (CCTime) t onTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight;

/**
 * Allocates and initializes an autoreleased instance to fade the animation blending weight of the
 * specified animation track on the target node to the specified value, over the specified time duration.
 */
+(id) actionWithDuration: (CCTime) t onTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight;

@end


#pragma mark -
#pragma mark CC3AnimationCrossFade

/** CC3AnimationCrossFade fades smoothly from one animation track to another. */
@interface CC3AnimationCrossFade : CCActionInterval <NSCopying> {
	GLuint _fromTrackID;
	GLuint _toTrackID;
	GLfloat _startWeight;
	GLfloat _endWeight;
}

/** The animation track to fade from. */
@property (nonatomic, assign, readonly) GLuint fromTrackID;

/** The animation track to fade to. */
@property (nonatomic, assign, readonly) GLuint toTrackID;

/**
 * Initializes this instance to fade from the specified track to the specified track, over
 * the specified time duration, and leaving the final track with a blending weight of one.
 */
-(id) initWithDuration: (CCTime) t
			 fromTrack: (GLuint) fromTrackID
			   toTrack: (GLuint) toTrackID;

/**
 * Initializes this instance to fade from the specified track to the specified track, over the
 * specified time duration, and leaving the final track with the specified blending weight.
 */
-(id) initWithDuration: (CCTime) t
			 fromTrack: (GLuint) fromTrackID
			   toTrack: (GLuint) toTrackID
	withBlendingWeight: (GLfloat) toBlendingWeight;

/**
 * Allocates and initializes an autoreleased instance to fade from the specified track to
 * the specified track, over the specified time duration, and leaving the final track with
 *  a blending weight of one.
 */
+(id) actionWithDuration: (CCTime) t
			   fromTrack: (GLuint) fromTrackID
				 toTrack: (GLuint) toTrackID;

/**
 * Allocates and initializes an autoreleased instance to fade from the specified track to
 * the specified track, over the specified time duration, and leaving the final track with
 * the specified blending weight.
 */
+(id) actionWithDuration: (CCTime) t
			   fromTrack: (GLuint) fromTrackID
				 toTrack: (GLuint) toTrackID
	  withBlendingWeight: (GLfloat) toBlendingWeight;

@end


#pragma mark -
#pragma mark CC3AnimationBlendingSetTrackTo

/**
 * CC3AnimationBlendingSetTrackTo immediately sets the animation blending weight of an animation
 * track in the target CC3Node to a specified value.
 *
 * By setting the blending weight to zero, the animation track can be effectively turned off.
 */
@interface CC3AnimationBlendingSetTrackTo : CCActionInstant {
	GLfloat _endWeight;
	GLuint _trackID;
}

/** The animation track on which the animation runs. */
@property (nonatomic, assign, readonly) GLuint trackID;

/**
 * Initializes this instance to set the animation blending weight of the specified animation
 * track on the target node to the specified value.
 *
 * By setting the blending weight to zero, the animation track can be effectively turned off.
 */
-(id) initOnTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight;

/**
 * Allocates and initializes an autoreleased instance to set the animation blending weight of the
 * specified animation track on the target node to the specified value.
 *
 * By setting the blending weight to zero, the animation track can be effectively turned off.
 */
+(id) actionOnTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight;

@end


#pragma mark -
#pragma mark CC3EnableAnimationTrack

/**
 * CC3EnableAnimation immediately enables a specified animation track on the target node
 * and all of its descendants.
 */
@interface CC3EnableAnimationTrack : CCActionInstant {
	GLuint _trackID;
}

/** The animation track to be enabled. */
@property (nonatomic, assign, readonly) GLuint trackID;

/**
 * Initializes this instance to enable the specified animation track on the target node
 * and all of its descendants.
 */
-(id) initOnTrack: (GLuint) trackID;

/** 
 * Allocates and initializes an autoreleased instance to enable the specified animation
 * track on the target node and all of its descendants.
 */
+(id) actionOnTrack: (GLuint) trackID;

@end


#pragma mark -
#pragma mark CC3DisableAnimationTrack

/**
 * CC3DisableAnimation immediately disables a specified animation track on the target node
 * and all of its descendants.
 */
@interface CC3DisableAnimationTrack : CCActionInstant {
	GLuint _trackID;
}

/** The animation track to be enabled. */
@property (nonatomic, assign, readonly) GLuint trackID;

/**
 * Initializes this instance to disable the specified animation track on the target node
 * and all of its descendants.
 */
-(id) initOnTrack: (GLuint) trackID;

/**
 * Allocates and initializes an autoreleased instance to disable the specified animation
 * track on the target node and all of its descendants.
 */
+(id) actionOnTrack: (GLuint) trackID;

@end


#pragma mark -
#pragma mark CC3ActionRangeLimit

/**
 * A CC3ActionRangeLimit holds another action, and serves to modify the normal zero-to-one
 * range of update values to a smaller range that is presented to the contained action.
 *
 * For example, for an instance that is limited to a range of 0.5 to 0.75, as the 
 * input update value changes from zero to one, the value that is forwarded to the
 * contained action will change from 0.5 to 0.75.
 */
@interface CC3ActionRangeLimit : CCActionEase {
	GLfloat _rangeStart;
	GLfloat _rangeSpan;
}

/**
 * Initializes this instance to modify the update values that are forwarded to the
 * specified action so that they remain within the specified range.
 */
-(id) initWithAction: (CCActionInterval*) action
		   limitFrom: (GLfloat) startOfRange
				  to: (GLfloat) endOfRange;

/**
 * Allocates and initializes an autoreleased instance that modify the update values that are
 * forwarded to the specified action so that they remain within the specified range.
 */
+(id) actionWithAction: (CCActionInterval*) action
			 limitFrom: (GLfloat) startOfRange
					to: (GLfloat) endOfRange;

@end


#pragma mark -
#pragma mark CC3Remove

/**
 * CC3Remove removes a CC3Node from the scene, by invoking the remove method on the CC3Node.
 *
 * This action can be used as part of a CCSequence to remove a node after some other kind
 * of action has completed. For example, you might create a CCSequence containing a CCFadeOut
 * and a CC3Remove, to fade a node away and then remove it from the scene.
 */
@interface CC3Remove : CCActionInstant
	
@end


