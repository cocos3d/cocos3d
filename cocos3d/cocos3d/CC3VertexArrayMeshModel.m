/*
 * CC3VertexArrayMeshModel.m
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
 * See header file CC3VertexArrayMeshModel.h for full API documentation.
 */

#import "CC3VertexArrayMeshModel.h"
#import "CC3MeshNode.h"

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

@interface CC3VertexArrayMeshModel (TemplateMethods)
-(void) bindLocationsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindNormalsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindColorsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindTextureCoordinatesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end


@implementation CC3VertexArrayMeshModel

@synthesize vertexLocations, vertexNormals, vertexColors, vertexTextureCoordinates;
@synthesize vertexIndices, interleaveVertices;

-(void) dealloc {
	[vertexLocations release];
	[vertexNormals release];
	[vertexColors release];
	[vertexTextureCoordinates release];
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
 * If no vertexLocation array has been set, returns a zero bounding box.
 */
-(CC3BoundingBox) boundingBox {
	return vertexLocations ? vertexLocations.boundingBox : [super boundingBox];
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		interleaveVertices = NO;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexArrayMeshModel*) another {
	[super populateFrom: another];

	// Share vertex arrays between copies
	[vertexLocations release];
	vertexLocations = [another.vertexLocations retain];						// retained

	[vertexNormals release];
	vertexNormals = [another.vertexNormals retain];							// retained

	[vertexColors release];
	vertexColors = [another.vertexColors retain];							// retained

	[vertexTextureCoordinates release];
	vertexTextureCoordinates = [another.vertexTextureCoordinates retain];	// retained

	[vertexIndices release];
	vertexIndices = [another.vertexIndices retain];							// retained

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
	} else {
		[vertexNormals createGLBuffer];
		[vertexColors createGLBuffer];
		[vertexTextureCoordinates createGLBuffer];
	}
	[vertexIndices createGLBuffer];
}

-(void) deleteGLBuffers {
	[vertexLocations deleteGLBuffer];
	[vertexNormals deleteGLBuffer];
	[vertexColors deleteGLBuffer];
	[vertexTextureCoordinates deleteGLBuffer];
	[vertexIndices deleteGLBuffer];
}

-(void) releaseRedundantData {
	[vertexLocations releaseRedundantData];
	[vertexNormals releaseRedundantData];
	[vertexColors releaseRedundantData];
	[vertexTextureCoordinates releaseRedundantData];
	[vertexIndices releaseRedundantData];
}

/** Sets the shouldReleaseRedundantData of vertexLocations array to NO. */
-(void) retainVertexLocations {
	vertexLocations.shouldReleaseRedundantData = NO;
}


#pragma mark Drawing

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Binding %@", self);
	[self bindLocationsWithVisitor: visitor];
	[self bindNormalsWithVisitor: visitor];
	[self bindColorsWithVisitor: visitor];
	[self bindTextureCoordinatesWithVisitor: visitor];
	[self bindIndicesWithVisitor: visitor];
}

/**
 * Template method that binds a pointer to the vertex location data to the GL engine.
 * If this mesh has no vertex location data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexLocations unbind class method.
 */
-(void) bindLocationsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexLocations) {
		[vertexLocations bind];
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
		[vertexNormals bind];
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
		[vertexColors bind];
	} else {
		[CC3VertexColors unbind];
	}
}

/**
 * Template method that binds a pointer to the vertex texture mapping data to the GL engine.
 * If this mesh has no vertex texture mapping data, the pointer is cleared in the GL engine
 * by invoking the CC3VertexTextureCoordinates unbind class method.
 */
-(void) bindTextureCoordinatesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (vertexTextureCoordinates && visitor.shouldDecorateNode) {
		[vertexTextureCoordinates bind];
	} else {
		[CC3VertexTextureCoordinates unbind];
	}
}

/** Template method that binds a pointer to the vertex index data to the GL engine. */
-(void) bindIndicesWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[vertexIndices bind];
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


#pragma mark Mesh context switching

+(void) resetSwitching {
	[super resetSwitching];
	[CC3VertexLocations resetSwitching];
	[CC3VertexNormals resetSwitching];
	[CC3VertexColors resetSwitching];
	[CC3VertexTextureCoordinates resetSwitching];
	[CC3VertexIndices resetSwitching];
}

@end


@interface CC3NodeBoundingVolume (TemplateMethods)
-(void) buildVolume;
@end

#pragma mark -
#pragma mark CC3VertexLocationsBoundingVolume implementation

@implementation CC3VertexLocationsBoundingVolume

-(CC3VertexLocations*) vertexLocations {
	return ((CC3VertexArrayMeshModel*)((CC3MeshNode*)self.node).meshModel).vertexLocations;
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
	return ((CC3VertexArrayMeshModel*)((CC3MeshNode*)self.node).meshModel).vertexLocations;
}

-(void) calcRadius {
	CC3VertexLocations* vLocs = self.vertexLocations;
	NSAssert1(vLocs.elementType == GL_FLOAT, @"%@ must have elementType GLFLOAT to calculate mesh radius", [vLocs class]);
	GLsizei vlCount = vLocs.elementCount;
	if (vlCount && vLocs.elements) {
		radius = 0.0;
		for (GLsizei i=0; i < vlCount; i++) {
			CC3Vector vl = [vLocs locationAt: i];
			GLfloat dist = CC3VectorLength(CC3VectorDifference(vl, centerOfGeometry));
			radius = MAX(radius, dist);
		}
		LogTrace(@"%@ setting radius of %@ to %.2f", [self class], self.node, radius);
	}
	NSAssert(radius > 0.0f, @"Spherical bounding radius is zero");
}

-(void) buildVolume {
	centerOfGeometry = self.vertexLocations.centerOfGeometry;
	[self calcRadius];
	[super buildVolume];
}

@end


#pragma mark -
#pragma mark CC3VertexLocationsBoundingBoxVolume implementation

@implementation CC3VertexLocationsBoundingBoxVolume

-(CC3VertexLocations*) vertexLocations {
	return ((CC3VertexArrayMeshModel*)((CC3MeshNode*)self.node).meshModel).vertexLocations;
}

-(void) buildVolume {
	centerOfGeometry = self.vertexLocations.centerOfGeometry;
	boundingBox = self.vertexLocations.boundingBox;
	[super buildVolume];
}

@end
