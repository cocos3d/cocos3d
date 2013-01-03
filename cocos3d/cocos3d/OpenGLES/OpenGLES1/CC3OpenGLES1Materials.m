/*
 * CC3OpenGLES1Materials.m
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
 * See header file CC3OpenGLESMaterials.h for full API documentation.
 */

#import "CC3OpenGLES1Materials.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerMaterialColor

@implementation CC3OpenGLES1StateTrackerMaterialColor

-(void) getGLValue { glGetMaterialfv(GL_FRONT, name, (GLfloat*)&originalValue); }

-(void) setGLValue { glMaterialfv(GL_FRONT_AND_BACK, name, (GLfloat*)&value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerMaterialFloat

@implementation CC3OpenGLES1StateTrackerMaterialFloat

-(void) getGLValue { glGetMaterialfv(GL_FRONT, name, (GLfloat*)&originalValue); }

-(void) setGLValue { glMaterialf(GL_FRONT_AND_BACK, name, value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerMaterialBlend

@implementation CC3OpenGLES1StateTrackerMaterialBlend

-(void) initializeTrackers {
	self.sourceBlend = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_BLEND_SRC];
	self.destinationBlend = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																		 forState: GL_BLEND_DST];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerAlphaFunction

@implementation CC3OpenGLES1StateTrackerAlphaFunction

-(void) initializeTrackers {
	self.function = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																 forState: GL_ALPHA_TEST_FUNC];
	self.reference = [CC3OpenGLESStateTrackerFloat trackerWithParent: self
															forState: GL_ALPHA_TEST_REF];
}

-(void) setGLValues { glAlphaFunc(function.value, reference.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1Materials

@implementation CC3OpenGLES1Materials

-(void) initializeTrackers {
	self.ambientColor = [CC3OpenGLES1StateTrackerMaterialColor trackerWithParent: self
																		forState: GL_AMBIENT];
	self.diffuseColor = [CC3OpenGLES1StateTrackerMaterialColor trackerWithParent: self
																		forState: GL_DIFFUSE];
	self.specularColor = [CC3OpenGLES1StateTrackerMaterialColor trackerWithParent: self
																		 forState: GL_SPECULAR];
	self.emissionColor = [CC3OpenGLES1StateTrackerMaterialColor trackerWithParent: self
																		 forState: GL_EMISSION];
	self.shininess = [CC3OpenGLES1StateTrackerMaterialFloat trackerWithParent: self
																	 forState: GL_SHININESS];
	self.alphaFunc = [CC3OpenGLES1StateTrackerAlphaFunction trackerWithParent: self];
	
	self.blendFunc = [CC3OpenGLES1StateTrackerMaterialBlend trackerWithParent: self];
}
@end

#endif
