/*
 * CC3DataArray.m
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
 * See header file CC3DataArray.h for full API documentation.
 */

#import "CC3DataArray.h"


#pragma mark CC3DataArray

@implementation CC3DataArray

@synthesize isReady=_isReady;

-(void) dealloc {
	[_data release];
	[super dealloc];
}
	
-(NSUInteger) elementSize { return MAX(_elementSize, 1); }

-(void) setElementSize: (NSUInteger) elementSize {
	if (elementSize == self.elementSize) return;
	NSUInteger elemCap = self.elementCapacity;		// Retrieve before changing size.
	_elementSize = MAX(elementSize, 1);
	self.elementCapacity = elemCap;
}

-(NSUInteger) elementCapacity { return _data.length / self.elementSize; }

-(void) setElementCapacity: (NSUInteger) elementCapacity {
	if (elementCapacity == self.elementCapacity) return;
	_data.length = self.elementSize * elementCapacity;
}

-(void) ensureElementCapacity: (NSUInteger) elementCapacity {
	if (elementCapacity > self.elementCapacity) self.elementCapacity = elementCapacity;
}


#pragma mark Accessing data

-(void*) elementAt: (NSUInteger) index {
	return (char*)_data.mutableBytes + (self.elementSize * index);
}


#pragma mark Allocation and initialization

-(id) init { return [self initWithElementSize: 1]; }

-(id) initWithElementSize: (NSUInteger) elementSize {
	if ( (self = [super init]) ) {
		_data = [NSMutableData new];	// retained
		_elementSize = elementSize;
		_isReady = NO;
	}
	return self;
}

+(id) dataArrayWithElementSize: (NSUInteger) elementSize {
	return [[[self alloc] initWithElementSize: elementSize] autorelease];
}

@end

