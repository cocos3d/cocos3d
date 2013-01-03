/*
 * CC3OpenGLESMaterials.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
#pragma mark CC3OpenGLESStateTrackerMaterialBlend

/**
 * CC3OpenGLESStateTrackerMaterialBlend is a type of CC3OpenGLESStateTrackerComposite
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
@interface CC3OpenGLESStateTrackerMaterialBlend : CC3OpenGLESStateTrackerComposite {
	CC3OpenGLESStateTrackerEnumeration* sourceBlend;
	CC3OpenGLESStateTrackerEnumeration* destinationBlend;
}

/** Tracks source blend (GL get name GL_BLEND_SRC) */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* sourceBlend;

/** Tracks destination blend (GL get name GL_BLEND_DST) */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* destinationBlend;

/**
 * Sets the source and destination blend values together. The values will be
 * set in the GL engine only if at least one of the values has actually changed.
 *
 * Uses the GL set function glBlendFunc to set the values in the GL engine.
 */
-(void) applySource: (GLenum) srcBlend andDestination: (GLenum) dstBlend;

@end

#pragma mark -
#pragma mark CC3OpenGLESStateTrackerAlphaFunction

/**
 * CC3OpenGLESStateTrackerAlphaFunction is a type of CC3OpenGLESStateTrackerComposite
 * that tracks the alpha test function and reference GL state values for materials.
 *
 * The function and reference values are read from GL individually, using distinct 
 * primitive trackers for each of the function and reference values. Both values are set
 * into the GL engine together using a single call to the GL set function glAlphaFunc.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerAlphaFunction : CC3OpenGLESStateTrackerComposite {
	CC3OpenGLESStateTrackerEnumeration* function;
	CC3OpenGLESStateTrackerFloat* reference;
}

/** Tracks the alpha test function (GL get name GL_ALPHA_TEST_FUNC) */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* function;

/** Tracks the alpha test reference value (GL get name GL_ALPHA_TEST_REF) */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFloat* reference;

/**
 * Sets the alpha test function and reference values together. The values will be
 * set in the GL engine only if at least one of the values has actually changed.
 *
 * Uses the GL set function glAlphaFunc to set the values in the GL engine.
 */
-(void) applyFunction: (GLenum) func andReference: (GLfloat) refValue;

@end


#pragma mark -
#pragma mark CC3OpenGLESMaterials

/** CC3OpenGLESMaterials manages trackers for materials state. */
@interface CC3OpenGLESMaterials : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerColor* ambientColor;
	CC3OpenGLESStateTrackerColor* diffuseColor;
	CC3OpenGLESStateTrackerColor* specularColor;
	CC3OpenGLESStateTrackerColor* emissionColor;
	CC3OpenGLESStateTrackerFloat* shininess;
	CC3OpenGLESStateTrackerAlphaFunction* alphaFunc;
	CC3OpenGLESStateTrackerMaterialBlend* blendFunc;
}

/** Tracks ambient color (GL name GL_AMBIENT). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerColor* ambientColor;

/** Tracks diffuse color (GL name GL_DIFFUSE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerColor* diffuseColor;

/** Tracks specular color (GL name GL_SPECULAR). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerColor* specularColor;

/** Tracks emission color (GL name GL_EMISSION). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerColor* emissionColor;

/** Tracks shininess (GL name GL_SHININESS). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerFloat* shininess;

/** Tracks alpha test function and reference value together. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerAlphaFunction* alphaFunc;

/** Tracks both the source and destination blend functions together. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerMaterialBlend* blendFunc;

@end
