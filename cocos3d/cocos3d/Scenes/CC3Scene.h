/*
 * CC3Scene.h
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

#import "CC3Camera.h"
#import "CC3NodeSequencer.h"
#import "CC3RenderSurfaces.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3PerformanceStatistics.h"
#import "CC3ViewController.h"
#import "CC3Backgrounder.h"


/** Default value of the minUpdateInterval property. */
static const CCTime kCC3DefaultMinimumUpdateInterval = 0.0f;

/** Default value of the maxUpdateInterval property. */
static const CCTime kCC3DefaultMaximumUpdateInterval = (1.0f / 15.0f);

/** Default color for the ambient scene light. */
static const ccColor4F kCC3DefaultLightColorAmbientScene = { 0.2f, 0.2f, 0.2f, 1.0f };

@class CC3Layer, CC3TouchedNodePicker;


#pragma mark -
#pragma mark CC3Scene

/**
 * CC3Scene is a CC3Node that manages a 3D scene.
 *
 * CC3Scene has the following responsibilities:
 *   - Acts as the root of the CC3Node structural assembly for the scene
 *   - Manages updating scene activity, including nodes, lights, and the camera
 *     based on a periodic animation trigger from the CC3Layer
 *   - Manages the drawing of the 3D artifacts to the GL engine
 *   - Manages the transition from 2D to 3D behaviour during each drawing frame
 *   - Manages the ordering of drawing of the 3D objects to maximize performance
 *   - facilitates user interaction with the scene by interacting with UI events
 *     occuring in the CC3Layer controls
 *   - supports selection of 3D nodes via UI touch events
 *   - collects performance statistics
 *
 * When creating a 3D application, you will almost always create a subclass of
 * CC3Scene to define the control, features, and behaviour of your 3D scene suitable
 * to your application. In your CC3Scene subclass, your will typically override one
 * or more of the following template methods:
 *
 *   - initializeScene - assemble the objects in your 3D scene, or load them from files.
 *
 *   - updateBeforeTransform: - periodically update the activity of your 3D scene prior to
 *                              the automatic recalulation of the node's transformation
 *                              matrix, and prior to the automatic invoking the same method
 *                              on each of child node of this node.
 *
 *   - updateAfterTransform:  - periodically update the activity of your 3D scene after
 *                              the automatic recalulation of the node's globalTransformMatrix
 *                              and prior to the automatic invoking the same method on each
 *                              of child node of this node.
 *
 *   - onOpen  - invoked automatically when the layer that is holding this scene is first
 *               opened for viewing, or when this scene is assigned to a layer that is already
 *               open. The application can override this method to perform any initialization
 *               that requires the camera frustum, or initial transforms or global properties
 *               (eg- globalLocation) of any nodes.
 *
 *   - onClose - invoked automatically when the layer is removed from viewing, or when this
 *               scene is removed from the layer (as during scene swapping). The application
 *               can override this method to perform any activities associated with removing
 *               the layer and this scene from the view. For example, the application may use
 *               this opportunity to release any memory resources that are no longer needed.
 * 
 * In these methods, you can manipulate most nodes by setting their properties.
 * You can move and orient nodes using the node's location, rotation and scale
 * properties, and can show or hide nodes with the node's visible property.
 *
 * You should override the updateBeforeTransform: method if you need to make changes to
 * the transform properties (location, rotation, scale), of any node. These changes will
 * them automatically be applied to the globalTransformMatrix of the node and its child nodes.
 *
 * You should override the updateAfterTransform: method if you need access to the
 * global transform properties (globalLocation, globalRotation, globalScale), of a node
 * since these properties are only valid after the globalTransformMatrix has been recalculated.
 * An example of where access to the global transform properties would be useful is in
 * the execution of collision detection algorithms.
 *
 * To access nodes in your scene, you can use the method getNodeNamed: on the CC3Scene
 * (or any node). However, if you need to access the same node repeatedly, for example
 * to update it on every frame, it's highly recommended that you retrieve it once and
 * then cache it in an instance variable in your CC3Scene instance.
 *
 * By default, the initializeScene, updateBeforeTransform:, and updateAfterTransform:
 * methods do nothing. Subclasses do not need to invoke this default superclass
 * implementations in the overridden methods. The updateBeforeTransform: and
 * updateAfterTransform: methods are defined in the CC3Node class.
 * See the documentation there.
 *
 * If you change the contents of the scene outside of the normal update mechanism,
 * for instance, as a result of a user event, you may find that the next frame is
 * rendered without the updated content. Depending on the degree of change to your
 * scene (for instance, if you have removed and added many nodes), you may notice a
 * flicker. To avoid this, you can use the updateScene method to force your updates
 * to be processed immediately, without waiting for the next update interval.
 *
 * You must add at least one CC3Camera to your 3D scene to make it viewable. This
 * camera may be added directly, or it may be added as part of a larger node assembly.
 * Regardless of the technique used to add cameras, the CC3Scene will take the first
 * camera added and automatically make it the activeCamera.
 *
 * The camera can also be used to project global locations within the 3D scene onto
 * a 2D point on the screen view, and can be used to project 2D screen points onto
 * a ray or plane intersection within the 3D scene. See the class notes of  CC3Camera
 * for more information on mapping between 3D and 2D locations.
 *
 * You can add fog to your scene using the fog property. Fog has a color and blends
 * with the display of objects within the scene. Objects farther away from the camera
 * are affected by the fog more than objects that are closer to the camera.
 *
 * During drawing, the nodes can be traversed in the hierarchical order of the
 * node structural assembly, starting at the CC3Scene instance that forms the root node
 * of the node assembly. Alternately, and preferrably, the CC3Scene can use a
 * CC3NodeSequencer instance to arrange the nodes into a linear sequence, ordered and
 * grouped based on definable sorting priorities. This is beneficial, because it allows
 * the application to order and group drawing operations in ways that reduce the number
 * and scope of state changes within the GL engine, thereby improving performance and
 * throughput.
 * 
 * For example, when drawing, nodes could be grouped by the drawing sequencer so that
 * opaque objects are drawn prior to blended objects, and an application with many
 * objects that use the same material or mesh can be sorted so that nodes with like
 * materials or meshes are grouped together. It is highly recommended that you use a
 * CC3NodeSequencer, and this is the default configuration for CC3Scene instances.
 *
 * The CC3Scene maintains this drawing sequence separately from the hierarchical node
 * assembly. This allows the maintenance of the hierarchical parent-child relationships
 * for operations such as movement and transformations, while simultaneously enabling
 * more efficient drawing operations through node drawing sequencing.
 *
 * An instance of CC3Scene is held by an instance of CC3Layer, which is a subclass of
 * the cocos2d CCLayer class, and can participate with other cocos2d layers and CCNodes
 * in an overall cocos2d scene. During drawing, the CC3Layer delegates all 3D operations
 * to its CC3Scene instance. You will also typically create a subclass of CC3Layer that
 * is customized for your application. In most cases, you will add methods and state to
 * both your CC3Scene and CC3Layer subclasses to facilitate user interaction.
 * 
 * The CC3Layer and CC3Scene can process touch events. To enable touch event handling,
 * set the isTouchEnabled property of your customized CC3Layer to YES. Touch events are
 * forwarded from the CC3Layer to the touchEvent:at: method of your CC3Scene for handling
 * by your CC3Scene.
 *
 * Since the touch-move events are both voluminous and seldom used, the implementation
 * of ccTouchMoved:withEvent: has been left out of the default CC3Layer implementation.
 * To receive and handle touch-move events for object picking, copy the commented-out
 * ccTouchMoved:withEvent: template method implementation in CC3Layer to your customized
 * CC3Layer subclass.
 *
 * The default implementation of the touchEvent:at: method forwards all touch events to
 * the node picker held in the touchedNodePicker property. The node picker determines
 * which 3D node is under the touch point. Object picking is handled asynchronously, and
 * once the node is retrieved, the nodeSelected:byTouchEvent:at: callback method will be
 * invoked on your customized CC3Scene instance. You indicate which nodes in your scene
 * should respond to touch events by setting the isTouchEnabled property on those nodes
 * that you want to trigger a touch event callback to the nodeSelected:byTouchEvent:at:
 * method. See the description of the nodeSelected:byTouchEvent:at: method and the
 * CC3Node isTouchEnabled property for useful hints about choosing which nodes to enable
 * for touch selection.
 *
 * Be aware that node picking from touch events is expensive, and you should override
 * the touchEvent:at: method to forward to the node picker only those touch events that
 * you actually intend to select a node. By default, all touch events are forwarded from
 * the touchEvent:at: method. You should override this implementation, handle touch events
 * that are not used for selection directly in this method, and forward only those events
 * for which you want a node picked, to the touchedNodePicker.
 *
 * The node picker uses a colorization algorithm to determine which node is under the
 * touch point. When a touch event occurs and has been forwarded to the node picker,
 * the node picker draws the scene in solid colors, with each node a different color,
 * and then reads the color of the pixel under the touch point to identify the object
 * under the touch point. This is performed under the covers, and the scene is immediately
 * redrawn in true colors and textures before being presented to the screen, so the user
 * is never aware that the scene was drawn twice.
 *
 * Depending on the complexity of the application, it may instantiate a single CC3Scene,
 * instance, or multiple instances if the application progresses from scene to scene.
 * Similarly, the application may have a single CC3Layer, or multiple CC3Layers.
 * Each CC3Layer may have its own CC3Scene instance, or may share a single instance.
 *
 * To maximize GL throughput, all OpenGL ES state is tracked by an instance of CC3OpenGL.
 * During drawing, the CC3OpenGL instance is available through the gl property of the
 * CC3NodeDrawingVisitor. During other activities, a singleton instance of CC3OpenGL can
 * be retrieved from CC3OpenGL.sharedGL.
 * 
 * It is critical that all changes to GL state are made through the CC3OpenGL instance.
 * When adding or overriding functionality in this framework, do NOT make gl* function
 * calls directly if there is a corresponding method defined on the CC3OpenGL class.
 * Instead, route the state change request through the appropriate CC3OpenGL method.
 *
 * You can collect statistics about the performance of your cocos3d application by setting
 * the performanceStatistics property to an appropriate instance of a statistics collector.
 * By default, no statistics are collected. See the notes of the performanceStatistics
 * property for more information.
 */
@interface CC3Scene : CC3Node {
	NSMutableArray* _lights;
	NSMutableArray* _billboards;
	CC3Layer* _cc3Layer;
	CC3Camera* _activeCamera;
	CC3NodeSequencer* _drawingSequencer;
	CC3TouchedNodePicker* _touchedNodePicker;
	CC3PerformanceStatistics* _performanceStatistics;
	CC3NodeUpdatingVisitor* _updateVisitor;
	CC3NodeDrawingVisitor* _viewDrawingVisitor;
	CC3NodeDrawingVisitor* _envMapDrawingVisitor;
	CC3NodeDrawingVisitor* _shadowVisitor;
	CC3NodeSequencerVisitor* _drawingSequenceVisitor;
	CC3MeshNode* _backdrop;
	CC3Fog* _fog;
	ccColor4F _ambientLight;
	NSTimeInterval _timeAtOpen;
	NSTimeInterval _elapsedTimeSinceOpened;
	CCTime _minUpdateInterval;
	CCTime _maxUpdateInterval;
	CCTime _deltaFrameTime;
	BOOL _shouldDisplayPickingRender : 1;
}

/** Returns whether this node is a scene. Returns YES. */
@property(nonatomic, readonly) BOOL isScene;

/**
 * The CC3Layer that is holding this 3D scene.
 *
 * This property is set automatically when this scene is assigned to the CC3Layer.
 * The application should not set this property directly.
 */
@property(nonatomic, assign) CC3Layer* cc3Layer;

/**
 * The controller that is controlling the view displaying this scene.
 * 
 * This property is retrieved from the same property on the CC3Layer holding this scene,
 * and is made available to support delegation from this 3D scene.
 */
@property(nonatomic, retain, readonly) CC3ViewController* controller;

/**
 * The 3D camera that is currently displaying the scene of this scene.
 *
 * You can set this property directly to a camera that you create, or if this property is not
 * set directly, it will be set automatically to the first CC3Camera added to this scene via
 * the addChild: method, including cameras contained somewhere in a structural assembly of
 * nodes whose root node was added to this instance via addChild:. In this way, adding the
 * root node of a node assembly loaded from a file will set the activeCamera property to the
 * first camera found in the assembly, if the property was not already set.
 *
 * Multiple cameras can be added to the scene, but only one can be active at any one time.
 * You can cycle through different views of your scene by loading several cameras into
 * your scene, and then setting this property to one after the other, as desired.
 *
 * When this property is set to a new camera, any nodes that were targetted at the old
 * camera will be re-targetted to the new camera, and all transform listeners that were
 * previously registered with the old camera via the addTransformListener: method will
 * automatically be moved to the new camera, ensuring that those nodes will continue to
 * receive notifications when the camera changes. In addition, the hasInfiniteDepthOfField
 * property from the old camera is copied to the new active camera, to ensure that
 * shadows continue to be rendered correctly with the new active camera.
 *
 * The activeCamera is retained, so removing the camera node from the scene does not change
 * this property. To remove the activeCamera from the scene, you should first set a different
 * camera as the activeCamera, and then invoke remove on the old camera.
 *
 * The initial value is nil. You must add at least one CC3Camera to your 3D scene to
 * make it viewable.
 */
@property(nonatomic, retain) CC3Camera* activeCamera;

/**
 * Returns the lights currently illuminating this scene.
 *
 * This is a read-only convenience property. You should not change the contents of the
 * array returned by this method. To add a light to the scene, add the light to a parent
 * node (or the scene itself) using the addChild: method. To remove a light from the scene,
 * invoke the remove method on the light itself, or the removeChild: method on its parent.
 */
@property(nonatomic, retain, readonly) NSArray* lights;

/**
 * To create a backdrop for this scene, set this to a CC3Backdrop instance, covered with
 * either a solid color, or a texture.
 *
 * The backdrop appears behind everything else in the scene, and does not change as the
 * camera moves around the scene. If you need to have more realistic scenery that changes
 * as the camera moves and pans, consider adding a skybox to your scene instead of using
 * a backdrop. You can create a skybox using a spherical or cube mesh, and applying a
 * cube-mapped texture to it.
 */
@property(nonatomic, retain) CC3MeshNode* backdrop;

/**
 * If set, creates fog within the CC3Scene. Fog has a color and blends with the
 * display of objects within the scene. Objects farther away from the camera are
 * affected by the fog more than objects that are closer to the camera.
 *
 * The initial value is nil, indicating that the scene will contain no fog.
 */
@property(nonatomic, retain) CC3Fog* fog;

/**
 * The touchedNodePicker picks the node under the point at which a touch event occurred.
 *
 * Touch events are forwarded to the touchedNodePicker from the touchEvent:at:
 * method when a node is to be picked from a particular touch event.
 */
@property(nonatomic, retain) CC3TouchedNodePicker* touchedNodePicker;

/** 
 * Returns whether this scene is illuminated.
 *
 * The scene is illuminated if the scene contains at least one light, or the value of
 * the ambientLight property is not black.
 */
@property(nonatomic, readonly) BOOL isIlluminated;

/**
 * The color of the ambient light of the scene. This is independent of any CC3Light
 * nodes that are added as child nodes. You can use this to provide general flat
 * lighting in your scene without having to add light nodes.
 *
 * The initial value is set to kCC3DefaultLightColorAmbientScene.
 */
@property(nonatomic, assign) ccColor4F ambientLight;

/**
 * Returns the total light illuminating the scene.
 *
 * Returns the arithmetic sum of the ambientLight property, plus the ambientColor
 * and diffuseColor properties of all visible lights in the scene.
 *
 * This property can be used to give rough maximum indications of light
 * intensity for the purpose of calculating shadow effects, etc.
 */
@property(nonatomic, readonly) ccColor4F totalIllumination;

/** Returns whether any of the lights in the scene are casting shadows. */
@property(nonatomic, readonly) BOOL doesContainShadows;

/**
 * Updates the relative intensities of each light by invoking the
 * updateRelativeIntensityFrom: method on each light.
 *
 * Certain characteristics, such as shadow intensities, depend on the relative
 * intensity of this light, relative to the total intensity of all lights in the scene.
 *
 * This method is invoked automatically when any property that affects the
 * intensity of any light in this scene is changed. In most situations, the
 * application should generally have no need to invoke this method directly.
 */
-(void) updateRelativeLightIntensities;

/**
 * If set, collects statistics about the updating and drawing performance of the 3D scene.
 *
 * By default, this property is nil, and no statistics are accumulated. To accumulate
 * statistics, set this property with an appropriate instance. Subclasses of
 * CC3PerformanceStatistics can customize the statistics that are collected.
 *
 * To allow flexibility in accumulating statistics, the statistics collector does not
 * automatically clear the accumulated statistics. If you set this property with a
 * statistic collector, it is your responsibility to read the values, and reset the
 * performanceStatistics instance periodically, using the CC3PerformanceStatistics
 * reset method, to ensure that the counters do not overflow. Depending on the
 * complexity and capabilities of your application, you should reset the performance
 * statistics at least every few seconds.
 */
@property(nonatomic, retain) CC3PerformanceStatistics* performanceStatistics;


#pragma mark CCRGBAProtocol and CCBlendProtocol support

/**
 * Implementation of the CCRGBAProtocol color property.
 *
 * Returns the color of the node in the backdrop property, or if there is no backdrop,
 * returns the value of the superclass implementation.
 *
 * Setting this property set the color of the node in the backdrop property, but does
 * not propagate the color change to all descendant nodes.
 */
@property(nonatomic, assign) ccColor3B color;

/**
 * Implementation of the CCRGBAProtocol opacity property.
 *
 * Returns the opacity of the node in the backdrop property, or if there is no backdrop,
 * returns the value of the superclass implementation.
 *
 * Setting this property set the opacity of the node in the backdrop property, and
 * propagates the opacity change to all descendant nodes.
 */
@property(nonatomic, assign) GLubyte opacity;


#pragma mark Allocation and initialization

/**
 * This template method is where a subclass should populate the 3D scene models.
 * This can be accomplished through a combination of instantiting model objects
 * directly and loading them from model data files exported from a 3D editor.
 *
 * This CC3Scene instance forms the base of a structural tree of nodes. Model objects
 * are added as nodes to this root node instance using the addChild: method.
 *
 * When loading from files, or adding large node assemblies, you can access individual
 * nodes using the getNodeNamed: method, if you need to set futher initial state.
 * 
 * If you will need to access the same node repeatedly, for example to update it on
 * every frame, it's highly recommended that you retrieve it once in this method,
 * and cache it in an instance variable in your CC3Scene subclass instance.
 *
 * You must add at least one CC3Camera to your 3D scene to make it viewable.
 * This can be instantiated directly, or loaded from a file as part of a node assembly.
 *
 * By default, this method does nothing. Subclasses do not need to invoke this default
 * superclass implementation in the overridden method.
 */
-(void) initializeScene;

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 */
+(id) scene;


#pragma mark Updating scene state

/**
 * Opens the scene for viewing. This implementation invokes the play method to start
 * update activity within the scene, then invokes the updateScene method to update
 * the scene state and transforms in preparation for the first displayable frame,
 * and then invokes the onOpen callback method on this instance, to give the application
 * an opportunity to perform any final activities before the first frame is rendered.
 *
 * This method is automatically invoked by the CC3Layer that holds this scene when
 * that layer is displayed. If the layer is running already when this scene is
 * assigned to the layer, this method is invoked right away. The applicaiton should
 * never need to invoke this method directly.
 */
-(void) open;

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene is first displayed.
 *
 * Alternately, this callback method is also invoked automatically when this CC3Scene
 * is attached to a CC3Layer, if the layer is already running, as would be the case
 * when 3D scenes are changed by changing the CC3Scene that is attached to the layer.
 *
 * By the time this method is invoked:
 *   - The CC3Layer has been attached to the view environment, has a contentSize,
 *     and is running.
 *   - The play method has been invoked on this CC3Scene, and the isRunning property
 *     of this scene is set to YES.
 *   - The initial updateScene invocation has been performed, and the initial transforms
 *     and global properties (eg- globalLocation) of all nodes have been been established.
 *   - The camera frustum, modelview, and projection transforms have been established.
 * 
 * The default implementation of this method does nothing.
 *
 * The application can override this method to perform any activities associated
 * with the initial display of the scene, that depend on the camera projection
 * or the global properties of any nodes.
 *
 * In particular, if desired, this method is a good place to invoke one of CC3Camera
 * moveToShowAllOf:... family of methods, used to cause the camera to automatically
 * focus on and frame a particular node, or the entire scene.
 */
-(void) onOpen;

/**
 * Closes the scene for viewing. This implementation invokes the pause method to stop
 * update activity and actions within the scene, and then invokes the onClose callback
 * method on this instance, to give the application an opportunity to perform any
 * activities as the scene closes down.
 *
 * This method is automatically invoked by the CC3Layer that holds this scene when
 * that layer has been removed from the display, or when this CC3Scene has been
 * replaced with another CC3Scene in the CC3Layer. The applicaiton should never
 * need to invoke this method directly.
 */
-(void) close;

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene has been removed from display.
 *
 * Alternately, this callback method is also invoked automatically when this CC3Scene
 * is removed from the CC3Layer, as would be the case when 3D scenes are changed by
 * changing the CC3Scene that is attached to the layer.
 *
 * By the time this callback method is invoked, the pause method on this CC3Scene
 * has been invoked, and the isRunning property is set to NO.
 *
 * The default implementation of this method does nothing.
 *
 * The application can override this method to perform any activities associated
 * with removing the layer and this scene from the view. For example, the application
 * may use this opportunity to release any memory resources that are no longer needed.
 */
-(void) onClose;

/**
 * Starts the dynamics of the 3D scene model, including internal updates and CCActions,
 * by setting the isRunning property to YES.
 *
 * The scene will automatically start playing when added to a CC3Layer, and will
 * automatically pause when removed from the CC3Layer. During typical use, you will
 * not need to invoke this method directly.
 */
-(void) play;

/**
 * Pauses the dynamics of the 3D scene model, including internal updates and CCActions,
 * by setting the isRunning property to NO.
 *
 * The scene will automatically start playing when added to a CC3Layer, and will
 * automatically pause when removed from the CC3Layer. During typical use, you will
 * not need to invoke this method directly.
 */
-(void) pause;

/**
 * The visitor that is used to visit the nodes to update and transform them during scheduled updates.
 *
 * This property defaults to an instance of the class returned by the updateVisitorClass method.
 * The application can set a different visitor if desired.
 */
@property(nonatomic, retain) CC3NodeUpdatingVisitor* updateVisitor;

/**
 * Returns the class of visitor that will automatically be instantiated into the
 * updateVisitor property.
 *
 * The returned class must be a subclass of CC3NodeUpdatingVisitor. This implementation
 * returns CC3NodeUpdatingVisitor. Subclasses may override to customize the behaviour
 * of the updating visits.
 */
-(id) updateVisitorClass;

/** @deprecated No longer used. */
@property(nonatomic, retain) id transformVisitor DEPRECATED_ATTRIBUTE;

/**
 * The value of this property is used as the lower limit accepted by the updateScene: method.
 * Values sent to the updateScene: method that are smaller than this maximum will be clamped
 * to this limit. If the value of this property is zero (or negative), the updateScene: method
 * will use the value that is passed to it unchanged.
 *
 * You can set this value if your custom scene cannot work with a zero interval, or with an
 * interval that is too small. For instance, if the logic of your scene uses the update
 * interval as the denominator in a division calculation, you would want to set this property
 * to a value slightly above zero.
 *
 * The initial value of this property is set to kCC3DefaultMinimumUpdateInterval.
 *
 * The behaviour described here does not apply to nodes controlled by CCActionIntervals,
 * which are not affected by the time between updates, or the value of this property.
 */
@property(nonatomic, assign) CCTime minUpdateInterval;

/**
 * If the value of this property is greater than zero, it will be used as the upper limit
 * accepted by the updateScene: method. Values sent to the updateScene: method that are larger
 * than this maximum will be clamped to this limit. If the value of this property is zero
 * (or negative), the updateScene: method will use the value that is passed to it unchanged.
 *
 * Resource limitations, and activities around start-up and shut-down, can sometimes cause
 * an occasional large interval between consecutive updates. These large intervals can
 * sometimes cause object in the scene to appear to jump around, and if you are using
 * physics simulation, might cause collisions to be missed.
 *
 * Setting a maximum update interval can help eliminate both concerns, but the trade-off
 * may be less realistic real-time behaviour. With a limit in place, larger intervals
 * between updates will make the scene appear to run in slow motion, rather than jump around.
 *
 * The initial value of this property is set to kCC3DefaultMaximumUpdateInterval.
 *
 * The behaviour described here does not apply to nodes controlled by CCActionIntervals,
 * which are not affected by the time between updates, or the value of this property.
 */
@property(nonatomic, assign) CCTime maxUpdateInterval;

/**
 * This method is invoked periodically when the components in the CC3Scene are to be updated.
 *
 * Typcially this method is invoked automatically from a CC3Layer instance via a scheduled update,
 * but may also be invoked by some other periodic operation, or even directly by the application.
 *
 * This method is invoked asynchronously to the frame rendering animation loop, to keep the
 * processing of model updates separate from OpenGL ES drawing.
 *
 * The dt argument gives the interval, in seconds, since the previous update. This value can be
 * used to create realistic real-time motion that is independent of specific frame or update rates.
 * If either of the minUpdateInterval or maxUpdateInterval properties have been set, this method
 * will clamp dt to those limits. See the description of minUpdateInterval and maxUpdateInterval
 * for more information about clamping the update interval.
 *
 * If this instance is not running, as indicated by the isRunning property, this method does nothing.
 *
 * As implemented, this method performs the following processing steps, in order:
 *   -# Checks isRunning property of this instance, and exits immediately if not running.
 *   -# If needed, clamps the dt property to the value in maxUpdateInterval property.
 *   -# Invokes updateBeforeTransform: on this instance.
 *   -# Triggers recalculation of the globalTransformMatrix on this node.
 *   -# Updates each child (including invoking updateBeforeTransform:, recalulating the child
 *      node's globalTransformMatrix, and invoking updateAfterTransform: on each descendant, in order).
 *   -# Invokes updateAfterTransform: on this instance.
 *   -# Updates target tracking in the active camera, and all lights and billboards.
 *
 * Sublcasses should not override this updateScene: method. To customize the behaviour of the
 * 3D model scene, sublcasses should override the updateBeforeTransform: or updateAfterTransform:
 * methods. Those two methods are defined and documented in the CC3Node class. Please refer
 * there for more documentation.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateScene: (CCTime) dt;

/**
 * Invokes the updateScene: method with the value of the minUpdateInterval property.
 *
 * This method temporarily ensures that the isRunning property is set to YES internally,
 * to ensure that the updateScene: method will run successfully.
 *
 * You can use this method if you change the contents of the scene outside of the normal
 * update mechanism, for instance, as a result of a user event, and need the update to
 * be processed immediately, without waiting for the next update interval, and even if
 * the scene has not been set running yet via the play method, or isRunning property.
 *
 * This method is automatically invoked from the open method, to ensure that transforms
 * have been processed before the first rendering frame draws the contents of the scene.
 */
-(void) updateScene;

/** The delta time from the most recent invocation of the updateScene: method. */
@property(nonatomic, readonly) CCTime deltaFrameTime;

/** 
 * The elapsed real-time, measured in seconds, since this scene was last opened.
 *
 * The value of this property will be zero until, and whenever, the onOpen method is invoked.
 * After the scene is opened, the value of this property will be updated on each update frame,
 * and indicates how long this scene has been open.
 */
@property(nonatomic, readonly) NSTimeInterval elapsedTimeSinceOpened;


#pragma mark Drawing

/**
 * This method is invoked when the objects in the CC3Scene are to be drawn.
 *
 * Typcially this method is invoked automatically from the draw method of the CC3Layer instance
 * on each frame rendering cycle. This method is invoked asynchronously to the model updating loop,
 * to keep the processing of OpenGL ES drawing separate from model updates.
 *
 * This implementation establishes the 3D rendering environment, handles node picking, invokes
 * the drawSceneContentWithVisitor: method to draw the contents of this scene, reverts to the 2D rendering
 * environment of the CC3Layer, and renders any 2D overlay billboards.
 *
 * If you want to customize the scene rendering flow, such as performing multiple-passes, or
 * adding post-processing effects, you should override the drawSceneContentWithVisitor: method.
 *
 * If the scene was touched by the user (finger or mouse), this method invokes the node picking
 * algorithm to determine the node that is under the touch point. This is performed prior to
 * invoking the drawSceneContentWithVisitor: method.
 *
 * This method is invoked automatically during each rendering frame. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) drawScene;

/**
 * Template method that draws the content of the scene.
 *
 * This method is invoked automatically by the drawScene method, once the 3D environment has
 * been established. Once this method is complete, the 2D rendering environment will be
 * re-established automatically, and any 2D billboard overlays will be rendered. This method
 * does not need to take care of any of this set-up and tear-down.
 *
 * This implementation turns on the lighting contained within the scene, and performs a single
 * rendering pass of the nodes in the scene.
 *
 * The core of the drawing is handled by invoking the visit: method on the specified visitor,
 * with this scene as the argument. Several template methods are available to provide
 * "building blocks" to help you build the functionality in this method, and which you can
 * individually customize as needed. The order of behavior of this method is:
 *   - invoke illuminateWithVisitor:        - turns on scene lighting
 *   - visit backdrop with visitor:			- draws an optional fixed backdrop
 *   - visit scene with visitor				- draws the nodes in the drawingSequencer
 *   - draw shadows using special visitor	- draws shadow volumes
 *
 * You can override this method to customize the scene rendering flow, such as performing
 * multiple rendering passes on different surfaces, or adding post-processing effects, using
 * the template methods mentioned above.
 *
 * Note that rendering output is directed to the render surface held in the renderSurface
 * property of the visitor. By default, that is set to the render surface held in the viewSurface
 * property of this scene. If you override this method, you can set the renderSurface property
 * of the visitor to another surface, and then invoke this superclass implementation, to render
 * this scene to a texture for later processing.
 *
 * When overriding the drawSceneContentWithVisitor: method with your own specialized rendering,
 * steps, be careful to avoid recursive loops when rendering to textures and environment maps.
 * For example, you might typically override drawSceneContentWithVisitor: to include steps to
 * render environment maps for reflections, etc. In that case, you should also override the
 * drawSceneContentForEnvironmentMapWithVisitor: to render the scene without those additional
 * steps, to avoid the inadvertenly invoking an infinite recursive rendering of a scene to a
 * texture while the scene is already being rendered to that texture.
 *
 * To maintain performance, by default, the depth buffer of the surface is not specifically
 * cleared when 3D drawing begins. If this scene is drawing to a surface that already has 
 * depth information rendered, you can override this method and clear the depth buffer before
 * continuing with 3D drawing, by invoking clearDepthContent on the renderSurface of the visitor,
 * and then invoking this superclass implementation, or continuing with your own drawing logic.
 *
 * Examples of when the depth buffer should be cleared are when this scene is being drawn
 * on top of other 3D content (as in a sub-window), or when any 2D content that is rendered
 * behind the scene makes use of depth drawing. See also the closeDepthTestWithVisitor:
 * method for more info about managing the depth buffer.
 */
-(void) drawSceneContentWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Template method that draws the content of the scene for use in an environment map texture.
 *
 * This implementation invokes the clearColorAndDepthContent method on the surface returned by
 * the visitor's renderSurface property, to clear the color and depth content from the environment
 * map buffers, and then invokes the drawSceneContentWithVisitor: method of this scene, rendering
 * the entire scene to the environment map, in exacly the same way the scene is rendered to the view.
 *
 * You can override this method to perform rendering tailored for environment maps. For instance,
 * an environment map typically may not require complete fidelity, and to conserve performance,
 * you may want to simplify the scene, or avoid certain costly activities such as drawing shadows,
 * multi-pass rendering, or post-rendering processing.
 *
 * When overriding the drawSceneContentWithVisitor: method with your own specialized rendering,
 * steps, be careful to avoid recursive loops when rendering to textures and environment maps.
 * For example, you might typically override drawSceneContentWithVisitor: to include steps to
 * render environment maps for reflections, etc. In that case, you should also override the
 * drawSceneContentForEnvironmentMapWithVisitor: to render the scene without those additional
 * steps, to avoid the inadvertenly invoking an infinite recursive rendering of a scene to a
 * texture while the scene is already being rendered to that texture.
 */
-(void) drawSceneContentForEnvironmentMapWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Template method that draws the static backdrop in the backdrop property, if it exists.
 *
 * The backdrop is not drawn if this scene is being drawn overlaid on the device camera image,
 * as indicated by the isOverlayingDeviceCamera property of this scene's view controller.
 */
-(void) drawBackdropWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Template method that draws shadows.
 *
 * The visitor passed in here should be the specialized visitor held in the shadowVisitor property.
 * Before invoking this method, you can invoke the alignShotWith: method on the shadowVisitor to
 * align the camera and renderSurface properties of the shadowVisitor with that of the main
 * drawing visitor.
 */
-(void) drawShadowsWithVisitor:  (CC3NodeDrawingVisitor*) visitor;

/**
 * Template method that turns on lighting of the 3D scene.
 *
 * This method is usually invoked from the drawSceneContentWithVisitor: method.
 *
 * Default implementation turns on global ambient lighting, and each CC3Light instance.
 */
-(void) illuminateWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Template method that leaves depth testing in the state required by the 2D environment.
 *
 * Since most 2D drawing does not need to use depth testing, and clearing the depth buffer is
 * a relatively costly operation, the standard behaviour is to simply turn depth testing off.
 * However, subclasses can override this method to leave depth testing on and clear the depth
 * buffer in order to permit 2D drawing to make use of depth testing.
 *
 * This method is invoked automatically during the transition back to 2D drawing, incluing
 * between the CC3Scene and the CC3Layer, and when drawing a CC3Billboard containing a 2D
 * cocos2d CCNode. Normally the application never needs to invoke this method directly.
 */
-(void) closeDepthTestWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * The node sequencer being used by this instance to order the drawing of child nodes.
 *
 * During drawing, the nodes can be traversed in the hierarchical order of the node structural
 * assembly, starting at the CC3Scene instance that forms the root node of the node assembly.
 * Alternately, and preferrably, the CC3Scene can use a CC3NodeSequencer instance to arrange
 * the nodes into a linear sequence, ordered and grouped based on definable sorting priorities.
 * This is beneficial, because it allows the application to order and group drawing operations
 * in ways that reduce the number and scope of state changes within the GL engine, thereby
 * improving performance and throughput.
 * 
 * For example, when drawing, nodes could be grouped by the drawing sequencer so that opaque
 * objects are drawn prior to blended objects, and an application with many objects that use
 * the same material or mesh can be sorted so that nodes with like materials or meshes are
 * grouped together. It is highly recommended that you use a CC3NodeSequencer.
 *
 * The default drawing sequencer includes only nodes with local content, and groups
 * them so that opaque nodes are drawn first, then nodes with blending.
 */
@property(nonatomic, retain) CC3NodeSequencer* drawingSequencer;

/** Returns whether this instance is using a drawing sequencer. */
@property(nonatomic, readonly) BOOL isUsingDrawingSequence;

/**
 * The view's surface manager. 
 *
 * The returned object manages the surfaces that render directly to the view, including the
 * surfaces in the viewSurface and pickingSurface properties, and manages the resolution of 
 * anti-aliasing multisampling.
 *
 * You can access this property from the onOpen method of this scene, or any time after.
 * This property is not valid before that time.
 */
@property(nonatomic, retain, readonly) CC3GLViewSurfaceManager* viewSurfaceManager;

/**
 * The render surface being used to draw to the view on the screen.
 *
 * When this render surface is active, all drawing activity is rendered to the framebuffer
 * attached to the view.
 *
 * The value of this property is retrieved from the surface manager in the viewSurfaceManager property.
 */
@property(nonatomic, retain, readonly) id<CC3RenderSurface> viewSurface;

/**
 * The visitor that is used to visit the nodes to draw them to the view on the screen.
 *
 * This property defaults to an instance of the class returned by the viewDrawVisitorClass method.
 * The application can set a different visitor if desired.
 */
@property(nonatomic, retain) CC3NodeDrawingVisitor* viewDrawingVisitor;

/**
 * Returns the class of visitor that will automatically be instantiated into the
 * viewDrawingVisitor property.
 *
 * The returned class must be a subclass of CC3NodeDrawingVisitor. This implementation returns
 * CC3NodeDrawingVisitor. Subclasses may override to customize the behaviour of the drawing visits.
 */
-(id) viewDrawVisitorClass;

/** 
 * The visitor that is used to visit the nodes to draw them to an environment map texture.
 *
 * If not set directly, the first time it is accessed, a new instance of the class
 * returned by the viewDrawVisitorClass method will be created and set into this property.
 * The isDrawingEnvironmentMap property of that visitor is set to YES, and the camera 
 * property is set to a new camera whose fieldOfView property is set to 90 degrees.
 */
@property(nonatomic, retain) CC3NodeDrawingVisitor* envMapDrawingVisitor;

/**
 * The visitor that is used to visit shadow nodes to draw them to the GL engine.
 *
 * This property is set automatically when a shadow is added somewhere in the scene,
 * and is cleared when the all shadows have been removed from the scene.
 * This property defaults to an instance of the CC3ShadowDrawingVisitor class.
 * The application can set a different visitor if desired. 
 */
@property(nonatomic, retain) CC3NodeDrawingVisitor* shadowVisitor;

/**
 * The sequencer visitor used to visit the drawing sequencer during operations
 * on the drawing sequencer, such as adding or removing individual nodes.
 *
 * This property defaults to an instance of the CC3NodeSequencerVisitor class.
 * The application can set a different visitor if desired.
 */
@property(nonatomic, retain) CC3NodeSequencerVisitor* drawingSequenceVisitor;

/** @deprecated Depth clearing is now handled by app in drawSceneContentWithVisitor:. */
@property(nonatomic, assign) BOOL shouldClearDepthBuffer;

/** @deprecated Use the shouldClearDepthBuffer propety instead. */
@property(nonatomic, assign) BOOL shouldClearDepthBufferBefore3D DEPRECATED_ATTRIBUTE;

/** @deprecated Use the shouldClearDepthBuffer propety instead. */
@property(nonatomic, assign) BOOL shouldClearDepthBufferBefore2D DEPRECATED_ATTRIBUTE;


#pragma mark Touch handling

/**
 * This method is invoked from the CC3Layer whenever a touch event occurs, if that layer has
 * indicated that it is interested in receiving touch events, and is handling them, or, under OSX,
 * whenever a mouse event occurs, if that layer has indicated that it is interested in receiving
 * mouse events, and is handling them
 *
 * This method is not invoked when gestures are used for user interaction. The CC3Layer processes
 * gestures and invokes higher-level application-defined behaviour on the application's customized
 * CC3Scene subclass.
 *
 * The touchType is one of the enumerated touch types: kCCTouchBegan, kCCTouchMoved, kCCTouchEnded,
 * or kCCTouchCancelled, and may have originated as a single-touch or multi-touch event.
 *
 * When running under OSX, this mouse events are treated as the corresponding touch event.
 * The specified touchType will be one of the following:
 *   - kCCTouchBegan:	a mouse-down event has occurred
 *   - kCCTouchMoved:	a mouse-drag event has occurred (with the button down)
 *   - kCCTouchEnded:	a mouse-up event has occurred
 *
 * To enable touch events, set the touchEnabled property of the CC3Layer. Once the CC3Layer is
 * touch-enabled, this method is invoked automatically whenever a single-touch event occurs.
 *
 * To enable mouse events when running under OSX, set the mouseEnabled property of the CC3Layer. Once
 * the CC3Layer is mouse-enabled, this method is invoked automatically whenever a mouse event occurs.
 *
 * Since the touch-move or mouse-move (hover) events are both voluminous and seldom used, the
 * handling of the ccTouchMoved:withEvent: and mouseMoved: methods have been left out of the
 * default CC3Layer implementation. To receive and handle touch-move events, copy the commented-out
 * ccTouchMoved:withEvent: template method implementation in CC3Layer to your customized CC3Layer
 * subclass. To receive and handle mouse-move events while hovering, implement the ccMouseMoved:
 * method in your customized CC3Layer, and set the acceptsMouseMovedEvents property of the main
 * window to YES during app initialization
 *
 * This default implementation forwards touch-down events to the pickNodeFromTouchEvent:at: method,
 * which determines which 3D node is under the touch point, and does nothing with touch-move and
 * touch-up events. For the touch-down events, object picking is handled asynchronously, and once the
 * node is retrieved, the nodeSelected:byTouchEvent:at: callback method will be invoked on this instance.
 *
 * Node picking from touch events is somewhat expensive. If you do not require node picking, you
 * should override this implementation and avoid forwarding the touch-down events to this method.
 * You can also override this method to enhance the touch interaction, such as swipe detection,
 * or dragging & dropping objects. You can use the implementation of this method as a template
 * for enhancements.
 *
 * Node selection from tap events can also be handled by using the unprojectPoint: method of the
 * active camera to convert the 2D touch-point to a 3D ray, and then using the 
 * nodesIntersectedByGlobalRay: method to detect the nodes whose bounding volumes are intersected
 * (punctured) by the ray. See the notes of the pickNodeFromTouchEvent:at: method for further
 * discussion of the relative merits of these two node selection techniques.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint;

/**
 * Indicates that a node should be picked for the touch event or tap gesture
 * that occurred at the specified point, which is the location in the 2D
 * coordinate system of the CC3Layer where the touch occurred.
 *
 * This method can be invoked as a result of a touch event or tap gesture.
 *
 * The event is queued internally, and the node is picked asychronously during
 * the next rendering frame. Once the node has been picked, the application is
 * notified via the nodeSelected:byTouchEvent:at: callback method of this instance.
 *
 * This is a convenience method that invokes the pickNodeFromTouchEvent:at:
 * method with a kCCTouchEnded touch type.
 *
 * Node selection from tap events can also be handled by using the unprojectPoint:
 * method of the active camera to convert the 2D touch-point to a 3D ray, and
 * then using the nodesIntersectedByGlobalRay: method to detect the nodes whose
 * bounding volumes are intersected (punctured) by the ray. See the notes of the
 * pickNodeFromTouchEvent:at: method for further discussion of the relative merits
 * of these two node selection techniques.
 */
-(void) pickNodeFromTapAt: (CGPoint) tPoint;

/**
 * Indicates that a node should be picked for the touch event of the specified
 * type that occurred at the specified point, which is the location in the 2D
 * coordinate system of the CC3Layer where the touch occurred.
 *
 * The tType is one of the enumerated touch types: kCCTouchBegan, kCCTouchMoved,
 * kCCTouchEnded, or kCCTouchCancelled.
 *
 * The event is queued internally, and the node is picked asychronously during
 * the next rendering frame. Once the node has been picked, the application is
 * notified via the nodeSelected:byTouchEvent:at: callback method of this instance.
 *
 * Node selection from touch events can also be handled by using the unprojectPoint:
 * method of the active camera to convert the 2D touch-point to a 3D ray, and then
 * using the nodesIntersectedByGlobalRay: method to detect the nodes whose bounding
 * volumes are intersected (punctured) by the ray.
 *
 * Both selection techniques have advantages. The node picker has pixel-perfect
 * accuracy, including with particles emitted from a particle system, and is
 * therefore more accurate than ray-tracing. Ray tracing detects whether the ray
 * intersects the bounding volume of the node. For particle systems in particular,
 * that bounding volume will include all the space between the particles as well.
 *
 * However, ray tracing has less impact on performance, and allows you to also detect
 * all objects under the touch point, including those hiding behind the visible objects.
 *
 * Node picking from touch events is somewhat expensive. If you do not require node
 * picking, you should override the touchEvent:at: implementation and avoid forwarding
 * the touch-down events to this method. You can also override that method to enhance
 * the touch interaction, such as swipe detection, or dragging & dropping objects.
 * 
 * For example, if you want to let a user touch an object and move it around with their
 * finger, only the initial touch-down event needs to select a node. Once the node is
 * selected, you can cache the node, and move it and release it by capturing the
 * touch-move and touch-up events in the touchEvent:at: method, or via gesture feedback.
 *
 * To support multi-touch events or gestures, add event-handing behaviour to your
 * customized CC3Layer, as you would for any cocos2d application, and invoke this
 * method from your customized CC3Layer when interaction with 3D objects, such as
 * node-picking, is required.
 */
-(void) pickNodeFromTouchEvent: (uint) tType at: (CGPoint) tPoint;

/**
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * The specified node will be one of the visible nodes whose isTouchable property
 * returns YES, or will be nil if the touch event occurred in an area under which
 * there is no 3D node that is touch enabled.
 *
 * For node assemblies, the specified node will not necessarily be the individual
 * component or leaf node that was touched. The specified node will be the closest
 * structural ancestor of the leaf node that has the isTouchEnabled property set to YES.
 *
 * For example, if the node representing a wheel of a car is touched, it may be more
 * desireable to identify the car as being the object of interest to be selected,
 * instead of the wheel. In this case, setting the isTouchEnabled property to YES
 * on the car, but to NO on the wheel, will allow the wheel to be touched, but the
 * node received by this callback will be the car structural node.
 * 
 * The touchType is one of the enumerated touch types: kCCTouchBegan, kCCTouchMoved,
 * kCCTouchEnded, or kCCTouchCancelled. The touchPoint is the location in 2D coordinate
 * system of the CC3Layer where the touch occurred.
 *
 * This callback is received as part of the update processing loop, and is invoked before
 * the invocation of either the updateBeforeTransform: and updateAfterTransform: methods.
 * This callback is invoked only once per event.
 * 
 * To enable touch events, set the isTouchEnabled property of the CC3Layer.
 *
 * Since the touch-move events are both voluminous and seldom used, the handling of
 * ccTouchMoved:withEvent: has been left out of the default CC3Layer implementation.
 * To receive and handle touch-move events for object picking, copy the commented-out
 * ccTouchMoved:withEvent: template method implementation in CC3Layer to your customized
 * CC3Layer subclass.
 *
 * In addition, node selection is expensive, and you should only propagate touch events
 * from touchEvent:at: that actually intend to select a node. By default, all touch events
 * are propagated from touchEvent:at:, but in practice, you should override that method
 * and handle touch events that are not used for selection in that method.
 *
 * For example, if you want to let a user touch an object and move it around with their
 * finger, only the initial touch-down event needs to select a node. Once the node is
 * selected, you can cache the node, and move it and release it by capturing the
 * touch-move and touch-up events in the touchEvent:at: method, and avoid propagating
 * them to the selection mechanism.
 * 
 * To enable a node to be selectable by touching, set the isTouchEnabled property
 * of that node, or an ancestor node to YES. 
 *
 * This implementation does nothing. Subclasses that are interested in node picking
 * will override.
 *
 * Usually, you would not invoke this method directly. This method is invoked automatically
 * whenever a touch event occurs and is processed by the touchEvent:at: method. If you are
 * handling touch events, multi-touch events, or gestures within your customized CC3Layer,
 * invoke the touchEvent:at: method to initiate node selection, and implement this callback
 * method to determine what to do with selected nodes.
 *
 * Node picking from touch events can also be handled by using the unprojectPoint:
 * method of the active camera to convert the 2D touch-point to a 3D ray, and then
 * using the nodesIntersectedByGlobalRay: method to detect the nodes whose bounding
 * volumes are intersected (punctured) by the ray.
 *
 * Both selection techniques have advantages. The node picker has pixel-perfect
 * accuracy, including with particles emitted from a particle system, and is
 * therefore more accurate than ray-tracing. Ray tracing detects whether the ray
 * intersects the bounding volume of the node. For particle systems in particular,
 * that bounding volume will include all the space between the particles as well.
 *
 * However, ray tracing has less impact on performance, and allows you to also
 * detect all objects under the touch point, including those hiding behind the
 * visible objects, plus those that are not visible.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint;

/**
 * Returns the class of visitor that will be instantiated in the touchedNodePicker
 * pickTouchedNode method, in order to paint each node a unique color so that
 * the node under the touched pixel can be identified.
 *
 * The returned class must be a subclass of CC3NodePickingVisitor. This implementation
 * returns CC3NodePickingVisitor. Subclasses may override to customized the behaviour
 * of the drawing visits.
 */
-(id) pickVisitorClass;

/** 
 * The render surface being used to draw when picking nodes from touch events.
 *
 * The value of this property is retrieved from the pickingSurface property of the surface
 * manager in the viewSurfaceManager property.
 *
 * For economy, if multisampling is not active and the viewSurface is readable, the
 * viewSurface can also be used as the picking surface. For that reason, if both of those
 * conditions hold, and this property has not been set to YES directly, this property will
 * return the same surface as the viewSurface property. Otherwise, this property will return
 * a surface dedicated for use in rendering the scene during node picking.
 *
 * You can force the use of a dedicated picking surface, even if multisampling is not in use
 * and the viewSurface is readable, by setting the shouldUseDedicatedPickingSurface property
 * of the viewSurfaceManager to YES. There are situations where this may be preferrable, such
 * as if there is no backdrop, and some of the objects contain  transparency. In that situation,
 * using the viewSurface for both view rendering and node picking rendering may result in 
 * unwanted visual artifacts on the transparent nodes during node picking resulting from touch
 * events. To avoid these artifacts, you can set the shouldUseDedicatedPickingSurface property
 * of the viewSurfaceManager to YES, at any time.
 */
@property(nonatomic, retain, readonly) id<CC3RenderSurface> pickingSurface;

/**
 * When set to YES, the scene will be displayed on the screen as rendered while picking a
 * node from a touch event, instead of the normal scene display render.
 *
 * This is a development-time diagnostic property, that can be used to debug node picking
 * from touch events.
 */
@property(nonatomic, assign) BOOL shouldDisplayPickingRender;

@end


#pragma mark -
#pragma mark CC3TouchedNodePicker

/** The max length of the queue that tracks touch events. */
#define kCC3TouchQueueLength 16

/**
 * A CC3TouchedNodePicker instance handles picking nodes from touch events in a CC3Scene.
 * 
 * This handler maintains a queue of touch types, to ensure than none are missed. However,
 * it does not keep a queue of touch points. Instead, it uses the most recent touch point
 * to determine the 3D object under the touch point.
 *
 * This handler picks 3D nodes using a color picking algorithm. When a touch event occurs,
 * its type is added to the queue, and the touch position is updated. On the next rendering
 * pass, the 3D scene is rendered so that each 3D node has a unique color. The color of
 * the pixel under the touch point then identifies the node that was touched. The scene
 * is then re-rendered in true colors in the same rendering pass, so the user never sees
 * the unique-color rendering that was used to pick the node.
 *
 * Once the node is picked, it is cached. On the next update pass, the node is picked up
 * and all touch events that occured since the previous update pass are dispatched to the
 * CC3Scene in sequence.
 *
 * This asychronous design keeps the update and rendering loops from interfering with each
 * other. The rendering loop only has to pick the object that is under the touch point
 * that was most recently recorded. And if the dispatching of events takes time, only the
 * update loop will be affected. The rendering loop can continue unhindered.
 *
 * For rapid finger movements, it is quite likely that more than one touch event could 
 * arrive before the next rendering pass picks a 3D node. For this reason, no attempt is
 * made to find the node for each and every touch location. In addition, the touch type
 * is only added to the queue if it is different than the previous touch type. For example,
 * a rapid inflow of kCCTouchMoved events will only result in a single kCCTouchMoved event
 * being picked and dispatched to the CC3Scene on each pair of  rendering and updating passes.
 */
@interface CC3TouchedNodePicker : NSObject {
	CC3NodePickingVisitor* _pickVisitor;
	CC3Scene* _scene;
	CC3Node* _pickedNode;
	uint _touchQueue[kCC3TouchQueueLength];
	uint _queuedTouchCount;
	CGPoint _touchPoint;
	BOOL _wasTouched;
	BOOL _wasPicked;
}

/**
 * The visitor that is used to visit the nodes to draw them when picking a node from touch selection.
 *
 * This property defaults to an instance of the class returned by the pickVisitorClass method of the
 * CC3Scene. The application can set a different visitor if desired.
 */
@property(nonatomic, retain) CC3NodePickingVisitor* pickVisitor;

/** The most recent touch point in cocos2d coordinates. */
@property(nonatomic, readonly) CGPoint touchPoint;

/**
 * The currently picked node.
 *
 * The value of this property is ephemeral, and contains a non-nil value only during node
 * picking from touch handling. The value is set by the pickTouchedNode method, and is 
 * cleared by the dispatchPickedNode method.
 */
@property(nonatomic, retain) CC3Node* pickedNode;

/**
 * Indicates that a node should be picked for the touch event of the specified
 * type that occurred at the specified point, which is the location in the 2D
 * coordinate system of the CC3Layer where the touch occurred.
 *
 * The tType is one of the enumerated touch types: kCCTouchBegan, kCCTouchMoved,
 * kCCTouchEnded, or kCCTouchCancelled.
 *
 * The event is queued internally, and the node is picked asychronously during the
 * next rendering frame when the pickTouchedNode method is automatically invoked.
 */
-(void) pickNodeFromTouchEvent: (uint) tType at: (CGPoint) tPoint;

/**
 * Invoked by the CC3Scene during drawing operations in the rendering frame that
 * occurs just after a touch event has been received by the touchEvent:at: method.
 *
 * The picking algorithm runs a specialized drawing routine that paints each node
 * with a unique color. The algorithm then reads the color of the pixel under the
 * touch point from the GL color buffer. The received color is then mapped back to
 * the node that was painted with that color.
 * 
 * This specialized coloring algorithm is inserted into normal drawing operations
 * when (and only when) a touch event has been received. Once the node has been
 * picked, the drawing operations are re-run in normal fashion prior to the final
 * posting of the frame to the display.
 * 
 * The coloring-and-picking algorithm is run only once per touch event, and is not
 * run during rendering frames when there has been no touch event received.
 *
 * This method is invoked automatically whenever a touch event occurs. Usually, the
 * application never needs to invoke this method directly.
 */
-(void) pickTouchedNode;

/**
 * Invoked by the CC3Scene during update operations, in the update loop that occurs
 * occurs just after a touch event has been received by the touchEvent:at: method,
 * and after a node has been picked as a result, by the pickTouchedNode method.
 *
 * This implementation invokes the nodeSelected:byTouchEvent:at: method on the CC3Scene instance.
 *
 * This method is invoked automatically whenever a touch event occurs. Usually, the
 * application never needs to invoke this method directly.
 */
-(void) dispatchPickedNode;


#pragma mark Allocation and initialization

/** Initializes this instance on the specified CC3Scene. */
-(id) initOnScene: (CC3Scene*) aCC3Scene;

/** Allocates and initializes an autoreleased instance on the specified CC3Scene. */
+(id) pickerOnScene: (CC3Scene*) aCC3Scene;

@end


#pragma mark -
#pragma mark CC3Node extension for scene

/** Extension to support scenes. */
@interface CC3Node (Scene)

/** Returns whether this node is a scene. This implementation returns NO. */
@property(nonatomic, readonly) BOOL isScene;

@end

