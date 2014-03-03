/*
 * CC3Foundation.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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

/** @mainpage cocos3d API reference
 *
 * @section intro About cocos3d
 *
 * cocos3d extends cocos2d to add support for full 3D rendering, in combination with
 * normal cocos2d 2D rendering.
 *
 * Rendering of 3D objects is performed within a CC3Layer, which is a specialized cocos2d
 * layer. In your application, you will usually create a customized subclass of CC3Layer,
 * which you add to a CCScene, or other CCLayer, to act as a bridge between the 2D and
 * 3D rendering.
 *
 * The CC3Layer instance holds a reference to an instance of CC3Scene, which manages the
 * 3D model objects, including loading from 3D model files, such as PowerVR POD files.
 * You will usually create a customized subclass of CC3Scene to create and manage the
 * objects and dynamics of your 3D scene.
 */

/* Base library of definitions and functions for operating in a 3D scene. */

#import "CC3Math.h"
#import "CC3Logging.h"
#import "ccTypes.h"
#import <CoreGraphics/CGColor.h>

/**
 * The version of cocos3d, derived from the version format, where each of the HI.ME.LO
 * components of the version is allocated two digits in this value, in the format HIMELO.
 *
 * Examples:
 *   - 0.7		-> 0x000700
 *   - 2.7.3	-> 0x020703
 */
#define COCOS3D_VERSION 0x020000

/** Returns a string describing the cocos3d version. */
static inline NSString* NSStringFromCC3Version() {
	int vFull, vMajor, vMinor, vBuild;
	vFull = COCOS3D_VERSION;
	vMajor = (vFull >> 16) & 0xFF;
	vMinor = (vFull >> 8) & 0xFF;
	vBuild = vFull & 0xFF;
	return [NSString stringWithFormat: @"Cocos3D v%i.%i.%i", vMajor, vMinor, vBuild];
}


#pragma mark -
#pragma mark Integer vector structure and functions

/** An integer 2D point. */
typedef struct {
	GLint x;			/**< The X-componenent of the point. */
	GLint y;			/**< The Y-componenent of the point. */
} CC3IntPoint;

/** A CC3IntPoint at the origin. */
static const CC3IntPoint kCC3IntPointZero = { 0, 0 };

/** Returns a string description of the specified CC3IntPoint struct in the form "(x, y)" */
static inline NSString* NSStringFromCC3IntPoint(CC3IntPoint v) {
	return [NSString stringWithFormat: @"(%i, %i)", v.x, v.y];
}

/** Returns a CC3IntPoint structure constructed from the vector components. */
static inline CC3IntPoint CC3IntPointMake(GLint x, GLint y) {
	CC3IntPoint v;
	v.x = x;
	v.y = y;
	return v;
}

/** Returns a CC3IntPoint structure constructed from the specified CGPoint. */
static inline CC3IntPoint CC3IntPointFromCGPoint(CGPoint pt) { return CC3IntPointMake(pt.x, pt.y); }

/** Returns a CGPoint structure constructed from the specified CC3IntPoint. */
static inline CGPoint CGPointFromCC3IntPoint(CC3IntPoint ipt) { return CGPointMake(ipt.x, ipt.y); }

/** Returns whether the two points are equal by comparing their respective components. */
static inline BOOL CC3IntPointsAreEqual(CC3IntPoint p1, CC3IntPoint p2) {
	return	(p1.x == p2.x) &&
			(p1.y == p2.y);
}

/** An integer 2D size. */
typedef struct {
	GLint width;			/**< The width measurement. */
	GLint height;			/**< The height measurement. */
} CC3IntSize;

/** A CC3IntSize of zero extent. */
static const CC3IntSize kCC3IntSizeZero = { 0, 0 };

/** Returns a string description of the specified CC3IntSize struct in the form "(width, height)" */
static inline NSString* NSStringFromCC3IntSize(CC3IntSize size) {
	return [NSString stringWithFormat: @"(%i, %i)", size.width, size.height];
}

/** Returns a CC3IntSize structure constructed from the dimensional components. */
static inline CC3IntSize CC3IntSizeMake(GLint w, GLint h) {
	CC3IntSize sz;
	sz.width = w;
	sz.height = h;
	return sz;
}

/** Returns a CC3IntSize structure constructed from the specified CGSize. */
static inline CC3IntSize CC3IntSizeFromCGSize(CGSize sz) { return CC3IntSizeMake(sz.width, sz.height); }

/** Returns a CGSize structure constructed from the specified CC3IntSize. */
static inline CGSize CGSizeFromCC3IntSize(CC3IntSize isz) { return CGSizeMake(isz.width, isz.height); }

/** Returns whether the two sizes are equal by comparing their respective components. */
static inline BOOL CC3IntSizesAreEqual(CC3IntSize s1, CC3IntSize s2) {
	return	(s1.width == s2.width) &&
			(s1.height == s2.height);
}

/** A struct representing an integer tessellation. */
typedef CC3IntPoint CC3Tessellation;

/** Returns a CC3Tessellation structure constructed from the specified components. */
static inline CC3Tessellation CC3TessellationMake(GLint x, GLint y) { return CC3IntPointMake(x, y); }

/** Returns a string description of the specified CC3Tessellation struct in the form "(x, y)" */
static inline NSString* NSStringFromCC3Tessellation(CC3Tessellation t) { return NSStringFromCC3IntPoint(t); }

/** An integer 3D vector. */
typedef struct {
	GLint x;			/**< The X-componenent of the vector. */
	GLint y;			/**< The Y-componenent of the vector. */
	GLint z;			/**< The Z-componenent of the vector. */
} CC3IntVector;

/** Returns a string description of the specified CC3IntVector struct in the form "(x, y, z)" */
static inline NSString* NSStringFromCC3IntVector(CC3IntVector v) {
	return [NSString stringWithFormat: @"(%i, %i, %i)", v.x, v.y, v.z];
}

/** Returns a CC3IntVector structure constructed from the vector components. */
static inline CC3IntVector CC3IntVectorMake(GLint x, GLint y, GLint z) {
	CC3IntVector v;
	v.x = x;
	v.y = y;
	v.z = z;
	return v;
}

/** Returns whether the two vectors are equal by comparing their respective components. */
static inline BOOL CC3IntVectorsAreEqual(CC3IntVector v1, CC3IntVector v2) {
	return	(v1.x == v2.x) &&
			(v1.y == v2.y) &&
			(v1.z == v2.z);
}

/** 
 * An integer 4D vector.
 *
 * This structure can be referenced as containing 4 individual XYZW axes components,
 * or containing a 3D XYZ vector, plus a W component.
*/
typedef struct {
	union {
		struct {
			GLint x;			/**< The X-componenent of the vector. */
			GLint y;			/**< The Y-componenent of the vector. */
			GLint z;			/**< The Z-componenent of the vector. */
		};
		
		struct {
			CC3IntVector v;		/**< The X, Y & Z components as a 3D vector. */
		};
	};
	GLint w;					/**< The homogeneous ratio factor. */
} CC3IntVector4;

/** Returns a string description of the specified CC3IntVector4 struct in the form "(x, y, z, w)" */
static inline NSString* NSStringFromCC3IntVector4(CC3IntVector4 v) {
	return [NSString stringWithFormat: @"(%i, %i, %i, %i)", v.x, v.y, v.z, v.w];
}

/** Returns a CC3IntVector4 structure constructed from the vector components. */
static inline CC3IntVector4 CC3IntVector4Make(GLint x, GLint y, GLint z, GLint w) {
	CC3IntVector4 v;
	v.x = x;
	v.y = y;
	v.z = z;
	v.w = w;
	return v;
}

/** Returns whether the two vectors are equal by comparing their respective components. */
static inline BOOL CC3IntVector4sAreEqual(CC3IntVector4 v1, CC3IntVector4 v2) {
	return (v1.w == v2.w) && CC3IntVectorsAreEqual(v1.v, v2.v);
}


#pragma mark -
#pragma mark 3D cartesian vector structure and functions

/** A vector in 3D space. */
typedef struct {
	GLfloat x;			/**< The X-componenent of the vector. */
	GLfloat y;			/**< The Y-componenent of the vector. */
	GLfloat z;			/**< The Z-componenent of the vector. */
} CC3Vector;

/** A CC3Vector of zero length at the origin. */
static const CC3Vector kCC3VectorZero = { 0.0, 0.0, 0.0 };

/** The null CC3Vector. It cannot be drawn, but is useful for marking an uninitialized vector. */
static const CC3Vector kCC3VectorNull = {INFINITY, INFINITY, INFINITY};

/** A CC3Vector with each component equal to one, representing the diagonal of a unit cube. */
static const CC3Vector kCC3VectorUnitCube = { 1.0, 1.0, 1.0 };

/** The diagonal length of a unit cube. */
static const GLfloat kCC3VectorUnitCubeLength = kCC3Sqrt3;

/** Unit vector pointing in the same direction as the positive X-axis. */
static const CC3Vector kCC3VectorUnitXPositive = { 1.0,  0.0,  0.0 };

/** Unit vector pointing in the same direction as the positive Y-axis. */
static const CC3Vector kCC3VectorUnitYPositive = { 0.0,  1.0,  0.0 };

/** Unit vector pointing in the same direction as the positive Z-axis. */
static const CC3Vector kCC3VectorUnitZPositive = { 0.0,  0.0,  1.0 };

/** Unit vector pointing in the same direction as the negative X-axis. */
static const CC3Vector kCC3VectorUnitXNegative = {-1.0,  0.0,  0.0 };

/** Unit vector pointing in the same direction as the negative Y-axis. */
static const CC3Vector kCC3VectorUnitYNegative = { 0.0, -1.0,  0.0 };

/** Unit vector pointing in the same direction as the negative Z-axis. */
static const CC3Vector kCC3VectorUnitZNegative = { 0.0,  0.0, -1.0 };

/** Returns a string description of the specified CC3Vector struct in the form "(x, y, z)" */
static inline NSString* NSStringFromCC3Vector(CC3Vector v) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f)", v.x, v.y, v.z];
}

/**
 * Returns a string description of the specified array of CC3Vector structs.
 *
 * The vectorCount argument indicates the number of vectors in the vectors array argument.
 *
 * Each vector in the array is output on a separate line in the result.
 */
NSString* NSStringFromCC3Vectors(CC3Vector* vectors, GLuint vectorCount);

/** Returns a CC3Vector structure constructed from the vector components. */
static inline CC3Vector CC3VectorMake(GLfloat x, GLfloat y, GLfloat z) {
	CC3Vector v;
	v.x = x;
	v.y = y;
	v.z = z;
	return v;
}

/** Convenience alias macro to create CC3Vectors with less keystrokes. */
#define cc3v(X,Y,Z) CC3VectorMake((X),(Y),(Z))

/** Returns whether the two vectors are equal by comparing their respective components. */
static inline BOOL CC3VectorsAreEqual(CC3Vector v1, CC3Vector v2) {
	return v1.x == v2.x &&
		   v1.y == v2.y &&
		   v1.z == v2.z;
}

/** Returns whether the specified vector is equal to the zero vector, specified by kCC3VectorZero. */
static inline BOOL CC3VectorIsZero(CC3Vector v) {
	return CC3VectorsAreEqual(v, kCC3VectorZero);
}

/** Returns whether the specified vector is equal to the null vector, specified by kCC3VectorNull. */
static inline BOOL CC3VectorIsNull(CC3Vector v) {
	return CC3VectorsAreEqual(v, kCC3VectorNull);
}

/**
 * Returns the result of scaling the original vector by the corresponding scale vector.
 * Scaling can be different for each axis. This has the effect of multiplying each component
 * of the vector by the corresponding component in the scale vector.
 */
static inline CC3Vector CC3VectorScale(CC3Vector v, CC3Vector scale) {
	return cc3v(v.x * scale.x,
				v.y * scale.y,
				v.z * scale.z);
}

/**
 * Returns the result of scaling the original vector by the corresponding scale
 * factor uniformly along all axes.
 */
static inline CC3Vector CC3VectorScaleUniform(CC3Vector v, GLfloat scale) {
	return cc3v(v.x * scale,
				v.y * scale,
				v.z * scale);
}

/**
 * Returns a vector that is the negative of the specified vector in all directions.
 * For vectors that represent directions, the returned vector points in the direction
 * opposite to the original.
 */
static inline CC3Vector CC3VectorNegate(CC3Vector v) {
	return cc3v(-v.x, -v.y, -v.z);
}

/**
 * Returns a vector whose components comprise the minimum value of each of the respective
 * components of the two specfied vectors. In general, do not expect this method to return
 * one of the specified vectors, but a new vector, each of the components of which is the
 * minimum value for that component between the two vectors.
 */
static inline CC3Vector CC3VectorMinimize(CC3Vector v1, CC3Vector v2) {
	return cc3v(MIN(v1.x, v2.x),
				MIN(v1.y, v2.y),
				MIN(v1.z, v2.z));
}

/**
 * Returns a vector whose components comprise the maximum value of each of the respective
 * components of the two specfied vectors. In general, do not expect this method to return
 * one of the specified vectors, but a new vector, each of the components of which is the
 * maximum value for that component between the two vectors.
 */
static inline CC3Vector CC3VectorMaximize(CC3Vector v1, CC3Vector v2) {
	return cc3v(MAX(v1.x, v2.x),
				MAX(v1.y, v2.y),
				MAX(v1.z, v2.z));
}

/** Returns the dot-product of the two given vectors (v1 . v2). */
static inline GLfloat CC3VectorDot(CC3Vector v1, CC3Vector v2) {
	return ((v1.x * v2.x) +
			(v1.y * v2.y) +
			(v1.z * v2.z));
}

/**
 * Returns the square of the scalar length of the specified CC3Vector from the origin.
 * This is calculated as (x*x + y*y + z*z) and will always be positive.
 *
 * This function is useful for comparing vector sizes without having to run an
 * expensive square-root calculation.
 */
static inline GLfloat CC3VectorLengthSquared(CC3Vector v) { return CC3VectorDot(v, v); }

/**
 * Returns the scalar length of the specified CC3Vector from the origin.
 * This is calculated as sqrt(x*x + y*y + z*z) and will always be positive.
 */
static inline GLfloat CC3VectorLength(CC3Vector v) {
	// Avoid expensive sqrt calc if vector is unit length or zero
	GLfloat lenSq = CC3VectorLengthSquared(v);
	return (lenSq == 1.0f || lenSq == 0.0f) ? lenSq : sqrtf(lenSq);
}

/**
 * Returns a normalized copy of the specified CC3Vector so that its length is 1.0.
 * If the length is zero, the original vector (a zero vector) is returned.
 */
static inline CC3Vector CC3VectorNormalize(CC3Vector v) {
	GLfloat lenSq = CC3VectorLengthSquared(v);
	if (lenSq == 0.0f || lenSq == 1.0f) return v;
	return CC3VectorScaleUniform(v, (1.0f / sqrtf(lenSq)));
}

/**
 * Returns a CC3Vector that is the inverse of the specified vector in all directions,
 * such that scaling the original by the inverse using CC3VectorScale will result in
 * a vector of unit dimension in each direction (1.0, 1.0, 1.0). The result of this
 * function is effectively calculated by dividing each component of the original
 * vector into 1.0 (1.0/x, 1.0/y, 1.0/z). It is the responsibility of the caller to
 * ensure that none of the components of the original is zero.
 */
static inline CC3Vector CC3VectorInvert(CC3Vector v) {
	return cc3v(1.0f / v.x,
				1.0f / v.y,
				1.0f / v.z);
}

/**
 * Returns the result of adding the two specified vectors, by adding the corresponding components 
 * of both vectors. This can also be thought of as a translation of the first vector by the second.
 */
static inline CC3Vector CC3VectorAdd(CC3Vector v, CC3Vector translation) {
	return cc3v(v.x + translation.x,
				v.y + translation.y,
				v.z + translation.z);
}

/**
 * Returns the difference between two vectors, by subtracting the subtrahend from the minuend,
 * which is accomplished by subtracting each of the corresponding x,y,z components.
 */
static inline CC3Vector CC3VectorDifference(CC3Vector minuend, CC3Vector subtrahend) {
	return cc3v(minuend.x - subtrahend.x,
				minuend.y - subtrahend.y,
				minuend.z - subtrahend.z);
}

/**
 * Returns a modulo version of the specifed rotation,
 * so that each component is between (+/-360 degrees).
 */
static inline CC3Vector CC3VectorRotationModulo(CC3Vector aRotation) {
	return cc3v(CC3CyclicAngle(aRotation.x),
				CC3CyclicAngle(aRotation.y),
				CC3CyclicAngle(aRotation.z));
}

/**
 * Returns the difference between two rotation vectors, in terms of the minimal degrees,
 * along each axis, required to travel between the two roations, given that rotations
 * are cyclical with a period of 360 degrees. The result may be positive or negative,
 * but will always be between (+/-180 degrees).
 *
 * For example, the difference between 350 and 10 will yield -20 (ie- the smallest change
 * from 10 degrees to 350 degrees is -20 degrees) rather than +340 (from simple subtraction).
 * Similarly, the difference between 10 and 350 will yield +20 (ie- the smallest change from
 * 350 degrees to 10 degrees is +20 degrees) rather than -340 (from simple subtraction).
 */
static inline CC3Vector CC3VectorRotationalDifference(CC3Vector minuend, CC3Vector subtrahend) {
	return cc3v(CC3SemiCyclicAngle(minuend.x - subtrahend.x),
				CC3SemiCyclicAngle(minuend.y - subtrahend.y),
				CC3SemiCyclicAngle(minuend.z - subtrahend.z));
}

/** Returns the positive scalar distance between the ends of the two specified vectors. */
static inline GLfloat CC3VectorDistance(CC3Vector start, CC3Vector end) {
	return CC3VectorLength(CC3VectorDifference(end, start));
}

/**
 * Returns the square of the scalar distance between the ends of the two specified vectors.
 *
 * This function is useful for comparing vector distances without having to run an
 * expensive square-root calculation.
 */
static inline GLfloat CC3VectorDistanceSquared(CC3Vector start, CC3Vector end) {
	return CC3VectorLengthSquared(CC3VectorDifference(end, start));
}

/**
 * Returns a vector that represents the average of the two specified vectors. This is
 * calculated by adding the two specified vectors and scaling the resulting sum vector by half.
 *
 * The returned vector represents the midpoint between a line that joins the endpoints
 * of the two specified vectors.
 */
static inline CC3Vector CC3VectorAverage(CC3Vector v1, CC3Vector v2) {
	return CC3VectorScaleUniform(CC3VectorAdd(v1, v2), 0.5);	
}

/** Returns the cross-product of the two given vectors (v1 x v2). */
static inline CC3Vector CC3VectorCross(CC3Vector v1, CC3Vector v2) {
	return cc3v(v1.y * v2.z - v1.z * v2.y,
				v1.z * v2.x - v1.x * v2.z,
				v1.x * v2.y - v1.y * v2.x);
}

/** Returns YES if the two vectors are either exactly parallel or exactly antiparallel. */
static inline BOOL CC3VectorsAreParallel(CC3Vector v1, CC3Vector v2) {
	return CC3VectorLengthSquared(CC3VectorCross(v1, v2)) == 0.0f;
}

/** Returns whether the two vectors are exactly perpendicular. */
static inline BOOL CC3VectorsArePerpendicular(CC3Vector v1, CC3Vector v2) {
	return CC3VectorDot(v1, v2) == 0.0f;
}

/**
 * Orthonormalizes the specified array of vectors, using a Gram-Schmidt process,
 * and returns the orthonormal results in the same array.
 *
 * The vectorCount argument indicates the number of vectors in the vectors array argument.
 *
 * Upon completion, each vector in the specfied array will be a unit vector that
 * is orthagonal to all of the other vectors in the array.
 *
 * The first vector in the array is used as the starting point for orthonormalization.
 * Since the Gram-Schmidt process is biased towards the starting vector, if this function
 * will be used repeatedly on the same set of vectors, it is recommended that the order
 * of the vectors in the array be changed on each call to this function, to ensure that
 * the starting bias be averaged across each of the vectors over the long term.
 */
void CC3VectorOrthonormalize(CC3Vector* vectors, GLuint vectorCount);

/**
 * Orthonormalizes the specified array of three vectors, using a Gram-Schmidt process,
 * and returns the orthonormal results in the same array.
 *
 * The number of vectors in the specified array must be exactly three.
 *
 * Upon completion, each vector in the specfied array will be a unit vector that
 * is orthagonal to all of the other vectors in the array.
 *
 * The first vector in the array is used as the starting point for orthonormalization.
 * Since the Gram-Schmidt process is biased towards the starting vector, if this function
 * will be used repeatedly on the same set of vectors, it is recommended that the order
 * of the vectors in the array be changed on each call to this function, to ensure that
 * the starting bias be averaged across each of the vectors over the long term.
 */
static inline void CC3VectorOrthonormalizeTriple(CC3Vector* triVector) { return CC3VectorOrthonormalize(triVector, 3); }

/**
 * Returns a linear interpolation between two vectors, based on the blendFactor.
 * which should be between zero and one inclusive. The returned value is calculated
 * as v1 + (blendFactor * (v2 - v1)). If the blendFactor is either zero or one
 * exactly, this method short-circuits to simply return v1 or v2 respectively.
 */
static inline CC3Vector CC3VectorLerp(CC3Vector v1, CC3Vector v2, GLfloat blendFactor) {
	if (blendFactor == 0.0f) return v1;
	if (blendFactor == 1.0f) return v2;
	return CC3VectorAdd(v1, CC3VectorScaleUniform(CC3VectorDifference(v2, v1), blendFactor));
}

/** 
 * Minimum acceptable absolute value for a scale transformation component.
 *
 * This is used to ensure that scales used in transforms do not cause uninvertable matrices.
 *
 * The initial value is 1.0e-9f. Set this to another value if appropriate.
 */
static GLfloat kCC3ScaleMin = 1.0e-9f;

/**
 * Ensures the specified value can be used as a component in a scale vector. If the value is
 * greater than kCC3ScaleMin or less than -kCC3ScaleMin, it is returned unchanced, otherwise
 * either -kCC3ScaleMin or kCC3ScaleMin is returned, depending on whether the value is
 * less than zero or not, respectively.
 *
 * This is used to ensure that scales used in transforms do not cause uninvertable matrices.
 */
static inline GLfloat CC3EnsureMinScaleAxis(GLfloat val) {
	// Test in order of expected value, for fast return.
	if (val > kCC3ScaleMin) return val;
	if (val >= 0.0f) return kCC3ScaleMin;
	if (val < -kCC3ScaleMin) return val;
	return -kCC3ScaleMin;
}

/**
 * Ensures the absolute value of each of the components in the specified scale vector
 * is greater than kCC3ScaleMin. Any component between -kCC3ScaleMin and kCC3ScaleMin
 * is replaced with -kCC3ScaleMin or kCC3ScaleMin depending on whether the component
 * is less than zero or not, respectively.
 *
 * This can be used to ensure that scales used in transforms do not cause uninvertable matrices.
 */
static inline CC3Vector CC3EnsureMinScaleVector(CC3Vector scale) {
	return cc3v(CC3EnsureMinScaleAxis(scale.x),
				CC3EnsureMinScaleAxis(scale.y),
				CC3EnsureMinScaleAxis(scale.z));
}


#pragma mark -
#pragma mark Cartesian vector in 4D homogeneous coordinate space structure and functions

/** 
 * A 4D vector, such as a homogeneous vector in 4D graphics matrix space, or a quaternion.
 *
 * This structure can be referenced as containing 4 individual XYZW axes components, 
 * or containing a 3D XYZ vector, plus a W component.
 */
typedef struct {
	union {
		struct {
			GLfloat x;			/**< The X-componenent of the vector or quaternion. */
			GLfloat y;			/**< The Y-componenent of the vector or quaternion. */
			GLfloat z;			/**< The Z-componenent of the vector or quaternion. */
		};
		
		struct {
			CC3Vector v;		/**< The X, Y & Z components as a 3D vector. */
		};
	};
		GLfloat w;				/**< The homogeneous ratio factor or the real part of a quaternion. */
} CC3Vector4, CC3Quaternion;

/** A CC3Vector4 of zero length at the origin. */
static const CC3Vector4 kCC3Vector4Zero = { { {0.0, 0.0, 0.0} }, 0.0 };

/** A CC3Vector4 location at the origin. As a definite location, the W component is 1.0. */
static const CC3Vector4 kCC3Vector4ZeroLocation = { { {0.0, 0.0, 0.0} }, 1.0 };

/** The null CC3Vector4. It cannot be drawn, but is useful for marking an uninitialized vector. */
static const CC3Vector4 kCC3Vector4Null = { { {INFINITY, INFINITY, INFINITY} }, INFINITY};

/** Returns a string description of the specified CC3Vector4 struct in the form "(x, y, z, w)" */
static inline NSString* NSStringFromCC3Vector4(CC3Vector4 v) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", v.x, v.y, v.z, v.w];
}

/** Returns a CC3Vector4 structure constructed from the vector components. */
static inline CC3Vector4 CC3Vector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {
	CC3Vector4 v;
	v.x = x;
	v.y = y;
	v.z = z;
	v.w = w;
	return v;
}

/** Returns a CC3Vector4 structure constructed from a 3D vector and a w component. */
static inline CC3Vector4 CC3Vector4FromCC3Vector(CC3Vector v, GLfloat w) {
	CC3Vector4 v4;
	v4.v = v;
	v4.w = w;
	return v4;
}

/**
 * Returns a CC3Vector4 homogeneous coordinate constructed from a 3D location.
 *
 * The W component of the returned vector is set to 1.0.
 */
static inline CC3Vector4 CC3Vector4FromLocation(CC3Vector aLocation) {
	return CC3Vector4FromCC3Vector(aLocation, 1.0f);
}

/**
 * Returns a CC3Vector4 homogeneous coordinate constructed from a 3D direction.
 *
 * The W component of the returned vector is set to 0.0.
 */
static inline CC3Vector4 CC3Vector4FromDirection(CC3Vector aDirection) {
	return CC3Vector4FromCC3Vector(aDirection, 0.0f);
}

/** @deprecated You can now use v.v instead. See the declaration of the CC3Vector4 structure. */
CC3Vector CC3VectorFromTruncatedCC3Vector4(CC3Vector4 v) DEPRECATED_ATTRIBUTE;

/** Returns whether the two vectors are equal by comparing their respective components. */
static inline BOOL CC3Vector4sAreEqual(CC3Vector4 v1, CC3Vector4 v2) {
	return  (v1.w == v2.w) && CC3VectorsAreEqual(v1.v, v2.v);
}

/** Returns whether the specified vector is equal to the zero vector, specified by kCC3Vector4Zero. */
static inline BOOL CC3Vector4IsZero(CC3Vector4 v) { return CC3Vector4sAreEqual(v, kCC3Vector4Zero); }

/** Returns whether the specified vector is equal to the null vector, specified by kCC3Vector4Null. */
static inline BOOL CC3Vector4IsNull(CC3Vector4 v) { return CC3Vector4sAreEqual(v, kCC3Vector4Null); }

/**
 * Returns whether the vector represents a direction, rather than a location.
 *
 * It is directional if the w component is zero.
 */
static inline BOOL CC3Vector4IsDirectional(CC3Vector4 v) { return (v.w == 0.0); }

/**
 * Returns whether the vector represents a location, rather than a direction.
 *
 * It is locational if the w component is not zero.
 */
static inline BOOL CC3Vector4IsLocational(CC3Vector4 v) { return !CC3Vector4IsDirectional(v); }

/**
 * If the specified homogeneous vector represents a location (w is not zero), returns a
 * homoginized copy of the vector, by dividing each component by the w-component (including
 * the w-component itself, leaving it with a value of one). If the specified vector is a
 * direction (w is zero), or is already homogenized (w is one) the vector is returned unchanged.
 */
static inline CC3Vector4 CC3Vector4Homogenize(CC3Vector4 v) {
	if (v.w == 0.0f || v.w == 1.0f) return v;
	return CC3Vector4FromCC3Vector(CC3VectorScaleUniform(v.v, 1.0f / v.w), 1.0f);
}

/**
 * Returns a CC3Vector structure constructed from a CC3Vector4. The CC3Vector4 is first
 * homogenized (via CC3Vector4Homogenize), before copying the resulting x, y & z
 * coordinates into the CC3Vector.
 */
static inline CC3Vector CC3VectorFromHomogenizedCC3Vector4(CC3Vector4 v) {
	return CC3Vector4Homogenize(v).v;
}

/** Returns the result of scaling the original vector by the corresponding scale factor uniformly along all axes. */
static inline CC3Vector4 CC3Vector4ScaleUniform(CC3Vector4 v, GLfloat scale) {
	return CC3Vector4FromCC3Vector(CC3VectorScaleUniform(v.v, scale), v.w * scale);
}

/**
 * Returns the result of scaling the original vector by the corresponding scale
 * factor uniformly along the X, Y & Z axes. The W component is left unchanged.
 *
 * Use this method for scaling 4D homgeneous coordinates.
 */
static inline CC3Vector4 CC3Vector4HomogeneousScaleUniform(CC3Vector4 v, GLfloat scale) {
	return CC3Vector4FromCC3Vector(CC3VectorScaleUniform(v.v, scale), v.w);
}

/** Returns the dot-product of the two given vectors (v1 . v2). */
static inline GLfloat CC3Vector4Dot(CC3Vector4 v1, CC3Vector4 v2) {
	return CC3VectorDot(v1.v, v2.v) + (v1.w * v2.w);
}

/**
 * Returns the square of the scalar length of the specified vector from the origin, including
 * the w-component. This is calculated as (x*x + y*y + z*z + w*w) and will always be positive.
 *
 * This function is useful for comparing vector sizes without having to run an expensive
 * square-root calculation.
 */
static inline GLfloat CC3Vector4LengthSquared(CC3Vector4 v) { return CC3Vector4Dot(v, v); }

/**
 * Returns the scalar length of the specified vector from the origin, including the w-component
 * This is calculated as sqrt(x*x + y*y + z*z + w*w) and will always be positive.
 */
static inline GLfloat CC3Vector4Length(CC3Vector4 v) {
	// Avoid expensive sqrt calc if vector is unit length or zero
	GLfloat lenSq = CC3Vector4LengthSquared(v);
	return (lenSq == 1.0f || lenSq == 0.0f) ? lenSq : sqrtf(lenSq);
}

/** Returns a normalized copy of the specified vector so that its length is 1.0. The w-component is also normalized. */
static inline CC3Vector4 CC3Vector4Normalize(CC3Vector4 v) {
	GLfloat lenSq = CC3Vector4LengthSquared(v);
	if (lenSq == 0.0f || lenSq == 1.0f) return v;
	return CC3Vector4ScaleUniform(v, (1.0f / sqrtf(lenSq)));
}

/** Returns a vector that is the negative of the specified vector in all dimensions, including W. */
static inline CC3Vector4 CC3Vector4Negate(CC3Vector4 v) { return CC3Vector4Make(-v.x, -v.y, -v.z, -v.w); }

/**
 * Returns a vector that is the negative of the specified homogeneous
 * vector in the X, Y & Z axes. The W component is left unchanged.
 */
static inline CC3Vector4 CC3Vector4HomogeneousNegate(CC3Vector4 v) {
	return CC3Vector4Make(-v.x, -v.y, -v.z, v.w);
}

/**
 * Returns the result of adding the two specified vectors, by adding the
 * corresponding components of both vectors.
 *
 * If one vector is a location (W=1) and the other is a direction (W=0),
 * this can be thought of as a translation of the location in that direction.
 */
static inline CC3Vector4 CC3Vector4Add(CC3Vector4 v, CC3Vector4 translation) {
	return CC3Vector4FromCC3Vector(CC3VectorAdd(v.v, translation.v), v.w + translation.w);
}

/**
 * Returns the difference between two vectors, by subtracting the subtrahend from the
 * minuend, which is accomplished by subtracting each of the corresponding components.
 *
 * If both vectors are locations (W=1), the result will be a direction (W=0).
 */
static inline CC3Vector4 CC3Vector4Difference(CC3Vector4 minuend, CC3Vector4 subtrahend) {
	return CC3Vector4FromCC3Vector(CC3VectorDifference(minuend.v, subtrahend.v), minuend.w - subtrahend.w);
}


#pragma mark -
#pragma mark Quaternions

/** A CC3Quaternion that represents the identity quaternion. */
static const CC3Quaternion kCC3QuaternionIdentity = { { {0.0, 0.0, 0.0} }, 1.0 };

/** @deprecated Replaced by kCC3QuaternionIdentity. */
static const CC3Vector4 kCC3Vector4QuaternionIdentity DEPRECATED_ATTRIBUTE = { { {0.0, 0.0, 0.0} }, 1.0 };

/** A CC3Vector4 of zero length at the origin. */
static const CC3Quaternion kCC3QuaternionZero = { { {0.0, 0.0, 0.0} }, 0.0 };

/** The null CC3Quaternion. Useful for marking an uninitialized quaternion. */
static const CC3Vector4 kCC3QuaternionNull = { { {INFINITY, INFINITY, INFINITY} }, INFINITY};

/** Returns a string description of the specified CC3Quaternion struct in the form "(x, y, z, w)" */
static inline NSString* NSStringFromCC3Quaternion(CC3Quaternion q) { return NSStringFromCC3Vector4(q); }

/** Returns a CC3Quaternion structure constructed from the vector components. */
static inline CC3Quaternion CC3QuaternionMake(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {
	return CC3Vector4Make(x, y, z, w);
}

/** Returns a CC3Quaternion structure constructed from a 3D vector and a w component. */
static inline CC3Quaternion CC3QuaternionFromCC3Vector(CC3Vector v, GLfloat w) {
	return CC3Vector4FromCC3Vector(v, w);
}

/** Returns whether the two quaterions are equal by comparing their respective components. */
static inline BOOL CC3QuaternionsAreEqual(CC3Quaternion q1, CC3Quaternion q2) {
	return CC3Vector4sAreEqual(q1, q2);
}

/** Returns whether the specified quaternion is equal to the zero quaternion, specified by kCC3QuaternionZero. */
static inline BOOL CC3QuaternionIsZero(CC3Quaternion q) { return CC3Vector4IsZero(q); }

/** Returns whether the specified quaternion is equal to the null quaternion, specified by kCC3QuaternionNull. */
static inline BOOL CC3QuaternionIsNull(CC3Quaternion q) { return CC3Vector4IsNull(q); }

/** @deprecated You can now use q.v instead. See the declaration of the CC3Quaterion/CC3Vector4 structure. */
CC3Vector CC3VectorFromQuaternion(CC3Quaternion q) DEPRECATED_ATTRIBUTE;

/** Returns a quaternion that is the negative of the specified quaterion in all dimensions, including W. */
static inline CC3Quaternion CC3QuaternionNegate(CC3Quaternion q) { return CC3Vector4Negate(q); }

/** Returns a normalized copy of the specified quaternion so that its length is 1.0. The w-component is also normalized. */
static inline CC3Quaternion CC3QuaternionNormalize(CC3Quaternion q) { return CC3Vector4Normalize(q); }

/**
 * Returns a quaternion that is the conjugate of the specified quaterion.
 * The X, Y, Z dimensions are negated, but the W is not.
 */
static inline CC3Quaternion CC3QuaternionConjugate(CC3Quaternion q) {
	return CC3QuaternionFromCC3Vector(CC3VectorNegate(q.v), q.w);
}

/** Returns the result of scaling the original quaternion by the corresponding scale factor uniformly along all axes. */
static inline CC3Quaternion CC3QuaternionScaleUniform(CC3Quaternion q, GLfloat scale) {
	return CC3Vector4ScaleUniform(q, scale);
}

/** Returns the dot-product of the two given quaternions (q1 . q2). */
static inline GLfloat CC3QuaternionDot(CC3Quaternion q1, CC3Quaternion q2) { return CC3Vector4Dot(q1, q2); }

/**
 * Returns the square of the scalar length (or magnitude) of the specified quaternion.
 * This is calculated as (x*x + y*y + z*z + w*w) and will always be positive.
 *
 * This function is useful for comparing vector sizes without having to run an expensive
 * square-root calculation.
 */
static inline GLfloat CC3QuaternionLengthSquared(CC3Quaternion q) { return CC3Vector4LengthSquared(q); }

/**
 * Returns the scalar length (or magnitude) of the specified quaternion.
 * This is calculated as sqrt(x*x + y*y + z*z + w*w) and will always be positive.
 */
static inline GLfloat CC3QuaternionLength(CC3Quaternion q) { return CC3Vector4Length(q); }

/**
 * Returns the inverse of the specified quaterion.
 *
 * The inverse of a quaternion is another quaternion such that multiplying a quaternion by
 * its inverse results in the identity quaternion.
 *
 * The returned inverse quaternion is calculated as the conjugate of the specified quaternion
 * divided by the square of the length of the specified quaternion.
 */
static inline CC3Quaternion CC3QuaternionInvert(CC3Quaternion q) {
	return CC3QuaternionScaleUniform(CC3QuaternionConjugate(q), 1.0f / CC3QuaternionLengthSquared(q));
}

/**
 * Returns the result of multiplying qL on the left by qR on the right.
 *
 * This represents a concatenation of two rotations, so that a point rotated by the result is
 * equivalent to the point being rotated first by qL and then by qR: (qL.qR).p == qR.(qL.p).
 */
static inline CC3Quaternion CC3QuaternionMultiply(CC3Quaternion qL, CC3Quaternion qR) {
	return CC3QuaternionMake((qL.w * qR.x) + (qL.x * qR.w) + (qL.y * qR.z) - (qL.z * qR.y),
							 (qL.w * qR.y) - (qL.x * qR.z) + (qL.y * qR.w) + (qL.z * qR.x),
							 (qL.w * qR.z) + (qL.x * qR.y) - (qL.y * qR.x) + (qL.z * qR.w),
							 (qL.w * qR.w) - (qL.x * qR.x) - (qL.y * qR.y) - (qL.z * qR.z));
}

/**
 * Converts the specified vector that represents an rotation in axis-angle form
 * to the corresponding quaternion. The X, Y & Z components of the incoming vector
 * contain the rotation axis, and the W component specifies the angle, in degrees.
 */
static inline CC3Quaternion CC3QuaternionFromAxisAngle(CC3Vector4 axisAngle) {
	// If q is a quaternion, (rx, ry, rz) is the rotation axis, and ra is
	// the rotation angle (negated for right-handed coordinate system), then:
	// q = ( sin(ra/2)*rx, sin(ra/2)*ry, sin(ra/2)*rz, cos(ra/2) )
	
	GLfloat halfAngle = -CC3DegToRad(axisAngle.w) / 2.0f;		// negate for RH system
	CC3Vector axis = CC3VectorNormalize(axisAngle.v);
	return CC3Vector4FromCC3Vector(CC3VectorScaleUniform(axis, sinf(halfAngle)), cosf(halfAngle));
}

/**
 * Converts the specified quaternion to a vector that represents a rotation in
 * axis-angle form. The X, Y & Z components of the returned vector contain the
 * rotation axis, and the W component specifies the angle, in degrees.
 */
static inline CC3Vector4 CC3AxisAngleFromQuaternion(CC3Quaternion quaternion) {
	// If q is a quaternion, (rx, ry, rz) is the rotation axis, and ra is
	// the rotation angle (negated for right-handed coordinate system), then:
	// q = ( sin(ra/2)*rx, sin(ra/2)*ry, sin(ra/2)*rz, cos(ra/2) )
	// ra = acos(q.w) * 2
	// (rx, ry, rz) = (q.x, q.y, q.z) / sin(ra/2)
	
	CC3Vector4 q = CC3Vector4Normalize(quaternion);
	GLfloat halfAngle = -acosf(q.w);						// Negate to preserve orientation
	GLfloat angle = -CC3RadToDeg(halfAngle) * 2.0f;		// Negate for RH system
	
	// If angle is zero, rotation axis is undefined. Use zero vector.
	CC3Vector axis;
	if (halfAngle != 0.0f)
		axis = CC3VectorScaleUniform(q.v, 1.0f / sinf(halfAngle));
	else
		axis = kCC3VectorZero;
	
	return CC3Vector4FromCC3Vector(axis, angle);
}

/**
 * Converts the specified Euler angle rotational vector to a quaternion.
 *
 * The specified rotation vector contains three Euler angles measured in degrees.
 */
CC3Quaternion CC3QuaternionFromRotation(CC3Vector aRotation);

/**
 * Converts the specified quaternion to a Euler angle rotational vector.
 *
 * The returned rotation vector contains three Euler angles measured in degrees.
 */
CC3Vector CC3RotationFromQuaternion(CC3Quaternion aQuaternion);

/**
 * Returns a spherical linear interpolation between two quaternions, based on the blendFactor.
 * which should be between zero and one inclusive. The returned quaternion is calculated as
 * q1 + (blendFactor * (q2 - q1)). If the blendFactor is either zero or one exactly, this
 * function short-circuits to simply return q1 or q2 respectively.
 */
CC3Quaternion CC3QuaternionSlerp(CC3Quaternion q1, CC3Quaternion q2, GLfloat blendFactor);

/** @deprecated Replaced by CC3QuaternionSlerp. */
CC3Vector4 CC3Vector4Slerp(CC3Vector4 v1, CC3Vector4 v2, GLfloat blendFactor) DEPRECATED_ATTRIBUTE;

/**
 * Returns the specified vector rotated by the specified quaternion.
 *
 * This uses a highly optimized version of the basic quaternion rotation equation: qvq(-1):
 *
 *   v' = v + 2 * cross(cross(v, q.v) + (q.w * v), q.v)
 *
 * Derivation of this algorithm can be found in the following Wikipedia article:
 * http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Performance_comparisons
 * which describes the algo in terms of a left-handed coordinate system. It has been modified
 * here for the right-handed coordinate system of OpenGL.
 *
 * The right-handed algo is also described here:
 * http://twistedpairdevelopment.wordpress.com/2013/02/11/rotating-a-vector-by-a-quaternion-in-glsl/
 *
 * A related algo can be found derived (for left-handed coordinates) here:
 * http://mollyrocket.com/forums/viewtopic.php?t=833&sid=3a84e00a70ccb046cfc87ac39881a3d0
 */
static inline CC3Vector CC3QuaternionRotateVector(CC3Quaternion q, CC3Vector v) {
	return CC3VectorAdd(v, CC3VectorScaleUniform(CC3VectorCross(CC3VectorAdd(CC3VectorCross(v, q.v),
																			 CC3VectorScaleUniform(v, q.w)), q.v), 2.0f));
}


#pragma mark -
#pragma mark Ray structure and functions

/**
 * Defines a ray or line in 3D space, by specifying a starting location and direction.
 *
 * For a line, the startLocation can variously be interpreted as the location of any
 * point on the line.
 */
typedef struct {
	CC3Vector startLocation;	/**< The location where the ray starts. */
	CC3Vector direction;		/**< The direction in which the ray points. */
} CC3Ray;

/** Returns a string description of the specified CC3Ray struct. */
static inline NSString* NSStringFromCC3Ray(CC3Ray aRay) {
	return [NSString stringWithFormat: @"(Start: %@, Towards: %@)",
			NSStringFromCC3Vector(aRay.startLocation), NSStringFromCC3Vector(aRay.direction)];
}

/** Returns a CC3Ray structure constructed from the start location and direction vectors. */
static inline CC3Ray CC3RayFromLocDir(CC3Vector aLocation, CC3Vector aDirection) {
	CC3Ray aRay;
	aRay.startLocation = aLocation;
	aRay.direction = aDirection;
	return aRay;
}

/** Returns a CC3Ray structure constructed from the start location and direction components. */
static inline CC3Ray CC3RayMake(GLfloat locX, GLfloat locY, GLfloat locZ,
								GLfloat dirX, GLfloat dirY, GLfloat dirZ) {
	return CC3RayFromLocDir(CC3VectorMake(locX, locY, locZ),
							CC3VectorMake(dirX, dirY, dirZ));
}

/** Returns whether the specified location lies on the specified ray. */
static inline BOOL CC3IsLocationOnRay(CC3Vector aLocation, CC3Ray aRay) {
	// Get a vector from the start of the ray to the location to be tested.
	// Project that vector onto the ray to find the projection of the location
	// onto the ray. If the projected location is the same as the initial
	// location, then the location is on the ray.
	CC3Vector locVect = CC3VectorDifference(aLocation, aRay.startLocation);
	GLfloat proj = CC3VectorDot(locVect, aRay.direction);
	CC3Vector projVect = CC3VectorScaleUniform(aRay.direction, proj);
	CC3Vector projLoc = CC3VectorAdd(aRay.startLocation, projVect);
	return CC3VectorsAreEqual(aLocation, projLoc);
}


#pragma mark -
#pragma mark Vertex structures

/** Returns a ccTex2F structure constructed from the vector components. */
static inline ccTex2F CC3TexCoordsMake(GLfloat u, GLfloat v) {
	ccTex2F tc;
	tc.u = u;
	tc.v = v;
	return tc;
}

/** Convenience alias macro to create ccTex2F with less keystrokes. */
#define cc3tc(U,V) CC3TexCoordsMake((U),(V))

/**
 * Defines a simple vertex, containing location and color.
 * Useful for painting solid colors that ignore lighting conditions.
 */
typedef struct {
	CC3Vector location;			/**< The 3D location of the vertex. */
	ccColor4F color;			/**< The color at the vertex. */
} CC3ColoredVertex;

/**
 * Defines a simple vertex, containing location, normal and color.
 * Useful for painting solid colors that interact with lighting conditions.
 */
typedef struct {
	CC3Vector location;			/**< The 3D location of the vertex. */
	CC3Vector normal;			/**< The 3D normal at the vertex. */
	ccColor4F color;			/**< The color at the vertex. */
} CC3LitColoredVertex;

/**
 * Defines a simple vertex, containing location, normal, and texture coordinate
 * data. Useful for interleaving vertex data for presentation to the GL engine.
 */
typedef struct {
	CC3Vector location;			/**< The 3D location of the vertex. */
	CC3Vector normal;			/**< The 3D normal at the vertex. */
	ccTex2F texCoord;			/**< The 2D coordinate of this vertex on the texture. */
} CC3TexturedVertex;

/** @deprecated Misspelling of CC3TexturedVertex. */
typedef CC3TexturedVertex CCTexturedVertex DEPRECATED_ATTRIBUTE;

/** Returns a string description of the specified textured vertex. */
static inline NSString* NSStringFromCC3TexturedVertex(CC3TexturedVertex vertex) {
	return [NSString stringWithFormat: @"(Location: %@, Normal: %@, TexCoord: (%.3f, %.3f))",
			NSStringFromCC3Vector(vertex.location), NSStringFromCC3Vector(vertex.normal), vertex.texCoord.u, vertex.texCoord.v];
	
}

#pragma mark -
#pragma mark Bounding box structure and functions

/**
 * Defines an axially-aligned-box or bounding-box (AABB), describing
 * a 3D volume by specifying the minimum and maximum 3D corners.
 */
typedef struct {
	CC3Vector minimum;			/**< The minimum corner (bottom-left-rear). */
	CC3Vector maximum;			/**< The maximum corner (top-right-front). */
} CC3Box;

/** A CC3Box of zero origin and dimensions. */
static const CC3Box kCC3BoxZero = { {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0} };

/** The null bounding box. It cannot be drawn, but is useful for marking an uninitialized bounding box. */
static const CC3Box kCC3BoxNull = { {INFINITY, INFINITY, INFINITY}, {INFINITY, INFINITY, INFINITY} };

/** Returns a string description of the specified CC3Box struct. */
static inline NSString* NSStringFromCC3Box(CC3Box bb) {
	return [NSString stringWithFormat: @"(Min: %@, Max: %@)",
			NSStringFromCC3Vector(bb.minimum), NSStringFromCC3Vector(bb.maximum)];
}

/** Returns a CC3Box structure constructed from the min and max vertices. */
static inline CC3Box CC3BoxFromMinMax(CC3Vector minVtx, CC3Vector maxVtx) {
	CC3Box bb;
	bb.minimum = minVtx;
	bb.maximum = maxVtx;
	return bb;
}

/** Returns a CC3Box structure constructed from the min and max components. */
static inline CC3Box CC3BoxMake(GLfloat minX, GLfloat minY, GLfloat minZ,
												GLfloat maxX, GLfloat maxY, GLfloat maxZ) {
	return CC3BoxFromMinMax(CC3VectorMake(minX, minY, minZ),
									CC3VectorMake(maxX, maxY, maxZ));
}

/** Returns whether the two bounding boxes are equal by comparing their respective components. */
static inline BOOL CC3BoxesAreEqual(CC3Box bb1, CC3Box bb2) {
	return CC3VectorsAreEqual(bb1.minimum, bb2.minimum)
		&& CC3VectorsAreEqual(bb1.maximum, bb2.maximum);
}

/**
 * Returns whether the specified bounding box is equal to
 * the zero bounding box, specified by kCC3BoxZero.
 */
static inline BOOL CC3BoxIsZero(CC3Box bb) {
	return CC3BoxesAreEqual(bb, kCC3BoxZero);
}

/**
 * Returns whether the specified bounding box is equal to
 * the null bounding box, specified by kCC3BoxNull.
 */
static inline BOOL CC3BoxIsNull(CC3Box bb) {
	return CC3BoxesAreEqual(bb, kCC3BoxNull);
}

/** Returns the geometric center of the specified bounding box. */
static inline CC3Vector CC3BoxCenter(CC3Box bb) {
	return CC3VectorAverage(bb.minimum, bb.maximum);
}

/** Returns the size of the specified bounding box, between the minimum to maximum corners. */
static inline CC3Vector CC3BoxSize(CC3Box bb) {
	return CC3VectorDifference(bb.maximum, bb.minimum);
}

/** Returns whether the specified bounding box contains the specified location. */
static inline BOOL CC3BoxContainsLocation(CC3Box bb, CC3Vector aLoc) {
	if (aLoc.x > bb.maximum.x) return NO;
	if (aLoc.x < bb.minimum.x) return NO;
	if (aLoc.y > bb.maximum.y) return NO;
	if (aLoc.y < bb.minimum.y) return NO;
	if (aLoc.z > bb.maximum.z) return NO;
	if (aLoc.z < bb.minimum.z) return NO;
	return YES;
}

/**
 * Returns the smallest CC3Box that contains both the specified bounding box
 * and location. If the specified bounding box is null, returns a bounding box of zero
 * size at the specified location.
 */
CC3Box CC3BoxEngulfLocation(CC3Box bb, CC3Vector aLoc);

/**
 * Returns the smallest CC3Box that contains the two specified bounding boxes.
 * If either bounding box is the null bounding box, simply returns the other bounding box
 * (which may also be the null bounding box).
 */
static inline CC3Box CC3BoxUnion(CC3Box bb1, CC3Box bb2) {
	if(CC3BoxIsNull(bb1)) return bb2;
	if(CC3BoxIsNull(bb2)) return bb1;
	
	bb1 = CC3BoxEngulfLocation(bb1, bb2.minimum);
	bb1 = CC3BoxEngulfLocation(bb1, bb2.maximum);
	return bb1;
}

/**
 * Returns a bounding box that has the same dimensions as the specified bounding box, but with
 * each corner expanded outward by the specified amount of padding.
 *
 * The padding value is added to the maximum vector, and subtracted from the minimum vector.
 */
static inline CC3Box CC3BoxAddPadding(CC3Box bb, CC3Vector padding) {
	CC3Box bbPadded;
	bbPadded.maximum = CC3VectorAdd(bb.maximum, padding);
	bbPadded.minimum = CC3VectorDifference(bb.minimum, padding);
	return bbPadded;
}

/**
 * Returns a box that has the same dimensions as the specified  box, but with
 * each corner expanded outward by the specified amount of padding.
 *
 * The padding value is added to all three components of the maximum vector, and subtracted
 * from all three components of the minimum vector.
 */
static inline CC3Box CC3BoxAddUniformPadding(CC3Box bb, GLfloat padding) {
	return (padding != 0.0f) ? CC3BoxAddPadding(bb, cc3v(padding, padding, padding)) : bb;
}

/** Returns a box constructed by translating the specified box by the specified translation offset. */
static inline CC3Box CC3BoxTranslate(CC3Box bb, CC3Vector offset) {
	CC3Box bbXltd;
	bbXltd.maximum = CC3VectorAdd(bb.maximum, offset);
	bbXltd.minimum = CC3VectorAdd(bb.minimum, offset);
	return bbXltd;
}

/**
 * Returns a box constructed by translating the specified box by a translation that is a
 * fraction of the box size, as determined by the specified offsetScale. For example, a
 * value of -0.2 in the X-component of the offsetScale, will move the box 20% of its
 * dimension in the X-axis, in the direction of the negative X-axis.
 */
static inline CC3Box CC3BoxTranslateFractionally(CC3Box bb,
																 CC3Vector offsetScale) {
	return CC3BoxTranslate(bb, CC3VectorScale(CC3BoxSize(bb), offsetScale));
}

/**
 * Returns a bounding box of the same size as the specified bounding box, and whose center
 * lies at the origin of the coordinate system. This effectivly moves the bounding box so
 * that its center is at the origin.
 */
static inline CC3Box CC3BoxMoveCenterToOrigin(CC3Box bb) {
	return CC3BoxTranslate(bb, CC3VectorNegate(CC3BoxCenter(bb)));
}

/**
 * Returns a bounding box constructed by scaling the specified bounding box by the specified
 * scale value. Scaling can be different along each axis of the box.
 *
 * This has the effect of multiplying each component of each of the vectors representing the
 * minimum and maximum corners of the box by the corresponding component in the scale vector.
 */
static inline CC3Box CC3BoxScale(CC3Box bb, CC3Vector scale) {
	CC3Box bbScaled;
	bbScaled.maximum = CC3VectorScale(bb.maximum, scale);
	bbScaled.minimum = CC3VectorScale(bb.minimum, scale);
	return bbScaled;
}

/**
 * Returns a bounding box constructed by scaling the specified bounding box by the specified
 * scale value. The same scaling is applied to each axis of the box.
 *
 * This has the effect of multiplying each component of each of the vectors representing the
 * minimum and maximum corners of the box by the scale value.
 */
static inline CC3Box CC3BoxScaleUniform(CC3Box bb, GLfloat scale) {
	CC3Box bbScaled;
	bbScaled.maximum = CC3VectorScaleUniform(bb.maximum, scale);
	bbScaled.minimum = CC3VectorScaleUniform(bb.minimum, scale);
	return bbScaled;
}

/**
 * Returns the location that the specified ray intersects the specified bounding box,
 * or returns kCC3VectorNull if the ray does not intersect the bounding box, or the
 * bounding box is behind the ray.
 *
 * The result takes into consideration the startLocation of the ray, and will return
 * kCC3VectorNull if the bounding box is behind the startLocation, even if the line
 * projecting back through the startLocation in the negative direction of the ray
 * intersects the bounding box.
 *
 * The ray may start inside the bounding box, and the exit location of the ray will be returned.
 */
CC3Vector CC3RayIntersectionWithBox(CC3Ray aRay, CC3Box bb);

/**
 * Returns the location that the specified ray intersects the specified bounding box,
 * on the side of the bounding box that has the specified normal, but only if the
 * intersection distance is less than the specified previous intersection location.
 *
 * The distance measurement is specified in the W component of the returned 4D vector.
 *
 * If the ray does not intersect the specified side of the bounding box, if the side
 * is behind the ray, or if the intersection distance is larger than that for the
 * specified previous intersection location is returned.
 *
 * This method first creates the plane on which the side exists, finds the intersection
 * of the ray and that plane, determines whether the intersection location is actually
 * within the bounding box, and then tests whether the intersection distance is less
 * than for the specified previous intersection.
 */
CC3Vector4 CC3RayIntersectionWithBoxSide(CC3Ray aRay, CC3Box bb,
										 CC3Vector sideNormal, CC3Vector4 prevHit);

/** @deprecated Renamed to CC3Box. */
typedef CC3Box CC3BoundingBox DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to kCC3BoxZero. */
#define kCC3BoundingBoxZero		kCC3BoxZero

/** @deprecated Renamed to kCC3BoxNull. */
#define kCC3BoundingBoxNull		kCC3BoxNull

/** @deprecated Renamed to NSStringFromCC3Box. */
NSString* NSStringFromCC3BoundingBox(CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxFromMinMax. */
CC3Box CC3BoundingBoxFromMinMax(CC3Vector minVtx, CC3Vector maxVtx) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxMake. */
CC3Box CC3BoundingBoxMake(GLfloat minX, GLfloat minY, GLfloat minZ,
						  GLfloat maxX, GLfloat maxY, GLfloat maxZ) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxesAreEqual. */
BOOL CC3BoundingBoxesAreEqual(CC3Box bb1, CC3Box bb2) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxIsZero. */
BOOL CC3BoundingBoxIsZero(CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxIsNull. */
BOOL CC3BoundingBoxIsNull(CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxCenter. */
CC3Vector CC3BoundingBoxCenter(CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxSize. */
CC3Vector CC3BoundingBoxSize(CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxContainsLocation. */
BOOL CC3BoundingBoxContainsLocation(CC3Box bb, CC3Vector aLoc) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxEngulfLocation. */
CC3Box CC3BoundingBoxEngulfLocation(CC3Box bb, CC3Vector aLoc) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxUnion. */
CC3Box CC3BoundingBoxUnion(CC3Box bb1, CC3Box bb2) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxAddPadding. */
CC3Box CC3BoundingBoxAddPadding(CC3Box bb, CC3Vector padding) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxAddUniformPadding. */
CC3Box CC3BoundingBoxAddUniformPadding(CC3Box bb, GLfloat padding) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxTranslate. */
CC3Box CC3BoundingBoxTranslate(CC3Box bb, CC3Vector offset) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxTranslateFractionally. */
CC3Box CC3BoundingBoxTranslateFractionally(CC3Box bb,
										   CC3Vector offsetScale) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxMoveCenterToOrigin. */
CC3Box CC3BoundingBoxMoveCenterToOrigin(CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxScale. */
CC3Box CC3BoundingBoxScale(CC3Box bb, CC3Vector scale) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3BoxScaleUniform. */
CC3Box CC3BoundingBoxScaleUniform(CC3Box bb, GLfloat scale) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3RayIntersectionWithBox. */
CC3Vector CC3RayIntersectionWithBoundingBox(CC3Ray aRay, CC3Box bb) DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to CC3RayIntersectionWithBoxSide. */
CC3Vector4 CC3RayIntersectionWithBoundingBoxSide(CC3Ray aRay, CC3Box bb,
												 CC3Vector sideNormal, CC3Vector4 prevHit) DEPRECATED_ATTRIBUTE;


#pragma mark -
#pragma mark 3D angular vector structure and functions

/**
 * An angle such as a heading or inclination.
 * Can be measured in degrees or radians and may be positive or negative.
 */ 
typedef GLfloat CC3Angle;

/** Specifies a vector using angular coordinate axes. Angles are measured in degrees or radians. */
typedef struct {
	CC3Angle heading;				/**< The horizontal heading. */
	CC3Angle inclination;			/**< The inclination from horizontal. */
	GLfloat radius;					/**< The radial distance. */
} CC3AngularVector;

/** Returns a string description of the specified CC3AngularVector struct in the form "(heading, inclination, radius)" */
static inline NSString* NSStringFromCC3AngularVector(CC3AngularVector av) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f)", av.heading, av.inclination, av.radius];
}

/** Returns an CC3AngularVector structure constructed from the vector components. */
static inline CC3AngularVector CC3AngularVectorMake(GLfloat heading, GLfloat inclination, GLfloat radius) {
	CC3AngularVector av;
	av.heading = heading;
	av.inclination = inclination;	
	av.radius = radius;
	return av;
}

/**
 * Returns an CC3AngularVector providing the heading, inclination & radius of the specified CC3Vector.
 * Heading is measured in degrees, in the X-Z plane, clockwise from the negative Z-axis.
 * Inclination is measured in degrees, with up being in the positive-Y direction.
 */
static inline CC3AngularVector CC3AngularVectorFromVector(CC3Vector aCoord) {
	CC3AngularVector av;
	av.radius = CC3VectorLength(aCoord);
	av.inclination = av.radius ? CC3RadToDeg(asinf(aCoord.y / av.radius)) : 0.0f;
	av.heading = CC3RadToDeg(atan2f(aCoord.x, -aCoord.z));
	return av;
}

/**
 * Returns a CC3Vector from the specified CC3AngularVector.
 * Heading is measured in degrees, in the X-Z plane, clockwise from the negative Z-axis.
 * Inclination is measured in degrees, with up being in the positive-Y direction.
 */
static inline CC3Vector CC3VectorFromAngularVector(CC3AngularVector av) {
	CC3Vector unitDir;
	
	// First, incline up the Y-axis from the negative Z-axis.
	GLfloat radInclination = CC3DegToRad(av.inclination);
	unitDir.y = sinf(radInclination);
	GLfloat xzLen = cosf(radInclination);
	
	// Now rotate around the Y-axis to the heading. The length of the projection of the direction
	// vector into the X-Z plane is the length of the projection onto the negative Z-axis after
	// the initial inclination. Use this length as the basis for calculating the X & Z CC3Vectors.
	// The result is a unit direction vector projected into all three axes.
	GLfloat radHeading = CC3DegToRad(av.heading);
	unitDir.x = xzLen * sinf(radHeading);
	unitDir.z = -xzLen * cosf(radHeading);
	return CC3VectorScaleUniform(unitDir, av.radius);
}

/**
 * Returns the difference between two CC3AngularVectors, by subtracting the corresponding heading,
 * inclination & radial components. Note that this is NOT true vector arithmetic, which would
 * yield a completely different angular and radial results.
 */
static inline CC3AngularVector CC3AngularVectorDifference(CC3AngularVector minuend, CC3AngularVector subtrahend) {
	CC3AngularVector difference;
	difference.heading = CC3SemiCyclicAngle(minuend.heading - subtrahend.heading);
	difference.inclination = minuend.inclination - subtrahend.inclination;
	difference.radius = minuend.radius - subtrahend.radius;
	return difference;
}


#pragma mark -
#pragma mark Face structures and functions

/** Defines a triangular face of the mesh, comprised of three vertices, stored in winding order. */
typedef struct {
	CC3Vector vertices[3];	/**< The vertices of the face, stored in winding order. */
} CC3Face;

/** A CC3Face with all vertices set to zero. */
static const CC3Face kCC3FaceZero = { { { 0.0, 0.0, 0.0 }, { 0.0, 0.0, 0.0 }, { 0.0, 0.0, 0.0 } } };

/** Returns a string description of the specified CC3Face struct. */
static inline NSString* NSStringFromCC3Face(CC3Face face) {
	return [NSString stringWithFormat: @"(%@, %@, %@)",
			NSStringFromCC3Vector(face.vertices[0]),
			NSStringFromCC3Vector(face.vertices[1]),
			NSStringFromCC3Vector(face.vertices[2])];
}

/** 
 * Returns a CC3Face structure constructed from the three specified vectors,
 * which should be supplied in winding order.
 */
static inline CC3Face CC3FaceMake(CC3Vector v0, CC3Vector v1, CC3Vector v2) {
	CC3Face face;
	face.vertices[0] = v0;
	face.vertices[1] = v1;
	face.vertices[2] = v2;
	return face;
}

/**
 * Returns a CC3Face structure that has the same vertices
 * as the specified face, but in the opposite winding order.
 */
static inline CC3Face CC3FaceInvert(CC3Face face) {
	return CC3FaceMake(face.vertices[0], face.vertices[2], face.vertices[1]);
}

/**
 * Returns the location of the center of the specified face, calculated
 * as the mathematical average of the three vertices that define the face.
 */
static inline CC3Vector CC3FaceCenter(CC3Face face) {
	CC3Vector* vtx = face.vertices;
	return cc3v((vtx[0].x + vtx[1].x + vtx[2].x) * kCC3OneThird,
				(vtx[0].y + vtx[1].y + vtx[2].y) * kCC3OneThird,
				(vtx[0].z + vtx[1].z + vtx[2].z) * kCC3OneThird);
}

/**
 * Returns a normalized normal vector derived from the location and winding order
 * of the three vertices in the specified face.
 *
 * The direction of the normal vector is affected by the winding order of the
 * vertices in the face. The vertices should wind vertex[0] -> vertex[1] -> vertex[2].
 * The normal will point in the direction that has the three points winding in a
 * counter-clockwise direction, according to a right-handed coordinate system.
 * If the direction of the normal is important, be sure the winding order of
 * the points in the face is correct.
 */
static inline CC3Vector CC3FaceNormal(CC3Face face) {
	return CC3VectorNormalize(CC3VectorCross(CC3VectorDifference(face.vertices[1], face.vertices[0]),
											 CC3VectorDifference(face.vertices[2], face.vertices[0])));
}

/** Defines the barycentric weights of the three vertices of a triangle, in the same order as the vertices in a CC3Face. */
typedef struct {
	GLfloat weights[3];		/**< The barycentric weights of the three vertices of the face. */
} CC3BarycentricWeights;

/** Returns a CC3BarycentricWeights structure constructed from the three specified weights. */
static inline CC3BarycentricWeights CC3BarycentricWeightsMake(GLfloat b0, GLfloat b1, GLfloat b2) {
	CC3BarycentricWeights bcw;
	bcw.weights[0] = b0;
	bcw.weights[1] = b1;
	bcw.weights[2] = b2;
	return bcw;
}

/** Returns a string description of the specified NSStringFromCC3BarycentricWeights struct. */
static inline NSString* NSStringFromCC3BarycentricWeights(CC3BarycentricWeights bcw) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f)", bcw.weights[0], bcw.weights[1], bcw.weights[2]];
}

/**
 * Returns whether the specified barycentric weights indicate a location inside a triangle.
 *
 * To be inside a triangle, none of the weights may be negative. If any of the weights are negative,
 * the specified barycentric weights represent a location outside a triangle.
 */
static inline BOOL CC3BarycentricWeightsAreInsideTriangle(CC3BarycentricWeights bcw) {
	return bcw.weights[0] >= 0.0f && bcw.weights[1] >= 0.0f && bcw.weights[2] >= 0.0f;
}

/**
 * Returns the barycentric weights for the specified location on the plane of the specified face.
 * The returned weights are specified in the same order as the vertices of the face.
 * 
 * The specified location should be on the plane of the specified face. 
 *
 * If the location is on the plane of the specified face, the three returned weights will add up to one.
 * If all three of the returned weights are positive, then the location is inside the triangle
 * defined by the face, otherwise, at least one of the returned weights will be negative.
 */
CC3BarycentricWeights CC3FaceBarycentricWeights(CC3Face face, CC3Vector aLocation);

/**
 * Returns the 3D cartesian location on the specified face that corresponds to the specified
 * barycentric coordinate weights.
 */
static inline CC3Vector CC3FaceLocationFromBarycentricWeights(CC3Face face, CC3BarycentricWeights bcw) {
	CC3Vector* c = face.vertices;
	GLfloat* b = bcw.weights;
	CC3Vector v;
	v.x = b[0] * c[0].x + b[1] * c[1].x + b[2] * c[2].x;
	v.y = b[0] * c[0].y + b[1] * c[1].y + b[2] * c[2].y;
	v.z = b[0] * c[0].z + b[1] * c[1].z + b[2] * c[2].z;
	return v;
}

/**
 * Defines a triangular face of the mesh, comprised of three vertex indices,
 * each a GLuint, stored in winding order.
 */
typedef struct {
	GLuint vertices[3];	/**< The indices of the vertices of the face, stored in winding order. */
} CC3FaceIndices;

/** A CC3FaceIndices with all vertices set to zero. */
static const CC3FaceIndices kCC3FaceIndicesZero = { {0, 0, 0} };

/** Returns a string description of the specified CC3FaceIndices struct. */
static inline NSString* NSStringFromCC3FaceIndices(CC3FaceIndices faceIndices) {
	return [NSString stringWithFormat: @"(%u, %u, %u)",
			faceIndices.vertices[0], faceIndices.vertices[1], faceIndices.vertices[2]];
}

/** 
 * Returns a CC3FaceIndices structure constructed from the three
 * specified vertex indices, which should be supplied in winding order.
 */
static inline CC3FaceIndices CC3FaceIndicesMake(GLuint i0, GLuint i1, GLuint i2) {
	CC3FaceIndices fi;
	fi.vertices[0] = i0;
	fi.vertices[1] = i1;
	fi.vertices[2] = i2;
	return fi;
}


#pragma mark -
#pragma mark Plane structures and functions

/** The coefficients of the equation for a plane in 3D space (ax + by + cz + d = 0). */
typedef struct {
	GLfloat a;				/**< The a coefficient in the planar equation. */
	GLfloat b;				/**< The b coefficient in the planar equation. */
	GLfloat c;				/**< The c coefficient in the planar equation. */
	GLfloat d;				/**< The d coefficient in the planar equation. */
} CC3Plane;

/** An undefined plane. */
static const CC3Plane kCC3PlaneZero = { 0, 0, 0, 0 };

/** Returns a string description of the specified CC3Plane struct in the form "(a, b, c, d)" */
static inline NSString* NSStringFromCC3Plane(CC3Plane p) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", p.a, p.b, p.c, p.d];
}

/** Returns a CC3Plane structure constructed from the specified coefficients. */
static inline CC3Plane CC3PlaneMake(GLfloat a, GLfloat b, GLfloat c, GLfloat d) {
	CC3Plane p;
	p.a = a;
	p.b = b;
	p.c = c;
	p.d = d;
	return p;
}

/** Returns the normal of the plane, which is (a, b, c) from the planar equation. */
static inline CC3Vector CC3PlaneNormal(CC3Plane p) {
	return *(CC3Vector*)&p;
}

/** Returns a CC3Plane that has the specified normal and intersects the specified location. */
static inline CC3Plane CC3PlaneFromNormalAndLocation(CC3Vector n, CC3Vector loc) {
	GLfloat d = -CC3VectorDot(loc, n);
	return CC3PlaneMake(n.x, n.y, n.z, d);
}

/**
 * Returns a CC3Plane structure that contains the specified locations.
 * 
 * The direction of the normal of the returned plane is dependent on the winding order
 * of the three locations. Winding is done in the order the locations are specified
 * (v1 -> v2 -> v3), and the normal will point in the direction that has the three
 * locations winding in a counter-clockwise direction, according to a right-handed
 * coordinate system. If the direction of the normal is important, be sure to specify
 * the three points in the appropriate order.
 */
static inline CC3Plane CC3PlaneFromLocations(CC3Vector v1, CC3Vector v2, CC3Vector v3) {
	CC3Vector n = CC3VectorNormalize(CC3VectorCross(CC3VectorDifference(v2, v1),
													CC3VectorDifference(v3, v1)));
	return CC3PlaneFromNormalAndLocation(n, v1);
}

/**
 * Returns a CC3Plane structure that contains the points in the specified face.
 * 
 * The direction of the normal of the returned plane is dependent on the winding order
 * of the face, which is taken to be vertex[0] -> vertex[1] -> vertex[2], and the normal
 * will point in the direction that has the three points winding in a counter-clockwise
 * direction, according to a right-handed coordinate system. If the direction of the
 * normal is important, be sure the winding order of the points in the face is correct.
 */
static inline CC3Plane CC3FacePlane(CC3Face face) {
	return CC3PlaneFromLocations(face.vertices[0], face.vertices[1], face.vertices[2]);
}

/** Returns whether the two planes are equal by comparing their respective components. */
static inline BOOL CC3PlanesAreEqual(CC3Plane p1, CC3Plane p2) {
	return p1.a == p2.a &&
		   p1.b == p2.b &&
		   p1.c == p2.c &&
		   p1.d == p2.d;
}

/** Returns whether the specified plane is equal to the zero plane, specified by kCC3PlaneZero. */
static inline BOOL CC3PlaneIsZero(CC3Plane p) { return CC3PlanesAreEqual(p, kCC3PlaneZero); }


/**
 * Returns a plane that is the negative of the specified plane in all dimensions, including D.
 *
 * The returned plane represents a plane that is coincident with the specified plane,
 * but whose normal points in the opposite direction.
 */
static inline CC3Plane CC3PlaneNegate(CC3Plane p) {
	return CC3PlaneMake(-p.a, -p.b, -p.c, -p.d);
}

/** Returns a normalized copy of the specified CC3Plane so that the length of its normal (a, b, c) is 1.0 */
static inline CC3Plane CC3PlaneNormalize(CC3Plane p) {
	GLfloat ooNormLen = 1.0f / CC3VectorLength(CC3PlaneNormal(p));
	return CC3PlaneMake(p.a * ooNormLen,
						p.b * ooNormLen,
						p.c * ooNormLen,
						p.d * ooNormLen);
}

/**
 * Returns the distance from the specified location to the specified plane.
 *
 * The distance is returned in terms of the length of the normal. If the normal
 * is of unit length, then the distance is in absolute units.
 */
static inline GLfloat CC3DistanceFromPlane(CC3Vector v, CC3Plane p) {
	return CC3VectorDot(v, CC3PlaneNormal(p)) + p.d;
}

/**
 * Returns whether the specified vector is in front of the specified normalized plane.
 *
 * If the vector is a location, being "in front" means the location is on the side of
 * the plane from which the plane normal points.
 *
 * If the vector is a direction, being "in front" means that the direction points away
 * from the plane on the same side of the plane as the normal points away from the plane.
 */
static inline BOOL CC3VectorIsInFrontOfPlane(CC3Vector v, CC3Plane p) {
	return (CC3DistanceFromPlane(v, p) > 0.0f);
}

/**
 * Returns whether the specified 4D homogeneous vector is in front of the
 * specified normalized plane.
 *
 * If the vector is a location (w = 1), being "in front" means the location
 * is on the side of the plane from which the plane normal points.
 *
 * If the vector is a direction (w = 0), being "in front" means that the
 * direction points away from the plane on the same side of the plane as
 * the normal points away from the plane.
 */
static inline BOOL CC3Vector4IsInFrontOfPlane(CC3Vector4 v, CC3Plane plane) {
	return CC3Vector4Dot(*(CC3Vector4*)&plane, v) > 0.0f;
}

/**
 * Returns the location of the point where the specified ray intersects the specified plane.
 *
 * The returned result is a 4D vector, where the x, y & z components give the intersection location
 * in 3D space, and the w component gives the distance from the startLocation of the ray to the
 * intersection location, in multiples of the ray direction vector. If this value is negative, the
 * intersection point is in the direction opposite to the direction of the ray.
 *
 * If the ray is parallel to the plane, no intersection occurs, and the returned 4D vector
 * will be equal to kCC3Vector4Null.
 */
CC3Vector4 CC3RayIntersectionWithPlane(CC3Ray ray, CC3Plane plane);

/**
 * Returns the instersection point of the three specified planes, or returns kCC3VectorNull
 * if the planes do not intersect at a single point, which can occur if the planes are
 * parallel, or if one plane is parallel to the line of intersection of the other two planes.
 */
CC3Vector CC3TriplePlaneIntersection(CC3Plane p1, CC3Plane p2, CC3Plane p3);

/** @deprecated Renamed to CC3PlaneFromLocations */
CC3Plane CC3PlaneFromPoints(CC3Vector v1, CC3Vector v2, CC3Vector v3) DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced with CC3DistanceFromPlane. */
GLfloat CC3DistanceFromNormalizedPlane(CC3Plane p, CC3Vector v) DEPRECATED_ATTRIBUTE;


#pragma mark -
#pragma mark Sphere structure and functions

/** Defines a sphere. */
typedef struct {
	CC3Vector center;			/**< The center of the sphere. */
	GLfloat radius;				/**< The radius of the sphere */
} CC3Sphere;

/** Returns a string description of the specified sphere. */
static inline NSString* NSStringFromCC3Spere(CC3Sphere sphere) {
	return [NSString stringWithFormat: @"(Center: %@, Radius: %.3f)",
			NSStringFromCC3Vector(sphere.center), sphere.radius];
}

/** Returns a CC3Spere constructed from the specified center and radius. */
static inline CC3Sphere CC3SphereMake(CC3Vector center, GLfloat radius) {
	CC3Sphere s;
	s.center = center;
	s.radius = radius;
	return s;
}

/** Returns a CC3Spere that circumscribes the specified box. */
static inline CC3Sphere CC3SphereFromCircumscribingBox(CC3Box box) {
	CC3Vector center = CC3BoxCenter(box);
	GLfloat radius = CC3VectorDistance(box.maximum, center);
	return CC3SphereMake(center, radius);
}

/** Returns whether the specified location lies within the specified sphere. */
static inline BOOL CC3IsLocationWithinSphere(CC3Vector aLocation, CC3Sphere aSphere) {
	// Compare the squares of the distances to avoid taking an expensive square root. 
	GLfloat radiusSquared = aSphere.radius * aSphere.radius;
	return CC3VectorDistanceSquared(aLocation, aSphere.center) <= radiusSquared;
}

/** Returns whether the specified spheres intersect. */
static inline BOOL CC3DoesSphereIntersectSphere(CC3Sphere sphereOne, CC3Sphere sphereTwo) {
	// Expand the first sphere to have a radius equal to the sume of the two radii,
	// and test whether the center of the other sphere is inside the expanded sphere.
	CC3Sphere bigSphere = CC3SphereMake(sphereOne.center, (sphereOne.radius + sphereTwo.radius));
	return CC3IsLocationWithinSphere(sphereTwo.center, bigSphere);
}

/** Returns the smallest CC3Sphere that contains the two specified spheres. */
CC3Sphere CC3SphereUnion(CC3Sphere s1, CC3Sphere s2);

/** Returns whether the specified ray intersects the specified sphere. */
BOOL CC3DoesRayIntersectSphere(CC3Ray aRay, CC3Sphere aSphere);

/**
 * Returns the location that the specified ray intersects the specified sphere, or returns
 * kCC3VectorNull if the ray does not intersect the sphere, or the sphere is behind the ray.
 *
 * The result takes into consideration the startLocation of the ray, and will return
 * kCC3VectorNull if the sphere is behind the startLocation, even if the line projecting
 * back through the startLocation in the negative direction of the ray intersects the sphere.
 *
 * The ray may start inside the sphere, in which case, the returned location represents
 * the exit location of the ray.
 */
CC3Vector CC3RayIntersectionWithSphere(CC3Ray aRay, CC3Sphere aSphere);

/** @deprecated Renamed to CC3RayIntersectionWithSphere. */
CC3Vector CC3RayIntersectionOfSphere(CC3Ray aRay, CC3Sphere aSphere) DEPRECATED_ATTRIBUTE;

/**
 * Returns the coefficients of the quadratic equation that describes the points of
 * intersection between the specified ray and sphere.
 *
 * Given the equation for a sphere at the origin:  x*x + y*y + z*z = r*r, and the
 * equation for a ray in the same frame of reference: p = s + tv, where s is the
 * ray start, v is the ray direction, and p is a point on the ray, we can solve for
 * the intersection points of the ray and sphere. The result is a quadratic equation
 * in t: at*t + bt + c = 0, where: a = v*v, b = 2(s.v), and c = s*s - r*r.
 *
 * The a, b and c elements of the returned CC3Plane structure contain the a, b and c
 * coefficients of the quadratic equation, respectively. The d element of the returned
 * CC3Plane structure contains the discriminant of the quadratic equation (d = b*b - 4ac).
 *
 * The returned quadratic coefficients are not a plane.
 * The CC3Plane structure is simply used for convenience.
 *
 * Reference: Mathematics for 3D Game Programming and Computer Graphics, 3rd ed. book, by Eric Lengyel
 */
CC3Plane CC3RaySphereIntersectionEquation(CC3Ray aRay, CC3Sphere aSphere);


#pragma mark -
#pragma mark Attenuation functions & structures

/**
 * The constant, linear, and quadratic coefficients of the attenuation function equation:
 * (a + b*r + c*r*r), where r is the radial distance between a the source (light or camera)
 * and the 3D location at which we want to calculate attenuation.
 */
typedef struct {
	GLfloat a;				/**< The constant coefficient in the attenuation function. */
	GLfloat b;				/**< The linear coefficient in the attenuation function. */
	GLfloat c;				/**< The quadratic coefficient in the attenuation function. */
} CC3AttenuationCoefficients;

/** Attenuation coefficients corresponding to no attenuation with distance (constant size). */
static const CC3AttenuationCoefficients kCC3AttenuationNone = {1.0, 0.0, 0.0};

/** Deprecated. Use kCC3AttenuationNone instead. */
static const CC3AttenuationCoefficients kCC3ParticleSizeAttenuationNone DEPRECATED_ATTRIBUTE = {1.0, 0.0, 0.0};

/**
 * Returns a string description of the specified CC3AttenuationCoefficients struct
 * in the form "(a, b, c)".
 */
static inline NSString* NSStringFromCC3AttenuationCoefficients(CC3AttenuationCoefficients coeffs) {
	return [NSString stringWithFormat: @"(%.3f, %.6f, %.9f)", coeffs.a, coeffs.b, coeffs.c];
}

/** Returns a CC3AttenuationCoefficients structure constructed from the specified coefficients. */
static inline CC3AttenuationCoefficients CC3AttenuationCoefficientsMake(GLfloat constant,
																		GLfloat linear,
																		GLfloat quadratic) {
	CC3AttenuationCoefficients coeffs;
	coeffs.a = constant;
	coeffs.b = linear;
	coeffs.c = quadratic;
	return coeffs;
}

/** Returns whether the two attenuation coefficents are equal by comparing their respective components. */
static inline BOOL CC3AttenuationCoefficientsAreEqual(CC3AttenuationCoefficients ac1,
													  CC3AttenuationCoefficients ac2) {
	return (ac1.a == ac2.a) && (ac1.b == ac2.b) && (ac1.c == ac2.c);
}

/**
 * If at least one of the coefficients in the specified attenuation is not zero, the specified
 * attenuation coefficients is returned unchanged. However, if all three coefficients of the
 * specified attenuation coefficients are zero, the value is illegal (and will cause divide-by-zero
 * errors, especially in shaders). If that is the case, this function returns kCC3AttenuationNone.
 */
static inline CC3AttenuationCoefficients CC3AttenuationCoefficientsLegalize(CC3AttenuationCoefficients ac) {
	return (ac.a != 0.0f || ac.b != 0.0f || ac.c != 0.0f) ? ac : kCC3AttenuationNone;
}


#pragma mark -
#pragma mark Viewport structure and functions

/** 
 * A rectangle defining a GL viewport.
 *
 * This can also be used for any rectangular group of pixels.
 */
typedef struct {
	GLint x;				/**< The X-position of the bottom-left corner of the viewport. */
	GLint y;				/**< The Y-position of the bottom-left corner of the viewport. */
	GLsizei w;				/**< The width of the viewport. */
	GLsizei h;				/**< The height of the viewport. */
} CC3Viewport;

/** An empty or undefined viewport. */
static const CC3Viewport kCC3ViewportZero = { 0, 0, 0, 0 };

/** Returns a string description of the specified CC3Viewport struct in the form "(x, y, w, h)" */
static inline NSString* NSStringFromCC3Viewport(CC3Viewport vp) {
	return [NSString stringWithFormat: @"(%i, %i, %i, %i)", vp.x, vp.y, vp.w, vp.h];
}

/** Returns a CC3Viewport structure constructed from the specified components. */
static inline CC3Viewport CC3ViewportMake(GLint x, GLint y, GLint w, GLint h) {
	CC3Viewport vp;
	vp.x = x;
	vp.y = y;
	vp.w = w;
	vp.h = h;
	return vp;
}

/** Returns a CC3Viewport constructed from the specified origin and size. */
static inline CC3Viewport CC3ViewportFromOriginAndSize(CC3IntPoint origin, CC3IntSize size) {
	return CC3ViewportMake(origin.x, origin.y, size.width, size.height);
}

/** Returns whether the two viewports are equal by comparing their respective components. */
static inline BOOL CC3ViewportsAreEqual(CC3Viewport vp1, CC3Viewport vp2) {
	return (vp1.x == vp2.x) && (vp1.y == vp2.y) && (vp1.w == vp2.w) && (vp1.h == vp2.h);
}

/** Returns whether the specified viewport is equal to the zero viewport, specified by kCC3ViewportZero. */
static inline BOOL CC3ViewportIsZero(CC3Viewport vp) {
	return CC3ViewportsAreEqual(vp, kCC3ViewportZero);
}

/**
 * Returns whether the specified point lies within the specified viewport.
 * A point is considered inside the viewport if its coordinates lie inside
 * the viewport or on the minimum X or minimum Y edge.
 */
static inline BOOL CC3ViewportContainsPoint(CC3Viewport vp, CGPoint point) {
	return (point.x >= vp.x) && (point.x < vp.x + vp.w) &&
	(point.y >= vp.y) && (point.y < vp.y + vp.h);
}

/** Returns a CC3Viewport constructed from the specified CGRect. */
static inline CC3Viewport CC3ViewportFromCGRect(CGRect rect) {
	return CC3ViewportFromOriginAndSize(CC3IntPointFromCGPoint(rect.origin), CC3IntSizeFromCGSize(rect.size));
}

/** Returns a CGRect constructed from the specified viewport. */
static inline CGRect CGRectFromCC3Viewport(CC3Viewport vp) {
	return CGRectMake(vp.x, vp.y, vp.w, vp.h);
}


#pragma mark -
#pragma mark Color support

/** Returns a GLfloat between 0 and 1 converted from the specified GLubyte value between 0 and 255. */
static inline GLfloat CCColorFloatFromByte(GLubyte colorValue) {
	return (GLfloat)colorValue * kCC3OneOver255;
}

/**
 * Returns a GLubyte between 0 and 255 converted from the specified GLfloat value.
 *
 * The specified float value is clamped to between 0 and 1 before conversion, so that
 * the Glubyte does not overflow or underflow, which would create unexpected colors.
 */
static inline GLubyte CCColorByteFromFloat(GLfloat colorValue) {
	return (GLubyte)(CLAMP(colorValue, 0.0f, 1.0f) * 255.0f);
}

/**
 * Returns the luminosity of the specified color as calculated using the ITU-R BT.709
 * conversion for high-definition television (HDTV):
 *
 *   luminosity = (0.2126 * red) + (0.7152 * green) + (0.0722 * blue),
 */
static inline GLfloat CC3LuminosityBT709(GLfloat red, GLfloat green, GLfloat blue) {
	return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
}

/**
 * Returns the luminosity of the specified color as calculated using the ITU-R BT.601
 * conversion for standard-definition television (SDTV):
 *
 *   luminosity = (0.299 * red) + (0.587 * green) + (0.114 * blue),
 */
static inline GLfloat CC3LuminosityBT601(GLfloat red, GLfloat green, GLfloat blue) {
	return (0.299 * red) + (0.587 * green) + (0.114 * blue);
}


#pragma mark -
#pragma mark ccColor4F constants and functions


/** Opaque Red */
static const ccColor4F kCCC4FRed = { 1.0, 0.0, 0.0, 1.0 };

/** Opaque Green */
static const ccColor4F kCCC4FGreen = { 0.0, 1.0, 0.0, 1.0 };

/** Opaque Blue */
static const ccColor4F kCCC4FBlue = { 0.0, 0.0, 1.0, 1.0 };

/** Opaque Cyan */
static const ccColor4F kCCC4FCyan = { 0.0, 1.0, 1.0, 1.0 };

/** Opaque Magenta */
static const ccColor4F kCCC4FMagenta = { 1.0, 0.0, 1.0, 1.0 };

/** Opaque Yellow */
static const ccColor4F kCCC4FYellow = { 1.0, 1.0, 0.0, 1.0 };

/** Opaque Orange */
static const ccColor4F kCCC4FOrange = { 1.0, 0.5, 0.0, 1.0 };

/** Opaque Light Gray */
static const ccColor4F kCCC4FLightGray = { 0.75, 0.75, 0.75, 1.0 };

/** Opaque Gray */
static const ccColor4F kCCC4FGray = { 0.5, 0.5, 0.5, 1.0 };

/** Opaque Dark Gray */
static const ccColor4F kCCC4FDarkGray = { 0.25, 0.25, 0.25, 1.0 };

/** Opaque White */
static const ccColor4F kCCC4FWhite = { 1.0, 1.0, 1.0, 1.0 };

/** Opaque Black */
static const ccColor4F kCCC4FBlack = { 0.0, 0.0, 0.0, 1.0 };

/** Transparent Black */
static const ccColor4F kCCC4FBlackTransparent = {0.0, 0.0, 0.0, 0.0};

/** Returns a string description of the specified ccColor4F in the form "(r, g, b, a)" */
static inline NSString* NSStringFromCCC4F(ccColor4F rgba) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", rgba.r, rgba.g, rgba.b, rgba.a];
}

#if COCOS2D_VERSION < 0x010100		// cocos2d 1.0 - exists in cocos2d versions above
/** Convenience alias macro to create ccColor4F with less keystrokes. */
#define ccc4f(R,G,B,A) CCC4FMake((R),(G),(B),(A))
#endif

/** Returns a ccColor4F structure constructed from the specified components */
static inline ccColor4F CCC4FMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	ccColor4F color;
	color.r = red;
	color.g = green;
	color.b = blue;
	color.a = alpha;
	return color;
}

/** Returns a ccColor4F structure constructed from the specified ccColor4B */
static inline ccColor4F CCC4FFromCCC4B(ccColor4B byteColor) {
	return ccc4f(CCColorFloatFromByte(byteColor.r),
				 CCColorFloatFromByte(byteColor.g),
				 CCColorFloatFromByte(byteColor.b),
				 CCColorFloatFromByte(byteColor.a));
}

/** Returns a ccColor4F structure constructed from the specified ccColor3B and opacity. */
static inline ccColor4F CCC4FFromColorAndOpacity(ccColor3B byteColor, GLubyte opacity) {
	return ccc4f(CCColorFloatFromByte(byteColor.r),
				 CCColorFloatFromByte(byteColor.g),
				 CCColorFloatFromByte(byteColor.b),
				 CCColorFloatFromByte(opacity));
}

/** Returns a ccColor4F structure constructed from the specified CoreGraphics CGColorRef. */
static inline ccColor4F CCC4FFromCGColor(CGColorRef cgColor) {
	ccColor4F rgba = (ccColor4F){ 1.0, 1.0, 1.0, 1.0 };  // initialize to white
	size_t componentCount = CGColorGetNumberOfComponents(cgColor);
	const CGFloat* colorComponents = CGColorGetComponents(cgColor);
	switch(componentCount) {
		case 4:			// RGB + alpha: set alpha then fall through to RGB 
			rgba.a = colorComponents[3];
		case 3:			// RGB: alpha already set
			rgba.r = colorComponents[0];
			rgba.g = colorComponents[1];
			rgba.b = colorComponents[2];
			break;
		case 2:			// gray scale + alpha: set alpha then fall through to gray scale
			rgba.a = colorComponents[1];
		case 1:		// gray scale: alpha already set
			rgba.r = colorComponents[0];
			rgba.g = colorComponents[0];
			rgba.b = colorComponents[0];
			break;
		default:	// if all else fails, return white which is already set
			break;
	}
	return rgba;
}

/** Returns the intensity of the specified color, calculated as the arithmetic mean of the R, G & B components. */
static inline GLfloat CCC4FIntensity(ccColor4F color) {
	return (color.r + color.g + color.b) * kCC3OneThird;
}

/** Returns whether the two colors are equal by comparing their respective components. */
static inline BOOL CCC4FAreEqual(ccColor4F c1, ccColor4F c2) {
	return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a;
}

/**
 * Returns the result of adding the two specified colors, by adding the corresponding components.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 * This can also be thought of as a translation of the first color by the second.
 */
static inline ccColor4F CCC4FAdd(ccColor4F rgba, ccColor4F translation) {
	return ccc4f(CLAMP(rgba.r + translation.r, 0.0f, 1.0f),
				 CLAMP(rgba.g + translation.g, 0.0f, 1.0f),
				 CLAMP(rgba.b + translation.b, 0.0f, 1.0f),
				 CLAMP(rgba.a + translation.a, 0.0f, 1.0f));
}

/**
 * Returns the difference between two colors, by subtracting the subtrahend from the minuend,
 * which is accomplished by subtracting each of the corresponding r,g, b, a components.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FDifference(ccColor4F minuend, ccColor4F subtrahend) {
	return ccc4f(CLAMP(minuend.r - subtrahend.r, 0.0f, 1.0f),
				 CLAMP(minuend.g - subtrahend.g, 0.0f, 1.0f),
				 CLAMP(minuend.b - subtrahend.b, 0.0f, 1.0f),
				 CLAMP(minuend.a - subtrahend.a, 0.0f, 1.0f));
}

/**
 * Returns a ccColor4F structure whose values are those of the specified original color,
 * where each color component has been translated by the specified offset.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FUniformTranslate(ccColor4F rgba, GLfloat offset) {
	return CCC4FAdd(rgba, ccc4f(offset, offset, offset, offset));
}

/**
 * Returns a ccColor4F structure whose values are those of the specified original color,
 * multiplied by the specified scaling factor.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FUniformScale(ccColor4F rgba, GLfloat scale) {
	return ccc4f(CLAMP(rgba.r * scale, 0.0f, 1.0f),
				 CLAMP(rgba.g * scale, 0.0f, 1.0f),
				 CLAMP(rgba.b * scale, 0.0f, 1.0f),
				 CLAMP(rgba.a * scale, 0.0f, 1.0f));
}

/**
 * Returns the result of modulating the specified colors, by multiplying the corresponding
 * components. Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FModulate(ccColor4F rgba, ccColor4F modulation) {
	return ccc4f(CLAMP(rgba.r * modulation.r, 0.0f, 1.0f),
				 CLAMP(rgba.g * modulation.g, 0.0f, 1.0f),
				 CLAMP(rgba.b * modulation.b, 0.0f, 1.0f),
				 CLAMP(rgba.a * modulation.a, 0.0f, 1.0f));
}

/**
 * Returns a ccColor4F structure whose values are a weighted average of the specified base color and
 * the blend color. The parameter blendWeight should be between zero and one. A value of zero will leave
 * the base color unchanged. A value of one will result in the blend being the same as the blend color.
 */
static inline ccColor4F CCC4FBlend(ccColor4F baseColor, ccColor4F blendColor, GLfloat blendWeight) {
	return ccc4f(CC3WeightedAverage(baseColor.r, blendColor.r, blendWeight),
				 CC3WeightedAverage(baseColor.g, blendColor.g, blendWeight),
				 CC3WeightedAverage(baseColor.b, blendColor.b, blendWeight),
				 CC3WeightedAverage(baseColor.a, blendColor.a, blendWeight));
}

/**
 * Returns a ccColor4F color whose R, G & B components are those of the specified color multiplied
 * by the alpha value of the specified color, clamping to the range between zero and one if needed.
 * The alpha value remains unchanged.
 * 
 * This function performs the same operation on the specified color that is known as pre-multiplied
 * alpha when applied to the texels of a texture.
 */
static inline ccColor4F CCC4FBlendAlpha(ccColor4F rgba) {
	return ccc4f(CLAMP(rgba.r * rgba.a, 0.0f, 1.0f),
				 CLAMP(rgba.g * rgba.a, 0.0f, 1.0f),
				 CLAMP(rgba.b * rgba.a, 0.0f, 1.0f),
				 rgba.a);
}

/**
 * Returns a random ccColor4F where each component value between the specified min inclusive and
 * the specified max exclusive. This can be useful when creating particle systems.
 */
static inline ccColor4F RandomCCC4FBetween(ccColor4F min, ccColor4F max) {
	return ccc4f(CC3RandomFloatBetween(min.r, max.r),
				 CC3RandomFloatBetween(min.g, max.g),
				 CC3RandomFloatBetween(min.b, max.b),
				 CC3RandomFloatBetween(min.a, max.a));
}


#pragma mark -
#pragma mark ccColor4B constants and functions

/** Returns a string description of the specified ccColor4B in the form "(r, g, b, a)" */
static inline NSString* NSStringFromCCC4B(ccColor4B rgba) {
	return [NSString stringWithFormat: @"(%i, %i, %i, %i)", rgba.r, rgba.g, rgba.b, rgba.a];
}

/** Returns whether the two colors are equal by comparing their respective components. */
static inline BOOL CCC4BAreEqual(ccColor4B c1, ccColor4B c2) {
	return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a;
}

/** Returns a ccColor4B structure constructed from the specified ccColor4F */
static inline ccColor4B CCC4BFromCCC4F(ccColor4F floatColor) {
	return ccc4(CCColorByteFromFloat(floatColor.r),
				CCColorByteFromFloat(floatColor.g),
				CCColorByteFromFloat(floatColor.b),
				CCColorByteFromFloat(floatColor.a));
}

/**
 * Returns a ccColor4B color whose R, G & B components are those of the specified color multiplied
 * by the alpha value of the specified color, clamping to the range between zero and 255 if needed.
 * The alpha value remains unchanged.
 * 
 * This function performs the same operation on the specified color that is known as pre-multiplied
 * alpha when applied to the texels of a texture.
 */
static inline ccColor4B CCC4BBlendAlpha(ccColor4B rgba) {
	GLfloat alpha = rgba.a * kCC3OneOver255;
	return ccc4(CLAMP(rgba.r * alpha, 0, 255),
				CLAMP(rgba.g * alpha, 0, 255),
				CLAMP(rgba.b * alpha, 0, 255),
				rgba.a);
}


#pragma mark -
#pragma mark ccColor3B constants and functions

/** Returns a string description of the specified ccColor3B in the form "(r, g, b)" */
static inline NSString* NSStringFromCCC3B(ccColor3B rgb) {
	return [NSString stringWithFormat: @"(%i, %i, %i)", rgb.r, rgb.g, rgb.b];
}

/** Returns whether the two colors are equal by comparing their respective components. */
static inline BOOL CCC3BAreEqual(ccColor3B c1, ccColor3B c2) {
	return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b;
}

/** Returns a ccColor3B structure constructed from the specified ccColor4F */
static inline ccColor3B CCC3BFromCCC4F(ccColor4F floatColor) {
	return ccc3(CCColorByteFromFloat(floatColor.r),
				CCColorByteFromFloat(floatColor.g),
				CCColorByteFromFloat(floatColor.b));
}

/** Returns a ccColor3B structure constructed from the specified ccColor4B */
static inline ccColor3B CCC3BFromCCC4B(ccColor4B color) { return *(ccColor3B*)&color; }

/**
 * Returns an ccColor3B structure whose values are a weighted average of the specified base color and
 * the blend color. The parameter blendWeight should be between zero and one. A value of zero will leave
 * the base color unchanged. A value of one will result in the blend being the same as the blend color.
 */
static inline ccColor3B CCC3BBlend(ccColor3B baseColor, ccColor3B blendColor, GLfloat blendWeight) {
	return ccc3(CC3WeightedAverage(baseColor.r, blendColor.r, blendWeight),
				CC3WeightedAverage(baseColor.g, blendColor.g, blendWeight),
				CC3WeightedAverage(baseColor.b, blendColor.b, blendWeight));
}


#pragma mark -
#pragma mark Miscellaneous extensions and functionality

/** 
 * Returns whether the two boolean values are in equal state.
 *
 * This test will work if the two booleans each contain different non-zero content to indicate
 * logical YES, whereas a simple == comparison would give an erroneous result in that situation.
 */
static inline BOOL CC3BooleansAreEqual(BOOL b1, BOOL b2) { return (b1 && b2) || (!b1 && !b2); }

/** Returns the string YES or NO, depending on the specified boolean value. */
static inline NSString* NSStringFromBoolean(BOOL value) { return value ? @"YES" : @"NO"; }

/** 
 * Ensures that the specified file path is absolute, converting it if necessary.
 * 
 * Relative paths are assumed to be relative to the application resources directory.
 * If the specified file path is not already absolute, the path to that directory is prepended to it.
 */
static inline NSString* CC3EnsureAbsoluteFilePath(NSString* filePath) {
	if(filePath.isAbsolutePath) return filePath;
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: filePath];
}

/** Returns whether the specified bit in the specified bitfield is set to one. */
static inline BOOL CC3IsBitSet(GLbitfield bits, GLuint bitIdx) {
	CC3AssertC(bitIdx < (8 * sizeof(bits)), @"Bit index %u is too large for the bitfield.", bitIdx);
	GLbitfield marker = 1;
	marker <<= bitIdx;
	return (bits & marker) ? YES : NO;
}

/** Returns whether the specified bit in the specified bitfield is set to zero. */
static inline BOOL CC3IsBitClear(GLbitfield bits, GLuint bitIdx) { return !CC3IsBitSet(bits, bitIdx); }

/** 
 * Sets the specified bit in the specified bitfield is to one if the specified value is YES,
 * or to zero if the specified value is NO.
 */
static inline void CC3SetBit(GLbitfield* bits, GLuint bitIdx, BOOL val) {
	CC3AssertC(bitIdx < (8 * sizeof(*bits)), @"Bit index %u is too large for the bitfield.", bitIdx);
	GLbitfield marker = 1;
	marker <<= bitIdx;
	if (val)
		*bits |= marker;
	else
		*bits &= ~marker;
}

/**
 * Reverses the order of the rows in the specified data block.
 * The transformation is performed in-place.
 *
 * This function can be useful for vertically flipping the contents of a texture or image,
 * which is a common requirement when transferring content data between an OpenGL texture
 * and an iOS or OSX image. Or it may be used to reverse the order of the rows of any
 * row-major memory structure.
 *
 * The specified data block is assumed to be in row-major order, containing the specified
 * number of rows, and with the specified number of bytes in each row. The total number of
 * bytes in the data block must be at least (bytesPerRow * rowCount).
 */
void CC3FlipVertically(GLubyte* rowMajorData, GLuint rowCount, GLuint bytesPerRow);

/** Temporarily turn off compiler warnings for hidden variable shadowing. */
#define CC3_PUSH_NOSHADOW	_Pragma("GCC diagnostic push") _Pragma("GCC diagnostic ignored \"-Wshadow\"")

/** Resume compiler warnings for hidden variable shadowing. */
#define CC3_POP_NOSHADOW	_Pragma("GCC diagnostic pop")

/** Temporarily turn off compiler warnings of unimplemented selectors. */
#define CC3_PUSH_NOSELECTOR	_Pragma("GCC diagnostic push") _Pragma("GCC diagnostic ignored \"-Wselector\"")

/** Resume compiler warnings of unimplemented selectors. */
#define CC3_POP_NOSELECTOR	_Pragma("GCC diagnostic pop")

