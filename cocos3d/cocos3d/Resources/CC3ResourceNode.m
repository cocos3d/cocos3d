/*
 * CC3ResourceNode.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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


@implementation CC3ResourceNode

-(Class) resourceClass {
	CC3Assert(NO, @"No resource class has been established for this %@ class. Create a subclass and override the resourceClass method.", [self class]);
	return [CC3NodesResource class];
}

-(void) populateFromResource: (CC3NodesResource*) resource {
	if ( !resource ) return;
	
	CC3Assert( [resource isKindOfClass: self.resourceClass],
			  @"%@ must be populated from a resource of type %@. It cannot be populated from %@",
			  self, self.resourceClass, resource);
	
	if (!_name) { self.name = resource.name; }
	self.userData = resource.userData;

	[self removeAllChildren];
	for (CC3Node* aNode in resource.nodes) [self addChild: aNode];
	LogRez(@"%@ added resource %@ with node structure: %@", self, resource,
		   [self appendStructureDescriptionTo: [NSMutableString stringWithCapacity: 1000]
								   withIndent: 1]);
}


#pragma mark Loading file resources

-(void) loadFromFile: (NSString*) aFilepath {
	[self populateFromResource: [self.resourceClass resourceFromFile: aFilepath]];
}

-(void) loadFromFile: (NSString*) aFilepath expectsVerticallyFlippedTextures: (BOOL) flipped {
	[self populateFromResource: [self.resourceClass resourceFromFile: aFilepath
									expectsVerticallyFlippedTextures: flipped]];
}


#pragma mark Allocation and initialization

-(id) initFromFile: (NSString*) aFilepath {
	if ( (self = [super init]) ) {
		[self loadFromFile: aFilepath];
	}
	return self;
}

+(id) nodeFromFile: (NSString*) aFilepath {
	return [[[self alloc] initFromFile: aFilepath] autorelease];
}

-(id) initFromFile: (NSString*) aFilepath expectsVerticallyFlippedTextures: (BOOL) flipped {
	if ( (self = [super init]) ) {
		[self loadFromFile: aFilepath expectsVerticallyFlippedTextures: flipped];
	}
	return self;
}

+(id) nodeFromFile: (NSString*) aFilepath expectsVerticallyFlippedTextures: (BOOL) flipped {
	return [[[self alloc] initFromFile: aFilepath expectsVerticallyFlippedTextures: flipped] autorelease];
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


#pragma mark Deprecated file loading methods

// Deprecated methods
-(CC3NodesResource*) resource { return nil; }
-(void) setResource: (CC3NodesResource*) aResource { [self populateFromResource: aResource]; }
-(BOOL) expectsVerticallyFlippedTextures { return NO; }
-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {}
-(void) loadFromResourceFile: (NSString*) aRezPath { [self loadFromFile: aRezPath]; }
-(id) initFromResourceFile: (NSString*) aRezPath { return [self initFromFile: aRezPath]; }
+(id) nodeFromResourceFile: (NSString*) aRezPath { return [self nodeFromFile: aRezPath]; }
-(id) initWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath {
	return [self initWithName: aName fromFile: aRezPath];
}
+(id) nodeWithName: (NSString*) aName fromResourceFile: (NSString*) aRezPath {
	return [self nodeWithName: aName fromFile: aRezPath];
}

@end

