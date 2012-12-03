/*
 * CC3OpenGLES2VertexArrays.m
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
 * See header file CC3OpenGLESVertexArrays.h for full API documentation.
 */

#import "CC3OpenGLES2VertexArrays.h"
#import "CC3OpenGLESEngine.h"
#import "CC3VertexArrays.h"


#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeInteger

@implementation CC3OpenGLESStateTrackerVertexAttributeInteger

-(GLuint) attributeIndex { return ((CC3OpenGLES2StateTrackerVertexAttributesPointer*)self.parent).attributeIndex; }

-(void) getGLValue { glGetVertexAttribiv(self.attributeIndex, name, &originalValue); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnce;
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeEnumeration

@implementation CC3OpenGLESStateTrackerVertexAttributeEnumeration

-(GLuint) attributeIndex { return ((CC3OpenGLES2StateTrackerVertexAttributesPointer*)self.parent).attributeIndex; }

-(void) getGLValue { glGetVertexAttribiv(self.attributeIndex, name, (GLint*)&originalValue); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnce;
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeBoolean

@implementation CC3OpenGLESStateTrackerVertexAttributeBoolean

-(GLuint) attributeIndex { return ((CC3OpenGLES2StateTrackerVertexAttributesPointer*)self.parent).attributeIndex; }

-(void) getGLValue {
	GLint glValue;
	glGetVertexAttribiv(self.attributeIndex, name, &glValue);
	originalValue = (glValue != GL_FALSE);
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnce;
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeCapability

@implementation CC3OpenGLESStateTrackerVertexAttributeCapability

-(GLuint) attributeIndex { return ((CC3OpenGLES2StateTrackerVertexAttributesPointer*)self.parent).attributeIndex; }

-(void) getGLValue {
	GLint glValue;
	glGetVertexAttribiv(self.attributeIndex, name, &glValue);
	originalValue = (glValue != GL_FALSE);
}

-(void) setGLValue {
	if (value) {
		glEnableVertexAttribArray(self.attributeIndex);
	} else {
		glDisableVertexAttribArray(self.attributeIndex);
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2StateTrackerVertexAttributesPointer

@implementation CC3OpenGLES2StateTrackerVertexAttributesPointer

-(void) initializeTrackers {
	self.capability = [CC3OpenGLESStateTrackerVertexAttributeCapability trackerWithParent: self
																				 forState: GL_VERTEX_ATTRIB_ARRAY_ENABLED];
	self.elementSize = [CC3OpenGLESStateTrackerVertexAttributeInteger trackerWithParent: self
																			   forState: GL_VERTEX_ATTRIB_ARRAY_SIZE];
	self.elementType = [CC3OpenGLESStateTrackerVertexAttributeEnumeration trackerWithParent: self
																				   forState: GL_VERTEX_ATTRIB_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLESStateTrackerVertexAttributeInteger trackerWithParent: self
																				forState: GL_VERTEX_ATTRIB_ARRAY_STRIDE];
	self.shouldNormalize = [CC3OpenGLESStateTrackerVertexAttributeBoolean trackerWithParent: self
																				   forState: GL_VERTEX_ATTRIB_ARRAY_NORMALIZED];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glVertexAttribPointer(_attributeIndex, _elementSize.value, _elementType.value,
						  _shouldNormalize.value, _vertexStride.value, _vertices.value);
}


#pragma mark Allocation and initialization

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker withAttributeIndex: (GLuint) attrIndx {
	if ( (self = [super initWithParent: aTracker]) ) {
		_attributeIndex = attrIndx;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker withAttributeIndex: (GLuint) attrIndx {
	return [[[self alloc] initWithParent: aTracker withAttributeIndex: attrIndx] autorelease];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithString: self.description];
	[desc appendFormat: @"\n    for attribute index %i", _attributeIndex];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2VertexArrays

@implementation CC3OpenGLES2VertexArrays

@synthesize attributes=_attributes;

-(void) dealloc {
	[_attributes release];
	[super dealloc];
}

-(CC3OpenGLES2StateTrackerVertexAttributesPointer*) attributeAt: (GLuint) attrIndx {
	return [_attributes objectAtIndex: attrIndx];
}

-(void) initializeTrackers {
	self.arrayBuffer = [CC3OpenGLESStateTrackerArrayBufferBinding trackerWithParent: self];
	self.indexBuffer = [CC3OpenGLESStateTrackerElementArrayBufferBinding trackerWithParent: self];
	
	self.attributes = [CCArray array];
	GLint maxVtxAttr = self.engine.platform.maxVertexAttributes.value;
	for (GLint i = 0; i < maxVtxAttr; i++) {
		[_attributes addObject: [CC3OpenGLES2StateTrackerVertexAttributesPointer trackerWithParent: self
																				withAttributeIndex: i]];
	}
}

-(CC3OpenGLESStateTrackerVertexPointer*) trackerForVertexArray: (CC3VertexArray*) vtxArray {
	return [self attributeAt: vtxArray.attributeIndex];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", self.arrayBuffer];
	[desc appendFormat: @"\n    %@ ", self.indexBuffer];
	for (id vaTrk in _attributes) [desc appendFormat: @"\n    %@ ", vaTrk];
	return desc;
}

@end

#endif
