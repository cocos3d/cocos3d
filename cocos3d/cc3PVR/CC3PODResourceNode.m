/*
 * CC3PODResourceNode.m
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
 * 
 * See header file CC3PODResourceNode.h for full API documentation.
 */

#import "CC3PODResourceNode.h"


@implementation CC3PODResourceNode

-(Class) resourceClass {
	return [CC3PODResource class];
}

@end


#pragma mark -
#pragma mark CC3World extensions to support PVR POD content

@implementation CC3World (PVRPOD)

-(void) addContentFromPODFile: (NSString*) aFilepath {
	[self addChild: [CC3PODResourceNode nodeFromFile: aFilepath]];
}

-(void) addContentFromPODFile: (NSString*) aFilepath withName: (NSString*) aName {
	[self addChild: [CC3PODResourceNode nodeWithName: aName fromFile: aFilepath]];
}

-(void) addContentFromPODResourceFile: (NSString*) aRezPath {
	[self addChild: [CC3PODResourceNode nodeFromResourceFile: aRezPath]];
}

-(void) addContentFromPODResourceFile: (NSString*) aRezPath withName: (NSString*) aName; {
	[self addChild: [CC3PODResourceNode nodeWithName: aName fromResourceFile: aRezPath]];
}

@end
