/*
 * CC3NodeVisitor.h
 *
 * cocos3d 0.6.1
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
 */

/** @file */	// Doxygen marker


#import "CC3GLMatrix.h"
#import "CC3PerformanceStatistics.h"
#import "cocos2d.h"
#import "ES1Renderer.h"


#pragma mark -
#pragma mark CC3NodeVisitor

@class CC3Node, CC3World;

/**
 * A CC3NodeVisitor is a context object that is passed to a node when it is visited
 * during a traversal of the node hierarchy.
 *
 * To initiate a visitation run, invoke the visit: method on any CC3Node. A visitation
 * run proceeds with following steps:
 *   -# The open method is invoked on the visitor
 *   -# The visit: method is invoked on each node in the node hierarchy,
 *      in a depth-first recursive traversal.
 *   -# The close method is invoked on the visitor
 * 
 * The following steps occur for each node that is visited with the visit: method:
 *   -# The processBeforeChildren: method is invoked on the visitor
 *   -# The visit: method is invoked on the visitor for each child node
 *   -# The processAfterChildren: method is invoked on the visitor
 * 
 * Subclasses will override the open, processBeforeChildren:, processAfterChildren:,
 * and close methods to customize the behaviour prior to, during, and after the node
 * traversal. The implementation of each of those methods in this base class does nothing.
 *
 * If a node is to be removed from the node structural hierarchy during a visitation run,
 * the requestRemovalOf: method can be used instead of directly invoking the remove method
 * on the node itself. A visitation run involves iterating through collections of child
 * nodes, and removing a node during the iteration of a collection raises an error.
 */
@interface CC3NodeVisitor : NSObject {
	CC3Node* startingNode;
	NSMutableSet* pendingRemovals;
	BOOL shouldVisitChildren;
}

/**
 * Indicates whether nodes should propagate visits to their children.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldVisitChildren;

/**
 * The CC3Node on which this visitation traversal was intitiated. This is the node
 * on which the visit: method was first invoked to begin a traversal of the node
 * structural hierarchy. 
 *
 * This property will be nil until the visit: method is invoked.
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
 * The heavy lifting of processing a particular node is handled by the processBeforeChildren:
 * and processAfterChildren: methods, which are invoked automatically on each node as it is
 * visited, before and after the childn nodes are visited respectively.
 *
 * Subclasses will override the processBeforeChildren: and processAfterChildren: methods to
 * customize node visitation behaviour.
 *
 * If the specified node is the node on which the traversal began (and retained in
 * the origin property), the open method is invoked before the process: method is
 * invoked, and the close method is invoked after the last child node is processed.
 */
-(void) visit: (CC3Node*) aNode;

/**
 * Invoked automatically to process the specified node when that node is visited,
 * before the visit: method is invoked on the child nodes of the specified node.
 * 
 * This abstract implementation does nothing. Subclasses will override to process
 * each node as it is visited.
 */
-(void) processBeforeChildren: (CC3Node*) aNode;

/**
 * If the shouldVisitChildren property is set to YES, this template method is invoked
 * automatically to cause the visitor to visit the child nodes of the specified node .
 *
 * This implementation invokes the visit: method on this visitor for each of the
 * children of the specified node. This establishes a depth-first traveral of the
 * node hierarchy.
 *
 * Subclasses may override this method to establish a different traversal.
 */
-(void) drawChildrenOf: (CC3Node*) aNode;

/**
 * Invoked automatically to process the specified node when that node is visited,
 * after the visit: method is invoked on the child nodes of the specified node.
 * 
 * This abstract implementation does nothing. Subclasses will override to process
 * each node as it is visited.
 */
-(void) processAfterChildren: (CC3Node*) aNode;

/**
 * Invoked automatically prior to the first node being visited during a visitation run.
 * This method is invoked automatically once before visiting any nodes.
 * It is not invoked for each node visited.
 *
 * This abstract implementation does nothing. Subclasses can override to initialize
 * their state, or to set any external state needed, such as GL state, prior to starting
 * a visitation run.
 */
-(void) open;

/**
 * Invoked automatically after the last node has been visited during a visitation run.
 * This method is invoked automatically after all nodes have been visited.
 * It is not invoked for each node visited.
 *
 * This implementation processes the removals of any nodes that were requested to
 * be removed via the requestRemovalOf: method during the visitation run. Subclasses
 * can override to clean up their state, or to reset any external state, such as GL
 * state, upon completion of a visitation run, and should invoke this superclass
 * implementation to process any removal requests.
 */
-(void) close;

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


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) visitor;

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
 * The transforms can be calculated from the CC3World or from the startingNode, depending
 * on the value of the shouldLocalizeToStartingNode property. Normally, the transforms
 * are calculated from the CC3World, but localizing to the startingNode can be useful for
 * determining relative transforms between ancestors and descendants.
 */
@interface CC3NodeTransformingVisitor : CC3NodeVisitor {
	BOOL isTransformDirty;
	BOOL shouldLocalizeToStartingNode;
}

/**
 * Indicates whether all transforms should be localized to the local coordinate system
 * of the startingNode.
 *
 * If this property is set to NO, the transforms of all ancestors of each node, all the
 * way to CC3World, will be included when calculating the transformMatrix and global
 * properties of that node. This is the normal situation.
 *
 * If this property is set to YES the transforms of the startingNode and its ancestors,
 * right up to the CC3World, will be ignored. The result is that the transformMatrix
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
 * Returns the transform matrix to use as the parent matrix when transforming the
 * specified node.
 * 
 * This usually returns the transformMatrix of the parent of the specified node.
 * However, if the specified node has no parent, or if the shouldLocalizeToStartingNode
 * is set to YES and the startingNode is either the specified node or its parent,
 * this method returns nil.
 */
-(CC3GLMatrix*) parentTansformMatrixFor: (CC3Node*) aNode;

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
 * This property gives the interval, in seconds, since the previous update. This value
 * can be used to create realistic real-time motion that is independent of specific frame
 * or update rates. Depending on the setting of the maxUpdateInterval property of the
 * CC3World instance, the value of this property may be clamped to an upper limit.
 * See the description of the CC3World maxUpdateInterval property for more information
 * about clamping the update interval.
 */
@property(nonatomic, assign) ccTime deltaTime;

/** Initializes this instance with the specified delta time. */
-(id) initWithDeltaTime: (ccTime) dt;

/** Allocates and initializes an autoreleased instance with the specified delta time. */
+(id) visitorWithDeltaTime: (ccTime) dt;

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
 * will be in the global coordinate system of the 3D world.
 */
@interface CC3NodeBoundingBoxVisitor : CC3NodeTransformingVisitor {
	CC3BoundingBox boundingBox;
}

/**
 * Returns the bounding box accumulated during the visitation run.
 *
 * If the value of the shouldLocalizeToStartingNode property is YES, the bounding
 * box will be in the local coordinate system of the startingNode, otherwise it
 * will be in the global coordinate system of the 3D world.
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

@class CC3Frustum;

/**
 * CC3NodeDrawingVisitor is a CC3NodeVisitor that is passed to a node when it is visited
 * during drawing operations.
 *
 * This visitor extracts the camera's frustum from the encapsulated world, so that only
 * nodes that are within the camera's field of view will be visited. Nodes outside the
 * frustum will be culled and not drawn.
 */
@interface CC3NodeDrawingVisitor : CC3NodeVisitor {
	CC3Frustum* frustum;
	GLuint textureUnitCount;
	GLuint textureUnit;
	BOOL shouldDecorateNode;
}

/**
 * The frustum used to determine if a node is within the camera's view. This is extracted
 * from the CC3World, set in the property by the open method, and cleared by the close method.
 * It is therefore only available during a visitation run. Since the CC3World may contain
 * multiple cameras, this ensures that the frustum of the current activeCamera is used.
 */
@property(nonatomic, readonly) CC3Frustum* frustum;

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
 * Draws the local content of the specified node. Invoked by the node itself when the
 * node's local content is to be drawn.
 *
 * This implementation double-dispatches back to the node's drawLocalContentWithVisitor:
 * method to perform the drawing. Subclass may override to enhance or modify this behaviour.
 */
-(void) drawLocalContentOf: (CC3Node*) aNode;

@end


#pragma mark -
#pragma mark CC3NodePickingVisitor

/**
 * CC3NodePickingVisitor is a CC3NodeDrawingVisitor that is passed to a node when
 * it is visited during node picking operations using color-buffer based picking.
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

