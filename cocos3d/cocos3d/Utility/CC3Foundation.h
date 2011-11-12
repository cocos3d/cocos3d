/*
 * CC3Foundation.h
 *
 * cocos3d 0.6.3
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
 */

/** @file */	// Doxygen marker

/** @mainpage cocos3d API reference
 *
 * @section intro About cocos3d
 *
 * Cocos3d extends cocos2d to add support for full 3D rendering, in combination with
 * normal cocos2d 2D rendering.
 *
 * Rendering of 3D objects is performed within a CC3Layer, which is a specialized cocos2d
 * layer. In your application, you will usually create a customized subclass of CC3Layer,
 * which you add to a CCScene, or other CCLayer, to act as a bridge between the 2D and
 * 3D rendering.
 *
 * The CC3Layer instance holds a reference to an instance of CC3World, which manages the
 * 3D model objects, including loading from 3D model files, such as PowerVR POD files.
 * You will usually create a customized subclass of CC3World to create and manage the
 * objects and dynamics of your 3D world.
 */

/* Base library of definitions and functions for operating in a 3D world. */

#import "CCArray.h"
#import "CC3Math.h"
#import "CC3Logging.h"
#import "CCNode.h"
#import "CCDirector.h"
#import <AvailabilityMacros.h>


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

/** A CC3Vector with each component equal to one, representing the diagonal of a unit cube. */
static const CC3Vector kCC3VectorUnitCube = { 1.0, 1.0, 1.0 };

/** The diagonal length of a unit cube. */
static const GLfloat kCC3VectorUnitCubeLength = M_SQRT3;

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
	return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z;
}

/**
 * Returns a vector whose components comprise the minimum value of each of the respective
 * components of the two specfied vectors. In general, do not expect this method to return
 * one of the specified vectors, but a new vector, each of the components of which is the
 * minimum value for that component between the two vectors.
 */
static inline CC3Vector CC3VectorMinimize(CC3Vector v1, CC3Vector v2) {
	CC3Vector vMin;
	vMin.x = MIN(v1.x, v2.x);
	vMin.y = MIN(v1.y, v2.y);
	vMin.z = MIN(v1.z, v2.z);
	return vMin;
}

/**
 * Returns a vector whose components comprise the maximum value of each of the respective
 * components of the two specfied vectors. In general, do not expect this method to return
 * one of the specified vectors, but a new vector, each of the components of which is the
 * maximum value for that component between the two vectors.
 */
static inline CC3Vector CC3VectorMaximize(CC3Vector v1, CC3Vector v2) {
	CC3Vector vMax;
	vMax.x = MAX(v1.x, v2.x);
	vMax.y = MAX(v1.y, v2.y);
	vMax.z = MAX(v1.z, v2.z);
	return vMax;
}

/**
 * Returns the square of the scalar length of the specified CC3Vector from the origin.
 * This is calculated as (x*x + y*y + z*z) and will always be positive.
 *
 * This function is useful for comparing vector sizes without having to run an
 * expensive square-root calculation.
 */
static inline GLfloat CC3VectorLengthSquared(CC3Vector v) {
	GLfloat x = v.x;
	GLfloat y = v.y;
	GLfloat z = v.z;
	return (x * x) + (y * y) + (z * z);
}

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
	
	GLfloat len = sqrtf(lenSq);
	CC3Vector normal;
	normal.x = v.x / len;
	normal.y = v.y / len;
	normal.z = v.z / len;
	return normal;
}

/**
 * Returns a vector that is the negative of the specified vector in all directions.
 * For vectors that represent directions, the returned vector points in the direction
 * opposite to the original.
 */
static inline CC3Vector CC3VectorNegate(CC3Vector v) {
	CC3Vector result;
	result.x = -v.x;
	result.y = -v.y;
	result.z = -v.z;
	return result;
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
	CC3Vector result;
	result.x = 1.0 / v.x;
	result.y = 1.0 / v.y;
	result.z = 1.0 / v.z;
	return result;
}

/**
 * Returns the result of adding the two specified vectors, by adding the corresponding components 
 * of both vectors. This can also be thought of as a translation of the first vector by the second.
 */
static inline CC3Vector CC3VectorAdd(CC3Vector v, CC3Vector translation) {
	CC3Vector result;
	result.x = v.x + translation.x;
	result.y = v.y + translation.y;
	result.z = v.z + translation.z;
	return result;
}

/**
 * Returns the difference between two vectors, by subtracting the subtrahend from the minuend,
 * which is accomplished by subtracting each of the corresponding x,y,z components.
 */
static inline CC3Vector CC3VectorDifference(CC3Vector minuend, CC3Vector subtrahend) {
	CC3Vector difference;
	difference.x = minuend.x - subtrahend.x;
	difference.y = minuend.y - subtrahend.y;
	difference.z = minuend.z - subtrahend.z;
	return difference;
}

/**
 * Returns a modulo version of the specifed rotation,
 * so that each component is between (+/-360 degrees).
 */
static inline CC3Vector CC3VectorRotationModulo(CC3Vector aRotation) {
	CC3Vector modRot;
	modRot.x = CC3CyclicAngle(aRotation.x);
	modRot.y = CC3CyclicAngle(aRotation.y);
	modRot.z = CC3CyclicAngle(aRotation.z);
	return modRot;
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
	CC3Vector difference;
	difference.x = CC3SemiCyclicAngle(minuend.x - subtrahend.x);
	difference.y = CC3SemiCyclicAngle(minuend.y - subtrahend.y);
	difference.z = CC3SemiCyclicAngle(minuend.z - subtrahend.z);
	return difference;
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
 * Returns the result of scaling the original vector by the corresponding scale vector.
 * Scaling can be different for each axis. This has the effect of multiplying each component
 * of the vector by the corresponding component in the scale vector.
 */
static inline CC3Vector CC3VectorScale(CC3Vector v, CC3Vector scale) {
	CC3Vector result;
	result.x = v.x * scale.x;
	result.y = v.y * scale.y;
	result.z = v.z * scale.z;
	return result;
}

/**
 * Returns the result of scaling the original vector by the corresponding scale
 * factor uniformly along all axes.
 */
static inline CC3Vector CC3VectorScaleUniform(CC3Vector v, GLfloat scale) {
	CC3Vector result;
	result.x = v.x * scale;
	result.y = v.y * scale;
	result.z = v.z * scale;
	return result;
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

/** Returns the dot-product of the two given vectors (v1 . v2). */
static inline GLfloat CC3VectorDot(CC3Vector v1, CC3Vector v2) {
	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}

/** Returns the cross-product of the two given vectors (v1 x v2). */
static inline CC3Vector CC3VectorCross(CC3Vector v1, CC3Vector v2) {
	CC3Vector result;
    result.x = v1.y * v2.z - v1.z * v2.y;
    result.y = v1.z * v2.x - v1.x * v2.z;
    result.z = v1.x * v2.y - v1.y * v2.x;
	return result;
}

/**
 * Returns a linear interpolation between two vectors, based on the blendFactor.
 * which should be between zero and one inclusive. The returned value is calculated
 * as v1 + (blendFactor * (v2 - v1)). If the blendFactor is either zero or one
 * exactly, this method short-circuits to simply return v1 or v2 respectively.
 */
static inline CC3Vector CC3VectorLerp(CC3Vector v1, CC3Vector v2, GLfloat blendFactor) {
	// Short-circuit if we know it's one of the end-points.
	if (blendFactor == 0.0f) {
		return v1;
	} else if (blendFactor == 1.0f) {
		return v2;
	}
	// Return: v1 + (blendFactor * (v2 - v1))
	return CC3VectorAdd(v1, CC3VectorScaleUniform(CC3VectorDifference(v2, v1), blendFactor));
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
	CC3Vector direction;			/**< The direction in which the ray points. */
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

/**
 * Defines a simple vertex, containing location, normal, and texture coordinate
 * data. Useful for interleaving vertex data for presentation to the GL engine.
 */
typedef struct {
	CC3Vector location;			/**< The 3D location of the vertex. */
	CC3Vector normal;			/**< The 3D normal at the vertex. */
	ccTex2F texCoord;			/**< The 2D coordinate of this vertex on the texture. */
} CC3TexturedVertex;

typedef CC3TexturedVertex CCTexturedVertex;		//** Deprecated misspelling of CC3TexturedVertex. */


#pragma mark -
#pragma mark Bounding box structure and functions

/**
 * Defines an axially-aligned-bounding-box (AABB), describing
 * a 3D volume by specifying the minimum and maximum 3D corners.
 */
typedef struct {
	CC3Vector minimum;			/**< The minimum corner (bottom-left-rear). */
	CC3Vector maximum;			/**< The maximum corner (top-right-front). */
} CC3BoundingBox;

/** A CC3BoundingBox of zero origin and dimensions. */
static const CC3BoundingBox kCC3BoundingBoxZero = { {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0} };

/** The null bounding box. It cannot be drawn, but is useful for marking an uninitialized bounding box. */
static const CC3BoundingBox kCC3BoundingBoxNull = { {INFINITY, INFINITY, INFINITY}, {INFINITY, INFINITY, INFINITY} };

/** Returns a string description of the specified CC3BoundingBox struct. */
static inline NSString* NSStringFromCC3BoundingBox(CC3BoundingBox bb) {
	return [NSString stringWithFormat: @"(Min: %@, Max: %@)",
			NSStringFromCC3Vector(bb.minimum), NSStringFromCC3Vector(bb.maximum)];
}

/** Returns a CC3BoundingBox structure constructed from the min and max vertices. */
static inline CC3BoundingBox CC3BoundingBoxFromMinMax(CC3Vector minVtx, CC3Vector maxVtx) {
	CC3BoundingBox bb;
	bb.minimum = minVtx;
	bb.maximum = maxVtx;
	return bb;
}

/** Returns a CC3BoundingBox structure constructed from the min and max components. */
static inline CC3BoundingBox CC3BoundingBoxMake(GLfloat minX, GLfloat minY, GLfloat minZ,
												GLfloat maxX, GLfloat maxY, GLfloat maxZ) {
	return CC3BoundingBoxFromMinMax(CC3VectorMake(minX, minY, minZ),
									CC3VectorMake(maxX, maxY, maxZ));
}

/** Returns whether the two bounding boxes are equal by comparing their respective components. */
static inline BOOL CC3BoundingBoxesAreEqual(CC3BoundingBox bb1, CC3BoundingBox bb2) {
	return CC3VectorsAreEqual(bb1.minimum, bb2.minimum)
		&& CC3VectorsAreEqual(bb1.maximum, bb2.maximum);
}

/**
 * Returns whether the specified bounding box is equal to
 * the null bounding box, specified by kCC3BoundingBoxNull.
 */
static inline BOOL CC3BoundingBoxIsNull(CC3BoundingBox bb) {
	return CC3BoundingBoxesAreEqual(bb, kCC3BoundingBoxNull);
}

/** Returns the geometric center of the specified bounding box. */
static inline CC3Vector CC3BoundingBoxCenter(CC3BoundingBox bb) {
	return CC3VectorAverage(bb.minimum, bb.maximum);
}

/**
 * Returns the smallest CC3BoundingBox that contains both the specified bounding box
 * and location. If the specified bounding box is null, returns a bounding box of zero
 * size at the specified location.
 */
CC3BoundingBox CC3BoundingBoxEngulfLocation(CC3BoundingBox bb, CC3Vector aLoc);

/**
 * Returns the smallest CC3BoundingBox that contains the two specified bounding boxes.
 * If either bounding box is the null bounding box, simply returns the other bounding box
 * (which may also be the null bounding box).
 */
CC3BoundingBox CC3BoundingBoxUnion(CC3BoundingBox bb1, CC3BoundingBox bb2);

/**
 * Returns a bounding box that has the same dimensions as the specified bounding
 * box, but with each corner expanded outward by the specified amount of padding.
 *
 * The padding value is added to all three components of the maximum vector,
 * and subtracted from all three components of the minimum vector.
 */
CC3BoundingBox CC3BoundingBoxAddPadding(CC3BoundingBox bb, GLfloat padding);


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

/** Returns the smallest CC3Sphere that contains the two specified spheres. */
CC3Sphere CC3SphereUnion(CC3Sphere s1, CC3Sphere s2);


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
	av.inclination = av.radius ? RadiansToDegrees(asinf(aCoord.y / av.radius)) : 0.0;	
	av.heading = RadiansToDegrees(atan2f(aCoord.x, -aCoord.z));
	return av;
}

/**
 * Returns a CC3Vector from the specified CC3AngularVector.
 * Heading is measured in degrees, in the X-Z plane, clockwise from the negative Z-axis.
 * Inclination is measured in degrees, with up being in the positive-Y direction.
 */
CC3Vector CC3VectorFromAngularVector(CC3AngularVector av);

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
#pragma mark Cartesian vector in 4D homogeneous coordinate space structure and functions

/** A homogeneous vector in 4D graphics matrix space. */
typedef struct {
	GLfloat x;			/**< The X-componenent of the vector. */
	GLfloat y;			/**< The Y-componenent of the vector. */
	GLfloat z;			/**< The Z-componenent of the vector. */
	GLfloat w;			/**< The homogeneous ratio factor. */
} CC3Vector4;

/** A CC3Vector4 of zero length at the origin. */
static const CC3Vector4 kCC3Vector4Zero = { 0.0, 0.0, 0.0, 0.0 };

/** A CC3Vector4 that represents the identity quaternion. */
static const CC3Vector4 kCC3Vector4QuaternionIdentity = { 0.0, 0.0, 0.0, 1.0 };

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
	v4.x = v.x;
	v4.y = v.y;
	v4.z = v.z;
	v4.w = w;
	return v4;
}

/**
 * Returns a CC3Vector structure constructed from a CC3Vector4,
 * by simply ignoring the w component of the 4D vector.
 */
static inline CC3Vector CC3VectorFromTruncatedCC3Vector4(CC3Vector4 v) {
	CC3Vector v3;
	v3.x = v.x;
	v3.y = v.y;
	v3.z = v.z;
	return v3;
}

/**
 * If the specified homogeneous vector represents a location (w is not zero), returns
 * a homoginized copy of the vector, by dividing each component by the w-component
 * (including the w-component itself, leaving it with a value of one). If the specified
 * vector is a direction (w is zero), or is already homogenized (w is one) the vector
 * is returned unchanged.
 */
static inline CC3Vector4 CC3Vector4Homogenize(CC3Vector4 v) {
	if (v.w == 0.0f || v.w == 1.0f) {
		return v;
	}
	CC3Vector4 hv;
	hv.x = v.x / v.w;
	hv.y = v.y / v.w;
	hv.z = v.z / v.w;
	hv.w = 1.0f;
	return hv;
}

/**
 * Returns a CC3Vector structure constructed from a CC3Vector4. The CC3Vector4 is first
 * homogenized (via CC3Vector4Homogenize), before copying the resulting x, y & z
 * coordinates into the CC3Vector.
 */
static inline CC3Vector CC3VectorFromHomogenizedCC3Vector4(CC3Vector4 v) {
	return CC3VectorFromTruncatedCC3Vector4(CC3Vector4Homogenize(v));
}

/** Returns whether the two vectors are equal by comparing their respective components. */
static inline BOOL CC3Vector4sAreEqual(CC3Vector4 v1, CC3Vector4 v2) {
	return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z && v1.w == v2.w;
}

/**
 * Returns the scalar length of the specified vector from the origin, including the w-component
 * This is calculated as sqrt(x*x + y*y + z*z + w*w) and will always be positive.
 */
static inline GLfloat CC3Vector4Length(CC3Vector4 v) {
	GLfloat x = v.x;
	GLfloat y = v.y;
	GLfloat z = v.z;
	GLfloat w = v.w;
	return sqrtf((x * x) + (y * y) + (z * z) + (w * w));
}

/** Returns a normalized copy of the specified vector so that its length is 1.0. The w-component is also normalized. */
static inline CC3Vector4 CC3Vector4Normalize(CC3Vector4 v) {
	GLfloat mag = CC3Vector4Length(v);
	CC3Vector4 normal;
	normal.x = v.x / mag;
	normal.y = v.y / mag;
	normal.z = v.z / mag;
	normal.w = v.w / mag;
	return normal;
}

/** Returns a vector that is the negative of the specified vector in all directions. */
static inline CC3Vector4 CC3Vector4Negate(CC3Vector4 v) {
	CC3Vector4 result;
	result.x = -v.x;
	result.y = -v.y;
	result.z = -v.z;
	result.w = -v.w;
	return result;
}

/** Returns the result of scaling the original vector by the corresponding scale factor uniformly along all axes. */
static inline CC3Vector4 CC3Vector4ScaleUniform(CC3Vector4 v, GLfloat scale) {
	CC3Vector4 result;
	result.x = v.x * scale;
	result.y = v.y * scale;
	result.z = v.z * scale;
	result.w = v.w * scale;
	return result;
}

/**
 * Returns the result of adding the two specified vectors, by adding the corresponding components 
 * of both vectors. This can also be thought of as a translation of the first vector by the second.
 */
static inline CC3Vector4 CC3Vector4Add(CC3Vector4 v, CC3Vector4 translation) {
	CC3Vector4 result;
	result.x = v.x + translation.x;
	result.y = v.y + translation.y;
	result.z = v.z + translation.z;
	result.w = v.w + translation.w;
	return result;
}

/** Returns the dot-product of the two given vectors (v1 . v2). */
static inline GLfloat CC3Vector4Dot(CC3Vector4 v1, CC3Vector4 v2) {
	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z) + (v1.w * v2.w);
}

/**
 * Converts the specified vector that represents an rotation in axis-angle form
 * to the corresponding quaternion. The X, Y & Z components of the incoming vector
 * contain the rotation axis, and the W component specifies the angle, in degrees.
 */
CC3Vector4 CC3QuaternionFromAxisAngle(CC3Vector4 axisAngle);

/**
 * Converts the specified quaternion to a vector that represents a rotation in
 * axis-angle form. The X, Y & Z components of the returned vector contain the
 * rotation axis, and the W component specifies the angle, in degrees.
 */
CC3Vector4 CC3AxisAngleFromQuaternion(CC3Vector4 quaternion);

/**
 * Returns a spherical linear interpolation between two vectors, based on the blendFactor.
 * which should be between zero and one inclusive. The returned value is calculated
 * as v1 + (blendFactor * (v2 - v1)). If the blendFactor is either zero or one
 * exactly, this method short-circuits to simply return v1 or v2 respectively.
 */
CC3Vector4 CC3Vector4Slerp(CC3Vector4 v1, CC3Vector4 v2, GLfloat blendFactor);


#pragma mark -
#pragma mark Plane and frustum structures and functions

/** The coefficients of the equation for a plane in 3D space (ax + by + cz + d = 0). */
typedef struct {
	GLfloat a;				/**< The a coefficient in the planar equation. */
	GLfloat b;				/**< The b coefficient in the planar equation. */
	GLfloat c;				/**< The c coefficient in the planar equation. */
	GLfloat d;				/**< The d coefficient in the planar equation. */
} CC3Plane;

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
	return cc3v(p.a, p.b, p.c);
}

/**
 * Returns a CC3Plane structure that contains the specified points.
 * 
 * The direction of the normal of the returned plane is dependent on the winding order
 * of the three points. Winding is done in the order the points are specified
 * (p1 -> p2 -> p3), and the normal will point in the direction that has the three points
 * winding in a counter-clockwise direction, according to a right-handed coordinate
 * system. If the direction of the normal is important, be sure to specify the three
 * points in the appropriate order.
 */
static inline CC3Plane CC3PlaneFromPoints(CC3Vector p1, CC3Vector p2, CC3Vector p3) {
	CC3Vector v12 = CC3VectorDifference(p2, p1);
	CC3Vector v23 = CC3VectorDifference(p3, p2);
	CC3Vector n = CC3VectorNormalize(CC3VectorCross(v12, v23));
	GLfloat d = -CC3VectorDot(p1, n);
	return CC3PlaneMake(n.x, n.y, n.z, d);
}

/** Returns a normalized copy of the specified CC3Plane so that the length of its normal (a, b, c) is 1.0 */
static inline CC3Plane CC3PlaneNormalize(CC3Plane p) {
	GLfloat normLen = CC3VectorLength(CC3PlaneNormal(p));
	CC3Plane np;
	np.a = p.a / normLen;
	np.b = p.b / normLen;
	np.c = p.c / normLen;
	np.d = p.d / normLen;
	return np;
}

/** Returns the distance from the point represented by the vector to the specified normalized plane. */
static inline GLfloat CC3DistanceFromNormalizedPlane(CC3Plane p, CC3Vector v) {
	return (p.a * v.x) + (p.b * v.y) + (p.c * v.z) + p.d;
}

/**
 * Returns the location of the point where the specified ray intersects the specified plane.
 *
 * The returned result is a 4D vector, where the x, y & z components give the intersection
 * location in 3D space, and the w component gives the distance from the startLocation of
 * the ray to the intersection location, in multiples of the ray direction vector. If this
 * value is negative, the intersection point is in the direction opposite to the direction
 * of the ray.
 *
 * If the ray is parallel to the plane, no intersection occurs, and the returned 4D vector
 * will be zeroed (equal to kCC3Vector4Zero).
 */
CC3Vector4 CC3RayIntersectionWithPlane(CC3Ray ray, CC3Plane plane);


#pragma mark -
#pragma mark Attenuation function structures

/**
 * The coefficients of the equation for an attenuation function: (a + b*r + c*r*r),
 * where r is the radial distance between a the source (light or camera) and the 3D
 * location at which we want to calculate attenuation.
 */
typedef struct {
	GLfloat a;				/**< The a coefficient in the attenuation function. */
	GLfloat b;				/**< The b coefficient in the attenuation function. */
	GLfloat c;				/**< The c coefficient in the attenuation function. */
} CC3AttenuationCoefficients;

/** Point size attenuation coefficients corresponding to no attenuation with distance (constant size). */
static const CC3AttenuationCoefficients kCC3ParticleSizeAttenuationNone = {1.0, 0.0, 0.0};

/**
 * Returns a string description of the specified CC3AttenuationCoefficients struct
 * in the form "(a, b, c)".
 */
static inline NSString* NSStringFromCC3AttenuationCoefficients(CC3AttenuationCoefficients coeffs) {
	return [NSString stringWithFormat: @"(%.3f, %.6f, %.9f)", coeffs.a, coeffs.b, coeffs.c];
}

/** Returns a CC3AttenuationCoefficients structure constructed from the specified coefficients. */
static inline CC3AttenuationCoefficients CC3AttenuationCoefficientsMake(GLfloat a, GLfloat b, GLfloat c) {
	CC3AttenuationCoefficients coeffs;
	coeffs.a = a;
	coeffs.b = b;
	coeffs.c = c;
	return coeffs;
}


#pragma mark -
#pragma mark Viewport structure and functions

/** GL viewport data */
typedef struct {
	GLint x;				/**< The X-position of the bottom-left corner of the viewport. */
	GLint y;				/**< The Y-position of the bottom-left corner of the viewport. */
	GLsizei w;				/**< The width of the viewport. */
	GLsizei h;				/**< The height of the viewport. */
} CC3Viewport;

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

/** Returns whether the two viewports are equal by comparing their respective components. */
static inline BOOL CC3ViewportsAreEqual(CC3Viewport vp1, CC3Viewport vp2) {
	return vp1.x == vp2.x && vp1.y == vp2.y && vp1.w == vp2.w && vp1.h == vp2.h;
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

/** Returns the dimensions of the specified viewport as a rectangle. */
static inline CGRect CGRectFromCC3Viewport(CC3Viewport vp) {
	return CGRectMake(vp.x, vp.y, vp.w, vp.h);
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

/** Opaque Light Gray */
static const ccColor4F kCCC4FLightGray = { (2.0 / 3.0), (2.0 / 3.0), (2.0 / 3.0), 1.0 };

/** Opaque Dark Gray */
static const ccColor4F kCCC4FDarkGray = { (1.0 / 3.0), (1.0 / 3.0), (1.0 / 3.0), 1.0 };

/** Opaque White */
static const ccColor4F kCCC4FWhite = { 1.0, 1.0, 1.0, 1.0 };

/** Opaque Black */
static const ccColor4F kCCC4FBlack = { 0.0, 0.0, 0.0, 1.0 };

/** Transparent Black */
static const ccColor4F kCCC4FBlackTransparent = {0.0, 0.0, 0.0, 0.0};

/** Returns a GLfloat between 0 and 1 converted from the specified GLubyte value between 0 and 255. */
static inline GLfloat CCColorFloatFromByte(GLubyte colorValue) {
	return (GLfloat)(colorValue * (1.0 / 255.0f));
}

/** Returns a GLubyte between 0 and 255 converted from the specified GLfloat value between 0 and 1. */
static inline GLubyte CCColorByteFromFloat(GLfloat colorValue) {
	return (GLubyte)(colorValue * 255.0f);
}

/** Returns a string description of the specified ccColor4F in the form "(r, g, b, a)" */
static inline NSString* NSStringFromCCC4F(ccColor4F rgba) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", rgba.r, rgba.g, rgba.b, rgba.a];
}

/** Convenience alias macro to create ccColor4F with less keystrokes. */
#define ccc4f(R,G,B,A) CCC4FMake((R),(G),(B),(A))

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
	ccColor4F color;
	color.r = CCColorFloatFromByte(byteColor.r);
	color.g = CCColorFloatFromByte(byteColor.g);
	color.b = CCColorFloatFromByte(byteColor.b);
	color.a = CCColorFloatFromByte(byteColor.a);
	return color;
}

/** Returns a ccColor4B structure constructed from the specified ccColor4F */
static inline ccColor4B CCC4BFromCCC4F(ccColor4F floatColor) {
	ccColor4B color;
	color.r = CCColorByteFromFloat(floatColor.r);
	color.g = CCColorByteFromFloat(floatColor.g);
	color.b = CCColorByteFromFloat(floatColor.b);
	color.a = CCColorByteFromFloat(floatColor.a);
	return color;
}

/** Returns a ccColor4F structure constructed from the specified ccColor3B and opacity. */
static inline ccColor4F CCC4FFromColorAndOpacity(ccColor3B byteColor, GLubyte opacity) {
	ccColor4F color;
	color.r = CCColorFloatFromByte(byteColor.r);
	color.g = CCColorFloatFromByte(byteColor.g);
	color.b = CCColorFloatFromByte(byteColor.b);
	color.a = CCColorFloatFromByte(opacity);
	return color;
}

/** Returns a ccColor3B structure constructed from the specified ccColor4F */
static inline ccColor3B CCC3BFromCCC4F(ccColor4F floatColor) {
	ccColor3B color;
	color.r = CCColorByteFromFloat(floatColor.r);
	color.g = CCColorByteFromFloat(floatColor.g);
	color.b = CCColorByteFromFloat(floatColor.b);
	return color;
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
	ccColor4F result;
	result.r = CLAMP(rgba.r + translation.r, 0.0, 1.0);
	result.g = CLAMP(rgba.g + translation.g, 0.0, 1.0);
	result.b = CLAMP(rgba.b + translation.b, 0.0, 1.0);
	result.a = CLAMP(rgba.a + translation.a, 0.0, 1.0);
	return result;
}

/**
 * Returns the difference between two colors, by subtracting the subtrahend from the minuend,
 * which is accomplished by subtracting each of the corresponding r,g, b, a components.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FDifference(ccColor4F minuend, ccColor4F subtrahend) {
	ccColor4F result;
	result.r = CLAMP(minuend.r - subtrahend.r, 0.0, 1.0);
	result.g = CLAMP(minuend.g - subtrahend.g, 0.0, 1.0);
	result.b = CLAMP(minuend.b - subtrahend.b, 0.0, 1.0);
	result.a = CLAMP(minuend.a - subtrahend.a, 0.0, 1.0);
	return result;
}

/**
 * Returns a ccColor4F structure whose values are those of the specified original color,
 * where each color component has been translated by the specified offset.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FUniformTranslate(ccColor4F rgba, GLfloat offset) {
	return CCC4FAdd(rgba, CCC4FMake(offset, offset, offset, offset));
}

/**
 * Returns a ccColor4F structure whose values are those of the specified original color,
 * multiplied by the specified scaling factor.
 * Each of the resulting color components is clamped to be between 0.0 and 1.0.
 */
static inline ccColor4F CCC4FUniformScale(ccColor4F rgba, GLfloat scale) {
	ccColor4F result;
	result.r = CLAMP(rgba.r * scale, 0.0, 1.0);
	result.g = CLAMP(rgba.g * scale, 0.0, 1.0);
	result.b = CLAMP(rgba.b * scale, 0.0, 1.0);
	result.a = CLAMP(rgba.a * scale, 0.0, 1.0);
	return result;
}

/**
 * Returns an ccColor4F structure whose values are a weighted average of the specified base color
 * and the blend color. The parameter blendWeight should be between zero and one. A value of zero
 * will leave the base color unchanged. A value of one will result in the blend being the same as
 * the blend color.
 */
static inline ccColor4F CCC4FBlend(ccColor4F baseColor, ccColor4F blendColor, GLfloat blendWeight) {
	return CCC4FMake(WAVG(baseColor.r, blendColor.r, blendWeight),
					 WAVG(baseColor.g, blendColor.g, blendWeight),
					 WAVG(baseColor.b, blendColor.b, blendWeight),
					 WAVG(baseColor.a, blendColor.a, blendWeight));
}

/**
 * Returns a random ccColor4F where each component value between the specified min inclusive and
 * the specified max exclusive. This can be useful when creating particle systems.
 */
static inline ccColor4F RandomCCC4FBetween(ccColor4F min, ccColor4F max) {
	ccColor4F result;
	result.r = CC3RandomFloatBetween(min.r, max.r);
	result.g = CC3RandomFloatBetween(min.g, max.g);
	result.b = CC3RandomFloatBetween(min.b, max.b);
	result.a = CC3RandomFloatBetween(min.a, max.a);
	return result;
}


#pragma mark -
#pragma mark Miscellaneous extensions and functionality

/** Returns the name of the specified touch type. */
NSString* NSStringFromTouchType(uint tType);

/** Returns the string YES or NO, depending on the specified boolean value. */
NSString* NSStringFromBoolean(BOOL value);

/** Extension category to support cocos3d functionality. */
@interface NSObject (CC3)

/**
 * Convenience method to automatically autorelease when copying objects.
 * Invokes the copy method to create a copy of this instance, autoreleases it, and returns it.
 */
-(id) copyAutoreleased;

@end


/** Extension category to support cocos3d functionality. */
@interface UIColor(CC3)

/** Returns a transparent ccColor4F struct containing the RGBA values for this color. */
-(ccColor4F) asCCColor4F;

/** Returns an autoreleased UIColor instance created from the RGBA values in the specified ccColor4F. */
+(UIColor*) colorWithCCColor4F: (ccColor4F) rgba;

@end


#pragma mark -
#pragma mark CCNode extension

/** Extension category to support cocos3d functionality. */
@interface CCNode (CC3)

/** Returns the bounding box of this CCNode, measured in pixels, in the global coordinate system. */
- (CGRect) globalBoundingBoxInPixels;

/**
 * Updates the viewport of any contained CC3World instances with the dimensions
 * of its CC3Layer and the device orientation.
 *
 * This CCNode implementation simply passes the notification along to its children.
 * Descendants that are CC3Layers will update their CC3World instances.
 */
-(void) updateViewport;

@end


#pragma mark -
#pragma mark CCDirector extension

/** Extension category to support cocos3d functionality. */
@interface CCDirector (CC3)

/** Returns the time interval in seconds between the current render frame and the previous frame. */
-(ccTime) frameInterval;

/** Returns the current rendering perfromance in average frames per second. */
-(ccTime) frameRate;

@end


#pragma mark -
#pragma mark CCArray extension

/**
 * Extension category to support cocos3d functionality.
 *
 * This extension includes a number of methods that add or remove objects to and from
 * the array without retaining and releasing them. These methods are identified by the
 * word Unretained in their names, and are faster than their standard equivalent methods
 * that do retain and release objects.
 *
 * It is critical that use of these methods is consistent for any object added. If an
 * object is added using an "Unretained" method, then it must be removed using an
 * "Unretained" method.
 */
@interface CCArray (CC3)

/** Returns the index of the specified object, by comparing objects using the == operator. */
-(NSUInteger) indexOfObjectIdenticalTo: (id) anObject;

/** Removes the specified object, by comparing objects using the == operator. */
-(void) removeObjectIdenticalTo: (id) anObject;

/** Replaces the object at the specified index with the specified object. */
-(void) replaceObjectAtIndex: (NSUInteger) index withObject: (id) anObject;


#pragma mark Support for unretained objects

/**
 * Adds the specified object to the end of the array, but does not retain the object.
 *
 * When removing the object, it must not be released. Use one the
 * removeUnretainedObject... methods to remove the object.
 */
- (void) addUnretainedObject: (id) anObject;

/**
 * Inserts the specified object at the specified index within the array,
 * but does not retain the object. The elements in the array after the
 * specified index position are shuffled up to make room for the new object.
 *
 * When removing the object, it must not be released. Use one the
 * removeUnretainedObject... methods to remove the object.
 */
- (void) insertUnretainedObject: (id) anObject atIndex: (NSUInteger) index;

/**
 * Removes the specified object from the array, without releasing it,
 * by comparing objects using the == operator.
 *
 * The objects after this object in the array are shuffled down to fill in the gap.
 *
 * The object being removed must not have been retained when added to the array.
 */
- (void) removeUnretainedObjectIdenticalTo: (id) anObject;

/**
 * Removes the object at the specified index, without releasing it.
 *
 * The objects after this object in the array are shuffled down to fill in the gap.
 *
 * The object being removed must not have been retained when added to the array.
 */
- (void) removeUnretainedObjectAtIndex: (NSUInteger) index;

/**
 * Removes all objects in the array, without releasing them.
 *
 * All objects being removed must not have been retained when added to the array.
 */
- (void) removeAllObjectsAsUnretained;

/**
 * Releases the array without releasing each contained object.
 *
 * All contained objects must not have been retained when added to the array.
 */
-(void) releaseAsUnretained;

/** Returns a more detailed description of this instance. */
-(NSString*) fullDescription;

@end
