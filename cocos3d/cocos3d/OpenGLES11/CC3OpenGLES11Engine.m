/*
 * CC3OpenGLES11Engine.m
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
 * 
 * See header file CC3OpenGLES11Engine.h for full API documentation.
 */

#import "CC3OpenGLES11Engine.h"

@implementation CC3OpenGLES11Engine

@synthesize platform;
@synthesize serverCapabilities;
@synthesize clientCapabilities;
@synthesize materials;
@synthesize textures;
@synthesize lighting;
@synthesize matrices;
@synthesize vertices;
@synthesize state;
@synthesize fog;
@synthesize hints;
@synthesize appExtensions;

-(void) dealloc {
	[platform release];
	[serverCapabilities release];
	[clientCapabilities release];
	[materials release];
	[textures release];
	[lighting release];
	[matrices release];
	[vertices release];
	[state release];
	[fog release];
	[hints release];
	[appExtensions release];
	
	[super dealloc];
}

-(id) init {
	if ( (self = [super init]) ) {
		// Platform must be initialized and set first so that the other trackers
		// below can access platform data during their initialization.
		self.platform = [CC3OpenGLES11Platform tracker];
		self.serverCapabilities = [CC3OpenGLES11ServerCapabilities tracker];
		self.clientCapabilities = [CC3OpenGLES11ClientCapabilities tracker];
		self.lighting = [CC3OpenGLES11Lighting tracker];
		self.matrices = [CC3OpenGLES11Matrices tracker];
		self.vertices = [CC3OpenGLES11VertexArrays tracker];
		self.materials = [CC3OpenGLES11Materials tracker];
		self.textures = [CC3OpenGLES11Textures tracker];	// Must init after matrices
		self.state = [CC3OpenGLES11State tracker];
		self.fog = [CC3OpenGLES11Fog tracker];
		self.hints = [CC3OpenGLES11Hints tracker];
		self.appExtensions = nil;
	}
	return self;
}

static CC3OpenGLES11Engine* engine;

+(CC3OpenGLES11Engine*) engine {
	if (!engine) {
		// This rather unconventional distinct separation of alloc and init is intentional.
		// Initialize AFTER setting the singleton variable so that the initialization code
		// of the instance itself can access this singleton. For example, when initializing
		// the light trackers, we need to know how many lights are supported by the platform,
		// which is accessed from the platform tracker.
		engine = [self alloc];
		[engine init];
	}
	return engine;
}

// Platform tracker not included here because its data is loaded only
// at app start-up, and so is not read as part of normal frame opening
-(void) open {
	[platform open];
	[serverCapabilities open];
	[clientCapabilities open];
	[materials open];
	[textures open];
	[lighting open];
	[matrices open];
	[vertices open];
	[state open];
	[fog open];
	[hints open];
	[appExtensions open];
}

// Platform tracker not included here because its data is read-only
// and so there is nothing to restore as part of normal frame closing
-(void) close {
	[platform close];
	[serverCapabilities close];
	[clientCapabilities close];
	[materials close];
	[textures close];
	[lighting close];
	[matrices close];
	[vertices close];
	[state close];
	[fog close];
	[hints close];
	[appExtensions close];
}

@end
