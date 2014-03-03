/*
 * CC3NodeListeners.h
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

#import "CC3Foundation.h"
#import "CC3OSExtensions.h"
#import <pthread.h>

@class CC3Node;


#pragma mark -
#pragma mark CC3NodeListenerProtocol

/**
 * This protocol defines the behaviour requirements for objects that wish to be
 * notified about the basic existence of a node.
 */
@protocol CC3NodeListenerProtocol <CC3Object>

/**
 * Callback method that will be invoked when the node has been deallocated.
 *
 * Although the sending node is still alive when sending this message, its state is
 * unpredictable, because all subclass state will have been released or detroyed when
 * this message is sent. The receiver of this message should not attempt to send any
 * messages to the sender. Instead, it should simply clear any references to the node.
 */
-(void) nodeWasDestroyed: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodeTransformListenerProtocol

/**
 * This protocol defines the behaviour requirements for objects that wish to be
 * notified whenever the transform of a node has changed.
 *
 * This occurs when one of the transform properties (location, rotation & scale)
 * of the node, or any of its structural ancestor nodes, has changed.
 *
 * A transform listener can be registered with a node via the addTransformListener: method.
 *
 * Each listener registered with a node will be sent the nodeWasTransformed: notification
 * message when the globalTransformMatrix of this node is recalculated, or is set directly.
 */
@protocol CC3NodeTransformListenerProtocol <CC3NodeListenerProtocol>

/** Callback method that will be invoked when the globalTransformMatrix of the specified node has changed. */
-(void) nodeWasTransformed: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodeTransformListeners

/** Manages a collection of transform listeners on behalf of a CC3Node. */
@interface CC3NodeTransformListeners : NSObject <NSLocking> {
	CC3Node* _node;
	NSMutableSet* _transformListenerWrappers;
	pthread_mutex_t _mutex;
}


#pragma mark Transformation listeners

/** Returns the number of listeners. */
@property(nonatomic, readonly) NSUInteger count;

/** Returns whether there are no listeners. */
@property(nonatomic, readonly) BOOL isEmpty;

/**
 * Returns a copy of the collection of objects that have requested that they be notified
 * whenever the transform of the node has changed.
 *
 * Each object in the returned collection implements the CC3NodeTransformListenerProtocol,
 * and will be sent the nodeWasTransformed: notification message when the transform of this
 * node changes.
 *
 * Objects can be added to this collection by using the addTransformListener: method, and
 * removed using the removeTransformListener: method. This property returns a copy of the
 * collection stored in this node. You can safely invoke the addTransformListener: or
 * removeTransformListener: methods while iterating the returned collection.
 *
 * Transform listeners are weakly referenced. Each listener should know who it has subscribed
 * to, and must remove itself as a listener (using the removeTransformListener: method) when
 * appropriate, such as when being deallocated.
 */
@property(nonatomic, retain, readonly) NSSet* transformListeners;

/**
 * Adds the specified object as a transform listener.
 *
 * It is safe to invoke this method more than once for the same listener, or
 * with a nil listener. In either case, this method simply ignores the request.
 *
 * Transform listeners are weakly referenced. Each listener should know who it has subscribed
 * to, and must remove itself as a listener (using the removeTransformListener: method) when
 * appropriate, such as when being deallocated.
 */
-(void) addTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener;

/**
 * Removes the specified object as a transform listener.
 *
 * It is safe to invoke this method with a listener that was not previously added,
 * or with a nil listener. In either case, this method simply ignores the request.
 */
-(void) removeTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener;

/** Removes all transform listeners. */
-(void) removeAllTransformListeners;

/** Notify the transform listeners that the node has been transformed. */
-(void) notifyTransformListeners;

/** Notify the transform listeners that the node has been destroyed. */
-(void) notifyDestructionListeners;


#pragma mark Allocation and initialization

/** Initializes this instance to track transform listeners for the specified node. */
-(id) initForNode: (CC3Node*) node;

/** Allocates and initializes an instance to track transform listeners for the specified node. */
+(id) listenersForNode: (CC3Node*) node;

@end

