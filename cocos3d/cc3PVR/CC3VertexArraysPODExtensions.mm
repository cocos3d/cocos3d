/*
 * CC3VertexArraysPODExtensions.mm
 *
 * cocos3d 0.5.4
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
 * See header file CC3VertexArraysPODExtensions.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}

#import "CC3VertexArraysPODExtensions.h"
#import "CC3PVRTModelPOD.h"


#pragma mark CC3VertexArray PVRPOD extensions

@implementation CC3VertexArray (PVRPOD)

-(id) initFromCPODData: (PODClassPtr) aCPODData
		  fromSPODMesh: (PODStructPtr) aSPODMesh {
	CPODData* pcd = (CPODData*)aCPODData;
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if ( (self = [super init]) ) {
		GLint elemSize = pcd->n;
		LogTrace(@"%@ %@ from %@", (elemSize ? @"Creating" : @"Skipping"), [self class], NSStringFromCPODData(pcd));
		if (elemSize) {
			self.elementType = GLElementTypeFromEPVRTDataType(pcd->eType);
			self.elementSize = elemSize;
			self.elementStride = pcd->nStride;
			self.elementCount = psm->nNumVertex;
			if (psm->pInterleaved) {					// vertex data is interleaved
				self.elements = psm->pInterleaved;
				self.elementOffset = (GLuint)pcd->pData;
			} else {									// not interleaved
				self.elements = pcd->pData;
				elementsAreRetained = YES;	// CC3VertexArray instance will free data when needed.
				pcd->pData = NULL;			// Clear data reference from CPODData so it won't try to free it.
				self.elementOffset = 0;
			}
		} else {
			[self release];
			return nil;
		}
		
	}
	return self;
}

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh {
	NSAssert(NO, @"CCVertexArrays initFromSPODMesh: must be overridden in subclass");
	return NULL;
}

+(id) arrayFromSPODMesh: (PODStructPtr) aSPODMesh {
	return [[[self alloc] initFromSPODMesh: aSPODMesh] autorelease];

}

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray PVRPOD extensions

@interface CC3DrawableVertexArray (TemplateArray)
-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc;
@end

@implementation CC3DrawableVertexArray (PVRPOD)

-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if ( (self = [super initFromCPODData: aCPODData fromSPODMesh: aSPODMesh]) ) {
		self.drawingMode = GLDrawingModeForSPODMesh(aSPODMesh);

		[self allocateStripLengths: psm->nNumStrips];
		for (uint i = 0; i < psm->nNumStrips; i++) {
			stripLengths[i] = [self vertexCountFromFaceCount: (psm->pnStripLength[i])];
		}
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3VertexLocations PVRPOD extensions

@implementation CC3VertexLocations (PVRPOD)

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	return [self initFromCPODData: &psm->sVertex fromSPODMesh: aSPODMesh];
}

-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	if ( (self = [super initFromCPODData: aCPODData fromSPODMesh: aSPODMesh]) ) {
		elementsAreRetained = YES;	// CC3VertexLocations manages freeing either dedicated or interleaved data
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3VertexNormals PVRPOD extensions

@implementation CC3VertexNormals (PVRPOD)

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	return [self initFromCPODData: &psm->sNormals fromSPODMesh: aSPODMesh];
}

@end


#pragma mark -
#pragma mark CC3VertexColors PVRPOD extensions

@implementation CC3VertexColors (PVRPOD)

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	return [self initFromCPODData: &psm->sVtxColours fromSPODMesh: aSPODMesh];
}

@end


#pragma mark -
#pragma mark CC3VertexTextureCoordinates PVRPOD extensions

@implementation CC3VertexTextureCoordinates (PVRPOD)

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh {
	return [self initFromSPODMesh: aSPODMesh forTextureChannel: 0];
}

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh forTextureChannel: (GLuint) texChannelIndex {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	if (texChannelIndex < psm->nNumUVW) {
		return [self initFromCPODData: &psm->psUVW[texChannelIndex] fromSPODMesh: aSPODMesh];
	} else {
		[self release];
		return nil;
	}
}

+(id) arrayFromSPODMesh: (PODStructPtr) aSPODMesh forTextureChannel: (GLuint) texChannelIndex {
	return [[[self alloc] initFromSPODMesh: aSPODMesh forTextureChannel: texChannelIndex] autorelease];
}

@end


#pragma mark -
#pragma mark CC3VertexIndices PVRPOD extensions

@implementation CC3VertexIndices (PVRPOD)

-(id) initFromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	return [self initFromCPODData: &psm->sFaces fromSPODMesh: aSPODMesh];
}

-(id) initFromCPODData: (PODClassPtr) aCPODData fromSPODMesh: (PODStructPtr) aSPODMesh {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	CPODData* pcd = (CPODData*)aCPODData;
	if ( (self = [super initFromCPODData: aCPODData fromSPODMesh: aSPODMesh]) ) {
		self.elementCount = [self vertexCountFromFaceCount: psm->nNumFaces];
		self.elements = pcd->pData;
		elementsAreRetained = YES;	// CC3VertexIndices instance will free data when needed.
		pcd->pData = NULL;			// Clear data reference from CPODData so it won't try to free it.
		self.elementOffset = 0;		// Indices are not interleaved.
	}
	return self;
}

@end



