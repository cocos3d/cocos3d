/*
 * CC3Material.h
 *
 * cocos3d 0.5.4
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

#import "CC3Texture.h"
#import "CCProtocols.h"

/** Default material color under ambient lighting. */
static const ccColor4F kCC3DefaultMaterialColorAmbient = { 0.2, 0.2, 0.2, 1.0 };

/** Default material color under diffuse lighting. */
static const ccColor4F kCC3DefaultMaterialColorDiffuse = { 0.8, 0.8, 0.8, 1.0 };

/** Default material color under specular lighting. */
static const ccColor4F kCC3DefaultMaterialColorSpecular = { 0.0, 0.0, 0.0, 1.0 };

/** Default emissive material color. */
static const ccColor4F kCC3DefaultMaterialColorEmission = { 0.0, 0.0, 0.0, 1.0 };

/** Default material shininess. */
static const GLfloat kCC3DefaultMaterialShininess = 0.0;

/** 
 * CC3Material manages information about a material that is used to cover one or more meshes.
 * This includes:
 *   - color
 *   - texture
 *   - interaction with lighting
 *   - opacity, translucency, and blending with background objects
 *
 * CC3Material supports two levels of control for blending and translucency:
 *   - To achieve the highest level of detail, accuracy and realism, you can individually
 *     set the explicit ambientColor, diffuseColor, specularColor, emissiveColor, shininess,
 *     sourceBlend, and destinationBlend properties. This suite of properties gives you the
 *     most complete control over the appearance of the material and its interaction with
 *     lighting conditions and the colors of the objects behind it, allowing you to generate
 *     rich visual effects. In addition, the isOpaque property sets the most commonly used
 *     blending combinations, and can be used to simplify your management of blending opaque
 *     or transparent materials, while still providing fine control of the ambient, diffuse
 *     and specular coloring.
 *   - At a simpler level, CC3Material also supports the cocos2d <CCRGBAProtocol> protocol.
 *     You can use the color and opacity properties of this protocol to set the most commonly
 *     used coloring and blending characteristics simply and easily. Setting the color property
 *     changes both the ambient and diffuse colors of the material in tandem. Setting the
 *     opacity property also automatically sets the source and destination blend functions to
 *     appropriate values for the opacity level. By using the color and opacity properties,
 *     you will not be able to achieve the complexity and realism that you can by using the
 *     more detailed properties, but you can achieve good effect with much less effort.
 *     And by supporting the <CCRGBAProtocol> protocol, the coloring and translucency of nodes
 *     with materials can be changed using standard cocos2d CCTint and CCFade actions, making
 *     it easier for you to add dynamic coloring effects to your nodes.
 * 
 * Each CC3MeshNode instance references an instance of CC3Material. Many CC3MeshNode
 * instances may reference the same instance of CC3Material, allowing many objects to
 * be covered by the same material.
 *
 * When being drawn, the CC3MeshNode invokes the draw method on the CC3Material
 * instance prior to drawing the associated mesh.
 *
 * When drawing the material to the GL engine, this class remembers which material was
 * last drawn, and only binds the material data to the GL engine when a different material
 * is drawn. This allows the application to organize the CC3MeshNodes within the CC3World
 * so that nodes using the same material are drawn together, before moving on to other
 * materials. This strategy can minimize the number of mesh switches in the GL engine,
 * which improves performance. 
 */
@interface CC3Material : CC3Identifiable <CCRGBAProtocol> {
	CC3Texture* texture;
	ccColor4F ambientColor;
	ccColor4F diffuseColor;
	ccColor4F specularColor;
	ccColor4F emissionColor;
	GLfloat shininess;
	GLenum sourceBlend;
	GLenum destinationBlend;
	BOOL isOpaque;
}

/** The texture covering this material. This may be left nil if no texture is needed. */
@property(nonatomic, retain) CC3Texture* texture;

/**
 * The color of this material under ambient lighting.
 * Initially set to kCC3DefaultMaterialColorAmbient.
 *
 * The value of this property is also affected by changes to the color and opacity
 * properties. See the notes for those properties for more information.
 */
@property(nonatomic, assign) ccColor4F ambientColor;

/**
 * The color of this material under ambient lighting.
 * Initially set to kCC3DefaultMaterialColorDiffuse.
 *
 * The value of this property is also affected by changes to the color and opacity
 * properties. See the notes for those properties for more information.
 */
@property(nonatomic, assign) ccColor4F diffuseColor;

/**
 * The color of this material under ambient lighting.
 * Initially set to kCC3DefaultMaterialColorSpecular.
 *
 * The value of this property is also affected by changes to the opacity property.
 * See the notes for the opacity property for more information.
 */
@property(nonatomic, assign) ccColor4F specularColor;

/**
 * The emission color of this material.
 * Initially set to kCC3DefaultMaterialColorEmission.
 *
 * The value of this property is also affected by changes to the opacity property.
 * See the notes for the opacity property for more information.
 */
@property(nonatomic, assign) ccColor4F emissionColor;

/** The shininess of this material. Initially set to kCC3DefaultMaterialShininess. */
@property(nonatomic, assign) GLfloat shininess;

/**
 * The blending function for the source material (this material). This property must
 * be set to one of the valid GL blending functions.
 *
 * The value in this property combines with the value in the destinationBlend property
 * to determine the way that materials are combined when one (the source) is drawn over
 * another (the destination). Features such as transparency can cause the two to blend
 * together in various ways.
 *
 * If you want the source to completely cover the destination, set sourceBlend to GL_ONE.
 *
 * If you want to have the destination show through the source, either by setting
 * the diffuse alpha below one, or by covering this material with a texture that contains
 * an alpha channel set the sourceBlend to GL_ONE_MINUS_SRC_ALPHA.
 *
 * However, watch out for textures with a pre-multiplied alpha channel. If this material
 * has a texture with a pre-multiplied alpha channel AND you are NOT trying to make this
 * material translucent by setting diffuse alpha below one, set sourceBlend to GL_ONE,
 * so that the pre-multiplied alpha of the source will blend with the destination correctly.
 *
 * Opaque materials can be managed slightly more efficiently than translucent materials.
 * If a material really does not allow other materials to be seen behind it, you should
 * ensure that the sourceBlend and destinationBlend properties are set to GL_ONE and
 * GL_ZERO, respectively, to optimize rendering performance. The performance improvement
 * is small, but can add up if a large number of opaque objects are rendered as if they
 * were translucent.
 *
 * The initial value is determined by the value of the class-side property
 * defaultSourceBlend, which can be modified by the setDefaultSourceBlend: method.
 *
 * The value of this property is also affected by changes to the isOpaque and opacity
 * properties. See the notes for those properties for more information.
 */
@property(nonatomic, assign) GLenum sourceBlend;

/**
 * The blending function for the destination material. This property must be set to one
 * of the valid GL blending functions.
 *
 * The value in this property combines with the value in the sourceBlend property
 * to determine the way that materials are combined when one (the source) is drawn over
 * another (the destination). Features such as transparency can cause the two to blend
 * together in various ways.
 *
 * If you want the source to completely cover the destination, set destinationBlend to GL_ZERO.
 *
 * If you want to have the destination show through the source, either by setting the diffuse
 * alpha below one, or by covering this material with a texture that contains an alpha channel
 ( (including pre-multiplied alpha channel), set the destinationBlend to GL_ONE_MINUS_SRC_ALPHA.
 *
 * Opaque materials can be managed slightly more efficiently than translucent materials.
 * If a material really does not allow other materials to be seen behind it, you should
 * ensure that the sourceBlend and destinationBlend properties are set to GL_ONE and
 * GL_ZERO, respectively, to optimize rendering performance. The performance improvement
 * is small, but can add up if a large number of opaque objects are rendered as if they
 * were translucent.
 *
 * The initial value is determined by the value of the class-side property
 * defaultDestinationBlend, which can be modified by the setDefaultDestinationBlend: method.
 *
 * The value of this property is also affected by changes to the isOpaque and opacity
 * properties. See the notes for those properties for more information.
 */
@property(nonatomic, assign) GLenum destinationBlend;

/**
 * Indicates whether this material is opaque.
 *
 * This method returns YES if the values of the sourceBlend and destinationBlend
 * properties are GL_ONE and GL_ZERO, respectively, otherwise this method returns NO.
 *
 * Setting this property to YES sets the value of the sourceBlend property to GL_ONE
 * and the value of the destinationBlend to GL_ZERO. Setting this property to YES is
 * a convenient way to force the source to completely cover the destination, even if
 * the diffuse alpha value is less than one, and even if the texture contains alpha.
 *
 * Setting this property to NO sets the value of the destinationBlend property to
 * GL_ONE_MINUS_SRC_ALPHA, and sets the sourceBlend property to GL_SRC_ALPHA, unless
 * the diffuse alpha value is equal to one AND this material has a texture that
 * contains pre-multiplied alpha, in which case sourceBlend is set to GL_ONE.
 *
 * Setting the value of this property does not change the alpha values of any
 * of the material colors. 
 *
 * The state of this property is also affected by setting the opacity property.
 * As a convenience, changing the opacity property to less than 255 will automatically
 * cause the isOpaque property to be set to NO, which in turn will change the sourceBlend
 * and destinationBlend properties, so that the translucency will be blended correctly.
 *
 * However, changing the opacity property to 255 will NOT automatically cause the
 * isOpaque property to be set to YES, Even if the opacity of the material is full,
 * the texture may contain translucency, which would be ignored if the isOpaque property
 * were to be set to YES.
 *
 * Setting this property should be thought of as a convenient way to switch between
 * the two most common types of blending combinations. For finer control of blending,
 * set the sourceBlend and destinationBlend properties and the alpha values of the
 * individual material colors directly, and avoid making changes to this property.
 *
 * Opaque materials can be managed slightly more efficiently than translucent materials.
 * If a material really does not allow other materials to be seen behind it, you should
 * ensure that this property is set to YES. The performance improvement is small, but
 * can add up if a large number of opaque objects are rendered as if they were translucent.
 */
@property(nonatomic, assign) BOOL isOpaque;


#pragma mark CCRGBAProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Querying this property returns the RGB components of the material's diffuseColor
 * property, converted from the floating point range (0 to 1), to the byte range
 * (0 to 255).
 *
 * When setting this property, the RGB values are each converted to a floating point
 * number between 0 and 1, and are set into both the ambientColor and diffuseColor
 * properties. The alpha of each of those properties remains the same.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Querying this property returns the alpha component of the material's diffuseColor
 * property, converted from the floating point range (0 to 1), to the byte range
 * (0 to 255).
 *
 * When setting this property, the value is converted to a floating point number
 * between 0 and 1, and is set into all of the ambientColor, diffuseColor,
 * specularColor, and emissionColor properties. The RGB components of each of
 * those properties remains unchanged.
 *
 * Changing this property may also affect the isOpaque property. As a convenience,
 * changing the opacity property to less than 255 will automatically cause the
 * isOpaque property to be set to NO, which in turn will change the sourceBlend and
 * destinationBlend properties, so that the translucency will be blended correctly.
 *
 * However, changing the opacity property to 255 will NOT automatically cause the
 * isOpaque property to be set to YES, Even if the opacity of the material is full,
 * the texture may contain translucency, which would be ignored if the isOpaque property
 * were to be set to YES.
 *
 * Setting this property should be thought of as a convenient way to make simple
 * changes to the opacity of a material, using the two most common types of
 * blending combinations. For finer control of blending, set the sourceBlend and
 * destinationBlend properties and the alpha values of the individual material
 * colors directly, and avoid making changes to this property.
 */
@property(nonatomic, assign) GLubyte opacity;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) material;

/** Allocates and initializes an unnamed autoreleased instance with the specified tag. */
+(id) materialWithTag: (GLuint) aTag;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) materialWithName: (NSString*) aName;

/** Allocates and initializes an autoreleased instance with the specified tag and name. */
+(id) materialWithTag: (GLuint) aTag withName: (NSString*) aName;

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 *
 * The returned instance will have a specularColor of { 1.0, 1.0, 1.0, 1.0 } and a
 * shininess of 75.0.
 */
+(id) shiny;

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 *
 * The returned instance will have both diffuseColor and specularColor set to
 * { 1.0, 1.0, 1.0, 1.0 } and a shininess of 75.0.
 */
+(id) shinyWhite;

/**
 * Returns the default GL material source blend used for new instances.
 *
 * The initial value is GL_ONE.
 */
+(GLenum) defaultSourceBlend;

/** Sets the default GL material source blend used for new instances. */
+(void) setDefaultSourceBlend: (GLenum) srcBlend;

/**
 * Returns the default GL material destination blend used for new instances.
 *
 * The initial value is GL_ZERO.
 */
+(GLenum) defaultDestinationBlend;

/** Sets the default GL material destination blend used for new instances. */
+(void) setDefaultDestinationBlend: (GLenum) destBlend;


#pragma mark Drawing

/**
 * If needed, applies this material to the GL engine.
 *
 * This implementation first determine if this material is different than the material that
 * was last bound to the GL engine. If this material is indeed different, this method
 * applies the material to the GL engine, otherwise it does nothing.
 *
 * This method is invoked from the draw method of any CC3Node instance referencing this
 * CC3Material intance. Usually, the application never needs to invoke this method directly.
 */
-(void) draw;

/**
 * Unbinds the GL engine from any materials.
 * 
 * This implementation simply delegates to the unbind class method.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) unbind;

/**
 * Unbinds the GL engine from any materials.
 * 
 * Disables material blending in the GL engine, and invokes the unbind class method
 * of CC3Texture to disable texturing.
 *
 * This method is invoked automatically from the CC3VertexArrayMeshModel instance.
 * Usually, the application never needs to invoke this method directly.
 */
+(void) unbind;


#pragma mark Material context switching

/**
 * Resets the tracking of the material switching functionality.
 *
 * This is invoked automatically by the CC3World at the beginning of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
+(void) resetSwitching;

@end

