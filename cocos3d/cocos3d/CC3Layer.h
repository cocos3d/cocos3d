/*
 * CC3Layer.h
 *
 * cocos3d 0.6.0-sp
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
 * CC3Layer descends from CCLayerColor, and will draw a colored background behind both 2D
 * and 3D content if configured with a background color. When using 3D objects that use
 * alpha-blending, keep in mind that the background color does not participate in
 * alpha-blending with 3D models that are drawn over it. The background color will not show
 * through any semi-transparent 3D objects. See also the discussion below about translucent
 * objects when using touch events to select 3D nodes.
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
 * Selection of 3D nodes using touch events uses a color-picking algorithm. When a touch
 * event occurs, the 3D scene is drawn in pure colors behind the scenes and then drawn in
 * its full glory over top. Since the full scene is redrawn as it should be before being
 * displayed, the user sees no visible difference.
 *
 * However, since the CC3Layer's background color and any background 2D nodes have already
 * been drawn by normal cocos2d CCLayer behaviour and cannot be redrawn during 3D drawing,
 * when a touch event is used to select a node, there is a very slight flicker on any
 * translucent nodes that have nothing behind them except the layer's background color or
 * 2D CCNodes. Opaque 3D nodes are not affected and do not flicker. Nor do translucent nodes
 * that have 3D nodes behind them.
 *
 * To remove this flicker on translucent nodes during touch event processing, make sure that
 * translucent nodes do not appear directly over the background color of the layer, or over
 * 2D CCNodes. In such cases, use a full 3D skybox in the 3D world instead.
 *
 * Most 3D games will be displayed in full-screen mode, so typically your custom CC3Layer
 * will be sized to cover the entire screen. However, the CC3Layer can indeed be set to a
 * contentSize less that the full window size, and may be positioned on the window, or
 * within a parent CCLayer like any other CCNode.
 * 
 * You can even dyanamically move your CC3Layer around within the window, by changing the
 * position property (for example, by using a CCMoveTo action). However, if you do want
 * to move the CC3Layer around the screen, be sure to set the shouldAlwaysUpdateViewport
 * property to YES before doing so. See the notes for the shouldAlwaysUpdateViewport
 * property for more info on this.
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
 * If you application contains multiple 3D scenes, you can swap between these scenes by
 * simply setting the value of this property to the new scene.
 * 
 * Any CCActions that are running in the old cc3World instance are paused, and any CCActions
 * pending within the new world are resumed.
 * 
 * Take note that the CCActions of the old world are paused, not stopped, and nodes with
 * active CCActions will continue to be retained by the CCActionManager. To avoid memory
 * leaks, If you are finished with the old world, be sure to invoke the cleanup method as
 * well so that all descendant nodes will be released from their actions.
 *
 * Setting this property also automatically invokes the udpateWorld method on the new
 * world to ensure that the transforms are up to date before the next frame is rendered.
 */
@property(nonatomic, retain) CC3World* cc3World;	

/**
 * Indicates whether this layer should update the 3D viewport on each rendering frame.
 *
 * If the value of this property is YES, the 3D viewport will be updated before each
 * frame is drawn. This is necessary if the position of this layer may be dynamically
 * changing. For example, if you have scheduled this layer to be moved around the
 * screen under control of a CCAction, set this property to YES prior to doing so.
 *
 * You do NOT need to set this property to YES to position the layer during initialization.
 *
 * The initial value of this property is NO. Unless the layer will actually be moving
 * around, leave this property set to NO, to avoid the overhead of calculating an
 * unnecessary transformation matrix on each frame render.
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
	

@end
