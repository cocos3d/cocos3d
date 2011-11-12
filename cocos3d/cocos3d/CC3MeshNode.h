/*
 * CC3MeshNode.h
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
 * There are a number of populateAs... parametric population methods available in
 * the CC3MeshNode (ParametricShapes) category extension. These methods can be used
 * to populate the vertices of the mesh contained in a new mesh node to create
 * interesting and useful parametric shapes and surfaces.
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
 * When the mesh is set in the mesh property, the CC3MeshNode instance creates and
 * builds a CC3NodeBoundingVolume instance from the mesh data, and sets it into its
 * boundingVolume property. 
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
	GLenum depthFunction;
	CC3NormalScaling normalScalingMethod;
	BOOL shouldDisableDepthMask;
	BOOL shouldDisableDepthTest;
	BOOL shouldCullFrontFaces;
	BOOL shouldCullBackFaces;
	BOOL shouldUseClockwiseFrontFaceWinding;
	BOOL shouldUseSmoothShading;
}

/**
 * The mesh that holds the vertex data for this mesh node.
 *
 * When this property is set, if this node has a boundingVolume, it is forced
 * to rebuild itself, otherwise, if this node does not have a boundingVolume,
 * a default bounding volume is created from the mesh.
 */
@property(nonatomic, retain) CC3Mesh* mesh;

/** @deprecated CC3MeshModel renamed to CC3Mesh. Use mesh property instead. */
@property(nonatomic, retain) CC3MeshModel* meshModel DEPRECATED_ATTRIBUTE;

/** The material covering this mesh node. */
@property(nonatomic, retain) CC3Material* material;

/**
 * The pure, solid color used to paint the mesh if no material is established for this node.
 * This color is not not be affected by the lighting conditions. The mesh will always appear
 * in the same pure, solid color, regardless of the lighting sources.
 */
@property(nonatomic, assign) ccColor4F pureColor;


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


#pragma mark CCRGBAProtocol and CCBlendProtocol support

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

/**
 * Implementation of the CCBlendProtocol blendFunc property.
 *
 * This is a convenience property that gets and sets both the sourceBlend and
 * destinationBlend properties of the material used by this node using a single
 * structure. Changes to this property is also passed along to any child nodes.
 * Querying this property returns {GL_ONE, GL_ZERO} if this node has no material.
 */
@property(nonatomic, assign) ccBlendFunc blendFunc;

/**
 * Indicates whether alpha testing should be used to determine if pixels with
 * lower alpha values should be drawn.
 *
 * Setting or reading the value of this property will set or return the value of the
 * same property on the material covering this mesh.
 *
 * If the value of this property is set to YES, each pixel will be drawn regardless
 * of the value of its alpha component. If the value of this property is set to NO,
 * the value of the alpha component of each pixel will be compared against the value
 * in the alphaTestReference property of the material, and only those pixel alpha
 * values that are greater than that reference value will be drawn. You can set the
 * value of the alphaTestReference property of the material to determine the cutoff
 * level.
 *
 * The initial value of this property is YES, indicating that pixels with lower
 * alpha values will be drawn.
 * 
 * For most situations, alpha testing is not necessary, and you can leave the value
 * of this property set to YES. Alpha testing can sometimes be useful when drawing
 * overlapping objects that each contain transparency, and it is not possible to rely
 * only on drawing order and depth testing to mediate whether a pixel should be drawn.
 */
@property(nonatomic, assign) BOOL shouldDrawLowAlpha;


#pragma mark Textures

/**
 * When the material covering this mesh contains a single texture, this property
 * references that texture. When multi-texturing is in use, and the material holds
 * more than one texture, this property references the texture that will be processed
 * by GL texture unit zero.
 *
 * This property is a convenience. It simply delegates to the same property on the
 * material covering this mesh node.
 *
 * When setting this property, if a material does not yet exist in this mesh node,
 * a new material will be created and the texture will be attached to it.
 */
@property(nonatomic, retain) CC3Texture* texture;

/**
 * Aligns the texture coordinates of the mesh with the textures held in the material.
 *
 * This method can be useful when the width and height of the textures in the material
 * are not a power-of-two. Under iOS, when loading a texture that is not a power-of-two,
 * the texture will be converted to a size whose width and height are a power-of-two.
 * The result is a texture that can have empty space on the top and right sides. If the
 * texture coordinates of the mesh do not take this into consideration, the result will
 * be that only the lower left of the mesh will be covered by the texture.
 *
 * When this occurs, invoking this method will adjust the texture coordinates of the mesh
 * to map to the original width and height of the textures.
 *
 * If the mesh is using multi-texturing, this method will adjust the texture coordinates
 * array for each texture unit, using the corresponding texture for that texture unit
 * in the specified material.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This method should only be invoked once on any mesh, and it may cause mapping conflicts
 * if the same mesh is shared by other CC3MeshNodes that use different textures.
 *
 * This method will also invoke the superclass behaviour to invoke the same method on
 * each child node.
 *
 * To adjust the texture coordinates of only a single mesh, without adjusting the texture
 * coordinates of any descendant nodes, invoke the alignWithTexturesIn: method of the
 * CC3Mesh held in this mesh node. To adjust the texture coordinates of only a single
 * texture coordinates array within the mesh, invoke the alignWithTexture: method on the
 * appropriate instance of CC3VertexTextureCoordinates.
 */
-(void) alignTextures;

/**
 * Aligns the texture coordinates of the mesh with the textures held in the material.
 *
 * The texture coordinates are aligned assuming that the texture is inverted in the
 * Y-direction. Certain texture formats are inverted during loading, and this method
 * can be used to compensate.
 *
 * This method can be useful when the width and height of the textures in the material
 * are not a power-of-two. Under iOS, when loading a texture that is not a power-of-two,
 * the texture will be converted to a size whose width and height are a power-of-two.
 * The result is a texture that can have empty space on the top and right sides. If the
 * texture coordinates of the mesh do not take this into consideration, the result will
 * be that only the lower left of the mesh will be covered by the texture.
 *
 * When this occurs, invoking this method will adjust the texture coordinates of the mesh
 * to map to the original width and height of the texturesa.
 *
 * If the mesh is using multi-texturing, this method will adjust the texture coordinates
 * array for each texture unit, using the corresponding texture for that texture unit
 * in the specified material.
 *
 * Care should be taken when using this method, as it changes the actual vertex data.
 * This method should only be invoked once on any mesh, and it may cause mapping conflicts
 * if the same mesh is shared by other CC3MeshNodes that use different textures.
 *
 * This method will also invoke the superclass behaviour to invoke the same method on
 * each child node.
 *
 * To adjust the texture coordinates of only a single mesh, without adjusting the texture
 * coordinates of any descendant nodes, invoke the alignWithInvertedTexturesIn: method of
 * the CC3Mesh held in this mesh node. To adjust the texture coordinates of only a single
 * texture coordinates array within the mesh, invoke the alignWithInvertedTexture: method
 * on the appropriate instance of CC3VertexTextureCoordinates.
 */
-(void) alignInvertedTextures;

/**
 * Configures the mesh so that a texture applied to this mesh will be repeated the
 * specified number of times across the mesh, in each dimension. The repeatFactor
 * argument contains two numbers, corresponding to how many times in each dimension
 * the texture should be repeated.
 * 
 * As an example, a value of (1, 2) for the repeatValue indicates that the texture
 * should repeat twice vertically, but not repeat horizontally.
 * 
 * When a texture is repeated, the corresponding side of the texture covering this
 * mesh must have a length that is a power-of-two, otherwise the padding added by
 * iOS to convert it to a power-of-two length internally will be visible in the
 * repeating pattern across the mesh.
 *
 * For a side that is not repeating, the corresponding side of the texture covering
 * this mesh does not require a length that is a power-of-two.
 *
 * The textureParameters property of any texture covering this mesh should include
 * the GL_REPEAT setting in each of its texture wrap components that correspond to
 * a repeatFactor greater than one. The GL_REPEAT setting is the default setting
 * for CC3Texture.
 *
 * For example, if you want to repeat your texture twice in one dimension, but only
 * once in the other, then you would use a repeatFactor of (1, 2) or (2, 1). For the
 * side that is repeating twice, the length of that side of the texture must be a
 * power-of-two. But the other side may have any dimension. The textureParameters
 * property of the CC3Texture should include the GL_REPEAT setting for the
 * corresponding texture dimension.
 *
 * If your texture requires aligning with the mesh (typically if one of the texture
 * dimensions is not a power-of-two), you should invoke either the alignTextures or
 * alignInvertedTextures method before invoking this method.
 *
 * In the example above, you would invoke one of those methods before invoking this
 * method, to first align the mesh with that non-power-of-two side.
 *
 * The dimensions of the repeatFactor are independent of the size derived from the
 * texture by the alignTextures or alignInvertedTextures methods. A value of 1.0 for
 * an element in the specified repeatFactor will automatically take into consideration
 * the adjustment made to the mesh by those methods, and will display only the part of
 * the texture defined by them.
 *
 * You can specify a fractional value for either of the components of the repeatFactor
 * to expand the texture in that dimension so that only part of the texture appears
 * in that dimension, while potentially repeating multiple times in the other dimension.
 */
-(void) repeatTexture: (ccTex2F) repeatFactor;

/**
 * Defines the rectangular area of the textures, for all texture units, that should
 * be mapped to the mesh used by this node.
 *
 * This property facilitates the use of sprite-sheets, where the mesh is covered
 * by a small fraction of a larger texture. This technique has many uses, including
 * animating a texture onto a mesh, where each section of the full texture is really
 * a different frame of a texture animation, or simply loading one larger texture
 * and using parts of it to texture many different meshes.
 *
 * The dimensions of this rectangle are taken as fractional portions of the full
 * area of the texture. Therefore, a rectangle with zero origin, and unit size
 * ((0.0, 0.0), (1.0, 1.0)) indicates that the mesh should be covered with the
 * complete texture.
 * 
 * A rectangle of smaller size, and/or a non-zero origin, indicates that the mesh
 * should be covered by a fractional area of the texture. For example, a rectangular
 * value for this property with origin at (0.5, 0.5), and size of (0.5, 0.5) indicates
 * that only the top-right quarter of the texture will be used to cover this mesh.
 *
 * The bounds of the texture rectangle must fit within a unit rectangle. Both the
 * bottom-left and top-right corners must lie between zero and one in both the
 * X and Y directions.
 *
 * The dimensions of the rectangle in this property are independent of adjustments
 * made by the  alignTextures and alignInvertedTextures methods. A unit rectangle
 * value for this property will automatically take into consideration the adjustment
 * made to the mesh by those methods, and will display only the part of the texture
 * defined by them. Rectangular values for this property that are smaller than the
 * unit rectangle will be relative to the displayable area defined by alignTextures
 * and alignInvertedTextures.
 *
 * As an example, if the alignWithTexturesIn: method was used to limit the mesh
 * to using only 80% of the texture (perhaps when using a non-POT texture), and this
 * property was set to a rectangle with origin at (0.5, 0.0) and size (0.5, 0.5),
 * the mesh will be covered by the bottom-right quarter of the usable 80% of the
 * overall texture.
 *
 * This property affects all texture units used by this mesh, to query or change
 * this property for a single texture unit only, use the textureRectangleForTextureUnit:
 * and setTextureRectangle:forTextureUnit: methods.
 *
 * The initial value of this property is a rectangle with origin at zero, and unit
 * size, indicating that the mesh will be covered with the complete usable area of
 * the texture.
 */
@property(nonatomic, assign) CGRect textureRectangle;

/**
 * Returns the textureRectangle property from the texture coordinates that are
 * mapping the specified texture unit index.
 *
 * See the notes for the textureRectangle property of this class for an explanation
 * of the use of this property.
 */
-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit;

/**
 * Sets the textureRectangle property from the texture coordinates that are
 * mapping the specified texture unit index.
 *
 * See the notes for the textureRectangle property of this class for an explanation
 * of the use of this property.
 */
-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit;


#pragma mark Drawing

/**
 * Draws the local content of this mesh node by following these steps:
 *   -# If the shouldDecorateNode property of the visitor is YES, and this node
 *      has a material, invokes the drawWithVisitor method of the material.
 *      Otherwise, invokes the CC3Material class-side unbind method.
 *   -# Invokes the drawWithVisitor: method of the encapsulated mesh.
 *
 * This method is called automatically from the transformAndDrawWithVisitor: method
 * of this node. Usually, the application never needs to invoke this method directly.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Accessing vertex data

/**
 * Changes the mesh data so that the pivot point of the mesh will be at the specified
 * location. The pivot point of the mesh is the location in the local coordinate system
 * around which all transforms are performed. A vertex at the pivot point would have
 * local coordinates (0,0,0).
 *
 * This method can be used to adjust the mesh structure to make it easier to apply
 * transformations, by moving the origin of the transformations to a more convenient
 * location in the mesh.
 *
 * This method changes the location component of every vertex in the mesh data.
 * This can be quite costly, and should only be performed once to adjust a mesh
 * so that it is easier to manipulate.
 * 
 * Do not use this method to move your model around. Instead, use the transform
 * properties (location, rotation and scale) of this node, and let the GL engine
 * do the heavy lifting of transforming the mesh vertices.
 * 
 * Since the new mesh locations will change the bounding box of the mesh, this
 * method invokes the rebuildBoundingVolume method on the boundingVolume of this
 * node, to ensure that the boundingVolume encompasses the new vertex locations.
 *
 * This method also ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) movePivotTo: (CC3Vector) aLocation;

/**
 * Changes the mesh data so that the pivot point of the mesh will be at the center of
 * geometry of the mesh vertices. The pivot point of the mesh is the location in the
 * local coordinate system around which all transforms are performed. A vertex at the
 * pivot point would have local coordinates (0,0,0).
 *
 * This method can be used to adjust the mesh structure to make it easier to apply
 * transformations, by moving the origin of the transformations to the center of the mesh.
 *
 * This method changes the location component of every vertex in the mesh data.
 * This can be quite costly, and should only be performed once to adjust a mesh
 * so that it is easier to manipulate.
 * 
 * Do not use this method to move your model around. Instead, use the transform
 * properties (location, rotation and scale) of this node, and let the GL engine
 * do the heavy lifting of transforming the mesh vertices.
 * 
 * Since the new mesh locations will change the bounding box of the mesh, this
 * method invokes the rebuildBoundingVolume method on the boundingVolume of this
 * node, to ensure that the boundingVolume encompasses the new vertex locations.
 *
 * This method also ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) movePivotToCenterOfGeometry;

/** Returns the number of vertices in this mesh. */
@property(nonatomic, readonly) GLsizei vertexCount;

/**
 * Returns the location element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexLocationAt: (GLsizei) index;

/**
 * Sets the location element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 * 
 * Since the new vertex location may change the bounding box of the mesh, when all
 * vertex changes have been made, be sure to invoke the rebuildBoundingVolume method
 * on this node, to ensure that the boundingVolume encompasses the new vertex locations.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexLocationsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexLocation: (CC3Vector) aLocation at: (GLsizei) index;

/**
 * Returns the normal element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexNormalAt: (GLsizei) index;

/**
 * Sets the normal element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexNormal: (CC3Vector) aNormal at: (GLsizei) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4F) vertexColor4FAt: (GLsizei) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexColorsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4F: (ccColor4F) aColor at: (GLsizei) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4B) vertexColor4BAt: (GLsizei) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexColorsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4B: (ccColor4B) aColor at: (GLsizei) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the specified texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLsizei) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the specified texture unit index, to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBufferForTextureUnit: method
 * to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLsizei) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the commonly used texture unit zero.
 *
 * This is a convenience method that is equivalent to invoking the
 * vertexTexCoord2FForTextureUnit:at: method, with zero as the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the commonly used texture unit zero, to the specified texture coordinate value.
 *
 * This is a convenience method that delegates to the setVertexTexCoord2F:forTextureUnit:at:
 * method, passing in zero for the texture unit index.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBuffer method to ensure that
 * the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index;

/** @deprecated Use the vertexTexCoord2FForTextureUnit:at: method instead, */
-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/** @deprecated Use the setVertexTexCoord2F:forTextureUnit:at: method instead, */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/**
 * Returns the index element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLushort) vertexIndexAt: (GLsizei) index;

/**
 * Sets the index element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the elementStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexIndicesGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexIndex: (GLushort) vertexIndex at: (GLsizei) index;

/** Updates the GL engine buffer with the vertex location data in this mesh. */
-(void) updateVertexLocationsGLBuffer;

/** Updates the GL engine buffer with the vertex normal data in this mesh. */
-(void) updateVertexNormalsGLBuffer;

/** Updates the GL engine buffer with the vertex color data in this mesh. */
-(void) updateVertexColorsGLBuffer;

/**
 * Updates the GL engine buffer with the vertex texture coord data from the
 * specified texture unit in this mesh.
 */
-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit;

/**
 * Updates the GL engine buffer with the vertex texture coord data from
 * texture unit zero in this mesh.
 */
-(void) updateVertexTextureCoordinatesGLBuffer;

/** Updates the GL engine buffer with the vertex index data in this mesh. */
-(void) updateVertexIndicesGLBuffer;

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
 *   - populateAsLineStripWith:vertices:andRetain:
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
#pragma mark CC3WireframeBoundingBoxNode

/**
 * CC3WireframeBoundingBoxNode is a type of CC3LineNode specialized for drawing
 * a wireframe bounding box around another node. A CC3WireframeBoundingBoxNode
 * is typically added as a child node to the node whose bounding box is to
 * be displayed.
 *
 * The CC3WireframeBoundingBoxNode node can be set to automatically track
 * the dynamic nature of the boundingBox of the parent node by setting
 * the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * Since we don't want to add descriptor labels or wireframe boxes to
 * wireframe nodes, the shouldDrawDescriptor, shouldDrawWireframeBox,
 * and shouldDrawLocalContentWireframeBox properties are overridden to
 * do nothing when set, and to always return YES.
 *
 * Similarly, CC3WireframeBoundingBoxNode node does not participate in calculating
 * the bounding box of the node whose bounding box it is drawing, since, as a child
 * of that node, it would interfere with accurate measurement of the bounding box.
 *
 * The shouldIncludeInDeepCopy property returns NO, so that the CC3WireframeBoundingBoxNode
 * will not be copied when the parent node is copied. A bounding box node for the copy
 * will be created automatically when each of the shouldDrawLocalContentWireframeBox
 * and shouldDrawWireframeBox properties are copied, if they are set to YES on the
 * original node that is copied.
 * 
 * A CC3WireframeBoundingBoxNode will continue to be visible even when its ancestor
 * nodes are invisible, unless the CC3WireframeBoundingBoxNode itself is made invisible.
 */
@interface CC3WireframeBoundingBoxNode : CC3LineNode {
	BOOL shouldAlwaysMeasureParentBoundingBox;
}

/**
 * Indicates whether the dimensions of this node should automatically be
 * remeasured on each update pass.
 *
 * If this property is set to YES, the box will automatically be resized
 * to account for movements by any descendant nodes of the parent node.
 * For bounding box nodes that track the overall boundingBox of a parent
 * node, this property should be set to YES.
 *
 * It is not necessary to set this property to YES to account for changes in
 * the transform properties of the parent node itself, or if this node is
 * tracking the bounding box of local content of the parent node. Generally,
 * changes to that will automatically be handled by the transform updates.
 *
 * When setting this property, be aware that measuring the bounding box of
 * the parent node can be an expensive operation.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldAlwaysMeasureParentBoundingBox;

@end


#pragma mark -
#pragma mark CC3WireframeLocalContentBoundingBoxNode

/**
 * CC3WireframeLocalContentBoundingBoxNode is a CC3WireframeBoundingBoxNode that
 * further specializes in drawing a bounding box around the local content of another
 * node with local content. A CC3WireframeLocalContentBoundingBoxNode is typically
 * added as a child node to the node whose bounding box is to be displayed.
 *
 * Since for almost all nodes, the local content generally does not change, the
 * shouldAlwaysMeasureParentBoundingBox property is usually left at NO, to avoid
 * unnecessary remeasuring of the bounding box of the local content of the parent
 * node when we know it will not be changing. However, this property can be set to
 * YES when adding a CC3WireframeLocalContentBoundingBoxNode to a node whose local
 * content does change frequently.
 */
@interface  CC3WireframeLocalContentBoundingBoxNode  : CC3WireframeBoundingBoxNode
@end



#pragma mark -
#pragma mark CC3DirectionMarkerNode

/**
 * CC3DirectionMarkerNode is a type of CC3LineNode specialized for drawing a line
 * from the pivot point of its parent node to a point outside the bounding box of
 * the parent node, in a particular direction. A CC3DirectionMarkerNode is typically
 * added as a child node to the node to visibly indicate the orientation of the
 * parent node.
 *
 * The CC3DirectionMarkerNode node can be set to automatically track the
 * dynamic nature of the boundingBox of the parent node by setting the
 * shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * Since we don't want to add descriptor labels or wireframe boxes to
 * direction marker nodes, the shouldDrawDescriptor, shouldDrawWireframeBox,
 * and shouldDrawLocalContentWireframeBox properties are overridden to
 * do nothing when set, and to always return YES.
 *
 * Similarly, CC3DirectionMarkerNode node does not participate in calculating the
 * bounding box of the node whose bounding box it is drawing, since, as a child
 * of that node, it would interfere with accurate measurement of the bounding box.
 *
 * The shouldIncludeInDeepCopy property returns YES by default, so that the
 * CC3DirectionMarkerNode will be copied when the parent node is copied.
 * 
 * A CC3DirectionMarkerNode will continue to be visible even when its ancestor
 * nodes are invisible, unless the CC3DirectionMarkerNode itself is made invisible.
 */
@interface CC3DirectionMarkerNode : CC3WireframeBoundingBoxNode {
	CC3Vector markerDirection;
}

/**
 * Indicates the unit direction towards which this line marker will point from
 * the pivot point (origin) of the parent node.
 *
 * When setting the value of this property, the incoming vector will be normalized
 * to a unit vector.
 *
 * The value of this property defaults to kCC3VectorUnitZNegative, a unit vector
 * in the direction of the negative Z-axis, which is the OpenGL ES default direction.
 */
@property(nonatomic, assign) CC3Vector markerDirection;

/**
 * Returns the proportional distance that the direction marker line should protrude
 * from the parent node. This is measured in proportion to the distance from the
 * pivot point (local origin) of the parent node to the side of the bounding box
 * through which the line is protruding.
 *
 * The default value of this property is 1.5.
 */
+(GLfloat) directionMarkerScale;

/**
 * Sets the proportional distance that the direction marker line should protrude
 * from the parent node. This is measured in proportion to the distance from the
 * pivot point (local origin) of the parent node to the side of the bounding box
 * through which the line is protruding.
 *
 * The default value of this property is 1.5.
 */
+(void) setDirectionMarkerScale: (GLfloat) scale;

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
 *   - populateAsWireBox:
 *   - populateAsTexturedBox:
 *   - populateAsTexturedBox:withCorner:
 */
@interface CC3BoxNode : CC3MeshNode
@end



