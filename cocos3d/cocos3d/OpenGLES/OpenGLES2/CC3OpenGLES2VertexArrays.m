/*
 * CC3OpenGLES2VertexArrays.m
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

#import "CC3OpenGLES2VertexArrays.h"
#import "CC3OpenGLESEngine.h"
#import "CC3GLProgram.h"
#import "CC3VertexArrays.h"
#import "CC3CC2Extensions.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeInteger

@implementation CC3OpenGLESStateTrackerVertexAttributeInteger

-(GLuint) attributeIndex { return ((CC3OpenGLES2StateTrackerVertexAttributesPointer*)self.parent).attributeIndex; }

-(void) getGLValue { glGetVertexAttribiv(self.attributeIndex, name, &originalValue); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnce;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for attribute index %i", super.description, self.attributeIndex];
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

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for attribute index %i", super.description, self.attributeIndex];
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

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for attribute index %i", super.description, self.attributeIndex];
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

// Overridden to always restore
-(BOOL) shouldRestoreOriginalOnClose { return YES; }

/**
 * Overridden to force vertex position, color & texture on, and all other vertex attributes off,
 * and ensure that the cocos2d internal state machine is aligned to the same state.
 * In most cases, the 3D scene draws before the 2D nodes such as sprites, so we enable position,
 * color & texture arrays, which is typical of 2D sprites. Other cocos2d node types will change
 * the state as needed. The important goal here is to align cocos2d's state with the GL state.
 */
-(void) restoreOriginalValue {
	BOOL attrIdx = self.attributeIndex;
	switch (attrIdx) {
		case kCCVertexAttrib_Position:
			ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);	// Force CC2 then fall through
		case kCCVertexAttrib_Color:
		case kCCVertexAttrib_TexCoords:
			value = YES;
			break;
		default:
			value = NO;
			break;
	}
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueIgnore;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for attribute index %i", super.description, self.attributeIndex];
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
	GLint glBoundBuffer;
	GLint vaBoundBuffer;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &glBoundBuffer);
	glGetVertexAttribiv(_attributeIndex, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, &vaBoundBuffer);

	NSMutableString* desc = [NSMutableString stringWithString: super.description];
	[desc appendFormat: @"\n    for attribute index %i bound to buffer %i (while GL bound buffer is %i)",
	 _attributeIndex, vaBoundBuffer, glBoundBuffer];
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

-(GLuint) attributesCount { return _attributes.count; }

/** Template method returns an autoreleased instance of a vertex attribute tracker. */
-(CC3OpenGLES2StateTrackerVertexAttributesPointer*) makeVertexAttributes: (GLuint) attrIndx {
	return [CC3OpenGLES2StateTrackerVertexAttributesPointer trackerWithParent: self withAttributeIndex: attrIndx];
}

-(CC3OpenGLES2StateTrackerVertexAttributesPointer*) attributeAt: (GLuint) attrIndx {
	// If the requested attribute index hasn't been allocated yet, add it.
	GLuint vapCnt = self.attributesCount;
	if (attrIndx >= vapCnt) {
		// Make sure we don't add beyond the max number of vertex attributes for the platform
		CC3Assert(attrIndx < self.engine.platform.maxVertexAttributes.value,
				  @"Request for vertex attribute index %u exceeds maximum of %u vertex attributes",
				  attrIndx, self.engine.platform.maxVertexAttributes.value);
		
		// Add all vertex attribute pointers between the current count and the requested index.
		for (GLuint i = vapCnt; i <= attrIndx; i++) {
			CC3OpenGLES2StateTrackerVertexAttributesPointer* vap = [self makeVertexAttributes: i];
			[_attributes addObject: vap];
			LogTrace(@"%@ added vertex attributes pointer %u:\n%@", [self class], i, vap);
		}
	}
	return [_attributes objectAtIndex: attrIndx];
}

-(void) initializeTrackers {
	self.arrayBuffer = [CC3OpenGLESStateTrackerArrayBufferBinding trackerWithParent: self];
	self.indexBuffer = [CC3OpenGLESStateTrackerElementArrayBufferBinding trackerWithParent: self];
	
	self.attributes = [CCArray array];
}

-(CC3OpenGLESStateTrackerVertexPointer*) vertexPointerForSemantic: (GLenum) semantic at: (GLuint) semanticIndex {
	CC3GLSLAttribute* attribute = [self.engine.shaders.activeProgram attributeForSemantic: semantic
																					   at: semanticIndex];
	GLint attrIdx = attribute.location;		// Negative if not valid attribute
	return (attribute && (attrIdx >= 0)) ? [self attributeAt: attrIdx] : nil;
}

-(void) clearUnboundVertexPointers {
	ccGLBindVAO(0);		// Ensure that a VAO was not left in place by cocos2d
	for (CC3OpenGLES2StateTrackerVertexAttributesPointer* vap in _attributes) vap.wasBound = NO;
}

-(void) disableUnboundVertexPointers {
	for (CC3OpenGLES2StateTrackerVertexAttributesPointer* vap in _attributes) [vap disableIfUnbound];
}

// Force alignment of the state tracking between the position, color & texture vertex arrays
-(void) enable2DVertexPointers {
	for (CC3OpenGLES2StateTrackerVertexAttributesPointer* vap in _attributes) {
		BOOL attrIdx = vap.attributeIndex;
		switch (attrIdx) {
			case kCCVertexAttrib_Position:
			case kCCVertexAttrib_Color:
			case kCCVertexAttrib_TexCoords:
				[vap enable];
				break;
			default:
				[vap disable];
				break;
		}
	}
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_None);
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
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
