/*
 * CC3OpenGLESPlatform.h
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

#import "CC3OpenGLESStateTracker.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerPlatformInteger

/**
 * CC3OpenGLESStateTrackerMaterialFloat tracks a float GL state value for platform limits.
 *
 * This is a read-only value. This implementation uses GL function glGetIntegerv to read
 * the value from the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnce, which
 * will cause the state to be automatically read once, on the first invocation of the
 * open method, and the value will never be automatically restored.
 */
@interface CC3OpenGLESStateTrackerPlatformInteger : CC3OpenGLESStateTrackerInteger {}
@end


#pragma mark -
#pragma mark CC3OpenGLESPlatform

/**
 * CC3OpenGLESPlatform manages trackers that read and remember platform characteristics,
 * capabilities and limits. None of the platform trackers attempt to update any values.
 */
@interface CC3OpenGLESPlatform : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerPlatformInteger* _maxLights;
	CC3OpenGLESStateTrackerPlatformInteger* _maxClipPlanes;
	CC3OpenGLESStateTrackerPlatformInteger* _maxPaletteMatrices;
	CC3OpenGLESStateTrackerPlatformInteger* _maxTextureUnits;
	CC3OpenGLESStateTrackerPlatformInteger* _maxVertexAttributes;
	CC3OpenGLESStateTrackerPlatformInteger* _maxVertexUnits;
	CC3OpenGLESStateTrackerPlatformInteger* _maxPixelSamples;
}

/** Reads the number of lights available, through GL parameter GL_MAX_LIGHTS. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxLights;

/** Reads the number of clip planes available, through GL parameter GL_MAX_CLIP_PLANES. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxClipPlanes;

/** Reads the number of palette matrices available, through GL parameter GL_MAX_PALETTE_MATRICES_OES. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxPaletteMatrices;

/** Reads the number of texture units available, through GL parameter GL_MAX_TEXTURE_UNITS. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxTextureUnits;

/** Reads the number of OpenGL ES 2 vertex attributes available, through GL parameter GL_MAX_VERTEX_ATTRIBS. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxVertexAttributes;

/** Reads the number of vertex units available, through GL parameter GL_MAX_VERTEX_UNITS_OES. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxVertexUnits;

/** Reads the number of vertex units available, through GL parameter GL_MAX_SAMPLES_APPLE. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerPlatformInteger* maxPixelSamples;

@end
