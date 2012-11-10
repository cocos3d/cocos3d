/*
 * CC3MeshNode.m
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
 * 
 * See header file CC3MeshNode.h for full API documentation.
 */

#import "CC3MeshNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3VertexArrayMesh.h"
#import "CC3Light.h"
#import "CC3IOSExtensions.h"


@interface CC3Node (TemplateMethods)
-(void) updateBoundingVolume;
-(void) markBoundingVolumeDirty;
@property(nonatomic, assign, readwrite) CC3Node* parent;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) configureFaceCulling: (CC3NodeDrawingVisitor*) visitor;
-(void) configureNormalization: (CC3NodeDrawingVisitor*) visitor;
-(void) configureColoring: (CC3NodeDrawingVisitor*) visitor;
-(void) configureDepthTesting: (CC3NodeDrawingVisitor*) visitor;
-(void) configureDecalParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) configureLineProperties: (CC3NodeDrawingVisitor*) visitor;
-(void) configureMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) alignTextureUnit: (GLuint) texUnit;
-(void) ensureMaterial;
-(void) makeMaterial;
-(void) ensureMesh;
-(void) makeMesh;
@end

@interface CC3Mesh (TemplateMethods)
-(void) deprecatedAlignWithTexturesIn: (CC3Material*) aMaterial;
-(void) deprecatedAlignWithInvertedTexturesIn: (CC3Material*) aMaterial;
@end


@implementation CC3MeshNode

@synthesize mesh, material, pureColor;
@synthesize lineWidth, shouldSmoothLines, lineSmoothingHint;

-(void) dealloc {
	[mesh release];
	[material release];
	[super dealloc];
}

-(void) setName: (NSString*) aName {
	super.name = aName;
	[mesh deriveNameFrom: self];
	[material deriveNameFrom: self];
}

// Sets the name of the mesh if needed then, if a bounding volume exists, forces it to
// rebuild using the new mesh data, or creates a default bounding volume from the mesh.
-(void) setMesh:(CC3Mesh *) aMesh {
	[mesh autorelease];
	mesh = [aMesh retain];
	[mesh deriveNameFrom: self];

	if ( !mesh.hasVertexNormals ) self.shouldUseLighting = NO;
	if ( !mesh.hasVertexTextureCoordinates ) self.texture = nil;
	
	if (boundingVolume) {
		[self markBoundingVolumeDirty];
	} else {
		self.boundingVolume = [self defaultBoundingVolume];
	}
}

/** If a mesh does not yet exist, create it as a CC3VertexArrayMesh with interleaved vertices. */
-(void) ensureMesh { if ( !mesh ) [self makeMesh]; }

/**
 * Template method to create a mesh for this node.
 *
 * Subclasses may override to provide a different material.
 */
-(void) makeMesh { self.mesh = [CC3VertexArrayMesh mesh]; }

/**
 * Sets the name of the material if needed, then checks the vertex content types and
 * the alignment of the texture
 * coordinates for each texture unit against the corresponding texture in the material.
 */
-(void) setMaterial: (CC3Material*) aMaterial {
	[material autorelease];
	material = [aMaterial retain];
	[material deriveNameFrom: self];

	if ( !mesh.hasVertexNormals ) self.shouldUseLighting = NO;
	if ( !mesh.hasVertexTextureCoordinates ) self.texture = nil;

	GLuint texCount = self.textureCount;
	for (GLuint texUnit = 0; texUnit < texCount; texUnit++) {
		[self alignTextureUnit: texUnit];
	}
}

/** If a material does not yet exist, create it by invoking the makeMaterial method. */
-(void) ensureMaterial { if ( !material ) [self makeMaterial]; }

/**
 * Template method to create a material for this mesh node.
 *
 * The new material's initial diffuse and ambient colors are modulated by the value of the
 * pureColor property to propagate any color changes already made into the material. The
 * initial value of pureColor is pure white, so if it has not been changed, the ambient and
 * diffuse colors of the material will take on their default initial values.
 *
 * This method is invoked automatically by the ensureMaterial method if a material is needed,
 * but has not yet been established.
 *
 * Subclasses may override to provide a different material.
 */
-(void) makeMaterial {
	CC3Material* mat = [CC3Material material];
	mat.ambientColor = CCC4FModulate(mat.ambientColor, self.pureColor);
	mat.diffuseColor = CCC4FModulate(mat.diffuseColor, self.pureColor);
	self.material = mat;
}

// Support for deprecated CC3MeshModel class
-(CC3Mesh*) meshModel { return self.mesh; }

// Support for deprecated CC3MeshModel class
-(void) setMeshModel: (CC3Mesh*) aMesh { self.mesh = aMesh; }

// After setting the bounding volume, forces it to build its volume from the mesh
-(void) setBoundingVolume:(CC3NodeBoundingVolume *) aBoundingVolume {
	[super setBoundingVolume: aBoundingVolume];
	[self markBoundingVolumeDirty];
}

-(CC3NodeBoundingVolume*) defaultBoundingVolume { return [mesh defaultBoundingVolume]; }

-(CC3BoundingBox) localContentBoundingBox {
	return mesh
			? CC3BoundingBoxAddUniformPadding(mesh.boundingBox, boundingVolumePadding)
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

-(BOOL) shouldCastShadowsWhenInvisible { return shouldCastShadowsWhenInvisible; }

-(void) setShouldCastShadowsWhenInvisible: (BOOL) shouldCast {
	shouldCastShadowsWhenInvisible = shouldCast;
	super.shouldCastShadowsWhenInvisible = shouldCast;
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

-(GLenum) depthFunction { return (depthFunction != GL_NEVER) ? depthFunction : super.depthFunction; }

-(void) setDepthFunction: (GLenum) depthFunc {
	depthFunction = depthFunc;
	super.depthFunction = depthFunc;
}

-(GLfloat) decalOffsetFactor { return decalOffsetFactor ? decalOffsetFactor : super.decalOffsetFactor; }

-(void) setDecalOffsetFactor: (GLfloat) factor {
	decalOffsetFactor = factor;
	super.decalOffsetFactor = factor;
}

-(GLfloat) decalOffsetUnits { return decalOffsetUnits ? decalOffsetUnits : super.decalOffsetUnits; }

-(void) setDecalOffsetUnits: (GLfloat) units {
	decalOffsetUnits = units;
	super.decalOffsetUnits = units;
}


#pragma mark Material coloring

-(BOOL) shouldUseLighting { return material ? material.shouldUseLighting : NO; }

-(void) setShouldUseLighting: (BOOL) useLighting {
	if (useLighting) [self ensureMaterial];
	material.shouldUseLighting = useLighting;
	[super setShouldUseLighting: useLighting];	// pass along to any children
}

-(ccColor4F) ambientColor {
	[self ensureMaterial];
	return material.ambientColor;
}

-(void) setAmbientColor:(ccColor4F) aColor {
	[self ensureMaterial];
	material.ambientColor = aColor;
	[super setAmbientColor: aColor];	// pass along to any children
}

-(ccColor4F) diffuseColor {
	[self ensureMaterial];
	return material.diffuseColor;
}

-(void) setDiffuseColor:(ccColor4F) aColor {
	[self ensureMaterial];
	material.diffuseColor = aColor;
	[super setDiffuseColor: aColor];	// pass along to any children
}

-(ccColor4F) specularColor {
	[self ensureMaterial];
	return material.specularColor;
}

-(void) setSpecularColor:(ccColor4F) aColor {
	[self ensureMaterial];
	material.specularColor = aColor;
	[super setSpecularColor: aColor];	// pass along to any children
}

-(ccColor4F) emissionColor {
	[self ensureMaterial];
	return material.emissionColor;
}

-(void) setEmissionColor:(ccColor4F) aColor {
	[self ensureMaterial];
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
	[self ensureMaterial];
	material.lightDirection = [self.transformMatrixInverted transformDirection: aLocation];
	[super setGlobalLightLocation: aLocation];
}


#pragma mark CCRGBAProtocol and CCBlendProtocol support

-(ccColor3B) color {
	[self ensureMaterial];
	return material.color;
}

-(void) setColor: (ccColor3B) color {
	[self ensureMaterial];
	material.color = color;
	if (shouldApplyOpacityAndColorToMeshContent) mesh.color = color;	// for meshes with colored vertices

	pureColor.r = CCColorFloatFromByte(color.r);
	pureColor.g = CCColorFloatFromByte(color.g);
	pureColor.b = CCColorFloatFromByte(color.b);

	[super setColor: color];	// pass along to any children
}

-(GLubyte) opacity {
	[self ensureMaterial];
	return material.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
	[self ensureMaterial];
	material.opacity = opacity;
	if (shouldApplyOpacityAndColorToMeshContent) mesh.opacity = opacity;	// for meshes with colored vertices
	pureColor.a = CCColorFloatFromByte(opacity);

	[super setOpacity: opacity];	// pass along to any children
}

-(BOOL) isOpaque { return material ? material.isOpaque : YES; }

-(void) setIsOpaque: (BOOL) opaque {
	[self ensureMaterial];
	material.isOpaque = opaque;
	if (opaque) pureColor.a = 1.0f;
	
	[super setIsOpaque: opaque];	// pass along to any children
}

-(ccBlendFunc) blendFunc {
	[self ensureMaterial];
	return material.blendFunc;
}

-(void) setBlendFunc: (ccBlendFunc) aBlendFunc {
	[self ensureMaterial];
	material.blendFunc = aBlendFunc;
	[super setBlendFunc: aBlendFunc];
}

-(BOOL) shouldDrawLowAlpha {
	[self ensureMaterial];
	return material.shouldDrawLowAlpha;
}

-(void) setShouldDrawLowAlpha: (BOOL) shouldDraw {
	[self ensureMaterial];
	material.shouldDrawLowAlpha = shouldDraw;
}

-(BOOL) shouldApplyOpacityAndColorToMeshContent { return shouldApplyOpacityAndColorToMeshContent; }

-(void) setShouldApplyOpacityAndColorToMeshContent: (BOOL) shouldApply {
	shouldApplyOpacityAndColorToMeshContent = shouldApply;
	super.shouldApplyOpacityAndColorToMeshContent = shouldApply;
}

#pragma mark Line drawing configuration

-(GLfloat) lineWidth { return lineWidth; }

-(void) setLineWidth: (GLfloat) aLineWidth {
	lineWidth = aLineWidth;
	super.lineWidth = aLineWidth;
}

-(BOOL) shouldSmoothLines { return shouldSmoothLines; }

-(void) setShouldSmoothLines: (BOOL) shouldSmooth {
	shouldSmoothLines = shouldSmooth;
	super.shouldSmoothLines = shouldSmooth;
}

-(GLenum) lineSmoothingHint { return lineSmoothingHint; }

-(void) setLineSmoothingHint: (GLenum) aHint {
	lineSmoothingHint = aHint;
	super.lineSmoothingHint = aHint;
}


#pragma mark Textures

-(GLuint) textureCount { return material ? material.textureCount : 0; }

-(CC3Texture*) texture { return material.texture; }

-(void) setTexture: (CC3Texture*) aTexture {
	if (aTexture) [self ensureMaterial];
	material.texture = aTexture;
	[self alignTextureUnit: 0];
}

-(void) addTexture: (CC3Texture*) aTexture {
	[self ensureMaterial];
	[material addTexture: aTexture];
	GLuint texCount = self.textureCount;
	if (texCount > 0) [self alignTextureUnit: (self.textureCount - 1)];
}

-(void) removeAllTextures { [material removeAllTextures]; }

-(CC3Texture*) textureForTextureUnit: (GLuint) texUnit {
	return [material textureForTextureUnit: texUnit];
}

-(void) setTexture: (CC3Texture*) aTexture forTextureUnit: (GLuint) texUnit {
	[self ensureMaterial];
	[material setTexture: aTexture forTextureUnit: texUnit];
	[self alignTextureUnit: texUnit];
}

-(BOOL) expectsVerticallyFlippedTextures { return mesh.expectsVerticallyFlippedTextures; }

-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	mesh.expectsVerticallyFlippedTextures = expectsFlipped;
	super.expectsVerticallyFlippedTextures = expectsFlipped;
}

-(BOOL) expectsVerticallyFlippedTextureInTextureUnit: (GLuint) texUnit {
	return [mesh expectsVerticallyFlippedTextureInTextureUnit: texUnit];
}

-(void) expectsVerticallyFlippedTexture: (BOOL) expectsFlipped inTextureUnit: (GLuint) texUnit {
	[mesh expectsVerticallyFlippedTexture: expectsFlipped inTextureUnit: texUnit];
}

-(void) alignTextureUnit: (GLuint) texUnit {
	CC3Texture* tex = [self textureForTextureUnit: texUnit];
	[mesh alignTextureUnit: texUnit withTexture: tex];
}

// Deprecated
-(void) alignTextures {
	[mesh deprecatedAlignWithTexturesIn: material];
	[super alignTextures];
}

// Deprecated
-(void) alignInvertedTextures {
	[mesh deprecatedAlignWithInvertedTexturesIn: material];
	[super alignInvertedTextures];
}

-(void) flipVerticallyTextureUnit: (GLuint) texUnit {
	[mesh flipVerticallyTextureUnit: texUnit];
}

-(void) flipTexturesVertically {
	[mesh flipTexturesVertically];
	[super flipTexturesVertically];
}

-(void) flipHorizontallyTextureUnit: (GLuint) texUnit {
	[mesh flipHorizontallyTextureUnit: texUnit];
}

-(void) flipTexturesHorizontally {
	[mesh flipTexturesHorizontally];
	[super flipTexturesHorizontally];
}

-(void) repeatTexture: (ccTex2F) repeatFactor forTextureUnit: (GLuint) texUnit {
	[mesh repeatTexture: repeatFactor forTextureUnit: texUnit];
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

-(BOOL) hasPremultipliedAlpha { return material ? material.hasPremultipliedAlpha : NO; }

-(BOOL) shouldApplyOpacityToColor { return material ? material.shouldApplyOpacityToColor : NO; }


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
		shouldCastShadowsWhenInvisible = NO;
		depthFunction = GL_LEQUAL;
		normalScalingMethod = kCC3NormalScalingAutomatic;
		lineWidth = 1.0f;
		shouldSmoothLines = NO;
		lineSmoothingHint = GL_DONT_CARE;
		shouldApplyOpacityAndColorToMeshContent = NO;
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
	self.material = [another.material autoreleasedCopy];	// retained
	
	pureColor = another.pureColor;
	shouldUseSmoothShading = another.shouldUseSmoothShading;
	shouldCullBackFaces = another.shouldCullBackFaces;
	shouldCullFrontFaces = another.shouldCullFrontFaces;
	shouldUseClockwiseFrontFaceWinding = another.shouldUseClockwiseFrontFaceWinding;
	shouldDisableDepthMask = another.shouldDisableDepthMask;
	shouldDisableDepthTest = another.shouldDisableDepthTest;
	shouldCastShadowsWhenInvisible = another.shouldCastShadowsWhenInvisible;
	depthFunction = another.depthFunction;
	normalScalingMethod = another.normalScalingMethod;
	lineWidth = another.lineWidth;
	shouldSmoothLines = another.shouldSmoothLines;
	lineSmoothingHint = another.lineSmoothingHint;
	shouldApplyOpacityAndColorToMeshContent = another.shouldApplyOpacityAndColorToMeshContent;
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

-(BOOL) isUsingGLBuffers { return mesh.isUsingGLBuffers; }

-(void) releaseRedundantData {
	[mesh releaseRedundantData];
	[super releaseRedundantData];
}

-(void) retainVertexContent {
	[mesh retainVertexContent];
	[super retainVertexContent];
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

-(void) doNotBufferVertexContent {
	[mesh doNotBufferVertexContent];
	[super doNotBufferVertexContent];
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

-(BOOL) isMeshNode { return YES; }


#pragma mark Drawing

-(GLenum) drawingMode { return mesh ? mesh.drawingMode : GL_TRIANGLE_STRIP; }

-(void) setDrawingMode: (GLenum) aMode { mesh.drawingMode = aMode; }

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
	[self configureDecalParameters: visitor];
	[self configureLineProperties: visitor];
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
	gles11ServCaps.cullFace.value = (shouldCullBackFaces || shouldCullFrontFaces);

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

	if (mesh && mesh.hasVertexNormals) {
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

	// If per-vertex coloring is being used, attach it to the material
	gles11Engine.serverCapabilities.colorMaterial.value = (mesh ? mesh.hasVertexColors : NO);
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
 * Template method that establishes the decal offset parameters to cause the depth
 * of the content being drawn to be offset relative to the depth of the content
 * that has already been drawn.
 */
-(void) configureDecalParameters: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	
	BOOL hasDecalOffset = decalOffsetFactor || decalOffsetUnits;
	gles11Engine.serverCapabilities.polygonOffsetFill.value = hasDecalOffset;
	[gles11Engine.state.polygonOffset applyFactor: decalOffsetFactor andUnits: decalOffsetUnits];
}

/** Template method to configure line drawing properties. */
-(void) configureLineProperties: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	gles11Engine.state.lineWidth.value = lineWidth;
	gles11Engine.serverCapabilities.lineSmooth.value = shouldSmoothLines;
	gles11Engine.hints.lineSmooth.value = lineSmoothingHint;
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
	if (visitor.shouldDecorateNode) {
		if (material) {
			[material drawWithVisitor: visitor];
		} else {
			[CC3Material unbind];
			CC3OpenGLES11Engine.engine.state.color.value = pureColor;
		}
	} else {
		[CC3Material unbind];
	}
}

/** Template method to draw the mesh to the GL engine. */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[mesh drawWithVisitor: visitor];
}


#pragma mark Vertex management

-(CC3VertexContent) vertexContentTypes {
	return mesh ? mesh.vertexContentTypes : kCC3VertexContentNone;
}

-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	[self ensureMesh];
	mesh.vertexContentTypes = vtxContentTypes;
	if ( !mesh.hasVertexNormals ) self.shouldUseLighting = NO;
	if ( !mesh.hasVertexTextureCoordinates ) self.texture = nil;
}


#pragma mark Accessing vertex data

-(void) moveMeshOriginTo: (CC3Vector) aLocation {
	[mesh moveMeshOriginTo: aLocation];
	[self markBoundingVolumeDirty];
}

-(void) moveMeshOriginToCenterOfGeometry {
	[mesh moveMeshOriginToCenterOfGeometry];
	[self markBoundingVolumeDirty];
}

// Deprecated methods
-(void) movePivotTo: (CC3Vector) aLocation { [self moveMeshOriginTo: aLocation]; }
-(void) movePivotToCenterOfGeometry { [self moveMeshOriginToCenterOfGeometry]; }

-(GLuint) vertexCount { return mesh ? mesh.vertexCount : 0; }

-(void) setVertexCount: (GLuint) vCount { mesh.vertexCount = vCount; }

-(GLuint) vertexIndexCount { return mesh ? mesh.vertexIndexCount : 0; }

-(void) setVertexIndexCount: (GLuint) vCount { mesh.vertexIndexCount = vCount; }

-(CC3Vector) vertexLocationAt: (GLuint) index {
	return mesh ? [mesh vertexLocationAt: index] : kCC3VectorZero;
}

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index {
	[mesh setVertexLocation: aLocation at: index];
	[self markBoundingVolumeDirty];
}

-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index {
	return mesh ? [mesh vertexHomogeneousLocationAt: index] : kCC3Vector4ZeroLocation;
}

-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index {
	[mesh setVertexHomogeneousLocation: aLocation at: index];
	[self markBoundingVolumeDirty];
}

-(CC3Vector) vertexNormalAt: (GLuint) index {
	return mesh ? [mesh vertexNormalAt: index] : kCC3VectorUnitZPositive;
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index {
	[mesh setVertexNormal: aNormal at: index];
}

-(GLenum) vertexColorType { return mesh ? mesh.vertexColorType : GL_FALSE; }

-(ccColor4F) vertexColor4FAt: (GLuint) index {
	return mesh ? [mesh vertexColor4FAt: index] : kCCC4FBlackTransparent;
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index {
	if (self.shouldApplyOpacityToColor) aColor = CCC4FBlendAlpha(aColor);
	[mesh setVertexColor4F: aColor at: index];
}

-(ccColor4B) vertexColor4BAt: (GLuint) index {
	return mesh ? [mesh vertexColor4BAt: index] : (ccColor4B){ 0, 0, 0, 0 };
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index {
	if (self.shouldApplyOpacityToColor) aColor = CCC4BBlendAlpha(aColor);
	[mesh setVertexColor4B: aColor at: index];
}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index {
	return mesh ? [mesh vertexTexCoord2FForTextureUnit: texUnit at: index] : (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index {
	[mesh setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
}

-(ccTex2F) vertexTexCoord2FAt: (GLuint) index {
	return [self vertexTexCoord2FForTextureUnit: 0 at: index];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: 0 at: index];
}

// Deprecated
-(ccTex2F) vertexTexCoord2FAt: (GLuint) index forTextureUnit: (GLuint) texUnit {
	return [self vertexTexCoord2FForTextureUnit: texUnit at: index];
}

// Deprecated
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLuint) index forTextureUnit: (GLuint) texUnit {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
}

-(GLuint) vertexIndexAt: (GLuint) index { return mesh ? [mesh vertexIndexAt: index] : 0; }

-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index {
	[mesh setVertexIndex: vertexIndex at: index];
}

-(void) updateVertexLocationsGLBuffer { [mesh updateVertexLocationsGLBuffer]; }

-(void) updateVertexNormalsGLBuffer { [mesh updateVertexNormalsGLBuffer]; }

-(void) updateVertexColorsGLBuffer { [mesh updateVertexColorsGLBuffer]; }

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {
	[mesh updateVertexTextureCoordinatesGLBufferForTextureUnit: texUnit];
}

-(void) updateVertexTextureCoordinatesGLBuffer {
	[self updateVertexTextureCoordinatesGLBufferForTextureUnit: 0];
}

-(void) updateGLBuffers { [mesh updateGLBuffers]; }

-(void) updateVertexIndicesGLBuffer { [mesh updateVertexIndicesGLBuffer]; }


#pragma mark Faces

-(BOOL) shouldCacheFaces { return mesh ? mesh.shouldCacheFaces : NO; }

-(void) setShouldCacheFaces: (BOOL) shouldCache {
	mesh.shouldCacheFaces = shouldCache;
	super.shouldCacheFaces = shouldCache;
}

-(GLuint) faceCount {
	return mesh ? mesh.faceCount : 0;
}

-(CC3Face) faceAt: (GLuint) faceIndex {
	return mesh ? [mesh faceAt: faceIndex] : kCC3FaceZero;
}
-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices {
	return mesh ? [mesh faceFromIndices: faceIndices] : kCC3FaceZero;
}

-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex {
	return mesh ? [mesh faceIndicesAt: faceIndex] : kCC3FaceIndicesZero;
}

-(CC3Vector) faceCenterAt: (GLuint) faceIndex {
	return mesh ? [mesh faceCenterAt: faceIndex] : kCC3VectorZero;
}

-(CC3Vector) faceNormalAt: (GLuint) faceIndex {
	return mesh ? [mesh faceNormalAt: faceIndex] : kCC3VectorZero;
}

-(CC3Plane) facePlaneAt: (GLuint) faceIndex {
	return mesh ? [mesh facePlaneAt: faceIndex] : (CC3Plane){ 0.0, 0.0, 0.0, 0.0};
}

-(CC3FaceNeighbours) faceNeighboursAt: (GLuint) faceIndex {
	return mesh ? [mesh faceNeighboursAt: faceIndex] : (CC3FaceNeighbours){{ 0, 0, 0}};
}


-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc {
	if (mesh) return [mesh faceCountFromVertexIndexCount: vc];
	NSAssert(NO, @"%@ has no mesh and cannot convert vertex count to face count.", self);
	return 0;
}

-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc {
	if (mesh) return [mesh vertexIndexCountFromFaceCount: fc];
	NSAssert(NO, @"%@ has no mesh and cannot convert face count to vertex count.", self);
	return 0;
}

// Deprecated
-(GLuint) faceCountFromVertexCount: (GLuint) vc { return [self faceCountFromVertexIndexCount: vc]; }
-(GLuint) vertexCountFromFaceCount: (GLuint) fc { return [self vertexIndexCountFromFaceCount: fc]; }

-(GLuint) findFirst: (GLuint) maxHitCount
	  intersections: (CC3MeshIntersection*) intersections
		 ofLocalRay: (CC3Ray) aRay
	acceptBackFaces: (BOOL) acceptBackFaces
	acceptBehindRay: (BOOL) acceptBehind {
	if ( !mesh ) return 0;
	return [mesh findFirst: maxHitCount
			 intersections: intersections
				ofLocalRay: aRay
		   acceptBackFaces: acceptBackFaces
		   acceptBehindRay: acceptBehind];
}

-(GLuint) findFirst: (GLuint) maxHitCount
globalIntersections: (CC3MeshIntersection*) intersections
		ofGlobalRay: (CC3Ray) aRay
	acceptBackFaces: (BOOL) acceptBackFaces
	acceptBehindRay: (BOOL) acceptBehind {
	if ( !mesh ) return 0;

	// Convert the array to local coordinates and find intersections.
	CC3Ray localRay = [self.transformMatrixInverted transformRay: aRay];
	GLuint hitCount = [self findFirst: maxHitCount
						intersections: intersections
						   ofLocalRay: localRay
					  acceptBackFaces: acceptBackFaces
					  acceptBehindRay: acceptBehind];

	// Convert the intersections to global coordinates.
	for (GLuint hitIdx = 0; hitIdx < hitCount; hitIdx++) {
		CC3MeshIntersection* hit = &intersections[hitIdx];
		hit->location = [self.transformMatrix transformLocation: hit->location];
		hit->distance = CC3VectorDistance(hit->location, aRay.startLocation);
	}

	return hitCount;
}

@end


#pragma mark -
#pragma mark CC3Node extension for mesh nodes

@implementation CC3Node (CC3MeshNode)

-(BOOL) isMeshNode { return NO; }

-(CC3MeshNode*) getMeshNodeNamed: (NSString*) aName {
	CC3Node* retrievedNode = [self getNodeNamed: aName];
	NSAssert1( !retrievedNode || retrievedNode.isMeshNode, @"Retrieved node %@ is not a CC3MeshNode.", retrievedNode);
	return (CC3MeshNode*)retrievedNode;
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
	return CC3PlaneFromLocations(p1, p2, p3);
}

@end


#pragma mark -
#pragma mark CC3BoxNode

@implementation CC3BoxNode
@end


#pragma mark -
#pragma mark CC3LineNode

@implementation CC3LineNode

// Deprecated property
-(GLenum) performanceHint { return self.lineSmoothingHint; }
-(void) setPerformanceHint: (GLenum) aHint { self.lineSmoothingHint = aHint; }

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

-(BOOL) shouldDrawBoundingVolume { return NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {}

/** Overridden so that not touchable unless specifically set as such. */
-(BOOL) isTouchable {
	return (self.visible || shouldAllowTouchableWhenInvisible) && isTouchEnabled;
}

/** Overridden so that can still be visible if parent is invisible, unless explicitly turned off. */
-(BOOL) visible { return visible; }

/** For wireframe lines, if material is created dynamically, make sure it ignores lighting. */
-(void) makeMaterial {
	[super makeMaterial];
	material.shouldUseLighting = NO;
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

-(void) updateFromParentBoundingBox { [self updateFromParentBoundingBoxWithVisitor: nil]; }

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
}

/**
 * Returns the parent's bounding box, or kCC3BoundingBoxZero if no parent,
 * or if parent doesn't have a bounding box.
 */
-(CC3BoundingBox) parentBoundingBox {
	if (parent) {
		CC3BoundingBox pbb = parent.boundingBox;
		if (!CC3BoundingBoxIsNull(pbb)) return pbb;
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

-(CC3Vector) markerDirection { return markerDirection; }

-(void) setMarkerDirection: (CC3Vector) aDirection {
	markerDirection = CC3VectorNormalize(aDirection);
}

-(void) setParent: (CC3Node*) aNode {
	[super setParent: aNode];
	[self updateFromParentBoundingBox];
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
	if (markerAxis == 0.0f) return kCC3MaxGLfloat;
	
	GLfloat scaleToMaxSide = maxBBAxis / markerAxis;
	GLfloat scaleToMinSide = minBBAxis / markerAxis;
	GLfloat minAbsoluteScale = fabsf((maxBBAxis - minBBAxis) / markerAxis) * kCC3DirMarkerMinAbsoluteScale;
	return MAX(MAX(scaleToMaxSide, scaleToMinSide), minAbsoluteScale);
}

// The proportional distance that the direction should protrude from the parent node
static GLfloat directionMarkerScale = 1.5;

+(GLfloat) directionMarkerScale { return directionMarkerScale; }

+(void) setDirectionMarkerScale: (GLfloat) aScale { directionMarkerScale = aScale; }

// The minimum length of a direction marker, in the global coordinate system.
static GLfloat directionMarkerMinimumLength = 0;

+(GLfloat) directionMarkerMinimumLength { return directionMarkerMinimumLength; }

+(void) setDirectionMarkerMinimumLength: (GLfloat) len { directionMarkerMinimumLength = len; }

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
	dirScale = dirScale * [[self class] directionMarkerScale];

	// Ensure that the direction marker has the minimum length specified by directionMarkerMinimumLength
	if (directionMarkerMinimumLength) {
		GLfloat gblUniScale = CC3VectorLength(self.globalScale) / kCC3VectorUnitCubeLength;
		GLfloat minScale = directionMarkerMinimumLength / gblUniScale;
		dirScale = MAX(dirScale, minScale);
	}

	CC3Vector lineEnd = CC3VectorScaleUniform(md, dirScale);
	LogTrace(@"%@ calculated line end %@ from pbb scale %@ and dir scale %.3f and min global length: %.3f", self,
			 NSStringFromCC3Vector(lineEnd), NSStringFromCC3Vector(pbbDirScale), dirScale, directionMarkerMinimumLength);
	return lineEnd;
}

@end


#pragma mark -
#pragma mark CC3BoundingVolumeDisplayNode

@implementation CC3BoundingVolumeDisplayNode

-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

-(BOOL) shouldDrawBoundingVolume { return NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {}

// Overridden so that not touchable unless specifically set as such
-(BOOL) isTouchable {
	return (self.visible || shouldAllowTouchableWhenInvisible) && isTouchEnabled;
}

// Overridden so that can still be visible if parent is invisible, unless explicitly turned off.
-(BOOL) visible { return visible; }
@end


