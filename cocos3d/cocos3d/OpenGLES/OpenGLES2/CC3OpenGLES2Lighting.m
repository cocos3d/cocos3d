/*
 * CC3OpenGLES2Lighting.m
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

#import "CC3OpenGLES2Lighting.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2Light

@implementation CC3OpenGLES2Light

-(void) initializeTrackers {
	self.light = [CC3OpenGLESStateTrackerCapability trackerWithParent: self
											 andOriginalValueHandling: kCC3GLESStateOriginalValueIgnore];
	self.ambientColor = [CC3OpenGLESStateTrackerColor trackerWithParent: self];
	self.diffuseColor = [CC3OpenGLESStateTrackerColor trackerWithParent: self];
	self.specularColor = [CC3OpenGLESStateTrackerColor trackerWithParent: self];
	self.position = [CC3OpenGLESStateTrackerVector4 trackerWithParent: self];
	self.spotDirection = [CC3OpenGLESStateTrackerVector trackerWithParent: self];
	self.spotExponent = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.spotCutoffAngle = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.constantAttenuation = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.linearAttenuation = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
	self.quadraticAttenuation = [CC3OpenGLESStateTrackerFloat trackerWithParent: self];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1Lighting

@implementation CC3OpenGLES2Lighting

-(Class) lightTrackerClass { return [CC3OpenGLES2Light class]; }

-(void) initializeTrackers {
	self.sceneAmbientLight = [CC3OpenGLESStateTrackerColor trackerWithParent: self];
	self.lights = [CCArray array];		// Start with none. Add them as requested.
}

@end

#endif
