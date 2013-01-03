/*
 * CC3OpenGLES2VertexArrays.h
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
 */

/** @file */	// Doxygen marker


#import "CC3OpenGLESVertexArrays.h"

#if CC3_OGLES_2


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeInteger

/**
 * CC3OpenGLESStateTrackerVertexAttributeInteger tracks an integer GL state value for an
 * individual vertex attribute pointer. The property attributeIndex identifies the particular
 * vertex attribute for which the state is being tracked.
 *
 * This implementation uses GL function glGetVertexAttribiv to read the value from the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnce, which
 * will cause the state to be automatically read once, on the first invocation of the
 * open method, and the value will never be automatically restored.
 */
@interface CC3OpenGLESStateTrackerVertexAttributeInteger : CC3OpenGLESStateTrackerInteger {}

/** The index of the vertex attribute. */
@property(nonatomic, readonly) GLuint attributeIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeEnumeration

/**
 * CC3OpenGLESStateTrackerVertexAttributeEnumeration tracks an enumerated GL state value for an
 * individual vertex attribute pointer. The property attributeIndex identifies the particular
 * vertex attribute for which the state is being tracked.
 *
 * This implementation uses GL function glGetVertexAttribiv to read the value from the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnce, which
 * will cause the state to be automatically read once, on the first invocation of the
 * open method, and the value will never be automatically restored.
 */
@interface CC3OpenGLESStateTrackerVertexAttributeEnumeration : CC3OpenGLESStateTrackerEnumeration {}

/** The index of the vertex attribute. */
@property(nonatomic, readonly) GLuint attributeIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeBoolean

/**
 * CC3OpenGLESStateTrackerVertexAttributeBoolean tracks an enumerated GL state value for an
 * individual vertex attribute pointer. The property attributeIndex identifies the particular
 * vertex attribute for which the state is being tracked.
 *
 * This implementation uses GL function glGetVertexAttribiv to read the value from the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnce, which
 * will cause the state to be automatically read once, on the first invocation of the
 * open method, and the value will never be automatically restored.
 */
@interface CC3OpenGLESStateTrackerVertexAttributeBoolean : CC3OpenGLESStateTrackerBoolean {}

/** The index of the vertex attribute. */
@property(nonatomic, readonly) GLuint attributeIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexAttributeCapability

/**
 * CC3OpenGLESStateTrackerVertexAttributeCapability tracks a capability GL state value for an
 * individual vertex attribute pointer. The property attributeIndex identifies the particular
 * vertex attribute for which the state is being tracked.
 *
 * This implementation uses GL function glGetVertexAttribiv to read the value from the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerVertexAttributeCapability : CC3OpenGLESStateTrackerCapability {}

/** The index of the vertex attribute. */
@property(nonatomic, readonly) GLuint attributeIndex;

@end


#pragma mark -
#pragma mark CC3OpenGLES2StateTrackerVertexAttributesPointer

/**
 * CC3OpenGLES2StateTrackerVertexAttributesPointer tracks the parameters
 * of a general OpenGL ES 2 vertex attributes pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_VERTEX_ARRAY_SIZE.
 *   - elementType uses GL name GL_VERTEX_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_VERTEX_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glVertexPointer method
 */
@interface CC3OpenGLES2StateTrackerVertexAttributesPointer : CC3OpenGLESStateTrackerVertexPointer {
	GLuint _attributeIndex;
}

/** The index of the vertex attribute. */
@property(nonatomic, readonly) GLuint attributeIndex;

/**
 * Initializes this instance to track GL status for the vertex attribute pointer with the specified index.
 *
 * The number of available vertex attributes can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxVertexAttributes.value.
 */
-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
  withAttributeIndex: (GLuint) attrIndx;

/**
 * Allocates and initializes an autoreleased instance to track GL status for the vertex
 * attribute pointer with the specified index.
 *
 * The number of available vertex attributes can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxVertexAttributes.value.
 */
+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
	 withAttributeIndex: (GLuint) attrIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES2VertexArrays

/** Provides specialized behaviour for OpenGL ES 2 implementations. */
@interface CC3OpenGLES2VertexArrays : CC3OpenGLESVertexArrays {
	CCArray* _attributes;
}

/**
 * Tracks state for each indexed vertex attribute.
 *
 * Do not access individual light trackers through this property. Use the attributeAt: method instead.
 *
 * The number of available vertex attributes is retrieved from
 * [CC3OpenGLESEngine engine].platform.maxVertexAttributes.value.
 */
@property(nonatomic, retain) CCArray* attributes;

/**
 * Returns the tracker for the vertex attribute at the specified index.
 *
 * The number of available vertex attributes is retrieved from
 * [CC3OpenGLESEngine engine].platform.maxVertexAttributes.value.
 */
-(CC3OpenGLES2StateTrackerVertexAttributesPointer*) attributeAt: (GLuint) attrIndx;

@end

#endif

