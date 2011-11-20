/*
 * CC3VertexArrayMesh.m
 *
 * cocos3d 0.6.4
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
 * See header file CC3VertexArrayMesh.h for full API documentation.
 */

#import "CC3VertexArrayMesh.h"
#import "CC3MeshNode.h"
#import "CC3OpenGLES11Engine.h"

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

@interface CC3VertexArrayMesh (TemplateMethods)
-(void) bindLocationsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindNormalsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindColorsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindTextureCoordinatesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindPointSizesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindBoneMatrixIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindBoneWeightsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end


@implementation CC3VertexArrayMesh

@synthesize vertexLocations, vertexNormals, vertexColors, vertexTextureCoordinates;
@synthesize vertexIndices, interleaveVertices;

-(void) dealloc {
	[vertexLocations release];
	[vertexNormals release];
	[vertexColors release];
	[vertexTextureCoordinates release];
	[overlayTextureCoordinates release];
	[vertexIndices release];
	[super dealloc];
}

-(BOOL) hasNormals {
	return (vertexNormals != nil);
}

-(BOOL) hasColors {
	return (vertexColors != nil);
}

/**
 * Returns the boundingBox from the vertexLocation array.
 * If no vertexLocation array has been set, returns a null bounding box.
 */
-(CC3BoundingBox) boundingBox {
	return vertexLocations ? vertexLocations.boundingBox : [super boundingBox];
}


#pragma mark Texture coordinates

-(GLuint) textureCoordinatesArrayCount {
	return (overlayTextureCoordinates ? overlayTextureCoordinates.count : 0) + (vertexTextureCoordinates ? 1 : 0);
}

-(void) addTextureCoordinates: (CC3VertexTextureCoordinates*) aTexCoord {
	NSAssert(aTexCoord, @"Overlay texture cannot be nil");
	NSAssert1(!overlayTextureCoordinates || ((overlayTextureCoordinates.count + 1) <
											 [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value),
			  @"Too many overlaid textures. This platform only supports %i texture units.",
			  [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value);
	LogTrace(@"Adding %@ to %@", aTexCoord, self);
	
	// Set the first texture coordinates into vertexTextureCoordinates
	if (!vertexTextureCoordinates) {
		self.vertexTextureCoordinates = aTexCoord;
	} else {
		// Add subsequent texture coordinate arrays to the array of overlayTextureCoordinates,
		// creating it first if necessary
		if(!overlayTextureCoordinates) {
			overlayTextureCoordinates = [[CCArray array] retain];
		}
		[overlayTextureCoordinates addObject: aTexCoord];
	}
}

-(void) removeTextureCoordinates: (CC3VertexTextureCoordinates*) aTexCoord {
	LogTrace(@"Removing %@ from %@", aTexCoord, self);
	
	// If the array to be removed is actually the vertexTextureCoordinates, remove it
	if (vertexTextureCoordinates == aTexCoord) {
		self.vertexTextureCoordinates = nil;
	} else {
		// Otherwise, find it in the array of overlays and remove it,
		// and remove the overlay array if it is now empty
		if (overlayTextureCoordinates && aTexCoord) {
			[overlayTextureCoordinates removeObjectIdenticalTo: aTexCoord];
			if (overlayTextureCoordinates.count == 0) {
				[overlayTextureCoordinates release];
				overlayTextureCoordinates = nil;
			}
		}
	}
}

-(void) removeAllTextureCoordinates {
	// Remove the first texture coordinates
	self.vertexTextureCoordinates = nil;
	
	// Remove the overlay texture coordinates
	CCArray* myOTCs = [overlayTextureCoordinates copy];
	for (CC3VertexTextureCoordinates* otc in myOTCs) {
		[self removeTextureCoordinates: otc];
	}
	[myOTCs release];
}

-(CC3VertexTextureCoordinates*) getTextureCoordinatesNamed: (NSString*) aName {
	NSString* tcName;
	
	// First check if the first texture coordinates is the one
	if (vertexTextureCoordinates) {
		tcName = vertexTextureCoordinates.name;
		if ([tcName isEqual: aName] || (!tcName && !aName)) {		// Name equal or both nil.
			return vertexTextureCoordinates;
		}
	}
	// Then look for it in the overlays array
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		tcName = otc.name;
		if ([tcName isEqual: aName] || (!tcName && !aName)) {		// Name equal or both nil.
			return otc;
		}
	}
	return nil;
}

-(CC3VertexTextureCoordinates*) textureCoordinatesForTextureUnit: (GLuint) texUnit {
	// If first texture unit, return vertexTextureCoordinates property
	if (texUnit == 0) {
		return vertexTextureCoordinates;
	} else {
		// Otherwise retrieve from overlay array
		return [overlayTextureCoordinates objectAtIndex: (texUnit - 1)];
	}
}

-(void) setTextureCoordinates: (CC3VertexTextureCoordinates *) aTexCoords
			   forTextureUnit: (GLuint) texUnit {
	NSAssert(aTexCoords, @"Overlay texture coordinates cannot be nil");
	if (texUnit == 0) {
		self.vertexTextureCoordinates = aTexCoords;
	} else if (texUnit < self.textureCoordinatesArrayCount) {
		[overlayTextureCoordinates replaceObjectAtIndex: (texUnit - 1) withObject: aTexCoords];
	} else {
		[self addTextureCoordinates: aTexCoords];
	}
}

-(void) alignWithTexturesIn: (CC3Material*) aMaterial {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint i = 0; i < tcCount; i++) {
		[[self textureCoordinatesForTextureUnit: i]
			alignWithTexture: [aMaterial textureForTextureUnit: i]];
	}
}

-(void) alignWithInvertedTexturesIn: (CC3Material*) aMaterial {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint i = 0; i < tcCount; i++) {
		[[self textureCoordinatesForTextureUnit: i]
			alignWithInvertedTexture: [aMaterial textureForTextureUnit: i]];
	}
}

-(void) repeatTexture: (ccTex2F) repeatFactor {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint i = 0; i < tcCount; i++) {
		[[self textureCoordinatesForTextureUnit: i] repeatTexture: repeatFactor];
	}
}

-(CGRect) textureRectangle {
	return [self textureRectangleForTextureUnit: 0];
}

-(void) setTextureRectangle: (CGRect) aRect {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint i = 0; i < tcCount; i++) {
		[self textureCoordinatesForTextureUnit: i].textureRectangle = aRect;
	}
}

-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	return texCoords ? texCoords.textureRectangle : kCC3UnitTextureRectangle;
}

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	texCoords.textureRectangle = aRect;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		interleaveVertices = NO;
		vertexLocations = nil;
		vertexNormals = nil;
		vertexColors = nil;
		vertexTextureCoordinates = nil;
		overlayTextureCoordinates = nil;
		vertexIndices = nil;
	}
	return self;
}

// Protected properties for copying
-(CCArray*) overlayTextureCoordinates { return overlayTextureCoordinates; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexArrayMesh*) another {
	[super populateFrom: another];

	// Share vertex arrays between copies
	self.vertexLocations = another.vertexLocations;						// retained but not copied
	self.vertexNormals = another.vertexNormals;							// retained but not copied
	self.vertexColors = another.vertexColors;							// retained but not copied
	self.vertexTextureCoordinates = another.vertexTextureCoordinates;	// retained but not copied
	
	// Remove any existing overlay textures and add the overlay textures from the other vertex array.
	[overlayTextureCoordinates removeAllObjects];
	CCArray* otherOTCs = another.overlayTextureCoordinates;
	if (otherOTCs) {
		for (CC3VertexTextureCoordinates* otc in otherOTCs) {
			[self addTextureCoordinates: [otc copyAutoreleased]];	// retained by collection
		}
	}

	self.vertexIndices = another.vertexIndices;							// retained
	interleaveVertices = another.interleaveVertices;
}

/**
 * If the interleavesVertices property is set to NO, creates GL vertex buffer objects for all
 * vertex arrays used by this mesh by invoking createGLBuffer on each contained vertex array.
 *
 * If the interleaveVertices property is set to YES, indicating that the underlying data is
 * shared across the contained vertex arrays, this method invokes createGLBuffer only on the
 * vertexLocations and vertexIndices vertex arrays, and copies the bufferID property from
 * the vertexLocations vertex array to the other vertex arrays (except vertexIndicies).
 */
-(void) createGLBuffers {
	[vertexLocations createGLBuffer];
	if (interleaveVertices) {
		GLuint commonBufferId = vertexLocations.bufferID;
		vertexNormals.bufferID = commonBufferId;
		vertexColors.bufferID = commonBufferId;
		vertexTextureCoordinates.bufferID = commonBufferId;
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			otc.bufferID = commonBufferId;
		}
	} else {
		[vertexNormals createGLBuffer];
		[vertexColors createGLBuffer];
		[vertexTextureCoordinates createGLBuffer];
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			[otc createGLBuffer];
		}
	}
	[vertexIndices createGLBuffer];
}

-(void) deleteGLBuffers {
	[vertexLocations deleteGLBuffer];
	[vertexNormals deleteGLBuffer];
	[vertexColors deleteGLBuffer];
	[vertexTextureCoordinates deleteGLBuffer];
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		[otc deleteGLBuffer];
	}
	[vertexIndices deleteGLBuffer];
}

-(void) releaseRedundantData {
	[vertexLocations releaseRedundantData];
	[vertexNormals releaseRedundantData];
	[vertexColors releaseRedundantData];
	[vertexTextureCoordinates releaseRedundantData];
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		[otc releaseRedundantData];
	}
	[vertexIndices releaseRedundantData];
}

-(void) retainVertexLocations {
	vertexLocations.shouldReleaseRedundantData = NO;
}

-(void) retainVertexNormals {
	vertexNormals.shouldReleaseRedundantData = NO;
}

-(void) retainVertexColors {
	vertexColors.shouldReleaseRedundantData = NO;
}

-(void) retainVertexTextureCoordinates {
	vertexTextureCoordinates.shouldReleaseRedundantData = NO;
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		otc.shouldReleaseRedundantData = NO;
	}
}

-(void) retainVertexIndices {
	vertexIndices.shouldReleaseRedundantData = NO;
}

-(void) doNotBufferVertexLocations {
	vertexLocations.shouldAllowVertexBuffering = NO;
}

-(void) doNotBufferVertexNormals {
	if (interleaveVertices) {
		[self doNotBufferVertexLocations];
	} else {
		vertexNormals.shouldAllowVertexBuffering = NO;
	}
}

-(void) doNotBufferVertexColors {
	if (interleaveVertices) {
		[self doNotBufferVertexLocations];
	} else {
		vertexColors.shouldAllowVertexBuffering = NO;
	}
}

-(void) doNotBufferVertexTextureCoordinates {
	if (interleaveVertices) {
		[self doNotBufferVertexLocations];
	} else {
		vertexTextureCoordinates.shouldAllowVertexBuffering = NO;
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			otc.shouldAllowVertexBuffering = NO;
		}
	}

}

-(void) doNotBufferVertexIndices {
	vertexIndices.shouldAllowVertexBuffering = NO;
}


#pragma mark Updating

-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLsizei) vertexCount {
	[vertexLocations updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
	if (!interleaveVertices) {
		[vertexNormals updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		[vertexColors updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		[vertexTextureCoordinates updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			[otc updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		}
	}
}

-(void) updateGLBuffers {
	[self updateGLBuffersStartingAt: 0 forLength: self.vertexCount];
}


#pragma mark Drawing

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Binding %@", self);
	[self bindLocationsWithVisitor: visitor];
	[self bindNormalsWithVisitor: visitor];
	[self bindColorsWithVisitor: visitor];
	[self bindTextureCoordinatesWithVisitor: visitor];
	[self bindPointSizesWithVisitor: visitor];
	[self bindIndicesWithVisitor: visitor];
	[self bindBoneMatrixIndicesWithVisitor: visitor];
	[self bindBoneWeightsWithVisitor: visitor];
}

/**
 * Template method that binds a pointer to the vertex location data to the GL engine.
 * If this mesh has no vertex location data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexLocations unbind class method.
 */
-(void) bindLocationsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexLocations) {
		[vertexLocations bindWithVisitor: visitor];
	} else {
		[CC3VertexLocations unbind];
	}
}

/**
 * Template method that binds a pointer to the vertex normal data to the GL engine.
 * If this mesh has no vertex normal data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexNormals unbind class method.
 */
-(void) bindNormalsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexNormals && visitor.shouldDecorateNode) {
		[vertexNormals bindWithVisitor: visitor];
	} else {
		[CC3VertexNormals unbind];
	}
}

/**
 * Template method that binds a pointer to the per-vertex color data to the GL engine.
 * If this mesh has no per-vertex color data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexColors unbind class method.
 */
-(void) bindColorsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexColors && visitor.shouldDecorateNode) {
		[vertexColors bindWithVisitor: visitor];
	} else {
		[CC3VertexColors unbind];
	}
}

/**
 * Template method that binds a pointer to the vertex texture mapping data to the GL engine
 * for each texture unit that has a texture, as indicated by the textureUnitCount of the
 * specified visitor.
 *
 * If there are fewer vertex texture coordinate arrays than indicated by the textureUnitCount,
 * the last vertex texture coordinate array is reused. In this way, a single vertex texture
 * coordinate array (in the vertexTextureCoordinates property) can be used for both the primary
 * texture and multiple texture overlays. Or, one array could be used for the primary texture
 * and another for all the overlays. Or the primary and each overlay could have their own
 * texture coordinate arrays.
 *
 * Any unused texture coordinate arrays are unbound from the GL engine.
 */
-(void) bindTextureCoordinatesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	GLuint tu = 0;								// The current texture unit
	CC3VertexTextureCoordinates* vtc = nil;		// The tex coord array to bind to it.

	// Don't do anything if we're not actually drawing textures to the GL engine.
	if (visitor.shouldDecorateNode) {

		// For each texture unit that has a texture...
		while(tu < visitor.textureUnitCount) {

			if (tu < self.textureCoordinatesArrayCount) {
				vtc = [self textureCoordinatesForTextureUnit: tu];
			}

			// Note that vtc at this point will be the most recently assigned array,
			// and may be the array that was used on the last iteration of this loop
			// if there are less texture coord arrays than there are textures.
			// In this case, we keep reusing the most recently used texture coord array.
			if(vtc) {
				visitor.textureUnit = tu;
				[vtc bindWithVisitor: visitor];
			} else {
				// If we have no tex coord at all, simply disable tex coords in this texture unit.
				[CC3VertexTextureCoordinates unbind: tu];
			}
			tu++;		// Move on to the next texture unit
		}
	}
	[CC3VertexTextureCoordinates unbindRemainingFrom: tu];
}

/**
 * Template method that binds a pointer to the vertex point size data to the GL engine.
 * Since this mesh has no vertex point size data, the pointer is cleared in the GL engine.
 * Subclasses with vertex point size data will override.
 */
-(void) bindPointSizesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[CC3VertexPointSizes unbind];
}

/**
 * Template method that binds a pointer to the vertex matrix index data to the GL engine.
 * Since this mesh has no vertex matrix index data, the pointer is cleared in the GL engine.
 * Subclasses with vertex matrix index data will override.
 */
-(void) bindBoneMatrixIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[CC3VertexMatrixIndices unbind];
}

/**
 * Template method that binds a pointer to the vertex weight data to the GL engine.
 * Since this mesh has no vertex weight data, the pointer is cleared in the GL engine.
 * Subclasses with vertex weight data will override.
 */
-(void) bindBoneWeightsWithVisitor:(CC3NodeDrawingVisitor*) visitor {
	[CC3VertexWeights unbind];
}

/** Template method that binds a pointer to the vertex index data to the GL engine. */
-(void) bindIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[vertexIndices bindWithVisitor: visitor];
}

/** 
 * Draws the mesh vertices to the GL engine.
 *
 * If the vertexIndices property is not nil, the draw method is invoked on that
 * CC3VertexIndices instance. Otherwise, the draw method is invoked on the
 * CC3VertexLocations instance in the vertexLocations property.
 */
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	if (vertexIndices) {
		[vertexIndices drawWithVisitor: visitor];
	} else {
		[vertexLocations drawWithVisitor: visitor];
	}
}

-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@ from %u for %u vertices", self, vertexIndex, vertexCount);
	if (vertexIndices) {
		[vertexIndices drawFrom: vertexIndex forCount: vertexCount withVisitor: visitor];
	} else {
		[vertexLocations drawFrom: vertexIndex forCount: vertexCount withVisitor: visitor];
	}
}

-(GLsizei) faceCountFromVertexCount: (GLsizei) vc {
	if (vertexIndices) {
		return [vertexIndices faceCountFromVertexCount: vc];
	}
	if (vertexLocations) {
		return [vertexLocations faceCountFromVertexCount: vc];
	}
	NSAssert(NO, @"%@ has no drawable vertex array and cannot convert vertex count to face count.");
	return 0;
}

-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc {
	if (vertexIndices) {
		return [vertexIndices vertexCountFromFaceCount: fc];
	}
	if (vertexLocations) {
		return [vertexLocations vertexCountFromFaceCount: fc];
	}
	NSAssert(NO, @"%@ has no drawable vertex array and cannot convert face count to vertex count.");
	return 0;
}

/**
 * Returns a bounding volume that first checks against the spherical boundary,
 * and then checks against a bounding box. The spherical boundary is fast to check,
 * but is not as accurate as the bounding box for many meshes. The bounding box
 * is more accurate, but is more expensive to check than the spherical boundary.
 * The bounding box is only checked if the spherical boundary does not indicate
 * that the mesh is outside the frustum.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	CC3NodeTighteningBoundingVolumeSequence* bvs = [CC3NodeTighteningBoundingVolumeSequence boundingVolume];
	[bvs addBoundingVolume: [CC3VertexLocationsSphericalBoundingVolume boundingVolume]];
	[bvs addBoundingVolume: [CC3VertexLocationsBoundingBoxVolume boundingVolume]];
	return bvs;
}


#pragma mark Accessing vertex data

-(void) movePivotTo: (CC3Vector) aLocation {
	[vertexLocations movePivotTo: aLocation];
}

-(void) movePivotToCenterOfGeometry {
	[vertexLocations movePivotToCenterOfGeometry];
}

-(GLsizei) vertexCount {
	return vertexLocations.elementCount;
}

-(CC3Vector) vertexLocationAt: (GLsizei) index {
	return vertexLocations ? [vertexLocations locationAt: index] : kCC3VectorZero;
}

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLsizei) index {
	[vertexLocations setLocation: aLocation at: index];
}

-(CC3Vector) vertexNormalAt: (GLsizei) index {
	return vertexNormals ? [vertexNormals normalAt: index] : kCC3VectorZero;
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLsizei) index {
	[vertexNormals setNormal: aNormal at: index];
}

-(ccColor4F) vertexColor4FAt: (GLsizei) index {
	return vertexColors ? [vertexColors color4FAt: index] : kCCC4FBlackTransparent;
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLsizei) index {
	[vertexColors setColor4F: aColor at: index];
}

-(ccColor4B) vertexColor4BAt: (GLsizei) index {
	return vertexColors ? [vertexColors color4BAt: index] : (ccColor4B){ 0, 0, 0, 0 };
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLsizei) index {
	[vertexColors setColor4B: aColor at: index];
}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLsizei) index {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	return texCoords ? [texCoords texCoord2FAt: index] : (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLsizei) index {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	[texCoords setTexCoord2F: aTex2F at: index];
}

-(GLushort) vertexIndexAt: (GLsizei) index {
	return vertexIndices ? [vertexIndices indexAt: index] : 0;
}

-(void) setVertexIndex: (GLushort) vertexIndex at: (GLsizei) index {
	[vertexIndices setIndex: vertexIndex at: index];
}

-(void) updateVertexLocationsGLBuffer {
	[vertexLocations updateGLBuffer];
}

-(void) updateVertexNormalsGLBuffer {
	[vertexNormals updateGLBuffer];
}

-(void) updateVertexColorsGLBuffer {
	[vertexColors updateGLBuffer];
}

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	[texCoords updateGLBuffer];
}

-(void) updateVertexIndicesGLBuffer {
	[vertexIndices updateGLBuffer];
}


#pragma mark Mesh context switching

+(void) resetSwitching {
	[super resetSwitching];
	[CC3VertexArray resetAllSwitching];
}

@end


#pragma mark -
#pragma mark Bounding Volumes

@interface CC3NodeBoundingVolume (TemplateMethods)
-(void) buildVolume;
@end

#pragma mark -
#pragma mark CC3VertexLocationsBoundingVolume implementation

@implementation CC3VertexLocationsBoundingVolume

-(CC3VertexLocations*) vertexLocations {
	return ((CC3VertexArrayMesh*)((CC3MeshNode*)self.node).mesh).vertexLocations;
}

-(void) buildVolume {
	centerOfGeometry = self.vertexLocations.centerOfGeometry;
	[super buildVolume];
}

@end


#pragma mark -
#pragma mark CC3VertexLocationsSphericalBoundingVolume implementation

@implementation CC3VertexLocationsSphericalBoundingVolume

-(CC3VertexLocations*) vertexLocations {
	return ((CC3VertexArrayMesh*)((CC3MeshNode*)self.node).mesh).vertexLocations;
}

/**
 * Find the sphere that currently encompasses all the vertices. Then, if we should maximize
 * the boundary, find the sphere that is the union of that sphere, and the sphere that
 * previously encompassed all the vertices. Otherwise, just use the new sphere.
 */
-(void) buildVolume {
	CC3Vector newCOG = self.vertexLocations.centerOfGeometry;
	GLfloat newRadius = self.vertexLocations.radius + self.node.boundingVolumePadding;
	
	if (shouldMaximize) {
		CC3Sphere unionSphere = CC3SphereUnion(CC3SphereMake(newCOG, newRadius),
											   CC3SphereMake(centerOfGeometry, radius));
		centerOfGeometry = unionSphere.center;
		radius = unionSphere.radius;
	} else {
		centerOfGeometry = newCOG;
		radius = newRadius;
	}
	
	[super buildVolume];
}

@end


#pragma mark -
#pragma mark CC3VertexLocationsBoundingBoxVolume implementation

@implementation CC3VertexLocationsBoundingBoxVolume

-(CC3VertexLocations*) vertexLocations {
	return ((CC3VertexArrayMesh*)((CC3MeshNode*)self.node).mesh).vertexLocations;
}

/**
 * Find the bounding box that currently encompasses all the vertices. Then, if we should
 * maximize the boundary, find the bounding box that is the union of that bounding box,
 * and the bounding box that previously encompassed all the vertices. Otherwise, just use
 * the new bounding box.
 */
-(void) buildVolume {
	CC3BoundingBox newBB = ((CC3MeshNode*)self.node).localContentBoundingBox;	// Includes possible padding
	
	if (shouldMaximize) {
		boundingBox = CC3BoundingBoxUnion(newBB, boundingBox);
	} else {
		boundingBox = newBB;
	}

	centerOfGeometry = CC3BoundingBoxCenter(boundingBox);

	[super buildVolume];
}

@end


#pragma mark -
#pragma mark Deprecated CC3VertexArrayMeshModel

@implementation CC3VertexArrayMeshModel
@end

