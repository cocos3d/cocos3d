/*
 * CC3PVRTexture.mm
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
 * 
 * See header file CC3PVRGLTexture.h for full API documentation.
 */

#import "CC3PVRGLTexture.h"
#import "CC3PVRTTexture.h"


#pragma mark -
#pragma mark CC3PVRGLTexture

@interface CC3GLTexture (TemplateMethods)
-(void) deleteGLTexture;
@end

@implementation CC3PVRGLTexture

@synthesize isTextureCube=_isTextureCube;

-(BOOL) isTexture2D { return !self.isTextureCube; }

-(GLenum) textureTarget { return self.isTextureCube ? GL_TEXTURE_CUBE_MAP : GL_TEXTURE_2D; }

-(Class) textureContentClass { return CC3PVRTextureContent.class; }

-(void) bindTextureContent: (CC3PVRTextureContent*) texContent toTarget: (GLenum) target {
	if (!texContent) return;
	
	[self deleteGLTexture];		// Delete any existing texture in the GL engine
	
	_textureID = texContent.textureID;
	_size = texContent.size;
	_hasMipmap = texContent.hasMipmap;
	_hasPremultipliedAlpha = texContent.hasPremultipliedAlpha;
	_isTextureCube = texContent.isTextureCube;
	_coverage = CGSizeMake(1.0, 1.0);				// PVR textures are always POT
	_isFlippedVertically = NO;						// PVR textures are not flipped
	
	LogTrace(@"Bound PVR texture ID %u", _textureID);
	
	// Update the texture parameters depending on whether the PVR file is 2D or cube-map.
	self.textureParameters = self.isTextureCube
								? [CC3GLTextureCube class].defaultTextureParameters
								: [CC3GLTexture2D class].defaultTextureParameters;
	
	if (self.class.shouldGenerateMipmaps) [self generateMipmap];
}

@end


#pragma mark -
#pragma mark CC3PVRTextureContent

@implementation CC3PVRTextureContent

@synthesize textureID=_textureID, size=_size, isTextureCube=_isTextureCube;
@synthesize hasMipmap=_hasMipmap, hasPremultipliedAlpha=_hasPremultipliedAlpha;

-(BOOL) isTexture2D { return !self.isTextureCube; }


#pragma mark Allocation and Initialization

#if CC3_IOS

-(id) initFromFile: (NSString*) aFilePath {
	if ( (self = [super init]) ) {
		
		// Split the path into directory and file names, sset the PVR read path
		// to the directory and pass the unqualified file name to the parser.
		NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
		NSString* fileName = absFilePath.lastPathComponent;
		NSString* dirName = absFilePath.stringByDeletingLastPathComponent;
		
		CPVRTResourceFile::SetReadPath([dirName stringByAppendingString: @"/"].UTF8String);
		
		PVRTextureHeaderV3 pvrHeader;
		BOOL wasLoaded = PVRTTextureLoadFromPVR(fileName.UTF8String,
												&_textureID,
												&pvrHeader) == PVR_SUCCESS;
		if ( !wasLoaded ) {
			LogError(@"Could not load texture %@.", absFilePath);
			[self release];
			return nil;
		}
		
		_size = CC3IntSizeMake(pvrHeader.u32Width, pvrHeader.u32Height);
		_hasMipmap = (pvrHeader.u32MIPMapCount > 1);
		_isTextureCube = (pvrHeader.u32NumFaces > 1);
		_hasPremultipliedAlpha = ((pvrHeader.u32Flags & PVRTEX3_PREMULTIPLIED) != 0);
	}
	return self;
}

#else

-(id) initFromFile: (NSString*) aFilePath {
	LogError(@"Could not load texture %@ because PVR files are not supported on this platform.", aFilePath);
	[self release];
	return nil;
}

#endif	// CC3_IOS

@end


#pragma mark -
#pragma mark CC3PVRTextureContentCC

@implementation CC3PVRTextureContentCC

-(NSUInteger) numberOfMipmaps {
#if CC3_CC2_1
	return numberOfMipmaps_;
#else
	return super.numberOfMipmaps;
#endif
}

#pragma mark Allocation and Initialization

/** Init from superclass loading method, and allow the texture ID to be managed externally. */
-(id) initFromFile: (NSString*) aFilePath {
	if ( (self = [self initWithContentsOfFile: CC3EnsureAbsoluteFilePath(aFilePath)]) ) {
		self.retainName = YES;
	}
	return self;
}

@end
