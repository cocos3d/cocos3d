/*
 * CC3ActionInterval.h
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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


#pragma mark CC3TransformTo

/**
 * CC3TransformTo is an abstract subclass of CCActionInterval that is the parent
 * of subclasses that transform the location, rotation, or scale of a target
 * CC3Node to some end value in some way.
 */
@interface CC3TransformTo : CCActionInterval {
	CC3Vector startVector;
	CC3Vector endVector;
	CC3Vector differenceVector;
}

/**
 * The property within the target node that is being transformed.
 * Subclasses will map this property to the appropriate property within the target.
 */
@property(nonatomic, assign) CC3Vector targetVector;

/**
 * Initializes this instance to transform the target property of the node
 * to the specified vector, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t endVector: (CC3Vector) aVector;

/**
 * Allocates and initializes an autoreleased instance to transform the target
 * property of the node to the specified vector, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t endVector: (CC3Vector) aVector;

@end


#pragma mark -
#pragma mark CC3MoveTo

/** CC3MoveTo is a CCActionInterval that moves a target CC3Node to a specific location. */
@interface CC3MoveTo : CC3TransformTo {}

/**
 * Initializes this instance to move the target node
 * to the specified location, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t moveTo: (CC3Vector) aLocation;

/**
 * Allocates and initializes an autoreleased instance to move the target node
 * to the specified location, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t moveTo: (CC3Vector) aLocation;

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
@interface CC3RotateTo : CC3TransformTo {}

/**
 * Initializes this instance to move the target node
 * to the specified rotation, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t rotateTo: (CC3Vector) aRotation;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to the specified rotation, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t rotateTo: (CC3Vector) aRotation;

@end


#pragma mark -
#pragma mark CC3RotateToLookTowards

/**
 * CC3RotateToLookTowards is a CCActionInterval that rotates a target CC3Node
 * to look towards a specific direction.
 */
@interface CC3RotateToLookTowards : CC3TransformTo {}

/**
 * Initializes this instance to rotate the target node to look towards
 * the specified dirction. within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t forwardDirection: (CC3Vector) aDirection;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to look towards the specified dirction. within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t forwardDirection: (CC3Vector) aDirection;

@end


#pragma mark -
#pragma mark CC3RotateToLookAt

/**
 * CC3RotateToLookAt is a CCActionInterval that rotates a target CC3Node
 * to look at a specific location.
 */
@interface CC3RotateToLookAt : CC3RotateToLookTowards {}

/**
 * Initializes this instance to rotate the target node to look at
 * the specified location. within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t targetLocation: (CC3Vector) aLocation;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * to look at the specified location. within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t targetLocation: (CC3Vector) aLocation;

@end


#pragma mark -
#pragma mark CC3ScaleTo

/** CC3ScaleTo is a CCActionInterval that scales a target CC3Node to a specific scale. */
@interface CC3ScaleTo : CC3TransformTo {}

/**
 * Initializes this instance to scale the target node
 * to the specified scale, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t scaleTo: (CC3Vector) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the target node
 * to the specified scale, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t scaleTo: (CC3Vector) aScale;

@end


#pragma mark -
#pragma mark CC3TransformBy

/**
 * CC3TransformBy is an abstract subclass of CCActionInterval that is the parent
 * of subclasses that transform the location, rotation, or scale of a target
 * CC3Node by some amount in some way.
 */
@interface CC3TransformBy : CC3TransformTo {}

/**
 * Initializes this instance to transform the target property of the node
 * by the specified vector within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t differenceVector: (CC3Vector) aVector;

/**
 * Allocates and initializes an autoreleased instance to transform the target
 * property of the node by the specified vector within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t differenceVector: (CC3Vector) aVector;

@end


#pragma mark -
#pragma mark CC3MoveBy

/** CC3MoveBy is a CCActionInterval that moves a target CC3Node by a specific translation amount. */
@interface CC3MoveBy : CC3TransformBy {}

/**
 * Initializes this instance to move the target node
 * by the specified translation amount, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t moveBy: (CC3Vector) aTranslation;

/**
 * Allocates and initializes an autoreleased instance to move the target node
 * by the specified translation amount, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t moveBy: (CC3Vector) aTranslation;

@end


#pragma mark -
#pragma mark CC3RotateBy

/** CC3RotateBy is a CCActionInterval that rotates a target CC3Node by a specific rotation amount. */
@interface CC3RotateBy : CC3TransformBy {}

/**
 * Initializes this instance to rotate the target node
 * by the specified rotation amount, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t rotateBy: (CC3Vector) aRotation;

/**
 * Allocates and initializes an autoreleased instance to rotate the target node
 * by the specified rotation amount, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t rotateBy: (CC3Vector) aRotation;

@end


#pragma mark -
#pragma mark CC3ScaleBy

/** CC3ScaleBy is a CCActionInterval that scales a target CC3Node by a specific scale factor. */
@interface CC3ScaleBy : CC3TransformBy {}

/**
 * Initializes this instance to scale the target node
 * by the specified scale factor, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t scaleBy: (CC3Vector) aScale;

/**
 * Allocates and initializes an autoreleased instance to scale the target node
 * by the specified scale factor, within the specified time duration.
 */
+(id) actionWithDuration: (ccTime) t scaleBy: (CC3Vector) aScale;

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
	ccColor4F startColor;
	ccColor4F endColor;
}

/**
 * Initializes this instance to change a color property of the target
 * node to the specified color, within the specified time duration.
 */
-(id) initWithDuration: (ccTime) t colorTo: (ccColor4F) aColor;

/**
 * Allocates and initializes an autoreleased instance to change a color property
 * of the target node to the specified color, within the specified time duration.
 */
+(id) actionWithDuration:(ccTime) t colorTo: (ccColor4F) aColor;

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
 * A CCActionInterval that animates a CC3Node.
 *
 * To animate a node, CC3Animate invokes the establishAnimationFrameAt: method
 * of the CC3Node it is animating. The heavy lifting is performed by the
 * CC3NodeAnimation instance held in the animation property of the node.
 *
 * The establishAnimationFrameAt: method of the CC3Node also takes care of
 * propagating the animation to its child nodes. A complete assembly of nodes
 * can therefore be animated in concert using a single CC3Animate instance.
 *
 * It is possible to animate only a fraction of the full animation. This can be done
 * using either the actionWithDuration:limitFrom:to: or asActionLimitedFrom:to:
 * methods.
 *
 * Doing so will result is an animation action that will perform only part of the animation.
 * This is very useful for an node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without
 * having to run the full animation. To do this, set the startOfRange and endOfRange values
 * to the fractional positions (between zero and one) of the start and end frames of the
 * sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */
@interface CC3Animate : CCActionInterval <NSCopying> {
	BOOL isReversed;
}

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
 * Wraps this instance in an autoreleased CC3ActionRangeLimit instance that maps
 * the normal zero-to-one update range to the specified range, and returns the
 * CC3ActionRangeLimit instance
 *
 * The effective result is an animation action that will perform only part of the animation.
 * This is very useful for an node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without
 * having to run the full animation. To do this, set the startOfRange and endOfRange values
 * to the fractional positions (between zero and one) of the start and end frames of the
 * sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */
-(CCActionInterval*) asActionLimitedFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange;

/**
 * Allocates and initializes an autoreleased instance with the specified duration,
 * then wraps that instance in an autoreleased CC3ActionRangeLimit instance that maps
 * the normal zero-to-one update range to the specified range, and returns the
 * CC3ActionRangeLimit instance.
 *
 * The effective result is an animation action that will perform only part of the animation.
 * This is very useful for an node that contains several different motions in one animation.
 * Using a range-limited CC3Animate, you can animate one of those distinct motions without
 * having to run the full animation. To do this, set the startOfRange and endOfRange values
 * to the fractional positions (between zero and one) of the start and end frames of the
 * sub-animation.
 *
 * For example, if a character animation contains a punch animation that starts and stops
 * at relative positions 0.67 and 0.78 respectively within the full animation, setting
 * those two values here will result in an animation containing only the punch.
 */

+(id) actionWithDuration: (ccTime) d limitFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange;

@end


#pragma mark -
#pragma mark CC3ActionRangeLimit

/**
 * A CC3ActionRangeLimit holds another action, and serves to modify the normal
 * zero-to-one range of update values to a smaller range that is presented to the
 * contained action.
 *
 * For example, for an instance that is limited to a range of 0.5 to 0.75, as the 
 * input update value changes from zero to one, the value that is forwarded to the
 * contained action will change from 0.5 to 0.75.
 */
@interface CC3ActionRangeLimit : CCActionEase {
	GLfloat rangeStart;
	GLfloat rangeSpan;
}

/**
 * Initializes this instance to modify the update values that are forwarded to the
 * specified action so that they remain within the specified range.
 */
-(id) initWithAction: (CCActionInterval*) action
		   limitFrom: (GLfloat) startOfRange
				  to: (GLfloat) endOfRange;

/**
 * Allocates and initializes an autoreleased instance that modify the update
 * values that are forwarded to the specified action so that they remain
 * within the specified range.
 */
+(id) actionWithAction: (CCActionInterval*) action
			 limitFrom: (GLfloat) startOfRange
					to: (GLfloat) endOfRange;

@end


