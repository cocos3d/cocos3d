/*
 * CC3OpenGLES2Materials.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLESMaterials.h for full API documentation.
 */

#import "CC3OpenGLES2Materials.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2StateTrackerMaterialBlend

@implementation CC3OpenGLES2StateTrackerMaterialBlend

-(void) initializeTrackers {
	self.sourceBlend = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_BLEND_SRC_RGB];
	self.destinationBlend = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																		 forState: GL_BLEND_DST_RGB];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2Materials

@implementation CC3OpenGLES2Materials

-(void) initializeTrackers {
	self.ambientColor = nil;
	self.diffuseColor = nil;
	self.specularColor = nil;
	self.emissionColor = nil;
	self.shininess = nil;
	self.alphaFunc = nil;
	
	self.blendFunc = [CC3OpenGLES2StateTrackerMaterialBlend trackerWithParent: self];
}

@end

#endif
