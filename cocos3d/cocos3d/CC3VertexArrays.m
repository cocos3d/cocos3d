/*
 * CC3VertexArrays.m
 *
 * cocos3d 0.7.1
 * Author: Bill Hollings, Chris Myers
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 * Copyright (c) 2011 Chris Myers. All rights reserved.
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
 * See header file CC3VertexArrays.h for full API documentation.
 */

#import "CC3VertexArrays.h"
#import "CC3Mesh.h"
#import "CC3OpenGLES11Utility.h"
#import "CC3OpenGLES11Engine.h"


#pragma mark CC3VertexArray

@interface CC3VertexArray (TemplateMethods)
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor;
@property(nonatomic, readonly) BOOL switchingArray;
@property(nonatomic, readonly) GLsizei availableElementCount;
@end


@implementation CC3VertexArray

@synthesize elements, elementCount, elementSize, elementType, elementStride;
@synthesize bufferID, elementOffset, bufferUsage, capacityExpansionFactor;
@synthesize shouldAllowVertexBuffering, shouldReleaseRedundantData;

-(void) dealloc {
	[self deleteGLBuffer];
	[self deallocateElements];
	[super dealloc];
}

-(GLsizei) elementLength {
	return GLElementTypeSize(elementType) * elementSize;
}

-(GLsizei) elementStride {
	return elementStride ? elementStride : self.elementLength;
}

/**
 * The number of available elements. If the elements have been allocated by this
 * array, that is the number of available elements. Otherwise, if the elements were
 * allocated elsewhere, it is the number specified by the elementCount value.
 */
-(GLsizei) availableElementCount {
	return (allocatedElementCount > 0) ? allocatedElementCount : elementCount;
}

-(GLenum) bufferTarget {
	return GL_ARRAY_BUFFER;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elements = nil;
		elementCount = 0;
		allocatedElementCount = 0;
		elementType = GL_FLOAT;
		elementSize = 3;
		elementStride = 0;
		bufferID = 0;
		bufferUsage = GL_STATIC_DRAW;
		elementOffset = 0;
		shouldAllowVertexBuffering = YES;
		shouldReleaseRedundantData = YES;
		capacityExpansionFactor = 1.25f;
	}
	return self;
}

+(id) vertexArray {
	return [[[self alloc] init] autorelease];
}

+(id) vertexArrayWithTag: (GLuint) aTag {
	return [[[self alloc] initWithTag: aTag] autorelease];
}

+(id) vertexArrayWithName: (NSString*) aName {
	return [[[self alloc] initWithName: aName] autorelease];
}

+(id) vertexArrayWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

-(GLvoid*) interleaveWith: (CC3VertexArray*) otherVtxArray usingOffset: (GLuint) elemOffset {
	self.elements = otherVtxArray.elements;
	self.elementStride = otherVtxArray.elementStride;
	self.elementCount = otherVtxArray.elementCount;
	self.elementOffset = elemOffset;
	return (GLbyte*)elements  + elementOffset;
}

// Protected property for access during copying
-(GLsizei) allocatedElementCount { return allocatedElementCount; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexArray*) another {
	[super populateFrom: another];

	elementType = another.elementType;
	elementSize = another.elementSize;
	elementStride = another.elementStride;
	bufferUsage = another.bufferUsage;
	elementOffset = another.elementOffset;
	capacityExpansionFactor = another.capacityExpansionFactor;
	shouldAllowVertexBuffering = another.shouldAllowVertexBuffering;
	shouldReleaseRedundantData = another.shouldReleaseRedundantData;

	[self deleteGLBuffer];		// Data has yet to be buffered. Get rid of old buffer if necessary.

	// If the original has its data stored in memory that it allocated, allocate the
	// same amount in this copy, and copy the data over. Otherwise, the memory is
	// being managed externally, so simply copy the elements reference over.
	if (another.allocatedElementCount) {
		[self allocateElements: another.allocatedElementCount];
		memcpy(elements, another.elements, (allocatedElementCount * self.elementStride));
	} else {
		elements = another.elements;
	}
	elementCount = another.elementCount;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ elements: %p, count: %i, allocated: %i, elementSize: %i, type: %@, offset: %i, stride: %i",
			[self description],
			elements, elementCount, allocatedElementCount, elementSize,
			NSStringFromGLEnum(elementType),
			elementOffset, elementStride];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3VertexArrays.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedVertexArrayTag;

-(GLuint) nextTag {
	return ++lastAssignedVertexArrayTag;
}

+(void) resetTagAllocation {
	lastAssignedVertexArrayTag = 0;
}


#pragma mark Binding GL artifacts

-(GLvoid*) allocateElements: (GLsizei) elemCount {
	if (elemCount) {
		self.elements = malloc(elemCount * self.elementStride);	// Safely disposes existing elements
		allocatedElementCount = elemCount;
		elementCount = elemCount;
		LogTrace(@"%@ allocated space for %u elements", self, elementCount);
	} else {
		[self deallocateElements];
	}
	return elements;
}

-(GLvoid*) reallocateElements: (GLsizei) elemCount {
	if (elemCount) {
		GLvoid* newElems = realloc(elements, (elemCount * self.elementStride));
		if (newElems) {
			elements = newElems;
			allocatedElementCount = elemCount;
			elementCount = elemCount;
			LogTrace(@"%@ reallocated space for %u elements", self, elementCount);
		}
	} else {
		[self deallocateElements];
	}
	return elements;
}

// If memory was previously allocated, and its currently too low, reallocate
-(BOOL) ensureCapacity: (GLsizei) elemCount {
	if (allocatedElementCount && allocatedElementCount < elemCount) {
		[self reallocateElements: (elemCount * capacityExpansionFactor)];
		return YES;
	}
	return NO;
}

// Does not change elementCount, because that is used for drawing.
-(void) deallocateElements {
	if (allocatedElementCount) {
		free(elements);
		allocatedElementCount = 0;
		LogTrace(@"%@ deallocated %u previously allocated elements", self, elementCount);
	}
	elements = NULL;
}

-(void) setElements: (GLvoid*) elems {
	[self deallocateElements];		// Safely disposes existing elements
	elements = elems;
}

-(void) createGLBuffer {
	if (shouldAllowVertexBuffering && !bufferID) {
		CC3OpenGLES11VertexArrays* gles11Vertices = [CC3OpenGLES11Engine engine].vertices;
		CC3OpenGLES11StateTrackerArrayBufferBinding* bufferBinding = [gles11Vertices bufferBinding: self.bufferTarget];

		LogTrace(@"%@ creating GL server buffer", self);
		bufferID =[gles11Vertices generateBuffer];
		GLsizeiptr buffSize = self.elementStride * self.availableElementCount;
		bufferBinding.value = bufferID;
		[bufferBinding loadBufferData: elements ofLength: buffSize forUse: bufferUsage];
		GLenum errCode = glGetError();
		if (errCode) {
			LogInfo(@"Could not create GL buffer of type %@ because of %@. Using app memory arrays.",
					NSStringFromGLEnum(self.bufferTarget), GetGLErrorText(errCode));
			[self deleteGLBuffer];
		}
		[bufferBinding unbind];
	} else {
		LogTrace(@"%@ NOT creating GL server buffer because shouldAllowVertexBuffering is %@ or bufferID is %i",
				 self, NSStringFromBoolean(shouldAllowVertexBuffering), bufferID);
	}
}

-(void) updateGLBufferStartingAt: (GLuint) offsetIndex forLength: (GLsizei) elemCount {
	if (bufferID) {
		CC3OpenGLES11StateTrackerArrayBufferBinding* bufferBinding;
		LogTrace(@"%@ updating GL server buffer with %i bytes starting at %i", self, length, offset);
		GLsizei elemStride = self.elementStride;
		bufferBinding = [[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget];
		bufferBinding.value = bufferID;
		NSAssert1(elements, @"%@ GL buffer cannot be updated because vertex data has been released", self); 
		[bufferBinding updateBufferData: elements
							 startingAt: (offsetIndex * elemStride)
							  forLength: (elemCount * elemStride)];
		[bufferBinding unbind];
	}
}

-(void) updateGLBuffer {
	[self updateGLBufferStartingAt: 0 forLength: elementCount];
}

-(void) deleteGLBuffer {
	if (bufferID) {
		[[CC3OpenGLES11Engine engine].vertices deleteBuffer: bufferID];
		bufferID = 0;	
	}
}

-(BOOL) isUsingGLBuffer { return bufferID != 0; }

-(void) releaseRedundantData {
	if (bufferID && shouldReleaseRedundantData) {
		[self deallocateElements];
	}
}

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.switchingArray) {
		[self bindGLWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
}

/**
 * Template method that binds the GL engine to the underlying vertex data,
 * in preparation for drawing.
 *
 * If the data has been copied into a VBO in GL memory, binds the GL engine to the bufferID
 * property, and invokes bindPointer: with the value of the elementOffset property.
 * If a VBO is not used, unbinds the GL from any VBO's, and invokes bindPointer: with a pointer
 * to the first data element managed by this vertex array instance.
 */
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (bufferID) {											// use GL buffer if it exists
		LogTrace(@"%@ binding GL buffer containing %u elements", self, elementCount);
		[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget].value = bufferID;
		[self bindPointer: (GLvoid*)elementOffset withVisitor: visitor];
	} else if (elementCount && elements) {					// use local client array if it exists
		LogTrace(@"%@ using local array containing %u elements", self, elementCount);
		[[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget] unbind];
		[self bindPointer: (GLvoid*)((GLuint)elements + elementOffset) withVisitor: visitor];
	} else {
		LogTrace(@"%@ no elements to bind", self);
	}
}

/**
 * Template method that binds the GL engine to the values of the elementSize, elementType
 * and elementStride properties, along with the specified data pointer, and enables the
 * type of aspect managed by this instance (locations, normals...) in the GL engine.
 *
 * This abstract implementation does nothing. Subclasses will override to handle
 * their particular type of vetex aspect.
 */
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) unbind { [[self class] unbind]; }

// Default does nothing. Subclasses will override.
+(void) unbind {}


#pragma mark Accessing elements

-(GLvoid*) addressOfElement: (GLsizei) index {
	// Check elements still in memory, and if allocated,
	// that index is less than number of vertices allocated
	NSAssert(elements, @"Elements are no longer in application memory.");
	NSAssert2(allocatedElementCount == 0 || index < allocatedElementCount, @"Requested index %i is greater than number of vertices allocated: %i.", index, elementCount);
	return (GLbyte*)elements + (self.elementStride * index) + elementOffset;
}

-(NSString*) describeElements {
	return [self describeElements: elementCount];
}

-(NSString*) describeElements: (GLsizei) elemCount {
	return [self describeElements: elemCount startingAt: 0];
}

-(NSString*) describeElements: (GLsizei) elemCount startingAt: (GLsizei) startElem {
	GLsizei endElem = MIN(startElem + elemCount, elementCount);
	NSMutableString* desc = [NSMutableString stringWithCapacity: ((endElem - startElem) * elementSize * 8)];
	[desc appendFormat: @"Content of %@:", [self fullDescription]];
	if (elements) {
		for (int elemIdx = startElem; elemIdx < endElem; elemIdx++) {
			[desc appendFormat: @"\n\t%i:", elemIdx];
			GLvoid* elemArray = [self addressOfElement: elemIdx];
			for (int eaIdx = 0; eaIdx < elementSize; eaIdx++) {
				switch (elementType) {
					case GL_FLOAT:
						[desc appendFormat: @" %.3f,", ((GLfloat*)elemArray)[eaIdx]];
						break;
					case GL_BYTE:
						[desc appendFormat: @" %i,", ((GLbyte*)elemArray)[eaIdx]];
						break;
					case GL_UNSIGNED_BYTE:
						[desc appendFormat: @" %u,", ((GLubyte*)elemArray)[eaIdx]];
						break;
					case GL_SHORT:
						[desc appendFormat: @" %i,", ((GLshort*)elemArray)[eaIdx]];
						break;
					case GL_UNSIGNED_SHORT:
						[desc appendFormat: @" %u,", ((GLushort*)elemArray)[eaIdx]];
						break;
					case GL_FIXED:
						[desc appendFormat: @" %i,", ((GLfixed*)elemArray)[eaIdx]];
						break;
					default:
						[desc appendFormat: @" unknown type (%u),", elementType];
						break;
				}
			}
		}
	} else {
		[desc appendFormat: @" Elements are no longer in memory."];
	}
	return desc;
}


#pragma mark Array context switching

/**
 * Returns whether this vertex array is different than the vertex array of the same type
 * that was most recently bound to the GL engine. To improve performance, vertex arrays
 * are only bound if they need to be.
 *
 * If appropriate, the application can arrange CC3MeshNodes in the CC3Scene so that nodes
 * using the same vertex arrays are drawn together, to minimize the number of binding
 * changes in the GL engine.
 */
-(BOOL) switchingArray { return YES; }

+(void) resetSwitching {}

+(void) resetAllSwitching {
	[CC3VertexLocations resetSwitching];
	[CC3VertexNormals resetSwitching];
	[CC3VertexColors resetSwitching];
	[CC3VertexTextureCoordinates resetSwitching];
	[CC3VertexIndices resetSwitching];
	[CC3VertexPointSizes resetSwitching];
	[CC3VertexMatrixIndices resetSwitching];
	[CC3VertexWeights resetSwitching];
}

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray

@interface CC3DrawableVertexArray (TemplateMethods)
-(CC3FaceIndices) faceIndicesAt: (GLsizei) faceIndex fromStripOfLength: (GLsizei) stripLen;
@end

@implementation CC3DrawableVertexArray

@synthesize drawingMode, stripCount, stripLengths;

-(void) dealloc {
	[self deallocateStripLengths];
	[super dealloc];
}

-(GLuint) firstElement {
	return 0;
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		drawingMode = GL_TRIANGLE_STRIP;
		stripCount = 0;
		stripLengths = NULL;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3DrawableVertexArray*) another {
	[super populateFrom: another];

	drawingMode = another.drawingMode;

	// Allocate memory for strips, then copy them over
	[self allocateStripLengths: another.stripCount];
	GLuint* otherStripLengths = another.stripLengths;
	for(int i=0; i < stripCount; i++) {
		stripLengths[i] = otherStripLengths[i];
	}
}

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (stripCount) {
		LogTrace(@"%@ drawing %u strips", self, stripCount);
		GLuint startOfStrip = 0;
		for (GLuint i = 0; i < stripCount; i++) {
			GLuint stripLen = stripLengths[i];
			[self drawFrom: startOfStrip forCount: stripLen withVisitor: visitor];
			startOfStrip += stripLen;
		}
	} else {
		[self drawFrom: 0 forCount: elementCount withVisitor: visitor];
	}
}

-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ drawing %u vertices", self, vertexCount);
	CC3PerformanceStatistics* perfStats = visitor.performanceStatistics;
	if (perfStats) {
		[perfStats addSingleCallFacesPresented: [self faceCountFromVertexCount: vertexCount]];
	}
}

-(void) allocateStripLengths: (GLsizei) sCount {
	[self deallocateStripLengths];			// get rid of any existing array
	
	if (sCount) {
		stripCount = sCount;
		stripLengths = calloc(stripCount, sizeof(GLuint));
		stripLengthsAreRetained = YES;
	}
}

-(void) deallocateStripLengths {
	if (stripLengthsAreRetained) {
		free(stripLengths);
		stripLengthsAreRetained = NO;
	}
	stripLengths = nil;
	stripCount = 0;
}

/** Converts the specified vertex count to a face count, based on the drawingMode property. */
-(GLsizei) faceCountFromVertexCount: (GLsizei) vc {
	switch (self.drawingMode) {
		case GL_TRIANGLES:
			return vc / 3;
		case GL_TRIANGLE_STRIP:
		case GL_TRIANGLE_FAN:
			return vc - 2;
		case GL_LINES:
			return vc / 2;
		case GL_LINE_STRIP:
			return vc - 1;
		case GL_LINE_LOOP:
		case GL_POINTS:
			return vc;
		default:
			NSAssert2(NO, @"%@ encountered unknown drawing mode %u", self, self.drawingMode);
			return 0;
	}
}

/** Converts the specified face count to a vertex count, based on the drawingMode property. */
-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc {
	switch (self.drawingMode) {
		case GL_TRIANGLES:
			return fc * 3;
		case GL_TRIANGLE_STRIP:
		case GL_TRIANGLE_FAN:
			return fc + 2;
		case GL_LINES:
			return fc * 2;
		case GL_LINE_STRIP:
			return fc + 1;
		case GL_LINE_LOOP:
		case GL_POINTS:
			return fc;
		default:
			NSAssert2(NO, @"%@ encountered unknown drawing mode %u", self, self.drawingMode);
			return 0;
	}
}

/**
 * If drawing is being done with strips, accumulate the number of faces per strip
 * by converting the number of elements in each strip to faces. Otherwise, simply
 * convert the total number of elements to faces.
 */
-(GLsizei) faceCount {
	if (stripCount) {
		GLsizei fCnt = 0;
		for (GLuint i = 0; i < stripCount; i++) {
			fCnt += [self faceCountFromVertexCount: stripLengths[i]];
		}
		return fCnt;
	} else {
		return [self faceCountFromVertexCount: elementCount];
	}
}

/**
 * If drawing is being done with strips, accumulate the number of faces per strip
 * prior to the strip that contains the specified face, then add the offset to
 * the face within that strip to retrieve the correct face from that strip.
 * If strips are not in use, simply extract the face from the full element array.
 */
-(CC3FaceIndices) faceIndicesAt: (GLsizei) faceIndex {
	if (stripCount) {
		// Mesh is divided into strips. Find the strip that contains the face,
		// by accumulating faces and element counts until we reach the strip
		// that contains the face. Then extract the face from that strip and
		// offset it by the number of elements in all the previous strips.
		GLsizei currStripStartFaceCnt = 0;
		GLsizei nextStripStartFaceCnt = 0;
		GLsizei stripStartVtxCnt = 0;
		for (GLuint i = 0; i < stripCount; i++) {
			GLsizei stripLen = stripLengths[i];
			nextStripStartFaceCnt += [self faceCountFromVertexCount: stripLen];
			if (nextStripStartFaceCnt > faceIndex) {
				CC3FaceIndices faceIndices = [self faceIndicesAt: (faceIndex - currStripStartFaceCnt)
											   fromStripOfLength: stripLen];
				// Offset the indices of the face by the number of elements
				// accumulated from all the previous strips and return them.
				faceIndices.vertices[0] += stripStartVtxCnt;
				faceIndices.vertices[1] += stripStartVtxCnt;
				faceIndices.vertices[2] += stripStartVtxCnt;
				return faceIndices;
			}
			currStripStartFaceCnt = nextStripStartFaceCnt;
			stripStartVtxCnt += stripLen;
		}
		NSAssert3(NO, @"%@ requested face index %i is larger than face count %i",
				  self, faceIndex, [self faceCount]);
		return kCC3FaceIndicesZero;
	} else {
		// Mesh is monolithic. Simply extract the face from the elements array.
		return [self faceIndicesAt: faceIndex fromStripOfLength: elementCount];
	}
}

/**
 * Returns the indicies for the face at the specified face index,
 * within an array of vertices of the specified length.
 */
-(CC3FaceIndices) faceIndicesAt: (GLsizei) faceIndex fromStripOfLength: (GLsizei) stripLen {
	GLsizei firstVtxIdx;			// The first index of the face.
	switch (self.drawingMode) {
		case GL_TRIANGLES:
			firstVtxIdx = faceIndex * 3;
			return CC3FaceIndicesMake(firstVtxIdx, firstVtxIdx + 1, firstVtxIdx + 2);
		case GL_TRIANGLE_STRIP:
			firstVtxIdx = faceIndex;
			if (CC3IntIsEven(faceIndex)) {		// The winding order alternates
				return CC3FaceIndicesMake(firstVtxIdx, firstVtxIdx + 1, firstVtxIdx + 2);
			} else {
				return CC3FaceIndicesMake(firstVtxIdx, firstVtxIdx + 2, firstVtxIdx + 1);
			}
		case GL_TRIANGLE_FAN:
			firstVtxIdx = faceIndex + 1;
			return CC3FaceIndicesMake(0, firstVtxIdx, firstVtxIdx + 1);
		case GL_LINES:
			firstVtxIdx = faceIndex * 2;
			return CC3FaceIndicesMake(firstVtxIdx, firstVtxIdx + 1, 0);
		case GL_LINE_STRIP:
			firstVtxIdx = faceIndex;
			return CC3FaceIndicesMake(firstVtxIdx, firstVtxIdx + 1, 0);
		case GL_LINE_LOOP:
			firstVtxIdx = faceIndex;
			GLsizei nextVtxIdx = (faceIndex < stripLen - 1) ? firstVtxIdx + 1 : 0;
			return CC3FaceIndicesMake(firstVtxIdx, nextVtxIdx, 0);
		case GL_POINTS:
			firstVtxIdx = faceIndex;
			return CC3FaceIndicesMake(firstVtxIdx, 0, 0);
		default:
			NSAssert2(NO, @"%@ encountered unknown drawing mode %u", self, self.drawingMode);
			return kCC3FaceIndicesZero;
	}
}

@end


#pragma mark -
#pragma mark CC3VertexLocations

@interface CC3VertexLocations (TemplateMethods)
-(void) buildBoundingBox;
-(void) buildBoundingBoxIfNecessary;
-(void) calcRadius;
-(void) calcRadiusIfNecessary;
@end


@implementation CC3VertexLocations

@synthesize firstElement;

-(void) markBoundaryDirty {
	boundaryIsDirty = YES;
	radiusIsDirty = YES;
}

-(void) setElements: (GLvoid*) elems {
	[super setElements: elems];
	[self markBoundaryDirty];
}

-(void) setElementCount: (GLsizei) count {
	[super setElementCount: count];
	[self markBoundaryDirty];
}

-(id) init {
	if ( (self = [super init]) ) {
		firstElement = 0;
		centerOfGeometry = kCC3VectorZero;
		boundingBox = kCC3BoundingBoxZero;
		radius = 0.0;
		[self markBoundaryDirty];
	}
	return self;
}

// Protected properties used during copying instances of this class
-(BOOL) boundaryIsDirty { return boundaryIsDirty; }
-(BOOL) radiusIsDirty { return radiusIsDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexLocations*) another {
	[super populateFrom: another];

	firstElement = another.firstElement;
	boundingBox = another.boundingBox;
	centerOfGeometry = another.centerOfGeometry;
	radius = another.radius;
	boundaryIsDirty = another.boundaryIsDirty;
	radiusIsDirty = another.radiusIsDirty;
}

-(CC3Vector) locationAt: (GLsizei) index {
	CC3Vector loc = *(CC3Vector*)[self addressOfElement: index];
	switch (elementSize) {
		case 2:
			loc.z = 0.0f;
		case 3:
		case 4:			// Will just read the first three components
		default:
			break;
	}
	return loc;
}

-(void) setLocation: (CC3Vector) aLocation at: (GLsizei) index {
	GLvoid* elemAddr = [self addressOfElement: index];
	switch (elementSize) {
		case 2:		// Just store X & Y
			*(CGPoint*)elemAddr = *(CGPoint*)&aLocation;
			break;
		case 4:		// Convert to 4D with w = 1
			*(CC3Vector4*)elemAddr = CC3Vector4FromCC3Vector(aLocation, 1.0f);
			break;
		case 3:
		default:
			*(CC3Vector*)elemAddr = aLocation;
			break;
	}
	[self markBoundaryDirty];
}

-(CC3Vector4) homogeneousLocationAt: (GLsizei) index {
	CC3Vector4 hLoc = *(CC3Vector4*)[self addressOfElement: index];
	switch (elementSize) {
		case 2:
			hLoc.z = 0.0f;
		case 3:
			hLoc.w = 1.0f;
		case 4:
		default:
			break;
	}
	return hLoc;
}

-(void) setHomogeneousLocation: (CC3Vector4) aLocation at: (GLsizei) index {
	GLvoid* elemAddr = [self addressOfElement: index];
	switch (elementSize) {
		case 2:		// Just store X & Y
			*(CGPoint*)elemAddr = *(CGPoint*)&aLocation;
			break;
		case 3:		// Truncate to 3D
			*(CC3Vector*)elemAddr = *(CC3Vector*)&aLocation;
			break;
		case 4:		
		default:
			*(CC3Vector4*)elemAddr = aLocation;
			break;
	}
	[self markBoundaryDirty];
}

-(CC3Face) faceAt: (GLsizei) faceIndex {
	return [self faceFromIndices: [self faceIndicesAt: faceIndex]];
}

-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices {
	return CC3FaceMake([self locationAt: faceIndices.vertices[0]],
					   [self locationAt: faceIndices.vertices[1]],
					   [self locationAt: faceIndices.vertices[2]]);
}

/** Returns the boundingBox, building it if necessary. */
-(CC3BoundingBox) boundingBox {
	[self buildBoundingBoxIfNecessary];
	return boundingBox;
}

/** Returns the centerOfGeometry, calculating it via the bounding box if necessary. */
-(CC3Vector) centerOfGeometry {
	[self buildBoundingBoxIfNecessary];
	return centerOfGeometry;
}

/** Builds the bounding box if it needs to be built. */
-(void) buildBoundingBoxIfNecessary {
	if (boundaryIsDirty) {
		[self buildBoundingBox];
	}
}

/** Returns the radius, calculating it if necessary. */
-(GLfloat) radius {
	[self calcRadiusIfNecessary];
	return radius;
}

/** Calculates the radius if it necessary. */
-(void) calcRadiusIfNecessary {
	if (radiusIsDirty) {
		[self calcRadius];
	}
}

/**
 * Calculates and populates the boundingBox and centerOfGeometry properties
 * from the vertex locations.
 *
 * This method is invoked automatically when the bounding box or centerOfGeometry property
 * is accessed for the first time after the elements property has been set.
 */
-(void) buildBoundingBox {
	NSAssert1(elements, @"%@ bounding box requested after elements data have been released", self);
	NSAssert1(elementType == GL_FLOAT, @"%@ must have elementType GLFLOAT to build the bounding box", self);

	CC3Vector vl, vlMin, vlMax;
	vl = (elementCount > 0) ? [self locationAt: 0] : kCC3VectorZero;
	vlMin = vl;
	vlMax = vl;
	for (GLsizei i = 1; i < elementCount; i++) {
		vl = [self locationAt: i];
		vlMin = CC3VectorMinimize(vlMin, vl);
		vlMax = CC3VectorMaximize(vlMax, vl);
	}
	boundingBox.minimum = vlMin;
	boundingBox.maximum = vlMax;
	centerOfGeometry = CC3BoundingBoxCenter(boundingBox);
	boundaryIsDirty = NO;
	LogTrace(@"%@ bounding box: (%@, %@) and center of geometry: %@", self,
			 NSStringFromCC3Vector(boundingBox.minimum),
			 NSStringFromCC3Vector(boundingBox.maximum),
			 NSStringFromCC3Vector(centerOfGeometry));
}


/**
 * Calculates and populates the radius property from the vertex locations.
 *
 * This method is invoked automatically when the radius property is accessed
 * for the first time after the boundary has been marked dirty.
 */
-(void) calcRadius {
	NSAssert1(elementType == GL_FLOAT, @"%@ must have elementType GLFLOAT to calculate mesh radius", [self class]);

	CC3Vector cog = self.centerOfGeometry;		// Will measure it if necessary
	if (elements && elementCount) {
		// Work with the square of the radius so that all distances can be compared
		// without having to run expensive square-root calculations.
		GLfloat radiusSq = 0.0;
		for (GLsizei i=0; i < elementCount; i++) {
			CC3Vector vl = [self locationAt: i];
			GLfloat distSq = CC3VectorDistanceSquared(vl, cog);
			radiusSq = MAX(radiusSq, distSq);
		}
		radius = sqrtf(radiusSq);		// Now finally take the square-root
		radiusIsDirty = NO;
		LogTrace(@"%@ setting radius to %.2f", self, radius);
	}
}

-(void) movePivotTo: (CC3Vector) aLocation {
	for (GLsizei i = 0; i < elementCount; i++) {
		CC3Vector locOld = [self locationAt: i];
		CC3Vector locNew = CC3VectorDifference(locOld, aLocation);
		[self setLocation: locNew at: i];
	}
	[self markBoundaryDirty];
	[self updateGLBuffer];
}

-(void) movePivotToCenterOfGeometry {
	[self movePivotTo: self.centerOfGeometry];
}


#pragma mark Drawing

/** Overridden to ensure the bounding box and radius are built before releasing the vertices. */
-(void) releaseRedundantData {
	[self buildBoundingBoxIfNecessary];
	[self calcRadiusIfNecessary];
	[super releaseRedundantData];
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].vertices.locations useElementsAt: pointer
														  withSize: elementSize
														  withType: elementType
														withStride: elementStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.vertexArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.vertexArray disable];
	[self resetSwitching];
}

-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawFrom: vertexIndex forCount: vertexCount withVisitor: visitor];

	GLuint firstVertex = self.firstElement + (self.elementStride * vertexIndex);
	[[CC3OpenGLES11Engine engine].vertices drawVerticiesAs: drawingMode
												startingAt: firstVertex
												withLength: vertexCount];
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentLocationsTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentLocationsTag != tag;
	currentLocationsTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentLocationsTag = 0;
}

@end


#pragma mark -
#pragma mark CC3VertexNormals

@implementation CC3VertexNormals

-(CC3Vector) normalAt: (GLsizei) index {
	return *(CC3Vector*)[self addressOfElement: index];
}

-(void) setNormal: (CC3Vector) aNormal at: (GLsizei) index {
	*(CC3Vector*)[self addressOfElement: index] = aNormal;
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].vertices.normals useElementsAt: pointer
														withType: elementType
													  withStride: elementStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.normalArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.normalArray disable];
	[self resetSwitching];
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentNormalsTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentNormalsTag != tag;
	currentNormalsTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentNormalsTag = 0;
}

@end


#pragma mark -
#pragma mark CC3VertexColors

@implementation CC3VertexColors

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_FLOAT;
		elementSize = 4;
	}
	return self;
}

-(ccColor4F) color4FAt: (GLsizei) index {
	switch (elementType) {
		case GL_UNSIGNED_BYTE:
			return CCC4FFromCCC4B(*(ccColor4B*)[self addressOfElement: index]);
		case GL_FLOAT:
		default:
			return *(ccColor4F*)[self addressOfElement: index];
	}
}

-(void) setColor4F: (ccColor4F) aColor at: (GLsizei) index {
	switch (elementType) {
		case GL_UNSIGNED_BYTE:
			*(ccColor4B*)[self addressOfElement: index] = CCC4BFromCCC4F(aColor);
			break;
		case GL_FLOAT:
		default:
			*(ccColor4F*)[self addressOfElement: index] = aColor;
	}
}

-(ccColor4B) color4BAt: (GLsizei) index {
	switch (elementType) {
		case GL_FLOAT:
			return CCC4BFromCCC4F(*(ccColor4F*)[self addressOfElement: index]);
		case GL_UNSIGNED_BYTE:
		default:
			return *(ccColor4B*)[self addressOfElement: index];
	}
}

-(void) setColor4B: (ccColor4B) aColor at: (GLsizei) index {
	switch (elementType) {
		case GL_FLOAT:
			*(ccColor4F*)[self addressOfElement: index] = CCC4FFromCCC4B(aColor);
			break;
		case GL_UNSIGNED_BYTE:
		default:
			*(ccColor4B*)[self addressOfElement: index] = aColor;
	}
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	[gles11Engine.vertices.colors useElementsAt: pointer
									   withSize: elementSize
									   withType: elementType
									 withStride: elementStride];
	[gles11Engine.clientCapabilities.colorArray enable];

	// Since material color tracking mucks with both ambient and diffuse material colors under
	// the covers, we won't really know what the ambient and diffuse material color values will
	// be when we get back to setting them...so indicate that to the corresponding trackers.
	gles11Engine.materials.ambientColor.valueIsKnown = NO;
	gles11Engine.materials.diffuseColor.valueIsKnown = NO;
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.colorArray disable];
	[self resetSwitching];
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentColorsTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentColorsTag != tag;
	currentColorsTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentColorsTag = 0;
}

@end


#pragma mark -
#pragma mark CC3VertexTextureCoordinates

@interface CC3VertexTextureCoordinates (TemplateMethods)
@property(nonatomic, readonly) CGSize mapSize;
@property(nonatomic, readonly) CGSize naturalMapSize;
-(void) alignWithTextureRectangle: (CGRect) newRect fromOld: (CGRect) oldRect;
@end

@implementation CC3VertexTextureCoordinates

@synthesize expectsVerticallyFlippedTextures;

-(CGRect) textureRectangle { return textureRectangle; }

-(void) setTextureRectangle: (CGRect) aRect {
	CGRect oldRect = textureRectangle;
	textureRectangle = aRect;
	[self alignWithTextureRectangle: aRect fromOld: oldRect];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_FLOAT;
		elementSize = 2;
		mapSize = CGSizeMake(1, 1);
		naturalMapSize = CGSizeZero;
		textureRectangle = kCC3UnitTextureRectangle;
		expectsVerticallyFlippedTextures = [[self class] defaultExpectsVerticallyFlippedTextures];
	}
	return self;
}

// Protected properties for copying.
-(CGSize) mapSize { return mapSize; }
	
// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexTextureCoordinates*) another {
	[super populateFrom: another];
	
	mapSize = another.mapSize;
	naturalMapSize = another.naturalMapSize;
	textureRectangle = another.textureRectangle;
	expectsVerticallyFlippedTextures = another.expectsVerticallyFlippedTextures;
}

static BOOL defaultExpectsVerticallyFlippedTextures = YES;

+(BOOL) defaultExpectsVerticallyFlippedTextures {
	return defaultExpectsVerticallyFlippedTextures;
}

+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	defaultExpectsVerticallyFlippedTextures = expectsFlipped;
}

-(ccTex2F) texCoord2FAt: (GLsizei) index {
	return *(ccTex2F*)[self addressOfElement: index];
}

-(void) setTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index {
	*(ccTex2F*)[self addressOfElement: index] = aTex2F;
}

/** Extracts the current texture unit from the visitor and binds this vertex array to that texture unit. */
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11TextureUnit* gles11TexUnit = [[CC3OpenGLES11Engine engine].textures textureUnitAt: visitor.textureUnit];
	[gles11TexUnit.textureCoordArray enable];
	[gles11TexUnit.textureCoordinates useElementsAt: pointer
										   withSize: elementSize
										   withType: elementType
										 withStride: elementStride];
	LogTrace(@"%@ bound to %@", self, gles11TexUnit);
}

+(void) unbind: (GLuint) textureUnit {
	LogTrace(@"Unbinding texture unit %u", textureUnit);
	CC3OpenGLES11TextureUnit* gles11TexUnit = [[CC3OpenGLES11Engine engine].textures textureUnitAt: textureUnit];
	[gles11TexUnit.textureCoordArray disable];
}

/**
 * Unbinds all texture units between the specified texture unit index and the maximum number
 * of texture units supported by the platform. This is a convenience method for disabling
 * unused texture units.
 */
+(void) unbindRemainingFrom: (GLuint)textureUnit {
	GLuint maxTexUnits = [CC3OpenGLES11Engine engine].textures.textureUnitCount;
	for (int tu = textureUnit; tu < maxTexUnits; tu++) {
		[self unbind: tu];
	}
}

+(void) unbind { [self unbindRemainingFrom: 0]; }

/**
 * Returns the size of the map as a fraction between zero and one in each dimension.
 * This indicates how much of the texture is covered by this texture coordinate map
 * when the texture is simply overlaid on the mesh, before any textureRectangle is applied.
 *
 * If the value of this property has not yet been measured by one of the
 * alignWith...TextureMapSize: methods, it is measured when first accessed here.
 */
-(CGSize) naturalMapSize {
	if (CGSizeEqualToSize(naturalMapSize, CGSizeZero)) {
		for (GLsizei i = 0; i < elementCount; i++) {
			ccTex2F tc = [self texCoord2FAt: i];
			naturalMapSize.width = MAX(tc.u, naturalMapSize.width);
			naturalMapSize.height = MAX(tc.v, naturalMapSize.height);
		}
	}
	return naturalMapSize;
}

/**
 * Aligns the vertex texture coordinates with the area of the texture defined
 * by the newRect. The oldRect describes the area of the texture that is currently
 * mapped by the texture coordinates.
 */
-(void) alignWithTextureRectangle: (CGRect) newRect fromOld: (CGRect) oldRect {

	// The size of the mapping in its natural state, before slicing out a rectangle 
	GLfloat natWidth = self.naturalMapSize.width;
	GLfloat natHeight = self.naturalMapSize.height;
	
	// Origin of new rect
	GLfloat nx = newRect.origin.x;
	GLfloat ny = newRect.origin.y;
	
	// Origin of old rect
	GLfloat ox = oldRect.origin.x;
	GLfloat oy = oldRect.origin.y;
	
	// Scaling from size of old rect to size of new rect
	GLfloat sw = newRect.size.width / oldRect.size.width;
	GLfloat sh = newRect.size.height / oldRect.size.height;
	
	// Iterate the vertices moving point in old rect to point in new rect.
	// Each of the current U & V are reverted back to the value they would
	// naturally have, without a rectangle,
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];

		GLfloat natU = ptc->u / natWidth;
		ptc->u = (nx + ((natU - ox) * sw)) * natWidth;

		GLfloat natV = ptc->v / natHeight;
		ptc->v = (ny + ((natV - oy) * sh)) * natHeight;
	}
}

-(void) alignWithTextureMapSize: (CGSize) texMapSize {
	NSAssert2((texMapSize.width && texMapSize.height),
			  @"%@ mapsize %@ cannot have zero dimension",
			  self, NSStringFromCGSize(texMapSize));

	// Don't waste time adjusting if nothing is changing
	// (eg. POT textures, or new texture has same texture map as old).
	if (CGSizeEqualToSize(texMapSize, mapSize)) return;
	
	LogCleanTrace(@"%@ aligning and changing map size from %@ to %@ but not flipping vertically",
				  self, NSStringFromCGSize(mapSize), NSStringFromCGSize(texMapSize));

	CGSize mapRatio = CGSizeMake(texMapSize.width / mapSize.width, texMapSize.height / mapSize.height);
	
	naturalMapSize = CGSizeZero;
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u *= mapRatio.width;
		ptc->v *= mapRatio.height;
		
		// While we are remapping, measure the resulting map size at the same time
		naturalMapSize.width = MAX(ptc->u, naturalMapSize.width);
		naturalMapSize.height = MAX(ptc->v, naturalMapSize.height);
	}
	mapSize = texMapSize;	// Remember what we've set the map size to

}

-(void) alignWithInvertedTextureMapSize: (CGSize) texMapSize {
	NSAssert2((texMapSize.width && texMapSize.height),
			  @"%@ mapsize %@ cannot have zero dimension",
			  self, NSStringFromCGSize(texMapSize));
	LogCleanTrace(@"%@ aligning and changing map size from %@ to %@ and flipping vertically",
				  self, NSStringFromCGSize(mapSize), NSStringFromCGSize(texMapSize));
	
	CGSize mapRatio = CGSizeMake(texMapSize.width / mapSize.width, texMapSize.height / mapSize.height);
	
	naturalMapSize = CGSizeZero;
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u *= mapRatio.width;
		ptc->v = texMapSize.height - (ptc->v * mapRatio.height);
		
		// While we are remapping, measure the resulting map size at the same time
		naturalMapSize.width = MAX(ptc->u, naturalMapSize.width);
		naturalMapSize.height = MAX(ptc->v, naturalMapSize.height);
	}

	// Remember that we've flipped and what we've set the map size to
	mapSize = texMapSize;
	expectsVerticallyFlippedTextures = !expectsVerticallyFlippedTextures;
	
	LogCleanTrace(@"%@ aligned and flipped vertically", self);
}

-(void) alignWithTexture: (CC3Texture*) texture {
	if (!texture) return;
	if ( XOR(expectsVerticallyFlippedTextures, texture.isFlippedVertically) ) {
		[self alignWithInvertedTextureMapSize: texture.mapSize];
	} else {
		[self alignWithTextureMapSize: texture.mapSize];
	}
}

-(void) alignWithInvertedTexture: (CC3Texture*) texture {
	if (!texture) return;
	[self alignWithInvertedTextureMapSize: texture.mapSize];
}

-(void) flipVertically {
	GLfloat minV = CGFLOAT_MAX;
	GLfloat maxV = -CGFLOAT_MAX;
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		minV = MIN(ptc->v, minV);
		maxV = MAX(ptc->v, maxV);
	}
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->v = minV + maxV - ptc->v;
	}
}

-(void) flipHorizontally {
	GLfloat minU = CGFLOAT_MAX;
	GLfloat maxU = -CGFLOAT_MAX;
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		minU = MIN(ptc->u, minU);
		maxU = MAX(ptc->u, maxU);
	}
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u = minU + maxU - ptc->u;
	}
}

-(void) repeatTexture: (ccTex2F) repeatFactor {
	CGSize repeatSize = CGSizeMake(repeatFactor.u * mapSize.width, repeatFactor.v * mapSize.height);
	[self alignWithTextureMapSize: repeatSize];
}

//-(void) repeatTexture: (ccTex2F) repeatFactor {
//	[self alignWithTextureMapSize: *(CGSize*)&repeatFactor];
//}


#pragma mark Array context switching

/**
 * Returns whether this vertex array is different than the vertex array of the same type
 * that was most recently bound to the GL engine. To improve performance, vertex arrays
 * are only bound if they need to be.
 *
 * Because the same instance of CC3VertexTextureCoordinates can be used by multiple
 * texture units, this property always returns YES, so that the texture array will be
 * bound to the GL engine every time.
 */
-(BOOL) switchingArray {
	return YES;
}

@end


#pragma mark -
#pragma mark CC3VertexIndices

@implementation CC3VertexIndices

-(GLenum) bufferTarget {
	return GL_ELEMENT_ARRAY_BUFFER;
}

-(GLuint) firstElement {
	return bufferID ? elementOffset : ((GLuint)elements + elementOffset);
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_UNSIGNED_SHORT;
		elementSize = 1;
	}
	return self;
}

-(GLushort*) allocateTriangles: (GLsizei) triangleCount {
	self.drawingMode = GL_TRIANGLES;
	self.elementType = GL_UNSIGNED_SHORT;
	return [self allocateElements: (triangleCount * 3)];
}

-(GLushort) indexAt: (GLsizei) index {
	GLvoid* ptr = [self addressOfElement: index];
	return elementType == GL_UNSIGNED_BYTE ? *(GLubyte*)ptr : *(GLushort*)ptr;
}

-(void) setIndex: (GLushort) vertexIndex at: (GLsizei) index {
	GLvoid* ptr = [self addressOfElement: index];
	if (elementType == GL_UNSIGNED_BYTE) {
		*(GLubyte*)ptr = vertexIndex;
	} else {
		*(GLushort*)ptr = vertexIndex;
	}
}

-(CC3FaceIndices) faceIndicesAt: (GLsizei) faceIndex {
	CC3FaceIndices idxIndices = [super faceIndicesAt: faceIndex];
	return CC3FaceIndicesMake([self indexAt: idxIndices.vertices[0]],
							  [self indexAt: idxIndices.vertices[1]],
							  [self indexAt: idxIndices.vertices[2]]);
}

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (bufferID) {									// use GL buffer if it exists
		LogTrace(@"%@ binding GL buffer", self);
		[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget].value = bufferID;
	} else if (elementCount && elements) {			// use local client array if it exists
		LogTrace(@"%@ using local array", self);
		[[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget] unbind];
	} else {
		LogTrace(@"%@ no elements to bind", self);
	}
}

+(void) unbind {
	[self resetSwitching];
}

-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawFrom: vertexIndex forCount: vertexCount withVisitor: visitor];

	GLuint firstVertex = self.firstElement + (self.elementStride * vertexIndex);
	[[CC3OpenGLES11Engine engine].vertices drawIndicies: (GLvoid*)firstVertex
											   ofLength: vertexCount
												andType: elementType
													 as: drawingMode];
}

-(void) populateFromRunLengthArray: (GLushort*) runLenArray ofLength: (GLsizei) rlaLen {
	GLsizei elemNum, rlaIdx, runNum;
	
	// Iterate through the runs in the array to count
	// the number of runs and total number of elements
	runNum = 0;
	elemNum = 0;
	rlaIdx = 0;
	while(rlaIdx < rlaLen) {
		GLushort runLength = runLenArray[rlaIdx];
		elemNum += runLength;
		rlaIdx += runLength + 1;
		runNum++;
	}
	
	// Allocate space for the elements and the runs
	[self allocateElements: elemNum];
	[self allocateStripLengths: runNum];
	
	// Iterate through the runs in the array, copying the 
	// elements and run-lengths to this vertex index array
	runNum = 0;
	elemNum = 0;
	rlaIdx = 0;
	while(rlaIdx < rlaLen) {
		GLushort runLength = runLenArray[rlaIdx++];
		stripLengths[runNum++] = runLength;
		for (int i = 0; i < runLength; i++) {
			[self setIndex: runLenArray[rlaIdx++] at: elemNum++];
		}
	}
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentIndicesTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentIndicesTag != tag;
	currentIndicesTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentIndicesTag = 0;
}

@end


#pragma mark -
#pragma mark CC3VertexPointSizes

@implementation CC3VertexPointSizes

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_FLOAT;
		elementSize = 1;
	}
	return self;
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].vertices.pointSizes useElementsAt: pointer
														   withType: elementType
														 withStride: elementStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.pointSizeArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.pointSizeArray disable];
	[self resetSwitching];
}

-(GLfloat) pointSizeAt: (GLsizei) index {
	return *(GLfloat*)[self addressOfElement: index];
}

-(void) setPointSize: (GLfloat) aSize at: (GLsizei) index {
	*(GLfloat*)[self addressOfElement: index] = aSize;
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentPointSizesTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentPointSizesTag != tag;
	currentPointSizesTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentPointSizesTag = 0;
}

@end


#pragma mark -
#pragma mark CC3VertexWeights

@implementation CC3VertexWeights

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_FLOAT;
		elementSize = 0;
	}
	return self;
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].vertices.weights useElementsAt: pointer
														withSize: elementSize
														withType: elementType
													  withStride: elementStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.weightArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.weightArray disable];
	[self resetSwitching];
}

-(GLfloat*) weightsAt: (GLsizei) index {
	return (GLfloat*)[self addressOfElement: index];
}

-(void) setWeights: (GLfloat*) weights at: (GLsizei) index {
	GLfloat* vertexWeights = [self weightsAt: index];
	GLint numWts = self.elementSize;
	for (int i = 0; i < numWts; i++) {
		vertexWeights[i] = weights[i];
	}
}

-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	return [self weightsAt: index][vertexUnit];
}

-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	[self weightsAt: index][vertexUnit] = aWeight;
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentWeightsTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentWeightsTag != tag;
	currentWeightsTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentWeightsTag = 0;
}

@end


#pragma mark -
#pragma mark CC3VertexMatrixIndices

@implementation CC3VertexMatrixIndices

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_UNSIGNED_BYTE;
		elementSize = 0;
	}
	return self;
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].vertices.matrixIndices useElementsAt: pointer
															  withSize: elementSize
															  withType: elementType
															withStride: elementStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.matrixIndexArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.matrixIndexArray disable];
	[self resetSwitching];
}

-(GLvoid*) matrixIndicesAt: (GLsizei) index {
	return [self addressOfElement: index];
}

-(void) setMatrixIndices: (GLvoid*) mtxIndices at: (GLsizei) index {
	GLint numMtx = self.elementSize;
	if (elementType == GL_UNSIGNED_BYTE) {
		GLubyte* vertexMatrices = (GLubyte*)[self addressOfElement: index];
		for (int i = 0; i < numMtx; i++) {
			vertexMatrices[i] = ((GLubyte*)mtxIndices)[i];
		}
	} else {
		GLushort* vertexMatrices = (GLushort*)[self addressOfElement: index];
		for (int i = 0; i < numMtx; i++) {
			vertexMatrices[i] = ((GLushort*)mtxIndices)[i];
		}
	}
}

-(GLushort) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	if (elementType == GL_UNSIGNED_BYTE) {
		GLubyte* vertexMatrices = (GLubyte*)[self addressOfElement: index];
		return (GLushort)vertexMatrices[vertexUnit];
	} else {
		GLushort* vertexMatrices = (GLushort*)[self addressOfElement: index];
		return vertexMatrices[vertexUnit];
	}
}

-(void) setMatrixIndex: (GLushort) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLsizei) index {
	if (elementType == GL_UNSIGNED_BYTE) {
		GLubyte* vertexMatrices = (GLubyte*)[self addressOfElement: index];
		vertexMatrices[vertexUnit] = aMatrixIndex;
	} else {
		GLushort* vertexMatrices = (GLushort*)[self addressOfElement: index];
		vertexMatrices[vertexUnit] = aMatrixIndex;
	}
}


#pragma mark Array context switching

// The tag of the array that was most recently drawn to the GL engine.
// The GL engine is only updated when an array of the same type with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same arrays are drawn together, to minimize context switching within the GL engine.
static GLuint currentMatrixIndicesTag = 0;

-(BOOL) switchingArray {
	BOOL shouldSwitch = currentMatrixIndicesTag != tag;
	currentMatrixIndicesTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentMatrixIndicesTag = 0;
}

@end
