/*
 * CC3Foundation.m
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
 * See header file CC3Foundation.h for full API documentation.
 */

#import "CC3Foundation.h"
#import "CC3Matrix3x3.h"
#import "CGPointExtension.h"


NSString* NSStringFromCC3Vectors(CC3Vector* vectors, GLuint vectorCount) {
	NSMutableString* desc = [NSMutableString stringWithCapacity: (vectorCount * 8)];
	for (GLuint vIdx = 0; vIdx < vectorCount; vIdx++) {
		[desc appendFormat: @"\n\t%@", NSStringFromCC3Vector(vectors[vIdx])];
	}
	return desc;
}

void CC3VectorOrthonormalize(CC3Vector* vectors, GLuint vectorCount) {
	LogTrace(@"Vectors BEFORE orthonormalization: %@", NSStringFromCC3Vectors(vectors, vectorCount));

	for (GLuint currIdx = 0; currIdx < vectorCount; currIdx++) {
		// Get the current vector, and subtract any projection from any previously processed vector.
		// (ie- subtract the portion of each previously processed vector that is parallel to this one).
		// Keep the current vector being cleaned separate from the original vector, so
		// keep the projections into the current vector consistent across all previous vectors.
		CC3Vector currVector = vectors[currIdx];
		CC3Vector cleanedCurrVector = currVector;
		for (GLuint prevIdx = 0; prevIdx < currIdx; prevIdx++) {
			CC3Vector prevVector = vectors[prevIdx];
			CC3Vector projPrevVector = CC3VectorScaleUniform(prevVector, CC3VectorDot(currVector, prevVector));
			cleanedCurrVector = CC3VectorDifference(cleanedCurrVector, projPrevVector);
		}
		// Replace the current vector with its orthonormalized version
		vectors[currIdx] = CC3VectorNormalize(cleanedCurrVector);
	}

	LogTrace(@"Vectors AFTER orthonormalization: %@", NSStringFromCC3Vectors(vectors, vectorCount));
}


#pragma mark -
#pragma mark Bounding box structure and functions

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
CC3Vector4 CC3RayIntersectionOfBoundingBoxSide(CC3Ray aRay, CC3BoundingBox bb, CC3Vector sideNormal, CC3Vector4 prevHit) {
	
	// Determine which corner to use from the direction of the edge plane normal,
	// create the edge plane, and determine where the ray intersects the edge plane.
	CC3Vector corner = (sideNormal.x + sideNormal.y + sideNormal.z > 0) ? bb.maximum : bb.minimum;
	CC3Plane sidePlane = CC3PlaneFromNormalAndLocation(sideNormal, corner);
	CC3Vector4 sideHit = CC3RayIntersectionWithPlane(aRay, sidePlane);
	
	// If ray is parallel to edge plane, or if edge plane is behind the ray
	// start, we have no intersection, so return the previous intersection.
	if (CC3Vector4IsNull(sideHit)) return prevHit;
	if (sideHit.w < 0.0f) return prevHit;
	
	// To avoid missed intersections due to rounding errors when checking if the
	// intersection is within the bounding box, force the side plane intersection
	// explicitly onto the appropriate side of the bounding box.
	if (sideNormal.x) sideHit.x = corner.x;
	if (sideNormal.y) sideHit.y = corner.y;
	if (sideNormal.z) sideHit.z = corner.z;
	
	// If the side intersection location is not within
	// the bounding box, return the previous intersection.
	CC3Vector edgeHit3d = CC3VectorFromTruncatedCC3Vector4(sideHit);
	if ( !CC3BoundingBoxContainsLocation(bb, edgeHit3d) ) return prevHit;
	
	// If the ray distance to this side is less than the previous intersection,
	// return this intersection, otherwise return the previous intersection.
	return sideHit.w < prevHit.w ? sideHit : prevHit;
}

CC3Vector  CC3RayIntersectionOfBoundingBox(CC3Ray aRay, CC3BoundingBox bb) {
	if (CC3BoundingBoxIsNull(bb)) return kCC3VectorNull;	// Short-circuit null bounding box
	CC3Vector4 closestHit = kCC3Vector4Null;
	closestHit = CC3RayIntersectionOfBoundingBoxSide(aRay, bb, kCC3VectorUnitXPositive, closestHit);
	closestHit = CC3RayIntersectionOfBoundingBoxSide(aRay, bb, kCC3VectorUnitXNegative, closestHit);
	closestHit = CC3RayIntersectionOfBoundingBoxSide(aRay, bb, kCC3VectorUnitYPositive, closestHit);
	closestHit = CC3RayIntersectionOfBoundingBoxSide(aRay, bb, kCC3VectorUnitYNegative, closestHit);
	closestHit = CC3RayIntersectionOfBoundingBoxSide(aRay, bb, kCC3VectorUnitZPositive, closestHit);
	closestHit = CC3RayIntersectionOfBoundingBoxSide(aRay, bb, kCC3VectorUnitZNegative, closestHit);
	return CC3VectorFromTruncatedCC3Vector4(closestHit);	
}


#pragma mark -
#pragma mark Quaternions

// Simple function, but too much expanded code to make inline
CC3Quaternion CC3QuaternionFromRotation(CC3Vector aRotation) {
	CC3Matrix3x3 rotMtx;
	CC3Matrix3x3PopulateFromRotationYXZ(&rotMtx, aRotation);
	return CC3Matrix3x3ExtractQuaternion(&rotMtx);
}

// Simple function, but too much expanded code to make inline
CC3Vector CC3RotationFromQuaternion(CC3Quaternion aQuaternion) {
	CC3Matrix3x3 rotMtx;
	CC3Matrix3x3PopulateFromQuaternion(&rotMtx, aQuaternion);
	return CC3Matrix3x3ExtractRotationYXZ(&rotMtx);
}

#define kSlerpCosAngleLinearEpsilon 0.01	// about 8 degrees

CC3Quaternion CC3QuaternionSlerp(CC3Quaternion q1, CC3Quaternion q2, GLfloat blendFactor) {
	// Short-circuit if we know it's one of the end-points.
	if (blendFactor == 0.0f) return q1;
	if (blendFactor == 1.0f) return q2;
	
	GLfloat theta, cosTheta, oneOverSinTheta, v1Weight, v2Weight;
	
	cosTheta = CC3Vector4Dot(q1, q2) / (CC3Vector4Length(q1) * CC3Vector4Length(q2));
	
	// (Q and −Q map to the same rotation), the rotation path may turn either the "short way"
	// (less than 180°) or the "long way" (more than 180°). Long paths can be prevented by
	// negating one end if the dot product, cos(theta), is negative, thus ensuring that
	// −90° ≤ theta ≤ 90°. Taken from http://en.wikipedia.org/wiki/Slerp
	if (cosTheta < 0.0) { return CC3QuaternionSlerp(q1, CC3QuaternionNegate(q2), blendFactor); }
	
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
	CC3Vector4 result = CC3QuaternionNormalize(CC3Vector4Add(CC3QuaternionScaleUniform(q1, v1Weight),
																CC3QuaternionScaleUniform(q2, v2Weight)));
	LogTrace(@"SLERP with cos %.3f at %.3f between %@ and %@ is %@", cosTheta, blendFactor, 
			 NSStringFromCC3Quaternion(q1), NSStringFromCC3Quaternion(q2),
			 NSStringFromCC3Quaternion(result));
	return result;
}

// Deprecated
CC3Vector4 CC3Vector4Slerp(CC3Vector4 v1, CC3Vector4 v2, GLfloat blendFactor) {
	return CC3QuaternionSlerp(v1, v2, blendFactor);
}


#pragma mark -
#pragma mark Face structures and functions

/**
 * Given the corners of the triagular face (c0, c1, c2), the barycentric weights are determined by
 * transforming the origin of the coordinate system to the first corner of the triangular face (c0).
 * 
 * We can write an equation for the specified location of interest (p), using c0 as the origin
 * and the two sides projecting from c0 as basis vectors:
 *    p = c0 + b1(c1 - c0) + b2(c2 - c0)
 *
 * Subtract c0 from both sides to translate to a coordinate system with c0 at the origin, and
 * substitute vectors vp, v1 & v2 to represent the the vectors from c0:
 *    (p - c0) = b1(c1 - c0) + b2(c2 - c0)
 *    vp = b1(v1) + b2(v2)
 * 
 * To solve for b1 & b2, we need two equations, which we can get by dotting both sides of this
 * equation by v1 to create one equation and by v2 to create the other equation:
 *    vp.v1 = b1(v1.v1) + b2(v2.v1)
 *    vp.v2 = b1(v1.v2) + b2(v2.v2)
 *
 * Solving for b1 & b2:
 *    b1 = ((v2.v2)(vp.v1) - (v2.v1)(vp.v2)) / d
 *    b2 = ((v1.v1)(vp.v2) - (v1.v2)(vp.v1)) / d
 * where:
 *    d = (v1.v1)(v2.v2) - (v1.v2)(v2.v1)
 *
 * We know have two of the three barycentric coordinates. We can get the third by expanding
 * the original equation and collecting like terms:
 *    p = c0 + b1(c1 - c0) + b2(c2 - c0)
 *    p = c0 + b1(c1) - b2(c0) + b2(c2) - b2(c0)
 *    p = (1 - b1 - b2)(c0) + b1(c1) + b2(c2)
 *    p = b0(c0) + b1(c1) + b2(c2)
 * where:
 *    b0 = 1 - b1 - b2
 *
 * References: Mathematics for 3D Game Programming and Computer Graphics, 3rd ed. book, by Eric Lengyel
 *        and: http://www.blackpawn.com/texts/pointinpoly/default.html
 */
CC3BarycentricWeights CC3FaceBarycentricWeights(CC3Face face, CC3Vector aLocation) {
	CC3BarycentricWeights bcw;
	GLfloat* b = bcw.weights;
	CC3Vector* c = face.vertices;
	
	// Create basis vectors using the first face corner (index 0) as the origin
	CC3Vector vp = CC3VectorDifference(aLocation, c[0]);
	CC3Vector v1 = CC3VectorDifference(c[1], c[0]);
	CC3Vector v2 = CC3VectorDifference(c[2], c[0]);
	
	// Create dot products required to solve the two equations and two unknowns
	GLfloat dot11 = CC3VectorDot(v1, v1);
	GLfloat dot12 = CC3VectorDot(v1, v2);
	GLfloat dot1p = CC3VectorDot(v1, vp);
	GLfloat dot22 = CC3VectorDot(v2, v2);
	GLfloat dot2p = CC3VectorDot(v2, vp);
	
	GLfloat invDenom = 1.0f / (dot11 * dot22 - dot12 * dot12);	// Denominator
	
	b[1] = (dot22 * dot1p - dot12 * dot2p) * invDenom;
	b[2] = (dot11 * dot2p - dot12 * dot1p) * invDenom;
	b[0] = 1.0f - b[1] - b[2];
	
	LogTrace(@"The barycentric weights of location %@ in triangle %@ are %@ using basis vectors",
			 NSStringFromCC3Vector(aLocation), NSStringFromCC3Face(face), NSStringFromCC3BarycentricWeights(bcw));
	return bcw;
}

/**
 * The barycentric weights are determined by calculating the areas of the three sub-triangles,
 * each defined by the specified location and two of the three corners of the face triangle.
 * Each barycentric weight is the ratio of the area of the corresponding sub-triangle to the
 * area of the face triangle.
 * 
 * For each corner of the face triangle, determine the opposite edge (e) and the vector from the
 * corner to the specified location (d). The area of a sub-triangle is given by half the magnitude of
 * the cross-product of two of its sides (one edge (e) and one vector to the specified location (d)).
 * Similarly, the area of the face triangle is given by half the magnitude of the cross-product of
 * two of the edges of the face triangle. To provide an orientation, or sign, to each magnitude,
 * a dot-product is taken of each cross-product and the normal of the face plane.
 *
 * The ratio of the area of a sub-triangle to the face triangle is then the ratio of these two signed
 * cross-product magnitudes. A negative value for the ratio indicates that the corresponding
 * barycentric weight is negative, which in turn indicates that the specified location is outside
 * the triangle on the other side of that corresponding side.
 * 
 * Reference: 3D Math Primer for Graphics and Game Development book, by Fletcher Dunn and Ian Parberry.
 */
/*
CC3BarycentricWeights CC3FaceBarycentricWeights(CC3Face face, CC3Vector v) {

	// The three corners of the face triangle
	CC3Vector v0 = face.vertices[0];
	CC3Vector v1 = face.vertices[1];
	CC3Vector v2 = face.vertices[2];

	// The three edges of the triangle, opposite the corresponding corner
	CC3Vector e0 = CC3VectorDifference(v2, v1);
	CC3Vector e1 = CC3VectorDifference(v0, v2);
	CC3Vector e2 = CC3VectorDifference(v1, v0);
	
	// The three vectors from each corner to the location of interest
	CC3Vector d0 = CC3VectorDifference(v, v0);
	CC3Vector d1 = CC3VectorDifference(v, v1);
	CC3Vector d2 = CC3VectorDifference(v, v2);
	
	// The unnormalized normal of the face plane (also the unsigned area of the face triangle)
	CC3Vector n = CC3VectorCross(e0, e1);

	// Determine the area of the face triangle and each sub-triangle as the magnitude of the
	// cross-product of two of its sides, dotted with the normal to give the magnitude a sign.
	GLfloat af = CC3VectorDot(n, n);	// Since n is also the cross-product to use for the area of the face triangle
	GLfloat a0 = CC3VectorDot(CC3VectorCross(e0, d2), n);
	GLfloat a1 = CC3VectorDot(CC3VectorCross(e1, d0), n);
	GLfloat a2 = CC3VectorDot(CC3VectorCross(e2, d1), n);
	
	CC3BarycentricWeights bcw;
	bcw.weights[0] = a0 / af;
	bcw.weights[1] = a1 / af;
	bcw.weights[2] = a2 / af;
	LogTrace(@"The barycentric weights of location %@ in triangle %@ are %@ using triangle areas",
			 NSStringFromCC3Vector(v), NSStringFromCC3Face(face), NSStringFromCC3BarycentricWeights(bcw));
	return bcw;
}
*/


#pragma mark -
#pragma mark Plane structures and functions

CC3Vector4 CC3RayIntersectionWithPlane(CC3Ray ray, CC3Plane plane) {
	// For a plane defined by v.pn + d = 0, where v is a point on the plane, pn is the normal
	// of the plane and d is a constant, and a ray defined by v(t) = rs + t*rd, where rs is
	// the ray start rd is the ray direction, and t is a multiple, the intersection occurs
	// where the two are equal: (rs + t*rd).pn + d = 0.
	// Solving for t gives t = -(rs.pn + d) / rd.pn
	// The denominator rd.pn will be zero if the ray is parallel to the plane.
	CC3Vector pn = CC3PlaneNormal(plane);
	CC3Vector rs = ray.startLocation;
	CC3Vector rd = ray.direction;
	GLfloat dirDotNorm = CC3VectorDot(rd, pn);
	
	if (dirDotNorm == 0.0f) return kCC3Vector4Null;		// Ray is parallel to plane, so no intersection
	
	GLfloat dirDist = -(CC3VectorDot(rs, pn) + plane.d) / CC3VectorDot(rd, pn);
	CC3Vector loc = CC3VectorAdd(rs, CC3VectorScaleUniform(rd, dirDist));
	return CC3Vector4FromCC3Vector(loc, dirDist);
}

CC3Vector CC3TriplePlaneIntersection(CC3Plane p1, CC3Plane p2, CC3Plane p3) {
	
	// For three planes of the form p.n + d = 0, the point of intersection is:
	//    pi = -( d1(n2 x n3) + d2(n3 x n1) + d3(n1 x n2) ) / ((n1 x n2).n3)
	// If the denominator is zero, the planes do not intersect at a single point.
	
	CC3Vector n1 = CC3PlaneNormal(p1);
	CC3Vector n2 = CC3PlaneNormal(p2);
	CC3Vector n3 = CC3PlaneNormal(p3);
	
	GLfloat n1xn2dotn3 = CC3VectorDot(CC3VectorCross(n1, n2), n3);
	if (n1xn2dotn3 == 0.0f) return kCC3VectorNull;
	
	CC3Vector d1n2xn3 = CC3VectorScaleUniform(CC3VectorCross(n2, n3), p1.d);
	CC3Vector d2n3xn1 = CC3VectorScaleUniform(CC3VectorCross(n3, n1), p2.d);
	CC3Vector d3n1xn2 = CC3VectorScaleUniform(CC3VectorCross(n1, n2), p3.d);
	
	CC3Vector sum = CC3VectorAdd(CC3VectorAdd(d1n2xn3, d2n3xn1), d3n1xn2);
	
	return CC3VectorScaleUniform(sum, (-1.0f / n1xn2dotn3));
}

// Deprecated function
CC3Plane CC3PlaneFromPoints(CC3Vector v1, CC3Vector v2, CC3Vector v3) {
	return CC3PlaneFromLocations(v1, v2, v3);
}

// Deprecated function
GLfloat CC3DistanceFromNormalizedPlane(CC3Plane p, CC3Vector v) {
	return CC3DistanceFromPlane(v, p);
}


#pragma mark -
#pragma mark Sphere structure and functions

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
	
	// The location midpoint between the centers. This is used as an origin
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
CC3Plane CC3RaySphereIntersectionEquation(CC3Ray aRay, CC3Sphere aSphere) {
	// The quadratic intersection equation assumes the sphere is at the origin,
	// so translate the ray to the sphere's reference frame.
	CC3Vector rayStart = CC3VectorDifference(aRay.startLocation, aSphere.center);

	// Calculate the coefficients of the quadratic intersection equation
	GLfloat a = CC3VectorLengthSquared(aRay.direction);
	GLfloat b = 2.0f * CC3VectorDot(rayStart, aRay.direction);
	GLfloat c = CC3VectorLengthSquared(rayStart) - (aSphere.radius * aSphere.radius);
	
	// Calculate the discriminant of the quadratic solution
	GLfloat d = (b * b) - (4.0f * a * c);
	
	// Return the coefficients and discriminant as a plane
	LogTrace(@"Intersection equation for ray %@ and sphere %@: %@",
				  NSStringFromCC3Ray(aRay), NSStringFromCC3Spere(aSphere),
				  NSStringFromCC3Plane(CC3PlaneMake(a, b, c, d)));
	return CC3PlaneMake(a, b, c, d);
}

BOOL CC3DoesRayIntersectSphere(CC3Ray aRay, CC3Sphere aSphere) {
	// Intersection occurs if the discriminant, of the quadratic equation that
	// describes the points of intersection between the ray and sphere, is not negative.
	return CC3RaySphereIntersectionEquation(aRay, aSphere).d >= 0.0f;
}

CC3Vector CC3RayIntersectionOfSphere(CC3Ray aRay, CC3Sphere aSphere) {
	// Retrieve the quadratic equation that describes the points of interesection.
	CC3Plane eqn = CC3RaySphereIntersectionEquation(aRay, aSphere);
	if (eqn.d < 0.0f) return kCC3VectorNull;	// No intersection if discriminant is negative.
	
	// There are two roots of the quadratic equation: ((-b +/- sqrt(D)) / 2a),
	// where D is the discriminant (b*b - 4ac). Get the square root of the
	// discriminant to avoid calculating it more than once.
	GLfloat sqrtDisc = sqrtf(eqn.d);
	
	// Test the smaller root first. If it is negative, then that intersection location
	// is behind the startLocation of the ray. If so, test the second root. If it is
	// negative, then that location is also behind the startLocation of the ray.
	// If the first root is negative and the second root is positive, it's an indication
	// that the startLocation is inside the sphere, and the second location is the exit point.
	GLfloat t = (-eqn.b - sqrtDisc) / (2.0f * eqn.a);
	if (t < 0.0f) t = (-eqn.b + sqrtDisc) / (2.0f * eqn.a);
	
	// If t is positive, the corresponding intersection location is on the ray.
	// Find that location on the ray as: p = s + tv and return it.
	if (t >= 0.0f) {
		CC3Vector tv = CC3VectorScaleUniform(aRay.direction, t);
		return CC3VectorAdd(aRay.startLocation, tv);
	}
	
	// Both intersection locations are behind the startLocation of the ray
	return kCC3VectorNull;
}


#pragma mark -
#pragma mark Miscellaneous extensions and functionality

NSString* CC3EnsureAbsoluteFilePath(NSString* filePath) {
	if(filePath.isAbsolutePath) return filePath;
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: filePath];
}

