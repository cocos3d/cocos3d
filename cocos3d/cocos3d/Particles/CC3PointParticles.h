/*
 * CC3PointParticles.h
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
#import "CC3VertexArrayMesh.h"
#import "CC3Camera.h"


#pragma mark -
#pragma mark CC3PointParticleProtocol

/**
 * CC3PointParticleProtocol defines the requirements for point particles that are emitted
 * and managed by the CC3PointParticleEmitter class.
 *
 * Relative to mesh particles, point particles are extremely efficient and performance-friendly,
 * since they comprise only a single vertex per particle, and do not need to be transformed.
 * However, they are limited in that they can comprise only a single rectangular 2D texture.
 *
 * Point particles can be located, colored, and textured. Point particles cannot be rotated
 * or given a 3D appearance. Point particles do not support a texture rectangle, and so all
 * particles from a single emitter must be textured identically. 
 */
@protocol CC3PointParticleProtocol <CC3CommonVertexArrayParticleProtocol>

/**
 * The index of this particle within the collection of particles managed by the emitter.
 *
 * You should not assume that this property will be consistent during the lifetime of
 * the particle. It can and will change spontaneously as other particles expire and
 * the emitter manages its collection of particles.
 *
 * This property is set by the particle emitter as it manages its collection of particles.
 * The application must treat this property as read-only, and must never set this property directly.
 *
 * At any time, this value is unique across all current living particles managed by the emitter.
 */
@property(nonatomic, assign) NSUInteger particleIndex;

/**
 * Invoked automatically, if the particle has vertex normal content, to point the normal vector
 * of the particle at the specified location, which is expressed in terms of the local coordinate
 * system of the emitter.
 *
 * To point the particle itself at the location, we use vector math. The vector from the emitter to
 * the particle is subtracted from the vector from the emitter to the specified location. The result
 * is a vector that points from the particle to the given location. This vector is normalized and
 * set in the normal property.
 *
 * This method is invoked automatically by the emitter if the particle has a normal, and the
 * shouldUseLighting property of the emitter is set to YES, to keep the normal of the particle
 * pointed towards the camera, so that the particle will appear to interact with the scene lighting.
 */
-(void) pointNormalAt: (CC3Vector) camLoc;

@end


#pragma mark -
#pragma mark CC3PointParticleMesh

/**
 * A mesh whose vertices are used to display point particles.
 *
 * This mesh adds the vertexPointSizes property to add a vertex array that manages
 * an optional particle size content for each vertex.
 *
 * Each vertex in the vertex arrays defines the visual characteristics for single point particle.
 * As with any other mesh, this content must include a location, so the vertexLocations array is
 * required by this model. In addition, optional characteristics may be specified for each vertex:
 * particle normal, color and size. Therefore, instances of this mesh may also include vertexNormals,
 * vertexColors, and vertexPointSizes arrays..
 *
 * Since only one vertex is used per point particle, and that data is usually updated frequently
 * by the application, there is little advantage to using indices during drawing. In general,
 * therefore, this mesh will not typically make use of a vertexIndices array.
 *
 * This subclass also contains several properties and population methods to assist in accessing
 * and managing the data in the vertex arrays.
 *
 * When creating a particle system, you do not typically need to interact with this class, or
 * create a customized subclass of CC3PointParticleMesh.
 */
@interface CC3PointParticleMesh : CC3VertexArrayMesh {
	CC3VertexPointSizes* vertexPointSizes;
}

/** @deprecated Use vertexCount instead. Point particles have one vertex per particle. */
@property(nonatomic, assign) GLuint particleCount DEPRECATED_ATTRIBUTE;

/**
 * The vertex array instance managing a particle size datum for each particle.
 *
 * Setting this property is optional. Many particle systems do not require individual
 * sizing for each particle.
 */
@property(nonatomic, retain) CC3VertexPointSizes* vertexPointSizes;


#pragma mark Vertex management

/**
 * Indicates the types of content contained in each vertex of this mesh.
 *
 * Each vertex can contain several types of content, optionally including location, normal,
 * color, and point size. To identify this various content, this property is a bitwise-OR
 * of flags that enumerate the types of content contained in each vertex of this mesh.
 *
 * Valid component flags of this property include:
 *   - kCC3VertexContentLocation
 *   - kCC3VertexContentNormal
 *   - kCC3VertexContentColor
 *   - kCC3VertexContentPointSize
 *
 * To indicate that this mesh should contain particular vertex content, construct a bitwise-OR
 * combination of one or more of the component types listed above, and set this property to that
 * combined value.
 *
 * Setting each bitwise-OR component in this property instructs this instance to
 * automatically construct the appropriate type of contained vertex array:
 *   - kCC3VertexContentLocation - automatically constructs a CC3VertexLocations instance in the
 *     vertexLocations property, that holds 3D vertex locations, in one CC3Vector structure per vertex.
 *     This component is optional, as the vertexLocations property will be constructed regardless.
 *   - kCC3VertexContentNormal - automatically constructs a CC3VertexNormals instance in the
 *     vertexNormals property, that holds 3D vertex normals, in one CC3Vector structure per vertex.
 *   - kCC3VertexContentColor - automatically constructs a CC3VertexColors instance in the vertexColors
 *     property, that holds RGBA colors with GLubyte components, in one ccColor4B structure per vertex.
 *   - kCC3VertexContentPointSize - automatically constructs a CC3VertexPointSizes
 *     instance in the vertexPointSizes property, that holds one GLfloat per vertex.
 * 
 * This property is a convenience property. Instead of using this property, you can create the
 * appropriate vertex arrays in those properties directly.
 * 
 * The vertex arrays constructed by this property will be configured to use interleaved data
 * if the shouldInterleaveVertices property is set to YES. You should ensure the value of the
 * shouldInterleaveVertices property to the desired value before setting the value of this property.
 * The initial value of the shouldInterleaveVertices property is YES.
 *
 * If the content is interleaved, for each vertex, the content is held in the structures identified in
 * the list above, in the order that they appear in the list. You can use this consistent organization
 * to create an enclosing structure to access all data for a single vertex, if it makes it easier to
 * access vertex data that way. If vertex content is not specified, it is simply absent, and the content
 * from the following type will be concatenated directly to the content from the previous type.
 *
 * For instance, if color content is not required, you would omit the kCC3VertexContentColor value
 * when setting this property, and the resulting structure for each vertex would be a location
 * CC3Vector, followed by a normal CC3Vector, followed immediately by a point size GLfloat.
 * You can then define an enclosing structure to hold and manage all content for a single vertex.
 *
 * The vertex arrays created by this property cover the most common use cases and data formats.
 * If you require more customized vertex arrays, you can use this property to create the typical
 * vertex arrays, and then customize them, by accessing the vertex arrays individually through
 * their respective properties. After doing so, if the vertex data is interleaved, you should
 * invoke the updateVertexStride method on this instance to automatically align the elementOffset
 * and vertexStride properties of all of the contained vertex arrays. After setting this property,
 * you do not need to invoke the updateVertexStride method unless you subsequently make changes
 * to the constructed vertex arrays.
 *
 * It is safe to set this property more than once. Doing so will remove any existing vertex arrays
 * and replace them with those indicated by this property.
 * 
 * When reading this property, the appropriate bitwise-OR values are returned, corresponding to the
 * contained vertex arrays, even if those arrays were constructed directly, instead of by setting
 * this property. If this mesh contains no vertex arrays, this property will return kCC3VertexContentNone.
 */
@property(nonatomic, assign) CC3VertexContent vertexContentTypes;

/** @deprecated Replaced by pointSizeAt:. */
-(GLfloat) particleSizeAt: (GLuint) vtxIndex DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced by setPointSize:at:. */
-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced by updatePointSizesGLBuffer. */
-(void) updateParticleSizesGLBuffer DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3PointParticleEmitter

/** Default size for particles. */
static const GLfloat kCC3DefaultParticleSize = 32.0;

/** Constant used with the particleSizeMinimum property to indicate no minimum size for particles. */
static const GLfloat kCC3ParticleSizeMinimumNone = 1.0;

/**
 * Constant used with the particleSizeMaximum property to indicate no maximum size
 * for particles, beyond any platform limit.
 */
static const GLfloat kCC3ParticleSizeMaximumNone = kCC3MaxGLfloat;

/** @deprecated Replaced with CC3VertexContent. */
typedef CC3VertexContent CC3PointParticleVertexContent DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced with kCC3VertexContentLocation. */
static const CC3VertexContent kCC3PointParticleContentLocation DEPRECATED_ATTRIBUTE	= kCC3VertexContentLocation;

/** @deprecated Replaced with kCC3VertexContentNormal. */
static const CC3VertexContent kCC3PointParticleContentNormal DEPRECATED_ATTRIBUTE = kCC3VertexContentNormal;

/** @deprecated Replaced with kCC3VertexContentColor. */
static const CC3VertexContent kCC3PointParticleContentColor DEPRECATED_ATTRIBUTE = kCC3VertexContentColor;

/** @deprecated Replaced with kCC3VertexContentPointSize. */
static const CC3VertexContent kCC3PointParticleContentSize DEPRECATED_ATTRIBUTE = kCC3VertexContentPointSize;

/**
 * CC3PointParticleEmitter emits particles that conform to the CC3PointParticleProtocol protocol.
 *
 * Each particle has its own location, and may optionally be configued with its own color
 * and individual size, and each particle may be configured with a vertex normal so that
 * it can interact with light sources. This particle content is defined by the
 * vertexContentTypes property of this emitter. 
 * 
 * Each point particle emitted displays the same texture, which is determined by the texture
 * property of this emitter node. Be aware that OpenGL point particles use the entire texture,
 * which you should generally ensure has dimensions that are power-of-two. Non-POT textures will
 * be padded by iOS when loaded, for compatibility with the graphics hardware. Although the
 * padding is generally transparent, it may throw off the expected location of your particle.
 *
 * In general, point particles will contain transparent content. As such, you will likely want
 * to set the blendFunc property to one of the following:
 *   - {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA} - Standard realistic translucent blending
 *                                              (this is the initial setting).
 *   - {GL_SRC_ALPHA, GL_ONE} - Additive blending, to have overlapping particles build on,
 *                              and intensify, each other
 *
 * For CC3PointParticleEmitter, the initial value of the shouldDisableDepthMask property
 * is YES, so that the particles do not enage in Z-fighting with each other. You can
 * experiment with changing this to NO if your emitter is better suited to it.
 *
 * You can also experiment with the shouldDisableDepthTest and depthFunction properties
 * to see if change them helps you get the look you are trying to achieve.
 *
 * You can control characteristics about the sizes of the particles, and how that size should
 * change with distance from the camera, using the particleSize, particleSizeMinimum,
 * particleSizeMaximum, particleSizeAttenuationCoefficients, and unityScaleDistance properties.
 *
 * The implementation of this CC3PointParticleEmitter class requires that the mesh property
 * is set with an instance of CC3PointParticleMesh mesh, which is tailored for point particles.
 *
 * All memory used by the particles and the underlying vertex mesh is managed by the
 * emitter node, and is deallocated automatically when the emitter is released.
 */
@interface CC3PointParticleEmitter : CC3CommonVertexArrayParticleEmitter {
	CC3Vector globalCameraLocation;
	CC3AttenuationCoefficients particleSizeAttenuationCoefficients;
	GLfloat particleSize;
	GLfloat particleSizeMinimum;
	GLfloat particleSizeMaximum;
	BOOL shouldSmoothPoints : 1;
	BOOL shouldNormalizeParticleSizesToDevice : 1;
	BOOL areParticleNormalsDirty : 1;
}

/**
 * The mesh that holds the vertex data for this mesh node.
 *
 * CC3PointParticleEmitter requires that the mesh be of type CC3PointParticleMesh.
 */
@property(nonatomic, retain) CC3PointParticleMesh* mesh;

/** @deprecated Replaced by the more generic redefined mesh property. */
@property(nonatomic, readonly) CC3PointParticleMesh* particleMesh DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced by the more generic vertexContentTypes. */
@property(nonatomic, readonly) CC3VertexContent particleContentTypes DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced by maximumParticleCapacity. */
@property(nonatomic, readonly) NSUInteger maxParticles DEPRECATED_ATTRIBUTE;

/**
 * If the kCC3VertexContentPointSize component was not specified in the vertexContentTypes
 * property, all particles will be emitted at the same size, as specified by this property.
 *
 * If the kCC3VertexContentPointSize component was specified, the size of each particle can
 * be individually set during the initialization of that particle. The size of each particle
 * defaults to this value, if not set to something else during its initialization.
 *
 * The initial value is kCC3DefaultParticleSize.
 */
@property(nonatomic, assign) GLfloat particleSize;

/**
 * The miniumum size for point particles. Particle sizes will not be allowed to shrink below this
 * value when distance attenuation is engaged.
 *
 * You can use this property to limit how small particles will become as they recede from the camera.
 *
 * The initial value of this property is kCC3ParticleSizeMinimumNone, indicating that particles
 * will be allowed to shrink to one pixel if needed.
 */
@property(nonatomic, assign) GLfloat particleSizeMinimum;

/**
 * The maxiumum size for point particles. Particle sizes will not be allowed to grow beyond this
 * value when distance attenuation is engaged.
 *
 * You can use this property to limit how large particles will become as they approach the camera.
 *
 * The initial value of this property is kCC3ParticleSizeMaximumNone, indicating that particles
 * will be allowed to grow until clamped by any platform limits.
 */
@property(nonatomic, assign) GLfloat particleSizeMaximum;

/**
 * The distance from the camera, in 3D space, at which the particle will be displayed
 * at unity scale (its natural size).
 *
 * The value of this property defines how the apparent size of the particle will change as it
 * moves closer to, or farther from, the camera. If the particle is closer to the camera than
 * this distance, the particle will appear proportionally larger than its natural size, and if
 * the particle is farther away from the camera than this distance, the particle will appear
 * proportionally smaller than its natural size.
 * 
 * The natural size of the particle is expressed in pixels and is set either by the particleSize
 * property of this emitter, or by the size property of the individual particle if the
 * vertexContentTypes property of this emitter includes the kCC3VertexContentPointSize value.
 *
 * Setting the value of this property to zero indicates that the size of the particles should stay
 * constant, at their natural size, regardless of how far the particle is from the camera.
 *
 * Setting this property replaces the need to set the value of the particleSizeAttenuationCoefficients
 * property, which offers a wider range of distance attenuation options, but is more complicated to use.
 *
 * The initial value of this property is zero, indicating that distance attenuation is not applied,
 * and each particle will appear at its natural size regardless of how far it is from the camera.
 */
@property(nonatomic, assign) GLfloat unityScaleDistance;

/**
 * The coefficients of the attenuation function that affects the size of a particle based on its
 * distance from the camera. The sizes of the particles are attenuated according to the formula
 * 1/sqrt(a + (b * r) + (c * r * r)), where r is the radial distance from the particle to the camera,
 * and a, b and c are the coefficients from this property.
 *
 * As an alternate to setting this property, you can set the unityScaleDistance property to establish
 * standard proportional distance attenuation.
 *
 * The initial value of this property is kCC3ParticleSizeAttenuationNone, indicating no attenuation
 * with distance.
 */
@property(nonatomic, assign) CC3AttenuationCoefficients particleSizeAttenuationCoefficients;

/**
 * Indicates whether the particle sizes should be adjusted so that particles appear
 * to be a consistent size across all device screen resolutions
 *
 * The 3D camera frustum is consistent across all devices, making the view of the 3D scene consistent
 * across all devices. However, particle size is defined in terms of pixels, and particles will appear
 * larger or smaller. relative to 3D artifacts, on different screen resolutions.
 * 
 * If this property is set to YES, the actual size of each particle, as submitted to the GL engine,
 * will be adjusted so that it appears to be the same size across all devices, relative to the 3D nodes.
 *
 * If this property is set to NO, the actual size of each particle will be drawn in the same absolute
 * pixel size across all devices, which may make it appear to be smaller or larger, relative to the
 * 3D artifacts around it, on different devices.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldNormalizeParticleSizesToDevice;

/** Indicates whether points should be smoothed (antialiased). The initial value is NO. */
@property(nonatomic, assign) BOOL shouldSmoothPoints;


#pragma mark Accessing vertex data

/**
 * Returns the particle size element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 *
 * You typically do not use this method directly. Instead, use the size property
 * of the individual particle from within your custom CC3PointParticle subclass.
 */
-(GLfloat) particleSizeAt: (GLuint) vtxIndex;

/**
 * Sets the particle size element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the updateParticleSizesGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 *
 * You typically do not use this method directly. Instead, use the size property
 * of the individual particle from within your custom CC3PointParticle subclass.
 */
-(void) setParticleSize: (GLfloat) aSize at: (GLuint) vtxIndex;

/**
 * Updates the GL engine buffer with the particle size data in this mesh.
 *
 * For particle emitters, this method is invoked automatically when particles
 * have been updated from within your CC3PointParticle subclass. Usually, the
 * application should never have need to invoke this method directly. 
 */
-(void) updateParticleSizesGLBuffer;

/**
 * Convenience method to cause the vertex point size data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex point sizes will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 *
 * This method is invoked automatically when the vertexContentTypes property is set.
 * Usually, the application should never have need to invoke this method directly.
 */
-(void) retainVertexPointSizes;

/**
 * Convenience method to cause the vertex point size data to be skipped when createGLBuffers
 * is invoked. The vertex data is not buffered to a GL VBO, is retained in application memory,
 * and is submitted to the GL engine on each frame render.
 *
 * Only the vertex point sizes will not be buffered to a GL VBO. Any other vertex content, such as
 * locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexPointSizes method.
 */
-(void) doNotBufferVertexPointSizes;


#pragma mark Accessing particles

/** Returns the particle at the specified index within the particles array, cast as a point particle. */
-(id<CC3PointParticleProtocol>) pointParticleAt: (NSUInteger) aParticleIndex;


#pragma mark Vertex management

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (NSUInteger) numParticles
						 ofType: (id) aParticleClass
					 containing: (CC3VertexContent) contentTypes DEPRECATED_ATTRIBUTE;

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (NSUInteger) maxParticles ofType: (id) aParticleClass DEPRECATED_ATTRIBUTE;

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (NSUInteger) numParticles
					 containing: (CC3VertexContent) contentTypes DEPRECATED_ATTRIBUTE;

/** @deprecated Use the particleClass, vertexContentTypes & maximumParticleCapacity properties instead. */
-(void) populateForMaxParticles: (NSUInteger) maxParticles DEPRECATED_ATTRIBUTE;

@end


#pragma mark -
#pragma mark CC3PointParticle

/**
 * CC3PointParticle is a standard base implementation of the CC3PointParticleProtocol.
 *
 * CC3PointParticle provides accessors for the particle normal and size.
 */
@interface CC3PointParticle : CC3ParticleBase <CC3PointParticleProtocol> {
	NSUInteger particleIndex;
	BOOL isAlive : 1;
}

/**
 * The emitter that emitted this particle.
 *
 * For CC3PointParticle, the emitter must be of type CC3PointParticleEmitter.
 */
@property(nonatomic, assign) CC3PointParticleEmitter* emitter;

/**
 * If this particle has vertex normal content, (which can be checked with the hasNormal property),
 * this property indicates the vertex normal that the particle uses to interact with light sources.
 * 
 * This property is automatically and dynamically adjusted by the emitter, based on the particle's
 * orientation with respect to the camera. Unless you have specific reason to change this property,
 * and know what you are doing, you should leave the value of this property alone.
 *
 * If this particle does not have vertex normal content, this property will always return kCC3VectorZero.
 * In this condition, it is safe to set this property, but changes will have no effect.
 */
@property(nonatomic, assign) CC3Vector normal;

/**
 * Indicates whether this particle has vertex normal content, as determined by the vertexContentTypes
 * property of the emitter. Within an emitter, either all particles have normal content, or none do.
 *
 * When this property returns YES, each particle will have a normal vector and will interact with
 * light sources. When this property returns NO, each particle will ignore lighting conditions.
 */
@property(nonatomic, readonly) BOOL hasNormal;

/**
 * If this particle has individual size content, (which can be checked with the hasSize property),
 * this property indicates the size at which this particle will appear.
 *
 * If this particle has individual size content, you can set this property at any time to define
 * the size of the particle.
 * 
 * If this particle does not have individual size content, this property will always return the
 * value of the particleSize property of the emitter. In this condition, it is safe to set this
 * property, but changes will have no effect.
 */
@property(nonatomic, assign) GLfloat size;

/**
 * Indicates whether this particle has vertex size content, as determined by the vertexContentTypes
 * property of the emitter. Within an emitter, either all particles have size content, or none do.
 *
 * When this property returns YES, each particle can be set to a different size. When this property
 * returns NO, all particles will have the size specified by the particleSize property of the emitter.
 */
@property(nonatomic, readonly) BOOL hasSize;

/** @deprecated Replaced by the particleIndex property. */
@property(nonatomic, assign) NSUInteger index DEPRECATED_ATTRIBUTE;

/** @deprecated Replaced by the updateBeforeTransform: method. */
-(void) update: (ccTime) dt DEPRECATED_ATTRIBUTE;

/** @deprecated Use the init method instead, and set emitter property directly. */
-(id) initFromEmitter: (CC3ParticleEmitter*) anEmitter;

/** @deprecated Use the particle method instead, and set emitter property directly. */
+(id) particleFromEmitter: (CC3ParticleEmitter*) anEmitter;

@end


#pragma mark -
#pragma mark CC3Node point particles extensions

/** CC3Node extension to support ancestors and descendants that make use of point particles. */
@interface CC3Node (PointParticles)

/**
 * Convenience method to cause the vertex point size data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex point sizes will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexPointSizes;

/**
 * Convenience method to cause the vertex point size data to be skipped when createGLBuffers
 * is invoked. The vertex data is not buffered to a GL VBO, is retained in application memory,
 * and is submitted to the GL engine on each frame render.
 *
 * Only the vertex point sizes will not be buffered to a GL VBO. Any other vertex content, such as
 * locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexPointSizes method.
 */
-(void) doNotBufferVertexPointSizes;

@end


#pragma mark -
#pragma mark CC3Mesh point particles extensions

/** CC3Mesh extension to define polymorphic methods to support vertex skinning. */
@interface CC3Mesh (PointParticles)

/** Indicates whether this mesh contains data for vertex point sizes. */
@property(nonatomic, readonly) BOOL hasVertexPointSizes;

/** @deprecated Replaced by hasVertexPointSizes. */
@property(nonatomic, readonly) BOOL hasPointSizes DEPRECATED_ATTRIBUTE;


#pragma mark Managing vertex content

/**
 * Returns the point size element at the specified index from the vertex data.
 *
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(GLfloat) vertexPointSizeAt: (GLuint) vtxIndex;

/**
 * Sets the point size element at the specified index in the vertex data to the specified value.
 * 
 * The index refers to vertices, not bytes. The implementation takes into consideration
 * the vertexStride and elementOffset properties to access the correct element.
 *
 * When all vertex changes have been made, be sure to invoke the updatePointSizesGLBuffer
 * method to ensure that the GL VBO that holds the vertex data is updated.
 *
 * If the releaseRedundantData method has been invoked and the underlying
 * vertex data has been released, this method will raise an assertion exception.
 */
-(void) setVertexPointSize: (GLfloat) aSize at: (GLuint) vtxIndex;

/** Updates the GL engine buffer with the point size data in this mesh. */
-(void) updatePointSizesGLBuffer;

/**
 * Convenience method to cause the vertex point size data to be retained in application
 * memory when releaseRedundantData is invoked, even if it has been buffered to a GL VBO.
 *
 * Only the vertex point sizes will be retained. Any other vertex data, such as locations,
 * or texture coordinates, that has been buffered to GL VBO's, will be released from
 * application memory when releaseRedundantData is invoked.
 */
-(void) retainVertexPointSizes;

/**
 * Convenience method to cause the vertex point size data to be skipped when createGLBuffers
 * is invoked. The vertex data is not buffered to a GL VBO, is retained in application memory,
 * and is submitted to the GL engine on each frame render.
 *
 * Only the vertex point sizes will not be buffered to a GL VBO. Any other vertex content, such as
 * locations, or texture coordinates, will be buffered to a GL VBO when createGLBuffers is invoked.
 *
 * This method causes the vertex data to be retained in application memory, so, if you have
 * invoked this method, you do NOT also need to invoke the retainVertexPointSizes method.
 */
-(void) doNotBufferVertexPointSizes;

@end
