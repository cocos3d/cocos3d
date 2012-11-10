/*
 * CC3MeshNode.h
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

#import "CC3Node.h"
#import "CC3Mesh.h"
#import "CC3Material.h"


#pragma mark -
#pragma mark CC3MeshNode

/**
 * A CC3Node that draws a 3D mesh.
 * This class forms the base of all visible 3D mesh models in the 3D scene.
 *
 * CC3MeshNode is a type of CC3Node, and will often participate in a structural node assembly.
 * An instance can be the child of another node, and the mesh node itself can have child nodes.
 *
 * CC3MeshNodes encapsulate a CC3Mesh instance, and can also encapsulate either a CC3Material
 * instance, or a pure color. The CC3Mesh instance contains the mesh vertex data. The CC3Material
 * instance describes the material and texture properties covering the mesh, which are affected by
 * lighting conditions. Alternately, instead of a material, the mesh may be colored by a single
 * pure color via the pureColor property.
 *
 * If it is not explicitly set beforehand, the material will automatically be created and assigned 
 * to the mesh node when a texture is added to the mesh node through the texture property or the
 * addTexture: method, or if any of the material properties of the mesh node are set or accessed,
 * including color, opacity, ambientColor, diffuseColor, specularColor, emissionColor, blendFunc,
 * or shouldDrawLowAlpha. The material will automatically be created if either the isOpaque or
 * shouldUseLighting property is set, but not if they are simply read.
 *
 * There are a number of populateAs... parametric population methods available in the CC3MeshNode
 * (ParametricShapes) category extension. These methods can be used to populate the vertices of the
 * mesh contained in a new mesh node to create interesting and useful parametric shapes and surfaces.
 *
 * When this node is drawn, it delegates to the mesh instance to render the mesh vertices. If a
 * material is defined, before drawing the mesh, it delegates to the material to configure the
 * covering of the mesh. If no material is defined, the node establishes its pure color before
 * rendering the mesh. The pure color is only used if the node has no material attached. And the
 * pure color may in turn be overridden by the mesh data if vertex coloring is in use.
 *
 * Each CC3MeshNode can have only one material or pure color. For large, complicated meshes that are
 * covered by more than one material, or colored with more than one color, the mesh must be broken
 * into smaller meshes, each of which are covered by a single material or color. These smaller
 * sub-meshes are sometimes referred to as "vertex groups". Each such sub-mesh is then wrapped in
 * its own CC3MeshNode instance, along with the material that covers that sub-mesh.
 *
 * These CC3MeshNode instances can then be added as child nodes to a single parent CC3Node instance.
 * This parent CC3Node can then be moved, rotated and scaled, and all of its child nodes will
 * transform in sync. The assembly will behave and be seen as a single object.
 *
 * When the mesh is set in the mesh property, the CC3MeshNode instance creates and builds a
 * CC3NodeBoundingVolume instance from the mesh data, and sets it into its boundingVolume property. 
 *
 * When a copy is made of a CC3MeshNode instance using the copy method, a copy is made of the material,
 * but the mesh is simply assigned by reference, and is not copied. The result is that the the new and
 * original nodes will have different materials, but will share the same mesh. This design avoids
 * creating multiple copies of volumnious and static mesh data when creating copies of nodes.
 *
 * Normally, the front faces of a mesh are displayed, and the back faces are culled and not displayed.
 * You can change this behaviour if you need to be changing the values of the shouldCullFrontFaces and
 * shouldCullBackFaces properties. An example might be if you wanted to show the back-side of a planar
 * sign, or if you wanted to show the inside faces of a skybox.
 *
 * However, be aware that culling is a significant performance-improving technique. You should avoid
 * disabling backface culling except where specifically needed for visual effect. And when you do,
 * if you only need the back faces, turn on front face culling for that mesh by setting the
 * shouldCullFrontFaces property to YES.
 */
@interface CC3MeshNode : CC3LocalContentNode {
	CC3Mesh* mesh;
	CC3Material* material;
	ccColor4F pureColor;
	GLenum depthFunction;
	GLfloat decalOffsetFactor;
	GLfloat decalOffsetUnits;
	GLubyte normalScalingMethod;
	GLfloat lineWidth;
	GLenum lineSmoothingHint;
	BOOL shouldSmoothLines : 1;
	BOOL shouldDisableDepthMask : 1;
	BOOL shouldDisableDepthTest : 1;
	BOOL shouldCullFrontFaces : 1;
	BOOL shouldCullBackFaces : 1;
	BOOL shouldUseClockwiseFrontFaceWinding : 1;
	BOOL shouldUseSmoothShading : 1;
	BOOL shouldCastShadowsWhenInvisible : 1;
	BOOL shouldApplyOpacityAndColorToMeshContent : 1;
}

/**
 * The mesh that holds the vertex data for this mesh node.
 *
 * When this property is set, if this node has a boundingVolume, it is forced to rebuild itself,
 * otherwise, if this node does not have a boundingVolume, a default bounding volume is created
 * from the mesh. In addition, if the mesh does not have normals, the shouldUseLighting property
 * of this node is set to NO, and if the mesh does not have texture coordinates, the texture
 * property of this node is set to nil.
 */
@property(nonatomic, retain) CC3Mesh* mesh;

/** @deprecated CC3MeshModel renamed to CC3Mesh. Use mesh property instead. */
@property(nonatomic, retain) CC3Mesh* meshModel DEPRECATED_ATTRIBUTE;

/**
 * The material covering this mesh node.
 *
 * If it is not explicitly set beforehand, the material will automatically be created
 * and assigned to the mesh node when a texture is added to the mesh node through the
 * texture property or the addTexture: method, or if any of the material properties
 * of the mesh node are set or accessed, including color, opacity, ambientColor,
 * diffuseColor, specularColor, emissionColor, blendFunc, or shouldDrawLowAlpha.
 * The material will automatically be created if either the isOpaque or
 * shouldUseLighting property is set, but not if they are simply read.
 */
@property(nonatomic, retain) CC3Material* material;

/**
 * The pure, solid color used to paint the mesh if no material is established for this node.
 * This color is not not be affected by the lighting conditions. The mesh will always appear
 * in the same pure, solid color, regardless of the lighting sources.
 *
 * If you do not want to use a material with this node, use this pureColor property to
 * set or access the color and opacity of this node. Setting or accessing any of the
 * other coloring properties (color, opacity, ambientColor, diffuseColor, specularColor,
 * or emissionColor) will create a material automatically.
 */
@property(nonatomic, assign) ccColor4F pureColor;

/**
 * Returns whether the underlying vertex data has been loaded into GL engine vertex
 * buffer objects. Vertex buffer objects are engaged via the createGLBuffers method.
 */
@property(nonatomic, readonly) BOOL isUsingGLBuffers;

/**
 * Returns an allocated, initialized, autorelease instance of the bounding volume to
 * be used by this node.
 *
 * This method is invoked automatically when the mesh property is set if no bounding
 * volume has been assigned.
 *
 * This implementation delegates to the mesh by invoking the same method on the mesh.
 * Subclasses will override to provide alternate default bounding volumes.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume;


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
 * between 0 and 1, and is set into all of the ambientColor, diffuseColor, specularColor,
 * and emissionColor properties of this node's material, and the pureColor property of
 * this node. The RGB components of each of those properties remains unchanged.
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
 * If this node has a material, returns the value of the same property on the material,
 * otherwise return YES.
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
 * Returns the number of textures covering this mesh, regardless of whether the
 * textures were attached using the texture property or the addTexture: method.
 */
@property(nonatomic, readonly) GLuint textureCount;

/**
 * When the material covering this mesh contains a single texture, this property
 * references that texture. When multi-texturing is in use, and the material holds
 * more than one texture, this property references the texture that will be processed
 * by GL texture unit zero.
 *
 * If a material does not yet exist in this mesh node, a new material will be
 * created and the texture will be attached to it.
 * 
 * Under iOS, during loading, textures are padded to dimensions of a power-of-two
 * (POT) and, because vertical OpenGL coordinates are inverted relative to iOS
 * view coordinates, most texture formats are loaded updside-down.
 *
 * To compensate, when a texture is attached to a mesh node, the texture coordinates
 * of the mesh are automatically adjusted to correctly display the texture, taking
 * into consideration POT padding and vertical orientation.
 */
@property(nonatomic, retain) CC3Texture* texture;

/**
 * In most situations, the material will use a single CC3Texture in the texture property.
 * However, if multi-texturing is used, additional CC3Texture instances can be provided
 * by adding them using this method.
 *
 * If a material does not yet exist in this mesh node, a new material will be
 * created and the texture will be attached to it.
 *
 * When multiple textures are attached to a material, when drawing, the material will
 * combine these textures together using configurations contained in the textureUnit
 * property of each texture.
 *
 * As a consistency convenience, if the texture property has not yet been set directly,
 * the first texture added using this method will appear in that property.
 *
 * Textures are processed by GL texture units in the order they are added to the material.
 * The first texture added (or set directly into the texture property) will be processed
 * by GL texture unit zero. Subsequent textures added with this method will be processed
 * by subsequent texture units, in the order they were added.
 *
 * The maximum number of texture units available is platform dependent, but will
 * be at least two. The maximum number of texture units available can be read from
 * [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value. If you attempt to
 * add more than this number of textures to the material, the additional textures
 * will be ignored, and an informational message to that fact will be logged.
 * 
 * Under iOS, during loading, textures are padded to dimensions of a power-of-two
 * (POT) and, because vertical OpenGL coordinates are inverted relative to iOS
 * view coordinates, most texture formats are loaded updside-down.
 *
 * To compensate, when a texture is attached to a mesh node, the texture coordinates
 * of the mesh are automatically adjusted to correctly display the texture, taking
 * into consideration POT padding and vertical orientation.
 */
-(void) addTexture: (CC3Texture*) aTexture;

/** Removes all textures from the material covering this mesh. */
-(void) removeAllTextures;

/**
 * Returns the texture that will be processed by the texture unit with the specified
 * index, which should be a number between zero, and one less than the value of the
 * textureCount property.
 *
 * The value returned will be nil if this node has no material,
 * or if that material has no textures.
 *
 * This method is a convenience. It simply delegates to the same method on the
 * material covering this mesh node, creating the material first, if needed.
 */
-(CC3Texture*) textureForTextureUnit: (GLuint) texUnit;

/**
 * Sets the texture that will be processed by the texture unit with the specified index,
 * which should be a number between zero, and the value of the textureCount property.
 * 
 * If the specified index is less than the number of texture units added already, the
 * specified texture will replace the one assigned to that texture unit. Otherwise, this
 * implementation will invoke the addTexture: method to add the texture to this material.
 *
 * If the specified texture unit index is zero, the value of the texture property will
 * be changed to the specified texture.
 *
 * If a material does not yet exist in this mesh node, a new material will be
 * created and the texture will be attached to it.
 * 
 * Under iOS, during loading, textures are padded to dimensions of a power-of-two
 * (POT) and, because vertical OpenGL coordinates are inverted relative to iOS
 * view coordinates, most texture formats are loaded updside-down.
 *
 * To compensate, when a texture is attached to a mesh node, the texture coordinates
 * of the mesh are automatically adjusted to correctly display the texture, taking
 * into consideration POT padding and vertical orientation.
 */
-(void) setTexture: (CC3Texture*) aTexture forTextureUnit: (GLuint) texUnit;

/**
 * Indicates whether the texture coordinates of this mesh expects that the texture
 * was flipped upside-down during texture loading.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * The value of this property is used in combination with the value of the 
 * isFlippedVertically property of a texture to determine whether the texture
 * will be oriented correctly when displayed using these texture coordinates.
 *
 * When a texture or material is assigned to this mesh node, the value of this
 * property is compared with the isFlippedVertically property of the texture to
 * automatically determine whether these texture coordinates need to be flipped
 * vertically in order to display the texture correctly. If needed, the texture
 * coordinates will be flipped automatically. As part of that inversion, the
 * value of this property will also be flipped, to indicate that the texture
 * coordinates are now aligned differently.
 *
 * If you need to adjust the value of this property, you sould do so before
 * setting a texture or material into this mesh node.
 *
 * When multi-texturing is being used on this mesh, you can use the
 * expectsVerticallyFlippedTexture:inTextureUnit: method for finer control
 * of orienting textures for each texture unit.
 *
 * When multi-texturing is being used, setting this value of this property will
 * use the expectsVerticallyFlippedTexture:inTextureUnit: method to set
 * the same value for each texture unit.
 *
 * Reading the value of this property will return YES if the property-reading
 * method expectsVerticallyFlippedTextureInTextureUnit: returns YES for
 * any texture unit, otherwise this property will return NO.
 * 
 * The initial value of this property is set when the underlying mesh texture
 * coordinates are built or loaded. See the same property on the CC3Resource
 * class to understand how this property is set during mesh resource loading.
 * 
 * When building meshes programmatically, you should endeavour to design the
 * mesh so that this property will be YES if you will be using vertically-flipped
 * textures (all texture file formats except PVR). This avoids the texture
 * coordinate having to be flipped automatically when a texture or material
 * is assigned to this mesh node.
 */
@property(nonatomic, assign) BOOL expectsVerticallyFlippedTextures;

/**
 * Returns whether the texture coordinates for the specfied texture unit expects
 * that the texture was flipped upside-down during texture loading.
 * 
 * The vertical axis of the coordinate system of OpenGL is inverted relative to
 * the iOS view coordinate system. This results in textures from most file formats
 * being oriented upside-down, relative to the OpenGL coordinate system. All file
 * formats except PVR format will be oriented upside-down after loading.
 *
 * The value of this property is used in combination with the value of the 
 * isFlippedVertically property of a texture to determine whether the texture
 * will be oriented correctly when displayed using these texture coordinates.
 *
 * When a texture or material is assigned to this mesh node, the value of this
 * property is compared with the isFlippedVertically property of the texture to
 * automatically determine whether these texture coordinates need to be flipped
 * vertically in order to display the texture correctly, and if needed, the
 * texture coordinates will be flipped automatically. As part of that inversion,
 * the value of this property will also be flipped, to indicate that the texture
 * coordinates are now aligned differently.
 *
 * If you need to adjust the value of this property, you sould do so before
 * setting a texture or material into this mesh node.
 * 
 * The initial value of this property is set when the underlying mesh texture
 * coordinates are built or loaded. See the expectsVerticallyFlippedTextures
 * property on the CC3Resource class to understand how this property is set
 * during mesh resource loading from model files.
 * 
 * When building meshes programmatically, you should endeavour to design the
 * mesh so that this property will be YES if you will be using vertically-flipped
 * textures (all texture file formats except PVR).
 */
-(BOOL) expectsVerticallyFlippedTextureInTextureUnit: (GLuint) texUnit;

/**
 * Sets whether the texture coordinates for the specfied texture unit expects
 * that the texture was flipped upside-down during texture loading.
 *
 * See the notes of the expectsVerticallyFlippedTextureInTextureUnit: method
 * for a discussion of texture coordinate orientation.
 *
 * Setting the value of this property will change the way the texture coordinates
 * are aligned when a texture is assigned to cover this texture unit for this mesh.
 */
-(void) expectsVerticallyFlippedTexture: (BOOL) expectsFlipped inTextureUnit: (GLuint) texUnit;

/**
 * Convenience method that flips the texture coordinate mapping vertically
 * for the specified texture channels. This has the effect of flipping the
 * texture for that texture channel vertically on the model. and can be
 * useful for creating interesting effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 */
-(void) flipVerticallyTextureUnit: (GLuint) texUnit;

/**
 * Convenience method that flips the texture coordinate mapping vertically
 * for all texture units. This has the effect of flipping the textures
 * vertically on the model. and can be useful for creating interesting
 * effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 *
 * This has the same effect as invoking the flipVerticallyTextureUnit:
 * method for all texture units.
 *
 * This method will also invoke the superclass behaviour to invoke
 * the same method on each child node.
 */
-(void) flipTexturesVertically;

/**
 * Convenience method that flips the texture coordinate mapping horizontally
 * for the specified texture channels. This has the effect of flipping the
 * texture for that texture channel horizontally on the model. and can be
 * useful for creating interesting effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 */
-(void) flipHorizontallyTextureUnit: (GLuint) texUnit;

/**
 * Convenience method that flips the texture coordinate mapping horizontally
 * for all texture units. This has the effect of flipping the textures
 * horizontally on the model. and can be useful for creating interesting
 * effects, or mirror images.
 *
 * This implementation flips correctly if the mesh is mapped
 * to only a section of the texture (a texture atlas).
 *
 * This has the same effect as invoking the flipHorizontallyTextureUnit:
 * method for all texture units.
 *
 * This method will also invoke the superclass behaviour to invoke
 * the same method on each child node.
 */
-(void) flipTexturesHorizontally;

/**
 * Configures the mesh so that a texture applied to the specified texture unit will
 * be repeated the specified number of times across the mesh, in each dimension.
 * The repeatFactor argument contains two numbers, corresponding to how many times
 * in each dimension the texture should be repeated.
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
 * You can specify a fractional value for either of the components of the repeatFactor
 * to expand the texture in that dimension so that only part of the texture appears
 * in that dimension, while potentially repeating multiple times in the other dimension.
 */
-(void) repeatTexture: (ccTex2F) repeatFactor forTextureUnit: (GLuint) texUnit;

/**
 * Configures the mesh so that the textures in all texture units will be repeated the
 * specified number of times across the mesh, in each dimension. The repeatFactor
 * argument contains two numbers, corresponding to how many times in each dimension
 * the texture should be repeated.
 *
 * This has the same effect as invoking the repeatTexture:forTextureUnit: method
 * for each texture unit.
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

/**
 * Indicates whether the RGB components of each pixel of the encapsulated textures
 * have had the corresponding alpha component applied already.
 *
 * Returns YES if any of the textures contained in this instance has pre-mulitiplied alpha.
 * 
 * See also the notes of the shouldApplyOpacityToColor property for the effects of using textures
 * with pre-multiplied alpha.
 */
@property(nonatomic, readonly) BOOL hasPremultipliedAlpha;

/**
 * Returns whether the opacity of each of the material colors (ambient, diffuse, specular and emission)
 * should be blended (multiplied) by its alpha value prior to being submitted to the GL engine,
 * and whether the alpha component of any vertex color should be blended into the vertex color.
 *
 * This property returns the value of the same property of the material of this node.
 *
 * If this property returns YES, each of the material colors will automatically be blended with its
 * alpha component prior to being submitted to the GL engine, and any vertex color set using the
 * setVertexColor4B:at: or setVertexColor4F:at: methods will automatically have its alpha value
 * blended into (multiplied into) each of the red, green and blue components of that vertex color,
 * before the color is set into the vertex.
 */
@property(nonatomic, readonly) BOOL shouldApplyOpacityToColor;


#pragma mark Drawing

/**
 * The drawing mode indicating how the vertices are connected (points, lines,
 * triangles...).
 *
 * This must be set with a valid GL drawing mode enumeration.
 * The default value is GL_TRIANGLES.
 */
@property(nonatomic, assign) GLenum drawingMode;

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


#pragma mark Vertex management

/**
 * Indicates the types of content contained in each vertex of this mesh.
 *
 * Each vertex can contain several types of content, optionally including location, normal,
 * color, texture coordinates, along with other specialized content for certain specialized
 * meshes. To identify this various content, this property is a bitwise-OR of flags that
 * enumerate the types of content contained in each vertex of this mesh.
 *
 * Valid component flags of this property include:
 *   - kCC3VertexContentLocation
 *   - kCC3VertexContentNormal
 *   - kCC3VertexContentColor
 *   - kCC3VertexContentTextureCoordinates
 *   - kCC3VertexContentPointSize
 *   - kCC3VertexContentWeights
 *   - kCC3VertexContentMatrixIndices
 *
 * To indicate that this mesh should contain particular vertex content, construct a
 * bitwise-OR combination of one or more of the component types listed above, and set
 * this property to that combined value.
 *
 * Setting this property affects the underlying mesh. When this property is set, if a mesh has
 * not yet been set in the mesh property of this node, a new CC3VertexArrayMesh, set to interleave
 * vertex data, will automatically be created and set into the mesh property of this node.
 *
 * When setting this property, if the kCC3VertexContentTextureCoordinates component is not
 * included, the texture property will be set to nil. If the kCC3VertexContentNormal component
 * is not included, the shouldUseLighting property will be set to NO automatically.
 *
 * This property is a convenience property. You can also construct the mesh by managing the
 * content directly within the underlying mesh. The effect that this property has on the internal
 * structure of the underlying mesh depends on the subclass of that mesh. In particular, see the
 * notes for this propety on the CC3VertexArrayMesh, CC3PointParticleMesh, and CC3SkinMesh classes
 * for more details, and specific use cases with those mesh subclasses.
 *
 * Not all meshes can contain all of the vertex content itemized above. In general, all
 * meshes can contain the first four vertex content types. Specialized mesh subclasses
 * can contain other combinations as follows:
 *   - kCC3VertexContentPointSize is accepted by CC3PointParticleEmitter in support of point particles.
 *   - kCC3VertexContentWeights and kCC3VertexContentMatrixIndices are accepted by CC3SkinMeshNode
 *     in support of skinned meshes controlled by bone-rigging.
 *
 * Meshes that do not support a particular vertex component type will silently ignore that
 * component of this property.
 * 
 * When reading this property, if no content has been defined for this mesh, this property
 * will return kCC3VertexContentNone.
 */
@property(nonatomic, assign) CC3VertexContent vertexContentTypes;


#pragma mark Accessing vertex data

/**
 * Changes the mesh vertices so that the origin of the mesh is at the specified location.
 *
 * The origin of the mesh is the location (0,0,0) in the local coordinate system, and is the
 * location around which all transforms are performed.
 *
 * This method can be used to adjust the mesh structure to make it easier to apply transformations,
 * by moving the origin of the transformations to a more convenient location in the mesh.
 *
 * This method changes the location component of every vertex in the mesh. This can be quite costly,
 * and should only be performed once, to adjust a mesh so that it is easier to manipulate. As an
 * alternate, you should consider changing the origin of the mesh at development time using a 3D editor.
 * 
 * Do not use this method to move your model around. Instead, use the transform properties
 * (location, rotation and scale) of this node, and let the GL engine do the heavy lifting of
 * transforming the mesh vertices.
 * 
 * This method automatically invokes the markBoundingVolumeDirty method, to ensure that the
 * boundingVolume encompasses the new vertex locations.
 *
 * This method also ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) moveMeshOriginTo: (CC3Vector) aLocation;

/**
 * Changes the mesh vertices so that the origin of the mesh is at the center of geometry of the mesh.
 *
 * The origin of the mesh is the location (0,0,0) in the local coordinate system, and is the
 * location around which all transforms are performed.
 *
 * This method can be used to adjust the mesh structure to make it easier to apply transformations,
 * by moving the origin of the transformations to the center of the mesh.
 *
 * This method changes the location component of every vertex in the mesh. This can be quite costly,
 * and should only be performed once, to adjust a mesh so that it is easier to manipulate. As an
 * alternate, you should consider changing the origin of the mesh at development time using a 3D editor.
 * 
 * Do not use this method to move your model around. Instead, use the transform properties
 * (location, rotation and scale) of this node, and let the GL engine do the heavy lifting of
 * transforming the mesh vertices.
 * 
 * This method automatically invokes the markBoundingVolumeDirty method, to ensure that the
 * boundingVolume encompasses the new vertex locations.
 *
 * This method also ensures that the GL VBO that holds the vertex data is updated.
 */
-(void) moveMeshOriginToCenterOfGeometry;

/** @deprecated Renamed to moveMeshOriginTo:. */
-(void) movePivotTo: (CC3Vector) aLocation DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to moveMeshOriginToCenterOfGeometry. */
-(void) movePivotToCenterOfGeometry DEPRECATED_ATTRIBUTE;

/**
 * Indicates the number of vertices in this mesh.
 *
 * Usually, you should treat this property as read-only. However, there may be
 * occasions with meshes that contain dynamic content, such as particle systems,
 * where it may be appropriate to set the value of this property.
 *
 * Setting the value of this property changes the amount of vertex content that
 * will be submitted to the GL engine during drawing.
 *
 * When setting this property, care should be taken to ensure that the value is
 * not set larger than the number of vertices that were allocated for this mesh.
 */
@property(nonatomic, assign) GLuint vertexCount;

/**
 * If indexed drawing is used by this mesh, indicates the number of vertex
 * indices in the mesh.
 *
 * If indexed drawing is not used by this mesh, this property has no effect,
 * and reading it will return zero.
 *
 * Usually, you should treat this property as read-only. However, there may be
 * occasions with meshes that contain dynamic content, such as particle systems,
 * where it may be appropriate to set the value of this property.
 *
 * Setting the value of this property changes the amount of vertex content that
 * will be submitted to the GL engine during drawing.
 *
 * When setting this property, care should be taken to ensure that the value is
 * not set larger than the number of vertices that were allocated for this mesh.
 */
@property(nonatomic, assign) GLuint vertexIndexCount;

/**
 * Returns the location element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * vertex data. If the dimensionality is 2, the returned vector will contain zero in
 * the Z component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * vertex data. If the dimensionality is 2, the Z component of the specified vector
 * will be ignored. If the dimensionality is 4, the specified vector will be converted
 * to a 4D vector, with the W component set to one, before storing.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexLocationsGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 * 
 * This method automatically invokes the markBoundingVolumeDirty method, to ensure that the
 * boundingVolume encompasses the new vertex locations.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index;

/**
 * Returns the location element at the specified index in the underlying vertex data,
 * as a four-dimensional location in the 4D homogeneous coordinate space.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the elementSize property. If the
 * value of the elementSize property is 3, the returned vector will contain one
 * in the W component. If the value of the elementSize property is 2, the returned
 * vector will contain zero in the Z component and one in the W component.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the underlying vertex data to
 * the specified four-dimensional location in the 4D homogeneous coordinate space.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex data is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * data. If the dimensionality is 3, the W component of the specified vector will be
 * ignored. If the dimensionality is 2, both the W and Z components of the specified
 * vector will be ignored.
 * 
 * When all vertex changes have been made, be sure to invoke the updateVertexLocationsGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 * 
 * This method automatically invokes the markBoundingVolumeDirty method, to ensure that the
 * boundingVolume encompasses the new vertex locations.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index;

/**
 * Returns the normal element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexNormalAt: (GLuint) index;

/**
 * Sets the normal element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index;

/**
 * Returns the symbolic content type of the vertex color, which indicates the range of values
 * stored for each vertex color.
 *
 * This property will return one of the values: GL_FLOAT, GL_UNSIGNED_BYTE, or GL_FIXED, or will return
 * GL_FALSE if this node does not have a mesh, or if that mesh does not support individual vertex colors.
 *
 * You can use the value returned by this property to select whether to access individual vertex
 * color content as bytes or floats, in order to retain accuracy and avoid unnecessary type conversions.
 */
@property(nonatomic, readonly) GLenum vertexColorType;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4F) vertexColor4FAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the shouldApplyOpacityToColor property of this node returns YES, each of the red, green
 * and blue components of the specified color will be multiplied by the alpha component of the
 * specified color before the color is set into the vertex. This occurs when the texture attached
 * to this mesh contains pre-multiplied alpha. When this occurs, the value retrieved using the
 * vertexColor4F: method will not be the same as the value set with this method, if the color
 * contained an alpha value less than one. See the notes of the shouldApplyOpacityToColor
 * property for more on using pre-multiplied alpha.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexColorsGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index;

/**
 * Returns the color element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccColor4B) vertexColor4BAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the shouldApplyOpacityToColor property of this node returns YES, each of the red, green
 * and blue components of the specified color will be multiplied by the alpha component of the
 * specified color before the color is set into the vertex. This occurs when the texture attached
 * to this mesh contains pre-multiplied alpha. When this occurs, the value retrieved using the
 * vertexColor4F: method will not be the same as the value set with this method, if the color
 * contained an alpha value less than 255. See the notes of the shouldApplyOpacityToColor
 * property for more on using pre-multiplied alpha.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexColorsGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the specified texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the specified texture unit index, to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBufferForTextureUnit: method
 * to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex data
 * at the commonly used texture unit zero.
 *
 * This is a convenience method that is equivalent to invoking the
 * vertexTexCoord2FForTextureUnit:at: method, with zero as the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex data,
 * at the commonly used texture unit zero, to the specified texture coordinate value.
 *
 * This is a convenience method that delegates to the setVertexTexCoord2F:forTextureUnit:at:
 * method, passing in zero for the texture unit index.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBuffer method to ensure that
 * the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index;

/** @deprecated Use the vertexTexCoord2FForTextureUnit:at: method instead, */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/** @deprecated Use the setVertexTexCoord2F:forTextureUnit:at: method instead, */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/**
 * Returns the index element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLuint) vertexIndexAt: (GLuint) index;

/**
 * Sets the index element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexIndicesGLBuffer method to ensure that the GL VBO
 * that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index;

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

/**
 * Convenience method to update the GL engine buffers with the vertex content data in this mesh.
 *
 * This updates the content of each vertex. It does not update the vertex indices. To update
 * the vertex index data to the GL engine, use the updateVertexIndicesGLBuffer method.
 */
-(void) updateGLBuffers;

/** Updates the GL engine buffer with the vertex index data in this mesh. */
-(void) updateVertexIndicesGLBuffer;


#pragma mark Faces

/**
 * Indicates whether information about the faces of this mesh should be cached.
 *
 * If this property is set to NO, accessing information about the faces through the
 * methods faceAt:, faceIndicesAt:, faceCenterAt:, faceNormalAt:, or facePlaneAt:,
 * will be calculated dynamically from the mesh data.
 *
 * If such data will be accessed frequently, this repeated dynamic calculation may
 * cause a noticable impact to performance. In such a case, this property can be
 * set to YES to cause the data to be calculated once and cached, improving the
 * performance of subsequent accesses to information about the faces.
 *
 * However, caching information about the faces will increase the amount of memory
 * required by the mesh, sometimes significantly. To avoid this additional memory
 * overhead, in general, you should leave this property set to NO, unless intensive
 * access to face information is causing a performance impact.
 *
 * An example of a situation where the use of this property may be noticable,
 * is when adding shadow volumes to nodes. Shadow volumes make intense use of
 * accessing face information about the mesh that is casting the shadow.
 *
 * When the value of this property is set to NO, any data cached during previous
 * access through the faceIndicesAt:, faceCenterAt:, faceNormalAt:, or facePlaneAt:,
 * methods will be cleared.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldCacheFaces;

/**
 * Returns the number of faces in this mesh.
 *
 * This is calculated from the number of vertices, taking into
 * consideration the type of primitives that this mesh is drawing.
 */
@property(nonatomic, readonly) GLuint faceCount;

/**
 * Returns the number of faces to be drawn from the specified number of
 * vertex indices, based on the type of primitives that this mesh is drawing.
 */ 
-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc;

/**
 * Returns the number of vertex indices required to draw the specified number
 * of faces, based on the type of primitives that this mesh is drawing.
 */ 
-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc;

/** @deprecated Renamed to faceCountFromVertexIndexCount:. */
-(GLuint) faceCountFromVertexCount: (GLuint) vc DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to vertexIndexCountFromFaceCount:. */
-(GLuint) vertexCountFromFaceCount: (GLuint) fc DEPRECATED_ATTRIBUTE;

/**
 * Returns the face from the mesh at the specified index.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex data, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure. For that
 * remaining vertex data, you can use the faceIndicesAt: method to retrieve the indices
 * of the vertex data, and then use the vertex accessor methods to retrieve the individual
 * vertex data components.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Face) faceAt: (GLuint) faceIndex;

/**
 * Returns the mesh face that is made up of the three vertices at the three indices
 * within the specified face indices structure.
 *
 * The returned face structure contains only the locations of the vertices. If the vertex
 * locations are interleaved with other vertex data, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure. For that
 * remaining vertex data, you can use the faceIndicesAt: method to retrieve the indices
 * of the vertex data, and then use the vertex accessor methods to retrieve the individual
 * vertex data components.
 */
-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices;

/**
 * Returns the face from the mesh at the specified index, as indices into the mesh vertices.
 *
 * The specified faceIndex value refers to the index of the face, not the vertices
 * themselves. So, a value of 5 will retrieve the three vertices that make up the
 * fifth triangular face in this mesh. The specified index must be between zero,
 * inclusive, and the value of the faceCount property, exclusive.
 *
 * The returned structure reference contains the indices of the three vertices that
 * make up the triangular face. These indices index into the actual vertex data within
 * the layout of the mesh.
 *
 * This method takes into consideration any padding (stride) between the vertex indices.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex;

/**
 * Returns the center of the mesh face at the specified index.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Vector) faceCenterAt: (GLuint) faceIndex;

/**
 * Returns the normal of the mesh face at the specified index.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Vector) faceNormalAt: (GLuint) faceIndex;

/**
 * Returns the plane of the mesh face at the specified index.
 *
 * If you will be invoking this method frequently, you can optionally set the
 * shouldCacheFaces property to YES to speed access, and possibly improve performance.
 * However, be aware that setting the shouldCacheFaces property to YES can significantly
 * increase the amount of memory used by the mesh.
 */
-(CC3Plane) facePlaneAt: (GLuint) faceIndex;

/** Returns the indices of the neighbours of the mesh face at the specified index. */
-(CC3FaceNeighbours) faceNeighboursAt: (GLuint) faceIndex;

/**
 * Populates the specified array with information about the intersections of the specified ray
 * and this mesh, up to the specified maximum number of intersections.
 *
 * This method returns the actual number of intersections found (up to the specified maximum).
 * This value indicates how many of the elements of the specifed intesections array were populated
 * during the execution of this method. The contents of elements beyond that number are undefined.
 *
 * Each of the populated elements of the intersections array contains information about the face
 * on which the intersection occurred, the location of the intersection, and the distance from the
 * ray startLocation where the intersection occurred. The location and distance components are
 * specified in the local coordinates system of this mesh.
 *
 * The intersections array is not sorted in any way. In particular, when the array contains multiple
 * entries, the first element in the array does not necessily contain the closest intersection.
 * If you need to determine the closest intersection, you can iterate the intersections array and
 * compare the values of the location element of each intersection.
 *
 * To use this method, allocate an array of CC3MeshIntersection structures, pass a reference to it
 * in the intersections parameter, and indicate the size of that array in the maxHitCount parameter.
 *
 * The method iterates through the faces in the mesh until the indicated number of intersections are
 * found, or until all the faces in the mesh have been inspected. Therefore, to keep performance high,
 * you should set the maxHitCount parameter no higher than the number of intersections that are useful
 * to you. For example, specifiying a value of one for the maxHitCount parameter will cause this method
 * to return as soon as the first intersection is found. In most cases, this is all that is needed.
 * 
 * The allowBackFaces parameter is used to indicate whether to include intersections where the ray
 * pierces a face from its back face. Typically, this means that the ray has intersected the face
 * as the ray exits on the far side of the mesh. In most cases you will interested only where the
 * ray intersects the near side of the mesh, in which case you can set this parameter to NO.
 *
 * The allowBehind parameter is used to indicate whether to include intersections that occur behind
 * the startLocation of the ray, in the direction opposite to the direction of the ray. Typically,
 * this might mean the mesh is located behind the ray startLocation, or it might mean the ray starts
 * inside the mesh. Again,in most cases, you will be interested only in intersections that occur in
 * the direction the ray is pointing, and can ususally set this parameter to NO.
 */
-(GLuint) findFirst: (GLuint) maxHitCount
	  intersections: (CC3MeshIntersection*) intersections
		 ofLocalRay: (CC3Ray) aRay
	acceptBackFaces: (BOOL) acceptBackFaces
	acceptBehindRay: (BOOL) acceptBehind;

/**
 * Populates the specified array with information about the intersections of the specified ray
 * and this mesh, up to the specified maximum number of intersections.
 *
 * This is a convenience method that converts the specified global ray to the local coordinate system
 * of this node, and invokes the findFirst:intersections:ofLocalRay:acceptBackFaces:acceptBehindRay:
 * method, and converts the location and distance components of each of the elements in the intersections
 * array to the global coordinate system.
 *
 * See the notes for the findFirst:intersections:ofLocalRay:acceptBackFaces:acceptBehindRay: method
 * to understand more about how to use this method.
 */
-(GLuint) findFirst: (GLuint) maxHitCount
globalIntersections: (CC3MeshIntersection*) intersections
		ofGlobalRay: (CC3Ray) aRay
	acceptBackFaces: (BOOL) acceptBackFaces
	acceptBehindRay: (BOOL) acceptBehind;

@end


#pragma mark -
#pragma mark CC3Node extension for mesh nodes

/** CC3Node category extension to support CC3MeshNodes. */
@interface CC3Node (CC3MeshNode)

/**
 * Indicates whether this node has 3D mesh data to be drawn.
 * Default value is NO. Subclasses that do draw 3D meshes will override to return YES.
 */
@property(nonatomic, readonly) BOOL isMeshNode;

/**
 * Convenience method that retrieves the first node found with the specified name,
 * anywhere in the structural hierarchy of descendants of this node (not just direct
 * children), and returns the node cast as a CC3MeshNode. The hierarchy search is
 * depth-first.
 *
 * This implementation simply invokes the getNodeNamed:, and casts the node returned
 * as a CC3MeshNode. An assertion is raised if the node is not a CC3MeshNode.
 */
-(CC3MeshNode*) getMeshNodeNamed: (NSString*) aName;

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
 * Since a cube or box is a mesh like any other mesh, the functionality required to create and
 * manipulate box meshes is present in the CC3MeshNode class, and if you choose, you can create
 * and manage box meshes using that class alone. At present, CC3BoxNode exists for the most part
 * simply to identify box meshes as such. However, in future, additional state or behaviour may
 * be added to this class.
 * 
 * You can use the following convenience method to aid in constructing a CC3BoxNode instance:
 *   - populateAsSolidBox:
 *   - populateAsSolidBox:withCorner:
 *   - populateAsWireBox:
 */
@interface CC3BoxNode : CC3MeshNode
@end


#pragma mark -
#pragma mark CC3LineNode

/**
 * CC3LineNode is a type of CC3MeshNode that is specialized to display lines.
 *
 * Since lines are a mesh like any other mesh, the functionality required to create and manipulate
 * line meshes is present in the CC3MeshNode class, and if you choose, you can create and manage line
 * meshes using that class alone. At present, CC3LineNode exists for the most part simply to identify
 * box meshes as such. However, in future, additional state or behaviour may be added to this class.
 *
 * To draw lines, you must make sure that the drawingMode property is set to one of GL_LINES,
 * GL_LINE_STRIP or GL_LINE_LOOP. This property must be set after the mesh is attached.
 * Other than that, you configure the mesh node and its mesh as you would with any mesh node.
 *
 * To color the lines, use the pureColor property to draw the lines in a pure, solid color
 * that is not affected by lighting conditions. You can also add a material to your CC3LineNode
 * instance to get more subtle coloring and blending, but this can sometimes
 * appear strange with lines. You can also use CCActionInterval to change the tinting or
 * opacity of the lines, as you would with any mesh node.
 *
 * Several convenience methods exist in the CC3MeshNode class to aid in constructing a
 * CC3LineNode instance:
 *   - populateAsLineStripWith:vertices:andRetain:
 *   - populateAsWireBox:  - a simple wire box
 */
@interface CC3LineNode : CC3MeshNode

/** @deprecated Property renamed to lineSmoothingHint on CC3MeshNode. */
@property(nonatomic, assign) GLenum performanceHint DEPRECATED_ATTRIBUTE;

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
	BOOL shouldAlwaysMeasureParentBoundingBox : 1;
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


#pragma mark Updating

/**
 * Updates this wireframe box from the bounding box of the parent node.
 *
 * The extent of the wireframe box is usually set automatically when first created, and is not
 * automatically updated if the parent bounding box changes. If you want this wireframe to update
 * automatically on each update frame, set the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * However, updating on each frame can be a drag on performance, so if the parent bounding box
 * changes under app control, you can invoke this method whenever the bounding box of the parent
 * node changes to keep the wireframe box synchronized with its parent. 
 */
-(void) updateFromParentBoundingBox;

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
 * CC3DirectionMarkerNode is a type of CC3LineNode specialized for drawing a line from the origin
 * of its parent node to a point outside the bounding box of the parent node, in a particular
 * direction. A CC3DirectionMarkerNode is typically added as a child node to the node to visibly
 * indicate the orientation of the parent node.
 *
 * The CC3DirectionMarkerNode node can be set to automatically track the dynamic nature of the
 * boundingBox of the parent node by setting the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * Since we don't want to add descriptor labels or wireframe boxes to direction marker nodes, the
 * shouldDrawDescriptor, shouldDrawWireframeBox, and shouldDrawLocalContentWireframeBox properties
 * are overridden to do nothing when set, and to always return YES.
 *
 * Similarly, CC3DirectionMarkerNode node does not participate in calculating the bounding box of
 * the node whose bounding box it is drawing, since, as a child of that node, it would interfere
 * with accurate measurement of the bounding box.
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
 * the origin of the parent node.
 *
 * When setting the value of this property, the incoming vector will be normalized to a unit vector.
 *
 * The value of this property defaults to kCC3VectorUnitZNegative, a unit vector
 * in the direction of the negative Z-axis, which is the OpenGL ES default direction.
 */
@property(nonatomic, assign) CC3Vector markerDirection;

/**
 * Returns the proportional distance that the direction marker line should protrude from the parent
 * node. This is measured in proportion to the distance from the origin of the parent node to the
 * side of the bounding box through which the line is protruding.
 *
 * The initial value of this property is 1.5.
 */
+(GLfloat) directionMarkerScale;

/**
 * Sets the proportional distance that the direction marker line should protrude from the parent node.
 * This is measured in proportion to the distance from the origin of the parent node to the side of
 * the bounding box through which the line is protruding.
 *
 * The initial value of this property is 1.5.
 */
+(void) setDirectionMarkerScale: (GLfloat) scale;

/**
 * Returns the minimum length of a direction marker line, expressed in the global
 * coordinate system.
 *
 * Setting a value for this property can be useful for adding direction markers
 * to very small nodes, or nodes that do not have volume, such as a camera or light.
 *
 * The initial value of this property is zero.
 */
+(GLfloat) directionMarkerMinimumLength;

/**
 * Sets the minimum length of a direction marker line, expressed in the global
 * coordinate system.
 *
 * Setting a value for this property can be useful for adding direction markers
 * to very small nodes, or nodes that do not have volume, such as a camera or light.
 *
 * The initial value of this property is zero.
 */
+(void) setDirectionMarkerMinimumLength: (GLfloat) len;

@end


#pragma mark -
#pragma mark CC3BoundingVolumeDisplayNode

/**
 * CC3BoundingVolumeDisplayNode is a type of CC3MeshNode specialized for displaying
 * the bounding volume of its parent node. A CC3BoundingVolumeDisplayNode is typically
 * added as a child node to the node whose bounding volume is to be displayed.
 */
@interface CC3BoundingVolumeDisplayNode : CC3MeshNode
@end



