/*
 * CC3GLProgramSemantics.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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

NSString* NSStringFromCC3VertexContentSemantic(CC3VertexContentSemantic semantic) {
	switch (semantic) {
		case kCC3VertexContentSemanticNone: return @"kCC3VertexContentSemanticNone";
		case kCC3VertexContentSemanticLocations: return @"kCC3VertexContentSemanticLocations";
		case kCC3VertexContentSemanticNormals: return @"kCC3VertexContentSemanticNormals";
		case kCC3VertexContentSemanticColors: return @"kCC3VertexContentSemanticColors";
		case kCC3VertexContentSemanticPointSizes: return @"kCC3VertexContentSemanticPointSizes";
		case kCC3VertexContentSemanticWeights: return @"kCC3VertexContentSemanticWeights";
		case kCC3VertexContentSemanticMatrices: return @"kCC3VertexContentSemanticMatrices";
		case kCC3VertexContentSemanticTexture0: return @"kCC3VertexContentSemanticTexture0";
		case kCC3VertexContentSemanticTexture1: return @"kCC3VertexContentSemanticTexture1";
		case kCC3VertexContentSemanticTexture2: return @"kCC3VertexContentSemanticTexture2";
		case kCC3VertexContentSemanticTexture3: return @"kCC3VertexContentSemanticTexture3";
		case kCC3VertexContentSemanticTexture4: return @"kCC3VertexContentSemanticTexture4";
		case kCC3VertexContentSemanticTexture5: return @"kCC3VertexContentSemanticTexture5";
		case kCC3VertexContentSemanticTexture6: return @"kCC3VertexContentSemanticTexture6";
		case kCC3VertexContentSemanticTexture7: return @"kCC3VertexContentSemanticTexture7";

		case kCC3VertexContentSemanticAppBase: return @"kCC3VertexContentSemanticAppBase";
		case kCC3VertexContentSemanticMax: return @"kCC3VertexContentSemanticMax";
		default: return [NSString stringWithFormat: @"Unknown vertex content semantic (%u)", semantic];
	}
}

NSString* NSStringFromCC3Semantic(CC3Semantic semantic) {
	switch (semantic) {
		case kCC3SemanticNone: return @"kCC3SemanticNone";

		case kCC3SemanticHasVertexNormal: return @"kCC3SemanticHasVertexNormal";
		case kCC3SemanticShouldNormalizeVertexNormal: return @"kCC3SemanticShouldNormalizeVertexNormal";
		case kCC3SemanticShouldRescaleVertexNormal: return @"kCC3SemanticShouldRescaleVertexNormal";
		case kCC3SemanticHasVertexColor: return @"kCC3SemanticHasVertexColor";
		case kCC3SemanticTexCoordCount: return @"kCC3SemanticTexCoordCount";

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
		case kCC3SemanticModelViewProjMatrix: return @"kCC3SemanticModelViewProjMatrix";
		case kCC3SemanticModelViewProjMatrixInv: return @"kCC3SemanticModelViewProjMatrixInv";
		case kCC3SemanticModelViewProjMatrixInvTran: return @"kCC3SemanticModelViewProjMatrixInvTran";
			
		case kCC3SemanticMaterialColorAmbient: return @"kCC3SemanticMaterialColorAmbient";
		case kCC3SemanticMaterialColorDiffuse: return @"kCC3SemanticMaterialColorDiffuse";
		case kCC3SemanticMaterialColorSpecular: return @"kCC3SemanticMaterialColorSpecular";
		case kCC3SemanticMaterialColorEmission: return @"kCC3SemanticMaterialColorEmission";
		case kCC3SemanticMaterialOpacity: return @"kCC3SemanticMaterialOpacity";
		case kCC3SemanticMaterialShininess: return @"kCC3SemanticMaterialShininess";
			
		case kCC3SemanticIsUsingLighting: return @"kCC3SemanticIsUsingLighting";
		case kCC3SemanticSceneLightColorAmbient: return @"kCC3SemanticSceneLightColorAmbient";

		case kCC3SemanticLightIsEnabled0: return @"kCC3SemanticLightIsEnabled0";
		case kCC3SemanticLightIsEnabled1: return @"kCC3SemanticLightIsEnabled1";
		case kCC3SemanticLightIsEnabled2: return @"kCC3SemanticLightIsEnabled2";
		case kCC3SemanticLightIsEnabled3: return @"kCC3SemanticLightIsEnabled3";
		case kCC3SemanticLightIsEnabled4: return @"kCC3SemanticLightIsEnabled4";
		case kCC3SemanticLightIsEnabled5: return @"kCC3SemanticLightIsEnabled5";
		case kCC3SemanticLightIsEnabled6: return @"kCC3SemanticLightIsEnabled6";
		case kCC3SemanticLightIsEnabled7: return @"kCC3SemanticLightIsEnabled7";

		case kCC3SemanticLightPosition0: return @"kCC3SemanticLightPosition0";
		case kCC3SemanticLightPosition1: return @"kCC3SemanticLightPosition1";
		case kCC3SemanticLightPosition2: return @"kCC3SemanticLightPosition2";
		case kCC3SemanticLightPosition3: return @"kCC3SemanticLightPosition3";
		case kCC3SemanticLightPosition4: return @"kCC3SemanticLightPosition4";
		case kCC3SemanticLightPosition5: return @"kCC3SemanticLightPosition5";
		case kCC3SemanticLightPosition6: return @"kCC3SemanticLightPosition6";
		case kCC3SemanticLightPosition7: return @"kCC3SemanticLightPosition7";

		case kCC3SemanticLightColorAmbient0: return @"kCC3SemanticLightColorAmbient0";
		case kCC3SemanticLightColorAmbient1: return @"kCC3SemanticLightColorAmbient1";
		case kCC3SemanticLightColorAmbient2: return @"kCC3SemanticLightColorAmbient2";
		case kCC3SemanticLightColorAmbient3: return @"kCC3SemanticLightColorAmbient3";
		case kCC3SemanticLightColorAmbient4: return @"kCC3SemanticLightColorAmbient4";
		case kCC3SemanticLightColorAmbient5: return @"kCC3SemanticLightColorAmbient5";
		case kCC3SemanticLightColorAmbient6: return @"kCC3SemanticLightColorAmbient6";
		case kCC3SemanticLightColorAmbient7: return @"kCC3SemanticLightColorAmbient7";
			
		case kCC3SemanticLightColorDiffuse0: return @"kCC3SemanticLightColorDiffuse0";
		case kCC3SemanticLightColorDiffuse1: return @"kCC3SemanticLightColorDiffuse1";
		case kCC3SemanticLightColorDiffuse2: return @"kCC3SemanticLightColorDiffuse2";
		case kCC3SemanticLightColorDiffuse3: return @"kCC3SemanticLightColorDiffuse3";
		case kCC3SemanticLightColorDiffuse4: return @"kCC3SemanticLightColorDiffuse4";
		case kCC3SemanticLightColorDiffuse5: return @"kCC3SemanticLightColorDiffuse5";
		case kCC3SemanticLightColorDiffuse6: return @"kCC3SemanticLightColorDiffuse6";
		case kCC3SemanticLightColorDiffuse7: return @"kCC3SemanticLightColorDiffuse7";
			
		case kCC3SemanticLightColorSpecular0: return @"kCC3SemanticLightColorSpecular0";
		case kCC3SemanticLightColorSpecular1: return @"kCC3SemanticLightColorSpecular1";
		case kCC3SemanticLightColorSpecular2: return @"kCC3SemanticLightColorSpecular2";
		case kCC3SemanticLightColorSpecular3: return @"kCC3SemanticLightColorSpecular3";
		case kCC3SemanticLightColorSpecular4: return @"kCC3SemanticLightColorSpecular4";
		case kCC3SemanticLightColorSpecular5: return @"kCC3SemanticLightColorSpecular5";
		case kCC3SemanticLightColorSpecular6: return @"kCC3SemanticLightColorSpecular6";
		case kCC3SemanticLightColorSpecular7: return @"kCC3SemanticLightColorSpecular7";

		case kCC3SemanticLightAttenuationCoefficients0: return @"kCC3SemanticLightAttenuationCoefficients0";
		case kCC3SemanticLightAttenuationCoefficients1: return @"kCC3SemanticLightAttenuationCoefficients1";
		case kCC3SemanticLightAttenuationCoefficients2: return @"kCC3SemanticLightAttenuationCoefficients2";
		case kCC3SemanticLightAttenuationCoefficients3: return @"kCC3SemanticLightAttenuationCoefficients3";
		case kCC3SemanticLightAttenuationCoefficients4: return @"kCC3SemanticLightAttenuationCoefficients4";
		case kCC3SemanticLightAttenuationCoefficients5: return @"kCC3SemanticLightAttenuationCoefficients5";
		case kCC3SemanticLightAttenuationCoefficients6: return @"kCC3SemanticLightAttenuationCoefficients6";
		case kCC3SemanticLightAttenuationCoefficients7: return @"kCC3SemanticLightAttenuationCoefficients7";

		case kCC3SemanticLightSpotDirection0: return @"kCC3SemanticLightSpotDirection0";
		case kCC3SemanticLightSpotDirection1: return @"kCC3SemanticLightSpotDirection1";
		case kCC3SemanticLightSpotDirection2: return @"kCC3SemanticLightSpotDirection2";
		case kCC3SemanticLightSpotDirection3: return @"kCC3SemanticLightSpotDirection3";
		case kCC3SemanticLightSpotDirection4: return @"kCC3SemanticLightSpotDirection4";
		case kCC3SemanticLightSpotDirection5: return @"kCC3SemanticLightSpotDirection5";
		case kCC3SemanticLightSpotDirection6: return @"kCC3SemanticLightSpotDirection6";
		case kCC3SemanticLightSpotDirection7: return @"kCC3SemanticLightSpotDirection7";
			
		case kCC3SemanticLightSpotExponent0: return @"kCC3SemanticLightSpotExponent0";
		case kCC3SemanticLightSpotExponent1: return @"kCC3SemanticLightSpotExponent1";
		case kCC3SemanticLightSpotExponent2: return @"kCC3SemanticLightSpotExponent2";
		case kCC3SemanticLightSpotExponent3: return @"kCC3SemanticLightSpotExponent3";
		case kCC3SemanticLightSpotExponent4: return @"kCC3SemanticLightSpotExponent4";
		case kCC3SemanticLightSpotExponent5: return @"kCC3SemanticLightSpotExponent5";
		case kCC3SemanticLightSpotExponent6: return @"kCC3SemanticLightSpotExponent6";
		case kCC3SemanticLightSpotExponent7: return @"kCC3SemanticLightSpotExponent7";

		case kCC3SemanticLightSpotCutoffAngle0: return @"kCC3SemanticLightSpotCutoffAngle0";
		case kCC3SemanticLightSpotCutoffAngle1: return @"kCC3SemanticLightSpotCutoffAngle1";
		case kCC3SemanticLightSpotCutoffAngle2: return @"kCC3SemanticLightSpotCutoffAngle2";
		case kCC3SemanticLightSpotCutoffAngle3: return @"kCC3SemanticLightSpotCutoffAngle3";
		case kCC3SemanticLightSpotCutoffAngle4: return @"kCC3SemanticLightSpotCutoffAngle4";
		case kCC3SemanticLightSpotCutoffAngle5: return @"kCC3SemanticLightSpotCutoffAngle5";
		case kCC3SemanticLightSpotCutoffAngle6: return @"kCC3SemanticLightSpotCutoffAngle6";
		case kCC3SemanticLightSpotCutoffAngle7: return @"kCC3SemanticLightSpotCutoffAngle7";

		case kCC3SemanticLightSpotCutoffAngleCosine0: return @"kCC3SemanticLightSpotCutoffAngleCosine0";
		case kCC3SemanticLightSpotCutoffAngleCosine1: return @"kCC3SemanticLightSpotCutoffAngleCosine1";
		case kCC3SemanticLightSpotCutoffAngleCosine2: return @"kCC3SemanticLightSpotCutoffAngleCosine2";
		case kCC3SemanticLightSpotCutoffAngleCosine3: return @"kCC3SemanticLightSpotCutoffAngleCosine3";
		case kCC3SemanticLightSpotCutoffAngleCosine4: return @"kCC3SemanticLightSpotCutoffAngleCosine4";
		case kCC3SemanticLightSpotCutoffAngleCosine5: return @"kCC3SemanticLightSpotCutoffAngleCosine5";
		case kCC3SemanticLightSpotCutoffAngleCosine6: return @"kCC3SemanticLightSpotCutoffAngleCosine6";
		case kCC3SemanticLightSpotCutoffAngleCosine7: return @"kCC3SemanticLightSpotCutoffAngleCosine7";
			
		case kCC3SemanticTextureCount: return @"kCC3SemanticTextureCount";
		case kCC3SemanticTexture0: return @"kCC3SemanticTexture0";
		case kCC3SemanticTexture1: return @"kCC3SemanticTexture1";
		case kCC3SemanticTexture2: return @"kCC3SemanticTexture2";
		case kCC3SemanticTexture3: return @"kCC3SemanticTexture3";
		case kCC3SemanticTexture4: return @"kCC3SemanticTexture4";
		case kCC3SemanticTexture5: return @"kCC3SemanticTexture5";
		case kCC3SemanticTexture6: return @"kCC3SemanticTexture6";
		case kCC3SemanticTexture7: return @"kCC3SemanticTexture7";
			
		case kCC3SemanticAppBase: return @"kCC3SemanticAppBase";
		case kCC3SemanticMax: return @"kCC3SemanticMax";
		default: return [NSString stringWithFormat: @"Unknown state semantic (%u)", semantic];
	}
}


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateBase

@implementation CC3GLProgramSemanticsDelegateBase

+(id) semanticsDelegate { return [[[self alloc] init] autorelease]; }

-(NSString*) nameOfUniformSemantic: (GLenum) semantic { return NSStringFromCC3Semantic(semantic); }

-(NSString*) nameOfAttributeSemantic: (GLenum) semantic { return NSStringFromCC3VertexContentSemantic(semantic); }

-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) uniform { return NO; }

-(BOOL) assignAttributeSemantic: (CC3GLSLAttribute*) attribute { return NO; }

-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLESLight* glesLight;
	GLenum semantic = uniform.semantic;
	switch (semantic) {
		
		// Attribute qualifiers
		case kCC3SemanticHasVertexNormal:
			[uniform setBoolean: visitor.currentMeshNode.mesh.hasVertexNormals];
			return YES;
		case kCC3SemanticShouldNormalizeVertexNormal:
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.normalize.value];
			return YES;
		case kCC3SemanticShouldRescaleVertexNormal:
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.rescaleNormal.value];
			return YES;
		case kCC3SemanticHasVertexColor:
			[uniform setBoolean: visitor.currentMeshNode.mesh.hasVertexColors];
			return YES;
		case kCC3SemanticTexCoordCount:
			[uniform setInteger: visitor.textureUnitCount];
			return YES;

		// Environment matrices
		case kCC3SemanticModelViewMatrix: {
			[uniform setMatrices4x4: CC3OpenGLESEngine.engine.matrices.modelViewMatrix];
			return YES;
		}
		case kCC3SemanticModelViewMatrixInvTran: {
			[uniform setMatrices3x3: CC3OpenGLESEngine.engine.matrices.modelViewInverseTransposeMatrix];
			return YES;
		}
		case kCC3SemanticModelViewProjMatrix: {
			[uniform setMatrices4x4: CC3OpenGLESEngine.engine.matrices.modelViewProjectionMatrix];
			return YES;
		}
			
		// Material properties
		case kCC3SemanticMaterialColorAmbient:
			[uniform setColor4F: CC3OpenGLESEngine.engine.materials.ambientColor.value];
			return YES;
		case kCC3SemanticMaterialColorDiffuse:
			[uniform setColor4F: CC3OpenGLESEngine.engine.materials.diffuseColor.value];
			return YES;
		case kCC3SemanticMaterialColorSpecular:
			[uniform setColor4F: CC3OpenGLESEngine.engine.materials.specularColor.value];
			return YES;
		case kCC3SemanticMaterialColorEmission:
			[uniform setColor4F: CC3OpenGLESEngine.engine.materials.emissionColor.value];
			return YES;
		case kCC3SemanticMaterialShininess:
			[uniform setFloat: CC3OpenGLESEngine.engine.materials.shininess.value];
			return YES;
			
		// Lighting
		case kCC3SemanticIsUsingLighting:
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.lighting.value];
			return YES;
		case kCC3SemanticSceneLightColorAmbient:
			[uniform setColor4F: CC3OpenGLESEngine.engine.lighting.sceneAmbientLight.value];
			return YES;
			
		case kCC3SemanticLightIsEnabled0:
		case kCC3SemanticLightIsEnabled1:
		case kCC3SemanticLightIsEnabled2:
		case kCC3SemanticLightIsEnabled3:
		case kCC3SemanticLightIsEnabled4:
		case kCC3SemanticLightIsEnabled5:
		case kCC3SemanticLightIsEnabled6:
		case kCC3SemanticLightIsEnabled7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightIsEnabled0)];
			[uniform setBoolean: glesLight.isEnabled];
			return YES;
			
		case kCC3SemanticLightPosition0:
		case kCC3SemanticLightPosition1:
		case kCC3SemanticLightPosition2:
		case kCC3SemanticLightPosition3:
		case kCC3SemanticLightPosition4:
		case kCC3SemanticLightPosition5:
		case kCC3SemanticLightPosition6:
		case kCC3SemanticLightPosition7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightPosition0)];
			if (glesLight.isEnabled) {
				// Transform global position/direction to eye space and normalize if direction
				CC3Vector4 ltPos = glesLight.position.value;
				CC3Matrix4x4* viewMtx = CC3OpenGLESEngine.engine.matrices.viewMatrix;
				ltPos = CC3Matrix4x4TransformCC3Vector4(viewMtx, ltPos);
				if (ltPos.w == 0.0f) ltPos = CC3Vector4Normalize(ltPos);
				[uniform setVector4: ltPos];
			}
			return YES;
			
		case kCC3SemanticLightColorAmbient0:
		case kCC3SemanticLightColorAmbient1:
		case kCC3SemanticLightColorAmbient2:
		case kCC3SemanticLightColorAmbient3:
		case kCC3SemanticLightColorAmbient4:
		case kCC3SemanticLightColorAmbient5:
		case kCC3SemanticLightColorAmbient6:
		case kCC3SemanticLightColorAmbient7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightColorAmbient0)];
			if (glesLight.isEnabled) [uniform setColor4F: glesLight.ambientColor.value ];
			return YES;
			
		case kCC3SemanticLightColorDiffuse0:
		case kCC3SemanticLightColorDiffuse1:
		case kCC3SemanticLightColorDiffuse2:
		case kCC3SemanticLightColorDiffuse3:
		case kCC3SemanticLightColorDiffuse4:
		case kCC3SemanticLightColorDiffuse5:
		case kCC3SemanticLightColorDiffuse6:
		case kCC3SemanticLightColorDiffuse7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightColorDiffuse0)];
			if (glesLight.isEnabled) [uniform setColor4F: glesLight.diffuseColor.value ];
			return YES;
			
		case kCC3SemanticLightColorSpecular0:
		case kCC3SemanticLightColorSpecular1:
		case kCC3SemanticLightColorSpecular2:
		case kCC3SemanticLightColorSpecular3:
		case kCC3SemanticLightColorSpecular4:
		case kCC3SemanticLightColorSpecular5:
		case kCC3SemanticLightColorSpecular6:
		case kCC3SemanticLightColorSpecular7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightColorSpecular0)];
			if (glesLight.isEnabled) [uniform setColor4F: glesLight.specularColor.value ];
			return YES;
			
		case kCC3SemanticLightAttenuationCoefficients0:
		case kCC3SemanticLightAttenuationCoefficients1:
		case kCC3SemanticLightAttenuationCoefficients2:
		case kCC3SemanticLightAttenuationCoefficients3:
		case kCC3SemanticLightAttenuationCoefficients4:
		case kCC3SemanticLightAttenuationCoefficients5:
		case kCC3SemanticLightAttenuationCoefficients6:
		case kCC3SemanticLightAttenuationCoefficients7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightAttenuationCoefficients0)];
			if (glesLight.isEnabled) {
				CC3AttenuationCoefficients ac;
				ac.a = glesLight.constantAttenuation.value;
				ac.b = glesLight.linearAttenuation.value;
				ac.c = glesLight.quadraticAttenuation.value;
				[uniform setVector: *(CC3Vector*)&ac];
			}
			return YES;
			
		case kCC3SemanticLightSpotDirection0:
		case kCC3SemanticLightSpotDirection1:
		case kCC3SemanticLightSpotDirection2:
		case kCC3SemanticLightSpotDirection3:
		case kCC3SemanticLightSpotDirection4:
		case kCC3SemanticLightSpotDirection5:
		case kCC3SemanticLightSpotDirection6:
		case kCC3SemanticLightSpotDirection7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightSpotDirection0)];
			if (glesLight.isEnabled) {
				// Transform global direction to eye space and normalize
				CC3Vector4 ltDir = CC3Vector4FromDirection(glesLight.spotDirection.value);
				CC3Matrix4x4* viewMtx = CC3OpenGLESEngine.engine.matrices.viewMatrix;
				ltDir = CC3Matrix4x4TransformCC3Vector4(viewMtx, ltDir);
				[uniform setVector: CC3VectorNormalize(CC3VectorFromTruncatedCC3Vector4(ltDir))];
			}

			if (glesLight.isEnabled) [uniform setVector: glesLight.spotDirection.value ];
			return YES;
			
		case kCC3SemanticLightSpotExponent0:
		case kCC3SemanticLightSpotExponent1:
		case kCC3SemanticLightSpotExponent2:
		case kCC3SemanticLightSpotExponent3:
		case kCC3SemanticLightSpotExponent4:
		case kCC3SemanticLightSpotExponent5:
		case kCC3SemanticLightSpotExponent6:
		case kCC3SemanticLightSpotExponent7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightSpotExponent0)];
			if (glesLight.isEnabled) [uniform setFloat: glesLight.spotExponent.value ];
			return YES;
			
		case kCC3SemanticLightSpotCutoffAngle0:
		case kCC3SemanticLightSpotCutoffAngle1:
		case kCC3SemanticLightSpotCutoffAngle2:
		case kCC3SemanticLightSpotCutoffAngle3:
		case kCC3SemanticLightSpotCutoffAngle4:
		case kCC3SemanticLightSpotCutoffAngle5:
		case kCC3SemanticLightSpotCutoffAngle6:
		case kCC3SemanticLightSpotCutoffAngle7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightSpotCutoffAngle0)];
			if (glesLight.isEnabled) [uniform setFloat: glesLight.spotCutoffAngle.value ];
			return YES;
			
		case kCC3SemanticLightSpotCutoffAngleCosine0:
		case kCC3SemanticLightSpotCutoffAngleCosine1:
		case kCC3SemanticLightSpotCutoffAngleCosine2:
		case kCC3SemanticLightSpotCutoffAngleCosine3:
		case kCC3SemanticLightSpotCutoffAngleCosine4:
		case kCC3SemanticLightSpotCutoffAngleCosine5:
		case kCC3SemanticLightSpotCutoffAngleCosine6:
		case kCC3SemanticLightSpotCutoffAngleCosine7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightSpotCutoffAngleCosine0)];
			if (glesLight.isEnabled) [uniform setFloat: cosf(DegreesToRadians(glesLight.spotCutoffAngle.value)) ];
			return YES;
			
		// Textures
		case kCC3SemanticTextureCount:
			[uniform setInteger: visitor.textureUnitCount];
			return YES;

		case kCC3SemanticTexture0:
		case kCC3SemanticTexture1:
		case kCC3SemanticTexture2:
		case kCC3SemanticTexture3:
		case kCC3SemanticTexture4:
		case kCC3SemanticTexture5:
		case kCC3SemanticTexture6:
		case kCC3SemanticTexture7:
			[uniform setInteger: semantic - kCC3SemanticTexture0];
			return YES;

		default: return NO;
	}
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateByVarNames

@implementation CC3GLProgramSemanticsDelegateByVarNames

-(BOOL) assignAttributeSemantic: (CC3GLSLAttribute*) variable {
	CC3SetSemantic(@"a_cc3Position", kCC3VertexContentSemanticLocations);
	CC3SetSemantic(@"a_cc3Normal", kCC3VertexContentSemanticNormals);
	CC3SetSemantic(@"a_cc3Color", kCC3VertexContentSemanticColors);
	CC3SetSemantic(@"a_cc3Weight", kCC3VertexContentSemanticWeights);
	CC3SetSemantic(@"a_cc3MatrixIdx", kCC3VertexContentSemanticMatrices);
	CC3SetSemantic(@"a_cc3PointSize", kCC3VertexContentSemanticPointSizes);
	CC3SetSemantic(@"a_cc3TexCoord", kCC3VertexContentSemanticTexture0);	// alias to a_cc3TexCoord0
	CC3SetSemantic(@"a_cc3TexCoord0", kCC3VertexContentSemanticTexture0);
	CC3SetSemantic(@"a_cc3TexCoord1", kCC3VertexContentSemanticTexture1);
	CC3SetSemantic(@"a_cc3TexCoord2", kCC3VertexContentSemanticTexture2);
	CC3SetSemantic(@"a_cc3TexCoord3", kCC3VertexContentSemanticTexture3);
	CC3SetSemantic(@"a_cc3TexCoord4", kCC3VertexContentSemanticTexture4);
	CC3SetSemantic(@"a_cc3TexCoord5", kCC3VertexContentSemanticTexture5);
	CC3SetSemantic(@"a_cc3TexCoord6", kCC3VertexContentSemanticTexture6);
	CC3SetSemantic(@"a_cc3TexCoord7", kCC3VertexContentSemanticTexture7);
	
	return NO;
}

-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) variable {

	// Attribute qualifiers
	CC3SetSemantic(@"u_cc3HasVertexNormal", kCC3SemanticHasVertexNormal);
	CC3SetSemantic(@"u_cc3ShouldNormalizeNormal", kCC3SemanticShouldNormalizeVertexNormal);
	CC3SetSemantic(@"u_cc3ShouldRescaleNormal", kCC3SemanticShouldRescaleVertexNormal);
	CC3SetSemantic(@"u_cc3HasVertexColor", kCC3SemanticHasVertexColor);
	CC3SetSemantic(@"u_cc3TexCoordCount", kCC3SemanticTexCoordCount);
	
	// Environment matrices
	CC3SetSemantic(@"u_cc3MtxM", kCC3SemanticModelMatrix);
	CC3SetSemantic(@"u_cc3MtxMI", kCC3SemanticModelMatrixInv);
	CC3SetSemantic(@"u_cc3MtxMIT", kCC3SemanticModelMatrixInvTran);
	CC3SetSemantic(@"u_cc3MtxV", kCC3SemanticViewMatrix);
	CC3SetSemantic(@"u_cc3MtxVI", kCC3SemanticViewMatrixInv);
	CC3SetSemantic(@"u_cc3MtxVIT", kCC3SemanticViewMatrixInvTran);
	CC3SetSemantic(@"u_cc3MtxMV", kCC3SemanticModelViewMatrix);
	CC3SetSemantic(@"u_cc3MtxMVI", kCC3SemanticModelViewMatrixInv);
	CC3SetSemantic(@"u_cc3MtxMVIT", kCC3SemanticModelViewMatrixInvTran);
	CC3SetSemantic(@"u_cc3MtxP", kCC3SemanticProjMatrix);
	CC3SetSemantic(@"u_cc3MtxPI", kCC3SemanticProjMatrixInv);
	CC3SetSemantic(@"u_cc3MtxPIT", kCC3SemanticProjMatrixInvTran);
	CC3SetSemantic(@"u_cc3MtxMVP", kCC3SemanticModelViewProjMatrix);
	CC3SetSemantic(@"u_cc3MtxMVPI", kCC3SemanticModelViewProjMatrixInv);
	CC3SetSemantic(@"u_cc3MtxMVPIT", kCC3SemanticModelViewProjMatrixInvTran);
	
	// Material properties
	CC3SetSemantic(@"u_cc3MatColorAmbient", kCC3SemanticMaterialColorAmbient);
	CC3SetSemantic(@"u_cc3MatColorDiffuse", kCC3SemanticMaterialColorDiffuse);
	CC3SetSemantic(@"u_cc3MatColorSpecular", kCC3SemanticMaterialColorSpecular);
	CC3SetSemantic(@"u_cc3MatColorEmission", kCC3SemanticMaterialColorEmission);
	CC3SetSemantic(@"u_cc3MatShininess", kCC3SemanticMaterialShininess);

	// Texture samplers & properties
	CC3SetSemantic(@"u_cc3TextureCount", kCC3SemanticTextureCount);
	CC3SetSemantic(@"s_cc3Texture[0]", kCC3SemanticTexture0);
	CC3SetSemantic(@"s_cc3Texture[1]", kCC3SemanticTexture1);
	CC3SetSemantic(@"s_cc3Texture[2]", kCC3SemanticTexture2);
	CC3SetSemantic(@"s_cc3Texture[3]", kCC3SemanticTexture3);
	CC3SetSemantic(@"s_cc3Texture[4]", kCC3SemanticTexture4);
	CC3SetSemantic(@"s_cc3Texture[5]", kCC3SemanticTexture5);
	CC3SetSemantic(@"s_cc3Texture[6]", kCC3SemanticTexture6);
	CC3SetSemantic(@"s_cc3Texture[7]", kCC3SemanticTexture7);

	// Lighting
	CC3SetSemantic(@"u_cc3IsUsingLighting", kCC3SemanticIsUsingLighting);
	CC3SetSemantic(@"u_cc3SceneLightColorAmbient", kCC3SemanticSceneLightColorAmbient);

	CC3SetSemantic(@"u_cc3Light.isEnabled", kCC3SemanticLightIsEnabled0);		// Aliases for light zero
	CC3SetSemantic(@"u_cc3Light.position", kCC3SemanticLightPosition0);
	CC3SetSemantic(@"u_cc3Light.colorAmbient", kCC3SemanticLightColorAmbient0);
	CC3SetSemantic(@"u_cc3Light.colorDiffuse", kCC3SemanticLightColorDiffuse0);
	CC3SetSemantic(@"u_cc3Light.colorSpecular", kCC3SemanticLightColorSpecular0);
	CC3SetSemantic(@"u_cc3Light.attenuationCoefficients", kCC3SemanticLightAttenuationCoefficients0);
	CC3SetSemantic(@"u_cc3Light.spotDirection", kCC3SemanticLightSpotDirection0);
	CC3SetSemantic(@"u_cc3Light.spotExponent", kCC3SemanticLightSpotExponent0);
	CC3SetSemantic(@"u_cc3Light.spotCutoffAngle", kCC3SemanticLightSpotCutoffAngle0);
	CC3SetSemantic(@"u_cc3Light.spotCutoffAngleCosine", kCC3SemanticLightSpotCutoffAngleCosine0);

	CC3SetSemantic(@"u_cc3Lights[0].isEnabled", kCC3SemanticLightIsEnabled0);
	CC3SetSemantic(@"u_cc3Lights[0].position", kCC3SemanticLightPosition0);
	CC3SetSemantic(@"u_cc3Lights[0].colorAmbient", kCC3SemanticLightColorAmbient0);
	CC3SetSemantic(@"u_cc3Lights[0].colorDiffuse", kCC3SemanticLightColorDiffuse0);
	CC3SetSemantic(@"u_cc3Lights[0].colorSpecular", kCC3SemanticLightColorSpecular0);
	CC3SetSemantic(@"u_cc3Lights[0].attenuationCoefficients", kCC3SemanticLightAttenuationCoefficients0);
	CC3SetSemantic(@"u_cc3Lights[0].spotDirection", kCC3SemanticLightSpotDirection0);
	CC3SetSemantic(@"u_cc3Lights[0].spotExponent", kCC3SemanticLightSpotExponent0);
	CC3SetSemantic(@"u_cc3Lights[0].spotCutoffAngle", kCC3SemanticLightSpotCutoffAngle0);
	CC3SetSemantic(@"u_cc3Lights[0].spotCutoffAngleCosine", kCC3SemanticLightSpotCutoffAngleCosine0);
	
	CC3SetSemantic(@"u_cc3Lights[1].isEnabled", kCC3SemanticLightIsEnabled1);
	CC3SetSemantic(@"u_cc3Lights[1].position", kCC3SemanticLightPosition1);
	CC3SetSemantic(@"u_cc3Lights[1].colorAmbient", kCC3SemanticLightColorAmbient1);
	CC3SetSemantic(@"u_cc3Lights[1].colorDiffuse", kCC3SemanticLightColorDiffuse1);
	CC3SetSemantic(@"u_cc3Lights[1].colorSpecular", kCC3SemanticLightColorSpecular1);
	CC3SetSemantic(@"u_cc3Lights[1].attenuationCoefficients", kCC3SemanticLightAttenuationCoefficients1);
	CC3SetSemantic(@"u_cc3Lights[1].spotDirection", kCC3SemanticLightSpotDirection1);
	CC3SetSemantic(@"u_cc3Lights[1].spotExponent", kCC3SemanticLightSpotExponent1);
	CC3SetSemantic(@"u_cc3Lights[1].spotCutoffAngle", kCC3SemanticLightSpotCutoffAngle1);
	CC3SetSemantic(@"u_cc3Lights[1].spotCutoffAngleCosine", kCC3SemanticLightSpotCutoffAngleCosine1);
	
	CC3SetSemantic(@"u_cc3Lights[2].isEnabled", kCC3SemanticLightIsEnabled2);
	CC3SetSemantic(@"u_cc3Lights[2].position", kCC3SemanticLightPosition2);
	CC3SetSemantic(@"u_cc3Lights[2].colorAmbient", kCC3SemanticLightColorAmbient2);
	CC3SetSemantic(@"u_cc3Lights[2].colorDiffuse", kCC3SemanticLightColorDiffuse2);
	CC3SetSemantic(@"u_cc3Lights[2].colorSpecular", kCC3SemanticLightColorSpecular2);
	CC3SetSemantic(@"u_cc3Lights[2].attenuationCoefficients", kCC3SemanticLightAttenuationCoefficients2);
	CC3SetSemantic(@"u_cc3Lights[2].spotDirection", kCC3SemanticLightSpotDirection2);
	CC3SetSemantic(@"u_cc3Lights[2].spotExponent", kCC3SemanticLightSpotExponent2);
	CC3SetSemantic(@"u_cc3Lights[2].spotCutoffAngle", kCC3SemanticLightSpotCutoffAngle2);
	CC3SetSemantic(@"u_cc3Lights[2].spotCutoffAngleCosine", kCC3SemanticLightSpotCutoffAngleCosine2);
	
	CC3SetSemantic(@"u_cc3Lights[3].isEnabled", kCC3SemanticLightIsEnabled3);
	CC3SetSemantic(@"u_cc3Lights[3].position", kCC3SemanticLightPosition3);
	CC3SetSemantic(@"u_cc3Lights[3].colorAmbient", kCC3SemanticLightColorAmbient3);
	CC3SetSemantic(@"u_cc3Lights[3].colorDiffuse", kCC3SemanticLightColorDiffuse3);
	CC3SetSemantic(@"u_cc3Lights[3].colorSpecular", kCC3SemanticLightColorSpecular3);
	CC3SetSemantic(@"u_cc3Lights[3].attenuationCoefficients", kCC3SemanticLightAttenuationCoefficients3);
	CC3SetSemantic(@"u_cc3Lights[3].spotDirection", kCC3SemanticLightSpotDirection3);
	CC3SetSemantic(@"u_cc3Lights[3].spotExponent", kCC3SemanticLightSpotExponent3);
	CC3SetSemantic(@"u_cc3Lights[3].spotCutoffAngle", kCC3SemanticLightSpotCutoffAngle3);
	CC3SetSemantic(@"u_cc3Lights[3].spotCutoffAngleCosine", kCC3SemanticLightSpotCutoffAngleCosine3);
	
	return NO;
}

@end
