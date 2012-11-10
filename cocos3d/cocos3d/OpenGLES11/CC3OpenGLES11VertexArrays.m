/*
 * CC3OpenGLES11VertexArrays.m
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
 * See header file CC3OpenGLES11VertexArrays.h for full API documentation.
 */

#import "CC3OpenGLES11VertexArrays.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerArrayBufferBinding

@implementation CC3OpenGLES11StateTrackerArrayBufferBinding

@synthesize queryName;

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [self initWithParent: aTracker
							 forState: GL_ARRAY_BUFFER]) ) {
		self.queryName = GL_ARRAY_BUFFER_BINDING;
	}
	return self;
}

-(void) setGLValue { glBindBuffer(name, value); }

-(void) getGLValue { glGetIntegerv(queryName, &originalValue); }

-(void) unbind { self.value = 0; }

-(void) loadBufferData: (GLvoid*) buffPtr  ofLength: (GLsizeiptr) buffLen forUse: (GLenum) buffUsage {
	glBufferData(name, buffLen, buffPtr, buffUsage);
	LogGLErrorTrace(@"while loading buffer data of length %i from %p for use %@ for %@",
					buffLen, buffPtr, NSStringFromGLEnum(buffUsage), self);
}

-(void) updateBufferData: (GLvoid*) buffPtr
			  startingAt: (GLintptr) offset
			   forLength: (GLsizeiptr) length {
	glBufferSubData(name, offset, length, buffPtr);
	LogGLErrorTrace(@"while updating buffer data of length %i at offset %i from %p for",
					length, offset, buffPtr, self);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerElementArrayBufferBinding

@implementation CC3OpenGLES11StateTrackerElementArrayBufferBinding

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [self initWithParent: aTracker forState: GL_ELEMENT_ARRAY_BUFFER]) ) {
		self.queryName = GL_ELEMENT_ARRAY_BUFFER_BINDING;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointer

@interface CC3OpenGLES11StateTrackerInteger (VertexPointer)
-(void) setValueRaw:(GLint) value;
@end

@interface CC3OpenGLES11StateTrackerEnumeration (VertexPointer)
-(void) setValueRaw:(GLenum) value;
@end

@interface CC3OpenGLES11StateTrackerPointer (VertexPointer)
-(void) setValueRaw:(GLvoid*) value;
@end

@implementation CC3OpenGLES11StateTrackerVertexPointer

@synthesize elementSize, elementType, vertexStride, vertices;

-(void) dealloc {
	[elementSize release];
	[elementType release];
	[vertexStride release];
	[vertices release];
	[super dealloc];
}

+(BOOL) defaultShouldAlwaysSetGL { return YES; }

-(void) initializeTrackers {}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	[super setOriginalValueHandling: origValueHandling];
	elementSize.originalValueHandling = origValueHandling;
	elementType.originalValueHandling = origValueHandling;
	vertexStride.originalValueHandling = origValueHandling;
	vertices.originalValueHandling = origValueHandling;
} 

-(BOOL) valueIsKnown {
	return vertices.valueIsKnown
			&& vertexStride.valueIsKnown
			&& elementSize.valueIsKnown
			&& elementType.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	elementSize.valueIsKnown = aBoolean;
	elementType.valueIsKnown = aBoolean;
	vertexStride.valueIsKnown = aBoolean;
	vertices.valueIsKnown = aBoolean;
}

// Set the values in the GL engine if either we should always do it, or if something has changed
-(void) useElementsAt: (GLvoid*) pData
			 withSize: (GLint) elemSize
			 withType: (GLenum) elemType
		   withStride: (GLsizei) elemStride {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!vertices.valueIsKnown || pData != vertices.value);
	shouldSetGL |= (!elementSize.valueIsKnown || elemSize != elementSize.value);
	shouldSetGL |= (!elementType.valueIsKnown || elemType != elementType.value);
	shouldSetGL |= (!vertexStride.valueIsKnown || elemStride != vertexStride.value);
	if (shouldSetGL) {
		[vertices setValueRaw: pData];
		[elementSize setValueRaw: elemSize];
		[elementType setValueRaw: elemType];
		[vertexStride setValueRaw: elemStride];
		[self setGLValues];
		LogGLErrorTrace(@"while setting GL values for %@", self);
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
}

-(void) useElementsAt: (GLvoid*) pData withType: (GLenum) elemType withStride: (GLsizei) elemStride {
	[self useElementsAt: pData withSize: 0 withType: elemType withStride: elemStride];
}

/** Invoked when dynamically instantiated (specifically with texture units. */
-(void) open {
	[super open];
	[elementSize open];
	[elementType open];
	[vertexStride open];
	[vertices open];
}

-(BOOL) valueNeedsRestoration {
	return (vertices.valueNeedsRestoration ||
			elementSize.valueNeedsRestoration ||
			elementType.valueNeedsRestoration ||
			vertexStride.valueNeedsRestoration);
}

-(void) restoreOriginalValues {
	[vertices restoreOriginalValue];
	[elementSize restoreOriginalValue];
	[elementType restoreOriginalValue];
	[vertexStride restoreOriginalValue];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", elementSize];
	[desc appendFormat: @"\n    %@ ", elementType];
	[desc appendFormat: @"\n    %@ ", vertexStride];
	[desc appendFormat: @"\n    %@ ", vertices];
	return desc;
}

// Deprecated methods
-(CC3OpenGLES11StateTrackerInteger*) elementStride { return self.vertexStride; }
-(void) setElementStride: (CC3OpenGLES11StateTrackerInteger*) elemStride { self.vertexStride = elemStride; }
-(CC3OpenGLES11StateTrackerPointer*) elementPointer { return self.vertices; }
-(void) setElementPointer: (CC3OpenGLES11StateTrackerPointer*) vtxPtr { self.vertices = vtxPtr; }

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexLocationsPointer

@implementation CC3OpenGLES11StateTrackerVertexLocationsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_VERTEX_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_VERTEX_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_VERTEX_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glVertexPointer(elementSize.value, elementType.value, vertexStride.value, vertices.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexNormalsPointer

@implementation CC3OpenGLES11StateTrackerVertexNormalsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self];		// no-op tracker
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_NORMAL_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_NORMAL_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glNormalPointer(elementType.value, vertexStride.value, vertices.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexColorsPointer

@implementation CC3OpenGLES11StateTrackerVertexColorsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_COLOR_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_COLOR_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_COLOR_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glColorPointer(elementSize.value, elementType.value, vertexStride.value, vertices.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointSizesPointer

@implementation CC3OpenGLES11StateTrackerVertexPointSizesPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self];		// no-op tracker
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_POINT_SIZE_ARRAY_TYPE_OES];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_POINT_SIZE_ARRAY_STRIDE_OES];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glPointSizePointerOES(elementType.value, vertexStride.value, vertices.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexWeightsPointer

@implementation CC3OpenGLES11StateTrackerVertexWeightsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_WEIGHT_ARRAY_SIZE_OES];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_WEIGHT_ARRAY_TYPE_OES];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_WEIGHT_ARRAY_STRIDE_OES];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glWeightPointerOES(elementSize.value, elementType.value, vertexStride.value, vertices.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer

@implementation CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_MATRIX_INDEX_ARRAY_SIZE_OES];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_MATRIX_INDEX_ARRAY_TYPE_OES];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_MATRIX_INDEX_ARRAY_STRIDE_OES];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glMatrixIndexPointerOES(elementSize.value, elementType.value, vertexStride.value, vertices.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11VertexArrays

@implementation CC3OpenGLES11VertexArrays

@synthesize arrayBuffer;
@synthesize indexBuffer;
@synthesize locations;
@synthesize matrixIndices;
@synthesize normals;
@synthesize colors;
@synthesize pointSizes;
@synthesize weights;

-(void) dealloc {
	[arrayBuffer release];
	[indexBuffer release];
	[locations release];
	[matrixIndices release];
	[normals release];
	[colors release];
	[pointSizes release];
	[weights release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.arrayBuffer = [CC3OpenGLES11StateTrackerArrayBufferBinding trackerWithParent: self];
	self.indexBuffer = [CC3OpenGLES11StateTrackerElementArrayBufferBinding trackerWithParent: self];
	self.locations = [CC3OpenGLES11StateTrackerVertexLocationsPointer trackerWithParent: self];
	self.matrixIndices = [CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer trackerWithParent: self];
	self.normals = [CC3OpenGLES11StateTrackerVertexNormalsPointer trackerWithParent: self];
	self.colors = [CC3OpenGLES11StateTrackerVertexColorsPointer trackerWithParent: self];
	self.pointSizes = [CC3OpenGLES11StateTrackerVertexPointSizesPointer trackerWithParent: self];
	self.weights = [CC3OpenGLES11StateTrackerVertexWeightsPointer trackerWithParent: self];
}

-(CC3OpenGLES11StateTrackerArrayBufferBinding*) bufferBinding: (GLenum) bufferTarget {
	switch (bufferTarget) {
		case GL_ARRAY_BUFFER:
			return arrayBuffer;
		case GL_ELEMENT_ARRAY_BUFFER:
			return indexBuffer;
		default:
			NSAssert1(NO, @"Illegal buffer target %u", bufferTarget);
			return nil;
	}
}

-(GLuint) generateBuffer {
	GLuint buffID;
	glGenBuffers(1, &buffID);
	LogGLErrorTrace(@"%@ generate buffer ID", self);
	return buffID;
}

-(void) deleteBuffer: (GLuint) buffID  {
	glDeleteBuffers(1, &buffID);
	LogGLErrorTrace(@"%@ delete buffer %i", self, buffID);
}

-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len {
	glDrawArrays(drawMode, start, len);
	LogGLErrorTrace(@"%@ drawing %u vertices as %@ starting from %u",
					self, len, NSStringFromGLEnum(drawMode), start);
}

-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode {
	NSAssert((type == GL_UNSIGNED_SHORT || type == GL_UNSIGNED_BYTE), @"OpenGL ES 1.1 supports only GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE types for vertex indices");
	glDrawElements(drawMode, len, type, indicies);
	LogGLErrorTrace(@"%@ drawing %u vertex indices as %@", self, len, NSStringFromGLEnum(drawMode));
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", arrayBuffer];
	[desc appendFormat: @"\n    %@ ", indexBuffer];
	[desc appendFormat: @"\n    %@ ", locations];
	[desc appendFormat: @"\n    %@ ", matrixIndices];
	[desc appendFormat: @"\n    %@ ", normals];
	[desc appendFormat: @"\n    %@ ", colors];
	[desc appendFormat: @"\n    %@ ", pointSizes];
	[desc appendFormat: @"\n    %@ ", weights];
	return desc;
}

@end
