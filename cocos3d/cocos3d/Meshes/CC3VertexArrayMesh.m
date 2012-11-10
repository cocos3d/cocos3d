/*
 * CC3VertexArrayMesh.m
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
 * See header file CC3VertexArrayMesh.h for full API documentation.
 */

#import "CC3VertexArrayMesh.h"
#import "CC3MeshNode.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"


@interface CC3VertexArrayMesh (TemplateMethods)
-(void) createVertexContent: (CC3VertexContent) vtxContentTypes;
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

@synthesize capacityExpansionFactor;

-(void) dealloc {
	[vertexLocations release];
	[vertexNormals release];
	[vertexColors release];
	[vertexTextureCoordinates release];
	[overlayTextureCoordinates release];
	[vertexIndices release];
	[super dealloc];
}

-(void) setName: (NSString*) aName {
	super.name = aName;
	[vertexLocations deriveNameFrom: self];
	[vertexNormals deriveNameFrom: self];
	[vertexColors deriveNameFrom: self];
	[vertexTextureCoordinates deriveNameFrom: self];
	[vertexIndices deriveNameFrom: self];
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		[otc deriveNameFrom: self];
	}
}

-(CC3VertexLocations*) vertexLocations { return vertexLocations; }

-(void) setVertexLocations: (CC3VertexLocations*) vtxLocs {
	[vertexLocations autorelease];
	vertexLocations = [vtxLocs retain];
	[vertexLocations deriveNameFrom: self];
}

-(BOOL) hasVertexLocations { return (vertexLocations != nil); }

-(CC3VertexNormals*) vertexNormals { return vertexNormals; }

-(void) setVertexNormals: (CC3VertexNormals*) vtxNorms {
	[vertexNormals autorelease];
	vertexNormals = [vtxNorms retain];
	[vertexNormals deriveNameFrom: self];
}

-(BOOL) hasVertexNormals { return (vertexNormals != nil); }

-(CC3VertexColors*) vertexColors { return vertexColors; }

-(void) setVertexColors: (CC3VertexColors*) vtxCols {
	[vertexColors autorelease];
	vertexColors = [vtxCols retain];
	[vertexColors deriveNameFrom: self];
}

-(BOOL) hasVertexColors { return (vertexColors != nil); }

-(GLenum) vertexColorType { return vertexColors ? vertexColors.elementType : GL_FALSE; }

-(CC3VertexTextureCoordinates*) vertexTextureCoordinates { return vertexTextureCoordinates; }

-(void) setVertexTextureCoordinates: (CC3VertexTextureCoordinates*) vtxTexCoords {
	[vertexTextureCoordinates autorelease];
	vertexTextureCoordinates = [vtxTexCoords retain];
	[vertexTextureCoordinates deriveNameFrom: self];
}

-(BOOL) hasVertexTextureCoordinates { return (vertexTextureCoordinates != nil); }

-(CC3VertexIndices*) vertexIndices { return vertexIndices; }

-(void) setVertexIndices: (CC3VertexIndices*) vtxInd {
	[vertexIndices autorelease];
	vertexIndices = [vtxInd retain];
	[vertexIndices deriveNameFrom: self];
}

-(BOOL) hasVertexIndices { return (vertexIndices != nil); }

-(BOOL) shouldInterleaveVertices { return shouldInterleaveVertices; }

-(void) setShouldInterleaveVertices: (BOOL) shouldInterleave {
	shouldInterleaveVertices = shouldInterleave;
	if (!shouldInterleaveVertices)
		LogInfo(@"%@ has been configured to use non-interleaved vertex content. To improve performance, it is recommended that you interleave all vertex content, unless you need to frequently update one type of vertex content without updating the others.", self);
}

// Deprecated property.
-(BOOL) interleaveVertices { return self.shouldInterleaveVertices; }
-(void) setInterleaveVertices: (BOOL) shouldInterleave { self.shouldInterleaveVertices = shouldInterleave; }

-(CC3Vector) centerOfGeometry {
	return vertexLocations ? vertexLocations.centerOfGeometry : [super centerOfGeometry];
}

-(CC3BoundingBox) boundingBox {
	return vertexLocations ? vertexLocations.boundingBox : [super boundingBox];
}


#pragma mark CCRGBAProtocol support

-(ccColor3B) color { return vertexColors ? vertexColors.color : ccBLACK; }

-(void) setColor: (ccColor3B) aColor { vertexColors.color = aColor; }

-(GLubyte) opacity { return vertexColors ? vertexColors.opacity : 0; }

-(void) setOpacity: (GLubyte) opacity { vertexColors.opacity = opacity; }


#pragma mark Texture coordinates

-(GLuint) textureCoordinatesArrayCount {
	return (overlayTextureCoordinates ? overlayTextureCoordinates.count : 0) + (vertexTextureCoordinates ? 1 : 0);
}

-(void) addTextureCoordinates: (CC3VertexTextureCoordinates*) vtxTexCoords {
	NSAssert(vtxTexCoords, @"Overlay texture cannot be nil");
	NSAssert1(!overlayTextureCoordinates || ((overlayTextureCoordinates.count + 1) <
											 [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value),
			  @"Too many overlaid textures. This platform only supports %i texture units.",
			  [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value);
	LogTrace(@"Adding %@ to %@", vtxTexCoords, self);
	
	// Set the first texture coordinates into vertexTextureCoordinates
	if (!vertexTextureCoordinates) {
		self.vertexTextureCoordinates = vtxTexCoords;
	} else {
		// Add subsequent texture coordinate arrays to the array of overlayTextureCoordinates,
		// creating it first if necessary
		if(!overlayTextureCoordinates) {
			overlayTextureCoordinates = [[CCArray array] retain];
		}
		[overlayTextureCoordinates addObject: vtxTexCoords];
		[vtxTexCoords deriveNameFrom: self];
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

// If first texture unit, return vertexTextureCoordinates property.
// Otherwise, if texUnit within bounds of overlays, get overlay.
// Otherwise, look up the texture coordinates for the previous texture unit
// recursively until one is found, or we reach first texture unit.
-(CC3VertexTextureCoordinates*) textureCoordinatesForTextureUnit: (GLuint) texUnit {
	if (texUnit == 0) {
		return vertexTextureCoordinates;
	} else if (texUnit < self.textureCoordinatesArrayCount) {
		return [overlayTextureCoordinates objectAtIndex: (texUnit - 1)];
	} else {
		return [self textureCoordinatesForTextureUnit: (texUnit - 1)];
	}
}

-(void) setTextureCoordinates: (CC3VertexTextureCoordinates *) aTexCoords
			   forTextureUnit: (GLuint) texUnit {
	NSAssert(aTexCoords, @"Overlay texture coordinates cannot be nil");
	if (texUnit == 0) {
		self.vertexTextureCoordinates = aTexCoords;
	} else if (texUnit < self.textureCoordinatesArrayCount) {
		[overlayTextureCoordinates fastReplaceObjectAtIndex: (texUnit - 1) withObject: aTexCoords];
	} else {
		[self addTextureCoordinates: aTexCoords];
	}
}

-(BOOL) expectsVerticallyFlippedTextures {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		if ( [self expectsVerticallyFlippedTextureInTextureUnit: texUnit] ) return YES;
	}
	return NO;
}

-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		[self expectsVerticallyFlippedTexture: expectsFlipped inTextureUnit: texUnit];
	}
}

-(BOOL) expectsVerticallyFlippedTextureInTextureUnit: (GLuint) texUnit {
	return [self textureCoordinatesForTextureUnit: texUnit].expectsVerticallyFlippedTextures;
}

-(void) expectsVerticallyFlippedTexture: (BOOL) expectsFlipped inTextureUnit: (GLuint) texUnit {
	[self textureCoordinatesForTextureUnit: texUnit].expectsVerticallyFlippedTextures = expectsFlipped;
}

-(void) alignTextureUnit: (GLuint) texUnit withTexture: (CC3Texture*) aTexture {
	[[self textureCoordinatesForTextureUnit: texUnit] alignWithTexture: aTexture];
}

// Deprecated
-(void) deprecatedAlignWithTexturesIn: (CC3Material*) aMaterial {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		CC3Texture* tex = [aMaterial textureForTextureUnit: texUnit];
		[[self textureCoordinatesForTextureUnit: texUnit] alignWithTexture: tex];
	}
}

// Deprecated texture inversion template method. Inversion is now automatic.
-(void) deprecatedAlign: (CC3VertexTextureCoordinates*) texCoords
	withInvertedTexture: (CC3Texture*) aTexture {
	[texCoords alignWithTexture: aTexture];
}
// Deprecated - invert or not depends on subclass.
-(void) deprecatedAlignWithInvertedTexturesIn: (CC3Material*) aMaterial {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		CC3Texture* tex = [aMaterial textureForTextureUnit: texUnit];
		[self deprecatedAlign: [self textureCoordinatesForTextureUnit: texUnit] withInvertedTexture: tex];
	}
}

-(void) flipVerticallyTextureUnit: (GLuint) texUnit {
	[[self textureCoordinatesForTextureUnit: texUnit] flipVertically];
}

-(void) flipTexturesVertically {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		[[self textureCoordinatesForTextureUnit: texUnit] flipVertically];
	}
}

-(void) flipHorizontallyTextureUnit: (GLuint) texUnit {
	[[self textureCoordinatesForTextureUnit: texUnit] flipHorizontally];
}

-(void) flipTexturesHorizontally {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		[[self textureCoordinatesForTextureUnit: texUnit] flipHorizontally];
	}
}

-(void) repeatTexture: (ccTex2F) repeatFactor forTextureUnit: (GLuint) texUnit {
	[[self textureCoordinatesForTextureUnit: texUnit] repeatTexture: repeatFactor];
}

-(void) repeatTexture: (ccTex2F) repeatFactor {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint texUnit = 0; texUnit < tcCount; texUnit++) {
		[[self textureCoordinatesForTextureUnit: texUnit] repeatTexture: repeatFactor];
	}
}

-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	return texCoords ? texCoords.textureRectangle : kCC3UnitTextureRectangle;
}

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {
	[self textureCoordinatesForTextureUnit: texUnit].textureRectangle = aRect;
}

-(CGRect) textureRectangle { return [self textureRectangleForTextureUnit: 0]; }

-(void) setTextureRectangle: (CGRect) aRect {
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint i = 0; i < tcCount; i++) {
		[self textureCoordinatesForTextureUnit: i].textureRectangle = aRect;
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		shouldInterleaveVertices = YES;
		vertexLocations = nil;
		vertexNormals = nil;
		vertexColors = nil;
		vertexTextureCoordinates = nil;
		overlayTextureCoordinates = nil;
		vertexIndices = nil;
		capacityExpansionFactor = 1.25;
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
			[self addTextureCoordinates: [otc autoreleasedCopy]];		// retained by collection
		}
	}

	self.vertexIndices = another.vertexIndices;							// retained but not copied
	shouldInterleaveVertices = another.shouldInterleaveVertices;
	capacityExpansionFactor = another.capacityExpansionFactor;
}

/**
 * If the interleavesVertices property is set to NO, creates GL vertex buffer objects for all
 * vertex arrays used by this mesh by invoking createGLBuffer on each contained vertex array.
 *
 * If the shouldInterleaveVertices property is set to YES, indicating that the underlying data is
 * shared across the contained vertex arrays, this method invokes createGLBuffer only on the
 * vertexLocations and vertexIndices vertex arrays, and copies the bufferID property from
 * the vertexLocations vertex array to the other vertex arrays (except vertexIndicies).
 */
-(void) createGLBuffers {
	[vertexLocations createGLBuffer];
	if (shouldInterleaveVertices) {
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

-(BOOL) isUsingGLBuffers {
	if (vertexLocations && vertexLocations.isUsingGLBuffer) return YES;
	if (vertexNormals && vertexNormals.isUsingGLBuffer) return YES;
	if (vertexColors && vertexColors.isUsingGLBuffer) return YES;
	if (vertexTextureCoordinates && vertexTextureCoordinates.isUsingGLBuffer) return YES;
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		if (otc.isUsingGLBuffer) return YES;
	}
	return NO;
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

-(void) retainVertexContent {
	[self retainVertexLocations];
	[self retainVertexNormals];
	[self retainVertexColors];
	[self retainVertexTextureCoordinates];
}

-(void) retainVertexLocations { vertexLocations.shouldReleaseRedundantData = NO; }

-(void) retainVertexNormals {
	if ( !self.hasVertexNormals ) return;

	if (shouldInterleaveVertices) [self retainVertexLocations];
	vertexNormals.shouldReleaseRedundantData = NO;
}

-(void) retainVertexColors {
	if ( !self.hasVertexColors ) return;

	if (shouldInterleaveVertices) [self retainVertexLocations];
	vertexColors.shouldReleaseRedundantData = NO;
}

-(void) retainVertexTextureCoordinates {
	if ( !self.hasVertexTextureCoordinates ) return;

	if (shouldInterleaveVertices) [self retainVertexLocations];
	vertexTextureCoordinates.shouldReleaseRedundantData = NO;
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		otc.shouldReleaseRedundantData = NO;
	}
}

-(void) retainVertexIndices { vertexIndices.shouldReleaseRedundantData = NO; }

-(void) doNotBufferVertexContent {
	[self doNotBufferVertexLocations];
	[self doNotBufferVertexNormals];
	[self doNotBufferVertexColors];
	[self doNotBufferVertexTextureCoordinates];
}

-(void) doNotBufferVertexLocations { vertexLocations.shouldAllowVertexBuffering = NO; }

-(void) doNotBufferVertexNormals {
	if (shouldInterleaveVertices) [self doNotBufferVertexLocations];
	vertexNormals.shouldAllowVertexBuffering = NO;
}

-(void) doNotBufferVertexColors {
	if (shouldInterleaveVertices) [self doNotBufferVertexLocations];
	vertexColors.shouldAllowVertexBuffering = NO;
}

-(void) doNotBufferVertexTextureCoordinates {
	if (shouldInterleaveVertices) [self doNotBufferVertexLocations];
	vertexTextureCoordinates.shouldAllowVertexBuffering = NO;
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		otc.shouldAllowVertexBuffering = NO;
	}
}

-(void) doNotBufferVertexIndices { vertexIndices.shouldAllowVertexBuffering = NO; }


#pragma mark Updating

-(void) updateGLBuffersStartingAt: (GLuint) offsetIndex forLength: (GLuint) vertexCount {
	[vertexLocations updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
	if ( !shouldInterleaveVertices ) {
		[vertexNormals updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		[vertexColors updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		[vertexTextureCoordinates updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			[otc updateGLBufferStartingAt: offsetIndex forLength: vertexCount];
		}
	}
}

-(void) updateGLBuffers { [self updateGLBuffersStartingAt: 0 forLength: self.vertexCount]; }

-(void) updateVertexLocationsGLBuffer { [vertexLocations updateGLBuffer]; }

-(void) updateVertexNormalsGLBuffer { [vertexNormals updateGLBuffer]; }

-(void) updateVertexColorsGLBuffer { [vertexColors updateGLBuffer]; }

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {
	[[self textureCoordinatesForTextureUnit: texUnit] updateGLBuffer];
}

-(void) updateVertexIndicesGLBuffer { [vertexIndices updateGLBuffer]; }


#pragma mark Drawing

-(GLenum) drawingMode {
	if (vertexIndices) return vertexIndices.drawingMode;
	if (vertexLocations) return vertexLocations.drawingMode;
	return super.drawingMode;
}

-(void) setDrawingMode: (GLenum) aMode {
	vertexIndices.drawingMode = aMode;
	vertexLocations.drawingMode = aMode;
}

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

/**
 * Returns a bounding volume that first checks against the spherical boundary, and then checks
 * against a bounding box. The spherical boundary is fast to check, but is not as accurate as
 * the bounding box for many meshes. The bounding box is more accurate, but is more expensive
 * to check than the spherical boundary. The bounding box is only checked if the spherical
 * boundary does not indicate that the mesh is outside the frustum.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	return [CC3NodeSphereThenBoxBoundingVolume vertexLocationsSphereandBoxBoundingVolume];
}


#pragma mark Managing vertex data

-(CC3VertexContent) vertexContentTypes {
	CC3VertexContent vtxContent = kCC3VertexContentNone;
	if (self.hasVertexLocations) vtxContent |= kCC3VertexContentLocation;
	if (self.hasVertexNormals) vtxContent |= kCC3VertexContentNormal;
	if (self.hasVertexColors) vtxContent |= kCC3VertexContentColor;
	if (self.hasVertexTextureCoordinates) vtxContent |= kCC3VertexContentTextureCoordinates;
	return vtxContent;
}

-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	[self createVertexContent: vtxContentTypes];
	[self updateVertexStride];
}

-(void) createVertexContent: (CC3VertexContent) vtxContentTypes {

	// Always create a new vertex locations
	if (!vertexLocations) self.vertexLocations = [CC3VertexLocations vertexArray];
	
	// Vertex normals
	if (vtxContentTypes & kCC3VertexContentNormal) {
		if (!vertexNormals) self.vertexNormals = [CC3VertexNormals vertexArray];
	} else {
		self.vertexNormals = nil;
	}

	// Vertex colors
	if (vtxContentTypes & kCC3VertexContentColor) {
		if (!vertexColors) {
			CC3VertexColors* vCols = [CC3VertexColors vertexArray];
			vCols.elementType = GL_UNSIGNED_BYTE;
			self.vertexColors = vCols;
		}
	} else {
		self.vertexColors = nil;
	}
	
	// Vertex texture coordinates
	if (vtxContentTypes & kCC3VertexContentTextureCoordinates) {
		if (!vertexTextureCoordinates) self.vertexTextureCoordinates = [CC3VertexTextureCoordinates vertexArray];
	} else {
		[self removeAllTextureCoordinates];
	}
}

-(GLuint) vertexStride {
	GLuint stride = 0;
	if (vertexLocations) stride += vertexLocations.elementLength;
	if (vertexNormals) stride += vertexNormals.elementLength;
	if (vertexColors) stride += vertexColors.elementLength;
	if (vertexTextureCoordinates) stride += vertexTextureCoordinates.elementLength;
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		stride += otc.elementLength;
	}
	return stride;
}

-(void) setVertexStride: (GLuint) vtxStride {
	if (shouldInterleaveVertices) {
		vertexLocations.vertexStride = vtxStride;
		vertexNormals.vertexStride = vtxStride;
		vertexColors.vertexStride = vtxStride;
		vertexTextureCoordinates.vertexStride = vtxStride;
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			otc.vertexStride = vtxStride;
		}
	}
}

-(GLuint) updateVertexStride {
	GLuint stride = 0;
	
	if (vertexLocations) {
		if (shouldInterleaveVertices) vertexLocations.elementOffset = stride;
		stride += vertexLocations.elementLength;
	}
	if (vertexNormals) {
		if (shouldInterleaveVertices) vertexNormals.elementOffset = stride;
		stride += vertexNormals.elementLength;
	}
	if (vertexColors) {
		if (shouldInterleaveVertices) vertexColors.elementOffset = stride;
		stride += vertexColors.elementLength;
	}
	if (vertexTextureCoordinates) {
		if (shouldInterleaveVertices) vertexTextureCoordinates.elementOffset = stride;
		stride += vertexTextureCoordinates.elementLength;
	}
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		if (shouldInterleaveVertices) otc.elementOffset = stride;
		stride += otc.elementLength;
	}
	
	self.vertexStride = stride;
	return stride;
}

-(GLuint) allocatedVertexCapacity { return vertexLocations ? vertexLocations.allocatedVertexCapacity : 0; }

-(void) setAllocatedVertexCapacity: (GLuint) vtxCount {
	if (!vertexLocations) self.vertexLocations = [CC3VertexLocations vertexArray];
	vertexLocations.allocatedVertexCapacity = vtxCount;
	if (self.shouldInterleaveVertices) {
		[vertexNormals interleaveWith: vertexLocations];
		[vertexColors interleaveWith: vertexLocations];
		[vertexTextureCoordinates interleaveWith: vertexLocations];
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			[otc interleaveWith: vertexLocations];
		}
	} else {
		vertexNormals.allocatedVertexCapacity = vtxCount;
		vertexColors.allocatedVertexCapacity = vtxCount;
		vertexTextureCoordinates.allocatedVertexCapacity = vtxCount;
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			otc.allocatedVertexCapacity = vtxCount;
		}
	}
}

-(BOOL) ensureVertexCapacity: (GLuint) vtxCount {
	GLuint currVtxCap = self.allocatedVertexCapacity;
	if (currVtxCap > 0 && currVtxCap < vtxCount) {
		self.allocatedVertexCapacity = (vtxCount * self.capacityExpansionFactor);
		return (self.allocatedVertexCapacity > currVtxCap);
	}
	return NO;
}

-(BOOL) ensureCapacity: (GLuint) vtxCount { return [self ensureVertexCapacity: vtxCount]; }

-(GLvoid*) interleavedVertices {
	return (shouldInterleaveVertices && vertexLocations) ? vertexLocations.vertices : NULL;
}

-(GLuint) vertexCount { return vertexLocations ? vertexLocations.vertexCount : 0; }

-(void) setVertexCount: (GLuint) vCount {
	// If we're attempting to set too many vertices for indexed drawing, log an error, but don't abort.
	if(vertexIndices && (vCount > (kCC3MaxGLushort + 1))) LogError(@"Setting vertexCount property of %@ to %i vertices. This mesh uses indexed drawing, which is limited by OpenGL ES to %i vertices. Vertices beyond that limit will not be drawn.", self, vCount, (kCC3MaxGLushort + 1));
	
	vertexLocations.vertexCount = vCount;
	vertexNormals.vertexCount = vCount;
	vertexColors.vertexCount = vCount;
	vertexTextureCoordinates.vertexCount = vCount;
	for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
		otc.vertexCount = vCount;
	}
}

-(GLuint) allocatedVertexIndexCapacity { return vertexIndices ? vertexIndices.allocatedVertexCapacity : 0; }

-(void) setAllocatedVertexIndexCapacity: (GLuint) vtxCount {
	if ( !vertexIndices && vtxCount > 0 ) self.vertexIndices = [CC3VertexIndices vertexArray];
	vertexIndices.allocatedVertexCapacity = vtxCount;
}

-(GLuint) vertexIndexCount { return vertexIndices ? vertexIndices.vertexCount : self.vertexCount; }

-(void) setVertexIndexCount: (GLuint) vCount { vertexIndices.vertexCount = vCount; }

-(void) moveMeshOriginTo: (CC3Vector) aLocation { [vertexLocations moveMeshOriginTo: aLocation]; }

-(void) moveMeshOriginToCenterOfGeometry { [vertexLocations moveMeshOriginToCenterOfGeometry]; }

-(CC3Vector) vertexLocationAt: (GLuint) index {
	return vertexLocations ? [vertexLocations locationAt: index] : kCC3VectorZero;
}

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index {
	[vertexLocations setLocation: aLocation at: index];
}

-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index {
	return vertexLocations ? [vertexLocations homogeneousLocationAt: index] : kCC3Vector4ZeroLocation;
}

-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index {
	[vertexLocations setHomogeneousLocation: aLocation at: index];
}

-(CC3Vector) vertexNormalAt: (GLuint) index {
	return vertexNormals ? [vertexNormals normalAt: index] : kCC3VectorUnitZPositive;
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index {
	[vertexNormals setNormal: aNormal at: index];
}

-(ccColor4F) vertexColor4FAt: (GLuint) index {
	return vertexColors ? [vertexColors color4FAt: index] : kCCC4FBlackTransparent;
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index {
	[vertexColors setColor4F: aColor at: index];
}

-(ccColor4B) vertexColor4BAt: (GLuint) index {
	return vertexColors ? [vertexColors color4BAt: index] : (ccColor4B){ 0, 0, 0, 0 };
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index {
	[vertexColors setColor4B: aColor at: index];
}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	return texCoords ? [texCoords texCoord2FAt: index] : (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index {
	CC3VertexTextureCoordinates* texCoords = [self textureCoordinatesForTextureUnit: texUnit];
	[texCoords setTexCoord2F: aTex2F at: index];
}

-(GLuint) vertexIndexAt: (GLuint) index {
	return vertexIndices ? [vertexIndices indexAt: index] : 0;
}

-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index {
	[vertexIndices setIndex: vertexIndex at: index];
}

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx {
	[vertexLocations copyVertices: vtxCount from: srcIdx to: dstIdx];
	if ( !shouldInterleaveVertices ) {
		[vertexNormals copyVertices: vtxCount from: srcIdx to: dstIdx];
		[vertexColors copyVertices: vtxCount from: srcIdx to: dstIdx];
		[vertexTextureCoordinates copyVertices: vtxCount from: srcIdx to: dstIdx];
		for (CC3VertexTextureCoordinates* otc in overlayTextureCoordinates) {
			[otc copyVertices: vtxCount from: srcIdx to: dstIdx];
		}
	}
}

-(void) copyVertices: (GLuint) vtxCount
				from: (GLuint) srcIdx
			  inMesh: (CC3VertexArrayMesh*) srcMesh
				  to: (GLuint) dstIdx {
	// If both meshes have the same interleaved content,
	// the copying can be optimized to a memory copy.
	if ((self.vertexContentTypes == srcMesh.vertexContentTypes) &&
		self.vertexStride == srcMesh.vertexStride &&
		(self.shouldInterleaveVertices && srcMesh.shouldInterleaveVertices)) {
			LogTrace(@"%@ using optimized memory copy from %@ due to identical vertex content.", self, srcMesh);
			[self.vertexLocations copyVertices: vtxCount
								   fromAddress: srcMesh.interleavedVertices
											to: dstIdx];
	} else {
		// Can't optimize, so must default to copying vertex element by vertex element
		LogTrace(@"%@ using vertex-by-vertex copy from %@ due to different vertex content.", self, srcMesh);
		for (GLuint i = 0; i < vtxCount; i++) {
			[self copyVertexAt: (srcIdx + i) from: srcMesh to: (dstIdx + i)];
		}
	}
}

-(void) copyVertexAt: (GLuint) srcIdx from: (CC3VertexArrayMesh*) srcMesh to: (GLuint) dstIdx {
	if (self.hasVertexLocations) [self setVertexLocation: [srcMesh vertexLocationAt: srcIdx] at: dstIdx];
	if (self.hasVertexNormals) [self setVertexNormal: [srcMesh vertexNormalAt: srcIdx] at: dstIdx];
	if (self.hasVertexColors) [self setVertexColor4F: [srcMesh vertexColor4FAt: srcIdx] at: dstIdx];
	GLuint tcCount = self.textureCoordinatesArrayCount;
	for (GLuint i = 0; i < tcCount; i++) {
		[self setVertexTexCoord2F: [srcMesh vertexTexCoord2FForTextureUnit: i at: srcIdx] forTextureUnit: i at: dstIdx];
	}
}

-(void) copyVertexIndices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx offsettingBy: (GLint) offset {
	[vertexIndices copyVertices: vtxCount from: srcIdx to: dstIdx offsettingBy: offset];
}

-(void) copyVertexIndices: (GLuint) vtxCount
					 from: (GLuint) srcIdx
				   inMesh: (CC3VertexArrayMesh*) srcMesh
					   to: (GLuint) dstIdx
			 offsettingBy: (GLint) offset {

	if ( !vertexIndices ) return;	// If there are no vertex indices, leave

	CC3VertexIndices* srcVtxIdxs = srcMesh.vertexIndices;
	if (srcVtxIdxs) {
		// If the template mesh has vertex indices, copy them over and offset them.
		// If both vertex index arrays are of the same type, we can optimize to a fast copy.
		if (srcVtxIdxs.elementType == vertexIndices.elementType) {
			[vertexIndices copyVertices: vtxCount
							fromAddress: [srcVtxIdxs addressOfElement: srcIdx]
									 to: dstIdx
						   offsettingBy: offset];
		} else {
			for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
				GLuint srcVtx = [srcVtxIdxs indexAt: (srcIdx + vtxIdx)];
				[vertexIndices setIndex: (srcVtx + offset) at: (dstIdx + vtxIdx)];
			}
		}
	} else {
		// If the source mesh does NOT have vertex indices, manufacture one for each vertex,
		// simply pointing directly to that vertex, taking the offset into consideration.
		// There will be a 1:1 mapping of indices to vertices.
		for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
			[vertexIndices setIndex: (offset + vtxIdx) at: (dstIdx + vtxIdx)];
		}
	}
}


#pragma mark Faces

-(GLuint) faceCount {
	if (vertexIndices) return vertexIndices.faceCount;
	if (vertexLocations) return vertexLocations.faceCount;
	return 0;
}

-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices {
	return vertexLocations ? [vertexLocations faceFromIndices: faceIndices] : kCC3FaceZero; 
}

-(CC3FaceIndices) uncachedFaceIndicesAt: (GLuint) faceIndex {
	if (vertexIndices) return [vertexIndices faceIndicesAt: faceIndex];
	if (vertexLocations) return [vertexLocations faceIndicesAt: faceIndex];
	NSAssert1(NO, @"%@ has no drawable vertex array and cannot retrieve indices for a face.", self);
	return kCC3FaceIndicesZero;
}

-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc {
	if (vertexIndices) return [vertexIndices faceCountFromVertexIndexCount: vc];
	if (vertexLocations) return [vertexLocations faceCountFromVertexIndexCount: vc];
	NSAssert1(NO, @"%@ has no drawable vertex array and cannot convert vertex count to face count.", self);
	return 0;
}

-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc {
	if (vertexIndices) return [vertexIndices vertexIndexCountFromFaceCount: fc];
	if (vertexLocations) return [vertexLocations vertexIndexCountFromFaceCount: fc];
	NSAssert1(NO, @"%@ has no drawable vertex array and cannot convert face count to vertex count.", self);
	return 0;
}


#pragma mark Mesh context switching

+(void) resetSwitching {
	[super resetSwitching];
	[CC3VertexArray resetAllSwitching];
}

@end


#pragma mark -
#pragma mark Bounding Volumes

/** Methods to support bounding volumes based on vertex locations. */
@interface CC3NodeBoundingVolume (VertexLocationsBoundingVolume)

/** The vertex locations array from the mesh. */
-(CC3VertexLocations*) vertexLocations;

@end

@implementation CC3NodeBoundingVolume (VertexLocationsBoundingVolume)

-(CC3VertexLocations*) vertexLocations {
	return ((CC3VertexArrayMesh*)((CC3MeshNode*)self.node).mesh).vertexLocations;
}

@end

#pragma mark -
#pragma mark CC3VertexLocationsBoundingVolume implementation

@implementation CC3VertexLocationsBoundingVolume

-(void) buildVolume { centerOfGeometry = self.vertexLocations.centerOfGeometry; }


#pragma mark Drawing bounding volume

-(BOOL) shouldDraw { return shouldDraw; }

-(void) setShouldDraw: (BOOL) shdDraw {}

@end


#pragma mark -
#pragma mark CC3VertexLocationsSphericalBoundingVolume implementation

@implementation CC3VertexLocationsSphericalBoundingVolume

/**
 * Find the sphere that currently encompasses all the vertices. Then, if we should maximize
 * the boundary, find the sphere that is the union of that sphere, and the sphere that
 * previously encompassed all the vertices. Otherwise, just use the new sphere.
 */
-(void) buildVolume {
	CC3VertexLocations* vtxLocs = self.vertexLocations;
	CC3Vector newCOG = vtxLocs.centerOfGeometry;
	GLfloat newRadius = vtxLocs.radius + self.node.boundingVolumePadding;
	
	if (shouldMaximize) {
		CC3Sphere unionSphere = CC3SphereUnion(CC3SphereMake(newCOG, newRadius),
											   CC3SphereMake(centerOfGeometry, radius));
		centerOfGeometry = unionSphere.center;
		radius = unionSphere.radius;
	} else {
		centerOfGeometry = newCOG;
		radius = newRadius;
	}
}

@end


#pragma mark -
#pragma mark CC3VertexLocationsBoundingBoxVolume implementation

@implementation CC3VertexLocationsBoundingBoxVolume

/**
 * Find the bounding box that currently encompasses all the vertices. Then, if we should maximize
 * the boundary, find the bounding box that is the union of that bounding box, and the bounding
 * box that previously encompassed all the vertices. Otherwise, just use the new bounding box.
 */
-(void) buildVolume {
	CC3BoundingBox newBB = ((CC3MeshNode*)self.node).localContentBoundingBox;	// Includes possible padding
	boundingBox = shouldMaximize ? CC3BoundingBoxUnion(newBB, boundingBox) : newBB;
	centerOfGeometry = CC3BoundingBoxCenter(boundingBox);
}

@end


#pragma mark -
#pragma mark CC3NodeSphereThenBoxBoundingVolume extension

@implementation CC3NodeSphereThenBoxBoundingVolume (VertexLocationsBoundingVolume)

+(id) vertexLocationsSphereandBoxBoundingVolume {
	return [self boundingVolumeWithSphere: [CC3VertexLocationsSphericalBoundingVolume boundingVolume]
								   andBox: [CC3VertexLocationsBoundingBoxVolume boundingVolume]];
}

@end




