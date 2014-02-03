/*
 * CC3STBImage.h
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


#import "CC3Foundation.h"
#import "CC3OpenGLFoundation.h"


#pragma mark -
#pragma mark CC3STBImage

/**
 * CC3STBImage represents an image file loaded using the STBImage library.
 *
 * This class can be used to bypass the OS image loaders. When building for iOS, raw PNG
 * and TGA images are pre-processed by Xcode to pre-multiply alpha, and to reorder the pixel
 * component byte order, to optimize the image for the iOS platform.
 *
 * However, these changes are not compatible with images that are not used strictly for
 * standard texture blending, including textures used as normal maps, or textures whose
 * components contain data unrelated to blending.
 *
 * This class can be use to load the following file types:
 *   - JPEG baseline (no JPEG progressive)
 *   - PNG 8-bit-per-channel only
 *   - TGA (not sure what subset, if a subset)
 *   - BMP non-1bpp, non-RLE
 *   - PSD (composited view only, no extra channels)
 *   - GIF (*comp always reports as 4-channel)
 *   - HDR (radiance rgbE format)
 *   - PIC (Softimage PIC)
 *
 * Note that most file types contain certain restrictions on content. This class is not
 * designed to be a general, all purpose image loader, but rather, is designed to handle
 * most common cases where the file content can be controlled during image creation.
 *
 * The set returned by the class-side useForFileExtensions property can be used to determine
 * which file-type extensions will be loaded using this class. The remaining file types will
 * be loaded using the standard OS image file loaders. See the notes for that property for
 * the default list of file extensions that will be loaded using this class.
 */
@interface CC3STBImage : NSObject {
	GLubyte* _imageData;
	CC3IntSize _size;
	GLuint _componentCount;
}

/** 
 * Returns a pointer to the pixel image data, without reliquishing ownership of the memory
 * referenced by the returned pointer.
 *
 * When this instance is deallocated, it will free the memory referenced by the returned
 * pointer. To claim ownership of the memory, invoke the extractImageData method instead.
 */
@property(nonatomic, readonly) GLubyte* imageData;

/** 
 * Returns a pointer to the pixel image data, and sets the imageData property to NULL.
 *
 * This effectively surrenders ownership of the pixel memory to the invoking object.
 * Subsequent invocations of the imageData property, or this method will return NULL,
 * and this instance will not attempt to free the memory referenced by the returned
 * pointer when this instance is deallocated.
 */
-(GLubyte*) extractImageData;

/** Returns the size of this texture in pixels. */
@property(nonatomic, readonly) CC3IntSize size;

/** Returns the number of color components per pixel. */
@property(nonatomic, readonly) GLuint componentCount;

/**
 * Returns the pixel format of the texture.
 *
 * The returned value may be one of the following:
 *   - GL_RGBA
 *   - GL_RGB
 *   - GL_LUMINANCE_ALPHA
 *   - GL_LUMINANCE
 */
@property(nonatomic, readonly) GLenum pixelFormat;

/** Returns the pixel data type. Always returns GL_UNSIGNED_BYTE.  */
@property(nonatomic, readonly) GLenum pixelType;


#pragma mark File loading

/** Loads the specified file, and returns whether the file was successfully loaded. */
-(BOOL) loadFromFile: (NSString*) aFilePath;


#pragma mark Allocation and initialization

/** Initializes this instance by loading the image file at the specified file path. */
-(id) initFromFile: (NSString*) aFilePath;

/** Allocates and initializes an instance by loading the image file at the specified file path. */
+(id) imageFromFile: (NSString*) aFilePath;


#pragma mark File types

/**
 * Returns a list of file extensions that will be loaded using this class.
 *
 * You can retrieve and modify this list directly in order to change the file extensions that will
 * be loaded using this class. File extensions added to this list should be completely lowercase.
 *
 * The shouldUseForFileExtension: method is used to compare a specific file extension agains this list.
 *
 * By default, special extensions are used, but you can add a primary extension, such as @"png",
 * to have ALL PNG files loaded using this library, if that suits your purposes. However, keep
 * in mind that Xcode performs a pre-processing optimization on known PNG and TGA files, so 
 * loading them as such may produce unexpected results.
 *
 * Initially, this list contains:
 *   - @"ppng"
 *   - @"pjpg"
 *   - @"ptga"
 *   - @"pbmp"
 *   - @"ppsd"
 *   - @"pgif"
 *   - @"phdr"
 *   - @"ppic"
 *
 * The 'p' prefix is a reference to the use of this class to load "pure", or "proper" files 
 * that have not been pre-processed by Xcode. The use of a modified file extension ensures 
 * that Xcode will not pre-process them.
 */
+(NSMutableSet*) useForFileExtensions;

/**
 * Returns whether this class should be used to load a file with the specified file extension,
 * by comparing it to the list of file extensions defined in the useForFileExtensions property.
 
 * The case of the specified file extension does not matter. It is converted to a lowercase
 * string before being compared against the file extensions in the useForFileExtensions property
 */
+(BOOL) shouldUseForFileExtension: (NSString*) fileExtension;

@end
