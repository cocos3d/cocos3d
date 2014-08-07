/*
 * CC3World.h
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

#import "CC3Scene.h"
#import	"CC3TargettingNode.h"	// Imported here for legacy apps that used it
								// via implicit import from lights and cameras.


#pragma mark -
#pragma mark Deprecated CC3World

/** Support for legacy. */
#define kCC3DefaultLightColorAmbientWorld kCC3DefaultLightColorAmbientScene

__deprecated
/** @deprecated CC3World renamed to CC3Scene. */
@interface CC3World : CC3Scene

/** @deprecated CC3World renamed to CC3Scene. Use CC3Scene scene instead. */
+(id) world __deprecated;

/** @deprecated Renamed to initializeScene. */
-(void) initializeWorld __deprecated;

/** @deprecated Renamed to updateScene:. */
-(void) updateWorld: (CCTime)dt __deprecated;

/** @deprecated Renamed to updateScene. */
-(void) updateWorld __deprecated;

/** @deprecated Renamed to drawScene. */
-(void) drawWorld __deprecated;

@end
