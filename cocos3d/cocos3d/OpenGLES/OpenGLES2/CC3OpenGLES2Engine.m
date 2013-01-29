/*
 * CC3OpenGLES2Engine.m
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
 * See header file CC3OpenGLESEngine.h for full API documentation.
 */

#import "CC3OpenGLES2Engine.h"

#if CC3_OGLES_2

#import "CC3OpenGLES2Platform.h"
#import "CC3OpenGLES2Capabilities.h"
#import "CC3OpenGLES2Materials.h"
#import "CC3OpenGLES2Textures.h"
#import "CC3OpenGLES2Lighting.h"
#import "CC3OpenGLES2Matrices.h"
#import "CC3OpenGLES2VertexArrays.h"
#import "CC3OpenGLES2State.h"
#import "CC3OpenGLES2Fog.h"
#import "CC3OpenGLES2Hints.h"

@implementation CC3OpenGLES2Engine

-(void) initializeTrackers {
	
	// Platform must be initialized and set first so that the other trackers
	// below can access platform data during their initialization.
	self.platform = [CC3OpenGLES2Platform trackerWithParent: self];

	self.capabilities = [CC3OpenGLES2Capabilities trackerWithParent: self];
	self.lighting = [CC3OpenGLES2Lighting trackerWithParent: self];
	self.matrices = [CC3OpenGLES2Matrices trackerWithParent: self];
	self.vertices = [CC3OpenGLES2VertexArrays trackerWithParent: self];
	self.materials = [CC3OpenGLES2Materials trackerWithParent: self];
	self.textures = [CC3OpenGLES2Textures trackerWithParent: self];	// Must init after matrices
	self.state = [CC3OpenGLES2State trackerWithParent: self];
	self.fog = [CC3OpenGLES2Fog trackerWithParent: self];
	self.hints = [CC3OpenGLES2Hints trackerWithParent: self];
	self.shaders = [CC3OpenGLESShaders trackerWithParent: self];
	self.appExtensions = nil;
}

@end

#endif