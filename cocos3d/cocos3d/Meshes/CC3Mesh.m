/*
 * CC3Mesh.m
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
 * 
 * See header file CC3Mesh.h for full API documentation.
 */

#import "CC3Mesh.h"

@interface CC3Mesh (TemplateMethods)
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor;
-(CC3FaceIndices) uncachedFaceIndicesAt: (GLuint) faceIndex;
-(BOOL) switchingMesh;
@end

@implementation CC3Mesh

@synthesize faces;

-(void) dealloc {
	[faces release];
	[super dealloc];
}

-(NSString*) nameSuffix { return @"Mesh"; }

-(BOOL) hasVertexLocations { return NO; }

-(BOOL) hasVertexNormals { return NO; }

-(BOOL) hasVertexColors { return NO; }

-(GLenum) vertexColorType { return GL_FALSE; }

-(BOOL) hasVertexTextureCoordinates { return NO; }

-(BOOL) hasVertexIndices { return NO; }

// Deprecated
-(BOOL) hasNormals { return self.hasVertexNormals; }
-(BOOL) hasColors { return self.hasVertexColors; }


-(CC3BoundingBox) boundingBox { return kCC3BoundingBoxNull; }

-(CC3Vector) centerOfGeometry {
	CC3BoundingBox bb = self.boundingBox;
	return CC3BoundingBoxIsNull(bb) ? kCC3VectorZero : CC3BoundingBoxCenter(bb);
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		faces = nil;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Mesh*) another {
	[super populateFrom: another];
	
	self.faces = another.faces;				// retained but not copied
}

+(id) mesh { return [[[self alloc] init] autorelease]; }

+(id) meshWithTag: (GLuint) aTag { return [[[self alloc] initWithTag: aTag] autorelease]; }

+(id) meshWithName: (NSString*) aName { return [[[self alloc] initWithName: aName] autorelease]; }

+(id) meshWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}


#pragma mark CCRGBAProtocol support

-(ccColor3B) color { return ccBLACK; }

-(void) setColor: (ccColor3B) aColor {}

-(GLubyte) opacity { return 0; }

-(void) setOpacity: (GLubyte) opacity {}


#pragma mark Vertex management

-(CC3VertexContent) vertexContentTypes { return kCC3VertexContentNone; }
-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {}

-(BOOL) shouldInterleaveVertices { return NO; }
-(void) setShouldInterleaveVertices: (BOOL) shouldInterleave {}

-(void) createGLBuffers {}

-(void) deleteGLBuffers {}

-(BOOL) isUsingGLBuffers { return NO; }

-(void) releaseRedundantData {}

-(void) retainVertexContent {}

-(void) retainVertexLocations {}

-(void) retainVertexNormals {}

-(void) retainVertexColors {}

-(void) retainVertexTextureCoordinates {}

-(void) retainVertexIndices {}

-(void) doNotBufferVertexContent {}

-(void) doNotBufferVertexLocations {}

-(void) doNotBufferVertexNormals {}

-(void) doNotBufferVertexColors {}

-(void) doNotBufferVertexTextureCoordinates {}

-(void) doNotBufferVertexIndices {}


#pragma mark Texture coordinates

-(BOOL) expectsVerticallyFlippedTextures { return YES; }

-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {}

-(BOOL) expectsVerticallyFlippedTextureInTextureUnit: (GLuint) texUnit { return YES; }

-(void) expectsVerticallyFlippedTexture: (BOOL) expectsFlipped inTextureUnit: (GLuint) texUnit {}

-(void) alignTextureUnit: (GLuint) texUnit withTexture: (CC3Texture*) aTexture {}

-(void) flipVerticallyTextureUnit: (GLuint) texUnit {}

-(void) flipTexturesVertically {}

-(void) flipHorizontallyTextureUnit: (GLuint) texUnit {}

-(void) flipTexturesHorizontally {}

-(void) repeatTexture: (ccTex2F) repeatFactor forTextureUnit: (GLuint) texUnit {}

-(void) repeatTexture: (ccTex2F) repeatFactor {}

-(CGRect) textureRectangle { return CGRectNull; }

-(void) setTextureRectangle: (CGRect) aRect {}

-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit { return CGRectNull; }

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {}

// Deprecated - delegate to protected method so it can be invoked from other deprecated library methods.
-(void) deprecatedAlignWithTexturesIn: (CC3Material*) aMaterial {}
-(void) alignWithTexturesIn: (CC3Material*) aMaterial {
	[self deprecatedAlignWithTexturesIn: aMaterial];
}

// Deprecated - delegate to protected method so it can be invoked from other deprecated library methods.
-(void) deprecatedAlignWithInvertedTexturesIn: (CC3Material*) aMaterial {}
-(void) alignWithInvertedTexturesIn: (CC3Material*) aMaterial {
	[self deprecatedAlignWithInvertedTexturesIn: aMaterial];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Meshs.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedMeshTag;

-(GLuint) nextTag {
	return ++lastAssignedMeshTag;
}

+(void) resetTagAllocation {
	lastAssignedMeshTag = 0;
}


#pragma mark Drawing

-(GLenum) drawingMode { return GL_TRIANGLE_STRIP; }

-(void) setDrawingMode: (GLenum) aMode {}

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.switchingMesh) {
		[self bindGLWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
	[self drawVerticesWithVisitor: visitor];
}

-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.switchingMesh) {
		[self bindGLWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
	[self drawVerticesFrom: vertexIndex forCount: vertexCount withVisitor: visitor];
}

/**
 * Template method that binds the mesh arrays to the GL engine prior to drawing.
 * The specified visitor encapsulates the frustum of the currently active camera,
 * and certain drawing options.
 *
 * This method does not create GL buffers, which are created with the createGLBuffers method.
 * This method binds the buffer or data pointers to the GL engine, prior to each draw call.
 */
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

/** 
 * Draws the mesh vertices to the GL engine.
 * Default implementation does nothing. Subclasses will override.
 */
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

/** 
 * Draws a portion of the mesh vertices to the GL engine.
 * Default implementation does nothing. Subclasses will override.
 */
-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(CC3NodeBoundingVolume*) defaultBoundingVolume { return nil; }


#pragma mark Accessing vertex data

-(void) moveMeshOriginTo: (CC3Vector) aLocation {}

-(void) moveMeshOriginToCenterOfGeometry {}

// Deprecated methods
-(void) movePivotTo: (CC3Vector) aLocation { [self moveMeshOriginTo: aLocation]; }
-(void) movePivotToCenterOfGeometry { [self moveMeshOriginToCenterOfGeometry]; }

-(BOOL) ensureCapacity: (GLuint) vtxCount { return NO; }

-(GLuint) vertexCount { return 0; }

-(void) setVertexCount: (GLuint) vCount {}

-(GLuint) vertexIndexCount { return 0; }

-(void) setVertexIndexCount: (GLuint) vCount {}

-(CC3Vector) vertexLocationAt: (GLuint) index { return kCC3VectorZero; }

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index {}

-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index { return kCC3Vector4ZeroLocation; }

-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index {}

-(CC3Vector) vertexNormalAt: (GLuint) index { return kCC3VectorZero; }

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index {}

-(ccColor4F) vertexColor4FAt: (GLuint) index { return kCCC4FBlackTransparent; }

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index {}

-(ccColor4B) vertexColor4BAt: (GLuint) index { return (ccColor4B){ 0, 0, 0, 0 }; }

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index {}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index {
	return (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index {}

-(ccTex2F) vertexTexCoord2FAt: (GLuint) index {
	return [self vertexTexCoord2FForTextureUnit: 0 at: index];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: 0 at: index];
}

// Deprecated
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index forTextureUnit: (GLuint) texUnit {
	return [self vertexTexCoord2FForTextureUnit: texUnit at: index];
}

// Deprecated
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index forTextureUnit: (GLuint) texUnit {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
}

-(GLuint) vertexIndexAt: (GLuint) index { return 0; }

-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index {}

-(void) updateVertexLocationsGLBuffer {}

-(void) updateVertexNormalsGLBuffer {}

-(void) updateVertexColorsGLBuffer {}

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {}

-(void) updateVertexTextureCoordinatesGLBuffer {
	[self updateVertexTextureCoordinatesGLBufferForTextureUnit: 0];
}

-(void) updateVertexIndicesGLBuffer {}

-(void) updateGLBuffers {}


#pragma mark Faces

-(CC3FaceArray*) faces {
	if ( !faces ) {
		NSString* facesName = [NSString stringWithFormat: @"%@-Faces", self.name];
		self.faces = [CC3FaceArray faceArrayWithName: facesName];
	}
	return faces;
}

-(void) setFaces: (CC3FaceArray*) aFaceArray {
	id old = faces;
	faces = [aFaceArray retain];
	[old release];
	faces.mesh = self;
}

-(BOOL) shouldCacheFaces { return faces ? faces.shouldCacheFaces : NO; }

-(void) setShouldCacheFaces: (BOOL) shouldCache { self.faces.shouldCacheFaces = shouldCache; }

-(GLuint) faceCount { return 0; }

-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc { return 0; }

-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc { return 0; }

// Deprecated
-(GLuint) faceCountFromVertexCount: (GLuint) vc { return [self faceCountFromVertexIndexCount: vc]; }
-(GLuint) vertexCountFromFaceCount: (GLuint) fc { return [self vertexIndexCountFromFaceCount: fc]; }

-(CC3Face) faceAt: (GLuint) faceIndex {
	return [self faceFromIndices: [self faceIndicesAt: faceIndex]];
}

-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices { return kCC3FaceZero; }

-(CC3FaceIndices) uncachedFaceIndicesAt: (GLuint) faceIndex { return kCC3FaceIndicesZero; }

-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex {
	return [self.faces indicesAt: faceIndex];
}

-(CC3Vector) faceCenterAt: (GLuint) faceIndex {
	return [self.faces centerAt: faceIndex];
}

-(CC3Vector) faceNormalAt: (GLuint) faceIndex {
	return [self.faces normalAt: faceIndex];
}

-(CC3Plane) facePlaneAt: (GLuint) faceIndex {
	return [self.faces planeAt: faceIndex];
}

-(CC3FaceNeighbours) faceNeighboursAt: (GLuint) faceIndex {
	return [self.faces neighboursAt: faceIndex];
}

-(GLuint) findFirst: (GLuint) maxHitCount
	  intersections: (CC3MeshIntersection*) intersections
		 ofLocalRay: (CC3Ray) aRay
	acceptBackFaces: (BOOL) acceptBackFaces
	acceptBehindRay: (BOOL) acceptBehind {
	
	GLuint hitIdx = 0;
	GLuint faceCount = self.faceCount;
	for (int faceIdx = 0; faceIdx < faceCount && hitIdx < maxHitCount; faceIdx++) {
		CC3MeshIntersection* hit = &intersections[hitIdx];
		hit->faceIndex = faceIdx;
		hit->face = [self faceAt: faceIdx];
		hit->facePlane = CC3FacePlane(hit->face);

		// Check if the ray is not parallel to the face, is approaching from the front,
		// or is approaching from the back and that is okay.
		GLfloat dirDotNorm = CC3VectorDot(aRay.direction, CC3PlaneNormal(hit->facePlane));
		hit->wasBackFace = dirDotNorm > 0.0f;
		if (dirDotNorm < 0.0f || (hit->wasBackFace && acceptBackFaces)) {

			// Find the point of intersection of the ray with the plane
			// and check that it is not behind the start of the ray.
			CC3Vector4 loc4 = CC3RayIntersectionWithPlane(aRay, hit->facePlane);
			if (acceptBehind || loc4.w >= 0.0f) {
				hit->location = CC3VectorFromTruncatedCC3Vector4(loc4);
				hit->distance = loc4.w;
				hit->barycentricLocation = CC3FaceBarycentricWeights(hit->face, hit->location);
				if ( CC3BarycentricWeightsAreInsideTriangle(hit->barycentricLocation) ) hitIdx++;
			}
		}
	}
	return hitIdx;
}


#pragma mark Mesh context switching

// The tag of the mesh that was most recently drawn to the GL engine.
// The GL engine is only updated when a mesh with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same mesh are drawn together, to minimize context switching within the GL engine.
static GLuint currentMeshTag = 0;

/**
 * Returns whether this mesh is different than the mesh that was most recently
 * drawn to the GL engine. To improve performance, meshes are only bound if they need to be.
 *
 * If appropriate, the application can arrange CC3MeshNodes in the CC3Scene so that nodes
 * using the same mesh are drawn together, to minimize the number of mesh binding
 * changes in the GL engine.
 *
 * This method is invoked automatically by the draw method to test whether this mesh needs
 * to be bound to the GL engine before drawing.
 */
-(BOOL) switchingMesh {
	BOOL shouldSwitch = currentMeshTag != tag;
	currentMeshTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentMeshTag = 0;
}

@end


#pragma mark -
#pragma mark CC3FaceArray

@implementation CC3FaceArray

@synthesize mesh, shouldCacheFaces;

-(void) dealloc {
	mesh = nil;					// not retained
	[self deallocateIndices];
	[self deallocateCenters];
	[self deallocateNormals];
	[self deallocatePlanes];
	[self deallocateNeighbours];
	[super dealloc];
}

/**
 * Clears all caches so that they will be lazily initialized
 * on next access using the new mesh data.
 */
-(void) setMesh: (CC3Mesh*) aMesh {
	mesh = aMesh;		// not retained
	[self deallocateIndices];
	[self deallocateCenters];
	[self deallocateNormals];
	[self deallocatePlanes];
	[self deallocateNeighbours];
}

/** If turning off, clears all caches except neighbours. */
-(void) setShouldCacheFaces: (BOOL) shouldCache {
	shouldCacheFaces = shouldCache;
	if (!shouldCacheFaces) {
		[self deallocateIndices];
		[self deallocateCenters];
		[self deallocateNormals];
		[self deallocatePlanes];
	}
}

-(GLuint) faceCount { return mesh ? mesh.faceCount : 0;}

-(CC3Face) faceAt: (GLuint) faceIndex {
	return mesh ? [mesh faceAt: faceIndex] : kCC3FaceZero;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		mesh = nil;
		shouldCacheFaces = NO;
		indices = NULL;
		indicesAreRetained = NO;
		indicesAreDirty = YES;
		centers = NULL;
		centersAreRetained = NO;
		centersAreDirty = YES;
		normals = NULL;
		normalsAreRetained = NO;
		normalsAreDirty = YES;
		planes = NULL;
		planesAreRetained = NO;
		planesAreDirty = YES;
		neighbours = NULL;
		neighboursAreRetained = NO;
		neighboursAreDirty = YES;
	}
	return self;
}

+(id) faceArray {
	return [[[self alloc] init] autorelease];
}

+(id) faceArrayWithTag: (GLuint) aTag {
	return [[[self alloc] initWithTag: aTag] autorelease];
}

+(id) faceArrayWithName: (NSString*) aName {
	return [[[self alloc] initWithName: aName] autorelease];
}

+(id) faceArrayWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

// Phantom properties used during copying
-(BOOL) indicesAreRetained { return indicesAreRetained; }
-(BOOL) centersAreRetained { return centersAreRetained; }
-(BOOL) normalsAreRetained { return normalsAreRetained; }
-(BOOL) planesAreRetained { return planesAreRetained; }
-(BOOL) neighboursAreRetained { return neighboursAreRetained; }

-(BOOL) indicesAreDirty { return indicesAreDirty; }
-(BOOL) centersAreDirty { return centersAreDirty; }
-(BOOL) normalsAreDirty { return normalsAreDirty; }
-(BOOL) planesAreDirty { return planesAreDirty; }
-(BOOL) neighboursAreDirty { return neighboursAreDirty; }


// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3FaceArray*) another {
	[super populateFrom: another];
	
	mesh = another.mesh;		// not retained
	
	shouldCacheFaces = another.shouldCacheFaces;
	
	// If indices should be retained, allocate memory and copy the data over.
	[self deallocateIndices];
	if (another.indicesAreRetained) {
		[self allocateIndices];
		memcpy(indices, another.indices, (self.faceCount * sizeof(CC3FaceIndices)));
	} else {
		indices = another.indices;
	}
	indicesAreDirty = another.indicesAreDirty;
	
	// If centers should be retained, allocate memory and copy the data over.
	[self deallocateCenters];
	if (another.centersAreRetained) {
		[self allocateCenters];
		memcpy(centers, another.centers, (self.faceCount * sizeof(CC3Vector)));
	} else {
		centers = another.centers;
	}
	centersAreDirty = another.centersAreDirty;
	
	// If normals should be retained, allocate memory and copy the data over.
	[self deallocateNormals];
	if (another.normalsAreRetained) {
		[self allocateNormals];
		memcpy(normals, another.normals, (self.faceCount * sizeof(CC3Vector)));
	} else {
		normals = another.normals;
	}
	normalsAreDirty = another.normalsAreDirty;
	
	// If planes should be retained, allocate memory and copy the data over.
	[self deallocatePlanes];
	if (another.planesAreRetained) {
		[self allocatePlanes];
		memcpy(planes, another.planes, (self.faceCount * sizeof(CC3Plane)));
	} else {
		planes = another.planes;
	}
	planesAreDirty = another.planesAreDirty;
	
	// If neighbours should be retained, allocate memory and copy the data over.
	[self deallocateNeighbours];
	if (another.neighboursAreRetained) {
		[self allocateNeighbours];
		memcpy(neighbours, another.neighbours, (self.faceCount * sizeof(CC3FaceNeighbours)));
	} else {
		neighbours = another.neighbours;
	}
	neighboursAreDirty = another.neighboursAreDirty;
}


#pragma mark Indices

-(CC3FaceIndices*) indices {
	if (indicesAreDirty || !indices) {
		[self populateIndices];
	}
	return indices;
}

-(void) setIndices: (CC3FaceIndices*) faceIndices {
	[self deallocateIndices];			// Safely disposes existing vertices
	indices = faceIndices;
}

-(CC3FaceIndices) uncachedIndicesAt: (GLuint) faceIndex {
	return [mesh uncachedFaceIndicesAt: faceIndex];
}

-(CC3FaceIndices) indicesAt: (GLuint) faceIndex {
	if (shouldCacheFaces) {
		return self.indices[faceIndex];
	}
	return [self uncachedIndicesAt: faceIndex];
}

-(CC3FaceIndices*) allocateIndices {
	[self deallocateIndices];
	GLuint faceCount = self.faceCount;
	if (faceCount) {
		indices = calloc(faceCount, sizeof(CC3FaceIndices));
		indicesAreRetained = YES;
		LogTrace(@"%@ allocated space for %u face indices", self, faceCount);
	}
	return indices;
}

-(void) deallocateIndices {
	if (indicesAreRetained && indices) {
		free(indices);
		indices = NULL;
		indicesAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated indices", self, self.faceCount);
	}
}

-(void) populateIndices {
	LogTrace(@"%@ populating %u face indices", self, self.faceCount);
	if ( !indices ) [self allocateIndices];
	
	GLuint faceCount = self.faceCount;
	for (int faceIdx = 0; faceIdx < faceCount; faceIdx++) {
		indices[faceIdx] = [self uncachedIndicesAt: faceIdx];
		
		LogTrace(@"Face %i has indices %@", faceIdx,
					  NSStringFromCC3FaceIndices(indices[faceIdx]));
	}
	indicesAreDirty = NO;
}

-(void) markIndicesDirty { indicesAreDirty = YES; }


#pragma mark Centers

-(CC3Vector*) centers {
	if (centersAreDirty || !centers) {
		[self populateCenters];
	}
	return centers;
}

-(void) setCenters: (CC3Vector*) faceCenters {
	[self deallocateCenters];			// Safely disposes existing vertices
	centers = faceCenters;
}

-(CC3Vector) centerAt: (GLuint) faceIndex {
	if (shouldCacheFaces) {
		return self.centers[faceIndex];
	}
	return CC3FaceCenter([self faceAt: faceIndex]);
}

-(CC3Vector*) allocateCenters {
	[self deallocateCenters];
	GLuint faceCount = self.faceCount;
	if (faceCount) {
		centers = calloc(faceCount, sizeof(CC3Vector));
		centersAreRetained = YES;
		LogTrace(@"%@ allocated space for %u face centers", self, faceCount);
	}
	return centers;
}

-(void) deallocateCenters {
	if (centersAreRetained && centers) {
		free(centers);
		centers = NULL;
		centersAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated centers", self, self.faceCount);
	}
}

-(void) populateCenters {
	LogTrace(@"%@ populating %u face centers", self, self.faceCount);
	if ( !centers ) [self allocateCenters];
	
	GLuint faceCount = self.faceCount;
	for (int faceIdx = 0; faceIdx < faceCount; faceIdx++) {
		centers[faceIdx] = CC3FaceCenter([self faceAt: faceIdx]);

		LogTrace(@"Face %i has vertices %@ and center %@", faceIdx,
					  NSStringFromCC3Face([self faceAt: faceIdx]),
					  NSStringFromCC3Vector(centers[faceIdx]));
	}
	centersAreDirty = NO;
}

-(void) markCentersDirty { centersAreDirty = YES; }


#pragma mark Normals

-(CC3Vector*) normals {
	if (normalsAreDirty || !normals) {
		[self populateNormals];
	}
	return normals;
}

-(void) setNormals: (CC3Vector*) faceNormals {
	[self deallocateNormals];			// Safely disposes existing vertices
	normals = faceNormals;
}

-(CC3Vector) normalAt: (GLuint) faceIndex {
	if (shouldCacheFaces) {
		return self.normals[faceIndex];
	}
	return CC3FaceNormal([self faceAt: faceIndex]);
}

-(CC3Vector*) allocateNormals {
	[self deallocateNormals];
	GLuint faceCount = self.faceCount;
	if (faceCount) {
		normals = calloc(faceCount, sizeof(CC3Vector));
		normalsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u face normals", self, faceCount);
	}
	return normals;
}

-(void) deallocateNormals {
	if (normalsAreRetained && normals) {
		free(normals);
		normals = NULL;
		normalsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated normals", self, self.faceCount);
	}
}

-(void) populateNormals {
	LogTrace(@"%@ populating %u face normals", self, self.faceCount);
	if ( !normals ) [self allocateNormals];
	
	GLuint faceCount = self.faceCount;
	for (int faceIdx = 0; faceIdx < faceCount; faceIdx++) {
		normals[faceIdx] = CC3FaceNormal([self faceAt: faceIdx]);
		
		LogTrace(@"Face %i has vertices %@ and normal %@", faceIdx,
					  NSStringFromCC3Face([self faceAt: faceIdx]),
					  NSStringFromCC3Vector(normals[faceIdx]));
	}
	normalsAreDirty = NO;
}

-(void) markNormalsDirty { normalsAreDirty = YES; }


#pragma mark Planes

-(CC3Plane*) planes {
	if (planesAreDirty || !planes) {
		[self populatePlanes];
	}
	return planes;
}

-(void) setPlanes: (CC3Plane*) facePlanes {
	[self deallocatePlanes];			// Safely disposes existing vertices
	planes = facePlanes;
}

-(CC3Plane) planeAt: (GLuint) faceIndex {
	if (shouldCacheFaces) {
		return self.planes[faceIndex];
	}
	return CC3FacePlane([self faceAt: faceIndex]);
}

-(CC3Plane*) allocatePlanes {
	[self deallocatePlanes];
	GLuint faceCount = self.faceCount;
	if (faceCount) {
		planes = calloc(faceCount, sizeof(CC3Plane));
		planesAreRetained = YES;
		LogTrace(@"%@ allocated space for %u face planes", self, faceCount);
	}
	return planes;
}

-(void) deallocatePlanes {
	if (planesAreRetained && planes) {
		free(planes);
		planes = NULL;
		planesAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated planes", self, self.faceCount);
	}
}

-(void) populatePlanes {
	LogTrace(@"%@ populating %u face planes", self, self.faceCount);
	if ( !planes ) [self allocatePlanes];
	
	GLuint faceCount = self.faceCount;
	for (int faceIdx = 0; faceIdx < faceCount; faceIdx++) {
		planes[faceIdx] = CC3FacePlane([self faceAt: faceIdx]);
		
		LogTrace(@"Face %i has vertices %@ and plane %@", faceIdx,
					  NSStringFromCC3Face([self faceAt: faceIdx]),
					  NSStringFromCC3Plane(planes[faceIdx]));
	}
	planesAreDirty = NO;
}

-(void) markPlanesDirty { planesAreDirty = YES; }


#pragma mark Neighbours

-(CC3FaceNeighbours*) neighbours {
	if (neighboursAreDirty || !neighbours) {
		[self populateNeighbours];
	}
	return neighbours;
}

-(void) setNeighbours: (CC3FaceNeighbours*) faceNeighbours {
	[self deallocateNeighbours];		// Safely disposes existing vertices
	neighbours = faceNeighbours;
}

-(CC3FaceNeighbours) neighboursAt: (GLuint) faceIndex {
	return self.neighbours[faceIndex];
}

-(CC3FaceNeighbours*) allocateNeighbours {
	[self deallocateNeighbours];
	GLuint faceCount = self.faceCount;
	if (faceCount) {
		neighbours = calloc(faceCount, sizeof(CC3FaceNeighbours));
		neighboursAreRetained = YES;
		LogTrace(@"%@ allocated space for %u face neighbours", self, faceCount);
	}
	return neighbours;
}

-(void) deallocateNeighbours {
	if (neighboursAreRetained && neighbours) {
		free(neighbours);
		neighbours = NULL;
		neighboursAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated neighbour structures", self, self.faceCount);
	}
}

-(void) populateNeighbours {
	LogTrace(@"%@ populating neighbours for %u faces", self, self.faceCount);
	if ( !neighbours ) [self allocateNeighbours];
	
	GLuint faceCnt = self.faceCount;
	
	// Break all neighbour links. Done in batch so that we can skip
	// testing neighbour connections from both directions later.
	for (int faceIdx = 0; faceIdx < faceCnt; faceIdx++) {
		GLuint* neighbourEdge = neighbours[faceIdx].edges;
		neighbourEdge[0] = neighbourEdge[1] = neighbourEdge[2] = kCC3FaceNoNeighbour;
	}
	
	// Iterate through all the faces
	for (int f1Idx = 0; f1Idx < faceCnt; f1Idx++) {

		// Get the neighbours of the current face, and if any of the edges still
		// need to have a neighbour assigned, look for them. We check this early
		// to avoid iterating through the remaining faces
		GLuint* f1Neighbours = neighbours[f1Idx].edges;
		if (f1Neighbours[0] == kCC3FaceNoNeighbour ||
			f1Neighbours[1] == kCC3FaceNoNeighbour ||
			f1Neighbours[2] == kCC3FaceNoNeighbour) {

			// For the current face, retrieve the vertex indices
			GLuint* f1Vertices = [mesh faceIndicesAt: f1Idx].vertices;
			
			// Iterate through all the faces beyond the current face
			for (int f2Idx = f1Idx + 1; f2Idx < faceCnt; f2Idx++) {

				// Get the neighbours of the other face, and if any of the edges still
				// need to have a neighbour assigned, see if any of the edges between
				// the current face and other face match. We check for neighbours early
				// to avoid iterating through all the face combinations.
				GLuint* f2Neighbours = neighbours[f2Idx].edges;
				if (f2Neighbours[0] == kCC3FaceNoNeighbour ||
					f2Neighbours[1] == kCC3FaceNoNeighbour ||
					f2Neighbours[2] == kCC3FaceNoNeighbour) {
				
					// For the other face, retrieve the vertex indices
					GLuint* f2Vertices = [mesh faceIndicesAt: f2Idx].vertices;
					
					// Compare each edge of the current face with each edge of the other face
					for (int f1EdgeIdx = 0; f1EdgeIdx < 3; f1EdgeIdx++) {
						
						// If this edge already has a neighbour, skip it
						if (f1Neighbours[f1EdgeIdx] == (GLuint)kCC3FaceNoNeighbour) {
							
							// Get the end points of an edge of the current face
							GLuint f1EdgeStart = f1Vertices[f1EdgeIdx];
							GLuint f1EdgeEnd = f1Vertices[(f1EdgeIdx < 2) ? (f1EdgeIdx + 1) : 0];
							
							// Iterate each edge of other face and compare against current face edge
							for (int f2EdgeIdx = 0; f2EdgeIdx < 3; f2EdgeIdx++) {
								
								// If this edge already has a neighbour, skip it
								if (f2Neighbours[f2EdgeIdx] == (GLuint)kCC3FaceNoNeighbour) {
									
									// Get the end points of an edge of the other face
									GLuint f2EdgeStart = f2Vertices[f2EdgeIdx];
									GLuint f2EdgeEnd = f2Vertices[(f2EdgeIdx < 2) ? (f2EdgeIdx + 1) : 0];
									
									// If the two edges have the same endpoints, mark each as a neighbour of the other
									if ((f1EdgeStart == f2EdgeStart && f1EdgeEnd == f2EdgeEnd) ||
										(f1EdgeStart == f2EdgeEnd && f1EdgeEnd == f2EdgeStart) ){
										f1Neighbours[f1EdgeIdx] = f2Idx;
										f2Neighbours[f2EdgeIdx] = f1Idx;
										LogTrace(@"Matched face %@ with face %@",
													  NSStringFromCC3FaceIndices(f1Indices),
													  NSStringFromCC3FaceIndices(f2Indices));
									}
								}
							}
						}
					}
				}
			}
			LogTrace(@"Face %i has indices %@ and neighbours %@", f1Idx,
						  NSStringFromCC3FaceIndices([mesh faceIndicesAt: f1Idx]),
						  NSStringFromCC3FaceNeighbours(neighbours[f1Idx]));
		}
		
	}
	neighboursAreDirty = NO;
	LogTrace(@"%@ finished building neighbours", self);
}

-(void) markNeighboursDirty { neighboursAreDirty = YES; }

@end
