/*
 * CC3GLTexture.h
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


#pragma mark -
#pragma mark CC3GLTexture

/** 
 * The root class of a class cluster representing textures that are loaded into the GL engine.
 *
 * Since a single GL texture can be used by many nodes and materials, GL textures are cached.
 * The application can use the class-side getGLTextureNamed: method to retrieve a loaded texture
 * from the cache, and the class-side addGLTexture: method to add a new texture to the cache.
 * See the notes of those two methods for more details.
 * 
 * When creating an instance on a single texture file, the textureFromFile: method can be used to
 * check the cache for an existing instance, and to automatically load an instance into the cache
 * from that file if it has not already been loaded.
 *
 * CC3GLTexture is the root of a class cluster for loading different file types. Depending on the
 * file type, the initFromFile: and textureFromFile: methods may return an instance of a class that
 * is different than the receiver. You can use the textureClassForFile: method to determine the
 * cluster subclass whose instance will be returned by these methods for a particular file.
 *
 * To improve both performance and texture quality, by default, instances whose width and height
 * are a power-of-two (see the isPOT property) automatically generate a mipmap when a texture is
 * loaded. If you do not want mipmaps to be generated automatically, set the class-side
 * shouldGenerateMipmaps property to NO. With automatic mipmap generation turned off, you can
 * selectively generate a mipmap on any single CC3GLTexture instance by using the generateMipmap
 * method. In addition, textures that contain mipmaps within the file content (PVR files may contain
 * mipmaps) will retain and use this mipmap. See the shouldGenerateMipmaps and hasMipmap properties,
 * and the generateMipmap method for more information.
 *
 * Under iOS and OSX, most texture formats are loaded updside-down. This is because the vertical
 * axis of the coordinate system of OpenGL is inverted relative to the iOS or OSX view coordinate
 * system. The isFlippedVerically property can be used to ensure that textures are displayed with
 * the correct orientation. When a CC3Texture is applied to a mesh, the mesh will be adjusted
 * automatically if the texture is vertically flipped.
 *
 * Generally, you do not use this class cluster directly. Instead, you will typically load textures
 * through the CC3Texture class, which will manage access to the correct instance of this class cluster.
 */
@interface CC3GLTexture : CC3Identifiable {
	GLuint _textureID;
	CC3IntSize _size;
	CGSize _coverage;
	GLenum _minifyingFunction;
	GLenum _magnifyingFunction;
	GLenum _horizontalWrappingFunction;
	GLenum _verticalWrappingFunction;
	BOOL _texParametersAreDirty : 1;
	BOOL _hasMipmap : 1;
	BOOL _isFlippedVertically : 1;
	BOOL _shouldFlipVerticallyOnLoad : 1;		// Used by some subclasses
	BOOL _hasPremultipliedAlpha : 1;
}

/** The texture ID used to identify this texture to the GL engine. */
@property(nonatomic, readonly) GLuint textureID;

/** The size of this texture in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/** Returns whether the width of this texture is a power-of-two. */
@property(nonatomic, readonly) BOOL isPOTWidth;

/** Returns whether the height of this texture is a power-of-two. */
@property(nonatomic, readonly) BOOL isPOTHeight;

/** Returns whether both the width and the height of this texture is a power-of-two. */
@property(nonatomic, readonly) BOOL isPOT;

/** Returns whether this texture is a standard two-dimentional texture. */
@property(nonatomic, readonly) BOOL isTexture2D;

/** Returns whether this texture is a six-sided cube-map texture. */
@property(nonatomic, readonly) BOOL isTextureCube;

/**
 * Returns the proportional size of the usable image in the texture, relative to its physical size.
 *
 * Depending on the environment, the physical size of textures may be some power-of-two (POT), even
 * when the texture dimensions are not. In this case, the usable image size is the actual portion
 * of it that contains the image. This property contains two fractional floats (width & height),
 * each between zero and one, representing the proportional size of the usable image
 *
 * As an example, an image whose dimensions are actually 320 x 480 pixels may be loaded into a
 * texture that is 512 x 512 pixels. In that case, the value returned by this property will be
 * {0.625, 0.9375}, as calculated from {320/512, 480/512}.
 */
@property(nonatomic, readonly) CGSize coverage;

/**
 * Indicates whether the alpha channel of this texture has already been multiplied
 * into each of the RGB color channels.
 *
 * The value of this property is determined from the contents of the texture file,
 * but you can set this property directly to override the value determined from the file.
 */
@property(nonatomic, assign) BOOL hasPremultipliedAlpha;

/**
 * Indicates whether this texture is flipped upside-down.
 *
 * The vertical axis of the coordinate system of OpenGL is inverted relative to the
 * CoreGraphics view coordinate system. As a result, some texture file formats may be
 * loaded upside down. Most common file formats, including JPG, PNG & PVR are loaded
 * right-way up, but using proprietary texture formats developed for other platforms
 * may result in textures being loaded upside-down.
 *
 * The value of this property is determined from the contents of the texture file, but
 * you can set this property directly to override the value determined from the file.
 */
@property(nonatomic, assign) BOOL isFlippedVertically;

/**
 * Returns the GL target of this texture.
 *
 * Returns GL_TEXTURE_2D if this is a 2D texture, or GL_TEXTURE_CUBE_MAP if this is a cube map texture.
 */
@property(nonatomic, readonly) GLenum textureTarget;


#pragma mark Mipmaps

/**
 * Returns whether a mipmap has been generated for this texture.
 *
 * If the class-side shouldGenerateMipmaps property is YES, mipmaps are generated automatically
 * when the texture data has been loaded.
 *
 * Mipmaps can also be generated manually by invoking the generateMipmap method.
 */
@property(nonatomic, readonly) BOOL hasMipmap;

/**
 * Generates a mipmap for this texture, if needed.
 *
 * It is safe to invoke this method more than once, because it will only generate
 * a mipmap if it does not yet exist.
 *
 * Mipmaps can only be generated for textures whose width and height are are a power-of-two
 * (see the isPOT property).
 */
-(void) generateMipmap;

/**
 * Returns whether a mipmap should be generated automatically for each instance when
 * the texture is loaded.
 *
 * If this property is set to YES, mipmap will only be generated if the texture
 * file does not already contain a mipmap.
 *
 * The value of this property affects all textures loaded while that value is in effect.
 * You can set this property to the desired value prior to loading one or more textures.
 *
 * The default value of this class-side property is YES, indicating that mipmaps
 * will be generated for any texture loaded whose dimensions are a power-of-two.
 */
+(BOOL) shouldGenerateMipmaps;

/**
 * Sets whether a mipmap should be generated automatically for each instance when
 * the texture is loaded.
 *
 * If this property is set to YES, mipmap will only be generated if the texture
 * file does not already contain a mipmap.
 *
 * The value of this property affects all textures loaded while that value is in effect.
 * You can set this property to the desired value prior to loading one or more textures.
 *
 * The default value of this class-side property is YES, indicating that mipmaps
 * will be generated for any texture loaded whose dimensions are a power-of-two.
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
 * The last four values above require that a mipmap be available, as indicated by the hasMipmap
 * property. If one of those value is set in this property, this property will only return either
 * GL_NEAREST (for all GL_NEAREST... values) or GL_LINEAR (for all GL_LINEAR... values) until a
 * mipmap has been created. See the hasMipmap property for more information about mipmaps.
 *
 * The initial value of this property is set by the defaultTextureParameters class-side property,
 * and defaults to GL_LINEAR_MIPMAP_NEAREST, or GL_LINEAR if the texture does not have a mipmap.
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
 * The values GL_REPEAT and GL_MIRRORED_REPEAT can only be set if the width of this texture is a
 * power-of-two. If the width is not a power-of-two, this property will always return GL_CLAMP_TO_EDGE.
 *
 * The initial value of this property is set by the defaultTextureParameters class-side property,
 * and will be GL_REPEAT if the width of this texture is a power-of-two, or GL_CLAMP_TO_EDGE if not.
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
 * The values GL_REPEAT and GL_MIRRORED_REPEAT can only be set if the height of this texture is a
 * power-of-two. If the height is not a power-of-two, this property will always return GL_CLAMP_TO_EDGE.
 *
 * The initial value of this property is set by the defaultTextureParameters class-side property,
 * and will be GL_REPEAT if the height of this texture is a power-of-two, or GL_CLAMP_TO_EDGE if not.
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
 * The initial value of this property is set by the defaultTextureParameters class-side property.
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


#pragma mark Drawing

/** 
 * Binds this GL texture to the GL engine. It is bound to the current texture unit indicated
 * by the specified visitor.
 *
 * If any of the texture parameter properties have been changed since the last time this
 * GL texture was bound, they are updated in the GL engine at this time.
 */
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Texture file loading

/**
 * Loads the single texture file at the specified file path, and returns whether the loading was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * If this instance has not been assigned a name, it is set to the unqualified file name
 * from the specified file path.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the texture file does
 * not already contain a mipmap, a mipmap will be generated for the texture automatically.
 *
 * If the instance is instantiated via initFromFile: or textureFromFile:, this method is invoked
 * automatically during instance initialization. If the instance is instantiated without using
 * one of those file-loading initializers, this method can be invoked directly to load the file.
 *
 * This method can be used to load a single standard 2D texture. It can also be used to load
 * cube-map textures contained within a single PVR texture file. 
 *
 * This method cannot be used to load cube-maps that require more than one file to be loaded.
 *
 * CC3GLTexture is the root class of a class cluster. Not all subclasses support the loading
 * of a single texture file. When using this method directly, be aware of which cluster class
 * you are using. You can use the textureClassForFile: method to determine the appropriate
 * cluster subclass to instantiate for loading the specified file.
 */
-(BOOL) loadFromFile: (NSString*) aFilePath;


#pragma mark Allocation and Initialization

/**
 * Returns an instance initialized by loading the single texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * This method can be used to load a single standard 2D texture. It can also be used to load
 * cube-map textures contained within a single PVR texture file.
 *
 * This method cannot be used to load cube-maps that require more than one file to be loaded.
 *
 * CC3GLTexture is the root of a class cluster for loading different file types. Depending on the
 * file type of the specified file, this method may return an instance of a class that is different
 * than the class of the receiver. You can use the textureClassForFile: method to determine the 
 * cluster subclass whose instance will be returned by this method for the specified file.
 *
 * Normally, you should use the textureFromFile: method to reuse any cached instance instead of
 * creating and loading a new instance. The textureFromFile: method automatically invokes this
 * method if an instance does not exist in the texture cache, in order to create and load the
 * texture from the file, and after doing so, places the newly loaded instance into the cache.
 *
 * However, by invoking the alloc method and then invoking this method directly, the application
 * can load the texture without first checking the texture cache. The texture can then be placed
 * in the cache using the addGLTexture: method. If you load two separate textures from the same
 * file, be sure to set a distinct name for each before adding each to the cache.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the texture file does
 * not already contain a mipmap, a mipmap will be generated for the texture automatically.
 *
 * Returns nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

/**
 * Returns an instance initialized by loading the single texture file at the specified file path.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The name of this instance is set to the unqualified file name from the specified
 * file path and the tag is set to an automatically generated unique tag value.
 *
 * This method can be used to load a single standard 2D texture. It can also be used to load
 * cube-map textures contained within a single PVR texture file.
 *
 * This method cannot be used to load cube-maps that require more than one file to be loaded.
 *
 * CC3GLTexture is the root of a class cluster for loading different file types. Depending on the
 * file type of the specified file, this method may return an instance of a class that is different
 * than the receiver. You can use the textureClassForFile: method to determine the cluster subclass
 * whose instance will be returned by this method for the specified file.
 *
 * Textures loaded through this method are cached. If the texture was already loaded and is in
 * the cache, it is retrieved and returned. If the texture has not in the cache, it is loaded
 * from the specified file, placed into the cache, and returned. It is therefore safe to invoke
 * this method any time the texture is needed, without having to worry that the texture will
 * be repeatedly loaded from file.
 *
 * To clear a texture instance from the cache, use the removeGLTexture: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromFile: methods.
 * This technique can be used to load the same texture twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 * However, when choosing to do so, be aware that textures often consume significant memory.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the texture file does
 * not already contain a mipmap, a mipmap will be generated for the texture automatically.
 *
 * Returns nil if the texture is not in the cache and could not be loaded.
 */
+(id) textureFromFile: (NSString*) aFilePath;

/**
 * Returns the correct CC3GLTexture subclass that will be used when loading a single texture
 * from the specified file path, by using the initFromFile: or textureFromFile: methods.
 *
 * When not using either of those two initialization methods to create an instance, you can
 * use this method to determine the class to instantiate using a different initializer, and
 * then use the loadFromFile: method to load the file.
 */
+(Class) textureClassForFile: (NSString*) aFilePath;


#pragma mark GL Texture cache

/**
 * Adds the specified texture to the collection of loaded textures.
 *
 * Textures are accessible via their names through the getTextureNamed: method, and should
 * be unique. If a texture with the same name as the specified texture already exists in
 * this cache, an assertion error is raised.
 */
+(void) addGLTexture: (CC3GLTexture*) texture;

/** Returns the texture with the specified name, or nil if a texture with that name has not been added. */
+(CC3GLTexture*) getGLTextureNamed: (NSString*) name;

/** Removes the specified texture from the collection of loaded programs. */
+(void) removeGLTexture: (CC3GLTexture*) texture;

/** Removes the texture with the specified name from the collection of loaded textures. */
+(void) removeGLTextureNamed: (NSString*) name;

@end


#pragma mark -
#pragma mark CC3GLTexture2D

/** 
 * The representation of a 2D texture loaded into the GL engine.
 *
 * This class is used for all 2D texture types except PVR.
 */
@interface CC3GLTexture2D : CC3GLTexture

/**
 * Indicates whether this instance will flip texture vertically during loading.
 *
 * Under iOS and OSX, most textures are loaded into memory upside-down because of the difference
 * in vertical orientation between the OpenGL and CoreGraphics coordinate systems.
 *
 * If this property is set to YES during loading, the texture will be flipped in memory so
 * that is is oriented the right way up.
 *
 * It is possible to compensate for an upside-down using texture coordinates. You can set
 * this property to NO prior to loading in order to leave the texture upside-down and use
 * texture coordinates to compensate.
 *
 * The initial value of this property is set to the value of the class-side
 * defaultShouldFlipVerticallyOnLoad property.
 */
@property(nonatomic, assign) BOOL shouldFlipVerticallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * The initial value of this class-side property is YES, indicating that instances will flip
 * all 2D textures the right way up during loading.
 */
+(BOOL) defaultShouldFlipVerticallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * The initial value of this class-side property is YES, indicating that instances will flip
 * all 2D textures the right way up during loading.
 */
+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip;

@end


#pragma mark -
#pragma mark CC3GLTextureCube

/** 
 * The representation of a 3D cube-map texture loaded into the GL engine.
 *
 * This class is used for all cube-map texture types except PVR.
 */
@interface CC3GLTextureCube : CC3GLTexture


#pragma mark Texture file loading

/**
 * Loads the texture file at the specified file path into the specified cube face target,
 * and returns whether the loading was successful.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * The specified cube face target can be one of the following:
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_X
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_X
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Z
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
 *
 * In order to complete this cube texture, this method should be invoked once for each
 * of these six face targets.
 *
 * If this instance has not been assigned a name, it is set to the unqualified file name
 * from the specified file path.
 *
 * This method does not automatically generate a mipmap. If you want a mipmap, you should
 * invoke the generateMipmap method once all six faces have been loaded.
 */
-(BOOL) loadCubeFace: (GLenum) faceTarget fromFile: (NSString*) aFilePath;

/**
 * Loads the six cube face textures at the specified file paths, and returns whether all
 * six files were successfully loaded.
 *
 * If this instance has not been assigned a name, it is set to the unqualified file name
 * of the specified posXFilePath file path.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * If the instance is instantiated via initFromFilesPosX:negX:posY:negY:posZ:negZ: or
 * textureFromFilesPosX:negX:posY:negY:posZ:negZ:, this method is invoked automatically
 * during instance initialization. If the instance is instantiated without using one of
 * those file-loading initializers, this method can be invoked directly to load the files.
 *
 * Each of the specified file paths may be either an absolute path, or a path relative to
 * the application resource directory. If the file is located directly in the application
 * resources directory, the corresponding file path can simply be the name of the file.
 */
-(BOOL) loadFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
					 posY: (NSString*) posYFilePath negY: (NSString*) negYFilePath
					 posZ: (NSString*) posZFilePath negZ: (NSString*) negZFilePath;

/**
 * Loads the six cube face textures using the specified pattern string as a string format
 * template to derive the names of the six textures, and returns whether all six files were
 * successfully loaded.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
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
 */
-(BOOL) loadFromFilePattern: (NSString*) aFilePathPattern;


#pragma mark Allocation and initialization

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
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * Returns nil if any of the six files could not be loaded.
 */
-(id) initFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
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
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * The name of this instance is set to the unqualified file name of the specified posXFilePath file path.
 *
 * Textures loaded through this method are cached. If the texture was already loaded and is in
 * the cache, it is retrieved and returned. If the texture has not in the cache, it is loaded,
 * placed into the cache, indexed by its name, and returned. It is therefore safe to invoke this
 * method any time the texture is needed, without having to worry that the texture will be
 * repeatedly loaded from file.
 *
 * To clear a texture instance from the cache, use the removeGLTexture: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromFilesPosX:negX:posY:negY:posZ:negZ:
 * methods. This technique can be used to load the same texture twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 * However, when choosing to do so, be aware that textures often consume significant memory.
 *
 * Returns nil if the texture is not in the cache and any of the six files could not be loaded.
 */
+(id) textureFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
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
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * The name of this instance is set to the unqualified file name derived from substituting
 * an empty string into the format marker in the specified file path pattern string.
 *
 * Returns nil if any of the six files could not be loaded.
 */
-(id) initFromFilePattern: (NSString*) aFilePathPattern;

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
 * Textures loaded through this method are cached. If the texture was already loaded and is in
 * the cache, it is retrieved and returned. If the texture has not in the cache, it is loaded,
 * placed into the cache, indexed by its name, and returned. It is therefore safe to invoke this
 * method any time the texture is needed, without having to worry that the texture will be
 * repeatedly loaded from file.
 *
 * To clear a texture instance from the cache, use the removeGLTexture: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromFilePattern: 
 * methods. This technique can be used to load the same texture twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 * However, when choosing to do so, be aware that textures often consume significant memory.
 *
 * Returns nil if the texture is not in the cache and any of the six files could not be loaded.
 */
+(id) textureFromFilePattern: (NSString*) aFilePathPattern;

@end


#pragma mark -
#pragma mark CC3Texture2DContent

/**
 * A helper class used by the CC3GLTexture class cluster during the loading of a 2D texture.
 *
 * PVR texture files cannot be loaded using this class.
 */
@interface CC3Texture2DContent : CCTexture2D {
	const GLvoid* _imageData;
}

/** Returns a pointer to the texture image data. */
@property(nonatomic, readonly) const GLvoid* imageData;

/** 
 * Flips this texture vertically, to compensate for the opposite orientation
 * of vertical graphical coordinates between OpenGL and iOS & OSX.
 */
-(void) flipVertically;


#pragma mark Allocation and Initialization

/**
 * Initializes this instance by loaded content from the specified file.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * Returns nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

@end
