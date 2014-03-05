/*
 * CC3NodeSequencer.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3BoundingVolumes.h"
#import "CC3Scene.h"
#import "CC3CC2Extensions.h"

#pragma mark -
#pragma mark CC3NodeEvaluator

@implementation CC3NodeEvaluator

-(BOOL) evaluate: (CC3Node*) aNode { return NO; }

+(id) evaluator { return [[[self alloc] init] autorelease]; }

-(void) populateFrom: (CC3NodeEvaluator*) another {}

-(id) copyWithZone: (NSZone*) zone {
	CC3NodeEvaluator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }

@end


#pragma mark -
#pragma mark CC3NodeRejector

@implementation CC3NodeRejector
@end


#pragma mark -
#pragma mark CC3NodeAcceptor

@implementation CC3NodeAcceptor

-(BOOL) evaluate: (CC3Node*) aNode { return YES; }

@end


#pragma mark -
#pragma mark CC3LocalContentNodeEvaluator

@implementation CC3LocalContentNodeEvaluator

-(BOOL) evaluate: (CC3Node*) aNode {
	if ( !aNode.hasLocalContent ) return NO;
	return [self evaluateLocalContentNode: (CC3LocalContentNode*)aNode];
}

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode { return NO; }

@end


#pragma mark -
#pragma mark CC3LocalContentNodeAcceptor

@implementation CC3LocalContentNodeAcceptor

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode { return YES; }

@end


#pragma mark -
#pragma mark CC3OpaqueNodeAcceptor

@implementation CC3OpaqueNodeAcceptor

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode { return lcNode.isOpaque; }

@end


#pragma mark -
#pragma mark CC3TranslucentNodeAcceptor

@implementation CC3TranslucentNodeAcceptor

-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode { return !lcNode.isOpaque; }

@end


#pragma mark -
#pragma mark CC3NodeSequencer

@implementation CC3NodeSequencer

@synthesize evaluator=_evaluator, allowSequenceUpdates=_allowSequenceUpdates;

-(void) dealloc {
	[_evaluator release];
	[super dealloc];
}

-(NSArray*) nodes { return [NSArray array]; }

-(BOOL) shouldUseOnlyForwardDistance { return NO; }

-(void) setShouldUseOnlyForwardDistance: (BOOL) onlyForward {}


#pragma mark Allocation and initialization

-(id) init { return [self initWithEvaluator: nil]; }

+(id) sequencer { return [[[self alloc] init] autorelease]; }

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super init]) ) {
		self.evaluator = anEvaluator;
		_allowSequenceUpdates = YES;
	}
	return self;
}

+(id) sequencerWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	return [[[self alloc] initWithEvaluator: anEvaluator] autorelease];
}


#pragma mark Sequencing nodes

-(void) populateFrom: (CC3NodeSequencer*) another {
	_allowSequenceUpdates = another.allowSequenceUpdates;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3NodeSequencer* aCopy = [[[self class] allocWithZone: zone]
							   initWithEvaluator: [_evaluator autoreleasedCopy]];
	[aCopy populateFrom: self];
	return aCopy;
}

-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor { return NO; }

-(BOOL) remove: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor { return NO; }

-(BOOL) updateSequenceWithVisitor: (CC3NodeSequencerVisitor*) visitor {
	[self identifyMisplacedNodesWithVisitor: visitor];
	if (visitor.hasMisplacedNodes) {
		LogTrace(@"%@ detected %u misplaced nodes: %@",
				 self, visitor.misplacedNodes.count, visitor.misplacedNodes);
		for(CC3Node* aNode in visitor.misplacedNodes) {
			if ([self remove: aNode withVisitor: visitor])
				[self add: aNode withVisitor: visitor];
		}
		[visitor clearMisplacedNodes];
		return YES;
	}
	return NO;
}

-(void) identifyMisplacedNodesWithVisitor: (CC3NodeSequencerVisitor*) visitor {}

-(void) visitNodesWithNodeVisitor: (CC3NodeVisitor*) nodeVisitor {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with evaluator %@", [self class], _evaluator];
}

-(NSString*) fullDescription { return self.description; }

@end


#pragma mark -
#pragma mark CC3BTreeNodeSequencer

@implementation CC3BTreeNodeSequencer

@synthesize sequencers=_sequencers;

-(void) dealloc {
	[_sequencers release];
	[super dealloc];
}

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super initWithEvaluator: anEvaluator]) ) {
		_sequencers = [NSMutableArray new];		// retained
	}
	return self;
}

-(void) populateFrom: (CC3BTreeNodeSequencer*) another {
	[super populateFrom: another];

	NSArray* otherChildren = another.sequencers;
	for (CC3NodeSequencer* otherChild in otherChildren)
		[self addSequencer: [otherChild autoreleasedCopy]];
}

-(void) addSequencer: (CC3NodeSequencer*) aNodeSequencer {
	[_sequencers addObject: aNodeSequencer];
}

/** Iterates through the sequencers, adding it to the first one that accepts the node. */
-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	if ( _evaluator && [_evaluator evaluate: aNode] )
		for (CC3NodeSequencer* s in _sequencers)
			if ([s add: aNode withVisitor: visitor]) return YES;
	return NO;
}

/** Iterates through the sequencers, asking each to remove the node. */
-(BOOL) remove: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	for (CC3NodeSequencer* s in _sequencers)
		if ([s remove: aNode withVisitor: visitor]) return YES;
	return NO;
}

/** Iterates through the sequencers, collecting misplaced nodes in the visitor. */
-(void) identifyMisplacedNodesWithVisitor: (CC3NodeSequencerVisitor*) visitor {
	if (_allowSequenceUpdates)
		for (CC3NodeSequencer* s in _sequencers)
			[s identifyMisplacedNodesWithVisitor: visitor];
}

-(void) visitNodesWithNodeVisitor: (CC3NodeVisitor*) aNodeVisitor {
	for (CC3NodeSequencer* s in _sequencers) [s visitNodesWithNodeVisitor: aNodeVisitor];
}

/** Concatenates the nodes from the contained sequencers into one array. */
-(NSArray*) nodes {
	NSMutableArray* nodes = [NSMutableArray array];
	for (CC3NodeSequencer* s in _sequencers) [nodes addObjectsFromArray: s.nodes];
	return nodes;
}

-(BOOL) shouldUseOnlyForwardDistance {
	for (CC3NodeSequencer* s in _sequencers)
		if (s.shouldUseOnlyForwardDistance) return YES;
	return NO;
}

-(void) setShouldUseOnlyForwardDistance: (BOOL) onlyForward {
	for (CC3NodeSequencer* s in _sequencers) s.shouldUseOnlyForwardDistance = onlyForward;
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", [super fullDescription]];
	for (CC3NodeSequencer* s in _sequencers)
		[desc appendFormat: @"\n%@", [s fullDescription]];
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
	[_nodes release];
	[super dealloc];
}

-(NSArray*) nodes { return [NSArray arrayWithArray: _nodes]; }

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super initWithEvaluator: anEvaluator]) ) {
		_nodes = [NSMutableArray new];		// retained
	}
	return self;
}

/**
 * Iterates through the existing nodes, passing them as sequential pairs, along with the node
 * to be added, to the shouldInsertNode:between:and:withVisitor: template method. If that method
 * returns YES, the node is inserted into the array at that point. If that method never returns
 * YES, the node is added at the end of the array. Returns whether the node was added.
 */
-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor {
	if ( _evaluator && [_evaluator evaluate: aNode] ) {
		NSUInteger nodeCount = _nodes.count;
		for (NSUInteger i = 0; i < nodeCount; i++) {
			CC3Node* leftNode = i > 0 ? [_nodes objectAtIndex: i - 1] : nil;
			CC3Node* rightNode = [_nodes objectAtIndex: i];
			CC3Assert(aNode != rightNode, @"%@ already contains %@!", self, aNode);
			if ( [self shouldInsertNode: aNode
								between: leftNode
									and: rightNode
							withVisitor: visitor] ) {
				[_nodes insertObject: aNode atIndex: i];
				return YES;
			}
		}
		[_nodes addObject: aNode];
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
	NSUInteger nodeIndex = [_nodes indexOfObjectIdenticalTo: aNode];
	if (nodeIndex != NSNotFound) {
		[_nodes removeObjectAtIndex: nodeIndex];
		return YES;
	}
	return NO;
}

-(void) identifyMisplacedNodesWithVisitor: (CC3NodeSequencerVisitor*) visitor {
	// Leave if sequence updating should not happen or if there is nothing to sort.
	if (!_allowSequenceUpdates || _nodes.count == 0) return;

	for (CC3Node* aNode in _nodes)
		if ( !(_evaluator && [_evaluator evaluate: aNode]) )
			[visitor addMisplacedNode: aNode];
}

-(void) visitNodesWithNodeVisitor: (CC3NodeVisitor*) aNodeVisitor {
	for (CC3Node* aNode in _nodes) [aNodeVisitor visit: aNode];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ with nodes: %@", [super fullDescription], [_nodes fullDescription]];
}

@end


#pragma mark -
#pragma mark CC3NodeArrayZOrderSequencer

@implementation CC3NodeArrayZOrderSequencer

@synthesize shouldUseOnlyForwardDistance=_shouldUseOnlyForwardDistance;

-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator {
	if ( (self = [super initWithEvaluator: anEvaluator]) ) {
		_shouldUseOnlyForwardDistance = NO;
	}
	return self;
}

-(void) populateFrom: (CC3NodeArrayZOrderSequencer*) another {
	[super populateFrom: another];
	_shouldUseOnlyForwardDistance = another.shouldUseOnlyForwardDistance;
}

/**
 * If either the Z-order of the node of interest is greater than the Z-order of the rightNode,
 * or the Z-order is equal, and the distance from the node of interest to the camera is greater
 * than the distance from the rightNode to the camera, return YES, otherwise return NO.
 * 
 * Since the array is traversed from front to back, the node will have already been tested
 * against the leftNode. Nodes without a boundingVolume are added to the end of the array.
 */
-(BOOL) shouldInsertNode: (CC3Node*) aNode
				 between: (CC3Node*) leftNode
					 and: (CC3Node*) rightNode
			 withVisitor: (CC3NodeSequencerVisitor*) visitor {

	// Check explicit Z-Order first. It overrides camera distance.
	if (aNode.zOrder > rightNode.zOrder) return YES;
	if (aNode.zOrder < rightNode.zOrder) return NO;

	// Next check camera distance based on bounding volume centers.
	return (aNode.cameraDistanceProduct >= rightNode.cameraDistanceProduct);
}

/**
 * Identify nodes that do not pass the evaluator or are not in the correct Z-order sequence.
 * Any node whose distance to the camera is greater than the nodes before it is considered misplaced.
 */
-(void) identifyMisplacedNodesWithVisitor: (CC3NodeSequencerVisitor*) visitor {
	// Leave if sequence updating should not happen or if there is nothing to sort.
	if (!_allowSequenceUpdates || _nodes.count == 0) return;

	CC3Camera* cam = visitor.scene.activeCamera;
	if (!cam) return;		// Can't do anything without a camera.

	CC3Vector camGlobalLoc = cam.globalLocation;
	GLint prevZOrder = kCC3MaxGLint;
	GLfloat prevCamDistProduct = kCC3MaxGLfloat;

	for (CC3Node* aNode in _nodes) {
		if ( !(_evaluator && [_evaluator evaluate: aNode]) )
			[visitor addMisplacedNode: aNode];
		else {
			// Get vector from node's center of geometry to camera.
			CC3Vector node2Cam = CC3VectorDifference(aNode.globalCenterOfGeometry, camGlobalLoc);
			
			// Determine the direction in which to measure from the camera. This will either be
			// in the direction of a straight line between the camera and the node, or will be
			// restricted to the direction "staight-out" from the camera.
			CC3Vector measureDir = _shouldUseOnlyForwardDistance ? cam.forwardDirection : node2Cam;
			
			// Cache the dot product of the direction vector, and the vector between the node
			// and the camera. This is a relative measure of the distance in that direction.
			// In the case of measuring along the line between the node and camera, it will be
			// the square of the distance. Comparing the squares of the distance instead of the
			// distance itself also has the benefit of avoiding expensive square-root calculations.
			GLfloat camDistProd = CC3VectorDot(node2Cam, measureDir);
			aNode.cameraDistanceProduct = camDistProd;

			// If this node is closer than the previous node in the array, update the
			// previous Z-order and distance value. Otherwise, mark the node as misplaced.
			// Explicit Z-order overrides actual distance.
			if ( aNode.zOrder < prevZOrder ) {
				prevZOrder = aNode.zOrder;
				prevCamDistProduct = camDistProd;
			} else if ( aNode.zOrder > prevZOrder )
				[visitor addMisplacedNode: aNode];
			  else if ( camDistProd <= prevCamDistProduct ) {
				prevZOrder = aNode.zOrder;
				prevCamDistProduct = camDistProd;
			} else
				[visitor addMisplacedNode: aNode];
		}
	}
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
				 withVisitor: (CC3NodeSequencerVisitor*) visitor { return NO; }

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
	CC3Texture* tex = aNode.texture;
	CC3Texture* leftTex = leftNode.texture;
	CC3Texture* rightTex = rightNode.texture;
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

@synthesize scene=_scene, misplacedNodes=_misplacedNodes;

-(void) dealloc {
	_scene = nil;		// weak reference
	[_misplacedNodes release];
	[super dealloc];
}

-(id) init { return [self initWithScene: nil]; }

-(id) initWithScene: (CC3Scene*) aCC3Scene {
	if ( (self = [super init]) ) {
		_scene = aCC3Scene;							// weak reference
		_misplacedNodes = [NSMutableArray new];		// retained
	}
	return self;
}

+(id) visitorWithScene: (CC3Scene*) aCC3Scene {
	return [[[self alloc] initWithScene: aCC3Scene] autorelease];
}

-(BOOL) hasMisplacedNodes { return (_misplacedNodes.count > 0); }

-(void) addMisplacedNode: (CC3Node*) aNode { [_misplacedNodes addObject: aNode]; }

-(void) clearMisplacedNodes { [_misplacedNodes removeAllObjects]; }

// Deprecated
-(CC3Scene*) world { return self.scene; }
-(void) setWorld: (CC3Scene*) aCC3Scene { self.scene = aCC3Scene; }
-(id) initWithWorld: (CC3Scene*) aCC3Scene { return [self initWithScene: aCC3Scene]; }
+(id) visitorWithWorld: (CC3Scene*) aCC3Scene { return [self visitorWithScene: aCC3Scene]; }

@end
