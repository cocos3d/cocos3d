/*
 * CC3OpenGLES11Platform.h
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

#import "CC3OpenGLES11StateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPlatformInteger

/**
 * CC3OpenGLES11StateTrackerMaterialFloat tracks a float GL state value for platform limits.
 *
 * This is a read-only value. This implementation uses GL function glGetIntegerv to read
 * the value from the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnce, which
 * will cause the state to be automatically read once, on the first invocation of the
 * open method, and the value will never be automatically restored.
 */
@interface CC3OpenGLES11StateTrackerPlatformInteger : CC3OpenGLES11StateTrackerInteger {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11Platform

/**
 * CC3OpenGLES11Platform manages trackers that read and remember platform characteristics,
 * capabilities and limits. None of the platform trackers attempt to update any values.
 */
@interface CC3OpenGLES11Platform : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerPlatformInteger* maxLights;
	CC3OpenGLES11StateTrackerPlatformInteger* maxClipPlanes;
	CC3OpenGLES11StateTrackerPlatformInteger* maxPaletteMatrices;
	CC3OpenGLES11StateTrackerPlatformInteger* maxTextureUnits;
	CC3OpenGLES11StateTrackerPlatformInteger* maxVertexUnits;
	CC3OpenGLES11StateTrackerPlatformInteger* maxPixelSamples;
}

/** Reads the number of lights available, through GL parameter GL_MAX_LIGHTS. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPlatformInteger* maxLights;

/** Reads the number of clip planes available, through GL parameter GL_MAX_CLIP_PLANES. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPlatformInteger* maxClipPlanes;

/** Reads the number of palette matrices available, through GL parameter GL_MAX_PALETTE_MATRICES_OES. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPlatformInteger* maxPaletteMatrices;

/** Reads the number of texture units available, through GL parameter GL_MAX_TEXTURE_UNITS. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPlatformInteger* maxTextureUnits;

/** Reads the number of vertex units available, through GL parameter GL_MAX_VERTEX_UNITS_OES. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPlatformInteger* maxVertexUnits;

/** Reads the number of vertex units available, through GL parameter GL_MAX_SAMPLES_APPLE. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerPlatformInteger* maxPixelSamples;

@end
