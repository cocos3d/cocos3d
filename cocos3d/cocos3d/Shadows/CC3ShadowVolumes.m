/*
 * CC3ShadowVolumes.m
 *
 * cocos3d 0.6.3
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3ShadowVolumes.h for full API documentation.
 */

#import "CC3ShadowVolumes.h"
#import "CC3Scene.h"
#import "CC3ParametricMeshNodes.h"


@interface CC3Node (TemplateMethods)
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor;
@property(nonatomic, unsafe_unretained, readwrite) CC3Node* parent;
@end

@interface CC3MeshNode (TemplateMethods)
-(id) shadowVolumeClass;
-(void) applyLocalTransforms;
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
@end


#pragma mark -
#pragma mark CC3ShadowVolumeMeshNode

@implementation CC3ShadowVolumeMeshNode

@synthesize light=_light, shouldDrawTerminator=_shouldDrawTerminator;

-(void) dealloc {
	[_light removeShadow: self];		// Will also set light to nil
	LogTrace(@"Removed %@ from %@ leaving %i shadows", self, _light, _light.shadows.count);

	_light = nil;			// weak reference
	[super dealloc];
}

-(BOOL) isShadowVolume { return YES; }

/** Create the shadow volume mesh once the parent is attached. */
-(void) setParent: (CC3Node*) aNode {
	[super setParent: aNode];
	[self createShadowMesh];
}

// Overridden so that can still be visible if parent is invisible, unless explicitly turned off.
-(BOOL) visible { return _visible; }

/**
 * If shadow volume should be visible, add a material
 * to display the volume, otherwise get rid of it.
 */
-(void) setVisible:(BOOL) isVisible {
	[super setVisible: isVisible];
	[self checkShadowMaterial];
}

-(void) setShouldDrawTerminator: (BOOL) shouldDraw {
	_shouldDrawTerminator = shouldDraw;
	self.drawingMode = _shouldDrawTerminator ? GL_LINES : GL_TRIANGLES;
	[self checkShadowMaterial];
}

-(GLushort) shadowLagFactor { return _shadowLagFactor; }

-(void) setShadowLagFactor: (GLushort) lagFactor {
	_shadowLagFactor = MAX(lagFactor, 1);
	super.shadowLagFactor = lagFactor;
}

-(GLushort) shadowLagCount { return _shadowLagCount; }

-(void) setShadowLagCount: (GLushort) lagCount {
	_shadowLagCount = lagCount;
	super.shadowLagCount = lagCount;
}

-(BOOL) shouldShadowFrontFaces { return _shouldShadowFrontFaces; }

-(void) setShouldShadowFrontFaces: (BOOL) shouldShadow {
	_shouldShadowFrontFaces = shouldShadow;
	super.shouldShadowFrontFaces = shouldShadow;
}

-(BOOL) shouldShadowBackFaces { return _shouldShadowBackFaces; }

-(void) setShouldShadowBackFaces: (BOOL) shouldShadow {
	_shouldShadowBackFaces = shouldShadow;
	super.shouldShadowBackFaces = shouldShadow;
}

-(GLfloat) shadowOffsetFactor { return _decalOffsetFactor ? _decalOffsetFactor : super.shadowOffsetFactor; }

-(void) setShadowOffsetFactor: (GLfloat) factor {
	_decalOffsetFactor = factor;
	super.shadowOffsetFactor = factor;
}

-(GLfloat) shadowOffsetUnits { return _decalOffsetUnits ? _decalOffsetUnits : super.shadowOffsetUnits; }

-(void) setShadowOffsetUnits: (GLfloat) units {
	_decalOffsetUnits = units;
	super.shadowOffsetUnits = units;
}

-(GLfloat) shadowVolumeVertexOffsetFactor {
	return _shadowVolumeVertexOffsetFactor ? _shadowVolumeVertexOffsetFactor : super.shadowVolumeVertexOffsetFactor;
}

-(void) setShadowVolumeVertexOffsetFactor: (GLfloat) factor {
	_shadowVolumeVertexOffsetFactor = factor;
	super.shadowVolumeVertexOffsetFactor = factor;
}

-(GLfloat) shadowExpansionLimitFactor { return _shadowExpansionLimitFactor; }

-(void) setShadowExpansionLimitFactor: (GLfloat) factor {
	_shadowExpansionLimitFactor = factor;
	super.shadowExpansionLimitFactor = factor;
}

-(BOOL) shouldAddShadowVolumeEndCapsOnlyWhenNeeded { return _shouldAddEndCapsOnlyWhenNeeded; }

-(void) setShouldAddShadowVolumeEndCapsOnlyWhenNeeded: (BOOL) onlyWhenNeeded {
	_shouldAddEndCapsOnlyWhenNeeded = onlyWhenNeeded;
	super.shouldAddShadowVolumeEndCapsOnlyWhenNeeded = onlyWhenNeeded;
}

-(BOOL) hasShadowVolumesForLight: (CC3Light*) aLight { return YES; }

-(BOOL) hasShadowVolumes { return YES; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_light = nil;
		_isShadowDirty = YES;
		_shouldDrawTerminator = NO;
		_shouldShadowFrontFaces = YES;
		_shouldShadowBackFaces = NO;
		_shouldAddEndCapsOnlyWhenNeeded = NO;
		_useDepthFailAlgorithm = NO;
		self.shouldUseLighting = NO;
		self.shouldDisableDepthMask = YES;
		_shadowLagFactor = 1;
		_shadowLagCount = 1;
		self.shadowOffsetFactor = 0;
		self.shadowOffsetUnits = -1;
		_shadowVolumeVertexOffsetFactor = 0;
		_shadowExpansionLimitFactor = 100;
		self.visible = self.class.defaultVisible;		// Use setter
		self.pureColor = kCCC4FYellow;					// For terminator lines
	}
	return self;
}

// Protected properties for copying
-(BOOL) isShadowDirty { return _isShadowDirty; }
-(BOOL) useDepthFailAlgorithm { return _useDepthFailAlgorithm; }

-(void) populateFrom: (CC3ShadowVolumeMeshNode*) another {
	[super populateFrom: another];
	
	self.light = another.light;						// weak reference
	_isShadowDirty = another.isShadowDirty;
	_shouldShadowFrontFaces = another.shouldShadowFrontFaces;
	_shouldShadowBackFaces = another.shouldShadowBackFaces;
	_shouldDrawTerminator = another.shouldDrawTerminator;
	_shouldAddEndCapsOnlyWhenNeeded = another.shouldAddShadowVolumeEndCapsOnlyWhenNeeded;
	_useDepthFailAlgorithm = another.useDepthFailAlgorithm;
	_shadowLagFactor = another.shadowLagFactor;
	_shadowLagCount = another.shadowLagCount;
	_shadowVolumeVertexOffsetFactor = another.shadowVolumeVertexOffsetFactor;
	_shadowExpansionLimitFactor = another.shadowExpansionLimitFactor;
}

/**
 * Overridden to return nil so that the shadow volume
 * will always be drawn when made visible during development.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume { return nil; }

/** Returns this node's parent, cast as a mesh node. */
-(CC3MeshNode*) shadowCaster { return (CC3MeshNode*)_parent; }

/** A shadow volume only uses a material when it is to be visible during development. */
-(void) checkShadowMaterial {
	if ( !_shouldDrawTerminator && self.visible ) {
		self.color = ccc3(85, 85, 85);	// Will lazily init material if needed
		self.opacity = 85;
	} else
		self.material = nil;
}

-(void) createShadowMesh {
	GLuint vertexCount = self.shadowCaster.vertexCount;
	
	// Create vertexLocation array.
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArray];
	locArray.drawingMode = GL_TRIANGLES;
	locArray.elementSize = 4;						// We're using homogeneous coordinates!
	locArray.allocatedVertexCapacity = vertexCount;
	locArray.vertexCount = 0;						// Will be populated dynamically
	locArray.shouldReleaseRedundantContent = NO;	// Shadow vertex data is dynamic
	
	CC3Mesh* aMesh = [CC3Mesh mesh];
	aMesh.vertexLocations = locArray;
	self.mesh = aMesh;
}

/**
 * Returns a 4D directional vector which can be added to each vertex when creating
 * the shadow volume vertices from the corresponding shadow caster vertices.
 *
 * The returned vector is in the local coordinate system of the shadow caster.
 *
 * The returned directional vector is a small offset vector in the direction away
 * from the light. A unit vector in that direction is scaled by both the distance
 * from the center of the shadow casting node to the camera and the
 * shadowVolumeVertexOffsetFactor property. Hence, if the shadow caster is farther
 * away from the camera, the returned value will be larger, to reduce the chance
 * of Z-fighting between the faces of the shadow volume and the shadow caster.
 */
-(CC3Vector4) shadowVolumeVertexOffsetForLightAt: (CC3Vector4) localLightPos {
	CC3Vector scLoc = self.shadowCaster.localContentCenterOfGeometry;
	CC3Vector lgtLoc = localLightPos.v;
	CC3Vector camLoc = [self.shadowCaster.globalTransformMatrixInverted
							transformLocation: self.activeCamera.globalLocation];	

	// Get a unit offset vector in the direction away from the light
	CC3Vector offsetDir = CC3VectorNormalize((_light.isDirectionalOnly)
												? CC3VectorNegate(lgtLoc) 
												: CC3VectorDifference(scLoc, lgtLoc));

	// Get the distance from the shadow caster CoG and the camera, and scale the
	// unit offset vector by that distance and the shadowVolumeVertexOffsetFactor
	GLfloat camDist = CC3VectorDistance(scLoc, camLoc);
	CC3Vector offset = CC3VectorScaleUniform(offsetDir, (camDist * _shadowVolumeVertexOffsetFactor));
	LogTrace(@"%@ nudging vertices by %@", self, NSStringFromCC3Vector(offset));

	// Create and return a 4D directional vector from the offset
	return CC3Vector4FromDirection(offset);
}

/**
 * Populates the shadow volume mesh by iterating through all the faces in the mesh of
 * the shadow casting node, looking for all pairs of neighbouring faces where one face
 * is in illuminated (facing towards the light) and the other is dark (facing away from
 * the light). The set of edges between these pairs forms the terminator of the mesh,
 * where the mesh on one side of the terminator is illuminated and the other is dark.
 *
 * The shadow volume is then constructed by extruding each edge line segment in the
 * terminator out to infinity in the direction away from the light source, forming a
 * tube of infinite length.
 *
 * Uses the 4D homogeneous location of the light in the global coordinate system.
 * When using the light location this method transforms this location to the local
 * coordinates system of the shadow caster.
 */
-(void) populateShadowMesh {
	
	CC3MeshNode* scNode = self.shadowCaster;
	GLuint faceCnt = scNode.faceCount;
	GLuint shdwVtxIdx = 0;
	BOOL wasMeshExpanded = NO;
	BOOL doesRequireCapping = _useDepthFailAlgorithm || !_shouldAddEndCapsOnlyWhenNeeded;
	
	// Transform the 4D position of the light into the local coordinates of the shadow caster.
	CC3Vector4 lightPosition = _light.globalHomogeneousPosition;
	CC3Vector4 localLightPosition = [scNode.globalTransformMatrixInverted
									 transformHomogeneousVector: lightPosition];
	
	// Determine whether we want to nudge the shadow volume vertices away from the shadow caster
	BOOL isNudgingVertices = (_shadowVolumeVertexOffsetFactor != 0.0f);
	CC3Vector4 svVtxNudge = isNudgingVertices
								? [self shadowVolumeVertexOffsetForLightAt: localLightPosition]
								: kCC3Vector4Zero;
	
	//	if (doesRequireCapping) LogDebug(@"Populating %@ with end caps", self);
	
	//	if ( [scNode.name isEqualToString: @"GeoSphere01"] ) {
	//		LogDebug(@"Populating %@ with %i faces for light at %@ and %@ end caps",
	//					  self, faceCnt, NSStringFromCC3Vector4(lightPosition),
	//					  (doesRequireCapping ? @"including" : @"excluding"));
	//	}
	
	LogTrace(@"Populating %@ with %i faces for light at %@ and %@ end caps",
				  self, faceCnt, NSStringFromCC3Vector4(lightPosition),
				  (doesRequireCapping ? @"including" : @"excluding"));
	
	LogTrace(@"%@ global light location: %@ shadow local light: %@ %@ inverted: %@",
				  self, NSStringFromCC3Vector4(lightPosition),
				  NSStringFromCC3Vector4(localLightPosition),
				  scNode.globalTransformMatrix,
				  scNode.globalTransformMatrixInverted);
	
	// Iterate through all the faces in the mesh of the shadow caster.
	for (GLuint faceIdx = 0; faceIdx < faceCnt; faceIdx++) {
		
		// Retrieve the current face, convert it to 4D homogeneous locations
		CC3Face face = [scNode deformedFaceAt: faceIdx];
		CC3Vector4 vertices4d[3];
		vertices4d[0] = CC3Vector4FromLocation(face.vertices[0]);
		vertices4d[1] = CC3Vector4FromLocation(face.vertices[1]);
		vertices4d[2] = CC3Vector4FromLocation(face.vertices[2]);
		
		// If needed, nudge the shadow volume face away from the
		// shadow caster face in the direction away from the light
		if (isNudgingVertices) {
			vertices4d[0] = CC3Vector4Add(vertices4d[0], svVtxNudge);
			vertices4d[1] = CC3Vector4Add(vertices4d[1], svVtxNudge);
			vertices4d[2] = CC3Vector4Add(vertices4d[2], svVtxNudge);
		}
		
		// Determine whether the face is illuminated.
		BOOL isFaceLit = CC3Vector4IsInFrontOfPlane(localLightPosition, [scNode deformedFacePlaneAt: faceIdx]);
		
		LogTrace(@"Face %i of %@ is %@. Indices: %@, Vertices: %@, plane: %@, neighbours: %@",
					  faceIdx, scNode, (isFaceLit ? @"illuminated" : @"dark"),
					  NSStringFromCC3FaceIndices([scNode faceIndicesAt: faceIdx]),
					  NSStringFromCC3Face([scNode deformedFaceAt: faceIdx]),
					  NSStringFromCC3Plane([scNode deformedFacePlaneAt: faceIdx]),
					  NSStringFromCC3FaceNeighbours([scNode faceNeighboursAt: faceIdx]));
		
		// If we're drawing end-caps, and this face is part of an end-cap, draw it.
		// It's part of an end-cap if it's a dark face and shadowing is based on front
		// faces (typical), or it's a lit face and shadowing is (also) based on back faces
		// (as with some open meshes).
		if (doesRequireCapping &&
			(isFaceLit ? _shouldShadowBackFaces : _shouldShadowFrontFaces) &&
			!_shouldDrawTerminator) {
			LogTrace(@"%@ adding end cap for face %i", self, faceIdx);
			wasMeshExpanded |= [self addShadowVolumeCapFor: isFaceLit
													  face: vertices4d
												forLightAt: localLightPosition
										   startingAtIndex: &shdwVtxIdx];
		}
		
		// Now check the neighbouring face on the other side of each edge of this face.
		CC3FaceNeighbours neighbours = [scNode faceNeighboursAt: faceIdx];
		for (int edgeIdx = 0; edgeIdx < 3; edgeIdx++) {
			
			// Get the index of the face on the other side of this edge
			GLuint neighbourFaceIdx = neighbours.edges[edgeIdx];
			
			// Check if this edge is part of the terminator. It is if either:
			//   - There is no neighbouring face on this edge, and either the face is lit
			//     and front faces are being shadowed, or the face is dark and back faces
			//     are being shadowed.
			//   - The neighbour has the opposite illumination than the current face
			//     (ie- lit/dark or dark/lit) AND we haven't encountered this edge before
			//     during this iteration, (ie- don't double count). The double-count test
			//     is accomplished by only accepting the neighbouring face if it has a
			//     larger index than the current face.
			BOOL isTerminatorEdge = NO;
			if (neighbourFaceIdx == kCC3FaceNoNeighbour) {
				isTerminatorEdge = isFaceLit ? _shouldShadowFrontFaces : _shouldShadowBackFaces;
			} else if (neighbourFaceIdx > faceIdx) {		// Don't double count edges
				BOOL isNeighbourFaceLit = CC3Vector4IsInFrontOfPlane(localLightPosition, [scNode deformedFacePlaneAt: neighbourFaceIdx]);
				isTerminatorEdge = (isNeighbourFaceLit != isFaceLit);
			}
			
			if (isTerminatorEdge) {
				
				// We've found a terminator edge!
				LogTrace(@"\tNeighbouring face %u is %@. We have a terminator edge.",
							  neighbourFaceIdx, ((neighbourFaceIdx == kCC3FaceNoNeighbour)
												 ? @"missing" 
												 : (isFaceLit ? @"dark" : @"illuminated")));
				
				// Get the end points of the terminator edge that we will be extruding.
				// To have the normals of the shadow volume mesh point outwards, we want the
				// winding of the extruded face to be the same as the dark face. So, choose
				// the start and end of the edge based on which face of this pair is illuminated.
				CC3Vector4 edgeStartLoc, edgeEndLoc;
				if (isFaceLit) {
					edgeStartLoc = vertices4d[edgeIdx];
					edgeEndLoc = vertices4d[(edgeIdx < 2) ? (edgeIdx + 1) : 0];
				} else {
					edgeStartLoc = vertices4d[(edgeIdx < 2) ? (edgeIdx + 1) : 0];
					edgeEndLoc = vertices4d[edgeIdx];
				}
				
				if (self.shouldDrawTerminator && self.visible) {
					// Draw the terminator line instead of a shadow
					wasMeshExpanded |= [self addTerminatorLineFrom: edgeStartLoc
																to: edgeEndLoc
												   startingAtIndex: &shdwVtxIdx];
				} else if (CC3Vector4IsDirectional(localLightPosition)) {
					// Draw the shadow from a directional light
					wasMeshExpanded |= [self addShadowVolumeSideFrom: edgeStartLoc
																  to: edgeEndLoc
											   forDirectionalLightAt: localLightPosition
													 startingAtIndex: &shdwVtxIdx];
				} else {
					// Draw the shadow from a locational light, possibly closing off the far end
					wasMeshExpanded |= [self addShadowVolumeSideFrom: edgeStartLoc
																  to: edgeEndLoc
															 withCap: doesRequireCapping
												forLocationalLightAt: localLightPosition
													 startingAtIndex: &shdwVtxIdx];
				}
			} else {
				LogTrace(@"\tNeighbouring face %u is %@. Not a terminator edge.",
							  neighbourFaceIdx, (isFaceLit ? @"illuminated" : @"dark"));
			}
		}
	}
	
	// Update the vertex count of the shadow volume mesh, based on how many sides we've added.
	_mesh.vertexCount = shdwVtxIdx;
	LogTrace(@"%@ setting vertex count to %u", self, shdwVtxIdx);
	
	// If the mesh is using GL VBO's, update them. If the mesh was expanded,
	// recreate the VBO's, otherwise update them.
	if (_mesh.isUsingGLBuffers) {
		if (wasMeshExpanded) {
			[_mesh deleteGLBuffers];
			[_mesh createGLBuffers];
		} else {
			[_mesh updateVertexLocationsGLBuffer];
		}
	}
	LogTrace(@"Finshed populating %@", self);
}

/**
 * Adds a side to the shadow volume, by extruding the specified terminator edge of
 * the specified shadow caster mesh to infinity. The light source is directional
 * at the specified position. The shadow volume vertices are added starting at the
 * specified vertex index.
 * 
 * For a directional light, the shadow volume sides are parallel and can therefore
 * be described as meeting at a single point at infinity. We therefore only need to
 * add a single triangle, whose far point is in the opposite direction of the light.
 */
-(BOOL) addShadowVolumeSideFrom: (CC3Vector4) edgeStartLoc
							 to: (CC3Vector4) edgeEndLoc
		  forDirectionalLightAt: (CC3Vector4) lightPosition
				startingAtIndex: (GLuint*) shdwVtxIdx {
	
	// Get the location of the single point at infinity from the light direction.
	CC3Vector4 farLoc = CC3Vector4HomogeneousNegate(lightPosition);
	
	// Ensure the mesh has enough capacity for another triangle.
	BOOL wasMeshExpanded = [self.mesh ensureVertexCapacity: (*shdwVtxIdx + 3)];
	
	// Add a single triangle from the edge to a single point at infinity,
	// with the same winding as the dark face.
	[_mesh setVertexHomogeneousLocation: edgeStartLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: farLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: edgeEndLoc at: (*shdwVtxIdx)++];
	
	LogTrace(@"%@ drawing shadow volume side face for directional light", self);
	
	return wasMeshExpanded;
}

/**
 * Adds a side to the shadow volume, by extruding the specified terminator edge of
 * the specified shadow caster mesh to infinity. The light source is positional at
 * the specified position. The shadow volume vertices are added starting at the
 * specified vertex index.
 * 
 * For a locational light, the shadow volume sides are not parallel and expand as
 * they extend away from the shadow casting object. If the shadow volume does not
 * need to be capped off at the far end, the shadow expands to infinity.
 *
 * However, if the shadow volume needs to be capped off at the far end, the shadow
 * is allowed to expand behind the shadow-caster to a distance equivalent to the
 * distance from the light to the shadow-caster, multiplied by the value of the
 * shadowExpansionLimitFactor property. At that point, the shadow volume will
 * extend out to infinity at that same size.
 * 
 * For the shadow volume segment that expands in size, each side is a trapezoid
 * formed by projecting a vector from the light, through each terminator edge
 * vertex, out to either infinity of the distance determined by the value of the
 * shadowExpansionLimitFactor property. Then, from that distance to infinity,
 * the shadow volume side behaves as if it originated from a directional light,
 * and is constructed from a single triangle, extending out to infinity in the
 * opposite direction of the light.
 */
-(BOOL) addShadowVolumeSideFrom: (CC3Vector4) edgeStartLoc
							 to: (CC3Vector4) edgeEndLoc
						withCap: (BOOL) doesRequireCapping
		   forLocationalLightAt: (CC3Vector4) lightPosition
				startingAtIndex: (GLuint*) shdwVtxIdx {

	CC3Vector4 farStartLoc, farEndLoc;

	if (doesRequireCapping) {
		// We need to cap this shadow volume at infinity, so allow the shadow volume
		// to expand only for a distance equivalent to the distance from the light to
		// the vertex, mulitiplied by the shadowExpansionLimitFactor property.
		farStartLoc = [self expand: edgeStartLoc awayFromLocationalLightAt: lightPosition];
		farEndLoc = [self expand: edgeEndLoc awayFromLocationalLightAt: lightPosition];
	} else {
		// We don't need to cap this shadow volume, so allow the shadow volume to expand
		// to infinity in a direction away from the light, through the edge points.
		// The W component of the result of each subtraction will be zero, indicating
		// a point at infinity.
		farStartLoc = CC3Vector4Difference(edgeStartLoc, lightPosition);
		farEndLoc = CC3Vector4Difference(edgeEndLoc, lightPosition);
	}
	
	// Ensure the mesh has enough capacity for another two triangles.
	BOOL wasMeshExpanded = [self.mesh ensureVertexCapacity: (*shdwVtxIdx + 6)];
	
	// The shadow volume faces have the same winding as the dark face.
	// First triangular face:
	[_mesh setVertexHomogeneousLocation: edgeStartLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: farStartLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: farEndLoc at: (*shdwVtxIdx)++];
	
	// Second triangular face:
	[_mesh setVertexHomogeneousLocation: edgeStartLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: farEndLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: edgeEndLoc at: (*shdwVtxIdx)++];

	if (doesRequireCapping) {
		// To cap, extend from the limited expansion points out to infinity in
		// a direction away from the light, as if the light was directional.
		// These segments will be parallel to each other, and the shadow will
		// expand no further.
		wasMeshExpanded |= [self addShadowVolumeSideFrom: farStartLoc
													  to: farEndLoc
								   forDirectionalLightAt: lightPosition
										 startingAtIndex: shdwVtxIdx];
	}
	
	LogTrace(@"%@ drawing shadow volume side face for positional light", self);
	
	return wasMeshExpanded;
}

/** 
 * Expands the location of an terminator edge vertex in the direction away from the locational
 * light at the specified location. The vertex is moved away from the light along the vector
 * from the light to the vertex, a distance equal to the distance between the light and the
 * vertex, multiplied by the value of the shadowExpansionLimitFactor property.
 */
-(CC3Vector4) expand: (CC3Vector4) edgeLoc awayFromLocationalLightAt: (CC3Vector4) lightLoc {
	CC3Vector4 extDir = CC3Vector4Difference(edgeLoc, lightLoc);
	CC3Vector4 extrusion = CC3Vector4ScaleUniform(extDir, _shadowExpansionLimitFactor);
	return CC3Vector4Add(edgeLoc, extrusion);
}

/**
 * Adds a face to the cap at the near end of the shadow volume.
 *
 * The winding order of the end-cap faces is determined from the winding order of
 * the model face, taking into consideration whether the face is lit or not.
 */
-(BOOL) addShadowVolumeCapFor: (BOOL) isFaceLit
						 face: (CC3Vector4*) vertices
				   forLightAt: (CC3Vector4) lightPosition
			  startingAtIndex: (GLuint*) shdwVtxIdx {
	
	// Ensure the mesh has enough capacity for another triangle.
	BOOL wasMeshExpanded = [self.mesh ensureVertexCapacity: (*shdwVtxIdx + 3)];
	
	// Add a single triangle face to the cap at the near end, built from the vertices
	// of the shadow caster face at the specified index. If the face is lit, use the
	// same winding order. If the face is dark, use the opposite winding.
	if (isFaceLit) {
		[_mesh setVertexHomogeneousLocation: vertices[0] at: (*shdwVtxIdx)++];
		[_mesh setVertexHomogeneousLocation: vertices[1] at: (*shdwVtxIdx)++];
		[_mesh setVertexHomogeneousLocation: vertices[2] at: (*shdwVtxIdx)++];
	} else {
		[_mesh setVertexHomogeneousLocation: vertices[0] at: (*shdwVtxIdx)++];
		[_mesh setVertexHomogeneousLocation: vertices[2] at: (*shdwVtxIdx)++];
		[_mesh setVertexHomogeneousLocation: vertices[1] at: (*shdwVtxIdx)++];
	}

	LogTrace(@"%@ drawing shadow volume near %@end cap face (%@, %@, %@)",
				  self, (CC3Vector4IsLocational(lightPosition) ? @"and far " : @""),
				  NSStringFromCC3Vector4(vertices[0]),
				  NSStringFromCC3Vector4(vertices[1]),
				  NSStringFromCC3Vector4(vertices[2]));
	
	return wasMeshExpanded;
}

/**
 * When drawing the terminator line of the mesh, just add the two line
 * endpoints, and don't make use of infinitely extruded endpoints.
 */
-(BOOL) addTerminatorLineFrom: (CC3Vector4) edgeStartLoc
						   to: (CC3Vector4) edgeEndLoc
			  startingAtIndex: (GLuint*) shdwVtxIdx {
	
	// Ensure the mesh has enough capacity for another line
	BOOL wasMeshExpanded = [self.mesh ensureVertexCapacity: (*shdwVtxIdx + 2)];
	
	// Add just the two end points of the terminator edge
	[_mesh setVertexHomogeneousLocation: edgeStartLoc at: (*shdwVtxIdx)++];
	[_mesh setVertexHomogeneousLocation: edgeEndLoc at: (*shdwVtxIdx)++];
	
	LogTrace(@"%@ drawing terminator line", self);
	
	return wasMeshExpanded;
}


#pragma mark Update

/** Overridden to decrement the shadow lag count on each update. */
-(void) processUpdateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	_shadowLagCount = MAX(_shadowLagCount - 1, 0);
	[super processUpdateBeforeTransform: visitor];
}

/** Returns whether the shadow cast by this shadow volume will be visible. */
-(BOOL) isShadowVisible {
	CC3MeshNode* scNode = self.shadowCaster;
	return (_light.visible || _light.shouldCastShadowsWhenInvisible) &&
			(scNode.visible || scNode.shouldCastShadowsWhenInvisible || self.visible) &&
			[scNode doesIntersectBoundingVolume: _light.shadowCastingVolume];
}

/**
 * Returns whether this shadow volume is ready to be updated.
 * It is if the lag count has been decremented to zero.
 */
-(BOOL) isReadyToUpdate { return (_shadowLagCount == 0); }

/**
 * If the shadow is ready to be updated, check if the shadow is both
 * visible and dirty, and re-populate the shadow mesh if needed.
 *
 * To keep the shadow lag count synchronized across all shadow-casting nodes,
 * the shadow lag count will be reset to the value of the shadow lag factor
 * if the shadow is ready to be updated, even if it is not actually updated
 * due to it being invisible, or not dirty.
 */
-(void) updateShadow {
	LogTrace(@"Testing to update %@ with shadow lag count %i", self, _shadowLagCount);
	if (self.isReadyToUpdate) {
		if (self.isShadowVisible) {
			[self updateStencilAlgorithm];
			if (_isShadowDirty) {
				LogTrace(@"Updating %@", self);
				[self populateShadowMesh];
				_isShadowDirty = NO;
			}
		}
		_shadowLagCount = _shadowLagFactor;
	}
}

/**
 * Selects whether to use the depth-fail or depth-pass algorithm,
 * based on whether this shadow falls across the camera.
 *
 * The depth-fail algorithm requires end caps on this shadow volume.
 * The depth-pass algorithm does not. Rendering end-caps when not needed
 * creates a performance penalty, so the depth-pass algorithm can be used
 * by setting the shouldAddEndCapsOnlyWhenNeeded property to YES.
 *
 * If the selected stencil algorithm changes, this shadow volume is marked
 * as dirty so that the end caps will be added or removed appropriately.
 */
-(void) updateStencilAlgorithm {
	BOOL oldAlgo = _useDepthFailAlgorithm;

	_useDepthFailAlgorithm = !_shouldAddEndCapsOnlyWhenNeeded ||
							[self.shadowCaster doesIntersectBoundingVolume: _light.cameraShadowVolume];
	
	// If the stencil algo was changed, mark this shadow as dirty,
	// so that end caps will be added or removed.
	if (_useDepthFailAlgorithm != oldAlgo) _isShadowDirty = YES;
}

/** Overridden to remove this shadow node from the light. */
-(void) wasRemoved {
	[_light removeShadow: self];
	[super wasRemoved];
}


#pragma mark Transformations

-(void) markTransformDirty {
	[super markTransformDirty];
	_isShadowDirty = YES;
}

/** A node that affects this shadow (generally the light) was transformed. Mark the shadow as dirty. */
-(void) nodeWasTransformed: (CC3Node*) aNode { 
	[super nodeWasTransformed: aNode];
	_isShadowDirty = YES;
}


#pragma mark Drawing

/** Overridden to set the line properties in addition to other configuration. */
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super configureDrawingParameters: visitor];
	if (_shouldDrawTerminator) visitor.gl.lineWidth = 1.0f;
}

-(void) drawToStencilWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@ using depth %@ algo", self, (_useDepthFailAlgorithm ? @"fail" : @"pass"));
	[self drawToStencilIncrementing: YES withVisitor: visitor];
	[self drawToStencilIncrementing: NO  withVisitor: visitor];
}

-(void) drawToStencilIncrementing: (BOOL) isIncrementing
					  withVisitor: (CC3NodeDrawingVisitor*) visitor {
	GLenum zFailOp, zPassOp;
	BOOL useFrontFaces;

	// Set the stencil operation based on whether we are incrementing or decrementing the stencil.
	GLenum stencilOp = isIncrementing ? GL_INCR_WRAP : GL_DECR_WRAP;
	
	// Depending on whether we are using the depth-fail, or depth-pass algorithm, perform the
	// increment/decrement stencil operation when the depth test fails or passes, respectively,
	// and simply retain the current stencil value otherwise. Also, determine whether we want
	// to cull either the front or back faces, depending on which stencil algorithm we are
	// using, and whether we are on the incrementing or decrementing pass.
	if (_useDepthFailAlgorithm) {
		zFailOp = stencilOp;				// Increment/decrment the stencil on depth fail...
		zPassOp = GL_KEEP;					// ...otherwise keep the current stencil value.
		useFrontFaces = !isIncrementing;	// Cull front faces when incrementing, back faces when decrementing
	} else {
		zPassOp = stencilOp;				// Increment/decrment the stencil on depth pass...
		zFailOp = GL_KEEP;					// ...otherwise keep the current stencil value.
		useFrontFaces = isIncrementing;		// Cull back faces when incrementing, front faces when decrementing
	}

	// Configure the stencil buffer operations
	[visitor.gl setOpOnStencilFail: GL_KEEP onDepthFail: zFailOp onDepthPass: zPassOp];
	
	// Remember current culling configuration for this shadow volume
	BOOL wasCullingBackFaces = self.shouldCullBackFaces;
	BOOL wasCullingFrontFaces = self.shouldCullFrontFaces;

	// Set culling appropriate for stencil operation
	self.shouldCullBackFaces = useFrontFaces;
	self.shouldCullFrontFaces = !useFrontFaces;
		
	[visitor visit: self];		// Draw the shadow volume to the stencil buffer
		
	// Restore current culling configuration for this shadow volume
	self.shouldCullBackFaces = wasCullingBackFaces;
	self.shouldCullFrontFaces = wasCullingFrontFaces;
}

static BOOL _shadowVolumeDefaultVisible = NO;

+(BOOL) defaultVisible { return _shadowVolumeDefaultVisible; }

+(void) setDefaultVisible: (BOOL) defaultVisible { _shadowVolumeDefaultVisible = defaultVisible; }


#pragma mark Shadows, wireframe boxes, direction markers and descriptors

// Shadows are not copied, because each shadow connects
// one-and-only-one shadow casting node to one-and-only-one light.
-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(void) addShadowVolumesForLight: (CC3Light*) aLight {}

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

-(BOOL) shouldDrawBoundingVolume { return NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {}

// Overridden so that not touchable unless specifically set as such
-(BOOL) isTouchable { return (self.visible || _shouldAllowTouchableWhenInvisible) && self.isTouchEnabled; }

@end


#pragma mark -
#pragma mark CC3StencilledShadowPainterNode

@implementation CC3StencilledShadowPainterNode

/** The shadow painter is always drawn. */
-(BOOL) isShadowVisible { return YES; }


#pragma mark CC3ShadowProtocol support

-(void) updateShadow {}

-(CC3Light*) light { return nil; }

-(void) setLight: (CC3Light*) light {}

@end


#pragma mark -
#pragma mark CC3ShadowDrawingVisitor

@implementation CC3ShadowDrawingVisitor

-(id) init {
	if ( (self = [super init]) ) {
		_shouldVisitChildren = NO;
	}
	return self;
}

-(BOOL) shouldDrawNode: (CC3Node*) aNode { return aNode.isShadowVisible; }

@end


#pragma mark -
#pragma mark CC3Node ShadowVolumes category

@implementation CC3Node (ShadowVolumes)

-(BOOL) isShadowVolume { return NO; }

-(void) addShadowVolumes {
	for (CC3Light* lt in self.scene.lights) [self addShadowVolumesForLight: lt];
}

-(void) addShadowVolumesForLight: (CC3Light*) aLight {
	for (CC3Node* child in _children) [child addShadowVolumesForLight: aLight];
}

-(NSArray*) shadowVolumes {
	NSMutableArray* svs = [NSMutableArray array];
	for (CC3Node* child in _children) if (child.isShadowVolume) [svs addObject: child];
	return svs;
}

-(CC3ShadowVolumeMeshNode*) getShadowVolumeForLight:  (CC3Light*) aLight {
	for (CC3ShadowVolumeMeshNode* sv in self.shadowVolumes) if (sv.light == aLight) return sv;
	return nil;
}

-(BOOL) hasShadowVolumesForLight: (CC3Light*) aLight {
	for (CC3Node* child in _children) if ( [child hasShadowVolumesForLight: aLight] ) return YES;
	return NO;
}

-(BOOL) hasShadowVolumes {
	for (CC3Node* child in _children) if ( [child hasShadowVolumes] ) return YES;
	return NO;
}

-(void) removeShadowVolumesForLight: (CC3Light*) aLight {
	[[self getShadowVolumeForLight: aLight] remove];
	for (CC3Node* child in _children) [child removeShadowVolumesForLight: aLight];
}

-(void) removeShadowVolumes {
	for (CC3Node* sv in self.shadowVolumes) [sv remove];
	for (CC3Node* child in _children) [child removeShadowVolumes];
}

-(BOOL) shouldShadowFrontFaces {
	for (CC3Node* child in _children) if ( !child.shouldShadowFrontFaces ) return NO;
	return YES;
}

-(void) setShouldShadowFrontFaces: (BOOL) shouldShadow {
	for (CC3Node* child in _children) child.shouldShadowFrontFaces = shouldShadow;
}

-(BOOL) shouldShadowBackFaces {
	for (CC3Node* child in _children) if (child.shouldShadowBackFaces ) return YES;
	return NO;
}

-(void) setShouldShadowBackFaces: (BOOL) shouldShadow {
	for (CC3Node* child in _children) child.shouldShadowBackFaces = shouldShadow;
}

-(GLfloat) shadowOffsetFactor {
	for (CC3Node* child in _children) {
		GLfloat sf = child.shadowOffsetFactor;
		if (sf) return sf;
	}
	return 0.0f;
}

-(void) setShadowOffsetFactor: (GLfloat) factor {
	for (CC3Node* child in _children) child.shadowOffsetFactor = factor;
}

-(GLfloat) shadowOffsetUnits {
	for (CC3Node* child in _children) {
		GLfloat su = child.shadowOffsetUnits;
		if (su) return su;
	}
	return 0.0f;
}

-(void) setShadowOffsetUnits: (GLfloat) units {
	for (CC3Node* child in _children) child.shadowOffsetUnits = units;
}

-(GLfloat) shadowVolumeVertexOffsetFactor {
	for (CC3Node* child in _children) {
		GLfloat svf = child.shadowVolumeVertexOffsetFactor;
		if (svf) return svf;
	}
	return 0.0f;
}

-(void) setShadowVolumeVertexOffsetFactor: (GLfloat) voFactor {
	for (CC3Node* child in _children) child.shadowVolumeVertexOffsetFactor = voFactor;
}

-(GLfloat) shadowExpansionLimitFactor {
	for (CC3Node* child in _children) return child.shadowExpansionLimitFactor;
	return 0.0f;
}

-(void) setShadowExpansionLimitFactor: (GLfloat) limFactor {
	for (CC3Node* child in _children) child.shadowExpansionLimitFactor = limFactor;
}

-(GLushort) shadowLagFactor {
	for (CC3Node* child in _children) {
		GLushort slf = child.shadowLagFactor;
		if (slf > 1) return slf;
	}
	return 1;
}

/**
 * After setting the lag factor in all descendants, pick a random lag count
 * to start counting from. The same lag factor value and the same lag count
 * value will be set in all descendants.
 */
-(void) setShadowLagFactor: (GLushort) lagFactor {
	for (CC3Node* child in _children) child.shadowLagFactor = lagFactor;
	self.shadowLagCount = CC3RandomUIntBelow(lagFactor) + 1;
}

-(GLushort) shadowLagCount {
	for (CC3Node* child in _children) {
		GLushort slc = child.shadowLagCount;
		if (slc > 0) return slc;
	}
	return 0;
}

-(void) setShadowLagCount: (GLushort) lagCount {
	for (CC3Node* child in _children) child.shadowLagCount = lagCount;
}

-(BOOL) shouldAddShadowVolumeEndCapsOnlyWhenNeeded {
	for (CC3Node* child in _children)
		if ( !child.shouldAddShadowVolumeEndCapsOnlyWhenNeeded ) return NO;
	return YES;
}

-(void) setShouldAddShadowVolumeEndCapsOnlyWhenNeeded: (BOOL) onlyWhenNeeded {
	for (CC3Node* child in _children)
		child.shouldAddShadowVolumeEndCapsOnlyWhenNeeded = onlyWhenNeeded;
}

-(void) prewarmForShadowVolumes {
	for (CC3Node* child in _children) [child prewarmForShadowVolumes];
}

-(BOOL) isShadowVisible { return NO; }

@end


#pragma mark -
#pragma mark CC3MeshNode ShadowVolumes category

@implementation CC3MeshNode (ShadowVolumes)

-(void) addShadowVolumesForLight: (CC3Light*) aLight {
	// If I shouldn't cast a shadow, or if I already have a shadow volume, just leave.
	if ( !self.shouldCastShadows || [self getShadowVolumeForLight: aLight] ) return;
	
	NSString* svName = [NSString stringWithFormat: @"%@-SV-%@", self.name, aLight.name];
	CC3Node<CC3ShadowProtocol>* sv = [[self shadowVolumeClass] nodeWithName: svName];
	[sv selectShaders];
	
	// Retain data required to build shadow volume mesh
	[self retainVertexLocations];
	[self retainVertexIndices];
	self.shouldCacheFaces = YES;
	
	[self prewarmForShadowVolumes];		// Force heavy face calcs now instead of lazily during drawing.

	// Set the active camera to infinite depth of field to accomodate infinite shadow volumes
	self.activeCamera.hasInfiniteDepthOfField = YES;

	[aLight addShadow: sv];			// Add to light before notifying scene a descendant has been added
	[self addChild: sv];			// The last thing we do is add the SV to the scene...
									// ...because we might be doing this on a background thread.
	LogTrace(@"Added shadow volume %@ to %@", sv, self);

	[super addShadowVolumesForLight: aLight];
}

-(id) shadowVolumeClass { return [CC3ShadowVolumeMeshNode class]; }

-(void) prewarmForShadowVolumes {
	if (self.faceCount == 0) return;

	// Sample each face characteristics used during shadow volume creation,
	// in order to force the face characteristics to be lazily populated.
	[self deformedFaceAt: 0];
	[self deformedFacePlaneAt: 0];
	[self faceNeighboursAt: 0];
	
	[super prewarmForShadowVolumes];
}

@end


#pragma mark -
#pragma mark CC3Billboard ShadowVolumes category

@implementation CC3Billboard (ShadowVolumes)

-(void) addShadowVolumesForLight: (CC3Light*) aLight {
	if (!_mesh) [self populateAsBoundingRectangle];

	[super addShadowVolumesForLight: aLight];

	CC3ShadowVolumeMeshNode* sv = [self getShadowVolumeForLight: aLight];
	sv.shouldShadowBackFaces = YES;
	sv.shadowOffsetUnits = 0;
	sv.shadowVolumeVertexOffsetFactor = kCC3DefaultShadowVolumeVertexOffsetFactor;
}

@end


#pragma mark -
#pragma mark CC3SkinMeshNode ShadowVolumes category

@implementation CC3SkinMeshNode (ShadowVolumes)

-(void) addShadowVolumesForLight: (CC3Light*) aLight {
	[super addShadowVolumesForLight: aLight];
	
	// Retain data required to build shadow volume mesh
	[self retainVertexBoneIndices];
	[self retainVertexBoneWeights];
}

@end

#pragma mark -
#pragma mark Mesh nodes that do not cast shadows

@implementation CC3NodeDescriptor (ShadowVolumes)
-(void) addShadowVolumesForLight: (CC3Light*) aLight {}
@end

@implementation CC3WireframeBoundingBoxNode (ShadowVolumes)
-(void) addShadowVolumesForLight: (CC3Light*) aLight {}
@end

@implementation CC3BoundingVolumeDisplayNode (ShadowVolumes)
-(void) addShadowVolumesForLight: (CC3Light*) aLight {}
@end

