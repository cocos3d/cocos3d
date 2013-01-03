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
		case kCC3SemanticTextureSamplers: return @"kCC3SemanticTextureSamplers";

		case kCC3SemanticTexUnitMode0: return @"kCC3SemanticTexUnitMode0";
		case kCC3SemanticTexUnitMode1: return @"kCC3SemanticTexUnitMode1";
		case kCC3SemanticTexUnitMode2: return @"kCC3SemanticTexUnitMode2";
		case kCC3SemanticTexUnitMode3: return @"kCC3SemanticTexUnitMode3";
		case kCC3SemanticTexUnitMode4: return @"kCC3SemanticTexUnitMode4";
		case kCC3SemanticTexUnitMode5: return @"kCC3SemanticTexUnitMode5";
		case kCC3SemanticTexUnitMode6: return @"kCC3SemanticTexUnitMode6";
		case kCC3SemanticTexUnitMode7: return @"kCC3SemanticTexUnitMode7";
			
		case kCC3SemanticTexUnitConstantColor0: return @"kCC3SemanticTexUnitConstantColor0";
		case kCC3SemanticTexUnitConstantColor1: return @"kCC3SemanticTexUnitConstantColor1";
		case kCC3SemanticTexUnitConstantColor2: return @"kCC3SemanticTexUnitConstantColor2";
		case kCC3SemanticTexUnitConstantColor3: return @"kCC3SemanticTexUnitConstantColor3";
		case kCC3SemanticTexUnitConstantColor4: return @"kCC3SemanticTexUnitConstantColor4";
		case kCC3SemanticTexUnitConstantColor5: return @"kCC3SemanticTexUnitConstantColor5";
		case kCC3SemanticTexUnitConstantColor6: return @"kCC3SemanticTexUnitConstantColor6";
		case kCC3SemanticTexUnitConstantColor7: return @"kCC3SemanticTexUnitConstantColor7";
			
		case kCC3SemanticTexUnitCombineRGBFunction0: return @"kCC3SemanticTexUnitCombineRGBFunction0";
		case kCC3SemanticTexUnitCombineRGBFunction1: return @"kCC3SemanticTexUnitCombineRGBFunction1";
		case kCC3SemanticTexUnitCombineRGBFunction2: return @"kCC3SemanticTexUnitCombineRGBFunction2";
		case kCC3SemanticTexUnitCombineRGBFunction3: return @"kCC3SemanticTexUnitCombineRGBFunction3";
		case kCC3SemanticTexUnitCombineRGBFunction4: return @"kCC3SemanticTexUnitCombineRGBFunction4";
		case kCC3SemanticTexUnitCombineRGBFunction5: return @"kCC3SemanticTexUnitCombineRGBFunction5";
		case kCC3SemanticTexUnitCombineRGBFunction6: return @"kCC3SemanticTexUnitCombineRGBFunction6";
		case kCC3SemanticTexUnitCombineRGBFunction7: return @"kCC3SemanticTexUnitCombineRGBFunction7";
			
		case kCC3SemanticTexUnitSource0RGB0: return @"kCC3SemanticTexUnitSource0RGB0";
		case kCC3SemanticTexUnitSource0RGB1: return @"kCC3SemanticTexUnitSource0RGB1";
		case kCC3SemanticTexUnitSource0RGB2: return @"kCC3SemanticTexUnitSource0RGB2";
		case kCC3SemanticTexUnitSource0RGB3: return @"kCC3SemanticTexUnitSource0RGB3";
		case kCC3SemanticTexUnitSource0RGB4: return @"kCC3SemanticTexUnitSource0RGB4";
		case kCC3SemanticTexUnitSource0RGB5: return @"kCC3SemanticTexUnitSource0RGB5";
		case kCC3SemanticTexUnitSource0RGB6: return @"kCC3SemanticTexUnitSource0RGB6";
		case kCC3SemanticTexUnitSource0RGB7: return @"kCC3SemanticTexUnitSource0RGB7";
			
		case kCC3SemanticTexUnitSource1RGB0: return @"kCC3SemanticTexUnitSource1RGB0";
		case kCC3SemanticTexUnitSource1RGB1: return @"kCC3SemanticTexUnitSource1RGB1";
		case kCC3SemanticTexUnitSource1RGB2: return @"kCC3SemanticTexUnitSource1RGB2";
		case kCC3SemanticTexUnitSource1RGB3: return @"kCC3SemanticTexUnitSource1RGB3";
		case kCC3SemanticTexUnitSource1RGB4: return @"kCC3SemanticTexUnitSource1RGB4";
		case kCC3SemanticTexUnitSource1RGB5: return @"kCC3SemanticTexUnitSource1RGB5";
		case kCC3SemanticTexUnitSource1RGB6: return @"kCC3SemanticTexUnitSource1RGB6";
		case kCC3SemanticTexUnitSource1RGB7: return @"kCC3SemanticTexUnitSource1RGB7";
			
		case kCC3SemanticTexUnitSource2RGB0: return @"kCC3SemanticTexUnitSource2RGB0";
		case kCC3SemanticTexUnitSource2RGB1: return @"kCC3SemanticTexUnitSource2RGB1";
		case kCC3SemanticTexUnitSource2RGB2: return @"kCC3SemanticTexUnitSource2RGB2";
		case kCC3SemanticTexUnitSource2RGB3: return @"kCC3SemanticTexUnitSource2RGB3";
		case kCC3SemanticTexUnitSource2RGB4: return @"kCC3SemanticTexUnitSource2RGB4";
		case kCC3SemanticTexUnitSource2RGB5: return @"kCC3SemanticTexUnitSource2RGB5";
		case kCC3SemanticTexUnitSource2RGB6: return @"kCC3SemanticTexUnitSource2RGB6";
		case kCC3SemanticTexUnitSource2RGB7: return @"kCC3SemanticTexUnitSource2RGB7";
			
		case kCC3SemanticTexUnitOperand0RGB0: return @"kCC3SemanticTexUnitOperand0RGB0";
		case kCC3SemanticTexUnitOperand0RGB1: return @"kCC3SemanticTexUnitOperand0RGB1";
		case kCC3SemanticTexUnitOperand0RGB2: return @"kCC3SemanticTexUnitOperand0RGB2";
		case kCC3SemanticTexUnitOperand0RGB3: return @"kCC3SemanticTexUnitOperand0RGB3";
		case kCC3SemanticTexUnitOperand0RGB4: return @"kCC3SemanticTexUnitOperand0RGB4";
		case kCC3SemanticTexUnitOperand0RGB5: return @"kCC3SemanticTexUnitOperand0RGB5";
		case kCC3SemanticTexUnitOperand0RGB6: return @"kCC3SemanticTexUnitOperand0RGB6";
		case kCC3SemanticTexUnitOperand0RGB7: return @"kCC3SemanticTexUnitOperand0RGB7";
			
		case kCC3SemanticTexUnitOperand1RGB0: return @"kCC3SemanticTexUnitOperand1RGB0";
		case kCC3SemanticTexUnitOperand1RGB1: return @"kCC3SemanticTexUnitOperand1RGB1";
		case kCC3SemanticTexUnitOperand1RGB2: return @"kCC3SemanticTexUnitOperand1RGB2";
		case kCC3SemanticTexUnitOperand1RGB3: return @"kCC3SemanticTexUnitOperand1RGB3";
		case kCC3SemanticTexUnitOperand1RGB4: return @"kCC3SemanticTexUnitOperand1RGB4";
		case kCC3SemanticTexUnitOperand1RGB5: return @"kCC3SemanticTexUnitOperand1RGB5";
		case kCC3SemanticTexUnitOperand1RGB6: return @"kCC3SemanticTexUnitOperand1RGB6";
		case kCC3SemanticTexUnitOperand1RGB7: return @"kCC3SemanticTexUnitOperand1RGB7";
			
		case kCC3SemanticTexUnitOperand2RGB0: return @"kCC3SemanticTexUnitOperand2RGB0";
		case kCC3SemanticTexUnitOperand2RGB1: return @"kCC3SemanticTexUnitOperand2RGB1";
		case kCC3SemanticTexUnitOperand2RGB2: return @"kCC3SemanticTexUnitOperand2RGB2";
		case kCC3SemanticTexUnitOperand2RGB3: return @"kCC3SemanticTexUnitOperand2RGB3";
		case kCC3SemanticTexUnitOperand2RGB4: return @"kCC3SemanticTexUnitOperand2RGB4";
		case kCC3SemanticTexUnitOperand2RGB5: return @"kCC3SemanticTexUnitOperand2RGB5";
		case kCC3SemanticTexUnitOperand2RGB6: return @"kCC3SemanticTexUnitOperand2RGB6";
		case kCC3SemanticTexUnitOperand2RGB7: return @"kCC3SemanticTexUnitOperand2RGB7";
			
		case kCC3SemanticTexUnitCombineAlphaFunction0: return @"kCC3SemanticTexUnitCombineAlphaFunction0";
		case kCC3SemanticTexUnitCombineAlphaFunction1: return @"kCC3SemanticTexUnitCombineAlphaFunction1";
		case kCC3SemanticTexUnitCombineAlphaFunction2: return @"kCC3SemanticTexUnitCombineAlphaFunction2";
		case kCC3SemanticTexUnitCombineAlphaFunction3: return @"kCC3SemanticTexUnitCombineAlphaFunction3";
		case kCC3SemanticTexUnitCombineAlphaFunction4: return @"kCC3SemanticTexUnitCombineAlphaFunction4";
		case kCC3SemanticTexUnitCombineAlphaFunction5: return @"kCC3SemanticTexUnitCombineAlphaFunction5";
		case kCC3SemanticTexUnitCombineAlphaFunction6: return @"kCC3SemanticTexUnitCombineAlphaFunction6";
		case kCC3SemanticTexUnitCombineAlphaFunction7: return @"kCC3SemanticTexUnitCombineAlphaFunction7";
			
		case kCC3SemanticTexUnitSource0Alpha0: return @"kCC3SemanticTexUnitSource0Alpha0";
		case kCC3SemanticTexUnitSource0Alpha1: return @"kCC3SemanticTexUnitSource0Alpha1";
		case kCC3SemanticTexUnitSource0Alpha2: return @"kCC3SemanticTexUnitSource0Alpha2";
		case kCC3SemanticTexUnitSource0Alpha3: return @"kCC3SemanticTexUnitSource0Alpha3";
		case kCC3SemanticTexUnitSource0Alpha4: return @"kCC3SemanticTexUnitSource0Alpha4";
		case kCC3SemanticTexUnitSource0Alpha5: return @"kCC3SemanticTexUnitSource0Alpha5";
		case kCC3SemanticTexUnitSource0Alpha6: return @"kCC3SemanticTexUnitSource0Alpha6";
		case kCC3SemanticTexUnitSource0Alpha7: return @"kCC3SemanticTexUnitSource0Alpha7";
			
		case kCC3SemanticTexUnitSource1Alpha0: return @"kCC3SemanticTexUnitSource1Alpha0";
		case kCC3SemanticTexUnitSource1Alpha1: return @"kCC3SemanticTexUnitSource1Alpha1";
		case kCC3SemanticTexUnitSource1Alpha2: return @"kCC3SemanticTexUnitSource1Alpha2";
		case kCC3SemanticTexUnitSource1Alpha3: return @"kCC3SemanticTexUnitSource1Alpha3";
		case kCC3SemanticTexUnitSource1Alpha4: return @"kCC3SemanticTexUnitSource1Alpha4";
		case kCC3SemanticTexUnitSource1Alpha5: return @"kCC3SemanticTexUnitSource1Alpha5";
		case kCC3SemanticTexUnitSource1Alpha6: return @"kCC3SemanticTexUnitSource1Alpha6";
		case kCC3SemanticTexUnitSource1Alpha7: return @"kCC3SemanticTexUnitSource1Alpha7";
			
		case kCC3SemanticTexUnitSource2Alpha0: return @"kCC3SemanticTexUnitSource2Alpha0";
		case kCC3SemanticTexUnitSource2Alpha1: return @"kCC3SemanticTexUnitSource2Alpha1";
		case kCC3SemanticTexUnitSource2Alpha2: return @"kCC3SemanticTexUnitSource2Alpha2";
		case kCC3SemanticTexUnitSource2Alpha3: return @"kCC3SemanticTexUnitSource2Alpha3";
		case kCC3SemanticTexUnitSource2Alpha4: return @"kCC3SemanticTexUnitSource2Alpha4";
		case kCC3SemanticTexUnitSource2Alpha5: return @"kCC3SemanticTexUnitSource2Alpha5";
		case kCC3SemanticTexUnitSource2Alpha6: return @"kCC3SemanticTexUnitSource2Alpha6";
		case kCC3SemanticTexUnitSource2Alpha7: return @"kCC3SemanticTexUnitSource2Alpha7";
			
		case kCC3SemanticTexUnitOperand0Alpha0: return @"kCC3SemanticTexUnitOperand0Alpha0";
		case kCC3SemanticTexUnitOperand0Alpha1: return @"kCC3SemanticTexUnitOperand0Alpha1";
		case kCC3SemanticTexUnitOperand0Alpha2: return @"kCC3SemanticTexUnitOperand0Alpha2";
		case kCC3SemanticTexUnitOperand0Alpha3: return @"kCC3SemanticTexUnitOperand0Alpha3";
		case kCC3SemanticTexUnitOperand0Alpha4: return @"kCC3SemanticTexUnitOperand0Alpha4";
		case kCC3SemanticTexUnitOperand0Alpha5: return @"kCC3SemanticTexUnitOperand0Alpha5";
		case kCC3SemanticTexUnitOperand0Alpha6: return @"kCC3SemanticTexUnitOperand0Alpha6";
		case kCC3SemanticTexUnitOperand0Alpha7: return @"kCC3SemanticTexUnitOperand0Alpha7";
			
		case kCC3SemanticTexUnitOperand1Alpha0: return @"kCC3SemanticTexUnitOperand1Alpha0";
		case kCC3SemanticTexUnitOperand1Alpha1: return @"kCC3SemanticTexUnitOperand1Alpha1";
		case kCC3SemanticTexUnitOperand1Alpha2: return @"kCC3SemanticTexUnitOperand1Alpha2";
		case kCC3SemanticTexUnitOperand1Alpha3: return @"kCC3SemanticTexUnitOperand1Alpha3";
		case kCC3SemanticTexUnitOperand1Alpha4: return @"kCC3SemanticTexUnitOperand1Alpha4";
		case kCC3SemanticTexUnitOperand1Alpha5: return @"kCC3SemanticTexUnitOperand1Alpha5";
		case kCC3SemanticTexUnitOperand1Alpha6: return @"kCC3SemanticTexUnitOperand1Alpha6";
		case kCC3SemanticTexUnitOperand1Alpha7: return @"kCC3SemanticTexUnitOperand1Alpha7";
			
		case kCC3SemanticTexUnitOperand2Alpha0: return @"kCC3SemanticTexUnitOperand2Alpha0";
		case kCC3SemanticTexUnitOperand2Alpha1: return @"kCC3SemanticTexUnitOperand2Alpha1";
		case kCC3SemanticTexUnitOperand2Alpha2: return @"kCC3SemanticTexUnitOperand2Alpha2";
		case kCC3SemanticTexUnitOperand2Alpha3: return @"kCC3SemanticTexUnitOperand2Alpha3";
		case kCC3SemanticTexUnitOperand2Alpha4: return @"kCC3SemanticTexUnitOperand2Alpha4";
		case kCC3SemanticTexUnitOperand2Alpha5: return @"kCC3SemanticTexUnitOperand2Alpha5";
		case kCC3SemanticTexUnitOperand2Alpha6: return @"kCC3SemanticTexUnitOperand2Alpha6";
		case kCC3SemanticTexUnitOperand2Alpha7: return @"kCC3SemanticTexUnitOperand2Alpha7";

			
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
	LogTrace(@"Retrieving semantic value for %@", uniform.fullDescription);
	CC3OpenGLESLight* glesLight;
	CC3OpenGLESTextureUnit* glesTexUnit;
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
		case kCC3SemanticMinimumDrawnAlpha:
			[uniform setFloat: (CC3OpenGLESEngine.engine.capabilities.alphaTest.value
									? CC3OpenGLESEngine.engine.materials.alphaFunc.reference.value
									: 0.0f)];
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

		case kCC3SemanticTextureSamplers:
			// Samplers are simply consecutive texture unit indices
			[uniform setIntegers: (int[]){0, 1, 2, 3, 4, 5, 6, 7}];
			return YES;

		// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
		// In most shaders, these will be left unused in favor of customized the texture combining in code.
		case kCC3SemanticTexUnitMode0:
		case kCC3SemanticTexUnitMode1:
		case kCC3SemanticTexUnitMode2:
		case kCC3SemanticTexUnitMode3:
		case kCC3SemanticTexUnitMode4:
		case kCC3SemanticTexUnitMode5:
		case kCC3SemanticTexUnitMode6:
		case kCC3SemanticTexUnitMode7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitMode0)];
			[uniform setInteger: glesTexUnit.textureEnvironmentMode.value];
			return YES;
			
		case kCC3SemanticTexUnitConstantColor0:
		case kCC3SemanticTexUnitConstantColor1:
		case kCC3SemanticTexUnitConstantColor2:
		case kCC3SemanticTexUnitConstantColor3:
		case kCC3SemanticTexUnitConstantColor4:
		case kCC3SemanticTexUnitConstantColor5:
		case kCC3SemanticTexUnitConstantColor6:
		case kCC3SemanticTexUnitConstantColor7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitConstantColor0)];
			[uniform setColor4F: glesTexUnit.color.value];
			return YES;

		case kCC3SemanticTexUnitCombineRGBFunction0:
		case kCC3SemanticTexUnitCombineRGBFunction1:
		case kCC3SemanticTexUnitCombineRGBFunction2:
		case kCC3SemanticTexUnitCombineRGBFunction3:
		case kCC3SemanticTexUnitCombineRGBFunction4:
		case kCC3SemanticTexUnitCombineRGBFunction5:
		case kCC3SemanticTexUnitCombineRGBFunction6:
		case kCC3SemanticTexUnitCombineRGBFunction7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitCombineRGBFunction0)];
			[uniform setInteger: glesTexUnit.combineRGBFunction.value];
			return YES;
			
		case kCC3SemanticTexUnitSource0RGB0:
		case kCC3SemanticTexUnitSource0RGB1:
		case kCC3SemanticTexUnitSource0RGB2:
		case kCC3SemanticTexUnitSource0RGB3:
		case kCC3SemanticTexUnitSource0RGB4:
		case kCC3SemanticTexUnitSource0RGB5:
		case kCC3SemanticTexUnitSource0RGB6:
		case kCC3SemanticTexUnitSource0RGB7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitSource0RGB0)];
			[uniform setInteger: glesTexUnit.rgbSource0.value];
			return YES;
			
		case kCC3SemanticTexUnitSource1RGB0:
		case kCC3SemanticTexUnitSource1RGB1:
		case kCC3SemanticTexUnitSource1RGB2:
		case kCC3SemanticTexUnitSource1RGB3:
		case kCC3SemanticTexUnitSource1RGB4:
		case kCC3SemanticTexUnitSource1RGB5:
		case kCC3SemanticTexUnitSource1RGB6:
		case kCC3SemanticTexUnitSource1RGB7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitSource1RGB0)];
			[uniform setInteger: glesTexUnit.rgbSource1.value];
			return YES;
			
		case kCC3SemanticTexUnitSource2RGB0:
		case kCC3SemanticTexUnitSource2RGB1:
		case kCC3SemanticTexUnitSource2RGB2:
		case kCC3SemanticTexUnitSource2RGB3:
		case kCC3SemanticTexUnitSource2RGB4:
		case kCC3SemanticTexUnitSource2RGB5:
		case kCC3SemanticTexUnitSource2RGB6:
		case kCC3SemanticTexUnitSource2RGB7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitSource2RGB0)];
			[uniform setInteger: glesTexUnit.rgbSource2.value];
			return YES;
			
		case kCC3SemanticTexUnitOperand0RGB0:
		case kCC3SemanticTexUnitOperand0RGB1:
		case kCC3SemanticTexUnitOperand0RGB2:
		case kCC3SemanticTexUnitOperand0RGB3:
		case kCC3SemanticTexUnitOperand0RGB4:
		case kCC3SemanticTexUnitOperand0RGB5:
		case kCC3SemanticTexUnitOperand0RGB6:
		case kCC3SemanticTexUnitOperand0RGB7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitOperand0RGB0)];
			[uniform setInteger: glesTexUnit.rgbOperand0.value];
			return YES;
			
		case kCC3SemanticTexUnitOperand1RGB0:
		case kCC3SemanticTexUnitOperand1RGB1:
		case kCC3SemanticTexUnitOperand1RGB2:
		case kCC3SemanticTexUnitOperand1RGB3:
		case kCC3SemanticTexUnitOperand1RGB4:
		case kCC3SemanticTexUnitOperand1RGB5:
		case kCC3SemanticTexUnitOperand1RGB6:
		case kCC3SemanticTexUnitOperand1RGB7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitOperand1RGB0)];
			[uniform setInteger: glesTexUnit.rgbOperand1.value];
			return YES;
			
		case kCC3SemanticTexUnitOperand2RGB0:
		case kCC3SemanticTexUnitOperand2RGB1:
		case kCC3SemanticTexUnitOperand2RGB2:
		case kCC3SemanticTexUnitOperand2RGB3:
		case kCC3SemanticTexUnitOperand2RGB4:
		case kCC3SemanticTexUnitOperand2RGB5:
		case kCC3SemanticTexUnitOperand2RGB6:
		case kCC3SemanticTexUnitOperand2RGB7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitOperand2RGB0)];
			[uniform setInteger: glesTexUnit.rgbOperand2.value];
			return YES;
			
		case kCC3SemanticTexUnitCombineAlphaFunction0:
		case kCC3SemanticTexUnitCombineAlphaFunction1:
		case kCC3SemanticTexUnitCombineAlphaFunction2:
		case kCC3SemanticTexUnitCombineAlphaFunction3:
		case kCC3SemanticTexUnitCombineAlphaFunction4:
		case kCC3SemanticTexUnitCombineAlphaFunction5:
		case kCC3SemanticTexUnitCombineAlphaFunction6:
		case kCC3SemanticTexUnitCombineAlphaFunction7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitCombineAlphaFunction0)];
			[uniform setInteger: glesTexUnit.combineAlphaFunction.value];
			return YES;
			
		case kCC3SemanticTexUnitSource0Alpha0:
		case kCC3SemanticTexUnitSource0Alpha1:
		case kCC3SemanticTexUnitSource0Alpha2:
		case kCC3SemanticTexUnitSource0Alpha3:
		case kCC3SemanticTexUnitSource0Alpha4:
		case kCC3SemanticTexUnitSource0Alpha5:
		case kCC3SemanticTexUnitSource0Alpha6:
		case kCC3SemanticTexUnitSource0Alpha7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitSource0Alpha0)];
			[uniform setInteger: glesTexUnit.alphaSource0.value];
			return YES;
			
		case kCC3SemanticTexUnitSource1Alpha0:
		case kCC3SemanticTexUnitSource1Alpha1:
		case kCC3SemanticTexUnitSource1Alpha2:
		case kCC3SemanticTexUnitSource1Alpha3:
		case kCC3SemanticTexUnitSource1Alpha4:
		case kCC3SemanticTexUnitSource1Alpha5:
		case kCC3SemanticTexUnitSource1Alpha6:
		case kCC3SemanticTexUnitSource1Alpha7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitSource1Alpha0)];
			[uniform setInteger: glesTexUnit.alphaSource1.value];
			return YES;
			
		case kCC3SemanticTexUnitSource2Alpha0:
		case kCC3SemanticTexUnitSource2Alpha1:
		case kCC3SemanticTexUnitSource2Alpha2:
		case kCC3SemanticTexUnitSource2Alpha3:
		case kCC3SemanticTexUnitSource2Alpha4:
		case kCC3SemanticTexUnitSource2Alpha5:
		case kCC3SemanticTexUnitSource2Alpha6:
		case kCC3SemanticTexUnitSource2Alpha7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitSource2Alpha0)];
			[uniform setInteger: glesTexUnit.alphaSource2.value];
			return YES;
			
		case kCC3SemanticTexUnitOperand0Alpha0:
		case kCC3SemanticTexUnitOperand0Alpha1:
		case kCC3SemanticTexUnitOperand0Alpha2:
		case kCC3SemanticTexUnitOperand0Alpha3:
		case kCC3SemanticTexUnitOperand0Alpha4:
		case kCC3SemanticTexUnitOperand0Alpha5:
		case kCC3SemanticTexUnitOperand0Alpha6:
		case kCC3SemanticTexUnitOperand0Alpha7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitOperand0Alpha0)];
			[uniform setInteger: glesTexUnit.alphaOperand0.value];
			return YES;
			
		case kCC3SemanticTexUnitOperand1Alpha0:
		case kCC3SemanticTexUnitOperand1Alpha1:
		case kCC3SemanticTexUnitOperand1Alpha2:
		case kCC3SemanticTexUnitOperand1Alpha3:
		case kCC3SemanticTexUnitOperand1Alpha4:
		case kCC3SemanticTexUnitOperand1Alpha5:
		case kCC3SemanticTexUnitOperand1Alpha6:
		case kCC3SemanticTexUnitOperand1Alpha7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitOperand1Alpha0)];
			[uniform setInteger: glesTexUnit.alphaOperand1.value];
			return YES;
			
		case kCC3SemanticTexUnitOperand2Alpha0:
		case kCC3SemanticTexUnitOperand2Alpha1:
		case kCC3SemanticTexUnitOperand2Alpha2:
		case kCC3SemanticTexUnitOperand2Alpha3:
		case kCC3SemanticTexUnitOperand2Alpha4:
		case kCC3SemanticTexUnitOperand2Alpha5:
		case kCC3SemanticTexUnitOperand2Alpha6:
		case kCC3SemanticTexUnitOperand2Alpha7:
			glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semantic - kCC3SemanticTexUnitOperand2Alpha0)];
			[uniform setInteger: glesTexUnit.alphaOperand2.value];
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
		case kCC3SemanticPointSpritesIsEnabled: {
			[uniform setBoolean: CC3OpenGLESEngine.engine.capabilities.pointSprites.value];
			return YES;
		}
			
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

-(void) populateWithDefaultVariableNameMappings {

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
	[self mapVariableName: @"u_cc3Material.ambientColor" toSemantic: kCC3SemanticMaterialColorAmbient];
	[self mapVariableName: @"u_cc3Material.diffuseColor" toSemantic: kCC3SemanticMaterialColorDiffuse];
	[self mapVariableName: @"u_cc3Material.specularColor" toSemantic: kCC3SemanticMaterialColorSpecular];
	[self mapVariableName: @"u_cc3Material.emissionColor" toSemantic: kCC3SemanticMaterialColorEmission];
	[self mapVariableName: @"u_cc3Material.shininess" toSemantic: kCC3SemanticMaterialShininess];
	[self mapVariableName: @"u_cc3Material.minimumDrawnAlpha" toSemantic: kCC3SemanticMinimumDrawnAlpha];

	// LIGHTING --------------
	[self mapVariableName: @"u_cc3IsUsingLighting" toSemantic: kCC3SemanticIsUsingLighting];
	[self mapVariableName: @"u_cc3SceneLightColorAmbient" toSemantic: kCC3SemanticSceneLightColorAmbient];
	
	[self mapVariableName: @"u_cc3Light.isEnabled" toSemantic: kCC3SemanticLightIsEnabled0];		// Aliases for light zero
	[self mapVariableName: @"u_cc3Light.position" toSemantic: kCC3SemanticLightPosition0];
	[self mapVariableName: @"u_cc3Light.ambientColor" toSemantic: kCC3SemanticLightColorAmbient0];
	[self mapVariableName: @"u_cc3Light.diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse0];
	[self mapVariableName: @"u_cc3Light.specularColor" toSemantic: kCC3SemanticLightColorSpecular0];
	[self mapVariableName: @"u_cc3Light.attenuation" toSemantic: kCC3SemanticLightAttenuation0];
	[self mapVariableName: @"u_cc3Light.spotDirection" toSemantic: kCC3SemanticLightSpotDirection0];
	[self mapVariableName: @"u_cc3Light.spotExponent" toSemantic: kCC3SemanticLightSpotExponent0];
	[self mapVariableName: @"u_cc3Light.spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle0];
	[self mapVariableName: @"u_cc3Light.spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine0];
	
	[self mapVariableName: @"u_cc3Lights[0].isEnabled" toSemantic: kCC3SemanticLightIsEnabled0];
	[self mapVariableName: @"u_cc3Lights[0].position" toSemantic: kCC3SemanticLightPosition0];
	[self mapVariableName: @"u_cc3Lights[0].ambientColor" toSemantic: kCC3SemanticLightColorAmbient0];
	[self mapVariableName: @"u_cc3Lights[0].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse0];
	[self mapVariableName: @"u_cc3Lights[0].specularColor" toSemantic: kCC3SemanticLightColorSpecular0];
	[self mapVariableName: @"u_cc3Lights[0].attenuation" toSemantic: kCC3SemanticLightAttenuation0];
	[self mapVariableName: @"u_cc3Lights[0].spotDirection" toSemantic: kCC3SemanticLightSpotDirection0];
	[self mapVariableName: @"u_cc3Lights[0].spotExponent" toSemantic: kCC3SemanticLightSpotExponent0];
	[self mapVariableName: @"u_cc3Lights[0].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle0];
	[self mapVariableName: @"u_cc3Lights[0].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine0];
	
	[self mapVariableName: @"u_cc3Lights[1].isEnabled" toSemantic: kCC3SemanticLightIsEnabled1];
	[self mapVariableName: @"u_cc3Lights[1].position" toSemantic: kCC3SemanticLightPosition1];
	[self mapVariableName: @"u_cc3Lights[1].ambientColor" toSemantic: kCC3SemanticLightColorAmbient1];
	[self mapVariableName: @"u_cc3Lights[1].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse1];
	[self mapVariableName: @"u_cc3Lights[1].specularColor" toSemantic: kCC3SemanticLightColorSpecular1];
	[self mapVariableName: @"u_cc3Lights[1].attenuation" toSemantic: kCC3SemanticLightAttenuation1];
	[self mapVariableName: @"u_cc3Lights[1].spotDirection" toSemantic: kCC3SemanticLightSpotDirection1];
	[self mapVariableName: @"u_cc3Lights[1].spotExponent" toSemantic: kCC3SemanticLightSpotExponent1];
	[self mapVariableName: @"u_cc3Lights[1].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle1];
	[self mapVariableName: @"u_cc3Lights[1].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine1];
	
	[self mapVariableName: @"u_cc3Lights[2].isEnabled" toSemantic: kCC3SemanticLightIsEnabled2];
	[self mapVariableName: @"u_cc3Lights[2].position" toSemantic: kCC3SemanticLightPosition2];
	[self mapVariableName: @"u_cc3Lights[2].ambientColor" toSemantic: kCC3SemanticLightColorAmbient2];
	[self mapVariableName: @"u_cc3Lights[2].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse2];
	[self mapVariableName: @"u_cc3Lights[2].specularColor" toSemantic: kCC3SemanticLightColorSpecular2];
	[self mapVariableName: @"u_cc3Lights[2].attenuation" toSemantic: kCC3SemanticLightAttenuation2];
	[self mapVariableName: @"u_cc3Lights[2].spotDirection" toSemantic: kCC3SemanticLightSpotDirection2];
	[self mapVariableName: @"u_cc3Lights[2].spotExponent" toSemantic: kCC3SemanticLightSpotExponent2];
	[self mapVariableName: @"u_cc3Lights[2].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle2];
	[self mapVariableName: @"u_cc3Lights[2].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine2];
	
	[self mapVariableName: @"u_cc3Lights[3].isEnabled" toSemantic: kCC3SemanticLightIsEnabled3];
	[self mapVariableName: @"u_cc3Lights[3].position" toSemantic: kCC3SemanticLightPosition3];
	[self mapVariableName: @"u_cc3Lights[3].ambientColor" toSemantic: kCC3SemanticLightColorAmbient3];
	[self mapVariableName: @"u_cc3Lights[3].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse3];
	[self mapVariableName: @"u_cc3Lights[3].specularColor" toSemantic: kCC3SemanticLightColorSpecular3];
	[self mapVariableName: @"u_cc3Lights[3].attenuation" toSemantic: kCC3SemanticLightAttenuation3];
	[self mapVariableName: @"u_cc3Lights[3].spotDirection" toSemantic: kCC3SemanticLightSpotDirection3];
	[self mapVariableName: @"u_cc3Lights[3].spotExponent" toSemantic: kCC3SemanticLightSpotExponent3];
	[self mapVariableName: @"u_cc3Lights[3].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle3];
	[self mapVariableName: @"u_cc3Lights[3].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine3];
	
	// TEXTURES --------------
	[self mapVariableName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];
	[self mapVariableName: @"s_cc3Textures" toSemantic: kCC3SemanticTextureSamplers];		// alias for s_cc3Textures[0]
	[self mapVariableName: @"s_cc3Textures[0]" toSemantic: kCC3SemanticTextureSamplers];	// alias for s_cc3Textures
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in code.
	[self mapVariableName: @"u_cc3TextureUnits[0].color" toSemantic: kCC3SemanticTexUnitConstantColor0];
	[self mapVariableName: @"u_cc3TextureUnits[0].mode" toSemantic: kCC3SemanticTexUnitMode0];
	[self mapVariableName: @"u_cc3TextureUnits[0].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction0];
	[self mapVariableName: @"u_cc3TextureUnits[0].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB0];
	[self mapVariableName: @"u_cc3TextureUnits[0].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB0];
	[self mapVariableName: @"u_cc3TextureUnits[0].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB0];
	[self mapVariableName: @"u_cc3TextureUnits[0].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB0];
	[self mapVariableName: @"u_cc3TextureUnits[0].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB0];
	[self mapVariableName: @"u_cc3TextureUnits[0].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB0];
	[self mapVariableName: @"u_cc3TextureUnits[0].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction0];
	[self mapVariableName: @"u_cc3TextureUnits[0].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha0];
	[self mapVariableName: @"u_cc3TextureUnits[0].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha0];
	[self mapVariableName: @"u_cc3TextureUnits[0].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha0];
	[self mapVariableName: @"u_cc3TextureUnits[0].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha0];
	[self mapVariableName: @"u_cc3TextureUnits[0].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha0];
	[self mapVariableName: @"u_cc3TextureUnits[0].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha0];
	
	[self mapVariableName: @"u_cc3TextureUnits[1].color" toSemantic: kCC3SemanticTexUnitConstantColor1];
	[self mapVariableName: @"u_cc3TextureUnits[1].mode" toSemantic: kCC3SemanticTexUnitMode1];
	[self mapVariableName: @"u_cc3TextureUnits[1].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction1];
	[self mapVariableName: @"u_cc3TextureUnits[1].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB1];
	[self mapVariableName: @"u_cc3TextureUnits[1].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB1];
	[self mapVariableName: @"u_cc3TextureUnits[1].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB1];
	[self mapVariableName: @"u_cc3TextureUnits[1].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB1];
	[self mapVariableName: @"u_cc3TextureUnits[1].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB1];
	[self mapVariableName: @"u_cc3TextureUnits[1].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB1];
	[self mapVariableName: @"u_cc3TextureUnits[1].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction1];
	[self mapVariableName: @"u_cc3TextureUnits[1].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha1];
	[self mapVariableName: @"u_cc3TextureUnits[1].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha1];
	[self mapVariableName: @"u_cc3TextureUnits[1].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha1];
	[self mapVariableName: @"u_cc3TextureUnits[1].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha1];
	[self mapVariableName: @"u_cc3TextureUnits[1].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha1];
	[self mapVariableName: @"u_cc3TextureUnits[1].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha1];
	
	[self mapVariableName: @"u_cc3TextureUnits[2].color" toSemantic: kCC3SemanticTexUnitConstantColor2];
	[self mapVariableName: @"u_cc3TextureUnits[2].mode" toSemantic: kCC3SemanticTexUnitMode2];
	[self mapVariableName: @"u_cc3TextureUnits[2].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction2];
	[self mapVariableName: @"u_cc3TextureUnits[2].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB2];
	[self mapVariableName: @"u_cc3TextureUnits[2].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB2];
	[self mapVariableName: @"u_cc3TextureUnits[2].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB2];
	[self mapVariableName: @"u_cc3TextureUnits[2].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB2];
	[self mapVariableName: @"u_cc3TextureUnits[2].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB2];
	[self mapVariableName: @"u_cc3TextureUnits[2].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB2];
	[self mapVariableName: @"u_cc3TextureUnits[2].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction2];
	[self mapVariableName: @"u_cc3TextureUnits[2].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha2];
	[self mapVariableName: @"u_cc3TextureUnits[2].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha2];
	[self mapVariableName: @"u_cc3TextureUnits[2].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha2];
	[self mapVariableName: @"u_cc3TextureUnits[2].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha2];
	[self mapVariableName: @"u_cc3TextureUnits[2].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha2];
	[self mapVariableName: @"u_cc3TextureUnits[2].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha2];
	
	[self mapVariableName: @"u_cc3TextureUnits[3].color" toSemantic: kCC3SemanticTexUnitConstantColor3];
	[self mapVariableName: @"u_cc3TextureUnits[3].mode" toSemantic: kCC3SemanticTexUnitMode3];
	[self mapVariableName: @"u_cc3TextureUnits[3].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction3];
	[self mapVariableName: @"u_cc3TextureUnits[3].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB3];
	[self mapVariableName: @"u_cc3TextureUnits[3].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB3];
	[self mapVariableName: @"u_cc3TextureUnits[3].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB3];
	[self mapVariableName: @"u_cc3TextureUnits[3].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB3];
	[self mapVariableName: @"u_cc3TextureUnits[3].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB3];
	[self mapVariableName: @"u_cc3TextureUnits[3].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB3];
	[self mapVariableName: @"u_cc3TextureUnits[3].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction3];
	[self mapVariableName: @"u_cc3TextureUnits[3].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha3];
	[self mapVariableName: @"u_cc3TextureUnits[3].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha3];
	[self mapVariableName: @"u_cc3TextureUnits[3].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha3];
	[self mapVariableName: @"u_cc3TextureUnits[3].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha3];
	[self mapVariableName: @"u_cc3TextureUnits[3].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha3];
	[self mapVariableName: @"u_cc3TextureUnits[3].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha3];
	
	// Applications can add more mappings for shaders that support additional texture units
}


#pragma mark Allocation and initialization

static CC3GLProgramSemanticsDelegateByVarNames* _sharedDefaultDelegate;

+(CC3GLProgramSemanticsDelegateByVarNames*) sharedDefaultDelegate {
	if ( !_sharedDefaultDelegate ) {
		_sharedDefaultDelegate = [CC3GLProgramSemanticsDelegateByVarNames new];		// retained
		[_sharedDefaultDelegate populateWithDefaultVariableNameMappings];
	}
	return _sharedDefaultDelegate;
}

@end
	
	
