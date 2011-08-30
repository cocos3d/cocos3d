/*
 * CC3DemoMashUpWorld.h
 *
 * cocos3d 0.6.1
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
 *
 * The cocos3d mascot model was created by Alexandru Barbulescu, and used here
 * by permission. Further rights may be claimed for that model.
 */


#import "CC3World.h"
#import "CC3MeshNode.h"
#import "CC3PODResourceNode.h"
#import "CC3PODLight.h"

@class SpinningNode;

#pragma mark -
#pragma mark CC3DemoMashUpWorld

/** Enumeration of camera zoom options. */
typedef enum {
	kCameraZoomNone,			/**< Inside the world. */
	kCameraZoomStraightBack,	/**< Zoomed straight out to view complete world. */
	kCameraZoomBackTopRight,	/**< Zoomed out to back top right view of complete world. */
} CameraZoomType;

/**
 * A sample application-specific CC3World subclass that demonstrates a number of 3D features:
 *   - loading mesh models, cameras and lights from 3D model files stored in the PowerVR POD format
 *   - creating mesh models from static header file data
 *   - sharing mesh data across several nodes with different materials
 *   - loading 3D models from a POD file converted from a Collada file created in a 3D editor (Blender)
 *   - assembling nodes into a hierarchical parent-child structual assembly.
 *   - texturing a 3D mesh from a CCTexture2D image
 *   - texturing a mesh using UV coordinates exported from a 3D editor
 *   - transparency and alpha-blending
 *   - coloring a mesh with a per-vertex color blend
 *   - multi-texturing an object using texture units by combining several individual textures into overlays
 *   - DOT3 bump-map texturing of an object to provide high-resolution surface detail on a model
 *     with few actual vertices
 *   - animating 3D models using a variety of standard cocos2d CCActionIntervals
 *   - overlaying the 3D world with 2D cocos2d controls such as joysticks and buttons
 *   - embedding 2D cocos2d text labels into the 3D world
 *   - incorporating 2D cocos2d CCParticleEmitters into the 3D world (as a sun and explosion fire)
 *   - creating a tightly focused spotlight whose intensity attenuates with distance
 *   - directing the 3D camera to track a particular target object
 *   - directing an object to track the camera, always facing (looking at) the camera (aka halo objects)
 *   - directing an object to track another object, always facing (looking at) that object
 *   - selecting a 3D object by touching the object on the screen with a finger
 *   - placing a 3D object on another at a point that was touched with a finger
 *   - adding an object as a child of another, but keeping the original orientation of the child
 *     (addAndLocalizeChild:)
 *   - handling touch-move events to create swipe gestures to spin a 3D object using rotation
 *     around an arbitrary axis
 *   - toggling between opacity and translucency using the isOpaque property
 *   - choosing to cull or display backfaces (shouldCullBackFaces)
 *   - creating and deploying many independent copies of a node, while sharing the underlying mesh data
 *   - drawing a descriptive text label on a node using CC3Node shouldDrawDescriptor property.
 *   - drawing a wireframe bounding box around a node using CC3Node shouldDrawWireframeBox property.
 *   - automatically zooming the camera out to view all objects in the world
 *   - constructing and drawing a highly tessellated rectangular plane mesh using CC3PlaneNode
 *   - caching mesh data into GL vertex buffer objects and releasing vertex data from application memory
 *   - retaining vertex location data in application memory (retainVertexLocations) for subsequent calculations
 *   - attaching application-specific userData to any node
 *
 * In addition, there are a number of interesting options for you to play with by uncommenting
 * certain line of code in the methods of this class that build objects in the 3D world,
 * including experimenting with:
 *   - different options for ordering nodes when drawing, including ordering by mesh or texture
 *   - translucent and transparent textures (addFloatingRing)
 *   - configuring the camera for parallel/isometric/orthographic projection instead of the default
 *     perpective projection
 *   - mounting the camera on a moving object, in this case a bouncing ball
 *   - mounting the camera on a moving object, in this case a bouncing ball, and having the
 *     camera stay focused on the rainbow teapot as both beach ball and teapot move and rotate
 *   - directing an object to track another object, always facing that object, but only
 *     rotating in one direction (eg- side-to-side, but not up and down).
 *   - displaying 2D labels (eg- health-bars) overlayed on top of the 3D world at locations projected from the position of 3D objects
 *   - disabling animation for a particular node, in this case the camera and light
 *   - invading with an army of teapots instead of robots
 *   - ignore lighting conditions when drawing a node to draw in pure colors and textures
 *   - initializing and disposing of users data by adding initUserData and releaseUserData method extension categories.
 *   - displaying descriptive text and wireframe bounding boxes on every node.
 *   - log a description of the entire node structure of the 3D world
 *
 * The camera initially opens on a scene of an animated robot arm with a 2D label attached
 * to the end of the rotating arm, demonstrating the technique of embedding a 2D CCNode
 * into the 3D world. The robot arm is loaded from a POD file, along with the moving light
 * and the camera.
 *
 * The robot arm is surrounded by three small teapots, one red, one green, and one blue.
 * These teapots are positioned at 100 on each of the X, Y and Z axes respectively (so the
 * viewer can appreciate the orientation of the scene.
 *
 * A fourth teapot, this one white, indicates the position of the light source, which is also
 * animated. You can see the effect on the lighting of the world as it moves back and forth.
 *
 * At any time, you can move the camera using the two joysticks. The left joystick controls
 * the direction that the camera is pointing, and the right joystick controls the location
 * of the camera, moving forward, back, left and right. By experimenting with these two
 * joysticks, you should be able to navigate the camera all around the 3D world, looking
 * behind, above, and below objects.
 *
 * Using the left joystick, you can redirect the camera to look far away in the direction
 * of the light source by extrapolating a line from the base of the robot arm through the
 * white teapot. There you will find the sun hanging in the sky, as a dynamic particle
 * emitter. This demonstrates the ability to embed standard cocos2d particle emitters
 * into a 3D scene. The sun is quite a large particle emitter, and you should notice a
 * drop in frame rate when it is visible.
 *
 * The scene is given perspective by a ground plane constructed from the cocos2d logo.
 * This ground plane is configured so that, in addition to its front face, its backface
 * will also be drawn. You can verify this by moving the camera down below the ground
 * plane, and looking up.
 *
 * Touching the switch-view button (with the green arrow on it) between the two joysticks
 * will point the camera at a second part of the scene, at a rotating globe, illustrating
 * the texturing of a mesh using a UV texture exported from a 3D editor (Blender in this
 * case) through a Collada exporter, converted to POD file format, and loaded into the
 * 3D world.
 *
 * Touching the switch-view button again will point the camera at a bouncing, rotating
 * beach ball. This beach ball is actually semi-transparent, and you can see objects through
 * the ball. This is particularly apparent if you move the camera so that it is behind the
 * ball, and look back through the ball at the robot arm. To be multi-colored, the beach
 * ball sports several materials. This is done by constructing the beach ball as a parent
 * node with four child nodes (and meshes), one for each colored material. This breakdown
 * is handled by the POD file exporter, and is automatically reconstructed during standard
 * loading from a POD file here. This demonstrates the parent-child nature of nodes. Moving
 * and rotating the parent beach ball node moves and rotates the children automatically.
 *
 * Touching the beach ball will toggle the beach ball between translucent and fully opaque,
 * demonstrating how the isOpaque property can be used to conveniently change the transparency
 * of a node. See the notes for the isOpaque property on CC3Material for more on this property,
 * and its interaction with other material properties.
 * 
 * Although the beach ball is constructed from four separate mesh nodes, touching any part
 * of the beach ball will actually select the node representing the complete beach ball,
 * and the entire beach ball is highlighted.
 *
 * Touching the switch-view button again will point the camera at yet another teapot, this
 * one textured with the cocos2d logo, and rotating on it's axis. This textured teapot has
 * another smaller teapot as a satellite. This satellite is colored with a color gradient
 * using a color array, and orbits around the teapot, and rotates on it's own axes.
 * The satellite teapot is a child node of the textured teapot node, and rotates along
 * with the textured teapot.
 *
 * Touching either teapot will toggle the display of a wireframe around the mesh of that
 * teapot (magenta), and a wireframe around both teapots (yellow - actually around the
 * structural node that holds both teapots). This easily is done by simply setting the
 * shouldDrawLocalContentWireframeBox and shouldDrawWireframeBox properties, respectively.
 * Notice that the wireframes move, rotate, and scale along with the teapots themselves,
 * and notice that the yellow wireframe that surrounds both teapots grows and shrinks
 * automatically as the rainbow teapot rotates and stretches the box around both teapots.
 *
 * Touching the switch-view button again will point the camera at two copies of Alexandru
 * Barbulescu's 3D cocos3d mascot. The mascot on the left stares back at the camera,
 * regardless of where you move the camera in the 3D world (which you do using the right
 * joystick). This kind of object is also known as a halo object, and can be useful when
 * you always want an object to face the camera.
 *
 * The second mascot is distracted by the satellite rainbow teapot. The gaze of this second
 * mascot tracks the location of the rainbow teapot as it orbits the textured teapot.
 *
 * Both mascots make use of CC3TargettingNode behaviour to point themselves at another
 * object. You can add any object as a child to a targetting node, orient the child node
 * so that the side that you consider the front of the object faces in the forwardDirection
 * of the targetting node, and then tell the targetting node to point in a particular
 * direction, or to always point at another node, and track the motion of that other node
 * as it moves around in the world.
 *
 * Although not demonstrated in this app, the camera is also a subclass of CC3TargettingNode,
 * which means you can create an "orbit camera" by simply giving your camera a target to track.
 * As you move the camera around, it will continue to look at the target object.
 *
 * Touching the switch-view button again will point the camera at a wooden sign that is
 * constructed from two separate textures that are loaded separately and applied as a
 * multi-texture to the sign mesh. When multiple textures are applied to a mesh, different
 * techniques can be configured for combining the textures to create interesting effects.
 * The wooden sign is touchable, and touching the wooden sign will select a different method
 * of combining the two textures. These methods of combining cycle through the following
 * options when the wooden sign is repeated touched: Modulation, Addition, Signed Addition,
 * Simple Replacement, Subtraction, and DOT3 bump-mapping (also known as normal mapping).
 
 * Touching the switch-view button again will point the camera at a purple floating head that
 * looks back at the camera, regardless of where the camera moves. This floating head shows
 * quite realistic surface detail and shadowing that changes as the light source moves up
 * and down, or as the head turns to face the camera as it moves around. The surface detail,
 * and interaction with lighting is performed by a bump-map texture. The floating head has
 * two textures applied, the first is a bump-map which contains a surface normal vector in
 * each pixel instead of a color. These per-pixel normals interact with a vector indicating
 * the direction of the light source to determine the luminiosity of each pixel. A second
 * texture containing the purple featuring is then overlaid on, and combined with, the main
 * bump-map texture, to create the overall textured and shadowed effect.
 *
 * Bump-mapping is a technique used to provide complex surface detail without requiring a
 * large number of mesh vertices. The actual mesh underlying the floating head contains only
 * 153 vertices.
 * 
 * Touching the purple floating head removes the bump-map texture, and leaves only the purple
 * texture laid on the raw mesh vertices. The surface detail virtually vanishes, leaving a
 * crude model of a head, and demonstrating that the surface detail and shadowing is contained
 * within the bump-mapped texture, not within the mesh vertices. The effect is quite striking.
 *
 * The light direction that is combined with the per-pixel texture normals to peform this
 * bump-mapping is provided by a CC3LightTracker node, which holds both the wooden sign and
 * the floating head as child nodes. It keeps track of the location of the light, even as both
 * the light and the models move around, and automatically provides the light direction
 * to the bump-mapped wooden sign and floating head nodes.
 *
 * Touching the purple head also logs an information message using userData that was attached
 * to the floating head an initialization time. The userData property can be used to attach
 * any application specific data that you want to any node, mesh, material, texture, etc.
 *
 * Touching the switch-view button again will point the camera at a die cube. You can spin
 * this die cube by touching it and swiping your finger in any direction. The die will
 * spin in the direction of the swipe. The faster and longer you swipe, the faster the
 * die will spin. The spinning die will slow down over time, eventually stopping. This
 * spinning die cube demonstrates a number of useful features in cocos3d:
 *   - The ability to rotate a 3D object around any axis.
 *   - The ability to convert touch-move events into swipe gestures to interact with a 3D object.
 *   - The separation of touch-event handling for control, and touch-event handling for node selection.
 *   - The ability to use the copyWithName:asClass: method to change the class of a node
 *     loaded from a POD file to add additional functionality to that node.
 *
 * The die cube POD file was created from a Blender model available from the Blender
 * "Two dice" modeling tutorial available online at:
 * http://wiki.blender.org/index.php/Doc:Tutorials/Modeling/Two_dice
 * 
 * Touching the switch-view button one final time will point the camera back at the animated
 * robot arm.
 *
 * Touching the invasion button (with the grid of dots on it) will unleash an army of robots,
 * by copying the main robot arm many times, and deploying the copies around the grid. Notice
 * that each of the robot arms moves independently. The army drops from the sky like rain.
 * The random rain is intentional, and is not some artifact of performance degredation.
 * Touching the invasion button again will cause the robot army to fade away and be removed.
 *
 * Touching the illumination button (with the sun on it) envelopes the world in a fog. The
 * farther away an object is, the less visible it is through the fog. The effect of the fog
 * is best appreciated with the world is full of the invading robot arms.
 *
 * Touching the illumination button a second time turns the sun and fog off and turns on a
 * spotlight that is attached to the camera. This spotlight is tightly focused. Objects that
 * are away from the center of the spotlight are illuminated less than objects in the center
 * of the spotlight. The intensity of the spotlight beam also attenuates with distance.
 * Objects that are farther away from the spotlight are less illumnated than objects that are
 * closer to the spotlight. Since it is attached to the camera, it moves as the camera moves,
 * as if you were walking through the scene carrying a flashlight.
 *
 * If you shine the spotlight on the purple floating head, you might notice two things.
 * The first is that the head is correctly illuminated from the position of the spotlight.
 * This is because the target of the CC3LightTracker holding the floating head and wooden
 * sign is switched from the main sunshine light to the spotlight. The second is that the
 * floating head appears fully illuminated even when the spotlight is not shining on it.
 * this is a funcion of the way that bump-map lighting works. It has no knowledge of the
 * configuration or focus of the spotlight, and therefore does not attenuate the per-pixel
 * illumination outside the beam of the spotlight. This is something to keep in mind when
 * combining the techniques of spotlights and bump-mapping.
 *
 * Touching the illumination button a third time will bring back the original sunshine.
 *
 * Touching the zoom button (with the plus-sign) rotates the camera so that it points
 * towards the center of the world, and moves the camera away from the world along the
 * line between the camera and the center of the world, until the entire world is visible.
 * A wireframe is drawn around the entire world to show its extent and the node descriptor
 * text is displayed to show the center of the world. This demonstrates the moveToShowAllOf:
 * family of methods on CC3Camera, which, in addition to providing interesting orbit-camera
 * control for the app, can be particularly useful at development time for troubleshooting
 * objects that are not drawing correctly, either are not visible at all, or are unexpectedly
 * out of the camera's field-of-view.
 *
 * The camera now points to the center of the world. However, the world may appear to be
 * lying off to one side. This is due to perspective, depending on the location of the
 * camera. The center of the world is in the center of the screen.
 * 
 * Also, after zooming out, you may notice that the left-most corner of the bounding box
 * is slightly off-screen. This is because the sun is a particle system billboard and
 * rotates as the camera pans out, effectively expanding the bounding box of the world
 * as it turns. A similar effect will occur if the bounding box of the world is dynamic
 * due to movement of nodes within the world.
 *
 * Touching the zoom button a second time moves the camera to view the entire world from
 * a different direction. Touching it a third time moves the camera back to the view it
 * had before the zoom button was touched the first time.
 * 
 * Most of the 3D objects are selectable by touching. Touching any of the 3D objects with
 * your finger will briefly highlight that object to show it has been selected, and will
 * toggle the display of descriptive information about that node at the origin of the node
 * in the local coordinate system of the node. This is the pivot point around which
 * transformations, such as movement, rotation and scaling, will occur. If the node is
 * a mesh node, the color of the label will be magenta. If the node is a structural node,
 * like the beach ball, the color of the label will be yellow.
 * 
 * Similarly, touching any part of the robot arm visually highlights the full robot arm.
 * But in this case, the node selected is actually one of the arm components, and the complete
 * robot arm is highlighted because all nodes in the robot arm share the same material.
 * This effect is therefore an artifact of the layout of materials on nodes, and in a real
 * application would need to be dealt with, depending on the desired results.
 *
 * If the ground plane is touched, it does not highlight, but a little orange teapot will
 * be placed on the ground at the location of the touch point, demonstrating the ability
 * to integrate touch events with object positioning in 3D (sometimes known as unprojecting).
 * For dramatic effect, as the teapot is placed, a fiery explosion is set off using a cocos2d
 * CCParticleSystem, demonstrating the ability to embed dynamic 2D particle systems into a
 * 3D world. Once the explosion particle system has exhausted, it is automatically removed
 * as a child of the teapot.
 *
 * Most of the dynamic motion in this scene is handled by standard cocos2d CCActionIntervals.
 *
 * Vertex arrays and meshes are created only once for each mesh type, and are used by several
 * nodes. For exmample, all of the teapots: textured, colored or multi-colored, use the same
 * teapot mesh instance, but can be transformed separately, and covered with different materials.
 */
@interface CC3DemoMashUpWorld : CC3World {
	CGPoint playerDirectionControl;
	CGPoint playerLocationControl;
	CC3PlaneNode* ground;
	CC3MeshNode* teapotWhite;
	CC3MeshNode* teapotTextured;
	CC3MeshNode* teapotSatellite;
	CC3MeshNode* beachBall;
	CC3MeshNode* globe;
	SpinningNode* dieCube;
	CC3MeshNode* mascot;
	CC3LightTracker* bumpMapLightTracker;
	CC3MeshNode* woodenSign;
	CC3MeshNode* floatingHead;
	CC3Texture* signTex;
	CC3Texture* stampTex;
	CC3Texture* embossedStampTex;
	CC3Texture* headTex;
	CC3Texture* headBumpTex;
	CC3Light* podLight;
	CC3Node* origCamTarget;
	CC3Node* camTarget;
	CC3Node* selectedNode;
	CGPoint touchDownPoint;
	CameraZoomType cameraZoomType;
	CC3Ray lastCameraOrientation;
}

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

/**
 * Switches the target of the camera to a new object by cycling through four different
 * 3D objects in the scene. The camera swings from one target to the next using CCActionIntervals.
 */
-(void) switchCameraTarget;

/** Launches an invasion of an army of robots. */
-(void) invade;

/**
 * Cycles between different lighting conditions. Initially the sun is shining on a clear scene.
 * When this method is invoked, fog is displayed. Invoking a second time, the sun and fog are
 * removed and the spotlight is turned on. Invoking a third time re-ignites the sun.
 * Returns whether or not the sun is now on.
 */
-(BOOL) cycleLights;

/**
 * Toggles between zooming out to show the entire world, and zooming back in to the
 * prevous camera position.
 */
-(void) cycleZoom;

@end


#pragma mark -
#pragma mark Specialized POD loading classes

/**
 * Customized POD resource class to handle the idiosyncracies of how the POD file is
 * handled in the original PVRT demo app. This is not normally necessary. Normally,
 * the POD file should be created accurately to reflect the scene.
 */
@interface IntroducingPODResource : CC3PODResource {}
@end

/**
 * Customized light class to handle the idiosyncracies of how lights from the POD file
 * is handled in the original PVRT demo app. This is not normally necessary. Normally,
 * the POD file should be created accurately to reflect the scene.
 */
@interface IntroducingPODLight : CC3PODLight {}
@end


/**
 * Customized POD resource class to handle the idiosyncracies of the POD file containing
 * the purple floating head. That POD file contains a reference to texture that does not
 * exist, so we override the texture loading behaviour to avoid it, rather than generate
 * spurious errors. This is not normally necessary. Normally, the POD file should be
 * created accurately to reflect the scene.
 */
@interface HeadPODResource : CC3PODResource {}
@end


/**
 * A customized node that automatically rotates by adjusting its rotational aspects on
 * each update pass, and can slow the rotation speed over time based on a friction property.
 */
@interface SpinningNode : CC3Node {
	GLfloat friction;
	GLfloat spinSpeed;
}

/**
 * The speed of rotation. This value can be directly updated, and then will automatically
 * be slowed down over time according to the value of the friction property.
 */
@property(nonatomic, assign) GLfloat spinSpeed;

/**
 * The friction value that is applied to the spinSpeed to slow it down over time.
 *
 * A value of zero will not slow rotation down at all and the node will continue
 * spinning indefinitely.
 */
@property(nonatomic, assign) GLfloat friction;

@end

