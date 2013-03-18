/*
 * CC3OpenGLESEngine.m
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

#import "CC3OpenGLESEngine.h"
#import "CC3CC2Extensions.h"

#if CC3_OGLES_2
#	import "CC3OpenGLES2Engine.h"
#	define CC3OpenGLESEngineClass	CC3OpenGLES2Engine
#elif CC3_OGLES_1
#	import "CC3OpenGLES1Engine.h"
#	define CC3OpenGLESEngineClass	CC3OpenGLES1Engine
#endif

@implementation CC3OpenGLESEngine

@synthesize trackersToOpen=_trackersToOpen;
@synthesize trackersToClose=_trackersToClose;
@synthesize platform=_platform;
@synthesize capabilities=_capabilities;
@synthesize materials=_materials;
@synthesize textures=_textures;
@synthesize lighting=_lighting;
@synthesize matrices=_matrices;
@synthesize vertices=_vertices;
@synthesize state=_state;
@synthesize fog=_fog;
@synthesize hints=_hints;
@synthesize shaders=_shaders;
@synthesize appExtensions;

-(void) dealloc {
	[_platform release];
	[_capabilities release];
	[_materials release];
	[_textures release];
	[_lighting release];
	[_matrices release];
	[_vertices release];
	[_state release];
	[_fog release];
	[_hints release];
	[_shaders release];
	[_appExtensions release];
	[_trackersToOpen release];
	[_trackersToClose releaseAsUnretained];		// Clears without releasing each element.

	[super dealloc];
}

/** Wait a minute! I AM the engine! */
-(CC3OpenGLESEngine*) engine { return self; }

-(id) init {
	if ( (self = [super init]) ) {
		_trackersToClose = [[CCArray arrayWithCapacity: 200] retain];
		_isClosing = NO;
		_trackerToOpenWasAdded = NO;
		[self initializeTrackers];
	}
	return self;
}

static CC3OpenGLESEngine* _engine;

+(CC3OpenGLESEngine*) engine {
	if (!_engine) {
		LogInfo(@"Third dimension provided by %@", NSStringFromCC3Version());
		
		// This rather unconventional distinct separation of alloc and init is intentional.
		// Initialize AFTER setting the singleton variable so that the initialization code
		// of the instance itself can access this singleton. For example, when initializing
		// the light trackers, we need to know how many lights are supported by the platform,
		// which is accessed from the platform tracker.
		_engine = [CC3OpenGLESEngineClass alloc];
		[_engine init];
	}
	return _engine;
}

-(void) initializeTrackers {}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n%@ ", _platform];
	[desc appendFormat: @"\n%@ ", _capabilities];
	[desc appendFormat: @"\n%@ ", _materials];
	[desc appendFormat: @"\n%@ ", _textures];
	[desc appendFormat: @"\n%@ ", _lighting];
	[desc appendFormat: @"\n%@ ", _matrices];
	[desc appendFormat: @"\n%@ ", _vertices];
	[desc appendFormat: @"\n%@ ", _state];
	[desc appendFormat: @"\n%@ ", _fog];
	[desc appendFormat: @"\n%@ ", _hints];
	[desc appendFormat: @"\n%@ ", _shaders];
	[desc appendFormat: @"\n%@ ", _appExtensions];
	return desc;
}

// Deprecated properties
-(CC3OpenGLESCapabilities*) serverCapabilities { return self.capabilities; }
-(void) setServerCapabilities: (CC3OpenGLESCapabilities*) caps { self.capabilities = caps; }
-(CC3OpenGLESCapabilities*) clientCapabilities { return self.capabilities; }
-(void) setClientCapabilities: (CC3OpenGLESCapabilities*) caps { self.capabilities = caps; }

@end
