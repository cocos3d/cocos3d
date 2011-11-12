/*
 * CC3MeshNode.m
 *
 * cocos3d 0.6.3
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
 * See header file CC3MeshNode.h for full API documentation.
 */

#import "CC3MeshNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3VertexArrayMesh.h"


@interface CC3Node (TemplateMethods)
-(void) populateFrom: (CC3Node*) another;
-(void) updateBoundingVolume;
-(void) rebuildBoundingVolume;
-(void) transformMatrixChanged;
@property(nonatomic, assign, readwrite) CC3Node* parent;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) configureFaceCulling: (CC3NodeDrawingVisitor*) visitor;
-(void) configureNormalization: (CC3NodeDrawingVisitor*) visitor;
-(void) configureColoring: (CC3NodeDrawingVisitor*) visitor;
-(void) configureDepthTesting: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) configureMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) populateAsVertexBox: (CC3BoundingBox) box;
@end

@implementation CC3MeshNode

@synthesize mesh, material, pureColor;

-(void) dealloc {
	[mesh release];
	[material release];
	[super dealloc];
}

// Sets the mesh then, if a bounding volume exists, forces it to rebuild
// using the new mesh data, or creates a default bounding volume from the mesh.
-(void) setMesh:(CC3Mesh *) aMesh {
	id oldMesh = mesh;
	mesh = [aMesh retain];
	[oldMesh release];
	if (boundingVolume) {
		[self rebuildBoundingVolume];
	} else {
		self.boundingVolume = [mesh defaultBoundingVolume];
	}

}

// Support for legacy CC3MeshModel class
-(CC3MeshModel*) meshModel {
	return (CC3MeshModel*)self.mesh;
}

// Support for legacy CC3MeshModel class
-(void) setMeshModel: (CC3MeshModel *) aMesh {
	self.mesh = aMesh;
}

// After setting the bounding volume, forces it to build its volume from the mesh
-(void) setBoundingVolume:(CC3NodeBoundingVolume *) aBoundingVolume {
	[super setBoundingVolume: aBoundingVolume];
	[self rebuildBoundingVolume];
}

-(CC3BoundingBox) localContentBoundingBox {
	return mesh
			? CC3BoundingBoxAddPadding(mesh.boundingBox, boundingVolumePadding)
			: kCC3BoundingBoxNull;
}

-(BOOL) shouldCullBackFaces { return shouldCullBackFaces; }

-(void) setShouldCullBackFaces: (BOOL) shouldCull {
	shouldCullBackFaces = shouldCull;
	super.shouldCullBackFaces = shouldCull;
}

-(BOOL) shouldCullFrontFaces { return shouldCullFrontFaces; }

-(void) setShouldCullFrontFaces: (BOOL) shouldCull {
	shouldCullFrontFaces = shouldCull;
	super.shouldCullFrontFaces = shouldCull;
}

-(BOOL) shouldUseClockwiseFrontFaceWinding { return shouldUseClockwiseFrontFaceWinding; }

-(void) setShouldUseClockwiseFrontFaceWinding: (BOOL) shouldWindCW {
	shouldUseClockwiseFrontFaceWinding = shouldWindCW;
	super.shouldUseClockwiseFrontFaceWinding = shouldWindCW;
}

-(BOOL) shouldUseSmoothShading { return shouldUseSmoothShading; }

-(void) setShouldUseSmoothShading: (BOOL) shouldSmooth {
	shouldUseSmoothShading = shouldSmooth;
	super.shouldUseSmoothShading = shouldSmooth;
}

-(CC3NormalScaling) normalScalingMethod { return normalScalingMethod; }

-(void) setNormalScalingMethod: (CC3NormalScaling) nsMethod {
	normalScalingMethod = nsMethod;
	super.normalScalingMethod = nsMethod;
}

-(BOOL) shouldDisableDepthMask { return shouldDisableDepthMask; }

-(void) setShouldDisableDepthMask: (BOOL) shouldDisable {
	shouldDisableDepthMask = shouldDisable;
	super.shouldDisableDepthMask = shouldDisable;
}

-(BOOL) shouldDisableDepthTest { return shouldDisableDepthTest; }

-(void) setShouldDisableDepthTest: (BOOL) shouldDisable {
	shouldDisableDepthTest = shouldDisable;
	super.shouldDisableDepthTest = shouldDisable;
}

-(GLenum) depthFunction { return depthFunction; }

-(void) setDepthFunction: (GLenum) depthFunc {
	depthFunction = depthFunc;
	super.depthFunction = depthFunc;
}


#pragma mark Material coloring

-(BOOL) shouldUseLighting {
	return material ? material.shouldUseLighting : NO;
}

-(void) setShouldUseLighting: (BOOL) useLighting {
	material.shouldUseLighting = useLighting;
	[super setShouldUseLighting: useLighting];	// pass along to any children
}

-(ccColor4F) ambientColor {
	return material ? material.ambientColor : kCCC4FBlackTransparent;
}

-(void) setAmbientColor:(ccColor4F) aColor {
	material.ambientColor = aColor;
	[super setAmbientColor: aColor];	// pass along to any children
}

-(ccColor4F) diffuseColor {
	return material ? material.diffuseColor : kCCC4FBlackTransparent;
}

-(void) setDiffuseColor:(ccColor4F) aColor {
	material.diffuseColor = aColor;
	[super setDiffuseColor: aColor];	// pass along to any children
}

-(ccColor4F) specularColor {
	return material ? material.specularColor : kCCC4FBlackTransparent;
}

-(void) setSpecularColor:(ccColor4F) aColor {
	material.specularColor = aColor;
	[super setSpecularColor: aColor];	// pass along to any children
}

-(ccColor4F) emissionColor {
	return material ? material.emissionColor : kCCC4FBlackTransparent;
}

-(void) setEmissionColor:(ccColor4F) aColor {
	material.emissionColor = aColor;
	[super setEmissionColor: aColor];	// pass along to any children
}

/** If the material has a bump-mapped texture, returns the global direction  */
-(CC3Vector) globalLightLocation {
	return (material && material.hasBumpMap)
			? [self.transformMatrix transformDirection: material.lightDirection]
			: [super globalLightLocation];
}

-(void) setGlobalLightLocation: (CC3Vector) aLocation {
	if (material && material.hasBumpMap) {
		material.lightDirection = [self.transformMatrixInverted transformDirection: aLocation];
	}
	[super setGlobalLightLocation: aLocation];
}


#pragma mark CCRGBAProtocol and CCBlendProtocol support

-(ccColor3B) color {
	return material ? material.color : ccc3(CCColorByteFromFloat(pureColor.r),
											CCColorByteFromFloat(pureColor.g),
											CCColorByteFromFloat(pureColor.b));
}

-(void) setColor: (ccColor3B) color {
	material.color = color;

	pureColor.r = CCColorFloatFromByte(color.r);
	pureColor.g = CCColorFloatFromByte(color.g);
	pureColor.b = CCColorFloatFromByte(color.b);

	[super setColor: color];	// pass along to any children
}

-(GLubyte) opacity {
	return material ? material.opacity : CCColorByteFromFloat(pureColor.a);
}

-(void) setOpacity: (GLubyte) opacity {
	material.opacity = opacity;
	pureColor.a = CCColorFloatFromByte(opacity);

	[super setOpacity: opacity];	// pass along to any children
}

-(BOOL) isOpaque {
	return material ? material.isOpaque : (pureColor.a == 1.0f);
}

-(void) setIsOpaque: (BOOL) opaque {
	material.isOpaque = opaque;
	pureColor.a = 1.0f;
	
	[super setIsOpaque: opaque];	// pass along to any children
}

-(ccBlendFunc) blendFunc {
	return material ? material.blendFunc : (ccBlendFunc){GL_ONE, GL_ZERO};
}

-(void) setBlendFunc: (ccBlendFunc) aBlendFunc {
	material.blendFunc = aBlendFunc;
	[super setBlendFunc: aBlendFunc];
}

-(BOOL) shouldDrawLowAlpha {
	return material ? material.shouldDrawLowAlpha : YES;
}

-(void) setShouldDrawLowAlpha: (BOOL) shouldDraw {
	material.shouldDrawLowAlpha = shouldDraw;
}


#pragma mark Textures

-(CC3Texture*) texture {
	return material.texture;
}

-(void) setTexture: (CC3Texture*) aTexture {
	if (!material) {
		NSString* matName = [NSString stringWithFormat: @"%@-Material", self.name];
		self.material = [CC3Material materialWithName: matName];
	}
	material.texture = aTexture;
}

-(void) alignTextures {
	[mesh alignWithTexturesIn: material];
	[super alignTextures];
}

-(void) alignInvertedTextures {
	[mesh alignWithInvertedTexturesIn: material];
	[super alignInvertedTextures];
}

-(void) repeatTexture: (ccTex2F) repeatFactor {
	[mesh repeatTexture: repeatFactor];
}

-(CGRect) textureRectangle {
	return mesh ? mesh.textureRectangle : kCC3UnitTextureRectangle;
}

-(void) setTextureRectangle: (CGRect) aRect {
	mesh.textureRectangle = aRect;
}

-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit {
	return mesh ? [mesh textureRectangleForTextureUnit: texUnit] : kCC3UnitTextureRectangle;
}

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {
	[mesh setTextureRectangle: aRect forTextureUnit: texUnit];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		pureColor = kCCC4FWhite;
		shouldUseSmoothShading = YES;
		shouldCullBackFaces = YES;
		shouldCullFrontFaces = NO;
		shouldUseClockwiseFrontFaceWinding = NO;
		shouldDisableDepthMask = NO;
		shouldDisableDepthTest = NO;
		depthFunction = GL_LEQUAL;
		normalScalingMethod = kCC3NormalScalingAutomatic;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// A copy is made of the material.
// The mesh is simply retained, without creating a copy.
// Both this node and the other node will share the mesh.
-(void) populateFrom: (CC3MeshNode*) another {
	[super populateFrom: another];
	
	self.mesh = another.mesh;								// retained but not copied
	self.material = [another.material copyAutoreleased];	// retained
	
	pureColor = another.pureColor;
	shouldUseSmoothShading = another.shouldUseSmoothShading;
	shouldCullBackFaces = another.shouldCullBackFaces;
	shouldCullFrontFaces = another.shouldCullFrontFaces;
	shouldUseClockwiseFrontFaceWinding = another.shouldUseClockwiseFrontFaceWinding;
	shouldDisableDepthMask = another.shouldDisableDepthMask;
	shouldDisableDepthTest = another.shouldDisableDepthTest;
	depthFunction = another.depthFunction;
	normalScalingMethod = another.normalScalingMethod;
}

-(void) createGLBuffers {
	LogTrace(@"%@ creating GL server buffers", self);
	[mesh createGLBuffers];
	[super createGLBuffers];
}

-(void) deleteGLBuffers {
	[mesh deleteGLBuffers];
	[super deleteGLBuffers];
}

-(void) releaseRedundantData {
	[mesh releaseRedundantData];
	[super releaseRedundantData];
}

-(void) retainVertexLocations {
	[mesh retainVertexLocations];
	[super retainVertexLocations];
}

-(void) retainVertexNormals {
	[mesh retainVertexNormals];
	[super retainVertexNormals];
}

-(void) retainVertexColors {
	[mesh retainVertexColors];
	[super retainVertexColors];
}

-(void) retainVertexTextureCoordinates {
	[mesh retainVertexTextureCoordinates];
	[super retainVertexTextureCoordinates];
}

-(void) retainVertexIndices {
	[mesh retainVertexIndices];
	[super retainVertexIndices];
}

-(void) doNotBufferVertexLocations {
	[mesh doNotBufferVertexLocations];
	[super doNotBufferVertexLocations];
}

-(void) doNotBufferVertexNormals {
	[mesh doNotBufferVertexNormals];
	[super doNotBufferVertexNormals];
}

-(void) doNotBufferVertexColors {
	[mesh doNotBufferVertexColors];
	[super doNotBufferVertexColors];
}

-(void) doNotBufferVertexTextureCoordinates {
	[mesh doNotBufferVertexTextureCoordinates];
	[super doNotBufferVertexTextureCoordinates];
}

-(void) doNotBufferVertexIndices {
	[mesh doNotBufferVertexIndices];
	[super doNotBufferVertexIndices];
}


#pragma mark Type testing

-(BOOL) isMeshNode {
	return YES;
}


#pragma mark Drawing

/**
 * Template method that uses template methods to configure drawing parameters
 * and the material, draws the mesh, and cleans up the drawing state.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self configureDrawingParameters: visitor];		// Before material is configured.
	[self configureMaterialWithVisitor: visitor];

	[self drawMeshWithVisitor: visitor];
	
	[self cleanupDrawingParameters: visitor];
}

/**
 * Template method to configure the drawing parameters.
 *
 * Subclasses may override to add additional drawing parameters.
 */
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[self configureFaceCulling: visitor];
	[self configureNormalization: visitor];
	[self configureColoring: visitor];
	[self configureDepthTesting: visitor];
}

/**
 * Template method configures GL face culling based on the shouldCullBackFaces,
 * shouldCullBackFaces, and shouldUseClockwiseFrontFaceWinding properties.
 */
-(void) configureFaceCulling: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = gles11Engine.serverCapabilities;
	CC3OpenGLES11State* gles11State = gles11Engine.state;

	// Enable culling if either back or front should be culled.
	gles11ServCaps.cullFace.value = shouldCullBackFaces || shouldCullFrontFaces;

	// Set whether back, front or both should be culled.
	// If neither should be culled, handled by capability so leave it as back culling.
	gles11State.cullFace.value = shouldCullBackFaces
									? (shouldCullFrontFaces ? GL_FRONT_AND_BACK : GL_BACK)
									: (shouldCullFrontFaces ? GL_FRONT : GL_BACK);

	// Set the front face winding
	gles11State.frontFace.value = shouldUseClockwiseFrontFaceWinding ? GL_CW : GL_CCW;
}

/**
 * Template method configures GL scaling of normals, based on
 * whether the scaling of this node is uniform or not.
 */
-(void) configureNormalization: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11ServerCapabilities* gles11ServCaps = [CC3OpenGLES11Engine engine].serverCapabilities;

	if (mesh && mesh.hasNormals) {
		switch (normalScalingMethod) {

			// Enable normalizing & disable re-scaling
			case kCC3NormalScalingNormalize:
				[gles11ServCaps.rescaleNormal disable];
				[gles11ServCaps.normalize enable];
				break;

			// Enable rescaling & disable normalizing
			case kCC3NormalScalingRescale:
				[gles11ServCaps.rescaleNormal enable];
				[gles11ServCaps.normalize disable];
				break;

			// Choose one of the others, based on scaling characteristics
			case kCC3NormalScalingAutomatic:	

				// If no scaling, disable both normalizing and re-scaling
				if (self.isTransformRigid) {
					[gles11ServCaps.rescaleNormal disable];
					[gles11ServCaps.normalize disable];

				// If uniform scaling, enable re-scaling & disable normalizing
				} else if (self.isUniformlyScaledGlobally) {
					[gles11ServCaps.rescaleNormal enable];
					[gles11ServCaps.normalize disable];

				// If non-uniform scaling, enable normalizing & disable re-scaling
				} else {
					[gles11ServCaps.rescaleNormal disable];
					[gles11ServCaps.normalize enable];
				}
				break;
			
			// Disable both rescaling & normalizing
			case kCC3NormalScalingNone:
			default:
				[gles11ServCaps.rescaleNormal disable];
				[gles11ServCaps.normalize disable];
				break;
		}
	} else {
		// No normals...so disable both rescaling & normalizing
		[gles11ServCaps.rescaleNormal disable];
		[gles11ServCaps.normalize disable];
	}
}

/**
 * Configures the GL state for smooth shading, and to support vertex coloring.
 * This must be invoked every time, because both the material and mesh influence
 * the colorMaterial property, and the mesh will not be re-bound if it does not
 * need to be switched. And this method must be invoked before material colors
 * are set, otherwise material colors will not stick.
 */
-(void) configureColoring: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];

	// Set the smoothing model
	gles11Engine.state.shadeModel.value = shouldUseSmoothShading ? GL_SMOOTH : GL_FLAT;

	// Attach the color to the material
	gles11Engine.serverCapabilities.colorMaterial.value = (mesh ? mesh.hasColors : NO);
}

/**
 * Template method disables depth testing and/or writing to the depth buffer if the
 * shouldDisableDepthTest and shouldDisableDepthMask property is set to YES, respectively,
 * and set the depth function.
 */
-(void) configureDepthTesting: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11State* gles11State = gles11Engine.state;
	gles11Engine.serverCapabilities.depthTest.value = !shouldDisableDepthTest;
	gles11State.depthMask.value = !shouldDisableDepthMask;
	gles11State.depthFunction.value = depthFunction;
}

/**
 * Reverts any drawing parameters that were set in the configureDrawingParameters:
 * method that need to be cleaned up.
 * 
 * Since most mesh drawing confguration is set for each mesh, most state does not
 * need to be cleaned up. Only specialized subclasses that need to set very specific
 * state and unset it once they are finished drawing, will need to override this method.
 */
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor {}

/** Template method to configure the material properties in the GL engine. */
-(void) configureMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	if (visitor.shouldDecorateNode) {
		if (material) {
			[material drawWithVisitor: visitor];
		} else {
			[CC3Material unbind];
			[gles11Engine.serverCapabilities.lighting disable];
			gles11Engine.state.color.value = pureColor;
		}
	} else {
		[CC3Material unbind];
	}
}

/** Template method to draw the mesh to the GL engine. */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[mesh drawWithVisitor: visitor];
}


#pragma mark Accessing vertex data

-(void) movePivotTo: (CC3Vector) aLocation {
	[mesh movePivotTo: aLocation];
	[self rebuildBoundingVolume];
}

-(void) movePivotToCenterOfGeometry {
	[mesh movePivotToCenterOfGeometry];
	[self rebuildBoundingVolume];
}

-(GLsizei) vertexCount {
	return mesh ? mesh.vertexCount : 0;
}

-(CC3Vector) vertexLocationAt: (GLsizei) index {
	return mesh ? [mesh vertexLocationAt: index] : kCC3VectorZero;
}

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLsizei) index {
	[mesh setVertexLocation: aLocation at: index];
}

-(CC3Vector) vertexNormalAt: (GLsizei) index {
	return mesh ? [mesh vertexNormalAt: index] : kCC3VectorZero;
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLsizei) index {
	[mesh setVertexNormal: aNormal at: index];
}

-(ccColor4F) vertexColor4FAt: (GLsizei) index {
	return mesh ? [mesh vertexColor4FAt: index] : kCCC4FBlackTransparent;
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLsizei) index {
	[mesh setVertexColor4F: aColor at: index];
}

-(ccColor4B) vertexColor4BAt: (GLsizei) index {
	return mesh ? [mesh vertexColor4BAt: index] : (ccColor4B){ 0, 0, 0, 0 };
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLsizei) index {
	[mesh setVertexColor4B: aColor at: index];
}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLsizei) index {
	return mesh ? [mesh vertexTexCoord2FForTextureUnit: texUnit at: index] : (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLsizei) index {
	[mesh setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
}

-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index {
	return [self vertexTexCoord2FForTextureUnit: 0 at: index];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: 0 at: index];
}

// Deprecated
-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index forTextureUnit: (GLuint) texUnit {
	return [self vertexTexCoord2FForTextureUnit: texUnit at: index];
}

// Deprecated
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index forTextureUnit: (GLuint) texUnit {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
}

-(GLushort) vertexIndexAt: (GLsizei) index {
	return mesh ? [mesh vertexIndexAt: index] : 0;
}

-(void) setVertexIndex: (GLushort) vertexIndex at: (GLsizei) index {
	[mesh setVertexIndex: vertexIndex at: index];
}

-(void) updateVertexLocationsGLBuffer {
	[mesh updateVertexLocationsGLBuffer];
}

-(void) updateVertexNormalsGLBuffer {
	[mesh updateVertexNormalsGLBuffer];
}

-(void) updateVertexColorsGLBuffer {
	[mesh updateVertexColorsGLBuffer];
}

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {
	[mesh updateVertexTextureCoordinatesGLBufferForTextureUnit: texUnit];
}

-(void) updateVertexTextureCoordinatesGLBuffer {
	[self updateVertexTextureCoordinatesGLBufferForTextureUnit: 0];
}

-(void) updateVertexIndicesGLBuffer {
	[mesh updateVertexIndicesGLBuffer];
}

@end


#pragma mark -
#pragma mark CC3LineNode

@interface CC3LineNode (TemplateMethods)
-(void) configureLineProperties;
@end


@implementation CC3LineNode

@synthesize lineWidth, shouldSmoothLines, performanceHint;


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		lineWidth = 1.0f;
		shouldSmoothLines = NO;
		performanceHint = GL_DONT_CARE;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3LineNode*) another {
	[super populateFrom: another];
	
	lineWidth = another.lineWidth;
	shouldSmoothLines = another.shouldSmoothLines;
	performanceHint = another.performanceHint;
}


#pragma mark Drawing

/** Overridden to set the line properties in addition to other configuration. */
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor];
	[self configureLineProperties];
}

-(void) configureLineProperties {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	gles11Engine.state.lineWidth.value = lineWidth;
	gles11Engine.serverCapabilities.lineSmooth.value = shouldSmoothLines;
	gles11Engine.hints.lineSmooth.value = performanceHint;
}

@end


#pragma mark -
#pragma mark CC3WireframeBoundingBoxNode

@interface CC3WireframeBoundingBoxNode (TemplateMethods)
-(void) updateFromParentBoundingBoxWithVisitor: (CC3NodeUpdatingVisitor*) visitor;
@property(nonatomic, readonly) CC3BoundingBox parentBoundingBox;
@end

@implementation CC3WireframeBoundingBoxNode

@synthesize shouldAlwaysMeasureParentBoundingBox;

-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

// Overridden so that not touchable unless specifically set as such
-(BOOL) isTouchable {
	return (self.visible || shouldAllowTouchableWhenInvisible) && isTouchEnabled;
}

// Overridden so that can still be visible if parent is invisible,
// unless explicitly set off.
-(BOOL) visible {
	return visible;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		shouldAlwaysMeasureParentBoundingBox = NO;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3WireframeBoundingBoxNode*) another {
	[super populateFrom: another];
	
	shouldAlwaysMeasureParentBoundingBox = another.shouldAlwaysMeasureParentBoundingBox;
}

-(void) releaseRedundantData {
	[self retainVertexLocations];
	[super releaseRedundantData];
}


#pragma mark Updating

/** If we should remeasure and update the bounding box dimensions, do so. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	if (shouldAlwaysMeasureParentBoundingBox) {
		[self updateFromParentBoundingBoxWithVisitor: visitor];
	}
}

/** Measures the bounding box of the parent node and updates the vertex locations. */
-(void) updateFromParentBoundingBoxWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	CC3BoundingBox pbb = self.parentBoundingBox;
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.minimum.y, pbb.minimum.z) at: 0];
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.minimum.y, pbb.maximum.z) at: 1];
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.maximum.y, pbb.minimum.z) at: 2];
	[self setVertexLocation: cc3v(pbb.minimum.x, pbb.maximum.y, pbb.maximum.z) at: 3];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.minimum.y, pbb.minimum.z) at: 4];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.minimum.y, pbb.maximum.z) at: 5];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.maximum.y, pbb.minimum.z) at: 6];
	[self setVertexLocation: cc3v(pbb.maximum.x, pbb.maximum.y, pbb.maximum.z) at: 7];
	[self updateVertexLocationsGLBuffer];
	[self rebuildBoundingVolume];
}

/**
 * Returns the parent's bounding box, or kCC3BoundingBoxZero if no parent,
 * or if parent doesn't have a bounding box.
 */
-(CC3BoundingBox) parentBoundingBox {
	if (parent) {
		CC3BoundingBox pbb = parent.boundingBox;
		if (!CC3BoundingBoxIsNull(pbb)) {
			return pbb;
		}
	}
	return kCC3BoundingBoxZero;
}

@end


#pragma mark -
#pragma mark CC3WireframeLocalContentBoundingBoxNode

@implementation CC3WireframeLocalContentBoundingBoxNode

/**
 * Overridden to return the parent's local content bounding box,
 * or kCC3BoundingBoxZero if no parent, or if parent doesn't have a bounding box.
 */
-(CC3BoundingBox) parentBoundingBox {
	if (parent && parent.hasLocalContent) {
		CC3BoundingBox pbb = ((CC3LocalContentNode*)parent).localContentBoundingBox;
		if (!CC3BoundingBoxIsNull(pbb)) {
			return pbb;
		}
	}
	return kCC3BoundingBoxZero;
}

@end


#pragma mark -
#pragma mark CC3DirectionMarkerNode

@interface CC3DirectionMarkerNode (TemplateMethods)
-(CC3Vector) calculateLineEnd;
@end

@implementation CC3DirectionMarkerNode

-(CC3Vector) markerDirection {
	return markerDirection;
}

-(void) setMarkerDirection: (CC3Vector) aDirection {
	markerDirection = CC3VectorNormalize(aDirection);
}

-(void) setParent: (CC3Node*) aNode {
	[super setParent: aNode];
	[self updateFromParentBoundingBoxWithVisitor: nil];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		markerDirection = kCC3VectorUnitZNegative;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3DirectionMarkerNode*) another {
	[super populateFrom: another];
	
	markerDirection = another.markerDirection;
}


#pragma mark Updating

/** Measures the bounding box of the parent node and updates the vertex locations. */
-(void) updateFromParentBoundingBoxWithVisitor: (CC3NodeUpdatingVisitor*) visitor {
	[self setVertexLocation: [self calculateLineEnd] at: 1];
	[self updateVertexLocationsGLBuffer];
	[self rebuildBoundingVolume];
}

#define kCC3DirMarkerLineScale 1.5
#define kCC3DirMarkerMinAbsoluteScale (0.25 / kCC3DirMarkerLineScale)

/**
 * Calculates the scale to use, along a single axis, for the length of the directional marker.
 * Divide the distance from the origin, along this axis, to each of two opposite sides of the
 * bounding box, by the length of the directional marker in this axis.
 *
 * Taking into consideration the sign of the direction, the real distance along this axis to
 * the side it will intersect will be the maximum of these two values.
 *
 * Finally, in case the origin is on, or very close to, one side, make sure the length of the
 * directional marker is at least 1/4 of the length of the distance between the two sides.
 */
-(GLfloat) calcScale: (GLfloat) markerAxis bbMin: (GLfloat) minBBAxis bbMax: (GLfloat) maxBBAxis {
	if (markerAxis == 0.0f) return CGFLOAT_MAX;
	
	GLfloat scaleToMaxSide = maxBBAxis / markerAxis;
	GLfloat scaleToMinSide = minBBAxis / markerAxis;
	GLfloat minAbsoluteScale = fabs((maxBBAxis - minBBAxis) / markerAxis) * kCC3DirMarkerMinAbsoluteScale;
	return MAX(MAX(scaleToMaxSide, scaleToMinSide), minAbsoluteScale);
}

/**
 * Calculate the end of the directonal marker line.
 *
 * This is done by calculating the scale we need to multiply the directional marker by to
 * reach each of the three sides of the bounding box, then take the smallest of these,
 * because that is the side it will intersect. Finally, multiply by an overall scale factor.
 */
-(CC3Vector) calculateLineEnd {
	CC3BoundingBox pbb = self.parentBoundingBox;
	CC3Vector md = self.markerDirection;
	
	CC3Vector pbbDirScale = cc3v([self calcScale: md.x bbMin: pbb.minimum.x bbMax: pbb.maximum.x],
								 [self calcScale: md.y bbMin: pbb.minimum.y bbMax: pbb.maximum.y],
								 [self calcScale: md.z bbMin: pbb.minimum.z bbMax: pbb.maximum.z]);
	GLfloat dirScale = MIN(pbbDirScale.x, MIN(pbbDirScale.y, pbbDirScale.z));
	CC3Vector lineEnd = CC3VectorScaleUniform(md, (dirScale * [[self class] directionMarkerScale]));
	LogTrace(@"%@ calculated line end %@ from pbb scale %@ and dir scale %.3f", self,
			 NSStringFromCC3Vector(lineEnd), NSStringFromCC3Vector(pbbDirScale), dirScale);
	return lineEnd;
}

// The proportional distance that the direction should protrude from the parent node
static GLfloat directionMarkerScale = 1.5;

+(GLfloat) directionMarkerScale {
	return directionMarkerScale;
}

+(void) setDirectionMarkerScale: (GLfloat) aScale {
	directionMarkerScale = aScale;
}

@end


#pragma mark -
#pragma mark CC3PlaneNode

@implementation CC3PlaneNode

-(CC3Plane) plane {
	CC3VertexArrayMesh* vam = (CC3VertexArrayMesh*)self.mesh;
	CC3BoundingBox bb = vam.vertexLocations.boundingBox;
	
	// Get three points on the plane by using three corners of the mesh bounding box.
	CC3Vector p1 = bb.minimum;
	CC3Vector p2 = bb.maximum;
	CC3Vector p3 = bb.minimum;
	p3.x = bb.maximum.x;

	// Transform these points.
	p1 = [self.transformMatrix transformLocation: p1];
	p2 = [self.transformMatrix transformLocation: p2];
	p3 = [self.transformMatrix transformLocation: p3];

	// Create and return a plane from these points.
	return CC3PlaneFromPoints(p1, p2, p3);
}

@end


#pragma mark -
#pragma mark CC3BoxNode

@implementation CC3BoxNode
@end

