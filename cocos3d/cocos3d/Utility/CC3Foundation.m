/*
 * CC3Foundation.m
 *
 * cocos3d 0.6.4
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


#pragma mark -
#pragma mark Cartesian vector in 4D homogeneous coordinate space structure and functions

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
	GLfloat halfAngle = -acosf(q.w);						// Negate to preserve orientation
	GLfloat angle = -RadiansToDegrees(halfAngle) * 2.0;		// Negate for RH system

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
	CC3Vector4 result = CC3Vector4Normalize(CC3Vector4Add(CC3Vector4ScaleUniform(v1, v1Weight),
												   CC3Vector4ScaleUniform(v2, v2Weight)));
	LogTrace(@"SLERP with cos %.3f at %.3f between %@ and %@ is %@", cosTheta, blendFactor, 
			 NSStringFromCC3Vector4(v1), NSStringFromCC3Vector4(v2),
			 NSStringFromCC3Vector4(result));
	return result;
}


#pragma mark -
#pragma mark Plane and frustrum structures and functions

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

