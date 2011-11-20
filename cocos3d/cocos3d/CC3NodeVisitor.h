/*
 * CC3NodeVisitor.h
 *
 * cocos3d 0.6.4
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

@class CC3NodeSequencer;


#pragma mark -
#pragma mark CC3NodeVisitor

@class CC3Node, CC3World;

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
	CC3GLMatrix* scratchMatrix;
	CCArray* pendingRemovals;
	BOOL shouldVisitChildren;
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
 * Returns a CC3GLMatrix that can be used as a scratch pad for any matrix math
 * that is required during drawing. This matrix is made available as a convenience
 * to remove the overhead of repeatedly allocating and disposing temporary matrices
 * during drawing matrix math calculations.
 *
 * The matrix is lazily created the first time this property is accessed, and
 * is not released until the visitor is deallocated. It can be reused repeatedly
 * during the drawing of any meshes, and from frame to frame.
 *
 * Because of this, you should not assume that the matrix will have any particular
 * contents when accessed at the beginning of any particular calculation. Always
 * ensure that you populate it to the desired initial state using one of the
 * populate... methods of CC3GLMatrix.
 */
@property(nonatomic, retain, readonly) CC3GLMatrix* scratchMatrix;

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
 * The transforms can be calculated from the CC3World or from the startingNode, depending
 * on the value of the shouldLocalizeToStartingNode property. Normally, the transforms
 * are calculated from the CC3World, but localizing to the startingNode can be useful for
 * determining relative transforms between ancestors and descendants.
 */
@interface CC3NodeTransformingVisitor : CC3NodeVisitor {
	BOOL isTransformDirty;
	BOOL shouldLocalizeToStartingNode;
	BOOL shouldRestoreTransforms;
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

@class CC3Camera;

/**
 * CC3NodeDrawingVisitor is a CC3NodeVisitor that is passed to a node when it is visited
 * during drawing operations.
 *
 * The camera property must be set before invoking the visit, so that only nodes that are
 * within the camera's field of view will be visited. Nodes outside the camera's frustum
 * will neither be visited nor drawn.
 */
@interface CC3NodeDrawingVisitor : CC3NodeVisitor {
	CC3NodeSequencer* drawingSequencer;
	CC3Camera* camera;
	GLuint textureUnitCount;
	GLuint textureUnit;
	BOOL shouldDecorateNode;
	BOOL shouldClearDepthBuffer;
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
 * The camera that is viewing the 3D scene that is being drawn.
 *
 * This property must be set before the visit: method is invoked. It is therefore only
 * available during a visitation run. Since the CC3World may contain multiple cameras,
 * this ensures that the current activeCamera is used.
 */
@property(nonatomic, assign) CC3Camera* camera;

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
 * the 3D world.
 * 
 * This property is automatically set to the value of the
 * shouldClearDepthBufferBefore3D property of the CC3World.
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
 * The visit: method must be invoked with a CC3World instance as the arguement.
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

