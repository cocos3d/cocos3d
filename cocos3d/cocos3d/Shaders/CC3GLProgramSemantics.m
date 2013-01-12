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
#import "CC3PointParticles.h"

NSString* NSStringFromCC3Semantic(CC3Semantic semantic) {
	switch (semantic) {
		case kCC3SemanticNone: return @"kCC3SemanticNone";

		// VERTEX CONTENT --------------
		case kCC3SemanticVertexLocations: return @"kCC3SemanticVertexLocations";
		case kCC3SemanticVertexNormals: return @"kCC3SemanticVertexNormals";
		case kCC3SemanticVertexTangents: return @"kCC3SemanticVertexTangents";
		case kCC3SemanticVertexBitangents: return @"kCC3SemanticVertexBitangents";
		case kCC3SemanticVertexColors: return @"kCC3SemanticVertexColors";
		case kCC3SemanticVertexPointSizes: return @"kCC3SemanticVertexPointSizes";
		case kCC3SemanticVertexWeights: return @"kCC3SemanticVertexWeights";
		case kCC3SemanticVertexMatrices: return @"kCC3SemanticVertexMatrices";
		case kCC3SemanticVertexTexture: return @"kCC3SemanticVertexTexture";
			
		case kCC3SemanticHasVertexNormal: return @"kCC3SemanticHasVertexNormal";
		case kCC3SemanticShouldNormalizeVertexNormal: return @"kCC3SemanticShouldNormalizeVertexNormal";
		case kCC3SemanticShouldRescaleVertexNormal: return @"kCC3SemanticShouldRescaleVertexNormal";
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
			
		case kCC3SemanticElapsedTime: return @"kCC3SemanticElapsedTime";
		case kCC3SemanticElapsedTimeSine: return @"kCC3SemanticElapsedTimeSine";
		case kCC3SemanticElapsedTimeCosine: return @"kCC3SemanticElapsedTimeCosine";
		case kCC3SemanticElapsedTimeTangent: return @"kCC3SemanticElapsedTimeTangent";

		case kCC3SemanticElapsedTimeTwoPi: return @"kCC3SemanticElapsedTimeTwoPi";
		case kCC3SemanticElapsedTimeTwoPiSine: return @"kCC3SemanticElapsedTimeTwoPiSine";
		case kCC3SemanticElapsedTimeTwoPiCosine: return @"kCC3SemanticElapsedTimeTwoPiCosine";
		case kCC3SemanticElapsedTimeTwoPiTangent: return @"kCC3SemanticElapsedTimeTwoPiTangent";

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
	LogTrace(@"Retrieving semantic value for %@", uniform.fullDescription);
	CC3OpenGLESEngine* glesEngine = CC3OpenGLESEngine.engine;
	CC3OpenGLESLight* glesLight;
	CC3OpenGLESTextureUnit* glesTexUnit;
	GLenum semantic = uniform.semantic;
	GLuint semanticIndex = uniform.semanticIndex;
	GLint uniformSize = uniform.size;
	CC3Matrix4x4 mtx4, pntInvMtx4, nodeMtx4;
	CC3Matrix3x3 mtx3;
	
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
			// Get local matrix into mtx4 by P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.transformMatrixInverted populateCC3Matrix4x4: &pntInvMtx4];
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x4: &nodeMtx4];
			CC3Matrix4x4Multiply(&mtx4, &pntInvMtx4, &nodeMtx4);
			[uniform setMatrix4x4: &mtx4];
			return YES;
		case kCC3SemanticModelLocalMatrixInv:
			// Get local matrix into mtx4 by P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.transformMatrixInverted populateCC3Matrix4x4: &pntInvMtx4];
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x4: &nodeMtx4];
			CC3Matrix4x4Multiply(&mtx4, &pntInvMtx4, &nodeMtx4);
			// Now invert
			CC3Matrix4x4InvertAdjoint(&mtx4);
			[uniform setMatrix4x4: &mtx4];
			return YES;
		case kCC3SemanticModelLocalMatrixInvTran:
			// Get local matrix into mtx4 by P(-1).T where T is node transform P(-1) is inv-xfm of parent
			[visitor.currentMeshNode.parent.transformMatrixInverted populateCC3Matrix4x4: &pntInvMtx4];
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x4: &nodeMtx4];
			CC3Matrix4x4Multiply(&mtx4, &pntInvMtx4, &nodeMtx4);
			// Now take inverse-transpose
			CC3Matrix3x3PopulateFrom4x4(&mtx3, &mtx4);
			CC3Matrix3x3InvertAdjoint(&mtx3);
			CC3Matrix3x3Transpose(&mtx3);
			[uniform setMatrix3x3: &mtx3];
			return YES;

		case kCC3SemanticModelMatrix:
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x4: &mtx4];
			[uniform setMatrix4x4: &mtx4];
			return YES;
		case kCC3SemanticModelMatrixInv:
			[visitor.currentMeshNode.transformMatrixInverted populateCC3Matrix4x4: &mtx4];
			[uniform setMatrix4x4: &mtx4];
			return YES;
		case kCC3SemanticModelMatrixInvTran:
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix3x3: &mtx3];
			CC3Matrix3x3InvertAdjoint(&mtx3);
			CC3Matrix3x3Transpose(&mtx3);
			[uniform setMatrix3x3: &mtx3];
			return YES;

		case kCC3SemanticViewMatrix:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticView]];
			return YES;
		case kCC3SemanticViewMatrixInv:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticViewInv]];
			return YES;
		case kCC3SemanticViewMatrixInvTran:
			[uniform setMatrix3x3: [glesEngine.matrices matrix3x3ForSemantic: kCC3MatrixSemanticViewInvTran]];
			return YES;

		case kCC3SemanticModelViewMatrix:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticModelView]];
			return YES;
		case kCC3SemanticModelViewMatrixInv:
			[uniform setMatrix4x4: [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticModelViewInv]];
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
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global position/direction to eye space and normalize if direction
					CC3Vector4 ltPos = glesLight.position.value;
					CC3Matrix4x4* viewMtx = [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticView];
					ltPos = CC3Matrix4x4TransformCC3Vector4(viewMtx, ltPos);
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
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [glesEngine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global direction to eye space and normalize
					CC3Vector4 ltDir = CC3Vector4FromDirection(glesLight.spotDirection.value);
					CC3Matrix4x4* viewMtx = [glesEngine.matrices matrix4x4ForSemantic: kCC3MatrixSemanticView];
					ltDir = CC3Matrix4x4TransformCC3Vector4(viewMtx, ltDir);
					[uniform setVector: CC3VectorNormalize(CC3VectorFromTruncatedCC3Vector4(ltDir)) at: i];
				}
				
				if (glesLight.isEnabled) [uniform setVector: glesLight.spotDirection.value at: i];
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
		case kCC3SemanticPointSpritesIsEnabled: {
			[uniform setBoolean: glesEngine.capabilities.pointSprites.value];
			return YES;
		}
			
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
	[self mapVarName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocations];
	[self mapVarName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormals];
	[self mapVarName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColors];
	[self mapVarName: @"a_cc3Weight" toSemantic: kCC3SemanticVertexWeights];
	[self mapVarName: @"a_cc3MatrixIdx" toSemantic: kCC3SemanticVertexMatrices];
	[self mapVarName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSizes];
	
	// If only one texture coordinate attribute is used, the index suffix ("a_cc3TexCoordN") is optional.
	[self mapVarName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture];
	for (NSUInteger tuIdx = 0; tuIdx < _maxTexUnitVars; tuIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"a_cc3TexCoord%u", tuIdx] toSemantic: kCC3SemanticVertexTexture at: tuIdx];
	}
	
	// ATTRIBUTE QUALIFIERS --------------
	[self mapVarName: @"u_cc3HasVertexNormal" toSemantic: kCC3SemanticHasVertexNormal];
	[self mapVarName: @"u_cc3ShouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];
	[self mapVarName: @"u_cc3ShouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];
	[self mapVarName: @"u_cc3HasVertexColor" toSemantic: kCC3SemanticHasVertexColor];
	[self mapVarName: @"u_cc3HasVertexTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];
	[self mapVarName: @"u_cc3HasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];	// alias for u_cc3Points.hasVertexPointSize
	[self mapVarName: @"u_cc3IsDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];			// alias for u_cc3Points.isDrawingPoints
	
	// PARTICLES ------------
	[self mapVarName: @"u_cc3Points.isDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];			// alias for u_cc3IsDrawingPoints
	[self mapVarName: @"u_cc3Points.hasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];	// alias for u_cc3HasVertexPointSize
	[self mapVarName: @"u_cc3Points.size" toSemantic: kCC3SemanticPointSize];
	[self mapVarName: @"u_cc3Points.sizeAttenuation" toSemantic: kCC3SemanticPointSizeAttenuation];
	[self mapVarName: @"u_cc3Points.minimumSize" toSemantic: kCC3SemanticPointSizeMinimum];
	[self mapVarName: @"u_cc3Points.maximumSize" toSemantic: kCC3SemanticPointSizeMaximum];
	[self mapVarName: @"u_cc3Points.sizeFadeThreshold" toSemantic: kCC3SemanticPointSizeFadeThreshold];
	[self mapVarName: @"u_cc3Points.shouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];
	
	// ENVIRONMENT MATRICES --------------
	[self mapVarName: @"u_cc3MtxModelLocal" toSemantic: kCC3SemanticModelLocalMatrix];
	[self mapVarName: @"u_cc3MtxModelLocalInv" toSemantic: kCC3SemanticModelLocalMatrixInv];
	[self mapVarName: @"u_cc3MtxModelLocalInvTran" toSemantic: kCC3SemanticModelLocalMatrixInvTran];
	[self mapVarName: @"u_cc3MtxModel" toSemantic: kCC3SemanticModelMatrix];
	[self mapVarName: @"u_cc3MtxModelInv" toSemantic: kCC3SemanticModelMatrixInv];
	[self mapVarName: @"u_cc3MtxModelInvTran" toSemantic: kCC3SemanticModelMatrixInvTran];
	[self mapVarName: @"u_cc3MtxView" toSemantic: kCC3SemanticViewMatrix];
	[self mapVarName: @"u_cc3MtxViewInv" toSemantic: kCC3SemanticViewMatrixInv];
	[self mapVarName: @"u_cc3MtxViewInvTran" toSemantic: kCC3SemanticViewMatrixInvTran];
	[self mapVarName: @"u_cc3MtxModelView" toSemantic: kCC3SemanticModelViewMatrix];
	[self mapVarName: @"u_cc3MtxModelViewInv" toSemantic: kCC3SemanticModelViewMatrixInv];
	[self mapVarName: @"u_cc3MtxModelViewInvTran" toSemantic: kCC3SemanticModelViewMatrixInvTran];
	[self mapVarName: @"u_cc3MtxProj" toSemantic: kCC3SemanticProjMatrix];
	[self mapVarName: @"u_cc3MtxProjInv" toSemantic: kCC3SemanticProjMatrixInv];
	[self mapVarName: @"u_cc3MtxProjInvTran" toSemantic: kCC3SemanticProjMatrixInvTran];
	[self mapVarName: @"u_cc3MtxViewProj" toSemantic: kCC3SemanticViewProjMatrix];
	[self mapVarName: @"u_cc3MtxViewProjInv" toSemantic: kCC3SemanticViewProjMatrixInv];
	[self mapVarName: @"u_cc3MtxViewProjInvTran" toSemantic: kCC3SemanticViewProjMatrixInvTran];
	[self mapVarName: @"u_cc3MtxModelViewProj" toSemantic: kCC3SemanticModelViewProjMatrix];
	[self mapVarName: @"u_cc3MtxModelViewProjInv" toSemantic: kCC3SemanticModelViewProjMatrixInv];
	[self mapVarName: @"u_cc3MtxModelViewProjInvTran" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];
	
	// CAMERA -----------------
	[self mapVarName: @"u_cc3CameraPosition" toSemantic: kCC3SemanticCameraLocationModelSpace];
	
	// MATERIALS --------------
	[self mapVarName: @"u_cc3Color" toSemantic: kCC3SemanticColor];
	[self mapVarName: @"u_cc3Material.ambientColor" toSemantic: kCC3SemanticMaterialColorAmbient];
	[self mapVarName: @"u_cc3Material.diffuseColor" toSemantic: kCC3SemanticMaterialColorDiffuse];
	[self mapVarName: @"u_cc3Material.specularColor" toSemantic: kCC3SemanticMaterialColorSpecular];
	[self mapVarName: @"u_cc3Material.emissionColor" toSemantic: kCC3SemanticMaterialColorEmission];
	[self mapVarName: @"u_cc3Material.shininess" toSemantic: kCC3SemanticMaterialShininess];
	[self mapVarName: @"u_cc3Material.minimumDrawnAlpha" toSemantic: kCC3SemanticMinimumDrawnAlpha];
	
	// LIGHTING --------------
	[self mapVarName: @"u_cc3IsUsingLighting" toSemantic: kCC3SemanticIsUsingLighting];
	[self mapVarName: @"u_cc3SceneLightColorAmbient" toSemantic: kCC3SemanticSceneLightColorAmbient];
	
	// If only one light is used it can be declared as a single variable structure without the index.
	[self mapVarName: @"u_cc3Light.isEnabled" toSemantic: kCC3SemanticLightIsEnabled];		// Aliases for light zero
	[self mapVarName: @"u_cc3Light.positionEyeSpace" toSemantic: kCC3SemanticLightLocationEyeSpace];
	[self mapVarName: @"u_cc3Light.ambientColor" toSemantic: kCC3SemanticLightColorAmbient];
	[self mapVarName: @"u_cc3Light.diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse];
	[self mapVarName: @"u_cc3Light.specularColor" toSemantic: kCC3SemanticLightColorSpecular];
	[self mapVarName: @"u_cc3Light.attenuation" toSemantic: kCC3SemanticLightAttenuation];
	[self mapVarName: @"u_cc3Light.spotDirectionEyeSpace" toSemantic: kCC3SemanticLightSpotDirectionEyeSpace];
	[self mapVarName: @"u_cc3Light.spotExponent" toSemantic: kCC3SemanticLightSpotExponent];
	[self mapVarName: @"u_cc3Light.spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle];
	[self mapVarName: @"u_cc3Light.spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine];
	
	// Multiple lights are indexed
	for (NSUInteger ltIdx = 0; ltIdx < _maxLightVars; ltIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].isEnabled", ltIdx] toSemantic: kCC3SemanticLightIsEnabled at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].positionEyeSpace", ltIdx] toSemantic: kCC3SemanticLightLocationEyeSpace at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].ambientColor", ltIdx] toSemantic: kCC3SemanticLightColorAmbient at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].diffuseColor", ltIdx] toSemantic: kCC3SemanticLightColorDiffuse at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].specularColor", ltIdx] toSemantic: kCC3SemanticLightColorSpecular at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].attenuation", ltIdx] toSemantic: kCC3SemanticLightAttenuation at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotDirectionEyeSpace", ltIdx] toSemantic: kCC3SemanticLightSpotDirectionEyeSpace at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotExponent", ltIdx] toSemantic: kCC3SemanticLightSpotExponent at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotCutoffAngle", ltIdx] toSemantic: kCC3SemanticLightSpotCutoffAngle at: ltIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3Lights[%u].spotCutoffAngleCosine", ltIdx] toSemantic: kCC3SemanticLightSpotCutoffAngleCosine at: ltIdx];
	}

	// TEXTURES --------------
	[self mapVarName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];
	[self mapVarName: @"s_cc3Texture" toSemantic: kCC3SemanticTextureSampler];		// alias for s_cc3Textures[0]
	[self mapVarName: @"s_cc3Textures[0]" toSemantic: kCC3SemanticTextureSampler];	// alias for s_cc3Texture
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in code.
	for (NSUInteger tuIdx = 0; tuIdx < _maxTexUnitVars; tuIdx++) {
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].color", tuIdx] toSemantic: kCC3SemanticTexUnitConstantColor at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].mode", tuIdx] toSemantic: kCC3SemanticTexUnitMode at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].combineRGBFunction", tuIdx] toSemantic: kCC3SemanticTexUnitCombineRGBFunction at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbSource0", tuIdx] toSemantic: kCC3SemanticTexUnitSource0RGB at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbSource1", tuIdx] toSemantic: kCC3SemanticTexUnitSource1RGB at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbSource2", tuIdx] toSemantic: kCC3SemanticTexUnitSource2RGB at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbOperand0", tuIdx] toSemantic: kCC3SemanticTexUnitOperand0RGB at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbOperand1", tuIdx] toSemantic: kCC3SemanticTexUnitOperand1RGB at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].rgbOperand2", tuIdx] toSemantic: kCC3SemanticTexUnitOperand2RGB at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].combineAlphaFunction", tuIdx] toSemantic: kCC3SemanticTexUnitCombineAlphaFunction at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaSource0", tuIdx] toSemantic: kCC3SemanticTexUnitSource0Alpha at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaSource1", tuIdx] toSemantic: kCC3SemanticTexUnitSource1Alpha at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaSource2", tuIdx] toSemantic: kCC3SemanticTexUnitSource2Alpha at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaOperand0", tuIdx] toSemantic: kCC3SemanticTexUnitOperand0Alpha at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaOperand1", tuIdx] toSemantic: kCC3SemanticTexUnitOperand1Alpha at: tuIdx];
		[self mapVarName: [NSString stringWithFormat: @"u_cc3TextureUnits[%u].alphaOperand2", tuIdx] toSemantic: kCC3SemanticTexUnitOperand2Alpha at: tuIdx];
	}

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
	
