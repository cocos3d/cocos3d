/*
 * CC3ParametricMeshes.h
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

#import "CC3VertexArrayMesh.h"
#import "CC3CC2Extensions.h"


#pragma mark -
#pragma mark CC3VertexArrayMesh parametric shapes extension

/**
 * This CC3VertexArrayMesh extension adds a number of methods for populating the mesh of
 * a mesh programatically to create various parametric shapes and surfaces.
 *
 * To use the methods in this extension, instantiate a CC3Mesh, and then invoke one of
 * the methods in this extension  to populate the mesh vertices.
 */
@interface CC3VertexArrayMesh (ParametricShapes)


#pragma mark Utility methods

/**
 * Ensures that this mesh has vertexContentType defined.
 *
 * This method is invoked by each of the populateAs... family of methods, prior to populating
 * the mesh contents.
 *
 * The vertexContentType property of this mesh may be set prior to invoking any of the populateAs...
 * family of methods, to define the content type for each vertex.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If you do not need either of the normal or texture coordinates, set the vertexContentTypes
 * property accordingly prior to invoking any of the populateAs... methods.
 */
-(void) ensureVertexContent;


#pragma mark Populating parametric triangles

/**
 * Populates this instance as a simple triangular mesh.
 *
 * The specified face defines the three vertices at the corners of the triangular mesh in 3D space.
 * The vertices within the CC3Face structure are specified in the winding order of the triangular
 * face. The winding order of the specified face determines the winding order of the vertices in
 * the mesh, and the direction of the normal vector applied to each of the vertices. Since the
 * resulting triangular mesh is flat, all vertices will have the same normal vector.
 
 * Although the triangle can be created with the corners can be anywhere in 3D space, for simplicity
 * of construction, it is common practice, when using this method, to specify the mesh in the X-Y
 * plane (where all three corners have a zero Z-component), and then rotate the node containing this
 * mesh to an orientation in 3D space.
 *
 * The texCoords parameter is an array of ccTex2F structures, providing the texture coordinates for
 * the cooresponding vertices of the face. This array must have three elements, one for each vertex
 * in the specified face. If the mesh will not be covered with a texture, you can pass in any values
 * in the elements of this array.
 *
 * The tessellation property determines how the mesh will be tessellated into smaller faces. The
 * specified tessellation value indicates how many divisions each side of the main triangle should
 * be divided into. Each side of the triangular mesh is tessellated into the same number of divisions.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is
 * desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsTriangle: (CC3Face) face
			 withTexCoords: (ccTex2F*) texCoords
		   andTessellation: (GLuint) divsPerSide;


#pragma mark Populating parametric planes

/**
 * Populates this instance as a simple rectangular mesh of the specified size, centered at the origin,
 * and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same as invoking
 * populateAsCenteredRectangleWithSize:andTessellation: with the divsPerAxis argument set to {1,1}.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize;

/**
 * Populates this instance as a simple rectangular mesh of the specified size, centered at the origin,
 * and laid out on the X-Y plane.
 *
 * The large rectangle can be divided into many smaller divisions. Building a rectanglular surface
 * from more than one division can dramatically improve realism when the surface is illuminated with
 * specular lighting or a tightly focused spotlight, because increasing the face count increases the
 * number of vertices that interact with the specular or spot lighting.
 *
 * The divsPerAxis argument indicates how to break this large rectangle into multiple faces. The X & Y
 * elements of the divsPerAxis argument indicate how each axis if the rectangle should be divided into
 * faces. The total number of faces in the rectangle will therefore be the multiplicative product of
 * the X & Y elements of the divsPerAxis argument.
 *
 * For example, a value of {5,5} for the divsPerAxis argument will result in the rectangle being
 * divided into 25 faces, arranged into a 5x5 grid.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) divsPerAxis;

/**
 * Populates this instance as a simple rectangular mesh of the specified size, with the specified
 * relative origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same as invoking
 * the populateAsRectangleWithSize:andRelativeOrigin:andTessellation: with the divsPerAxis argument
 * set to {1,1}.
 *
 * The relative origin is a fractional point that is relative to the rectangle's extent, and indicates
 * where the origin of the rectangular mesh is to be located. The mesh origin is the origin of the
 * local coordinate system of the mesh, and is the basis for all transforms applied to the mesh
 * (including the location and rotation properties).
 *
 * The specified relative origin should be a fractional value. If it is {0, 0}, the rectangle will
 * be laid out so that the bottom-left corner is at the origin. If it is {1, 1}, the rectangle will
 * be laid out so that the top-right corner of the rectangle is at the origin. If it is {0.5, 0.5},
 * the rectangle will be laid out with the origin at the center, as in the
 * populateAsCenteredRectangleWithSize: method.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is
 * desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define
 * the content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal,
 * and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize andRelativeOrigin: (CGPoint) origin;

/**
 * Populates this instance as a simple rectangular mesh of the specified size, with the specified
 * relative origin, and laid out on the X-Y plane.
 *
 * The large rectangle can be divided into many smaller divisions. Building a rectanglular surface
 * from more than one division can dramatically improve realism when the surface is illuminated with
 * specular lighting or a tightly focused spotlight, because increasing the face count increases the
 * number of vertices that interact with the specular or spot lighting.
 *
 * The divsPerAxis argument indicates how to break this large rectangle into multiple faces. The X & Y
 * elements of the divsPerAxis argument indicate how each axis if the rectangle should be divided into
 * faces. The total number of faces in the rectangle will therefore be the multiplicative product of
 * the X & Y elements of the divsPerAxis argument.
 *
 * For example, a value of {5,5} for the divsPerAxis argument will result in the rectangle being
 * divided into 25 faces, arranged into a 5x5 grid.
 *
 * The relative origin is a fractional point that is relative to the rectangle's extent, and indicates
 * where the origin of the rectangular mesh is to be located. The mesh origin is the origin of the
 * local coordinate system of the mesh, and is the basis for all transforms applied to the mesh
 * (including the location and rotation properties).
 *
 * The specified relative origin should be a fractional value. If it is {0, 0}, the rectangle will
 * be laid out so that the bottom-left corner is at the origin. If it is {1, 1}, the rectangle will
 * be laid out so that the top-right corner of the rectangle is at the origin. If it is {0.5, 0.5},
 * the rectangle will be laid out with the origin at the center, as in the
 * populateAsCenteredRectangleWithSize: method.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
				  andRelativeOrigin: (CGPoint) origin
					andTessellation: (ccGridSize) divsPerAxis;


#pragma mark Populating parametric circular disk

/**
 * Populates this instance as a flat, single-sided circular disk mesh of the specified radius,
 * centered at the origin, and laid out on the X-Y plane.
 *
 * The surface of the disk is divided into many smaller divisions, both in the radial and angular dimensions.
 *
 * The radialAndAngleDivs argument indicates how to divide the surface of the disks into divisions.
 * The X element of the radialAndAngleDivs argument indicates how many radial divisions will occur
 * from the center and the circuferential edge. A value of one means that the mesh will consist of
 * a series of radial triangles from the center of the circle to the edge. A larger value for the
 * X element of the radialAndAngleDivs argument will structure the mesh as a series of concentric
 * rings. This value must be at least one.
 * 
 * The Y element of the radialAndAngleDivs argument indicates how many angular divisions will occur
 * around the circumference. This value must be at least three, which will essentially render the
 * circle as a triangle. But, typically, this value will be larger.
 * 
 * For example, a value of {4,24} for the radialAndAngleDivs argument will result in the disk being
 * divided into four concentric rings, each divided into 24 segments around the circumference of the circle.
 * 
 * Each segement, except those in the innermost disk is trapezoidal, and will be constructed from two
 * triangular mesh faces. Therefore, the number of triangles in the mesh will be (2X - 1) * Y, where
 * X = radialAndAngleDivs.x and Y = radialAndAngleDivs.y.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The texture is mapped to the tessellated disk as if a tagential square was overlaid over the circle,
 * starting from the lower left corner, where both X and Y are at a minimum. The center of the disk
 * maps to the center of the texture.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsDiskWithRadius: (GLfloat) radius andTessellation: (ccGridSize) radialAndAngleDivs;


#pragma mark Populating parametric boxes

/**
 * Populates this instance as a simple rectangular box mesh from the specified bounding box, which
 * contains two of the diagonal corners of the box.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is to be wrapped around this mesh, since the single texture is wrapped around all six
 * sides of the box, the texture will be mapped according to the layout illustrated in the texture
 * file BoxTexture.png, included in the distribution.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the "top" of the box is
 * the side that faces towards the positive-Y axis, and the "right" side of the box is the side that
 * faces towards the positive-X axis.
 *
 * For the purposes of wrapping a texture around the box, the texture will wrap uniformly around all
 * sides, and the texture will not appear stretched between any two adjacent sides. This is useful when
 * you are texturing the box with a simple rectangular repeating pattern and want the texture to appear
 * consistent across the sides, for example, a brick pattern wrapping around all four sides of a house.
 *
 * Depending on the relative aspect of the height and width of the box, the texture may appear distorted
 * horizontal or vertically. If you need to correct that, you can use the repeatTexture: method, and
 * adjust one of the dimensions.
 *
 * For higher fidelity in applying textures to non-cube boxes, so that the texture will not be stretched
 * to fit, use the populateAsSolidBox:withCorner: method.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture template file for this method.
 */
-(void) populateAsSolidBox: (CC3BoundingBox) box;

/**
 * Populates this instance as a simple rectangular box mesh from the specified bounding box, which
 * contains two of the diagonal corners of the box.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is to be wrapped around this mesh, since the single texture is wrapped around all six
 * sides of the box, the texture will be mapped according to the layout illustrated in the texture
 * file BoxTexture.png, included in the distribution.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the "top" of the box
 * is the side that faces towards the positive-Y axis, and the "right" side of the box is the side
 * that faces towards the positive-X axis.
 *
 * For the purposes of wrapping the texture around the box, this method assumes that the texture is
 * an unfolded cube. The box can be created with any relative dimensions, but if it is not a cube,
 * the texture may appear stretched or shrunk on two or more sides. The texture will still fully wrap
 * all six sides of the box, but the texture is stretched or shrunk to fit each side according to its
 * dimension relative to the other sides. The appearance will be as if you had started with a textured
 * cube and then pulled one or two of the dimensions out further.
 *
 * For higher fidelity in applying textures to non-cube boxes, so that the texture will not be stretched
 * to fit, use either of the populateAsSolidBox: or populateAsSolidBox:withCorner: methods, with a
 * texture whose layout is compatible with the aspect ratio of the box.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture template file for this method.
 */
-(void) populateAsCubeMappedSolidBox: (CC3BoundingBox) box;

/**
 * Populates this instance as a simple rectangular box mesh from the specified bounding box, which
 * contains two of the diagonal corners of the box, and configures the mesh texture coordinates so
 * that the entire box can be wrapped in a single texture.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh is to be covered
 * with a texture, use the texture property of this mesh to set the texture. If a solid color is desired,
 * leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is to be wrapped around this mesh, since the single texture is wrapped around all six
 * sides of the box, the texture will be mapped according to the layout illustrated in the texture file
 * BoxTexture.png, included in the distribution.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the "top" of the box
 * is the side that faces towards the positive-Y axis, and the "right" side of the box is the side
 * that faces towards the positive-X axis.
 *
 * For the purposes of wrapping the texture around the box, the corner argument specifies the relative
 * point in the texture that will map to the corner of the box that is at the juncture of the "left",
 * "front" and "bottom" sides (see the BoxTexture.png image for a better understanding of this point).
 * The corner argument is specified as a fraction in each of the S & T dimensions of the texture.
 * In the CGPoint that specifies the corner, the x & y elements of the CGPoint correspond to the S & T
 * dimensions of this left-front-bottom corner mapping, with each value being between zero and one.
 *
 * Since, by definition, opposite sides of the box have the same dimensions, this single corner point
 * identifies the S & T dimensions of all six of the sides of the box. A value of (1/4, 1/3) for the
 * corner is used when the box is a cube. A smaller value for the x-element would move the corner to
 * the left in the texture layout, indicating that the left and right sides are shallower than they
 * are in a cube, and that the front and back are wider than in a cube, and vice-versa for a larger
 * value in the x-element of the corner. Similarly for the y-element. A y-element that is smaller
 * than 1/3, moves the corner point downwards on the texture, indicating that the bottom and top are
 * shallower than they are in a cube, or that the front and back are higher than they are in a cube.
 *
 * The two axes defined by the corner are interrelated, because the sides need to be the same depth as
 * the top and bottom. The best way to determine the values to use in the corner is to use the measure
 * of this point (where the "left", "front", and "bottom" sides meet) from the layout of the texture.
 * If the aspect of the corner on the texture does not align with the aspect of the width, height and
 * depth of the box, the texture will appear stretched on one or two sides relative to the others.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture template file for this method.
 */
-(void) populateAsSolidBox: (CC3BoundingBox) box withCorner: (CGPoint) corner;

/**
 * Populates this instance as a wire-frame box with the specified dimensions.
 *
 * You can add a material or pureColor as desired to establish the color of the lines
 * of the wire-frame. If a material is used, the appearance of the lines will be affected
 * by the lighting conditions. If a pureColor is used, the appearance of the lines will
 * not be affected by the lighting conditions, and the wire-frame box will always appear
 * in the same pure, solid color, regardless of the lighting sources.
 *
 * This is a convenience method for creating a simple, but useful, shape.
 */
-(void) populateAsWireBox: (CC3BoundingBox) box;


#pragma mark Populating parametric sphere

/**
 * Populates this instance as a spherical mesh of the specified radius, centered at the origin.
 *
 * The surface of the sphere is divided into many smaller divisions, similar to latitude and
 * longtitude divisions. The sphere mesh contains two poles, where the surface intersects the
 * positive and negative Y-axis.
 *
 * The divsPerAxis argument indicates how to divide the surface of the sphere into divisions.
 * The X element of the divsPerAxis argument indicates how many longtitude divisions will
 * occur around one circumnavigation of the equator. The Y element of the divsPerAxis argument
 * indicates how many latitude divisions will occur between the north pole and the south pole.
 * 
 * For example, a value of {12,8} for the divsPerAxis argument will result in the sphere being
 * divided into twelve divisions of longtitude around the equator, and eight divisions of
 * latitude between the north and south poles.
 *
 * Except at the poles, each division is roughly trapezoidal and is drawn as two triangles.
 * At the poles, each division is a single triangle.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this mesh to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is applied to this mesh, it is mapped to the sphere with a simple cylindrical
 * projection around the equator (similar to Mercator projection without the north-south stretching).
 * This type of projection is typical of maps of the earth taken from space, and results in the
 * smooth curving of any texture around the sphere from the equator to the poles. Texture wrapping
 * begins at the negative Z-axis, so the center of the texture will be positioned at the point where
 * the sphere intersects the positive Z-axis, and the conceptual seam (where the left and right
 * edges of the texture are stitched together) will occur where the sphere intersects the plane
 * (X = 0) along the negative-Z axis. This texture orientation means that the center of the texture
 * will face the forwardDirection of the sphere node.
 */
-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (ccGridSize) divsPerAxis;


#pragma mark Populating parametric cone

/**
 * Populates this instance as a conical mesh of the specified radius and height.
 *
 * The mesh is constructed so that the base of the cone is centered on the origin of the X-Z plane,
 * and the apex is on the positive Y-axis at the specified height. The cone is open and does not
 * have a bottom.
 *
 * The surface of the cone is divided into many smaller divisions, as specified by the
 * angleAndHeightsDivs parameter. The X-coordinate of this parameter indicates how many angular
 * divisions are created around the circumference of the base, and the Y-coordinate of this
 * parameter indicates how many vertical divisions are created between the base and the apex.
 * 
 * For example, a value of {12,8} for the angleAndHeightsDivs parameter will result in a cone with
 * 12 divisions around the circumference of the base, and 8 divisions along the Y-axis to the apex.
 *
 * By reducing the number of angular divisions to 3 or 4, you can use this method to create a
 * tetrahedron or square pyramid, respectively.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this mesh to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is applied to this mesh, it is mapped to the cone with a simple horizontal
 * projection. Horizontal lines in the texture will remain parallel, but vertical lines will
 * converge at the apex. Texture wrapping begins at the negative Z-axis, so the center of the
 * texture will be positioned at the point where the cone intersects the positive Z-axis, and
 * the conceptual seam (where the left and right edges of the texture are stitched together)
 * will occur where the cone intersects the negative-Z axis. This texture orientation means
 * that the center of the texture will face the forwardDirection of the cone node.
 */
-(void) populateAsHollowConeWithRadius: (GLfloat) radius
								height: (GLfloat) height
					   andTessellation: (ccGridSize) angleAndHeightDivs;


#pragma mark Populating parametric lines

/**
 * Populates this instance as a line strip with the specified number of vertex points.
 * The data for the points that define the end-points of the lines are contained within the
 * specified vertices array. The vertices array must contain at least vertexCount elements.
 *
 * The lines are specified and rendered as a strip, where each line is connected to the
 * previous and following lines. Each line starts at the point where the previous line ended,
 * and that point is defined only once in the vertices array. Therefore, the number of lines
 * drawn is equal to one less than the specified vertexCount.
 * 
 * The shouldRetainVertices flag indicates whether the data in the vertices array should
 * be retained by this instance. If this flag is set to YES, the data in the vertices array
 * will be copied to an internal array that is managed by this instance. If this flag is
 * set to NO, the data is not copied internally and, instead, a reference to the vertices
 * data is established. In this case, it is up to you to manage the lifespan of the data
 * contained in the vertices array.
 *
 * If you are defining the vertices data dynamically in another method, you may want to
 * set this flag to YES to have this instance copy and manage the data. If the vertices
 * array is a static array, you can set this flag to NO.
 *
 * You can add a material or pureColor as desired to establish the color of the lines.
 * If a material is used, the appearance of the lines will be affected by the lighting
 * conditions. If a pureColor is used, the appearance of the lines will not be affected
 * by the lighting conditions, and the wire-frame box will always appear in the same pure,
 * solid color, regardless of the lighting sources.
 *
 * This is a convenience method for creating a simple, but useful, shape.
 */
-(void) populateAsLineStripWith: (GLuint) vertexCount
					   vertices: (CC3Vector*) vertices
					  andRetain: (BOOL) shouldRetainVertices;


#pragma mark Populating for bitmapped font textures

/**
 * Populates this instance as a rectangular mesh displaying the text of the specified string,
 * built from bitmap character images taken from a texture atlas as defined by the specified
 * bitmapped font configuration.
 *
 * The texture that matches the specified font configuration (and identified in the font configuration),
 * should be loaded and assigned to the texture property of the mesh node that uses this mesh.
 *
 * The text may be multi-line, and can be left-, center- or right-aligned, as specified.
 *
 * The specified lineHeight define the height of a line of text in the coordinate system of this
 * mesh. This parameter can be set to zero to use the natural line height of the font.
 *
 * For example, a font with font size of 16 might have a natural line height of 19. Setting the
 * lineHeight parameter to zero would result in a mesh where a line of text would be 19 units high.
 * On the other hand, setting this property to 0.2 will result in a mesh where the same line of text
 * has a height of 0.2 units. Depending on the size of other models in your scene, you may want to
 * set this lineHeight to something compatible. In addition, the visual size of the text will also
 * be affected by the value of the scale or uniformScale properties of any mesh node using this mesh.
 * Both the lineHeight and the node scale work to establish the visual size of the label text.
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions.
 * Building a rectanglular surface from more than one division can dramatically improve realism
 * when the surface is illuminated with specular lighting or a tightly focused spotlight, or if
 * the mesh is to be deformed in some way by a later process (such as wrapping the text texture
 * around some other shape).
 *
 * The divsPerChar argument indicates how to break each character rectangle into multiple faces.
 * The X & Y elements of the divsPerChar argument indicate how each axis if the rectangle for each
 * character should be divided into faces. The number of faces in the rectangle for each character
 * will therefore be the multiplicative product of the X & Y elements of the divsPerChar argument.
 *
 * For example, a value of {3,2} for the divsPerChar argument will result in each character being
 * divided into 6 smaller rectangular faces, arranged into a 3x2 grid.
 *
 * The relative origin defines the location of the origin for texture alignment, and is specified
 * as a fraction of the size of the overall label layout, starting from the bottom-left corner.
 *
 * For example, origin values of (0, 0), (0.5, 0.5), and (1, 1) indicate that the label mesh should
 * be aligned so that the bottom-left corner, center, or top-right corner, respectively, should be
 * located at the local origin of the corresponding mesh.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * This method may be invoked repeatedly to change the label string. The mesh will automomatically
 * be rebuilt to the correct number of vertices required to display the currently specified string.
 */
-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
									andFont: (CC3BMFontConfiguration*) fontConfig
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (UITextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (ccGridSize) divsPerChar;


#pragma mark -
#pragma mark Deprecated methods

/**
 * @deprecated Use the vertexContentTypes property, followed by the allocatedVertexCapacity property, instead.
 * You can also use the prepareParametricMesh method to automatically established textured vertices
 * if the vertexContentTypes property has not been set.
 */
-(CC3TexturedVertex*) allocateTexturedVertices: (GLuint) vertexCount;

/** @deprecated Use allocatedVertexIndexCapacity = (triangleCount * 3) instead. */
-(GLushort*) allocateIndexedTriangles: (GLuint) triangleCount;

@end


