/*
 * CC3ParametricMeshNodes.h
 *
 * cocos3d 0.7.1
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
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) divsPerAxis;

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * with the specified pivot point at the origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsRectangleWithSize:andPivot:andTessellation: with the divsPerAxis
 * argument set to {1,1}.
 *
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredRectangleWithSize: method.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot;

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * with the specified pivot point at the origin, and laid out on the X-Y plane.
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
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredRectangleWithSize method.
 *
 * This mesh can be covered with a solid material or a single texture. If this mesh
 * is to be covered with a texture, use the texture property of this node to set
 * the texture. If a solid color is desired, leave the texture property unassigned.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
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
 * will not be stretched to fit, use the populateAsTexturedBox:withCorner: method.
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
 * The texture is mapped to the sphere with a simple cylindrical projection around
 * the equator (similar to Mercator projection without the north-south stretching).
 * This type of projection is typical of maps of the earth taken from space, and
 * results in the smooth curving of any texture around the sphere from the equator
 * to the poles. Texture wrapping begins at the negative Z-axis, so the center of
 * the texture will be positioned at the point where the sphere intersects the
 * positive Z-axis, and the conceptual seam (where the left and right edges of the
 * texture are stitched together) will occur where the sphere intersects the plane
 * (X = 0) along the negative-Z axis. This texture orientation means that the center
 * of the texture will face the forwardDirection of the sphere node.
 */
-(void) populateAsSphereWithRadius: (GLfloat) radius andTessellation: (ccGridSize) divsPerAxis;


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
 * As this node is translated, rotate and scaled, the line strip will be re-oriented
 * in 3D space.
 *
 * This is a convenience method for creating a simple, but useful, shape.
 */
-(void) populateAsLineStripWith: (GLshort) vertexCount
					   vertices: (CC3Vector*) vertices
					  andRetain: (BOOL) shouldRetainVertices;


#pragma mark Deprecated parametric methods

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
 * @deprecated Use populateAsRectangleWithSize:andPivot:, as it creates a
 * rectangular mesh that can be covered with either a texture or a solid color.
 */
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use populateAsRectangleWithSize:andPivot:andTessellation:, as it creates
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
 * @deprecated Use the populateAsRectangleWithSize:andPivot: method instead,
 * and then use the texture property of this node to set the texture.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsCenteredRectangleWithSize:andPivot:andTessellation:
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



