/*
 * CC3ShaderSemantics.m
 *
 * cocos3d 2.0.0
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
 * 
 * See header file CC3ShaderSemantics.h for full API documentation.
 */

#import "CC3ShaderSemantics.h"
#import "CC3GLSLVariable.h"
#import "CC3NodeVisitor.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3Scene.h"
#import "CC3PointParticles.h"
#import "CC3NodeAnimation.h"
#import "CC3VertexSkinning.h"
#import "CC3OpenGL.h"


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
		case kCC3SemanticVertexBoneWeights: return @"kCC3SemanticVertexBoneWeights";
		case kCC3SemanticVertexBoneIndices: return @"kCC3SemanticVertexBoneIndices";
		case kCC3SemanticVertexTexture: return @"kCC3SemanticVertexTexture";
			
		case kCC3SemanticHasVertexNormal: return @"kCC3SemanticHasVertexNormal";
		case kCC3SemanticShouldNormalizeVertexNormal: return @"kCC3SemanticShouldNormalizeVertexNormal";
		case kCC3SemanticShouldRescaleVertexNormal: return @"kCC3SemanticShouldRescaleVertexNormal";
		case kCC3SemanticHasVertexTangent: return @"kCC3SemanticHasVertexTangent";
		case kCC3SemanticHasVertexBitangent: return @"kCC3SemanticHasVertexBitangent";
		case kCC3SemanticHasVertexColor: return @"kCC3SemanticHasVertexColor";
		case kCC3SemanticHasVertexWeight: return @"kCC3SemanticHasVertexWeight";
		case kCC3SemanticHasVertexMatrixIndex: return @"kCC3SemanticHasVertexMatrixIndex";
		case kCC3SemanticHasVertexTextureCoordinate: return @"kCC3SemanticHasVertexTextureCoordinate";
		case kCC3SemanticHasVertexPointSize: return @"kCC3SemanticHasVertexPointSize";
		case kCC3SemanticIsDrawingPoints: return @"kCC3SemanticIsDrawingPoints";
		case kCC3SemanticShouldDrawFrontFaces: return @"kCC3SemanticShouldDrawFrontFaces";
		case kCC3SemanticShouldDrawBackFaces: return @"kCC3SemanticShouldDrawBackFaces";

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
		case kCC3SemanticCameraFrustumDepth: return @"kCC3SemanticCameraFrustumDepth";
			
		// MATERIALS --------------
		case kCC3SemanticColor: return @"kCC3SemanticColor";
		case kCC3SemanticMaterialColorAmbient: return @"kCC3SemanticMaterialColorAmbient";
		case kCC3SemanticMaterialColorDiffuse: return @"kCC3SemanticMaterialColorDiffuse";
		case kCC3SemanticMaterialColorSpecular: return @"kCC3SemanticMaterialColorSpecular";
		case kCC3SemanticMaterialColorEmission: return @"kCC3SemanticMaterialColorEmission";
		case kCC3SemanticMaterialOpacity: return @"kCC3SemanticMaterialOpacity";
		case kCC3SemanticMaterialShininess: return @"kCC3SemanticMaterialShininess";
		case kCC3SemanticMaterialReflectivity: return @"kCC3SemanticMaterialReflectivity";

		// LIGHTING --------------
		case kCC3SemanticIsUsingLighting: return @"kCC3SemanticIsUsingLighting";
		case kCC3SemanticSceneLightColorAmbient: return @"kCC3SemanticSceneLightColorAmbient";

		case kCC3SemanticLightIsEnabled: return @"kCC3SemanticLightIsEnabled";
		case kCC3SemanticLightPositionGlobal: return @"kCC3SemanticLightPositionGlobal";
		case kCC3SemanticLightPositionEyeSpace: return @"kCC3SemanticLightPositionEyeSpace";
		case kCC3SemanticLightPositionModelSpace: return @"kCC3SemanticLightPositionModelSpace";
		case kCC3SemanticLightInvertedPositionGlobal: return @"kCC3SemanticLightInvertedPositionGlobal";
		case kCC3SemanticLightInvertedPositionEyeSpace: return @"kCC3SemanticLightInvertedPositionEyeSpace";
		case kCC3SemanticLightInvertedPositionModelSpace: return @"kCC3SemanticLightInvertedPositionModelSpace";
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

		case kCC3SemanticFogIsEnabled: return @"kCC3SemanticFogIsEnabled";
		case kCC3SemanticFogColor: return @"kCC3SemanticFogColor";
		case kCC3SemanticFogAttenuationMode: return @"kCC3SemanticFogAttenuationMode";
		case kCC3SemanticFogDensity: return @"kCC3SemanticFogDensity";
		case kCC3SemanticFogStartDistance: return @"kCC3SemanticFogStartDistance";
		case kCC3SemanticFogEndDistance: return @"kCC3SemanticFogEndDistance";
			
		// TEXTURES --------------
		case kCC3SemanticTextureCount: return @"kCC3SemanticTextureCount";
		case kCC3SemanticTextureSampler: return @"kCC3SemanticTextureSampler";
		case kCC3SemanticTexture2DCount: return @"kCC3SemanticTexture2DCount";
		case kCC3SemanticTexture2DSampler: return @"kCC3SemanticTexture2DSampler";
		case kCC3SemanticTextureCubeCount: return @"kCC3SemanticTextureCubeCount";
		case kCC3SemanticTextureCubeSampler: return @"kCC3SemanticTextureCubeSampler";

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
			
		// BONE SKINNING
		case kCC3SemanticVertexBoneCount: return @"kCC3SemanticVertexBoneCount";
		case kCC3SemanticBatchBoneCount: return @"kCC3SemanticBatchBoneCount";

		// BONE SKINNING MATRICES
		case kCC3SemanticBoneMatricesGlobal: return @"kCC3SemanticBoneMatricesGlobal";
		case kCC3SemanticBoneMatricesInvTranGlobal: return @"kCC3SemanticBoneMatricesInvTranGlobal";
		case kCC3SemanticBoneMatricesEyeSpace: return @"kCC3SemanticBoneMatricesEyeSpace";
		case kCC3SemanticBoneMatricesInvTranEyeSpace: return @"kCC3SemanticBoneMatricesInvTranEyeSpace";
		case kCC3SemanticBoneMatricesModelSpace: return @"kCC3SemanticBoneMatricesModelSpace";
		case kCC3SemanticBoneMatricesInvTranModelSpace: return @"kCC3SemanticBoneMatricesInvTranModelSpace";

		// BONE SKINNING DISCRETE TRANSFORMS
		case kCC3SemanticBoneQuaternionsGlobal: return @"kCC3SemanticBoneQuaternionsGlobal";
		case kCC3SemanticBoneTranslationsGlobal: return @"kCC3SemanticBoneTranslationsGlobal";
		case kCC3SemanticBoneScalesGlobal: return @"kCC3SemanticBoneScalesGlobal";
		case kCC3SemanticBoneQuaternionsEyeSpace: return @"kCC3SemanticBoneQuaternionsEyeSpace";
		case kCC3SemanticBoneTranslationsEyeSpace: return @"kCC3SemanticBoneTranslationsEyeSpace";
		case kCC3SemanticBoneScalesEyeSpace: return @"kCC3SemanticBoneScalesEyeSpace";
		case kCC3SemanticBoneQuaternionsModelSpace: return @"kCC3SemanticBoneQuaternionsModelSpace";
		case kCC3SemanticBoneTranslationsModelSpace: return @"kCC3SemanticBoneTranslationsModelSpace";
		case kCC3SemanticBoneScalesModelSpace: return @"kCC3SemanticBoneScalesModelSpace";
			
		// PARTICLES ------------
		case kCC3SemanticPointSize: return @"kCC3SemanticPointSize";
		case kCC3SemanticPointSizeAttenuation: return @"kCC3SemanticPointSizeAttenuation";
		case kCC3SemanticPointSizeMinimum: return @"kCC3SemanticPointSizeMinimum";
		case kCC3SemanticPointSizeMaximum: return @"kCC3SemanticPointSizeMaximum";
		case kCC3SemanticPointSpritesIsEnabled: return @"kCC3SemanticPointSpritesIsEnabled";
			
		// TIME ------------------
		case kCC3SemanticFrameTime: return @"kCC3SemanticFrameTime";
			
		case kCC3SemanticSceneTime: return @"kCC3SemanticSceneTime";
		case kCC3SemanticSceneTimeSine: return @"kCC3SemanticSceneTimeSine";
		case kCC3SemanticSceneTimeCosine: return @"kCC3SemanticSceneTimeCosine";
		case kCC3SemanticSceneTimeTangent: return @"kCC3SemanticSceneTimeTangent";

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
#pragma mark CC3ShaderSemanticsBase

@implementation CC3ShaderSemanticsBase

+(id) semanticsDelegate { return [[[self alloc] init] autorelease]; }

-(NSString*) nameOfSemantic: (GLenum) semantic { return NSStringFromCC3Semantic(semantic); }

-(BOOL) configureVariable: (CC3GLSLVariable*) variable { return NO; }

/**
 * Returns a variable scope derived from the specified semantic.
 *
 * Subclasses that permit application-specific semantics should override this method to
 * handle those additional semantics if they should not default to kCC3GLSLVariableScopeNode.
 */
-(CC3GLSLVariableScope) variableScopeForSemantic: (GLenum) semantic {
	switch (semantic) {

		// Draw scope semantics

		case kCC3SemanticDrawCountCurrentFrame:
		case kCC3SemanticRandomNumber:

		case kCC3SemanticBatchBoneCount:

		case kCC3SemanticBoneMatricesGlobal:
		case kCC3SemanticBoneMatricesInvTranGlobal:
		case kCC3SemanticBoneMatricesEyeSpace:
		case kCC3SemanticBoneMatricesInvTranEyeSpace:
		case kCC3SemanticBoneMatricesModelSpace:
		case kCC3SemanticBoneMatricesInvTranModelSpace:

		case kCC3SemanticBoneQuaternionsGlobal:
		case kCC3SemanticBoneTranslationsGlobal:
		case kCC3SemanticBoneScalesGlobal:
		case kCC3SemanticBoneQuaternionsEyeSpace:
		case kCC3SemanticBoneTranslationsEyeSpace:
		case kCC3SemanticBoneScalesEyeSpace:
		case kCC3SemanticBoneQuaternionsModelSpace:
		case kCC3SemanticBoneTranslationsModelSpace:
		case kCC3SemanticBoneScalesModelSpace:
			
			return kCC3GLSLVariableScopeDraw;

			
		// Scene scope semantics
			
		case kCC3SemanticViewMatrix:
		case kCC3SemanticViewMatrixInv:
		case kCC3SemanticViewMatrixInvTran:
		case kCC3SemanticProjMatrix:
		case kCC3SemanticProjMatrixInv:
		case kCC3SemanticProjMatrixInvTran:
		case kCC3SemanticViewProjMatrix:
		case kCC3SemanticViewProjMatrixInv:
		case kCC3SemanticViewProjMatrixInvTran:
			
		case kCC3SemanticCameraLocationGlobal:
		case kCC3SemanticCameraFrustum:
		case kCC3SemanticCameraFrustumDepth:
		case kCC3SemanticViewport:

		case kCC3SemanticSceneLightColorAmbient:

		case kCC3SemanticLightIsEnabled:
		case kCC3SemanticLightPositionGlobal:
		case kCC3SemanticLightPositionEyeSpace:
		case kCC3SemanticLightInvertedPositionGlobal:
		case kCC3SemanticLightInvertedPositionEyeSpace:
		case kCC3SemanticLightColorAmbient:
		case kCC3SemanticLightColorDiffuse:
		case kCC3SemanticLightColorSpecular:
		case kCC3SemanticLightAttenuation:
		case kCC3SemanticLightSpotDirectionGlobal:
		case kCC3SemanticLightSpotDirectionEyeSpace:
		case kCC3SemanticLightSpotExponent:
		case kCC3SemanticLightSpotCutoffAngle:
		case kCC3SemanticLightSpotCutoffAngleCosine:

		case kCC3SemanticFogIsEnabled:
		case kCC3SemanticFogColor:
		case kCC3SemanticFogAttenuationMode:
		case kCC3SemanticFogDensity:
		case kCC3SemanticFogStartDistance:
		case kCC3SemanticFogEndDistance:
			
		case kCC3SemanticFrameTime:
		case kCC3SemanticSceneTime:
		case kCC3SemanticSceneTimeSine:
		case kCC3SemanticSceneTimeCosine:
		case kCC3SemanticSceneTimeTangent:
			
			return kCC3GLSLVariableScopeScene;
			
			
		// Node scope semantics
		default:
			return kCC3GLSLVariableScopeNode;
	}
}

/**
 * For semantics that may have more than one target, such as components of lights, or textures,
 * the iteration loops in this method are designed to deal with two situations:
 *   - If the uniform is declared as an array of single types (eg- an array of floats, bools, or
 *     vec3's), the uniform semantic index will be zero and the uniform size will be larger than one.
 *   - If the uniform is declared as a scalar (eg- distinct uniforms for each light, etc), the
 *     uniform size will be one, but the uniform semantic index can be larger than zero.
 */
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ drawing %@ retrieving semantic value for %@", self, visitor.currentNode, uniform.fullDescription);
	GLenum semantic = uniform.semantic;
	GLuint semanticIndex = uniform.semanticIndex;
	GLint uniformSize = uniform.size;
	
	CC3Material* mat;
	CC3SkinSection* skin;
	CC3PointParticleEmitter* emitter;
	CC3Matrix4x4 m4x4;
	CC3Matrix4x3 m4x3,  mRslt4x3, tfmMtx, *pm4x3;
	CC3Matrix3x3 m3x3;
	CC3Viewport vp;
	CCTime sceneTime;
	GLuint boneCnt = 0, tuCnt = 0, texCnt = 0;
	BOOL isInverted = NO, isPtEmitter = NO;
	
	switch (semantic) {
		
#pragma mark Setting attribute semantics
		// ATTRIBUTE QUALIFIERS --------------
		case kCC3SemanticHasVertexNormal:
			[uniform setBoolean: visitor.currentMesh.hasVertexNormals];
			return YES;
		case kCC3SemanticShouldNormalizeVertexNormal:
			[uniform setBoolean: (visitor.currentMeshNode.effectiveNormalScalingMethod == kCC3NormalScalingNormalize)];
			return YES;
		case kCC3SemanticShouldRescaleVertexNormal:
			[uniform setBoolean: (visitor.currentMeshNode.effectiveNormalScalingMethod == kCC3NormalScalingRescale)];
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
		case kCC3SemanticHasVertexWeight:
			[uniform setBoolean: visitor.currentMesh.hasVertexBoneWeights];
			return YES;
		case kCC3SemanticHasVertexMatrixIndex:
			[uniform setBoolean: visitor.currentMesh.hasVertexBoneIndices];
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
		case kCC3SemanticShouldDrawFrontFaces:
			[uniform setBoolean: !visitor.currentMeshNode.shouldCullFrontFaces];
			return YES;
		case kCC3SemanticShouldDrawBackFaces:
			[uniform setBoolean: !visitor.currentMeshNode.shouldCullBackFaces];
			return YES;

#pragma mark Setting environment matrix semantics
		// ENVIRONMENT MATRICES --------------
		case kCC3SemanticModelLocalMatrix:
			// Get local matrix as P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.globalTransformMatrixInverted populateCC3Matrix4x3: &m4x3];
			[visitor.currentMeshNode.globalTransformMatrix populateCC3Matrix4x3: &tfmMtx];
			CC3Matrix4x3Multiply(&mRslt4x3, &m4x3, &tfmMtx);
			[uniform setMatrix4x3: &mRslt4x3];
			return YES;
		case kCC3SemanticModelLocalMatrixInv:
			// Get local matrix as P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.globalTransformMatrixInverted populateCC3Matrix4x3: &m4x3];
			[visitor.currentMeshNode.globalTransformMatrix populateCC3Matrix4x3: &tfmMtx];
			CC3Matrix4x3Multiply(&mRslt4x3, &m4x3, &tfmMtx);
			// Now invert
			CC3Matrix4x3InvertAdjoint(&mRslt4x3);
			[uniform setMatrix4x3: &mRslt4x3];
			return YES;
		case kCC3SemanticModelLocalMatrixInvTran:
			// Get local matrix as P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.globalTransformMatrixInverted populateCC3Matrix4x3: &m4x3];
			[visitor.currentMeshNode.globalTransformMatrix populateCC3Matrix4x3: &tfmMtx];
			CC3Matrix4x3Multiply(&mRslt4x3, &m4x3, &tfmMtx);
			CC3Matrix3x3PopulateFrom4x3(&m3x3, &mRslt4x3);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
		case kCC3SemanticModelMatrix:
			[uniform setMatrix4x3: visitor.modelMatrix];
			return YES;
		case kCC3SemanticModelMatrixInv:
			CC3Matrix4x3PopulateFrom4x3(&m4x3, visitor.modelMatrix);
			CC3Matrix4x3InvertAdjoint(&m4x3);
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticModelMatrixInvTran:
			CC3Matrix3x3PopulateFrom4x3(&m3x3, visitor.modelMatrix);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
		case kCC3SemanticViewMatrix:
			[uniform setMatrix4x3: visitor.viewMatrix];
			return YES;
		case kCC3SemanticViewMatrixInv:
			CC3Matrix4x3PopulateFrom4x3(&m4x3, visitor.viewMatrix);
			CC3Matrix4x3InvertAdjoint(&m4x3);
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticViewMatrixInvTran:
			CC3Matrix3x3PopulateFrom4x3(&m3x3, visitor.viewMatrix);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
		case kCC3SemanticModelViewMatrix:
			[uniform setMatrix4x3: visitor.modelViewMatrix];
			return YES;
		case kCC3SemanticModelViewMatrixInv:
			CC3Matrix4x3PopulateFrom4x3(&m4x3, visitor.modelViewMatrix);
			CC3Matrix4x3InvertAdjoint(&m4x3);
			[uniform setMatrix4x3: &m4x3];
			return YES;
		case kCC3SemanticModelViewMatrixInvTran:
			CC3Matrix3x3PopulateFrom4x3(&m3x3, visitor.modelViewMatrix);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
		case kCC3SemanticProjMatrix:
			[uniform setMatrix4x4: visitor.projMatrix];
			return YES;
		case kCC3SemanticProjMatrixInv:
			CC3Matrix4x4PopulateFrom4x4(&m4x4, visitor.projMatrix);
			CC3Matrix4x4InvertAdjoint(&m4x4);
			[uniform setMatrix4x4: &m4x4];
			return YES;
		case kCC3SemanticProjMatrixInvTran:
			CC3Matrix3x3PopulateFrom4x4(&m3x3, visitor.projMatrix);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
		case kCC3SemanticViewProjMatrix:
			[uniform setMatrix4x4: visitor.viewProjMatrix];
			return YES;
		case kCC3SemanticViewProjMatrixInv:
			CC3Matrix4x4PopulateFrom4x4(&m4x4, visitor.viewProjMatrix);
			CC3Matrix4x4InvertAdjoint(&m4x4);
			[uniform setMatrix4x4: &m4x4];
			return YES;
		case kCC3SemanticViewProjMatrixInvTran:
			CC3Matrix3x3PopulateFrom4x4(&m3x3, visitor.viewProjMatrix);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
		case kCC3SemanticModelViewProjMatrix:
			[uniform setMatrix4x4: visitor.modelViewProjMatrix];
			return YES;
		case kCC3SemanticModelViewProjMatrixInv:
			CC3Matrix4x4PopulateFrom4x4(&m4x4, visitor.modelViewProjMatrix);
			CC3Matrix4x4InvertAdjoint(&m4x4);
			[uniform setMatrix4x4: &m4x4];
			return YES;
		case kCC3SemanticModelViewProjMatrixInvTran:
			CC3Matrix3x3PopulateFrom4x4(&m3x3, visitor.modelViewProjMatrix);
			CC3Matrix3x3InvertAdjointTranspose(&m3x3);
			[uniform setMatrix3x3: &m3x3];
			return YES;
			
#pragma mark Setting skinning semantics
		// BONE SKINNING ----------------
		case kCC3SemanticVertexBoneCount:
			[uniform setInteger: visitor.currentMeshNode.vertexBoneCount];
			return YES;
		case kCC3SemanticBatchBoneCount:
			[uniform setInteger: visitor.currentSkinSection.boneCount];
			return YES;

		// BONE SKINNING MATRICES ----------------
		case kCC3SemanticBoneMatricesGlobal:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++)
				[uniform setMatrix4x3: [visitor globalBoneMatrixAt: boneIdx] at: boneIdx];
			return YES;
		case kCC3SemanticBoneMatricesInvTranGlobal:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				CC3Matrix3x3PopulateFrom4x3(&m3x3, [visitor globalBoneMatrixAt: boneIdx]);
				CC3Matrix3x3InvertAdjointTranspose(&m3x3);
				[uniform setMatrix3x3: &m3x3 at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneMatricesEyeSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++)
				[uniform setMatrix4x3: [visitor eyeSpaceBoneMatrixAt: boneIdx] at: boneIdx];
			return YES;
		case kCC3SemanticBoneMatricesInvTranEyeSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				CC3Matrix3x3PopulateFrom4x3(&m3x3, [visitor eyeSpaceBoneMatrixAt: boneIdx]);
				CC3Matrix3x3InvertAdjointTranspose(&m3x3);
				[uniform setMatrix3x3: &m3x3 at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneMatricesModelSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++)
				[uniform setMatrix4x3: [visitor modelSpaceBoneMatrixAt: boneIdx] at: boneIdx];
			return YES;
		case kCC3SemanticBoneMatricesInvTranModelSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				CC3Matrix3x3PopulateFrom4x3(&m3x3, [visitor modelSpaceBoneMatrixAt: boneIdx]);
				CC3Matrix3x3InvertAdjointTranspose(&m3x3);
				[uniform setMatrix3x3: &m3x3 at: boneIdx];
			}
			return YES;
			
		// BONE SKINNING DISCRETE TRANSFORMS
		case kCC3SemanticBoneQuaternionsGlobal:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				pm4x3 = [visitor globalBoneMatrixAt: boneIdx];
				[uniform setVector4: CC3Matrix4x3ExtractQuaternion(pm4x3) at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneTranslationsGlobal:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				pm4x3 = [visitor globalBoneMatrixAt: boneIdx];
				[uniform setVector: CC3Matrix4x3ExtractTranslation(pm4x3) at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneScalesGlobal:
		case kCC3SemanticBoneScalesEyeSpace:		// Same as global because view matrix is not scaled
			skin = visitor.currentSkinSection;
			boneCnt = skin.boneCount;
			CC3AssertBoneUniformForSkinSection(uniform, skin);
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++)
				[uniform setVector: CC3VectorScale(visitor.currentMeshNode.globalScale,
												   [skin boneAt: boneIdx].skeletalScale)];
			return YES;
		case kCC3SemanticBoneQuaternionsEyeSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				pm4x3 = [visitor eyeSpaceBoneMatrixAt: boneIdx];
				[uniform setVector4: CC3Matrix4x3ExtractQuaternion(pm4x3) at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneTranslationsEyeSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				pm4x3 = [visitor eyeSpaceBoneMatrixAt: boneIdx];
				[uniform setVector: CC3Matrix4x3ExtractTranslation(pm4x3) at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneQuaternionsModelSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				pm4x3 = [visitor modelSpaceBoneMatrixAt: boneIdx];
				[uniform setVector4: CC3Matrix4x3ExtractQuaternion(pm4x3) at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneTranslationsModelSpace:
			CC3AssertBoneUniformForSkinSection(uniform, visitor.currentSkinSection);
			boneCnt = visitor.currentSkinSection.boneCount;
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++) {
				pm4x3 = [visitor modelSpaceBoneMatrixAt: boneIdx];
				[uniform setVector: CC3Matrix4x3ExtractTranslation(pm4x3) at: boneIdx];
			}
			return YES;
		case kCC3SemanticBoneScalesModelSpace:
			skin = visitor.currentSkinSection;
			boneCnt = skin.boneCount;
			CC3AssertBoneUniformForSkinSection(uniform, skin);
			for (GLuint boneIdx = 0; boneIdx < boneCnt; boneIdx++)
				[uniform setVector: [skin boneAt: boneIdx].skeletalScale];
			return YES;

			
#pragma mark Setting camera semantics
		// CAMERA -----------------
		case kCC3SemanticCameraLocationGlobal:
			[uniform setVector: visitor.camera.globalLocation];
			return YES;
		case kCC3SemanticCameraLocationModelSpace:
			// Transform the global camera location to the local model space
			[uniform setVector: [visitor.currentMeshNode.globalTransformMatrixInverted
								 transformLocation: visitor.camera.globalLocation]];
			return YES;
		case kCC3SemanticCameraFrustum: {
			// Applies the field of view angle to the narrower aspect.
			vp = visitor.camera.viewport;
			GLfloat aspect = (GLfloat) vp.w / (GLfloat) vp.h;
			CC3Camera* cam = visitor.camera;
			GLfloat fovWidth, fovHeight;
			if (aspect >= 1.0f) {			// Landscape
				fovHeight = CC3DegToRad(cam.effectiveFieldOfView);
				fovWidth = fovHeight * aspect;
			} else {						// Portrait
				fovWidth = CC3DegToRad(cam.effectiveFieldOfView);
				fovHeight = fovWidth / aspect;
			}
			[uniform setVector4: CC3Vector4Make(fovWidth, fovHeight,
												cam.nearClippingDistance,
												cam.farClippingDistance)];
			return YES;
		}
		case kCC3SemanticCameraFrustumDepth: {
			CC3Camera* cam = visitor.camera;
			[cam.projectionMatrix populateCC3Matrix4x4: &m4x4];
			[uniform setVector4: CC3Vector4Make(cam.farClippingDistance,
												cam.nearClippingDistance,
												m4x4.c3r3, m4x4.c4r3)];
			return YES;
		}
		case kCC3SemanticViewport:
			vp = visitor.camera.viewport;
			[uniform setIntVector4: CC3IntVector4Make(vp.x, vp.y, vp.w, vp.h)];
			return YES;
			
#pragma mark Setting material semantics
		// MATERIALS --------------
		case kCC3SemanticColor:
			[uniform setColor4F: visitor.currentColor];
			return YES;
		case kCC3SemanticMaterialColorAmbient:
			[uniform setColor4F: visitor.currentMaterial.effectiveAmbientColor];
			return YES;
		case kCC3SemanticMaterialColorDiffuse:
			[uniform setColor4F: visitor.currentMaterial.effectiveDiffuseColor];
			return YES;
		case kCC3SemanticMaterialColorSpecular:
			[uniform setColor4F: visitor.currentMaterial.effectiveSpecularColor];
			return YES;
		case kCC3SemanticMaterialColorEmission:
			[uniform setColor4F: visitor.currentMaterial.effectiveEmissionColor];
			return YES;
		case kCC3SemanticMaterialOpacity:
			[uniform setFloat: visitor.currentMaterial.effectiveDiffuseColor.a];
			return YES;
		case kCC3SemanticMaterialShininess:
			[uniform setFloat: visitor.currentMaterial.shininess];
			return YES;
		case kCC3SemanticMaterialReflectivity:
			[uniform setFloat: visitor.currentMaterial.reflectivity];
			return YES;
		case kCC3SemanticMinimumDrawnAlpha:
			mat = visitor.currentMaterial;
			[uniform setFloat: (mat.shouldDrawLowAlpha ? 0.0f : mat.alphaTestReference)];
			return YES;
			
#pragma mark Setting lighting semantics
		// LIGHTING --------------
		case kCC3SemanticIsUsingLighting:
			[uniform setBoolean: visitor.currentNode.shouldUseLighting];
			return YES;
		case kCC3SemanticSceneLightColorAmbient:
			[uniform setColor4F: visitor.scene.ambientLight];
			return YES;
		case kCC3SemanticLightIsEnabled:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				[uniform setBoolean: light.visible at: i];
			}
			return YES;

		case kCC3SemanticLightInvertedPositionGlobal:
			isInverted = YES;
		case kCC3SemanticLightPositionGlobal:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				CC3Vector4 ltPos = light.globalHomogeneousPosition;
				if (isInverted) ltPos = CC3Vector4HomogeneousNegate(ltPos);
				[uniform setVector4: ltPos at: i];
			}
			return YES;
		case kCC3SemanticLightInvertedPositionEyeSpace:
			isInverted = YES;
		case kCC3SemanticLightPositionEyeSpace:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				CC3Vector4 ltPos = light.globalHomogeneousPosition;
				if (isInverted) ltPos = CC3Vector4HomogeneousNegate(ltPos);
				// Transform global position/direction to eye space and normalize if direction
				ltPos = CC3Matrix4x3TransformCC3Vector4(visitor.viewMatrix, ltPos);
				if (light.isDirectionalOnly) ltPos = CC3Vector4Normalize(ltPos);
				[uniform setVector4: ltPos at: i];
			}
			return YES;
		case kCC3SemanticLightInvertedPositionModelSpace:
			isInverted = YES;
		case kCC3SemanticLightPositionModelSpace:
			[visitor.currentMeshNode.globalTransformMatrixInverted populateCC3Matrix4x3: &m4x3];
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				CC3Vector4 ltPos = light.globalHomogeneousPosition;
				if (isInverted) ltPos = CC3Vector4HomogeneousNegate(ltPos);
				// Transform global position/direction to model space and normalize if direction
				ltPos = CC3Matrix4x3TransformCC3Vector4(&m4x3, ltPos);
				if (light.isDirectionalOnly) ltPos = CC3Vector4Normalize(ltPos);
				[uniform setVector4: ltPos at: i];
			}
			return YES;

		case kCC3SemanticLightColorAmbient:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				ccColor4F ltColor = light.visible ? light.ambientColor : kCCC4FBlackTransparent;
				[uniform setColor4F: ltColor at: i];
			}
			return YES;
		case kCC3SemanticLightColorDiffuse:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				ccColor4F ltColor = light.visible ? light.diffuseColor : kCCC4FBlackTransparent;
				[uniform setColor4F: ltColor at: i];
			}
			return YES;
		case kCC3SemanticLightColorSpecular:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				ccColor4F ltColor = light.visible ? light.specularColor : kCCC4FBlackTransparent;
				[uniform setColor4F: ltColor at: i];
			}
			return YES;
		case kCC3SemanticLightAttenuation:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				CC3AttenuationCoefficients ac = CC3AttenuationCoefficientsLegalize(light.attenuation);
				[uniform setVector: *(CC3Vector*)&ac at: i];
			}
			return YES;

		case kCC3SemanticLightSpotDirectionGlobal:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				[uniform setVector: light.globalForwardDirection at: i];
			}
			return YES;
		case kCC3SemanticLightSpotDirectionEyeSpace:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				CC3Vector spotDir = light.globalForwardDirection;
				// Transform global direction to eye space and normalize
				spotDir = CC3Matrix4x3TransformDirection(visitor.viewMatrix, spotDir);
				[uniform setVector: CC3VectorNormalize(spotDir) at: i];
			}
			return YES;
		case kCC3SemanticLightSpotDirectionModelSpace:
			[visitor.currentMeshNode.globalTransformMatrixInverted populateCC3Matrix4x3: &m4x3];
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				CC3Vector spotDir = light.globalForwardDirection;
				// Transform global direction to model space and normalize
				spotDir = CC3Matrix4x3TransformDirection(&m4x3, spotDir);
				[uniform setVector: CC3VectorNormalize(spotDir) at: i];
			}
			return YES;
		case kCC3SemanticLightSpotExponent:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				[uniform setFloat: light.spotExponent at: i];
			}
			return YES;
		case kCC3SemanticLightSpotCutoffAngle:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				[uniform setFloat: light.spotCutoffAngle at: i];
			}
			return YES;
		case kCC3SemanticLightSpotCutoffAngleCosine:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3Light* light = [visitor lightAt: (semanticIndex + i)];
				[uniform setFloat: cosf(CC3DegToRad(light.spotCutoffAngle)) at: i];
			}
			return YES;
			
		case kCC3SemanticFogIsEnabled:
			[uniform setBoolean: visitor.scene.fog.visible];
			return YES;
		case kCC3SemanticFogColor:
			[uniform setColor4F: visitor.scene.fog.diffuseColor];
			return YES;
		case kCC3SemanticFogAttenuationMode:
			[uniform setInteger: visitor.scene.fog.attenuationMode];
			return YES;
		case kCC3SemanticFogDensity:
			[uniform setFloat: visitor.scene.fog.density];
			return YES;
		case kCC3SemanticFogStartDistance:
			[uniform setFloat: visitor.scene.fog.startDistance];
			return YES;
		case kCC3SemanticFogEndDistance:
			[uniform setFloat: visitor.scene.fog.endDistance];
			return YES;
			
#pragma mark Setting texture semantics
		// TEXTURES --------------
		case kCC3SemanticTextureCount:
			// Count all textures of any type
			[uniform setInteger: visitor.textureCount];
			return YES;
		case kCC3SemanticTextureSampler:
			// Samplers that can be any type are simply consecutive texture unit indices
			// starting at the semanticIndex of the uniform. Typically, semanticIndex > 0
			// and uniformSize > 1 are mutually exclusive.
			for (GLuint i = 0; i < uniformSize; i++) [uniform setInteger: (semanticIndex + i) at: i];
			return YES;

		case kCC3SemanticTexture2DCount:
			mat = visitor.currentMaterial;
			tuCnt = visitor.textureCount;
			// Count just the textures whose sampler semantic is of the correct type
			for (GLuint tuIdx = 0; tuIdx < tuCnt; tuIdx++)
				if ( [mat textureForTextureUnit: tuIdx].samplerSemantic == kCC3SemanticTexture2DSampler ) texCnt++;
			[uniform setInteger: texCnt];
			return YES;
		case kCC3SemanticTextureCubeCount:
			mat = visitor.currentMaterial;
			tuCnt = visitor.textureCount;
			// Count just the textures whose sampler semantic is of the correct type
			for (GLuint tuIdx = 0; tuIdx < tuCnt; tuIdx++)
				if ( [mat textureForTextureUnit: tuIdx].samplerSemantic == kCC3SemanticTextureCubeSampler ) texCnt++;
			[uniform setInteger: texCnt];
			return YES;

		case kCC3SemanticTexture2DSampler:
			// 2D samplers always come first and are consecutive, so we can simply use consecutive
			// texture unit indices starting at the semanticIndex of the uniform. Typically,
			// semanticIndex > 0 and uniformSize > 1 are mutually exclusive.
			for (GLuint i = 0; i < uniformSize; i++) [uniform setInteger: (semanticIndex + i) at: i];
			return YES;

		case kCC3SemanticTextureCubeSampler:
			// Cube samplers always come after 2D samplers, and are consecutive, so we can simply
			// use consecutive texture unit indices starting at the semanticIndex of the uniform,
			// plus an offset to skip any 2D textures. Typically, semanticIndex > 0 and
			// uniformSize > 1 are mutually exclusive.
			semanticIndex += visitor.currentShaderProgram.texture2DCount;
			for (GLuint i = 0; i < uniformSize; i++) [uniform setInteger: (semanticIndex + i) at: i];
			return YES;

		// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
		// In most shaders, these will be left unused in favor of customized the texture combining in code.
		case kCC3SemanticTexUnitMode:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3TextureUnit* tu = [visitor currentTextureUnitAt: (semanticIndex + i)];
				[uniform setInteger: (tu ? tu.textureEnvironmentMode :  GL_MODULATE) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitConstantColor:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3TextureUnit* tu = [visitor currentTextureUnitAt: (semanticIndex + i)];
				[uniform setColor4F: (tu ? tu.constantColor :  kCCC4FBlackTransparent) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitCombineRGBFunction:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.combineRGBFunction :  GL_MODULATE) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource0RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.rgbSource0 :  GL_TEXTURE) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource1RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.rgbSource1 :  GL_PREVIOUS) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource2RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.rgbSource2 :  GL_CONSTANT) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand0RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.rgbOperand0 :  GL_SRC_COLOR) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand1RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.rgbOperand1 :  GL_SRC_COLOR) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand2RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.rgbOperand2 :  GL_SRC_ALPHA) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitCombineAlphaFunction:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.combineAlphaFunction :  GL_MODULATE) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource0Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.alphaSource0 :  GL_TEXTURE) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource1Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.alphaSource1 :  GL_PREVIOUS) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource2Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.alphaSource2 :  GL_CONSTANT) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand0Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.alphaOperand0 :  GL_SRC_ALPHA) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand1Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.alphaOperand1 :  GL_SRC_ALPHA) at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand2Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				CC3ConfigurableTextureUnit* ctu = (CC3ConfigurableTextureUnit*)[visitor currentTextureUnitAt: (semanticIndex + i)];
				BOOL isCTU = [ctu isKindOfClass: [CC3ConfigurableTextureUnit class]];
				[uniform setInteger: (isCTU ? ctu.alphaOperand2 :  GL_SRC_ALPHA) at: i];
			}
			return YES;
			
#pragma mark Setting model semantics
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
			[uniform setVector: CC3BoxSize(visitor.currentMeshNode.mesh.boundingBox)];
			return YES;
		case kCC3SemanticAnimationFraction:
			[uniform setFloat: [visitor.currentMeshNode animationTimeOnTrack: 0]];
			return YES;

#pragma mark Setting particle semantics
		// PARTICLES ------------
		case kCC3SemanticPointSize:
			emitter = (CC3PointParticleEmitter*)visitor.currentNode;
			isPtEmitter = [emitter isKindOfClass: [CC3PointParticleEmitter class]];
			[uniform setFloat: (isPtEmitter ? emitter.normalizedParticleSize : 0.0f)];
			return YES;
		case kCC3SemanticPointSizeAttenuation: {
			emitter = (CC3PointParticleEmitter*)visitor.currentNode;
			isPtEmitter = [emitter isKindOfClass: [CC3PointParticleEmitter class]];
			CC3AttenuationCoefficients ac = (isPtEmitter)
												? CC3AttenuationCoefficientsLegalize(emitter.particleSizeAttenuation)
												: kCC3AttenuationNone;
			[uniform setVector: *(CC3Vector*)&ac];
			return YES;
		}
		case kCC3SemanticPointSizeMinimum:
			emitter = (CC3PointParticleEmitter*)visitor.currentNode;
			isPtEmitter = [emitter isKindOfClass: [CC3PointParticleEmitter class]];
			[uniform setFloat: (isPtEmitter ? emitter.normalizedParticleSizeMinimum : 0.0f)];
			return YES;
		case kCC3SemanticPointSizeMaximum:
			emitter = (CC3PointParticleEmitter*)visitor.currentNode;
			isPtEmitter = [emitter isKindOfClass: [CC3PointParticleEmitter class]];
			[uniform setFloat: (isPtEmitter ? emitter.normalizedParticleSizeMaximum : 0.0f)];
			return YES;
		case kCC3SemanticPointSpritesIsEnabled:
			[uniform setBoolean: visitor.currentMeshNode.isDrawingPointSprites];
			return YES;
			
#pragma mark Setting time semantics
		// TIME ------------------
		case kCC3SemanticFrameTime:
			[uniform setFloat: visitor.deltaTime];
			return YES;
		case kCC3SemanticSceneTime:
			sceneTime = visitor.scene.elapsedTimeSinceOpened;
			[uniform setPoint: ccp(sceneTime, fmodf(sceneTime, 1.0))];
			return YES;
		case kCC3SemanticSceneTimeSine:
			sceneTime = visitor.scene.elapsedTimeSinceOpened;
			[uniform setVector4: CC3Vector4Make(sinf(sceneTime),
												sinf(sceneTime / 2.0f),
												sinf(sceneTime / 4.0f),
												sinf(sceneTime / 8.0f))];
			return YES;
		case kCC3SemanticSceneTimeCosine:
			sceneTime = visitor.scene.elapsedTimeSinceOpened;
			[uniform setVector4: CC3Vector4Make(cosf(sceneTime),
												cosf(sceneTime / 2.0f),
												cosf(sceneTime / 4.0f),
												cosf(sceneTime / 8.0f))];
			return YES;
		case kCC3SemanticSceneTimeTangent:
			sceneTime = visitor.scene.elapsedTimeSinceOpened;
			[uniform setVector4: CC3Vector4Make(tanf(sceneTime),
												tanf(sceneTime / 2.0f),
												tanf(sceneTime / 4.0f),
												tanf(sceneTime / 8.0f))];
			return YES;
			
#pragma mark Setting miscellaneous semantics
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
#pragma mark CC3ShaderSemanticsByVarName

@implementation CC3ShaderSemanticsByVarName

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
		variable.scope = [self variableScopeForSemantic: varConfig.semantic];
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
#pragma mark CC3ShaderSemanticsByVarName default mappings extension

@implementation CC3ShaderSemanticsByVarName (DefaultMappings)

-(void) populateWithDefaultVariableNameMappings {
	
	// VETEX ATTRIBUTES --------------
	[self mapVarName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocation];				/**< Vertex location. */
	[self mapVarName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormal];					/**< Vertex normal. */
	[self mapVarName: @"a_cc3Tangent" toSemantic: kCC3SemanticVertexTangent];				/**< Vertex tangent. */
	[self mapVarName: @"a_cc3Bitangent" toSemantic: kCC3SemanticVertexBitangent];			/**< Vertex bitangent (aka binormal). */
	[self mapVarName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColor];					/**< Vertex color. */
	[self mapVarName: @"a_cc3BoneWeights" toSemantic: kCC3SemanticVertexBoneWeights];		/**< Vertex skinning bone weights (each an array of length specified by u_cc3VertexBoneCount). */
	[self mapVarName: @"a_cc3BoneIndices" toSemantic: kCC3SemanticVertexBoneIndices];		/**< Vertex skinning bone indices (each an array of length specified by u_cc3VertexBoneCount). */
	[self mapVarName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSize];			/**< Vertex point size. */
	
	// If only one texture coordinate attribute is used, the index suffix ("a_cc3TexCoordN") is optional.
	[self mapVarName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture];				/**< Vertex texture coordinate for the first texture unit. */
	GLuint maxTexUnits = CC3OpenGL.sharedGL.maxNumberOfTextureUnits;
	for (GLuint tuIdx = 0; tuIdx < maxTexUnits; tuIdx++)
		[self mapVarName: [NSString stringWithFormat: @"a_cc3TexCoord%u", tuIdx] toSemantic: kCC3SemanticVertexTexture at: tuIdx];	/**< Vertex texture coordinate for a texture unit. */
	
	// VERTEX STATE --------------
	[self mapVarName: @"u_cc3VertexHasNormal" toSemantic: kCC3SemanticHasVertexNormal];							/**< (bool) Whether a vertex normal is available. */
	[self mapVarName: @"u_cc3VertexHasTangent" toSemantic: kCC3SemanticHasVertexTangent];						/**< (bool) Whether a vertex tangent is available. */
	[self mapVarName: @"u_cc3VertexHasBitangent" toSemantic: kCC3SemanticHasVertexBitangent];					/**< (bool) Whether a vertex bitangent is available. */
	[self mapVarName: @"u_cc3VertexHasColor" toSemantic: kCC3SemanticHasVertexColor];							/**< (bool) Whether a vertex color is available. */
	[self mapVarName: @"u_cc3VertexHasWeights" toSemantic: kCC3SemanticHasVertexWeight];						/**< (bool) Whether a vertex weight is available. */
	[self mapVarName: @"u_cc3VertexHasMatrixIndices" toSemantic: kCC3SemanticHasVertexMatrixIndex];				/**< (bool) Whether a vertex matrix index is available. */
	[self mapVarName: @"u_cc3VertexHasTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];			/**< (bool) Whether a vertex texture coordinate is available. */
	[self mapVarName: @"u_cc3VertexHasPointSize" toSemantic: kCC3SemanticHasVertexPointSize];					/**< (bool) Whether a vertex point size is available. */
	[self mapVarName: @"u_cc3VertexShouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];	/**< (bool) Whether vertex normals should be normalized. */
	[self mapVarName: @"u_cc3VertexShouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];		/**< (bool) Whether vertex normals should be rescaled. */
	[self mapVarName: @"u_cc3VertexShouldDrawFrontFaces" toSemantic: kCC3SemanticShouldDrawFrontFaces];			/**< (bool) Whether the front side of each face is to be drawn. */
	[self mapVarName: @"u_cc3VertexShouldDrawBackFaces" toSemantic: kCC3SemanticShouldDrawBackFaces];			/**< (bool) Whether the back side of each face is to be drawn. */
	
	// ENVIRONMENT MATRICES --------------
	[self mapVarName: @"u_cc3MatrixModelLocal" toSemantic: kCC3SemanticModelLocalMatrix];						/**< (mat4) Current model-to-parent matrix. */
	[self mapVarName: @"u_cc3MatrixModelLocalInv" toSemantic: kCC3SemanticModelLocalMatrixInv];					/**< (mat4) Inverse of current model-to-parent matrix. */
	[self mapVarName: @"u_cc3MatrixModelLocalInvTran" toSemantic: kCC3SemanticModelLocalMatrixInvTran];			/**< (mat3) Inverse-transpose of current model-to-parent matrix. */
	
	[self mapVarName: @"u_cc3MatrixModel" toSemantic: kCC3SemanticModelMatrix];									/**< (mat4) Current model-to-world matrix. */
	[self mapVarName: @"u_cc3MatrixModelInv" toSemantic: kCC3SemanticModelMatrixInv];							/**< (mat4) Inverse of current model-to-world matrix. */
	[self mapVarName: @"u_cc3MatrixModelInvTran" toSemantic: kCC3SemanticModelMatrixInvTran];					/**< (mat3) Inverse-transpose of current model-to-world matrix. */
	
	[self mapVarName: @"u_cc3MatrixView" toSemantic: kCC3SemanticViewMatrix];									/**< (mat4) Camera view matrix. */
	[self mapVarName: @"u_cc3MatrixViewInv" toSemantic: kCC3SemanticViewMatrixInv];								/**< (mat4) Inverse of camera view matrix. */
	[self mapVarName: @"u_cc3MatrixViewInvTran" toSemantic: kCC3SemanticViewMatrixInvTran];						/**< (mat3) Inverse-transpose of camera view matrix. */
	
	[self mapVarName: @"u_cc3MatrixModelView" toSemantic: kCC3SemanticModelViewMatrix];							/**< (mat4) Current model-view matrix. */
	[self mapVarName: @"u_cc3MatrixModelViewInv" toSemantic: kCC3SemanticModelViewMatrixInv];					/**< (mat4) Inverse of current model-view matrix. */
	[self mapVarName: @"u_cc3MatrixModelViewInvTran" toSemantic: kCC3SemanticModelViewMatrixInvTran];			/**< (mat3) Inverse-transpose of current model-view matrix. */
	
	[self mapVarName: @"u_cc3MatrixProj" toSemantic: kCC3SemanticProjMatrix];									/**< (mat4) Camera projection matrix. */
	[self mapVarName: @"u_cc3MatrixProjInv" toSemantic: kCC3SemanticProjMatrixInv];								/**< (mat4) Inverse of camera projection matrix. */
	[self mapVarName: @"u_cc3MatrixProjInvTran" toSemantic: kCC3SemanticProjMatrixInvTran];						/**< (mat3) Inverse-transpose of camera projection matrix. */
	
	[self mapVarName: @"u_cc3MatrixViewProj" toSemantic: kCC3SemanticViewProjMatrix];							/**< (mat4) Camera view and projection matrix. */
	[self mapVarName: @"u_cc3MatrixViewProjInv" toSemantic: kCC3SemanticViewProjMatrixInv];						/**< (mat4) Inverse of camera view and projection matrix. */
	[self mapVarName: @"u_cc3MatrixViewProjInvTran" toSemantic: kCC3SemanticViewProjMatrixInvTran];				/**< (mat3) Inverse-transpose of camera view and projection matrix. */
	
	[self mapVarName: @"u_cc3MatrixModelViewProj" toSemantic: kCC3SemanticModelViewProjMatrix];					/**< (mat4) Current model-view-projection matrix. */
	[self mapVarName: @"u_cc3MatrixModelViewProjInv" toSemantic: kCC3SemanticModelViewProjMatrixInv];			/**< (mat4) Inverse of current model-view-projection matrix. */
	[self mapVarName: @"u_cc3MatrixModelViewProjInvTran" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];	/**< (mat3) Inverse-transpose of current model-view-projection matrix. */
	
	// BONE SKINNING ----------------
	[self mapVarName: @"u_cc3VertexBoneCount" toSemantic: kCC3SemanticVertexBoneCount];							/**< (int) Number of bones influencing each vertex (ie- number of bone-weights & bone-indices specified on each vertex) */
	[self mapVarName: @"u_cc3BatchBoneCount" toSemantic: kCC3SemanticBatchBoneCount];								/**< (int) Number of bones that are being used by the current skin section. */

	// BONE SKINNING MATRICES ----------------
	[self mapVarName: @"u_cc3BoneMatricesGlobal" toSemantic: kCC3SemanticBoneMatricesGlobal];					/**< (mat4[]) Array of bone matrices in the current mesh skin section in global coordinates (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneMatricesInvTranGlobal" toSemantic: kCC3SemanticBoneMatricesInvTranGlobal];		/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in global coordinates (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneMatricesEyeSpace" toSemantic: kCC3SemanticBoneMatricesEyeSpace];				/**< (mat4[]) Array of bone matrices in the current mesh skin section in eye space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneMatricesInvTranEyeSpace" toSemantic: kCC3SemanticBoneMatricesInvTranEyeSpace];	/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in eye space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneMatricesModel" toSemantic: kCC3SemanticBoneMatricesModelSpace];				/**< (mat4[]) Array of bone matrices in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneMatricesInvTranModel" toSemantic: kCC3SemanticBoneMatricesInvTranModelSpace];	/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */

	// BONE SKINNING DISCRETE TRANSFORMS
	[self mapVarName: @"u_cc3BoneQuaternionsGlobal" toSemantic: kCC3SemanticBoneQuaternionsGlobal];				/**< (vec4[]) Array of bone quaternions in the current mesh skin section in global coordinates (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneTranslationsGlobal" toSemantic: kCC3SemanticBoneTranslationsGlobal];			/**< (vec3[]) Array of bone translations in the current mesh skin section in global coordinates (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneScalesGlobal" toSemantic: kCC3SemanticBoneScalesGlobal];						/**< (vec3[]) Array of bone scales in the current mesh skin section in global coordinates (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneQuaternionsEyeSpace" toSemantic: kCC3SemanticBoneQuaternionsEyeSpace];			/**< (vec4[]) Array of bone quaternions in the current mesh skin section in eye space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneTranslationsEyeSpace" toSemantic: kCC3SemanticBoneTranslationsEyeSpace];		/**< (vec3[]) Array of bone translations in the current mesh skin section in eye space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneScalesEyeSpace" toSemantic: kCC3SemanticBoneScalesEyeSpace];					/**< (vec3[]) Array of bone scales in the current mesh skin section in eye space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneQuaternionsModelSpace" toSemantic: kCC3SemanticBoneQuaternionsModelSpace];		/**< (vec4[]) Array of bone quaternions in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneTranslationsModelSpace" toSemantic: kCC3SemanticBoneTranslationsModelSpace];	/**< (vec3[]) Array of bone translations in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */
	[self mapVarName: @"u_cc3BoneScalesModelSpace" toSemantic: kCC3SemanticBoneScalesModelSpace];				/**< (vec3[]) Array of bone scales in the current mesh skin section in model space (length of array is specified by u_cc3BatchBoneCount). */
	
	// CAMERA -----------------
	[self mapVarName: @"u_cc3CameraPositionGlobal" toSemantic: kCC3SemanticCameraLocationGlobal];		/**< (vec3) Location of the camera in global coordinates. */
	[self mapVarName: @"u_cc3CameraPositionModel" toSemantic: kCC3SemanticCameraLocationModelSpace];	/**< (vec3) Location of the camera in local coordinates of model (not camera). */
	[self mapVarName: @"u_cc3CameraFrustum" toSemantic: kCC3SemanticCameraFrustum];						/**< (vec4) Dimensions of the camera frustum (FOV width (radians), FOV height (radians), near clip, far clip). */
	[self mapVarName: @"u_cc3CameraFrustumDepth" toSemantic: kCC3SemanticCameraFrustumDepth];			/**< (vec4) The depth of the camera frustum (far clip, near clip, -(f+n)/(f-n), -2nf/(f-n)). */
	[self mapVarName: @"u_cc3CameraViewport" toSemantic: kCC3SemanticViewport];							/**< (int4) The viewport rectangle in pixels (x, y, width, height). */
	
	// MATERIALS --------------
	[self mapVarName: @"u_cc3Color" toSemantic: kCC3SemanticColor];									/**< (vec4) Color when lighting & materials are not in use. */
	[self mapVarName: @"u_cc3MaterialAmbientColor" toSemantic: kCC3SemanticMaterialColorAmbient];	/**< (vec4) Ambient color of the material. */
	[self mapVarName: @"u_cc3MaterialDiffuseColor" toSemantic: kCC3SemanticMaterialColorDiffuse];	/**< (vec4) Diffuse color of the material. */
	[self mapVarName: @"u_cc3MaterialSpecularColor" toSemantic: kCC3SemanticMaterialColorSpecular];	/**< (vec4) Specular color of the material. */
	[self mapVarName: @"u_cc3MaterialEmissionColor" toSemantic: kCC3SemanticMaterialColorEmission];	/**< (vec4) Emission color of the material. */
	[self mapVarName: @"u_cc3MaterialOpacity" toSemantic: kCC3SemanticMaterialOpacity];				/**< (float) Opacity of the material. */
	[self mapVarName: @"u_cc3MaterialShininess" toSemantic: kCC3SemanticMaterialShininess];			/**< (float) Shininess of the material (0 <> 128). */
	[self mapVarName: @"u_cc3MaterialReflectivity" toSemantic: kCC3SemanticMaterialReflectivity];	/**< (float) Reflectivity of the material (0 <> 1). */
	[self mapVarName: @"u_cc3MaterialMinimumDrawnAlpha" toSemantic: kCC3SemanticMinimumDrawnAlpha];	/**< (float) Minimum alpha value to be drawn, otherwise will be rendered fully tranparent. */
	
	// LIGHTING --------------
	[self mapVarName: @"u_cc3LightIsUsingLighting" toSemantic: kCC3SemanticIsUsingLighting];					/**< (bool) Whether any lighting is enabled. */
	[self mapVarName: @"u_cc3LightSceneAmbientLightColor" toSemantic: kCC3SemanticSceneLightColorAmbient];		/**< (vec4) Ambient light color of the scene. */
	
	// With multiple lights, each element in the following is an array.
	[self mapVarName: @"u_cc3LightIsLightEnabled" toSemantic: kCC3SemanticLightIsEnabled];						/**< (bool[]) Whether each light is enabled. */
	[self mapVarName: @"u_cc3LightPositionEyeSpace" toSemantic: kCC3SemanticLightPositionEyeSpace];				/**< (vec4[]) Location of each light in eye space. */
	[self mapVarName: @"u_cc3LightPositionGlobal" toSemantic: kCC3SemanticLightPositionGlobal];					/**< (vec4[]) Location of each light in global coordinates. */
	[self mapVarName: @"u_cc3LightPositionModel" toSemantic: kCC3SemanticLightPositionModelSpace];				/**< (vec4[]) Location of each light in local coordinates of model (not light). */
	[self mapVarName: @"u_cc3LightAmbientColor" toSemantic: kCC3SemanticLightColorAmbient];						/**< (vec4[]) Ambient color of each light. */
	[self mapVarName: @"u_cc3LightDiffuseColor" toSemantic: kCC3SemanticLightColorDiffuse];						/**< (vec4[]) Diffuse color of each light. */
	[self mapVarName: @"u_cc3LightSpecularColor" toSemantic: kCC3SemanticLightColorSpecular];					/**< (vec4[]) Specular color of each light. */
	[self mapVarName: @"u_cc3LightAttenuation" toSemantic: kCC3SemanticLightAttenuation];						/**< (vec3[]) Distance attenuation coefficients for each light. */
	[self mapVarName: @"u_cc3LightSpotDirectionEyeSpace" toSemantic: kCC3SemanticLightSpotDirectionEyeSpace];	/**< (vec3[]) Direction of each spotlight in eye space. */
	[self mapVarName: @"u_cc3LightSpotDirectionGlobal" toSemantic: kCC3SemanticLightSpotDirectionGlobal];		/**< (vec3[]) Direction of each spotlight in global coordinates. */
	[self mapVarName: @"u_cc3LightSpotDirectionModel" toSemantic: kCC3SemanticLightSpotDirectionModelSpace];	/**< (vec3[]) Direction of each spotlight in local coordinates of the model (not light). */
	[self mapVarName: @"u_cc3LightSpotExponent" toSemantic: kCC3SemanticLightSpotExponent];						/**< (float[]) Fade-off exponent of each spotlight. */
	[self mapVarName: @"u_cc3LightSpotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle];				/**< (float[]) Cutoff angle of each spotlight (degrees). */
	[self mapVarName: @"u_cc3LightSpotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine];	/**< (float[]) Cosine of cutoff angle of each spotlight. */

	[self mapVarName: @"u_cc3FogIsEnabled" toSemantic: kCC3SemanticFogIsEnabled];				/**< (bool) Whether scene fogging is enabled. */
	[self mapVarName: @"u_cc3FogColor" toSemantic: kCC3SemanticFogColor];						/**< (vec4) Fog color. */
	[self mapVarName: @"u_cc3FogAttenuationMode" toSemantic: kCC3SemanticFogAttenuationMode];	/**< (int) Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
	[self mapVarName: @"u_cc3FogDensity" toSemantic: kCC3SemanticFogDensity];					/**< (float) Fog density. */
	[self mapVarName: @"u_cc3FogStartDistance" toSemantic: kCC3SemanticFogStartDistance];		/**< (float) Distance from camera at which fogging effect starts. */
	[self mapVarName: @"u_cc3FogEndDistance" toSemantic: kCC3SemanticFogEndDistance];			/**< (float) Distance from camera at which fogging effect ends. */

	// TEXTURES --------------
	[self mapVarName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];			/**< (int) Number of active textures of any type. */
	[self mapVarName: @"s_cc3Texture" toSemantic: kCC3SemanticTextureSampler];				/**< (sampler2D/sampler3D) Single texture sampler of any type. */
	[self mapVarName: @"s_cc3Textures" toSemantic: kCC3SemanticTextureSampler];				/**< (sampler2D[]/sampler3D) Array of texture samplers of any single type. */

	[self mapVarName: @"u_cc3Texture2DCount" toSemantic: kCC3SemanticTexture2DCount];		/**< (int) Number of active textures of all types. */
	[self mapVarName: @"s_cc3Texture2D" toSemantic: kCC3SemanticTexture2DSampler];			/**< (sampler2D) Single 2D texture sampler. */
	[self mapVarName: @"s_cc3Texture2Ds" toSemantic: kCC3SemanticTexture2DSampler];			/**< (sampler2D[]) Array of 2D texture samplers. */

	[self mapVarName: @"u_cc3TextureCubeCount" toSemantic: kCC3SemanticTextureCubeCount];	/**< (int) Number of active textures of all types. */
	[self mapVarName: @"s_cc3TextureCube" toSemantic: kCC3SemanticTextureCubeSampler];		/**< (samplerCube) Single cube texture sampler. */
	[self mapVarName: @"s_cc3TextureCubes" toSemantic: kCC3SemanticTextureCubeSampler];		/**< (samplerCube[]) Array of cube texture samplers. */

	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in GLSL code.
	[self mapVarName: @"u_cc3TextureUnitColor" toSemantic: kCC3SemanticTexUnitConstantColor];						/**< (vec4[]) The constant color of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitMode" toSemantic: kCC3SemanticTexUnitMode];									/**< (int[]) Environment mode of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitCombineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction];		/**< (int[]) RBG combiner function of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitRGBSource0" toSemantic: kCC3SemanticTexUnitSource0RGB];						/**< (int[]) The RGB of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitRGBSource1" toSemantic: kCC3SemanticTexUnitSource1RGB];						/**< (int[]) The RGB of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitRGBSource2" toSemantic: kCC3SemanticTexUnitSource2RGB];						/**< (int[]) The RGB of source 2 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitRGBOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB];					/**< (int[]) The RGB combining operand of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitRGBOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB];					/**< (int[]) The RGB combining operand of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitRGBOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB];					/**< (int[]) The RGB combining operand of source 2 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitCombineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction];	/**< (int[]) Alpha combiner function of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitAlphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha];					/**< (int[]) The alpha of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitAlphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha];					/**< (int[]) The alpha of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitAlphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha];					/**< (int[]) The alpha of source 2 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitAlphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha];				/**< (int[]) The alpha combining operand of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitAlphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha];				/**< (int[]) The alpha combining operand of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnitAlphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha];				/**< (int[]) The alpha combining operand of source 2 of each texture unit. */
	
	// MODEL ----------------
	[self mapVarName: @"u_cc3ModelCenterOfGeometry" toSemantic: kCC3SemanticCenterOfGeometry];		/**< (vec3) The center of geometry of the model in the model's local coordinates. */
	[self mapVarName: @"u_cc3ModelBoundingRadius" toSemantic: kCC3SemanticBoundingRadius];			/**< (float) The radius of a sphere, located at the center of geometry, that encompasses all of the vertices, in the model's local coordinates. */
	[self mapVarName: @"u_cc3ModelBoundingBoxMinimum" toSemantic: kCC3SemanticBoundingBoxMin];		/**< (vec3) The maximum corner of the model's bounding box in the model's local coordinates. */
	[self mapVarName: @"u_cc3ModelBoundingBoxMaximum" toSemantic: kCC3SemanticBoundingBoxMax];		/**< (vec3) The dimensions of the model's bounding box in the model's local coordinates. */
	[self mapVarName: @"u_cc3ModelBoundingBoxSize" toSemantic: kCC3SemanticBoundingBoxSize];		/**< (float) The radius of the model's bounding sphere in the model's local coordinates. */
	[self mapVarName: @"u_cc3ModelAnimationFraction" toSemantic: kCC3SemanticAnimationFraction];	/**< (float) Fraction of the model's animation that has been viewed (range 0-1). */
	
	// PARTICLES ------------
	[self mapVarName: @"u_cc3IsDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];						/**< (bool) Whether the vertices are being drawn as points. */
	[self mapVarName: @"u_cc3PointSize" toSemantic: kCC3SemanticPointSize];									/**< (float) Default size of points, if not specified per-vertex in a vertex attribute array. */
	[self mapVarName: @"u_cc3PointSizeAttenuation" toSemantic: kCC3SemanticPointSizeAttenuation];			/**< (vec3) Point size distance attenuation coefficients. */
	[self mapVarName: @"u_cc3PointMinimumSize" toSemantic: kCC3SemanticPointSizeMinimum];					/**< (float) Minimum size points will be allowed to shrink to. */
	[self mapVarName: @"u_cc3PointMaximumSize" toSemantic: kCC3SemanticPointSizeMaximum];					/**< (float) Maximum size points will be allowed to grow to. */
	[self mapVarName: @"u_cc3PointShouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];	/**< (bool) Whether points should be interpeted as textured sprites. */
	
	// TIME ------------------
	[self mapVarName: @"u_cc3FrameTime" toSemantic: kCC3SemanticFrameTime];				/**< (float) The time in seconds since the last frame. */
	[self mapVarName: @"u_cc3SceneTime" toSemantic: kCC3SemanticSceneTime];				/**< (vec2) The real time, in seconds, since the scene was opened, and the fractional part of that time (T, fmod(T, 1)). */
	[self mapVarName: @"u_cc3SceneTimeSin" toSemantic: kCC3SemanticSceneTimeSine];		/**< (vec4) Sine of the scene time (sin(T), sin(T/2), sin(T/4), sin(T/8)). */
	[self mapVarName: @"u_cc3SceneTimeCos" toSemantic: kCC3SemanticSceneTimeCosine];	/**< (vec4) Cosine of the scene time (cos(T), cos(T/2), cos(T/4), cos(T/8)). */
	[self mapVarName: @"u_cc3SceneTimeTan" toSemantic: kCC3SemanticSceneTimeTangent];	/**< (vec4) Tangent of the scene time (tan(T), tan(T/2), tan(T/4), tan(T/8)). */

	// MISC ENVIRONMENT --------
	[self mapVarName: @"u_cc3DrawCount" toSemantic: kCC3SemanticDrawCountCurrentFrame];		/**< (int) The number of draw calls so far in this frame. */
	[self mapVarName: @"u_cc3Random" toSemantic: kCC3SemanticRandomNumber];					/**< (float) A random number between 0 and 1. */

	// DEPRECATED ------------------
	[self mapVarName: @"u_cc3BonesPerVertex" toSemantic: kCC3SemanticVertexBoneCount];	/**< @deprecated Replaced with u_cc3VertexBoneCount. */
	[self mapVarName: @"u_cc3BoneCount" toSemantic: kCC3SemanticBatchBoneCount];			/**< @deprecated Replaced with u_cc3BatchBoneCount. */
	[self mapVarName: @"u_cc3BoneMatrixCount" toSemantic: kCC3SemanticBatchBoneCount];	/**< @deprecated Replaced with u_cc3BatchBoneCount. */
	[self mapVarName: @"u_cc3AppTime" toSemantic: kCC3SemanticSceneTime];				/**< @deprecated Use u_cc3SceneTime instead. */
	[self mapVarName: @"u_cc3AppTimeSine" toSemantic: kCC3SemanticSceneTimeSine];		/**< @deprecated Use u_cc3SceneTimeSin instead. */
	[self mapVarName: @"u_cc3AppTimeCosine" toSemantic: kCC3SemanticSceneTimeCosine];	/**< @deprecated Use u_cc3SceneTimeCos instead. */
	[self mapVarName: @"u_cc3AppTimeTangent" toSemantic: kCC3SemanticSceneTimeTangent];	/**< @deprecated Use u_cc3SceneTimeTan instead. */
}

-(void) populateWithStructuredVariableNameMappings {
	
	// VETEX ATTRIBUTES --------------
	[self mapVarName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocation];				/**< Vertex location. */
	[self mapVarName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormal];					/**< Vertex normal. */
	[self mapVarName: @"a_cc3Tangent" toSemantic: kCC3SemanticVertexTangent];				/**< Vertex tangent. */
	[self mapVarName: @"a_cc3Bitangent" toSemantic: kCC3SemanticVertexBitangent];			/**< Vertex bitangent (aka binormal). */
	[self mapVarName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColor];					/**< Vertex color. */
	[self mapVarName: @"a_cc3BoneWeights" toSemantic: kCC3SemanticVertexBoneWeights];		/**< Vertex skinning bone weights (each an array of length specified by u_cc3BonesPerVertex). */
	[self mapVarName: @"a_cc3BoneIndices" toSemantic: kCC3SemanticVertexBoneIndices];		/**< Vertex skinning bone indices (each an array of length specified by u_cc3BonesPerVertex). */
	[self mapVarName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSize];			/**< Vertex point size. */
	
	// If only one texture coordinate attribute is used, the index suffix ("a_cc3TexCoordN") is optional.
	[self mapVarName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture];				/**< Vertex texture coordinate for the first texture unit. */
	GLuint maxTexUnits = CC3OpenGL.sharedGL.maxNumberOfTextureUnits;
	for (GLuint tuIdx = 0; tuIdx < maxTexUnits; tuIdx++)
		[self mapVarName: [NSString stringWithFormat: @"a_cc3TexCoord%u", tuIdx] toSemantic: kCC3SemanticVertexTexture at: tuIdx];	/**< Vertex texture coordinate for a texture unit. */
	
	// VERTEX STATE --------------
	[self mapVarName: @"u_cc3Vertex.hasVertexNormal" toSemantic: kCC3SemanticHasVertexNormal];					/**< (bool) Whether a vertex normal is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexTangent" toSemantic: kCC3SemanticHasVertexTangent];				/**< (bool) Whether a vertex tangent is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexBitangent" toSemantic: kCC3SemanticHasVertexBitangent];			/**< (bool) Whether a vertex bitangent is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexColor" toSemantic: kCC3SemanticHasVertexColor];					/**< (bool) Whether a vertex color is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexWeight" toSemantic: kCC3SemanticHasVertexWeight];					/**< (bool) Whether a vertex weight is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexMatrixIndex" toSemantic: kCC3SemanticHasVertexMatrixIndex];		/**< (bool) Whether a vertex matrix index is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];	/**< (bool) Whether a vertex texture coordinate is available. */
	[self mapVarName: @"u_cc3Vertex.hasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];			/**< (bool) Whether a vertex point size is available. */
	[self mapVarName: @"u_cc3Vertex.isDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];					/**< (bool) Whether the vertices are being drawn as points. */
	[self mapVarName: @"u_cc3Vertex.shouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];	/**< (bool) Whether vertex normals should be normalized. */
	[self mapVarName: @"u_cc3Vertex.shouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];	/**< (bool) Whether vertex normals should be rescaled. */
	
	// ENVIRONMENT MATRICES --------------
	[self mapVarName: @"u_cc3Matrices.modelLocal" toSemantic: kCC3SemanticModelLocalMatrix];					/**< (mat4) Current model-to-parent matrix. */
	[self mapVarName: @"u_cc3Matrices.modelLocalInv" toSemantic: kCC3SemanticModelLocalMatrixInv];				/**< (mat4) Inverse of current model-to-parent matrix. */
	[self mapVarName: @"u_cc3Matrices.modelLocalInvTran" toSemantic: kCC3SemanticModelLocalMatrixInvTran];		/**< (mat3) Inverse-transpose of current model-to-parent matrix. */
	
	[self mapVarName: @"u_cc3Matrices.model" toSemantic: kCC3SemanticModelMatrix];								/**< (mat4) Current model-to-world matrix. */
	[self mapVarName: @"u_cc3Matrices.modelInv" toSemantic: kCC3SemanticModelMatrixInv];						/**< (mat4) Inverse of current model-to-world matrix. */
	[self mapVarName: @"u_cc3Matrices.modelInvTran" toSemantic: kCC3SemanticModelMatrixInvTran];				/**< (mat3) Inverse-transpose of current model-to-world matrix. */
	
	[self mapVarName: @"u_cc3Matrices.view" toSemantic: kCC3SemanticViewMatrix];								/**< (mat4) Camera view matrix. */
	[self mapVarName: @"u_cc3Matrices.viewInv" toSemantic: kCC3SemanticViewMatrixInv];							/**< (mat4) Inverse of camera view matrix. */
	[self mapVarName: @"u_cc3Matrices.viewInvTran" toSemantic: kCC3SemanticViewMatrixInvTran];					/**< (mat3) Inverse-transpose of camera view matrix. */
	
	[self mapVarName: @"u_cc3Matrices.modelView" toSemantic: kCC3SemanticModelViewMatrix];						/**< (mat4) Current model-view matrix. */
	[self mapVarName: @"u_cc3Matrices.modelViewInv" toSemantic: kCC3SemanticModelViewMatrixInv];				/**< (mat4) Inverse of current model-view matrix. */
	[self mapVarName: @"u_cc3Matrices.modelViewInvTran" toSemantic: kCC3SemanticModelViewMatrixInvTran];		/**< (mat3) Inverse-transpose of current model-view matrix. */
	
	[self mapVarName: @"u_cc3Matrices.proj" toSemantic: kCC3SemanticProjMatrix];								/**< (mat4) Camera projection matrix. */
	[self mapVarName: @"u_cc3Matrices.projInv" toSemantic: kCC3SemanticProjMatrixInv];							/**< (mat4) Inverse of camera projection matrix. */
	[self mapVarName: @"u_cc3Matrices.projInvTran" toSemantic: kCC3SemanticProjMatrixInvTran];					/**< (mat3) Inverse-transpose of camera projection matrix. */
	
	[self mapVarName: @"u_cc3Matrices.viewProj" toSemantic: kCC3SemanticViewProjMatrix];						/**< (mat4) Camera view and projection matrix. */
	[self mapVarName: @"u_cc3Matrices.viewProjInv" toSemantic: kCC3SemanticViewProjMatrixInv];					/**< (mat4) Inverse of camera view and projection matrix. */
	[self mapVarName: @"u_cc3Matrices.viewProjInvTran" toSemantic: kCC3SemanticViewProjMatrixInvTran];			/**< (mat3) Inverse-transpose of camera view and projection matrix. */
	
	[self mapVarName: @"u_cc3Matrices.modelViewProj" toSemantic: kCC3SemanticModelViewProjMatrix];				/**< (mat4) Current model-view-projection matrix. */
	[self mapVarName: @"u_cc3Matrices.modelViewProjInv" toSemantic: kCC3SemanticModelViewProjMatrixInv];		/**< (mat4) Inverse of current model-view-projection matrix. */
	[self mapVarName: @"u_cc3Matrices.modelViewProjInvTran" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];/**< (mat3) Inverse-transpose of current model-view-projection matrix. */
	
	// SKINNING ----------------
	[self mapVarName: @"u_cc3Bones.bonesPerVertex" toSemantic: kCC3SemanticVertexBoneCount];							/**< (int) Number of bones influencing each vertex (ie- number of weights/matrices specified on each vertex) */
	[self mapVarName: @"u_cc3Bones.matrixCount" toSemantic: kCC3SemanticBatchBoneCount];							/**< (int) Number of matrices in the matrix arrays in this structure. */
	[self mapVarName: @"u_cc3Bones.matricesEyeSpace" toSemantic: kCC3SemanticBoneMatricesEyeSpace];					/**< (mat4[]) Array of bone matrices in the current mesh skin section in eye space. */
	[self mapVarName: @"u_cc3Bones.matricesInvTranEyeSpace" toSemantic: kCC3SemanticBoneMatricesInvTranEyeSpace];	/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in eye space. */
	[self mapVarName: @"u_cc3Bones.matricesGlobal" toSemantic: kCC3SemanticBoneMatricesGlobal];						/**< (mat4[]) Array of bone matrices in the current mesh skin section in global coordinates. */
	[self mapVarName: @"u_cc3Bones.matricesInvTranGlobal" toSemantic: kCC3SemanticBoneMatricesInvTranGlobal];		/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in global coordinates. */
	
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
	// With multiple lights, most of the structure elements is an array.
	[self mapVarName: @"u_cc3Lighting.isUsingLighting" toSemantic: kCC3SemanticIsUsingLighting];					/**< (bool) Whether any lighting is enabled. */
	[self mapVarName: @"u_cc3Lighting.sceneAmbientLightColor" toSemantic: kCC3SemanticSceneLightColorAmbient];		/**< (vec4) Ambient light color of the scene. */
	[self mapVarName: @"u_cc3Lighting.isLightEnabled" toSemantic: kCC3SemanticLightIsEnabled];						/**< (bool[]) Whether each light is enabled. */
	[self mapVarName: @"u_cc3Lighting.positionEyeSpace" toSemantic: kCC3SemanticLightPositionEyeSpace];				/**< (vec4[]) Location of each light in eye space. */
	[self mapVarName: @"u_cc3Lighting.positionGlobal" toSemantic: kCC3SemanticLightPositionGlobal];					/**< (vec4[]) Location of each light in global coordinates. */
	[self mapVarName: @"u_cc3Lighting.positionModel" toSemantic: kCC3SemanticLightPositionModelSpace];				/**< (vec4[]) Location of each light in local coordinates of model (not light). */
	[self mapVarName: @"u_cc3Lighting.ambientColor" toSemantic: kCC3SemanticLightColorAmbient];						/**< (vec4[]) Ambient color of each light. */
	[self mapVarName: @"u_cc3Lighting.diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse];						/**< (vec4[]) Diffuse color of each light. */
	[self mapVarName: @"u_cc3Lighting.specularColor" toSemantic: kCC3SemanticLightColorSpecular];					/**< (vec4[]) Specular color of each light. */
	[self mapVarName: @"u_cc3Lighting.attenuation" toSemantic: kCC3SemanticLightAttenuation];						/**< (vec3[]) Distance attenuation coefficients for each light. */
	[self mapVarName: @"u_cc3Lighting.spotDirectionEyeSpace" toSemantic: kCC3SemanticLightSpotDirectionEyeSpace];	/**< (vec3[]) Direction of each spotlight in eye space. */
	[self mapVarName: @"u_cc3Lighting.spotDirectionGlobal" toSemantic: kCC3SemanticLightSpotDirectionGlobal];		/**< (vec3[]) Direction of each spotlight in global coordinates. */
	[self mapVarName: @"u_cc3Lighting.spotDirectionModel" toSemantic: kCC3SemanticLightSpotDirectionModelSpace];	/**< (vec3[]) Direction of each spotlight in local coordinates of the model (not light). */
	[self mapVarName: @"u_cc3Lighting.spotExponent" toSemantic: kCC3SemanticLightSpotExponent];						/**< (float[]) Fade-off exponent of each spotlight. */
	[self mapVarName: @"u_cc3Lighting.spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle];				/**< (float[]) Cutoff angle of each spotlight (degrees). */
	[self mapVarName: @"u_cc3Lighting.spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine];	/**< (float[]) Cosine of cutoff angle of each spotlight. */
	
	[self mapVarName: @"u_cc3Fog.isEnabled" toSemantic: kCC3SemanticFogIsEnabled];				/**< (bool) Whether scene fogging is enabled. */
	[self mapVarName: @"u_cc3Fog.color" toSemantic: kCC3SemanticFogColor];						/**< (vec4) Fog color. */
	[self mapVarName: @"u_cc3Fog.attenuationMode" toSemantic: kCC3SemanticFogAttenuationMode];	/**< (int) Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
	[self mapVarName: @"u_cc3Fog.density" toSemantic: kCC3SemanticFogDensity];					/**< (float) Fog density. */
	[self mapVarName: @"u_cc3Fog.startDistance" toSemantic: kCC3SemanticFogStartDistance];		/**< (float) Distance from camera at which fogging effect starts. */
	[self mapVarName: @"u_cc3Fog.endDistance" toSemantic: kCC3SemanticFogEndDistance];			/**< (float) Distance from camera at which fogging effect ends. */
	
	// TEXTURES --------------
	[self mapVarName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];	/**< (int) Number of active textures. */
	[self mapVarName: @"s_cc3Texture" toSemantic: kCC3SemanticTextureSampler];		/**< (sampler2D) Single texture sampler (texture unit 0). */
	[self mapVarName: @"s_cc3Textures" toSemantic: kCC3SemanticTextureSampler];		/**< (sampler2D[]) Array of texture samplers. */
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in GLSL code.
	[self mapVarName: @"u_cc3TextureUnits.color" toSemantic: kCC3SemanticTexUnitConstantColor];							/**< (vec4[]) The constant color of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.mode" toSemantic: kCC3SemanticTexUnitMode];									/**< (int[]) Environment mode of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction];		/**< (int[]) RBG combiner function of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB];						/**< (int[]) The RGB of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB];						/**< (int[]) The RGB of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB];						/**< (int[]) The RGB of source 2 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB];						/**< (int[]) The RGB combining operand of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB];						/**< (int[]) The RGB combining operand of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB];						/**< (int[]) The RGB combining operand of source 2 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction];	/**< (int[]) Alpha combiner function of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha];					/**< (int[]) The alpha of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha];					/**< (int[]) The alpha of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha];					/**< (int[]) The alpha of source 2 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha];					/**< (int[]) The alpha combining operand of source 0 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha];					/**< (int[]) The alpha combining operand of source 1 of each texture unit. */
	[self mapVarName: @"u_cc3TextureUnits.alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha];					/**< (int[]) The alpha combining operand of source 2 of each texture unit. */
	
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
	[self mapVarName: @"u_cc3Points.shouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];	/**< (bool) Whether points should be interpeted as textured sprites. */
	
	// TIME ------------------
	[self mapVarName: @"u_cc3Time.appTime" toSemantic: kCC3SemanticSceneTime];					/**< @deprecated Use sceneTime instead. */
	[self mapVarName: @"u_cc3Time.appTimeSine" toSemantic: kCC3SemanticSceneTimeSine];			/**< @deprecated Use sceneTimeSin instead. */
	[self mapVarName: @"u_cc3Time.appTimeCosine" toSemantic: kCC3SemanticSceneTimeCosine];		/**< @deprecated Use sceneTimeCos instead. */
	[self mapVarName: @"u_cc3Time.appTimeTangent" toSemantic: kCC3SemanticSceneTimeTangent];	/**< @deprecated Use sceneTimeTan instead. */
	
	// MISC ENVIRONMENT ---------
	[self mapVarName: @"u_cc3DrawCount" toSemantic: kCC3SemanticDrawCountCurrentFrame];		/**< (int) The number of draw calls so far in this frame. */
	[self mapVarName: @"u_cc3Random" toSemantic: kCC3SemanticRandomNumber];					/**< (float) A random number between 0 and 1. */
	
}

-(void) populateWithLegacyVariableNameMappings {
	
	// VETEX ATTRIBUTES --------------
	[self mapVarName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocation];				/**< Vertex location. */
	[self mapVarName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormal];					/**< Vertex normal. */
	[self mapVarName: @"a_cc3Tangent" toSemantic: kCC3SemanticVertexTangent];				/**< Vertex tangent. */
	[self mapVarName: @"a_cc3Bitangent" toSemantic: kCC3SemanticVertexBitangent];			/**< Vertex bitangent (aka binormal). */
	[self mapVarName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColor];					/**< Vertex color. */
	[self mapVarName: @"a_cc3BoneWeights" toSemantic: kCC3SemanticVertexBoneWeights];		/**< Vertex skinning bone weights (each an array of length specified by u_cc3BonesPerVertex). */
	[self mapVarName: @"a_cc3BoneIndices" toSemantic: kCC3SemanticVertexBoneIndices];		/**< Vertex skinning bone indices (each an array of length specified by u_cc3BonesPerVertex). */
	[self mapVarName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSize];			/**< Vertex point size. */
	
	// If only one texture coordinate attribute is used, the index suffix ("a_cc3TexCoordN") is optional.
	[self mapVarName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture];				/**< Vertex texture coordinate for the first texture unit. */
	GLuint maxTexUnits = CC3OpenGL.sharedGL.maxNumberOfTextureUnits;
	for (GLuint tuIdx = 0; tuIdx < maxTexUnits; tuIdx++)
		[self mapVarName: [NSString stringWithFormat: @"a_cc3TexCoord%u", tuIdx] toSemantic: kCC3SemanticVertexTexture at: tuIdx];	/**< Vertex texture coordinate for a texture unit. */
	
	// ATTRIBUTE QUALIFIERS --------------
	[self mapVarName: @"u_cc3HasVertexNormal" toSemantic: kCC3SemanticHasVertexNormal];					/**< (bool) Whether a vertex normal is available. */
	[self mapVarName: @"u_cc3ShouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];	/**< (bool) Whether vertex normals should be normalized. */
	[self mapVarName: @"u_cc3ShouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];	/**< (bool) Whether vertex normals should be rescaled. */
	[self mapVarName: @"u_cc3HasVertexTangent" toSemantic: kCC3SemanticHasVertexTangent];				/**< (bool) Whether a vertex tangent is available. */
	[self mapVarName: @"u_cc3HasVertexBitangent" toSemantic: kCC3SemanticHasVertexBitangent];			/**< (bool) Whether a vertex bitangent is available. */
	[self mapVarName: @"u_cc3HasVertexColor" toSemantic: kCC3SemanticHasVertexColor];					/**< (bool) Whether a vertex color is available. */
	[self mapVarName: @"u_cc3HasVertexWeight" toSemantic: kCC3SemanticHasVertexWeight];					/**< (bool) Whether a vertex weight is available. */
	[self mapVarName: @"u_cc3HasVertexMatrixIndex" toSemantic: kCC3SemanticHasVertexMatrixIndex];		/**< (bool) Whether a vertex matrix index is available. */
	[self mapVarName: @"u_cc3HasVertexTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];	/**< (bool) Whether a vertex texture coordinate is available. */
	[self mapVarName: @"u_cc3HasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];			/**< (bool) Whether a vertex point size is available. */
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
	
	[self mapVarName: @"u_cc3MtxModelView" toSemantic: kCC3SemanticModelViewMatrix];					/**< (mat4) Current model-view matrix. */
	[self mapVarName: @"u_cc3MtxModelViewInv" toSemantic: kCC3SemanticModelViewMatrixInv];				/**< (mat4) Inverse of current model-view matrix. */
	[self mapVarName: @"u_cc3MtxModelViewInvTran" toSemantic: kCC3SemanticModelViewMatrixInvTran];		/**< (mat3) Inverse-transpose of current model-view matrix. */
	
	[self mapVarName: @"u_cc3MtxProj" toSemantic: kCC3SemanticProjMatrix];								/**< (mat4) Camera projection matrix. */
	[self mapVarName: @"u_cc3MtxProjInv" toSemantic: kCC3SemanticProjMatrixInv];						/**< (mat4) Inverse of camera projection matrix. */
	[self mapVarName: @"u_cc3MtxProjInvTran" toSemantic: kCC3SemanticProjMatrixInvTran];				/**< (mat3) Inverse-transpose of camera projection matrix. */
	
	[self mapVarName: @"u_cc3MtxViewProj" toSemantic: kCC3SemanticViewProjMatrix];						/**< (mat4) Camera view and projection matrix. */
	[self mapVarName: @"u_cc3MtxViewProjInv" toSemantic: kCC3SemanticViewProjMatrixInv];				/**< (mat4) Inverse of camera view and projection matrix. */
	[self mapVarName: @"u_cc3MtxViewProjInvTran" toSemantic: kCC3SemanticViewProjMatrixInvTran];		/**< (mat3) Inverse-transpose of camera view and projection matrix. */
	
	[self mapVarName: @"u_cc3MtxModelViewProj" toSemantic: kCC3SemanticModelViewProjMatrix];			/**< (mat4) Current model-view-projection matrix. */
	[self mapVarName: @"u_cc3MtxModelViewProjInv" toSemantic: kCC3SemanticModelViewProjMatrixInv];		/**< (mat4) Inverse of current model-view-projection matrix. */
	[self mapVarName: @"u_cc3MtxModelViewProjInvTran" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];	/**< (mat3) Inverse-transpose of current model-view-projection matrix. */
	
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
	[self mapVarName: @"u_cc3Light.positionEyeSpace" toSemantic: kCC3SemanticLightPositionEyeSpace];	/**< (vec4) Location of the first light in eye space. */
	[self mapVarName: @"u_cc3Light.positionGlobal" toSemantic: kCC3SemanticLightPositionGlobal];		/**< (vec4) Location of the first light in global coordinates. */
	[self mapVarName: @"u_cc3Light.positionModel" toSemantic: kCC3SemanticLightPositionModelSpace];		/**< (vec4) Location of the first light in local coordinates of model (not light). */
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
	for (GLuint ltIdx = 0; ltIdx < 4; ltIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].isEnabled", ltIdx] toSemantic: kCC3SemanticLightIsEnabled at: ltIdx];						/**< (bool) Whether a light is enabled. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionEyeSpace", ltIdx] toSemantic: kCC3SemanticLightPositionEyeSpace at: ltIdx];			/**< (vec4) Homogeneous position (location or direction) of a light in eye space. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionGlobal", ltIdx] toSemantic: kCC3SemanticLightPositionGlobal at: ltIdx];				/**< (vec4) Homogeneous position (location or direction) of a light in global coordinates. */
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionModel", ltIdx] toSemantic: kCC3SemanticLightPositionModelSpace at: ltIdx];			/**< (vec4) Homogeneous position (location or direction) of a light in local coordinates of model (not light). */
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
	
	[self mapVarName: @"u_cc3Fog.isEnabled" toSemantic: kCC3SemanticFogIsEnabled];				/**< (bool) Whether scene fogging is enabled. */
	[self mapVarName: @"u_cc3Fog.color" toSemantic: kCC3SemanticFogColor];						/**< (vec4) Fog color. */
	[self mapVarName: @"u_cc3Fog.attenuationMode" toSemantic: kCC3SemanticFogAttenuationMode];	/**< (int) Fog attenuation mode (one of GL_LINEAR, GL_EXP or GL_EXP2). */
	[self mapVarName: @"u_cc3Fog.density" toSemantic: kCC3SemanticFogDensity];					/**< (float) Fog density. */
	[self mapVarName: @"u_cc3Fog.startDistance" toSemantic: kCC3SemanticFogStartDistance];		/**< (float) Distance from camera at which fogging effect starts. */
	[self mapVarName: @"u_cc3Fog.endDistance" toSemantic: kCC3SemanticFogEndDistance];			/**< (float) Distance from camera at which fogging effect ends. */
	
	// TEXTURES --------------
	[self mapVarName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];	/**< (int) Number of active textures. */
	[self mapVarName: @"s_cc3Texture" toSemantic: kCC3SemanticTextureSampler];		/**< (sampler2D) Texture sampler. */
	[self mapVarName: @"s_cc3Textures" toSemantic: kCC3SemanticTextureSampler];		/**< (sampler2D[]) Array of texture samplers. */
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in code.
	for (GLuint tuIdx = 0; tuIdx < 4; tuIdx++) {
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
	
	// SKINNING ----------------
	[self mapVarName: @"u_cc3BonesPerVertex" toSemantic: kCC3SemanticVertexBoneCount];							/**< (int) Number of bones influencing each vertex (ie- number of weights/matrices specified on each vertex) */
	[self mapVarName: @"u_cc3BoneMatrixCount" toSemantic: kCC3SemanticBatchBoneCount];							/**< (int) Length of the u_cc3BoneMatricesEyeSpace and u_cc3BoneMatricesInvTranEyeSpace arrays. */
	[self mapVarName: @"u_cc3BoneMatricesEyeSpace" toSemantic: kCC3SemanticBoneMatricesEyeSpace];				/**< (mat4[]) Array of bone matrices in the current mesh skin section in eye space. */
	[self mapVarName: @"u_cc3BoneMatricesInvTranEyeSpace" toSemantic: kCC3SemanticBoneMatricesInvTranEyeSpace];	/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section  in eye space. */
	[self mapVarName: @"u_cc3BoneMatricesGlobal" toSemantic: kCC3SemanticBoneMatricesGlobal];					/**< (mat4[]) Array of bone matrices in the current mesh skin section in global coordinates. */
	[self mapVarName: @"u_cc3BoneMatricesInvTranGlobal" toSemantic: kCC3SemanticBoneMatricesInvTranGlobal];		/**< (mat3[]) Array of inverse-transposes of the bone matrices in the current mesh skin section in global coordinates. */
	
	// PARTICLES ------------
	[self mapVarName: @"u_cc3Points.isDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];				/**< (bool) Whether the vertices are being drawn as points (alias for u_cc3IsDrawingPoints). */
	[self mapVarName: @"u_cc3Points.hasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];		/**< (bool) Whether the vertex point size is available (alias for u_cc3HasVertexPointSize). */
	[self mapVarName: @"u_cc3Points.size" toSemantic: kCC3SemanticPointSize];								/**< (float) Default size of points, if not specified per-vertex in a vertex attribute array. */
	[self mapVarName: @"u_cc3Points.sizeAttenuation" toSemantic: kCC3SemanticPointSizeAttenuation];			/**< (vec3) Point size distance attenuation coefficients. */
	[self mapVarName: @"u_cc3Points.minimumSize" toSemantic: kCC3SemanticPointSizeMinimum];					/**< (float) Minimum size points will be allowed to shrink to. */
	[self mapVarName: @"u_cc3Points.maximumSize" toSemantic: kCC3SemanticPointSizeMaximum];					/**< (float) Maximum size points will be allowed to grow to. */
	[self mapVarName: @"u_cc3Points.shouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];	/**< (bool) Whether points should be interpeted as textured sprites. */
	
	// TIME ------------------
	[self mapVarName: @"u_cc3Time.frameTime" toSemantic: kCC3SemanticFrameTime];						/**< (float) The time in seconds since the last frame. */
	[self mapVarName: @"u_cc3Time.appTime" toSemantic: kCC3SemanticSceneTime];					/**< (float) The application time in seconds. */
	[self mapVarName: @"u_cc3Time.appTimeSine" toSemantic: kCC3SemanticSceneTimeSine];			/**< (vec4) The sine of the application time (sin(T), sin(T/2), sin(T/4), sin(T/8)). */
	[self mapVarName: @"u_cc3Time.appTimeCosine" toSemantic: kCC3SemanticSceneTimeCosine];		/**< (vec4) The cosine of the application time (cos(T), cos(T/2), cos(T/4), cos(T/8)). */
	[self mapVarName: @"u_cc3Time.appTimeTangent" toSemantic: kCC3SemanticSceneTimeTangent];		/**< (vec4) The tangent of the application time (tan(T), tan(T/2), tan(T/4), tan(T/8)). */
	
	// MISC ENVIRONMENT ---------
	[self mapVarName: @"u_cc3DrawCount" toSemantic: kCC3SemanticDrawCountCurrentFrame];		/**< (int) The number of draw calls so far in this frame. */
	[self mapVarName: @"u_cc3Random" toSemantic: kCC3SemanticRandomNumber];					/**< (float) A random number between 0 and 1. */
}

@end
	
