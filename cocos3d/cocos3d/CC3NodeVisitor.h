/*
 * CC3NodeVisitor.h
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
 */

/** @file */	// Doxygen marker


#import "CC3PerformanceStatistics.h"
#import "cocos2d.h"
#import "ES1Renderer.h"


#pragma mark -
#pragma mark CC3NodeVisitor

@class CC3Node, CC3World;

/**
 * A CC3NodeVisitor is a context object that is passed to a node when it is visited
 * during a traversal of the node hierarchy. The traversal of the node structural
 * hierarchy is handled by the node, using contextual information contained in the
 * visitor. The visitor encapsulates the CC3World, so that nodes have access to other
 * nodes within their world.
 *
 * The visitor class may also determine some or all of the activities that will occur 
 * during the traversal of the node hierarchy.
 *
 * This base implementation does nothing. Subclasses can perform specialized functions
 * when visiting the nodes, such as drawing, updating, or selecting nodes.
 */
@interface CC3NodeVisitor : NSObject {
	CC3World* world;
	CC3PerformanceStatistics* performanceStatistics;
	NSMutableSet* pendingRemovals;
	GLuint pickingDepthBuffer;
	GLuint pickingFrameBuffer;
	BOOL shouldVisitChildren;
}

/**
 * Indicates whether nodes should propagate visits to their children.
 *
 * The default initial value is YES.
 */
@property(nonatomic, assign) BOOL shouldVisitChildren;

/**
 * The CC3World that the node is part of. Each node can interact with other nodes in
 * the 3D world, through this property.
 *
 * The requirement for encapsulating the world is determined by the subclass.
 * Some subclasses may not need access to the CC3World.
 */
@property(nonatomic, retain) CC3World* world;

/**
 * The performanceStatistics being accumulated by the CC3World.
 *
 * This is extracted from the CC3World, and may be nil if the world is not collecting statistics.
 */
@property(nonatomic, readonly) CC3PerformanceStatistics* performanceStatistics;

/**
 * Invoked automatically prior to the first node being visited during a visitation run.
 * This method is invoked automatically once before visiting any nodes.
 * It is not invoked for each node visited.
 *
 * Default implementation does nothing. Subclasses can override to initialize their state,
 * or to set any external state needed, such as GL state, prior to starting a visitation run.
 */
-(void) open;

/**
 * Invoked automatically after visiting the last node during a visitation run.
 * This method is invoked automatically after all nodes have been visited.
 * It is not invoked for each node visited.
 *
 * Default implementation does nothing. Subclasses can override to clean up their state,
 * or to reset any external state, such as GL state, upon completion of a visitation run.
 */
-(void) close;

/** Allocates and initializes an autoreleased instance without a CC3World. */
+(id) visitor;

/** Initializes this instance with the specified CC3World. */
-(id) initWithWorld: (CC3World*) theWorld;

/** Allocates and initializes an autoreleased instance with the specified CC3World. */
+(id) visitorWithWorld: (CC3World*) theWorld;

/**
 * Requests the removal of the specfied node.
 * 
 * During a visitation run, you should use this method instead of directly invoking the
 * remove method on the node itself. Visitation involves iterating through collections
 * of child nodes, and removing a node during the iteration of a collection raises an error.
 *
 * This method can safely be invoked while a node is being visited. The visitor keeps
 * track of the requests, and safely removes all requested nodes as part of the close
 * method, once the visitation of the full node assembly is finished.
 */
-(void) requestRemovalOf: (CC3Node*) aNode;

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
 * This visitor inherits the ability to enapsulate the CC3World, but it does not use
 * this property. It is okay to instantiate an instance without the world.
 */
@interface CC3NodeTransformingVisitor : CC3NodeVisitor {
	BOOL isTransformDirty;
}

/**
 * Builds the transformation matrices of the specified node and all descendent nodes.
 *
 * Each node rebuilds its transformation matrix if either its own transform is dirty,
 * or if an ancestor's transform was dirty. As it traverses the node hierarchy, this
 * visitor keeps track of whether the transform of an ancestor node was dirty.
 */
-(void) updateNode: (CC3Node*) aNode;

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

/** Initializes this instance with the specified world and delta time. */
-(id) initWithWorld: (CC3World*) theWorld andDeltaTime: (ccTime) dt;

/** Allocates and initializes an autoreleased instance with the specified world and delta time. */
+(id) visitorWithWorld: (CC3World*) theWorld andDeltaTime: (ccTime) dt;

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
