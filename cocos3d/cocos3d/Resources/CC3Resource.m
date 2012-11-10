/*
 * CC3Resource.m
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
 * See header file CC3Resource.h for full API documentation.
 */

#import "CC3Resource.h"


@implementation CC3Resource

@synthesize nodes, directory, wasLoaded, expectsVerticallyFlippedTextures;

-(void) dealloc {
	[nodes release];
	[directory release];
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		nodes = [[CCArray array] retain];
		directory = nil;
		wasLoaded = NO;
		expectsVerticallyFlippedTextures = [[self class] defaultExpectsVerticallyFlippedTextures];
	}
	return self;
}

+(id) resource {
	return [[[self alloc] init] autorelease];
}

-(id) initFromFile: (NSString*) aFilePath {
	if ( (self = [self init]) ) {
		if ( ![self loadFromFile: aFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) resourceFromFile: (NSString*) aFilePath {
	return [[[self alloc] initFromFile: aFilePath] autorelease];
}

-(BOOL) loadFromFile: (NSString*) aFilePath {
	if (wasLoaded) {
		LogError(@"%@ has already been loaded.", self);
		return wasLoaded;
	}
	
	// Ensure the path is absolute, converting it if needed.
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);

	LogRez(@"");
	LogRez(@"--------------------------------------------------");
	LogRez(@"Loading resources from file '%@'", absFilePath);

	if (!name) self.name = [absFilePath lastPathComponent];
	if (!directory) self.directory = [absFilePath stringByDeletingLastPathComponent];
	
#if LOGGING_REZLOAD
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
#endif

	wasLoaded = [self processFile: absFilePath];	// Main subclass loading method
	
	if (wasLoaded)
		LogRez(@"Loaded resources from file '%@' in %.4f seconds",
			   absFilePath, ([NSDate timeIntervalSinceReferenceDate] - startTime));
	else
		LogError(@"Could not load resource file '%@'", absFilePath);

	return wasLoaded;
}

// Subclasses should override this method, but invoke this superclass implementation first.
-(BOOL) processFile: (NSString*) anAbsoluteFilePath { return NO; }


#pragma mark Aligning texture coordinates to NPOT and iOS-inverted textures

static BOOL defaultExpectsVerticallyFlippedTextures = YES;

+(BOOL) defaultExpectsVerticallyFlippedTextures {
	return defaultExpectsVerticallyFlippedTextures;
}

+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	defaultExpectsVerticallyFlippedTextures = expectsFlipped;
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Identifiables.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedResourceTag;

-(GLuint) nextTag {
	return ++lastAssignedResourceTag;
}

+(void) resetTagAllocation {
	lastAssignedResourceTag = 0;
}


#pragma mark Deprecated file loading methods

// Deprecated methods
-(BOOL) loadFromResourceFile: (NSString*) aRezPath { return [self loadFromFile: aRezPath];}
-(id) initFromResourceFile: (NSString*) aRezPath { return [self initFromFile: aRezPath]; }
+(id) resourceFromResourceFile: (NSString*) aRezPath { return [self resourceFromFile: aRezPath]; }

@end
