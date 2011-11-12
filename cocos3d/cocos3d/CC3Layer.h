/*
 * CC3Layer.h
 *
 * cocos3d 0.6.3
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

/** @file */	// Doxygen marker

#import "ControllableCCLayer.h"
#import "CC3World.h"

/**
 * CC3Layer is a cocos2d CCLayer that supports full 3D rendering in combination with normal
 * cocos2d 2D rendering. It forms the bridge between the 2D and 3D drawing environments.
 *
 * The CC3Layer contains an instance of CC3World, and delegates all 3D operations, for both
 * updating and drawing 3D models, to the CC3World instance.
 *
 * In addition, like any cocos2d CCLayer, 2D child CCNodes can be added to this layer and
 * will be rendered either over or under the 3D world, based on their individual Z-order.
 * In particular, 2D controls such as menus, sprites, labels, health bars, joysticks, etc,
 * can be overlayed on the 3D world simply by adding them as children of this layer.
 * Similarly, a 2D backdrop could be rendered behind the 3D world by adding an appropriate
 * CCNode as a child with a negative Z-order.
 *
 * Like other CCNodes, this layer can be added to another 2D node, and given a contentSize,
 * position, and scale. You can even dynamically move and scale the embedded CC3Layer
 * using CCActions.
 *
 * Changes to the position and scale of the CC3Layer are propagated to the viewport of the
 * contained CC3World, and to any child CC3Layers and CC3Worlds.
 *
 * However, these properties will only be propagated if the node being moved is a CC3Layer.
 * If the CC3Layer is a child of a regular 2D CCLayer or  CCNode, and that node is moved,
 * the resulting changes to the position or scale of the child CC3Layer may not
 * automatically be propagated to the CC3World viewport. In this case, you can use the
 * updateViewport method of CC3Layer to ensure that the CC3World viewport is aligned
 * with the position and scale of the CC3Layer.
 *
 * CC3Layer descends from CCLayerColor, and will draw a colored background behind both 2D
 * and 3D content if configured with a background color.
 *
 * To make use of the standard cocos2d model updatating functionality to update and animate
 * the 3D world, use the scheduleUpdate or schedule:interval: methods of CC3Layer to invoke
 * periodic callbacks to the update: method of the CC3Layer instance. The update: method
 * forwards these callbacks to the CC3World instance held by the CC3Layer.
 *
 * To enable simple single-touch event handling for this layer, set the isTouchEnabled
 * property to YES. Once enabled, single-touch events will automatically be forwarded to
 * the touchEvent:at: method on your customized CC3World instance to support user selection
 * of 3D nodes via touches. For more information on handling 3D node selections, see the
 * description of the method nodeSelected:byTouchEvent:at: of CC3World.
 *
 * Since the touch-move events are both voluminous and seldom used, the implementation
 * of ccTouchMoved:withEvent: has been left out of the default CC3Layer implementation.
 * To receive and handle touch-move events for object picking, copy the commented-out
 * ccTouchMoved:withEvent: template method implementation in CC3Layer to your customized
 * CC3Layer subclass.
 *
 * For more sophisticated touch interfaces, such as multi-touch events or gestures, add
 * event-handing behaviour to your customized CC3Layer, as you would for any cocos2d
 * application and, when required, invoke the touchEvent:at: method on your customized
 * CC3World to initiate node selection.
 *
 * Most 3D games will be displayed in full-screen mode, so typically your custom CC3Layer
 * will be sized to cover the entire screen. However, the CC3Layer can indeed be set to a
 * contentSize less that the full window size, and may be positioned on the window, or
 * within a parent CCLayer like any other CCNode.
 * 
 * You can even dyanamically move your CC3Layer around within the window, by changing the
 * position property (for example, by using a CCMoveTo action).
 *
 * CC3Layer directly descends from ControllableCCLayer, which means that it can optionally
 * be controlled by a CCNodeController instance. Doing so enables two features:
 *   - Automatic rotatation the layer (both the 2D and 3D components) when the device
 *     orientation changes.
 *   - The CC3Layer can be overlaid on a device camera image stream so that both the 2D and
 *     3D worlds can participate in an augmented reality view perspective.
 *
 * With the CCNodeController attached, either or both of these features can be turned on
 * or off. If neither of these features is required, there is no need to instantiate and
 * attach a CCNodeController, and the CC3Layer can be used without it.
 *
 * For most applications, you will create subclasses of both CC3Layer and CC3World.
 * The customized subclass of CC3World manages the behaviour of the 3D resources.
 * The customized subclass of CC3Layer manages the 2D artifacts, such as menus, sprites,
 * labels, health bars, joysticks, etc, that you want to overlay on the 3D scene.
 *
 * Typically, you will create a separate instance of CC3World for each 3D scene. You can
 * also create a distinct CC3Layer for each scene as well or, more typically, reuse a single
 * CC3Layer instance across multiple CC3World scenes by simply assigning a differnt CC3World
 * instance to the layer. Any running actions in the old world are automatically paused,
 * and any running actions in the new world are automatically started. For more information
 * on swapping 3D scenes, see the notes on the cc3World property.
 * 
 * To create and use your CC3Layer and CC3World pair, follow these steps:
 *   -# Instantiate your CC3World class, including creating or loading 3D file resources
 *      in the initializeWorld method.
 *   -# Instantiate your CC3Layer subclass, adding any 2D controls in the initializeControls method.
 *   -# Attach your CC3World to the cc3World property of your CC3Layer.
 *   -# Invoke the play method of your CC3World to enable dynamic behaviour for the 3D world.
 *   -# Schedule regular updates in your CC3Layer instance by invoking either the
 *      scheduleUpdate or schedule:interval: method.
 *   -# Optionally create a CCNodeController.
 *   -# Run your CC3Layer instance either by invoking the runSceneOnNode: method of the
 *      CCNodeController with your CC3Layer, or by wrapping your CC3Layer in a CCScene
 *      and invoking the runWithScene: method of the shared CCDirector instance.
 */
@interface CC3Layer : ControllableCCLayer {
	CC3World* cc3World;
	BOOL shouldAlwaysUpdateViewport;
}

/**
 * Returns whether this layer is opaque.
 *
 * Return YES if the isColored property returns YES and
 * the opacity property returns 255, otherwise returns NO.
 */
@property(nonatomic, readonly) BOOL isOpaque;


#pragma mark Allocation and initialization

/**
 * Template method that is invoked automatically during initialization, regardless
 * of the actual init* method that was invoked. Subclasses can override to set up their
 * 2D controls and other initial state without having to override all of the possible
 * superclass init methods.
 *
 * This default implementation does nothing. It is not necessary to invoke this
 * superclass implementation when overriding in a subclass.
 */
-(void) initializeControls;


#pragma mark Updating layer

/**
 * The CC3World instance that maintains the 3D models and draws the 3D content.
 *
 * If your application contains multiple 3D scenes, you can swap between these scenes
 * by simply setting the value of this property to the new scene. The old CC3World
 * instance is released. So if you want to swap that old world back into this layer
 * at some point in the future, you should cache it somewhere, or recreated it.
 *
 * When the old world is released, it will clean up after itself, including all the
 * nodes and meshes it contains.
 *
 * If this layer already has a CC3World assigned, the wasRemoved method of the existing
 * CC3World to stop and remove any CCActions running on it and the nodes it contains.
 *
 * You can set the shouldCleanupWhenRemoved of the CC3World to NO if you want the
 * CCActions attached to the world and its nodes to be paused, but not stopped and
 * removed. Be aware that CCActions that are paused, but not stopped, will retain the
 * CC3World, and could be cause for memory leaks if not managed correctly. Please see
 * the notes of the CC3Node shouldCleanupWhenRemoved property and the CC3Node wasRemoved
 * method for more information.
 *
 * Setting this property automatically invokes the udpateWorld method on the new world
 * to ensure that the transforms are up to date before the next frame is rendered.
 */
@property(nonatomic, retain) CC3World* cc3World;	

/**
 * Indicates whether this layer should update the 3D viewport on each rendering frame.
 *
 * If the value of this property is YES, the 3D viewport will be updated before each
 * frame is drawn. This is sometimes useful if the layer is changing in a way that is
 * not automatically tracked by the 3D world.
 *
 * You do not need to set this property when changing the position or scale of the layer.
 * These changes are forwarded to the 3D world automatically.
 *
 * The initial value of this property is NO. Unless you encounter issues when modifying
 * the layer, leave this property set to NO, to avoid the overhead of calculating an
 * unnecessary transformation matrix on each frame render.
 *
 * As an alternate to updating the viewport on every frame render, consider invoking
 * the updateViewport method whenever your application changes the orientation of this
 * layer in a manner that is not automatically propagated to the CC3World viewport.
 */
@property(nonatomic, assign) BOOL shouldAlwaysUpdateViewport;

/**
 * This method is invoked periodically when the components in the CC3World are to be updated.
 *
 * The dt argument gives the interval, in seconds, since the previous update.
 *
 * This implementation forwards this update to the updateWorld: method of the contained
 * CC3World instance. Subclasses can override to perform updates to 2D nodes added to
 * this layer, but should be sure to invoke this superclass implementation, or to invoke
 * updateWorld: on the cc3World directly.
 *
 * Typcially this method is scheduled to be invoked automatically at a periodic interval by
 * using the scheduleUpdate or schedule:interval: methods of this instance, but may also be
 * invoked by some other periodic operation, or even directly by the application.
 *
 * This method is invoked asynchronously to the frame rendering animation loop, to keep the
 * processing of model updates separate from OpenGL ES drawing.
 */
-(void) update: (ccTime)dt;

/**
 * Updates the viewport of the contained CC3World instance with the dimensions
 * of this layer and the device orientation.
 *
 * This method is invoked automatically when the position, size, scale, or orientation
 * of this layer changes. You do not need to invoke this method when changing the position
 * or scale of the layer. These changes are forwarded to the CC3World viewport automatically.
 *
 * Usually, the application should never need to invoke this method directly. However,
 * if your application changes the orientation of this layer in a manner that is not
 * automatically detected, you can use this method to align the CC3World viewport with
 * the updated layer.
 */
-(void) updateViewport;

/**
 * If a background color has been specified, and this layer is not overlaying the device
 * camera, draws the background color over the entire layer.
 *
 * This method is invoked automatically when this layer is drawn. The application should
 * never need to invoke this method directly.
 */
-(void) drawBackdrop;

@end
