/*
 * CC3PODResourceNode.m
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
 * See header file CC3PODResourceNode.h for full API documentation.
 */

#import "CC3PODResourceNode.h"


@implementation CC3PODResourceNode

@synthesize animationFrameCount=_animationFrameCount;
@synthesize animationFrameRate=_animationFrameRate;

-(Class) resourceClass { return [CC3PODResource class]; }

/** Overridden to extract the animation frame count and rate. */
-(void) populateFromResource: (CC3PODResource*) resource {
	[super populateFromResource: resource];
	
	_animationFrameCount = resource.animationFrameCount;
	_animationFrameRate = resource.animationFrameRate;
}

-(void) populateFrom: (CC3PODResourceNode*) another {
	[super populateFrom: another];
	
	_animationFrameCount = another.animationFrameCount;
	_animationFrameRate = another.animationFrameRate;
}

@end


#pragma mark -
#pragma mark CC3Node extensions to support PVR POD content

@implementation CC3Node (PVRPODRez)

-(void) addContentFromPODFile: (NSString*) aFilepath {
	[self addChild: [CC3PODResourceNode nodeFromFile: aFilepath]];
}

-(void) addContentFromPODFile: (NSString*) aFilepath withName: (NSString*) aName {
	[self addChild: [CC3PODResourceNode nodeWithName: aName fromFile: aFilepath]];
}

// Deprecated
-(void) addContentFromPODResourceFile: (NSString*) aRezPath {
	[self addContentFromPODFile: aRezPath];
}

// Deprecated
-(void) addContentFromPODResourceFile: (NSString*) aRezPath withName: (NSString*) aName; {
	[self addContentFromPODFile: aRezPath withName: aName];
}

@end
