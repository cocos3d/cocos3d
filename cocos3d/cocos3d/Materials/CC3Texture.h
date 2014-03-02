/*
 * CC3Texture.h
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


#import "CC3Identifiable.h"
#import "CC3NodeVisitor.h"
#import "CC3TextureUnit.h"
#import "CC3CC2Extensions.h"

@class CC3Texture2DContent;


#pragma mark -
#pragma mark CC3Texture

/** 
 * The root class of a class cluster representing textures.
 *
 * Since a single texture can be used by many nodes and materials, textures can be cached.
 * The application can use the class-side getTextureNamed: method to retrieve a loaded texture
 * from the cache, and the class-side addTexture: method to add a new texture to the cache.
 * See the notes of those two methods for more details.
 * 
 * When creating an instance, several of the class-side texture... family of methods
 * (particularly those loading from files) automatically check the cache for an existing
 * instance, based on the filename, and will use that cached instance instead of loading
 * the file again. If the texture is not in the cache, these methods will load it and place
 * it in the cache automatically. These methods can therefore be invoked repeatedly without
 * having to be concerned whether multiple copies of the same texture content will be loaded.
 * Check the notes for the creation methods to verify which methods make use of the cache.
 *
 * CC3Texture is the root of a class cluster organized for loading different texture types,
 * for both 2D and cube textures. Use the creation and initialization methods from this root
 * CC3Texture class. The initializer will ensure that the correct subclass for the texture
 * type, and in some cases, the texture file type, is created and returned. Because of this
 * class-cluster structure, be aware that the class of the instance returned by an instance
 * creation or initialization method may be different than the receiver of that method.
 *
 * There is one exception to this paradigm. Under fixed-pipeline rendering, such as in 
 * OpenGL ES 1.1 under iOS, or OpenGL without shaders under OSX, multi-texturing is handled
 * using configurable texture units. In order to assign a texture unit to a CC3Texture, you
 * must directly instatiate an instance of CC3TextureUnitTexture, and then assign a texture
 * unit to it, instead of letting the CC3Texture creation and initialization methods handle it.
 *
 * To improve both performance and texture quality, by default, instances whose width and height
 * are a power-of-two (see the isPOT property) automatically generate a mipmap when a texture is
 * loaded. If you do not want mipmaps to be generated automatically, set the class-side
 * shouldGenerateMipmaps property to NO. With automatic mipmap generation turned off, you can
 * selectively generate a mipmap on any single CC3Texture instance by using the generateMipmap
 * method. In addition, textures that contain mipmaps within the file content (PVR files may contain
 * mipmaps) will retain and use this mipmap. See the shouldGenerateMipmaps and hasMipmap properties,
 * and the generateMipmap method for more information.
 *
 * Under iOS and OSX, most texture formats are loaded updside-down. This is because the vertical
 * axis of the coordinate system of OpenGL is inverted relative to the iOS or OSX view coordinate
 * system. Subclasses that may loaded upside-down can be configured to automatically flip the texture
 * right-way up during loading. In addition, the isFlippedVerically property indicates whether the
 * texture is upside down. This can be used to ensure that textures are displayed with the correct
 * orientation. When a CC3Texture is applied to a mesh, the mesh will be adjusted automatically if
 * the texture is upside down.
 *
 * When building for iOS, raw PNG and TGA images are pre-processed by Xcode to pre-multiply alpha,
 * and to reorder the pixel component byte order, to optimize the image for the iOS platform.
 * If you want to avoid this pre-processing for PNG or TGA files, for textures such as normal maps
 * or lighting maps, that you don't want to be modified, you can prepend a 'p' to the file
 * extension ("ppng" or "ptga") to cause Xcode to skip this pre-processing and to use a loader
 * that does not pre-multiply the alpha. You can also use this for other file types as well.
 * See the notes for the CC3STBImage useForFileExtensions class-side property for more info.
 */
@interface CC3Texture : CC3Identifiable {
	GLuint _textureID;
	CC3IntSize _size;
	CGSize _coverage;
	GLenum _pixelFormat;
	GLenum _pixelType;
	GLenum _minifyingFunction;
	GLenum _magnifyingFunction;
	GLenum _horizontalWrappingFunction;
	GLenum _verticalWrappingFunction;
	CC3Texture2DContent* _ccTextureContent;
	BOOL _texParametersAreDirty : 1;
	BOOL _hasMipmap : 1;
	BOOL _isUpsideDown : 1;
	BOOL _shouldFlipVerticallyOnLoad : 1;
	BOOL _shouldFlipHorizontallyOnLoad : 1;
	BOOL _hasAlpha : 1;
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
 * Returns the pixel format of the texture.
 *
 * The returned value may be one of the following:
 *   - GL_RGBA
 *   - GL_RGB
 *   - GL_ALPHA
 *   - GL_LUMINANCE
 *   - GL_LUMINANCE_ALPHA
 *   - GL_DEPTH_COMPONENT
 *   - GL_DEPTH_STENCIL
 */
@property(nonatomic, readonly) GLenum pixelFormat;

/** 
 * Returns the pixel data type.
 *
 * Possible values depend on the value of the pixelFormat property as follows:
 *
 *   pixelFormat                pixelType
 *   -----------                ---------
 *   GL_RGBA                    GL_UNSIGNED_BYTE
 *                              GL_UNSIGNED_SHORT_4_4_4_4
 *                              GL_UNSIGNED_SHORT_5_5_5_1
 *   GL_RGB                     GL_UNSIGNED_BYTE
 *                              GL_UNSIGNED_SHORT_5_6_5
 *   GL_ALPHA                   GL_UNSIGNED_BYTE
 *   GL_LUMINANCE               GL_UNSIGNED_BYTE
 *   GL_LUMINANCE_ALPHA         GL_UNSIGNED_BYTE
 *   GL_DEPTH_COMPONENT         GL_UNSIGNED_SHORT
 *                              GL_UNSIGNED_INT
 *   GL_DEPTH_STENCIL           GL_UNSIGNED_INT_24_8
 */
@property(nonatomic, readonly) GLenum pixelType;

/**
 * Indicates whether this texture has an alpha channel, representing opacity.
 *
 * The value of this property is determined from the contents of the texture file,
 * but you can set this property directly to override the value determined from the file.
 */
@property(nonatomic, assign) BOOL hasAlpha;

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
@property(nonatomic, assign) BOOL isUpsideDown;

/**
 * Returns the GL target of this texture.
 *
 * Returns GL_TEXTURE_2D if this is a 2D texture, or GL_TEXTURE_CUBE_MAP
 * if this is a cube map texture.
 */
@property(nonatomic, readonly) GLenum textureTarget;

/**
 * Returns the GL face to use when initially attaching this texture to a framebuffer.
 *
 * Returns GL_TEXTURE_2D if this is a 2D texture, or GL_TEXTURE_CUBE_MAP_POSITIVE_X 
 * if this is a cube map texture.
 */
@property(nonatomic, readonly) GLenum initialAttachmentFace;

/**
 * When using multiple textures with fixed-pipeline rendering, as in OpenGL ES 1.1, 
 * textures are combined using environmental settings applied via a texture unit.
 *
 * When using OpenGL ES 2.0, or OpenGL on OSX, texture units are not typically used,
 * but in some circumstances can be used to carry certain additional configuration
 * information for the texture.
 *
 * In this implementation, setting this property has no effect, and reading this property
 * will always return nil. Subclasses, such as CC3TextureUnitTexture, will override to
 * make use of this property. When making use of texture units, be sure to instantiate
 * an instance of a subclass that supports texture units, such as CC3TextureUnitTexture.
 */
@property(nonatomic, retain) CC3TextureUnit* textureUnit;

/**
 * The direction, in local node coordinates, of the light source that is to interact
 * with this texture if the texture has been configured as an object-space bump-map.
 *
 * Object-space bump-maps are textures that store a normal vector (XYZ coordinates), in
 * object-space coordinates, in the RGB components of each texture pixel, instead of color
 * information. These per-pixel normals interact with the value of this lightDirection
 * property (through a dot-product), to determine the luminance of the pixel. 
 *
 * Object-space bump-maps are used primarily with multi-texturing in a fixed-pipeline
 * rendering environment such as OpenGL ES 1.1. Bump-maps in a programmable-pipeline,
 * such as OpenGL ES 2.0, more commonly use tangent-space normal mapping, which does
 * not make use of this property.
 *
 * Most textures ignore this property. In this implementation, setting this property
 * has no effect, and reading this property always returns kCC3VectorZero.
 *
 * Subclasses, such as CC3TextureUnitTexture may override to make use of this property.
 */
@property(nonatomic, assign) CC3Vector lightDirection;

/**
 * Returns whether this texture is configured as an object-space bump-map.
 *
 * Returns NO. Subclasses, such as CC3TextureUnitTexture may override.
 */
@property(nonatomic, readonly) BOOL isBumpMap;

/**
 * Some texture types wrap a base internal texture. This property returns that wrapped texture,
 * or, if this instance does not wrap another texture, this property returns this instance.
 *
 * This property provides polymorphic compatibility with CC3Texture subclasses, notably
 * CC3TextureUnitTexture, that contain another, underlying texture.
 */
@property(nonatomic, retain, readonly) CC3Texture* texture;


#pragma mark Texture transformations

/**
 * Indicates whether this instance will flip the texture vertically during loading.
 *
 * Under iOS and OSX, most textures are loaded into memory upside-down because of the
 * difference in vertical orientation between the OpenGL and CoreGraphics coordinate systems.
 *
 * If this property is set to YES during loading, the texture will be flipped in memory so
 * that it is oriented the right way up.
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
 * Indicates whether this instance will flip the texture horizontally during loading.
 *
 * Some types of textures (notably cube-map textures) are stored in GL memory horizontally flipped.
 *
 * If this property is set to YES during loading, the texture will be flipped horizontally in memory.
 *
 * The initial value of this property is set to the value of the class-side
 * defaultShouldFlipHorizontallyOnLoad property.
 */
@property(nonatomic, assign) BOOL shouldFlipHorizontallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * Each subclass can have a different value for this class-side property. See the notes for
 * this property on each subclass to understand the initial value.
 */
+(BOOL) defaultShouldFlipVerticallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * Each subclass can have a different value for this class-side property. See the notes for
 * this property on each subclass to understand the initial value.
 */
+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip;

/**
 * This class-side property determines the initial value of the shouldFlipHorizontallyOnLoad
 * for instances of this class.
 *
 * Each subclass can have a different value for this class-side property. See the notes for
 * this property on each subclass to understand the initial value.
 */
+(BOOL) defaultShouldFlipHorizontallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * Each subclass can have a different value for this class-side property. See the notes for
 * this property on each subclass to understand the initial value.
 */
+(void) setDefaultShouldFlipHorizontallyOnLoad: (BOOL) shouldFlip;


#pragma mark Mipmaps

/**
 * Returns whether a mipmap has been generated for this texture.
 *
 * If the class-side shouldGenerateMipmaps property is YES, mipmaps are generated 
 * automatically after the texture data has been loaded.
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
 * The values GL_REPEAT and GL_MIRRORED_REPEAT can only be set if the isPOT property returns
 * YES, indicating that both width and height dimensions of this texture are a power-of-two.
 * Otherwise, this property will always return GL_CLAMP_TO_EDGE.
 *
 * This property must be set to GL_CLAMP_TO_EDGE when using this texture as a rendering target
 * as an attachment to a rendering surface such as a framebuffer ("render-to-texture").
 *
 * The initial value of this property is set by the defaultTextureParameters class-side
 * property, and will be GL_REPEAT if the dimensions of this texture are a power-of-two,
 * or GL_CLAMP_TO_EDGE if not.
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
 * The values GL_REPEAT and GL_MIRRORED_REPEAT can only be set if the isPOT property returns
 * YES, indicating that both width and height dimensions of this texture are a power-of-two.
 * Otherwise, this property will always return GL_CLAMP_TO_EDGE.
 *
 * This property must be set to GL_CLAMP_TO_EDGE when using this texture as a rendering target
 * as an attachment to a rendering surface such as a framebuffer ("render-to-texture").
 *
 * The initial value of this property is set by the defaultTextureParameters class-side
 * property, and will be GL_REPEAT if the dimensions of this texture are a power-of-two,
 * or GL_CLAMP_TO_EDGE if not.
 */
@property(nonatomic, assign) GLenum verticalWrappingFunction;

/**
 * A convenience method to accessing the following four texture parameter properties
 * using a cocos2d ccTexParams structure:
 *   - minifyingFunction
 *   - magnifyingFunction
 *   - horizontalWrappingFunction
 *   - verticalWrappingFunction
 *
 * The value of each component of this structure will be the same as the corresponding
 * property on this instance. See the notes for each of those properties for an indication
 * of the initial values for each of those properties.
 */
@property(nonatomic, assign) ccTexParams textureParameters;

/**
 * The default values for the textureParameters property 
 * (with the initial values of this class-side property):
 *   - minifyingFunction (GL_LINEAR_MIPMAP_NEAREST)
 *   - magnifyingFunction (GL_LINEAR)
 *   - horizontalWrappingFunction (GL_REPEAT)
 *   - verticalWrappingFunction (GL_REPEAT)
 */
+(ccTexParams) defaultTextureParameters;

/**
 * The default values for the textureParameters property
 * (with the initial values of this class-side property):
 *   - minifyingFunction (GL_LINEAR_MIPMAP_NEAREST)
 *   - magnifyingFunction (GL_LINEAR)
 *   - horizontalWrappingFunction (GL_REPEAT)
 *   - verticalWrappingFunction (GL_REPEAT)
 *
 * You can change the value of this class-side property to affect
 * any textures subsequently created or loaded from a file.
 */
+(void) setDefaultTextureParameters: (ccTexParams) texParams;


#pragma mark Drawing

/**
 * Binds this texture to the GL engine.
 *
 * If any of the texture parameter properties have been changed since the last time this
 * texture was bound, they are updated in the GL engine at this time.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Returns the GLSL uniform texture sampler semantic for this type of texture. */
@property(nonatomic, readonly) GLenum samplerSemantic;


#pragma mark Texture content and sizing

/**
 * Replaces a portion of the content of this texture by writing the specified array of pixels
 * into the specified rectangular area within the specified target for this texture, The specified
 * content replaces the texture data within the specified rectangle. The specified content array
 * must be large enough to contain content for the number of pixels in the specified rectangle.
 *
 * If this is a standard 2D texture, the target must be GL_TEXTURE_2D. If this is a cube-map
 * texture, the specified target can be one of the following:
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_X
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_X
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Z
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
 *
 * Content is read from the specified array left to right across each row of pixels within
 * the specified image rectangle, starting at the row at the bottom of the rectangle, and
 * ending at the row at the top of the rectangle.
 *
 * Within the specified array, the pixel content should be packed tightly, with no gaps left
 * at the end of each row. The last pixel of one row should immediately be followed by the
 * first pixel of the next row.
 *
 * The pixels in the specified array are in standard 32-bit RGBA. If the pixelFormat and
 * pixelType properties of this texture are not GL_RGBA and GL_UNSIGNED_BYTE, respectively,
 * the pixels in the specified array will be converted to the format and type of this texture
 * before being inserted into the texture. Be aware that this conversion will reduce the
 * performance of this method. For maximum performance, match the format and type of this
 * texture to the 32-bit RGBA format of the specified array, by setting the pixelFormat
 * property to GL_RGBA and the pixelType property to GL_UNSIGNED_BYTE. However, keep in mind
 * that the 32-bit RGBA format consumes more memory than most other formats, so if performance
 * is of lesser concern, you may choose to minimize the memory requirements of this texture
 * by setting the pixelFormat and pixelType properties to values that consume less memory.
 *
 * If this texture has mipmaps, they are not automatically updated. Once all desired content
 * has been replaced, invoke the generateMipmap method to regenerate the mipmaps.
 */
-(void) replacePixels: (CC3Viewport) rect
			 inTarget: (GLenum) target
		  withContent: (ccColor4B*) colorArray;

/** Resizes this texture to the specified dimensions and clears all texture content. */
-(void) resizeTo: (CC3IntSize) size;


#pragma mark Associated CCTexture

/** 
 * Returns a cocos2d-compatible 2D texture, that references the same GL texture.
 *
 * The value of the class-side shouldCacheAssociatedCCTextures property determines whether
 * the CCTexture returned by this method will automatically be added to the CCTextureCache.
 *
 * With the class-side shouldCacheAssociatedCCTextures property set to NO, you can still 
 * add any CCTexture retrieved from this property to the CCTextureCache using the 
 * CCTextureCache addTexture:named: method.
 *
 * Although a CCTexture can be retrieved for any type of CC3Texture, including cube-maps,
 * using a cube-mapped texture as a cocos2d texture may lead to unexpected behavour.
 */
@property(nonatomic, retain, readonly) 	CCTexture* ccTexture;

/**
 * Indicates whether the associated cocos2d CCTexture, available through the ccTexture 
 * property, should be automatically added to the cocos2d CCTextureCache.
 *
 * The initial value of this property is NO. If you intend to share many of the same textures
 * between cocos3d and cocos2d objects, you may want to set this property to YES.
 *
 * With this property set to NO, you can still add any CCTexture retrieved from the ccTexture
 * property to the CCTextureCache using the CCTexture addToCacheWithName: method.
 */
+(BOOL) shouldCacheAssociatedCCTextures;

/**
 * Indicates whether the associated cocos2d CCTexture, available through the ccTexture
 * property, should be automatically added to the cocos2d CCTextureCache.
 *
 * The initial value of this property is NO. If you intend to share many of the same textures
 * between cocos3d and cocos2d objects, you may want to set this property to YES.
 *
 * With this property set to NO, you can still add any CCTexture retrieved from the ccTexture
 * property to the CCTextureCache using the CCTexture addToCacheWithName: method.
 */
+(void) setShouldCacheAssociatedCCTextures: (BOOL) shouldCache;

/** @deprecated Renamed to ccTexture. */
@property(nonatomic, retain, readonly) 	CCTexture* ccTexture2D DEPRECATED_ATTRIBUTE;

/** @deprecated Use the ccTexture property instead. */
-(CCTexture*) asCCTexture2D DEPRECATED_ATTRIBUTE;


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
 * CC3Texture is the root of a class cluster for loading different file types. Depending on the
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
 * in the cache using the addTexture: method. If you load two separate textures from the same
 * file, be sure to set a distinct name for each before adding each to the cache.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, and the texture file does
 * not already contain a mipmap, a mipmap will be generated for the texture automatically.
 *
 * Returns nil if the file could not be loaded.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
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
 * CC3Texture is the root of a class cluster for loading different file types. Depending on the
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
 * To clear a texture instance from the cache, use the removeTexture: method.
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
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureFromFile: (NSString*) aFilePath;

/**
 * Initializes this instance from the content in the specified CGImage.
 *
 * The name property of this instance will be nil.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initWithCGImage: (CGImageRef) cgImg;

/**
 * Allocates and initializes an autoreleased instance from the content in the specified CGImage.
 *
 * The name property of this instance will be nil.
 *
 * If the class-side shouldGenerateMipmaps property is set to YES, a mipmap will be generated
 * for the texture automatically.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureWithCGImage: (CGImageRef) cgImg;

/**
 * Initializes this instance from the specified texture properties, without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine when the resizeTo: method is
 * invoked, providing the texture with a size.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initWithPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Allocates and initializes an autoreleased instance from the specified texture properties,
 * without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine when the resizeTo: method is
 * invoked, providing the texture with a size.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureWithPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Initializes this instance from the specified texture properties, without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine, with space allocated for a
 * texture of the specified size and pixel content. Content can be added later by using this
 * texture as a rendering surface.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Allocates and initializes an autoreleased instance from the specified texture properties,
 * without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine, with space allocated for a
 * texture of the specified size and pixel content. Content can be added later by using this
 * texture as a rendering surface.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type;

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
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
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
 * To clear a texture instance from the cache, use the removeTexture: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromFilesPosX:negX:posY:negY:posZ:negZ:
 * methods. This technique can be used to load the same texture twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 * However, when choosing to do so, be aware that textures often consume significant memory.
 *
 * Returns nil if the texture is not in the cache and any of the six files could not be loaded.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureCubeFromFilesPosX: (NSString*) posXFilePath negX: (NSString*) negXFilePath
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
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initCubeFromFilePattern: (NSString*) aFilePathPattern;

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
 * To clear a texture instance from the cache, use the removeTexture: method.
 *
 * To load the file directly, bypassing the cache, use the alloc and initFromFilePattern:
 * methods. This technique can be used to load the same texture twice, if needed for some reason.
 * Each distinct instance can then be given its own name, and added to the cache separately.
 * However, when choosing to do so, be aware that textures often consume significant memory.
 *
 * Returns nil if the texture is not in the cache and any of the six files could not be loaded.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureCubeFromFilePattern: (NSString*) aFilePathPattern;

/**
 * Initializes this instance from the specified texture properties, without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine when the resizeTo: method is
 * invoked, providing the texture with a size.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Allocates and initializes an autoreleased instance from the specified texture properties,
 * without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine when the resizeTo: method is
 * invoked, providing the texture with a size.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureCubeWithPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Initializes this instance from the specified texture properties, without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine, with space allocated for six
 * texture faces of the specified size and pixel content. Content can be added later by using
 * this texture as a rendering surface.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be a different
 * instance of a different class than the receiver.
 */
-(id) initCubeWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Allocates and initializes an autoreleased instance from the specified texture properties,
 * without providing content.
 *
 * Once initialized, the texture will be bound to the GL engine, with space allocated for a
 * texture of the specified size and pixel content. Content can be added later by using this
 * texture as a rendering surface.
 *
 * See the notes for the pixelFormat and pixelType properties for the range of values permitted
 * for the corresponding format and type parameters here.
 *
 * The name property of this instance will be nil.
 *
 * Since textures can consume significant resources, you should assign this instance a name
 * and add it to the texture cache by using the class-side addTexture: method. You can then
 * retrieve the texture from the cache via the getTextureNamed: method to apply this texture
 * to multple meshes.
 *
 * CC3Texture is the root of a class-cluster. The object returned may be an instance of a
 * different class than the receiver.
 */
+(id) textureCubeWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/**
 * Returns a texture name derived from the specified file path.
 *
 * This method is used to standardize the naming of textures, to ease in adding and retrieving
 * textures to and from the cache, and is used to create the name for each texture that is
 * loaded from a file.
 *
 * This implementation returns the lastComponent of the specified file path.
 */
+(NSString*) textureNameFromFilePath: (NSString*) aFilePath;

/**
 * Returns a description formatted as a source-code line for loading this texture from a file.
 *
 * During development time, you can log this string, then copy and paste it into a pre-loading
 * function within your app code.
 */
-(NSString*) constructorDescription;


#pragma mark Texture cache

/** Removes this texture instance from the cache. */
-(void) remove;

/**
 * Adds the specified texture to the collection of loaded textures.
 *
 * Textures are accessible via their names through the getTextureNamed: method, and each
 * texture name should be unique. If a texture with the same name as the specified texture
 * already exists in this cache, an assertion error is raised.
 *
 * This cache is a weak cache, meaning that it does not hold strong references to the textures
 * that are added to it. As a result, the specified texture will automatically be deallocated
 * and removed from this cache once all external strong references to it have been released.
 */
+(void) addTexture: (CC3Texture*) texture;

/** Returns the texture with the specified name, or nil if a texture with that name has not been added. */
+(CC3Texture*) getTextureNamed: (NSString*) name;

/** Removes the specified texture from the texture cache. */
+(void) removeTexture: (CC3Texture*) texture;

/** Removes the texture with the specified name from the texture cache. */
+(void) removeTextureNamed: (NSString*) name;

/**
 * Removes from the cache all textures that are instances of any subclass of the receiver.
 *
 * You can use this method to selectively remove specific types of texturs, based on
 * the texture class, by invoking this method on that class. If you invoke this method
 * on the CC3Texture class, this cache will be compltely cleared. However, if you invoke
 * this method on one of its subclasses, only those textures that are instances of that
 * subclass (or one of its subclasses in turn) will be removed, leaving the remaining
 * textures in the cache.
 */
+(void) removeAllTextures;

/**
 * Returns whether textures are being pre-loaded.
 *
 * See the setIsPreloading setter method for a description of how and when to use this property.
 */
+(BOOL) isPreloading;

/**
 * Sets whether textures are being pre-loaded.
 *
 * Textures that are added to this cache while the value of this property is YES will be
 * strongly cached and cannot be deallocated until specifically removed from this cache.
 * You must manually remove any textures added to this cache while the value of this
 * property is YES.
 *
 * Textures that are added to this cache while the value of this property is NO will be
 * weakly cached, and will automatically be deallocated and removed from this cache once
 * all references to the resource outside this cache are released.
 *
 * You can set the value of this property at any time, and can vary it between YES and NO
 * to accomodate your specific loading patterns.
 *
 * The initial value of this property is NO, meaning that textures will be weakly cached
 * in this cache, and will automatically be removed if not used in the scene. You can set
 * this property to YES in order to pre-load textures that will not be immediately used
 * in the scene, but which you wish to keep in the cache for later use.
 */
+(void) setIsPreloading: (BOOL) isPreloading;

/**
 * Returns a description of the contents of this cache, with each entry formatted as a
 * source-code line for loading the texture from a file.
 *
 * During development time, you can log this string, then copy and paste it into a
 * pre-loading function within your app code.
 */
+(NSString*) cachedTexturesDescription;

@end


#pragma mark -
#pragma mark CC3Texture2D

/**
 * The representation of a 2D texture loaded into the GL engine.
 *
 * This class is used for all 2D texture types except PVR.
 *
 * This class is part of a class-cluster under the parent CC3Texture class. Although you can
 * invoke an instance creation method on this class directly, you will more commonly invoke
 * them on the CC3Texture class instead. The creation and initialization methods will ensure
 * that the correct subclass for the texture type, and in some cases, the texture file type,
 * is created and returned. Because of this class-cluster structure, be aware that the class
 * of the instance returned by an instance creation or initialization method may be different
 * than the receiver of that method.
 */
@interface CC3Texture2D : CC3Texture


#pragma mark Texture content and sizing

/**
 * Replaces a portion of the content of this texture by writing the specified array of pixels
 * into the specified rectangular area within this texture, The specified content replaces
 * the texture data within the specified rectangle. The specified content array must be large
 * enough to contain content for the number of pixels in the specified rectangle.
 *
 * Content is read from the specified array left to right across each row of pixels within
 * the specified image rectangle, starting at the row at the bottom of the rectangle, and
 * ending at the row at the top of the rectangle.
 *
 * Within the specified array, the pixel content should be packed tightly, with no gaps left
 * at the end of each row. The last pixel of one row should immediately be followed by the
 * first pixel of the next row.
 *
 * The pixels in the specified array are in standard 32-bit RGBA. If the pixelFormat and
 * pixelType properties of this texture are not GL_RGBA and GL_UNSIGNED_BYTE, respectively,
 * the pixels in the specified array will be converted to the format and type of this texture
 * before being inserted into the texture. Be aware that this conversion will reduce the
 * performance of this method. For maximum performance, match the format and type of this
 * texture to the 32-bit RGBA format of the specified array, by setting the pixelFormat
 * property to GL_RGBA and the pixelType property to GL_UNSIGNED_BYTE. However, keep in mind
 * that the 32-bit RGBA format consumes more memory than most other formats, so if performance
 * is of lesser concern, you may choose to minimize the memory requirements of this texture
 * by setting the pixelFormat and pixelType properties to values that consume less memory.
 *
 * If this texture has mipmaps, they are not automatically updated. Once all desired content
 * has been replaced, invoke the generateMipmap method to regenerate the mipmaps.
 */
-(void) replacePixels: (CC3Viewport) rect withContent: (ccColor4B*) colorArray;


#pragma mark Texture transformations

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * The initial value for 2D textures is YES, indicating that a 2D texture that has been loaded
 * in upsdide-down will be fipped the right way up.
 */
+(BOOL) defaultShouldFlipVerticallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * The initial value for 2D textures is YES, indicating that a 2D texture that has been loaded
 * in upsdide-down will be fipped the right way up.
 */
+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip;

/**
 * This class-side property determines the initial value of the shouldFlipHorizontallyOnLoad
 * for instances of this class. The initial value for 2D textures is NO.
 */
+(BOOL) defaultShouldFlipHorizontallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipHorizontallyOnLoad
 * for instances of this class. The initial value for 2D textures is NO.
 */
+(void) setDefaultShouldFlipHorizontallyOnLoad: (BOOL) shouldFlip;

@end


#pragma mark -
#pragma mark CC3TextureCube

/** 
 * The representation of a 3D cube-map texture loaded into the GL engine.
 *
 * This class is used for all cube-map texture types except PVR.
 *
 * This class is part of a class-cluster under the parent CC3Texture class. Although you can
 * invoke an instance creation method on this class directly, you will more commonly invoke
 * them on the CC3Texture class instead. The creation and initialization methods will ensure 
 * that the correct subclass for the texture type, and in some cases, the texture file type,
 * is created and returned. Because of this class-cluster structure, be aware that the class
 * of the instance returned by an instance creation or initialization method may be different
 * than the receiver of that method.
 */
@interface CC3TextureCube : CC3Texture


#pragma mark Texture file loading

/**
 * Loads the specified image into the specified cube face target.
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
 * This method does not automatically generate a mipmap. If you want a mipmap, you should
 * invoke the generateMipmap method once all six faces have been loaded.
 */
-(void) loadCubeFace: (GLenum) faceTarget fromCGImage: (CGImageRef) cgImg;

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


#pragma mark Texture content and sizing

/**
 * Replaces a portion of the content of this texture by writing the specified array of pixels
 * into the specified rectangular area within the specified face of this texture, The specified
 * content replaces the texture data within the specified rectangle. The specified content array
 * must be large enough to contain content for the number of pixels in the specified rectangle.
 *
 * The specified cube face target can be one of the following:
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_X
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_X
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
 *   - GL_TEXTURE_CUBE_MAP_POSITIVE_Z
 *   - GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
 *
 * Content is read from the specified array left to right across each row of pixels within
 * the specified image rectangle, starting at the row at the bottom of the rectangle, and
 * ending at the row at the top of the rectangle.
 *
 * Within the specified array, the pixel content should be packed tightly, with no gaps left
 * at the end of each row. The last pixel of one row should immediately be followed by the
 * first pixel of the next row.
 *
 * The pixels in the specified array are in standard 32-bit RGBA. If the pixelFormat and
 * pixelType properties of this texture are not GL_RGBA and GL_UNSIGNED_BYTE, respectively,
 * the pixels in the specified array will be converted to the format and type of this texture
 * before being inserted into the texture. Be aware that this conversion will reduce the
 * performance of this method. For maximum performance, match the format and type of this
 * texture to the 32-bit RGBA format of the specified array, by setting the pixelFormat
 * property to GL_RGBA and the pixelType property to GL_UNSIGNED_BYTE. However, keep in mind
 * that the 32-bit RGBA format consumes more memory than most other formats, so if performance
 * is of lesser concern, you may choose to minimize the memory requirements of this texture
 * by setting the pixelFormat and pixelType properties to values that consume less memory.
 *
 * If this texture has mipmaps, they are not automatically updated. Once all desired content
 * has been replaced, invoke the generateMipmap method to regenerate the mipmaps.
 */
-(void) replacePixels: (CC3Viewport) rect
		   inCubeFace: (GLenum) faceTarget
		  withContent: (ccColor4B*) colorArray;


#pragma mark Texture transformations

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * The initial value for cube-map textures is NO, indicating that a cube-map texture that
 * has been loaded in upsdide-down will be left upside-down. This is because cube-mapped
 * textures need to be stored in GL memory rotated by 180 degrees (flipped both vertically
 * and horizontally).
 */
+(BOOL) defaultShouldFlipVerticallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipVerticallyOnLoad
 * for instances of this class.
 *
 * The initial value for cube-map textures is NO, indicating that a cube-map texture that
 * has been loaded in upsdide-down will be left upside-down. This is because cube-mapped
 * textures need to be stored in GL memory rotated by 180 degrees (flipped both vertically
 * and horizontally).
 */
+(void) setDefaultShouldFlipVerticallyOnLoad: (BOOL) shouldFlip;

/**
 * This class-side property determines the initial value of the shouldFlipHorizontallyOnLoad
 * for instances of this class. 
 * 
 * The initial value for cube-map textures is YES, indicating that the texture will be flipped
 * horizontally. This is because cube-mapped textures need to be stored in GL memory rotated
 * by 180 degrees (flipped both vertically and horizontally).
 */
+(BOOL) defaultShouldFlipHorizontallyOnLoad;

/**
 * This class-side property determines the initial value of the shouldFlipHorizontallyOnLoad
 * for instances of this class.
 *
 * The initial value for cube-map textures is YES, indicating that the texture will be flipped
 * horizontally. This is because cube-mapped textures need to be stored in GL memory rotated
 * by 180 degrees (flipped both vertically and horizontally).
 */
+(void) setDefaultShouldFlipHorizontallyOnLoad: (BOOL) shouldFlip;

@end


#pragma mark -
#pragma mark CC3TextureUnitTexture

/**
 * CC3TextureUnitTexture is a specialized CC3Texture subclass that actually wraps another
 * texture instance and combines it with an instance of a texture unit to define additional
 * environmental configuration information about the use of the texture in multi-texturing
 * under fixed-pipeline rendering used by OpenGL ES 1.1 on iOS, or OpenGL on OSX without shaders.
 *
 * This class is generally not used for multi-texturing under programmable-pipeline rendering
 * used by OpenGL ES 2.0 on, or OpenGL on OSX with shaders, as you will generally handle
 * multitexturing in the shader code. However, it is possible to use an instance of this
 * class with a programmable-pipeline shader if your shader is designed to make use of the
 * texture unit configuration content. This can be used as a mechanism for supporting the
 * same multi-texturing configuration between both fixed and programmable pipelines.
 *
 * You instantiate an instance of CC3TextureUnitTexture directly, using any of the instance
 * creation or initializaton methods defined by the CC3Texture superclass. Or, if you already
 * have an instance of a CC3Texture, you can wrap it in an instance of CC3TextureUnitTexture
 * by using the textureWithTexture: or initWithTexture: creation and initialization methods
 * of this class.
 *
 * You can then create an instance of CC3TextureUnit, configure it appropriately, and set it
 * into the textureUnit property of your CC3TextureUnitTexture instance. By adding multiple
 * CC3TextureUnitTexture instances to your CC3Material, you can combine textures creatively.
 *
 * For example, to configure a material for bump-mapping, add a texture that contains a
 * normal vector at each pixel instead of a color, and set the textureUnit property of
 * the texture to a CC3BumpMapTextureUnit. Then add another texture, containing the image
 * that will be visible, to the material. The material will combine these two textures,
 * as specified by the CC3TextureUnit held by the second texture.
 */
@interface CC3TextureUnitTexture : CC3Texture {
	CC3Texture* _texture;
	CC3TextureUnit* _textureUnit;
}

/**
 * The CC3Texture texture being managed by this instance.
 *
 * This property is populated automatically during instance creation and loading.
 */
@property(nonatomic, retain, readonly) CC3Texture* texture;

/**
 * The texture environment settings that are applied to the texture unit that draws this
 * texture, when this texture participates in multi-texturing under fixed-pipeline rendering.
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


#pragma mark Allocation and Initialization

/**
 * Initializes this instance on the specified underlying texture.
 *
 * The name property of this instance will set to that of the specified texture.
 */
-(id) initWithTexture: (CC3Texture*) texture;

/**
 * Allocates and initializes an autoreleased instance on the specified underlying texture.
 *
 * The name property of this instance will set to that of the specified texture.
 */
+(id) textureWithTexture: (CC3Texture*) texture;

@end


#pragma mark -
#pragma mark CC3Texture2DContent

/**
 * A CCTexture subclass used by the CC3Texture class cluster during the loading of a 2D
 * texture, and when extracting a CCTexture from the CC3Texture ccTexture property.
 *
 * PVR texture files cannot be loaded using this class.
 */
@interface CC3Texture2DContent : CCTexture {
	const GLvoid* _imageData;
	GLenum _pixelGLFormat;
	GLenum _pixelGLType;
	BOOL _isUpsideDown : 1;
}

/** 
 * The texture ID used to identify this texture to the GL engine.
 *
 * This implementation allows this property to be set, in order to permit an instance
 * to be created from a CC3Texture.
 */
@property(nonatomic,readwrite) GLuint name;

/** Returns a pointer to the texture image data. */
@property(nonatomic, readonly) const GLvoid* imageData;

/**
 * Returns the GL engine pixel format of the texture.
 *
 * See the pixelFormat property of CC3Texture for the range of possible values.
 */
@property(nonatomic, readonly) GLenum pixelGLFormat;

/**
 * Returns the pixel data type.
 *
 * Possible values depend on the value of the pixelFormat property. See the pixelType
 * property of CC3Texture for the range of possible values.
 */
@property(nonatomic, readonly) GLenum pixelGLType;

/** 
 * Indicates whether this texture has an alpha channel, representing opacity.
 *
 * The value of this property is derived from the value of the pixelGLFomat property.
 */
@property(nonatomic, readonly) BOOL hasAlpha;

/** Returns the number of bytes in each pixel of content. */
@property(nonatomic, readonly) GLuint bytesPerPixel;

/**
 * Indicates whether this texture is upside-down.
 *
 * The vertical axis of the coordinate system of OpenGL is inverted relative to the CoreGraphics
 * view coordinate system. As a result, any texture content created from a CGImage will be upside
 * down. This includes texture content loaded from a file by an instance of this class.
 */
@property(nonatomic, readonly) BOOL isUpsideDown;


#pragma mark Transforming image in memory

/** 
 * Flips this texture vertically, to compensate for the opposite orientation
 * of vertical graphical coordinates between OpenGL and iOS & OSX.
 *
 * The value of the isUpsideDown property is toggled after flipping.
 */
-(void) flipVertically;

/** Flips this texture horizontally. */
-(void) flipHorizontally;

/**
 * Rotates the image by 180 degrees. 
 *
 * This is equivalent to combined vertical and horizontal flips, but is executed
 * in one pass for efficiency.
 *
 * The value of the isUpsideDown property is toggled after rotating.
 */
-(void) rotateHalfCircle;

/** 
 * Resizes this texture to the specified dimensions.
 *
 * This method changes the values of the size, width, height, maxS & maxT properties, 
 * but does not make any changes to the texture within the GL engine. This method is
 * invoked during the resizing of a texture that backs a surface.
 */
-(void) resizeTo: (CC3IntSize) size;

/**
 * Deletes the texture content from main memory. This should be invoked
 * once the texture is bound to the GL engine. 
 */
-(void) deleteImageData;


#pragma mark Allocation and Initialization

/**
 * Initializes this instance with content loaded from the specified file.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * Returns nil if the file could not be loaded.
 *
 * The value of the isUpsideDown is set to YES.
 */
-(id) initFromFile: (NSString*) aFilePath;

/** 
 * Initializes this instance from the content in the specified CGImage.
 *
 * The value of the isUpsideDown is set to YES.
 */
-(id) initWithCGImage: (CGImageRef) cgImg;

/** 
 * Initializes this instance to define the properties of a texture, without defining any
 * specific content.
 *
 * This instance can be used to initialize an empty CC3Texture, to which content can be added later.
 *
 * The value of the isUpsideDown is set to NO.
 */
-(id) initWithSize: (CC3IntSize) size andPixelFormat: (GLenum) format andPixelType: (GLenum) type;

/** Initializes this instance to represent the same GL texture as the specified CC3Texture. */
-(id) initFromCC3Texture: (CC3Texture*) texture;

/** Allocates and initializes an instance to represent the same GL texture as the specified CC3Texture. */
+(id) textureFromCC3Texture: (CC3Texture*) texture;

@end

// Macros for legacy references to removed classes and methods
#define CC3GLTexture			CC3Texture
#define CC3GLTexture2D			CC3Texture2D
#define CC3GLTextureCube		CC3TextureCube
#define CC3PVRGLTexture			CC3PVRTexture
#define addGLTexture			addTexture
#define getGLTextureNamed		getTextureNamed
#define removeGLTexture			removeTexture

