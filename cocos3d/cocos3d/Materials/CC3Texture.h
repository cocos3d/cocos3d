/*
 * CC3Texture.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CCTextureCache.h"


#pragma mark -
#pragma mark CC3Texture

/** 
 * Each instance of CC3Texture wraps a cocos2d CCTexture2D instance, and manages
 * various texture settings, and applying that texture to the GL engine.
 *
 * To improve both performance and texture quality, by default, instances generate
 * a mipmap of the underlying CCTexture2D when a texture is loaded through this
 * instance. If you do not want mipmaps to be automatically generated, set the
 * class-side shouldGenerateMipmaps property to NO. With automatic mipmap generation
 * turned off, you can selectively generate a mipmap by using the generateMipmap
 * method on any single CC3Texture instance. In addition, textures that contain
 * mipmaps within the file content (PVR files may contain mipmaps) will retain and
 * use this mipmap. See the shouldGenerateMipmaps and hasMipmap properties, and the
 * generateMipmap method for more information.
 *
 * Under iOS, most texture formats are loaded updside-down. This is because the vertical
 * axis of the coordinate system of OpenGL is inverted relative to the iOS view coordinate 
 * system. The isFlippedVerically property can be used to ensure that textures are
 * displayed with the correct orientation. When a CC3Texture is applied to a mesh,
 * the mesh will be adjusted automatically if the texture is vertically flipped.
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
	CCTexture2D* _texture;
	CC3TextureUnit* _textureUnit;
	GLenum _minifyingFunction;
	GLenum _magnifyingFunction;
	GLenum _horizontalWrappingFunction;
	GLenum _verticalWrappingFunction;
	BOOL _texParametersAreDirty : 1;
}

/**
 * The CCTexture2D texture being managed by this instance.
 *
 * This property is populated automatically by the loadTextureFile: method, or one
 * of the file-loading initialization methods, but it can also be set directly to
 * a CCTexture2D that has already been loaded.
 * 
 * When setting this property directly, be aware that doing so does not automatically
 * generate a mipmap for the texture, even if the class-side property shouldGenerateMipmaps
 * is set to YES. You can use the generateMipmap method of this instance to do so once
 * this property is set.
 *
 * If this property is set to an instance of CC3Texture2D, the hasMipmap and
 * isFlippedVertically of that instance will be set correctly. However, if this
 * property is set to an instance of CCTexture2D, you should ensure that the
 * hasMipmap and isFlippedVertically properties of that instance are set correctly.
 */
@property(nonatomic, retain) CCTexture2D* texture;

/**
 * The texture environment settings that are applied to the texture unit that draws this
 * texture, when this texture participates in multi-texturing.
 *
 * The texture unit is optional, and this propety may be left as nil to provide standard
 * single texture rendering. The default value of this property is nil.
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
@property(nonatomic, readonly) CGSize mapSize;

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

/**
 * Returns whether this texture is flipped vertically.
 *
 * Under iOS, most texture formats are loaded updside-down. This is because the vertical
 * axis of the coordinate system of OpenGL is inverted relative to the iOS view coordinate 
 * system. This results in textures being displayed upside-down, relative to the OpenGL
 * coordinate system.
 *
 * This property simply returns the value of the same property on the contained CCTexture2D.
 *
 * This property will return NO if this texture was loaded from a PVR texture file,
 * and will return YES if loaded from any other texture file type.
 */
@property(nonatomic, readonly) BOOL isFlippedVertically;


#pragma mark Mipmaps

/**
 * Returns whether a mipmap has been generated for the underlying CCTexture2D instance.
 *
 * This property simply returns the value of the same property on the contained CCTexture2D.
 *
 * If the class-side shouldGenerateMipmaps property is YES, mipmaps are generated
 * automatically whenever a CC3Texture2D is loaded via the loadTextureFile: method
 * of this instance, or through one of the instance initialization methods that
 * load a texture.
 *
 * Mipmaps can also be generated by invoking the generateMipmap method, which
 * delegates to the generateMipmapIfNeeded method of the underlying CCTexture2D.
 *
 * Once a mipmap is generated for a particular underlying CCTexture2D, all instances
 * of CC3Texture that share that CCTexture2D will return YES from this property.
 *
 * If the underlying CCTexture2D was assigned via the texture property, and if a
 * mipmap has been generated for a CCTexture2D before it was assigned to any
 * CC3Texture instance, or you know that the CCTexture2D was loaded with a mipmap,
 * you should mark it as such by setting its hasMipmap property to YES. This is
 * not required if the texture is a CC3Texture2D, since it already tracks whether
 * the mimmap was loaded or generated.
 */
@property(nonatomic, readonly) BOOL hasMipmap;

/**
 * Generates a mipmap for the contained CCTexture2D, if needed, by invoking the
 * generateMipmapIfNeeded method on the contained CCTexture2D.
 *
 * It is safe to invoke this method more than once, because it will only generate
 * a mipmap if a mipmap has not yet been generated.
 *
 * If the contained texture is an instance of CCTexture2D that was assigned to
 * this instance via the texture property, be aware that some formats (notably
 * PVR) may already contain mipmaps in the content loaded from file. In this case,
 * it is up to the application to set the hasMipmap property of the CCTexture2D
 * to YES before invoking this method.
 *
 * If the contained texture is an instance of the CC3Texture2D subclass, its
 * hasMipmap property will have been accurately set during loading, and there
 * is no need for the application to set it prior to invoking this method.
 */
-(void) generateMipmap;

/**
 * Returns whether a mipmap should be generated for any textures that are loaded
 * via the loadTextureFile: method of this instance, or through one of the instance
 * initialization methods that load a texture.
 *
 * If this property is set to YES, mipmap will only be generated if the texture
 * file does not already contain a mipmap.
 *
 * This property affects all textures loaded through CC3Texture. You can set this
 * property to the desired value prior to loading one or more textures.
 *
 * The default value of this class-side property is YES, indicating that mipmaps
 * will be generated for any textures loaded through CC3Texture.
 */
+(BOOL) shouldGenerateMipmaps;

/**
 * Sets whether a mipmap should be generated for any textures that are loaded
 * via the loadTextureFile: method of this instance, or through one of the instance
 * initialization methods that load a texture.
 *
 * If this property is set to YES, mipmap will only be generated if the texture
 * file does not already contain a mipmap.
 *
 * This property affects all textures loaded through CC3Texture. You can set this
 * property to the desired value prior to loading one or more textures.
 *
 * The default value of this class-side property is YES, indicating that mipmaps
 * will be generated for any textures loaded through CC3Texture.
 */
+(void) setShouldGenerateMipmaps: (BOOL) shouldMipmap;


#pragma mark Texture parameters

/**
 * The minifying function to be used whenever a pixel being textured maps
 * to an area greater than one texel.
 *
 * This property must be one of the following values:
 *   - GL_NEAREST:                Uses the texel nearest to the center of the pixel.
 *   - GL_LINEAR:                 Uses a weighted average of the four closest texels.
 *   - GL_NEAREST_MIPMAP_NEAREST: Uses GL_NEAREST on the mipmap that is closest in size.
 *   - GL_LINEAR_MIPMAP_NEAREST:  Uses GL_LINEAR on the mipmap that is closest in size.
 *   - GL_NEAREST_MIPMAP_LINEAR:  Uses GL_NEAREST on the two mipmaps that are closest in size,
 *                                then uses the weighted average of the two results.
 *   - GL_LINEAR_MIPMAP_LINEAR:   Uses GL_LINEAR on the two mipmaps that are closest in size,
 *                                then uses the weighted average of the two results.
 *
 * The last four values above require that a mipmap be available, as indicated
 * by the hasMipmap property. If one of those value is set in this property,
 * this property will only return either GL_NEAREST (for all GL_NEAREST... values)
 * or GL_LINEAR (for all GL_LINEAR... values) until a mipmap has been created for
 * the underlying CCTexture2D instance, and has been marked as such for this class.
 * See the hasMipmap property for more information about how that property is updated.
 *
 * The initial value of this property is set by the defaultTextureParameters
 * class-side property, and defaults to GL_LINEAR_MIPMAP_NEAREST, or GL_LINEAR
 * if the underlying CCTexture2D does not have a generated mipmap.
 */
@property(nonatomic, assign) GLenum minifyingFunction;

/**
 * The magnifying function to be used whenever a pixel being textured maps
 * to an area less than or equal to one texel.
 *
 * This property must be one of the following values:
 *   - GL_NEAREST: Uses the texel nearest to the center of the pixel.
 *   - GL_LINEAR:  Uses a weighted average of the four closest texels.
 *
 * The initial value of this property is set by the defaultTextureParameters
 * class-side property, and defaults to GL_LINEAR.
 */
@property(nonatomic, assign) GLenum magnifyingFunction;

/**
 * The method used to detemine the texel to use when a texture coordinate has
 * a value less than zero or greater than one in the horizontal (S) direction.
 *
 * This property must be one of the following values:
 *   - GL_CLAMP_TO_EDGE:   Uses the nearest texel from the nearest edge, effectively
 *                         extending this texel across the mesh.
 *   - GL_REPEAT:          Repeats the texture across the mesh.
 *   - GL_MIRRORED_REPEAT: Repeats the texture across the mesh, altering between
 *                         the texture and a mirror-image of the texture.
 *
 * The initial value of this property is set by the defaultTextureParameters
 * class-side property, and defaults to GL_REPEAT.
 */
@property(nonatomic, assign) GLenum horizontalWrappingFunction;

/**
 * The method used to detemine the texel to use when a texture coordinate has
 * a value less than zero or greater than one in the vertical (T) direction.
 *
 * This property must be one of the following values:
 *   - GL_CLAMP_TO_EDGE:   Uses the nearest texel from the nearest edge, effectively
 *                         extending this texel across the mesh.
 *   - GL_REPEAT:          Repeats the texture across the mesh.
 *   - GL_MIRRORED_REPEAT: Repeats the texture across the mesh, altering between
 *                         the texture and a mirror-image of the texture.
 *
 * The initial value of this property is set by the defaultTextureParameters
 * class-side property, and defaults to GL_REPEAT.
 */
@property(nonatomic, assign) GLenum verticalWrappingFunction;

/**
 * A convenience method to accessing the following four texture parameters
 * using a cocos2d ccTexParams structure:
 *   - minifyingFunction
 *   - magnifyingFunction
 *   - horizontalWrappingFunction
 *   - shouldRepeatVertically
 *
 * The initial value of this property is set by the defaultTextureParameters
 * class-side property.
 */
@property(nonatomic, assign) ccTexParams textureParameters;

/**
 * The default values for the textureParameters property
 * (with the initial values of this class-side property):
 *   - minifyingFunction (GL_LINEAR_MIPMAP_NEAREST)
 *   - magnifyingFunction (GL_LINEAR)
 *   - horizontalWrappingFunction (GL_REPEAT)
 *   - shouldRepeatVertically (GL_REPEAT)
 */
+(ccTexParams) defaultTextureParameters;

/**
 * The default values for the textureParameters property
 * (with the initial values of this class-side property):
 *   - minifyingFunction (GL_LINEAR_MIPMAP_NEAREST)
 *   - magnifyingFunction (GL_LINEAR)
 *   - horizontalWrappingFunction (GL_REPEAT)
 *   - shouldRepeatVertically (GL_REPEAT)
 *
 * You can change the value of this class-side property to affect
 * any textures subsequently created or loaded from a file.
 */
+(void) setDefaultTextureParameters: (ccTexParams) texParams;


#pragma mark Allocation and Initialization

/**
 * Initializes this instance by loading the texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
-(id) initFromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance instance by loading the
 * texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
+(id) textureFromFile: (NSString*) aFilePath;

/**
 * Initializes this instance by loading the texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to the specified value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance instance by loading the
 * texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to the specified value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath;

/**
 * Initializes this instance by loading the texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the specified name and the tag is set to
 * an automatically generated unique tag value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance instance by loading the
 * texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the specified name and the tag is set to
 * an automatically generated unique tag value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFilePath;

/**
 * Initializes this instance by loading the texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the specified name and the tag is set
 * to the specified value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance instance by loading the
 * texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the specified name and the tag is set
 * to the specified value.
 *
 * Returns nil if the file could not be loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
+(id) textureWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFilePath;

/**
 * Loads the texture file at the specified file path into the texture property,
 * and returns whether the loading was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * If the instance is instantiated with one of the file-loading initialization method,
 * this method will be invoked automatically during instance initialization. If the
 * instance is instantiated without using one of the file-loading methods, this method
 * can be invoked directly to load the file.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the
 * texture file does not already contain a mipmap, a mipmap will be generated
 * for the texture automatically.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CCTexture2D held in the texture property.
 */
-(BOOL) loadTextureFile: (NSString*) aFilePath;


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


#pragma mark -
#pragma mark CCTexture2D extension category

/**
 * This extension adds behaviour to support the use of a CCTexture2D
 * instance as a component of a CC3Texture.
 *
 * Adds the capability to track whether the texture contains a mipmap.
 *
 * Adds the capability to track whether the texture was flipped vertically
 * by the iOS during loading.
 *
 * Adds the ability to use CCTexture2D as the top of a class cluster, and in
 * particular, to force a particular subclass of CCTexture2D to be instantiated
 * and returned when the CCTexture2D alloc method is invoked.
 */
@interface CCTexture2D (CC3Texture)

#pragma mark Allocation and initialization

/**
 * Returns the cluster class that will be instantiated and returned when the alloc
 * method is invoked. The returned class will be a subclass of CCTexture2D, or nil.
 *
 * If this property is not nil, subsequent invocations of the CCTexture2D
 * alloc method will instantiate and return an instance of that class.
 *
 * If this property is nil, subsequent invocations of the CCTexture2D
 * alloc method will instantiate and return an instance of CCTexture2D.
 * 
 * This property will temporarily be set to CC3Texture2D by CC3Texture when
 * loading the underlying CCTexture2D instance.
 */
+(Class) instantiationClass;

/**
 * Sets the cluster class that will be instantiated and returned when the alloc
 * method is invoked. The specified class must be a subclass of CCTexture2D, or nil.
 *
 * If the specified class is not nil, subsequent invocations of the CCTexture2D
 * alloc method will instantiate and return an instance of that class.
 *
 * If the specified class is nil, subsequent invocations of the CCTexture2D
 * alloc method will instantiate and return an instance of CCTexture2D.
 * 
 * This property will temporarily be set to CC3Texture2D by CC3Texture when
 * loading the underlying CCTexture2D instance.
 */
+(void) setInstantiationClass: (Class) aClass;


#pragma mark Tracking vertical orientation

/**
 * Returns whether this texture is flipped vertically.
 *
 * Under iOS, most texture formats are loaded updside-down. This is because the vertical
 * axis of the coordinate system of OpenGL is inverted relative to the iOS view coordinate 
 * system. This results in textures being displayed upside-down, relative to the OpenGL
 * coordinate system.
 *
 * This property will return NO if this texture was loaded from a PVR texture file,
 * and will return YES if loaded from any other texture file type.
 *
 * For instances of the cluster subclass CC3Texture2D, the value of this property
 * is set to the correct value automatically when the texture file is loaded.
 *
 * For instances of the base cluster parent CCTexture2D, you should set this
 * property to the correct value after loading.
 *
 * If you manually set this property to NO for a CCTexture2D, you should set this
 * property back to YES before clearing this texture from the CCTextureCache, in
 * case the GL engine reuses the texture name again.
 */
@property(nonatomic, assign) BOOL isFlippedVertically;


#pragma mark Tracking mipmap generation

/**
 * Indicates whether this texture contains a mipmap.
 *
 * For instances of the cluster subclass CC3Texture2D, the value of this property
 * is set to the correct value automatically when the texture file is loaded.
 *
 * For instances of the base cluster parent CCTexture2D, you should set this property
 * to the correct value after loading, and before the generateMipmapIfNeeded method
 * is invoked.
 *
 * This property will also be set to YES when the generateMipmapIfNeeded is invoked.
 *
 * If you manually set this property to YES for a CCTexture2D, you should set this
 * property back to NO before clearing this texture from the CCTextureCache, in
 * case the GL engine reuses the texture name again.
 */
@property(nonatomic, assign) BOOL hasMipmap;

/**
 * If this texture does not have a mipmap yet, as indicated by the value of the
 * hasMipmap property, this method generates a GL mipmap for this texture, and
 * sets the value of the hasMipmap property to YES.
 *
 * It is safe to invoke this method more than once, or on a texture that was
 * loaded from a file that already contains a mipmap, because it will only
 * generate a mipmap if the texture file does not already contain a mipmap
 * and a mipmap has not yet been generated.
 *
 * Be aware that some formats (notably PVR) may already contain mipmaps in the
 * content loaded from file. For instances of the cluster subclass CC3Texture2D,
 * this is tracked automatically, and invoking this method will not overwrite
 * the loaded mipmap. But for instances of the base cluster parent CCTexture2D,
 * you should be sure to set the hasMipmap property to YES before invoking this
 * method, to avoid overwriting the loaded mipmap.
 */
-(BOOL) generateMipmapIfNeeded;

@end


#pragma mark -
#pragma mark CC3Texture2D

/**
 * CC3Texture2D is a cluster subclass of CCTexture2D.
 *
 * CC3Texture2D provides more automated tracking of mipmaps and texture orienation.
 * In particular, by instantiating a CC3Texture2D instead of the CCTexture2D superclass:
 *   - The hasMipmap property will correctly indicate the presence of a mipmap
 *     in a texture loaded from a PVR file that already contains a mipmap, so
 *     that a subsequent invocation of generateMipmapIfNeeded will not overwrite
 *     this loaded mipmap, and that loaded mipmap can be used by the CC3Texture
 *     even if the shouldGenerateMipmaps is set to NO.
 *   - The isFlippedVertically property is automatically set to NO when the
 *     instance was loaded from a PVR file, and set to YES otherwise.
 *   - When an instance of CC3Texture2D is deallocated, it automatically sets
 *     the hasMipmap property to NO, and the isFlippedVertically to YES, before
 *     deallocation. This avoids potential confusion if the same texture name
 *     is reused by the GL engine for a CCTexture2D instance.
 *
 * CC3Texture automatically causes an instance of CC3Texture2D to be
 * instantiated by CCTextureCache when the CC3Texture is loaded from a file.
 */
@interface CC3Texture2D : CCTexture2D

/**
 * This is a replication of the same class-side property of the CCTexture2D
 * superclass. If you change the value of the superclass property, you should
 * also change the value of this property to match.
 */
+(BOOL) PVRImagesHavePremultipliedAlpha;

/**
 * This is a replication of the same class-side property of the CCTexture2D
 * superclass. If you change the value of the superclass property, you should
 * also change the value of this property to match.
 */
+(void) PVRImagesHavePremultipliedAlpha: (BOOL) haveAlphaPremultiplied;

@end
