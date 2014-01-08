/*
 * CC3VertexArrayMesh.h
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

#import "CC3Mesh.h"
#import "CC3BoundingVolumes.h"


#pragma mark -
#pragma mark Deprecated vertex array mesh and vertex locations bounding volumes

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated Functionality moved to CC3Mesh.
 */
@interface CC3VertexArrayMesh : CC3Mesh
@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated Functionality moved to parent CC3NodeCenterOfGeometryBoundingVolume class.
 */
@interface CC3VertexLocationsBoundingVolume : CC3NodeCenterOfGeometryBoundingVolume
@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated Functionality moved to parent CC3NodeSphericalBoundingVolume class.
 */
@interface CC3VertexLocationsSphericalBoundingVolume : CC3NodeSphericalBoundingVolume
@end

DEPRECATED_ATTRIBUTE
/**
 * Deprecated.
 * @deprecated Functionality moved to parent CC3NodeBoxBoundingVolume class.
 */
@interface CC3VertexLocationsBoundingBoxVolume : CC3NodeBoxBoundingVolume
@end



