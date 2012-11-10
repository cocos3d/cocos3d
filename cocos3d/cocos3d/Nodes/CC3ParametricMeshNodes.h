/*
 * CC3ParametricMeshNodes.h
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

#import "CC3MeshNode.h"
#import "CC3ParametricMeshes.h"


#pragma mark -
#pragma mark CC3MeshNode parametric shapes extension

/**
 * This CC3MeshNode extension adds a number of methods for populating the mesh of a
 * mesh node programatically to create various parametric shapes and surfaces.
 *
 * To use the methods in this extension, instantiate a CC3MeshNode, and then invoke
 * one of the methods in this extension of CC3MeshNode in order to populate the mesh
 * vertices.
 *
 * Depending on the shape of the mesh you are creating, you may want to actually
 * instantiate one of the specialized subclasses of CC3MeshNode, since they often
 * add more functionality to the specific shape.
 */
@interface CC3MeshNode (ParametricShapes)


#pragma mark Utility methods

/**
 * Ensures that the contained mesh has been created, is of type CC3VertexArrayMesh, and has
 * vertexContentType defined, then returns the the mesh, cast as a CC3VertexArrayMesh.
 *
 * This method is invoked by each of the populateAs... family of methods, prior to populating
 * the mesh contents.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking any of the
 * populateAs... family of methods, to define the content type for each vertex.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If you do not need either of the normal or texture coordinates, set the vertexContentTypes
 * property accordingly prior to invoking any of the populateAs... methods.
 */
-(CC3VertexArrayMesh*) prepareParametricMesh;


#pragma mark Populating parametric triangles

/**
 * Populates this instance as a simple triangular mesh.
 *
 * The specified face defines the three vertices at the corners of the triangular mesh in 3D space.
 * The vertices within the CC3Face structure are specified in the winding order of the triangular
 * face. The winding order of the specified face determines the winding order of the vertices in
 * the mesh, and the direction of the normal vector applied to each of the vertices. Since the
 * resulting triangular mesh is flat, all vertices will have the same normal vector.
 
 * Although the triangle can be created with the corners can be anywhere in 3D space, for
 * simplicity of construction, it is common practice, when using this method, to specify the
 * mesh in the X-Y plane (where all three corners have a zero Z-component), and then rotate
 * this node to an orientation in 3D space.
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
 * Populates this instance as a simple rectangular mesh of the specified size,
 * centered at the origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is
 * the same as invoking populateAsCenteredRectangleWithSize:andTessellation: with
 * the divsPerAxis argument set to {1,1}.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize;

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * centered at the origin, and laid out on the X-Y plane.
 *
 * The large rectangle can be divided into many smaller divisions. Building a rectanglular
 * surface from more than one division can dramatically improve realism when the surface is
 * illuminated with specular lighting or a tightly focused spotlight, because increasing the
 * face count increases the number of vertices that interact with the specular or spot lighting.
 *
 * The divsPerAxis argument indicates how to break this large rectangle into multiple faces.
 * The X & Y elements of the divsPerAxis argument indicate how each axis if the rectangle
 * should be divided into faces. The total number of faces in the rectangle will therefore
 * be the multiplicative product of the X & Y elements of the divsPerAxis argument.
 *
 * For example, a value of {5,5} for the divsPerAxis argument will result in the rectangle
 * being divided into 25 faces, arranged into a 5x5 grid.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
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
 * Populates this instance as a flat, single-sided circular disk mesh of the specified
 * radius, centered at the origin, and laid out on the X-Y plane.
 *
 * The surface of the disk is divided into many smaller divisions, both in the radial and
 * angular dimensions.
 *
 * The radialAndAngleDivs argument indicates how to divide the surface of the disks into
 * divisions. The X element of the radialAndAngleDivs argument indicates how many radial
 * divisions will occur from the center and the circuferential edge. A value of one means
 * that the mesh will consist of a series of radial triangles from the center of the
 * circle to the edge. A larger value for the X element of the radialAndAngleDivs argument
 * will structure the mesh as a series of concentric rings. This value must be at least one.
 * 
 * The Y element of the radialAndAngleDivs argument indicates how many angular divisions
 * will occur around the circumference. This value must be at least three, which will
 * essentially render the circle as a triangle. But, typically, this value will be larger.
 * 
 * For example, a value of {4,24} for the radialAndAngleDivs argument will result in the
 * disk being divided into four concentric rings, each divided into 24 segments around the
 * circumference of the circle.
 * 
 * Each segement, except those in the innermost disk is trapezoidal, and will be constructed
 * from two triangular mesh faces. Therefore, the number of triangles in the mesh will be
 * (2X - 1) * Y, where X = radialAndAngleDivs.x and Y = radialAndAngleDivs.y.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The texture is mapped to the tessellated disk as if a tagential square was overlaid over
 * the circle, starting from the lower left corner, where both X and Y are at a minimum.
 * The center of the disk maps to the center of the texture.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 */
-(void) populateAsDiskWithRadius: (GLfloat) radius andTessellation: (ccGridSize) radialAndAngleDivs;


#pragma mark Populating parametric boxes

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners of the box.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is to be wrapped around this mesh, since the single texture is wrapped
 * around all six sides of the box, the texture will be mapped according to the layout
 * illustrated in the texture file BoxTexture.png, included in the distribution.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the "top"
 * of the box is the side that faces towards the positive-Y axis, and the "right" side
 * of the box is the side that faces towards the positive-X axis.
 *
 * For the purposes of wrapping a texture around the box, the texture will wrap
 * uniformly around all sides, and the texture will not appear stretched between any
 * two adjacent sides. This is useful when you are texturing the box with a simple
 * rectangular repeating pattern and want the texture to appear consistent across
 * the sides, for example, a brick pattern wrapping around all four sides of a house.
 *
 * Depending on the relative aspect of the height and width of the box, the texture
 * may appear distorted horizontal or vertically. If you need to correct that, you
 * can use the repeatTexture: method, and adjust one of the dimensions.
 *
 * For higher fidelity in applying textures to non-cube boxes, so that the texture
 * will not be stretched to fit, use the populateAsSolidBox:withCorner: method.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture
 * template file for this method.
 */
-(void) populateAsSolidBox: (CC3BoundingBox) box;

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners of the box.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is to be wrapped around this mesh, since the single texture is wrapped
 * around all six sides of the box, the texture will be mapped according to the layout
 * illustrated in the texture file BoxTexture.png, included in the distribution.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the "top"
 * of the box is the side that faces towards the positive-Y axis, and the "right" side
 * of the box is the side that faces towards the positive-X axis.
 *
 * For the purposes of wrapping the texture around the box, this method assumes that
 * the texture is an unfolded cube. The box can be created with any relative dimensions,
 * but if it is not a cube, the texture may appear stretched or shrunk on two or more
 * sides. The texture will still fully wrap all six sides of the box, but the texture
 * is stretched or shrunk to fit each side according to its dimension relative to the
 * other sides. The appearance will be as if you had started with a textured cube and
 * then pulled one or two of the dimensions out further.
 *
 * For higher fidelity in applying textures to non-cube boxes, so that the texture
 * will not be stretched to fit, use either of the populateAsSolidBox: or
 * populateAsSolidBox:withCorner: methods, with a texture whose layout is compatible
 * with the aspect ratio of the box.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture
 * template file for this method.
 */
-(void) populateAsCubeMappedSolidBox: (CC3BoundingBox) box;

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners of the box, and
 * configures the mesh texture coordinates so that the entire box can be wrapped
 * in a single texture.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
 * to define the content type for each vertex. Content types kCC3VertexContentLocation,
 * kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate).
 * and the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * If a texture is to be wrapped around this mesh, since the single texture is wrapped
 * around all six sides of the box, the texture will be mapped according to the layout
 * illustrated in the texture file BoxTexture.png, included in the distribution.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the
 * "top" of the box is the side that faces towards the positive-Y axis, and the
 * "right" side of the box is the side that faces towards the positive-X axis.
 *
 * For the purposes of wrapping the texture around the box, the corner argument
 * specifies the relative point in the texture that will map to the corner of the
 * box that is at the juncture of the "left", "front" and "bottom" sides (see the
 * BoxTexture.png image for a better understanding of this point). The corner
 * argument is specified as a fraction in each of the S & T dimensions of the texture.
 * In the CGPoint that specifies the corner, the x & y elements of the CGPoint
 * correspond to the S & T dimensions of this left-front-bottom corner mapping,
 * with each value being between zero and one.
 *
 * Since, by definition, opposite sides of the box have the same dimensions, this
 * single corner point identifies the S & T dimensions of all six of the sides of
 * the box. A value of (1/4, 1/3) for the corner is used when the box is a cube.
 * A smaller value for the x-element would move the corner to the left in the
 * texture layout, indicating that the left and right sides are shallower than
 * they are in a cube, and that the front and back are wider than in a cube, and
 * vice-versa for a larger value in the x-element of the corner. Similarly for
 * the y-element. A y-element that is smaller than 1/3, moves the corner point
 * downwards on the texture, indicating that the bottom and top are shallower than
 * they are in a cube, or that the front and back are higher than they are in a cube.
 *
 * The two axes defined by the corner are interrelated, because the sides need to
 * be the same depth as the top and bottom. The best way to determine the values to
 * use in the corner is to use the measure of this point (where the "left", "front",
 * and "bottom" sides meet) from the layout of the texture. If the aspect of the
 * corner on the texture does not align with the aspect of the width, height and
 * depth of the box, the texture will appear stretched on one or two sides relative
 * to the others.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture
 * template file for this method.
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
 * As this node is translated, rotate and scaled, the wire-frame box will be re-oriented
 * in 3D space.
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
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 *
 * The vertexContentType property of this mesh node may be set prior to invoking this method,
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
 *
 * The boundingVolume of this node is automatically set to a spherical shape (an instance of 
 * CC3VertexLocationsSphericalBoundingVolume) to match the shape of this mesh.
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
 * built from bitmap character images taken from a texture atlas as defined by the bitmpped font
 * configuration loaded from the specified font configuration file.
 *
 * A compatible bitmap font configuration file, and associated texture, can be created using any
 * of these editors:
 *    http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *    http://www.bmglyph.com/ (Commercial, Mac OS X - also available through AppStore)
 *    http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *    http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *    http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 *
 * The texture that matches the specified font configuration (and identified in the font configuration),
 * is automatically loaded and assigned to the texture property of this mesh node.
 *
 * The text may be multi-line, and can be left-, center- or right-aligned, as specified.
 *
 * The specified lineHeight define the height of a line of text in the coordinate system of this
 * mesh node. This parameter can be set to zero to use the natural line height of the font.
 *
 * For example, a font with font size of 16 might have a natural line height of 19. Setting the
 * lineHeight parameter to zero would result in a mesh where a line of text would be 19 units high.
 * On the other hand, setting this property to 0.2 will result in a mesh where the same line of text
 * has a height of 0.2 units. Depending on the size of other models in your scene, you may want to
 * set this lineHeight to something compatible. In addition, the visual size of the text will also
 * be affected by the value of the scale or uniformScale properties of this node. Both the lineHeight
 * and scale properties work to establish the visual size of the label text.
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
							   fromFontFile: (NSString*) fontFileName
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (UITextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (ccGridSize) divsPerChar;

@end


#pragma mark -
#pragma mark CC3SimpleLineNode

/**
 * CC3SimpleLineNode simplifies the creation of a simple two-point straight line.
 *
 * You can create a single simple straight line model by instantiating an instance of this
 * class and then setting either or both of the lineStart and lineEnd properties.
 *
 * The mesh underlying this node is automatically populated as a simple two-vertex line.
 * When using this class, you do not need to use any of the populateAs... methods to generate
 * and populate the mesh.
 */
@interface CC3SimpleLineNode : CC3LineNode

/**
 * Indicates the start of the line in the local coordinate system of this node.
 *
 * The initial value is kCC3VectorZero, indicating that the line starts at the origin of
 * the local coordinate system.
 */
@property(nonatomic, assign) CC3Vector lineStart;

/**
 * Indicates the end of the line in the local coordinate system of this node.
 *
 * The initial value is kCC3VectorZero, indicating that the line ends at the origin of
 * the local coordinate system.
 */
@property(nonatomic, assign) CC3Vector lineEnd;

@end


#pragma mark -
#pragma mark CC3TouchBox

/**
 * CC3TouchBox is a specialized node that creates an invisible box mesh that can be used to
 * define a 3D region for touch activity.
 *
 * If you do not set the box property explicitly, when you add an instance of this class as a child
 * of another CC3Node, this node will automatically be populated as a box the same size as the
 * bounding box of that parent. If the parent node contains other nodes, its bounding box will
 * include its descendants, resulting in this mesh being populated to encapsulate all descendant
 * nodes of its parent. The effect is to define a box-shaped touch region around a composite node
 * that might be comprised of a number of smaller nodes with space in between them.
 *
 * If the parent node contains descendants that are moving around, the bounding box of the parent
 * node may be dynamic and constantly changing. If you want the touch box to track changes to the
 * parent bounding box, set the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * You can also set the box property directly to create a box that is shaped differently than the
 * bounding box of the parent. For example, you might want to do this if you want the touch box to
 * be larger than the actual visible nodes, in order to make it easier to touch.
 *
 * The mesh underlying this node is automatically populated when you set the box property, or when
 * you add this node to a parent. You do not need to invoke any of the populateAs... methods directly.
 *
 * Since this node is intended to be used as an invisible touch pad, the visible property of this node
 * is initially set to NO, and the shouldAllowTouchableWhenInvisible property is initially set to YES.
 * In addition, the bounding box of this mesh will not contribute to the bounding box of the parent.
 */
@interface CC3TouchBox : CC3BoxNode {
	BOOL shouldAlwaysMeasureParentBoundingBox : 1;
}

/**
 * Indicates the size of the touch box.
 *
 * Setting this property populates this node with a box mesh of the specified extent.
 *
 * Instead of setting this property directly, you can automatically create the box mesh by simply
 * adding this node to a parent CC3Node. If this property has not already been set when this node
 * is added to a parent, the value of this property will automatically be set to the value of the
 * boundingBox property of the parent.
 *
 * If the parent node contains descendants that are moving around, the bounding box of the parent
 * node may be dynamic and constantly changing. If you want the touch box to track changes to the
 * parent bounding box, set the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * If you set this property directly, and then subsequently add this node to a parent, the value
 * of this property will not change, and the underlying mesh will not be repopulated. By setting
 * the value of this property directly, you can create a mesh box that is of a different size
 * than the parent bounding box.
 *
 * Setting this property to kCC3BoundingBoxNull will remove the underlying mesh.
 *
 * The initial value of this property is kCC3BoundingBoxNull.
 */
@property(nonatomic, assign) CC3BoundingBox box;

/**
 * Indicates whether the dimensions of this node should automatically be remeasured on each update pass.
 *
 * If this property is set to YES, the box will automatically be resized to account for movements by
 * any descendant nodes of the parent node. To create a dynamic touch box that automatically adjusts
 * as the descendants of the parent node move around, this property should be set to YES.
 *
 * It is not necessary to set this property to YES to account for changes in the transform properties
 * of the parent node itself.
 *
 * When setting this property, be aware that dynamically measuring the bounding box of the parent node
 * can be an expensive operation if the parent contains a number of descendant nodes.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldAlwaysMeasureParentBoundingBox;

@end


#pragma mark -
#pragma mark CC3BitmapLabelNode

/**
 * CC3BitmapLabelNode displays a rectangular mesh displaying the text of a specified string,
 * built from bitmap character images taken from a texture atlas as defined by a bitmpped font
 * configuration loaded from a font configuration file.
 *
 * The labelString property specifies the string that is to be displayed in the bitmap font described
 * in the bitmpa font file identified by the fontFileName property.
 *
 * A compatible bitmap font configuration file, and associated texture, can be created using any
 * of these editors:
 *    http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *    http://www.bmglyph.com/ (Commercial, Mac OS X - also available through AppStore)
 *    http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *    http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *    http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 *
 * The texture that matches the specified font configuration (and identified in the font configuration),
 * is automatically loaded and assigned to the texture property of this mesh node.
 *
 * The text may be multi-line, and can be left-, center- or right-aligned, as specified by the
 * textAlignment property. The resulting mesh can be positioned with its origin anywhere within
 * the text rectangle using the relativeOrigin property.
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions as
 * defined by the tessellation property.
 *
 * The properties of this class can be changed at any time to display a different text string, or to
 * change the visual aspects of the label. Changing any of the properties in this class causes the
 * underlying mesh to be automatically rebuilt.
 *
 * The vertexContentType property of this mesh may be set to define the content type for each vertex.
 * Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate
 * are populated by this method.
 *
 * If the vertexContentType property is not explicitly set, that property is automatically set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and the
 * mesh will be populated with location, normal and texture coordinates for each vertex.
 */
@interface CC3BitmapLabelNode : CC3MeshNode {
	NSString* labelString;
	NSString* fontFileName;
	CC3BMFontConfiguration* fontConfig;
	UITextAlignment textAlignment;
	CGPoint relativeOrigin;
	ccGridSize tessellation;
	GLfloat lineHeight;
}

/**
 * Indicates the string to be displayed. This string may include newline characters (\n) to
 * create a multi-line label.
 *
 * This property can be changed at any time to display a different text string.
 */
@property(nonatomic, retain) NSString* labelString;

/**
 * Indicates the name of the bitmap font file that contains the specifications of the font used
 * to display the text.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, retain) NSString* fontFileName;

/**
 * The line height in the local coordinate system of this node.
 *
 * This property can be changed at any time to change the size of the label layout.
 *
 * The initial value of this property is zero. If the value of this property is not explicitly set
 * to another value, it will return the value from the font configuration, once the fontFileName
 * property is set, resulting in this label taking on the unscaled line height of the bitmapped font.
 */
@property(nonatomic, assign) GLfloat lineHeight;

/**
 * For multi-line labels, indicates how the lines should be aligned.
 *
 * The initial value of this property is UITextAlignmentLeft, indicating that multi-line text will
 * be left-aligned.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, assign) UITextAlignment textAlignment;

/**
 * Indicates the location of the origin of the mesh, and is specified as a fraction of the size of
 * the overall label layout, starting from the bottom-left corner. The origin determines how the
 * mesh will be positioned by the location property of this node, and is the point around which
 * any rotational transformations take place.
 *
 * For example, origins of (0,0), (0.5,0.5), and (1,1) indicate that the label mesh should be aligned
 * so that the bottom-left corner, center, or top-right corner of the label text, respectively,
 * should be located at the local origin of the corresponding mesh.
 *
 * After the fontFileName property has been set, you can make use of the value of the baseline property
 * to locate the local origin on the baseline of the font, by setting this property to (X, self.baseline),
 * where X is a fraction indicating where the origin should be positioned horizontally.
 *
 * The initial value of this property is {0,0}, indicating that this label node will have its origin
 * at the bottom-left corner of the label text.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, assign) CGPoint relativeOrigin;

/**
 * Indicates the granularity of the mesh for each character. 
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions within the
 * mesh. This essentially defines how many rectangular faces (quads) should be used to create each character.
 *
 * Building a rectangular surface from multiple faces can dramatically improve realism when the surface
 * is illuminated with specular lighting or a tightly focused spotlight, or if the mesh is to be deformed
 * in some way by a later process (such as wrapping the text texture around some other shape).
 *
 * The X & Y elements of this property indicate how each axis if the rectangle for each character should
 * be divided into faces. The number of rectangular faces (quads) in the rectangle for each character will
 * therefore be the multiplicative product of the X & Y elements of this property.
 *
 * For example, if this property has a value of {3,2}, each character will be constructed from six smaller
 * rectangular faces, arranged into a 3x2 grid.
 *
 * The initial value of this property is {1,1}, indicating that, within the underlying mesh, each character
 * will be constructed from a single rectangular face.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, assign) ccGridSize tessellation;

/**
 * Returns the nominal size of the font, in points or pixels.
 *
 * This property returns zero if the fontFileName property has not been set.
 */
@property(nonatomic, readonly) GLfloat fontSize;

/**
 * Returns the position of the baseline of the font, as a fraction of the lineHeight property,
 * as measured from the bottom of the label.
 * 
 * After setting the fontFileName property, you can use this property to set the relativeOrigin
 * property if you want to position the local origin of this label on the baseline of the font.
 * See the relativeOrigin property for more info.
 *
 * This property returns zero if the fontFileName property has not been set.
 */
@property(nonatomic, readonly) GLfloat baseline;

@end


#pragma mark -
#pragma mark Deprecated CC3MeshNode parametric shapes

@interface CC3MeshNode (DeprecatedParametricShapes)

/** @deprecated Renamed to populateAsRectangleWithSize:andRelativeOrigin:. */
-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to populateAsRectangleWithSize:andRelativeOrigin:andTessellation. */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) divsPerAxis DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use populateAsCenteredRectangleWithSize:, as it creates a
 * rectangular mesh that can be covered with either a texture or a solid color.
 */
-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use populateAsCenteredRectangleWithSize:andTessellation:, as it creates
 * a rectangular mesh that can be covered with either a texture or a solid color.
 */
-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize
									andTessellation: (ccGridSize) divsPerAxis DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use populateAsRectangleWithSize:andRelativeOrigin:, as it creates a
 * rectangular mesh that can be covered with either a texture or a solid color.
 */
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use populateAsRectangleWithSize:andRelativeOrigin:andTessellation:, as it creates
 * a rectangular mesh that can be covered with either a texture or a solid color.
 */
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize
								   andPivot: (CGPoint) pivot
							andTessellation: (ccGridSize) divsPerAxis DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsCenteredRectangleWithSize: method instead,
 * and then use the texture property of this node to set the texture.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsCenteredRectangleWithSize:andTessellation:
 * method instead, and then use the texture property of this node to set the texture.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) divsPerAxis
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsRectangleWithSize:andRelativeOrigin: method instead,
 * and then use the texture property of this node to set the texture.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsCenteredRectangleWithSize:andRelativeOrigin:andTessellation:
 * method instead, and then use the texture property of this node to set the texture.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) divsPerAxis
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use populateAsSolidBox:, as it creates a box mesh
 * that can be covered with either a texture or a solid color.
 */
-(void) populateAsTexturedBox: (CC3BoundingBox) box DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to populateAsSolidBox:withCorner:. */
-(void) populateAsTexturedBox: (CC3BoundingBox) box withCorner: (CGPoint) corner DEPRECATED_ATTRIBUTE;

@end

