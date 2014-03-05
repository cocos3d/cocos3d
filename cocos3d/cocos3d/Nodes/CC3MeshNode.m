/*
 * CC3MeshNode.m
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
 * 
 * See header file CC3MeshNode.h for full API documentation.
 */

#import "CC3MeshNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3Mesh.h"
#import "CC3Light.h"
#import "CC3ShaderMatcher.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3OSExtensions.h"


@interface CC3Node (TemplateMethods)
-(void) updateBoundingVolume;
-(void) markBoundingVolumeDirty;
@property(nonatomic, unsafe_unretained, readwrite) CC3Node* parent;
@property(nonatomic, readonly)  BOOL shouldUpdateToTarget;
@end

@interface CC3Mesh (TemplateMethods)
-(void) deprecatedAlignWithTexturesIn: (CC3Material*) aMaterial;
-(void) deprecatedAlignWithInvertedTexturesIn: (CC3Material*) aMaterial;
@end

@implementation CC3MeshNode

@synthesize mesh=_mesh, material=_material, pureColor=_pureColor, lineWidth=_lineWidth;
@synthesize shouldSmoothLines=_shouldSmoothLines, lineSmoothingHint=_lineSmoothingHint;

-(void) dealloc {
	[_mesh release];
	[_material release];
	[_shaderContext release];

	[super dealloc];
}

-(void) setName: (NSString*) aName {
	super.name = aName;
	[_mesh deriveNameFrom: self];
	[_material deriveNameFrom: self];
}

// Sets the name of the mesh if needed and marks the bounding volume as dirty.
-(void) setMesh:(CC3Mesh *) aMesh {
	if (aMesh == _mesh) return;
	
	[_mesh release];
	_mesh = [aMesh retain];
	
	[_mesh deriveNameFrom: self];

	if ( !_mesh.hasVertexNormals ) _material.shouldUseLighting = NO;	// Only if material exists
	if ( !_mesh.hasVertexTextureCoordinates ) _material.texture = nil;	// Only if material exists
	
	[self markBoundingVolumeDirty];
}

/** If a mesh does not yet exist, create it as a CC3Mesh with interleaved vertices. */
-(CC3Mesh*) ensureMesh {
	if ( !_mesh ) self.mesh = [self makeMesh];
	return _mesh;
}

-(CC3Mesh*) makeMesh { return [CC3Mesh mesh]; }

// Support for deprecated CC3MeshModel class
-(CC3Mesh*) meshModel { return self.mesh; }

// Support for deprecated CC3MeshModel class
-(void) setMeshModel: (CC3Mesh*) aMesh { self.mesh = aMesh; }

/**
 * Sets the name of the material if needed, then checks the vertex content types and the
 * alignment of the texture coordinates for each texture unit against the corresponding
 * texture in the material.
 */
-(void) setMaterial: (CC3Material*) aMaterial {
	if (aMaterial == _material) return;
	
	[_material release];
	_material = [aMaterial retain];

	[_material deriveNameFrom: self];

	if ( !_mesh.hasVertexNormals ) _material.shouldUseLighting = NO;
	if ( !_mesh.hasVertexTextureCoordinates ) _material.texture = nil;

	[self alignTextureUnits];
}

-(CC3Material*) ensureMaterial {
	if ( !_material ) self.material = [self makeMaterial];
	return _material;
}

-(CC3Material*) makeMaterial {
	CC3Material* mat = [CC3Material material];
	mat.ambientColor = CCC4FModulate(mat.ambientColor, self.pureColor);
	mat.diffuseColor = CCC4FModulate(mat.diffuseColor, self.pureColor);
	return mat;
}

/**
 * Returns a bounding volume that first checks against the spherical boundary, and then checks
 * against a bounding box. The spherical boundary is fast to check, but is not as accurate as
 * the bounding box for many meshes. The bounding box is more accurate, but is more expensive
 * to check than the spherical boundary. The bounding box is only checked if the spherical
 * boundary does not indicate that the mesh is outside the frustum.
 */
-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	return [CC3NodeSphereThenBoxBoundingVolume boundingVolume];
}

-(BOOL) shouldDrawInClipSpace { return _shouldDrawInClipSpace; }

-(void) setShouldDrawInClipSpace: (BOOL) shouldClip {
	if (shouldClip != _shouldDrawInClipSpace) {
		_shouldDrawInClipSpace = shouldClip;
		
		if (_shouldDrawInClipSpace) {
			[self populateAsCenteredRectangleWithSize: CGSizeMake(2.0f, 2.0f)];
			self.shouldDisableDepthTest = YES;
			self.shouldDisableDepthMask = YES;
			self.shouldUseLighting = NO;
			self.boundingVolume = nil;
		}
	}

	super.shouldDrawInClipSpace = shouldClip;
}

-(BOOL) shouldCullBackFaces { return _shouldCullBackFaces; }

-(void) setShouldCullBackFaces: (BOOL) shouldCull {
	_shouldCullBackFaces = shouldCull;
	super.shouldCullBackFaces = shouldCull;
}

-(BOOL) shouldCullFrontFaces { return _shouldCullFrontFaces; }

-(void) setShouldCullFrontFaces: (BOOL) shouldCull {
	_shouldCullFrontFaces = shouldCull;
	super.shouldCullFrontFaces = shouldCull;
}

-(BOOL) shouldUseClockwiseFrontFaceWinding { return _shouldUseClockwiseFrontFaceWinding; }

-(void) setShouldUseClockwiseFrontFaceWinding: (BOOL) shouldWindCW {
	_shouldUseClockwiseFrontFaceWinding = shouldWindCW;
	super.shouldUseClockwiseFrontFaceWinding = shouldWindCW;
}

-(BOOL) shouldUseSmoothShading { return _shouldUseSmoothShading; }

-(void) setShouldUseSmoothShading: (BOOL) shouldSmooth {
	_shouldUseSmoothShading = shouldSmooth;
	super.shouldUseSmoothShading = shouldSmooth;
}

-(BOOL) shouldCastShadowsWhenInvisible { return _shouldCastShadowsWhenInvisible; }

-(void) setShouldCastShadowsWhenInvisible: (BOOL) shouldCast {
	_shouldCastShadowsWhenInvisible = shouldCast;
	super.shouldCastShadowsWhenInvisible = shouldCast;
}

-(CC3NormalScaling) normalScalingMethod { return _normalScalingMethod; }

-(void) setNormalScalingMethod: (CC3NormalScaling) nsMethod {
	_normalScalingMethod = nsMethod;
	super.normalScalingMethod = nsMethod;
}

-(BOOL) shouldDisableDepthMask { return _shouldDisableDepthMask; }

-(void) setShouldDisableDepthMask: (BOOL) shouldDisable {
	_shouldDisableDepthMask = shouldDisable;
	super.shouldDisableDepthMask = shouldDisable;
}

-(BOOL) shouldDisableDepthTest { return _shouldDisableDepthTest; }

-(void) setShouldDisableDepthTest: (BOOL) shouldDisable {
	_shouldDisableDepthTest = shouldDisable;
	super.shouldDisableDepthTest = shouldDisable;
}

-(GLenum) depthFunction { return (_depthFunction != GL_NEVER) ? _depthFunction : super.depthFunction; }

-(void) setDepthFunction: (GLenum) depthFunc {
	_depthFunction = depthFunc;
	super.depthFunction = depthFunc;
}

-(GLfloat) decalOffsetFactor { return _decalOffsetFactor ? _decalOffsetFactor : super.decalOffsetFactor; }

-(void) setDecalOffsetFactor: (GLfloat) factor {
	_decalOffsetFactor = factor;
	super.decalOffsetFactor = factor;
}

-(GLfloat) decalOffsetUnits { return _decalOffsetUnits ? _decalOffsetUnits : super.decalOffsetUnits; }

-(void) setDecalOffsetUnits: (GLfloat) units {
	_decalOffsetUnits = units;
	super.decalOffsetUnits = units;
}


#pragma mark Materials

-(BOOL) shouldUseLighting { return _material ? _material.shouldUseLighting : NO; }

-(void) setShouldUseLighting: (BOOL) useLighting {
	self.ensureMaterial.shouldUseLighting = useLighting;
	[super setShouldUseLighting: useLighting];	// pass along to any children
}

-(ccColor4F) ambientColor { return self.ensureMaterial.ambientColor; }

-(void) setAmbientColor:(ccColor4F) aColor {
	self.ensureMaterial.ambientColor = aColor;
	[super setAmbientColor: aColor];	// pass along to any children
}

-(ccColor4F) diffuseColor { return self.ensureMaterial.diffuseColor; }

-(void) setDiffuseColor:(ccColor4F) aColor {
	self.ensureMaterial.diffuseColor = aColor;
	[super setDiffuseColor: aColor];	// pass along to any children
}

-(ccColor4F) specularColor { return self.ensureMaterial.specularColor; }

-(void) setSpecularColor:(ccColor4F) aColor {
	self.ensureMaterial.specularColor = aColor;
	[super setSpecularColor: aColor];	// pass along to any children
}

-(ccColor4F) emissionColor { return self.ensureMaterial.emissionColor; }

-(void) setEmissionColor:(ccColor4F) aColor {
	self.ensureMaterial.emissionColor = aColor;
	[super setEmissionColor: aColor];	// pass along to any children
}

-(GLfloat) shininess { return self.ensureMaterial.shininess; }

-(void) setShininess: (GLfloat) shininess {
	self.ensureMaterial.shininess = shininess;
	[super setShininess: shininess];	// pass along to any children
}

-(GLfloat) reflectivity { return self.ensureMaterial.reflectivity; }

-(void) setReflectivity: (GLfloat) reflectivity {
	self.ensureMaterial.reflectivity = reflectivity;
	[super setReflectivity: reflectivity];	// pass along to any children
}

-(CC3Vector4) globalLightPosition {
	return (_material && _material.hasBumpMap)
				? [self.globalTransformMatrix transformHomogeneousVector: CC3Vector4FromDirection(_material.lightDirection)]
				: [super globalLightPosition];
}

-(void) setGlobalLightPosition: (CC3Vector4) aPosition {
	CC3Vector4 localLtPos = [self.globalTransformMatrixInverted transformHomogeneousVector: aPosition];
	self.ensureMaterial.lightDirection = localLtPos.v;
	[super setGlobalLightPosition: aPosition];
}


#pragma mark Shaders

-(CC3ShaderContext*) shaderContext {
	if ( !_shaderContext ) _shaderContext = [CC3ShaderContext new];		// retained - don't use setter
	return _shaderContext;
}

// Set shader context if not the same, and pass along to descendants
-(void) setShaderContext: (CC3ShaderContext*) shaderContext {
	if (shaderContext == _shaderContext) return;

	[_shaderContext release];
	_shaderContext = [shaderContext retain];

	[super setShaderContext: shaderContext];	// pass along to any children
}

#if CC3_GLSL
-(CC3ShaderProgram*) shaderProgram {
	CC3ShaderProgram* sp = self.shaderContext.program;
	if ( !sp ) {
		sp = [CC3ShaderProgram.shaderMatcher programForMeshNode: self];
		self.shaderContext.program = sp;		// Use shaderContext, so doesn't set descendants
		LogRez(@"Shader program %@ automatically selected for %@", sp, self);
	}
	return sp;
}

-(void) setShaderProgram: (CC3ShaderProgram*) shaderProgram {
	self.shaderContext.program = shaderProgram;
	[super setShaderProgram: shaderProgram];	// pass along to any children
}
#else
-(CC3ShaderProgram*) shaderProgram { return nil; }
-(void) setShaderProgram: (CC3ShaderProgram*) shaderProgram {}
#endif	// CC3GLSL

-(CC3ShaderProgram*) selectShaderProgram { return self.shaderProgram; }

-(void) selectShaders {
	[self selectShaderProgram];
	[super selectShaders];
}

-(void) removeLocalShaders { self.shaderProgram = nil; }

-(void) removeShaders {
	[self removeLocalShaders];
	[super removeShaders];
}

// Deprecated
-(void) clearShaderProgram { [self removeLocalShaders]; }


#pragma mark CCRGBAProtocol and CCBlendProtocol support

-(ccColor3B) color { return self.ensureMaterial.color; }

-(void) setColor: (ccColor3B) color {
	self.ensureMaterial.color = color;
	if (_shouldApplyOpacityAndColorToMeshContent) _mesh.color = color;	// for meshes with colored vertices

	_pureColor.r = CCColorFloatFromByte(color.r);
	_pureColor.g = CCColorFloatFromByte(color.g);
	_pureColor.b = CCColorFloatFromByte(color.b);

	[super setColor: color];	// pass along to any children
}

-(GLubyte) opacity { return self.ensureMaterial.opacity; }

-(void) setOpacity: (GLubyte) opacity {
	self.ensureMaterial.opacity = opacity;
	if (_shouldApplyOpacityAndColorToMeshContent) _mesh.opacity = opacity;	// for meshes with colored vertices
	_pureColor.a = CCColorFloatFromByte(opacity);

	[super setOpacity: opacity];	// pass along to any children
}

-(BOOL) shouldBlendAtFullOpacity { return self.ensureMaterial.shouldBlendAtFullOpacity; }

-(void) setShouldBlendAtFullOpacity: (BOOL) shouldBlend {
	self.ensureMaterial.shouldBlendAtFullOpacity = shouldBlend;
	
	[super setShouldBlendAtFullOpacity: shouldBlend];	// pass along to any children
}

-(BOOL) isOpaque { return self.ensureMaterial.isOpaque; }

-(void) setIsOpaque: (BOOL) opaque {
	self.ensureMaterial.isOpaque = opaque;
	if (opaque) _pureColor.a = 1.0f;
	
	[super setIsOpaque: opaque];	// pass along to any children
}

-(ccBlendFunc) blendFunc { return self.ensureMaterial.blendFunc; }

-(void) setBlendFunc: (ccBlendFunc) aBlendFunc {
	self.ensureMaterial.blendFunc = aBlendFunc;
	[super setBlendFunc: aBlendFunc];
}

-(BOOL) shouldDrawLowAlpha { return self.ensureMaterial.shouldDrawLowAlpha; }

-(void) setShouldDrawLowAlpha: (BOOL) shouldDraw {
	self.ensureMaterial.shouldDrawLowAlpha = shouldDraw;
}

-(BOOL) shouldApplyOpacityAndColorToMeshContent { return _shouldApplyOpacityAndColorToMeshContent; }

-(void) setShouldApplyOpacityAndColorToMeshContent: (BOOL) shouldApply {
	_shouldApplyOpacityAndColorToMeshContent = shouldApply;
	super.shouldApplyOpacityAndColorToMeshContent = shouldApply;
}

#pragma mark Line drawing configuration

-(GLfloat) lineWidth { return _lineWidth; }

-(void) setLineWidth: (GLfloat) aLineWidth {
	_lineWidth = aLineWidth;
	super.lineWidth = aLineWidth;
}

-(BOOL) shouldSmoothLines { return _shouldSmoothLines; }

-(void) setShouldSmoothLines: (BOOL) shouldSmooth {
	_shouldSmoothLines = shouldSmooth;
	super.shouldSmoothLines = shouldSmooth;
}

-(GLenum) lineSmoothingHint { return _lineSmoothingHint; }

-(void) setLineSmoothingHint: (GLenum) aHint {
	_lineSmoothingHint = aHint;
	super.lineSmoothingHint = aHint;
}


#pragma mark Textures

-(GLuint) textureCount { return _material ? _material.textureCount : 0; }

-(CC3Texture*) texture { return _material.texture; }

-(void) setTexture: (CC3Texture*) aTexture {
	if (aTexture) [self ensureMaterial];
	_material.texture = aTexture;
	[self alignTextureUnit: 0];
	[super setTexture: aTexture];
}

-(void) addTexture: (CC3Texture*) aTexture {
	[self.ensureMaterial addTexture: aTexture];
	GLuint texCount = self.textureCount;
	if (texCount > 0) [self alignTextureUnit: (self.textureCount - 1)];
	[super addTexture: aTexture];
}

-(void) removeAllTextures { [_material removeAllTextures]; }

-(CC3Texture*) textureForTextureUnit: (GLuint) texUnit {
	return [_material textureForTextureUnit: texUnit];
}

-(void) setTexture: (CC3Texture*) aTexture forTextureUnit: (GLuint) texUnit {
	[self.ensureMaterial setTexture: aTexture forTextureUnit: texUnit];
	[self alignTextureUnit: texUnit];
}

-(BOOL) expectsVerticallyFlippedTextures { return _mesh.expectsVerticallyFlippedTextures; }

-(void) setExpectsVerticallyFlippedTextures: (BOOL) expectsFlipped {
	_mesh.expectsVerticallyFlippedTextures = expectsFlipped;
	super.expectsVerticallyFlippedTextures = expectsFlipped;
}

-(BOOL) expectsVerticallyFlippedTextureInTextureUnit: (GLuint) texUnit {
	return [_mesh expectsVerticallyFlippedTextureInTextureUnit: texUnit];
}

-(void) expectsVerticallyFlippedTexture: (BOOL) expectsFlipped inTextureUnit: (GLuint) texUnit {
	[_mesh expectsVerticallyFlippedTexture: expectsFlipped inTextureUnit: texUnit];
}

-(void) alignTextureUnits {
	GLuint texCount = self.textureCount;
	for (GLuint texUnit = 0; texUnit < texCount; texUnit++) [self alignTextureUnit: texUnit];
}

-(void) alignTextureUnit: (GLuint) texUnit {
	[_mesh alignTextureUnit: texUnit withTexture: [self textureForTextureUnit: texUnit]];
}

// Deprecated
-(void) alignTextures {
	[_mesh deprecatedAlignWithTexturesIn: _material];
	[super alignTextures];
}

// Deprecated
-(void) alignInvertedTextures {
	[_mesh deprecatedAlignWithInvertedTexturesIn: _material];
	[super alignInvertedTextures];
}

-(void) flipVerticallyTextureUnit: (GLuint) texUnit { [_mesh flipVerticallyTextureUnit: texUnit]; }

-(void) flipTexturesVertically {
	[_mesh flipTexturesVertically];
	[super flipTexturesVertically];
}

-(void) flipHorizontallyTextureUnit: (GLuint) texUnit { [_mesh flipHorizontallyTextureUnit: texUnit]; }

-(void) flipTexturesHorizontally {
	[_mesh flipTexturesHorizontally];
	[super flipTexturesHorizontally];
}

-(void) repeatTexture: (ccTex2F) repeatFactor forTextureUnit: (GLuint) texUnit {
	[_mesh repeatTexture: repeatFactor forTextureUnit: texUnit];
}

-(void) repeatTexture: (ccTex2F) repeatFactor { [_mesh repeatTexture: repeatFactor]; }

-(CGRect) textureRectangle { return _mesh ? _mesh.textureRectangle : kCC3UnitTextureRectangle; }

-(void) setTextureRectangle: (CGRect) aRect { _mesh.textureRectangle = aRect; }

-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit {
	return _mesh ? [_mesh textureRectangleForTextureUnit: texUnit] : kCC3UnitTextureRectangle;
}

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {
	[_mesh setTextureRectangle: aRect forTextureUnit: texUnit];
}

-(BOOL) isDrawingPointSprites { return (self.drawingMode == GL_POINTS) && (self.textureCount > 0); }

-(BOOL) hasTextureAlpha { return _material ? _material.hasTextureAlpha : NO; }

-(BOOL) hasTexturePremultipliedAlpha { return _material ? _material.hasTexturePremultipliedAlpha : NO; }

-(BOOL) hasPremultipliedAlpha { return self.hasTexturePremultipliedAlpha; }		// Deprecated

-(BOOL) shouldApplyOpacityToColor { return _material ? _material.shouldApplyOpacityToColor : NO; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_mesh = nil;
		_material = nil;
		_shaderContext = nil;
		_pureColor = kCCC4FWhite;
		_shouldUseSmoothShading = YES;
		_shouldCullBackFaces = YES;
		_shouldCullFrontFaces = NO;
		_shouldUseClockwiseFrontFaceWinding = NO;
		_shouldDisableDepthMask = NO;
		_shouldDisableDepthTest = NO;
		_shouldCastShadowsWhenInvisible = NO;
		_depthFunction = GL_LEQUAL;
		_normalScalingMethod = kCC3NormalScalingAutomatic;
		_lineWidth = 1.0f;
		_shouldSmoothLines = NO;
		_lineSmoothingHint = GL_DONT_CARE;
		_shouldApplyOpacityAndColorToMeshContent = NO;
		_shouldDrawInClipSpace = NO;
	}
	return self;
}

-(void) populateFrom: (CC3MeshNode*) another {
	[super populateFrom: another];
	
	// Don't use setters, to avoid side effects, including to bounding volume and tex coords.
	[_mesh release];
	_mesh = [another.mesh retain];					// retained - Mesh shared between original and copy

	[_material release];
	_material = [another.material copy];			// retained
	
	[_shaderContext release];
	_shaderContext = [another.shaderContext copy];	// retained
	
	_pureColor = another.pureColor;
	_shouldUseSmoothShading = another.shouldUseSmoothShading;
	_shouldCullBackFaces = another.shouldCullBackFaces;
	_shouldCullFrontFaces = another.shouldCullFrontFaces;
	_shouldUseClockwiseFrontFaceWinding = another.shouldUseClockwiseFrontFaceWinding;
	_shouldDisableDepthMask = another.shouldDisableDepthMask;
	_shouldDisableDepthTest = another.shouldDisableDepthTest;
	_shouldCastShadowsWhenInvisible = another.shouldCastShadowsWhenInvisible;
	_depthFunction = another.depthFunction;
	_normalScalingMethod = another.normalScalingMethod;
	_lineWidth = another.lineWidth;
	_shouldSmoothLines = another.shouldSmoothLines;
	_lineSmoothingHint = another.lineSmoothingHint;
	_shouldApplyOpacityAndColorToMeshContent = another.shouldApplyOpacityAndColorToMeshContent;
}

-(void) createGLBuffers {
	LogTrace(@"%@ creating GL server buffers", self);
	[_mesh createGLBuffers];
	[super createGLBuffers];
}

-(void) deleteGLBuffers {
	[_mesh deleteGLBuffers];
	[super deleteGLBuffers];
}

-(BOOL) isUsingGLBuffers { return _mesh.isUsingGLBuffers; }

-(void) releaseRedundantContent {
	[_mesh releaseRedundantContent];
	[super releaseRedundantContent];
}

-(void) retainVertexContent {
	[_mesh retainVertexContent];
	[super retainVertexContent];
}

-(void) retainVertexLocations {
	[_mesh retainVertexLocations];
	[super retainVertexLocations];
}

-(void) retainVertexNormals {
	[_mesh retainVertexNormals];
	[super retainVertexNormals];
}

-(void) retainVertexTangents {
	[_mesh retainVertexTangents];
	[super retainVertexTangents];
}

-(void) retainVertexBitangents {
	[_mesh retainVertexBitangents];
	[super retainVertexBitangents];
}

-(void) retainVertexColors {
	[_mesh retainVertexColors];
	[super retainVertexColors];
}

-(void) retainVertexBoneIndices {
	[_mesh retainVertexBoneIndices];
	[super retainVertexBoneIndices];
}

-(void) retainVertexBoneWeights {
	[_mesh retainVertexBoneWeights];
	[super retainVertexBoneWeights];
}

-(void) retainVertexTextureCoordinates {
	[_mesh retainVertexTextureCoordinates];
	[super retainVertexTextureCoordinates];
}

-(void) retainVertexIndices {
	[_mesh retainVertexIndices];
	[super retainVertexIndices];
}

-(void) doNotBufferVertexContent {
	[_mesh doNotBufferVertexContent];
	[super doNotBufferVertexContent];
}

-(void) doNotBufferVertexLocations {
	[_mesh doNotBufferVertexLocations];
	[super doNotBufferVertexLocations];
}

-(void) doNotBufferVertexNormals {
	[_mesh doNotBufferVertexNormals];
	[super doNotBufferVertexNormals];
}

-(void) doNotBufferVertexTangents {
	[_mesh doNotBufferVertexTangents];
	[super doNotBufferVertexTangents];
}

-(void) doNotBufferVertexBitangents {
	[_mesh doNotBufferVertexBitangents];
	[super doNotBufferVertexBitangents];
}

-(void) doNotBufferVertexColors {
	[_mesh doNotBufferVertexColors];
	[super doNotBufferVertexColors];
}

-(void) doNotBufferVertexBoneIndices {
	[_mesh doNotBufferVertexBoneIndices];
	[super doNotBufferVertexBoneIndices];
}

-(void) doNotBufferVertexBoneWeights {
	[_mesh doNotBufferVertexBoneWeights];
	[super doNotBufferVertexBoneWeights];
}

-(void) doNotBufferVertexTextureCoordinates {
	[_mesh doNotBufferVertexTextureCoordinates];
	[super doNotBufferVertexTextureCoordinates];
}

-(void) doNotBufferVertexIndices {
	[_mesh doNotBufferVertexIndices];
	[super doNotBufferVertexIndices];
}


#pragma mark Type testing

-(BOOL) isMeshNode { return YES; }


#pragma mark Drawing

-(GLenum) drawingMode { return _mesh ? _mesh.drawingMode : GL_TRIANGLES; }

-(void) setDrawingMode: (GLenum) aMode { _mesh.drawingMode = aMode; }

/**
 * Template method that uses template methods to configure drawing parameters
 * and the material, draws the mesh, and cleans up the drawing state.
 */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	[self configureDrawingParameters: visitor];		// Before material is applied.
	[self applyMaterialWithVisitor: visitor];
	[self applyShaderProgramWithVisitor: visitor];

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
	CC3OpenGL* gl = visitor.gl;

	// Enable culling if either back or front should be culled.
	[gl enableCullFace: (_shouldCullBackFaces || _shouldCullFrontFaces)];

	// Set whether back, front or both should be culled.
	// If neither should be culled, handled by capability so leave it as back culling.
	gl.cullFace = _shouldCullBackFaces
						? (_shouldCullFrontFaces ? GL_FRONT_AND_BACK : GL_BACK)
						: (_shouldCullFrontFaces ? GL_FRONT : GL_BACK);

	// If back faces are not being culled, then enable two-sided lighting,
	// so that the lighting of the back faces uses negated normals.
	[gl enableTwoSidedLighting: !_shouldCullBackFaces];
	
	// Set the front face winding
	gl.frontFace = _shouldUseClockwiseFrontFaceWinding ? GL_CW : GL_CCW;
}

/**
 * Template method configures GL scaling of normals, based on
 * whether the scaling of this node is uniform or not.
 */
-(void) configureNormalization: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	switch (self.effectiveNormalScalingMethod) {
		case kCC3NormalScalingNormalize:		// Enable normalizing & disable re-scaling
			[gl enableNormalize: YES];
			[gl enableRescaleNormal: NO];
			break;
		case kCC3NormalScalingRescale:			// Enable rescaling & disable normalizing
			[gl enableNormalize: NO];
			[gl enableRescaleNormal: YES];
			break;
		case kCC3NormalScalingNone:				// Disable both rescaling & normalizing
		default:
			[gl enableNormalize: NO];
			[gl enableRescaleNormal: NO];
			break;
	}
}

-(CC3NormalScaling) effectiveNormalScalingMethod {
	if ( !(_mesh && _mesh.hasVertexNormals) ) return kCC3NormalScalingNone;

	switch (_normalScalingMethod) {
		case kCC3NormalScalingNormalize: return kCC3NormalScalingNormalize;
		case kCC3NormalScalingRescale: return kCC3NormalScalingRescale;
		case kCC3NormalScalingAutomatic:
			if (self.isTransformRigid) return kCC3NormalScalingNone;
			else if (self.isUniformlyScaledGlobally) return kCC3NormalScalingRescale;
			else return kCC3NormalScalingNormalize;
		case kCC3NormalScalingNone:
		default:
			return kCC3NormalScalingNone;
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
	CC3OpenGL* gl = visitor.gl;

	// Set the smoothing model
	gl.shadeModel = _shouldUseSmoothShading ? GL_SMOOTH : GL_FLAT;

	// If per-vertex coloring is being used, attach it to the material
	[gl enableColorMaterial: (visitor.shouldDecorateNode && _mesh && _mesh.hasVertexColors)];
}

/**
 * Template method disables depth testing and/or writing to the depth buffer if the
 * shouldDisableDepthTest and shouldDisableDepthMask property is set to YES, respectively,
 * and set the depth function.
 */
-(void) configureDepthTesting: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	[gl enableDepthTest: !_shouldDisableDepthTest];
	gl.depthMask = !_shouldDisableDepthMask;
	gl.depthFunc = _depthFunction;
}

/**
 * Template method that establishes the decal offset parameters to cause the depth
 * of the content being drawn to be offset relative to the depth of the content
 * that has already been drawn.
 */
-(void) configureDecalParameters: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	BOOL hasDecalOffset = _decalOffsetFactor || _decalOffsetUnits;
	[gl enablePolygonOffset: hasDecalOffset];
	[gl setPolygonOffsetFactor: _decalOffsetFactor units: _decalOffsetUnits];
}

/** Template method to configure line drawing properties. */
-(void) configureLineProperties: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	gl.lineWidth = _lineWidth;
	[gl enableLineSmoothing: _shouldSmoothLines];
	gl.lineSmoothingHint = _lineSmoothingHint;
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

/** 
 * Template method to apply the material and texture properties to the GL engine.
 * The visitor keeps track of which texture unit is being processed, with each texture
 * incrementing the appropriate texture unit counter as it draws. GL texture units that
 * are not used by the textures are disabled.
 */
-(void) applyMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor {

	[self updateLightPosition];
	
	[visitor resetTextureUnits];
	
	if (_material && visitor.shouldDecorateNode) {
		[_material drawWithVisitor: visitor];
	} else {
		[CC3Material unbindWithVisitor: visitor];
		if (visitor.shouldDecorateNode) visitor.currentColor = _pureColor;
	}

	[visitor disableUnusedTextureUnits];

	// currentColor can be set by material, mesh node, or node picking visitor prior to this method.
	visitor.gl.color = visitor.currentColor;
}

/** Checks if this node is tracking a global light position (for bump mapping) and update if needed. */
-(void) updateLightPosition {
	if (self.shouldUpdateToTarget && self.isTrackingForBumpMapping)
		self.globalLightPosition = self.target.globalHomogeneousPosition;
}

-(void) applyShaderProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.currentShaderProgram bindWithVisitor: visitor];
}

/** Template method to draw the mesh to the GL engine. */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor { [_mesh drawWithVisitor: visitor]; }


#pragma mark Vertex management

-(CC3VertexContent) vertexContentTypes { return _mesh ? _mesh.vertexContentTypes : kCC3VertexContentNone; }

-(void) setVertexContentTypes: (CC3VertexContent) vtxContentTypes {
	[self ensureMesh];
	_mesh.vertexContentTypes = vtxContentTypes;
	if ( !_mesh.hasVertexNormals ) _material.shouldUseLighting = NO;	// Only if material exists
	if ( !_mesh.hasVertexTextureCoordinates ) _material.texture = nil;	// Only if material exists
}


#pragma mark Accessing vertex data

-(CC3Vector) centerOfGeometry {
	return _children ? super.centerOfGeometry : self.localContentCenterOfGeometry;
}

-(CC3Vector) localContentCenterOfGeometry {
	return _mesh ? _mesh.centerOfGeometry : kCC3VectorZero;
}

-(CC3Box) localContentBoundingBox {
	return _mesh
			? CC3BoxAddUniformPadding(_mesh.boundingBox, _boundingVolumePadding)
			: kCC3BoxNull;
}

-(void) moveMeshOriginTo: (CC3Vector) aLocation {
	[_mesh moveMeshOriginTo: aLocation];
	[self markBoundingVolumeDirty];
}

-(void) moveMeshOriginToCenterOfGeometry {
	[_mesh moveMeshOriginToCenterOfGeometry];
	[self markBoundingVolumeDirty];
}

// Deprecated methods
-(void) movePivotTo: (CC3Vector) aLocation { [self moveMeshOriginTo: aLocation]; }
-(void) movePivotToCenterOfGeometry { [self moveMeshOriginToCenterOfGeometry]; }

-(GLuint) vertexCount { return _mesh ? _mesh.vertexCount : 0; }

-(void) setVertexCount: (GLuint) vCount { _mesh.vertexCount = vCount; }

-(GLuint) vertexIndexCount { return _mesh ? _mesh.vertexIndexCount : 0; }

-(void) setVertexIndexCount: (GLuint) vCount { _mesh.vertexIndexCount = vCount; }

-(CC3Vector) vertexLocationAt: (GLuint) index {
	return _mesh ? [_mesh vertexLocationAt: index] : kCC3VectorZero;
}

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLuint) index {
	[_mesh setVertexLocation: aLocation at: index];
	[self markBoundingVolumeDirty];
}

-(CC3Vector4) vertexHomogeneousLocationAt: (GLuint) index {
	return _mesh ? [_mesh vertexHomogeneousLocationAt: index] : kCC3Vector4ZeroLocation;
}

-(void) setVertexHomogeneousLocation: (CC3Vector4) aLocation at: (GLuint) index {
	[_mesh setVertexHomogeneousLocation: aLocation at: index];
	[self markBoundingVolumeDirty];
}

-(CC3Vector) vertexNormalAt: (GLuint) index {
	return _mesh ? [_mesh vertexNormalAt: index] : kCC3VectorUnitZPositive;
}

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLuint) index {
	[_mesh setVertexNormal: aNormal at: index];
}

-(void) flipNormals {
	[_mesh flipNormals];
	[super flipNormals];
}

-(CC3Vector) vertexTangentAt: (GLuint) index {
	return _mesh ? [_mesh vertexTangentAt: index] : kCC3VectorUnitXPositive;
}

-(void) setVertexTangent: (CC3Vector) aTangent at: (GLuint) index {
	[_mesh setVertexTangent: aTangent at: index];
}

-(CC3Vector) vertexBitangentAt: (GLuint) index {
	return _mesh ? [_mesh vertexBitangentAt: index] : kCC3VectorUnitYPositive;
}

-(void) setVertexBitangent: (CC3Vector) aTangent at: (GLuint) index {
	[_mesh setVertexBitangent: aTangent at: index];
}

-(GLenum) vertexColorType { return _mesh ? _mesh.vertexColorType : GL_FALSE; }

-(ccColor4F) vertexColor4FAt: (GLuint) index {
	return _mesh ? [_mesh vertexColor4FAt: index] : kCCC4FBlackTransparent;
}

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLuint) index {
	if (self.shouldApplyOpacityToColor) aColor = CCC4FBlendAlpha(aColor);
	[_mesh setVertexColor4F: aColor at: index];
}

-(ccColor4B) vertexColor4BAt: (GLuint) index {
	return _mesh ? [_mesh vertexColor4BAt: index] : (ccColor4B){ 0, 0, 0, 0 };
}

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLuint) index {
	if (self.shouldApplyOpacityToColor) aColor = CCC4BBlendAlpha(aColor);
	[_mesh setVertexColor4B: aColor at: index];
}

-(GLuint) vertexBoneCount { return _mesh ? _mesh.vertexBoneCount : 0; }

-(GLfloat) vertexWeightForBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex {
	return _mesh ? [_mesh vertexWeightForBoneInfluence: influenceIndex at: vtxIndex] : 0.0f;
}

-(void) setVertexWeight: (GLfloat) weight forBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex {
	[_mesh setVertexWeight: weight forBoneInfluence: influenceIndex at: vtxIndex];
}

-(GLfloat*) vertexBoneWeightsAt: (GLuint) vtxIndex { return _mesh ? [_mesh vertexBoneWeightsAt: vtxIndex] : NULL; }

-(void) setVertexBoneWeights: (GLfloat*) weights at: (GLuint) vtxIndex {
	[_mesh setVertexBoneWeights: weights at: vtxIndex];
}

-(GLuint) vertexBoneIndexForBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex {
	return _mesh ? [_mesh vertexBoneIndexForBoneInfluence: influenceIndex at: vtxIndex] : 0;
}

-(void) setVertexBoneIndex: (GLuint) boneIndex forBoneInfluence: (GLuint) influenceIndex at: (GLuint) vtxIndex {
	[_mesh setVertexBoneIndex: boneIndex forBoneInfluence: influenceIndex at: vtxIndex];
}

-(GLvoid*) vertexBoneIndicesAt: (GLuint) vtxIndex {
	return _mesh ? [_mesh vertexBoneIndicesAt: vtxIndex] : NULL;
}

-(void) setVertexBoneIndices: (GLvoid*) boneIndices at: (GLuint) vtxIndex {
	[_mesh setVertexBoneIndices: boneIndices at: vtxIndex];
}

-(GLenum) vertexBoneIndexType { return _mesh.vertexBoneIndexType; }

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLuint) index {
	return _mesh ? [_mesh vertexTexCoord2FForTextureUnit: texUnit at: index] : (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLuint) index {
	[_mesh setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
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

-(GLuint) vertexIndexAt: (GLuint) index { return _mesh ? [_mesh vertexIndexAt: index] : 0; }

-(void) setVertexIndex: (GLuint) vertexIndex at: (GLuint) index {
	[_mesh setVertexIndex: vertexIndex at: index];
}

-(void) updateVertexLocationsGLBuffer { [_mesh updateVertexLocationsGLBuffer]; }

-(void) updateVertexNormalsGLBuffer { [_mesh updateVertexNormalsGLBuffer]; }

-(void) updateVertexTangentsGLBuffer { [_mesh updateVertexTangentsGLBuffer]; }

-(void) updateVertexBitangentsGLBuffer { [_mesh updateVertexBitangentsGLBuffer]; }

-(void) updateVertexColorsGLBuffer { [_mesh updateVertexColorsGLBuffer]; }

-(void) updateVertexBoneWeightsGLBuffer { [_mesh updateVertexBoneWeightsGLBuffer]; }

-(void) updateVertexBoneIndicesGLBuffer { [_mesh updateVertexBoneIndicesGLBuffer]; }

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {
	[_mesh updateVertexTextureCoordinatesGLBufferForTextureUnit: texUnit];
}

-(void) updateVertexTextureCoordinatesGLBuffer {
	[self updateVertexTextureCoordinatesGLBufferForTextureUnit: 0];
}

-(void) updateGLBuffers { [_mesh updateGLBuffers]; }

-(void) updateVertexIndicesGLBuffer { [_mesh updateVertexIndicesGLBuffer]; }


#pragma mark Faces

-(BOOL) shouldCacheFaces { return _mesh ? _mesh.shouldCacheFaces : NO; }

-(void) setShouldCacheFaces: (BOOL) shouldCache {
	_mesh.shouldCacheFaces = shouldCache;
	super.shouldCacheFaces = shouldCache;
}

-(GLuint) faceCount { return _mesh ? _mesh.faceCount : 0; }

-(CC3Face) faceAt: (GLuint) faceIndex {
	return _mesh ? [_mesh faceAt: faceIndex] : kCC3FaceZero;
}
-(CC3Face) faceFromIndices: (CC3FaceIndices) faceIndices {
	return _mesh ? [_mesh faceFromIndices: faceIndices] : kCC3FaceZero;
}

-(CC3FaceIndices) faceIndicesAt: (GLuint) faceIndex {
	return _mesh ? [_mesh faceIndicesAt: faceIndex] : kCC3FaceIndicesZero;
}

-(CC3Vector) faceCenterAt: (GLuint) faceIndex {
	return _mesh ? [_mesh faceCenterAt: faceIndex] : kCC3VectorZero;
}

-(CC3Vector) faceNormalAt: (GLuint) faceIndex {
	return _mesh ? [_mesh faceNormalAt: faceIndex] : kCC3VectorZero;
}

-(CC3Plane) facePlaneAt: (GLuint) faceIndex {
	return _mesh ? [_mesh facePlaneAt: faceIndex] : (CC3Plane){ 0.0, 0.0, 0.0, 0.0};
}

-(CC3FaceNeighbours) faceNeighboursAt: (GLuint) faceIndex {
	return _mesh ? [_mesh faceNeighboursAt: faceIndex] : (CC3FaceNeighbours){{ 0, 0, 0}};
}


-(GLuint) faceCountFromVertexIndexCount: (GLuint) vc {
	if (_mesh) return [_mesh faceCountFromVertexIndexCount: vc];
	CC3Assert(NO, @"%@ has no mesh and cannot convert vertex count to face count.", self);
	return 0;
}

-(GLuint) vertexIndexCountFromFaceCount: (GLuint) fc {
	if (_mesh) return [_mesh vertexIndexCountFromFaceCount: fc];
	CC3Assert(NO, @"%@ has no mesh and cannot convert face count to vertex count.", self);
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
	if ( !_mesh ) return 0;
	return [_mesh findFirst: maxHitCount
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
	if ( !_mesh ) return 0;

	// Convert the array to local coordinates and find intersections.
	CC3Ray localRay = [self.globalTransformMatrixInverted transformRay: aRay];
	GLuint hitCount = [self findFirst: maxHitCount
						intersections: intersections
						   ofLocalRay: localRay
					  acceptBackFaces: acceptBackFaces
					  acceptBehindRay: acceptBehind];

	// Convert the intersections to global coordinates.
	for (GLuint hitIdx = 0; hitIdx < hitCount; hitIdx++) {
		CC3MeshIntersection* hit = &intersections[hitIdx];
		hit->location = [self.globalTransformMatrix transformLocation: hit->location];
		hit->distance = CC3VectorDistance(hit->location, aRay.startLocation);
	}

	return hitCount;
}

-(GLuint) vertexUnitCount { return self.vertexBoneCount; }

-(GLfloat) vertexWeightForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return _mesh ? [_mesh vertexWeightForVertexUnit: vertexUnit at: index] : 0.0f;
}

-(void) setVertexWeight: (GLfloat) aWeight forVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	[_mesh setVertexWeight: aWeight forVertexUnit: vertexUnit at: index];
}

-(GLfloat*) vertexWeightsAt: (GLuint) index { return _mesh ? [_mesh vertexWeightsAt: index] : NULL; }

-(void) setVertexWeights: (GLfloat*) weights at: (GLuint) index {
	[_mesh setVertexWeights: weights at: index];
}

-(GLuint) vertexMatrixIndexForVertexUnit: (GLuint) vertexUnit at: (GLuint) index {
	return _mesh ? [_mesh vertexMatrixIndexForVertexUnit: vertexUnit at: index] : 0;
}

-(void) setVertexMatrixIndex: (GLuint) aMatrixIndex
			   forVertexUnit: (GLuint) vertexUnit
						  at: (GLuint) index {
	[_mesh setVertexMatrixIndex: aMatrixIndex forVertexUnit: vertexUnit at: index];
}

-(GLvoid*) vertexMatrixIndicesAt: (GLuint) index {
	return _mesh ? [_mesh vertexMatrixIndicesAt: index] : NULL;
}

-(void) setVertexMatrixIndices: (GLvoid*) mtxIndices at: (GLuint) index {
	[_mesh setVertexMatrixIndices: mtxIndices at: index];
}

-(GLenum) matrixIndexType { return _mesh.matrixIndexType; }

-(void) updateVertexWeightsGLBuffer { [self updateVertexBoneWeightsGLBuffer]; }

-(void) updateVertexMatrixIndicesGLBuffer { [self updateVertexBoneIndicesGLBuffer]; }

@end


#pragma mark -
#pragma mark CC3Node extension for mesh nodes

@implementation CC3Node (CC3MeshNode)

-(BOOL) isMeshNode { return NO; }

-(CC3MeshNode*) getMeshNodeNamed: (NSString*) aName {
	CC3Node* retrievedNode = [self getNodeNamed: aName];
	CC3Assert( !retrievedNode || retrievedNode.isMeshNode, @"Retrieved node %@ is not a CC3MeshNode.", retrievedNode);
	return (CC3MeshNode*)retrievedNode;
}

@end


