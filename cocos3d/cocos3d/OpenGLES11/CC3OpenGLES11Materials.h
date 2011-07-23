/*
 * CC3OpenGLES11Materials.h
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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
#pragma mark CC3OpenGLES11StateTrackerMaterialColor

/**
 * CC3OpenGLES11StateTrackerMaterialColor tracks a color GL state value for materials.
 *
 * This implementation uses GL function glGetMaterialfv to read the value from the
 * GL engine, and GL function glMaterialfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 *
 */
@interface CC3OpenGLES11StateTrackerMaterialColor : CC3OpenGLES11StateTrackerColor {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerMaterialFloat

/**
 * CC3OpenGLES11StateTrackerMaterialFloat tracks a float GL state value for materials.
 *
 * This implementation uses GL function glGetMaterialfv to read the value from the
 * GL engine, and GL function glMaterialf to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerMaterialFloat : CC3OpenGLES11StateTrackerFloat {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerMaterialBlend

/**
 * CC3OpenGLES11StateTrackerMaterialBlend is a type of CC3OpenGLES11StateTrackerComposite
 * that tracks the source and destination blending GL state values for materials.
 *
 * The blending values are read from GL individually, using distinct primitive trackers
 * for each of the source and destination blend values. Both blending values are set
 * into the GL engine together using a single call to the GL set function glBlendFunc.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerMaterialBlend : CC3OpenGLES11StateTrackerComposite {
	CC3OpenGLES11StateTrackerEnumeration* sourceBlend;
	CC3OpenGLES11StateTrackerEnumeration* destinationBlend;
}

/** Tracks source blend (GL get name GL_BLEND_SRC) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* sourceBlend;

/** Tracks destination blend (GL get name GL_BLEND_DST) */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerEnumeration* destinationBlend;

/**
 * Sets the source and destination blend values together. The values will be
 * set in the GL engine only if at least one of the values has actually changed.
 *
 * Uses the GL set function glBlendFunc to set the values in the GL engine.
 */
-(void) applySource: (GLenum) srcBlend andDestination: (GLenum) dstBlend;

@end


#pragma mark -
#pragma mark CC3OpenGLES11Materials

/** CC3OpenGLES11Materials manages trackers for materials state. */
@interface CC3OpenGLES11Materials : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerMaterialColor* ambientColor;
	CC3OpenGLES11StateTrackerMaterialColor* diffuseColor;
	CC3OpenGLES11StateTrackerMaterialColor* specularColor;
	CC3OpenGLES11StateTrackerMaterialColor* emissionColor;
	CC3OpenGLES11StateTrackerMaterialFloat* shininess;
	CC3OpenGLES11StateTrackerMaterialBlend* blend;
}

/** Tracks ambient color (GL name GL_AMBIENT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerMaterialColor* ambientColor;

/** Tracks diffuse color (GL name GL_DIFFUSE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerMaterialColor* diffuseColor;

/** Tracks specular color (GL name GL_SPECULAR). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerMaterialColor* specularColor;

/** Tracks emission color (GL name GL_EMISSION). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerMaterialColor* emissionColor;

/** Tracks shininess (GL name GL_SHININESS). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerMaterialFloat* shininess;

/** Tracks both the source and destination blend functions together. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerMaterialBlend* blend;

@end
