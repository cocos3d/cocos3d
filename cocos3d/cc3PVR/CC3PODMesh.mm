/*
 * CC3PODMesh.mm
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
 * See header file CC3PODMesh.h for full API documentation.
 */

#import "CC3PODMesh.h"
#import "CC3PVRTModelPOD.h"
#import "CC3VertexArraysPODExtensions.h"


#pragma mark CC3Mesh extensions for PVR POD data

@implementation CC3Mesh (PVRPOD)

-(id) initAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		SPODMesh* psm = (SPODMesh*)[aPODRez meshPODStructAtIndex: aPODIndex];
		LogRez(@"Creating %@ at index %i from: %@", [self class], aPODIndex, NSStringFromSPODMesh(psm));
		
		self.vertexLocations = [CC3VertexLocations arrayFromCPODData: &psm->sVertex fromSPODMesh: psm];
		self.vertexNormals = [CC3VertexNormals arrayFromCPODData: &psm->sNormals fromSPODMesh: psm];
		self.vertexTangents = [CC3VertexTangents arrayFromCPODData: &psm->sTangents fromSPODMesh: psm];
		self.vertexBitangents = [CC3VertexTangents arrayFromCPODData: &psm->sBinormals fromSPODMesh: psm];
		self.vertexColors = [CC3VertexColors arrayFromCPODData: &psm->sVtxColours fromSPODMesh: psm];
		self.vertexBoneWeights = [CC3VertexBoneWeights arrayFromCPODData: &psm->sBoneWeight fromSPODMesh: psm];
		self.vertexBoneIndices = [CC3VertexBoneIndices arrayFromCPODData: &psm->sBoneIdx fromSPODMesh: psm];
		
		for (GLuint i = 0; i < psm->nNumUVW; i++) {
			CC3VertexTextureCoordinates* texCoords;
			texCoords = [CC3VertexTextureCoordinates arrayFromSPODMesh: psm forTextureUnit: i];
			texCoords.expectsVerticallyFlippedTextures = aPODRez.expectsVerticallyFlippedTextures;
			[self addTextureCoordinates: texCoords];
		}
		
		self.vertexIndices = [CC3VertexIndices arrayFromCPODData: &psm->sFaces fromSPODMesh: psm];
		
		// Once all vertex arrays are populated, if the data is interleaved, mark it as such and
		// swap the reference to the original data within the SPODMesh, so that CC3VertexArray
		// can take over responsibility for managing the data memory allocated by CPVRTModelPOD.
		// This allows CC3VertexArray to release the vertex data from memory once it has been bound
		// to a GL buffer in the graphics hardware, and allows the CPVRTModelPOD to be released
		// from memory without it removing the vertex data in the process. We can't just NULL the
		// interleaved pointer reference, because a NULL indicates to CPVRTModelPOD that the data
		// is contained within the individual vertex arrays, and it will try to free those instead.
		// So, we create a "dummy" memory allocation for CPVRTModelPOD to free when it needs to.
		// The original pointer is now being managed by the CC3VertexLocations instance.
		if (psm->pInterleaved != NULL) {
			_shouldInterleaveVertices = YES;
			psm->pInterleaved = (PVRTuint8*)calloc(1, sizeof(PVRTuint8));
		} else {
			_shouldInterleaveVertices = NO;
		}
		
	}
	return self;
}

+(id) meshAtIndex: (GLint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [[[self alloc] initAtIndex: aPODIndex fromPODResource: aPODRez] autorelease];
}

@end


#pragma mark CC3PODMesh

@implementation CC3PODMesh

-(GLint) podIndex { return _podIndex; }

-(void) setPodIndex: (GLint) aPODIndex { _podIndex = aPODIndex; }

-(void) populateFrom: (CC3PODMesh*) another {
	[super populateFrom: another];
	
	_podIndex = another.podIndex;
}

// Deprecated texture inversion. When this is invoked on a POD mesh, it does need inversion.
-(void) deprecatedAlign: (CC3VertexTextureCoordinates*) texCoords
	withInvertedTexture: (CC3Texture*) aTexture {
	[texCoords flipVertically];		// Avoid switching expectsVerticallyFlippedTextures
}

@end
