/*
 * CC3OpenGLES2.m
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
 *
 * See header file CC3OpenGLES2.h for full API documentation.
 */

#import "CC3OpenGLES2.h"

#if CC3_OGLES_2

@interface CC3OpenGL (TemplateMethods)
-(void) initPlatformLimits;
@end

@implementation CC3OpenGLES2


#pragma mark Textures

-(void) disableTexturingFrom: (GLuint) startTexUnitIdx {
	GLuint maxTexUnits = value_MaxTextureUnitsUsed;
	for (GLuint tuIdx = startTexUnitIdx; tuIdx < maxTexUnits; tuIdx++) {
		[self bindTexture: 0 toTarget: GL_TEXTURE_2D at: tuIdx];
		[self bindTexture: 0 toTarget: GL_TEXTURE_CUBE_MAP at: tuIdx];
	}
}


#pragma mark Allocation and initialization

-(void) initPlatformLimits {
	[super initPlatformLimits];

	glGetIntegerv(GL_MAX_SAMPLES_APPLE, &value_GL_MAX_SAMPLES);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_SAMPLES_APPLE), value_GL_MAX_SAMPLES);
	LogInfo(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
}

@end

#endif	// CC3_OGLES_2