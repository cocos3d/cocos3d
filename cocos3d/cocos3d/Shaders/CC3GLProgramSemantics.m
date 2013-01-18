/*
 * CC3GLProgramSemantics.m
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
 * 
 * See header file CC3GLProgramSemantics.h for full API documentation.
 */

#import "CC3GLProgramSemantics.h"
#import "CC3GLSLVariable.h"
#import "CC3OpenGLESEngine.h"
#import "CC3NodeVisitor.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3Scene.h"
#import "CC3PointParticles.h"
#import "CC3NodeAnimation.h"


NSString* NSStringFromCC3Semantic(CC3Semantic semantic) {
	switch (semantic) {
		case kCC3SemanticNone: return @"kCC3SemanticNone";

		// VERTEX CONTENT --------------
		case kCC3SemanticVertexLocation: return @"kCC3SemanticVertexLocation";
		case kCC3SemanticVertexNormal: return @"kCC3SemanticVertexNormal";
		case kCC3SemanticVertexTangent: return @"kCC3SemanticVertexTangent";
		case kCC3SemanticVertexBitangent: return @"kCC3SemanticVertexBitangent";
		case kCC3SemanticVertexColor: return @"kCC3SemanticVertexColor";
		case kCC3SemanticVertexPointSize: return @"kCC3SemanticVertexPointSize";
		case kCC3SemanticVertexWeight: return @"kCC3SemanticVertexWeight";
		case kCC3SemanticVertexMatrix: return @"kCC3SemanticVertexMatrix";
		case kCC3SemanticVertexTexture: return @"kCC3SemanticVertexTexture";
			
		case kCC3SemanticHasVertexNormal: return @"kCC3SemanticHasVertexNormal";
		case kCC3SemanticShouldNormalizeVertexNormal: return @"kCC3SemanticShouldNormalizeVertexNormal";
		case kCC3SemanticShouldRescaleVertexNormal: return @"kCC3SemanticShouldRescaleVertexNormal";
		case kCC3SemanticHasVertexTangent: return @"kCC3SemanticHasVertexTangent";
		case kCC3SemanticHasVertexBitangent: return @"kCC3SemanticHasVertexBitangent";
		case kCC3SemanticHasVertexColor: return @"kCC3SemanticHasVertexColor";
		case kCC3SemanticHasVertexTextureCoordinate: return @"kCC3SemanticHasVertexTextureCoordinate";
		case kCC3SemanticHasVertexPointSize: return @"kCC3SemanticHasVertexPointSize";
		case kCC3SemanticIsDrawingPoints: return @"kCC3SemanticIsDrawingPoints";

		// ENVIRONMENT MATRICES --------------
		case kCC3SemanticModelLocalMatrix: return @"kCC3SemanticModelLocalMatrix";
		case kCC3SemanticModelLocalMatrixInv: return @"kCC3SemanticModelLocalMatrixInv";
		case kCC3SemanticModelLocalMatrixInvTran: return @"kCC3SemanticModelLocalMatrixInvTran";
		case kCC3SemanticModelMatrix: return @"kCC3SemanticModelMatrix";
		case kCC3SemanticModelMatrixInv: return @"kCC3SemanticModelMatrixInv";
		case kCC3SemanticModelMatrixInvTran: return @"kCC3SemanticModelMatrixInvTran";
		case kCC3SemanticViewMatrix: return @"kCC3SemanticViewMatrix";
		case kCC3SemanticViewMatrixInv: return @"kCC3SemanticViewMatrixInv";
		case kCC3SemanticViewMatrixInvTran: return @"kCC3SemanticViewMatrixInvTran";
		case kCC3SemanticModelViewMatrix: return @"kCC3SemanticModelViewMatrix";
		case kCC3SemanticModelViewMatrixInv: return @"kCC3SemanticModelViewMatrixInv";
		case kCC3SemanticModelViewMatrixInvTran: return @"kCC3SemanticModelViewMatrixInvTran";
		case kCC3SemanticProjMatrix: return @"kCC3SemanticProjMatrix";
		case kCC3SemanticProjMatrixInv: return @"kCC3SemanticProjMatrixInv";
		case kCC3SemanticProjMatrixInvTran: return @"kCC3SemanticProjMatrixInvTran";
		case kCC3SemanticViewProjMatrix: return @"kCC3SemanticViewProjMatrix";
		case kCC3SemanticViewProjMatrixInv: return @"kCC3SemanticViewProjMatrixInv";
		case kCC3SemanticViewProjMatrixInvTran: return @"kCC3SemanticViewProjMatrixInvTran";
		case kCC3SemanticModelViewProjMatrix: return @"kCC3SemanticModelViewProjMatrix";
		case kCC3SemanticModelViewProjMatrixInv: return @"kCC3SemanticModelViewProjMatrixInv";
		case kCC3SemanticModelViewProjMatrixInvTran: return @"kCC3SemanticModelViewProjMatrixInvTran";
			
		// CAMERA -----------------
		case kCC3SemanticCameraLocationModelSpace: return @"kCC3SemanticCameraLocationModelSpace";
		case kCC3SemanticCameraLocationGlobal: return @"kCC3SemanticCameraLocationGlobal";
		case kCC3SemanticCameraFrustum: return @"kCC3SemanticCameraFrustum";

			
		// MATERIALS --------------
		case kCC3SemanticColor: return @"kCC3SemanticColor";
		case kCC3SemanticMaterialColorAmbient: return @"kCC3SemanticMaterialColorAmbient";
		case kCC3SemanticMaterialColorDiffuse: return @"kCC3SemanticMaterialColorDiffuse";
		case kCC3SemanticMaterialColorSpecular: return @"kCC3SemanticMaterialColorSpecular";
		case kCC3SemanticMaterialColorEmission: return @"kCC3SemanticMaterialColorEmission";
		case kCC3SemanticMaterialOpacity: return @"kCC3SemanticMaterialOpacity";
		case kCC3SemanticMaterialShininess: return @"kCC3SemanticMaterialShininess";

		// LIGHTING --------------
		case kCC3SemanticIsUsingLighting: return @"kCC3SemanticIsUsingLighting";
		case kCC3SemanticSceneLightColorAmbient: return @"kCC3SemanticSceneLightColorAmbient";

		case kCC3SemanticLightIsEnabled: return @"kCC3SemanticLightIsEnabled";
		case kCC3SemanticLightLocationModelSpace: return @"kCC3SemanticLightLocationModelSpace";
		case kCC3SemanticLightLocationGlobal: return @"kCC3SemanticLightLocationGlobal";
		case kCC3SemanticLightLocationEyeSpace: return @"kCC3SemanticLightLocationEyeSpace";
		case kCC3SemanticLightColorAmbient: return @"kCC3SemanticLightColorAmbient";
		case kCC3SemanticLightColorDiffuse: return @"kCC3SemanticLightColorDiffuse";
		case kCC3SemanticLightColorSpecular: return @"kCC3SemanticLightColorSpecular";
		case kCC3SemanticLightAttenuation: return @"kCC3SemanticLightAttenuation";
		case kCC3SemanticLightSpotDirectionGlobal: return @"kCC3SemanticLightSpotDirectionGlobal";
		case kCC3SemanticLightSpotDirectionEyeSpace: return @"kCC3SemanticLightSpotDirectionEyeSpace";
		case kCC3SemanticLightSpotDirectionModelSpace: return @"kCC3SemanticLightSpotDirectionModelSpace";
		case kCC3SemanticLightSpotExponent: return @"kCC3SemanticLightSpotExponent";
		case kCC3SemanticLightSpotCutoffAngle: return @"kCC3SemanticLightSpotCutoffAngle";
		case kCC3SemanticLightSpotCutoffAngleCosine: return @"kCC3SemanticLightSpotCutoffAngleCosine";
			
		// TEXTURES --------------
		case kCC3SemanticTextureCount: return @"kCC3SemanticTextureCount";
		case kCC3SemanticTextureSampler: return @"kCC3SemanticTextureSampler";

		case kCC3SemanticTexUnitMode: return @"kCC3SemanticTexUnitMode";
		case kCC3SemanticTexUnitConstantColor: return @"kCC3SemanticTexUnitConstantColor";
		case kCC3SemanticTexUnitCombineRGBFunction: return @"kCC3SemanticTexUnitCombineRGBFunction";
		case kCC3SemanticTexUnitSource0RGB: return @"kCC3SemanticTexUnitSource0RGB";
		case kCC3SemanticTexUnitSource1RGB: return @"kCC3SemanticTexUnitSource1RGB";
		case kCC3SemanticTexUnitSource2RGB: return @"kCC3SemanticTexUnitSource2RGB";
		case kCC3SemanticTexUnitOperand0RGB: return @"kCC3SemanticTexUnitOperand0RGB";
		case kCC3SemanticTexUnitOperand1RGB: return @"kCC3SemanticTexUnitOperand1RGB";
		case kCC3SemanticTexUnitOperand2RGB: return @"kCC3SemanticTexUnitOperand2RGB";
		case kCC3SemanticTexUnitCombineAlphaFunction: return @"kCC3SemanticTexUnitCombineAlphaFunction";
		case kCC3SemanticTexUnitSource0Alpha: return @"kCC3SemanticTexUnitSource0Alpha";
		case kCC3SemanticTexUnitSource1Alpha: return @"kCC3SemanticTexUnitSource1Alpha";
		case kCC3SemanticTexUnitSource2Alpha: return @"kCC3SemanticTexUnitSource2Alpha";
		case kCC3SemanticTexUnitOperand0Alpha: return @"kCC3SemanticTexUnitOperand0Alpha";
		case kCC3SemanticTexUnitOperand1Alpha: return @"kCC3SemanticTexUnitOperand1Alpha";
		case kCC3SemanticTexUnitOperand2Alpha: return @"kCC3SemanticTexUnitOperand2Alpha";
			
		// MODEL ----------------
		case kCC3SemanticAnimationFraction: return @"kCC3SemanticAnimationFraction";
		case kCC3SemanticCenterOfGeometry: return @"kCC3SemanticCenterOfGeometry";
		case kCC3SemanticBoundingBoxMin: return @"kCC3SemanticBoundingBoxMin";
		case kCC3SemanticBoundingBoxMax: return @"kCC3SemanticBoundingBoxMax";
		case kCC3SemanticBoundingBoxSize: return @"kCC3SemanticBoundingBoxSize";
		case kCC3SemanticBoundingRadius: return @"kCC3SemanticBoundingRadius";

		// PARTICLES ------------
		case kCC3SemanticPointSize: return @"kCC3SemanticPointSize";
		case kCC3SemanticPointSizeAttenuation: return @"kCC3SemanticPointSizeAttenuation";
		case kCC3SemanticPointSizeMinimum: return @"kCC3SemanticPointSizeMinimum";
		case kCC3SemanticPointSizeMaximum: return @"kCC3SemanticPointSizeMaximum";
		case kCC3SemanticPointSizeFadeThreshold: return @"kCC3SemanticPointSizeFadeThreshold";
		case kCC3SemanticPointSpritesIsEnabled: return @"kCC3SemanticPointSpritesIsEnabled";
			
		// TIME ------------------
		case kCC3SemanticFrameTime: return @"kCC3SemanticFrameTime";
			
		case kCC3SemanticApplicationTime: return @"kCC3SemanticApplicationTime";
		case kCC3SemanticApplicationTimeSine: return @"kCC3SemanticApplicationTimeSine";
		case kCC3SemanticApplicationTimeCosine: return @"kCC3SemanticApplicationTimeCosine";
		case kCC3SemanticApplicationTimeTangent: return @"kCC3SemanticApplicationTimeTangent";

		// MISC ENVIRONMENT ---------
		case kCC3SemanticViewport: return @"kCC3SemanticViewport";
		case kCC3SemanticDrawCountCurrentFrame: return @"kCC3SemanticDrawCountCurrentFrame";
		case kCC3SemanticRandomNumber: return @"kCC3SemanticRandomNumber";
			
		case kCC3SemanticAppBase: return @"kCC3SemanticAppBase";
		case kCC3SemanticMax: return @"kCC3SemanticMax";
		default: return [NSString stringWithFormat: @"Unknown state semantic (%u)", semantic];
	}
}


#pragma mark -
#pragma mark CC3GLSLVariableConfiguration

@implementation CC3GLSLVariableConfiguration

@synthesize name=_name, semantic=_semantic, semanticIndex=_semanticIndex;

-(void) dealloc {
	[_name release];
	[super dealloc];
}

-(id) init {
	if ( (self = [super init]) ) {
		_name = nil;
		_semantic = kCC3SemanticNone;
		_semanticIndex = 0;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsBase

@implementation CC3GLProgramSemanticsBase

+(id) semanticsDelegate { return [[[self alloc] init] autorelease]; }

-(NSString*) nameOfSemantic: (GLenum) semantic { return NSStringFromCC3Semantic(semantic); }

-(BOOL) configureVariable: (CC3GLSLVariable*) variable { return NO; }

/**
 * For semantics that may have more than one target, such as components of lights, or textures,
 * the iteration loops in this method are designed to deal with two situations:
 *   - If the uniform is declared as an array of single types (eg- an array of floats, bools, or
 *     vec3's), the uniform semantic index will be zero and the uniform size will be larger than one.
 *   - If the uniform is declared as an element of a structure in an array (eg- a vec3 in a structure
 *     that is itself contained in an array, the uniform size will be one, but the uniform semantic
 *     index can be larger than zero.
 */
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ retrieving semantic value for %@", self, uniform.fullDescription);
	CC3OpenGLESEngine* glesEngine = CC3OpenGLESEngine.engine;
	CC3OpenGLESLight* glesLight;
	CC3OpenGLESTextureUnit* glesTexUnit;
	GLenum semantic = uniform.semantic;
	GLuint semanticIndex = uniform.semanticIndex;
	GLint uniformSize = uniform.size;
	CC3Matrix4x3 m4x3, pntInvMtx, nodeMtx;
	CC3Matrix4x3* pMtx4x3;
	CC3Matrix3x3 m3x3;
	CC3Viewport vp;
	ccTime appTime;
	
	switch (semantic) {
		
		// ATTRIBUTE QUALIFIERS --------------
		case kCC3SemanticHasVertexNormal:
			[uniform setBoolean: visitor.currentMesh.hasVertexNormals];
			return YES;
		case kCC3SemanticShouldNormalizeVertexNormal:
			[uniform setBoolean: glesEngine.capabilities.normalize.value];
			return YES;
		case kCC3SemanticShouldRescaleVertexNormal:
			[uniform setBoolean: glesEngine.capabilities.rescaleNormal.value];
			return YES;
		case kCC3SemanticHasVertexTangent:
			[uniform setBoolean: visitor.currentMesh.hasVertexTangents];
			return YES;
		case kCC3SemanticHasVertexBitangent:
			[uniform setBoolean: visitor.currentMesh.hasVertexBitangents];
			return YES;
		case kCC3SemanticHasVertexColor:
			[uniform setBoolean: visitor.currentMesh.hasVertexColors];
			return YES;
		case kCC3SemanticHasVertexTextureCoordinate:
			[uniform setBoolean: visitor.currentMesh.hasVertexTextureCoordinates];
			return YES;
		case kCC3SemanticHasVertexPointSize:
			[uniform setBoolean: visitor.currentMesh.hasVertexPointSizes];
			return YES;
		case kCC3SemanticIsDrawingPoints:
			[uniform setBoolean: visitor.currentMeshNode.drawingMode == GL_POINTS];
			return YES;

		// ENVIRONMENT MATRICES --------------
		case kCC3SemanticModelLocalMatrix:
			// Get local matrix as P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.transformMatrixInverted populateCC3Matrix4x3: &pntInvMtx];
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x3: &nodeMtx];
			CC3Matrix4x3Multiply(&m4x3, &pntInvMtx, &nodeMtx);
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticModelLocalMatrixInv:
			// Get local matrix as P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.transformMatrixInverted populateCC3Matrix4x3: &pntInvMtx];
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x3: &nodeMtx];
			CC3Matrix4x3Multiply(&m4x3, &pntInvMtx, &nodeMtx);
			// Now invert
			CC3Matrix4x3InvertAdjoint(&m4x3);
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticModelLocalMatrixInvTran:
			// Get local matrix as P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.transformMatrixInverted populateCC3Matrix4x3: &pntInvMtx];
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x3: &nodeMtx];
			CC3Matrix4x3Multiply(&m4x3, &pntInvMtx, &nodeMtx);
			// Now take inverse-transpose
			CC3Matrix3x3PopulateFrom4x3(&m3x3, &m4x3);
			CC3Matrix3x3InvertAdjoint(&m3x3);
			CC3Matrix3x3Transpose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;

		case kCC3SemanticModelMatrix:
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x3: &m4x3];
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticModelMatrixInv:
			[visitor.currentMeshNode.transformMatrixInverted populateCC3Matrix4x3: &m4x3];
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticModelMatrixInvTran:
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix3x3: &m3x3];
			CC3Matrix3x3InvertAdjoint(&m3x3);
			CC3Matrix3x3Transpose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;

		case kCC3SemanticViewMatrix:
			[uniform setMatrix4x3: [glesEngine.matrices matrix4x3ForSemantic: kCC3MatrixSemanticView]];
			return YES;
		case kCC3SemanticViewMatrixInv:
			[uniform setMatrix4x3: [glesEngine.matrices matrix4x3ForSemantic: kCC3MatrixSemanticViewInv]];
			return YES;
		case kCC3SemanticViewMatrixInvTran:
			[uniform setMatrix3x3: [glesEngine.matrices matrix3x3ForSemantic: kCC3MatrixSemanticViewInvTran]];
			return YES;

		case kCC3SemanticModelViewMatrix:
			[uniform setMatrix4x3: [glesEngine.matrices matrix4x3ForSemantic: kCC3MatrixSemanticModelView]];
			return YES;
		case kCC3SemanticModelViewMatrixInv:
			[uniform setMatrix4x3: [glesEngine.matrices matrix4x3ForSemantic: kCC3MatrixSemanticModelViewInv]];
			return YES;
		case kCC3SemanticModelViewMatrixInvTran:
			[uniform setMatrix3x3: [glesEngine.matrices matrix3x3ForSemantic: kCC3MatrixSemanticModelViewInvTran]];
			return YES;

		case kCC3SemanticProjMatrix:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticProj]];
			return YES;
		case kCC3SemanticProjMatrixInv:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticProjInv]];
			return YES;
		case kCC3SemanticProjMatrixInvTran:
			[uniform setMatrix3x3: [glesEngine.matrices matrix3x3ForSemantic: kCC3MatrixSemanticProjInvTran]];
			return YES;

		case kCC3SemanticViewProjMatrix:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticViewProj]];
			return YES;
		case kCC3SemanticViewProjMatrixInv:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticViewProjInv]];
			return YES;
		case kCC3SemanticViewProjMatrixInvTran:
			[uniform setMatrix3x3: [glesEngine.matrices matrix3x3ForSemantic: kCC3MatrixSemanticViewProjInvTran]];
			return YES;

		case kCC3SemanticModelViewProjMatrix:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticModelViewProj]];
			return YES;
		case kCC3SemanticModelViewProjMatrixInv:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticModelViewProjInv]];
			return YES;
		case kCC3SemanticModelViewProjMatrixInvTran:
			[uniform setMatrix3x3: [glesEngine.matrices matrix3x3ForSemantic: kCC3MatrixSemanticModelViewProjInvTran]];
			return YES;
			
		// CAMERA -----------------
		case kCC3SemanticCameraLocationGlobal:
			[uniform setVector: visitor.camera.globalLocation];
			return YES;
		case kCC3SemanticCameraLocationModelSpace:
			// Transform the global camera location to the local model space
			[uniform setVector: [visitor.currentMeshNode.transformMatrixInverted
								 transformLocation: visitor.camera.globalLocation]];
			return YES;
		case kCC3SemanticCameraFrustum:
			// Applies the field of view angle to the narrower aspect.
			vp = visitor.scene.viewportManager.viewport;
			GLfloat aspect = (GLfloat) vp.w / (GLfloat) vp.h;
			CC3Camera* cam = visitor.camera;
			GLfloat fovWidth, fovHeight;
			if (aspect >= 1.0f) {			// Landscape
				fovHeight = DegreesToRadians(cam.effectiveFieldOfView);
				fovWidth = fovHeight * aspect;
			} else {						// Portrait
				fovWidth = DegreesToRadians(cam.effectiveFieldOfView);
				fovHeight = fovWidth / aspect;
			}
			[uniform setVector4: CC3Vector4Make(fovWidth, fovHeight, cam.nearClippingDistance, cam.farClippingDistance)];
			return YES;
		case kCC3SemanticViewport:
			vp = visitor.scene.viewportManager.viewport;
			[uniform setIntVector4: CC3IntVector4Make(vp.x, vp.y, vp.w, vp.h)];
			return YES;
			
		// MATERIALS --------------
		case kCC3SemanticColor:
			[uniform setColor4F: glesEngine.state.color.value];
			return YES;
		case kCC3SemanticMaterialColorAmbient:
			[uniform setColor4F: glesEngine.materials.ambientColor.value];
			return YES;
		case kCC3SemanticMaterialColorDiffuse:
			[uniform setColor4F: glesEngine.materials.diffuseColor.value];
			return YES;
		case kCC3SemanticMaterialColorSpecular:
			[uniform setColor4F: glesEngine.materials.specularColor.value];
			return YES;
		case kCC3SemanticMaterialColorEmission:
			[uniform setColor4F: glesEngine.materials.emissionColor.value];
			return YES;
		case kCC3SemanticMaterialOpacity:
			[uniform setFloat: glesEngine.materials.diffuseColor.value.a];
			return YES;
		case kCC3SemanticMaterialShininess:
			[uniform setFloat: glesEngine.materials.shininess.value];
			return YES;
		case kCC3SemanticMinimumDrawnAlpha:
			[uniform setFloat: (glesEngine.capabilities.alphaTest.value
									? glesEngine.materials.alphaFunc.reference.value
									: 0.0f)];
			return YES;
			
		// LIGHTING --------------
		case kCC3SemanticIsUsingLighting:
			[uniform setBoolean: glesEngine.capabilities.lighting.value];
			return YES;
		case kCC3SemanticSceneLightColorAmbient:
			[uniform setColor4F: glesEngine.lighting.sceneAmbientLight.value];
			return YES;
		case kCC3SemanticLightIsEnabled:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				[uniform setBoolean: glesLight.isEnabled at: i];
			}
			return YES;

		case kCC3SemanticLightLocationEyeSpace:
			pMtx4x3 = [glesEngine.matrices matrix4x3ForSemantic: kCC3MatrixSemanticView];
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global position/direction to eye space and normalize if direction
					CC3Vector4 ltPos = CC3Matrix4x3TransformCC3Vector4(pMtx4x3, glesLight.position.value);
					if (ltPos.w == 0.0f) ltPos = CC3Vector4Normalize(ltPos);
					[uniform setVector4: ltPos at: i];
				}
			}
			return YES;
		case kCC3SemanticLightLocationGlobal:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setVector4: glesLight.position.value at: i];
			}
			return YES;
		case kCC3SemanticLightLocationModelSpace:
			[visitor.currentMeshNode.transformMatrixInverted populateCC3Matrix4x3: &m4x3];
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global position/direction to model space and normalize if direction
					CC3Vector4 ltPos = CC3Matrix4x3TransformCC3Vector4(&m4x3, glesLight.position.value);
					if (ltPos.w == 0.0f) ltPos = CC3Vector4Normalize(ltPos);
					[uniform setVector4: ltPos at: i];
				}
			}
			return YES;

		case kCC3SemanticLightColorAmbient:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setColor4F: glesLight.ambientColor.value at: i];
			}
			return YES;
		case kCC3SemanticLightColorDiffuse:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setColor4F: glesLight.diffuseColor.value at: i];
			}
			return YES;
		case kCC3SemanticLightColorSpecular:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setColor4F: glesLight.specularColor.value at: i];
			}
			return YES;
		case kCC3SemanticLightAttenuation:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					CC3AttenuationCoefficients ac;
					ac.a = glesLight.constantAttenuation.value;
					ac.b = glesLight.linearAttenuation.value;
					ac.c = glesLight.quadraticAttenuation.value;
					[uniform setVector: *(CC3Vector*)&ac at: i];
				}
			}
			return YES;
			
		case kCC3SemanticLightSpotDirectionEyeSpace:
			pMtx4x3 = [glesEngine.matrices matrix4x3ForSemantic: kCC3MatrixSemanticView];
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global direction to eye space and normalize
					CC3Vector ltDir = CC3Matrix4x3TransformDirection(pMtx4x3, glesLight.spotDirection.value);
					[uniform setVector: CC3VectorNormalize(ltDir) at: i];
				}
			}
			return YES;
		case kCC3SemanticLightSpotDirectionGlobal:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setVector: glesLight.spotDirection.value at: i];
			}
			return YES;
		case kCC3SemanticLightSpotDirectionModelSpace:
			[visitor.currentMeshNode.transformMatrixInverted populateCC3Matrix4x3: &m4x3];
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global direction to model space and normalize
					CC3Vector ltDir = CC3Matrix4x3TransformDirection(&m4x3, glesLight.spotDirection.value);
					[uniform setVector: CC3VectorNormalize(ltDir) at: i];
				}
			}
			return YES;
		case kCC3SemanticLightSpotExponent:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setFloat: glesLight.spotExponent.value at: i];
			}
			return YES;
		case kCC3SemanticLightSpotCutoffAngle:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setFloat: glesLight.spotCutoffAngle.value at: i];
			}
			return YES;
		case kCC3SemanticLightSpotCutoffAngleCosine:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setFloat: cosf(DegreesToRadians(glesLight.spotCutoffAngle.value)) at: i];
			}
			return YES;
			
		// TEXTURES --------------
		case kCC3SemanticTextureCount:
			[uniform setInteger: visitor.textureUnitCount];
			return YES;
		case kCC3SemanticTextureSampler:
			// Samplers are simply consecutive texture unit indices
			for (GLuint i = 0; i < uniformSize; i++) [uniform setInteger: (semanticIndex + i) at: i];
			return YES;

		// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
		// In most shaders, these will be left unused in favor of customized the texture combining in code.
		case kCC3SemanticTexUnitMode:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.textureEnvironmentMode.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitConstantColor:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setColor4F: glesTexUnit.color.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitCombineRGBFunction:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.combineRGBFunction.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource0RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbSource0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource1RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbSource1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource2RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbSource2.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand0RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbOperand0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand1RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbOperand1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand2RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbOperand2.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitCombineAlphaFunction:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.combineAlphaFunction.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource0Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaSource0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource1Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaSource1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource2Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaSource2.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand0Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaOperand0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand1Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaOperand1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand2Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [glesEngine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaOperand2.value at: i];
			}
			return YES;
			
		// MODEL ----------------
		case kCC3SemanticCenterOfGeometry:
			[uniform setVector: visitor.currentMeshNode.mesh.centerOfGeometry];
			return YES;
		case kCC3SemanticBoundingRadius:
			[uniform setFloat: visitor.currentMeshNode.mesh.radius];
			return YES;
		case kCC3SemanticBoundingBoxMin:
			[uniform setVector: visitor.currentMeshNode.mesh.boundingBox.minimum];
			return YES;
		case kCC3SemanticBoundingBoxMax:
			[uniform setVector: visitor.currentMeshNode.mesh.boundingBox.maximum];
			return YES;
		case kCC3SemanticBoundingBoxSize:
			[uniform setVector: CC3BoundingBoxSize(visitor.currentMeshNode.mesh.boundingBox)];
			return YES;
		case kCC3SemanticAnimationFraction:
			[uniform setFloat: visitor.currentMeshNode.animation.currentFrame];
			return YES;

		// PARTICLES ------------
		case kCC3SemanticPointSize:
			[uniform setFloat: glesEngine.state.pointSize.value];
			return YES;
		case kCC3SemanticPointSizeAttenuation:
			[uniform setVector: glesEngine.state.pointSizeAttenuation.value];
			return YES;
		case kCC3SemanticPointSizeMinimum:
			[uniform setFloat: glesEngine.state.pointSizeMinimum.value];
			return YES;
		case kCC3SemanticPointSizeMaximum:
			[uniform setFloat: glesEngine.state.pointSizeMaximum.value];
			return YES;
		case kCC3SemanticPointSizeFadeThreshold:
			[uniform setFloat: glesEngine.state.pointSizeFadeThreshold.value];
			return YES;
		case kCC3SemanticPointSpritesIsEnabled:
			[uniform setBoolean: glesEngine.capabilities.pointSprites.value];
			return YES;
			
		// TIME ------------------
		case kCC3SemanticFrameTime:
			[uniform setFloat: visitor.deltaTime];
			return YES;
		case kCC3SemanticApplicationTime:
			[uniform setFloat: CCDirector.sharedDirector.displayLinkTime];
			return YES;
		case kCC3SemanticApplicationTimeSine:
			appTime = CCDirector.sharedDirector.displayLinkTime;
			[uniform setVector4: CC3Vector4Make(sinf(appTime),
												sinf(appTime/2.0f),
												sinf(appTime/4.0f),
												sinf(appTime/8.0f))];
			return YES;
		case kCC3SemanticApplicationTimeCosine:
			appTime = CCDirector.sharedDirector.displayLinkTime;
			[uniform setVector4: CC3Vector4Make(cosf(appTime),
												cosf(appTime/2.0f),
												cosf(appTime/4.0f),
												cosf(appTime/8.0f))];
			return YES;
		case kCC3SemanticApplicationTimeTangent:
			appTime = CCDirector.sharedDirector.displayLinkTime;
			[uniform setVector4: CC3Vector4Make(tanf(appTime),
												tanf(appTime/2.0f),
												tanf(appTime/4.0f),
												tanf(appTime/8.0f))];
			return YES;
			
		// MISC ENVIRONMENT ---------
		case kCC3SemanticDrawCountCurrentFrame:
			[uniform setInteger: CC3GLDraws()];
			return YES;
		case kCC3SemanticRandomNumber:
			[uniform setFloat: CC3RandomFloat()];
			return YES;
			
		default: return NO;
	}
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsByVarName

@implementation CC3GLProgramSemanticsByVarName

-(void) dealloc {
	[_varConfigsByName release];
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_varConfigsByName = [NSMutableDictionary new];		// retained
	}
	return self;
}


#pragma mark Variable configuration

/**
 * Uses the variable name property to look up a configuration and sets the semantic
 * and semanticIndex properties of the specified variable from that configuration.
 */
-(BOOL) configureVariable: (CC3GLSLVariable*) variable {
	CC3GLSLVariableConfiguration* varConfig = [_varConfigsByName objectForKey: variable.name];
	if (varConfig) {
		variable.semantic = varConfig.semantic;
		variable.semanticIndex = varConfig.semanticIndex;
		return YES;
	}
	return NO;
}

-(void) addVariableConfiguration: (CC3GLSLVariableConfiguration*) varConfig {
	[_varConfigsByName setObject: varConfig forKey: varConfig.name];
}

-(void) mapVarName: (NSString*) name toSemantic: (GLenum) semantic at: (GLuint) semanticIndex {
	CC3GLSLVariableConfiguration* varConfig = [CC3GLSLVariableConfiguration new];
	varConfig.name = name;
	varConfig.semantic = semantic;
	varConfig.semanticIndex = semanticIndex;
	[self addVariableConfiguration: varConfig];
	[varConfig release];
}

-(void) mapVarName: (NSString*) name toSemantic: (GLenum) semantic {
	[self mapVarName: name toSemantic: semantic at: 0];
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsByVarName default mappings extension

@implementation CC3GLProgramSemanticsByVarName (DefaultMappings)

-(void) populateWithDefaultVariableNameMappings {
	
	// VETEX ATTRIBUTES --------------
	[self mapVarName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocation];			/**< Vertex location. */
	[self mapVarName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormal];				/**< Vertex normal. */
	[self mapVarName: @"a_cc3Tangent" toSemantic: kCC3SemanticVertexTangent];			/**< Vertex tangent. */
	[self mapVarName: @"a_cc3Bitangent" toSemantic: kCC3SemanticVertexBitangent];		/**< Vertex bitangent (aka binormal). */
	[self mapVarName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColor];				/**< Vertex color. */
	[self mapVarName: @"a_cc3Weight" toSemantic: kCC3SemanticVertexWeight];				/**< Vertex skinning weight. */
	[self mapVarName: @"a_cc3MatrixIndex" toSemantic: kCC3SemanticVertexMatrix];		/**< Vertex skinning matrice. */
	[self mapVarName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSize];		/**< Vertex point size. */
	
	// If only one texture coordinate attribute is used, the index suffix ("a_cc3TexCoordN") is optional.
	[self mapVarName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture];				/**< Vertex texture coordinate for the first texture unit. */
	for (NSUInteger tuIdx = 0; tuIdx < _maxTexUnitVars; tuIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"a_cc3TexCoord%u", tuIdx] toSemantic: kCC3SemanticVertexTexture at: tuIdx];	/**< Vertex texture coordinate for a texture unit. */
	}
	
	// ATTRIBUTE QUALIFIERS --------------
	[self mapVarName: @"u_cc3HasVertexNormal" toSemantic: kCC3SemanticHasVertexNormal];					/**< (bool) Whether the vertex normal is available. */
	[self mapVarName: @"u_cc3ShouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];	/**< (bool) Whether vertex normals should be normalized. */
	[self mapVarName: @"u_cc3ShouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];	/**< (bool) Whether vertex normals should be rescaled. */
	[self mapVarName: @"u_cc3HasVertexTangent" toSemantic: kCC3SemanticHasVertexTangent];				/**< (bool) Whether the vertex tangent is available. */
	[self mapVarName: @"u_cc3HasVertexBitangent" toSemantic: kCC3SemanticHasVertexBitangent];			/**< (bool) Whether the vertex bitangent is available. */
	[self mapVarName: @"u_cc3HasVertexColor" toSemantic: kCC3SemanticHasVertexColor];					/**< (bool) Whether the vertex color is available. */
	[self mapVarName: @"u_cc3HasVertexTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];	/**< (bool) Whether the vertex texture coordinate is available. */
	[self mapVarName: @"u_cc3HasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];			/**< (bool) Whether the vertex point size is available. */
	[self mapVarName: @"u_cc3IsDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];					/**< (bool) Whether the vertices are being drawn as points. */
	
	// ENVIRONMENT MATRICES --------------
	[self mapVarName: @"u_cc3MtxModelLocal" toSemantic: kCC3SemanticModelLocalMatrix];					/**< (mat4) Current model-to-parent matrix. */
	[self mapVarName: @"u_cc3MtxModelLocalInv" toSemantic: kCC3SemanticModelLocalMatrixInv];			/**< (mat4) Inverse of current model-to-parent matrix. */
	[self mapVarName: @"u_cc3MtxModelLocalInvTran" toSemantic: kCC3SemanticModelLocalMatrixInvTran];	/**< (mat3) Inverse-transpose of current model-to-parent matrix. */

	[self mapVarName: @"u_cc3MtxModel" toSemantic: kCC3SemanticModelMatrix];							/**< (mat4) Current model-to-world matrix. */
	[self mapVarName: @"u_cc3MtxModelInv" toSemantic: kCC3SemanticModelMatrixInv];						/**< (mat4) Inverse of current model-to-world matrix. */
	[self mapVarName: @"u_cc3MtxModelInvTran" toSemantic: kCC3SemanticModelMatrixInvTran];				/**< (mat3) Inverse-transpose of current model-to-world matrix. */
	
	[self mapVarName: @"u_cc3MtxView" toSemantic: kCC3SemanticViewMatrix];								/**< (mat4) Camera view matrix. */
	[self mapVarName: @"u_cc3MtxViewInv" toSemantic: kCC3SemanticViewMatrixInv];						/**< (mat4) Inverse of camera view matrix. */
	[self mapVarName: @"u_cc3MtxViewInvTran" toSemantic: kCC3SemanticViewMatrixInvTran];				/**< (mat3) Inverse-transpose of camera view matrix. */
	
	[self mapVarName: @"u_cc3MtxModelView" toSemantic: kCC3SemanticModelViewMatrix];					/**< (mat4) Current modelview matrix. */
	[self mapVarName: @"u_cc3MtxModelViewInv" toSemantic: kCC3SemanticModelViewMatrixInv];				/**< (mat4) Inverse of current modelview matrix. */
	[self mapVarName: @"u_cc3MtxModelViewInvTran" toSemantic: kCC3SemanticModelViewMatrixInvTran];		/**< (mat3) Inverse-transpose of current modelview matrix. */
	
	[self mapVarName: @"u_cc3MtxProj" toSemantic: kCC3SemanticProjMatrix];								/**< (mat4) Camera projection matrix. */
	[self mapVarName: @"u_cc3MtxProjInv" toSemantic: kCC3SemanticProjMatrixInv];						/**< (mat4) Inverse of camera projection matrix. */
	[self mapVarName: @"u_cc3MtxProjInvTran" toSemantic: kCC3SemanticProjMatrixInvTran];				/**< (mat3) Inverse-transpose of camera projection matrix. */
	
	[self mapVarName: @"u_cc3MtxViewProj" toSemantic: kCC3SemanticViewProjMatrix];						/**< (mat4) Camera view and projection matrix. */
	[self mapVarName: @"u_cc3MtxViewProjInv" toSemantic: kCC3SemanticViewProjMatrixInv];				/**< (mat4) Inverse of camera view and projection matrix. */
	[self mapVarName: @"u_cc3MtxViewProjInvTran" toSemantic: kCC3SemanticViewProjMatrixInvTran];		/**< (mat3) Inverse-transpose of camera view and projection matrix. */
	
	[self mapVarName: @"u_cc3MtxModelViewProj" toSemantic: kCC3SemanticModelViewProjMatrix];			/**< (mat4) Current modelview-projection matrix. */
	[self mapVarName: @"u_cc3MtxModelViewProjInv" toSemantic: kCC3SemanticModelViewProjMatrixInv];		/**< (mat4) Inverse of current modelview-projection matrix. */
	[self mapVarName: @"u_cc3MtxModelViewProjInvTran" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];	/**< (mat3) Inverse-transpose of current modelview-projection matrix. */
	
	// CAMERA -----------------
	[self mapVarName: @"u_cc3Camera.positionGlobal" toSemantic: kCC3SemanticCameraLocationGlobal];		/**< (vec3) Location of the camera in global coordinates. */
	[self mapVarName: @"u_cc3Camera.positionModel" toSemantic: kCC3SemanticCameraLocationModelSpace];	/**< (vec3) Location of the camera in local coordinates of model (not camera). */
	[self mapVarName: @"u_cc3Camera.frustum" toSemantic: kCC3SemanticCameraFrustum];					/**< (vec4) Dimensions of the camera frustum (FOV width (radians), FOV height (radians), near clip, far clip). */
	[self mapVarName: @"u_cc3Camera.viewport" toSemantic: kCC3SemanticViewport];						/**< (int4) The viewport rectangle in pixels (x, y, width, height). */
	
	// MATERIALS --------------
	[self mapVarName: @"u_cc3Color" toSemantic: kCC3SemanticColor];										/**< (vec4) Color when lighting & materials are not in use. */
	[self mapVarName: @"u_cc3Material.ambientColor" toSemantic: kCC3SemanticMaterialColorAmbient];		/**< (vec4) Ambient color of the material. */
	[self mapVarName: @"u_cc3Material.diffuseColor" toSemantic: kCC3SemanticMaterialColorDiffuse];		/**< (vec4) Diffuse color of the material. */
	[self mapVarName: @"u_cc3Material.specularColor" toSemantic: kCC3SemanticMaterialColorSpecular];	/**< (vec4) Specular color of the material. */
	[self mapVarName: @"u_cc3Material.emissionColor" toSemantic: kCC3SemanticMaterialColorEmission];	/**< (vec4) Emission color of the material. */
	[self mapVarName: @"u_cc3Material.opacity" toSemantic: kCC3SemanticMaterialOpacity];				/**< (float) Opacity of the material. */
	[self mapVarName: @"u_cc3Material.shininess" toSemantic: kCC3SemanticMaterialShininess];			/**< (float) Shininess of the material. */
	[self mapVarName: @"u_cc3Material.minimumDrawnAlpha" toSemantic: kCC3SemanticMinimumDrawnAlpha];	/**< (float) Minimum alpha value to be drawn, otherwise will be discarded. */
	
	// LIGHTING --------------
	[self mapVarName: @"u_cc3IsUsingLighting" toSemantic: kCC3SemanticIsUsingLighting];					/**< (bool) Whether any lighting is enabled. */
	[self mapVarName: @"u_cc3SceneLightColorAmbient" toSemantic: kCC3SemanticSceneLightColorAmbient];	/**< (vec4) Ambient light color of the scene. */
	
	// If only one light is used it can be declared as a single variable structure without the index.
	[self mapVarName: @"u_cc3Light.isEnabled" toSemantic: kCC3SemanticLightIsEnabled];					/**< (bool) Whether the first light is enabled. */
	[self mapVarName: @"u_cc3Light.positionEyeSpace" toSemantic: kCC3SemanticLightLocationEyeSpace];	/**< (vec4) Location of the first light in eye space. */
	[self mapVarName: @"u_cc3Light.positionGlobal" toSemantic: kCC3SemanticLightLocationGlobal];		/**< (vec4) Location of the first light in global coordinates. */
	[self mapVarName: @"u_cc3Light.positionModel" toSemantic: kCC3SemanticLightLocationModelSpace];		/**< (vec4) Location of the first light in local coordinates of model (not light). */
	[self mapVarName: @"u_cc3Light.ambientColor" toSemantic: kCC3SemanticLightColorAmbient];			/**< (vec4) Ambient color of the first light. */
	[self mapVarName: @"u_cc3Light.diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse];			/**< (vec4) Diffuse color of the first light. */
	[self mapVarName: @"u_cc3Light.specularColor" toSemantic: kCC3SemanticLightColorSpecular];			/**< (vec4) Specular color of the first light. */
	[self mapVarName: @"u_cc3Light.attenuation" toSemantic: kCC3SemanticLightAttenuation];				/**< (vec3) Distance attenuation coefficients for the first light. */
	[self mapVarName: @"u_cc3Light.spotDirectionEyeSpace" toSemantic: kCC3SemanticLightSpotDirectionEyeSpace];	/**< (vec3) Direction of the first spotlight in eye space. */
	[self mapVarName: @"u_cc3Light.spotDirectionGlobal" toSemantic: kCC3SemanticLightSpotDirectionGlobal];		/**< (vec3) Direction of the first spotlight in global coordinates. */
	[self mapVarName: @"u_cc3Light.spotDirectionModel" toSemantic: kCC3SemanticLightSpotDirectionModelSpace];	/**< (vec3) Direction of the first spotlight in local coordinates of the model (not light). */
	[self mapVarName: @"u_cc3Light.spotExponent" toSemantic: kCC3SemanticLightSpotExponent];					/**< (float) Fade-off exponent of the first spotlight. */
	[self mapVarName: @"u_cc3Light.spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle];				/**< (float) Cutoff angle of the first spotlight (degrees). */
	[self mapVarName: @"u_cc3Light.spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine];	/**< (float) Cosine of cutoff angle of the first spotlight. */
	
	// Multiple lights are indexed
	for (NSUInteger ltIdx = 0; ltIdx < _maxLightVars; ltIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].isEnabled", ltIdx] toSemantic: kCC3SemanticLightIsEnabled at: ltIdx];						/**< (bool) Whether a light is enabled. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionEyeSpace", ltIdx] toSemantic: kCC3SemanticLightLocationEyeSpace at: ltIdx];			/**< (vec4) Location of a light in eye space. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionGlobal", ltIdx] toSemantic: kCC3SemanticLightLocationGlobal at: ltIdx];				/**< (vec4) Location of a light in global coordinates. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionModel", ltIdx] toSemantic: kCC3SemanticLightLocationModelSpace at: ltIdx];			/**< (vec4) Location of a light in local coordinates of model (not light). */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].ambientColor", ltIdx] toSemantic: kCC3SemanticLightColorAmbient at: ltIdx];					/**< (vec4) Ambient color of a light. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].diffuseColor", ltIdx] toSemantic: kCC3SemanticLightColorDiffuse at: ltIdx];					/**< (vec4) Diffuse color of a light. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].specularColor", ltIdx] toSemantic: kCC3SemanticLightColorSpecular at: ltIdx];				/**< (vec4) Specular color of a light. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].attenuation", ltIdx] toSemantic: kCC3SemanticLightAttenuation at: ltIdx];					/**< (vec3) Distance attenuation coefficients for a light. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotDirectionEyeSpace", ltIdx] toSemantic: kCC3SemanticLightSpotDirectionEyeSpace at: ltIdx];	/**< (vec3) Direction of a spotlight in eye space. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotDirectionGlobal", ltIdx] toSemantic: kCC3SemanticLightSpotDirectionGlobal at: ltIdx];		/**< (vec3) Direction of a spotlight in global coordinates. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotDirectionModel", ltIdx] toSemantic: kCC3SemanticLightSpotDirectionModelSpace at: ltIdx];	/**< (vec3) Direction of a spotlight in local coordinates of the model (not light). */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotExponent", ltIdx] toSemantic: kCC3SemanticLightSpotExponent at: ltIdx];						/**< (float) Fade-off exponent of a spotlight. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotCutoffAngle", ltIdx] toSemantic: kCC3SemanticLightSpotCutoffAngle at: ltIdx];				/**< (float) Cutoff angle of a spotlight (degrees). */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotCutoffAngleCosine", ltIdx] toSemantic: kCC3SemanticLightSpotCutoffAngleCosine at: ltIdx];	/**< (float) Cosine of cutoff angle of a spotlight. */
	}

	// TEXTURES --------------
	[self mapVarName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];				/**< (int) Number of active textures. */
	[self mapVarName: @"s_cc3Texture" toSemantic: kCC3SemanticTextureSampler];					/**< (sampler2D) Texture sampler (alias for s_cc3Textures[0]). */
	[self mapVarName: @"s_cc3Textures[0]" toSemantic: kCC3SemanticTextureSampler];				/**< (sampler2D) Texture sampler (alias for s_cc3Texture). */
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in code.
	for (NSUInteger tuIdx = 0; tuIdx < _maxTexUnitVars; tuIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].color", tuIdx] toSemantic: kCC3SemanticTexUnitConstantColor at: tuIdx];						/**< (vec4) The constant color of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].mode", tuIdx] toSemantic: kCC3SemanticTexUnitMode at: tuIdx];									/**< (int) Environment mode of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].combineRGBFunction", tuIdx] toSemantic: kCC3SemanticTexUnitCombineRGBFunction at: tuIdx];		/**< (int) RBG combiner function of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbSource0", tuIdx] toSemantic: kCC3SemanticTexUnitSource0RGB at: tuIdx];						/**< (int) The RGB of source 0 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbSource1", tuIdx] toSemantic: kCC3SemanticTexUnitSource1RGB at: tuIdx];						/**< (int) The RGB of source 1 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbSource2", tuIdx] toSemantic: kCC3SemanticTexUnitSource2RGB at: tuIdx];						/**< (int) The RGB of source 2 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbOperand0", tuIdx] toSemantic: kCC3SemanticTexUnitOperand0RGB at: tuIdx];					/**< (int) The RGB combining operand of source 0 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbOperand1", tuIdx] toSemantic: kCC3SemanticTexUnitOperand1RGB at: tuIdx];					/**< (int) The RGB combining operand of source 1 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbOperand2", tuIdx] toSemantic: kCC3SemanticTexUnitOperand2RGB at: tuIdx];					/**< (int) The RGB combining operand of source 2 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].combineAlphaFunction", tuIdx] toSemantic: kCC3SemanticTexUnitCombineAlphaFunction at: tuIdx];	/**< (int) Alpha combiner function of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaSource0", tuIdx] toSemantic: kCC3SemanticTexUnitSource0Alpha at: tuIdx];					/**< (int) The alpha of source 0 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaSource1", tuIdx] toSemantic: kCC3SemanticTexUnitSource1Alpha at: tuIdx];					/**< (int) The alpha of source 1 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaSource2", tuIdx] toSemantic: kCC3SemanticTexUnitSource2Alpha at: tuIdx];					/**< (int) The alpha of source 2 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaOperand0", tuIdx] toSemantic: kCC3SemanticTexUnitOperand0Alpha at: tuIdx];				/**< (int) The alpha combining operand of source 0 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaOperand1", tuIdx] toSemantic: kCC3SemanticTexUnitOperand1Alpha at: tuIdx];				/**< (int) The alpha combining operand of source 1 of a texture unit. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaOperand2", tuIdx] toSemantic: kCC3SemanticTexUnitOperand2Alpha at: tuIdx];				/**< (int) The alpha combining operand of source 2 of a texture unit. */
	}
	
	// MODEL ----------------
	[self mapVarName: @"u_cc3Model.centerOfGeometry" toSemantic: kCC3SemanticCenterOfGeometry];		/**< (vec3) The center of geometry of the model in the model's local coordinates. */
	[self mapVarName: @"u_cc3Model.boundingRadius" toSemantic: kCC3SemanticBoundingRadius];			/**< (vec3) The minimum corner of the model's bounding box in the model's local coordinates. */
	[self mapVarName: @"u_cc3Model.boundingBoxMinimum" toSemantic: kCC3SemanticBoundingBoxMin];		/**< (vec3) The maximum corner of the model's bounding box in the model's local coordinates. */
	[self mapVarName: @"u_cc3Model.boundingBoxMaximum" toSemantic: kCC3SemanticBoundingBoxMax];		/**< (vec3) The dimensions of the model's bounding box in the model's local coordinates. */
	[self mapVarName: @"u_cc3Model.boundingBoxSize" toSemantic: kCC3SemanticBoundingBoxSize];		/**< (float) The radius of the model's bounding sphere in the model's local coordinates. */
	[self mapVarName: @"u_cc3Model.animationFraction" toSemantic: kCC3SemanticAnimationFraction];	/**< (float) Fraction of the model's animation that has been viewed (range 0-1). */
	
	// PARTICLES ------------
	[self mapVarName: @"u_cc3Points.isDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];				/**< (bool) Whether the vertices are being drawn as points (alias for u_cc3IsDrawingPoints). */
	[self mapVarName: @"u_cc3Points.hasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];		/**< (bool) Whether the vertex point size is available (alias for u_cc3HasVertexPointSize). */
	[self mapVarName: @"u_cc3Points.size" toSemantic: kCC3SemanticPointSize];								/**< (float) Default size of points, if not specified per-vertex in a vertex attribute array. */
	[self mapVarName: @"u_cc3Points.sizeAttenuation" toSemantic: kCC3SemanticPointSizeAttenuation];			/**< (vec3) Point size distance attenuation coefficients. */
	[self mapVarName: @"u_cc3Points.minimumSize" toSemantic: kCC3SemanticPointSizeMinimum];					/**< (float) Minimum size points will be allowed to shrink to. */
	[self mapVarName: @"u_cc3Points.maximumSize" toSemantic: kCC3SemanticPointSizeMaximum];					/**< (float) Maximum size points will be allowed to grow to. */
	[self mapVarName: @"u_cc3Points.sizeFadeThreshold" toSemantic: kCC3SemanticPointSizeFadeThreshold];		/**< (float) Points will be allowed to grow to. */
	[self mapVarName: @"u_cc3Points.shouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];	/**< (bool) Whether points should be interpeted as textured sprites. */
	
	// TIME ------------------
	[self mapVarName: @"u_cc3Time.frameTime" toSemantic: kCC3SemanticFrameTime];						/**< (float) The time in seconds since the last frame. */
	[self mapVarName: @"u_cc3Time.appTime" toSemantic: kCC3SemanticApplicationTime];					/**< (float) The application time in seconds. */
	[self mapVarName: @"u_cc3Time.appTimeSine" toSemantic: kCC3SemanticApplicationTimeSine];			/**< (vec4) The sine of the application time (sin(T), sin(T/2), sin(T/4), sin(T/8)). */
	[self mapVarName: @"u_cc3Time.appTimeCosine" toSemantic: kCC3SemanticApplicationTimeCosine];		/**< (vec4) The cosine of the application time (cos(T), cos(T/2), cos(T/4), cos(T/8)). */
	[self mapVarName: @"u_cc3Time.appTimeTangent" toSemantic: kCC3SemanticApplicationTimeTangent];		/**< (vec4) The tangent of the application time (tan(T), tan(T/2), tan(T/4), tan(T/8)). */

	// MISC ENVIRONMENT ---------
	[self mapVarName: @"u_cc3DrawCount" toSemantic: kCC3SemanticDrawCountCurrentFrame];		/**< (int) The number of draw calls so far in this frame. */
	[self mapVarName: @"u_cc3Random" toSemantic: kCC3SemanticRandomNumber];					/**< (float) A random number between 0 and 1. */

}

static NSUInteger _maxLightVars = 4;
+(NSUInteger) maxDefaultMappingLightVariables { return _maxLightVars; }
+(void) setMaxDefaultMappingLightVariables: (NSUInteger) maxLights { _maxLightVars = maxLights; }

static NSUInteger _maxTexUnitVars = 4;
+(NSUInteger) maxDefaultMappingTextureUnitVariables { return _maxTexUnitVars; }
+(void) setMaxDefaultMappingTextureUnitVariables: (NSUInteger) maxTexUnits { _maxTexUnitVars = maxTexUnits; }


#pragma mark Allocation and initialization

static CC3GLProgramSemanticsByVarName* _sharedDefaultDelegate;

+(CC3GLProgramSemanticsByVarName*) sharedDefaultDelegate {
	if ( !_sharedDefaultDelegate ) {
		_sharedDefaultDelegate = [CC3GLProgramSemanticsByVarName new];		// retained
		[_sharedDefaultDelegate populateWithDefaultVariableNameMappings];
	}
	return _sharedDefaultDelegate;
}

@end
	
