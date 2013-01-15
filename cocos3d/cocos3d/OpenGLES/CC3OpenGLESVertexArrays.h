/*
 * CC3OpenGLESVertexArrays.h
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


#import "CC3OpenGLESStateTracker.h"
#import "CC3OpenGLESCapabilities.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerArrayBufferBinding

/**
 * CC3OpenGLESStateTrackerArrayBufferBinding tracks binding and filling a vertex array.
 *
 * Reading the value from the GL engine uses a different GL enumeration name than
 * setting the value in the GL engine. The property queryName is the GL enumeration
 * name used when reading the GL value.
 *
 * Uses the GL name GL_ARRAY_BUFFER to set the GL value.
 * Uses the GL query name GL_ARRAY_BUFFER_BINDING to read the GL value.
 * 
 * In addition to binding an array, this class can also load buffer data for the vertex
 * array using the loadBufferData:ofLength:forUse: method.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerArrayBufferBinding : CC3OpenGLESStateTrackerInteger {
	GLenum queryName;
}

/** The enumerated name under which the GL engine reads this state. */
@property(nonatomic, assign) GLenum queryName;

/** Unbinds all vertex arrays by setting the value property to zero. */
-(void) unbind;

/**
 * Loads data into the currently bound GL buffer, starting at the specified buffer
 * pointer, and extending for the specified length. The buffer usage is a hint for the
 * GL engine, and must be a valid GL buffer usage enumeration value.
 */
-(void) loadBufferData: (GLvoid*) buffPtr  ofLength: (GLsizeiptr) buffLen forUse: (GLenum) buffUsage;

/**
 * Updates data in the GL buffer, from data starting at the specified offset
 * in the specified buffer pointer, and extending for the specified length.
 */
-(void) updateBufferData: (GLvoid*) buffPtr
			  startingAt: (GLintptr) offset
			   forLength: (GLsizeiptr) length;

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerElementArrayBufferBinding

/**
 * CC3OpenGLESStateTrackerElementArrayBufferBinding tracks binding and filling
 * a vertex element (index) array.
 *
 * Reading the value from the GL engine uses a different GL enumeration name than
 * setting the value in the GL engine. The property queryName is the GL enumeration
 * name used when reading the GL value.
 *
 * Uses the GL name GL_ELEMENT_ARRAY_BUFFER to set the GL value.
 * Uses the GL query name GL_ELEMENT_ARRAY_BUFFER_BINDING to read the GL value.
 * 
 * In addition to binding an array, this class can also load buffer data for the vertex
 * array using the loadBufferData:ofLength:forUse: method.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerElementArrayBufferBinding : CC3OpenGLESStateTrackerArrayBufferBinding {}
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerVertexPointer

/**
 * CC3OpenGLESStateTrackerVertexPointer is a type of CC3OpenGLESStateTrackerComposite that tracks
 * the parameters of a vertex pointer.
 *
 * The vertex pointer parameters are read from GL individually, using distinct primitive
 * trackers for each parameters. However, all parameters are set together using the
 * bindElementsAt:withSize:withType:withStride:withShouldNormalize: method, and the parameters
 * are set into the GL engine together using a single call to one of the gl*Pointer functions.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method.
 *
 * The shouldAlwaysSetGL property is set to YES, which causes the state in the GL engine
 * to be updated on every invocation of the
 * bindElementsAt:withSize:withType:withStride:withShouldNormalize: method.
 */
@interface CC3OpenGLESStateTrackerVertexPointer : CC3OpenGLESStateTrackerComposite {
	CC3OpenGLESStateTrackerCapability* _capability;
	CC3OpenGLESStateTrackerInteger* _elementSize;
	CC3OpenGLESStateTrackerEnumeration* _elementType;
	CC3OpenGLESStateTrackerInteger* _vertexStride;
	CC3OpenGLESStateTrackerPointer* _vertices;
	CC3OpenGLESStateTrackerBoolean* _shouldNormalize;
	BOOL _wasBound : 1;
}

/** Tracks whether this vertex array is enabled or disabled. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* capability;

/** Tracks vertex element size. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerInteger* elementSize;

/** Tracks vertex element type. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* elementType;

/** Tracks vertex element stride. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerInteger* vertexStride;

/** @deprecated Renamed to vertexStride. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerInteger* elementStride DEPRECATED_ATTRIBUTE;

/** Tracks the pointer to the vertex data. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPointer* vertices;

/** @deprecated Renamed to vertices. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPointer* elementPointer DEPRECATED_ATTRIBUTE;

/**
 * Tracks whether the vertex content should be normalized during drawing.
 *
 * This property applies only to OpenGL ES 2. When using OpenGL ES 1, the tracker in this
 * property has no effect.
 */
@property(nonatomic, retain) CC3OpenGLESStateTrackerBoolean* shouldNormalize;

/** 
 * Indicates whether this vertex pointer was bound for the current drawing operation.
 *
 * This property is cleared automatically by the parent tracker prior to binding the vertex
 * pointers for each mesh, and is set automatically by the bindElementsAt:withSize:withType:withStride:withShouldNormalize:
 * method when this vertex pointer is bound to the GL engine.
 */
@property(nonatomic, assign) BOOL wasBound;

/**
 * Enables this vertex array pointer.
 *
 * This method is invoked automatically from the
 * bindElementsAt:withSize:withType:withStride:withShouldNormalize: method.
 */
-(void) enable;

/** Disables this vertex array pointer. */
-(void) disable;

/** Disables this vertex array pointer if the wasBound property is NO. */
-(void) disableIfUnbound;

/**
 * Binds element pointer, size, type, stride, normalization requirements value together
 * for the vertex attribute at the specified index.
 *
 * The values will be set in the GL engine only if at least one of the values has
 * actually changed, or if the shouldAlwaysSetGL property is YES.
 *
 * The initial value of the shouldAlwaysSetGL property is YES, so the values will be
 * set in the GL engine every time this method is invoked, unless the shouldAlwaysSetGL
 * property is set to NO.
 *
 * Invokes the setGLValues method to set the values in the GL engine.
 *
 * This method also invokes the enable method to enable this vertex pointer in the GL engine,
 * and sets the wasBound property to indicate that this vertex pointer was bound to the GL engine.
 */
-(void) bindElementsAt: (GLvoid*) pData
			  withSize: (GLint) elemSize
			  withType: (GLenum) elemType
			withStride: (GLsizei) elemStride
   withShouldNormalize: (BOOL) shldNorm;

@end


#pragma mark -
#pragma mark CC3OpenGLESVertexArrays

/** CC3OpenGLESVertexArrays manages trackers for vertex arrays. */
@interface CC3OpenGLESVertexArrays : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerArrayBufferBinding* arrayBuffer;
	CC3OpenGLESStateTrackerElementArrayBufferBinding* indexBuffer;
}

/** Tracks vertex array buffer binding. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerArrayBufferBinding* arrayBuffer;

/** Tracks vertex element array buffer binding. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerElementArrayBufferBinding* indexBuffer;

/**
 * Returns the array or index buffer binding tracker, as determined by the specified bufferTarget value.
 *   - returns the tracker in the arrayBuffer property if bufferTarget is GL_ARRAY_BUFFER
 *   - returns the tracker in the indexBuffer property if bufferTarget is GL_ELEMENT_ARRAY_BUFFER
 *   - raises an assertion error if bufferTarget is any other value.
 */
-(CC3OpenGLESStateTrackerArrayBufferBinding*) bufferBinding: (GLenum) bufferTarget;

/**
 * Generates and returns a GL buffer ID.
 *
 * This is a wrapper for the GL function glGenBuffers.
 */
-(GLuint) generateBuffer;

/**
 * Deletes the GL buffer with the specifid buffer ID.
 *
 * This is a wrapper for the GL function glDeleteBuffers.
 */
-(void) deleteBuffer: (GLuint) buffID;

/** Returns the vertex pointer tracker for the specified vertex array semantic at the specified semantic index. */
-(CC3OpenGLESStateTrackerVertexPointer*) vertexPointerForSemantic: (GLenum) semantic at: (GLuint) semanticIndex;

/** Returns the vertex pointer tracker for the specified vertex array semantic at semantic index zero. */
-(CC3OpenGLESStateTrackerVertexPointer*) vertexPointerForSemantic: (GLenum) semantic;

/** Clears the tracking of unbound vertex pointers. */
-(void) clearUnboundVertexPointers;

/** Disables any vertex pointers that have not been bound to the GL engine. */
-(void) disableUnboundVertexPointers;

/** Enables the vertex pointers needed for drawing cocos2d 2D artifacts, and disables all the rest. */
-(void) enable2DVertexPointers;

/**
 * Draws vertices bound by the vertex pointers using the specified draw mode,
 * starting at the specified index, and drawing the specified number of verticies.
 *
 * This is a wrapper for the GL function glDrawArrays.
 */
-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len;

/**
 * Draws the vertices indexed by the specified indices, to the specified number of indices,
 * each of the specified GL type, and using the specified draw mode.
 *
 * This is a wrapper for the GL function glDrawElements.
 */
-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode;

@end



