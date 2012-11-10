/*
 * CC3VertexArrays.m
 *
 * cocos3d 0.7.2
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


#pragma mark -
#pragma mark CC3VertexArrayContent

@implementation CC3VertexArrayContent


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		vertices = NULL;
		vertexCount = 0;
//		allocatedVertexCapacity = 0;
		vertexStride = 0;
		bufferID = 0;
		bufferUsage = GL_STATIC_DRAW;
		shouldAllowVertexBuffering = YES;
		shouldReleaseRedundantData = YES;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3VertexArray

@interface CC3VertexArray (TemplateMethods)
-(BOOL) allocateVertexCapacity: (GLuint) vtxCount;
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) verticesWereChanged;
@property(nonatomic, readonly) BOOL switchingArray;
@property(nonatomic, readonly) GLuint availableVertexCount;
@end


@implementation CC3VertexArray

@synthesize bufferID, elementOffset, bufferUsage;
@synthesize shouldAllowVertexBuffering, shouldReleaseRedundantData;

-(void) dealloc {
	[self deleteGLBuffer];
	self.allocatedVertexCapacity = 0;
//	[vertexContent release];
	[super dealloc];
}

-(GLvoid*) vertices { return vertices; }

/**
 * Safely disposes of any existing allocated vertex memory, maintaining the existing vertex
 * count while doing so if the new vertices are not empty. This handles the case where vertex
 * count is set before vertices. Also, notify subclasses that the vertices have changed.
 */
-(void) setVertices: (GLvoid*) vtxs {
	if (vtxs != vertices) {
		GLuint currVtxCount = vertexCount;
		self.allocatedVertexCapacity = 0;		// Safely disposes existing vertices
		vertices = vtxs;
		if (vertices) vertexCount = currVtxCount;
		[self verticesWereChanged];
	}
}

/** The vertices array has been changed. Default is to do nothing. Some subclasses may want to react. */
-(void) verticesWereChanged {}

-(GLuint) vertexCount { return vertexCount; }

-(void) setVertexCount: (GLuint) vtxCount { vertexCount = vtxCount; }

-(GLint) elementSize { return elementSize; }

/**
 * If the element size is set after vertex memory has been allocated, reallocate it.
 * If that reallocation fails, don't change the size.
 */
-(void) setElementSize: (GLint) elemSize {
	GLint currSize = elementSize;
	elementSize = elemSize;
	if ( ![self allocateVertexCapacity: allocatedVertexCapacity] ) elementSize = currSize;
}

-(GLenum) elementType { return elementType; }

/**
 * If the element type is set after vertex memory has been allocated, reallocate it.
 * If that reallocation fails, don't change the size.
 */
-(void) setElementType: (GLenum) elemType {
	GLenum currType = elementType;
	elementType = elemType;
	if ( ![self allocateVertexCapacity: allocatedVertexCapacity] ) elementType = currType;
}

-(GLuint) elementLength { return GLElementTypeSize(elementType) * elementSize; }

-(GLuint) vertexStride { return vertexStride ? vertexStride : self.elementLength; }

/**
 * If the stride is set after vertex memory has been allocated, reallocate it.
 * If that reallocation fails, don't change the stride.
 */
-(void) setVertexStride: (GLuint) stride {
	GLuint currStride = vertexStride;
	vertexStride = stride;
	if ( ![self allocateVertexCapacity: allocatedVertexCapacity] ) vertexStride = currStride;
}

/**
 * The number of available vertices. If the vertices have been allocated by this
 * array, that is the number of available vertices. Otherwise, if the vertices were
 * allocated elsewhere, it is the number specified by the vertexCount value.
 */
-(GLuint) availableVertexCount {
	return (allocatedVertexCapacity > 0) ? allocatedVertexCapacity : vertexCount;
}

-(GLenum) bufferTarget { return GL_ARRAY_BUFFER; }

// Deprecated properties
-(GLvoid*) elements { return self.vertices; }
-(void) setElements: (GLvoid*) elems { self.vertices = elems; }
-(GLuint) elementCount { return self.vertexCount; }
-(void) setElementCount: (GLuint) elemCount { self.vertexCount = elemCount; }
-(GLuint) elementStride { return self.vertexStride; }
-(void) setElementStride: (GLuint) elemStride { self.vertexStride = elemStride; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
//		vertexContent = [CC3VertexArrayContent new];
		vertices = NULL;
		vertexCount = 0;
		allocatedVertexCapacity = 0;
		elementType = GL_FLOAT;
		elementSize = 3;
		vertexStride = 0;
		bufferID = 0;
		bufferUsage = GL_STATIC_DRAW;
		elementOffset = 0;
		shouldAllowVertexBuffering = YES;
		shouldReleaseRedundantData = YES;
	}
	return self;
}

+(id) vertexArray { return [[[self alloc] init] autorelease]; }

+(id) vertexArrayWithTag: (GLuint) aTag { return [[[self alloc] initWithTag: aTag] autorelease]; }

+(id) vertexArrayWithName: (NSString*) aName { return [[[self alloc] initWithName: aName] autorelease]; }

+(id) vertexArrayWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

-(GLvoid*) interleaveWith: (CC3VertexArray*) otherVtxArray usingOffset: (GLuint) elemOffset {
	self.vertices = otherVtxArray.vertices;
	self.vertexStride = otherVtxArray.vertexStride;
	self.vertexCount = otherVtxArray.vertexCount;
	self.elementOffset = elemOffset;
	return (GLbyte*)vertices  + self.elementOffset;
}

-(GLvoid*) interleaveWith: (CC3VertexArray*) otherVtxArray {
	return [self interleaveWith: otherVtxArray usingOffset: self.elementOffset];
}

-(void) populateFrom: (CC3VertexArray*) another {
	[super populateFrom: another];

	elementType = another.elementType;
	elementSize = another.elementSize;
	vertexStride = another.vertexStride;
	bufferUsage = another.bufferUsage;
	elementOffset = another.elementOffset;
	shouldAllowVertexBuffering = another.shouldAllowVertexBuffering;
	shouldReleaseRedundantData = another.shouldReleaseRedundantData;

	[self deleteGLBuffer];		// Data has yet to be buffered. Get rid of old buffer if necessary.

	// If the original has its data stored in memory that it allocated, allocate the
	// same amount in this copy, and copy the data over. Otherwise, the memory is
	// being managed externally, so simply copy the vertices reference over.
	if (another.allocatedVertexCapacity) {
		self.allocatedVertexCapacity = another.allocatedVertexCapacity;
		memcpy(vertices, another.vertices, (allocatedVertexCapacity * self.vertexStride));
	} else {
		vertices = another.vertices;
	}
	vertexCount = another.vertexCount;
}

-(GLuint) allocatedVertexCapacity { return allocatedVertexCapacity; }

-(void) setAllocatedVertexCapacity: (GLuint) vtxCount {
	if (vtxCount != allocatedVertexCapacity) {
		NSAssert1((vtxCount == 0 || self.vertexStride > 0), @"%@ must have the stride defined before allocating vertices. Set the elementType and elementSize properties before setting the allocatedVertexCapacity property.", self);
		[self allocateVertexCapacity: vtxCount];
	}
}

/**
 * Allocates new vertex memory, reallocates existing vertex memory, or deallocates existing vertex memory.
 *
 * If vtxCount is non-zero, and the vertices property is NULL, memory is allocated, and the vertices
 * property is set to point to it. If vtxCount is non-zero, and the vertices property is non-NULL,
 * the existing memory is reallocated, possibly changing the value of the vertices property in the
 * process. If vtxCount is zero, any previously allocated vertices are safely deallocated.
 *
 * Returns NO if an error occurs, otherwise returns YES.
 */
-(BOOL) allocateVertexCapacity: (GLuint) vtxCount {
	if (allocatedVertexCapacity == vtxCount) return YES;
	
	// If nothing has been allocated yet, ensure that we don't reallocate an externally set pointer
	if (allocatedVertexCapacity == 0) vertices = NULL;
	
	GLvoid* newVertices = NULL;
	
	// Don't use realloc to free memory that was previously allocated. Behaviour of realloc is
	// undefined and implementation dependent when the requested size is zero.
	if (vtxCount > 0) {
		// Returned pointer will be non-NULL on successful allocation and NULL on failed allocation.
		// If we fail, log an error and return without changing anything.
		newVertices = realloc(vertices, (vtxCount * self.vertexStride));
		if ( !newVertices ) {
			LogError(@"%@ could not allocate space for %u vertices", self, vtxCount);
			return NO;
		}
	} else {
		free(vertices);
	}
	
	LogTrace(@"%@ changed vertex allocation from %u vertices at %p to %u vertices at %p",
			 self, allocatedVertexCapacity, vertices, vtxCount, newVertices);
	
	// Don't use vertices setter, because it will attempt to deallocate again.
	// But do notify subclasses that the vertices have changed.
	vertices = newVertices;
	allocatedVertexCapacity = vtxCount;
	vertexCount = vtxCount;
	[self verticesWereChanged];
	
	return YES;
}

// Deprecated
-(GLvoid*) allocateElements: (GLuint) vtxCount {
	self.allocatedVertexCapacity = vtxCount;
	return vertices;
}

// Deprecated
-(GLvoid*) reallocateElements: (GLuint) vtxCount {
	self.allocatedVertexCapacity = vtxCount;
	return vertices;
}

// Deprecated
-(void) deallocateElements { self.allocatedVertexCapacity = 0; }

// Deprecated property
-(GLfloat) capacityExpansionFactor { return 1.25; };
-(void) setCapacityExpansionFactor: (GLfloat) capExFactor {}

// Deprecated
-(BOOL) ensureCapacity: (GLuint) vtxCount {
	if (allocatedVertexCapacity && allocatedVertexCapacity < vtxCount) {
		[self reallocateElements: (vtxCount * 1.25)];
		return YES;
	}
	return NO;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ vertices: %p, count: %i, allocated: %i, elementSize: %i, type: %@, offset: %i, stride: %i, bufferID: %i",
			[self description],
			vertices, vertexCount, allocatedVertexCapacity, elementSize,
			NSStringFromGLEnum(elementType),
			elementOffset, vertexStride, bufferID];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3VertexArrays.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedVertexArrayTag;

-(GLuint) nextTag { return ++lastAssignedVertexArrayTag; }

+(void) resetTagAllocation { lastAssignedVertexArrayTag = 0; }


#pragma mark Binding GL artifacts

-(void) createGLBuffer {
	if (shouldAllowVertexBuffering && !bufferID) {
		CC3OpenGLES11VertexArrays* gles11Vertices = [CC3OpenGLES11Engine engine].vertices;
		CC3OpenGLES11StateTrackerArrayBufferBinding* bufferBinding = [gles11Vertices bufferBinding: self.bufferTarget];
		
		bufferID = [gles11Vertices generateBuffer];
		LogTrace(@"%@ creating GL server buffer with ID %i", self, bufferID);
		GLsizeiptr buffSize = self.vertexStride * self.availableVertexCount;
		bufferBinding.value = bufferID;
		[bufferBinding loadBufferData: vertices ofLength: buffSize forUse: bufferUsage];
		GLenum errCode = glGetError();
		if (errCode) {
			LogInfo(@"%@ could not create GL buffer with ID %i of type %@ because of %@. Using local memory arrays instead.",
					self, bufferID, NSStringFromGLEnum(self.bufferTarget), GetGLErrorText(errCode));
			[self deleteGLBuffer];
		}
		[bufferBinding unbind];
	} else {
		LogTrace(@"%@ NOT creating GL server buffer because shouldAllowVertexBuffering is %@ or buffer ID already set to %i",
				 self, NSStringFromBoolean(shouldAllowVertexBuffering), bufferID);
	}
}

-(void) updateGLBufferStartingAt: (GLuint) offsetIndex forLength: (GLuint) vtxCount {
	if (bufferID) {
		CC3OpenGLES11StateTrackerArrayBufferBinding* bufferBinding;
		LogTrace(@"%@ updating GL server buffer with %i bytes starting at %i", self, length, offset);
		GLuint elemStride = self.vertexStride;
		bufferBinding = [[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget];
		bufferBinding.value = bufferID;
		[bufferBinding updateBufferData: vertices
							 startingAt: (offsetIndex * elemStride)
							  forLength: (vtxCount * elemStride)];
		[bufferBinding unbind];
	}
}

-(void) updateGLBuffer { [self updateGLBufferStartingAt: 0 forLength: vertexCount]; }

-(void) deleteGLBuffer {
	if (bufferID) {
		LogTrace(@"%@ deleting GL server buffer ID %i", self, bufferID);
		[[CC3OpenGLES11Engine engine].vertices deleteBuffer: bufferID];
		bufferID = 0;
	}
}

-(BOOL) isUsingGLBuffer { return bufferID != 0; }

-(void) releaseRedundantData {
	if (bufferID && shouldReleaseRedundantData) {
		GLuint currVtxCount = vertexCount;
		self.allocatedVertexCapacity = 0;
		vertexCount = currVtxCount;		// Maintain vertexCount for drawing
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
		LogTrace(@"%@ binding GL buffer containing %u vertices", self, vertexCount);
		[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget].value = bufferID;
		[self bindPointer: (GLvoid*)elementOffset withVisitor: visitor];
	} else if (vertexCount && vertices) {					// use local client array if it exists
		LogTrace(@"%@ using local array containing %u vertices", self, vertexCount);
		[[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget] unbind];
		[self bindPointer: (GLvoid*)((GLuint)vertices + elementOffset) withVisitor: visitor];
	} else {
		LogTrace(@"%@ no vertices to bind", self);
	}
}

/**
 * Template method that binds the GL engine to the values of the elementSize, elementType
 * and vertexStride properties, along with the specified data pointer, and enables the
 * type of aspect managed by this instance (locations, normals...) in the GL engine.
 *
 * This abstract implementation does nothing. Subclasses will override to handle
 * their particular type of vetex aspect.
 */
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) unbind { [[self class] unbind]; }

// Default does nothing. Subclasses will override.
+(void) unbind {}


#pragma mark Accessing vertices

-(GLvoid*) addressOfElement: (GLuint) index {
	// Check vertices still in memory, and if allocated,
	// that index is less than number of vertices allocated
	NSAssert(vertices || !bufferID, @"Vertex content is no longer in application memory. To retain mesh data in main memory, invoke the retainVertexContent method on this mesh before invoking the releaseRedundantData method.");
	NSAssert(vertices, @"Vertex content is missing.");
	NSAssert2(allocatedVertexCapacity == 0 || index < allocatedVertexCapacity, @"Requested index %i is greater than number of vertices allocated: %i.", index, vertexCount);
	return (GLbyte*)vertices + (self.vertexStride * index) + elementOffset;
}

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx {
	if (vtxCount == 0) return;	// Fail safe. Vertex address may be NULL if no vertices to copy.
	GLvoid* srcPtr = [self addressOfElement: srcIdx];
	GLvoid* dstPtr = [self addressOfElement: dstIdx];
	[self copyVertices: vtxCount fromAddress: srcPtr toAddress: dstPtr];
}

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx toAddress: (GLvoid*) dstPtr {
	if (vtxCount == 0) return;	// Fail safe. Vertex address may be NULL if no vertices to copy.
	GLvoid* srcPtr = [self addressOfElement: srcIdx];
	[self copyVertices: vtxCount fromAddress: srcPtr toAddress: dstPtr];
}

-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr to: (GLuint) dstIdx {
	if (vtxCount == 0) return;	// Fail safe. Vertex address may be NULL if no vertices to copy.
	GLvoid* dstPtr = [self addressOfElement: dstIdx];
	[self copyVertices: vtxCount fromAddress: srcPtr toAddress: dstPtr];
}

-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr toAddress: (GLvoid*) dstPtr {
	if (vtxCount == 0) return;	// Fail safe. Vertex address may be NULL if no vertices to copy.
	memcpy(dstPtr, srcPtr, (vtxCount * self.vertexStride));
}

-(NSString*) describeVertices { return [self describeVertices: vertexCount]; }

-(NSString*) describeVertices: (GLuint) vtxCount { return [self describeVertices: vtxCount startingAt: 0]; }

-(NSString*) describeVertices: (GLuint) vtxCount startingAt: (GLuint) startElem {
	GLuint endElem = MIN(startElem + vtxCount, vertexCount);
	NSMutableString* desc = [NSMutableString stringWithCapacity: ((endElem - startElem) * elementSize * 8)];
	[desc appendFormat: @"Content of %@:", [self fullDescription]];
	if (vertices) {
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

// Deprecated
-(NSString*) describeElements { return [self describeVertices]; }
-(NSString*) describeElements: (GLuint) vtxCount { return [self describeVertices: vtxCount]; }
-(NSString*) describeElements: (GLuint) vtxCount startingAt: (GLuint) startElem {
	return [self describeVertices: vtxCount startingAt: startElem];
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
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex fromStripOfLength: (GLuint) stripLen;
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
		drawingMode = GL_TRIANGLES;
		stripCount = 0;
		stripLengths = NULL;
		stripLengthsAreRetained = NO;
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
		[self drawFrom: 0 forCount: vertexCount withVisitor: visitor];
	}
}

-(void) drawFrom: (GLuint) vtxIdx
		forCount: (GLuint) vtxCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ drawing %u vertices", self, vtxCount);
	CC3PerformanceStatistics* perfStats = visitor.performanceStatistics;
	if (perfStats) {
		[perfStats addSingleCallFacesPresented: [self faceCountFromVertexIndexCount: vtxCount]];
	}
}

-(void) allocateStripLengths: (GLuint) sCount {
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
	stripLengths = NULL;
	stripCount = 0;
}

/** Converts the specified vertex count to a face count, based on the drawingMode property. */
-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc {
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
-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc {
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

// Deprecated
-(GLuint) faceCountFromVertexCount: (GLuint) vc { return [self faceCountFromVertexIndexCount: vc]; }
-(GLuint) vertexCountFromFaceCount: (GLuint) fc { return [self vertexIndexCountFromFaceCount: fc]; }

/**
 * If drawing is being done with strips, accumulate the number of faces per strip
 * by converting the number of vertices in each strip to faces. Otherwise, simply
 * convert the total number of vertices to faces.
 */
-(GLuint) faceCount {
	if (stripCount) {
		GLuint fCnt = 0;
		for (GLuint i = 0; i < stripCount; i++) {
			fCnt += [self faceCountFromVertexIndexCount: stripLengths[i]];
		}
		return fCnt;
	} else {
		return [self faceCountFromVertexIndexCount: vertexCount];
	}
}

/**
 * If drawing is being done with strips, accumulate the number of faces per strip
 * prior to the strip that contains the specified face, then add the offset to
 * the face within that strip to retrieve the correct face from that strip.
 * If strips are not in use, simply extract the face from the full element array.
 */
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex {
	if (stripCount) {
		// Mesh is divided into strips. Find the strip that contains the face,
		// by accumulating faces and element counts until we reach the strip
		// that contains the face. Then extract the face from that strip and
		// offset it by the number of vertices in all the previous strips.
		GLuint currStripStartFaceCnt = 0;
		GLuint nextStripStartFaceCnt = 0;
		GLuint stripStartVtxCnt = 0;
		for (GLuint i = 0; i < stripCount; i++) {
			GLuint stripLen = stripLengths[i];
			nextStripStartFaceCnt += [self faceCountFromVertexIndexCount: stripLen];
			if (nextStripStartFaceCnt > faceIndex) {
				CC3FaceIndices faceIndices = [self faceIndicesAt: (faceIndex - currStripStartFaceCnt)
											   fromStripOfLength: stripLen];
				// Offset the indices of the face by the number of vertices
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
		// Mesh is monolithic. Simply extract the face from the vertices array.
		return [self faceIndicesAt: faceIndex fromStripOfLength: vertexCount];
	}
}

/**
 * Returns the indicies for the face at the specified face index,
 * within an array of vertices of the specified length.
 */
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex fromStripOfLength: (GLuint) stripLen {
	GLuint firstVtxIdx;			// The first index of the face.
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
			GLuint nextVtxIdx = (faceIndex < stripLen - 1) ? firstVtxIdx + 1 : 0;
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

-(NSString*) nameSuffix { return @"Locations"; }

-(void) markBoundaryDirty {
	boundaryIsDirty = YES;
	radiusIsDirty = YES;
}

// Mark boundary dirty, but only if vertices are valid (to avoid marking dirty on dealloc)
-(void) verticesWereChanged { if (vertices && vertexCount) [self markBoundaryDirty]; }

-(void) setVertexCount: (GLuint) count {
	[super setVertexCount: count];
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

-(CC3Vector) locationAt: (GLuint) index {
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

-(void) setLocation: (CC3Vector) aLocation at: (GLuint) index {
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

-(CC3Vector4) homogeneousLocationAt: (GLuint) index {
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

-(void) setHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index {
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

-(CC3Face) faceAt: (GLuint) faceIndex {
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
	if (boundaryIsDirty) [self buildBoundingBox];
}

/** Returns the radius, calculating it if necessary. */
-(GLfloat) radius {
	[self calcRadiusIfNecessary];
	return radius;
}

/** Calculates the radius if it necessary. */
-(void) calcRadiusIfNecessary {
	if (radiusIsDirty) [self calcRadius];
}

/**
 * Calculates and populates the boundingBox and centerOfGeometry properties
 * from the vertex locations.
 *
 * This method is invoked automatically when the bounding box or centerOfGeometry property
 * is accessed for the first time after the vertices property has been set.
 */
-(void) buildBoundingBox {
	// If we don't have vertices, but do have a non-zero vertexCount, raise an assertion
	NSAssert1( !( !vertices && vertexCount ), @"%@ bounding box requested after vertex data have been released", self);
	NSAssert1(elementType == GL_FLOAT, @"%@ must have elementType GLFLOAT to build the bounding box", self);

	CC3Vector vl, vlMin, vlMax;
	vl = (vertexCount > 0) ? [self locationAt: 0] : kCC3VectorZero;
	vlMin = vl;
	vlMax = vl;
	for (GLuint i = 1; i < vertexCount; i++) {
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
	if (vertices && vertexCount) {
		// Work with the square of the radius so that all distances can be compared
		// without having to run expensive square-root calculations.
		GLfloat radiusSq = 0.0;
		for (GLuint i=0; i < vertexCount; i++) {
			CC3Vector vl = [self locationAt: i];
			GLfloat distSq = CC3VectorDistanceSquared(vl, cog);
			radiusSq = MAX(radiusSq, distSq);
		}
		radius = sqrtf(radiusSq);		// Now finally take the square-root
		radiusIsDirty = NO;
		LogTrace(@"%@ setting radius to %.2f", self, radius);
	}
}

-(void) moveMeshOriginTo: (CC3Vector) aLocation {
	for (GLuint i = 0; i < vertexCount; i++) {
		CC3Vector locOld = [self locationAt: i];
		CC3Vector locNew = CC3VectorDifference(locOld, aLocation);
		[self setLocation: locNew at: i];
	}
	[self markBoundaryDirty];
	[self updateGLBuffer];
}

-(void) moveMeshOriginToCenterOfGeometry {
	[self moveMeshOriginTo: self.centerOfGeometry];
}

// Deprecated methods
-(void) movePivotTo: (CC3Vector) aLocation { [self moveMeshOriginTo: aLocation]; }
-(void) movePivotToCenterOfGeometry { [self moveMeshOriginToCenterOfGeometry]; }


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
														withStride: vertexStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.vertexArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.vertexArray disable];
	[self resetSwitching];
}

-(void) drawFrom: (GLuint) vtxIdx
		forCount: (GLuint) vtxCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawFrom: vtxIdx forCount: vtxCount withVisitor: visitor];

	GLuint firstVertex = self.firstElement + (self.vertexStride * vtxIdx);
	[[CC3OpenGLES11Engine engine].vertices drawVerticiesAs: drawingMode
												startingAt: firstVertex
												withLength: vtxCount];
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

-(NSString*) nameSuffix { return @"Normals"; }

-(CC3Vector) normalAt: (GLuint) index {
	return *(CC3Vector*)[self addressOfElement: index];
}

-(void) setNormal: (CC3Vector) aNormal at: (GLuint) index {
	*(CC3Vector*)[self addressOfElement: index] = aNormal;
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].vertices.normals useElementsAt: pointer
														withType: elementType
													  withStride: vertexStride];
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

-(NSString*) nameSuffix { return @"Colors"; }

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_UNSIGNED_BYTE;
		elementSize = 4;
	}
	return self;
}

-(ccColor4F) color4FAt: (GLuint) index {
	switch (elementType) {
		case GL_FIXED:
		case GL_UNSIGNED_BYTE:
			return CCC4FFromCCC4B(*(ccColor4B*)[self addressOfElement: index]);
		case GL_FLOAT:
		default:
			return *(ccColor4F*)[self addressOfElement: index];
	}
}

-(void) setColor4F: (ccColor4F) aColor at: (GLuint) index {
	switch (elementType) {
		case GL_FIXED:
		case GL_UNSIGNED_BYTE:
			*(ccColor4B*)[self addressOfElement: index] = CCC4BFromCCC4F(aColor);
			break;
		case GL_FLOAT:
		default:
			*(ccColor4F*)[self addressOfElement: index] = aColor;
	}
}

-(ccColor4B) color4BAt: (GLuint) index {
	switch (elementType) {
		case GL_FLOAT:
			return CCC4BFromCCC4F(*(ccColor4F*)[self addressOfElement: index]);
		case GL_FIXED:
		case GL_UNSIGNED_BYTE:
		default:
			return *(ccColor4B*)[self addressOfElement: index];
	}
}

-(void) setColor4B: (ccColor4B) aColor at: (GLuint) index {
	switch (elementType) {
		case GL_FLOAT:
			*(ccColor4F*)[self addressOfElement: index] = CCC4FFromCCC4B(aColor);
			break;
		case GL_FIXED:
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
									 withStride: vertexStride];
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


#pragma mark CCRGBAProtocol support

/** Returns the color of the first vertex. */
-(ccColor3B) color {
	if (self.vertexCount == 0) return ccBLACK;
	ccColor4B vtxCol = [self color4BAt: 0];
	return *(ccColor3B*)&vtxCol;
}

/** Sets the color of each vertex without changing the individual opacity of each vertex. */
-(void) setColor: (ccColor3B) aColor {
	GLuint vtxCount = self.vertexCount;
	for (GLuint vIdx = 0; vIdx < vtxCount; vIdx++) {
		ccColor4B vtxCol = [self color4BAt: vIdx];
		[self setColor4B: ccc4(aColor.r, aColor.g, aColor.b, vtxCol.a) at: vIdx];
	}
	[self updateGLBuffer];
}

/** Returns the opacity of the first vertex. */
-(GLubyte) opacity { return (self.vertexCount > 0) ? [self color4BAt: 0].a : 0; }

/** Sets the opacity of each vertex without changing the individual color of each vertex. */
-(void) setOpacity: (GLubyte) opacity {
	GLuint vtxCount = self.vertexCount;
	for (GLuint vIdx = 0; vIdx < vtxCount; vIdx++) {
		ccColor4B vtxCol = [self color4BAt: vIdx];
		[self setColor4B: ccc4(vtxCol.r, vtxCol.g, vtxCol.b, opacity) at: vIdx];
	}
	[self updateGLBuffer];
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
-(void) alignWithTextureRectangle: (CGRect) newRect fromOld: (CGRect) oldRect;
@end

@implementation CC3VertexTextureCoordinates

@synthesize expectsVerticallyFlippedTextures;

-(NSString*) nameSuffix { return @"TexCoords"; }

-(CGRect) textureRectangle { return textureRectangle; }

-(CGRect) effectiveTextureRectangle {
	if (expectsVerticallyFlippedTextures) {
		return CGRectMake(textureRectangle.origin.x * mapSize.width,
						  (1.0f - textureRectangle.origin.y) * mapSize.height,
						  textureRectangle.size.width * mapSize.width,
						  -textureRectangle.size.height * mapSize.height);
	} else {
		return CGRectMake(textureRectangle.origin.x * mapSize.width,
						  textureRectangle.origin.y * mapSize.height,
						  textureRectangle.size.width * mapSize.width,
						  textureRectangle.size.height * mapSize.height);
	}
}

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

-(ccTex2F) texCoord2FAt: (GLuint) index {
	return *(ccTex2F*)[self addressOfElement: index];
}

-(void) setTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index {
	*(ccTex2F*)[self addressOfElement: index] = aTex2F;
}

/** Extracts the current texture unit from the visitor and binds this vertex array to that texture unit. */
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11TextureUnit* gles11TexUnit = [[CC3OpenGLES11Engine engine].textures textureUnitAt: visitor.textureUnit];
	[gles11TexUnit.textureCoordArray enable];
	[gles11TexUnit.textureCoordinates useElementsAt: pointer
										   withSize: elementSize
										   withType: elementType
										 withStride: vertexStride];
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
 * Aligns the vertex texture coordinates with the area of the texture defined
 * by the newRect. The oldRect describes the area of the texture that is currently
 * mapped by the texture coordinates.
 */
-(void) alignWithTextureRectangle: (CGRect) newRect fromOld: (CGRect) oldRect {
	
	// The size of the texture mapping in its natural state
	GLfloat mw = mapSize.width;
	GLfloat mh = mapSize.height;
	
	// Old rect components
	GLfloat ox = oldRect.origin.x;
	GLfloat oy = oldRect.origin.y;
	GLfloat ow = oldRect.size.width;
	GLfloat oh = oldRect.size.height;
	
	// New rect components
	GLfloat nx = newRect.origin.x;
	GLfloat ny = newRect.origin.y;
	GLfloat nw = newRect.size.width;
	GLfloat nh = newRect.size.height;
	
	// For each texture coordinate, convert to the original coordinate, taking into consideration
	// the mapSize and the old texture rectangle. Then, convert to the new coordinate, taking into
	// consideration the mapSize and the new texture rectangle.
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		
		GLfloat origU = ((ptc->u / mw) - ox) / ow;			// Revert to original value
		ptc->u = (nx + (origU * nw)) * mw;					// Calc new value
		
		// Take into consideration whether the texture is flipped.
		if (expectsVerticallyFlippedTextures) {
			GLfloat origV = (1.0f - (ptc->v / mh) - oy) / oh;	// Revert to original value
			ptc->v = (1.0f - (ny + (origV * nh))) * mh;			// Calc new value
		} else {
			GLfloat origV = ((ptc->v / mh) - oy) / oh;			// Revert to original value
			ptc->v = (ny + (origV * nh)) * mh;					// Calc new value
		}
	}
}

-(void) alignWithTextureMapSize: (CGSize) texMapSize {
	NSAssert2((texMapSize.width && texMapSize.height),
			  @"%@ mapsize %@ cannot have zero dimension",
			  self, NSStringFromCGSize(texMapSize));

	// Don't waste time adjusting if nothing is changing
	// (eg. POT textures, or new texture has same texture map as old).
	if (CGSizeEqualToSize(texMapSize, mapSize)) return;
	
	LogTrace(@"%@ aligning and changing map size from %@ to %@ but not flipping vertically",
				  self, NSStringFromCGSize(mapSize), NSStringFromCGSize(texMapSize));

	CGSize mapRatio = CGSizeMake(texMapSize.width / mapSize.width, texMapSize.height / mapSize.height);
	
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u *= mapRatio.width;
		ptc->v *= mapRatio.height;
	}
	mapSize = texMapSize;	// Remember what we've set the map size to

}

-(void) alignWithInvertedTextureMapSize: (CGSize) texMapSize {
	NSAssert2((texMapSize.width && texMapSize.height),
			  @"%@ mapsize %@ cannot have zero dimension",
			  self, NSStringFromCGSize(texMapSize));
	LogTrace(@"%@ aligning and changing map size from %@ to %@ and flipping vertically",
				  self, NSStringFromCGSize(mapSize), NSStringFromCGSize(texMapSize));
	
	CGSize mapRatio = CGSizeMake(texMapSize.width / mapSize.width, texMapSize.height / mapSize.height);
	
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u *= mapRatio.width;
		ptc->v = texMapSize.height - (ptc->v * mapRatio.height);
	}

	// Remember that we've flipped and what we've set the map size to
	mapSize = texMapSize;
	expectsVerticallyFlippedTextures = !expectsVerticallyFlippedTextures;
	
	LogTrace(@"%@ aligned and flipped vertically", self);
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
	GLfloat minV = kCC3MaxGLfloat;
	GLfloat maxV = -kCC3MaxGLfloat;
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		minV = MIN(ptc->v, minV);
		maxV = MAX(ptc->v, maxV);
	}
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->v = minV + maxV - ptc->v;
	}
}

-(void) flipHorizontally {
	GLfloat minU = kCC3MaxGLfloat;
	GLfloat maxU = -kCC3MaxGLfloat;
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		minU = MIN(ptc->u, minU);
		maxU = MAX(ptc->u, maxU);
	}
	for (GLuint i = 0; i < vertexCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u = minU + maxU - ptc->u;
	}
}

-(void) repeatTexture: (ccTex2F) repeatFactor {
	CGSize repeatSize = CGSizeMake(repeatFactor.u * mapSize.width, repeatFactor.v * mapSize.height);
	[self alignWithTextureMapSize: repeatSize];
}


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
-(BOOL) switchingArray { return YES; }

@end


#pragma mark -
#pragma mark CC3VertexIndices

@implementation CC3VertexIndices

-(NSString*) nameSuffix { return @"Indices"; }

-(GLenum) bufferTarget { return GL_ELEMENT_ARRAY_BUFFER; }

-(GLuint) firstElement { return bufferID ? elementOffset : ((GLuint)vertices + elementOffset); }

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementType = GL_UNSIGNED_SHORT;
		elementSize = 1;
	}
	return self;
}

// Deprecated
-(GLuint*) allocateTriangles: (GLuint) triangleCount {
	self.drawingMode = GL_TRIANGLES;
	self.elementType = GL_UNSIGNED_SHORT;
	self.allocatedVertexCapacity = (triangleCount * 3);
	return vertices;
}

-(GLuint) indexAt: (GLuint) index {
	GLvoid* ptr = [self addressOfElement: index];
	return elementType == GL_UNSIGNED_BYTE ? *(GLubyte*)ptr : *(GLushort*)ptr;
}

-(void) setIndex: (GLuint) vtxIdx at: (GLuint) index {
	GLvoid* ptr = [self addressOfElement: index];
	if (elementType == GL_UNSIGNED_BYTE) {
		*(GLubyte*)ptr = vtxIdx;
	} else {
		*(GLushort*)ptr = vtxIdx;
	}
}

-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex {
	CC3FaceIndices idxIndices = [super faceIndicesAt: faceIndex];
	return CC3FaceIndicesMake([self indexAt: idxIndices.vertices[0]],
							  [self indexAt: idxIndices.vertices[1]],
							  [self indexAt: idxIndices.vertices[2]]);
}

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (bufferID) {									// use GL buffer if it exists
		LogTrace(@"%@ binding GL buffer", self);
		[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget].value = bufferID;
	} else if (vertexCount && vertices) {			// use local client array if it exists
		LogTrace(@"%@ using local array", self);
		[[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget] unbind];
	} else {
		LogTrace(@"%@ no vertices to bind", self);
	}
}

+(void) unbind {
	[self resetSwitching];
}

-(void) drawFrom: (GLuint) vtxIdx
		forCount: (GLuint) vtxCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawFrom: vtxIdx forCount: vtxCount withVisitor: visitor];
	GLuint firstVertex = self.firstElement + (self.vertexStride * vtxIdx);
	[[CC3OpenGLES11Engine engine].vertices drawIndicies: (GLvoid*)firstVertex
											   ofLength: vtxCount
												andType: elementType
													 as: drawingMode];
}

-(void) populateFromRunLengthArray: (GLushort*) runLenArray ofLength: (GLuint) rlaLen {
	GLuint elemNum, rlaIdx, runNum;
	
	// Iterate through the runs in the array to count
	// the number of runs and total number of vertices
	runNum = 0;
	elemNum = 0;
	rlaIdx = 0;
	while(rlaIdx < rlaLen) {
		GLushort runLength = runLenArray[rlaIdx];
		elemNum += runLength;
		rlaIdx += runLength + 1;
		runNum++;
	}
	
	// Allocate space for the vertices and the runs
	self.allocatedVertexCapacity = elemNum;
	[self allocateStripLengths: runNum];
	
	// Iterate through the runs in the array, copying the 
	// vertices and run-lengths to this vertex index array
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


#pragma mark Accessing vertices

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx to: (GLuint) dstIdx offsettingBy: (GLint) offset {
	GLvoid* srcPtr = [self addressOfElement: srcIdx];
	GLvoid* dstPtr = [self addressOfElement: dstIdx];
	[self copyVertices: vtxCount fromAddress: srcPtr toAddress: dstPtr offsettingBy: offset];
}

-(void) copyVertices: (GLuint) vtxCount from: (GLuint) srcIdx toAddress: (GLvoid*) dstPtr offsettingBy: (GLint) offset {
	GLvoid* srcPtr = [self addressOfElement: srcIdx];
	[self copyVertices: vtxCount fromAddress: srcPtr toAddress: dstPtr offsettingBy: offset];
}

-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr to: (GLuint) dstIdx offsettingBy: (GLint) offset {
	GLvoid* dstPtr = [self addressOfElement: dstIdx];
	[self copyVertices: vtxCount fromAddress: srcPtr toAddress: dstPtr offsettingBy: offset];
}

-(void) copyVertices: (GLuint) vtxCount fromAddress: (GLvoid*) srcPtr toAddress: (GLvoid*) dstPtr offsettingBy: (GLint) offset {
	if (elementType == GL_UNSIGNED_BYTE) {
		GLubyte* srcByte = srcPtr;
		GLubyte* dstByte = dstPtr;
		for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
			dstByte[vtxIdx] = srcByte[vtxIdx] + offset;
		}
	} else {
		GLushort* srcShort = srcPtr;
		GLushort* dstShort = dstPtr;
		for (GLuint vtxIdx = 0; vtxIdx < vtxCount; vtxIdx++) {
			dstShort[vtxIdx] = srcShort[vtxIdx] + offset;
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

+(void) resetSwitching { currentIndicesTag = 0; }

@end


#pragma mark -
#pragma mark CC3VertexPointSizes

@implementation CC3VertexPointSizes

-(NSString*) nameSuffix { return @"PointSizes"; }

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
														 withStride: vertexStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.pointSizeArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.pointSizeArray disable];
	[self resetSwitching];
}

-(GLfloat) pointSizeAt: (GLuint) index {
	return *(GLfloat*)[self addressOfElement: index];
}

-(void) setPointSize: (GLfloat) aSize at: (GLuint) index {
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

+(void) resetSwitching { currentPointSizesTag = 0; }

@end


#pragma mark -
#pragma mark CC3VertexWeights

@implementation CC3VertexWeights

-(NSString*) nameSuffix { return @"Weights"; }

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
													  withStride: vertexStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.weightArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.weightArray disable];
	[self resetSwitching];
}

-(GLfloat*) weightsAt: (GLuint) index {
	return (GLfloat*)[self addressOfElement: index];
}

-(void) setWeights: (GLfloat*) weights at: (GLuint) index {
	GLfloat* vertexWeights = [self weightsAt: index];
	GLint numWts = self.elementSize;
	for (int i = 0; i < numWts; i++) {
		vertexWeights[i] = weights[i];
	}
}

-(GLfloat) weightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return [self weightsAt: index][vertexUnit];
}

-(void) setWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
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

+(void) resetSwitching { currentWeightsTag = 0; }

@end


#pragma mark -
#pragma mark CC3VertexMatrixIndices

@implementation CC3VertexMatrixIndices

-(NSString*) nameSuffix { return @"MatrixIndices"; }

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
															withStride: vertexStride];
	[[CC3OpenGLES11Engine engine].clientCapabilities.matrixIndexArray enable];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.matrixIndexArray disable];
	[self resetSwitching];
}

-(GLvoid*) matrixIndicesAt: (GLuint) index {
	return [self addressOfElement: index];
}

-(void) setMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index {
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

-(GLuint) matrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	if (elementType == GL_UNSIGNED_BYTE) {
		GLubyte* vertexMatrices = (GLubyte*)[self addressOfElement: index];
		return vertexMatrices[vertexUnit];
	} else {
		GLushort* vertexMatrices = (GLushort*)[self addressOfElement: index];
		return vertexMatrices[vertexUnit];
	}
}

-(void) setMatrixIndex: (GLuint) aMatrixIndex forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
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

+(void) resetSwitching { currentMatrixIndicesTag = 0; }

@end
