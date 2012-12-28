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
#import "CC3PointParticles.h"

NSString* NSStringFromCC3Semantic(CC3Semantic semantic) {
	switch (semantic) {
		case kCC3SemanticNone: return @"kCC3SemanticNone";

		// VERTEX CONTENT --------------
		case kCC3SemanticVertexLocations: return @"kCC3SemanticVertexLocations";
		case kCC3SemanticVertexNormals: return @"kCC3SemanticVertexNormals";
		case kCC3SemanticVertexColors: return @"kCC3SemanticVertexColors";
		case kCC3SemanticVertexPointSizes: return @"kCC3SemanticVertexPointSizes";
		case kCC3SemanticVertexWeights: return @"kCC3SemanticVertexWeights";
		case kCC3SemanticVertexMatrices: return @"kCC3SemanticVertexMatrices";
		case kCC3SemanticVertexTexture0: return @"kCC3SemanticVertexTexture0";
		case kCC3SemanticVertexTexture1: return @"kCC3SemanticVertexTexture1";
		case kCC3SemanticVertexTexture2: return @"kCC3SemanticVertexTexture2";
		case kCC3SemanticVertexTexture3: return @"kCC3SemanticVertexTexture3";
		case kCC3SemanticVertexTexture4: return @"kCC3SemanticVertexTexture4";
		case kCC3SemanticVertexTexture5: return @"kCC3SemanticVertexTexture5";
		case kCC3SemanticVertexTexture6: return @"kCC3SemanticVertexTexture6";
		case kCC3SemanticVertexTexture7: return @"kCC3SemanticVertexTexture7";
			
		case kCC3SemanticHasVertexNormal: return @"kCC3SemanticHasVertexNormal";
		case kCC3SemanticShouldNormalizeVertexNormal: return @"kCC3SemanticShouldNormalizeVertexNormal";
		case kCC3SemanticShouldRescaleVertexNormal: return @"kCC3SemanticShouldRescaleVertexNormal";
		case kCC3SemanticHasVertexColor: return @"kCC3SemanticHasVertexColor";
		case kCC3SemanticHasVertexTextureCoordinate: return @"kCC3SemanticHasVertexTextureCoordinate";
		case kCC3SemanticHasVertexPointSize: return @"kCC3SemanticHasVertexPointSize";
		case kCC3SemanticIsDrawingPoints: return @"kCC3SemanticIsDrawingPoints";

		// ENVIRONMENT MATRICES --------------
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
			
		// CAMERA -----------------
		case kCC3SemanticCameraPosition: return @"kCC3SemanticCameraPosition";
			
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

		case kCC3SemanticLightAttenuation0: return @"kCC3SemanticLightAttenuation0";
		case kCC3SemanticLightAttenuation1: return @"kCC3SemanticLightAttenuation1";
		case kCC3SemanticLightAttenuation2: return @"kCC3SemanticLightAttenuation2";
		case kCC3SemanticLightAttenuation3: return @"kCC3SemanticLightAttenuation3";
		case kCC3SemanticLightAttenuation4: return @"kCC3SemanticLightAttenuation4";
		case kCC3SemanticLightAttenuation5: return @"kCC3SemanticLightAttenuation5";
		case kCC3SemanticLightAttenuation6: return @"kCC3SemanticLightAttenuation6";
		case kCC3SemanticLightAttenuation7: return @"kCC3SemanticLightAttenuation7";

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
			
		// TEXTURES --------------
		case kCC3SemanticTextureCount: return @"kCC3SemanticTextureCount";
		case kCC3SemanticTexture0: return @"kCC3SemanticTexture0";
		case kCC3SemanticTexture1: return @"kCC3SemanticTexture1";
		case kCC3SemanticTexture2: return @"kCC3SemanticTexture2";
		case kCC3SemanticTexture3: return @"kCC3SemanticTexture3";
		case kCC3SemanticTexture4: return @"kCC3SemanticTexture4";
		case kCC3SemanticTexture5: return @"kCC3SemanticTexture5";
		case kCC3SemanticTexture6: return @"kCC3SemanticTexture6";
		case kCC3SemanticTexture7: return @"kCC3SemanticTexture7";

		// PARTICLES ------------
		case kCC3SemanticPointSize: return @"kCC3SemanticPointSize";
		case kCC3SemanticPointSizeAttenuation: return @"kCC3SemanticPointSizeAttenuation";
		case kCC3SemanticPointSizeMinimum: return @"kCC3SemanticPointSizeMinimum";
		case kCC3SemanticPointSizeMaximum: return @"kCC3SemanticPointSizeMaximum";
		case kCC3SemanticPointSizeFadeThreshold: return @"kCC3SemanticPointSizeFadeThreshold";
		case kCC3SemanticPointSpritesIsEnabled: return @"kCC3SemanticPointSpritesIsEnabled";
			
			
		case kCC3SemanticAppBase: return @"kCC3SemanticAppBase";
		case kCC3SemanticMax: return @"kCC3SemanticMax";
		default: return [NSString stringWithFormat: @"Unknown state semantic (%u)", semantic];
	}
}


#pragma mark -
#pragma mark CC3GLSLVariableConfiguration

@implementation CC3GLSLVariableConfiguration

@synthesize name=_name, semantic=_semantic;

-(void) dealloc {
	[_name release];
	[super dealloc];
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateBase

@implementation CC3GLProgramSemanticsDelegateBase

+(id) semanticsDelegate { return [[[self alloc] init] autorelease]; }

-(NSString*) nameOfSemantic: (GLenum) semantic { return NSStringFromCC3Semantic(semantic); }

-(BOOL) configureVariable: (CC3GLSLVariable*) variable { return NO; }

-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLESLight* glesLight;
	GLenum semantic = uniform.semantic;
	switch (semantic) {
		
		// ATTRIBUTE QUALIFIERS --------------
		case kCC3SemanticHasVertexNormal:
			[uniform setBoolean: visitor.currentMesh.hasVertexNormals];
			return YES;
		case kCC3SemanticShouldNormalizeVertexNormal:
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.normalize.value];
			return YES;
		case kCC3SemanticShouldRescaleVertexNormal:
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.rescaleNormal.value];
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
		case kCC3SemanticModelMatrix: {
			CC3Matrix4x4 mtx;
			[visitor.currentMeshNode.transformMatrix populateCC3Matrix4x4: &mtx];
			[uniform setMatrices4x4: &mtx];
			return YES;
		}
		case kCC3SemanticModelMatrixInv: {
			CC3Matrix4x4 mtx;
			[visitor.currentMeshNode.transformMatrixInverted populateCC3Matrix4x4: &mtx];
			[uniform setMatrices4x4: &mtx];
			return YES;
		}
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
			
			// CAMERA -----------------
		case kCC3SemanticCameraPosition:
			[uniform setVector: visitor.camera.globalLocation];
			return YES;
			
		// MATERIALS --------------
		case kCC3SemanticColor: {
			[uniform setColor4F: CC3OpenGLESEngine.engine.state.color.value];
			return YES;
		}
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
			
		// LIGHTING --------------
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
			
		case kCC3SemanticLightAttenuation0:
		case kCC3SemanticLightAttenuation1:
		case kCC3SemanticLightAttenuation2:
		case kCC3SemanticLightAttenuation3:
		case kCC3SemanticLightAttenuation4:
		case kCC3SemanticLightAttenuation5:
		case kCC3SemanticLightAttenuation6:
		case kCC3SemanticLightAttenuation7:
			glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semantic - kCC3SemanticLightAttenuation0)];
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
			
		// TEXTURES --------------
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

		// PARTICLES ------------
		case kCC3SemanticPointSize:
			[uniform setFloat: CC3OpenGLESEngine.engine.state.pointSize.value];
			return YES;
		case kCC3SemanticPointSizeAttenuation:
			[uniform setVector: CC3OpenGLESEngine.engine.state.pointSizeAttenuation.value];
			return YES;
		case kCC3SemanticPointSizeMinimum:
			[uniform setFloat: CC3OpenGLESEngine.engine.state.pointSizeMinimum.value];
			return YES;
		case kCC3SemanticPointSizeMaximum:
			[uniform setFloat: CC3OpenGLESEngine.engine.state.pointSizeMaximum.value];
			return YES;
		case kCC3SemanticPointSizeFadeThreshold:
			[uniform setFloat: CC3OpenGLESEngine.engine.state.pointSizeFadeThreshold.value];
			return YES;
		case kCC3SemanticPointSpritesIsEnabled:
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.pointSprites.value];
			return YES;

			
		default: return NO;
	}
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateByVarNames

@implementation CC3GLProgramSemanticsDelegateByVarNames

-(void) dealloc {
	[_varConfigsByName release];
	[super dealloc];
}

/**
 * Uses the variable name property to look up a configuration and sets the
 */
-(BOOL) configureVariable: (CC3GLSLVariable*) variable {
	CC3GLSLVariableConfiguration* varConfig = [_varConfigsByName objectForKey: variable.name];
	if (varConfig) {
		variable.semantic = varConfig.semantic;
		return YES;
	}
	return NO;
}

-(void) addVariableConfiguration: (CC3GLSLVariableConfiguration*) varConfig {
	if ( !_varConfigsByName ) _varConfigsByName = [NSMutableDictionary new];		// retained
	[_varConfigsByName setObject: varConfig forKey: varConfig.name];
}

-(void) mapVariableName: (NSString*) name toSemantic: (GLenum) semantic {
	CC3GLSLVariableConfiguration* varConfig = [CC3GLSLVariableConfiguration new];
	varConfig.name = name;
	varConfig.semantic = semantic;
	[self addVariableConfiguration: varConfig];
	[varConfig release];
}

-(void) populateWithDefaultSemanticMappings {

	// VETEX ATTRIBUTES --------------
	[self mapVariableName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocations];
	[self mapVariableName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormals];
	[self mapVariableName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColors];
	[self mapVariableName: @"a_cc3Weight" toSemantic: kCC3SemanticVertexWeights];
	[self mapVariableName: @"a_cc3MatrixIdx" toSemantic: kCC3SemanticVertexMatrices];
	[self mapVariableName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSizes];
	[self mapVariableName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture0];	// alias to a_cc3TexCoord0
	[self mapVariableName: @"a_cc3TexCoord0" toSemantic: kCC3SemanticVertexTexture0];
	[self mapVariableName: @"a_cc3TexCoord1" toSemantic: kCC3SemanticVertexTexture1];
	[self mapVariableName: @"a_cc3TexCoord2" toSemantic: kCC3SemanticVertexTexture2];
	[self mapVariableName: @"a_cc3TexCoord3" toSemantic: kCC3SemanticVertexTexture3];
	[self mapVariableName: @"a_cc3TexCoord4" toSemantic: kCC3SemanticVertexTexture4];
	[self mapVariableName: @"a_cc3TexCoord5" toSemantic: kCC3SemanticVertexTexture5];
	[self mapVariableName: @"a_cc3TexCoord6" toSemantic: kCC3SemanticVertexTexture6];
	[self mapVariableName: @"a_cc3TexCoord7" toSemantic: kCC3SemanticVertexTexture7];
	
	// ATTRIBUTE QUALIFIERS --------------
	[self mapVariableName: @"u_cc3HasVertexNormal" toSemantic: kCC3SemanticHasVertexNormal];
	[self mapVariableName: @"u_cc3ShouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];
	[self mapVariableName: @"u_cc3ShouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];
	[self mapVariableName: @"u_cc3HasVertexColor" toSemantic: kCC3SemanticHasVertexColor];
	[self mapVariableName: @"u_cc3HasVertexTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];
	[self mapVariableName: @"u_cc3HasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];	// alias for u_cc3Points.hasVertexPointSize
	[self mapVariableName: @"u_cc3IsDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];		// alias for u_cc3Points.isDrawingPoints
	
	// PARTICLES ------------
	[self mapVariableName: @"u_cc3Points.isDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];			// alias for u_cc3IsDrawingPoints
	[self mapVariableName: @"u_cc3Points.hasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];	// alias for u_cc3HasVertexPointSize
	[self mapVariableName: @"u_cc3Points.size" toSemantic: kCC3SemanticPointSize];
	[self mapVariableName: @"u_cc3Points.sizeAttenuation" toSemantic: kCC3SemanticPointSizeAttenuation];
	[self mapVariableName: @"u_cc3Points.minimumSize" toSemantic: kCC3SemanticPointSizeMinimum];
	[self mapVariableName: @"u_cc3Points.maximumSize" toSemantic: kCC3SemanticPointSizeMaximum];
	[self mapVariableName: @"u_cc3Points.sizeFadeThreshold" toSemantic: kCC3SemanticPointSizeFadeThreshold];
	[self mapVariableName: @"u_cc3Points.shouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];
	
	// ENVIRONMENT MATRICES --------------
	[self mapVariableName: @"u_cc3MtxM" toSemantic: kCC3SemanticModelMatrix];
	[self mapVariableName: @"u_cc3MtxMI" toSemantic: kCC3SemanticModelMatrixInv];
	[self mapVariableName: @"u_cc3MtxMIT" toSemantic: kCC3SemanticModelMatrixInvTran];
	[self mapVariableName: @"u_cc3MtxV" toSemantic: kCC3SemanticViewMatrix];
	[self mapVariableName: @"u_cc3MtxVI" toSemantic: kCC3SemanticViewMatrixInv];
	[self mapVariableName: @"u_cc3MtxVIT" toSemantic: kCC3SemanticViewMatrixInvTran];
	[self mapVariableName: @"u_cc3MtxMV" toSemantic: kCC3SemanticModelViewMatrix];
	[self mapVariableName: @"u_cc3MtxMVI" toSemantic: kCC3SemanticModelViewMatrixInv];
	[self mapVariableName: @"u_cc3MtxMVIT" toSemantic: kCC3SemanticModelViewMatrixInvTran];
	[self mapVariableName: @"u_cc3MtxP" toSemantic: kCC3SemanticProjMatrix];
	[self mapVariableName: @"u_cc3MtxPI" toSemantic: kCC3SemanticProjMatrixInv];
	[self mapVariableName: @"u_cc3MtxPIT" toSemantic: kCC3SemanticProjMatrixInvTran];
	[self mapVariableName: @"u_cc3MtxMVP" toSemantic: kCC3SemanticModelViewProjMatrix];
	[self mapVariableName: @"u_cc3MtxMVPI" toSemantic: kCC3SemanticModelViewProjMatrixInv];
	[self mapVariableName: @"u_cc3MtxMVPIT" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];
	
	// CAMERA -----------------
	[self mapVariableName: @"u_cc3CameraPosition" toSemantic: kCC3SemanticCameraPosition];
	
	// MATERIALS --------------
	[self mapVariableName: @"u_cc3Color" toSemantic: kCC3SemanticColor];
	[self mapVariableName: @"u_cc3MatColorAmbient" toSemantic: kCC3SemanticMaterialColorAmbient];
	[self mapVariableName: @"u_cc3MatColorDiffuse" toSemantic: kCC3SemanticMaterialColorDiffuse];
	[self mapVariableName: @"u_cc3MatColorSpecular" toSemantic: kCC3SemanticMaterialColorSpecular];
	[self mapVariableName: @"u_cc3MatColorEmission" toSemantic: kCC3SemanticMaterialColorEmission];
	[self mapVariableName: @"u_cc3MatShininess" toSemantic: kCC3SemanticMaterialShininess];
	
	// TEXTURES --------------
	[self mapVariableName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];
	[self mapVariableName: @"s_cc3Texture[0]" toSemantic: kCC3SemanticTexture0];
	[self mapVariableName: @"s_cc3Texture[1]" toSemantic: kCC3SemanticTexture1];
	[self mapVariableName: @"s_cc3Texture[2]" toSemantic: kCC3SemanticTexture2];
	[self mapVariableName: @"s_cc3Texture[3]" toSemantic: kCC3SemanticTexture3];
	[self mapVariableName: @"s_cc3Texture[4]" toSemantic: kCC3SemanticTexture4];
	[self mapVariableName: @"s_cc3Texture[5]" toSemantic: kCC3SemanticTexture5];
	[self mapVariableName: @"s_cc3Texture[6]" toSemantic: kCC3SemanticTexture6];
	[self mapVariableName: @"s_cc3Texture[7]" toSemantic: kCC3SemanticTexture7];
	
	// LIGHTING --------------
	[self mapVariableName: @"u_cc3IsUsingLighting" toSemantic: kCC3SemanticIsUsingLighting];
	[self mapVariableName: @"u_cc3SceneLightColorAmbient" toSemantic: kCC3SemanticSceneLightColorAmbient];
	
	[self mapVariableName: @"u_cc3Light.isEnabled" toSemantic: kCC3SemanticLightIsEnabled0];		// Aliases for light zero
	[self mapVariableName: @"u_cc3Light.position" toSemantic: kCC3SemanticLightPosition0];
	[self mapVariableName: @"u_cc3Light.colorAmbient" toSemantic: kCC3SemanticLightColorAmbient0];
	[self mapVariableName: @"u_cc3Light.colorDiffuse" toSemantic: kCC3SemanticLightColorDiffuse0];
	[self mapVariableName: @"u_cc3Light.colorSpecular" toSemantic: kCC3SemanticLightColorSpecular0];
	[self mapVariableName: @"u_cc3Light.attenuation" toSemantic: kCC3SemanticLightAttenuation0];
	[self mapVariableName: @"u_cc3Light.spotDirection" toSemantic: kCC3SemanticLightSpotDirection0];
	[self mapVariableName: @"u_cc3Light.spotExponent" toSemantic: kCC3SemanticLightSpotExponent0];
	[self mapVariableName: @"u_cc3Light.spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle0];
	[self mapVariableName: @"u_cc3Light.spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine0];
	
	[self mapVariableName: @"u_cc3Lights[0].isEnabled" toSemantic: kCC3SemanticLightIsEnabled0];
	[self mapVariableName: @"u_cc3Lights[0].position" toSemantic: kCC3SemanticLightPosition0];
	[self mapVariableName: @"u_cc3Lights[0].colorAmbient" toSemantic: kCC3SemanticLightColorAmbient0];
	[self mapVariableName: @"u_cc3Lights[0].colorDiffuse" toSemantic: kCC3SemanticLightColorDiffuse0];
	[self mapVariableName: @"u_cc3Lights[0].colorSpecular" toSemantic: kCC3SemanticLightColorSpecular0];
	[self mapVariableName: @"u_cc3Lights[0].attenuation" toSemantic: kCC3SemanticLightAttenuation0];
	[self mapVariableName: @"u_cc3Lights[0].spotDirection" toSemantic: kCC3SemanticLightSpotDirection0];
	[self mapVariableName: @"u_cc3Lights[0].spotExponent" toSemantic: kCC3SemanticLightSpotExponent0];
	[self mapVariableName: @"u_cc3Lights[0].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle0];
	[self mapVariableName: @"u_cc3Lights[0].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine0];
	
	[self mapVariableName: @"u_cc3Lights[1].isEnabled" toSemantic: kCC3SemanticLightIsEnabled1];
	[self mapVariableName: @"u_cc3Lights[1].position" toSemantic: kCC3SemanticLightPosition1];
	[self mapVariableName: @"u_cc3Lights[1].colorAmbient" toSemantic: kCC3SemanticLightColorAmbient1];
	[self mapVariableName: @"u_cc3Lights[1].colorDiffuse" toSemantic: kCC3SemanticLightColorDiffuse1];
	[self mapVariableName: @"u_cc3Lights[1].colorSpecular" toSemantic: kCC3SemanticLightColorSpecular1];
	[self mapVariableName: @"u_cc3Lights[1].attenuation" toSemantic: kCC3SemanticLightAttenuation1];
	[self mapVariableName: @"u_cc3Lights[1].spotDirection" toSemantic: kCC3SemanticLightSpotDirection1];
	[self mapVariableName: @"u_cc3Lights[1].spotExponent" toSemantic: kCC3SemanticLightSpotExponent1];
	[self mapVariableName: @"u_cc3Lights[1].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle1];
	[self mapVariableName: @"u_cc3Lights[1].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine1];
	
	[self mapVariableName: @"u_cc3Lights[2].isEnabled" toSemantic: kCC3SemanticLightIsEnabled2];
	[self mapVariableName: @"u_cc3Lights[2].position" toSemantic: kCC3SemanticLightPosition2];
	[self mapVariableName: @"u_cc3Lights[2].colorAmbient" toSemantic: kCC3SemanticLightColorAmbient2];
	[self mapVariableName: @"u_cc3Lights[2].colorDiffuse" toSemantic: kCC3SemanticLightColorDiffuse2];
	[self mapVariableName: @"u_cc3Lights[2].colorSpecular" toSemantic: kCC3SemanticLightColorSpecular2];
	[self mapVariableName: @"u_cc3Lights[2].attenuation" toSemantic: kCC3SemanticLightAttenuation2];
	[self mapVariableName: @"u_cc3Lights[2].spotDirection" toSemantic: kCC3SemanticLightSpotDirection2];
	[self mapVariableName: @"u_cc3Lights[2].spotExponent" toSemantic: kCC3SemanticLightSpotExponent2];
	[self mapVariableName: @"u_cc3Lights[2].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle2];
	[self mapVariableName: @"u_cc3Lights[2].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine2];
	
	[self mapVariableName: @"u_cc3Lights[3].isEnabled" toSemantic: kCC3SemanticLightIsEnabled3];
	[self mapVariableName: @"u_cc3Lights[3].position" toSemantic: kCC3SemanticLightPosition3];
	[self mapVariableName: @"u_cc3Lights[3].colorAmbient" toSemantic: kCC3SemanticLightColorAmbient3];
	[self mapVariableName: @"u_cc3Lights[3].colorDiffuse" toSemantic: kCC3SemanticLightColorDiffuse3];
	[self mapVariableName: @"u_cc3Lights[3].colorSpecular" toSemantic: kCC3SemanticLightColorSpecular3];
	[self mapVariableName: @"u_cc3Lights[3].attenuation" toSemantic: kCC3SemanticLightAttenuation3];
	[self mapVariableName: @"u_cc3Lights[3].spotDirection" toSemantic: kCC3SemanticLightSpotDirection3];
	[self mapVariableName: @"u_cc3Lights[3].spotExponent" toSemantic: kCC3SemanticLightSpotExponent3];
	[self mapVariableName: @"u_cc3Lights[3].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle3];
	[self mapVariableName: @"u_cc3Lights[3].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine3];
	
}

-(void) populateWithPureColorSemanticMappings {
	[self mapVariableName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocations];
	[self mapVariableName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSizes];

	[self mapVariableName: @"u_cc3MtxMV" toSemantic: kCC3SemanticModelViewMatrix];
	[self mapVariableName: @"u_cc3MtxMVP" toSemantic: kCC3SemanticModelViewProjMatrix];
	[self mapVariableName: @"u_cc3Color" toSemantic: kCC3SemanticColor];
	
	// PARTICLES ------------
	[self mapVariableName: @"u_cc3Points.isDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];			// alias for u_cc3IsDrawingPoints
	[self mapVariableName: @"u_cc3Points.hasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];	// alias for u_cc3HasVertexPointSize
	[self mapVariableName: @"u_cc3Points.size" toSemantic: kCC3SemanticPointSize];
	[self mapVariableName: @"u_cc3Points.sizeAttenuation" toSemantic: kCC3SemanticPointSizeAttenuation];
	[self mapVariableName: @"u_cc3Points.minimumSize" toSemantic: kCC3SemanticPointSizeMinimum];
	[self mapVariableName: @"u_cc3Points.maximumSize" toSemantic: kCC3SemanticPointSizeMaximum];
	[self mapVariableName: @"u_cc3Points.sizeFadeThreshold" toSemantic: kCC3SemanticPointSizeFadeThreshold];
	[self mapVariableName: @"u_cc3Points.shouldDisplayAsSprites" toSemantic: kCC3SemanticPointSpritesIsEnabled];
}


#pragma mark Allocation and initialization

static CC3GLProgramSemanticsDelegateByVarNames* _sharedDefaultDelegate;

+(CC3GLProgramSemanticsDelegateByVarNames*) sharedDefaultDelegate {
	if ( !_sharedDefaultDelegate ) {
		_sharedDefaultDelegate = [CC3GLProgramSemanticsDelegateByVarNames new];		// retained
		[_sharedDefaultDelegate populateWithDefaultSemanticMappings];
	}
	return _sharedDefaultDelegate;
}

@end
	
	
