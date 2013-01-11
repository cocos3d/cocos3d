/*
 * CC3PVRShamanGLProgramSemantics.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3PVRShamanGLProgramSemantics.h for full API documentation.
 */

#import "CC3PVRShamanGLProgramSemantics.h"


NSString* NSStringFromCC3PVRShamanSemantic(CC3PVRShamanSemantic semantic) {
	switch (semantic) {
		case kCC3PVRShamanSemanticNone: return @"kCC3PVRShamanSemanticNone";
			
		case kCC3PVRShamanSemanticLightSpotFalloff: return @"kCC3PVRShamanSemanticLightSpotFalloff";
		case kCC3PVRShamanSemanticViewportSize: return @"kCC3PVRShamanSemanticViewportSize";
		case kCC3PVRShamanSemanticViewportClipping: return @"kCC3PVRShamanSemanticViewportClipping";
		case kCC3PVRShamanSemanticElapsedTimeLastFrame: return @"kCC3PVRShamanSemanticElapsedTimeLastFrame";
			
		case kCC3PVRShamanSemanticAppBase: return @"kCC3PVRShamanSemanticAppBase";
		default: return [NSString stringWithFormat: @"Unknown PVRShaman semantic (%u)", semantic];
	}
}


#pragma mark -
#pragma mark CC3PVRShamanGLProgramSemantics

@implementation CC3PVRShamanGLProgramSemantics

-(GLenum) semanticForPFXSemanticName: (NSString*) semanticName {
	return [self.class semanticForPVRShamanSemanticName: semanticName];
}

static NSMutableDictionary* _semanticsByPVRShamanSemanticName = nil;

+(GLenum) semanticForPVRShamanSemanticName: (NSString*) semanticName {
	[self ensurePVRShamanSemanticMap];
	NSNumber* semNum = [_semanticsByPVRShamanSemanticName objectForKey: semanticName];
	return semNum ? semNum.unsignedIntValue : kCC3SemanticNone;
}

+(void) addSemantic: (GLenum) semantic forPVRShamanSemanticName: (NSString*) semanticName {
	[self ensurePVRShamanSemanticMap];
	[_semanticsByPVRShamanSemanticName setObject: [NSNumber numberWithUnsignedInt: semantic]
										  forKey: semanticName];
}

+(void) ensurePVRShamanSemanticMap {
	if (_semanticsByPVRShamanSemanticName) return;

	_semanticsByPVRShamanSemanticName = [NSMutableDictionary new];		// retained
	
	[self addSemantic: kCC3SemanticVertexLocations forPVRShamanSemanticName: @"POSITION"];
	[self addSemantic: kCC3SemanticVertexNormals forPVRShamanSemanticName: @"NORMAL"];
	[self addSemantic: kCC3SemanticVertexTangents forPVRShamanSemanticName: @"TANGENT"];
	[self addSemantic: kCC3SemanticVertexBitangents forPVRShamanSemanticName: @"BINORMAL"];
	[self addSemantic: kCC3SemanticVertexTexture forPVRShamanSemanticName: @"UV"];
	[self addSemantic: kCC3SemanticVertexColors forPVRShamanSemanticName: @"VERTEXCOLOR"];
	[self addSemantic: kCC3SemanticVertexMatrices forPVRShamanSemanticName: @"BONEINDEX"];
	[self addSemantic: kCC3SemanticVertexWeights forPVRShamanSemanticName: @"BONEWEIGHT"];

	[self addSemantic: kCC3SemanticModelMatrix forPVRShamanSemanticName: @"WORLD"];
	[self addSemantic: kCC3SemanticModelMatrixInv forPVRShamanSemanticName: @"WORLDI"];
	[self addSemantic: kCC3SemanticModelMatrixInvTran forPVRShamanSemanticName: @"WORLDIT"];
	
	[self addSemantic: kCC3SemanticViewMatrix forPVRShamanSemanticName: @"VIEW"];
	[self addSemantic: kCC3SemanticViewMatrixInv forPVRShamanSemanticName: @"VIEWI"];
	[self addSemantic: kCC3SemanticViewMatrixInvTran forPVRShamanSemanticName: @"VIEWIT"];
	
	[self addSemantic: kCC3SemanticProjMatrix forPVRShamanSemanticName: @"PROJECTION"];
	[self addSemantic: kCC3SemanticProjMatrixInv forPVRShamanSemanticName: @"PROJECTIONI"];
	[self addSemantic: kCC3SemanticProjMatrixInvTran forPVRShamanSemanticName: @"PROJECTIONIT"];
	
	[self addSemantic: kCC3SemanticModelViewMatrix forPVRShamanSemanticName: @"WORLDVIEW"];
	[self addSemantic: kCC3SemanticModelViewMatrixInv forPVRShamanSemanticName: @"WORLDVIEWI"];
	[self addSemantic: kCC3SemanticModelViewMatrixInvTran forPVRShamanSemanticName: @"WORLDVIEWIT"];
	
	[self addSemantic: kCC3SemanticModelViewProjMatrix forPVRShamanSemanticName: @"WORLDVIEWPROJECTION"];
	[self addSemantic: kCC3SemanticModelViewProjMatrixInv forPVRShamanSemanticName: @"WORLDVIEWPROJECTIONI"];
	[self addSemantic: kCC3SemanticModelViewProjMatrixInvTran forPVRShamanSemanticName: @"WORLDVIEWPROJECTIONIT"];
	
	[self addSemantic: kCC3SemanticViewProjMatrix forPVRShamanSemanticName: @"VIEWPROJECTION"];
	[self addSemantic: kCC3SemanticViewProjMatrixInv forPVRShamanSemanticName: @"VIEWPROJECTIONI"];
	[self addSemantic: kCC3SemanticViewProjMatrixInvTran forPVRShamanSemanticName: @"VIEWPROJECTIONIT"];
	
	[self addSemantic: kCC3SemanticModelLocalMatrix forPVRShamanSemanticName: @"OBJECT"];
	[self addSemantic: kCC3SemanticModelLocalMatrixInv forPVRShamanSemanticName: @"OBJECTI"];
	[self addSemantic: kCC3SemanticModelLocalMatrixInvTran forPVRShamanSemanticName: @"OBJECTIT"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"UNPACKMATRIX"];
	
	[self addSemantic: kCC3SemanticMaterialOpacity forPVRShamanSemanticName: @"MATERIALOPACITY"];
	[self addSemantic: kCC3SemanticMaterialShininess forPVRShamanSemanticName: @"MATERIALSHININESS"];
	[self addSemantic: kCC3SemanticMaterialColorAmbient forPVRShamanSemanticName: @"MATERIALCOLORAMBIENT"];
	[self addSemantic: kCC3SemanticMaterialColorDiffuse forPVRShamanSemanticName: @"MATERIALCOLORDIFFUSE"];
	[self addSemantic: kCC3SemanticMaterialColorSpecular forPVRShamanSemanticName: @"MATERIALCOLORSPECULAR"];
	
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONECOUNT"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONEMATRIXARRAY"];
	[self addSemantic: kCC3SemanticNone forPVRShamanSemanticName: @"BONEMATRIXARRAYIT"];
	
	[self addSemantic: kCC3SemanticLightColorDiffuse forPVRShamanSemanticName: @"LIGHTCOLOR"];
	[self addSemantic: kCC3SemanticLightLocationModelSpace forPVRShamanSemanticName: @"LIGHTPOSMODEL"];
	[self addSemantic: kCC3SemanticLightLocationGlobal forPVRShamanSemanticName: @"LIGHTPOSWORLD"];
	[self addSemantic: kCC3SemanticLightLocationEyeSpace forPVRShamanSemanticName: @"LIGHTPOSEYE"];
	[self addSemantic: kCC3SemanticLightLocationModelSpace forPVRShamanSemanticName: @"LIGHTDIRMODEL"];
	[self addSemantic: kCC3SemanticLightLocationGlobal forPVRShamanSemanticName: @"LIGHTDIRWORLD"];
	[self addSemantic: kCC3SemanticLightLocationEyeSpace forPVRShamanSemanticName: @"LIGHTDIREYE"];
	[self addSemantic: kCC3SemanticLightAttenuation forPVRShamanSemanticName: @"LIGHTATTENUATION"];
	[self addSemantic: kCC3PVRShamanSemanticLightSpotFalloff forPVRShamanSemanticName: @"LIGHTFALLOFF"];

	[self addSemantic: kCC3SemanticCameraLocationModelSpace forPVRShamanSemanticName: @"EYEPOSMODEL"];
	[self addSemantic: kCC3SemanticCameraLocationGlobal forPVRShamanSemanticName: @"EYEPOSWORLD"];

	[self addSemantic: kCC3SemanticTextureSampler forPVRShamanSemanticName: @"TEXTURE"];
	[self addSemantic: kCC3SemanticAnimationFraction forPVRShamanSemanticName: @"ANIMATION"];
	
	[self addSemantic: kCC3SemanticDrawCountCurrentFrame forPVRShamanSemanticName: @"GEOMENTRYCOUNTER"];
	[self addSemantic: kCC3PVRShamanSemanticViewportSize forPVRShamanSemanticName: @"VIEWPORTPIXELSIZE"];
	[self addSemantic: kCC3PVRShamanSemanticViewportClipping forPVRShamanSemanticName: @"VIEWPORTCLIPPING"];
	
	[self addSemantic: kCC3SemanticElapsedTime forPVRShamanSemanticName: @"TIME"];
	[self addSemantic: kCC3SemanticElapsedTimeCosine forPVRShamanSemanticName: @"TIMECOS"];
	[self addSemantic: kCC3SemanticElapsedTimeSine forPVRShamanSemanticName: @"TIMESIN"];
	[self addSemantic: kCC3SemanticElapsedTimeTangent forPVRShamanSemanticName: @"TIMETAN"];

	[self addSemantic: kCC3SemanticElapsedTimeTwoPi forPVRShamanSemanticName: @"TIME2PI"];
	[self addSemantic: kCC3SemanticElapsedTimeTwoPiCosine forPVRShamanSemanticName: @"TIME2PICOS"];
	[self addSemantic: kCC3SemanticElapsedTimeTwoPiSine forPVRShamanSemanticName: @"TIME2PISIN"];
	[self addSemantic: kCC3SemanticElapsedTimeTwoPiTangent forPVRShamanSemanticName: @"TIME2PITAN"];

	[self addSemantic: kCC3PVRShamanSemanticElapsedTimeLastFrame forPVRShamanSemanticName: @"LASTTIME"];
	[self addSemantic: kCC3SemanticFrameTime forPVRShamanSemanticName: @"ELAPSEDTIME"];

	[self addSemantic: kCC3SemanticCenterOfGeometry forPVRShamanSemanticName: @"BOUNDINGCENTER"];
	[self addSemantic: kCC3SemanticBoundingRadius forPVRShamanSemanticName: @"BOUNDINGSPHERERADIUS"];
	[self addSemantic: kCC3SemanticBoundingBoxSize forPVRShamanSemanticName: @"BOUNDINGBOXSIZE"];
	[self addSemantic: kCC3SemanticBoundingBoxMin forPVRShamanSemanticName: @"BOUNDINGBOXMIN"];
	[self addSemantic: kCC3SemanticBoundingBoxMax forPVRShamanSemanticName: @"BOUNDINGBOXMAX"];

	[self addSemantic: kCC3SemanticRandomNumber forPVRShamanSemanticName: @"RANDOM"];
}

@end


