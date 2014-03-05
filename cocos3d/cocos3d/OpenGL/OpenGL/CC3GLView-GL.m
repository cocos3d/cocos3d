/*
 * CC3GLView-GL.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3GLView-GL.h for full API documentation.
 */

#import "CC3GLView-GL.h"
#import "CC3Logging.h"

#if CC3_OGL

#pragma mark -
#pragma mark CC3GLView

@implementation CC3GLView

@synthesize surfaceManager=_surfaceManager;
@synthesize colorFormat=_colorFormat, depthFormat=_depthFormat;

-(void) dealloc {
	[_surfaceManager release];
	[super dealloc];
}

-(GLuint) requestedSamples { return 1; }

-(GLuint) pixelSamples { return _surfaceManager.pixelSamples; }

-(CC3GLContext*) context { return (CC3GLContext*)self.openGLContext; }

-(void) prepareOpenGL {
	[super prepareOpenGL];
	
	GLint screenIdx = 0;
	GLint colorSize;
	GLint alphaSize;
	GLint depthSize;
	GLint stencilSize;
	
	NSOpenGLPixelFormat* pixFmt = self.pixelFormat;
	[pixFmt getValues: &colorSize forAttribute:NSOpenGLPFAColorSize forVirtualScreen: screenIdx];
	[pixFmt getValues: &alphaSize forAttribute:NSOpenGLPFAAlphaSize forVirtualScreen: screenIdx];
	[pixFmt getValues: &depthSize forAttribute:NSOpenGLPFADepthSize forVirtualScreen: screenIdx];
	[pixFmt getValues: &stencilSize forAttribute:NSOpenGLPFAStencilSize forVirtualScreen: screenIdx];

	_colorFormat = CC3GLColorFormatFromBitPlanes(colorSize, alphaSize);
	_depthFormat = CC3GLDepthFormatFromBitPlanes(depthSize, stencilSize);
	
	CC3OpenGL.sharedGL.context = self.context;	// Set the primary GL context from this view
	
	_surfaceManager = [[CC3GLViewSurfaceManager alloc] initWithView: self];		// retained
}

-(void) reshape {
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	
	[self lockOpenGLContext];
	
	CC3IntSize size = CC3IntSizeFromCGSize(NSSizeToCGSize(self.bounds.size));
	[_surfaceManager resizeTo: size];
	
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection: CGSizeFromCC3IntSize(size)];
	[director drawScene];	// avoid flicker
	
	[self unlockOpenGLContext];
}

-(void) addGestureRecognizer: (UIGestureRecognizer*) gesture {}

-(void) removeGestureRecognizer: (UIGestureRecognizer*) gesture {}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

@end

GLenum CC3GLColorFormatFromBitPlanes(GLint colorCount, GLint alphaCount) {
	LogTrace(@"Color buffer size: %i, alpha size: %i", colorCount, alphaCount);
	switch (alphaCount) {
		case 0:
			switch (colorCount) {
				case 12: return GL_RGB4;
				case 15: return GL_RGB5;
				case 24: return GL_RGB8;
				case 48: return GL_RGB16;
			}
		case 1:
			if (colorCount == 16) return GL_RGB5_A1;
		case 2:
			if (colorCount == 8) return GL_RGBA2;
			if (colorCount == 32) return GL_RGB10_A2;
		case 4:
			if (colorCount == 16) return GL_RGBA4;
		case 8:
			if (colorCount == 32) return GL_RGBA8;
		case 12:
			if (colorCount == 48) return GL_RGBA12;
		case 16:
			if (colorCount == 64) return GL_RGBA16;
	}
	CC3AssertC(NO, @"Unrecognized color buffer bit plane combination: color %i, alpha: %i", colorCount, alphaCount);
	return GL_ZERO;
}

GLenum CC3GLDepthFormatFromBitPlanes(GLint depthCount, GLint stencilCount) {
	LogTrace(@"Depth buffer size: %i, stencil size: %i", depthCount, stencilCount);

	if (depthCount && stencilCount) return GL_DEPTH24_STENCIL8;

	switch (depthCount) {
		case 0: return GL_ZERO;
		case 16: return GL_DEPTH_COMPONENT16;
		case 24: return GL_DEPTH_COMPONENT24;
		case 32: return GL_DEPTH_COMPONENT32;
	}
	CC3AssertC(NO, @"Unrecognized depth buffer bit plane combination: depth %i, stencil: %i", depthCount, stencilCount);
	return GL_ZERO;
}

#endif	// CC3_OGL
