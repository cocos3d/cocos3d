/**
 * CC3NodeListeners.m
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
 * 
 * See header file CC3NodeListeners.h for full API documentation.
 */

#import "CC3NodeListeners.h"


#pragma mark -
#pragma mark CC3NodeTransformListeners

@implementation CC3NodeTransformListeners

-(void) dealloc {
	_node = nil;							// weak reference
	[_transformListenerWrappers release];

	[self deleteLock];
	
	[super dealloc];
}


#pragma mark NSLocking implementation

-(void) lock { pthread_mutex_lock(&_mutex); }

-(void) unlock { pthread_mutex_unlock(&_mutex); }

-(void) initLock { pthread_mutex_init(&_mutex, NULL); }

-(void) deleteLock { pthread_mutex_destroy(&_mutex); }


#pragma mark Transformation listeners

/** Utility method to resolve the weak reference from the specified object, and cast the result as a listener. */
-(id<CC3NodeTransformListenerProtocol>) getListenerFrom: (NSObject*) listenerWrapper {
	return (id<CC3NodeTransformListenerProtocol>)listenerWrapper.resolveWeakReference;
}

-(NSUInteger) count { return _transformListenerWrappers.count; }

-(BOOL) isEmpty { return self.count == 0; }

-(NSSet*) transformListeners {
	NSMutableSet* xfmListeners = [NSMutableSet set];
	[self lock];
	for(NSValue* xlWrap in _transformListenerWrappers)
		[xfmListeners addObject: [self getListenerFrom: xlWrap]];
	[self unlock];
	return xfmListeners;
}

-(void) addTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener {
	if (!aListener) return;
	
	// Adds listener as a weak reference
	[self lock];
	[_transformListenerWrappers addObject: [aListener asWeakReference]];
	[self unlock];
}

-(void) removeTransformListener: (id<CC3NodeTransformListenerProtocol>) aListener {
	if (!aListener) return;

	// Removes listener as a weak reference
	[self lock];
	[_transformListenerWrappers removeObject: [aListener asWeakReference]];
	[self unlock];
}

-(void) removeAllTransformListeners {
	NSSet* myListeners = self.transformListeners;
	for(NSValue* xlWrap in myListeners)
		[self removeTransformListener: [self getListenerFrom: xlWrap]];
}

-(void) notifyTransformListeners {
	LogTrace(@"%@ notifying %i transform listeners", _node, self.count);
	[self lock];
	for (NSValue* xlWrap in _transformListenerWrappers)
		[[self getListenerFrom: xlWrap] nodeWasTransformed: _node];
	[self unlock];
}

-(void) notifyDestructionListeners {
	[self lock];
	for (NSValue* xlWrap in _transformListenerWrappers)
		[[self getListenerFrom: xlWrap] nodeWasDestroyed: _node];
	[self unlock];
}


#pragma mark Allocation and initialization

-(id) initForNode: (CC3Node*) node {
	if ( (self = [super init]) ) {
		_node = node;		// weak reference
		_transformListenerWrappers = [NSMutableSet new];	// retained
		[self initLock];
	}
	return self;
}

+(id) listenersForNode: (CC3Node*) node { return [[[self alloc] initForNode: node] autorelease]; }

@end




