/*
 * CC3UtilityMeshNodes.h
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

#import "CC3ParametricMeshNodes.h"


#pragma mark -
#pragma mark CC3PlaneNode

/**
 * CC3PlaneNode is a type of CC3MeshNode that is specialized to display planes and
 * simple rectanglular meshes.
 *
 * Since a plane is a mesh like any other mesh, the functionality required to create
 * and manipulate plane meshes is present in the CC3MeshNode class, and if you choose,
 * you can create and manage plane meshes using that class alone. Some plane-specific
 * functionality is defined within this class.
 * 
 * Several convenience methods exist in the CC3MeshNode class to aid in constructing a
 * CC3PlaneNode instance:
 *   - populateAsCenteredRectangleWithSize:
 *   - populateAsRectangleWithSize:andPivot:
 */
@interface CC3PlaneNode : CC3MeshNode

/**
 * Returns a CC3Plane structure corresponding to this plane.
 *
 * This structure is built from the location vertices of three of the corners
 * of the bounding box of the mesh.
 */
@property(nonatomic, readonly) CC3Plane plane;

@end


#pragma mark -
#pragma mark CC3LineNode

/**
 * CC3LineNode is a type of CC3MeshNode that is specialized to display lines.
 *
 * Since lines are a mesh like any other mesh, the functionality required to create and manipulate
 * line meshes is present in the CC3MeshNode class, and if you choose, you can create and manage line
 * meshes using that class alone. At present, CC3LineNode exists for the most part simply to identify
 * box meshes as such. However, in future, additional state or behaviour may be added to this class.
 *
 * To draw lines, you must make sure that the drawingMode property is set to one of GL_LINES,
 * GL_LINE_STRIP or GL_LINE_LOOP. This property must be set after the mesh is attached.
 * Other than that, you configure the mesh node and its mesh as you would with any mesh node.
 *
 * To color the lines, use the pureColor property to draw the lines in a pure, solid color
 * that is not affected by lighting conditions. You can also add a material to your CC3LineNode
 * instance to get more subtle coloring and blending, but this can sometimes
 * appear strange with lines. You can also use CCActionInterval to change the tinting or
 * opacity of the lines, as you would with any mesh node.
 *
 * Several convenience methods exist in the CC3MeshNode class to aid in constructing a
 * CC3LineNode instance:
 *   - populateAsLineStripWith:vertices:andRetain:
 *   - populateAsWireBox:  - a simple wire box
 */
@interface CC3LineNode : CC3MeshNode

/** @deprecated Property renamed to lineSmoothingHint on CC3MeshNode. */
@property(nonatomic, assign) GLenum performanceHint DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3SimpleLineNode

/**
 * CC3SimpleLineNode simplifies the creation of a simple two-point straight line.
 *
 * You can create a single simple straight line model by instantiating an instance of this
 * class and then setting either or both of the lineStart and lineEnd properties.
 *
 * The mesh underlying this node is automatically populated as a simple two-vertex line.
 * When using this class, you do not need to use any of the populateAs... methods to generate
 * and populate the mesh.
 */
@interface CC3SimpleLineNode : CC3LineNode {
	CC3Vector _lineVertices[2];
}

/**
 * Indicates the start of the line in the local coordinate system of this node.
 *
 * The initial value is kCC3VectorZero, indicating that the line starts at the origin of
 * the local coordinate system.
 */
@property(nonatomic, assign) CC3Vector lineStart;

/**
 * Indicates the end of the line in the local coordinate system of this node.
 *
 * The initial value is kCC3VectorZero, indicating that the line ends at the origin of
 * the local coordinate system.
 */
@property(nonatomic, assign) CC3Vector lineEnd;

@end


#pragma mark -
#pragma mark CC3BoxNode

/**
 * CC3BoxNode is a type of CC3MeshNode that is specialized to display simple box or cube meshes.
 *
 * Since a cube or box is a mesh like any other mesh, the functionality required to create and
 * manipulate box meshes is present in the CC3MeshNode class, and if you choose, you can create
 * and manage box meshes using that class alone. At present, CC3BoxNode exists for the most part
 * simply to identify box meshes as such. However, in future, additional state or behaviour may
 * be added to this class.
 *
 * You can use one of the following convenience methods to aid in constructing a CC3BoxNode instance:
 *   - populateAsSolidBox:
 *   - populateAsSolidBox:withCorner:
 *   - populateAsWireBox:
 */
@interface CC3BoxNode : CC3MeshNode
@end


#pragma mark -
#pragma mark CC3TouchBox

/**
 * CC3TouchBox is a specialized node that creates an invisible box mesh that can be used to
 * define a 3D region for touch activity.
 *
 * If you do not set the box property explicitly, when you add an instance of this class as a child
 * of another CC3Node, this node will automatically be populated as a box the same size as the
 * bounding box of that parent. If the parent node contains other nodes, its bounding box will
 * include its descendants, resulting in this mesh being populated to encapsulate all descendant
 * nodes of its parent. The effect is to define a box-shaped touch region around a composite node
 * that might be comprised of a number of smaller nodes with space in between them.
 *
 * If the parent node contains descendants that are moving around, the bounding box of the parent
 * node may be dynamic and constantly changing. If you want the touch box to track changes to the
 * parent bounding box, set the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * You can also set the box property directly to create a box that is shaped differently than the
 * bounding box of the parent. For example, you might want to do this if you want the touch box to
 * be larger than the actual visible nodes, in order to make it easier to touch.
 *
 * The mesh underlying this node is automatically populated when you set the box property, or when
 * you add this node to a parent. You do not need to invoke any of the populateAs... methods directly.
 *
 * Since this node is intended to be used as an invisible touch pad, the visible property of this node
 * is initially set to NO, and the shouldAllowTouchableWhenInvisible property is initially set to YES.
 * In addition, the bounding box of this mesh will not contribute to the bounding box of the parent.
 */
@interface CC3TouchBox : CC3BoxNode {
	BOOL _shouldAlwaysMeasureParentBoundingBox : 1;
}

/**
 * Indicates the size of the touch box.
 *
 * Setting this property populates this node with a box mesh of the specified extent.
 *
 * Instead of setting this property directly, you can automatically create the box mesh by simply
 * adding this node to a parent CC3Node. If this property has not already been set when this node
 * is added to a parent, the value of this property will automatically be set to the value of the
 * boundingBox property of the parent.
 *
 * If the parent node contains descendants that are moving around, the bounding box of the parent
 * node may be dynamic and constantly changing. If you want the touch box to track changes to the
 * parent bounding box, set the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * If you set this property directly, and then subsequently add this node to a parent, the value
 * of this property will not change, and the underlying mesh will not be repopulated. By setting
 * the value of this property directly, you can create a mesh box that is of a different size
 * than the parent bounding box.
 *
 * Setting this property to kCC3BoxNull will remove the underlying mesh.
 *
 * The initial value of this property is kCC3BoxNull.
 */
@property(nonatomic, assign) CC3Box box;

/**
 * Indicates whether the dimensions of this node should automatically be remeasured on each update pass.
 *
 * If this property is set to YES, the box will automatically be resized to account for movements by
 * any descendant nodes of the parent node. To create a dynamic touch box that automatically adjusts
 * as the descendants of the parent node move around, this property should be set to YES.
 *
 * It is not necessary to set this property to YES to account for changes in the transform properties
 * of the parent node itself.
 *
 * When setting this property, be aware that dynamically measuring the bounding box of the parent node
 * can be an expensive operation if the parent contains a number of descendant nodes.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldAlwaysMeasureParentBoundingBox;

@end


#pragma mark -
#pragma mark CC3SphereNode

/**
 * CC3SphereNode is a type of CC3MeshNode that is specialized to display a simple sphere mesh.
 *
 * Since a sphere is a mesh like any other mesh, the functionality required to create and
 * manipulate sphere meshes is present in the CC3MeshNode class, and if you choose, you can
 * create and manage sphere meshes using that class alone.
 *
 * However, when using bounding volumes, CC3SphereNode returns a spherical bounding volume
 * from the defaultBoundingVolume method, instead of the default bounding volume for a
 * standard mesh node. This provides a better fit of the bounding volume around the mesh.
 *
 * You can use the following convenience method to aid in constructing a CC3SphereNode instance:
 *   - populateAsSphereWithRadius:andTessellation:
 */
@interface CC3SphereNode : CC3MeshNode
@end


#pragma mark -
#pragma mark CC3ClipSpaceNode

/**
 * CC3ClipSpaceNode simplifies the creation of a simple rectangular node that can be used
 * in the clip-space of the view in order to cover the view with a rectangular image. This
 * provides an easy and convenient mechanism for creating backdrops and post-processing effects.
 *
 * Any mesh node can be configured for rendeirng in the clip-space by setting the shouldDrawInClipSpace
 * property is set to YES. This subclass is a convenience class that sets that property to YES during
 * instance initialization.
 *
 * See the notes of the shouldDrawInClipSpace property for further information about drawing
 * a node in clip-space.
 */
@interface CC3ClipSpaceNode : CC3MeshNode

/**
 * Allocates and initializes and autoreleased instance covered with the specified texture.
 *
 * This is a convenience method for a common use of this class.
 */
+(id) nodeWithTexture: (CC3Texture*) texture;

/**
 * Allocates and initializes and autoreleased instance covered with the specified color.
 *
 * This is a convenience method for a common use of this class.
 */
+(id) nodeWithColor: (ccColor4F) color;

@end


#pragma mark -
#pragma mark CC3Backdrop

/**
 * CC3Backdrop represents a simple full-view static backdrop that is rendered in clip-space.
 * The backdrop can be created as a solid color, or a texture, by using either the nodeWithColor:
 * or nodeWithTexture: method inherited from the CC3ClipSpaceNode superclass.
 *
 * See the class notes for the CC3ClipSpaceNode superclass, and the notes of the 
 * shouldDrawInClipSpace property for further information about drawing a node in clip-space.
 */
@interface CC3Backdrop : CC3ClipSpaceNode
@end


#pragma mark -
#pragma mark CC3WireframeBoundingBoxNode

/**
 * CC3WireframeBoundingBoxNode is a type of CC3LineNode specialized for drawing
 * a wireframe bounding box around another node. A CC3WireframeBoundingBoxNode
 * is typically added as a child node to the node whose bounding box is to
 * be displayed.
 *
 * The CC3WireframeBoundingBoxNode node can be set to automatically track
 * the dynamic nature of the boundingBox of the parent node by setting
 * the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * Since we don't want to add descriptor labels or wireframe boxes to
 * wireframe nodes, the shouldDrawDescriptor, shouldDrawWireframeBox,
 * and shouldDrawLocalContentWireframeBox properties are overridden to
 * do nothing when set, and to always return YES.
 *
 * Similarly, CC3WireframeBoundingBoxNode node does not participate in calculating
 * the bounding box of the node whose bounding box it is drawing, since, as a child
 * of that node, it would interfere with accurate measurement of the bounding box.
 *
 * The shouldIncludeInDeepCopy property returns NO, so that the CC3WireframeBoundingBoxNode
 * will not be copied when the parent node is copied. A bounding box node for the copy
 * will be created automatically when each of the shouldDrawLocalContentWireframeBox
 * and shouldDrawWireframeBox properties are copied, if they are set to YES on the
 * original node that is copied.
 * 
 * A CC3WireframeBoundingBoxNode will continue to be visible even when its ancestor
 * nodes are invisible, unless the CC3WireframeBoundingBoxNode itself is made invisible.
 */
@interface CC3WireframeBoundingBoxNode : CC3LineNode {
	BOOL _shouldAlwaysMeasureParentBoundingBox : 1;
}

/**
 * Indicates whether the dimensions of this node should automatically be
 * remeasured on each update pass.
 *
 * If this property is set to YES, the box will automatically be resized
 * to account for movements by any descendant nodes of the parent node.
 * For bounding box nodes that track the overall boundingBox of a parent
 * node, this property should be set to YES.
 *
 * It is not necessary to set this property to YES to account for changes in
 * the transform properties of the parent node itself, or if this node is
 * tracking the bounding box of local content of the parent node. Generally,
 * changes to that will automatically be handled by the transform updates.
 *
 * When setting this property, be aware that measuring the bounding box of
 * the parent node can be an expensive operation.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldAlwaysMeasureParentBoundingBox;


#pragma mark Updating

/**
 * Updates this wireframe box from the bounding box of the parent node.
 *
 * The extent of the wireframe box is usually set automatically when first created, and is not
 * automatically updated if the parent bounding box changes. If you want this wireframe to update
 * automatically on each update frame, set the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * However, updating on each frame can be a drag on performance, so if the parent bounding box
 * changes under app control, you can invoke this method whenever the bounding box of the parent
 * node changes to keep the wireframe box synchronized with its parent. 
 */
-(void) updateFromParentBoundingBox;

@end


#pragma mark -
#pragma mark CC3WireframeLocalContentBoundingBoxNode

/**
 * CC3WireframeLocalContentBoundingBoxNode is a CC3WireframeBoundingBoxNode that
 * further specializes in drawing a bounding box around the local content of another
 * node with local content. A CC3WireframeLocalContentBoundingBoxNode is typically
 * added as a child node to the node whose bounding box is to be displayed.
 *
 * Since for almost all nodes, the local content generally does not change, the
 * shouldAlwaysMeasureParentBoundingBox property is usually left at NO, to avoid
 * unnecessary remeasuring of the bounding box of the local content of the parent
 * node when we know it will not be changing. However, this property can be set to
 * YES when adding a CC3WireframeLocalContentBoundingBoxNode to a node whose local
 * content does change frequently.
 */
@interface  CC3WireframeLocalContentBoundingBoxNode  : CC3WireframeBoundingBoxNode
@end


#pragma mark -
#pragma mark CC3DirectionMarkerNode

/**
 * CC3DirectionMarkerNode is a type of CC3LineNode specialized for drawing a line from the origin
 * of its parent node to a point outside the bounding box of the parent node, in a particular
 * direction. A CC3DirectionMarkerNode is typically added as a child node to the node to visibly
 * indicate the orientation of the parent node.
 *
 * The CC3DirectionMarkerNode node can be set to automatically track the dynamic nature of the
 * boundingBox of the parent node by setting the shouldAlwaysMeasureParentBoundingBox property to YES.
 *
 * Since we don't want to add descriptor labels or wireframe boxes to direction marker nodes, the
 * shouldDrawDescriptor, shouldDrawWireframeBox, and shouldDrawLocalContentWireframeBox properties
 * are overridden to do nothing when set, and to always return YES.
 *
 * Similarly, CC3DirectionMarkerNode node does not participate in calculating the bounding box of
 * the node whose bounding box it is drawing, since, as a child of that node, it would interfere
 * with accurate measurement of the bounding box.
 *
 * The shouldIncludeInDeepCopy property returns YES by default, so that the
 * CC3DirectionMarkerNode will be copied when the parent node is copied.
 * 
 * A CC3DirectionMarkerNode will continue to be visible even when its ancestor
 * nodes are invisible, unless the CC3DirectionMarkerNode itself is made invisible.
 */
@interface CC3DirectionMarkerNode : CC3WireframeBoundingBoxNode {
	CC3Vector _markerDirection;
}

/**
 * Indicates the unit direction towards which this line marker will point from
 * the origin of the parent node.
 *
 * When setting the value of this property, the incoming vector will be normalized to a unit vector.
 *
 * The value of this property defaults to kCC3VectorUnitZNegative, a unit vector
 * in the direction of the negative Z-axis, which is the OpenGL ES default direction.
 */
@property(nonatomic, assign) CC3Vector markerDirection;

/**
 * Returns the proportional distance that the direction marker line should protrude from the parent
 * node. This is measured in proportion to the distance from the origin of the parent node to the
 * side of the bounding box through which the line is protruding.
 *
 * The initial value of this property is 1.5.
 */
+(GLfloat) directionMarkerScale;

/**
 * Sets the proportional distance that the direction marker line should protrude from the parent node.
 * This is measured in proportion to the distance from the origin of the parent node to the side of
 * the bounding box through which the line is protruding.
 *
 * The initial value of this property is 1.5.
 */
+(void) setDirectionMarkerScale: (GLfloat) scale;

/**
 * Returns the minimum length of a direction marker line, expressed in the global
 * coordinate system.
 *
 * Setting a value for this property can be useful for adding direction markers
 * to very small nodes, or nodes that do not have volume, such as a camera or light.
 *
 * The initial value of this property is zero.
 */
+(GLfloat) directionMarkerMinimumLength;

/**
 * Sets the minimum length of a direction marker line, expressed in the global
 * coordinate system.
 *
 * Setting a value for this property can be useful for adding direction markers
 * to very small nodes, or nodes that do not have volume, such as a camera or light.
 *
 * The initial value of this property is zero.
 */
+(void) setDirectionMarkerMinimumLength: (GLfloat) len;

@end


#pragma mark -
#pragma mark CC3BoundingVolumeDisplayNode

/**
 * CC3BoundingVolumeDisplayNode is a type of CC3MeshNode specialized for displaying
 * the bounding volume of its parent node. A CC3BoundingVolumeDisplayNode is typically
 * added as a child node to the node whose bounding volume is to be displayed.
 */
@interface CC3BoundingVolumeDisplayNode : CC3MeshNode
@end


#pragma mark -
#pragma mark CC3Fog

/**
 * CC3Fog is a mesh node that can render fog in the 3D scene.
 *
 * Typically, instances of this class are not generally used within the node assembly of a 
 * scene. Instead, a single instance of this class is used in the fog property of the CC3Scene.
 *
 * Fog color is controlled by the diffuseColor property.
 *
 * The style of attenuation imposed by the fog is set by the attenuationMode property.
 * See the notes of that property for information about how fog attenuates visibility.
 *
 * Using the performanceHint property, you can direct the GL engine to trade off between
 * faster or nicer rendering quality.
 *
 * Under OpenGL ES 1.1, fog is implemented as a direct feature of the GL engine, and this
 * class establishes the GL state for that fog.
 *
 * Under OpenGL versions that support GLSL, fog is rendered as a post-processing effect,
 * typically by rendering the scene to a surface that has both color and depth textures.
 * Add the color and depth textures from the scene-rendering surface to this node, and a
 * shader program that can render the node in clip-space, and provide fog effects. A good
 * choice is the combination of the CC3ClipSpaceTexturable.vsh vertex shader and the
 * CC3Fog.fsh fragment shader.
 */
@interface CC3Fog : CC3MeshNode {
	GLenum _attenuationMode;
	GLenum _performanceHint;
	GLfloat _density;
	GLfloat _startDistance;
	GLfloat _endDistance;
}

/**
 * Indicates how the fog attenuates visibility with distance.
 *
 * The value of this property must be one of the following sybolic constants:
 * GL_LINEAR, GL_EXP or GL_EXP2.
 *
 * When the value of this property is GL_LINEAR, the relative visibility of an object
 * in the fog will be determined by the linear function ((e - z) / (e - s)), where
 * s is the value of the start property, e is the value of the end property, and z is
 * the distance of the object from the camera
 *
 * When the value of this property is GL_EXP, the relative visibility of an object in
 * the fog will be determined by the exponential function e^(-(d - z)), where d is the
 * value of the density property and z is the distance of the object from the camera.
 *
 * When the value of this property is GL_EXP2, the relative visibility of an object in
 * the fog will be determined by the exponential function e^(-(d - z)^2), where d is the
 * value of the density property and z is the distance of the object from the camera.
 *
 * The initial value of this property is GL_EXP2.
 */
@property(nonatomic, assign) GLenum attenuationMode;

/**
 * Indicates how the GL engine should trade off between rendering quality and speed.
 * The value of this property should be one of GL_FASTEST, GL_NICEST, or GL_DONT_CARE.
 *
 * The initial value of this property is GL_DONT_CARE.
 */
@property(nonatomic, assign) GLenum performanceHint;

/**
 * The density value used in the exponential functions. This property is only used
 * when the attenuationMode property is set to GL_EXP or GL_EXP2.
 *
 * See the description of the attenuationMode for a discussion of how the exponential
 * functions determine visibility.
 *
 * The initial value of this property is 1.0.
 */
@property(nonatomic, assign) GLfloat density;

/**
 * The distance from the camera, at which linear attenuation starts. Objects between
 * this distance and the near clipping plane of the camera will be completly visible.
 *
 * This property is only used when the attenuationMode property is set to GL_LINEAR.
 *
 * See the description of the attenuationMode for a discussion of how the linear
 * function determine visibility.
 *
 * The initial value of this property is 0.0.
 */
@property(nonatomic, assign) GLfloat startDistance;

/**
 * The distance from the camera, at which linear attenuation ends. Objects between
 * this distance and the far clipping plane of the camera will be completely obscured.
 *
 * This property is only used when the attenuationMode property is set to GL_LINEAR.
 *
 * See the description of the attenuationMode for a discussion of how the linear
 * function determine visibility.
 *
 * The initial value of this property is 1.0.
 */
@property(nonatomic, assign) GLfloat endDistance;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) fog;


#pragma mark Deprecated functionality

/** @deprecated Use diffuseColor property instead. */
@property(nonatomic, assign) ccColor4F floatColor DEPRECATED_ATTRIBUTE;

/** @deprecated Use CCActions to control the fog characteristics. */
-(void) update: (CCTime)dt DEPRECATED_ATTRIBUTE;

@end



