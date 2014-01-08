/*
 * CC3TargettingNode.h
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


#pragma mark -
#pragma mark Deprecated classes and node extensions

DEPRECATED_ATTRIBUTE
/**
 * Deprecated and functionality moved to CC3Node class.
 * @deprecated CC3TargettingNode is deprecated. Its former functionality
 * has been moved into the CC3Node class.
 */
@interface CC3TargettingNode : CC3Node
@end

/**
 * Deprecated and functionality moved to CC3Node class.
 * @deprecated CC3LightTracker is deprecated. Its former functionality has been
 * moved into the CC3Node class with the isTrackingForBumpMapping property.
 */
DEPRECATED_ATTRIBUTE
@interface  CC3LightTracker : CC3Node
@end

@interface CC3Node (CC3TargettingNode)

/** @deprecated Replaced with asOrientingWrapper. */
-(CC3TargettingNode*) asTargettingNode DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced with asTrackingWrapper. */
-(CC3TargettingNode*) asTracker DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced with asCameraTrackingWrapper. */
-(CC3TargettingNode*) asCameraTracker DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced with asBumpMapLightTrackingWrapper. */
-(CC3TargettingNode*) asLightTracker DEPRECATED_ATTRIBUTE;

@end
