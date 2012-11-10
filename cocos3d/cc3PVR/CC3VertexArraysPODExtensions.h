/*
 * CC3VertexArraysPODExtensions.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3VertexArrays.h"
#import "CC3PVRFoundation.h"


#pragma mark CC3VertexArray PVRPOD extensions

/** Extensions to CC3VertexArray to support PVR POD data. */
@interface CC3VertexArray (PVRPOD)

/**
 * Initializes this instance from the specified CPODData structure
 * and the specified SPODMesh structure.
 */
-(id) initFromCPODData: (PODClassPtr) aCPODData
		  fromSPODMesh: (PODStructPtr) aSPODMesh;

/**
 * Initializes this instance from the  specified SPODMesh structure.
 *
 * This abstract implementation does nothing. Category extensions to the concrete
 * subclasses of CC3VertexArray must override to extract the suitable CPODData
 * structure for the type of array from the specifed SPODMesh structure and then
 * invoke the initFromCPODData:fromSPODMesh: initializer.
 */
-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh;

/** Allocates and initializes an autoreleased instance from the  specified SPODMesh structure. */
+(id) arrayFromSPODMesh: (PODStructPtr) aSPODMesh;

@end


#pragma mark -
#pragma mark CC3VertexTextureCoordinates PVRPOD extensions

/** Extensions to CC3VertexTextureCoordinates to support PVR POD data. */
@interface CC3VertexTextureCoordinates (PVRPOD)

/**
 * Initializes this instance from the  specified SPODMesh structure,
 * using the specified texture channel.
 */
-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh forTextureUnit: (GLuint) texUnit;

/**
 * Allocates and initializes an autoreleased instance from the
 * specified SPODMesh structure, using the specified texture channel.
 */
+(id) arrayFromSPODMesh: (PODStructPtr) aSPODMesh forTextureUnit: (GLuint) texUnit;

/**
 * Initializes this instance from the  specified SPODMesh structure,
 * using texture channel zero.
 */
-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh;

@end


