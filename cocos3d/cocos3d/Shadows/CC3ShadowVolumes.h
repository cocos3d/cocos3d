/*
 * CC3ShadowVolumes.h
 *
 * cocos3d 0.6.3
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3VertexSkinning.h"
#import "CC3Light.h"
#import "CC3Billboard.h"
#import "CC3UtilityMeshNodes.h"

/** The suggested default shadow volume vertex offset factor. */
static const GLfloat kCC3DefaultShadowVolumeVertexOffsetFactor = 0.001f;


#pragma mark -
#pragma mark CC3ShadowVolumeMeshNode

/**
 * The mesh node used to build a shadow volume. A single CC3ShadowVolumeMeshNode
 * instance represents the shadow from a single light for a single shadow-casting node.
 *
 * As a mesh node, the CC3ShadowVolumeMeshNode instance is added as a child to the node
 * whose shadow is to be represented. To automatically create a CC3ShadowVolumeMeshNode
 * and add it to the shadow-casting node, use the addShadowVolumesForLight: method on
 * the shadow-casting node (or any structural ancestor of that node).
 *
 * CC3ShadowVolumeMeshNode implements the CC3ShadowProtocol. The implementation of the
 * updateShadow method populates a shadow volume mesh that encompasses the volume of
 * space shadowed by the shadow-casting node. Any other object with this shadow volume
 * will be shadowed by that node.
 *
 * The shadow volume mesh of this node is invisible in itself, but by depth-testing
 * against other drawn nodes, a stencil is created indicating which view pixels will
 * be in shadow. Those view pixels are then darkened accordingly.
 *
 * Of all shadowing techniques, shadow volumes result in the most accurate shadows,
 * but are also the most computationally intensive.
 *
 * Shadow volumes use a stencil buffer to determine the areas that require shading. The stencil
 * buffer must be allocated within the EAGLView when the view is created and initialized.
 * On the iOS, the sencil buffer is combined with the depth buffer. You create a stencil buffer by
 * passing the value GL_DEPTH24_STENCIL8 as the depth format argument in the CC3GLView method
 * viewWithFrame:pixelFormat:depthFormat:preserveBackbuffer:sharegroup:multiSampling:numberOfSamples:.
 */
@interface CC3ShadowVolumeMeshNode : CC3MeshNode <CC3ShadowProtocol> {
	CC3Light* _light;
	GLushort _shadowLagFactor;
	GLushort _shadowLagCount;
	GLfloat _shadowVolumeVertexOffsetFactor;
	GLfloat _shadowExpansionLimitFactor;
	BOOL _isShadowDirty : 1;
	BOOL _shouldDrawTerminator : 1;
	BOOL _shouldShadowFrontFaces : 1;
	BOOL _shouldShadowBackFaces : 1;
	BOOL _useDepthFailAlgorithm : 1;
	BOOL _shouldAddEndCapsOnlyWhenNeeded : 1;
}

/**
 * Indicates that this should display the terminator line of the shadow-casting node.
 *
 * The terminator line is the line that separates the illuminated side of the
 * shadow-casting object from the dark side. It defines the start of the shadow
 * volume mesh that is attached to the shadow-casting node.
 *
 * This property can be useful for diagnostics during development. This property
 * only has effect if the visible property is set to YES for this shadow-volume node.
 */
@property(nonatomic, assign) BOOL shouldDrawTerminator;

// TODO: will change when polymorphism has been figured out
/**
 * Draws this node to a stencil. The stencil is marked wherever another node
 * intersects the mesh volume of this node, and is therefore in shadow.
 *
 * The application should not use this method. The method signature, and use of
 * this method will change as additional shadow-casting techniques are introduced.
 */
-(void) drawToStencilWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Returns the default value to which the visible property will be set when an instance is
 * created and initialized.
 *
 * The initial value of this property is NO. Normally, shadow volumes affect the contents of
 * the stencil buffer, but are not directly visible themselves. However, during development
 * debugging, you can set this property to YES to make the shadow volumes visible within the
 * scene, to help visualize how the shadow volumes are interacting with the scene.
 */
+(BOOL) defaultVisible;

/**
 * Sets the default value to which the visible property will be set when an instance is 
 * created and initialized.
 *
 * The initial value of this property is NO. Normally, shadow volumes affect the contents of
 * the stencil buffer, but are not directly visible themselves. However, during development
 * debugging, you can set this property to YES to make the shadow volumes visible within the
 * scene, to help visualize how the shadow volumes are interacting with the scene.
 */
+(void) setDefaultVisible: (BOOL) defaultVisible;

@end


#pragma mark -
#pragma mark CC3StencilledShadowPainterNode

/**
 * The mesh node used to paint the shadows cast by shadow volumes.
 *
 * Shadow volumes are used to define a stencil that is then used to draw dark areas onto the
 * viewport in clip-space, where scene mesh nodes are casting shadows. This painter is used
 * to draw those dark areas where the stencil indicates.
 */
@interface CC3StencilledShadowPainterNode : CC3ClipSpaceNode <CC3ShadowProtocol>
@end


#pragma mark -
#pragma mark CC3ShadowDrawingVisitor

/**
 * CC3ShadowDrawingVisitor is a CC3NodeDrawingVisitor that is passed
 * to a shadow node for drawing shadows.
 */
@interface CC3ShadowDrawingVisitor : CC3NodeDrawingVisitor
@end


#pragma mark -
#pragma mark CC3Node ShadowVolumes category

/** Extension category to support shadow volumes. */
@interface CC3Node (ShadowVolumes)

/**
 * Returns whether this node is an instance of a shadow volume.
 *
 * Always returns NO. Subclasses that are shadow volumes will return YES.
 */
@property(nonatomic, readonly) BOOL isShadowVolume;

/**
 * For each light currently in the scene, adds a shadow volume to each
 * descendant node that contains a mesh.
 *
 * This method is a convenience method that invokes the addShadowVolumesForLight: on this node
 * for each existing light in the scene. See the notes for the addShadowVolumesForLight: method
 * for detailed information about adding shadow volumes to nodes.
 *
 * It is safe to invoke this method more than once with the same, or a different light.
 * Only one shadow volume will be added to any mesh node for a particular light. The mesh
 * node implementation checks to see if a shadow volume has been added already, and will
 * not add a second shadow volume for the same light.
 *
 * This method requires access to the lights in the scene, and will only be
 * effective when invoked after:
 *   - The node has been added to the scene.
 *   - The lights that are to cast shadows have been added to the scene. 
 * Invoking this method before adding this node, its descendants, and the
 * lights, to the scene will have no effect.
 */
-(void) addShadowVolumes;

/**
 * Adds a shadow volume to each descendant node that contains a mesh, for the specified light.
 * By using this method, you can control which lights cast shadows for each mesh node in your scene.
 *
 * A shadow volume is a special child mesh node added to each descendant mesh node. The effect
 * is to have each descendant mesh cast a shadow from the specified light. Invoking this method
 * on the CC3Scene will cause all meshes in the scene to cast shadows from the specified light.
 *
 * These shadow volume meshes are invisible, but are used to populate a stencil buffer that keeps
 * track of where a shadow volume mesh intersects a visible object mesh. This stencil is used to
 * paint the shadows onto the scene.
 *
 * The shadow volume created by this method will only have effect if the visible property of both
 * the node and the light are set to YES (ie- turning off a light also turns off any shadows it
 * is casting).
 *
 * Shadow volumes use a stencil buffer to determine the areas that require shading. The stencil
 * buffer must be allocated within the EAGLView when the view is created and initialized.
 * On the iOS, the sencil buffer is combined with the depth buffer. You create a stencil buffer by
 * passing the value GL_DEPTH24_STENCIL8 as the depth format argument in the CC3GLView method
 * viewWithFrame:pixelFormat:depthFormat:preserveBackbuffer:sharegroup:multiSampling:numberOfSamples:.
 *
 * It is safe to invoke this method more than once with the same, or a different light. Only one
 * shadow volume will be added to any mesh node for a particular light. Each mesh node checks to
 * see if a shadow volume has been added already, and will not add a second shadow volume for the
 * same light.
 *
 * To ensure that all objects behind each shadow-casting mesh node are shadowed, each shadow
 * volume mesh extends to infinity. As a result, when a shadow volum is added using this method,
 * the hasInfiniteDepthOfField property of the active camera is automatically set to YES, so that
 * the shadow volume is not clipped by the far clipping plane of the camera's frustum.
 *
 * If you know that you will never require end-caps, and want a finite camera frustum, you
 * can set the hasInfiniteDepthOfField of the active camera back to NO. See the notes for
 * the shouldAddShadowVolumeEndCapsOnlyWhenNeeded property for more info on the use of shadow
 * volume end caps.
 *
 * Shadows are inherently dynamic, and change as the shadow-casting node and light move relative
 * to one another. For this reason, this method causes all meshes with a shadow volume to retain
 * vertex location and index data (and for skinned meshes vertex weight and matrix index data).
 *
 * If you know that the mesh nodes and light are fixed, after the first update to the scene,
 * you can save memory by retrieving the vertex locations, indices, weights and matrix indices
 * vertex arrays, set the shouldReleaseRedundantContent property on each to YES, and invoke the
 * releaseRedundantContent method on each.
 *
 * The internal management of shadow volumes requires intense access to the faces of the mesh
 * that is casting the shadow. For this reason, when a shadow volume is added to a mesh node, the
 * shouldCacheFaces property of that node is automatically set to YES, to improve the performance
 * of shadow volume calculations. If you prefer to preserve memory instead, you can explicitly set
 * this property back to NO.
 *
 * This method will affect only the current descendant mesh nodes. Descendants added after this
 * method is invoked will not automatically cast shadows. When dynamically adding a descendant
 * node, invoke this method to have the new node cast a shadow from the specified light.
 *
 * When a light is removed from the scene, the shadow volume for that light will automatically
 * be removed from each mesh node. However, when a light is added, shadow volumes will not
 * automatically be created for that light. When dyamically adding a light, you should invoke
 * this method, or the addShadowVolumes method, to create a shadow volume for that light.
 */
-(void) addShadowVolumesForLight: (CC3Light*) aLight;

/**
 * Returns whether this node, or any descendant, has
 * had a shadow volume added for the specified light.
 */
-(BOOL) hasShadowVolumesForLight: (CC3Light*) aLight;

/**
 * Returns whether this node, or any descendant, has
 * had a shadow volume added for any light.
 */
-(BOOL) hasShadowVolumes;

/**
 * Removes the shadow volume child nodes that were previously added using
 * the addShadowVolumesForLight: and addShadowVolumes methods for the
 * specified light, from this node and all descendant nodes.
 *
 * Removing shadow volumes from a node will NOT automatically set its
 * shouldCacheFaces property to NO, and will not automatically free up
 * vertex data that was retained to build the shadow volumes. If you no
 * longer need the face or vertex data to be cached, you should explicitly
 * set the shouldCacheFaces property to NO, and the shouldReleaseRedundantContent
 * property to YES, and invoke the releaseRedundantContent method.
 *
 * It is safe to invoke this method more than once, or even if no shadow
 * volumes have previously been added.
 */
-(void) removeShadowVolumesForLight: (CC3Light*) aLight;

/**
 * Removes all the shadow volume child nodes that were previously added using
 * the addShadowVolumesForLight: and addShadowVolumes methods, from this node
 * and all descendant nodes, by invoking the removeShadowVolumesForLight:
 * method for each light in the scene.
 *
 * It is safe to invoke this method more than once, or even if no shadow
 * volumes have previously been added.
 */
-(void) removeShadowVolumes;

/**
 * Returns an array of all the shadow volume child nodes that were previously added
 * to this node using the addShadowVolumesForLight: and addShadowVolumes methods.
 *
 * This implementation only looks through the immediate child nodes of this node,
 * and does not recurse below this level. As such, this method only has meaning
 * when invoked on a mesh node.
 */
@property(nonatomic, readonly) NSArray* shadowVolumes;

/**
 * Returns the shadow volume that was added to this node for the specified light,
 * or returns nil if such a shadow volume does not exist in this node.
 *
 * This implementation only looks through the immediate child nodes of this node,
 * and does not recurse below this level. As such, this method only has meaning
 * when invoked on a mesh node.
 */
-(CC3ShadowVolumeMeshNode*) getShadowVolumeForLight: (CC3Light*) aLight;

/**
 * An offset factor used by the GL engine when comparing the Z-distance of the
 * content of shadows against previously drawn content. This can be used to correct
 * for Z-fighting between shadows and the surrounding objects (including the node
 * casting the shadow itself).
 *
 * For descendant nodes that are shadow volumes, this property combines with the
 * shadowOffsetUnits property to offset the shadow volume from the shadow-casting
 * node itself, so that the shadow volume end caps are drawn slightly in front of
 * the shadow-casting node, to ensure that the shadow volume end caps do not acquire
 * holes caused by Z-fighting with the shadow-caster.
 * 
 * For shadow volume nodes, the initial value of this property is zero. You can
 * adjust this value (typically negative) if Z-fighting occurs. However, be aware
 * that larger absolute values can distort the shadows.
 *
 * This is a convenience property that sets or queries the decalOffsetFactor property
 * on any descendant shadow nodes. The decalOffsetFactor property will only be set
 * on descendant nodes that represent shadows. The value of that property on other
 * nodes that are not shadows will be left unchanged.
 *
 * See the notes for the decalOffsetFactor property for technical details about how
 * the value of this property affects drawing.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first non-zero value of this property from
 * any descendant shadow node, or will return zero if no shadow nodes are found in
 * the descendants of this node.
 */
@property(nonatomic, assign) GLfloat shadowOffsetFactor;

/**
 * An offset value used by the GL engine when comparing the Z-distance of the
 * content of shadows against previously drawn content. This can be used to correct
 * for Z-fighting between shadows and the surrounding objects (including the node
 * casting the shadow itself).
 *
 * For descendant nodes that are shadow volumes, this property combines with the
 * shadowOffsetFactor property to offset the shadow volume from the shadow-casting
 * node itself, so that the shadow volume end caps are drawn slightly in front of
 * the shadow-casting node, to ensure that the shadow volume end caps do not acquire
 * holes caused by Z-fighting with the shadow-caster.
 * 
 * For shadow volume nodes, the initial value of this property is minus one (-1) unit.
 * You can adjust this value (typically negative) if Z-fighting occurs. However, be
 * aware that larger absolute values will tend to distort shadows cast.
 *
 * This is a convenience property that sets or queries the decalOffsetUnits property
 * on any descendant shadow nodes. The decalOffsetUnits property will only be set
 * on descendant nodes that represent shadows. The value of that property on other
 * nodes that are not shadows will be left unchanged.
 *
 * See the notes for the decalOffsetUnits property for technical details about how
 * the value of this property affects drawing.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first non-zero value of this property from
 * any descendant shadow node, or will return zero if no shadow nodes are found in
 * the descendants of this node.
 */
@property(nonatomic, assign) GLfloat shadowOffsetUnits;

/**
 * The vertices of a shadow volume start at the vertices of the light terminator of the
 * shadow-casting node, and extend away from the light source. The value of this property
 * is multiplied by the distance from the camera to the shadow-casting node to derive a
 * short distance to offset the shadow volume vertices from the corresponding vertices
 * of the shadow-casting node, in the direction away from the light.
 *
 * The purpose of nudging the vertices of the shadow volume away from the shadow-casting
 * mesh is to reduce Z-fighting between the shadow-caster mesh and the shadow volume
 * mesh. In this sense, this property aims to fix the same issue that the shadowOffsetUnits
 * and shadowOffsetFactor properties attempt to resolve.
 *
 * The difference is that the shadowVolumeVertexOffsetFactor is always applied in
 * the direction away from the <em>light</em>, whereas the shadowOffsetUnits and
 * shadowOffsetFactor properties move the depth testing towards or away from the
 * <em>camera</em>. This difference can sometimes show up as the relative positions
 * of the shadow-caster, light and camera move around, and is particularly apparent
 * with 2D planar meshes.
 * 
 * Particularly with 2D planar meshes, you can set this property to a positive, non-zero
 * value to nudge the shadow volume vertices away from the shadow-caster vertices in the
 * direction away from the light.
 *
 * Although both this property and the shadowOffsetUnits and shadowOffsetFactor properties
 * can be used together, doing so can introduce conflicts, again depending on the relative
 * positions of the shadow-casting node, light and camera. It is recommended that you use
 * one or the other technique. Either set one or both of the shadowOffsetUnits and
 * shadowOffsetFactor properties to a non-zero value, and leave this property with a zero
 * value, or set this property to a non-zero value, and set the shadowOffsetUnits and
 * shadowOffsetFactor properties each to zero.
 *
 * For non-planar convex meshes, leave this property set to zero. For planar meshes,
 * set this property to a positive non-zero value, and set the shadowOffsetUnits and
 * shadowOffsetFactor properties to zero.
 *
 * The initial value of this property is zero, indicating that no offset will be applied
 * to the shadow volume vertices. Typically, the value of this property is measured in
 * thousandths. As a convenience, the constant kCC3DefaultShadowVolumeVertexOffsetFactor
 * can be used to set the value of this property to an appropriate value.
 *
 * The value of this property can only be changed after the shadow volumes have been added.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first non-zero value of this property from
 * any descendant shadow node, or will return zero if no shadow nodes are found in
 * the descendants of this node.
 */
@property(nonatomic, assign) GLfloat shadowVolumeVertexOffsetFactor;

/**
 * The calculation of shadow shape and movement can often be quite expensive. To keep
 * performance high, these calculations are performed only when necessary, specifically
 * when any of the shadow-casting node, light or camera moves.
 *
 * Because of this design, few updates will be required for a relatively static
 * environment where the light, camera, and node do not often move. In such a situation,
 * the processing load added by the shadow calculations will be low.
 * 
 * However, when the node, light and camera are in constant motion, a noticable performance
 * penalty may arise as the shadow shape and movement is re-calculated frequently.
 *
 * This property can be used to control how often the shape and location of the shadow
 * should be updated. The value of this property indicates the number of update cycles
 * (usually the same as the number of frames) between successive updates of the shadow
 * volume shape and location.
 *
 * Setting the value of this property to one will cause the shape and location of the
 * shadow to be updated on every update to the locations of the node, light and camera
 * (ie- every frame). Setting the value of this property to an integer greater than one
 * will cause the update of the shadow to occur only once per that many updates to the
 * shadow-casting node, light and camera (ie- once per that number of frames), effectively
 * creating a lag between the movement of the shadow-casting node, and its shadow.
 *
 * The visible effect of this lag depends on the nature of the movement of the
 * shadow-casting node. In many situations, the lag will be unnoticable, or at least
 * acceptablly low. However, the lag can sometimes create self-shadowing effects on
 * the side of the node that is in shadow. The acceptability of this will depend on
 * whether the camera can move behind the node to view the sides that are in shadow,
 * and whether the self-shadow is visible on the darkened side.
 *
 * The use of a value larger than one for this property can often be particularly
 * useful for the shadows of skinned mesh nodes (bone-rigged characters), because
 * the calculations involved in updating the shape and motion of deformable meshes
 * are particularly performance-heavy, and the additional lag introduced by this
 * property is usually quite acceptable visually.
 *
 * When a number of shadows are being calculated, and the value of this property is set
 * to a value greater than one, the shadowLagCount property can be used to ensure that
 * all shadows are not calculated during the same update cycle, spreading the load of
 * calculating shadow updates for a number of mesh nodes across several update cycles.
 * See the notes of the shadowLagCount property for more info.
 *
 * The initial value of this property is one, indicating that the shadow shape and
 * motion will be updated on every update of the shadow-casting node, light or camera.
 *
 * The value of this property can only be changed after the shadow volumes have been added.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first value greater than one from this property
 * from any descendant shadow node, or will return one if no shadow nodes are found
 * in the descendants of this node.
 */
@property(nonatomic, assign) GLushort shadowLagFactor;

/**
 * Indicates the current number of update cycles to the shadow-casting node, light and
 * camera that must be processed before the shadow shape and movement will be updated.
 *
 * In order to improve performance, the shadowLagFactor property can be used to control
 * how often the shape and location of the shadow should be updated. The value of that
 * property indicates the number of update cycles (usually the same as the number of
 * frames) between successive updates of the shadow volume shape and location. This
 * introduces a lag between the movement of the shadow-casting node, and its shadow,
 * which in many cases will not be visibly significant See the notes of the
 * shadowLagFactor for more info about controlling this behaviour.
 *
 * The value of this property is decremented just before the updateBeforeTransform:
 * method is invoked during each update cycle, and when the value reaches zero, the
 * transform, shape, and location of the shadow will be recalculated. Once the
 * recalculation is complete, the value of this property is set to the value of the
 * shadowLagFactor, to being the update cycle countdown again.
 *
 * When the shadowLagFactor property is used to improve performance, to avoid having
 * all shadows updated in the same update cycle, setting the value of this property
 * to a different value across different shadow-casting nodes can help distribute the
 * load of calculating the shadows for a number of shadow-casting nodes across several
 * update cycles.
 *
 * In most cases, you do not need to set the value of this property directly. becuase
 * when the value of the shadowLagFactor property is set, the value of this property is
 * automatically set to a random value between one and the value of the shadowLagFactor.
 *
 * When setting the value of this property, it is usually desireable to set the same
 * value in all the nodes within each structural node assembly so that the shadows
 * of all shadow-casting nodes that are moving together, will move together.
 *
 * Reading the value of this property will tell you where in the update cycle the
 * shadow is currently sitting. The value of this property will change on each update,
 * cycling between the value of the shadowLagFactor, and zero.
 *
 * The initial value of this property is one, indicating that the shadow shape and
 * motion will be updated on the next update of the shadow-casting node, light or camera.
 *
 * After that update, the value will be automatically changed to the value of the
 * shadowLagFactor property.
 *
 * The value of this property can only be changed after the shadow volumes have been added.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first value greater than zero from this property
 * from any descendant shadow node, or will return zero if no shadow nodes are found
 * in the descendants of this node. 
 */
@property(nonatomic, assign) GLushort shadowLagCount;

/**
 * When using shadow volumes, the shadow volume can be drawn with or without end-caps.
 * This property determines whether the end-caps will always be added, or will be
 * automatically added only when needed.
 * 
 * Adding end-caps can add a large number of additional faces to the shadow volume,
 * which can affect performance. It is therefore desireable to avoid using end-caps
 * where possible.
 *
 * End-caps are required when the camera is located within the shadow volume (meaning
 * that the camera is shadowed by the node casting the shadow). Because of this,
 * end-caps will automatically be added to a shadow volume when the camera passes
 * into that shadow volume, and will automatically be removed when the camera passes
 * back out of the shadow volume.
 *
 * However, without end-caps, the shadow will also be cast across the back of the
 * shadow-casting object itself, darkening the side of the object away from the light,
 * which may or may not be visible from the camera, and may or may not appear as
 * visually undesireable, depending on the lighting and color or texture applied to
 * the node. This self-shadowing is more noticable on light-colored materials.
 * In this situation, it may be desireable to include the end-caps at all times,
 * regardless of whether the camera is inside the shadow of the node or not.
 *
 * When this property is set to YES, the end-caps will automatically be added only
 * when the camera is within the shadow volume, and will be removed when the camera
 * moves out of the shadow volume. This provides optimal performance.
 *
 * When this property is set to NO, end-caps will be included always. This is not
 * as efficient, but avoids the issue of self-shadowing described above.
 *
 * The initial value of this property is NO, indicating that end-caps will be
 * included always, to avoid self-shadowing. If the visual effect of self-shadowing
 * on your object is not significant, you can set the value of this property to
 * YES to improve performance.
 *
 * The value of this property can only be changed after the shadow volumes have been added.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first NO value of this property from any
 * descendant shadow node, or will return YES if no shadow nodes are found in
 * the descendants of this node.
 */
@property(nonatomic, assign) BOOL shouldAddShadowVolumeEndCapsOnlyWhenNeeded;

/**
 * For shadows cast from locational lights, indicates a maximum distance that the
 * shadow will be allowed to expand.
 *
 * A shadow from lights at a specific location (locational lights), will expand in
 * size the farther it is cast from the shadow casting node. For some types of shadows,
 * allowing it to expand forever can cause visual artifacts, and so it can be beneficial
 * to limit that expansion.
 *
 * For example, an infinitely expanding shadow volume can display ghost-shadow artifacts
 * from single-sided shadow meshes (such as planes). In this case, limiting the expansion
 * allows the shadow volume to be closed off at the end by extending the remaining shadow
 * volume to a single point at infinity, rather than an infinite size at infinity.
 *
 * The value is specified as a multiplicative factor of the distance from the light to the
 * shadow casting node. For example, a value of 10 indicates that the shadow will continue
 * to expand for a distance behind the shadow-caster equivalent to 10 times the distance
 * from the light to the shadow-caster, and then it will remain the same size out to infinity.
 *
 * The initial value of this property is 100. The value of this property can only be changed
 * after the shadows have been added.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the value of this property from any descendant shadow
 * node, or will return zero if no shadow nodes are found in the descendants of this node.
 */
@property(nonatomic, assign) GLfloat shadowExpansionLimitFactor;

/**
 * Indicates whether a shadow should be cast from the front faces of the mesh.
 * 
 * For most meshes, the front faces form the visible faces of the mesh, and it
 * is these visible faces that will cast the shadow.
 *
 * The initial value of this property is YES, indicating that the shadow will
 * be cast from the front faces of the node.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first NO value of this property from any
 * descendant shadow node, or will return YES if no shadow nodes are found in
 * the descendants of this node.
 */
@property(nonatomic, assign) BOOL shouldShadowFrontFaces;

/**
 * Indicates whether a shadow should be cast from the back faces of the mesh.
 * 
 * For most meshes, the front faces form the visible faces of the mesh, and
 * the back faces are not rendered. In these typical situations, the value of
 * this property should be set to NO so that a shadow will not be built from
 * the back faces of the object.
 *
 * However, there are situations, such as with 2D planar meshes that can be
 * viewed from either side, where the back faces will be rendered.
 *
 * With shadows, there is also the situation where a planar node can be used
 * as a wall, with light coming from behind the wall. Since the back faces
 * of the wall mesh are facing the light, the wall will not cast a shadow.
 * 
 * In these less-common situations, this property can be set to YES to cause
 * a shadow to be cast by the back faces of the mesh.
 *
 * For a two-sided planar mesh, you can set both the shouldShadowFrontFaces
 * property and this property to YES to cause a shadow to be cast regardless
 * of the orientation of the 2D planar mesh to the light or the camera.
 *
 * The initial value of this property is NO, indicating that the shadow will
 * not be cast from the back faces of the node.
 *
 * Setting this value sets the same property on all descendant nodes that are shadows.
 *
 * Querying this property returns the first YES value of this property from any
 * descendant shadow node, or will return NO if no shadow nodes are found in
 * the descendants of this node.
 */
@property(nonatomic, assign) BOOL shouldShadowBackFaces;

/** 
 * Prewarms the meshes of all descendant mesh nodes to prepare for shadow volumes.
 *
 * Shadow volumes make very heavy use of many mesh face characteristics. This method
 * ensures that the faces have been populated for each descendant mesh node.
 *
 * This method is invoked automatically when a shadow volume is added to a mesh node.
 * Usually, the application should never need to invoke this method directly.
 */
-(void) prewarmForShadowVolumes;

/**
 * If this node is a shadow volume, returns whether the shadow cast by the shadow
 * volume will be visible. Returns NO if this node is not a shadow volume node.
 */
-(BOOL) isShadowVisible;

@end


#pragma mark -
#pragma mark CC3Billboard ShadowVolumes category

/** Extension category to support shadow volumes. */
@interface CC3Billboard (ShadowVolumes)

/**
 * Overridden to establish the underlying mesh, and to set the following properties
 * to accommodate that a billboard is an open, planar mesh:
 *   shouldShadowBackFaces = YES
 *   shadowOffsetUnits = 0
 *   shadowVolumeVertexOffsetFactor = kCC3DefaultShadowVolumeVertexOffsetFactor
 *
 * See the notes for the CC3Node addShadowVolumesForLight: method
 * for detailed information about adding shadow volumes to nodes.
 */
-(void) addShadowVolumesForLight: (CC3Light*) aLight;

@end
