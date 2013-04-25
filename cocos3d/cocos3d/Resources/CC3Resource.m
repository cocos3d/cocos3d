/*
 * CC3Resource.m
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
 * See header file CC3Resource.h for full API documentation.
 */

#import "CC3Resource.h"
#import "CC3NodesResource.h"


@implementation CC3Resource

@synthesize directory=_directory, isBigEndian=_isBigEndian, wasLoaded=_wasLoaded;

-(void) dealloc {
	[_directory release];
	[super dealloc];
}

-(BOOL) loadFromFile: (NSString*) aFilePath {
	if (_wasLoaded) {
		LogError(@"%@ has already been loaded.", self);
		return _wasLoaded;
	}
	
	// Ensure the path is absolute, converting it if needed.
	NSString* absFilePath = CC3EnsureAbsoluteFilePath(aFilePath);
	
	LogRez(@"--------------------------------------------------");
	LogRez(@"Loading resources from file '%@'", absFilePath);
	
	if (!_name) self.name = absFilePath.lastPathComponent;
	if (!_directory) self.directory = [absFilePath stringByDeletingLastPathComponent];
	
	MarkRezActivityStart();
	
	_wasLoaded = [self processFile: absFilePath];	// Main subclass loading method
	
	if (_wasLoaded)
		LogRez(@"Loaded resources from file '%@' in %.4f seconds", aFilePath, GetRezActivityDuration());
	else
		LogError(@"Could not load resource file '%@'", absFilePath);
	
	LogRez(@"");		// Empty line to separate from next logs
	
	return _wasLoaded;
}

-(BOOL) processFile: (NSString*) anAbsoluteFilePath { return NO; }

-(BOOL) saveToFile: (NSString*) aFilePath {
	CC3Assert(NO, @"%@ does not support saving the resource content back to a file.", self);
	return NO;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_directory = nil;
		_isBigEndian = NO;
		_wasLoaded = NO;
	}
	return self;
}

+(id) resource { return [[[self alloc] init] autorelease]; }

-(id) initFromFile: (NSString*) aFilePath {
	if ( (self = [self init]) ) {		// Use self so subclasses will init properly
		if ( ![self loadFromFile: aFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) resourceFromFile: (NSString*) aFilePath {
	id rez = [self getResourceNamed: aFilePath.lastPathComponent];
	if (rez) return rez;

	rez = [[self alloc] initFromFile: aFilePath];
	[self addResource: rez];
	[rez release];
	return rez;
}

-(NSString*) description { return [NSString stringWithFormat: @"%@ from file %@", self.class, self.name]; }


#pragma mark Resource cache

static NSMutableDictionary* _resourcesByName = nil;

+(CC3Resource*) getResourceNamed: (NSString*) rezName { return [_resourcesByName objectForKey: rezName]; }

+(void) addResource: (CC3Resource*) resource {
	if ( !resource ) return;
	CC3Assert(resource.name, @"%@ cannot be added to the resource cache because its name property is nil.", resource);
	if ( !_resourcesByName ) _resourcesByName = [NSMutableDictionary new];		// retained
	[_resourcesByName setObject: resource forKey: resource.name];
}

+(void) removeResource: (CC3Resource*) resource {
	NSString* rezName = resource.name;
	if (resource == [self getResourceNamed: rezName]) {
		[_resourcesByName removeObjectForKey: rezName];
	} else {
		LogInfo(@"%@ was not removed from the resource cache because it is not the instance that is cached under name %@", resource, rezName);
	}
}

+(void) removeAllResources { [_resourcesByName removeAllObjects]; }

-(void) remove { [[self class] removeResource: self]; }


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Identifiables.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedResourceTag;

-(GLuint) nextTag { return ++lastAssignedResourceTag; }

+(void) resetTagAllocation { lastAssignedResourceTag = 0; }


#pragma mark Deprecated functionality

-(CCArray*) nodes { return nil; }
-(BOOL) expectsVerticallyFlippedTextures { return NO; }
-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsVerticallyFlippedTextures {}
+(BOOL) defaultExpectsVerticallyFlippedTextures { return CC3NodesResource.defaultExpectsVerticallyFlippedTextures; }
+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped { CC3NodesResource.defaultExpectsVerticallyFlippedTextures = expectsFlipped; }
-(BOOL) loadFromResourceFile: (NSString*) aRezPath { return [self loadFromFile: aRezPath];}
-(id) initFromResourceFile: (NSString*) aRezPath { return [self initFromFile: aRezPath]; }
+(id) resourceFromResourceFile: (NSString*) aRezPath { return [self resourceFromFile: aRezPath]; }

@end
