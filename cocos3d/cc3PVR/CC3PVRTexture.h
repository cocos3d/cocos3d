/*
 * CC3PVRTexture.h
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


#import "CC3Texture.h"
#import "CCTexturePVR.h"


#pragma mark -
#pragma mark CC3PVRTexture

/** 
 * The representation of a PVR texture that has been loaded into the GL engine.
 *
 * This class is used for all 2D and cube-map textures loaded from a PVR file type.
 *
 * This class is part of a class-cluster under the parent CC3Texture class. Although you can
 * invoke an instance creation method on this class directly, you will more commonly invoke
 * them on the CC3Texture class instead. The creation and initialization methods will ensure
 * that the correct subclass for the texture type, and in some cases, the texture file type,
 * is created and returned. Because of this class-cluster structure, be aware that the class
 * of the instance returned by an instance creation or initialization method may be different
 * than the receiver of that method.
 */
@interface CC3PVRTexture : CC3Texture {
	BOOL _isTextureCube : 1;
}

/**
 * PVR textures cannot be flipped after loading. This property is overridden so
 * that changes are ignored, and to always return NO.
 */
@property(nonatomic, assign) BOOL shouldFlipVerticallyOnLoad;

/**
 * PVR textures cannot be flipped after loading. This property is overridden so
 * that changes are ignored, and to always return NO.
 */
@property(nonatomic, assign) BOOL shouldFlipHorizontallyOnLoad;

@end


#pragma mark -
#pragma mark CC3PVRTextureContent

/**
 * A helper class used by the CC3PVRTexture class cluster during the loading of a
 * texture from a PVR file using the PowerVR library.
 */
@interface CC3PVRTextureContent : NSObject {
	GLuint _textureID;
	CC3IntSize _size;
	GLenum _pixelFormat;
	GLenum _pixelType;
	BOOL _hasMipmap : 1;
	BOOL _isTextureCube : 1;
	BOOL _hasPremultipliedAlpha : 1;
}

/** The texture ID used to identify this texture to the GL engine. */
@property(nonatomic, readonly) GLuint textureID;

/** The size of this texture in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/**
 * Returns the pixel format of the texture.
 *
 * See the pixelFormat property of CC3Texture for the range of possible values.
 */
@property(nonatomic, readonly) GLenum pixelFormat;

/**
 * Returns the pixel data type.
 *
 * Possible values depend on the value of the pixelFormat property. See the pixelType
 * property of CC3Texture for the range of possible values.
 */
@property(nonatomic, readonly) GLenum pixelType;

/** Returns whether this texture contains a mipmap. */
@property(nonatomic, readonly) BOOL hasMipmap;

/** 
 * Returns whether the alpha channel of this texture has already been multiplied
 * into each of the RGB color channels.
 */
@property(nonatomic, readonly) BOOL hasPremultipliedAlpha;

/** Returns whether this texture is a standard two-dimentional texture. */
@property(nonatomic, readonly) BOOL isTexture2D;

/** Returns whether this texture is a six-sided cube-map texture. */
@property(nonatomic, readonly) BOOL isTextureCube;


#pragma mark Allocation and Initialization

/**
 * Initializes this instance by loaded content from the specified PVR file.
 *
 * The specified file path may be either an absolute path, or a path relative to the
 * application resource directory. If the file is located directly in the application
 * resources directory, the specified file path can simply be the name of the file.
 *
 * Returns nil if the file could not be loaded.
 */
-(id) initFromFile: (NSString*) aFilePath;

@end
