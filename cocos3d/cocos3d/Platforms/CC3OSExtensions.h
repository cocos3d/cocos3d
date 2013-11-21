/*
 * CC3OSExtensions.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#pragma mark NSObject extensions

/** Extension category to support cocos3d functionality. */
@interface NSObject (CC3)

/**
 * Returns a string containing a more complete description of this object.
 *
 * This implementation simply invokes the description method. Subclasses with more
 * substantial content can override to provide much more information.
 */
-(NSString*) fullDescription;

/** @deprecated Not required with ARC. */
-(id) autoreleasedCopy DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to autoreleasedCopy to satisfy naming paradigm for copy... methods. */
-(id) copyAutoreleased DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark NSArray extensions

/** Extension category to support cocos3d functionality. */
@interface NSArray (CC3)

/**
 * Returns a string containing a more complete description of this object.
 *
 * The returned string includes a description of each element, each on a separate line.
 */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark NSThread extensions

@interface NSThread (CC3)

/** 
 * Dispatches the specified block to the run loop of this thread, without waiting for the
 * block to be executed.
 *
 * This method returns immediately once the specified block is queued for execution on the run
 * loop of this thread. This method does not wait for the execution of the block to complete.
 */
-(void) runBlockAsync: (void (^)(void)) block;

/**
 * Dispatches the specified block to the run loop of this thread, and waits for the block
 * to be executed. 
 *
 * This method returns only after the the specified block has completed execution. 
 * The current thread will halt (block) until then.
 */
-(void) runBlockSync: (void (^)(void)) block;

@end
