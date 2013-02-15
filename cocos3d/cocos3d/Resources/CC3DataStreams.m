/*
 * CC3DataStreams.m
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
 * 
 * See header file CC3DataStreams.h for full API documentation.
 */

#import "CC3DataStreams.h"


@implementation CC3DataReader

@synthesize data=_data, isBigEndian=_isBigEndian, wasReadBeyondEOF=_wasReadBeyondEOF;

-(void) dealloc {
	[_data release];
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) init {
	CC3Assert(NO, @"%@ cannot be initialized without an NSData object", [self class ]);
	return nil;
}

-(id) initOnData: (NSData*) data {
	if ( (self = [super init]) ) {
		_data = [data retain];
		_readRange = NSMakeRange(0, 0);
		_isBigEndian = NO;
		_wasReadBeyondEOF = NO;
	}
	return self;
}

+(id) readerOnData: (NSData*) data { return [[[self alloc] initOnData: data] autorelease]; }

-(NSUInteger) position { return _readRange.location; }

-(NSUInteger) bytesRemaining { return _data.length - _readRange.location; }


#pragma mark Reading stream content

-(void) read: (NSUInteger) count bytes: (char*) bytes {
	_readRange.length = count;
	NSUInteger endRange = NSMaxRange(_readRange);
	_wasReadBeyondEOF |= (endRange > _data.length);
	if( !_wasReadBeyondEOF ) {
		[_data getBytes: bytes range: _readRange];
		_readRange.location = endRange;
	}
}

-(char) readByte {
	char value = 0;
	[self read: sizeof(value) bytes: (char*)&value];
	return value;
}

-(unsigned char) readUnsignedByte {
	unsigned char value = 0;
	[self read: sizeof(value) bytes: (char*)&value];
	return value;
}

-(float) readFloat {
	NSSwappedFloat value;
	value.v = 0;	// zero the internal value
	[self read: sizeof(value) bytes: (char*)&value];
	return _isBigEndian ? NSSwapBigFloatToHost(value) : NSSwapLittleFloatToHost(value);
}

-(double) readDouble {
	NSSwappedDouble value;
	value.v = 0;	// zero the internal value
	[self read: sizeof(value) bytes: (char*)&value];
	return _isBigEndian ? NSSwapBigDoubleToHost(value) : NSSwapLittleDoubleToHost(value);
}

-(int) readInteger {
	int value = 0;
	[self read: sizeof(value) bytes: (char*)&value];
	return _isBigEndian ? NSSwapBigIntToHost(value) : NSSwapLittleIntToHost(value);
}

-(unsigned int) readUnsignedInteger {
	unsigned int value = 0;
	[self read: sizeof(value) bytes: (char*)&value];
	return _isBigEndian ? NSSwapBigIntToHost(value) : NSSwapLittleIntToHost(value);
}

-(short) readShort {
	short value = 0;
	[self read: sizeof(value) bytes: (char*)&value];
	return _isBigEndian ? NSSwapBigShortToHost(value) : NSSwapLittleShortToHost(value);
}

-(unsigned short) readUnsignedShort {
	unsigned  short value = 0;
	[self read: sizeof(value) bytes: (char*)&value];
	return _isBigEndian ? NSSwapBigShortToHost(value) : NSSwapLittleShortToHost(value);
}

//-(float) readFloat {
//	float value = 0.0f;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}
//
//-(double) readDouble {
//	double value = 0.0;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}
//
//-(int) readInteger {
//	int value = 0;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}
//
//-(unsigned int) readUnsignedInteger {
//	unsigned int value = 0;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}
//
//-(short) readShort {
//	short value = 0;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}
//
//-(unsigned short) readUnsignedShort {
//	unsigned  short value = 0;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}
//
//-(void*) readPointer {
//	void* value = NULL;
//	[self read: sizeof(value) bytes: (char*)&value];
//	return value;
//}

@end
