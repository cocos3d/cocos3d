/*
 * CC3VertexArraysPODExtensions.mm
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
 * See header file CC3VertexArraysPODExtensions.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}

#import "CC3VertexArraysPODExtensions.h"
#import "CC3PVRTModelPOD.h"


#pragma mark CC3VertexArray PVRPOD extensions

@interface CC3VertexArray (PVRPODTemplateMethods)
	-(void) setElementsFromCPODData: (CPODData*) aCPODData fromSPODMesh: (SPODMesh*) aSPODMesh;
@end

@implementation CC3VertexArray (PVRPOD)

-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	CPODData* pcd = (CPODData*)aCPODData;
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if ( (self = [super init]) ) {
		GLint elemSize = pcd->n;
		LogRez(@"\t%@ %@ from: %@", (elemSize ? @"Creating" : @"Skipping"), [self class], NSStringFromCPODData(pcd));
		if (elemSize) {
			self.elementType = GLElementTypeFromEPVRTDataType(pcd->eType);
			self.shouldNormalizeContent = CC3ShouldNormalizeEPVRTDataType(pcd->eType);
			self.elementSize = elemSize;
			self.vertexStride = pcd->nStride;
			self.vertexCount = psm->nNumVertex;
			[self setElementsFromCPODData: pcd fromSPODMesh: psm];
		} else {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) arrayFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	return [[[self alloc] initFromCPODData: aCPODData fromSPODMesh: aSPODMesh] autorelease];
}

/** Template method extracts the vertex data from the specified SPODMesh and CPODData structures.  */
-(void) setElementsFromCPODData: (CPODData*) aCPODData fromSPODMesh: (SPODMesh*) aSPODMesh {
	if (aSPODMesh->pInterleaved) {					// vertex data is interleaved
		self.vertices = aSPODMesh->pInterleaved;
		self.elementOffset = (GLuint)(intptr_t)aCPODData->pData;
	} else {										// not interleaved
		self.vertices = aCPODData->pData;
		_allocatedVertexCapacity = _vertexCount;	// CC3VertexArray instance will free data when needed.
		aCPODData->pData = NULL;					// Clear data reference from CPODData so it won't try to free it.
		self.elementOffset = 0;
	}
}

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray PVRPOD extensions

@implementation CC3DrawableVertexArray (PVRPOD)

-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if ( (self = [super initFromCPODData: aCPODData fromSPODMesh: aSPODMesh]) ) {
		self.drawingMode = GLDrawingModeForSPODMesh(aSPODMesh);

		[self allocateStripLengths: psm->nNumStrips];
		for (uint i = 0; i < psm->nNumStrips; i++)
			_stripLengths[i] = [self vertexIndexCountFromFaceCount: (psm->pnStripLength[i])];
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3VertexLocations PVRPOD extensions

@implementation CC3VertexLocations (PVRPOD)

/** CC3VertexLocations manages freeing either dedicated or interleaved data */
-(void) setElementsFromCPODData: (CPODData*) aCPODData fromSPODMesh: (SPODMesh*) aSPODMesh {
	[super setElementsFromCPODData: aCPODData fromSPODMesh: aSPODMesh];
	_allocatedVertexCapacity = _vertexCount;	// CC3VertexArray instance will free data when needed.
}

@end


#pragma mark -
#pragma mark CC3VertexColors PVRPOD extensions

@implementation CC3VertexColors (PVRPOD)

// Element size must be 4 for colors. POD loader sometimes provides incorrect value.
// Thanks to cocos3d user esmrg who contributed the fix for element size.
-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	if ( (self = [super initFromCPODData: aCPODData fromSPODMesh: aSPODMesh]) ) {
		self.elementSize = 4;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3VertexTextureCoordinates PVRPOD extensions

@implementation CC3VertexTextureCoordinates (PVRPOD)

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh forTextureUnit: (GLuint) texUnit {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if (texUnit < psm->nNumUVW)
		return [self initFromCPODData: &psm->psUVW[texUnit] fromSPODMesh: aSPODMesh];
	else
		return nil;
}

+(id) arrayFromSPODMesh: (PODStructPtr) aSPODMesh forTextureUnit: (GLuint) texUnit {
	return [[[self alloc] initFromSPODMesh: aSPODMesh forTextureUnit: texUnit] autorelease];
}

@end


#pragma mark -
#pragma mark CC3VertexIndices PVRPOD extensions

@implementation CC3VertexIndices (PVRPOD)

/** Calc vertexCount after drawingMode has been set. */
-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	if ( (self = [super initFromCPODData: aCPODData fromSPODMesh: aSPODMesh]) ) {
		self.vertexCount = [self vertexIndexCountFromFaceCount: ((SPODMesh*)aSPODMesh)->nNumFaces];
		_allocatedVertexCapacity = _vertexCount;	// CC3VertexArray instance will free data when needed.
	}
	return self;
}

-(void) setElementsFromCPODData: (CPODData*) aCPODData fromSPODMesh: (SPODMesh*) aSPODMesh {
	self.vertices = aCPODData->pData;
	aCPODData->pData = NULL;			// Clear data reference from CPODData so it won't try to free it.
	self.elementOffset = 0;				// Indices are not interleaved.
}

@end



