/*
 * CC3OpenGLES11VertexArrays.m
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

-(id) init {
	if ( (self = [self initForState: GL_ARRAY_BUFFER]) ) {
		self.queryName = GL_ARRAY_BUFFER_BINDING;
	}
	return self;
}

-(void) setGLValue {
	glBindBuffer(name, value);
}

-(void) getGLValue {
	glGetIntegerv(queryName, &originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %i (was tracking %@)",
			 [self class], NSStringFromGLEnum(queryName), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%i", value] : @"UNKNOWN"));
}

-(void) unbind {
	self.value = 0;
}

-(void) loadBufferData: (GLvoid*) buffPtr  ofLength: (GLsizeiptr) buffLen forUse: (GLenum) buffUsage {
	glBufferData(name, buffLen, buffPtr, buffUsage);
}

-(void) updateBufferData: (GLvoid*) buffPtr
			  startingAt: (GLintptr) offset
			   forLength: (GLsizeiptr) length {
	glBufferSubData(name, offset, length, buffPtr);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerElementArrayBufferBinding

@implementation CC3OpenGLES11StateTrackerElementArrayBufferBinding

-(id) init {
	if ( (self = [self initForState: GL_ELEMENT_ARRAY_BUFFER]) ) {
		self.queryName = GL_ELEMENT_ARRAY_BUFFER_BINDING;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointer

@implementation CC3OpenGLES11StateTrackerVertexPointer

@synthesize elementSize, elementType, elementStride, elementPointer;

-(void) dealloc {
	[elementSize release];
	[elementType release];
	[elementStride release];
	[elementPointer release];
	[super dealloc];
}

+(BOOL) defaultShouldAlwaysSetGL {
	return YES;
}

-(void) initializeTrackers {}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	[super setOriginalValueHandling: origValueHandling];
	elementSize.originalValueHandling = origValueHandling;
	elementType.originalValueHandling = origValueHandling;
	elementStride.originalValueHandling = origValueHandling;
	elementPointer.originalValueHandling = origValueHandling;
} 

-(BOOL) valueIsKnown {
	return elementPointer.valueIsKnown
			&& elementStride.valueIsKnown
			&& elementSize.valueIsKnown
			&& elementType.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	elementSize.valueIsKnown = aBoolean;
	elementType.valueIsKnown = aBoolean;
	elementStride.valueIsKnown = aBoolean;
	elementPointer.valueIsKnown = aBoolean;
}

-(void) open {
	[elementSize open];
	[elementType open];
	[elementStride open];
	[elementPointer open];
}

-(void) restoreOriginalValue {
	[self useElementsAt: elementPointer.originalValue
			   withSize: elementSize.originalValue
			   withType: elementType.originalValue
			 withStride: elementStride.originalValue];
}

// Set the values in the GL engine if either we should always do it, or if something has changed
-(void) useElementsAt: (GLvoid*) pData
			 withSize: (GLint) elemSize
			 withType: (GLenum) elemType
		   withStride: (GLsizei) elemStride {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= [elementPointer attemptSetValue: pData];
	shouldSetGL |= [elementSize attemptSetValue: elemSize];
	shouldSetGL |= [elementType attemptSetValue: elemType];
	shouldSetGL |= [elementStride attemptSetValue: elemStride];
	if (shouldSetGL) {
		[self setGLValues];
	}
	[self logSetGLValues: shouldSetGL];
}

-(void) useElementsAt: (GLvoid*) pData withType: (GLenum) elemType withStride: (GLsizei) elemStride {
	[self useElementsAt: pData withSize: 0 withType: elemType withStride: elemStride];
}

-(void) setGLValues {}

-(void) logSetGLValues: (BOOL) wasChanged {
	if (elementSize.value != 0) {
		// GL function uses element size
		LogTrace("%@ %@ %@ = %i, %@ = %@, %@ = %i and %@ = %p", [self class], (wasChanged ? @"applied" : @"reused"),
				 NSStringFromGLEnum(elementSize.name), elementSize.value,
				 NSStringFromGLEnum(elementType.name), NSStringFromGLEnum(elementType.value),
				 NSStringFromGLEnum(elementStride.name), elementStride.value,
				 @"POINTER", elementPointer.value);
	} else {
		// GL function doesn't use element size
		LogTrace("%@ %@ %@ = %@, %@ = %i and %@ = %p", [self class], (wasChanged ? @"applied" : @"reused"),
				 NSStringFromGLEnum(elementType.name), NSStringFromGLEnum(elementType.value),
				 NSStringFromGLEnum(elementStride.name), elementStride.value,
				 @"POINTER", elementPointer.value);
	}
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", elementSize];
	[desc appendFormat: @"\n    %@ ", elementType];
	[desc appendFormat: @"\n    %@ ", elementStride];
	[desc appendFormat: @"\n    %@ ", elementPointer];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexLocationsPointer

@implementation CC3OpenGLES11StateTrackerVertexLocationsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_VERTEX_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_VERTEX_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_VERTEX_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer tracker];
}

-(void) setGLValues {
	glVertexPointer(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexNormalsPointer

@implementation CC3OpenGLES11StateTrackerVertexNormalsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger tracker];		// no-op tracker
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_NORMAL_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_NORMAL_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer tracker];
}

-(void) setGLValues {
	glNormalPointer(elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexColorsPointer

@implementation CC3OpenGLES11StateTrackerVertexColorsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_COLOR_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_COLOR_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_COLOR_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer tracker];
}

-(void) setGLValues {
	glColorPointer(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointSizesPointer

@implementation CC3OpenGLES11StateTrackerVertexPointSizesPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger tracker];		// no-op tracker
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_POINT_SIZE_ARRAY_TYPE_OES];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_POINT_SIZE_ARRAY_STRIDE_OES];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer tracker];
}

-(void) setGLValues {
	glPointSizePointerOES(elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11VertexArrays

@implementation CC3OpenGLES11VertexArrays

@synthesize arrayBuffer;
@synthesize indexBuffer;
@synthesize locations;
@synthesize normals;
@synthesize colors;
@synthesize pointSizes;

-(void) dealloc {
	[arrayBuffer release];
	[indexBuffer release];
	[locations release];
	[normals release];
	[colors release];
	[pointSizes release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.arrayBuffer = [CC3OpenGLES11StateTrackerArrayBufferBinding tracker];
	self.indexBuffer = [CC3OpenGLES11StateTrackerElementArrayBufferBinding tracker];
	self.locations = [CC3OpenGLES11StateTrackerVertexLocationsPointer tracker];
	self.normals = [CC3OpenGLES11StateTrackerVertexNormalsPointer tracker];
	self.colors = [CC3OpenGLES11StateTrackerVertexColorsPointer tracker];
	self.pointSizes = [CC3OpenGLES11StateTrackerVertexPointSizesPointer tracker];
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

-(void) open {
	LogTrace("Opening %@", [self class]);
	[arrayBuffer open];
	[indexBuffer open];
	[locations open];
	[normals open];
	[colors open];
	[pointSizes open];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[arrayBuffer close];
	[indexBuffer close];
	[locations close];
	[normals close];
	[colors close];
	[pointSizes close];
}

-(GLuint) generateBuffer {
	GLuint buffID;
	glGenBuffers(1, &buffID);
	return buffID;
}

-(void) deleteBuffer: (GLuint) buffID  {
	glDeleteBuffers(1, &buffID);
}

-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len {
	glDrawArrays(drawMode, start, len);
} 

-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode {
	glDrawElements(drawMode, len, type, indicies);
} 

@end
