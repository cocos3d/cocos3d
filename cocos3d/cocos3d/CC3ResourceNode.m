/*
 * CC3ResourceNode.m
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
 * See header file CC3ResourceNode.h for full API documentation.
 */

#import "CC3ResourceNode.h"


@interface CC3Node (TemplateMethods)
-(void) populateFrom: (CC3Node*) another;
@end

@implementation CC3ResourceNode

@synthesize resource;

-(void) dealloc {
	[resource release];
	[super dealloc];
}

-(Class) resourceClass {
	NSAssert1(NO, @"No resource class has been established for this %@ class. Create a subclass and override the resourceClass method.", [self class]);
	return [CC3Resource class];
}

-(void) setResource: (CC3Resource *) aResource {
	if (aResource != resource) {
		[self removeAllChildren];
		[resource release];
		resource = [aResource retain];
		if (!name) {
			self.name = aResource.name;
		}
		LogTrace(@"%@ setting resource: %@", self, aResource);
		for (CC3Node* aNode in [aResource nodes]) {
			[self addChild: aNode];
		}
	}
}

-(void) loadFromFile: (NSString*) aFilepath {
	self.resource = [[self resourceClass] resourceFromFile: aFilepath];
}

-(id) initFromFile: (NSString*) aFilepath {
	if ( (self = [super init]) ) {
		[self loadFromFile: aFilepath];
	}
	return self;
}

+(id) nodeFromFile: (NSString*) aFilepath {
	return [[[self alloc] initFromFile: aFilepath] autorelease];
}

-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFilepath {
	if ( (self = [super initWithName: aName]) ) {
		[self loadFromFile: aFilepath];
	}
	return self;
}

+(id) nodeWithName: (NSString*) aName fromFile: (NSString*) aFilepath {
	return [[[self alloc] initWithName: aName fromFile: aFilepath] autorelease];
}

-(void) loadFromResourceFile: (NSString*) aRezPath {
	self.resource = [[self resourceClass] resourceFromResourceFile: aRezPath];
}

-(id) initFromResourceFile: (NSString*) aRezPath {
	if ( (self = [super init]) ) {
		[self loadFromResourceFile: aRezPath];
	}
	return self;
}

+(id) nodeFromResourceFile: (NSString*) aRezPath {
	return [[[self alloc] initFromResourceFile: aRezPath] autorelease];
}

-(id) initWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath {
	if ( (self = [super initWithName: aName]) ) {
		[self loadFromResourceFile: aRezPath];
	}
	return self;
}

+(id) nodeWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath {
	return [[[self alloc] initWithName: aName fromResourceFile: aRezPath] autorelease];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// The encapsulated resource instance is not copied, but is retaind and shared between instances.
-(void) populateFrom: (CC3ResourceNode*) another {
	[super populateFrom: another];
	
	[resource release];
	resource = [another.resource retain];		// retained
}

@end

