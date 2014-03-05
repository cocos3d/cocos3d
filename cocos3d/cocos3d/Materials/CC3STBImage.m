/*
 * CC3STBImage.m
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
 * 
 * See header file CC3STBImage.h for full API documentation.
 */

#import "CC3STBImage.h"

// STBI Image loading library - define STBI_HEADER_FILE_ONLY to include .c as a header file
#define STBI_HEADER_FILE_ONLY
#import "stb_image.c"


#pragma mark -
#pragma mark CC3STBImage

@implementation CC3STBImage

@synthesize imageData=_imageData;
@synthesize size=_size;
@synthesize componentCount=_componentCount;

-(void) dealloc {
	[self deleteImageData];
	[super dealloc];
}

-(void) deleteImageData {
	stbi_image_free(_imageData);
	_imageData = NULL;
}

-(GLubyte*) extractImageData {
	GLubyte* imgData = _imageData;
	_imageData = NULL;
	return imgData;
}

-(GLenum) pixelFormat {
	switch (_componentCount) {
		case 4:		return GL_RGBA;
		case 3:		return GL_RGB;
		case 2:		return GL_LUMINANCE_ALPHA;
		case 1:		return GL_LUMINANCE;
		default:	return GL_ZERO;
	}
}

-(GLenum) pixelType { return GL_UNSIGNED_BYTE; }


#pragma mark File loading

-(BOOL) loadFromFile: (NSString*) aFilePath {

	[self deleteImageData];		// Delete any existing image data first.
	
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	_imageData = stbi_load(absFilePath.UTF8String,
						   (int*)&_size.width,
						   (int*)&_size.height,
						   (int*)&_componentCount, 0);
	if (!_imageData) {
		LogError(@"Could not load image file %@ using STBI library because: %@",
				 absFilePath, [NSString stringWithUTF8String: stbi_failure_reason()]);
		return NO;
	}
	return YES;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_imageData = NULL;
		_size = kCC3IntSizeZero;
		_componentCount = 0;
	}
	return self;
}

-(id) initFromFile: (NSString*) aFilePath {
	if ( (self = [self init]) ) {
		if ( ![self loadFromFile: aFilePath] ) return nil;
	}
	return self;
}

+(id) imageFromFile: (NSString*) aFilePath { return [[[self alloc] initFromFile: aFilePath] autorelease]; }


#pragma mark File types

static NSMutableSet* _useForFileExtensions = nil;

+(NSMutableSet*) useForFileExtensions {
	if (!_useForFileExtensions) {
		_useForFileExtensions = [[NSMutableSet setWithObjects: @"ppng", @"pjpg", @"ptga", @"pbmp",
															   @"ppsd", @"pgif", @"phdr", @"ppic", nil] retain];
	}
	return _useForFileExtensions;
}

+(BOOL) shouldUseForFileExtension: (NSString*) fileExtension {
	return [[self useForFileExtensions] containsObject: [fileExtension lowercaseString]];
}

@end
