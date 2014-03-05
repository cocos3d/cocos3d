/*
 * CC3OSExtensions.h
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


/* Base library of extensions to operating system frameworks to support cocos3d. */

#import <Foundation/Foundation.h>

#import "CC3iOSExtensions.h"
#import "CC3OSXExtensions.h"


#pragma mark -
#pragma mark NSObject protocol extensions

/** Extension to support cocos3d functionality. */
@protocol CC3Object <NSObject>

/**
 * Returns a string containing a more complete description of this object.
 *
 * This implementation simply invokes the description method. Subclasses with more
 * substantial content can override to provide much more information.
 */
-(NSString*) fullDescription;

/**
 * Returns this object wrapped in a weak reference.
 *
 * You can retrieve this original object by invoking the resolveWeakReference on the returned object.
 *
 * This method is useful when you want to add this object to a collection, but don't want to create
 * a strong reference to it within the collection, or in any other situation where you want to
 * assign this object to a strong reference, but need to avoid a potential retain cycle.
 *
 * This implementation creates and returns an NSValue, with this object set as its nonretainedObjectValue.
 */
-(id) asWeakReference;

/**
 * When invoked on the object returned by the asWeakReference method, returns the original object.
 * When invoked on any other object, simply returns that object.
 */
-(id) resolveWeakReference;

@end


#pragma mark -
#pragma mark NSObject class extensions

/** Extension category to support cocos3d functionality. */
@interface NSObject (CC3) <CC3Object>

/** 
 * Returns whether this object represents the standard null object retrieved from [NSNull null].
 *
 * Returns NO. The NSNull subclass returns YES.
 */
@property(nonatomic, readonly) BOOL isNull;

/** 
 * Returns an autoreleased copy of this object.
 *
 * This is a convenience method that simply invokes [[self copy] autorelease]. 
 */
-(id) autoreleasedCopy;

/** @deprecated Renamed to autoreleasedCopy to satisfy naming paradigm for copy... methods. */
-(id) copyAutoreleased DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark NSThread extensions

/** Extension category to support cocos3d functionality. */
@interface NSThread (CC3)

/** 
 * Dispatches the specified block to the run loop of this thread, without waiting for the
 * block to be executed.
 *
 * This method returns immediately once the specified block is queued for execution on the run
 * loop of this thread. This method does not wait for the execution of the block to complete.
 *
 * This method copies the block and releases the copy it once it has been executed.
 */
-(void) runBlockAsync: (void (^)(void)) block;

/**
 * Dispatches the specified block to the run loop of this thread, and waits for the block
 * to be executed. 
 *
 * This method returns only after the the specified block has completed execution. 
 * The current thread will halt (block) until then.
 *
 * This method copies the block and releases the copy it once it has been executed.
 */
-(void) runBlockSync: (void (^)(void)) block;

/**
 * Waits the specified number of seconds, then dispatches the specified block to the run 
 * loop of this thread.
 *
 * This method returns immediately once the specified block is queued for execution on the run
 * loop of this thread. This method does not wait for the execution of the block to complete.
 *
 * This method copies the block and releases the copy it once it has been executed.
 */
-(void) runBlock: (void (^)(void))block after: (NSTimeInterval) seconds;

@end


#pragma mark -
#pragma mark NSRunLoop extensions

/** Extension category to support cocos3d functionality. */
@interface NSRunLoop (CC3)

/**
 * Dispatches the specified block to be run on the next iteration of this run loop. 
 * The block will be run only once, within one of the default run loop modes, during
 * the next iteration of the run loop.
 *
 * This is useful for running a block that is used for cleaning-up, and you want to ensure
 * that all autoreleased objects have been deallocated before running the block.
 *
 * This method returns immediately once the specified block is queued for execution on
 * this run loop. This method does not wait for the execution of the block to complete.
 *
 * This method copies the block and releases the copy it once it has been executed.
 */
-(void) runBlockOnNextIteration: (void (^)(void)) block;

@end


#pragma mark -
#pragma mark NSString extensions

/** Extension category to support cocos3d functionality. */
@interface NSString (CC3)

/** Returns the number of lines in this string. */
@property(nonatomic, readonly) NSUInteger lineCount;

/** 
 * Returns an array of the lines in this string, as determined by separating
 * them with the newline character, and trimming each of all newline chars.
 */
@property(nonatomic, readonly) NSArray* lines;

/**
 * Returns an array of the lines in this string, as determined by separating them with the
 * newline character. Each line in the returned array is terminated by the newline character.
 */
@property(nonatomic, readonly) NSArray* terminatedLines;

@end



