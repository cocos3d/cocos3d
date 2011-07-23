/*
 * CC3NodeSequencer.m
 *
 * cocos3d 0.6.0-sp
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3NodeSequencer.h for full API documentation.
 */

#import "CC3NodeSequencer.h"
#import "CC3MeshNode.h"
#import "CCTexture2D.h"
#import "CC3BoundingVolumes.h"
#import "CC3World.h"

#pragma mark -
#pragma mark CC3NodeEvaluator

@implementation CC3NodeEvaluator

-(BOOL) evaluate: (CC3Node*) aNode {
	return NO;
}

+(id) evaluator {
	return [[[self alloc] init] autorelease];
}

@end


#pragma mark -
#pragma mark CC3NodeRejector

@implementation CC3NodeRejector
@end


#pragma mark -
#pragma mark CC3NodeAcceptor

@implementation CC3NodeAcceptor

-(BOOL) evaluate: (CC3Node*) aNode {
	return YES;
}

@end


#pragma mark -
#pragma mark CC3LocalContentNodeEvaluator

@implementation CC3LocalContentNodeEvaluator

-(BOOL) evaluate: (CC3Node*) aNode {
	if (aNode.hasLocalContent) {
		return [self evaluateLocalContentNode: (CC3LocalContentNode*)aNode];
	} else {
		return NO;
	}
}

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode {
	return NO;
}

@end


#pragma mark -
#pragma mark CC3LocalContentNodeAcceptor

@implementation CC3LocalContentNodeAcceptor

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode {
	return YES;
}

@end


#pragma mark -
#pragma mark CC3OpaqueNodeAcceptor

@implementation CC3OpaqueNodeAcceptor

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode {
	return lcNode.isOpaque;
}

@end


#pragma mark -
#pragma mark CC3TranslucentNodeAcceptor

@implementation CC3TranslucentNodeAcceptor

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode {
	return !lcNode.isOpaque;
}

@end


#pragma mark -
#pragma mark CC3NodeSequencer

@implementation CC3NodeSequencer

@synthesize evaluator, allowSequenceUpdates;

-(void) dealloc {
	[evaluator release];
	[super dealloc];
}

-(NSArray*) nodes {
	return [NSArray array];
}

-(BOOL) shouldUseOnlyForwardDistance {
	return NO;
}

-(void) setShouldUseOnlyForwardDistance: (BOOL) onlyForward {}

-(id) init {
	return [self initWithEvaluator: nil];
}

+(id) sequencer {
	return [[[self alloc] init] autorelease];
}

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super init]) ) {
		self.evaluator = anEvaluator;
		allowSequenceUpdates = YES;
	}
	return self;
}

+(id) sequencerWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	return [[[self alloc] initWithEvaluator: anEvaluator] autorelease];
}

-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	return NO;
}

-(BOOL) remove: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	return NO;
}

-(BOOL) updateSequenceWithVisitor: (CC3NodeSequencerMisplacedNodeVisitor*) visitor {
	[self removeMisplacedNodesWithVisitor: visitor];
	if (visitor.hasMisplacedNodes) {
		LogTrace(@"%@ detected %u misplaced nodes: %@",
				 self, visitor.misplacedNodes.count, visitor.misplacedNodes);
		for(CC3Node* n in visitor.misplacedNodes) {
			[self add: n withVisitor: visitor];
		}
		return YES;
	}
	return NO;
}

-(void) removeMisplacedNodesWithVisitor: (CC3NodeSequencerMisplacedNodeVisitor*) visitor {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", [self class]];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ %@", self, self.nodes];
}

@end


#pragma mark -
#pragma mark CC3BTreeNodeSequencer

@implementation CC3BTreeNodeSequencer

@synthesize sequencers;

-(void) dealloc {
	[sequencers release];
	[super dealloc];
}

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super initWithEvaluator: anEvaluator]) ) {
		sequencers = [[NSMutableArray array] retain];
	}
	return self;
}

-(void) addSequencer: (CC3NodeSequencer*) aNodeSequencer {
	[sequencers addObject: aNodeSequencer];
}

/** Iterates through the sequencers, adding it to the first one that accepts the node. */
-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	if ( evaluator && [evaluator evaluate: aNode] ) {
		for (CC3NodeSequencer* s in sequencers) {
			if ([s add: aNode withVisitor: visitor]) {
				return YES;
			}
		}
	}
	return NO;
}

/** Iterates through the sequencers, asking each to remove the node. */
-(BOOL) remove: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	for (CC3NodeSequencer* s in sequencers) {
		if ([s remove: aNode withVisitor: visitor]) {
			return YES;
		}
	}
	return NO;
}

/** Iterates through the sequencers, asking each to remove misplaced nodes. */
-(void) removeMisplacedNodesWithVisitor: (CC3NodeSequencerMisplacedNodeVisitor*) visitor {
	if (allowSequenceUpdates) {
		for (CC3NodeSequencer* s in sequencers) {
			[s removeMisplacedNodesWithVisitor: visitor];
		}
	}
}

/** Concatenates the nodes from the contained sequencers into one array. */
-(NSArray*) nodes {
	NSMutableArray* nodes = [NSMutableArray array];
	for (CC3NodeSequencer* s in sequencers) {
		[nodes addObjectsFromArray: s.nodes];
	}
	return nodes;
}

-(BOOL) shouldUseOnlyForwardDistance {
	for (CC3NodeSequencer* s in sequencers) {
		if (s.shouldUseOnlyForwardDistance) {
			return YES;
		}
	}
	return NO;
}

-(void) setShouldUseOnlyForwardDistance: (BOOL) onlyForward {
	for (CC3NodeSequencer* s in sequencers) {
		s.shouldUseOnlyForwardDistance = onlyForward;
	}
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	for (CC3NodeSequencer* s in sequencers) {
		[desc appendFormat: @"\n%@", [s fullDescription]];
	}
	return desc;
}

+(id) sequencerLocalContentOpaqueFirst {
	CC3BTreeNodeSequencer* bTree = [self sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	[bTree addSequencer: [CC3NodeArraySequencer sequencerWithEvaluator: [CC3OpaqueNodeAcceptor evaluator]]];
	[bTree addSequencer: [CC3NodeArrayZOrderSequencer sequencerWithEvaluator: [CC3TranslucentNodeAcceptor evaluator]]];
	return bTree;
}

+(id) sequencerLocalContentOpaqueFirstGroupTextures {
	CC3BTreeNodeSequencer* bTree = [self sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	[bTree addSequencer: [CC3MeshNodeArraySequencerGroupTextures sequencerWithEvaluator: [CC3OpaqueNodeAcceptor evaluator]]];
	[bTree addSequencer: [CC3NodeArrayZOrderSequencer sequencerWithEvaluator: [CC3TranslucentNodeAcceptor evaluator]]];
	return bTree;
}

+(id) sequencerLocalContentOpaqueFirstGroupMeshes {
	CC3BTreeNodeSequencer* bTree = [self sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	[bTree addSequencer: [CC3MeshNodeArraySequencerGroupMeshes sequencerWithEvaluator: [CC3OpaqueNodeAcceptor evaluator]]];
	[bTree addSequencer: [CC3NodeArrayZOrderSequencer sequencerWithEvaluator: [CC3TranslucentNodeAcceptor evaluator]]];
	return bTree;
}

@end


#pragma mark -
#pragma mark CC3NodeArraySequencer

@implementation CC3NodeArraySequencer

-(void) dealloc {
	[nodes release];
	[super dealloc];
}

-(NSArray*) nodes {
	return nodes;
}

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super initWithEvaluator: anEvaluator]) ) {
		nodes = [[NSMutableArray array] retain];
	}
	return self;
}

/**
 * Iterates through the existing nodes, passing them as sequential pairs, along with the
 * node to be added, to the shouldInsertNode:between:and:withVisitor: template method.
 * If that method returns YES, the node is inserted into the array at that point.
 * If that method never returns YES< the node is added at the end of the array.
 * Returns whether the node was added.
 */
-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	if ( evaluator && [evaluator evaluate: aNode] ) {
		NSUInteger nodeCount = nodes.count;
		for (NSUInteger i = 0; i < nodeCount; i++) {
			CC3Node* leftNode = i > 0 ? [nodes objectAtIndex: i - 1] : nil;
			CC3Node* rightNode = [nodes objectAtIndex: i];
			if ( [self shouldInsertNode: aNode
								between: leftNode
									and: rightNode
							withVisitor: visitor] ) {
				[nodes insertObject: aNode atIndex: i];
				return YES;
			}
		}
		[nodes addObject: aNode];
		return YES;
	}
	return NO;
}

-(BOOL) shouldInsertNode: (CC3Node*) aNode
				 between: (CC3Node*) leftNode
					 and: (CC3Node*) rightNode
			 withVisitor: (CC3NodeSequencerVisitor*) visitor {
	return NO;
}

-(BOOL) remove: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	NSUInteger nodeIndex = [nodes indexOfObjectIdenticalTo: aNode];
	if (nodeIndex != NSNotFound) {
		[nodes removeObjectAtIndex: nodeIndex];
		return YES;
	}
	return NO;
}

/** Removes nodes that do not pass the evaluator. */
-(void) removeMisplacedNodesWithVisitor: (CC3NodeSequencerMisplacedNodeVisitor*) visitor {
	if (!allowSequenceUpdates) return;		// Leave if sequence updating should not happen.

	NSMutableArray* misplacedNodes = [NSMutableArray arrayWithCapacity: nodes.count];
	for (CC3Node* n in nodes) {
		if ( (evaluator && ![evaluator evaluate: n]) ) {
			[misplacedNodes addObject: n];
		}
	}
	// Remove all misplaced nodes from this node array, and add them to the visitor's cache.
	for (CC3Node* n in misplacedNodes) {
		[nodes removeObjectIdenticalTo: n];
	}
	[visitor addMisplacedNodes: misplacedNodes];
}

@end


#pragma mark -
#pragma mark CC3NodeArrayZOrderSequencer

@implementation CC3NodeArrayZOrderSequencer

-(BOOL) shouldUseOnlyForwardDistance {
	return shouldUseOnlyForwardDistance;
}

-(void) setShouldUseOnlyForwardDistance: (BOOL) onlyForward {
	shouldUseOnlyForwardDistance = onlyForward;
}

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super initWithEvaluator: anEvaluator]) ) {
		shouldUseOnlyForwardDistance = NO;
	}
	return self;
}

/**
 * If the distance from the node of interest to the camera is greater than the
 * distance from the rightNode to the camera, return YES, otherwise return NO.
 * Since the array is traversed from front to back, the node will have already
 * been tested against the leftNode. Nodes without a boundingVolume are added
 * to the end of the array.
 */
-(BOOL) shouldInsertNode: (CC3Node*) aNode
				 between: (CC3Node*) leftNode
					 and: (CC3Node*) rightNode
			 withVisitor: (CC3NodeSequencerVisitor*) visitor {
	CC3NodeBoundingVolume* bv = aNode.boundingVolume;
	CC3NodeBoundingVolume* rtBV = rightNode.boundingVolume;
	return (bv && rtBV && bv.cameraDistanceProduct >= rtBV.cameraDistanceProduct);
}

/**
 * Removes nodes that do not pass the evaluator or are not in the correct Z-order sequence.
 * Any node whose distance to the camera is greater than the nodes before it is removed.
 */
-(void) removeMisplacedNodesWithVisitor: (CC3NodeSequencerMisplacedNodeVisitor*) visitor {
	if (!allowSequenceUpdates) return;		// Leave if sequence updating should not happen.

	NSMutableArray* misplacedNodes = [NSMutableArray arrayWithCapacity: nodes.count];
	CC3Camera* cam = visitor.world.activeCamera;
	if (!cam) return;		// Can't do anything without a camera.

	CC3Vector camGlobalLoc = cam.globalLocation;
	GLfloat prevCamDistProduct = CGFLOAT_MAX;

	for (CC3Node* n in nodes) {
		if ( (evaluator && ![evaluator evaluate: n]) ) {
			[misplacedNodes addObject: n];
		} else {
			CC3NodeBoundingVolume* bv = n.boundingVolume;
			if (bv) {
				// Get vector from node's center of geometry to camera.
				CC3Vector node2Cam = CC3VectorDifference(bv.globalCenterOfGeometry, camGlobalLoc);

                // Determine the direction in which to measure from the camera. This will either be
                // in the direction of a straight line between the camera and the node, or will be
                // restricted to the direction "staight-out" from the camera.
                CC3Vector measurementDirection = shouldUseOnlyForwardDistance ? cam.forwardDirection : node2Cam;

                // Cache the dot product of the direction vector, and the vector between the node and the camera.
                // This is a relative measure of the distance in that direction. In the case of measuring along
                // the line between the node and camera, it will be the square of the distance. We don't bother
                // finding the actual distance, because for comparison purposes the square is good enough, and
                // the relatively costly square-root calculation is unnecessary.
				bv.cameraDistanceProduct = CC3VectorDot(node2Cam, measurementDirection);
				
				// If this node is closer than the previous node in the array, update the
				// previous distance value. Otherwise, mark the node as misplaced.
				if (bv.cameraDistanceProduct <= prevCamDistProduct) {
					prevCamDistProduct = bv.cameraDistanceProduct;
				} else {
					[misplacedNodes addObject: n];
				}
			} else {		// If no bounding volume, mark the node as misplaced.
				[misplacedNodes addObject: n];
			}
		}
	}
	// Remove all misplaced nodes from this node array, and add them to the visitor's cache.
	for (CC3Node* n in misplacedNodes) {
		[nodes removeObjectIdenticalTo: n];
	}
	[visitor addMisplacedNodes: misplacedNodes];
}

@end


#pragma mark -
#pragma mark CC3MeshNodeArraySequencer

@implementation CC3MeshNodeArraySequencer

-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	return aNode.isMeshNode && [super add: aNode withVisitor: visitor];
}

/**
 * Nodes are always instances of CC3MeshNode, so cast them as such
 * and invoke the shouldInsertMeshNode:between:and:withVisitor: template method.
 */
-(BOOL) shouldInsertNode: (CC3Node*) aNode
				 between: (CC3Node*) leftNode
					 and: (CC3Node*) rightNode
			 withVisitor: (CC3NodeSequencerVisitor*) visitor {
	return [self shouldInsertMeshNode: (CC3MeshNode*)aNode
						   between: (CC3MeshNode*)leftNode
							   and: (CC3MeshNode*)rightNode
					   withVisitor: visitor];
}

-(BOOL) shouldInsertMeshNode: (CC3MeshNode*) aNode
					 between: (CC3MeshNode*) leftNode
						 and: (CC3MeshNode*) rightNode
				 withVisitor: (CC3NodeSequencerVisitor*) visitor {
	return NO;
}

@end


#pragma mark -
#pragma mark CC3MeshNodeArraySequencerGroupTextures

@implementation CC3MeshNodeArraySequencerGroupTextures

-(BOOL) shouldInsertMeshNode: (CC3MeshNode*) aNode
					 between: (CC3MeshNode*) leftNode
						 and: (CC3MeshNode*) rightNode
				 withVisitor: (CC3NodeSequencerVisitor*) visitor {
	
	//if just starting, skip because we never insert at beginning
	if (leftNode == nil) return NO;
	
	// If the left texture is the same, but the right one isn't,
	// this is where we want to insert to keep like textures together.
	CCTexture2D* tex = aNode.material.texture.texture;
	CCTexture2D* leftTex = leftNode.material.texture.texture;
	CCTexture2D* rightTex = rightNode.material.texture.texture;
	return (tex == leftTex && tex != rightTex);
}

@end


#pragma mark -
#pragma mark CC3MeshNodeArraySequencerGroupMeshes

@implementation CC3MeshNodeArraySequencerGroupMeshes

-(BOOL) shouldInsertMeshNode: (CC3MeshNode*) aNode
					 between: (CC3MeshNode*) leftNode
						 and: (CC3MeshNode*) rightNode
				 withVisitor: (CC3NodeSequencerVisitor*) visitor {
	
	//if just starting, skip because we never insert at beginning
	if (leftNode == nil) return NO;
	
	// If the left mesh is the same, but the right one isn't,
	// this is where we want to insert to keep like meshes together.
	CC3Mesh* mesh = aNode.mesh;
	CC3Mesh* leftMesh = leftNode.mesh;
	CC3Mesh* rightMesh = rightNode.mesh;
	return (mesh == leftMesh && mesh != rightMesh);
}

@end


#pragma mark -
#pragma mark CC3NodeSequencerVisitor

@implementation CC3NodeSequencerVisitor

@synthesize world;

-(void) dealloc {
	world = nil;				// not retained
	[super dealloc];
}

-(id) initWithWorld: (CC3World*) aCC3World {
	if ( (self = [super init]) ) {
		world = aCC3World;
	}
	return self;
}

+(id) visitorWithWorld: (CC3World*) aCC3World {
	return [[[self alloc] initWithWorld: aCC3World] autorelease];
}

@end



#pragma mark -
#pragma mark CC3NodeSequencerMisplacedNodeVisitor

@implementation CC3NodeSequencerMisplacedNodeVisitor

@synthesize misplacedNodes;

-(void) dealloc {
	[misplacedNodes release];
	[super dealloc];
}

-(BOOL) hasMisplacedNodes {
	return (misplacedNodes.count > 0);
}

-(id) initWithWorld: (CC3World*) aCC3World {
	if ( (self = [super initWithWorld: aCC3World]) ) {
		misplacedNodes = [[NSMutableArray array] retain];
	}
	return self;
}

-(void) addMisplacedNodes: (NSArray*) anArrayOfNodes {
	[misplacedNodes addObjectsFromArray: anArrayOfNodes];
}

@end
