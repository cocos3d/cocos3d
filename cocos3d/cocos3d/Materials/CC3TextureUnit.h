/*
 * CC3TextureUnit.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3NodeVisitor.h"
#import "CCProtocols.h"
#import	"CC3CC2Extensions.h"

/**
 * In a bump-map configuration, indicates how the XYZ coordinates of each per-pixel
 * normal are stored in the RGB values of each pixel.
 *
 * The texture has three slots (R, G & B) in which to store three normal coordinate
 * components (X, Y & Z). This can be done in any of six ways, as indicated by the
 * values of the CC3DOT3RGB enumeration.
 */
typedef enum {
	kCC3DOT3RGB_XYZ,		/**< R=X, G=Y, B=Z. */
	kCC3DOT3RGB_XZY,		/**< R=X, G=Z, B=Y. */
	kCC3DOT3RGB_YXZ,		/**< R=Y, G=X, B=Z. */
	kCC3DOT3RGB_YZX,		/**< R=Y, G=Z, B=X. */
	kCC3DOT3RGB_ZXY,		/**< R=Z, G=X, B=Y. */
	kCC3DOT3RGB_ZYX,		/**< R=Z, G=Y, B=X. */
} CC3DOT3RGB;


#pragma mark -
#pragma mark CC3TextureUnit

/** 
 * In fixed rendering pipeline (without shaders), CC3TextureUnit is used by certain classes
 * in the CC3Texture class-cluster to configure the GL texture environment to which the
 * texture is being applied. Notably, the texture unit defines how the texture is to be
 * combined with textures from other texture units in a multi-texture layout.
 *
 * CC3TextureUnit is not typically used in a programmable rendering pipeline containing
 * GLSL shaders. However, for certain techniques, such as object-space bump-mapping, a
 * CC3TextureUnit can be used to carry additional environmental parameters for the shaders.
 *
 * With fixed-pipeline multi-texturing, several textures can be overlaid and combined in
 * interesting ways onto a single material. Each texture is processed by a GL texture unit,
 * and is combined with the textures already processed by other texture units. The source
 * and type of combining operation can be individually configured by subclasses of this class.
 * Support for bump-mapping as one of these combining configurations is explicitly provided
 * by the CC3BumpMapTextureUnit subclass.
 *
 * This base CC3TextureUnit class permits setting a variety of texture environment
 * modes via the textureEnvironmentMode property. For the full range of configuration
 * flexibility, the CC3ConfigurableTextureUnit subclass contains the full range of
 * configuration properties associated with the GL_COMBINE texture environment mode.
 */
@interface CC3TextureUnit : NSObject <NSCopying, CCRGBAProtocol> {
	ccColor4F _constantColor;
	GLenum _textureEnvironmentMode;
	CC3DOT3RGB _rgbNormalMap : 4;
}

/**
 * Defines the texture function to be used when combining this texture unit with
 * the output of the previous texture unit. This can be set to one of several fixed
 * texture functions (GL_ADD, GL_MODULATE, GL_DECAL, GL_BLEND, GL_REPLACE), in which
 * case the remaining configuration properties of this class are ignored. Setting this
 * property to GL_MODULATE replicates the default behaviour of the CC3Texture class.
 *
 * If you want to set this property to GL_COMBINE, to open up significant additional
 * configuration flexibility, use the CC3ConfigurableTextureUnit subclass, which contains
 * the full range of configuration properties associated with the GL_COMBINE functionality.
 *
 * The initial value of this property is GL_MODULATE.
 */
@property(nonatomic, assign) GLenum textureEnvironmentMode;

/**
 * The constant color of the texture unit. This will be used by the combiner
 * when the value of one of the source properties of a subclass is set to
 * GL_CONSTANT. This is often the case for bump-mapping configurations.
 * 
 * Although this property can be set directly, it is rare to do so. Usually, this property
 * is set indirectly via the lightDirection property, which converts the XYZ coordinates of
 * a lighting direction vector into the RGB components of this property.
 *
 * This property is not used by this parent class implementation, but is
 * provided for common access by subclasses.
 *
 * The initial value of this property is kCCC4FBlackTransparent.
 */
@property(nonatomic, assign) ccColor4F constantColor;

/**
 * The direction, in local tangent coordinates, of the light source that is to
 * interact with subclasses that are configured as bump-maps (aka normal maps).
 *
 * Bump-maps are textures that store a normal vector (XYZ coordinates) in
 * the RGB components of each texture pixel, instead of color information.
 * These per-pixel normals interact with the value of this lightDirection
 * property (through a dot-product), to determine the luminance of the pixel.
 *
 * Setting this property changes the value of the constantColor property.
 * The lightDirection vector is normalized and shifted from the range of +/- 1.0
 * to the range 0.0-1.0. Then each XYZ component in the vector is mapped to the
 * RGB components of the constantColor using the rgbNormalMap property.
 *
 * Reading this value reads the value from the constantColor property.
 * The RGB components of the color are mapped to the XYZ components of the
 * direction vector using the rgbNormalMap property, and then shifted from
 * the color component range 0.0-1.0 to the directional vector range +/- 1.0.
 *
 * The value of this property must be in the tangent-space coordinates associated
 * with the texture UV space, in practice, this property is typically not set
 * directly. Instead, you can use the globalLightPosition property of the mesh
 * node that is making use of this texture and texture unit.
 */
@property(nonatomic, assign) CC3Vector lightDirection;

/**
 * When a subclass is configured as a bump-map, this property indicates how the
 * XYZ coordinates of each per-pixel normal are stored in the RGB values of each
 * pixel.
 *
 * The texture has three slots (R, G & B) in which to store three normal coordinate
 * components (X, Y & Z). This can be done in any of six ways, as indicated by the
 * values of the CC3DOT3RGB enumeration.
 *
 * The initial value of this property is kCC3DOT3RGB_XYZ, indicating that the
 * X, Y & Z components of the bump-map normals will be stored in the R, G & B
 * coordinates of the texture pixels, respectively.
 */
@property(nonatomic, assign) CC3DOT3RGB rgbNormalMap;

/**
 * Returns whether this texture unit is configured as a bump-map.
 *
 * This implementation always returns NO. Subclasses that support bump-mapping will
 * override this default implementation.
 */
@property(nonatomic, readonly) BOOL isBumpMap;


#pragma mark CCRGBAProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Querying this property returns the RGB components of the constantColor property,
 * converted from the floating point range (0 to 1), to the byte range (0 to 255).
 *
 * When setting this property, the RGB values are each converted to a floating point
 * number between 0 and 1, and are set into the constantColor property.
 * The alpha component of constantColor remains unchanged.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Querying this property returns the alpha component of the constantColor property,
 * converted from the floating point range (0 to 1), to the byte range (0 to 255).
 *
 * When setting this property, the value is converted to a floating point number
 * between 0 and 1, and is set into the constantColor property.
 * The RGB components of constantColor remain unchanged.
 */
@property(nonatomic, assign) GLubyte opacity;


#pragma mark Allocation and Initialization

/** Allocates and initializes an autoreleased instance. */
+(id) textureUnit;


#pragma mark Drawing

/**
 * Template method that binds the configuration of this texture unit to the GL engine.
 *
 * The visitor provides additional configuration information that can be
 * used by subclass overrides of this method.
 */
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Automatically invoked from CC3Texture when no texture unit configuration is
 * provided in that texture.
 *
 * In the GL engine, sets the combining function to the default value of GL_MODULATE,
 * and the texture constant color to the default value of kCCC4FBlackTransparent.
 */
+(void) bindDefaultWithVisitor: (CC3NodeDrawingVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3ConfigurableTextureUnit

/**
 * A texture unit that provides complete flexibility in defining the way
 * the texture will be combined with the output of previous texture units.
 */
@interface CC3ConfigurableTextureUnit : CC3TextureUnit {
	GLenum _combineRGBFunction;
	GLenum _rgbSource0;
	GLenum _rgbSource1;
	GLenum _rgbSource2;
	GLenum _rgbOperand0;
	GLenum _rgbOperand1;
	GLenum _rgbOperand2;
	GLenum _combineAlphaFunction;
	GLenum _alphaSource0;
	GLenum _alphaSource1;
	GLenum _alphaSource2;
	GLenum _alphaOperand0;
	GLenum _alphaOperand1;
	GLenum _alphaOperand2;
}

/**
 * Defines the texture function to be used when combining this texture unit with
 * the output of the previous texture unit. This can be set to one of several fixed
 * texture functions (GL_ADD, GL_MODULATE, GL_DECAL, GL_BLEND, GL_REPLACE), in which
 * case the remaining configuration properties of this class are ignored. Setting this
 * property to GL_MODULATE replicates the default behaviour of the CC3Texture class.
 *
 * Setting this property to GL_COMBINE activates the other configuration properties
 * of this class, opening up significant additional configuration flexibility.
 *
 * The initial value of this property is GL_COMBINE, indicating that all configuration
 * properties are active.
 */
@property(nonatomic, assign) GLenum textureEnvironmentMode;

/**
 * If the textureEnvironmentMode property is set to GL_COMBINE, this property defines
 * the form of combining function used to combine the RGB components of the texture
 * associated with this texture unit with the output of the previous texture unit.
 *
 * This property may be set to any of the following values:
 *  - GL_REPLACE - simply use the texture identified by the rgbSource0 property.
 *  - GL_MODULATE - multiply together the RGB components of the textures identified
 *    by the rgbSource0 and rgbSource1 properties.
 *  - GL_ADD - add together the RGB components of the textures identified by the
 *    rgbSource0 and rgbSource1 properties.
 *  - GL_ADD_SIGNED - add together the RGB components of the textures identified by
 *    the rgbSource0 and rgbSource1 properties and then subtract 0.5.
 *  - GL_SUBTRACT - subtract the RGB components of the texture identified by rgbSource1
 *    from those of the texture identified by rgbSource0.
 *  - GL_INTERPOLATE - interpolate the RGB components between the textures identified
 *    by the rgbSource0, rgbSource1 and rgbSource1 properties
 *  - GL_DOT3_RGB or GL_DOT3_RGBA - treat the RGB components of the textures identified
 *    by the rgbSource0 and rgbSource1 properties as the three coordinates of a normal
 *    vector, take the dot product of the two vectors, and put the resulting scalar
 *    value into each of the 3 (RGB) or 4 (RGBA) components on output. This has the
 *    effect of modulating the underlying light colors in such a way that the surface
 *    appears to be three-dimensional.
 *
 * The initial value of this property is set to GL_MODULATE, which replicates the
 * behaviour of the CC3Texture class
 */
@property(nonatomic, assign) GLenum combineRGBFunction;

/**
 * Identifies the source texture for the RGB components used as argument
 * zero in the texture function defined by the combineRGBFunction property.
 *
 * This property may be set to any of the following values:
 *  - GL_TEXTURE - use this texture
 *  - GL_CONSTANT - use the color in the constantColor property of this texture unit.
 *  - GL_PRIMARY_COLOR - use the color of the material.
 *  - GL_PREVIOUS - use the output of the previous texture unit in the chain,
 *    or the color of the material when processing texture unit zero.
 *
 * The intial value of this property is GL_TEXTURE, indicating that the texture
 * combiner will use this texture as argument zero in the texture combiner function.
 */
@property(nonatomic, assign) GLenum rgbSource0;

/**
 * Identifies the source texture for the RGB components used as argument
 * one in the texture function defined by the combineRGBFunction property.
 *
 * See the notes for the rgbSource0 property for the list of permitted values.
 *
 * The intial value of this property is GL_PREVIOUS, indicating that the texture combiner
 * will use the output of the previous texture unit in the chain, or the color of the
 * material if processing texture unit zero.
 */
@property(nonatomic, assign) GLenum rgbSource1;

/**
 * Identifies the source texture for the RGB components used as argument
 * two in the texture function defined by the combineRGBFunction property.
 *
 * See the notes for the rgbSource0 property for the list of permitted values.
 *
 * The intial value of this property is GL_CONSTANT, indicating that the texture
 * combiner will use the value in the constantColor property of this texture unit.
 */
@property(nonatomic, assign) GLenum rgbSource2;

/**
 * Defines the operand to be applied to the RGB components of rgbSource0
 * prior to them being used by the combiner.
 *
 * This property may be set to any of the following values:
 *  - GL_SRC_COLOR - the source color.
 *  - GL_ONE_MINUS_SRC_COLOR - the inverse of the source color.
 *  - GL_SRC_ALPHA - the source alpha.
 *  - GL_ONE_MINUS_SRC_ALPHA - the inverse of the source alpha.
 *
 * The initial value of this property is GL_SRC_COLOR, indicating that the
 * RGB color of rgbSource0 will be used as-is by the combiner.
 */
@property(nonatomic, assign) GLenum rgbOperand0;

/**
 * Defines the operand to be applied to the RGB components of rgbSource1
 * prior to them being used by the combiner.
 *
 * See the notes for the rgbOperand0 property for the list of permitted values.
 *
 * The initial value of this property is GL_SRC_COLOR, indicating that the
 * RGB color of rgbSource1 will be used as-is by the combiner.
 */
@property(nonatomic, assign) GLenum rgbOperand1;

/**
 * Defines the operand to be applied to the RGB components of rgbSource2
 * prior to them being used by the combiner.
 *
 * See the notes for the rgbOperand2 property for the list of permitted values.
 *
 * The initial value of this property is GL_SRC_ALPHA, indicating that the
 * alpha component of rgbSource2 will be used by the combiner.
 */
@property(nonatomic, assign) GLenum rgbOperand2;

/**
 * If the textureEnvironmentMode property is set to GL_COMBINE, this property defines
 * the form of combining function used to combine the alpha component of the texture
 * associated with this texture unit with the output of the previous texture unit.
 *
 * This property may be set to any of the following values:
 *  - GL_REPLACE - simply use the texture identified by the rgbSource0 property.
 *  - GL_MODULATE - multiply together the alpha components of the textures identified
 *    by the rgbSource0 and rgbSource1 properties.
 *  - GL_ADD - add together the alpha components of the textures identified by the
 *    rgbSource0 and rgbSource1 properties.
 *  - GL_ADD_SIGNED - add together the alpha components of the textures identified by
 *    the rgbSource0 and rgbSource1 properties and then subtract 0.5.
 *  - GL_SUBTRACT - subtract the alpha component of the texture identified by rgbSource1
 *    from that of the texture identified by rgbSource0.
 *  - GL_INTERPOLATE - interpolate the alpha components between the textures identified
 *    by the rgbSource0, rgbSource1 and rgbSource1 properties
 *
 * The initial value of this property is set to GL_MODULATE, which replicates the
 * behaviour of the CC3Texture class
 */
@property(nonatomic, assign) GLenum combineAlphaFunction;

/**
 * Identifies the source texture for the alpha component used as argument
 * zero in the texture function defined by the combineAlphaFunction property.
 *
 * This property may be set to any of the following values:
 *  - GL_TEXTURE - use this texture
 *  - GL_CONSTANT - use the alpha component in the constantColor property of this texture unit.
 *  - GL_PRIMARY_COLOR - use the color of the material.
 *  - GL_PREVIOUS - use the output of the previous texture unit in the chain,
 *    or the color of the material when processing texture unit zero.
 *
 * The intial value of this property is GL_TEXTURE, indicating that the texture
 * combiner will use this texture as argument zero in the texture combiner function.
 */
@property(nonatomic, assign) GLenum alphaSource0;

/**
 * Identifies the source texture for the alpha components used as argument
 * one in the texture function defined by the combineAlphaFunction property.
 *
 * See the notes for the alphaSource0 property for the list of permitted values.
 *
 * The intial value of this property is GL_PREVIOUS, indicating that the texture combiner
 * will use the output of the previous texture unit in the chain, or the color of the
 * material if processing texture unit zero.
 */
@property(nonatomic, assign) GLenum alphaSource1;

/**
 * Identifies the source texture for the alpha components used as argument
 * two in the texture function defined by the combineAlphaFunction property.
 *
 * See the notes for the alphaSource0 property for the list of permitted values.
 *
 * The intial value of this property is GL_CONSTANT, indicating that the texture
 * combiner will use the alpha value in the constantColor property of this texture unit.
 */
@property(nonatomic, assign) GLenum alphaSource2;

/**
 * Defines the operand to be applied to the alpha component of alphaSource0
 * prior to it being used by the combiner.
 *
 * This property may be set to any of the following values:
 *  - GL_SRC_ALPHA - the source alpha.
 *  - GL_ONE_MINUS_SRC_ALPHA - the inverse of the source alpha.
 *
 * The initial value of this property is GL_SRC_ALPHA, indicating that the
 * alpha component of alphaSource0 will be used as-is by the combiner.
 */
@property(nonatomic, assign) GLenum alphaOperand0;

/**
 * Defines the operand to be applied to the alpha component of alphaSource1
 * prior to it being used by the combiner.
 *
 * See the notes for the alphaOperand0 property for the list of permitted values.
 *
 * The initial value of this property is GL_SRC_ALPHA, indicating that the
 * alpha component of alphaSource1 will be used as-is by the combiner.
 */
@property(nonatomic, assign) GLenum alphaOperand1;

/**
 * Defines the operand to be applied to the alpha component of alphaSource2
 * prior to it being used by the combiner.
 *
 * See the notes for the alphaOperand0 property for the list of permitted values.
 *
 * The initial value of this property is GL_SRC_ALPHA, indicating that the
 * alpha component of alphaSource2 will be used as-is by the combiner.
 */
@property(nonatomic, assign) GLenum alphaOperand2;

/**
 * Returns whether this texture unit is configured as a bump-map.
 *
 * This implementation always returns YES if the textureEnvironmentMode property is set to
 * GL_COMBINE and the combineRGBFunction property is set to either GL_DOT3_RGB or GL_DOT3_RGBA.
 */
@property(nonatomic, readonly) BOOL isBumpMap;

@end


#pragma mark -
#pragma mark CC3BumpMapTextureUnit

/**
 * A texture unit configured for DOT3 bump-mapping. It will combine the per-pixel normal
 * vectors found in the texture with the constantColor property to derive per-pixel luminosity.
 *
 * Typically, the value of the constantColor property is not set directly, but is established
 * automatically by setting the lightDirection property to indicate the direction of the light
 * source, in tanget-space coordinates. See the notes of the lightDirection property for more
 * information about establishing the direction of the light source.
 * 
 * This implementation combines the texture RGB components (rdbSource0) with the value of
 * constantColor (as rgbSource1), using a DOT3 combining function. If you need more flexibility
 * in configuing the bump-mapping, consider using an instance of CC3ConfigurableTextureUnit.
 *
 * When using bump-mapping, you should associate this texture unit with the first texture of
 * a material to establish per-pixel luminosity, and then add any additional textures (ie- the
 * visible texture) on the material so they will be combined with the luminosity output.
 */
@interface CC3BumpMapTextureUnit : CC3TextureUnit

/**
 * Returns whether this texture unit is configured as a bump-map.
 *
 * This implementation always returns YES.
 */
@property(nonatomic, readonly) BOOL isBumpMap;

@end
