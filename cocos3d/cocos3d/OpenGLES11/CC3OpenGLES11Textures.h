/*
 * CC3OpenGLES11Textures.h
 *
 * cocos3d 0.5.4
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


#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureBinding

/**
 * CC3OpenGLES11StateTrackerTextureBinding tracks an integer GL state value for
 * texture binding.
 *
 * This implementation uses the GL function glBindTexture to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerTextureBinding : CC3OpenGLES11StateTrackerInteger {}

/** Unbinds all textures by setting the value property to zero. */
-(void) unbind;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerActiveTexture

/**
 * CC3OpenGLES11StateTrackerActiveTexture tracks an enumerated GL state value for
 * identifying the active texture.
 *
 * The active texture value can be between zero and the number of available texture
 * channels minus one, inclusive.
 *
 * The number of available texture channels can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxTextureChannels.value.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerActiveTexture : CC3OpenGLES11StateTrackerEnumeration {}

/** The GL enumeration value GL_TEXTUREi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glEnumValue;

@end


#pragma mark -
#pragma mark CC3OpenGLES11Textures

/** CC3OpenGLES11Textures manages trackers for texture state. */
@interface CC3OpenGLES11Textures : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerActiveTexture* activeTexture;
	CC3OpenGLES11StateTrackerActiveTexture* clientActiveTexture;
	CC3OpenGLES11StateTrackerTextureBinding* textureBinding;
}

/** Tracks active texture (GL get name GL_ACTIVE_TEXTURE and set function glActiveTexture). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerActiveTexture* activeTexture;

/** Tracks active client texture (GL get name GL_CLIENT_ACTIVE_TEXTURE and set function glClientActiveTexture). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerActiveTexture* clientActiveTexture;

/** Tracks texture binding (GL get name GL_TEXTURE_BINDING_2D and set function glBindTexture). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTextureBinding* textureBinding;

@end
