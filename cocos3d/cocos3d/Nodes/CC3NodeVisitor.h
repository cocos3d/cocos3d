/*
 * CC3NodeVisitor.h
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


#import "CC3Matrix.h"
#import "CC3PerformanceStatistics.h"

@class CC3NodeSequencer, CC3Camera;


#pragma mark -
#pragma mark CC3NodeVisitor

@class CC3Node, CC3Scene;

/**
 * A CC3NodeVisitor is a context object that is passed to a node when it is visited
 * during a traversal of the node hierarchy.
 *
 * To initiate a visitation run, invoke the visit: method on any CC3Node.
 *
 * Subclasses will override template methods to customize the behaviour prior to, during,
 * and after the node traversal.
 *
 * If a node is to be removed from the node structural hierarchy during a visitation run,
 * the requestRemovalOf: method can be used instead of directly invoking the remove method
 * on the node itself. A visitation run involves iterating through collections of child
 * nodes, and removing a node during the iteration of a collection raises an error.
 */
@interface CC3NodeVisitor : NSObject {
	CC3Node* startingNode;
	CC3Node* currentNode;
	CCArray* pendingRemovals;
	CC3Camera* camera;
	BOOL shouldVisitChildren : 1;
}

/**
 * Indicates whether this visitor should traverse the child nodes of any node it visits.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldVisitChildren;

/**
 * The CC3Node that is currently being visited. 
 *
 * This property is only valid during the traversal of the node returned by this property,
 * and will be nil both before and after the visit: method is invoked on the node.
 */
@property(nonatomic, readonly) CC3Node* currentNode;

/**
 * The CC3Node on which this visitation traversal was intitiated. This is the node
 * on which the visit: method was first invoked to begin a traversal of the node
 * structural hierarchy. 
 *
 * This property is only valid during the traversal, and will be nil both before
 * and after the visit: method is invoked.
 */
@property(nonatomic, readonly) CC3Node* startingNode;

/**
 * The performanceStatistics being accumulated during the visitation runs.
 *
 * This is extracted from the startingNode, and may be nil if that node
 * is not collecting statistics.
 */
@property(nonatomic, readonly) CC3PerformanceStatistics* performanceStatistics;

/**
 * Visits the specified node, then if the shouldVisitChildren property is set to YES,
 * invokes this visit: method on each child node as well.
 *
 * Subclasses will override several template methods to customize node visitation behaviour.
 */
-(void) visit: (CC3Node*) aNode;

/**
 * Requests the removal of the specfied node.
 * 
 * During a visitation run, to remove a node from the hierarchy, you must use this method
 * instead of directly invoking the remove method on the node itself. Visitation involves
 * iterating through collections of child nodes, and removing a node during the iteration
 * of a collection raises an error.
 *
 * This method can safely be invoked while a node is being visited. The visitor keeps
 * track of the requests, and safely removes all requested nodes as part of the close
 * method, once the visitation of the full node assembly is finished.
 */
-(void) requestRemovalOf: (CC3Node*) aNode;

/**
 * The camera that is viewing the 3D scene.
 *
 * Access to the active camera is needed for many node visitations, such as updates and drawing.
 * If this property is not set in advance, it is retrieved automatically from the activeCamera
 * property of the starting node, at the beginning of a visitation run.
 *
 * This property is cleared at the end of each visitation run to ensure that the camera that is
 * currently active is always used.
 */
@property(nonatomic, assign) CC3Camera* camera;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) visitor;

/** Returns a more detailed description of this instance. */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark CC3NodeTransformingVisitor

/**
 * CC3NodeTransformingVisitor is a CC3NodeVisitor that is passed to a node when it is
 * visited during transformation operations.
 *
 * This visitor encapsulates whether the transformation matrix needs to be recalculated.
 * The transformation matrix needs to be recalculated if any of the node's transform properties
 * (location, rotation, scale) have changed, or if those of an ancestor node were changed.
 *
 * The transforms can be calculated from the CC3Scene or from the startingNode, depending
 * on the value of the shouldLocalizeToStartingNode property. Normally, the transforms
 * are calculated from the CC3Scene, but localizing to the startingNode can be useful for
 * determining relative transforms between ancestors and descendants.
 */
@interface CC3NodeTransformingVisitor : CC3NodeVisitor {
	BOOL isTransformDirty : 1;
	BOOL shouldLocalizeToStartingNode : 1;
	BOOL shouldRestoreTransforms : 1;
}

/**
 * Indicates whether all transforms should be localized to the local coordinate system
 * of the startingNode.
 *
 * If this property is set to NO, the transforms of all ancestors of each node, all the
 * way to CC3Scene, will be included when calculating the transformMatrix and global
 * properties of that node. This is the normal situation.
 *
 * If this property is set to YES the transforms of the startingNode and its ancestors,
 * right up to the CC3Scene, will be ignored. The result is that the transformMatrix
 * and all global properties (globalLocation, etc) will be relative to the startingNode.
 
 * This can be useful when you want to coordinate node positioning within a particular
 * common ancestor, by using their global properties relative to that common ancestor
 * node.
 * 
 * It is also used when determine the boundingBox property of a node, by transforming
 * all descendant nodes by all transforms between the node and each descendant, but
 * ignoring the transforms of the ancestor nodes of the node whose local bounding box
 * is being calculated.
 *
 * Setting this property to YES will force the recalculation of the transformMatrix of
 * each node visited, to ensure that they are relative to the startingNode. Further,
 * once the visitation run is complete, if this property is set to YES, the close
 * method will rebuild the transformMatrices of the startingNode and its descendants,
 * to leave the transformMatrices in their normal global form.
 * 
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldLocalizeToStartingNode;

/**
 * This property only has effect when the shouldLocalizeToStartingNode property is set to YES.
 *
 * Indicates whether the full global transforms should be restored afte the localized
 * transforms have been calculated and consumed. Setting this to YES is useful when
 * the localized transform is being temporarily calculated for a specialized purpose
 * such as determining a local bounding box, but then the full global transform should
 * be immediately restored for further use.
 *
 * The initial value of this property is NO. However, specialized subclasses may set
 * to YES initially as appropriate.
 */
@property(nonatomic, assign) BOOL shouldRestoreTransforms;

/**
 * Returns whether the transform matrix of the node currently being visited is dirty
 * and needs to be recalculated.
 *
 * The value of this property is consistent throughout the processing of a particular
 * node. It is set before each node is visited, and is not changed until after the
 * node has finished being processed, even if the node's transform matrix is recalculated
 * during processing. This allows any post-node-processing activities, either within the
 * visitor or within the node, to know that the transform matrix was changed.
 */
@property(nonatomic, readonly) BOOL isTransformDirty;

/**
 * Returns the transform matrix to use as the parent matrix when transforming the
 * specified node.
 * 
 * This usually returns the value of the parentTransformMatrix of the specified node.
 * However, if the shouldLocalizeToStartingNode property is set to YES and the
 * startingNode is either the specified node or its parent, this method returns nil.
 */
-(CC3Matrix*) parentTansformMatrixFor: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodeUpdatingVisitor

/**
 * CC3NodeUpdatingVisitor is a CC3NodeVisitor that is passed to a node when it is visited
 * during updating and transforming operations.
 *
 * This visitor encapsulates the time since the previous update.
 */
@interface CC3NodeUpdatingVisitor : CC3NodeTransformingVisitor {
	ccTime deltaTime;
}

/**
 * This property gives the interval, in seconds, since the previous update. This value can be
 * used to create realistic real-time motion that is independent of specific frame or update rates.
 * Depending on the setting of the maxUpdateInterval property of the CC3Scene instance, the value
 * of this property may be clamped to an upper limit. See the description of the CC3Scene
 * maxUpdateInterval property for more information about clamping the update interval.
 */
@property(nonatomic, assign) ccTime deltaTime;

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVisitor

/**
 * Specialized transforming visitor that measures the bounding box of a node and all
 * its descendants, by traversing each descendant node, ensuring each transformMatrix
 * is up to date, and accumulating a bounding box that encompasses the local content
 * of the startingNode and all of its descendants.
 *
 * If the value of the shouldLocalizeToStartingNode property is YES, the bounding
 * box will be in the local coordinate system of the startingNode, otherwise it
 * will be in the global coordinate system of the 3D scene.
 */
@interface CC3NodeBoundingBoxVisitor : CC3NodeTransformingVisitor {
	CC3BoundingBox boundingBox;
}

/**
 * Returns the bounding box accumulated during the visitation run.
 *
 * If the value of the shouldLocalizeToStartingNode property is YES, the bounding
 * box will be in the local coordinate system of the startingNode, otherwise it
 * will be in the global coordinate system of the 3D scene.
 *
 * If none of the startingNode or its descendants have any local content, this
 * property will return kCC3BoundingBoxNull.
 *
 * The initial value of this property will be kCC3BoundingBoxNull.
 */
@property(nonatomic, readonly) CC3BoundingBox boundingBox;

@end


#pragma mark -
#pragma mark CC3NodeDrawingVisitor

/**
 * CC3NodeDrawingVisitor is a CC3NodeVisitor that is passed to a node when it is visited
 * during drawing operations.
 *
 * The visitor uses the camera property to determine which nodes to visit. Only nodes that
 * are within the camera's field of view will be visited. Nodes outside the camera's frustum
 * will neither be visited nor drawn.
 */
@interface CC3NodeDrawingVisitor : CC3NodeVisitor {
	CC3NodeSequencer* drawingSequencer;
	GLuint textureUnitCount;
	GLuint textureUnit;
	BOOL shouldDecorateNode : 1;
	BOOL shouldClearDepthBuffer : 1;
}

/**
 * The node sequencer that contains the drawable nodes, in the sequence in which
 * they will be drawn.
 *
 * If this property is not nil, the nodes will be drawn in the order they appear
 * in the node sequencer. If this property is set to nil, the visitor will
 * traverse the node tree during the visitation run, drawing each node that contains
 * local content as it is encountered.
 */
@property(nonatomic, assign) CC3NodeSequencer* drawingSequencer;

/**
 * The number of texture units being drawn.
 *
 * This value is set by the texture contained in the node's material,
 * and is then consumed by the mesh when binding texture coordinates.
 */
@property(nonatomic, assign) GLuint textureUnitCount; 

/**
 * The current texture unit being drawn.
 *
 * This value is set during drawing when the visitor is passed to the texture coordinates array.
 */
@property(nonatomic, assign) GLuint textureUnit; 

/**
 * Indicates whether nodes should decorate themselves with their configured material,
 * textures, or color arrays. In most cases, nodes should be drawn decorated. However,
 * specialized visitors may turn off normal decoration drawing in order to do
 * specialized coloring instead.
 *
 * The default initial value is YES.
 */
@property(nonatomic, assign) BOOL shouldDecorateNode;

/**
 * Indicates whether the OpenGL depth buffer should be cleared before drawing
 * the 3D scene.
 * 
 * This property is automatically set to the value of the
 * shouldClearDepthBufferBefore3D property of the CC3Scene.
 */
@property(nonatomic, assign) BOOL shouldClearDepthBuffer;

/**
 * Draws the specified node. Invoked by the node itself when the node's local
 * content is to be drawn.
 *
 * This implementation first caches the current lighting enablement state in case
 * lighting is turned off during drawing of the material, then it double-dispatches
 * back to the node's drawWithVisitor: method to perform the drawing. Finally, this
 * implementation updates the drawing performance statistics.
 *
 * Subclass may override to enhance or modify this behaviour.
 */
-(void) draw: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodePickingVisitor

/**
 * CC3NodePickingVisitor is a CC3NodeDrawingVisitor that is passed to a node when
 * it is visited during node picking operations using color-buffer based picking.
 *
 * The visit: method must be invoked with a CC3Scene instance as the arguement.
 *
 * Node picking is the act of picking a 3D node from user input, such as a touch.
 * One method of accomplishing this is to draw the scene such that each object is
 * drawn in a unique solid color. Once the scene is drawn, the color of the pixel
 * that has been touched can be read from the OpenGL ES color buffer, and mapped
 * back to the object that was painted with that color. This drawing is performed
 * in the background so that the user is unaware of the specialized coloring.
 *
 * If antialiasing multisampling is active, before reading the color of the touched
 * pixel, the multisampling framebuffer is resolved to the resolve framebuffer,
 * and the resolve framebuffer is made active so that the color of the touched pixel
 * can be read. After reading the color of the touched pixel, the multisampling
 * framebuffer is made active in preparation of normal drawing operations.
 */
@interface CC3NodePickingVisitor : CC3NodeDrawingVisitor {
	CC3Node* pickedNode;
	ccColor4F originalColor;
}

/** The node that was most recently picked. */
@property(nonatomic, readonly) CC3Node* pickedNode;

@end


#pragma mark -
#pragma mark CC3NodePuncturingVisitor

/**
 * CC3NodePuncturingVisitor is a CC3NodeVisitor that is used to collect nodes
 * that are punctured (intersected) by a global ray.
 *
 * For example, you can use the CC3Camera unprojectPoint: method to convert a 2D touch point
 * into a CC3Ray that projects into the 3D scene from the center of the camera. All objects
 * that lie visually below the touch point will be punctured by that projected ray.
 *
 * Or, you may want to know which nodes lie under a targetting reticle, or have been hit by
 * the path of a bullet.
 * 
 * To find the nodes that are punctured by a global CC3Ray, create an instance of this class,
 * and invoke the visit: method on that instance, passing the CC3Scene as the argument. You can
 * also invoke the visit: method with a particular structural node, instead of the full CC3Scene,
 * to limit the range of nodes to inspect (for example, to determine which object in a room, but
 * not outside the room, was hit by a bullet), for design or performance reasons.
 *
 * The visitor will collect the nodes that are punctured by the ray, in order of distance from
 * the startLocation of the CC3Ray. You can access the nodes and the puncture locations using the
 * closestPuncturedNode, punctureNodeAt: closestPunctureLocation, and punctureLocationAt: methods.
 *
 * Only nodes that have a bounding volume will be tested by this visitor. Nodes without a bounding
 * volume, or whose shouldIgnoreRayIntersection property is set to YES will be ignored by this visitor.
 *
 * The shouldPunctureFromInside property can be used to include or exclude nodes where the start
 * location of the ray is within its bounding volume. 
 *
 * To save instantiating a CC3NodePuncturingVisitor each time, you can reuse the visitor instance
 * over and over, through different invocations of the visit: method.
 */
@interface CC3NodePuncturingVisitor : CC3NodeVisitor {
	CCArray* nodePunctures;
	CC3Ray ray;
	BOOL shouldPunctureFromInside : 1;
	BOOL shouldPunctureInvisibleNodes : 1;
}

/**
 * Indicates whether the visitor should consider the ray to intersect a node's
 * bounding volume if the ray starts within the bounding volume of the node.
 *
 * The initial value of this property is NO, indicating that the visitor
 * will not collect punctures for any node where the ray starts within
 * the bounding volume of that node.
 *
 * This initial value makes sense for the common use of using the ray to pick
 * nodes from a touch, as, when the camera is within a node, that node will
 * not be visible. However, if you have a character within a room, and you
 * want to know where in the room a thrown object hits the walls, you might
 * want to set this property to YES to collect nodes that are punctured from
 * the inside as well as from the outside.
 */
@property(nonatomic, assign) BOOL shouldPunctureFromInside;

/**
 * Indicates whether the visitor should include those nodes that are not
 * visible (whose visible property returns NO), when collecting the nodes
 * whose bounding volumes are punctured by the ray.
 *
 * The initial value of this property is NO, indicating that invisible
 * nodes will be ignored by this visitor.
 */
@property(nonatomic, assign) BOOL shouldPunctureInvisibleNodes;

/**
 * The ray that is to be traced, specified in the global coordinate system.
 *
 * This property is set on initialization, but you may set it to another
 * ray when reusing the same visitor on more than one visitation.
 */
@property(nonatomic, assign) CC3Ray ray;

/** The number of nodes that were punctured by the ray. */
@property(nonatomic, readonly) NSUInteger nodeCount;

/**
 * Returns the node punctured by the ray that is closest to the startLocation
 * of the ray, or nil if the ray intersects no nodes.
 *
 * The result will not include any node that does not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
@property(nonatomic, readonly) CC3Node* closestPuncturedNode;

/**
 * Returns the location of the puncture on the node returned by the
 * closestPuncturedNode property, or kCC3VectorNull if the ray intersects no nodes.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the local
 * coordinate system of the node.
 *
 * The result will not include any node that does not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
@property(nonatomic, readonly) CC3Vector closestPunctureLocation;

/**
 * Returns the location of the puncture on the node returned by the
 * closestPuncturedNode property, or kCC3VectorNull if the ray intersects no nodes.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the global
 * coordinate system.
 */
@property(nonatomic, readonly) CC3Vector closestGlobalPunctureLocation;

/**
 * Returns the node punctured by the ray at the specified order index,
 * which must be between zero and nodeCount minus one, inclusive.
 *
 * When multiple nodes are punctured by the ray, they can be accessed
 * using the specified positional index, with the order determined by
 * the distance from the startLocation of the ray to the global location
 * of the puncture for each node. The index zero represents the node
 * whose puncture is globally closest to the startLocation of the ray.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
-(CC3Node*) puncturedNodeAt: (NSUInteger) index;

/**
 * Returns the location of the puncture on the node returned by the
 * puncturedNodeAt: method. The specified index must be between zero
 * and nodeCount minus one, inclusive.
 *
 * When multiple nodes are punctured by the ray, the location of the
 * puncture on each can be accessed using the specified positional index,
 * with the order determined by the distance from the startLocation of
 * the ray to the global location of the puncture for each node. The
 * index zero represents the node whose puncture is globally closest
 * to the startLocation of the ray.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the local
 * coordinate system of the node.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
-(CC3Vector) punctureLocationAt: (NSUInteger) index;

/**
 * Returns the location of the puncture on the node returned by the
 * puncturedNodeAt: method. The specified index must be between zero
 * and nodeCount minus one, inclusive.
 *
 * When multiple nodes are punctured by the ray, the location of the
 * puncture on each can be accessed using the specified positional index,
 * with the order determined by the distance from the startLocation of
 * the ray to the global location of the puncture for each node. The
 * index zero represents the node whose puncture is globally closest
 * to the startLocation of the ray.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the local
 * coordinate system of the node.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
-(CC3Vector) globalPunctureLocationAt: (NSUInteger) index;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified ray,
 * which is specified in the global coordinate system.
 */
-(id) initWithRay: (CC3Ray) aRay;

/**
 * Allocates and initializes an autoreleased instance with the specified ray,
 * which is specified in the global coordinate system.
 */
+(id) visitorWithRay: (CC3Ray) aRay;

@end
