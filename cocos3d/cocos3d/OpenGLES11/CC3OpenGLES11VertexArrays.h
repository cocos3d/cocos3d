/*
 * CC3OpenGLES11VertexArrays.h
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
 */

/** @file */	// Doxygen marker


#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerArrayBufferBinding

/**
 * CC3OpenGLES11StateTrackerArrayBufferBinding tracks binding and filling a vertex array.
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
@interface CC3OpenGLES11StateTrackerArrayBufferBinding : CC3OpenGLES11StateTrackerInteger {
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
#pragma mark CC3OpenGLES11StateTrackerElementArrayBufferBinding

/**
 * CC3OpenGLES11StateTrackerElementArrayBufferBinding tracks binding and filling
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
@interface CC3OpenGLES11StateTrackerElementArrayBufferBinding : CC3OpenGLES11StateTrackerArrayBufferBinding {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointer

/**
 * CC3OpenGLES11StateTrackerVertexPointer is a type of CC3OpenGLES11StateTrackerComposite
 * that tracks the parameters of a vertex pointer.
 *
 * The vertex pointer parameters are read from GL individually, using distinct primitive
 * trackers for each parameters. However, all parameters are set together using either
 * the useElementsAt:withSize:withType:withStride: method, or the 
 * useElementsAt:withType:withStride: method, and the parameters are set into the GL
 * engine together using a single call to one of the gl*Pointer functions.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method.
 *
 * The shouldAlwaysSetGL property is set to YES, which causes the state in the
 * GL engine to be updated on every invocation of the methods
 * useElementsAt:withSize:withType:withStride: or useElementsAt:withType:withStride:.
 */
@interface CC3OpenGLES11StateTrackerVertexPointer : CC3OpenGLES11StateTrackerComposite {
	CC3OpenGLES11StateTrackerInteger* elementSize;
	CC3OpenGLES11StateTrackerEnumeration* elementType;
	CC3OpenGLES11StateTrackerInteger* vertexStride;
	CC3OpenGLES11StateTrackerPointer* vertices;
}

/** Tracks vertex element size. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerInteger* elementSize;

/** Tracks vertex element type. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* elementType;

/** Tracks vertex element stride. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerInteger* vertexStride;

/** @deprecated Renamed to vertexStride. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerInteger* elementStride DEPRECATED_ATTRIBUTE;

/** Tracks the pointer to the vertex data. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointer* vertices;

/** @deprecated Renamed to vertices. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPointer* elementPointer DEPRECATED_ATTRIBUTE;

/**
 * Sets element pointer, element size, element type and element stride value together.
 * The values will be set in the GL engine only if at least one of the values has
 * actually changed, or if the shouldAlwaysSetGL property is YES.
 *
 * The initial value of the shouldAlwaysSetGL property is YES, so the values will be
 * set in the GL engine every time this method is invoked, unless the shouldAlwaysSetGL
 * property is set to NO.
 *
 * Invokes the setGLValues method to set the values in the GL engine.
 */
-(void) useElementsAt: (GLvoid*) pData
			 withSize: (GLint) elemSize
			 withType: (GLenum) elemType
		   withStride: (GLsizei) elemStride;

/**
 * For vertex pointers that do not use element size, sets element pointer,
 * element type and element stride value together. The values will be set
 * in the GL engine only if at least one of the values has actually changed,
 * or if the shouldAlwaysSetGL property is YES.
 *
 * The initial value of the shouldAlwaysSetGL property is YES, so the values
 * will be set in the GL engine every time this method is invoked, unless
 * the shouldAlwaysSetGL property value is set to NO.
 *
 * Invokes the setGLValues method to set the values in the GL engine.
 */
-(void) useElementsAt: (GLvoid*) pData
			 withType: (GLenum) elemType
		   withStride: (GLsizei) elemStride;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexLocationsPointer

/**
 * CC3OpenGLES11StateTrackerVertexLocationsPointer tracks the parameters
 * of the vertex locations pointer.
 *   - use the useElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_VERTEX_ARRAY_SIZE.
 *   - elementType uses GL name GL_VERTEX_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_VERTEX_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glVertexPointer method
 */
@interface CC3OpenGLES11StateTrackerVertexLocationsPointer : CC3OpenGLES11StateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexNormalsPointer

/**
 * CC3OpenGLES11StateTrackerVertexNormalsPointer tracks the parameters
 * of the vertex normals pointer.
 *   - use the useElementsAt:withType:withStride: method to set the values
 *   - elementSize is not used.
 *   - elementType uses GL name GL_NORMAL_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_NORMAL_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glNormalPointer method
 */
@interface CC3OpenGLES11StateTrackerVertexNormalsPointer : CC3OpenGLES11StateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexColorsPointer

/**
 * CC3OpenGLES11StateTrackerVertexColorsPointer tracks the parameters
 * of the vertex colors pointer.
 *   - use the useElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_COLOR_ARRAY_SIZE.
 *   - elementType uses GL name GL_COLOR_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_COLOR_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glColorPointer method
 */
@interface CC3OpenGLES11StateTrackerVertexColorsPointer : CC3OpenGLES11StateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointSizesPointer

/**
 * CC3OpenGLES11StateTrackerVertexPointSizesPointer tracks the parameters
 * of the vertex point sizes pointer.
 *   - use the useElementsAt:withType:withStride: method to set the values
 *   - elementSize is not used.
 *   - elementType uses GL name GL_POINT_SIZE_ARRAY_TYPE_OES.
 *   - vertexStride uses GL name GL_POINT_SIZE_ARRAY_STRIDE_OES.
 *   - the values are set in the GL engine using the glPointSizePointerOES method
 */
@interface CC3OpenGLES11StateTrackerVertexPointSizesPointer : CC3OpenGLES11StateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexWeightsPointer

/**
 * CC3OpenGLES11StateTrackerVertexLocationsPointer tracks the parameters
 * of the vertex weights pointer.
 *   - use the useElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_WEIGHT_ARRAY_SIZE_OES.
 *   - elementType uses GL name GL_WEIGHT_ARRAY_TYPE_OES.
 *   - vertexStride uses GL name GL_WEIGHT_ARRAY_STRIDE_OES.
 *   - the values are set in the GL engine using the glWeightPointerOES method
 */
@interface CC3OpenGLES11StateTrackerVertexWeightsPointer : CC3OpenGLES11StateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer

/**
 * CC3OpenGLES11StateTrackerVertexLocationsPointer tracks the parameters
 * of the vertex matrix indices pointer.
 *   - use the useElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_MATRIX_INDEX_ARRAY_SIZE_OES.
 *   - elementType uses GL name GL_MATRIX_INDEX_ARRAY_TYPE_OES.
 *   - vertexStride uses GL name GL_MATRIX_INDEX_ARRAY_STRIDE_OES.
 *   - the values are set in the GL engine using the glMatrixIndexPointerOES method
 */
@interface CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer : CC3OpenGLES11StateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES11VertexArrays

/** CC3OpenGLES11VertexArrays manages trackers for vertex arrays. */
@interface CC3OpenGLES11VertexArrays : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerArrayBufferBinding* arrayBuffer;
	CC3OpenGLES11StateTrackerElementArrayBufferBinding* indexBuffer;
	CC3OpenGLES11StateTrackerVertexLocationsPointer* locations;
	CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer* matrixIndices;
	CC3OpenGLES11StateTrackerVertexNormalsPointer* normals;
	CC3OpenGLES11StateTrackerVertexColorsPointer* colors;
	CC3OpenGLES11StateTrackerVertexPointSizesPointer* pointSizes;
	CC3OpenGLES11StateTrackerVertexWeightsPointer* weights;
}

/** Tracks vertex array buffer binding. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerArrayBufferBinding* arrayBuffer;

/** Tracks vertex element array buffer binding. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerElementArrayBufferBinding* indexBuffer;

/** Tracks the vertex locations pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexLocationsPointer* locations;

/** Tracks the vertex matrix indices pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer* matrixIndices;

/** Tracks the vertex normals pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexNormalsPointer* normals;

/** Tracks the vertex colors pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexColorsPointer* colors;

/** Tracks the vertex point sizes pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexPointSizesPointer* pointSizes;

/** Tracks the vertex weights pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexWeightsPointer* weights;

/**
 * Returns the array or index buffer binding tracker, as determined by the specified bufferTarget value.
 *   - returns the tracker in the arrayBuffer property if bufferTarget is GL_ARRAY_BUFFER
 *   - returns the tracker in the indexBuffer property if bufferTarget is GL_ELEMENT_ARRAY_BUFFER
 *   - raises an assertion error if bufferTarget is any other value.
 */
-(CC3OpenGLES11StateTrackerArrayBufferBinding*) bufferBinding: (GLenum) bufferTarget;

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
