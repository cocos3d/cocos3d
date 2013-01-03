/*
 * CC3OpenGLES1Lighting.m
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
 * See header file CC3OpenGLESLighting.h for full API documentation.
 */

#import "CC3OpenGLES1Lighting.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightFloat

@implementation CC3OpenGLES1StateTrackerLightFloat

-(GLenum) glLightIndex { return GL_LIGHT0 + ((CC3OpenGLESLight*)self.parent).lightIndex; }

-(void) getGLValue { glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue); }

-(void) setGLValue { glLightf(self.glLightIndex, name, value); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightColor

@implementation CC3OpenGLES1StateTrackerLightColor

-(GLenum) glLightIndex { return GL_LIGHT0 + ((CC3OpenGLESLight*)self.parent).lightIndex; }

-(void) getGLValue { glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue); }

-(void) setGLValue { glLightfv(self.glLightIndex, name, (GLfloat*)&value); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightVector

@implementation CC3OpenGLES1StateTrackerLightVector

-(GLenum) glLightIndex { return GL_LIGHT0 + ((CC3OpenGLESLight*)self.parent).lightIndex; }

-(void) getGLValue { glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue); }

-(void) setGLValue { glLightfv(self.glLightIndex, name, (GLfloat*)&value); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerLightVector4

@implementation CC3OpenGLES1StateTrackerLightVector4

-(GLenum) glLightIndex { return GL_LIGHT0 + ((CC3OpenGLESLight*)self.parent).lightIndex; }

-(void) getGLValue { glGetLightfv(self.glLightIndex, name, (GLfloat*)&originalValue); }

-(void) setGLValue { glLightfv(self.glLightIndex, name, (GLfloat*)&value); }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1Light

@implementation CC3OpenGLES1Light

-(void) initializeTrackers {
	self.light = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
															 forState: GL_LIGHT0 + self.lightIndex];
	self.ambientColor = [CC3OpenGLES1StateTrackerLightColor trackerWithParent: self
																	 forState: GL_AMBIENT];
	self.diffuseColor = [CC3OpenGLES1StateTrackerLightColor trackerWithParent: self
																	 forState: GL_DIFFUSE];
	self.specularColor = [CC3OpenGLES1StateTrackerLightColor trackerWithParent: self
																	  forState: GL_SPECULAR];
	self.position = [CC3OpenGLES1StateTrackerLightVector4 trackerWithParent: self
																   forState: GL_POSITION];
	self.spotDirection = [CC3OpenGLES1StateTrackerLightVector trackerWithParent: self
																	   forState: GL_SPOT_DIRECTION];
	self.spotExponent = [CC3OpenGLES1StateTrackerLightFloat trackerWithParent: self
																	 forState: GL_SPOT_EXPONENT];
	self.spotCutoffAngle = [CC3OpenGLES1StateTrackerLightFloat trackerWithParent: self
																		forState: GL_SPOT_CUTOFF];
	self.constantAttenuation = [CC3OpenGLES1StateTrackerLightFloat trackerWithParent: self
																			forState: GL_CONSTANT_ATTENUATION];
	self.linearAttenuation = [CC3OpenGLES1StateTrackerLightFloat trackerWithParent: self
																		  forState: GL_LINEAR_ATTENUATION];
	self.quadraticAttenuation = [CC3OpenGLES1StateTrackerLightFloat trackerWithParent: self
																			 forState: GL_QUADRATIC_ATTENUATION];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerSceneLightColor

@implementation CC3OpenGLES1StateTrackerSceneLightColor

-(void) setGLValue { glLightModelfv(name, (GLfloat*)&value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1Lighting

@implementation CC3OpenGLES1Lighting

-(Class) lightTrackerClass { return [CC3OpenGLES1Light class]; }

-(void) initializeTrackers {
	self.sceneAmbientLight = [CC3OpenGLES1StateTrackerSceneLightColor trackerWithParent: self
																			   forState: GL_LIGHT_MODEL_AMBIENT
															   andOriginalValueHandling: kCC3GLESStateOriginalValueReadOnceAndRestore];
	self.lights = [CCArray array];		// Start with none. Add them as requested.
}

@end

#endif
