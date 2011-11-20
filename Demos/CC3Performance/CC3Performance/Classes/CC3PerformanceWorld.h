/*
 * CC3PerformanceWorld.h
 *
 * cocos3d 0.6.4
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
 */


#import "CC3World.h"
#import "NodeGrid.h"


/**
 * This application-specific CC3World provides a platform for testing and displaying
 * various performance-related aspects of cocos3d.
 *
 * The user can select one of various node types, and determine how many copies of
 * that node should be added to the 3D world. Those copies are laid out in a square
 * grid within the world. This app then collects various statistics about the
 * performance of the 3D world. The customized CC3Layer can then extract these
 * statistics and display them in real-time.
 *
 * The user can also select whether the nodes in the world are animated or not.
 * Animating the nodes adds load because the transformMatrix of each node must be
 * updated during each update.
 *
 * The statistics that are collected are available automatically in any cocos3d
 * application. You can collect performance statistics on your own application
 * by setting and managing an instance of CC3PerformanceStatistics or one of its
 * subclasses.
 *
 * Interestingly, you can easily compare the performance cost of the GL drawing
 * activity, relative to the overhead of the cocos3d framework. To do so, uncomment
 * the first line in the implementation of the initializeWorld method of this class.
 * See the inline comments above that first line within the initializeWorld method
 * to understand how this works.
 */
@interface CC3PerformanceWorld : CC3World {
	NSMutableArray* availableTemplateNodes;
	CC3Node* templateNode;
	NodeGrid* nodeGrid;
	CGPoint playerDirectionControl;
	CGPoint playerLocationControl;
	uint perSideCount;
	BOOL shouldAnimateNodes;
}

@property(nonatomic, readonly) NSMutableArray* availableTemplateNodes;

/**
 * This property controls the velocity of the change in direction of the 3D camera
 * (a proxy for the player). This property is set by the CC3Layer, from the velocity
 * of the corresponding joystick control.
 */
@property(nonatomic, assign) CGPoint playerDirectionControl;

/**
 * This property controls the velocity of the change in location of the 3D camera
 * (a proxy for the player). This property is set by the CC3Layer, from the velocity
 * of the corresponding joystick control.
 */
@property(nonatomic, assign) CGPoint playerLocationControl;

/** The node to be used as a template when creating copies for the grid. */
@property(nonatomic, retain) CC3Node* templateNode;

/**
 * The number of nodes that are laid out per side on the square grid of nodes.
 * The total number of copies of the template node that are added to the world
 * is therefore (perSideCount * perSideCount).
 */
@property(nonatomic, assign) uint perSideCount;

/**
 * Indicates whether the node copies should be animated.
 *
 * Animating adds load the the CPU because the transformMatrix of each node
 * must be updated during each update pass.
 *
 * Animation of the nodes is performed by using a specialized CC3NodeUpdatingVisitor
 * that animates each node in a pseudo-random manner.
 */
@property(nonatomic, assign) BOOL shouldAnimateNodes;

/** Increases the number of nodes being displayed. */
-(void) increaseNodes;

/** Decreases the number of nodes being displayed. */
-(void) decreaseNodes;

/** Changes the type of nodes being displayed to the next node type. */
-(void) nextNodeType;

/** Changes the type of nodes being displayed to the previous node type. */
-(void) prevNodeType;

@end

/**
 * A specialized CC3NodeUpdatingVisitor that animates each copy of the template
 * node by modifying the rotation property of each copy of the template node
 * that it visits.
 *
 * When the user indicates that the nodes should be animated, the world will use
 * an instance of this visitor class when updating the nodes. Otherwise, it will
 * use an instance of the normal CC3NodeUpdatingVisitor class.
 */
@interface CC3AnimatingVisitor : CC3NodeUpdatingVisitor
@end
