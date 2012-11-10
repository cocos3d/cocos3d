/*
 * CC3CC2Extensions.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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


/* Base library of extensions to cocos2d to support cocos3d. */

#import "CCArray.h"
#import "CCNode.h"
#import "CCLayer.h"
#import "CCMenu.h"
#import "CCDirector.h"
#import "CCActionInterval.h"
#import "CCLabelBMFont.h"


#pragma mark -
#pragma mark CC3CCSizeTo action

/** Animates a change to the contentSize of a CCNode. */
@interface CC3CCSizeTo : CCActionInterval {
	CGSize startSize_;
	CGSize endSize_;
	CGSize sizeChange_;
}

/**
 * Initializes this instance to change the contentSize property of the target to the specified
 * size, within the specified elapsed duration.
 */
-(id) initWithDuration: (ccTime) dur sizeTo: (CGSize) endSize;

/**
 * Allocates and initializes an autoreleased instance to change the contentSize property of
 * the target to the specified size, within the specified elapsed duration.
 */
+(id) actionWithDuration: (ccTime) dur sizeTo: (CGSize) endSize;

@end



#pragma mark -
#pragma mark CCNode extension

/** Extension category to support cocos3d functionality. */
@interface CCNode (CC3)

/** Returns the bounding box of this CCNode, measured in pixels, in the global coordinate system. */
- (CGRect) globalBoundingBoxInPixels;

/**
 * Updates the viewport of any contained CC3Scene instances with the dimensions
 * of its CC3Layer and the device orientation.
 *
 * This CCNode implementation simply passes the notification along to its children.
 * Descendants that are CC3Layers will update their CC3Scene instances.
 */
-(void) updateViewport;

/**
 * Returns a point in the coordinate space of this node that corresponds to the specified point
 * in the coordinate space of the UIView, taking into consideration the orientation of the device.
 *
 * You can use this method to convert locations in a UIView, including those returned by touch
 * events and gestures, such as the locationInView: method on tap and long-press gestures, to
 * a location in this layer.
 */
-(CGPoint) cc3ConvertUIPointToNodeSpace: (CGPoint) viewPoint;

/**
 * Returns a point in the coordinate space of the UIView that corresponds to the specified point
 * in the coordinate space of this node, taking into consideration the orientation of the device.
 *
 * This method performs the inverse of the operation provided by the cc3ConvertUIPointToNodeSpace: method.
 */
-(CGPoint) cc3ConvertNodePointToUISpace: (CGPoint) glPoint;

/**
 * Returns a movement in the coordinate space of this layer that corresponds
 * to the specified movement in the coordinate space of the UIView, taking into
 * consideration the orientation of the device.
 *
 * You can use this method to convert movements in a UIView, including those
 * returned by touch events and gestures, such as the translationInView: and
 * velocityInView: methods of UIPanGestureRecognizer, to movement in this layer.
 */
-(CGPoint) cc3ConvertUIMovementToNodeSpace: (CGPoint) uiMovement;

/**
 * Normalizes the specified movement, which is in the coordinate space of the
 * UIView, so that the movement is made relative to the size of this node.
 *
 * The returned value is a fraction proportional to the size of this node.
 * A drag movement from one side of the node all the way to the other side would
 * return positive or negative one in the X or Y component of the returned point.
 * Similarly, a drag movement from the center to one side would return 0.5 in
 * the X or Y component of the returned point.
 *
 * This method allows you to convert drag movements to a measurement that is
 * independent of the absolute size of the node, and is of a scale useful for
 * processing as input that is not used as a direct positioning value.
 *
 * You can use this method to normalize movements in a UIView, including those
 * returned by touch events and gestures, such as the translationInView: and
 * velocityInView: methods of UIPanGestureRecognizer, so that they are proportional,
 * and independent of, the size of this node.
 *
 * This method takes into consideration the orientation of the device.
 */
-(CGPoint) cc3NormalizeUIMovement: (CGPoint) uiMovement;

/**
 * Returns whether this node will receive touch events.
 *
 * This implementation returns NO.
 */
-(BOOL) cc3IsTouchEnabled;

/** Returns whether this node contains the specified UI touch location. */
-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint;

/**
 * Returns whether this node, or any of its descendants will consume a touch
 * event at the specified UIView location when presented with the event.
 *
 * This method is useful for testing whether a touch event should be handled
 * by a descendant node instead of a gesture recognizer. The result of this
 * method can be used to cancel the gesture recognizer.
 *
 * Based on cocos2d Gesture Recognizer ideas by Krzysztof Zabłocki at:
 * http://www.merowing.info/2012/03/using-gesturerecognizers-in-cocos2d/
 */
-(BOOL) cc3WillConsumeTouchEventAt: (CGPoint) viewPoint;

/**
 * Validates that the specified gesture is okay to proceed, and cancels the gesture
 * if not. Returns YES if the gesture is valid and okay to proceed. Returns NO if
 * the gesture was cancelled.
 *
 * Your gesture handling callback methods should use this method before processing
 * the gesture to ensure that there are no conflicts between the touch events of
 * the gesture and the touch events handled by this node or any of its descendants.
 *
 * For discrete gestures, such as tap gestures, you should use this method each
 * time the callback is invoked. For many discrete gestures, the callback is only
 * invoked when the gesture is in state UIGestureRecognizerStateEnded.
 *
 * For continuous gestures, such as pan or pinch gestures, you should use this method
 * when the callback is invoked and the gesture is in state UIGestureRecognizerStateBegan.
 * You do not need to revalidate the continuous gesture on each subsequent callback, when
 * the state of the gesture is UIGestureRecognizerStateChanged. Doing so is unnecessary.
 *
 * This implementation extracts the location of the touch point from the gesture and
 * uses the cc3WillConsumeTouchEventAt: method of this node to test if this node or
 * any of its descendants are interested in the touch event that triggerd the gesture.
 *
 * If neither this node nor any descendant is interested in the touch event, this
 * method returns YES. If this node or a descendant is interested in the touch event,
 * the gesture is cancelled and this method returns NO.
 */
-(BOOL) cc3ValidateGesture: (UIGestureRecognizer*) gesture;

@end


#pragma mark -
#pragma mark CCLayer extension

/** Extension category to support cocos3d functionality. */
@interface CCLayer (CC3)

/**
 * Returns whether this node will receive touch events.
 *
 * This implementation returns the value of the isTouchEnabled property.
 */
-(BOOL) cc3IsTouchEnabled;

@end


#pragma mark -
#pragma mark CCMenu extension

/** Extension category to support cocos3d functionality. */
@interface CCMenu (CC3)

/** 
 * Returns whether this node contains the specified UI touch location.
 *
 * Overridden to test the view point against the bounds of the child
 * menu items instead of against the bounds of the menu itself.
 */
-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint;

@end


#pragma mark -
#pragma mark CCDirector extension

/** Extension category to support cocos3d functionality. */
@interface CCDirector (CC3)

/** Returns the time interval in seconds between the current render frame and the previous frame. */
-(ccTime) frameInterval;

/** Returns the current rendering perfromance in average frames per second. */
-(ccTime) frameRate;

@end


#pragma mark -
#pragma mark CC3BMFontConfiguration 

/** Extends CC3BMFontConfiguration to support cocos3d functionality. */
@interface CC3BMFontConfiguration : CCBMFontConfiguration {
@public
	ccGridSize textureSize;
	NSUInteger baseline;
	GLfloat fontSize;
}

/** Returns a pointer to the specification of the specified character. */
-(ccBMFontDef*) characterSpecFor: (unichar) c;

/**
 * Returns the amount of kerning required when the specified second character follows the
 * first character in a line of text.
 */
-(NSInteger) kerningBetween: (unichar) firstChar and: (unichar) secondChar;

/**
 * Returns an instance loaded from the specified bitmap font definition file.
 *
 * This implementation maintains a cache so that each file is only loaded once.
 */
+(id) configurationFromFontFile: (NSString*) fontFile;

/** Clears all cached font configurations to conserve memory. */
+(void) clearFontConfigurations;

@end


#pragma mark -
#pragma mark CCArray extension

/**
 * Extension category to support cocos3d functionality.
 *
 * This extension includes a number of methods that add or remove objects to and from
 * the array without retaining and releasing them. These methods are identified by the
 * word Unretained in their names, and are faster than their standard equivalent methods
 * that do retain and release objects.
 *
 * It is critical that use of these methods is consistent for any object added. If an
 * object is added using an "Unretained" method, then it must be removed using an
 * "Unretained" method.
 */
@interface CCArray (CC3)

/** Returns the index of the specified object, by comparing objects using the == operator. */
-(NSUInteger) indexOfObjectIdenticalTo: (id) anObject;

/** Removes the specified object, by comparing objects using the == operator. */
-(void) removeObjectIdenticalTo: (id) anObject;

/**
 * Replaces the object at the specified index with the specified object.
 *
 * This performs a simple replacement, which is faster than the implementation
 * of the replaceObjectAtIndex: method, which adds and then removes.
 */
-(void) fastReplaceObjectAtIndex: (NSUInteger) index withObject: (id) anObject;

/**
 * Expands or shrinks the array to the specified capacity.
 *
 * If the new capacity is less than the current number of elements, the excess elements are released.
 * 
 * Returns whether the size of the array was changed.
 */
-(BOOL) setCapacity: (NSUInteger) newCapacity;


#pragma mark Allocation and initialization

/**
 * Initializes this instance to have zero initial capacity. It will be expanded automatically
 * when objects are added, or can be expanced explicity using the setCapacity: method.
 */
- (id) initWithZeroCapacity;

/**
 * Allocates and initializes an autoreleased instance to have zero initial capacity.
 * It will be expanded automatically when objects are added, or can be expanced explicity
 * using the setCapacity: method.
 */
+(id) arrayWithZeroCapacity;


#pragma mark Support for unretained objects

/**
 * Adds the specified object to the end of the array, but does not retain the object.
 *
 * When removing the object, it must not be released. Use one the
 * removeUnretainedObject... methods to remove the object.
 */
- (void) addUnretainedObject: (id) anObject;

/**
 * Inserts the specified object at the specified index within the array,
 * but does not retain the object. The elements in the array after the
 * specified index position are shuffled up to make room for the new object.
 *
 * When removing the object, it must not be released. Use one the
 * removeUnretainedObject... methods to remove the object.
 */
- (void) insertUnretainedObject: (id) anObject atIndex: (NSUInteger) index;

/**
 * Removes the specified object from the array, without releasing it,
 * by comparing objects using the == operator.
 *
 * The objects after this object in the array are shuffled down to fill in the gap.
 *
 * The object being removed must not have been retained when added to the array.
 */
- (void) removeUnretainedObjectIdenticalTo: (id) anObject;

/**
 * Removes the object at the specified index, without releasing it.
 *
 * The objects after this object in the array are shuffled down to fill in the gap.
 *
 * The object being removed must not have been retained when added to the array.
 */
- (void) removeUnretainedObjectAtIndex: (NSUInteger) index;

/**
 * Removes all objects in the array, without releasing them.
 *
 * All objects being removed must not have been retained when added to the array.
 */
- (void) removeAllObjectsAsUnretained;

/**
 * Releases the array without releasing each contained object.
 *
 * All contained objects must not have been retained when added to the array.
 */
-(void) releaseAsUnretained;

/** Returns a more detailed description of this instance. */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functions

/** Returns the name of the specified touch type. */
NSString* NSStringFromTouchType(uint tType);
