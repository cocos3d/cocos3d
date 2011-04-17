/*
 * CC3DemoMashUpWorld.h
 *
 * cocos3d 0.5.4
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
#import "CC3MeshNode.h"
#import "CC3PODResourceNode.h"
#import "CC3PODLight.h"


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


#pragma mark -
#pragma mark CC3DemoMashUpWorld

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
 *   - animating 3D models using a variety of standard cocos2d CCActionIntervals
 *   - overlaying the 3D world with 2D cocos2d controls such as joysticks and buttons
 *   - displaying 2D labels (eg- health-bars) at locations projected from the position of 3D objects
 *   - directing the 3D camera to track a particular target object
 *   - selecting a 3D object by touching the object on the screen with a finger
 *   - placing a 3D object on another at a point that was touched with a finger
 *   - adding an object as a child of another, but keeping the original orientation of the child
 *     (addAndLocalizeChild:)
 *   - toggling between opacity and translucency using the isOpaque property
 *   - choosing to cull or display backfaces (shouldCullBackFaces)
 *   - creating and deploying many independent copies of a node, while sharing the underlying mesh data
 *   - constructing and drawing a wire-frame bounding box around a node using CC3LineNode
 *   - constructing and drawing a rectangular plane mesh using CC3PlaneNode
 *   - caching mesh data into GL vertex buffer objects and releasing vertex data from application memory
 *   - retaining vertex location data in application memory (retainVertexLocations) for subsequent calculations
 *
 * In addition, there are a number of interesting options for you to play with by uncommenting
 * certain line of code in the methods of this class that build objects in the 3D world,
 * including experimenting with:
 *   - different options for ordering nodes when drawing, including ordering by mesh or texture
 *   - translucent and transparent textures (addFloatingRing)
 *   - configuring the camera for parallel/isometric/orthographic projection instead of the default
 *     perpective projection
 *   - mounting the camera on a moving object, in this case a bouncing ball
 *   - disabling animation for a particular node, in this case the camera and light
 *   - invading with an army of teapots instead of robots
 *
 * The camera initially opens on a scene of an animated robot arm with a 2D label attached to the
 * end of the rotating arm, demonstrating the technique of projecting a 3D location onto the 2D
 * view. The robot arm is loaded from a POD file, along with the moving light and the camera.
 *
 * The robot arm is surrounded by three small teapots, one red, one green, and one blue.
 * These teapots are positioned at 100 on each of the X, Y and Z axes respectively (so the
 * viewer can appreciate the orientation of the scene.
 *
 * A fourth teapot, this one white, indicates the position of the light source, which is also
 * animated. You can see the effect on the lighting of the world as it moves back and forth.
 * Underneath it all is a ground plane textured with the cocos2d logo.
 *
 * At any time, you can move the camera using the two joysticks. The left joystick controls
 * the direction that the camera is pointing, and the right joystick controls the location
 * of the camera, left, right, up, and down. By experimenting with these two joysticks,
 * you should be able to navigate the camera all around the 3D world, looking behind, above,
 * and below objects.
 *
 * The scene is given perspective by a ground plane constructed from the cocos2d logo.
 * This ground plane is configured so that, in addition to its front face, its backface will
 * also be drawn. You can verify this by moving the camera down below the ground plane,
 * and looking up.
 *
 * Touching the switch view button (with the green arrow on it) between the two joysticks will
 * point the camera at a second part of the scene, a bouncing, rotating beach ball. This beach
 * ball is actually semi-transparent, and you can see objects through the ball. This is
 * particularly apparent if you move the camera so that it is behind the ball, and look back
 * through the ball at the robot arm. To be multi-colored, the beach ball sports several materials.
 * This is done by constructing the beach ball as a parent node with four child nodes (and meshes),
 * one for each colored material. This breakdown is handled by the POD file exporter, and is
 * automatically reconstructed during standard loading from a POD file here. This demonstrates
 * the parent-child nature of nodes. Moving and rotating the parent beach ball node moves
 * and rotates the children automatically.
 *
 * Touching the switch view button again will point the camera at yet another teapot, this one
 * textured with the cocos2d logo, and rotating on it's axis. This textured teapot has another
 * smaller teapot as a satellite. This satellite is colored with a color gradient using a
 * color array, and orbits around the teapot, and rotates on it's own axes. The satellite teapot
 * is a child node of the textured teapot node, and rotates along with the textured teapot.
 *
 * Touching the switch view button yet again will point the camera at a rotating globe,
 * illustrating the texturing of a mesh using a UV texture exported from a 3D editor
 * (Blender in this case) through a Collada exporter, converted to POD file format, and
 * loaded into the 3D world.
 *
 * Touching the switch view button one final time will point the camera back at the animated
 * robot arm.
 *
 * Most of the 3D objects are selectable. Touching any of the 3D objects with your finger
 * will briefly highlight that object to show it has been selected. Although the beach ball
 * is constructed from four separate meshe nodes, touching any part of the beach ball will
 * actually select the node representing the complete beach ball, and the entire beach ball
 * is highlighted.
 * 
 * Similarly, touching any part of the robot arm visually highlights the full robot arm.
 * But in this case, the node selected is actually one of the arm components, and the complete
 * robot arm is highlighted because all nodes in the robot arm share the same material.
 * This effect is therefore an artifact of the layout of materials on nodes, and in a real
 * application would need to be dealt with, depending on the desired results.
 *
 * Touching the beach ball will also toggle the beach ball between translucent and fully
 * opaque, demonstrating how the isOpaque property can be used to conveniently change the
 * transparency of a node. See the notes for the isOpaque property on CC3Material for more
 * on this property, and its interaction with other material properties.
 *
 * If the ground plane is touched, it does not highlight, but a little orange teapot will be
 * placed on the ground at the location of the touch point, demonstrating the ability to
 * integrate touch events with object positioning in 3D (sometimes known as unprojecting).
 *
 * You may notice that, when a touch event is processed and the beach ball is translucent
 * and is over the "sky", there is a very slight flicker to the beach ball. The flicker
 * does not occur when the beach ball has a 3D object such as the ground behind it, or when
 * the beach ball is made opaque (by touching it). This is expected behaviour. It occurs
 * because the "sky" is not part of the 3D scene, but is simply the background color of the
 * CC3Layer, and does not participate in the translucency of the beach ball. For a more
 * complete explanation of this artifact, and how you can avoid it, please see the class
 * notes of the CC3Layer class.
 *
 * Touching either the textured or rainbow teapot will toggle the display of a wire-frame
 * of the teapot's bounding box. This is done by either adding or removing an instance of
 * CC3LineNode as a child of the teapot node. The CC3LineNode is populated from the bounding
 * box of the teapot mesh, and since it is added as a child of the teapot node itself, will
 * move and scale with the teapot node. This demonstrates the use of CC3LineNode to draw lines,
 * and visualizes the bounding-box style of CC3BoundingVolume on a node.
 *
 * Touching the invasion button (with the grid of dots on it) will unleash an army of robots,
 * by copying the main robot arm many times, and deploying the copies around the grid. Notice
 * that each of the robot arms moves independently. The army drops from the sky like rain.
 * The random rain is intentional, and is not some artifact of performance degredation.
 * Touching the invasion button again will cause the robot army to fade away and be removed.
 *
 * All of the dynamic motion in this scene is handled by standard cocos2d CCActionIntervals.
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
	IntroducingPODLight* podLight;
	CC3Node* origCamTarget;
	CC3Node* camTarget;
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

@end
