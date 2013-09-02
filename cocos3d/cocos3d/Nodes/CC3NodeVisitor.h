/*
 * CC3NodeVisitor.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3Matrix.h"
#import "CC3PerformanceStatistics.h"
#import "CC3OpenGL.h"

@class CC3Node, CC3MeshNode, CC3Camera, CC3Light, CC3Scene, CC3ShaderProgram;
@class CC3Material, CC3TextureUnit, CC3Mesh, CC3NodeSequencer, CC3SkinSection;
@protocol CC3RenderSurface;


#pragma mark -
#pragma mark CC3NodeVisitor

/**
 * A CC3NodeVisitor is a context object that is passed to a node when it is visited
 * during a traversal of the node hierarchy.
 *
 * To initiate a visitation run, invoke the visit: method on any CC3Node.
 *
 * Subclasses will override template methods to customize the behaviour prior to, during,
 * and after the node traversal.
 *
 * If a node is to be removed from the node structural hierarchy during a visitation run,
 * the requestRemovalOf: method can be used instead of directly invoking the remove method
 * on the node itself. A visitation run involves iterating through collections of child
 * nodes, and removing a node during the iteration of a collection raises an error.
 */
@interface CC3NodeVisitor : NSObject {
	CC3Node* _startingNode;
	CC3Node* _currentNode;
	CCArray* _pendingRemovals;
	CC3Camera* _camera;
	BOOL _shouldVisitChildren : 1;
}

/**
 * Indicates whether this visitor should traverse the child nodes of any node it visits.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldVisitChildren;

/**
 * Visits the specified node, then if the shouldVisitChildren property is set to YES,
 * invokes this visit: method on each child node as well.
 *
 * Subclasses will override several template methods to customize node visitation behaviour.
 */
-(void) visit: (CC3Node*) aNode;

/**
 * Requests the removal of the specfied node.
 *
 * During a visitation run, to remove a node from the hierarchy, you must use this method
 * instead of directly invoking the remove method on the node itself. Visitation involves
 * iterating through collections of child nodes, and removing a node during the iteration
 * of a collection raises an error.
 *
 * This method can safely be invoked while a node is being visited. The visitor keeps
 * track of the requests, and safely removes all requested nodes as part of the close
 * method, once the visitation of the full node assembly is finished.
 */
-(void) requestRemovalOf: (CC3Node*) aNode;


#pragma mark Accessing node contents

/**
 * The CC3Node on which this visitation traversal was intitiated. This is the node
 * on which the visit: method was first invoked to begin a traversal of the node
 * structural hierarchy.
 *
 * This property is only valid during the traversal, and will be nil both before
 * and after the visit: method is invoked.
 */
@property(nonatomic, readonly) CC3Node* startingNode;

/**
 * Returns the CC3Scene.
 *
 * This is a convenience property that returns the scene property of the startingNode property.
 */
@property(nonatomic, readonly) CC3Scene* scene;

/**
 * The camera that is viewing the 3D scene.
 *
 * If this property is not set in advance, it is lazily initialized to the value
 * of the defaultCamera property when first accessed during a visitation run.
 *
 * The value of this property is not cleared at the end of the visitation run.
 */
@property(nonatomic, retain) CC3Camera* camera;

/**
 * The default camera to use when visiting a node assembly.
 *
 * This implementation returns the activeCamera property of the starting node.
 * Subclasses may override.
 */
@property(nonatomic, readonly) CC3Camera* defaultCamera;

/**
 * The CC3Node that is currently being visited.
 *
 * This property is only valid during the traversal of the node returned by this property,
 * and will be nil both before and after the visit: method is invoked on the node.
 */
@property(nonatomic, readonly) CC3Node* currentNode;

/**
 * Returns the mesh node that is currently being visited.
 *
 * This is a convenience property that returns the value of the currentNode property,
 * cast as a CC3MeshNode. It is up to the invoker to make sure that the current node
 * actually is a CC3MeshNode.
 *
 * This property is only valid during the traversal of the node returned by this property,
 * and will be nil both before and after the visit: method is invoked on that node.
 */
@property(nonatomic, readonly) CC3MeshNode* currentMeshNode;

/**
 * Returns the mesh of the mesh node that is currently being visited.
 *
 * It is up to the invoker to make sure that the current node actually is a CC3MeshNode.
 *
 * This property is only valid during the traversal of the node returned by this property,
 * and will be nil both before and after the visit: method is invoked on the node.
 */
@property(nonatomic, readonly) CC3Mesh* currentMesh;

/**
 * Returns the material of the mesh node that is currently being visited, or returns nil
 * if that mesh node has no material.
 *
 * It is up to the invoker to make sure that the current node actually is a CC3MeshNode.
 *
 * This property is only valid during the traversal of the node returned by the currentMeshNode
 * property, and will be nil both before and after the visit: method is invoked on that node.
 */
@property(nonatomic, readonly) CC3Material* currentMaterial;

/**
 * Returns the texture unit at the specified index from the mesh node that is currently being
 * visited, or returns nil if the material covering the node has no corresponding texture unit.
 *
 * It is up to the invoker to make sure that the current node actually is a CC3MeshNode.
 *
 * The value returned by this method is only valid during the traversal of the node returned
 * by the currentMeshNode property, and will be nil both before and after the visit: method
 * is invoked on that node.
 */
-(CC3TextureUnit*) currentTextureUnitAt: (GLuint) texUnit;

/** The number of lights in the scene. */
@property(nonatomic, readonly) NSUInteger lightCount;

/**
 * Returns the light indicated by the index, or nil if the specified index is greater than
 * the number of lights currently existing in the scene.
 *
 * The specified index is an index into the lights array of the scene, and is not necessarily
 * the same as the lightIndex property of the CC3Light.
 */
-(CC3Light*) lightAt: (GLuint) index;

/**
 * The performanceStatistics being accumulated during the visitation runs.
 *
 * This is extracted from the startingNode, and may be nil if that node
 * is not collecting statistics.
 */
@property(nonatomic, readonly) CC3PerformanceStatistics* performanceStatistics;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) visitor;

/** Returns a more detailed description of this instance. */
-(NSString*) fullDescription;

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
 * The transforms can be calculated from the CC3Scene or from the startingNode, depending
 * on the value of the shouldLocalizeToStartingNode property. Normally, the transforms
 * are calculated from the CC3Scene, but localizing to the startingNode can be useful for
 * determining relative transforms between ancestors and descendants.
 */
@interface CC3NodeTransformingVisitor : CC3NodeVisitor {
	BOOL _isTransformDirty : 1;
	BOOL _shouldLocalizeToStartingNode : 1;
	BOOL _shouldRestoreTransforms : 1;
}

/**
 * Indicates whether all transforms should be localized to the local coordinate system
 * of the startingNode.
 *
 * If this property is set to NO, the transforms of all ancestors of each node, all the
 * way to CC3Scene, will be included when calculating the globalTransformMatrix and global
 * properties of that node. This is the normal situation.
 *
 * If this property is set to YES the transforms of the startingNode and its ancestors,
 * right up to the CC3Scene, will be ignored. The result is that the globalTransformMatrix
 * and all global properties (globalLocation, etc) will be relative to the startingNode.
 
 * This can be useful when you want to coordinate node positioning within a particular
 * common ancestor, by using their global properties relative to that common ancestor
 * node.
 * 
 * It is also used when determine the boundingBox property of a node, by transforming
 * all descendant nodes by all transforms between the node and each descendant, but
 * ignoring the transforms of the ancestor nodes of the node whose local bounding box
 * is being calculated.
 *
 * Setting this property to YES will force the recalculation of the globalTransformMatrix of
 * each node visited, to ensure that they are relative to the startingNode. Further,
 * once the visitation run is complete, if this property is set to YES, the close
 * method will rebuild the transformMatrices of the startingNode and its descendants,
 * to leave the transformMatrices in their normal global form.
 * 
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldLocalizeToStartingNode;

/**
 * This property only has effect when the shouldLocalizeToStartingNode property is set to YES.
 *
 * Indicates whether the full global transforms should be restored afte the localized
 * transforms have been calculated and consumed. Setting this to YES is useful when
 * the localized transform is being temporarily calculated for a specialized purpose
 * such as determining a local bounding box, but then the full global transform should
 * be immediately restored for further use.
 *
 * The initial value of this property is NO. However, specialized subclasses may set
 * to YES initially as appropriate.
 */
@property(nonatomic, assign) BOOL shouldRestoreTransforms;

/**
 * Returns whether the transform matrix of the node currently being visited is dirty
 * and needs to be recalculated.
 *
 * The value of this property is consistent throughout the processing of a particular
 * node. It is set before each node is visited, and is not changed until after the
 * node has finished being processed, even if the node's transform matrix is recalculated
 * during processing. This allows any post-node-processing activities, either within the
 * visitor or within the node, to know that the transform matrix was changed.
 */
@property(nonatomic, readonly) BOOL isTransformDirty;

/**
 * Returns the transform matrix to use as the parent matrix when transforming the
 * specified node.
 * 
 * This usually returns the value of the parentGlobalTransformMatrix of the specified node.
 * However, if the shouldLocalizeToStartingNode property is set to YES and the
 * startingNode is either the specified node or its parent, this method returns nil.
 */
-(CC3Matrix*) parentTansformMatrixFor: (CC3Node*) aNode;

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
	ccTime _deltaTime;
}

/**
 * This property gives the interval, in seconds, since the previous update. This value can be
 * used to create realistic real-time motion that is independent of specific frame or update rates.
 * Depending on the setting of the maxUpdateInterval property of the CC3Scene instance, the value
 * of this property may be clamped to an upper limit. See the description of the CC3Scene
 * maxUpdateInterval property for more information about clamping the update interval.
 */
@property(nonatomic, assign) ccTime deltaTime;

@end


#pragma mark -
#pragma mark CC3NodeBoundingBoxVisitor

/**
 * Specialized transforming visitor that measures the bounding box of a node and all
 * its descendants, by traversing each descendant node, ensuring each globalTransformMatrix
 * is up to date, and accumulating a bounding box that encompasses the local content
 * of the startingNode and all of its descendants.
 *
 * If the value of the shouldLocalizeToStartingNode property is YES, the bounding
 * box will be in the local coordinate system of the startingNode, otherwise it
 * will be in the global coordinate system of the 3D scene.
 */
@interface CC3NodeBoundingBoxVisitor : CC3NodeTransformingVisitor {
	CC3Box _boundingBox;
}

/**
 * Returns the bounding box accumulated during the visitation run.
 *
 * If the value of the shouldLocalizeToStartingNode property is YES, the bounding
 * box will be in the local coordinate system of the startingNode, otherwise it
 * will be in the global coordinate system of the 3D scene.
 *
 * If none of the startingNode or its descendants have any local content, this
 * property will return kCC3BoxNull.
 *
 * The initial value of this property will be kCC3BoxNull.
 */
@property(nonatomic, readonly) CC3Box boundingBox;

@end


#pragma mark -
#pragma mark CC3NodeDrawingVisitor

/**
 * CC3NodeDrawingVisitor is a CC3NodeVisitor that is passed to a node when it is visited
 * during drawing operations.
 *
 * The visitor uses the camera property to determine which nodes to visit. Only nodes that
 * are within the camera's field of view will be visited. Nodes outside the camera's frustum
 * will neither be visited nor drawn.
 *
 * Drawing operations only visit drawable mesh nodes, so the node access properties defined on
 * the CC3NodeVisitor superclass that rely on the current node being a CC3MeshNode containing
 * a mesh and material will be valid.
 */
@interface CC3NodeDrawingVisitor : CC3NodeVisitor {
	CC3NodeSequencer* _drawingSequencer;
	CC3SkinSection* _currentSkinSection;
	CC3ShaderProgram* _currentShaderProgram;
	id<CC3RenderSurface> _renderSurface;
	CC3OpenGL* _gl;
	CC3Matrix4x4 _projMatrix;
	CC3Matrix4x3 _viewMatrix;
	CC3Matrix4x3 _modelMatrix;
	CC3Matrix4x4 _viewProjMatrix;
	CC3Matrix4x3 _modelViewMatrix;
	CC3Matrix4x4 _modelViewProjMatrix;
	CC3Viewport _onScreenViewport;
	ccColor4F _currentColor;
	GLuint _textureUnitCount;
	GLuint _currentTextureUnitIndex;
	GLuint _nextUnassignedTextureSampler;
	ccTime _deltaTime;
	BOOL _shouldDecorateNode : 1;
	BOOL _isDrawingEnvironmentMap : 1;
	BOOL _isVPMtxDirty : 1;
	BOOL _isMVMtxDirty : 1;
	BOOL _isMVPMtxDirty : 1;
}

/** 
 * The OpenGL state. During drawing, all OpenGL commands are called through this instance.
 *
 * If not set directly, this is lazily initialized to the CC3OpenGL.sharedGL singleton.
 */
@property(nonatomic, retain) CC3OpenGL* gl;

/**
 * The index of the current texture unit being drawn.
 *
 * This value is set during drawing when the visitor is passed to the texture coordinates array.
 */
@property(nonatomic, assign) GLuint currentTextureUnitIndex;

/**
 * Set the value of the textureUnitCount to that of the currentTextureUnitIndex property,
 * and disables all texture units whose index is at or above the current value of the
 * currentTextureUnitIndex property.
 */
-(void) disableUnusedTextureUnits;

/**
 * Returns the number of texture units being drawn.
 *
 * The value of this property is set by the disableUnusedTextureUnits method, which is invoked
 * by the node's material, and is then consumed by the mesh when binding texture coordinates.
 */
@property(nonatomic, readonly) GLuint textureUnitCount;

/**
 * Returns the value to use for the next texture sampler that does not have an corresponding
 * texture in the current material.
 *
 * This property is accessed whenever the current material has fewer textures than texture
 * samplers declared in the shader program, and is accessed once for each of the surplus shader
 * program texture samplers (both 2D and cube-map samplers), in order to assign them a value
 * that is not already consumed by a valid texture from the material.
 *
 * As each material is drawn, the value of this property starts at the value of the
 * textureUnitCount property, and then increments by one each time this property is accessed.
 */
@property(nonatomic, readonly) GLuint nextUnassignedTextureSampler;

/**
 * This property gives the interval, in seconds, since the previous frame.
 *
 * See the description of the CC3Scene minUpdateInterval and maxUpdateInterval properties
 * for more information about clamping the update interval.
 */
@property(nonatomic, assign) ccTime deltaTime;

/**
 * Indicates whether nodes should decorate themselves with their configured material, textures,
 * or color arrays. In most cases, nodes should be drawn decorated. However, specialized visitors
 * may turn off normal decoration drawing in order to do specialized coloring instead.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldDecorateNode;

/**
 * Indicates whether this visitor is rendering an environment map to a texture.
 *
 * Environment maps typically do not require full detail. This property can be used during
 * drawing to make optimization decisions such as to avoid drawing certain more complex
 * content when creating an environment map.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL isDrawingEnvironmentMap;

/**
 * Draws the specified node. Invoked by the node itself when the node's local
 * content is to be drawn.
 *
 * This implementation first caches the current lighting enablement state in case
 * lighting is turned off during drawing of the material, then it double-dispatches
 * back to the node's drawWithVisitor: method to perform the drawing. Finally, this
 * implementation updates the drawing performance statistics.
 *
 * Subclass may override to enhance or modify this behaviour.
 */
-(void) draw: (CC3Node*) aNode;


#pragma mark Accessing scene content

/**
 * The rendering surface to which this visitor is rendering.
 *
 * The surface will be activated at the beginning of each visitation run.
 *
 * If not set beforehand, this property will be initialized to the value of the 
 * defaultRenderSurface property the first time it is accessed.
 *
 * This property is is not cleared at the end of the visitation run. It is retained so that
 * this visitor can be used to render multiple node assemblies and complete multiple drawing
 * passes without having to set the surface each time.
 */
@property(nonatomic, retain) id<CC3RenderSurface> renderSurface;

/**
 * Template property that returns the initial value of the renderSurface property.
 *
 * This implementation returns the scene's viewSurface. Since it relies on the scene property
 * haveing a value, this property will be nil unless a visitation run is in progress.
 *
 * Subclasses may override to return a different surface.
 */
@property(nonatomic, readonly) id<CC3RenderSurface> defaultRenderSurface;

/**
 * During the drawing of nodes that use vertex skinning, this property holds the skin
 * section that is currently being drawn.
 *
 * The value of this property is set by the skin section itself and is only valid
 * during the drawing of that skin section.
 */
@property(nonatomic, assign) CC3SkinSection* currentSkinSection;

/**
 * The currently active shader program.
 *
 * This property is set automatically by the program when it binds to the GL engine.
 */
@property(nonatomic, assign) CC3ShaderProgram* currentShaderProgram;

/**
 * The current color used during drawing if no materials or lighting are engaged.
 *
 * Each of the RGBA components of this color are floating point values between 0 and 1.
 */
@property(nonatomic, assign) ccColor4F currentColor;

/**
 * The current color used during drawing if no materials or lighting are engaged.
 *
 * Each of the RGBA components of this color are integer values between 0 and 255.
 */
@property(nonatomic, assign) ccColor4B currentColor4B;


#pragma mark Environmental matrices

/** Returns the current projection matrix. */
@property(nonatomic, readonly) CC3Matrix4x4* projMatrix;

/** Returns the current view matrix. */
@property(nonatomic, readonly) CC3Matrix4x3* viewMatrix;

/** Returns the current model-to-global transform matrix. */
@property(nonatomic, readonly) CC3Matrix4x3* modelMatrix;

/** Returns the current view-projection matrix. */
@property(nonatomic, readonly) CC3Matrix4x4* viewProjMatrix;

/** Returns the current model-view matrix. */
@property(nonatomic, readonly) CC3Matrix4x3* modelViewMatrix;

/** Returns the current model-view-projection matrix. */
@property(nonatomic, readonly) CC3Matrix4x4* modelViewProjMatrix;

/**
 * Populates the current projection matrix from the specified matrix.
 *
 * This method is invoked automatically when the camera property is set.
 */
-(void) populateProjMatrixFrom: (CC3Matrix*) projMtx;

/**
 * Populates the current view matrix from the specified matrix.
 *
 * This method is invoked automatically when the camera property is set.
 */
-(void) populateViewMatrixFrom: (CC3Matrix*) viewMtx;

/** Populates the current model-to-global matrix from the specified matrix. */
-(void) populateModelMatrixFrom: (CC3Matrix*) modelMtx;

@end


#pragma mark -
#pragma mark CC3NodePickingVisitor

/**
 * CC3NodePickingVisitor is a CC3NodeDrawingVisitor that is passed to a node when
 * it is visited during node picking operations using color-buffer based picking.
 *
 * The visit: method must be invoked with a CC3Scene instance as the argument.
 *
 * Node picking is the act of picking a 3D node from user input, such as a touch.
 * One method of accomplishing this is to draw the scene such that each object is
 * drawn in a unique solid color. Once the scene is drawn, the color of the pixel
 * that has been touched can be read from the OpenGL ES color buffer, and mapped
 * back to the object that was painted with that color.
 */
@interface CC3NodePickingVisitor : CC3NodeDrawingVisitor {
	CC3Node* _pickedNode;
}

/** The node that was most recently picked. */
@property(nonatomic, readonly) CC3Node* pickedNode;

@end


#pragma mark -
#pragma mark CC3NodePuncture

/** Helper class for CC3NodePuncturingVisitor that tracks a node and the location of its puncture. */
@interface CC3NodePuncture : NSObject {
	CC3Node* _node;
	CC3Vector _punctureLocation;
	CC3Vector _globalPunctureLocation;
	float _sqGlobalPunctureDistance;
}

/** The punctured node. */
@property(nonatomic, retain, readonly) CC3Node* node;

/** The location of the puncture, in the local coordinate system of the punctured node. */
@property(nonatomic, readonly) CC3Vector punctureLocation;

/** The location of the puncture, in the global coordinate system. */
@property(nonatomic, readonly) CC3Vector globalPunctureLocation;

/**
 * The square of the distance from the startLocation of the ray to the puncture.
 * This is used to sort the punctures by distance from the start of the ray.
 */
@property(nonatomic, readonly) float sqGlobalPunctureDistance;


#pragma mark Allocation and initialization

/** Initializes this instance with the specified node and ray. */
-(id) initOnNode: (CC3Node*) aNode fromRay: (CC3Ray) aRay;

/** Allocates and initializes an autoreleased instance with the specified node and ray. */
+(id) punctureOnNode: (CC3Node*) aNode fromRay: (CC3Ray) aRay;

@end


#pragma mark -
#pragma mark CC3NodePuncturingVisitor

/**
 * CC3NodePuncturingVisitor is a CC3NodeVisitor that is used to collect nodes
 * that are punctured (intersected) by a global ray.
 *
 * For example, you can use the CC3Camera unprojectPoint: method to convert a 2D touch point
 * into a CC3Ray that projects into the 3D scene from the center of the camera. All objects
 * that lie visually below the touch point will be punctured by that projected ray.
 *
 * Or, you may want to know which nodes lie under a targetting reticle, or have been hit by
 * the path of a bullet.
 * 
 * To find the nodes that are punctured by a global CC3Ray, create an instance of this class,
 * and invoke the visit: method on that instance, passing the CC3Scene as the argument. You can
 * also invoke the visit: method with a particular structural node, instead of the full CC3Scene,
 * to limit the range of nodes to inspect (for example, to determine which object in a room, but
 * not outside the room, was hit by a bullet), for design or performance reasons.
 *
 * The visitor will collect the nodes that are punctured by the ray, in order of distance from
 * the startLocation of the CC3Ray. You can access the nodes and the puncture locations using the
 * closestPuncturedNode, punctureNodeAt: closestPunctureLocation, and punctureLocationAt: methods.
 *
 * Only nodes that have a bounding volume will be tested by this visitor. Nodes without a bounding
 * volume, or whose shouldIgnoreRayIntersection property is set to YES will be ignored by this visitor.
 *
 * The shouldPunctureFromInside property can be used to include or exclude nodes where the start
 * location of the ray is within its bounding volume. 
 *
 * To save instantiating a CC3NodePuncturingVisitor each time, you can reuse the visitor instance
 * over and over, through different invocations of the visit: method.
 */
@interface CC3NodePuncturingVisitor : CC3NodeVisitor {
	CCArray* _nodePunctures;
	CC3Ray _ray;
	BOOL _shouldPunctureFromInside : 1;
	BOOL _shouldPunctureInvisibleNodes : 1;
}

/**
 * Indicates whether the visitor should consider the ray to intersect a node's
 * bounding volume if the ray starts within the bounding volume of the node.
 *
 * The initial value of this property is NO, indicating that the visitor
 * will not collect punctures for any node where the ray starts within
 * the bounding volume of that node.
 *
 * This initial value makes sense for the common use of using the ray to pick
 * nodes from a touch, as, when the camera is within a node, that node will
 * not be visible. However, if you have a character within a room, and you
 * want to know where in the room a thrown object hits the walls, you might
 * want to set this property to YES to collect nodes that are punctured from
 * the inside as well as from the outside.
 */
@property(nonatomic, assign) BOOL shouldPunctureFromInside;

/**
 * Indicates whether the visitor should include those nodes that are not
 * visible (whose visible property returns NO), when collecting the nodes
 * whose bounding volumes are punctured by the ray.
 *
 * The initial value of this property is NO, indicating that invisible
 * nodes will be ignored by this visitor.
 */
@property(nonatomic, assign) BOOL shouldPunctureInvisibleNodes;

/**
 * The ray that is to be traced, specified in the global coordinate system.
 *
 * This property is set on initialization, but you may set it to another
 * ray when reusing the same visitor on more than one visitation.
 */
@property(nonatomic, assign) CC3Ray ray;

/** The number of nodes that were punctured by the ray. */
@property(nonatomic, readonly) NSUInteger nodeCount;

/**
 * Returns the node punctured by the ray that is closest to the startLocation
 * of the ray, or nil if the ray intersects no nodes.
 *
 * The result will not include any node that does not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
@property(nonatomic, readonly) CC3Node* closestPuncturedNode;

/**
 * Returns the location of the puncture on the node returned by the
 * closestPuncturedNode property, or kCC3VectorNull if the ray intersects no nodes.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the local
 * coordinate system of the node.
 *
 * The result will not include any node that does not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
@property(nonatomic, readonly) CC3Vector closestPunctureLocation;

/**
 * Returns the location of the puncture on the node returned by the
 * closestPuncturedNode property, or kCC3VectorNull if the ray intersects no nodes.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the global
 * coordinate system.
 */
@property(nonatomic, readonly) CC3Vector closestGlobalPunctureLocation;

/**
 * Returns the node punctured by the ray at the specified order index,
 * which must be between zero and nodeCount minus one, inclusive.
 *
 * When multiple nodes are punctured by the ray, they can be accessed
 * using the specified positional index, with the order determined by
 * the distance from the startLocation of the ray to the global location
 * of the puncture for each node. The index zero represents the node
 * whose puncture is globally closest to the startLocation of the ray.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
-(CC3Node*) puncturedNodeAt: (NSUInteger) index;

/**
 * Returns the location of the puncture on the node returned by the
 * puncturedNodeAt: method. The specified index must be between zero
 * and nodeCount minus one, inclusive.
 *
 * When multiple nodes are punctured by the ray, the location of the
 * puncture on each can be accessed using the specified positional index,
 * with the order determined by the distance from the startLocation of
 * the ray to the global location of the puncture for each node. The
 * index zero represents the node whose puncture is globally closest
 * to the startLocation of the ray.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the local
 * coordinate system of the node.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
-(CC3Vector) punctureLocationAt: (NSUInteger) index;

/**
 * Returns the location of the puncture on the node returned by the
 * puncturedNodeAt: method. The specified index must be between zero
 * and nodeCount minus one, inclusive.
 *
 * When multiple nodes are punctured by the ray, the location of the
 * puncture on each can be accessed using the specified positional index,
 * with the order determined by the distance from the startLocation of
 * the ray to the global location of the puncture for each node. The
 * index zero represents the node whose puncture is globally closest
 * to the startLocation of the ray.
 *
 * The returned location is on the bounding volume of the node (or tightest
 * bounding volume if the node is using a composite bounding volume such as
 * CC3NodeTighteningBoundingVolumeSequence), and is specified in the local
 * coordinate system of the node.
 *
 * The results will not include nodes that do not have a bounding volume,
 * or whose shouldIgnoreRayIntersection property is set to YES.
 */
-(CC3Vector) globalPunctureLocationAt: (NSUInteger) index;


#pragma mark Allocation and initialization

/**
 * Initializes this instance with the specified ray,
 * which is specified in the global coordinate system.
 */
-(id) initWithRay: (CC3Ray) aRay;

/**
 * Allocates and initializes an autoreleased instance with the specified ray,
 * which is specified in the global coordinate system.
 */
+(id) visitorWithRay: (CC3Ray) aRay;

@end
