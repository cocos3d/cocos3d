/*
 * CC3Texture.h
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3Identifiable.h"
#import "CC3NodeVisitor.h"
#import "CC3TextureUnit.h"
#import "CCTexture2D.h"

/** 
 * Default texture parameters assigned to the textureParameters property
 * of each instance during instance initialization.
 */
static const ccTexParams kCC3DefaultTextureParameters = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT };


#pragma mark -
#pragma mark CC3Texture

/** 
 * Each instance of CC3Texture wraps a cocos2d CCTexture2D instance, and manages
 * applying that texture to the GL engine.
 *
 * In most cases, a material will hold a single instance of CC3Texture in the texture
 * property to provide a simple single-texture surface. This is the most common application
 * of textures to a material.
 *
 * For more sophisticated surfaces, materials also support multi-texturing, where more than
 * one instance of CC3Texture is added to the material. With multi-texturing, several textures
 * can be combined in flexible, customized fashion, permitting sophisticated surface effects.
 *
 * With OpenGL, multi-texturing is processed by a chain of texture units. The material's
 * first texture is processed by the first texture unit (texture unit zero), and subsequent
 * textures held in the material are processed by subsequent texture units, in the order in
 * which the textures were added to the material.
 * 
 * Each texture unit combines its texture with the output of the previous texture unit
 * in the chain. Combining textures is quite flexible under OpenGL, and there are many
 * ways that each texture can be combined with the output of the previous texture unit.
 * The way that a particular texture combines with the previous textures is defined by
 * an instance of CC3TextureUnit, held in the textureUnit property of each texture that
 * was added to the material.
 *
 * For example, to configure a material for bump-mapping, add a texture that contains a
 * normal vector at each pixel instead of a color, and set the textureUnit property of
 * the texture to a CC3BumpMapTextureUnit. Then add another texture, containing the image
 * that will be visible, to the material. The material will combine these two textures,
 * as specified by the CC3TextureUnit held by the second texture.
 */
@interface CC3Texture : CC3Identifiable {
	CCTexture2D* texture;
	CC3TextureUnit* textureUnit;
	ccTexParams textureParameters;
}

/** The 2D texture being managed by this instance. */
@property(nonatomic, retain) CCTexture2D* texture;

/**
 * The texture environment settings that are applied to the texture unit that draws this texture.
 *
 * The texture unit is optional, and this propety may be left as nil to provide standard single
 * texture rendering. The default value of this property is nil.
 * 
 * The texture unit can be used to configure how the texture will be combined with other
 * textures when using multi-texturing. When the material supports multiple textures, each
 * texture should contain a texture unit that describes how the GL engine should combine
 * that texture with the textures that have already been applied.
 *
 * Different subclasses of CC3TextureUnit provide different customizations for combining
 * textures. The CC3BumpMapTextureUnit provides easy settings for DOT3 bump-mapping, and
 * CC3ConfigurableTextureUnit provides complete flexibility in setting texture environment
 * settings.
 */
@property(nonatomic, retain) CC3TextureUnit* textureUnit;

/**
 * A set of texture parameters used to optimize the display of the contained texture
 * in the GL engine. These setting are passed to the underlying CCTexture2D instance.
 *
 * The initial value of these parameters are:
 *   - Minifying function: GL_LINEAR
 *   - Magnifying function: GL_LINEAR
 *   - Texture wrap S: GL_REPEAT
 *   - Texture wrap T: GL_REPEAT
 */
@property(nonatomic, assign) ccTexParams textureParameters;

/**
 * Returns the proportional size of the usable image in the contained CCTexture2D,
 * relative to its physical size.
 *
 * The physical size of most textures is some power-of-two (POT), whereas the usable image
 * size is the actual portion of it that contains the image. The value returned by this
 * method contains two fractional floats (u & v), each between zero and one, representing
 * the proportional size of the usable image
 *
 * As an example, an image whose dimensions are actually 320 x 480 pixels will result in
 * a texture that is 512 x 512 pixels, and the mapSize returned by this method will be
 * {0.625, 0.9375}, calculated from {320/512, 480/512}.
 */
@property(nonatomic, readonly) ccTex2F mapSize;

/**
 * Indicates whether the RGB components of each pixel of the encapsulated texture
 * have had the corresponding alpha component applied already.
 *
 * Returns YES if this instance contains a CCTexture2D instance, and that texture
 * instance indicates that it contains pre-mulitiplied alpha.
 */
@property(nonatomic,readonly) BOOL hasPremultipliedAlpha;

/**
 * The direction, in local tangent coordinates, of the light source that is to
 * interact with this texture if the texture unit has been configured as a bump-map.
 *
 * Bump-maps are textures that store a normal vector (XYZ coordinates) in
 * the RGB components of each texture pixel, instead of color information.
 * These per-pixel normals interact with the value of this lightDirection
 * property (through a dot-product), to determine the luminance of the pixel.
 *
 * Setting this property sets the equivalent property in the texture unit.
 *
 * Reading this value returns the value of the equivalent property in the
 * texture unit, or returns kCC3VectorZero if this texture has no textureUnit.
 *
 * The value of this property must be in the tangent-space coordinates associated
 * with the texture UV space, in practice, this property is typically not set
 * directly. Instead, you can use the globalLightLocation property of the mesh
 * node that is making use of this texture.
 */
@property(nonatomic, assign) CC3Vector lightDirection;

/**
 * Returns whether this texture contains a texture unit that is configured as a bump-map.
 *
 * Returns YES only if the textureUnit property is not nil, and the same property on that
 * texture unit is set to YES. Otherwise, this property returns NO.
 */
@property(nonatomic, readonly) BOOL isBumpMap;


#pragma mark Allocation and Initialization

/**
 * Initializes this unnamed instance with an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initFromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureFromFile: (NSString*) aFileName;

/**
 * Initializes this unnamed instance with the specified tag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an unnamed autoreleased instance with the specified tag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFileName;

/**
 * Initializes this instance with the specified name and an automatically generated unique
 * tag value. The tag value will be generated automatically via the method nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Initializes this instance with the specified tag and name.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an autoreleased instance with the specified tag and name.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Loads the specified texture file into the texture property,
 * and returns whether the loading was successful.
 */
-(BOOL) loadTextureFile: (NSString*) aFileName;


#pragma mark Drawing

/**
 * If the texture property is not nil, draws the texture to the GL engine as follows:
 *   - Binds the texture to the next available GL texture unit in the GL engine.
 *   - Binds the textureUnit to the GL texture unit to configure how the GL texture unit
 *     will combine this texture with the output of any previous texture units when multiple
 *     texures are overlaid on a single material. If the textureUnit property is nil, the
 *     default single-texture configuration is established via the class-side bindDefaultTo:
 *     method of CC3TextureUnit.
 *   - Increments the textureUnit property of the specfied visitor to indicate that this
 *     texture has used one of the GL texture units, and that any further textures for the
 *     same material should use different GL texture units.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Disables the specified texture unit in the GL engine.
 *
 * The texture unit value should be a number between zero and the maximum number of texture
 * units, which can be read from [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 */
+(void) unbind: (GLuint) texUnit;

/**
 * Disables all texture units between the specified texture unit index and the number of
 * texture units that are in use in this application. This method is automatically invoked
 * by the material to disable all texture units that are not used by the texture or textures
 * contained within the material.
 */
+(void) unbindRemainingFrom: (GLuint)textureUnit;

/** Disables all texture units in the GL engine */
+(void) unbind;

@end
