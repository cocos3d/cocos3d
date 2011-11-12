/*
 * CC3ParametricMeshNodes.h
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
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsCenteredRectangleWithSize:andTessellation: with the facesPerSide
 * argument set to {1,1}.
 *
 * You can add a material or pureColor as desired to establish how the look of the rectangle.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize;

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * centered at the origin, and laid out on the X-Y plane.
 *
 * The large rectangle can be broken down into many smaller faces. Building a rectanglular
 * surface from more than one face can dramatically improve realism when the surface is
 * illuminated with specular lighting or a tightly focused spotlight, because increasing the
 * face count increases the number of vertices that interact with the specular or spot lighting.
 *
 * The facesPerSide argument indicates how to break this large rectangle into multiple faces.
 * The X & Y elements of the facesPerSide argument indicate how each axis if the rectangle
 * should be divided into faces. The total number of faces in the rectangle will therefore
 * be the multiplicative product of the X & Y elements of the facesPerSide argument.
 *
 * For example, a value of {5,5} for the facesPerSide argument will result in the rectangle
 * being divided into 25 faces, arranged into a 5x5 grid.
 *
 * You can add a material or pureColor as desired to establish how the look of the rectangle.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide;

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * with the specified pivot point at the origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsRectangleWithSize:andPivot:andTessellation: with the facesPerSide
 * argument set to {1,1}.
 *
 * You can add a material or pureColor as desired to establish how the look of the rectangle.
 *
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredRectangleWithSize: method.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot;

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * with the specified pivot point at the origin, and laid out on the X-Y plane.
 *
 * The large rectangle can be broken down into many smaller faces. Building a rectanglular
 * surface from more than one face can dramatically improve realism when the surface is
 * illuminated with specular lighting or a tightly focused spotlight, because increasing the
 * face count increases the number of vertices that interact with the specular or spot lighting.
 *
 * The facesPerSide argument indicates how to break this large rectangle into multiple faces.
 * The X & Y elements of the facesPerSide argument indicate how each axis if the rectangle
 * should be divided into faces. The total number of faces in the rectangle will therefore
 * be the multiplicative product of the X & Y elements of the facesPerSide argument.
 *
 * For example, a value of {5,5} for the facesPerSide argument will result in the rectangle
 * being divided into 25 faces, arranged into a 5x5 grid.
 *
 * You can add a material or pureColor as desired to establish how the look of the rectangle.
 *
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredRectangleWithSize method.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide;

/**
 * Populates this instance as a rectangular mesh of the specified size, centered at
 * the origin, laid out on the X-Y plane, and that can be covered by a texture.
 *
 * Use the texture property of this node to set the texture.
 *
 * If your texture does not have both dimensions as power-of-two dimensions, you can
 * use either of the alignTextures or alignInvertedTextures methods to adjust the
 * mesh texture coordinates to make use of only the usable portion of the texture.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsCenteredTexturedRectangleWithSize:andTessellation: with the
 * facesPerSide argument set to {1,1}.
 */
-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize;

/**
 * Populates this instance as a rectangular mesh of the specified size, centered at
 * the origin, laid out on the X-Y plane, and that can be covered by a texture.
 *
 * Use the texture property of this node to set the texture.
 *
 * If your texture does not have both dimensions as power-of-two dimensions, you can
 * use either of the alignTextures or alignInvertedTextures methods to adjust the
 * mesh texture coordinates to make use of only the usable portion of the texture.
 *
 * The large rectangle can be broken down into many smaller faces. Building a rectanglular
 * surface from more than one face can dramatically improve realism when the surface is
 * illuminated with specular lighting or a tightly focused spotlight, because increasing the
 * face count increases the number of vertices that interact with the specular or spot lighting.
 *
 * The facesPerSide argument indicates how to break this large rectangle into multiple faces.
 * The X & Y elements of the facesPerSide argument indicate how each axis if the rectangle
 * should be divided into faces. The total number of faces in the rectangle will therefore
 * be the multiplicative product of the X & Y elements of the facesPerSide argument.
 *
 * For example, a value of {5,5} for the facesPerSide argument will result in the rectangle
 * being divided into 25 faces, arranged into a 5x5 grid.
 */
-(void) populateAsCenteredTexturedRectangleWithSize: (CGSize) rectSize
									andTessellation: (ccGridSize) facesPerSide;

/**
 * Populates this instance as a rectangular mesh of the specified size, with the specified
 * pivot point at the origin, laid out on the X-Y plane, and that can be covered by a texture.
 *
 * Use the texture property of this node to set the texture.
 *
 * If your texture does not have both dimensions as power-of-two dimensions, you can
 * use either of the alignTextures or alignInvertedTextures methods to adjust the
 * mesh texture coordinates to make use of only the usable portion of the texture.
 *
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredTexturedRectangleWithSize: method.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsCenteredTexturedRectangleWithSize:andPivot:andTessellation: with
 * the facesPerSide argument set to {1,1}.
 */
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize andPivot: (CGPoint) pivot;

/**
 * Populates this instance as a rectangular mesh of the specified size, with the specified
 * pivot point at the origin, laid out on the X-Y plane, and that can be covered by a texture.
 *
 * Use the texture property of this node to set the texture.
 *
 * If your texture does not have both dimensions as power-of-two dimensions, you can
 * use either of the alignTextures or alignInvertedTextures methods to adjust the
 * mesh texture coordinates to make use of only the usable portion of the texture.
 *
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredTexturedRectangleWithSize: method.
 *
 * The large rectangle can be broken down into many smaller faces. Building a rectanglular
 * surface from more than one face can dramatically improve realism when the surface is
 * illuminated with specular lighting or a tightly focused spotlight, because increasing the
 * face count increases the number of vertices that interact with the specular or spot lighting.
 *
 * The facesPerSide argument indicates how to break this large rectangle into multiple faces.
 * The X & Y elements of the facesPerSide argument indicate how each axis if the rectangle
 * should be divided into faces. The total number of faces in the rectangle will therefore
 * be the multiplicative product of the X & Y elements of the facesPerSide argument.
 *
 * For example, a value of {5,5} for the facesPerSide argument will result in the rectangle
 * being divided into 25 faces, arranged into a 5x5 grid.
 */
-(void) populateAsTexturedRectangleWithSize: (CGSize) rectSize
								   andPivot: (CGPoint) pivot
							andTessellation: (ccGridSize) facesPerSide;


#pragma mark Deprecated parametric plane methods

/**
 * @deprecated Use the populateAsCenteredTexturedRectangleWithSize: method instead,
 * and then use the texture property of this node to set the texture.
 *
 * When using that replacement method, if your texture does not have both
 * dimensions as power-of-two dimensions, you can use either of the
 * alignTextures or alignInvertedTextures methods to adjust the mesh texture
 * coordinates to make use of only the usable portion of the texture.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsCenteredTexturedRectangleWithSize:andTessellation:
 * method instead, and then use the texture property of this node to set the texture.
 *
 * When using that replacement method, if your texture does not have both
 * dimensions as power-of-two dimensions, you can use either of the
 * alignTextures or alignInvertedTextures methods to adjust the mesh texture
 * coordinates to make use of only the usable portion of the texture.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsTexturedRectangleWithSize:andPivot: method instead,
 * and then use the texture property of this node to set the texture.
 *
 * When using that replacement method, if your texture does not have both
 * dimensions as power-of-two dimensions, you can use either of the
 * alignTextures or alignInvertedTextures methods to adjust the mesh texture
 * coordinates to make use of only the usable portion of the texture.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;

/**
 * @deprecated Use the populateAsCenteredTexturedRectangleWithSize:andPivot:andTessellation:
 * method instead, and then use the texture property of this node to set the texture.
 *
 * When using that replacement method, if your texture does not have both
 * dimensions as power-of-two dimensions, you can use either of the
 * alignTextures or alignInvertedTextures methods to adjust the mesh texture
 * coordinates to make use of only the usable portion of the texture.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert DEPRECATED_ATTRIBUTE;


#pragma mark Populating parametric boxes

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners.
 *
 * You can add a material or pureColor as desired to establish how the color of the box.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create simple structures in your 3D world.
 */
-(void) populateAsSolidBox: (CC3BoundingBox) box;

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners of the box, and
 * configures the mesh texture coordinates so that the entire box can be wrapped
 * in a single texture.
 *
 * Use the texture property of this node to set the texture.
 *
 * Since the single texture is wrapped around all six sides of the box, the texture
 * should have a specific layout, which you can see illustrated in the texture file
 * BoxTexture.png.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the "top"
 * of the box is the side that faces towards the positive-Y axis, and the "right" side
 * of the box is the side that faces towards the positive-X axis.
 *
 * For the purposes of wrapping the texture around the box, this method assumes that
 * the natural shape of the box is a cube. The box can be created with any relative
 * dimensions, but if it is not a cube, the texture may appear stretched or shrunk
 * on two or more sides. The texture will still fully wrap all six sides of the box,
 * but the texture is stretched or shrunk to fit each side according to its dimension
 * relative to the other sides. The appearance will be as if you had started with a
 * textured cube and then pulled one of the dimensions out further.
 *
 * For higher fidelity in applying textures to non-cube boxes, so that the texture
 * will not be stretched to fit, use the populateAsTexturedBox:withCorner: method.
 *
 * If your texture does not have both dimensions as power-of-two dimensions, you can
 * use either of the alignTextures or alignInvertedTextures methods to adjust the
 * mesh texture coordinates to make use of only the usable portion of the texture.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture
 * template file for this method.
 */
-(void) populateAsTexturedBox: (CC3BoundingBox) box;

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners of the box, and
 * configures the mesh texture coordinates so that the entire box can be wrapped
 * in a single texture.
 *
 * Use the texture property of this node to set the texture.
 *
 * Since the single texture is wrapped around all six sides of the box, the texture
 * should have a specific layout, which you can see illustrated in the texture file
 * BoxTexture.png.
 *
 * The "front" of the box is the side that faces towards the positive-Z axis, the
 * "top" of the box is the side that faces towards the positive-Y axis, and the
 * "right" side of the box is the side that faces towards the positive-X axis.
 *
 * For the purposes of wrapping the texture around the box, the corner argument is
 * used to indicate the relative dimensions of the box. Specifically, the corner
 * argument specifies the point in the texture that is at the juncture of the "left"
 * "front" and "bottom" sides of the texture (see the BoxTexture.png image for a
 * better understanding of this point), and is specified as a fraction in each of
 * the S & T dimensions of the texture. In the CGPoint that specifies the corner,
 * the x & y elements of the CGPoint correspond to the S & T dimensions of the
 * juncture of the "left", "front" and "bottom" sides in the texture.
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
 * and "bottom" sides meet) from the layout of the texture.
 *
 * If your texture is not have both dimensions as power-of-two dimensions, you can
 * use either of the alignTextures or alignInvertedTextures methods to adjust the
 * mesh texture coordinates to make use of only the usable portion of the texture.
 *
 * Thanks to cocos3d user andyman for contributing the prototype code and texture
 * template file for this method.
 */
-(void) populateAsTexturedBox: (CC3BoundingBox) box withCorner: (CGPoint) corner;

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


#pragma mark Populating parametric boxes

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

@end



