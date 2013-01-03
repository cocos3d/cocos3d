/*
 * CC3OpenGLES1VertexArrays.h
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

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexLocationsPointer

/**
 * CC3OpenGLES1StateTrackerVertexLocationsPointer tracks the parameters
 * of the vertex locations pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_VERTEX_ARRAY_SIZE.
 *   - elementType uses GL name GL_VERTEX_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_VERTEX_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glVertexPointer method
 */
@interface CC3OpenGLES1StateTrackerVertexLocationsPointer : CC3OpenGLESStateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexNormalsPointer

/**
 * CC3OpenGLES1StateTrackerVertexNormalsPointer tracks the parameters
 * of the vertex normals pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize is not used.
 *   - elementType uses GL name GL_NORMAL_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_NORMAL_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glNormalPointer method
 */
@interface CC3OpenGLES1StateTrackerVertexNormalsPointer : CC3OpenGLESStateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexColorsPointer

/**
 * CC3OpenGLES1StateTrackerVertexColorsPointer tracks the parameters
 * of the vertex colors pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_COLOR_ARRAY_SIZE.
 *   - elementType uses GL name GL_COLOR_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_COLOR_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glColorPointer method
 */
@interface CC3OpenGLES1StateTrackerVertexColorsPointer : CC3OpenGLESStateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexPointSizesPointer

/**
 * CC3OpenGLES1StateTrackerVertexPointSizesPointer tracks the parameters
 * of the vertex point sizes pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize is not used.
 *   - elementType uses GL name GL_POINT_SIZE_ARRAY_TYPE_OES.
 *   - vertexStride uses GL name GL_POINT_SIZE_ARRAY_STRIDE_OES.
 *   - the values are set in the GL engine using the glPointSizePointerOES method
 */
@interface CC3OpenGLES1StateTrackerVertexPointSizesPointer : CC3OpenGLESStateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexWeightsPointer

/**
 * CC3OpenGLES1StateTrackerVertexWeightsPointer tracks the parameters
 * of the vertex weights pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_WEIGHT_ARRAY_SIZE_OES.
 *   - elementType uses GL name GL_WEIGHT_ARRAY_TYPE_OES.
 *   - vertexStride uses GL name GL_WEIGHT_ARRAY_STRIDE_OES.
 *   - the values are set in the GL engine using the glWeightPointerOES method
 */
@interface CC3OpenGLES1StateTrackerVertexWeightsPointer : CC3OpenGLESStateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexMatrixIndicesPointer

/**
 * CC3OpenGLES1StateTrackerVertexMatrixIndicesPointer tracks the parameters
 * of the vertex matrix indices pointer.
 *   - use the bindElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_MATRIX_INDEX_ARRAY_SIZE_OES.
 *   - elementType uses GL name GL_MATRIX_INDEX_ARRAY_TYPE_OES.
 *   - vertexStride uses GL name GL_MATRIX_INDEX_ARRAY_STRIDE_OES.
 *   - the values are set in the GL engine using the glMatrixIndexPointerOES method
 */
@interface CC3OpenGLES1StateTrackerVertexMatrixIndicesPointer : CC3OpenGLESStateTrackerVertexPointer{}
@end


#pragma mark -
#pragma mark CC3OpenGLES1VertexArrays

/** Provides specialized behaviour for OpenGL ES 1 implementations. */
@interface CC3OpenGLES1VertexArrays : CC3OpenGLESVertexArrays {
	CC3OpenGLESStateTrackerVertexPointer* _locations;
	CC3OpenGLESStateTrackerVertexPointer* _matrixIndices;
	CC3OpenGLESStateTrackerVertexPointer* _normals;
	CC3OpenGLESStateTrackerVertexPointer* _colors;
	CC3OpenGLESStateTrackerVertexPointer* _pointSizes;
	CC3OpenGLESStateTrackerVertexPointer* _weights;
}

/** Tracks the vertex locations pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* locations;

/** Tracks the vertex matrix indices pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* matrixIndices;

/** Tracks the vertex normals pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* normals;

/** Tracks the vertex colors pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* colors;

/** Tracks the vertex point sizes pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* pointSizes;

/** Tracks the vertex weights pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* weights;

@end

#endif

