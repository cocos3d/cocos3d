/*
 * CC3Layer.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Scene.h"
#import "CC3RenderSurfaces.h"

#if CC3_CC2_RENDER_QUEUE
#	import	"CCRenderer_private.h"
#endif	// CC3_CC2_RENDER_QUEUE


/**
 * CC3Layer is a cocos2d CCLayer that supports full 3D rendering in combination with normal
 * cocos2d 2D rendering. It forms the bridge between the 2D and 3D drawing environments.
 *
 * The CC3Layer contains an instance of CC3Scene, and delegates all 3D operations, for both
 * updating and drawing 3D models, to the CC3Scene instance.
 *
 * In addition, like any cocos2d CCLayer, 2D child CCNodes can be added to this layer and
 * will be rendered either over or under the 3D scene, based on their individual Z-order.
 * In particular, 2D controls such as menus, sprites, labels, health bars, joysticks, etc,
 * can be overlayed on the 3D scene simply by adding them as children of this layer.
 *
 * Like other CCNodes, this layer can be added to another 2D node, and given a contentSize,
 * position, and scale. You can even dynamically move and scale the embedded CC3Layer
 * using CCActions.
 *
 * Changes to the position and scale of the CC3Layer are propagated to the viewport of the
 * contained CC3Scene, and to any child CC3Layers and CC3Scenes.
 *
 * However, these properties will only be propagated if the node being moved is a CC3Layer.
 * If the CC3Layer is a child of a regular 2D CCLayer or CCNode, and that node is moved,
 * the resulting changes to the position or scale of the child CC3Layer may not
 * automatically be propagated to the CC3Scene viewport. In this case, you can use the
 * updateViewport method of CC3Layer to ensure that the CC3Scene viewport is aligned
 * with the position and scale of the CC3Layer.
 *
 * Also, although the 3D scene will be correctly rendered when this, or a parent layer is
 * scaled, be aware that scaling of the 2D nodes affects the interaction between the 2D and
 * 3D environments. Specifically, when the 2D layer is scaled, the following limitation apply:
 *   - a 2D CCNode held by CC3Billboards whose shouldDrawAs2DOverlay property is set to
 *     YES, indicating that the 2D CCNode should be drawn as an overlay above the 3D
 *     scene, will not be rendered in the correct position, relative to the 3D scene.
 *   - projection and unprojection between the 2D and 3D coordinate systems, including
 *     projecting touch events onto 3D nodes, will not work correctly.
 *
 * When compiling with versions of cocos2d prior to 3.0, to make use of the standard cocos2d
 * model updatating functionality to update and animate the 3D scene, use the scheduleUpdate
 * method of CC3Layer to invoke periodic callbacks to the update: method of the CC3Layer 
 * instance. The update: method forwards these callbacks to the CC3Scene instance held by 
 * the CC3Layer. When compiling with versions of cocos2d 3.0 or higher, these callbacks will
 * happen automatically, and you do not need to invoke the scheduleUpdate method.
 *
 * To enable simple single-touch event handling for this layer, set the userInteractionEnabled
 * property to YES. Once enabled, single-touch events will automatically be forwarded to
 * the touchEvent:at: method on your customized CC3Scene instance to support user selection
 * of 3D nodes via touches. For more information on handling 3D node selections, see the
 * description of the method nodeSelected:byTouchEvent:at: of CC3Scene.
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
 * CC3Scene to initiate node selection.
 *
 * Most 3D games will be displayed in full-screen mode, so typically your custom CC3Layer
 * will be sized to cover the entire screen. However, the CC3Layer can indeed be set to a
 * contentSize less that the full window size, and may be positioned on the window, or
 * within a parent CCLayer like any other CCNode.
 * 
 * You can even dyanamically move your CC3Layer around within the window, by changing the
 * position property (for example, by using a CCActionMoveTo action).
 *
 * For most applications, you will create subclasses of both CC3Layer and CC3Scene.
 * The customized subclass of CC3Scene manages the behaviour of the 3D resources.
 * The customized subclass of CC3Layer manages the 2D artifacts, such as menus, sprites,
 * labels, health bars, joysticks, etc, that you want to overlay on the 3D scene.
 *
 * Typically, you will create a separate instance of CC3Scene for each 3D scene. You can
 * also create a distinct CC3Layer for each scene as well or, more typically, reuse a single
 * CC3Layer instance across multiple CC3Scene scenes by simply assigning a differnt CC3Scene
 * instance to the layer. Any running actions in the old scene are automatically paused,
 * and any running actions in the new scene are automatically started. For more information
 * on swapping 3D scenes, see the notes on the cc3Scene property.
 * 
 * To create and use your CC3Layer and CC3Scene pair, follow these steps:
 *   -# Create a CC3ViewController.
 *   -# Instantiate your CC3Layer subclass on the controller, adding any 2D controls in the
 *      initializeControls method, and managing event handlers and gesture recognizers in the
 *      onOpenCC3Layer and onCloseCC3Layer methods.
 *   -# Instantiate your CC3Scene class, including creating or loading 3D file resources
 *      in the initializeScene method.
 *   -# Attach your CC3Scene to the cc3Scene property of your CC3Layer.
 *   -# When compiling with versions of cocos2d prior to 3.0, schedule regular updates in
 *      your CC3Layer instance by invoking the scheduleUpdate method.
 */
@interface CC3Layer : CCLayer {
	CC3Scene* _cc3Scene;
	CC3SceneDrawingSurfaceManager* _surfaceManager;
	NSMutableArray* _cc3GestureRecognizers;
	char* _renderStreamGroupMarker;
	BOOL _shouldAlwaysUpdateViewport : 1;
	BOOL _shouldTrackViewSize : 1;
}

/**
 * The CC3Scene instance that maintains the 3D models and draws the 3D content.
 *
 * If your application contains multiple 3D scenes, you can swap between these scenes
 * by simply setting the value of this property to the new scene. The old CC3Scene
 * instance is released. So if you want to swap that old scene back into this layer
 * at some point in the future, you should cache it somewhere, or recreated it.
 *
 * When the old scene is released, it will clean up after itself, including all the
 * nodes and meshes it contains.
 *
 * If this layer already has a CC3Scene assigned, the wasRemoved method of the existing 
 * CC3Scene is invoked to stop and remove any CCActions running on it and any nodes it contains.
 *
 * You can set the shouldStopActionsWhenRemoved of the CC3Scene to NO if you want the CCActions
 * attached to the scene and its nodes to be paused, but not stopped and removed. Be aware that
 * CCActions that are paused, but not stopped, will retain the CC3Scene, and could be cause for
 * memory leaks if not managed correctly. Please see the notes of the CC3Node
 * shouldStopActionsWhenRemoved property and the CC3Node wasRemoved method for more information.
 *
 * Setting this property while this layer is being displayed automatically invokes the
 * open method on the new scene to ensure that the transforms are up to date before the
 * next frame is rendered.
 *
 * In many cases, you do not need to set this property directly. If you do not set this 
 * property directly, an instance of the Class returned by the cc3SceneClass property is 
 * automatically instantiated the first time this property is accessed.
 */
@property(nonatomic, strong) CC3Scene* cc3Scene;

/**
 * Returns the Class used to automatically instantiate a value for the cc3Scene property, 
 * if that property is not set directly. 
 *
 * The value returned by this method is a subclass of CC3Scene.
 *
 * This implementation attempts to derive the appropriate scene class from the name of the
 * class of this instance by looking for a subclass of CC3Scene whose name is one of the 
 * following (searched in this order):
 *   # If the class name of this instance ends in "Layer", it is stripped and "Scene" is
 *     appended to the stripped result (eg. HelloLayer -> HelloScene).
 *   # If the class name of this instance ends in "Layer", it is stripped (eg. HelloLayer -> Hello).
 *   # "Scene" is appended to the class name of this instance (eg. Hello -> HelloScene, 
 *     including HelloLayer -> HelloLayerScene).
 *
 * If that is not sufficient, you can override the getter method of this property in your 
 * custom CC3Layer subclass to return whatever you want, or you can set the cc3Scene property
 * directly. If you override this method, remember the value returned by this method must be 
 * a subclass of CC3Scene.
 */
@property(nonatomic, readonly) Class cc3SceneClass;


#pragma mark Surfaces

/**
 * The surface manager that manages the surfaces associated with this layer, and used
 * to render the scene from this layer.
 *
 * If this property is not explicitly set, it is initialized to an instance of the class
 * returned by the surfaceManager class when this property is first accessed. At a minimum,
 * the surface manager contains the pickingSurface used to pick nodes from touch events.
 * If this layer will be using additional surfaces, you should consider subclassing the
 * CC3SceneDrawingSurfaceManager class and overriding the surfaceManagerClass property.
 *
 * When setting this property, the surfaces in the surface manager are automatically
 * resized to the contentSize of this layer.
 */
@property(nonatomic, strong) CC3SceneDrawingSurfaceManager* surfaceManager;

/**
 * The class that will be used to automatically populate the surfaceManager property when
 * it is first accessed.
 *
 * By default, this property returns the CC3SceneDrawingSurfaceManager class. If this layer will 
 * be using additional surfaces, you should consider subclassing the CC3SceneDrawingSurfaceManager
 * class and overriding this property to return that class.
 */
@property(nonatomic, readonly) Class surfaceManagerClass;


#pragma mark iOS Gesture recognizers and touch handling

/**
 * Returns a collection of iOS UIGestureRecognizers that were added using the 
 * cc3AddGestureRecognizer: method. This property is only available under iOS.
 */
@property(nonatomic, strong, readonly) NSArray* cc3GestureRecognizers;

/**
 * Adds the specified iOS gesture recognizer to the UIView that is displaying this
 * layer, and tracks the gesture recognizer in the cc3GestureRecognizers property.
 *
 * For applications that use a single CC3Layer to cover the entire UIView, you can
 * override the onOpenCC3Layer method to create gesture recognizers, and you can
 * invoke this method to easily add them to the UIView.
 *
 * When this layer is removed from the view, the gesture recognizers added using this
 * method are automatically removed from the view, and from the cc3GestureRecognizers
 * property. Whenever this layer is displayed again, new gesture recognizers will be
 * created and attached to the view when the onOpenCC3Layer method runs again.
 *
 * For applications that diplay several CC3Layers that support gesture recognizers,
 * you may want to create centralized gesture recognizers in some other scope, and
 * bypass adding them using this method.
 */
-(void) cc3AddGestureRecognizer: (UIGestureRecognizer*) gesture;

/**
 * Removes the specified iOS gesture recognizer from the UIView that is displaying this
 * layer, and removes the gesture recognizer from the cc3GestureRecognizers property.
 *
 * When this layer is removed from the view, the gesture recognizers added to the
 * cc3GestureRecognizers property using the cc3AddGestureRecognizer: method are
 * automatically removed from the view, and from the cc3GestureRecognizers property.
 * Usually, the application does not need to invoke this method directly.
 */
-(void) cc3RemoveGestureRecognizer: (UIGestureRecognizer*) gesture;

/**
 * Removes all iOS gesture recognizers that were previously added using the
 * cc3AddGestureRecognizer: method, and removes them all from the UIView.
 *
 * This method is invoked automatically when this layer is removed from the view.
 * Usually, the application does not need to invoke this method directly, but if
 * you need to remove all gesture recognizers prior to closing the layer, you can
 * use this method to do so.
 */
-(void) cc3RemoveAllGestureRecognizers;

/**
 * Invoked automatically when the touchEnabled property or mouseEnabled is set to YES, and
 * a touch or mouse event of the specified type occurs within the bounds of this layer.
 * The specified touchPoint indicates where the touch event occurred, in the local coordinate
 * system of this layer.
 *
 * Under iOS, the event originates from a finger touch event. Under OSX, the event may have
 * originated as either a finger touch event on a touch pad, or an equivalent mouse event.
 *
 * When running under OSX, this layer treats mouse events as the corresponding touch event.
 * The specified touchType will be one of the following:
 *   - kCCTouchBegan:	a mouse-down event has occurred
 *   - kCCTouchMoved:	a mouse-drag event has occurred (with the button down)
 *   - kCCTouchEnded:	a mouse-up event has occurred
 *
 * Returns whether the event was handled.
 *
 * This implementation forwards all events to the CC3Scene touchEvent:at: method, and always
 * returns YES. Subclasses may override this method to handle some events here instead.
 */
-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint;


#pragma mark Allocation and initialization

/**
 * Template method that is invoked automatically during initialization. You can override
 * this method to add 2D controls to the layer.
 *
 * This default implementation does nothing. It is not necessary to invoke this
 * superclass implementation when overriding in a subclass.
 */
-(void) initializeControls;


#pragma mark Updating layer

/**
 * Callback invoked when the contentSize property of this layer changes.
 *
 * This implementation updates the viewport to match the new layer dimensions, and keeps
 * track of whether the layer covers the full view. Subclasses may override to perform
 * activities such as adjusting the layout of buttons and controls to fit the new size.
 */
-(void) contentSizeChanged;

/**
 * Template method that is invoked automatically immediately after this layer has
 * opened on the underlying view, and before the CC3Scene is opened.
 *
 * This default implementation does nothing. You can override this method in your
 * custom subclass to perform set-up activity prior to the scene becoming visible,
 * such as adding gesture recognizers or event handlers.
 *
 * You can invoke the cc3AddGestureRecognizer method from this method to add gesture
 * recognizers. When creating gesture recognizers, you should use your custom CC3Layer
 * as the target of the action messages from the recognizers. You can then use the
 * cc3Convert... family of methods on this instance to convert locations and movements
 * from the gesture recognizers into the coordinate system of this layer.
 *
 * If your application contains several CC3Layers on-screen at once, you may want
 * to register gesture recongizers within the onEnter method of a parent grouping
 * CCNode, instead of from within each CC3Layer.
 */
-(void) onOpenCC3Layer;

/**
 * Template method that is invoked automatically immediately after the CC3Scene
 * has closed, and immediately before this layer is closed.
 *
 * This default implementation does nothing. You can override this method in your
 * custom subclass to perform tear-down activity prior to the scene disappearing.
 *
 * Any gesture recognizers added in the onOpenCC3Layer method by invoking
 * cc3AddGestureRecognizer: will be removed automatically after this method runs.
 * You do not need to use this method to remove any gesture recognizers that you
 * added using the cc3AddGestureRecognizer method. However, if you have bypassed
 * the cc3AddGestureRecognizer method to create and add gesture recognizers, you
 * can use this method to remove them.
 */
-(void) onCloseCC3Layer;

/**
 * Indicates whether this layer should update the 3D viewport on each rendering frame.
 *
 * If the value of this property is YES, the 3D viewport will be updated before each
 * frame is drawn. This is sometimes useful if the layer is changing in a way that is
 * not automatically tracked by the 3D scene.
 *
 * You do not need to set this property when changing the position or scale of the layer.
 * These changes are forwarded to the 3D scene automatically.
 *
 * The initial value of this property is NO. Unless you encounter issues when modifying
 * the layer, leave this property set to NO, to avoid the overhead of calculating an
 * unnecessary transformation matrix on each frame render.
 *
 * As an alternate to updating the viewport on every frame render, consider invoking
 * the updateViewport method whenever your application changes the orientation of this
 * layer in a manner that is not automatically propagated to the CC3Scene viewport.
 */
@property(nonatomic, assign) BOOL shouldAlwaysUpdateViewport;

/**
 * Indicates whether this layer should track the size of the underlying view.
 *
 * If the value of this property is YES, when the size of the underlying view changes 
 * (eg- through a device rotation on iOS, or a window resizing on OSX), the contentSize
 * property of this layer will be set to the new size of the view.
 *
 * The initial value of this property is YES. It is automatically set to NO if the contentSize
 * property of this layer is set to a value other than the size of the underlying view. 
 *
 * You can directly set the value of this property if you have some other sizing management
 * scheme, but be aware that this property will be set to NO each time the contentSize property
 * is set to a value that is not the same size of the view.
 */
@property(nonatomic, assign) BOOL shouldTrackViewSize;

/**
 * This method is invoked periodically when the components in the CC3Scene are to be updated.
 *
 * The dt argument gives the interval, in seconds, since the previous update.
 *
 * This implementation forwards this update to the updateScene: method of the contained
 * CC3Scene instance. Subclasses can override to perform updates to 2D nodes added to
 * this layer, but should be sure to invoke this superclass implementation, or to invoke
 * updateScene: on the CC3Scene directly.
 *
 * Typcially this method is scheduled to be invoked automatically at a periodic interval.
 * When compiling with versions of cocos2d 3.0 or higher, this will happen automatically.
 * When compiling with versions of cocos2d prior to 3.0, you can do so by invoking the
 * scheduleUpdate method on this instance from the initializeControls method.
 *
 * This method is invoked asynchronously to the frame rendering animation loop, to keep the
 * processing of model updates separate from OpenGL ES drawing.
 */
-(void) update: (CCTime)dt;

/**
 * Updates the viewport of the contained CC3Scene instance with the dimensions of this layer.
 *
 * This method is invoked automatically when the position, size, scale, or orientation
 * of this layer changes. You do not need to invoke this method when changing the position
 * or scale of the layer. These changes are forwarded to the CC3Scene viewport automatically.
 *
 * Usually, the application should never need to invoke this method directly. However,
 * if your application changes the orientation of this layer in a manner that is not
 * automatically detected, you can use this method to align the CC3Scene viewport with
 * the updated layer.
 */
-(void) updateViewport;


#pragma mark Developer support

/**
 * Returns a marker string that is pushed onto the GL render stream prior to rendering
 * this node. The group is popped from the GL render stream after this node is rendered.
 *
 * This property returns a NULL pointer. Subclasses that contain renderable content can
 * override to provide a meaningful string. Subclasses should avoid dynamically generating
 * this property on each access, since this property is accessed each time the node is rendered.
 */
@property(nonatomic, readonly) const char* renderStreamGroupMarker;

@end


#if CC3_CC2_RENDER_QUEUE

#pragma mark -
#pragma mark CC3LayerRenderCommand

/** A CCRenderCommand specialized for rendering 3D scenes from a CC3Layer. */
@interface CC3LayerRenderCommand : NSObject <CCRenderCommand> {
	CC3Layer* _cc3Layer;
	CC3NodeDrawingVisitor* _visitor;
}

/** 
 * The drawing visitor to use when drawing the CC3Layer. 
 *
 * This property must be set before queing this command for rendering the CC3Layer.
 */
@property(nonatomic, retain) CC3NodeDrawingVisitor* visitor;

/** Initializes this instance to render the specified CC3Layer. */
-(instancetype) initForCC3Layer: (CC3Layer*) layer;

/** Allocates and initializes an instance to render the specified CC3Layer. */
+(instancetype) renderCommandForCC3Layer: (CC3Layer*) layer;

@end

#endif	// CC3_CC2_RENDER_QUEUE
