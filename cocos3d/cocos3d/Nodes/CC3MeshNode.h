/*
 * CC3MeshNode.h
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

#import "CC3LocalContentNode.h"
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
 * instance, or a pure color. The CC3Mesh instance contains the mesh vertex content. The CC3Material
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
	CC3Mesh* _mesh;
	CC3Material* _material;
	CC3ShaderContext* _shaderContext;
	ccColor4F _pureColor;
	GLenum _depthFunction;
	GLfloat _decalOffsetFactor;
	GLfloat _decalOffsetUnits;
	GLfloat _lineWidth;
	GLenum _lineSmoothingHint;
	CC3NormalScaling _normalScalingMethod : 4;
	BOOL _shouldSmoothLines : 1;
	BOOL _shouldDisableDepthMask : 1;
	BOOL _shouldDisableDepthTest : 1;
	BOOL _shouldCullFrontFaces : 1;
	BOOL _shouldCullBackFaces : 1;
	BOOL _shouldDrawInClipSpace : 1;
	BOOL _shouldUseClockwiseFrontFaceWinding : 1;
	BOOL _shouldUseSmoothShading : 1;
	BOOL _shouldCastShadowsWhenInvisible : 1;
	BOOL _shouldApplyOpacityAndColorToMeshContent : 1;
	BOOL _hasRigidSkeleton : 1;		// Used by skinned mesh node subclasses
}

/**
 * The mesh that holds the vertex content for this mesh node.
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
 * If a mesh does not yet exist, this method invokes the makeMesh method to create
 * a suitable mesh, and sets it into the mesh property. Does nothing if this mesh
 * node already has a mesh. Returns the mesh (existing or new).
 *
 * This method is invoked whenever a property is set that would affect the mesh.
 * Usually, you will never need to invoke this method.
 */
-(CC3Mesh*) ensureMesh;

/**
 * This template method creates a suitable mesh for this mesh node.
 *
 * This implementation invokes [CC3Mesh mesh], and returns the result.
 * Subclasses may override to provide a different mesh.
 *
 * This method is invoked automatically by the ensureMesh method if a mesh is needed,
 * but has not yet been established. Usually, you will never need to invoke this method.
 */
-(CC3Mesh*) makeMesh;

/**
 * Returns whether the underlying vertex content has been loaded into GL engine vertex
 * buffer objects. Vertex buffer objects are engaged via the createGLBuffers method.
 */
@property(nonatomic, readonly) BOOL isUsingGLBuffers;

/**
 * The normal scaling method that is currently in use for this mesh node.
 *
 * This property differs from the normalScalingMethod. The normalScalingMethod is a settable
 * property that is used to indicate the desired scaling method to be used for normals, and
 * can include a setting of kCC3NormalScalingAutomatic, to allow the mesh node to resolve
 * which method to use. This property returns that resolved value.
 *
 * If the mesh has vertex normals, this property will match the normalScalingMethod for values
 * kCC3NormalScalingNone, kCC3NormalScalingRescale & kCC3NormalScalingNormalize. If the mesh
 * does not contain vertex normals, this property will always return kCC3NormalScalingNone.
 */
@property(nonatomic, readonly) CC3NormalScaling effectiveNormalScalingMethod;


#pragma mark Materials

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
 * The shininess of the material of this mesh node.
 *
 * The value of this property is clamped to between zero and kCC3MaximumMaterialShininess.
 * The initial value of this property is kCC3DefaultMaterialShininess (zero).
 */
@property(nonatomic, assign) GLfloat shininess;

/**
 * The reflectivity of the material of this mesh node.
 *
 * This property can be used when the material is covered by an environmental reflection cube-map
 * texture to indicate the weighting that should be applied to the reflection texture, relative to
 * any other textures on the material. A value of zero indicates that the surface should be
 * completely unreflective, and a value of one indicates that the surface is entirely reflective.
 *
 * This property requires a programmable pipeline and has no effect when running OpenGL ES 1.1.
 *
 * The value of this property is clamped to between zero and one.
 * The initial value of this property is kCC3DefaultMaterialReflectivity (zero).
 */
@property(nonatomic, assign) GLfloat reflectivity;

/** 
 * If a material does not yet exist, this method invokes the makeMaterial method to create
 * a suitable material, and sets it into the material property. Does nothing if this mesh
 * node already has a material. Returns the material (existing or new).
 *
 * This method is invoked whenever a property is set that would affect the material.
 * Usually, you will never need to invoke this method.
 */
-(CC3Material*) ensureMaterial;

/**
 * This template method creates a suitable material for this mesh node.
 *
 * The new material's initial diffuse and ambient colors are modulated by the value of the
 * pureColor property to propagate any color changes already made into the material. The
 * initial value of pureColor is pure white, so if it has not been changed, the ambient and
 * diffuse colors of the material will take on their default initial values.
 * Subclasses may override to provide a different material.
 *
 * This method is invoked automatically by the ensureMaterial method if a material is needed,
 * but has not yet been established. Usually, you will never need to invoke this method.
 */
-(CC3Material*) makeMaterial;


#pragma mark Shaders

/**
 * The GLSL shader program context containing the GLSL program (vertex & fragment shaders) 
 * used to draw this node.
 *
 * A single CC3ShaderProgram object can be used by many nodes. The CC3ShaderContext
 * instance in this property contains state and behaviour specific to the use of the shader
 * program by this mesh node.
 *
 * Each shader program typically makes use of many uniform variables. In most, or many, cases,
 * each uniform will have a semantic defined, and the content of the uniform will automatically
 * be extracted from the environment, including from this mesh node itself. So, in most cases,
 * once the semantic is defined, the application needs pay no further attention to the uniform.
 *
 * The shader context can be used to modify this standard semanitic-driven behaviour in two
 * ways. This shader context can be used to assign a value to a specialized or custom shader
 * uniform whose value is not derived semantically from the node or the environment, and it 
 * can be used to override the value of an otherwise semantically-derived uniform, if needed.
 *
 * If this property is not set directly, it is automatically initialized to a new shader 
 * context instance on first access (typically when the shaderProgram property is established,
 * or a uniform override is added). Unless you have a need to set the value of this property
 * directly, you can simply let it be managed automatically.
 *
 * This property is used only when running under OpenGL ES 2.
 */
@property(nonatomic, retain) CC3ShaderContext* shaderContext;

/**
 * The GLSL program (vertex & fragment shaders) used to draw this node.
 *
 * The program is held in the shader context in the shaderContext property. This is a 
 * convenience property that allows the shader program to be accessed from the shaderContext.
 *
 * Setting the value of this property will set the specified program into the context in the
 * shaderContext property, creating a new shader context if necessary.
 *
 * As an alternative to setting this property directly, you can either access this property,
 * or invoke the selectShaderProgram method (or let it be invoked automatically during the 
 * first draw), to have an appropriate shader program automatically selected for use by this
 * node, and assigned to this property,
 *
 * This property is used only when running under OpenGL ES 2.
 */
@property(nonatomic, retain) CC3ShaderProgram* shaderProgram;

/**
 * Selects an appropriate shader program for this mesh node, and returns that shader program.
 *
 * When running under a programmable rendering pipeline, such as OpenGL ES 2.0 or OpenGL, all
 * mesh nodes require shaders to be assigned. This can be done directly using the shaderProgram
 * property. Or a shader program can be selected automatically based on the characteristics of
 * the mesh node by invoking this method.
 *
 * Since all mesh nodes require shaders, if this method is not invoked, and a shader program 
 * was not manually assigned via the shaderProgram property, a shaders will be automatically 
 * assigned to each mesh node the first time it is rendered. The automatic selection is the 
 * same, whether this method is invoked, or the selection is made lazily. However, if the 
 * shaders must be loaded and compiled, there can be a noticable pause in drawing a mesh node
 * for the first time if lazy assignment is used.
 *
 * Shader selection is driven by the characteristics of the mesh node and its material,
 * including the number of textures, whether alpha testing is used, etc. If you change
 * any of these characteristics that affect the shader selection, you can invoke the
 * removeLocalShaders method to cause a different shader program to be selected, based
 * on the new mesh node and material characteristics.
 *
 * Shader selection is handled by an implementation of the CC3ShaderMatcher held in the
 * CC3ShaderProgram shaderMatcher class-side property. The application can therefore 
 * customize shader program selection by establishing a custom instance in the 
 * CC3ShaderProgram shaderMatcher class-side property
 *
 * This method differs from the selectShaders method in that this method does not
 * propagate to any descendant nodes.
 */
-(CC3ShaderProgram*) selectShaderProgram;

/**
 * Removes the shaders from this mesh node, allowing new shaders to be selected, either directly
 * by subsequently invoking the selectShaderProgram method, or automatically the next time this
 * mesh node is drawn.
 *
 * Shader selection is driven by the characteristics of the mesh node and its material,
 * including the number of textures, whether alpha testing is used, etc. If you change
 * any of these characteristics that affect the shader selection, you can invoke the
 * removeLocalShaders method to cause a different shader program to be selected, based
 * on the new mesh node and material characteristics.
 *
 * This method is equivalent to setting the shaderProgram property to nil.
 *
 * This method differs from the removeShaders method in that this method does not
 * propagate to any descendant nodes.
 */
-(void) removeLocalShaders;

/** @deprecated Renamed to removeLocalShaders. */
-(void) clearShaderProgram DEPRECATED_ATTRIBUTE;


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
 *
 * When building for iOS, raw PNG and TGA images are pre-processed by Xcode to pre-multiply
 * alpha, and to reorder the pixel component byte order, to optimize the image for the iOS
 * platform. If you want to avoid this pre-processing for PNG or TGA files, for textures
 * such as normal maps or lighting maps, that you don't want to be modified, you can prepend
 * a 'p' to the file extension ("ppng" or "ptga") to cause Xcode to skip this pre-processing
 * and to use a loader that does not pre-multiply the alpha. You can also use this for other
 * file types as well. See the notes for the CC3STBImage useForFileExtensions class-side
 * property for more info.
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
 * The maximum number of texture units available is platform dependent, but will be
 * at least two. The maximum number of texture units available can be read from the
 * CC3OpenGL.sharedGL.maxNumberOfTextureUnits property. If you attempt to add more than
 * this number of textures to the material, the additional textures will be ignored,
 * and an informational message to that fact will be logged.
 *
 * Under iOS, during loading, textures are padded to dimensions of a power-of-two
 * (POT) and, because vertical OpenGL coordinates are inverted relative to iOS
 * view coordinates, most texture formats are loaded updside-down.
 *
 * To compensate, when a texture is attached to a mesh node, the texture coordinates
 * of the mesh are automatically adjusted to correctly display the texture, taking
 * into consideration POT padding and vertical orientation.
 *
 * When building for iOS, raw PNG and TGA images are pre-processed by Xcode to pre-multiply
 * alpha, and to reorder the pixel component byte order, to optimize the image for the iOS
 * platform. If you want to avoid this pre-processing for PNG or TGA files, for textures
 * such as normal maps or lighting maps, that you don't want to be modified, you can prepend
 * a 'p' to the file extension ("ppng" or "ptga") to cause Xcode to skip this pre-processing
 * and to use a loader that does not pre-multiply the alpha. You can also use this for other
 * file types as well. See the notes for the CC3STBImage useForFileExtensions class-side
 * property for more info.
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
 * The vertical axis of the coordinate system of OpenGL is inverted relative to the
 * CoreGraphics view coordinate system. As a result, some texture file formats may be
 * loaded upside down. Most common file formats, including JPG, PNG & PVR are loaded
 * right-way up, but using proprietary texture formats developed for other platforms
 * may result in textures being loaded upside-down.
 *
 * The value of this property is used in combination with the value of the 
 * isUpsideDown property of a texture to determine whether the texture
 * will be oriented correctly when displayed using these texture coordinates.
 *
 * When a texture or material is assigned to this mesh node, the value of this
 * property is compared with the isUpsideDown property of the texture to
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
 * coordinates are built or loaded. See the same property on the CC3NodesResource
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
 * isUpsideDown property of a texture to determine whether the texture
 * will be oriented correctly when displayed using these texture coordinates.
 *
 * When a texture or material is assigned to this mesh node, the value of this
 * property is compared with the isUpsideDown property of the texture to
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
 * property on the CC3NodesResource class to understand how this property is set
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
 * Returns whether this mesh is being drawn as point sprites.
 *
 * This property returns YES if this mesh node has a texture and the drawingMode property
 * is set to GL_POINTS, otherwise this property returns NO.
 */
@property(nonatomic, readonly) BOOL isDrawingPointSprites;

/**
 * Returns whether any of the textures used by this material have an alpha channel, representing opacity.
 *
 * Returns YES if any of the textures contained in this instance has an alpha channel.
 *
 * See also the notes of the shouldBlendAtFullOpacity property for the effects of using a
 * texture with an alpha channel.
 */
@property(nonatomic, readonly) BOOL hasTextureAlpha;

/**
 * Returns whether the alpha channel has already been multiplied into each of the RGB
 * color channels, in any of the textures used by this material.
 *
 * Returns YES if any of the textures contained in this instance has pre-mulitiplied alpha.
 *
 * See also the notes of the shouldApplyOpacityToColor property for the effects of using textures
 * with pre-multiplied alpha.
 */
@property(nonatomic, readonly) BOOL hasTexturePremultipliedAlpha;

/** @deprecated Renamed to hasTexturePremultipliedAlpha. */
@property(nonatomic, readonly) BOOL hasPremultipliedAlpha DEPRECATED_ATTRIBUTE;

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
 *   - kCC3VertexContentTangent
 *   - kCC3VertexContentBitangent
 *   - kCC3VertexContentColor
 *   - kCC3VertexContentTextureCoordinates
 *   - kCC3VertexContentBoneWeights
 *   - kCC3VertexContentBoneIndices
 *   - kCC3VertexContentPointSize
 *
 * To indicate that this mesh should contain particular vertex content, construct a
 * bitwise-OR combination of one or more of the component types listed above, and set
 * this property to that combined value.
 *
 * Setting this property affects the underlying mesh. When this property is set, if a mesh
 * has not yet been set in the mesh property of this node, a new CC3Mesh, set to interleave
 * vertex content, will automatically be created and set into the mesh property of this node.
 *
 * When setting this property, if the kCC3VertexContentTextureCoordinates component is not
 * included, the texture property will be set to nil. If the kCC3VertexContentNormal component
 * is not included, the shouldUseLighting property will be set to NO automatically.
 *
 * This property is a convenience property. You can also construct the mesh by managing the
 * vertex content directly by assigning specific vertex arrays to the appropriate properties
 * on the underlying mesh.
 *
 * The mesh constructed by this property will be configured to use interleaved data if the
 * shouldInterleaveVertices property of the mesh is set to YES. You should ensure the value
 * of the shouldInterleaveVertices property of the underlying mesh is set to the desired value
 * before setting the value of this property. The initial value of the shouldInterleaveVertices
 * property is YES.
 *
 * If the content is interleaved, for each vertex, the content is held in the structures identified in
 * the list above, in the order that they appear in the list. You can use this consistent organization
 * to create an enclosing structure to access all data for a single vertex, if it makes it easier to
 * access vertex content that way. If vertex content is not specified, it is simply absent, and the content
 * from the following type will be concatenated directly to the content from the previous type.
 *
 * For instance, in a typical textured and illuminated mesh, you might not require per-vertex
 * color, tangent and bitangent content. You would therefore omit the kCC3VertexContentColor,
 * kCC3VertexContentTangent and kCC3VertexContentBitangent values in the bitmask when setting
 * this property, and the resulting structure for each vertex would be a location CC3Vector,
 * followed by a normal CC3Vector, followed immediately by a texture coordinate ccTex2F.
 * You can then define an enclosing structure to hold and manage all content for a single vertex.
 * In this particular example, this is already done for you with the CC3TexturedVertex structure.
 *
 * You can declare and use such a custom vertex structure even if you have constructed the vertex
 * arrays directly, without using this property. The structure of the content of a single vertex
 * is the same in either case.
 *
 * The vertex arrays created in the underlying mesh by this property cover the most common use
 * cases and data formats. If you require more customized vertex arrays, you can use this property
 * to create the typical mesh content, and then customize the mesh, by accessing the vertex arrays
 * individually through their respective properties on the mesh. After doing so, if the vertex
 * content is interleaved, you should invoke the updateVertexStride method on the mesh to
 * automatically align the elementOffset and vertexStride properties of all of the vertex arrays.
 * After setting this property, you do not need to invoke the updateVertexStride method unless
 * you subsequently make changes to the constructed vertex arrays.
 *
 * It is safe to set this property more than once. Doing so will remove any existing vertex arrays
 * and replace them with those indicated by this property.
 *
 * When reading this property, the appropriate bitwise-OR values are returned, corresponding to
 * the mesh vertex arrays, even if those arrays were constructed directly, instead of through
 * setting this property. If this mesh contains no vertex arrays, this property will return
 * kCC3VertexContentNone.
 */
@property(nonatomic, assign) CC3VertexContent vertexContentTypes;


#pragma mark Accessing vertex content

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
 * This method also ensures that the GL VBO that holds the vertex content is updated.
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
 * This method also ensures that the GL VBO that holds the vertex content is updated.
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
 * If indexed drawing is used by this mesh, indicates the number of vertex indices in the mesh.
 *
 * If indexed drawing is not used by this mesh, this property has no effect, and reading it
 * will return zero.
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
 * Returns the location element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * vertex content. If the dimensionality is 2, the returned vector will contain zero in
 * the Z component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * vertex content. If the dimensionality is 2, the Z component of the specified vector
 * will be ignored. If the dimensionality is 4, the specified vector will be converted
 * to a 4D vector, with the W component set to one, before storing.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexLocationsGLBuffer
 * method to ensure that the GL VBO that holds the vertex content is updated.
 * 
 * This method automatically invokes the markBoundingVolumeDirty method, to ensure that the
 * boundingVolume encompasses the new vertex locations.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index;

/**
 * Returns the location element at the specified index in the underlying vertex content,
 * as a four-dimensional location in the 4D homogeneous coordinate space.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * This implementation takes into consideration the elementSize property. If the
 * value of the elementSize property is 3, the returned vector will contain one
 * in the W component. If the value of the elementSize property is 2, the returned
 * vector will contain zero in the Z component and one in the W component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the underlying vertex content to
 * the specified four-dimensional location in the 4D homogeneous coordinate space.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * This implementation takes into consideration the dimensionality of the underlying
 * data. If the dimensionality is 3, the W component of the specified vector will be
 * ignored. If the dimensionality is 2, both the W and Z components of the specified
 * vector will be ignored.
 * 
 * When all vertex changes have been made, be sure to invoke the updateVertexLocationsGLBuffer
 * method to ensure that the GL VBO that holds the vertex content is updated.
 * 
 * This method automatically invokes the markBoundingVolumeDirty method, to ensure that the
 * boundingVolume encompasses the new vertex locations.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index;

/**
 * Returns the normal element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexNormalAt: (GLuint) index;

/**
 * Sets the normal element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index;

/**
 * Returns the tangent element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexTangentAt: (GLuint) index;

/**
 * Sets the tangent element at the specified index in the vertex content to the specified value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexTangent: (CC3Vector) aTangent at: (GLuint) index;

/**
 * Returns the tangent element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(CC3Vector) vertexBitangentAt: (GLuint) index;

/**
 * Sets the bitangent element at the specified index in the vertex content to the specified value.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexNormalsGLBuffer method to ensure that the GL VBO
 * that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexBitangent: (CC3Vector) aTangent at: (GLuint) index;

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
 * Returns the color element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccColor4F) vertexColor4FAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex content to the specified value.
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
 * method to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index;

/**
 * Returns the color element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccColor4B) vertexColor4BAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex content to the specified value.
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
 * method to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index;

/**
 * Returns the number of bones that influence each vertex in this mesh. This value defines
 * the number of bone weights and bone indices that are attached to each vertex.
 */
@property(nonatomic, readonly) GLuint vertexBoneCount;

/**
 * Returns the weight value, for the specified influence index within the vertex, for the
 * vertex at the specified index within the underlying vertex content.
 *
 * The weight indicates how much a particular bone influences the movement of the particular
 * vertex. Several weights are stored for each vertex, one for each bone that influences the
 * movement of that vertex. The specified influenceIndex parameter must be between zero, and
 * the vertexBoneCount property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLfloat) vertexWeightForBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Sets the weight value, for the specified influence index within the vertex, for the
 * vertex at the specified index within the underlying vertex content.
 *
 * The weight indicates how much a particular bone influences the movement of the particular
 * vertex. Several weights are stored for each vertex, one for each bone that influences the
 * movement of that vertex. The specified influenceIndex parameter must be between zero, and
 * the vertexBoneCount property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexBoneWeightsGLBuffer
 * method to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexWeight: (GLfloat) weight forBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Returns the weights of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several weights are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the returned array is the same for each vertex
 * in this vertex array, as defined by the vertexBoneCount property.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLfloat*) vertexBoneWeightsAt: (GLuint) vtxIndex;

/**
 * Sets the weights of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several weights are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the specified input array must therefore be at
 * least as large as the value of the vertexBoneCount property.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexBoneWeightsGLBuffer
 * method to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexBoneWeights: (GLfloat*) weights at: (GLuint) vtxIndex;

/**
 * Returns the index of the bone, that provides the influence at the specified influence index
 * within a vertex, for the vertex at the specified index within the underlying vertex content.
 *
 * The bone index indicates which bone provides the particular influence for the movement of
 * the particular vertex. Several bone indices are stored for each vertex, one for each bone
 * that influences the movement of that vertex. The specified influenceIndex parameter must
 * be between zero, and the vertexBoneCount property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLuint) vertexBoneIndexForBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Sets the index of the bone, that provides the influence at the specified influence index
 * within a vertex, for the vertex at the specified index within the underlying vertex content.
 *
 * The bone index indicates which bone provides the particular influence for the movement of
 * the particular vertex. Several bone indices are stored for each vertex, one for each bone
 * that influences the movement of that vertex. The specified influenceIndex parameter must
 * be between zero, and the vertexBoneCount property (inclusive/exclusive respectively).
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexBoneIndicesGLBuffer
 * method to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexBoneIndex: (GLuint) boneIndex forBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex;

/**
 * Returns the indices of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several indices are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the returned array is the same for each vertex
 * in this vertex array, as defined by the vertexBoneCount property.
 *
 * The bone indices can be stored in each vertex as either type GLushort or type GLubyte.
 * The returned array will be of the type of index stored by the verties in this mesh, and it
 * is up to the application to know which type will be returned, and cast the returned array
 * accordingly. The type can be determined by the vertexBoneIndexType property of this mesh,
 * which will return one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLvoid*) vertexBoneIndicesAt: (GLuint) vtxIndex;

/**
 * Sets the indices of all of the bones that influence the movement of the vertex at the
 * specified index within the underlying vertex content.
 *
 * Several indices are stored for each vertex, one for each bone that influences the movement
 * of the vertex. The number of elements in the specified input array must therefore be at
 * least as large as the value of the vertexBoneCount property.
 *
 * The bone indices can be stored in each vertx as either type GLushort or type GLubyte.
 * The specified array must be of the type of index stored by the verties in this mesh, and
 * it is up to the application to know which type is required, and provide that type of array
 * accordingly. The type can be determined by the vertexBoneIndexType property of this mesh,
 * which will return one of GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE, respectively.
 *
 * To avoid checking the elementType altogether, you can use the setVertxBoneIndex:forBoneInfluence:at:
 * method, which sets the bone index values one at a time, and automatically converts the input type to
 * the correct stored type.
 *
 * The vertex index refers to vertices, not bytes. The implementation takes into consideration
 * whether the vertex content is interleaved to access the correct vertex content component.
 *
 * When all vertex changes have been made, be sure to invoke the updateVertexBoneIndicesGLBuffer
 * method to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexBoneIndices: (GLvoid*) boneIndices at: (GLuint) vtxIndex;

/**
 * Returns the type of data element used to store each bone index.
 *
 * The value returned by this property will be either GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE,
 * corresponding to each bone index being stored in either a type GLushort or type GLubyte,
 * respectively.
 *
 * You can use the value of this property to determine how to cast the data arrays used by
 * the vertexBoneIndicesAt: and setVertexBoneIndices:at: methods.
 */
@property(nonatomic, readonly) GLenum vertexBoneIndexType;

/**
 * Returns the texture coordinate element at the specified index from the vertex content
 * at the specified texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex content,
 * at the specified texture unit index, to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexTextureCoordinatesGLBufferForTextureUnit: method
 * to ensure that the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex content
 * at the commonly used texture unit zero.
 *
 * This is a convenience method that is equivalent to invoking the
 * vertexTexCoord2FForTextureUnit:at: method, with zero as the texture unit index.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex content,
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
 * the GL VBO that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index;

/** @deprecated Use the vertexTexCoord2FForTextureUnit:at: method instead, */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/** @deprecated Use the setVertexTexCoord2F:forTextureUnit:at: method instead, */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index forTextureUnit: (GLuint) texUnit DEPRECATED_ATTRIBUTE;

/**
 * Returns the index element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(GLuint) vertexIndexAt: (GLuint) index;

/**
 * Sets the index element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the
 * updateVertexIndicesGLBuffer method to ensure that the GL VBO
 * that holds the vertex content is updated.
 *
 * If the releaseRedundantContent method has been invoked and the underlying
 * vertex content has been released, this method will raise an assertion exception.
 */
-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index;

/** Updates the GL engine buffer with the vertex location content in this mesh. */
-(void) updateVertexLocationsGLBuffer;

/** Updates the GL engine buffer with the vertex normal content in this mesh. */
-(void) updateVertexNormalsGLBuffer;

/** Updates the GL engine buffer with the vertex tangent content in this mesh. */
-(void) updateVertexTangentsGLBuffer;

/** Updates the GL engine buffer with the vertex tangent content in this mesh. */
-(void) updateVertexBitangentsGLBuffer;

/** Updates the GL engine buffer with the vertex color content in this mesh. */
-(void) updateVertexColorsGLBuffer;

/** Updates the GL engine buffer with the vertex bone weight content in this mesh. */
-(void) updateVertexBoneWeightsGLBuffer;

/** Updates the GL engine buffer with the vertex bone indices content in this mesh. */
-(void) updateVertexBoneIndicesGLBuffer;

/**
 * Updates the GL engine buffer with the vertex texture coord content from the
 * specified texture unit in this mesh.
 */
-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit;

/**
 * Updates the GL engine buffer with the vertex texture coord content from
 * texture unit zero in this mesh.
 */
-(void) updateVertexTextureCoordinatesGLBuffer;

/**
 * Convenience method to update the GL engine buffers with the vertex content in this mesh.
 *
 * This updates the content of each vertex. It does not update the vertex indices. To update
 * the vertex index data to the GL engine, use the updateVertexIndicesGLBuffer method.
 */
-(void) updateGLBuffers;

/** Updates the GL engine buffer with the vertex index content in this mesh. */
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
 * locations are interleaved with other vertex content, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure. For that
 * remaining vertex content, you can use the faceIndicesAt: method to retrieve the indices
 * of the vertex content, and then use the vertex accessor methods to retrieve the individual
 * vertex content components.
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
 * locations are interleaved with other vertex content, such as color or texture coordinates,
 * or other padding, that data will not appear in the returned face structure. For that
 * remaining vertex content, you can use the faceIndicesAt: method to retrieve the indices
 * of the vertex content, and then use the vertex accessor methods to retrieve the individual
 * vertex content components.
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
 * make up the triangular face. These indices index into the actual vertex content within
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


#pragma mark Drawing

/**
 * The drawing mode indicating how the vertices are connected (points, lines, triangles...).
 *
 * This must be set with a valid GL drawing mode enumeration. The default value is GL_TRIANGLES.
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


#pragma mark Deprecated methods

/** *@deprecated Renamed to vertexBoneCount. */
@property(nonatomic, readonly) GLuint vertexUnitCount DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to vertexWeightForBoneInfluence:at:. */
-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setVertexWeight:forBoneInfluence:at:. */
-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to vertexBoneWeightsAt:. */
-(GLfloat*) vertexWeightsAt: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setVertexBoneWeights:at:. */
-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to vertexBoneIndexForBoneInfluence:at:. */
-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setVertexBoneIndex:forBoneInfluence:at:. */
-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex
			   forVertexUnit: (GLuint) vertexUnit
						  at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to vertexBoneIndicesAt:. */
-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to setVertexBoneIndices:at:. */
-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to vertexBoneIndexType. */
@property(nonatomic, readonly) GLenum matrixIndexType DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to updateVertexBoneWeightsGLBuffer. */
-(void) updateVertexWeightsGLBuffer DEPRECATED_ATTRIBUTE;

/** *@deprecated Renamed to updateVertexBoneIndicesGLBuffer. */
-(void) updateVertexMatrixIndicesGLBuffer DEPRECATED_ATTRIBUTE;

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


