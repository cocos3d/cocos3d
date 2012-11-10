/*
 * CC3MeshParticles.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3Particles.h"


#pragma mark -
#pragma mark CC3MeshParticleProtocol

/**
 * CC3MeshParticleProtocol defines the requirements for mesh particles that are emitted
 * and managed by the CC3MeshParticleEmitter class.
 *
 * Each mesh particle is comprised of an individual mesh. Like any mesh, a mesh particle
 * represents a true 3D object that can have length, width and depth, can be moved, rotated
 * and scaled, and can be colored and covered with a texture.
 *
 * Each mesh particle uses a CC3VertexArrayMesh as a template. But, because it is a particle,
 * this basic mesh template is copied into the mesh arrays of the CC3MeshParticleEmitter, where
 * it is merged with the meshes of the other particles managed by the emitter, and is submitted
 * to the GL engine in a single draw call.
 *
 * Like mesh nodes, mesh particles may be transformed (moved, rotated & scaled). However, unlike
 * mesh nodes, the vertices of a mesh particle are transformed by the CPU in application memory,
 * and the transformed vertices are drawn without further individual transformation by the GPU.
 *
 * Mesh particles are transformed by the emitter through the transformVertices method on the particle.
 * This method is invoked automatically by the emitter when a particle has been changed, and the mesh
 * particle implementation defines what type of transform occurs when this method is invoked.
 *
 * This creates a trade-off, where, relative to mesh nodes, the GPU rendering performance is
 * dramatically improved for large numbers of mesh particles, but the CPU load is increased
 * when mesh particles are constantly being transformed, particularly for larger meshes.
 *
 * Relative to mesh nodes, mesh particles work best when there are many small meshes that are
 * transfomed slowly, where the benefit of drawing in a single call outweighs the cost of 
 * processing the vertices in the CPU. For larger meshes, it is more effective to use mesh nodes,
 * where the transformations can be carried out by the GPU.
 *
 * See the notes of the CC3MeshParticleEmitter class for more info.
 */
@protocol CC3MeshParticleProtocol <CC3CommonVertexArrayParticleProtocol>

/**
 * The CC3VertexArrayMesh used as a template for the mesh of this particle.
 *
 * This particle uses the vertices of this mesh as a starting point. The vertices for the particle
 * are copied into the underlying common mesh that supports all particles emitted by a single emitter.
 * The particle can then manipulate its own copy of the vertices, and can have its own locations,
 * rotations, vertex colors and texture coordinates.
 *
 * For particles created outside the emitter, and added to the emitter with the emitParticle:
 * method, this property can be set directly by the application to define the mesh of this particle.
 * For particles created within the emitter, and emitted automatically, or via the emitParticle
 * method, this property will be assigned by the emitter, usually from a pre-defined template mesh.
 */
@property(nonatomic, retain) CC3VertexArrayMesh* templateMesh;

/**
 * Returns the index offset, in the underlying mesh vertex arrays, of the first vertex of this particle.
 *
 * This offset can be used to access content directly within the underlying mesh vertex arrays.
 */
@property(nonatomic, assign) GLuint firstVertexOffset;

/**
 * Returns the index offset, in the underlying mesh vertex index array, of the first vertex index
 * of this particle.
 *
 * This offset can be used to access the vertex indices directly within the underlying mesh vertex
 * index array.
 *
 * If the underlying mesh is not using indexed vertices, this property will be set to the same value
 * as the firstVertexOffset property.
 */
@property(nonatomic, assign) GLuint firstVertexIndexOffset;

/**
 * Transforms the vertices of this particle.
 *
 * For each emitter, all particles are submitted to the GL engine in a single draw call.
 * This means that all vertices for all particles from that emitter will use the same GL
 * transform matrix, which is defined by the transformation properties of the emitter.
 *
 * To allow each mesh particle to be transformed independently, the vertices for each particle
 * must be transformed in memory by the CPU.
 *
 * This method is invoked automatically on any particle that has been updated, when the emitter
 * is transformed. Usually the application never needs to invoke this method directly.
 */
-(void) transformVertices;

@end


#pragma mark -
#pragma mark CC3MeshParticleEmitter

/**
 * CC3MeshParticleEmitter emits particles that conform to the CC3MeshParticleProtocol protocol.
 * 
 * Each mesh particle is comprised of an individual mesh. Like any mesh, a mesh particle
 * represents a true 3D object that can have length, width and depth, can be moved, rotated
 * and scaled, and can be colored and covered with a texture.
 *
 * Each mesh particle uses a CC3VertexArrayMesh as a template. But, because it is a particle,
 * this basic mesh template is copied into the mesh arrays of the CC3MeshParticleEmitter, where
 * it is merged with the meshes of the other particles managed by the emitter, and is submitted
 * to the GL engine in a single draw call.
 *
 * Like mesh nodes, mesh particles may be transformed (moved, rotated & scaled). However, unlike
 * mesh nodes, the vertices of a mesh particle are transformed by the CPU in application memory,
 * and the transformed vertices are drawn without further individual transformation by the GPU.
 *
 * Mesh particles are transformed by this emitter through the transformVertices method on the particle.
 * This method is invoked automatically by the emitter when a particle has been changed, and the mesh
 * particle implementation defines what type of transform occurs when this method is invoked.
 *
 * This creates a trade-off, where, relative to mesh nodes, the GPU rendering performance is
 * dramatically improved for large numbers of mesh particles, but the CPU load is increased
 * when mesh particles are constantly being transformed, particularly for larger meshes.
 *
 * Relative to mesh nodes, mesh particles work best when there are many small meshes that are
 * transfomed slowly, where the benefit of drawing in a single call outweighs the cost of 
 * processing the vertices in the CPU. For larger meshes, it is more effective to use mesh nodes,
 * where the transformations can be carried out by the GPU.
 *
 * Each mesh particle added to or emitted by this mesh emitter uses a CC3VertexArrayMesh as a
 * template. For particles created by the application outside the emitter, and added to the emitter
 * with the emitParticle: method, the application can directly set the templateMesh property of the
 * mesh particle prior to invoking the emitParticle: method of this emitter. With this technique,
 * each particle can use a different mesh template, and so each paticle can be a different shape.
 * If the templateMesh property of a particle submitted to the emitParticle: method is nil, this
 * emitter will assign the template mesh in the particleTemplateMesh property to the particle.
 *
 * For particles created within the emitter, and emitted automatically, or via the emitParticle
 * method, each particle will be assigned the template mesh specified in the particleTemplateMesh
 * property of this emitter. In this scenario, each particle will be the same shape. Subclasses,
 * such as CC3MultiTemplateMeshParticleEmitter, can extend this functionality to allow particles
 * that are automatically emitted to be assigned a template mesh that is randomly selected from
 * a collection of template meshes.
 *
 * Because all particles managed by this emitter are drawn with a single GL draw call, all
 * particles added to or emitted by this emitter are covered by the same material and texture.
 *
 * However, you can assign a different color to each particle by configuring this emitter to
 * use vertex color content by including the kCC3VertexContentColor component when setting the
 * vertexContentTypes property of this emitter.
 *
 * Similarly, if the vertexContentTypes property of this emitter includes the
 * kCC3VertexContentTextureCoordinates component, then the particles will be covered by a
 * texture. By assigning the texture coordinates of each particle to different sections of
 * the texture assigned to this emitter, each particle can effectively be textured separately.
 *
 * All memory used by the particles and the underlying vertex mesh is managed by the
 * emitter node, and is deallocated automatically when the emitter is released.
 */
@interface CC3MeshParticleEmitter : CC3CommonVertexArrayParticleEmitter {
	CC3VertexArrayMesh* particleTemplateMesh;
	BOOL isParticleTransformDirty : 1;
	BOOL shouldNotTransformInvisibleParticles : 1;
}

/**
 * The mesh used as a template for the mesh of each particle emitted automatically by this emitter.
 * Each particle created within the emitter, and emitted automatically, or via the emitParticle
 * method, will be assigned the template mesh specified in this property.
 *
 * When a particle is created by the application outside the emitter, and submitted to the emitter
 * via the emitParticle: method, the application can assign a different template mesh to it via
 * the templateMesh property of the particle, before invoking the emitParticle: method.
 *
 * However, when using the emitParticle: method, the application does not have to assign a template mesh
 * directly. If the templateMesh property of a particle submitted to the emitParticle: method is nil,
 * this emitter will assign the template mesh in this particleTemplateMesh property to the particle.
 *
 * Each particle emitted by this emitter uses the vertices of this mesh as a starting point,
 * however, each particle has access to its own copy of its mesh vertices. In this way, different
 * particles can have different locations, rotations, vertex colors and texture coordinates.
 *
 * If the value of the vertexContentTypes property of this emitter have not yet been set, that
 * property is set to the value of the vertexContentTypes property of the specified particle
 * template mesh. Therefore, by default, the particles of this emitter will contain the same
 * vertex content types as this template mesh.
 *
 * This emitter can be configured with vertex content types that are different than the template
 * mesh, by setting the value of the vertexContentTypes property of this emitter explicitly.
 * When vertex content is copied from the template mesh to a particle, vertex content types
 * that do not appear in this mesh will be ignored, and particle content for content types not
 * available in the template mesh will be given default values, and can be set during initializaton
 * of each particle. For example, if the particle template mesh does not contain individual vertex
 * color information, you can still define color as vertex content type for this emitter,
 * and set the color of each particle when it is initialized.
 *
 * This property must be set prior to this emitter emitting any particles. It is possible to
 * change the value of this property during emission.
 */
@property(nonatomic, retain) CC3VertexArrayMesh* particleTemplateMesh;

/**
 * A write-only property that configures this emitter to emit particles as defined by the
 * specified template mesh node.
 *
 * This is a convenience write-only property method that simply sets the particleTemplateMesh
 * and material properties (including the texture) of this emitter from the corresponding mesh
 * and material properties of the specified mesh node.
 *
 * When these properties are set, the template mesh is simply retained, but the template material
 * is copied, so that the material of the emitter can be configured independently from that of
 * the template mesh node.
 *
 * The mesh property of the particleTemplate mesh node must be a type of CC3VertexArrayMesh,
 * otherwise an assertion error will be thrown.
 *
 * Since this property is a convenience property for setting other properties, this is a
 * write-only property. Reading this property always returns nil.
 */
@property(nonatomic, assign) CC3MeshNode* particleTemplate;

/**
 * Template method that sets the templateMesh property of the specified particle.
 *
 * This implementation sets the particle's templateMesh property to the mesh in the
 * particleTemplateMesh property of this emitter.
 *
 * Subclasses may override this implementation to create some other selection and assignment methodology.
 *
 * This method is invoked automatically when a particle is emitted, or the emitParticle: method is
 * invoked with a particle that does not already have a templateMesh. The application should never
 * need to invoke this method directly.
 */
-(void) assignTemplateMeshToParticle: (id<CC3MeshParticleProtocol>) aParticle;


#pragma mark Emitting particles

/**
 * Emits a single particle of the type specified in the particleClass property.
 *
 * Refer the the documentation of this method in the parent CC3ParticleEmitter class for a complete
 * description of the emission process.
 *
 * The emitted particle will be assigned the template mesh defined in the particleTemplateMesh property.
 */
-(id<CC3MeshParticleProtocol>) emitParticle;

/**
 * Adds the specified particle to the emitter and emits it.
 *
 * Refer the the documentation of this method in the parent CC3ParticleEmitter class for a complete
 * description of the emission process.
 *
 * The emitted particle will be assigned the template mesh defined in the particleTemplateMesh property.
 */
-(BOOL) emitParticle: (id<CC3MeshParticleProtocol>) aParticle;

/**
 * Returns a particle suitable for emission by this emitter. The returned particle can subsequently
 * be emitted from this emitter using the emitParticle: method.
 *
 * The particle emitted may be an existing expired particle that is being reused, or it may be a
 * newly instantiated particle. If an expired particle is available within this emitter, it will
 * be reused. If not, this method invokes the makeParticle method to create a new particle.
 *
 * The returned particle will be assigned the template mesh defined in the particleTemplateMesh property.
 * If the particle is being reused and originally had a different particle mesh, the template mesh of
 * the reused particle is replaced.
 * 
 * You can also use the makeParticle method directly to ensure that a new particle has been created.
 */
-(id<CC3MeshParticleProtocol>) acquireParticle;

/**
 * Creates a new autoreleased instance of a particle of the type specified by the particleClass property.
 * The returned particle can subsequently be emitted from this emitter using the emitParticle: method.
 *
 * The returned particle will be assigned the template mesh defined in the particleTemplateMesh property.
 *
 * Distinct from the acquireParticle method, this method bypasses the reuse of expired particles
 * and always creates a new autoreleased particle instance.
 */
-(id<CC3MeshParticleProtocol>) makeParticle;


#pragma mark Accessing particles

/** Returns the particle at the specified index within the particles array, cast as a mesh particle. */
-(id<CC3MeshParticleProtocol>) meshParticleAt: (NSUInteger) aParticleIndex;


#pragma mark Transformations

/**
 * Indicates whether particles should be transformed when the emitter is not within view of the camera.
 *
 * As particles move and rotate, their vertices are transformed. This can consume significant
 * processing when the number of particles and the complexity of the particle meshes is large.
 *
 * Setting this property to NO will stop the particles from being transformed when the bounding
 * volume of the emitter does not intersect the frustum of the camera, improving application
 * performance when the particles are offscreen. Particles will still be updated, but their
 * vertices will not be transformed until the emitter comes within the view of the camera.
 *
 * Care should be taken when setting this property to NO, because the bounding volume of an emitter
 * is calculated from the current vertices of the particles. When the particles stop being transformed,
 * under the action of this property, the bounding volume will stop being updated. Since the particles
 * are still updated even when not visible, this can cause a jarring visual effect when the emitter
 * comes back into view of the camera and the particles may seem to jump unexpectedly into space that
 * was not part of the emitter bounding volume when it previously stopped being updated. If such an
 * effect occurs and is undesirable, this property can be left set to YES so that particles will
 * continue to be transformed even when outside the view of the camera.
 *
 * When the bounding volume of the emitter is fixed, as indicated by the shouldUseFixedBoundingVolume
 * property, it is assumed that the bounding volume has already been sized to encompass all possible
 * paths of the particles. As a result, when this emitter uses a fixed bounding volume, the particles
 * are never transformed when that bounding volume is outside the view of the camera. Therefore, when
 * a fixed bounding volume is used (the shouldUseFixedBoundingVolume is set to YES), the value of
 * this property has no effect.
 *
 * The initial value of this property is YES, indicating that particles will be transformed even
 * when not visible to the camera, unless the shouldUseFixedBoundingVolume property is also set
 * to YES, indicating that emitter has a fixed bounding volume that encompasses all particles.
 */
@property(nonatomic, assign) BOOL shouldTransformUnseenParticles;

/**
 * Indicates whether any of the transform properties on any of the particles have been changed,
 * and so the vertices of the particle need to be transformed.
 *
 * This property is automatically set to YES when one of those properties have been changed on
 * any of the particles and is reset to NO once the particles have been transformed.
 *
 * Transformation of the particles occurs automatically when the emitter is transformed.
 */
@property(nonatomic, readonly) BOOL isParticleTransformDirty;

/**
 * Indicates that a particle has been transformed in some way, and that the vertices need to be
 * transformed accordingly prior to the next drawing frame.
 *
 * This method is invoked automatically whenever any of the transform properties of any particle
 * (location, rotation (including any type of rotation), or scale) are changed. Usually, the
 * application never needs to invoke this method directly.
 */
-(void) markParticleTransformDirty;

@end


#pragma mark -
#pragma mark CC3MeshParticle

/**
 * CC3MeshParticle is a standard base implementation of the CC3MeshParticleProtocol.
 *
 * CC3MeshParticle brings many of the capabilities of a CC3MeshNode to particles.
 *
 * Like mesh nodes, particles of this type can be flexibly moved, rotated and scaled, and the
 * vertices will be automatically transformed into the vertex arrays of the emitter.
 *
 * Although all particles in a single emitter must be covered by the same material and texture,
 * particles of this type may be assigned a textureRectangle, allowing each particle to use a
 * separate section of the emitter's texture, effectively texturing each particle separately.
 *
 * The individual vertices of each particle can be manipulated using the same family of vertex
 * access methods available to mesh nodes.
 */
@interface CC3MeshParticle : CC3ParticleBase <CC3MeshParticleProtocol> {
	CC3Rotator* rotator;
	CC3VertexArrayMesh* templateMesh;
	CC3Vector location;
	GLuint firstVertexOffset;
	GLuint firstVertexIndexOffset;
	BOOL _isAlive : 1;
	BOOL _isTransformDirty : 1;
	BOOL _isColorDirty : 1;
}

/**
 * The emitter that emitted this particle.
 *
 * For CC3MeshParticle, the emitter must be of type CC3MeshParticleEmitter.
 */
@property(nonatomic, assign) CC3MeshParticleEmitter* emitter;

/**
 * Returns the rotator that manages the local rotation of this particle.
 *
 * CC3Rotator is the base class of a class cluster, of which different subclasses perform
 * different types of rotation. The type of object returned by this property may change,
 * depending on what rotational changes have been made to this particle.
 *
 * For example, if no rotation is applied to this particle, this property will return a base
 * CC3Rotator. After the rotation of this node has been changed, this property will return
 * a CC3MutableRotator, and if directional properties, such as forwardDirection have been
 * accessed or changed, this property will return a CC3DirectionalRotator. The creation
 * of the type of rotator required to support the various rotations is automatic.
 */
@property(nonatomic, retain) CC3Rotator* rotator;


#pragma mark Transformation properties

/**
 * The location of this particle in the local coordinate system of the emitter.
 *
 * You can set this property in the initializeParticle and updateBeforeTransform: methods
 * to move the particle around.
 *
 * The initial value of this property, set prior to the invocation of the 
 * initializeParticle method, is kCC3VectorZero.
 */
@property(nonatomic, assign) CC3Vector location;

/**
 * Translates the location of this property by the specified vector.
 *
 * The incoming vector specify the amount of change in location, not the final location.
 */
-(void) translateBy: (CC3Vector) aVector;

/**
 * The rotational orientation of the particle in 3D space, relative to the emitter. The global
 * rotation of the particle is therefore a combination of the global rotation of the emitter
 * and the value of this rotation property. This value contains three Euler angles, defining
 * a rotation of this nodearound the X, Y and Z axes. Each angle is specified in degrees.
 *
 * Rotation is performed in Y-X-Z order, which is the OpenGL default. Depending on the nature
 * of the object you are trying to control, you can think of this order as yaw, then pitch,
 * then roll, or heading, then inclination, then tilt,
 *
 * When setting this value, each component is converted to modulo +/-360 degrees.
 *
 * Rotational transformation can also be specified using the rotationAxis and rotationAngle
 * properties, or the quaternion property. Subsequently, this property can be read to return
 * the corresponding Euler angles.
 */
@property(nonatomic, assign) CC3Vector rotation;

/**
 * Rotates this particle from its current rotational state by the specified Euler angles in degrees.
 *
 * The incoming Euler angles specify the amount of change in rotation, not the final rotational state.
 */
-(void) rotateBy: (CC3Vector) aRotation;

/**
 * The rotation of the particle in 3D space, relative to the parent of this node, expressed
 * as a quaternion.
 *
 * Rotational transformation can also be specified using the rotation property (Euler angles),
 * or the rotationAxis and rotationAngle properties. Subsequently, this property can be read
 * to return the corresponding quaternion.
 */
@property(nonatomic, assign) CC3Quaternion quaternion;

/**
 * Rotates this particle from its current rotational state by the specified quaternion.
 *
 * The incoming quaternion specifies the amount of change in rotation, not the final rotational state.
 */
-(void) rotateByQuaternion: (CC3Quaternion) aQuaternion;

/**
 * The axis of rotation of the particle in 3D space, relative to the emitter, expressed as
 * a directional vector. This axis can be used in conjunction with the rotationAngle property
 * to describe the rotation as a single angular rotation around an arbitrary axis.
 *
 * Under the identity rotation (no rotation), the rotationAngle is zero and the rotationAxis
 * is undefined. Under that condition, this property will return the zero vector kCC3VectorZero.
 *
 * Rotational transformation can also be specified using the rotation property (Euler
 * angles), or the quaternion property. Subsequently, this property can be read to return
 * the corresponding axis of rotation.
 */
@property(nonatomic, assign) CC3Vector rotationAxis;

/**
 * The angular rotation around the axis specified in the rotationAxis property.
 *
 * When setting this value, it is converted to modulo +/-360 degrees. When reading this
 * value after making changes using rotateByAngle:aroundAxis:, or using another rotation
 * property, the value of this property will be clamped to +/-180 degrees.
 *
 * For example, if current rotation is 170 degrees around the rotationAxis, invoking
 * the rotateByAngle:aroundAxis: method using the same rotation axis and 20 degrees,
 * reading this property will return -170 degrees, not 190 degrees.
 *
 * Rotational transformation can also be specified using the rotation property (Euler
 * angles), or the quaternion property. Subsequently, this property can be read to
 * return the corresponding angle of rotation.
 */
@property(nonatomic, assign) GLfloat rotationAngle;

/**
 * Rotates this particle from its current rotational state by rotating around
 * the specified axis by the specified angle in degrees.
 *
 * The incoming axis and angle specify the amount of change in rotation, not the final rotational state.
 *
 * Thanks to cocos3d user nt901 for contributing to the development of this feature
 */
-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis;

/**
 * The direction in which this particle is pointing.
 *
 * The value of this property is specified in the local coordinate system of this particle.
 *
 * The initial value of this property is kCC3VectorUnitZPositive, pointing down the positive
 * Z-axis in the local coordinate system of this particle. When this particle is rotated, the
 * original positive-Z axis of the node's local coordinate system will point in this direction.
 *
 * Pointing the particle in a particular direction does not fully define its rotation in 3D space,
 * because the particle can be oriented in any rotation around the axis along the forwardDirection
 * vector (think of pointing a camera at a scene, and then rotating the camera along the axis
 * of its lens, landscape towards portrait).
 *
 * The orientation around this axis is defined by specifying an additional 'up' direction, which
 * fixes the rotation around the forwardDirection by specifying which direction is considered to
 * be 'up'. The 'up' direction is specified by setting the referenceUpDirection property, which
 * is independent of the tilt of the local axes, and does not need to be perpendicular to the
 * forwardDirection.
 *
 * The value returned for this property is of unit length. When setting this
 * property, the value will be normalized to be a unit vector.
 *
 * A valid direction vector is required. Attempting to set this property
 * to the zero vector (kCC3VectorZero) will raise an assertion error.
 */
@property(nonatomic, assign) CC3Vector forwardDirection;

/**
 * The direction that is considered to be 'up' when rotating to face in a particular direction,
 * by using one of the directional properties forwardDirection, target, or targetLocation.
 *
 * As explained in the note for the forwardDirection, specifying a forwardDirection alone is not
 * sufficient to determine the rotation of a particle in 3D space. This property indicates which
 * direction should be considered 'up' when orienting the rotation of the particle to face a
 * direction, target, or target location.
 * 
 * The interpretation of whether the value of this property is specified in local or global
 * coordinates depends on how the direction of pointing is being specified. 
 *
 * When using the forwardDirection property, the value of this property is taken to be specified
 * in the local coordinate system. When using either the target or targetLocation properties,
 * the interpretation of whether the value of this property is specified in the local or global
 * coordinate system is determined by the value of the targettingConstraint property.
 *
 * The initial value of this property is kCC3VectorUnitYPositive, pointing parallel
 * to the positive Y-axis, and in most cases, this property can be left with that value.
 *
 * The value returned is of unit length. When setting this property, the value will be normalized
 * to be a unit vector.
 *
 * When setting this property, a valid direction vector is required. Attempting to set this
 * property to the zero vector (kCC3VectorZero) will raise an assertion error.
 */
@property(nonatomic, assign) CC3Vector referenceUpDirection;

/**
 * The direction, in the particle's coordinate system, that is considered to be 'up'.
 * This corresponds to the referenceUpDirection, after it has been transformed by the rotations
 * of this particle. For example, rotating the particle upwards to point towards an elevated
 * target will move the upDirection of this particle away from the referenceUpDirection.
 *
 * The value returned by this property is in the local coordinate system of this particle.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector upDirection;

/**
 * The direction in the particle's coordinate system that would be considered to be "off to the right"
 * when looking out from the particle, along the forwardDirection and with the upDirection defined.
 *
 * The value returned by this property is in the local coordinate system of this particle.
 *
 * The value returned is of unit length. 
 */
@property(nonatomic, readonly) CC3Vector rightDirection;


#pragma mark Texture support

/**
 * Sets the texture rectangle of this particle, for all texture units.
 *
 * This property facilitates the use of sprite-sheets, where the mesh is covered by a small
 * fraction of a larger texture.
 *
 * Setting this property adjusts the texture coordinates of this particle so that they
 * map to the specified texture rectangle within the bounds of the texture.
 *
 * The texture rectangle applied here takes into consideration the textureRectangle
 * property of the particleTemplateMesh, and the mapSize of the texture itself.
 *
 * See the notes for this same property on CC3MeshNode and CC3Mesh for more information
 * about applying texture rectangles to meshes.
 *
 * Once applied, the value of this property is not retained, and reading this property
 * returns a null rectangle. Subclasses may override to cache the value of this property.
 */
@property(nonatomic, assign) CGRect textureRectangle;

/**
 * Sets the texture rectangle of this particle, for the specified texture unit.
 *
 * See the notes for the textureRectangle property of this class, for an explanation
 * of the use of this property.
 */
-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit;


#pragma mark Accessing vertex data

/**
 * Returns the location element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying vertex content.
 * If the dimensionality is 2, the returned vector will contain zero in the Z component.
 */
-(CC3Vector) vertexLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying vertex content.
 * If the dimensionality is 2, the Z component of the specified vector will be ignored. If the
 * dimensionality is 4, the specified vector will be converted to a 4D vector, with the W component
 * set to one, before storing.
 */
-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index;

/**
 * Returns the location element at the specified index in the underlying vertex content,
 * as a four-dimensional location in the 4D homogeneous coordinate space.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying vertex
 * content. If the dimensionality is 3, the returned vector will contain one in the W component.
 * If the dimensionality is 2, the returned vector will contain zero in the Z component and one
 * in the W component.
 */
-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index;

/**
 * Sets the location element at the specified index in the underlying vertex content
 * to the specified four-dimensional location in the 4D homogeneous coordinate space.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 *
 * This implementation takes into consideration the dimensionality of the underlying vertex content.
 * If the dimensionality is 3, the W component of the specified vector will be ignored. If the
 * dimensionality is 2, both the W and Z components of the specified vector will be ignored.
 */
-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index;

/**
 * Returns the normal element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(CC3Vector) vertexNormalAt: (GLuint) index;

/**
 * Sets the normal element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index;

/**
 * Returns the color element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(ccColor4F) vertexColor4FAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index;

/**
 * Returns the color element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(ccColor4B) vertexColor4BAt: (GLuint) index;

/**
 * Sets the color element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex content
 * at the specified texture unit index.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex content,
 * at the specified texture unit index, to the specified texture coordinate value.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index;

/**
 * Returns the texture coordinate element at the specified index from the vertex content
 * at the commonly used texture unit zero.
 *
 * This is a convenience method that is equivalent to invoking the
 * vertexTexCoord2FForTextureUnit:at: method, with zero as the texture unit index.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index;

/**
 * Sets the texture coordinate element at the specified index in the vertex content,
 * at the commonly used texture unit zero, to the specified texture coordinate value.
 *
 * This is a convenience method that delegates to the setVertexTexCoord2F:forTextureUnit:at:
 * method, passing in zero for the texture unit index.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. The implementation takes into consideration whether the
 * vertex content is interleaved to access the correct vertex data component.
 */
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index;

/**
 * Returns the index element at the specified index from the vertex content.
 *
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh.
 *
 * Similarly, the returned vertex index is relative to the content of this particle, not the
 * entire underlying mesh.
 */
-(GLuint) vertexIndexAt: (GLuint) index;

/**
 * Sets the index element at the specified index in the vertex content to the specified value.
 * 
 * The index refers to vertices, not bytes, and is relative to the content of this particle,
 * not the entire underlying mesh. Similarly, the vertexIndex is relative to the content of
 * this particle, not the entire underlying mesh.
 */
-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index;

/** Indicates whether this particle contains vertex location content. */
@property(nonatomic, readonly) BOOL hasVertexLocations;

/** Indicates whether this particle contains vertex normal content. */
@property(nonatomic, readonly) BOOL hasVertexNormals;

/** Indicates whether this particle contains vertex color content. */
@property(nonatomic, readonly) BOOL hasVertexColors;

/** Indicates whether this particle contains vertex texture coordinate content. */
@property(nonatomic, readonly) BOOL hasVertexTextureCoordinates;


#pragma mark Transformations

/**
 * Indicates whether any of the transform properties, location, rotation, or scale
 * have been changed, and so the vertices of this particle need to be transformed.
 *
 * This property is automatically set to YES when one of those properties have been
 * changed, and is reset to NO once the particle vertices have been transformed.
 *
 * Transformation of the vertices occurs automatically when the emitter is transformed.
 */
@property(nonatomic, readonly) BOOL isTransformDirty;

/**
 * Indicates that the particle has been transformed in some way, and that the vertices need to be
 * transformed accordingly prior to the next drawing frame.
 *
 * This method is invoked automatically whenever any of the transform properties of this particle
 * (location, rotation (including any type of rotation), or scale) has been changed. Usually, the
 * application never needs to invoke this method directly.
 */
-(void) markTransformDirty;

/**
 * Transforms the vertices of this particle.
 *
 * For an  emitter, all particles are submitted to the GL engine in a single draw call.
 * This means that all vertices for all particles from that emitter will use the same GL
 * transform matrix, which is defined by the transformation properties of the emitter.
 *
 * To allow each mesh particle to be transformed independently, the vertices for each particle
 * must be transformed in memory by the CPU.
 *
 * This method is invoked automatically on each particle when the emitter is transformed.
 *
 * This implementation checks the isTransformDirty property to see if this particle has been moved,
 * rotated, or scaled since the previous transform. If so, this method traverses the vertices in
 * this particle, transforming each vertex according to the transformation properties (location,
 * rotation and scale) of this particle.
 *
 * If neither rotation or scaling has been applied to this particle, this implementation performs
 * an optimized translation of the vertex locations only. If rotation has been applied to this
 * particle as well, then the locations of the vertices are generally transformed using the location,
 * rotation and scaling transformations that have been applied to this particle, and the normals of
 * the vertices are rotated using the rotation applied to this particle.
 *
 * After the vertex locations have been transformed, this method also invokes the transformVertexColors
 * method to update the colors of the individual vertices of this particle if individual particle and
 * vertex colors are supported by the emitter.
 *
 * If your particles have specialized transformation requirements, or can be optimized in some 
 * other way, you can override this method to transform the vertices of this particle differently.
 * You should check the value of the isTransformDirty property before doing any work, and you should
 * set the value of that property to NO after the vertices have been transformed.
 *
 * This method is invoked automatically on any particle that has been updated, when the emitter
 * is transformed. Usually the application never needs to invoke this method directly.
 */
-(void) transformVertices;

/**
 * Indicates whether the color of this particle has been changed, and so the vertices of this
 * particle need to be updated with the new color.
 *
 * This property is automatically set to YES when any of the color properties (color, opacity, color4f,
 * color4B) has been changed, and is reset to NO once the particle vertices have been transformed.
 *
 * Transformation of the vertices occurs automatically when the emitter is transformed.
 */
@property(nonatomic, readonly) BOOL isColorDirty;

/**
 * Indicates that the color of the particle has been changed, and that the vertices need to be
 * transformed accordingly prior to the next drawing frame.
 *
 * This method is invoked automatically whenever any of the color properties (color, opacity, color4f,
 * color4B) has been changed. Usually, the application never needs to invoke this method directly.
 */
-(void) markColorDirty;

/**
 * Template method that transforms the color of each of the vertices of this particle.
 *
 * This implementation checks the isColorDirty property to determine if this particle has been colored
 * since the previous transform. If so, this method traverses the vertices in this particle, copying
 * the color into each vertex.
 *
 * This method is invoked automatically from the transformVertices method of any particle whose color
 * has been updated by setting one of the color properties (color, opacity, color4f, color4B).
 */
-(void) transformVertexColors;

@end


#pragma mark -
#pragma mark CC3ScalableMeshParticle

/** 
 * CC3ScalableMeshParticle is a type of CC3MeshParticle that can be scaled.
 *
 * This clas is distinct from CC3MeshParticle so that mesh particle that do not require
 * scaling do not have to carry storage for scaling information.
 */
@interface CC3ScalableMeshParticle : CC3MeshParticle {
	CC3Vector scale;
}

/**
 * The scale of the particle in each dimension, relative to the emitter.
 *
 * Unless non-uniform scaling is needed, it is recommended that you use the uniformScale property instead.
 */
@property(nonatomic, assign) CC3Vector scale;

/**
 * The scale of the particle, uniform in each dimension, relative to the emitter.
 *
 * Unless non-uniform scaling is needed, it is recommended that you use this property instead
 * of the scale property.
 *
 * If non-uniform scaling is applied via the scale property, this uniformScale property will
 * return the length of the scale property vector divided by the length of a unit cube (sqrt(3.0)),
 * as an approximation of the overall scaling condensed to a single scalar value.
 */
@property(nonatomic, assign) GLfloat uniformScale;

/** Indicates whether current local scaling (via the scale property) is uniform along all axes. */
@property(nonatomic, readonly) BOOL isUniformlyScaledLocally;


#pragma mark Transformations

/**
 * Returns whether the current transform applied to this particle is rigid.
 *
 * A rigid transform contains only rotation and translation transformations and does not include
 * any scaling transformation. For the transform to be rigid, this particle must have unity scaling.
 */
@property(nonatomic, readonly) BOOL isTransformRigid;

@end
