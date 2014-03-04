/*
 * CC3DataStreams.h
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


#import "CC3Foundation.h"


/** 
 * CC3DataReader sequentially reads data from the bytes managed by a NSData object.
 *
 * Reading starts at the beginning of the data bytes contained in the NSData object.
 * As each element is read, the pointer is advanced to the beginning of the next element.
 *
 * If an attempt is made to read beyond the end of the contained data, the element reading
 * methods will return a default value, and the value of the wasReadBeyondEOF property is
 * set to YES. You can test the value of this property after each read, or once reading is
 * complete in order to determine if an unexpected end of data was encountered.
 */
@interface CC3DataReader : NSObject {
	NSData* _data;
	NSRange _readRange;
	BOOL _wasReadBeyondEOF : 1;
	BOOL _isBigEndian : 1;
}

/** Returns the encapsulated data object. */
@property(nonatomic, retain, readonly) NSData* data;

/** Returns the current position in the stream. */
@property(nonatomic, readonly) NSUInteger position;

/** Bytes remaining to be read. */
@property(nonatomic, readonly) NSUInteger bytesRemaining;

/** Returns YES if an attempt was made to read beyond the end of the data content. */
@property(nonatomic, readonly) BOOL wasReadBeyondEOF;

/** 
 * Indicates whether the source content was encoded on a big-endian platform.
 *
 * Most OSX and iOS platforms are little-endian, so this property defaults to NO.
 * You can set the value of this property to YES prior to reading any content if
 * you know the data was encoded on a big-endian platform.
 */
@property(nonatomic, assign) BOOL isBigEndian;


#pragma mark Allocation and initialization

/** Initializes this instance on the specified NSData object.  */
-(id) initOnData: (NSData*) data;

/** Allocates and initializes an autoreleased instance on the specified NSData object. */
+(id) readerOnData: (NSData*) data;


#pragma mark Reading stream content

/** 
 * Reads the specified number of bytes into the specified byte array, and advances the stream position.
 *
 * If ALL of the bytes cannot be read, then the entire array of bytes is zeroed,
 * and the stream position, as returned by the postion property, is not advanced.
 *
 * Returns YES if the requested number of bytes was successfully read into the specified byte
 * array, and the steam position was advanced. Otherwise, returns NO to indicate that none of
 * the bytes were read, the stream position was not advanced, and the byte array was zeroed.
 */
-(BOOL) readAll: (NSUInteger) count bytes: (char*) bytes;

/**
 * Reads and returns a byte from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(char) readByte;

/**
 * Reads and returns an unsigned byte from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(unsigned char) readUnsignedByte;

/**
 * Reads and returns a float from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(float) readFloat;

/**
 * Reads and returns a double from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(double) readDouble;

/**
 * Reads and returns an integer from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(int) readInteger;

/**
 * Reads and returns an unsigned integer from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(unsigned int) readUnsignedInteger;

/**
 * Reads and returns a short from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(short) readShort;

/**
 * Reads and returns an unsigned short from the current position in the stream,
 * and advances the stream pointer.
 *
 * If the value could not be read, returns zero, and does not advance the stream position.
 */
-(unsigned short) readUnsignedShort;

@end
