/*
 * CC3Foundation.m
 *
 * cocos3d 0.6.2
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
 * See header file CC3Foundation.h for full API documentation.
 */

#import "CC3Foundation.h"
#import "CCTouchDispatcher.h"

#pragma mark -
#pragma mark 3D cartesian vector structure and functions

NSString* NSStringFromCC3Vector(CC3Vector v) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f)", v.x, v.y, v.z];
}

CC3Vector CC3VectorMake(GLfloat x, GLfloat y, GLfloat z) {
	CC3Vector v;
	v.x = x;
	v.y = y;
	v.z = z;
	return v;
}

BOOL CC3VectorsAreEqual(CC3Vector v1, CC3Vector v2) {
	return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z;
}

CC3Vector CC3VectorMinimize(CC3Vector v1, CC3Vector v2) {
	CC3Vector vMin;
	vMin.x = MIN(v1.x, v2.x);
	vMin.y = MIN(v1.y, v2.y);
	vMin.z = MIN(v1.z, v2.z);
	return vMin;
}

CC3Vector CC3VectorMaximize(CC3Vector v1, CC3Vector v2) {
	CC3Vector vMax;
	vMax.x = MAX(v1.x, v2.x);
	vMax.y = MAX(v1.y, v2.y);
	vMax.z = MAX(v1.z, v2.z);
	return vMax;
}

GLfloat CC3VectorLengthSquared(CC3Vector v) {
	GLfloat x = v.x;
	GLfloat y = v.y;
	GLfloat z = v.z;
	return (x * x) + (y * y) + (z * z);
}

// Avoid expensive sqrt calc if vector is unit length or zero
GLfloat CC3VectorLength(CC3Vector v) {
	GLfloat lenSq = CC3VectorLengthSquared(v);
	return (lenSq == 1.0f || lenSq == 0.0f) ? lenSq : sqrtf(lenSq);
}

CC3Vector CC3VectorNormalize(CC3Vector v) {
	GLfloat lenSq = CC3VectorLengthSquared(v);
	if (lenSq == 0.0f || lenSq == 1.0f) return v;

	GLfloat len = sqrtf(lenSq);
	CC3Vector normal;
	normal.x = v.x / len;
	normal.y = v.y / len;
	normal.z = v.z / len;
	return normal;
}

CC3Vector CC3VectorNegate(CC3Vector v) {
	CC3Vector result;
	result.x = -v.x;
	result.y = -v.y;
	result.z = -v.z;
	return result;
}

CC3Vector CC3VectorInvert(CC3Vector v) {
	CC3Vector result;
	result.x = 1.0 / v.x;
	result.y = 1.0 / v.y;
	result.z = 1.0 / v.z;
	return result;
}

CC3Vector CC3VectorDifference(CC3Vector minuend, CC3Vector subtrahend) {
	CC3Vector difference;
	difference.x = minuend.x - subtrahend.x;
	difference.y = minuend.y - subtrahend.y;
	difference.z = minuend.z - subtrahend.z;
	return difference;
}

CC3Vector CC3VectorRotationModulo(CC3Vector aRotation) {
	CC3Vector modRot;
	modRot.x = Cyclic(aRotation.x, kCircleDegreesPeriod);
	modRot.y = Cyclic(aRotation.y, kCircleDegreesPeriod);
	modRot.z = Cyclic(aRotation.z, kCircleDegreesPeriod);
	return modRot;
}

CC3Vector CC3VectorRotationalDifference(CC3Vector minuend, CC3Vector subtrahend) {
	CC3Vector difference;
	difference.x = CyclicDifference(minuend.x, subtrahend.x, kCircleDegreesPeriod);
	difference.y = CyclicDifference(minuend.y, subtrahend.y, kCircleDegreesPeriod);
	difference.z = CyclicDifference(minuend.z, subtrahend.z, kCircleDegreesPeriod);
	return difference;
}

GLfloat CC3VectorDistance(CC3Vector start, CC3Vector end) {
	return CC3VectorLength(CC3VectorDifference(end, start));
}

GLfloat CC3VectorDistanceSquared(CC3Vector start, CC3Vector end) {
	return CC3VectorLengthSquared(CC3VectorDifference(end, start));
}

CC3Vector CC3VectorScale(CC3Vector v, CC3Vector scale) {
	CC3Vector result;
	result.x = v.x * scale.x;
	result.y = v.y * scale.y;
	result.z = v.z * scale.z;
	return result;
}

CC3Vector CC3VectorScaleUniform(CC3Vector v, GLfloat scale) {
	CC3Vector result;
	result.x = v.x * scale;
	result.y = v.y * scale;
	result.z = v.z * scale;
	return result;
}

CC3Vector CC3VectorAdd(CC3Vector v, CC3Vector translation) {
	CC3Vector result;
	result.x = v.x + translation.x;
	result.y = v.y + translation.y;
	result.z = v.z + translation.z;
	return result;
}

CC3Vector CC3VectorAverage(CC3Vector v1, CC3Vector v2) {
	return CC3VectorScaleUniform(CC3VectorAdd(v1, v2), 0.5);	
}

GLfloat CC3VectorDot(CC3Vector v1, CC3Vector v2) {
	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}

CC3Vector CC3VectorCross(CC3Vector v1, CC3Vector v2) {
	CC3Vector result;
    result.x = v1.y * v2.z - v1.z * v2.y;
    result.y = v1.z * v2.x - v1.x * v2.z;
    result.z = v1.x * v2.y - v1.y * v2.x;
	return result;
}

CC3Vector CC3VectorLerp(CC3Vector v1, CC3Vector v2, GLfloat blendFactor) {
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

NSString* NSStringFromCC3Ray(CC3Ray aRay) {
	return [NSString stringWithFormat: @"(Start: %@, Towards: %@)",
			NSStringFromCC3Vector(aRay.startLocation), NSStringFromCC3Vector(aRay.direction)];
}

CC3Ray CC3RayMake(GLfloat locX, GLfloat locY, GLfloat locZ,
				  GLfloat dirX, GLfloat dirY, GLfloat dirZ) {
	return CC3RayFromLocDir(CC3VectorMake(locX, locY, locZ),
							CC3VectorMake(dirX, dirY, dirZ));
}
	
CC3Ray CC3RayFromLocDir(CC3Vector aLocation, CC3Vector aDirection) {
	CC3Ray aRay;
	aRay.startLocation = aLocation;
	aRay.direction = aDirection;
	return aRay;
}


#pragma mark -
#pragma mark Bounding box structure and functions

NSString* NSStringFromCC3BoundingBox(CC3BoundingBox bb) {
	return [NSString stringWithFormat: @"(Min: %@, Max: %@)",
			NSStringFromCC3Vector(bb.minimum), NSStringFromCC3Vector(bb.maximum)];
}

CC3BoundingBox CC3BoundingBoxMake(GLfloat minX, GLfloat minY, GLfloat minZ,
								  GLfloat maxX, GLfloat maxY, GLfloat maxZ) {
	return CC3BoundingBoxFromMinMax(CC3VectorMake(minX, minY, minZ),
									CC3VectorMake(maxX, maxY, maxZ));
}

CC3BoundingBox CC3BoundingBoxFromMinMax(CC3Vector minVtx, CC3Vector maxVtx) {
	CC3BoundingBox bb;
	bb.minimum = minVtx;
	bb.maximum = maxVtx;
	return bb;
}

BOOL CC3BoundingBoxesAreEqual(CC3BoundingBox bb1, CC3BoundingBox bb2) {
	return CC3VectorsAreEqual(bb1.minimum, bb2.minimum)
		&& CC3VectorsAreEqual(bb1.maximum, bb2.maximum);
}

BOOL CC3BoundingBoxIsNull(CC3BoundingBox bb) {
	return CC3BoundingBoxesAreEqual(bb, kCC3BoundingBoxNull);
}

CC3Vector CC3BoundingBoxCenter(CC3BoundingBox bb) {
	return CC3VectorAverage(bb.minimum, bb.maximum);
}


CC3BoundingBox CC3BoundingBoxEngulfLocation(CC3BoundingBox bb, CC3Vector aLoc) {
	CC3BoundingBox bbOut;
	if(CC3BoundingBoxIsNull(bb)) {
		bbOut.minimum = aLoc;
		bbOut.maximum = aLoc;
	} else {
		bbOut.minimum.x = MIN(bb.minimum.x, aLoc.x);
		bbOut.minimum.y = MIN(bb.minimum.y, aLoc.y);
		bbOut.minimum.z = MIN(bb.minimum.z, aLoc.z);
		
		bbOut.maximum.x = MAX(bb.maximum.x, aLoc.x);
		bbOut.maximum.y = MAX(bb.maximum.y, aLoc.y);
		bbOut.maximum.z = MAX(bb.maximum.z, aLoc.z);
	}	
	return bbOut;
}

CC3BoundingBox CC3BoundingBoxUnion(CC3BoundingBox bb1, CC3BoundingBox bb2) {
	if(CC3BoundingBoxIsNull(bb1)) {
		return bb2;
	}
	if(CC3BoundingBoxIsNull(bb2)) {
		return bb1;
	}
	bb1 = CC3BoundingBoxEngulfLocation(bb1, bb2.minimum);
	bb1 = CC3BoundingBoxEngulfLocation(bb1, bb2.maximum);
	return bb1;
}

CC3BoundingBox CC3BoundingBoxAddPadding(CC3BoundingBox bb, GLfloat padding) {
	CC3Vector padVector = cc3v(padding, padding, padding);
	CC3BoundingBox bbPadded;
	bbPadded.maximum = CC3VectorAdd(bb.maximum, padVector);
	bbPadded.minimum = CC3VectorDifference(bb.minimum, padVector);
	return bbPadded;
}


#pragma mark -
#pragma mark Sphere structure and functions

NSString* NSStringFromCC3Spere(CC3Sphere sphere) {
	return [NSString stringWithFormat: @"(Center: %@, Radius: %.3f)",
			NSStringFromCC3Vector(sphere.center), sphere.radius];
}

CC3Sphere CC3SphereMake(CC3Vector center, GLfloat radius) {
	CC3Sphere s;
	s.center = center;
	s.radius = radius;
	return s;
}

CC3Sphere CC3SphereUnion(CC3Sphere s1, CC3Sphere s2) {
	CC3Vector uc, mc, is1, is2, epF, epB;

	// The center of the union sphere will lie on the line between the centers of the
	// two component spheres. We will look for the two end points (epF & epB) that
	// define the diameter of the sphere on that same line. Each endpoint is the
	// farther of the two points where the spheres intersect this center line.
	// The distance is measured from the midpoint of the line between the centers.
	// This comparison is performed twice, once in each direction of the line.

	// Unit vector between the centers
	uc = CC3VectorNormalize(CC3VectorDifference(s2.center, s1.center));
	
	// The location midpoint between the centers. This is used as an anchor
	// for comparing distances along the line that intersects both centers.
	mc = CC3VectorAverage(s1.center, s2.center);

	// Calculate where each sphere intersects the line in the direction of the unit
	// vector between the centers. Then take the intersection point that is farther
	// from the midpoint along this line as the foward endpoint.
	is1 = CC3VectorAdd(s1.center, CC3VectorScaleUniform(uc, s1.radius));
	is2 = CC3VectorAdd(s2.center, CC3VectorScaleUniform(uc, s2.radius));
	epF = (CC3VectorDistanceSquared(is1, mc) > CC3VectorDistanceSquared(is2, mc)) ? is1 : is2;
	
	// Calculate where each sphere intersects the line in the opposite direction of
	// the unit vector between the centers. Then take the intersection point that is
	// farther from the midpoint along this line as the backward endpoint.
	is1 = CC3VectorDifference(s1.center, CC3VectorScaleUniform(uc, s1.radius));
	is2 = CC3VectorDifference(s2.center, CC3VectorScaleUniform(uc, s2.radius));
	epB = (CC3VectorDistanceSquared(is1, mc) > CC3VectorDistanceSquared(is2, mc)) ? is1 : is2;

	// The resulting union sphere has a center at the midpoint between the two endpoints,
	// and a radius that is half the distance between the two endpoints.
	CC3Sphere rslt;
	rslt.center = CC3VectorAverage(epF, epB);
	rslt.radius = CC3VectorDistance(epF, epB) * 0.5;
	return rslt;
}


#pragma mark -
#pragma mark 3D angular vector structure and functions

NSString* NSStringFromCC3AngularVector(CC3AngularVector av) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f)", av.heading, av.inclination, av.radius];
}

CC3AngularVector CC3AngularVectorMake(GLfloat heading, GLfloat inclination, GLfloat radius) {
	CC3AngularVector av;
	av.heading = heading;
	av.inclination = inclination;	
	av.radius = radius;
	return av;
}

CC3AngularVector CC3AngularVectorFromVector(CC3Vector aCoord) {
	CC3AngularVector av;
	av.radius = CC3VectorLength(aCoord);
	av.inclination = av.radius ? RadiansToDegrees(asinf(aCoord.y / av.radius)) : 0.0;	
	av.heading = RadiansToDegrees(atan2f(aCoord.x, -aCoord.z));
	return av;
}

CC3Vector CC3VectorFromAngularVector(CC3AngularVector av) {
	CC3Vector unitDir;
	
	// First, incline up the Y-axis from the negative Z-axis.
	GLfloat radInclination = DegreesToRadians(av.inclination);
	unitDir.y = sinf(radInclination);
	GLfloat xzLen = cosf(radInclination);
	
	// Now rotate around the Y-axis to the heading. The length of the projection of the direction
	// vector into the X-Z plane is the length of the projection onto the negative Z-axis after
	// the initial inclination. Use this length as the basis for calculating the X & Z CC3Vectors.
	// The result is a unit direction vector projected into all three axes.
	GLfloat radHeading = DegreesToRadians(av.heading);
	unitDir.x = xzLen * sinf(radHeading);
	unitDir.z = -xzLen * cosf(radHeading);
	return CC3VectorScaleUniform(unitDir, av.radius);
}

CC3AngularVector CC3AngularVectorDifference(CC3AngularVector minuend, CC3AngularVector subtrahend) {
	CC3AngularVector difference;
	difference.heading = CyclicDifference(minuend.heading, subtrahend.heading, kCircleDegreesPeriod);
	difference.inclination = minuend.inclination - subtrahend.inclination;
	difference.radius = minuend.radius - subtrahend.radius;
	return difference;
}


#pragma mark -
#pragma mark Cartesian vector in 4D homogeneous coordinate space structure and functions

NSString* NSStringFromCC3Vector4(CC3Vector4 v) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", v.x, v.y, v.z, v.w];
}

CC3Vector4 CC3Vector4Make(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {
	CC3Vector4 v;
	v.x = x;
	v.y = y;
	v.z = z;
	v.w = w;
	return v;
}

CC3Vector4 CC3Vector4FromCC3Vector(CC3Vector v, GLfloat w) {
	CC3Vector4 v4;
	v4.x = v.x;
	v4.y = v.y;
	v4.z = v.z;
	v4.w = w;
	return v4;
}

CC3Vector CC3VectorFromHomogenizedCC3Vector4(CC3Vector4 v) {
	return CC3VectorFromTruncatedCC3Vector4(CC3Vector4Homogenize(v));
}

CC3Vector CC3VectorFromTruncatedCC3Vector4(CC3Vector4 v) {
	CC3Vector v3;
	v3.x = v.x;
	v3.y = v.y;
	v3.z = v.z;
	return v3;
}

BOOL CC3Vector4sAreEqual(CC3Vector4 v1, CC3Vector4 v2) {
	return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z && v1.w == v2.w;
}

CC3Vector4 CC3Vector4Homogenize(CC3Vector4 v) {
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

GLfloat CC3Vector4Length(CC3Vector4 v) {
	GLfloat x = v.x;
	GLfloat y = v.y;
	GLfloat z = v.z;
	GLfloat w = v.w;
	return sqrtf((x * x) + (y * y) + (z * z) + (w * w));
}

CC3Vector4 CC3Vector4Normalize(CC3Vector4 v) {
	GLfloat mag = CC3Vector4Length(v);
	CC3Vector4 normal;
	normal.x = v.x / mag;
	normal.y = v.y / mag;
	normal.z = v.z / mag;
	normal.w = v.w / mag;
	return normal;
}

CC3Vector4 CC3Vector4Negate(CC3Vector4 v) {
	CC3Vector4 result;
	result.x = -v.x;
	result.y = -v.y;
	result.z = -v.z;
	result.w = -v.w;
	return result;
}

CC3Vector4 CC3Vector4ScaleUniform(CC3Vector4 v, GLfloat scale) {
	CC3Vector4 result;
	result.x = v.x * scale;
	result.y = v.y * scale;
	result.z = v.z * scale;
	result.w = v.w * scale;
	return result;
}

CC3Vector4 CC3Vector4Translate(CC3Vector4 v, CC3Vector4 translation) {
	CC3Vector4 result;
	result.x = v.x + translation.x;
	result.y = v.y + translation.y;
	result.z = v.z + translation.z;
	result.w = v.w + translation.w;
	return result;
}

GLfloat CC3Vector4Dot(CC3Vector4 v1, CC3Vector4 v2) {
	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z) + (v1.w * v2.w);
}

CC3Vector4 CC3QuaternionFromAxisAngle(CC3Vector4 axisAngle) {
	// If q is a quaternion, (rx, ry, rz) is the rotation axis, and ra is
	// the rotation angle (negated for right-handed coordinate system), then:
	// q = ( sin(ra/2)*rx, sin(ra/2)*ry, sin(ra/2)*rz, cos(ra/2) )
	
	GLfloat halfAngle = -DegreesToRadians(axisAngle.w) / 2.0;		// negate for RH system
	CC3Vector axis = CC3VectorNormalize(CC3VectorFromTruncatedCC3Vector4(axisAngle));
	return CC3Vector4FromCC3Vector(CC3VectorScaleUniform(axis, sinf(halfAngle)), cosf(halfAngle));
}

CC3Vector4 CC3AxisAngleFromQuaternion(CC3Vector4 quaternion) {
	// If q is a quaternion, (rx, ry, rz) is the rotation axis, and ra is
	// the rotation angle (negated for right-handed coordinate system), then:
	// q = ( sin(ra/2)*rx, sin(ra/2)*ry, sin(ra/2)*rz, cos(ra/2) )
	// ra = acos(q.w) * 2
	// (rx, ry, rz) = (q.x, q.y, q.z) / sin(ra/2)
	
	CC3Vector4 q = CC3Vector4Normalize(quaternion);
	GLfloat halfAngle = acosf(q.w);

	GLfloat angle = -RadiansToDegrees(halfAngle) * 2.0;		// negate for RH system

	// If angle is zero, rotation axis is undefined. Use zero vector.
	CC3Vector axis;
	if (halfAngle != 0.0f) {
		axis = CC3VectorScaleUniform(CC3VectorFromTruncatedCC3Vector4(q),
									 (1.0 / sinf(halfAngle)));
	} else {
		axis = kCC3VectorZero;
	}
	return CC3Vector4FromCC3Vector(axis, angle);
}

#define kSlerpCosAngleLinearEpsilon 0.01	// about 8 degrees

CC3Vector4 CC3Vector4Slerp(CC3Vector4 v1, CC3Vector4 v2, GLfloat blendFactor) {
	// Short-circuit if we know it's one of the end-points.
	if (blendFactor == 0.0f) {
		return v1;
	} else if (blendFactor == 1.0f) {
		return v2;
	}

	GLfloat theta, cosTheta, oneOverSinTheta, v1Weight, v2Weight;

	cosTheta = CC3Vector4Dot(v1, v2) / (CC3Vector4Length(v1) * CC3Vector4Length(v2));

	// (Q and −Q map to the same rotation), the rotation path may turn either the "short way"
	// (less than 180°) or the "long way" (more than 180°). Long paths can be prevented by
	// negating one end if the dot product, cos(theta), is negative, thus ensuring that
	// −90° ≤ theta ≤ 90°. Taken from http://en.wikipedia.org/wiki/Slerp
	if (cosTheta < 0.0) {
		return CC3Vector4Slerp(v1, CC3Vector4Negate(v2), blendFactor);
	}

	// If angle close to zero (cos() close to one), save cycles by interpolating linearly
	if ((1.0 - cosTheta) < kSlerpCosAngleLinearEpsilon) {
		v1Weight = 1.0 - blendFactor;
		v2Weight = blendFactor;
	} else {
		theta = acosf(cosTheta);
		oneOverSinTheta = 1.0 / sinf(theta);
		v1Weight = (sinf(theta * (1.0 - blendFactor)) * oneOverSinTheta);
		v2Weight = (sinf(theta * blendFactor) * oneOverSinTheta);
	}
	CC3Vector4 result = CC3Vector4Normalize(CC3Vector4Translate(CC3Vector4ScaleUniform(v1, v1Weight),
												   CC3Vector4ScaleUniform(v2, v2Weight)));
	LogTrace(@"SLERP with cos %.3f at %.3f between %@ and %@ is %@", cosTheta, blendFactor, 
			 NSStringFromCC3Vector4(v1), NSStringFromCC3Vector4(v2),
			 NSStringFromCC3Vector4(result));
	return result;
}


#pragma mark -
#pragma mark Plane and frustrum structures and functions

NSString* NSStringFromCC3Plane(CC3Plane p) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", p.a, p.b, p.c, p.d];
}

CC3Plane CC3PlaneMake(GLfloat a, GLfloat b, GLfloat c, GLfloat d) {
	CC3Plane p;
	p.a = a;
	p.b = b;
	p.c = c;
	p.d = d;
	return p;
}

CC3Plane CC3PlaneFromPoints(CC3Vector p1, CC3Vector p2, CC3Vector p3) {
	CC3Vector v12 = CC3VectorDifference(p2, p1);
	CC3Vector v23 = CC3VectorDifference(p3, p2);
	CC3Vector n = CC3VectorNormalize(CC3VectorCross(v12, v23));
	GLfloat d = -CC3VectorDot(p1, n);
	return CC3PlaneMake(n.x, n.y, n.z, d);
}

CC3Vector CC3PlaneNormal(CC3Plane p) {
	return cc3v(p.a, p.b, p.c);
}

CC3Plane CC3PlaneNormalize(CC3Plane p) {
	GLfloat normLen = CC3VectorLength(CC3PlaneNormal(p));
	CC3Plane np;
	np.a = p.a / normLen;
	np.b = p.b / normLen;
	np.c = p.c / normLen;
	np.d = p.d / normLen;
	return np;
}

GLfloat CC3DistanceFromNormalizedPlane(CC3Plane p, CC3Vector v) {
	return (p.a * v.x) + (p.b * v.y) + (p.c * v.z) + p.d;
}

CC3Vector4 CC3RayIntersectionWithPlane(CC3Ray ray, CC3Plane plane) {
	// For a plane defined by v.pn + d = 0, where v is a point on the plane, pn is the normal
	// of the plane and d is a constant, and a ray defined by v(t) = rs + t*rd, where rs is
	// the ray start rd is the ray direction, and t is a multiple, the intersection occurs
	// where the two are equal: (rs + t*rd).pn + d = 0.
	// Solving for t gives t = -(rs.pn + d) / rd.pn
	// The denominator rd.n will be zero if the ray is parallel to the plane.
	CC3Vector pn = CC3PlaneNormal(plane);
	CC3Vector rs = ray.startLocation;
	CC3Vector rd = ray.direction;
	GLfloat dirDotNorm = CC3VectorDot(rd, pn);
	if (dirDotNorm != 0.0f) {
		GLfloat dirDist = -(CC3VectorDot(rs, pn) + plane.d) / CC3VectorDot(rd, pn);
		CC3Vector loc = CC3VectorAdd(rs, CC3VectorScaleUniform(rd, dirDist));
		return CC3Vector4FromCC3Vector(loc, dirDist);
	} else {
		return kCC3Vector4Zero;
	}
}


#pragma mark -
#pragma mark Attenuation function structures

NSString* NSStringFromCC3AttenuationCoefficients(CC3AttenuationCoefficients coeffs) {
	return [NSString stringWithFormat: @"(%.3f, %.6f, %.9f)", coeffs.a, coeffs.b, coeffs.c];
}

CC3AttenuationCoefficients CC3AttenuationCoefficientsMake(GLfloat a, GLfloat b, GLfloat c) {
	CC3AttenuationCoefficients coeffs;
	coeffs.a = a;
	coeffs.b = b;
	coeffs.c = c;
	return coeffs;
}


#pragma mark -
#pragma mark Viewport structure and functions

NSString* NSStringFromCC3Viewport(CC3Viewport vp) {
	return [NSString stringWithFormat: @"(%i, %i, %i, %i)", vp.x, vp.y, vp.w, vp.h];
}

CC3Viewport CC3ViewportMake(GLint x, GLint y, GLint w, GLint h) {
	CC3Viewport vp;
	vp.x = x;
	vp.y = y;
	vp.w = w;
	vp.h = h;
	return vp;
}

BOOL CC3ViewportsAreEqual(CC3Viewport vp1, CC3Viewport vp2) {
	return vp1.x == vp2.x && vp1.y == vp2.y && vp1.w == vp2.w && vp1.h == vp2.h;
}

BOOL CC3ViewportContainsPoint(CC3Viewport vp, CGPoint point) {
	return (point.x >= vp.x) && (point.x < vp.x + vp.w) &&
		   (point.y >= vp.y) && (point.y < vp.y + vp.h);
}

CGRect CGRectFromCC3Viewport(CC3Viewport vp) {
	return CGRectMake(vp.x, vp.y, vp.w, vp.h);
}


#pragma mark -
#pragma mark ccColor4F functions

NSString* NSStringFromCCC4F(ccColor4F rgba) {
	return [NSString stringWithFormat: @"(%.3f, %.3f, %.3f, %.3f)", rgba.r, rgba.g, rgba.b, rgba.a];
}

ccColor4F CCC4FMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	ccColor4F color;
	color.r = red;
	color.g = green;
	color.b = blue;
	color.a = alpha;
	return color;
}

ccColor4F CCC4FFromCCC4B(ccColor4B byteColor) {
	ccColor4F color;
	color.r = CCColorFloatFromByte(byteColor.r);
	color.g = CCColorFloatFromByte(byteColor.g);
	color.b = CCColorFloatFromByte(byteColor.b);
	color.a = CCColorFloatFromByte(byteColor.a);
	return color;
}

ccColor4B CCC4BFromCCC4F(ccColor4F floatColor) {
	ccColor4B color;
	color.r = CCColorByteFromFloat(floatColor.r);
	color.g = CCColorByteFromFloat(floatColor.g);
	color.b = CCColorByteFromFloat(floatColor.b);
	color.a = CCColorByteFromFloat(floatColor.a);
	return color;
}

ccColor4F CCC4FFromColorAndOpacity(ccColor3B byteColor, GLubyte opacity) {
	ccColor4F color;
	color.r = CCColorFloatFromByte(byteColor.r);
	color.g = CCColorFloatFromByte(byteColor.g);
	color.b = CCColorFloatFromByte(byteColor.b);
	color.a = CCColorFloatFromByte(opacity);
	return color;
}

ccColor3B CCC3BFromCCC4F(ccColor4F floatColor) {
	ccColor3B color;
	color.r = CCColorByteFromFloat(floatColor.r);
	color.g = CCColorByteFromFloat(floatColor.g);
	color.b = CCColorByteFromFloat(floatColor.b);
	return color;
}

BOOL CCC4FAreEqual(ccColor4F c1, ccColor4F c2) {
	return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a;
}

ccColor4F CCC4FAdd(ccColor4F rgba, ccColor4F translation) {
	ccColor4F result;
	result.r = CLAMP(rgba.r + translation.r, 0.0, 1.0);
	result.g = CLAMP(rgba.g + translation.g, 0.0, 1.0);
	result.b = CLAMP(rgba.b + translation.b, 0.0, 1.0);
	result.a = CLAMP(rgba.a + translation.a, 0.0, 1.0);
	return result;
}

ccColor4F CCC4FDifference(ccColor4F minuend, ccColor4F subtrahend) {
	ccColor4F result;
	result.r = CLAMP(minuend.r - subtrahend.r, 0.0, 1.0);
	result.g = CLAMP(minuend.g - subtrahend.g, 0.0, 1.0);
	result.b = CLAMP(minuend.b - subtrahend.b, 0.0, 1.0);
	result.a = CLAMP(minuend.a - subtrahend.a, 0.0, 1.0);
	return result;
}

ccColor4F CCC4FUniformTranslate(ccColor4F rgba, GLfloat offset) {
	return CCC4FAdd(rgba, CCC4FMake(offset, offset, offset, offset));
}

ccColor4F CCC4FUniformScale(ccColor4F rgba, GLfloat scale) {
	ccColor4F result;
	result.r = CLAMP(rgba.r * scale, 0.0, 1.0);
	result.g = CLAMP(rgba.g * scale, 0.0, 1.0);
	result.b = CLAMP(rgba.b * scale, 0.0, 1.0);
	result.a = CLAMP(rgba.a * scale, 0.0, 1.0);
	return result;
}

ccColor4F CCC4FBlend(ccColor4F baseColor, ccColor4F blendColor, GLfloat blendWeight) {
	return CCC4FMake(WAVG(baseColor.r, blendColor.r, blendWeight),
					 WAVG(baseColor.g, blendColor.g, blendWeight),
					 WAVG(baseColor.b, blendColor.b, blendWeight),
					 WAVG(baseColor.a, blendColor.a, blendWeight));
}

ccColor4F RandomCCC4FBetween(ccColor4F min, ccColor4F max) {
	ccColor4F result;
	result.r = RandomFloatBetween(min.r, max.r);
	result.g = RandomFloatBetween(min.g, max.g);
	result.b = RandomFloatBetween(min.b, max.b);
	result.a = RandomFloatBetween(min.a, max.a);
	return result;
}

GLfloat CCColorFloatFromByte(GLubyte colorValue) {
	return (GLfloat)(colorValue / 255.0f);
}

GLubyte CCColorByteFromFloat(GLfloat colorValue) {
	return (GLubyte)(colorValue * 255.0f);
}


#pragma mark -
#pragma mark Miscellaneous extensions and functionality

NSString* NSStringFromTouchType(uint tType) {
	switch (tType) {
		case kCCTouchBegan:
			return @"kCCTouchBegan";
		case kCCTouchMoved:
			return @"kCCTouchMoved";
		case kCCTouchEnded:
			return @"kCCTouchEnded";
		case kCCTouchCancelled:
			return @"kCCTouchCancelled";
		default:
			return [NSString stringWithFormat: @"unknown touch type (%u)", tType];
	}
}

NSString* NSStringFromBoolean(BOOL value) {
	return value ? @"YES" : @"NO";
}

@implementation NSObject (CC3)

-(id) copyAutoreleased {
	return [[self copy] autorelease];
}

@end


@implementation UIColor (CC3)

-(ccColor4F) asCCColor4F {
	ccColor4F rgba = kCCC4FWhite;  // initialize to white
	
	CGColorRef cgColor= self.CGColor;
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

+(UIColor*) colorWithCCColor4F: (ccColor4F) rgba {
	return [UIColor colorWithRed: rgba.r green: rgba.g blue: rgba.b alpha: rgba.a];
}

@end


#pragma mark -
#pragma mark CCNode extension

@implementation CCNode (CC3)

- (CGRect) globalBoundingBoxInPixels {
	CGRect rect = CGRectMake(0, 0, contentSizeInPixels_.width, contentSizeInPixels_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

-(void) updateViewport {
	[children_ makeObjectsPerformSelector:@selector(updateViewport)];	
}

@end


#pragma mark -
#pragma mark CCDirector extension

@implementation CCDirector (CC3)

-(ccTime) frameInterval {
	return dt;
}
-(ccTime) frameRate {
	return frameRate_;
}

@end


#pragma mark -
#pragma mark CCArray extension

@implementation CCArray (CC3)

-(NSUInteger) indexOfObjectIdenticalTo: (id) anObject {
	return [self indexOfObject: anObject];
}

-(void) removeObjectIdenticalTo: (id) anObject {
	[self removeObject: anObject];
}

-(void) replaceObjectAtIndex: (NSUInteger) index withObject: (id) anObject {
	NSAssert(index < data->num, @"Invalid index. Out of bounds");

	id oldObj = data->arr[index];
	data->arr[index] = [anObject retain];
	[oldObj release];						// Release after in case new is same as old
}


#pragma mark Support for unretained objects

- (void) addUnretainedObject: (id) anObject {
	ccCArrayAppendValueWithResize(data, anObject);
}

- (void) insertUnretainedObject: (id) anObject atIndex: (NSUInteger) index {
	ccCArrayEnsureExtraCapacity(data, 1);
	ccCArrayInsertValueAtIndex(data, anObject, index);
}

- (void) removeUnretainedObjectIdenticalTo: (id) anObject {
	ccCArrayRemoveValue(data, anObject);
}

- (void) removeUnretainedObjectAtIndex: (NSUInteger) index {
	ccCArrayRemoveValueAtIndex(data, index);
}

- (void) removeAllObjectsAsUnretained {
	ccCArrayRemoveAllValues(data);
}

-(void) releaseAsUnretained {
	[self removeAllObjectsAsUnretained];
	[self release];
}

- (NSString*) fullDescription {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ (", [self class]];
	if (data->num > 0) {
		[desc appendFormat:@"\n\t%@", data->arr[0]];
	}
	for (NSUInteger i = 1; i < data->num; i++) {
		[desc appendFormat:@",\n\t%@", data->arr[i]];
	}
	[desc appendString:@")"];
	return desc;
}

@end

