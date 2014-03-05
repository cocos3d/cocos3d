/*
 * CC3World.m
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
 * See header file CC3World.h for full API documentation.
 */

#import "CC3World.h"

/** Re-declaration of deprecated methods to suppress compiler warnings within this class. */
@protocol CC3WorldDeprecated
-(void) initializeWorld;
-(void) updateWorld: (CCTime)dt;
-(void) updateWorld;
-(void) drawWorld;
@end

#pragma mark -
#pragma mark Deprecated CC3World
@implementation CC3World

+(id) world { return [self new]; }

// Delegate to legacy in case it has been overridden.
-(void) initializeScene { [(id<CC3WorldDeprecated>)self initializeWorld]; }
-(void) initializeWorld {}

// Delegate to legacy in case it has been overridden.
-(void) updateScene: (CCTime) dt { [(id<CC3WorldDeprecated>)self updateWorld: dt]; }
-(void) updateScene { [(id<CC3WorldDeprecated>)self updateWorld]; }

// Forward to superclass, in case apps invoke it.
-(void) updateWorld: (CCTime) dt { [super updateScene: dt]; }
-(void) updateWorld { [super updateScene]; }

// Delegate to legacy in case it has been overridden.
-(void) drawScene { [(id<CC3WorldDeprecated>)self drawWorld]; }

// Forward to superclass, in case apps invoke it.
-(void) drawWorld { [super drawScene]; }

@end
