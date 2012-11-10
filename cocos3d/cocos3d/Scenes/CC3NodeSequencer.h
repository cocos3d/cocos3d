/*
 * CC3NodeSequencer.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 */

/** @file */	// Doxygen marker

#import "CC3MeshNode.h"

@class CC3Scene, CC3NodeSequencerVisitor;

#pragma mark -
#pragma mark CC3NodeEvaluator

/**
 * A CC3NodeEvaluator performs some type of accept/reject evaluation on a CC3Node instance.
 * The type of evaluation performed is determined by the subclass of CC3NodeEvaluator.
 * A wide range of subclasses may be constructed to perform a variety of evaluations.
 *
 * The central evaluation method evaluate: returns YES or NO, indicating whether the
 * evaluator accepts or rejects the node.
 */
@interface CC3NodeEvaluator : NSObject <NSCopying> {}

/**
 * Performs the evaluation defined by this class on the specified node and returns
 * YES if the node is accepted, or NO if it is rejected.
 * 
 * This default implementation always returns NO. Subclasses will override.
 */
-(BOOL) evaluate: (CC3Node*) aNode;

/** Allocates and initializes an autoreleased instance. */
+(id) evaluator;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or
 * copyWithZone: method. In most situations, the application should use the
 * copy method, and should never need to invoke this method directly.
 * 
 * Subclasses that add additional instance state (instance variables) should extend
 * copying by overriding this method to copy that additional state. Superclass that
 * override this method should be sure to invoke the superclass implementation to
 * ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3NodeEvaluator*) another;

@end


#pragma mark -
#pragma mark CC3NodeAcceptor

/** A type of CC3NodeEvaluator that accepts all nodes by always returning YES from the evaluate: method. */
@interface CC3NodeAcceptor : CC3NodeEvaluator
@end


#pragma mark -
#pragma mark CC3NodeRejector

/** A type of CC3NodeEvaluator that rejects all nodes by always returning NO from the evaluate: method. */
@interface CC3NodeRejector : CC3NodeEvaluator
@end


#pragma mark -
#pragma mark CC3LocalContentNodeEvaluator

/**
 * A type of CC3NodeEvaluator that specializes in evaluating only CC3Nodes with local content.
 * 
 * The evalute: method checks the hasLocalContent property of the node. If the node does not
 * have local content, the evaluate: method returns NO indicating that the evaluation failed.
 *
 * If the node does have local content, the node is cast to an instance of CC3LocalContentNode
 * and passed to the evaluateLocalContentNode: for further evaluation.
 */
@interface CC3LocalContentNodeEvaluator : CC3NodeEvaluator

/**
 * Performs the evaluation defined by this class on the specified node, which must be a type
 * of CC3LocalContentNode, and returns YES if the node is accepted, or NO if it is rejected.
 *
 * This default implementation simply returns NO, meaning that all CC3LocalContentNodes
 * will be rejected. Since all other nodes have also been rejected by the evaluate: method
 * prior to invoking this method, the effect of this class is to reject all nodes.
 */
-(BOOL) evaluateLocalContentNode: (CC3LocalContentNode*) lcNode;

@end


#pragma mark -
#pragma mark CC3LocalContentNodeAcceptor

/**
 * A type of CC3LocalContentNodeEvaluator that accepts all nodes with local content,
 * and rejects all other nodes.
 */
@interface CC3LocalContentNodeAcceptor : CC3LocalContentNodeEvaluator
@end


#pragma mark -
#pragma mark CC3OpaqueNodeAcceptor

/**
 * A type of CC3LocalContentNodeEvaluator that accepts only opaque nodes.
 * To do this, the evaluateLocalContentNode: method returns YES if the isOpaque
 * property of the CC3LocalContentNode instance is YES.
 */
@interface CC3OpaqueNodeAcceptor : CC3LocalContentNodeEvaluator
@end


#pragma mark -
#pragma mark CC3TranslucentNodeAcceptor

/**
 * A type of CC3LocalContentNodeEvaluator that accepts only translucent nodes.
 * To do this, the evaluateLocalContentNode: method returns YES if the isOpaque
 * property of the CC3LocalContentNode instance is NO.
 */
@interface CC3TranslucentNodeAcceptor : CC3LocalContentNodeEvaluator
@end


#pragma mark -
#pragma mark CC3NodeSequencer

/**
 * A CC3NodeSequencer instance organizes nodes that are added to it. The node sequencer
 * contains a CC3NodeEvaluator to determine whether it is interested in a node when an
 * attempt is made to add the node. Only nodes that are accepted the evaluator will be
 * added to the sequencer.
 *
 * The type of sequencing performed is determined by the subclass of CC3NodeSequencer.
 * A wide range of subclasses may be constructed to perform a variety of sequencing techniques.
 */
@interface CC3NodeSequencer : NSObject <NSCopying> {
	CC3NodeEvaluator* evaluator;
	BOOL allowSequenceUpdates : 1;
}

/**
 * The evaluator that determines whether a node should be added to this sequencer.
 * If no evaluator is attached to this sequencer, no nodes will be added.
 */
@property(nonatomic, retain) CC3NodeEvaluator* evaluator;

/**
 * Returns an array of the nodes that have been added to this sequencer,
 * ordered as this sequencer defines.
 *
 * The returned array is a copy of the any internal arrays.
 * Changing the contents will not change the internal node seqeunce.
 */
@property(nonatomic, readonly) CCArray* nodes;

/**
 * Indicates that the sequencer will run the algorithm to relocate misplaced nodes
 * when the updateSequenceWithVisitor: method is invoked. Setting this property to NO means
 * that when updateSequenceWithVisitor: is invoked, on this or a parent sequencer, no attempt
 * will be made to move misplaced nodes in this sequencer to their correct drawing
 * sequence position.
 *
 * Initially, this property is set to YES to ensure nodes are always in their correct
 * drawing sequence position, to avoid unexpected visual artifacts.
 *
 * However, the updateSequenceWithVisitor: method is invoked on each drawing frame, and checks
 * each drawable node. You may find performance improvements by setting this property to
 * NO on some sequencers, if you know that the nodes contained in a particular sequencer
 * will not be moved out of that sequencer, or re-sorted within that sequencer, and you want
 * to save the overhead of checking each node on each drawing frame.
 *
 * If you have set this property to NO, you can still force a node to be re-positioned to its
 * correct drawing sequence position by invoking the checkDrawingOrder method on the node.
 */
@property(nonatomic, assign) BOOL allowSequenceUpdates;

/**
 * For sequencers that order nodes based on distance to the camera, indicates whether,
 * when comparing distances from the nodes to the camera, only the distance component
 * that is parallel to the camera's forwardDirection should be considered.
 *
 * If the value of this property is NO, nodes will be sorted based on the true 3D
 * straight-line distance from each node to the camera, as if drawing a measuring tape
 * from the location of the camera to the location of the center of geometry of the node.
 * This is the most common 3D scenario.
 *
 * If the value of this property is YES, nodes will be sorted based on the shortest
 * distance from the camera to a plane that is perpendicular to the forwardDirection
 * of the camera and contains the location of the node. This has the effect of sorting
 * nodes based on their distance "straight-out" from the camera, ignoring distance
 * contributed by nodes that are "off to the side" of the camera's view. This option
 * is good for scenes that are built from large planar nodes that move in layers at
 * fixed distances from a fixed camera, similar to cell-animation techniques.
 *
 * The initial value for this property is NO, indicating that the true 3D distance
 * between the camera and the center of geometry of the node will be used to determine
 * drawing order. Unless your 3D scene is using special cell-animation techniques with
 * large planar nodes, you should not change the value of this property.
 *
 * In this default abstract implmentation, the value returned is always returned as NO,
 * and values set in this property are ignored. Subclasses that sort based on Z-order,
 * and subclasses that contain such other sequencers will override.
 */
@property(nonatomic, assign) BOOL shouldUseOnlyForwardDistance;


#pragma mark Allocation and initialization

/**
 * Allocates and initializes an autoreleased instance with no evaluator.
 * This sequencer will not accept any nodes until an evaluator is attached.
 */
+(id) sequencer;

/** Initializes this instance with the specified evaluator. */
-(id) initWithEvaluator: (CC3NodeEvaluator*) anEvaluator;

/** Allocates and initializes an autoreleased instance with the specified evaluator. */
+(id) sequencerWithEvaluator: (CC3NodeEvaluator*) anEvaluator;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or
 * copyWithZone: method. In most situations, the application should use the
 * copy method, and should never need to invoke this method directly.
 * 
 * Subclasses that add additional instance state (instance variables) should extend
 * copying by overriding this method to copy that additional state. Superclass that
 * override this method should be sure to invoke the superclass implementation to
 * ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3NodeSequencer*) another;


#pragma mark Sequencing nodes

/**
 * Adds the specified node to this sequencer if the node is accepted by the
 * contained evaluator. If the node is rejected by the evaluator, it is not added.
 * Returns whether the node was added.
 */
-(BOOL) add: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor;

/**
 * Removes the specified node, if it exists within this sequencer,
 * and returns whether it was removed.
 */
-(BOOL) remove: (CC3Node*) aNode withVisitor: (CC3NodeSequencerVisitor*) visitor;

/**
 * Invokes the identifyMisplacedNodesWithVisitor: method on this sequencer to
 * look for nodes that are "misplaced", then removes and re-adds those misplaced
 * nodes back into this sequencer, so that they can be inserted into their correct
 * sequence position.
 *
 * This method is invoked automatically from the CC3Scene on each drawing frame.
 * The application should never need to invoke this method directly.
 */
-(BOOL) updateSequenceWithVisitor: (CC3NodeSequencerVisitor*) visitor;

/**
 * If the allowSequenceUpdates is set to YES, looks for nodes that are misplaced in
 * this sequencer, and adds them to the misplacedNodes property of the specified visitor. 
 *
 * What it means for a node to be "misplaced" is defined by the sequencer subclass.
 * A sequencer subclass may determine that the node no longer meets the criteria
 * of the sequencer's evaluator, or that the node is now out of order, relative to
 * the sorting or grouping criteria defined by the sequencer.
 *
 * The default behaviour is to do nothing. Subclasses will override as necessary.
 *
 * This method is invoked automatically by the updateSequenceWithVisitor: method.
 * The application should never need to invoke this method directly.
 */
-(void) identifyMisplacedNodesWithVisitor: (CC3NodeSequencerVisitor*) visitor;

/**
 * Visits the nodes contained in this node sequencer with the specified node visitor.
 * The nodes are visited in the order that they are sequenced by this node sequencer.
 *
 * Note that the argument is a CC3NodeVisitor, not a CC3NodeSequencerVisitor as with
 * other methods on this class.
 *
 * The default implementation does nothing. Subclasses that contain nodes, or contain
 * other sequencers that contain nodes, will override.
 */
-(void) visitNodesWithNodeVisitor: (CC3NodeVisitor*) aNodeVisitor;

/** Returns a string containing a more complete description of this object. */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark CC3BTreeNodeSequencer

/**
 * An CC3BTreeNodeSequencer is a type of CC3NodeSequencer that separates nodes into a
 * B-tree structure of child sequencers.
 *
 * When a node is added, it is first evaluated by the contained evaluator. If it is accepted,
 * the sequencer iterates through the contained child sequencers, in the order that the
 * child sequencers were added, attempting to add the node to each child sequencer in turn.
 * The node is added to the first child sequencer that accepts it.
 *
 * Instances of CC3BTreeNodeSequencer can be used to group nodes by some parent criteria
 * while allowing the nodes to be further grouped within each child grouping.
 *
 * Setting the property shouldUseOnlyForwardDistance sets the same value in each child sequencer.
 * Reading that property returns YES if any child sequencer returns YES, otherwise it returns NO.
 */
@interface CC3BTreeNodeSequencer : CC3NodeSequencer {
	CCArray* sequencers;
}

/** The array of child sequencers. */
@property(nonatomic, readonly) CCArray* sequencers;

/** Adds the specified sequencer as a child sequencer. */
-(void) addSequencer: (CC3NodeSequencer*) aNodeSequencer;

/**
 * Allocates and initializes an autoreleased instance that accepts only nodes that have
 * local content to draw, and sequences them so that all the opaque nodes appear before
 * all the translucent nodes.
 * 
 * The opaque nodes are sorted in the order they are added. The translucent nodes are
 * sorted by their distance from the camera, from furthest from the camera to closest.
 */
+(id) sequencerLocalContentOpaqueFirst;

/**
 * Allocates and initializes an autoreleased instance that accepts only nodes that have
 * local content to draw, and sequences them so that all the opaque nodes appear before
 * all the translucent nodes.
 * 
 * The opaque nodes are grouped by texture, so that all nodes with the same texture
 * appear together. The translucent nodes are sorted by their distance from the camera,
 * from furthest from the camera to closest.
 */
+(id) sequencerLocalContentOpaqueFirstGroupTextures;

/**
 * Allocates and initializes an autoreleased instance that accepts only nodes that have
 * local content to draw, and sequences them so that all the opaque nodes appear before
 * all the translucent nodes.
 * 
 * The opaque nodes are grouped by mesh, so that all nodes with the same mesh appear
 * together. The translucent nodes are sorted by their distance from the camera, from
 * furthest from the camera to closest.
 */
+(id) sequencerLocalContentOpaqueFirstGroupMeshes;

@end


#pragma mark -
#pragma mark CC3NodeArraySequencer

/**
 * An CC3NodeArraySequencer is a type of CC3NodeSequencer that arranges nodes into an
 * array, and orders the nodes in the array by some criteria.
 *
 * When a node is added, it is first evaluated by the contained evaluator. If it is
 * accepted, the sequencer iterates through the existing nodes that it holds, invoking
 * the template method shouldInsertNode:between:and:withVisitor: on each pair of
 * sequential existing nodes, looking for the place to insert the new node. The node
 * is inserted the first time that template method returns YES. If not suitable
 * insertion point is found, the node is added to the end of the array.
 *
 * This base class simply arranges the nodes in the order they are presented, by always
 * adding to the end of the contained array of nodes. Subclasses will customize the way
 * that the nodes are ordered and grouped in the array.
 *
 * The contents of the nodes array are not copied when this sequencer is copied.
 */
@interface CC3NodeArraySequencer : CC3NodeSequencer {
	CCArray* nodes;
}

/**
 * Attempts to insert the specified node between two specified nodes that already exist
 * in the array, and returns whether it was inserted at that location.
 * 
 * This default implementation always returns NO, resulting in each node always being added
 * to the end of the array.
 */
-(BOOL) shouldInsertNode: (CC3Node*) aNode
				 between: (CC3Node*) leftNode
					 and: (CC3Node*) rightNode
			 withVisitor: (CC3NodeSequencerVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3NodeArrayZOrderSequencer

/**
 * An CC3NodeArrayZOrderSequencer is a type of CC3NodeArraySequencer that sorts
 * the contained nodes by their Z-order, which is a combination of the explicit
 * Z-order property of each node, and a measure of the distance from the camera
 * to the globalCenterOfGravity of the node's bounding volume.
 *
 * Use this sequencer for translucent nodes. There is no need to use this sequencer
 * for nodes that are opaque (whose isOpaque property returns YES), and the overhead
 * of testing each node on each update should be avoided in that case.
 *
 * The nodes are sorted using the Z-order property and the cameraDistanceProduct
 * property of the boundingVolume of each node, from furthest from the camera to
 * closest. Nodes without a boundingVolume are added to the end of the array.
 *
 * Explicit Z-order sequence takes priority over distance to camera. However,
 * sorting based on distance to the camera alone is quite effective. In almost all
 * cases, it is not necessary to set the Z-order property of the nodes, and if the
 * nodes are moving around, assigning an explicit Z-order to each node can actually
 * interfere with the dynamic determination of the correct drawing order. Only use
 * the Z-order property if you have reason to force a specific node to be drawn
 * before or after another node for visual effect.
 *
 * The distance between a node and the camera can be measured in one of two ways:
 *   -# The true 3D straight-line distance between the node and the camera.
 *   -# The distance from the camera to the node measured "straight out" from the
 *      camera, ignoring how far the node is away from the center of the camera's view.
 *
 * The value of the shouldUseOnlyForwardDistance property determines which of these two
 * methods will be used. See the notes of that property in the CC3NodeSequencer for more
 * information. By default, the true 3D distance is used.
 *
 * Since all nodes, and the camera, can move around on each update, this sequencer will
 * test and re-order its nodes on each update.
 *
 * Be careful about setting the allowSequenceUpdates property to NO on this sequencer.
 * Since this sequencer will generally only be used to keep translucent nodes in their
 * correct drawing order, setting allowSequenceUpdates to NO will defeat the purpose,
 * and will result in translucent nodes not properly displaying other translucent
 * objects that are behind them.
 */
@interface CC3NodeArrayZOrderSequencer : CC3NodeArraySequencer {
    BOOL shouldUseOnlyForwardDistance;
}

@end


#pragma mark -
#pragma mark CC3MeshNodeArraySequencer

/**
 * An CC3MeshNodeArraySequencer is a type of CC3NodeArraySequencer that only accepts
 * mesh nodes, in addition to whatever other evaluation criteria is set by the
 * evaluator property. This is a convenience class that allows many mesh-oriented
 * subclasses to be easily created.
 *
 * For subclass convenience, since this sequencer only accepts mesh nodes, the
 * implementation of the template method shouldInsertNode:between:and:withVisitor:
 * casts the nodes to CC3MeshNode and delegates to the
 * shouldInsertMeshNode:between:and:withVisitor: method.
 *
 * This base class simply arranges the nodes in the order they are presented.
 * Subclasses will customize the way that the nodes are ordered and grouped in the array.
 */
@interface CC3MeshNodeArraySequencer : CC3NodeArraySequencer

/**
 * Attempts to insert the specified node between two specified nodes that already exist
 * in the array, and returns whether it was inserted at that location.
 * 
 * This default implementation always returns NO, resulting in each node always being added
 * to the end of the array.
 */
-(BOOL) shouldInsertMeshNode: (CC3MeshNode*) aNode
					 between: (CC3MeshNode*) leftNode
						 and: (CC3MeshNode*) rightNode
				 withVisitor: (CC3NodeSequencerVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3MeshNodeArraySequencerGroupTextures

/**
 * An CC3MeshNodeArraySequencerGroupTextures is a type of CC3MeshNodeArraySequencer that
 * groups together nodes that are using the same texture.
 */
@interface CC3MeshNodeArraySequencerGroupTextures : CC3MeshNodeArraySequencer
@end


#pragma mark -
#pragma mark CC3MeshNodeArraySequencerGroupMeshes

/**
 * An CC3MeshNodeArraySequencerGroupTextures is a type of CC3MeshNodeArraySequencer that
 * groups together nodes that are using the same mesh.
 */
@interface CC3MeshNodeArraySequencerGroupMeshes : CC3MeshNodeArraySequencer
@end


#pragma mark -
#pragma mark CC3NodeSequencerVisitor

/**
 * This visitor is used to visit CC3NodeSequencers to perform operations on nodes
 * within the sequencers.
 *
 * The visitor maintains a reference to the CC3Scene, so that the sequencer may
 * use aspects of the scene during operations.
 *
 * This visitor can be used to visit CC3NodeSequencers to detect and keep track of
 * nodes that are misplaced within the sequencer, using the updateSequenceWithVisitor:
 * method on the sequencer.
 *
 * What it means for a node to be "misplaced" is defined by the sequencer itself.
 * A sequencer may determine that the node no longer meets the criteria of the
 * sequencer's evaluator, or that the node is now out of order, relative to the
 * sorting or grouping criteria defined by the sequencer.
 *
 * A sequencer visitor can either be instantiated for a single visitation of a sequencer,
 * or can be instantiated once and reused to visit different sequencers over and over.
 * In doing so, you should invoke the reset method on the sequencer visitor prior to
 * using it to visit a sequencer.
 */
@interface CC3NodeSequencerVisitor : NSObject {
	CC3Scene* scene;
	CCArray* misplacedNodes;
}

/**
 * The CC3Scene instance. The sequencer may use aspects of the scene when
 * performing sequencing operations with a node.
 */
@property(nonatomic, assign) CC3Scene* scene;

/** Initializes this instance with the specified CC3Scene. */
-(id) initWithScene: (CC3Scene*) aCC3Scene;

/** Allocates and initializes an autoreleased instance with the specified CC3Scene. */
+(id) visitorWithScene: (CC3Scene*) aCC3Scene;

/** @deprecated Renamed to scene. */
@property(nonatomic, assign) CC3Scene* world DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to initWithScene:. */
-(id) initWithWorld: (CC3Scene*) aCC3Scene DEPRECATED_ATTRIBUTE;

/** @deprecated Renamed to visitorWithScene:. */
+(id) visitorWithWorld: (CC3Scene*) aCC3Scene DEPRECATED_ATTRIBUTE;

/** Indicates whether the misplacedNodes property contains nodes. */
@property(nonatomic, readonly) BOOL hasMisplacedNodes;

/**
 * Returns an array of nodes that the sequencer deems to be misplaced after
 * being visited by this visitor.
 *
 * The returned array may be nil.
 */
@property(nonatomic, readonly) CCArray* misplacedNodes;

/** Adds the specified node to the array of nodes held in the misplacedNodes property */
-(void) addMisplacedNode: (CC3Node*) aNode;

/** Clears the misplacedNodes array. */
-(void) clearMisplacedNodes;

@end
