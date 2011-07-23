/*
 * CC3VertexArrays.m
 *
 * cocos3d 0.6.0-sp
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
 * See header file CC3VertexArrays.h for full API documentation.
 */

#import "CC3VertexArrays.h"
#import "CC3OpenGLES11Utility.h"
#import "CC3OpenGLES11Engine.h"

#pragma mark CC3VertexArray

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

@interface CC3VertexArray (TemplateMethods)
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor;
@property(nonatomic, readonly) BOOL switchingArray;
@end


@implementation CC3VertexArray

@synthesize elements, elementCount, elementSize, elementType, elementStride;
@synthesize bufferID, elementOffset, bufferUsage;
@synthesize shouldAllowVertexBuffering, shouldReleaseRedundantData;

-(void) dealloc {
	[self deleteGLBuffer];
	[self deallocateElements];
	[super dealloc];
}

-(GLsizei) elementStride {
	return elementStride ? elementStride : GLElementTypeSize(elementType) * elementSize;
}

-(GLenum) bufferTarget {
	return GL_ARRAY_BUFFER;
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elements = nil;
		elementCount = 0;
		elementType = GL_FLOAT;
		elementSize = 3;
		elementStride = 0;
		bufferID = 0;
		bufferUsage = GL_STATIC_DRAW;
		elementOffset = 0;
		elementsAreRetained = NO;
		shouldAllowVertexBuffering = YES;
		shouldReleaseRedundantData = YES;
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

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexArray*) another {
	[super populateFrom: another];

	elementType = another.elementType;
	elementSize = another.elementSize;
	elementStride = another.elementStride;
	bufferUsage = another.bufferUsage;
	elementOffset = another.elementOffset;
	shouldAllowVertexBuffering = another.shouldAllowVertexBuffering;
	shouldReleaseRedundantData = another.shouldReleaseRedundantData;

	[self deleteGLBuffer];		// Data has yet to be buffered. Get rid of old buffer if necessary.

	// Allocate memory and copy the vertex data over.
	// Watch out! If this array is part of interleaved data, this will result in multiple copies
	// of the interleaved data, which is probably not what is wanted.
	[self allocateElements: another.elementCount];
	memcpy(elements, another.elements, elementCount * elementStride);
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
		elementCount = elemCount;
		self.elements = calloc(elementCount, self.elementStride);	// Safely disposes existing elements
		elementsAreRetained = YES;
		LogTrace(@"%@ allocated space for %u elements", self, elementCount);
	} else {
		[self deallocateElements];
	}
	return elements;
}

// Does not change elementCount, because that is used for drawing.
-(void) deallocateElements {
	if (elementsAreRetained && elements) {
		free(elements);
		elements = NULL;
		elementsAreRetained = NO;
		LogTrace(@"%@ deallocated %u previously allocated elements", self, elementCount);
	}
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
		GLsizeiptr buffSize = self.elementStride * elementCount;
		bufferBinding.value = bufferID;
		[bufferBinding loadBufferData: elements ofLength: buffSize forUse: bufferUsage];
		GLenum errCode = glGetError();
		if (errCode) {
			LogInfo(@"Could not create GL buffer of type %@ because of %@. Using app memory arrays.",
					NSStringFromGLEnum(self.bufferTarget), GetGLErrorText(errCode));
			[self deleteGLBuffer];
		}
		[bufferBinding unbind];
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
	}
}

-(void) updateGLBuffer {
	[self updateGLBufferStartingAt: 0 forLength: elementCount];
}

-(void) releaseRedundantData {
	if (bufferID && shouldReleaseRedundantData) {
		[self deallocateElements];
	}
}

-(void) deleteGLBuffer {
	if (bufferID) {
		[[CC3OpenGLES11Engine engine].vertices deleteBuffer: bufferID];
		bufferID = 0;	
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

-(void) unbind {
	[[self class] unbind];
}

// Default does nothing. Subclasses will override.
+(void) unbind {}


#pragma mark Accessing elements

-(GLvoid*) addressOfElement: (GLsizei) index {
	NSAssert(elements, @"Elements are no longer in application memory.");
	return (GLbyte*)elements + (self.elementStride * index) + elementOffset;
}


#pragma mark Array context switching

/**
 * Returns whether this vertex array is different than the vertex array of the same type
 * that was most recently bound to the GL engine. To improve performance, vertex arrays
 * are only bound if they need to be.
 *
 * If appropriate, the application can arrange CC3MeshNodes in the CC3World so that nodes
 * using the same vertex arrays are drawn together, to minimize the number of binding
 * changes in the GL engine.
 */
-(BOOL) switchingArray {
	return YES;
}

+(void) resetSwitching {}

@end


#pragma mark -
#pragma mark CC3DrawableVertexArray

@interface CC3DrawableVertexArray (TemplateArray)
-(void) drawStripOfLength: (GLuint) stripLen startingAt: (GLuint) startOfStrip;
-(GLsizei) faceCountFromVertexCount: (GLsizei) vc;
-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc;
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
	GLuint startOfStrip = self.firstElement;
	if (stripCount) {
		LogTrace(@"%@ drawing %u strips", self, stripCount);
		for (uint i=0; i < stripCount; i++) {
			GLuint stripLen = stripLengths[i];
			[self drawStripOfLength: stripLen startingAt: startOfStrip];
			[visitor.performanceStatistics addSingleCallFacesPresented: [self faceCountFromVertexCount: stripLen]];
			startOfStrip += stripLen;
		}
	} else {
		[self drawStripOfLength: elementCount startingAt: startOfStrip];
		[visitor.performanceStatistics addSingleCallFacesPresented: [self faceCountFromVertexCount: elementCount]];
	}
}


/**
 * Draws a single strip of vertices, of the specified number of elements, starting at
 * the element at startOfStrip.
 *
 * If drawing is to be performed in a single GL call, this method can be invoked
 * with stripLen equal to the elementCount property, and startOfStrip equal to the
 * firstElement property.
 *
 * This abstract implementation does nothing. Subclasses will override.
 */
-(void) drawStripOfLength: (GLuint) stripLen startingAt: (GLuint) startOfStrip {} 

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
			LogError(@"%@ encountered unknown drawing mode %u", self, self.drawingMode);
			return vc;
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
			LogError(@"%@ encountered unknown drawing mode %u", self, self.drawingMode);
			return fc;
	}
}

@end


#pragma mark -
#pragma mark CC3VertexLocations

@interface CC3VertexLocations (TemplateMethods)
-(void) buildBoundingBox;
-(void) buildBoundingBoxIfNecessary;
@end


@implementation CC3VertexLocations

@synthesize firstElement, boundingBoxNeedsBuilding;

-(void) setElements: (GLvoid*) elems {
	[super setElements: elems];
	self.boundingBoxNeedsBuilding = YES;
}

-(id) init {
	if ( (self = [super init]) ) {
		firstElement = 0;
		centerOfGeometry = kCC3VectorZero;
		boundingBox.minimum = kCC3VectorZero;
		boundingBox.maximum = kCC3VectorZero;
		self.boundingBoxNeedsBuilding = YES;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3VertexLocations*) another {
	[super populateFrom: another];

	firstElement = another.firstElement;
	boundingBox = another.boundingBox;
	centerOfGeometry = another.centerOfGeometry;
	boundingBoxNeedsBuilding = another.boundingBoxNeedsBuilding;
}

-(CC3Vector) locationAt: (GLsizei) index {
	return *(CC3Vector*)[self addressOfElement: index];
}

-(void) setLocation: (CC3Vector) aLocation at: (GLsizei) index {
	*(CC3Vector*)[self addressOfElement: index] = aLocation;
	self.boundingBoxNeedsBuilding = YES;
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
	if (boundingBoxNeedsBuilding) {
		[self buildBoundingBox];
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
	vl = [self locationAt: 0];
	vlMin = vl;
	vlMax = vl;
	for (GLsizei i = 1; i < elementCount; i++) {
		vl = [self locationAt: i];
		vlMin = CC3VectorMinimize(vlMin, vl);
		vlMax = CC3VectorMaximize(vlMax, vl);
	}
	boundingBox.minimum = vlMin;
	boundingBox.maximum = vlMax;
	centerOfGeometry = CC3VectorScaleUniform(CC3VectorAdd(vlMax, vlMin), 0.5);
	self.boundingBoxNeedsBuilding = NO;
	LogTrace(@"%@ bounding box: (%@, %@) and center of geometry: %@", self,
			 NSStringFromCC3Vector(boundingBox.minimum),
			 NSStringFromCC3Vector(boundingBox.maximum),
			 NSStringFromCC3Vector(centerOfGeometry));
}

-(void) movePivotTo: (CC3Vector) aLocation {
	for (GLsizei i = 0; i < elementCount; i++) {
		CC3Vector locOld = [self locationAt: i];
		CC3Vector locNew = CC3VectorDifference(locOld, aLocation);
		[self setLocation: locNew at: i];
	}
	self.boundingBoxNeedsBuilding = YES;
}

-(void) movePivotToCenterOfGeometry {
	[self movePivotTo: self.centerOfGeometry];
}


#pragma mark Binding GL artifacts

/** Overridden to ensure the bounding box is built before releasing the vertices. */
-(void) releaseRedundantData {
	[self buildBoundingBoxIfNecessary];
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

-(void) drawStripOfLength: (GLuint) stripLen startingAt: (GLuint) startOfStrip {
	LogTrace(@"%@ drawing %u vertices", self, stripLen);
	[[CC3OpenGLES11Engine engine].vertices drawVerticiesAs: drawingMode
												startingAt: startOfStrip
												withLength: stripLen];
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
		elementSize = 4;
	}
	return self;
}

-(ccColor4F) color4FAt: (GLsizei) index {
	return *(ccColor4F*)[self addressOfElement: index];
}

-(void) setColor4F: (ccColor4F) aColor at: (GLsizei) index {
	*(ccColor4F*)[self addressOfElement: index] = aColor;
}

-(ccColor4B) color4BAt: (GLsizei) index {
	return *(ccColor4B*)[self addressOfElement: index];
}

-(void) setColor4B: (ccColor4B) aColor at: (GLsizei) index {
	*(ccColor4B*)[self addressOfElement: index] = aColor;
}

-(void) bindPointer: (GLvoid*) pointer withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	[gles11Engine.vertices.colors useElementsAt: pointer
									   withSize: elementSize
									   withType: elementType
									 withStride: elementStride];
	[gles11Engine.clientCapabilities.colorArray enable];
//	[gles11Engine.serverCapabilities.colorMaterial enable];

	// Since material color tracking mucks with both ambient and diffuse material colors under
	// the covers, we won't really know what the ambient and diffuse material color values will
	// be when we get back to setting them...so indicate that to the corresponding trackers.
	gles11Engine.materials.ambientColor.valueIsKnown = NO;
	gles11Engine.materials.diffuseColor.valueIsKnown = NO;
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].clientCapabilities.colorArray disable];
//	[[CC3OpenGLES11Engine engine].serverCapabilities.colorMaterial disable];
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

@implementation CC3VertexTextureCoordinates

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		elementSize = 2;
	}
	return self;
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

+(void) unbind {
	[self unbindRemainingFrom: 0];
}

-(void) alignWithTextureMapSize: (ccTex2F) texMapSize {
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u *= texMapSize.u;
		ptc->v *= texMapSize.v;
	}
}

-(void) alignWithInvertedTextureMapSize: (ccTex2F) texMapSize {
	for (GLsizei i = 0; i < elementCount; i++) {
		ccTex2F* ptc = (ccTex2F*)[self addressOfElement: i];
		ptc->u *= texMapSize.u;
		ptc->v = (1.0 - ptc->v) * texMapSize.v;
	}
}

-(void) alignWithTexture: (CC3Texture*) texture {
	[self alignWithTextureMapSize: texture.mapSize];
}

-(void) alignWithInvertedTexture: (CC3Texture*) texture {
	[self alignWithInvertedTextureMapSize: texture.mapSize];
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
#pragma mark CC3VertexPointSizes

@implementation CC3VertexPointSizes

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
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
	}
	return self;
}

-(GLushort) indexAt: (GLsizei) index {
	GLvoid* ptr = [self addressOfElement: index];
	return elementType == GL_UNSIGNED_BYTE ? *(GLubyte*)ptr : *(GLushort*)ptr;
}

-(void) setIndex: (GLushort) anIndex at: (GLsizei) index {
	GLvoid* ptr = [self addressOfElement: index];
	if (elementType == GL_UNSIGNED_BYTE) {
		*(GLubyte*)ptr = anIndex;
	} else {
		*(GLushort*)ptr = anIndex;
	}
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

-(void) drawStripOfLength: (GLuint) stripLen startingAt: (GLuint) startOfStrip {
	LogTrace(@"%@ drawing %u indices", self, stripLen);
	[[CC3OpenGLES11Engine engine].vertices drawIndicies: (GLvoid*)startOfStrip
											   ofLength: stripLen
												andType: elementType
													 as: drawingMode];
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
#pragma mark CC3IndexRunLengthArray

@implementation CC3VertexRunLengthIndices

// Since we want to use a run-length encoded index array, we need local control, so don't attempt to create a buffer
-(void) createGLBuffer {}

// Since we want to use a run-length encoded index array, we need local control, so remove any buffer binding.
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ using local array", self);
	[[[CC3OpenGLES11Engine engine].vertices bufferBinding: self.bufferTarget] unbind];
}

// Draws the mesh using a RLE (run-length encoded) index array
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ drawing %u indices using local run-length array", self, elementCount);
	GLubyte* elementsAsBytes = (GLubyte*) elements;
	GLushort* elementsAsShorts = (GLushort*) elements;
	switch (elementType) {
		case GL_UNSIGNED_BYTE:
			for(int i = 0; i < elementCount; i += elementsAsBytes[i] + 1) {
				[[CC3OpenGLES11Engine engine].vertices drawIndicies: &elementsAsBytes[i+1]
														   ofLength: elementsAsBytes[i]
															andType: elementType
																 as: drawingMode];
				[visitor.performanceStatistics addSingleCallFacesPresented: [self faceCountFromVertexCount: elementsAsBytes[i]]];
			}
			break;
		case GL_UNSIGNED_SHORT:
			for(int i = 0; i < elementCount; i += elementsAsShorts[i] + 1) {
				[[CC3OpenGLES11Engine engine].vertices drawIndicies: &elementsAsShorts[i+1]
														   ofLength: elementsAsShorts[i]
															andType: elementType
																 as: drawingMode];
				[visitor.performanceStatistics addSingleCallFacesPresented: [self faceCountFromVertexCount: elementsAsShorts[i]]];
			}
			break;
		default:
			LogError(@"Illegal index element type in %@: %u", self, elementType);
			break;
	}	
}

@end
