/*
 * CC3OpenGLES11Engine.m
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
 * See header file CC3OpenGLES11Engine.h for full API documentation.
 */

#import "CC3OpenGLES11Engine.h"
#import "CC3CC2Extensions.h"

@implementation CC3OpenGLES11Engine

@synthesize trackersToOpen;
@synthesize trackersToClose;
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
	[trackersToOpen release];
	[trackersToClose releaseAsUnretained];		// Clears without releasing each element.

	[super dealloc];
}

/** Wait a minute! I AM the engine! */
-(CC3OpenGLES11Engine*) engine { return self; }

-(id) init {
	if ( (self = [super init]) ) {
		trackersToClose = [[CCArray arrayWithCapacity: 200] retain];
		isClosing = NO;
		trackerToOpenWasAdded = NO;
		[self initializeTrackers];
	}
	return self;
}

-(void) initializeTrackers {
	
	// Platform must be initialized and set first so that the other trackers
	// below can access platform data during their initialization.
	self.platform = [CC3OpenGLES11Platform trackerWithParent: self];

	self.serverCapabilities = [CC3OpenGLES11ServerCapabilities trackerWithParent: self];
	self.clientCapabilities = [CC3OpenGLES11ClientCapabilities trackerWithParent: self];
	self.lighting = [CC3OpenGLES11Lighting trackerWithParent: self];
	self.matrices = [CC3OpenGLES11Matrices trackerWithParent: self];
	self.vertices = [CC3OpenGLES11VertexArrays trackerWithParent: self];
	self.materials = [CC3OpenGLES11Materials trackerWithParent: self];
	self.textures = [CC3OpenGLES11Textures trackerWithParent: self];	// Must init after matrices
	self.state = [CC3OpenGLES11State trackerWithParent: self];
	self.fog = [CC3OpenGLES11Fog trackerWithParent: self];
	self.hints = [CC3OpenGLES11Hints trackerWithParent: self];
	self.appExtensions = nil;
}

static CC3OpenGLES11Engine* engine;

+(CC3OpenGLES11Engine*) engine {
	if (!engine) {
		LogInfo(@"Third dimension provided by %@", NSStringFromCC3Version());
		
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

-(void) open {
	
	// Open each tracker that is to be opened.
	LogTrace(@"%@ opening %i trackers", [self class], trackersToOpen.count);
	for (CC3OpenGLES11StateTracker* tracker in trackersToOpen) {
		[tracker open];
	}

	// If the trackersToOpen array is dirty (a tracker has recently been added)
	// remove all trackers that do not need to be re-opened on each frame.
	// This is done by copying those that do to another array and then swapping
	// the new array for the old.
	if (trackerToOpenWasAdded) {
		CCArray* oldTrackersToOpen = [trackersToOpen autorelease];
		trackersToOpen = nil;		// Will be lazily created by addTrackerToOpen if necessary
		
		for (CC3OpenGLES11StateTracker* tracker in oldTrackersToOpen) {
			if ( ((CC3OpenGLES11StateTrackerPrimitive*)tracker).shouldAlwaysReadOriginal ) {
				[self addTrackerToOpen: tracker]; 
			}
		}
		[trackersToOpen reduceMemoryFootprint];
		trackerToOpenWasAdded = NO;
	}
}

-(void) close {
	isClosing = YES;

	// Close each tracker
	LogTrace(@"%@ closing %i trackers", [self class], trackersToClose.count);
	for (CC3OpenGLES11StateTracker* tracker in trackersToClose) {
		[tracker close];
	}
	
	// Closed after all others, because the value of these can be changed
	// during the closing of the other trackers.
	[textures.activeTexture close];				
	[textures.clientActiveTexture close];
	
	// Remove each element without releasing it.
	[trackersToClose removeAllObjectsAsUnretained];

	isClosing = NO;
}

// Lazily init the trackersToOpen array so that it can be nilled out
// if it is empty, but recreated if other trackers are added later.
-(void) addTrackerToOpen: (CC3OpenGLES11StateTracker*) aTracker {
	if (!trackersToOpen) {
		trackersToOpen = [[CCArray arrayWithCapacity: 100] retain];
	}
	[trackersToOpen addObject: aTracker];
	trackerToOpenWasAdded = YES;
}

// For speed, elements are not retained in the array.
// Don't add trackers that are changed while they are being closed. This particularly
// applies to trackers on which other trackers are dependent, like activeTexture and
// clientActiveTexture.
-(void) addTrackerToClose: (CC3OpenGLES11StateTracker*) aTracker {
	if (!isClosing) {
		LogTrace(@"Adding %@ at %i", aTracker, trackersToClose.count);
		[trackersToClose addUnretainedObject: aTracker];
	}
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n%@ ", platform];
	[desc appendFormat: @"\n%@ ", serverCapabilities];
	[desc appendFormat: @"\n%@ ", clientCapabilities];
	[desc appendFormat: @"\n%@ ", materials];
	[desc appendFormat: @"\n%@ ", textures];
	[desc appendFormat: @"\n%@ ", lighting];
	[desc appendFormat: @"\n%@ ", matrices];
	[desc appendFormat: @"\n%@ ", vertices];
	[desc appendFormat: @"\n%@ ", state];
	[desc appendFormat: @"\n%@ ", fog];
	[desc appendFormat: @"\n%@ ", hints];
	[desc appendFormat: @"\n%@ ", appExtensions];
	return desc;
}

@end
