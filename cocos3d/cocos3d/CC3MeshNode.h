/*
 * CC3MeshNode.h
 *
 * cocos3d 0.6.0-sp
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

#import "CC3Node.h"
#import "CC3Mesh.h"
#import "CC3Material.h"


#pragma mark -
#pragma mark CC3MeshNode

/**
 * A CC3Node that draws a 3D mesh.
 * This class forms the base of all visible 3D mesh models in the 3D world.
 *
 * CC3MeshNode is a type of CC3Node, and will often participate in a structural
 * node assembly. An instance can be the child of another node, and the mesh node
 * itself can have child nodes.
 *
 * CC3MeshNodes encapsulate a CC3Mesh instance, and can also encapsulate either
 * a CC3Material instance, or a pure color. The CC3Mesh instance contains the
 * mesh vertex data. The CC3Material instance describes the material and texture
 * properties covering the mesh, which are affected by lighting conditions.
 * Alternately, instead of a material, the mesh may be colored by a single pure color
 * via the pureColor property.
 *
 * When this node is drawn, it delegates to the mesh instance to render the mesh
 * vertices. If a material is defined, before drawing the mesh, it delegates to the
 * material to configure the covering of the mesh. If no material is defined, the node
 * establishes its pure color before rendering the mesh. The pure color is only used
 * if the node has no material attached. And the pure color may in turn be overridden
 * by the mesh data if vertex coloring is in use.
 *
 * Each CC3MeshNode can have only one material or pure color. For large, complicated
 * meshes that are covered by more than one material, or colored with more than one
 * color, the mesh must be broken into smaller meshes, each of which are covered by
 * a single material or color. These smaller sub-meshes are sometimes referred to as
 * "vertex groups". Each such sub-mesh is then wrapped in its own CC3MeshNode instance,
 * along with the material that covers that sub-mesh.
 *
 * These CC3MeshNode instances can then be added as child nodes to a single parent
 * CC3Node instance. This parent CC3Node can then be moved, rotated and scaled,
 * and all of its child nodes will transform in sync. The assembly will behave and
 * be seen as a single object.
 *
 * When the mesh is set in the mesh property, the CC3MeshNode instance
 * creates and builds a CC3NodeBoundingVolume instance from the mesh data, and
 * sets it into its boundingVolume property. 
 *
 * When a copy is made of a CC3MeshNode instance using the copy method, a copy is
 * made of the material, but the mesh is simply assigned by reference, and
 * is not copied. The result is that the the new and original nodes will have
 * different materials, but will share the same mesh. This design avoids
 * creating multiple copies of volumnious and static mesh data when creating
 * copies of nodes.
 *
 * Normally, the front faces of a mesh are displayed, and the back faces are culled
 * and not displayed. You can change this behaviour if you need to be changing the
 * values of the shouldCullFrontFaces and shouldCullBackFaces properties. An example
 * might be if you wanted to show the back-side of a planar sign, or if you wanted
 * to show the inside faces of a skybox.
 *
 * However, be aware that culling is a significant performance-improving technique.
 * You should avoid disabling backface culling except where specifically needed for
 * visual effect. And when you do, if you only need the back faces, turn on front
 * face culling for that mesh by setting the shouldCullFrontFaces property to YES.
 */
@interface CC3MeshNode : CC3LocalContentNode {
	CC3Mesh* mesh;
	CC3Material* material;
	ccColor4F pureColor;
	BOOL shouldCullFrontFaces;
	BOOL shouldCullBackFaces;
}

/**
 * The mesh that holds the vertex data for this mesh node.
 *
 * When this property is set, if this node has a boundingVolume, it is forced
 * to rebuild itself, otherwise, if this node does not have a boundingVolume,
 * a default bounding volume is created from the mesh.
 */
@property(nonatomic, retain) CC3Mesh* mesh;

/** CC3MeshModel renamed to CC3Mesh. Use mesh property instead. @deprecated */
@property(nonatomic, retain) CC3MeshModel* meshModel;

/** The material covering this mesh node. */
@property(nonatomic, retain) CC3Material* material;

/**
 * The pure, solid color used to paint the mesh if no material is established for this node.
 * This color is not not be affected by the lighting conditions. The mesh will always appear
 * in the same pure, solid color, regardless of the lighting sources.
 */
@property(nonatomic, assign) ccColor4F pureColor;

/**
 * Indicates whether the back faces of the mesh should be culled.
 *
 * The initial value is YES, indicating that back faces will not be displayed. You can set
 * this property to NO if you have reason to display the back faces of the mesh (for instance,
 * if you have a rectangular plane and you want to show both sides of it).
 *
 * Since the normal of the face points out the front face, back faces interact with light
 * the same way the front faces do, and will appear luminated by light that falls on the
 * front face, much like a stained-glass window. This may not be the affect that you are after,
 * and for some lighting conditions, instead of disabling back face culling, you might consider
 * creating a second textured front face, placed back-to-back with the original front face.
 *
 * Be aware that culling improves performance, so this property should be set to NO only when
 * specifically needed for visual effect, and only on the meshes that need it.
 */
@property(nonatomic, assign) BOOL shouldCullBackFaces;

/**
 * Indicates whether the front faces of the mesh should be culled.
 *
 * The initial value is NO. Normally, you should leave this property with the initial value,
 * unless you have a specific need not to display the front faces.
 */
@property(nonatomic, assign) BOOL shouldCullFrontFaces;


#pragma mark Material coloring

/**
 * If this value is set to YES, current lighting conditions will be taken into consideration
 * when drawing colors and textures, and the material ambientColor, diffuseColor, specularColor,
 * emissionColor, and shininess properties will have effect.
 *
 * If this value is set to NO, lighting conditions will be ignored when drawing colors and
 * textures, and the material emissionColor will be applied to the mesh surface without regard to
 * lighting. Blending will still occur, but the other material aspects, including ambientColor,
 * diffuseColor, specularColor, and shininess will be ignored. This is useful for a cartoon
 * effect, where you want a pure color, or the natural colors of the texture, to be included
 * in blending calculations, without having to arrange lighting, or if you want those colors
 * to be displayed in their natural values despite current lighting conditions.
 *
 * Setting the value of this property sets the same property in the contained material.
 * Reading the value of this property returns the value of the same property in the contained material.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldUseLighting;

/**
 * The ambient color of the material of this mesh node.
 *
 * Material color is initially set to kCC3DefaultMaterialColorAmbient.
 * If this instance has no material, this property will return kCCC4FBlackTransparent.
 *
 * The value of this property is also affected by changes to the color and opacity
 * properties. See the notes for those properties for more information.
 */
@property(nonatomic, assign) ccColor4F ambientColor;

/**
 * The diffuse color of the material of this mesh node.
 *
 * Material color is initially set to kCC3DefaultMaterialColorDiffuse.
 * If this instance has no material, this property will return kCCC4FBlackTransparent.
 *
 * The value of this property is also affected by changes to the color and opacity
 * properties. See the notes for those properties for more information.
 */
@property(nonatomic, assign) ccColor4F diffuseColor;

/**
 * The specular color of the material of this mesh node.
 *
 * Material color is initially set to kCC3DefaultMaterialColorSpecular.
 * If this instance has no material, this property will return kCCC4FBlackTransparent.
 *
 * The value of this property is also affected by changes to the opacity property.
 * See the notes for the opacity property for more information.
 */
@property(nonatomic, assign) ccColor4F specularColor;

/**
 * The emission color of the material of this mesh node.
 *
 * Material color is initially set to kCC3DefaultMaterialColorEmission.
 * If this instance has no material, this property will return kCCC4FBlackTransparent.
 *
 * The value of this property is also affected by changes to the opacity property.
 * See the notes for the opacity property for more information.
 */
@property(nonatomic, assign) ccColor4F emissionColor;

/**
 * When this mesh node is textured with a DOT3 bump-map (normal map), this property
 * indicates the location, in the global coordinate system, of the light that is
 * illuminating the node.
 *
 * This global light location is tranformed from a loction in the global coordinate
 * system to a direction in the local coordinate system of this node. This local
 * direction is then applied to the texture of this node, where it interacts with
 * the normals stored in the bump-map texture to determine surface illumination.
 *
 * This property only needs to be set, and will only have effect when set, when one
 * of the textures of this node is configured as a bump-map. Set the value of this
 * property to the globalLocation of the light source. Bump-map textures may interact
 * with only one light source.
 *
 * When setting this property, this implementation also sets the same property in all
 * child nodes. When reading this property, this implementation returns a value if
 * this node contains a texture configured for bump-mapping, or the value of the same
 * property from the first descendant node that is a CC3MeshNode and that contains a
 * texture configured for bump-mapping. Otherwise, this implementation returns
 * kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector globalLightLocation;


#pragma mark CCRGBAProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Querying this property returns the RGB components of the material's diffuseColor
 * property, or of this node's pureColor property if this node has no material.
 * In either case, the RGB values are converted from the floating point range (0 to 1),
 * to the byte range (0 to 255).
 *
 * When setting this property, the RGB values are each converted to a floating point
 * number between 0 and 1, and are set into both the ambientColor and diffuseColor
 * properties of this node's material, and the pureColor property of this node.
 * The alpha of each of those properties remains unchanged.
 *
 * Setting this property also sets the same property on all descendant nodes.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Querying this property returns the alpha component of the material's diffuseColor
 * property, or of this node's pureColor property if this node has no material.
 * In either case, the RGB values are converted from the floating point range (0 to 1),
 * to the byte range (0 to 255).
 *
 * When setting this property, the value is converted to a floating point number
 * between 0 and 1, and is set into all of the ambientColor, diffuseColor,
 * specularColor, and emissionColor properties of this node's material, and the
 * pureColor property of this node 
 * The RGB components of each of those properties remains unchanged.
 *
 * Setting this property also sets the same property on all descendant nodes.
 *
 * See the notes for this property on CC3Material for more information on how this
 * property interacts with the other material properties.
 *
 * Setting this property should be thought of as a convenient way to switch between the
 * two most common types of blending combinations. For finer control of blending, set
 * specific blending properties on the CC3Material instance directly, and avoid making
 * changes to this property.
 */
@property(nonatomic, assign) GLubyte opacity;

/**
 * Indicates whether the material of this mesh node is opaque.
 *
 * If this node has a material, returns the value of the same property on the material.
 * If this node has no material, return YES if the alpha component of the pureColor
 * property is 1.0, otherwise returns NO.
 *
 * Setting this property sets the same property in the material and in all descendants,
 * and sets the alpha component of the pureColor property to 1.0.
 *
 * See the notes for this property on CC3Material for more information on how this
 * property interacts with the other material properties.
 *
 * Setting this property should be thought of as a convenient way to switch between the
 * two most common types of blending combinations. For finer control of blending, set
 * specific blending properties on the CC3Material instance directly, and avoid making
 * changes to this property.
 */
@property(nonatomic, assign) BOOL isOpaque;


#pragma mark Drawing

/**
 * Draws the local content of this mesh node by following these steps:
 *   -# If the shouldDecorateNode property of the visitor is YES, and this node has a
 *      material, invokes the draw method of the material. Otherwise, invokes the
 *      CC3Material class-side unbind method.
 *   -# Invokes the drawWithVisitor: method of the encapsulated mesh.
 *
 * This method is called automatically from the transformAndDrawWithVisitor: method
 * of this node. Usually, the application never needs to invoke this method directly.
 */
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Allocation and initialization

/**
 * Populates this instance as a simple rectangular mesh of the specified size,
 * centered at the origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsCenteredRectangleWithSize:andTessellation: with the facesPerSide
 * argument set to {1,1}.
 *
 * You can add a material or pureColor as desired to establish how the look of the rectangle.
 *
 * As this node is translated, rotate and scaled, the rectangle will be re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, signs, etc.
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
 *
 * As this node is translated, rotate and scaled, the rectangle will be re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, signs, etc.
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
 * populateAsCenteredRectangleWithSize method.
 *
 * As this node is translated, rotate and scaled, the rectangle will be re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, signs, etc.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot;


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
 *
 * As this node is translated, rotate and scaled, the rectangle will be re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, signs, etc.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide;
	
/**
 * Populates this instance as a simple textured rectangular mesh of the specified size,
 * centered at the origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsCenteredRectangleWithSize:andTessellation:withTexture:invertTexture:
 * with the facesPerSide argument set to {1,1}.
 *
 * The shouldInvert flag indicates whether the texture should be inverted when laid out
 * on the mesh. Some textures appear inverted after loading under iOS. This flag can be
 * used to compensate for that by reinverting the texture to the correct orientation.
 *
 * As this node is translated, rotate and scaled, the textured rectangle will be
 * re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, etc.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert;

/**
 * Populates this instance as a simple textured rectangular mesh of the specified size,
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
 * The shouldInvert flag indicates whether the texture should be inverted when laid out
 * on the mesh. Some textures appear inverted after loading under iOS. This flag can be
 * used to compensate for that by reinverting the texture to the correct orientation.
 *
 * As this node is translated, rotate and scaled, the textured rectangle will be
 * re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, etc.
 */
-(void) populateAsCenteredRectangleWithSize: (CGSize) rectSize
							andTessellation: (ccGridSize) facesPerSide
								withTexture: (CC3Texture*) texture
							  invertTexture: (BOOL) shouldInvert;

/**
 * Populates this instance as a simple textured rectangular mesh of the specified size,
 * with the specified pivot point at the origin, and laid out on the X-Y plane.
 *
 * The rectangular mesh contains only one face with two triangles. The result is the same
 * as invoking populateAsRectangleWithSize:andPivot:andTessellation:withTexture:invertTexture:
 * with the facesPerSide argument set to {1,1}.
 *
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredRectangleWithSize:withTexture: method.
 *
 * The shouldInvert flag indicates whether the texture should be inverted when laid out
 * on the mesh. Some textures appear inverted after loading under iOS. This flag can be
 * used to compensate for that by reinverting the texture to the correct orientation.
 *
 * As this node is translated, rotate and scaled, the textured rectangle will be
 * re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, etc.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert;

/**
 * Populates this instance as a simple textured rectangular mesh of the specified size,
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
 * The pivot point can be any point within the rectangle's size. For example, if the
 * pivot point is {0, 0}, the rectangle will be laid out so that the bottom-left corner
 * is at the origin. Or, if the pivot point is in the center of the rectangle's size,
 * the rectangle will be laid out centered on the origin, as in the
 * populateAsCenteredRectangleWithSize:withTexture: method.
 *
 * The shouldInvert flag indicates whether the texture should be inverted when laid out
 * on the mesh. Some textures appear inverted after loading under iOS. This flag can be
 * used to compensate for that by reinverting the texture to the correct orientation.
 *
 * As this node is translated, rotate and scaled, the textured rectangle will be
 * re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create walls, floors, etc.
 */
-(void) populateAsRectangleWithSize: (CGSize) rectSize
						   andPivot: (CGPoint) pivot
					andTessellation: (ccGridSize) facesPerSide
						withTexture: (CC3Texture*) texture
					  invertTexture: (BOOL) shouldInvert;

/**
 * Populates this instance as a simple rectangular box mesh from the specified
 * bounding box, which contains two of the diagonal corners.
 *
 * You can add a material or pureColor as desired to establish how the look of the box.
 *
 * To add a texture, add a material to this node, then add a CC3Texture instance to that
 * material. You must also add an instance of CC3VertexTextureCoordinates to the mesh
 * model of this node, and populate it with the texture coordinate mapping data.
 *
 * The mesh uses interleaved data, so when populating the texture coordinate data,
 * set the elements property of the CC3VertexTextureCoordinates instance to the same as the
 * elements property of the CC3VertexLocations instance from the vertexLocations property
 * of the mesh. Then insert the texture coordinate data into that interleaved vertex
 * data. Each element of that interleaved elements array is a CCTexturedVertex structure,
 * which contains the combined location, normal, and texture coordinate data for a single
 * vertex. For more on how to do this, see the implementation of this method and take note
 * of how this is done with the normal data.
 *
 * As this node is translated, rotate and scaled, the rectangle will be re-oriented in 3D space.
 *
 * This is a convenience method for creating a simple, but useful shape, which can be
 * used to create simple structures in your 3D world.
 */
-(void) populateAsSolidBox: (CC3BoundingBox) box;

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


#pragma mark -
#pragma mark CC3LineNode

/**
 * CC3LineNode is a type of CC3MeshNode that is specialized to display lines. It includes
 * properties for setting the line width, and whether or not the lines should be smoothed
 * using automatic anti-aliasing.
 *
 * To draw lines, you must make sure that the drawingMode property of the vertex array that
 * performs the drawing within the mesh (either the vertexIndices or vertexLocations
 * instance) is set to one of GL_LINES, GL_LINE_STRIP or GL_LINE_LOOP. Other than that,
 * you configure the mesh node and its mesh as you would with any mesh node.
 *
 * For a simple wire box, you can use the populateAsWireBox:withPureColor: convenience
 * method of CC3MeshNode.
 *
 * To color the lines, use the pureColor property to draw the lines in a pure, solid color
 * that is not affected by lighting conditions. You can also add a material to your
 * CC3LineNode instance to get more subtle coloring and blending, but this can sometimes
 * appear strange with lines. You can also use CCActionInterval to change the tinting or
 * opacity of the lines, as you would with any mesh node.
 *
 * Several convenience methods exist in the CC3MeshNode class to aid in constructing a
 * CC3LineNode instance:
 *   - populateAsLineStripWith:vertices:andRetain::
 *   - populateAsWireBox:
 */
@interface CC3LineNode : CC3MeshNode {
	GLfloat lineWidth;
	GLenum performanceHint;
	BOOL shouldSmoothLines;
}

/** The width of the lines that will be drawn. The initial value is 1.0. */
@property(nonatomic, assign) GLfloat lineWidth;

/** Indicates whether lines should be smoothed (antialiased). The initial value is NO. */
@property(nonatomic, assign) BOOL shouldSmoothLines;

/**
 * Indicates how the GL engine should trade off between rendering quality and speed.
 * The value of this property should be one of GL_FASTEST, GL_NICEST, or GL_DONT_CARE.
 *
 * The initial value of this property is GL_DONT_CARE.
 */
@property(nonatomic, assign) GLenum performanceHint;

@end


#pragma mark -
#pragma mark CC3PlaneNode

/**
 * CC3PlaneNode is a type of CC3MeshNode that is specialized to display planes and
 * simple rectanglular meshes.
 *
 * Since a plane is a mesh like any other mesh, the functionality required to create
 * and manipulate plane meshes is present in the CC3MeshNode class, and if you choose,
 * you can create and manage plane meshes using that class alone. Some plane-specific
 * functionality is defined within this class.
 * 
 * Several convenience methods exist in the CC3MeshNode class to aid in constructing a
 * CC3PlaneNode instance:
 *   - populateAsCenteredRectangleWithSize:
 *   - populateAsRectangleWithSize:andPivot:
 *   - populateAsCenteredRectangleWithSize:withTexture:invertTexture:
 *   - populateAsRectangleWithSize:andPivot:withTexture:invertTexture:
 */
@interface CC3PlaneNode : CC3MeshNode

/**
 * Returns a CC3Plane structure corresponding to this plane.
 *
 * This structure is built from the location vertices of three of the corners
 * of the bounding box of the mesh.
 */
@property(nonatomic, readonly) CC3Plane plane;

@end


#pragma mark -
#pragma mark CC3BoxNode

/**
 * CC3BoxNode is a type of CC3MeshNode that is specialized to display simple box or cube meshes.
 *
 * Since a cube or box is a mesh like any other mesh, the functionality required to create
 * and manipulate plane meshes is present in the CC3MeshNode class, and if you choose, you
 * can create and manage box meshes using that class alone. At present, CC3BoxNode exists
 * for the most part simply to identify box meshes as such. However, in future, additional
 * state or behaviour may be added to this class.
 * 
 * You can use the following convenience method to aid in constructing a CC3BoxNode instance:
 *   - populateAsSolidBox:
 */
@interface CC3BoxNode : CC3MeshNode
@end



