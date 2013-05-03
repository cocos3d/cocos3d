/*
 * CC3Texture.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3GLTexture.h"


#pragma mark -
#pragma mark CC3Texture

/** 
 * Each instance of CC3Texture wraps a CC3GLTexture instance and a CC3TextureUnit instance,
 * and manages applying the texture and texture unit settings to the GL engine.
 *
 * To conserve memory and improve texture loading performance, CC3GLTexture instances are
 * cached, and many CC3Texture instances can share the same underlying CC3GLTexture instance.
 * You can therefore create many CC3Texture instances loaded from the same texture file,
 * without having to worry about the texture contents being loaded multiple times.
 *
 * In most cases, a material will hold a single instance of CC3Texture in the texture property
 * to provide a simple single-texture surface. This is the most common application of textures
 * to a material.
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
 * Under OpenGL ES 1.1, or OpenGL using a fixed-function pipeline, each texture unit combines
 * its texture with the output of the previous texture unit in the chain. Combining textures
 * is quite flexible under OpenGL, and there are many ways that each texture can be combined
 * with the output of the previous texture unit. The way that a particular texture combines
 * with the previous textures is defined by an instance of CC3TextureUnit, held in the
 * textureUnit property of each texture that was added to the material.
 *
 * For example, to configure a material for bump-mapping, add a texture that contains a
 * normal vector at each pixel instead of a color, and set the textureUnit property of
 * the texture to a CC3BumpMapTextureUnit. Then add another texture, containing the image
 * that will be visible, to the material. The material will combine these two textures,
 * as specified by the CC3TextureUnit held by the second texture.
 *
 * Under OpenGL ES 2.0 or OpenGL with a programmable pipeline, you will generally handle
 * multitexturing in the shader code.
 */
@interface CC3Texture : CC3Identifiable {
	CC3GLTexture* _texture;
	CC3TextureUnit* _textureUnit;
}

/**
 * The CC3GLTexture texture being managed by this instance.
 *
 * This property is populated automatically by the loadTextureFile: method, or one
 * of the file-loading initialization methods, but it can also be set directly to
 * a CC3GLTexture that has already been loaded.
 *
 * If this instance does not yet have a name, it is set to the name of the specified
 * CC3GLTexture instance.
 */
@property(nonatomic, retain) CC3GLTexture* texture;

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
 * Different subclasses of CC3TextureUnit provide different customizations for combining textures. The
 * CC3BumpMapTextureUnit provides easy settings for DOT3 bump-mapping, and CC3ConfigurableTextureUnit
 * provides complete flexibility in setting texture environment settings.
 */
@property(nonatomic, retain) CC3TextureUnit* textureUnit;

/**
 * Returns whether the alpha channel of this texture has already been multiplied
 * into each of the RGB color channels.
 *
 * This is a convenience property that simply returns the value of the same property on the
 * underlying CC3GLTexture instance.
 */
@property(nonatomic,readonly) BOOL hasPremultipliedAlpha;

/**
 * Returns whether this texture is flipped upside-down.
 *
 * The vertical axis of the coordinate system of OpenGL is inverted relative to the
 * CoreGraphics view coordinate system. As a result, some texture file formats may be
 * loaded upside down. Most common file formats, including JPG, PNG & PVR are loaded
 * right-way up, but using proprietary texture formats developed for other platforms
 * may result in textures being loaded upside-down.
 *
 * This is a convenience property that simply returns the value of the same property on the
 * underlying CC3GLTexture instance.
 */
@property(nonatomic, readonly) BOOL isFlippedVertically;

/** Returns whether this texture is a standard two-dimentional texture. */
@property(nonatomic, readonly) BOOL isTexture2D;

/** Returns whether this texture is a six-sided cube-map texture. */
@property(nonatomic, readonly) BOOL isTextureCube;

/**
 * Returns the proportional size of the usable image in the texture, relative to its physical size.
 *
 * The physical size of most textures is some power-of-two (POT), whereas the usable image size is
 * the actual portion of it that contains the image. The returned value contains two fractional floats
 * (width & height), each between zero and one, representing the proportional size of the usable image
 *
 * As an example, an image whose dimensions are actually 320 x 480 pixels will result in a texture
 * that is 512 x 512 pixels, and the mapSize returned by this method will be {0.625, 0.9375},
 * calculated from {320/512, 480/512}.
 *
 * This is a convenience property that simply returns the value of the same property on the
 * underlying CC3GLTexture instance.
 */
@property(nonatomic, readonly) CGSize coverage;

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
 * directly. Instead, you can use the globalLightPosition property of the mesh
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


#pragma mark Texture file loading

/**
 * Loads the texture file at the specified file path into the texture property,
 * and returns whether the loading was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * If this instance does not yet have a name, it is set to the unqualified file name from
 * the specified file path.
 *
 * If the instance is instantiated with either initFromFile: or textureFromFile:, this method will
 * be invoked automatically during instance initialization. If the instance is instantiated without
 * using one of the file-loading methods, this method can be invoked directly to load the file.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, and the texture files do
 * not already contain a mipmap, a mipmap will be generated for the texture automatically.
 */
-(BOOL) loadTextureFile: (NSString*) aFilePath;

/**
 * Loads the six cube face textures at the specified file paths, and returns whether all
 * six files were successfully loaded.
 *
 * If this instance has not been assigned a name, it is set to the unqualified file name
 * of the specified posXFilePath file path.
 *
 * If the instance is instantiated via initFromFilesPosX:negX:posY:negY:posZ:negZ: or
 * textureFromFilesPosX:negX:posY:negY:posZ:negZ:, this method is invoked automatically
 * during instance initialization. If the instance is instantiated without using one of
 * those file-loading initializers, this method can be invoked directly to load the files.
 *
 * Each of the specified file paths may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the corresponding file path can simply be the name of the file.
 *
 * Each underlying texture is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same posXFilePath file name will only load the textures
 * once. All instances that have invoked this method on the same posXFilePath file path will
 * share the same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the underlying texture automatically.
 */
-(BOOL) loadCubeMapFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
							posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
							posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath;

/**
 * Loads the six cube face textures using the specified pattern string as a string format
 * template to derive the names of the six textures, and returns whether all six files were
 * successfully loaded.
 *
 * If the instance is instantiated via initFromFilePattern: or textureFromFilePattern:,
 * this method is invoked automatically during instance initialization. If the instance
 * is instantiated without using one of those file-loading initializers, this method can
 * be invoked directly to load the files.
 *
 * This method expects the six required files to have identical paths and names, except that
 * each should contain one of the following character substrings in the same place in each
 * file path: "PosX", "NegX", "PosY", "NegY", "PosZ", "NegZ".
 *
 * The specified file path pattern should include one standard NSString format marker %@ at
 * the point where one of the substrings in the list above should be substituted.
 *
 * As an example, the file path pattern MyCubeTex%@.png would be expanded by this method
 * to load the following six textures:
 *  - MyCubeTexPosX.png
 *  - MyCubeTexNegX.png
 *  - MyCubeTexPosY.png
 *  - MyCubeTexNegY.png
 *  - MyCubeTexPosZ.png
 *  - MyCubeTexNegZ.png
 *
 * The format marker can occur anywhere in the file name. It does not need to occur at the
 * end as in this example.
 *
 * The specified file path pattern may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the specified file path pattern can simply be the file name pattern.
 *
 * If this instance has not been assigned a name, it is set to the unqualified file name
 * derived from substituting an empty string into the format marker in the specified file
 * path pattern string.
 *
 * Each underlying texture is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path pattern will only load the textures once.
 * All instances that have invoked this method on the same file path pattern will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the underlying texture automatically.
 */
-(BOOL) loadCubeMapFromFilePattern: (NSString*) aFilePathPattern;


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
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * Returns nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance loaded from the texture file at
 * the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances created by invoking this method on the same file path will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * Returns nil if the file could not be loaded.
 */
+(id) textureFromFile: (NSString*) aFilePath;

/**
 * Initializes this instance with the specified name and loaded from the texture file
 * at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances that have invoked this method on the same file path will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * Returns nil if the file could not be loaded.
 */
-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilePath;

/**
 * Allocates and initializes an autoreleased instance with the specified name and loaded
 * from the texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * Each texture file is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path will only load the file once.
 * All instances created by invoking this method on the same name will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * Returns nil if the file could not be loaded.
 */
+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFilePath;

/**
 * Initializes this instance by loading the six cube face textures at the specified file paths,
 * and returns whether all six files were successfully loaded.
 *
 * Each of the specified file paths may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the corresponding file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name of the specified posXFilePath file path.
 *
 * Each underlying texture is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same posXFilePath file name will only load the textures
 * once. All instances that have invoked this method on the same posXFilePath file name will
 * share the same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the underlying texture automatically.
 *
 * Returns nil if any of the six files could not be loaded.
 */
-(id) initCubeMapFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
						  posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
						  posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath;

/**
 * Returns an instance initialized by loading the six cube face textures at the specified
 * file paths, and returns whether all six files were successfully loaded.
 *
 * Each of the specified file paths may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the corresponding file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name of the specified posXFilePath file path.
 *
 * Each underlying texture is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same posXFilePath file name will only load the textures
 * once. All instances created by invoking this method on the same posXFilePath file name will
 * share the same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the underlying texture automatically.
 *
 * Returns nil if any of the six files could not be loaded.
 */
+(id) textureCubeMapFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
							 posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
							 posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath;

/**
 * Initializes this instance by loading the six cube face textures using the specified pattern
 * string as a string format template to derive the names of the six textures, and returns whether
 * all six files were successfully loaded.
 *
 * This method expects the six required files to have identical paths and names, except that
 * each should contain one of the following character substrings in the same place in each
 * file path: "PosX", "NegX", "PosY", "NegY", "PosZ", "NegZ".
 *
 * The specified file path pattern should include one standard NSString format marker %@ at
 * the point where one of the substrings in the list above should be substituted.
 *
 * As an example, the file path pattern MyCubeTex%@.png would be expanded by this method
 * to load the following six textures:
 *  - MyCubeTexPosX.png
 *  - MyCubeTexNegX.png
 *  - MyCubeTexPosY.png
 *  - MyCubeTexNegY.png
 *  - MyCubeTexPosZ.png
 *  - MyCubeTexNegZ.png
 *
 * The format marker can occur anywhere in the file name. It does not need to occur at the
 * end as in this example.
 *
 * The specified file path pattern may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the specified file path pattern can simply be the file name pattern.
 *
 * The name of this instance is set to the unqualified file name derived from substituting
 * an empty string into the format marker in the specified file path pattern string.
 *
 * Each underlying texture is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path pattern will only load the textures once.
 * All instances that have invoked this method on the same file path pattern will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the underlying texture automatically.
 *
 * Returns nil if any of the six files could not be loaded.
 */
-(id) initCubeMapFromFilePattern: (NSString*) aFilePathPattern;

/**
 * Returns an instance initialized by loading the six cube face textures using the specified pattern
 * string as a string format template to derive the names of the six textures, and returns whether
 * all six files were successfully loaded.
 *
 * This method expects the six required files to have identical paths and names, except that
 * each should contain one of the following character substrings in the same place in each
 * file path: "PosX", "NegX", "PosY", "NegY", "PosZ", "NegZ".
 *
 * The specified file path pattern should include one standard NSString format marker %@ at
 * the point where one of the substrings in the list above should be substituted.
 *
 * As an example, the file path pattern MyCubeTex%@.png would be expanded by this method
 * to load the following six textures:
 *  - MyCubeTexPosX.png
 *  - MyCubeTexNegX.png
 *  - MyCubeTexPosY.png
 *  - MyCubeTexNegY.png
 *  - MyCubeTexPosZ.png
 *  - MyCubeTexNegZ.png
 *
 * The format marker can occur anywhere in the file name. It does not need to occur at the
 * end as in this example.
 *
 * The specified file path pattern may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the specified file path pattern can simply be the file name pattern.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * The name of this instance is set to the unqualified file name derived from substituting
 * an empty string into the format marker in the specified file path pattern string.
 *
 * Each underlying texture is globally cached upon loading. Invoking this method on multiple
 * instances of CC3Texture with the same file path pattern will only load the textures once.
 * All instances created by invoking this method on the same file path pattern will share the
 * same instance of the underlying CC3GLTexture held in the texture property.
 *
 * If the CC3GLTexture.shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the underlying texture automatically.
 *
 * Returns nil if any of the six files could not be loaded.
 */
+(id) textureCubeMapFromFilePattern: (NSString*) aFilePathPattern;


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

@end


#pragma mark -
#pragma mark Deprecated functionality

/** Extension category to support deprecated functionality. */
@interface CC3Texture (Deprecated)

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, readonly) GLuint textureID DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to coverage. */
@property(nonatomic, readonly) CGSize mapSize DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, readonly) BOOL hasMipmap DEPRECATED_ATTRIBUTE;

/** @deprecated Access this method on the contained CC3GLTexture. */
-(void) generateMipmap DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the CC3GLTexture class. */
+(BOOL) shouldGenerateMipmaps DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the CC3GLTexture class. */
+(void) setShouldGenerateMipmaps: (BOOL) shouldMipmap DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, assign) GLenum minifyingFunction DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, assign) GLenum magnifyingFunction DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, assign) GLenum horizontalWrappingFunction DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, assign) GLenum verticalWrappingFunction DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
@property(nonatomic, assign) ccTexParams textureParameters DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
+(ccTexParams) defaultTextureParameters DEPRECATED_ATTRIBUTE;

/** @deprecated Access this property on the contained CC3GLTexture. */
+(void) setDefaultTextureParameters: (ccTexParams) texParams DEPRECATED_ATTRIBUTE;

/** @deprecated Use the initWithTag: and then loadFromFile: methods. */
-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath DEPRECATED_ATTRIBUTE;

/** @deprecated Use the initWithTag: and then loadFromFile: methods. */
+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFilePath DEPRECATED_ATTRIBUTE;

/** @deprecated Use the initWithTag:withName: and then loadFromFile: methods. */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFilePath DEPRECATED_ATTRIBUTE;

/** @deprecated Use the initWithTag:withName: and then loadFromFile: methods. */
+(id) textureWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFilePath DEPRECATED_ATTRIBUTE;

@end