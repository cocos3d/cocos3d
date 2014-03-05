/*
 * CC3NodesResource.m
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
 * See header file CC3NodesResource.h for full API documentation.
 */

#import "CC3NodesResource.h"

@implementation CC3NodesResource

@synthesize nodes=_nodes, expectsVerticallyFlippedTextures=_expectsVerticallyFlippedTextures;
@synthesize shouldFreezeInanimateNodes=_shouldFreezeInanimateNodes;

-(void) dealloc {
	[_nodes release];
	[super dealloc];
}

-(CC3Node*) getNodeMatching: (CC3Node*) node {
	NSString* nodeName = node.name;
	for (CC3Node* rezNode in self.nodes) {
		CC3Node* matchedNode = [rezNode getNodeNamed: nodeName];
		if (matchedNode) return matchedNode;
	}
	return nil;
}

-(void) addNode: (CC3Node*) node { [_nodes addObject: node]; }

-(void) removeNode: (CC3Node*) node { [_nodes removeObjectIdenticalTo: node]; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_nodes = [NSMutableArray new];		// retained
		_expectsVerticallyFlippedTextures = self.class.defaultExpectsVerticallyFlippedTextures;
		_shouldFreezeInanimateNodes = self.class.defaultShouldFreezeInanimateNodes;
	}
	return self;
}

+(id) resourceFromFile: (NSString*) aFilePath expectsVerticallyFlippedTextures: (BOOL) flipped {
	CC3NodesResource* rez = (CC3NodesResource*)[self getResourceNamed: [self resourceNameFromFilePath: aFilePath]];
	if (rez) return rez;
	
	rez = [self resource];								// autoreleased
	rez.expectsVerticallyFlippedTextures = flipped;
	if ( ![rez loadFromFile: aFilePath] ) rez = nil;	// autoreleased
	[self addResource: rez];
	return rez;
}


#pragma mark Aligning texture coordinates to NPOT and iOS-inverted textures

static BOOL defaultExpectsVerticallyFlippedTextures = NO;

+(BOOL) defaultExpectsVerticallyFlippedTextures { return defaultExpectsVerticallyFlippedTextures; }

+(void) setDefaultExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	defaultExpectsVerticallyFlippedTextures = expectsFlipped;
}


#pragma mark Animation

static BOOL _defaultShouldFreezeInanimateNodes = NO;

+(BOOL) defaultShouldFreezeInanimateNodes { return _defaultShouldFreezeInanimateNodes; }

+(void) setDefaultShouldFreezeInanimateNodes: (BOOL) shouldFreeze {
	_defaultShouldFreezeInanimateNodes = shouldFreeze;
}

@end


#pragma mark Adding animation to nodes

@implementation CC3Node (CC3NodesResource)

-(void) addAnimationInResource: (CC3NodesResource*) rez asTrack: (GLuint) trackID {
	CC3Node* matchingRezNode = [rez getNodeMatching: self];
	if (matchingRezNode) [self addAnimation: matchingRezNode.animation asTrack: trackID];

	for (CC3Node* child in self.children) [child addAnimationInResource: rez asTrack: trackID];
}

-(GLuint) addAnimationInResource: (CC3NodesResource*) rez {
	GLuint trackID = [CC3NodeAnimationState generateTrackID];
	[self addAnimationInResource: rez asTrack: trackID];
	return trackID;
}

@end

