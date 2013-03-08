/*
 * CC3OpenGLESVertexArrays.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLESVertexArrays.h for full API documentation.
 */

#import "CC3OpenGLESVertexArrays.h"
#import "CC3CC2Extensions.h"

#pragma mark -
#pragma mark CC3OpenGLESStateTrackerArrayBufferBinding

@implementation CC3OpenGLESStateTrackerArrayBufferBinding

@synthesize queryName;

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
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
	ccGLBindVAO(0);		// Ensure that a VAO was not left in place by cocos2d
	glBufferData(name, buffLen, buffPtr, buffUsage);
	LogGLErrorTrace(@"while loading buffer data of length %i from %p for use %@ for %@",
					buffLen, buffPtr, NSStringFromGLEnum(buffUsage), self);
}

-(void) updateBufferData: (GLvoid*) buffPtr
			  startingAt: (GLintptr) offset
			   forLength: (GLsizeiptr) length {
	ccGLBindVAO(0);		// Ensure that a VAO was not left in place by cocos2d
	glBufferSubData(name, offset, length, buffPtr);
	LogGLErrorTrace(@"while updating buffer data of length %i at offset %i from %p for",
					length, offset, buffPtr, self);
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerElementArrayBufferBinding

@implementation CC3OpenGLESStateTrackerElementArrayBufferBinding

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker {
	if ( (self = [self initWithParent: aTracker forState: GL_ELEMENT_ARRAY_BUFFER]) ) {
		self.queryName = GL_ELEMENT_ARRAY_BUFFER_BINDING;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexPointer

@interface CC3OpenGLESStateTrackerInteger (VertexPointer)
-(void) setValueRaw: (GLint) value;
@end

@interface CC3OpenGLESStateTrackerEnumeration (VertexPointer)
-(void) setValueRaw: (GLenum) value;
@end

@interface CC3OpenGLESStateTrackerBoolean (VertexPointer)
-(void) setValueRaw: (BOOL) value;
@end

@interface CC3OpenGLESStateTrackerPointer (VertexPointer)
-(void) setValueRaw: (GLvoid*) value;
@end

@implementation CC3OpenGLESStateTrackerVertexPointer

@synthesize capability=_capability;
@synthesize vertices=_vertices;
@synthesize elementSize=_elementSize;
@synthesize elementType=_elementType;
@synthesize vertexStride=_vertexStride;
@synthesize shouldNormalize=_shouldNormalize;
@synthesize wasBound=_wasBound;

-(void) dealloc {
	[_capability release];
	[_elementSize release];
	[_elementType release];
	[_vertexStride release];
	[_vertices release];
	[_shouldNormalize release];
	[super dealloc];
}

+(BOOL) defaultShouldAlwaysSetGL { return YES; }

-(void) initializeTrackers {}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	[super setOriginalValueHandling: origValueHandling];
	_elementSize.originalValueHandling = origValueHandling;
	_elementType.originalValueHandling = origValueHandling;
	_vertexStride.originalValueHandling = origValueHandling;
	_vertices.originalValueHandling = origValueHandling;
	_shouldNormalize.originalValueHandling = origValueHandling;
}

-(BOOL) valueIsKnown {
	return _vertices.valueIsKnown
			&& _vertexStride.valueIsKnown
			&& _elementSize.valueIsKnown
			&& _elementType.valueIsKnown
			&& _shouldNormalize.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	_elementSize.valueIsKnown = aBoolean;
	_elementType.valueIsKnown = aBoolean;
	_vertexStride.valueIsKnown = aBoolean;
	_vertices.valueIsKnown = aBoolean;
	_shouldNormalize.valueIsKnown = aBoolean;
}

-(void) enable { [self.capability enable]; }

-(void) disable { [self.capability disable]; }

-(void) disableIfUnbound { if ( !_wasBound ) [self disable]; }

// Bind the values in the GL engine if either we should always do it, or if something has changed
-(void) bindElementsAt: (GLvoid*) pData
			  withSize: (GLint) elemSize
			  withType: (GLenum) elemType
			withStride: (GLsizei) elemStride
   withShouldNormalize: (BOOL) shldNorm {
	BOOL shouldSetGL = self.shouldAlwaysSetGL || !self.valueIsKnown;
	shouldSetGL |= (pData != _vertices.value);
	shouldSetGL |= (elemSize != _elementSize.value);
	shouldSetGL |= (elemType != _elementType.value);
	shouldSetGL |= (elemStride != _vertexStride.value);
	shouldSetGL |= (shldNorm != _shouldNormalize.value);
	if (shouldSetGL) {
		[_vertices setValueRaw: pData];
		[_elementSize setValueRaw: elemSize];
		[_elementType setValueRaw: elemType];
		[_vertexStride setValueRaw: elemStride];
		[_shouldNormalize setValueRaw: shldNorm];

		LogTrace(@"Setting GL value for %@", self);
		[self setGLValues];
		LogGLErrorTrace(@"while setting GL values for %@", self);
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	[self enable];
	self.wasBound = YES;
}

/** Invoked when dynamically instantiated (specifically with texture units. */
-(void) open {
	[super open];
	[_capability open];
	[_elementSize open];
	[_elementType open];
	[_vertexStride open];
	[_vertices open];
	[_shouldNormalize open];
}

-(BOOL) valueNeedsRestoration {
	return (_vertices.valueNeedsRestoration ||
			_elementSize.valueNeedsRestoration ||
			_elementType.valueNeedsRestoration ||
			_vertexStride.valueNeedsRestoration ||
			_shouldNormalize.valueNeedsRestoration);
}

-(void) restoreOriginalValues {
	[_vertices restoreOriginalValue];
	[_elementSize restoreOriginalValue];
	[_elementType restoreOriginalValue];
	[_vertexStride restoreOriginalValue];
	[_shouldNormalize restoreOriginalValue];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@ (%@bound):", [self class], (_wasBound ? @"" : @"un")];
	[desc appendFormat: @"\n        %@ ", _capability];
	[desc appendFormat: @"\n        %@ ", _elementSize];
	[desc appendFormat: @"\n        %@ ", _elementType];
	[desc appendFormat: @"\n        %@ ", _vertexStride];
	[desc appendFormat: @"\n        %@ ", _shouldNormalize];
	[desc appendFormat: @"\n        %@ ", _vertices];
	return desc;
}

// Deprecated methods
-(CC3OpenGLESStateTrackerInteger*) elementStride { return self.vertexStride; }
-(void) setElementStride: (CC3OpenGLESStateTrackerInteger*) elemStride { self.vertexStride = elemStride; }
-(CC3OpenGLESStateTrackerPointer*) elementPointer { return self.vertices; }
-(void) setElementPointer: (CC3OpenGLESStateTrackerPointer*) vtxPtr { self.vertices = vtxPtr; }

@end


#pragma mark -
#pragma mark CC3OpenGLESVertexArrays

@implementation CC3OpenGLESVertexArrays

@synthesize arrayBuffer;
@synthesize indexBuffer;

-(void) dealloc {
	[arrayBuffer release];
	[indexBuffer release];
	[super dealloc];
}

-(CC3OpenGLESStateTrackerArrayBufferBinding*) bufferBinding: (GLenum) bufferTarget {
	switch (bufferTarget) {
		case GL_ARRAY_BUFFER:
			return arrayBuffer;
		case GL_ELEMENT_ARRAY_BUFFER:
			return indexBuffer;
		default:
			CC3Assert(NO, @"Illegal buffer target %u", bufferTarget);
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

-(CC3OpenGLESStateTrackerVertexPointer*) vertexPointerForSemantic: (GLenum) semantic
															   at:(GLuint)semanticIndex {
	return nil;
}

-(CC3OpenGLESStateTrackerVertexPointer*) vertexPointerForSemantic: (GLenum) semantic {
	return [self vertexPointerForSemantic: semantic at: 0];
}

-(void) clearUnboundVertexPointers {}

-(void) disableUnboundVertexPointers {}

-(void) enable2DVertexPointers {}

-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len {
	glDrawArrays(drawMode, start, len);
	LogGLErrorTrace(@"%@ drawing %u vertices as %@ starting from %u",
					self, len, NSStringFromGLEnum(drawMode), start);
	CC_INCREMENT_GL_DRAWS(1);
}

-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode {
	CC3Assert((type == GL_UNSIGNED_SHORT || type == GL_UNSIGNED_BYTE), @"OpenGL ES permits drawing a maximum of 65536 indexed vertices, and supports only GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE types for vertex indices");
	glDrawElements(drawMode, len, type, indicies);
	LogGLErrorTrace(@"%@ drawing %u vertex indices as %@", self, len, NSStringFromGLEnum(drawMode));
	CC_INCREMENT_GL_DRAWS(1);
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", self.arrayBuffer];
	[desc appendFormat: @"\n    %@ ", self.indexBuffer];
	return desc;
}

@end
