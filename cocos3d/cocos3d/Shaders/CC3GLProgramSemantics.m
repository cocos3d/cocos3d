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

		case kCC3SemanticLightIsEnabled: return @"kCC3SemanticLightIsEnabled";
		case kCC3SemanticLightPosition: return @"kCC3SemanticLightPosition";
		case kCC3SemanticLightColorAmbient: return @"kCC3SemanticLightColorAmbient";
		case kCC3SemanticLightColorDiffuse: return @"kCC3SemanticLightColorDiffuse";
		case kCC3SemanticLightColorSpecular: return @"kCC3SemanticLightColorSpecular";
		case kCC3SemanticLightAttenuation: return @"kCC3SemanticLightAttenuation";
		case kCC3SemanticLightSpotDirection: return @"kCC3SemanticLightSpotDirection";
		case kCC3SemanticLightSpotExponent: return @"kCC3SemanticLightSpotExponent";
		case kCC3SemanticLightSpotCutoffAngle: return @"kCC3SemanticLightSpotCutoffAngle";
		case kCC3SemanticLightSpotCutoffAngleCosine: return @"kCC3SemanticLightSpotCutoffAngleCosine";
			
		// TEXTURES --------------
		case kCC3SemanticTextureCount: return @"kCC3SemanticTextureCount";
		case kCC3SemanticTextureSamplers: return @"kCC3SemanticTextureSamplers";

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

@synthesize name=_name, semantic=_semantic, semanticIndex=_semanticIndex;

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
	CC3OpenGLESLight* glesLight;
	CC3OpenGLESTextureUnit* glesTexUnit;
	GLenum semantic = uniform.semantic;
	GLuint semanticIndex = uniform.semanticIndex;
	GLint uniformSize = uniform.size;
	
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
			[uniform setMatrix4x4: &mtx];
			return YES;
		}
		case kCC3SemanticModelMatrixInv: {
			CC3Matrix4x4 mtx;
			[visitor.currentMeshNode.transformMatrixInverted populateCC3Matrix4x4: &mtx];
			[uniform setMatrix4x4: &mtx];
			return YES;
		}
		case kCC3SemanticModelViewMatrix: {
			[uniform setMatrix4x4: CC3OpenGLESEngine.engine.matrices.modelViewMatrix];
			return YES;
		}
		case kCC3SemanticModelViewMatrixInvTran:
			[uniform setMatrix3x3: CC3OpenGLESEngine.engine.matrices.modelViewInverseTransposeMatrix];
			return YES;
		case kCC3SemanticModelViewProjMatrix:
			[uniform setMatrix4x4: CC3OpenGLESEngine.engine.matrices.modelViewProjectionMatrix];
			return YES;
			
		// CAMERA -----------------
		case kCC3SemanticCameraPosition:
			[uniform setVector: visitor.camera.globalLocation];
			return YES;
			
		// MATERIALS --------------
		case kCC3SemanticColor:
			[uniform setColor4F: CC3OpenGLESEngine.engine.state.color.value];
			return YES;
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
		case kCC3SemanticLightIsEnabled:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				[uniform setBoolean: glesLight.isEnabled at: i];
			}
			return YES;
		case kCC3SemanticLightPosition:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global position/direction to eye space and normalize if direction
					CC3Vector4 ltPos = glesLight.position.value;
					CC3Matrix4x4* viewMtx = CC3OpenGLESEngine.engine.matrices.viewMatrix;
					ltPos = CC3Matrix4x4TransformCC3Vector4(viewMtx, ltPos);
					if (ltPos.w == 0.0f) ltPos = CC3Vector4Normalize(ltPos);
					[uniform setVector4: ltPos at: i];
				}
			}
			return YES;
		case kCC3SemanticLightColorAmbient:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setColor4F: glesLight.ambientColor.value at: i];
			}
			return YES;
		case kCC3SemanticLightColorDiffuse:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setColor4F: glesLight.diffuseColor.value at: i];
			}
			return YES;
		case kCC3SemanticLightColorSpecular:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setColor4F: glesLight.specularColor.value at: i];
			}
			return YES;
		case kCC3SemanticLightAttenuation:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					CC3AttenuationCoefficients ac;
					ac.a = glesLight.constantAttenuation.value;
					ac.b = glesLight.linearAttenuation.value;
					ac.c = glesLight.quadraticAttenuation.value;
					[uniform setVector: *(CC3Vector*)&ac at: i];
				}
			}
			return YES;
		case kCC3SemanticLightSpotDirection:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) {
					// Transform global direction to eye space and normalize
					CC3Vector4 ltDir = CC3Vector4FromDirection(glesLight.spotDirection.value);
					CC3Matrix4x4* viewMtx = CC3OpenGLESEngine.engine.matrices.viewMatrix;
					ltDir = CC3Matrix4x4TransformCC3Vector4(viewMtx, ltDir);
					[uniform setVector: CC3VectorNormalize(CC3VectorFromTruncatedCC3Vector4(ltDir)) at: i];
				}
				
				if (glesLight.isEnabled) [uniform setVector: glesLight.spotDirection.value at: i];
			}
			return YES;
		case kCC3SemanticLightSpotExponent:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setFloat: glesLight.spotExponent.value at: i];
			}
			return YES;
		case kCC3SemanticLightSpotCutoffAngle:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setFloat: glesLight.spotCutoffAngle.value at: i];
			}
			return YES;
		case kCC3SemanticLightSpotCutoffAngleCosine:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesLight = [CC3OpenGLESEngine.engine.lighting lightAt: (semanticIndex + i)];
				if (glesLight.isEnabled) [uniform setFloat: cosf(DegreesToRadians(glesLight.spotCutoffAngle.value)) at: i];
			}
			return YES;
			
		// TEXTURES --------------
		case kCC3SemanticTextureCount:
			[uniform setInteger: visitor.textureUnitCount];
			return YES;
		case kCC3SemanticTextureSamplers:
			// Samplers are simply consecutive texture unit indices
			for (GLuint i = 0; i < uniformSize; i++) [uniform setInteger: i at: i];
			return YES;

		// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
		// In most shaders, these will be left unused in favor of customized the texture combining in code.
		case kCC3SemanticTexUnitMode:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.textureEnvironmentMode.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitConstantColor:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setColor4F: glesTexUnit.color.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitCombineRGBFunction:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.combineRGBFunction.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource0RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbSource0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource1RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbSource1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource2RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbSource2.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand0RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbOperand0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand1RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbOperand1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand2RGB:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.rgbOperand2.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitCombineAlphaFunction:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.combineAlphaFunction.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource0Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaSource0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource1Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaSource1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitSource2Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaSource2.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand0Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaOperand0.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand1Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaOperand1.value at: i];
			}
			return YES;
		case kCC3SemanticTexUnitOperand2Alpha:
			for (GLuint i = 0; i < uniformSize; i++) {
				glesTexUnit = [CC3OpenGLESEngine.engine.textures textureUnitAt: (semanticIndex + i)];
				[uniform setInteger: glesTexUnit.alphaOperand2.value at: i];
			}
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
	if ( !_varConfigsByName ) _varConfigsByName = [NSMutableDictionary new];		// retained
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
#pragma mark CC3GLProgramSemanticsDelegateByVarNames default mappings extension

@implementation CC3GLProgramSemanticsDelegateByVarNames (DefaultMappings)

-(void) populateWithDefaultVariableNameMappings {
	
	// VETEX ATTRIBUTES --------------
	[self mapVarName: @"a_cc3Position" toSemantic: kCC3SemanticVertexLocations];
	[self mapVarName: @"a_cc3Normal" toSemantic: kCC3SemanticVertexNormals];
	[self mapVarName: @"a_cc3Color" toSemantic: kCC3SemanticVertexColors];
	[self mapVarName: @"a_cc3Weight" toSemantic: kCC3SemanticVertexWeights];
	[self mapVarName: @"a_cc3MatrixIdx" toSemantic: kCC3SemanticVertexMatrices];
	[self mapVarName: @"a_cc3PointSize" toSemantic: kCC3SemanticVertexPointSizes];
	[self mapVarName: @"a_cc3TexCoord" toSemantic: kCC3SemanticVertexTexture];	// alias to a_cc3TexCoord0
	[self mapVarName: @"a_cc3TexCoord0" toSemantic: kCC3SemanticVertexTexture at: 0];
	[self mapVarName: @"a_cc3TexCoord1" toSemantic: kCC3SemanticVertexTexture at: 1];
	[self mapVarName: @"a_cc3TexCoord2" toSemantic: kCC3SemanticVertexTexture at: 2];
	[self mapVarName: @"a_cc3TexCoord3" toSemantic: kCC3SemanticVertexTexture at: 3];
	[self mapVarName: @"a_cc3TexCoord4" toSemantic: kCC3SemanticVertexTexture at: 4];
	[self mapVarName: @"a_cc3TexCoord5" toSemantic: kCC3SemanticVertexTexture at: 5];
	[self mapVarName: @"a_cc3TexCoord6" toSemantic: kCC3SemanticVertexTexture at: 6];
	[self mapVarName: @"a_cc3TexCoord7" toSemantic: kCC3SemanticVertexTexture at: 7];
	
	// ATTRIBUTE QUALIFIERS --------------
	[self mapVarName: @"u_cc3HasVertexNormal" toSemantic: kCC3SemanticHasVertexNormal];
	[self mapVarName: @"u_cc3ShouldNormalizeNormal" toSemantic: kCC3SemanticShouldNormalizeVertexNormal];
	[self mapVarName: @"u_cc3ShouldRescaleNormal" toSemantic: kCC3SemanticShouldRescaleVertexNormal];
	[self mapVarName: @"u_cc3HasVertexColor" toSemantic: kCC3SemanticHasVertexColor];
	[self mapVarName: @"u_cc3HasVertexTexCoord" toSemantic: kCC3SemanticHasVertexTextureCoordinate];
	[self mapVarName: @"u_cc3HasVertexPointSize" toSemantic: kCC3SemanticHasVertexPointSize];	// alias for u_cc3Points.hasVertexPointSize
	[self mapVarName: @"u_cc3IsDrawingPoints" toSemantic: kCC3SemanticIsDrawingPoints];		// alias for u_cc3Points.isDrawingPoints
	
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
	[self mapVarName: @"u_cc3MtxM" toSemantic: kCC3SemanticModelMatrix];
	[self mapVarName: @"u_cc3MtxMI" toSemantic: kCC3SemanticModelMatrixInv];
	[self mapVarName: @"u_cc3MtxMIT" toSemantic: kCC3SemanticModelMatrixInvTran];
	[self mapVarName: @"u_cc3MtxV" toSemantic: kCC3SemanticViewMatrix];
	[self mapVarName: @"u_cc3MtxVI" toSemantic: kCC3SemanticViewMatrixInv];
	[self mapVarName: @"u_cc3MtxVIT" toSemantic: kCC3SemanticViewMatrixInvTran];
	[self mapVarName: @"u_cc3MtxMV" toSemantic: kCC3SemanticModelViewMatrix];
	[self mapVarName: @"u_cc3MtxMVI" toSemantic: kCC3SemanticModelViewMatrixInv];
	[self mapVarName: @"u_cc3MtxMVIT" toSemantic: kCC3SemanticModelViewMatrixInvTran];
	[self mapVarName: @"u_cc3MtxP" toSemantic: kCC3SemanticProjMatrix];
	[self mapVarName: @"u_cc3MtxPI" toSemantic: kCC3SemanticProjMatrixInv];
	[self mapVarName: @"u_cc3MtxPIT" toSemantic: kCC3SemanticProjMatrixInvTran];
	[self mapVarName: @"u_cc3MtxMVP" toSemantic: kCC3SemanticModelViewProjMatrix];
	[self mapVarName: @"u_cc3MtxMVPI" toSemantic: kCC3SemanticModelViewProjMatrixInv];
	[self mapVarName: @"u_cc3MtxMVPIT" toSemantic: kCC3SemanticModelViewProjMatrixInvTran];
	
	// CAMERA -----------------
	[self mapVarName: @"u_cc3CameraPosition" toSemantic: kCC3SemanticCameraPosition];
	
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
	
	[self mapVarName: @"u_cc3Light.isEnabled" toSemantic: kCC3SemanticLightIsEnabled];		// Aliases for light zero
	[self mapVarName: @"u_cc3Light.position" toSemantic: kCC3SemanticLightPosition];
	[self mapVarName: @"u_cc3Light.ambientColor" toSemantic: kCC3SemanticLightColorAmbient];
	[self mapVarName: @"u_cc3Light.diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse];
	[self mapVarName: @"u_cc3Light.specularColor" toSemantic: kCC3SemanticLightColorSpecular];
	[self mapVarName: @"u_cc3Light.attenuation" toSemantic: kCC3SemanticLightAttenuation];
	[self mapVarName: @"u_cc3Light.spotDirection" toSemantic: kCC3SemanticLightSpotDirection];
	[self mapVarName: @"u_cc3Light.spotExponent" toSemantic: kCC3SemanticLightSpotExponent];
	[self mapVarName: @"u_cc3Light.spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle];
	[self mapVarName: @"u_cc3Light.spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine];
	
	[self mapVarName: @"u_cc3Lights[0].isEnabled" toSemantic: kCC3SemanticLightIsEnabled at: 0];
	[self mapVarName: @"u_cc3Lights[0].position" toSemantic: kCC3SemanticLightPosition at: 0];
	[self mapVarName: @"u_cc3Lights[0].ambientColor" toSemantic: kCC3SemanticLightColorAmbient at: 0];
	[self mapVarName: @"u_cc3Lights[0].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse at: 0];
	[self mapVarName: @"u_cc3Lights[0].specularColor" toSemantic: kCC3SemanticLightColorSpecular at: 0];
	[self mapVarName: @"u_cc3Lights[0].attenuation" toSemantic: kCC3SemanticLightAttenuation at: 0];
	[self mapVarName: @"u_cc3Lights[0].spotDirection" toSemantic: kCC3SemanticLightSpotDirection at: 0];
	[self mapVarName: @"u_cc3Lights[0].spotExponent" toSemantic: kCC3SemanticLightSpotExponent at: 0];
	[self mapVarName: @"u_cc3Lights[0].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle at: 0];
	[self mapVarName: @"u_cc3Lights[0].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine at: 0];
	
	[self mapVarName: @"u_cc3Lights[1].isEnabled" toSemantic: kCC3SemanticLightIsEnabled at: 1];
	[self mapVarName: @"u_cc3Lights[1].position" toSemantic: kCC3SemanticLightPosition at: 1];
	[self mapVarName: @"u_cc3Lights[1].ambientColor" toSemantic: kCC3SemanticLightColorAmbient at: 1];
	[self mapVarName: @"u_cc3Lights[1].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse at: 1];
	[self mapVarName: @"u_cc3Lights[1].specularColor" toSemantic: kCC3SemanticLightColorSpecular at: 1];
	[self mapVarName: @"u_cc3Lights[1].attenuation" toSemantic: kCC3SemanticLightAttenuation at: 1];
	[self mapVarName: @"u_cc3Lights[1].spotDirection" toSemantic: kCC3SemanticLightSpotDirection at: 1];
	[self mapVarName: @"u_cc3Lights[1].spotExponent" toSemantic: kCC3SemanticLightSpotExponent at: 1];
	[self mapVarName: @"u_cc3Lights[1].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle at: 1];
	[self mapVarName: @"u_cc3Lights[1].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine at: 1];
	
	[self mapVarName: @"u_cc3Lights[2].isEnabled" toSemantic: kCC3SemanticLightIsEnabled at: 2];
	[self mapVarName: @"u_cc3Lights[2].position" toSemantic: kCC3SemanticLightPosition at: 2];
	[self mapVarName: @"u_cc3Lights[2].ambientColor" toSemantic: kCC3SemanticLightColorAmbient at: 2];
	[self mapVarName: @"u_cc3Lights[2].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse at: 2];
	[self mapVarName: @"u_cc3Lights[2].specularColor" toSemantic: kCC3SemanticLightColorSpecular at: 2];
	[self mapVarName: @"u_cc3Lights[2].attenuation" toSemantic: kCC3SemanticLightAttenuation at: 2];
	[self mapVarName: @"u_cc3Lights[2].spotDirection" toSemantic: kCC3SemanticLightSpotDirection at: 2];
	[self mapVarName: @"u_cc3Lights[2].spotExponent" toSemantic: kCC3SemanticLightSpotExponent at: 2];
	[self mapVarName: @"u_cc3Lights[2].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle at: 2];
	[self mapVarName: @"u_cc3Lights[2].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine at: 2];
	
	[self mapVarName: @"u_cc3Lights[3].isEnabled" toSemantic: kCC3SemanticLightIsEnabled at: 3];
	[self mapVarName: @"u_cc3Lights[3].position" toSemantic: kCC3SemanticLightPosition at: 3];
	[self mapVarName: @"u_cc3Lights[3].ambientColor" toSemantic: kCC3SemanticLightColorAmbient at: 3];
	[self mapVarName: @"u_cc3Lights[3].diffuseColor" toSemantic: kCC3SemanticLightColorDiffuse at: 3];
	[self mapVarName: @"u_cc3Lights[3].specularColor" toSemantic: kCC3SemanticLightColorSpecular at: 3];
	[self mapVarName: @"u_cc3Lights[3].attenuation" toSemantic: kCC3SemanticLightAttenuation at: 3];
	[self mapVarName: @"u_cc3Lights[3].spotDirection" toSemantic: kCC3SemanticLightSpotDirection at: 3];
	[self mapVarName: @"u_cc3Lights[3].spotExponent" toSemantic: kCC3SemanticLightSpotExponent at: 3];
	[self mapVarName: @"u_cc3Lights[3].spotCutoffAngle" toSemantic: kCC3SemanticLightSpotCutoffAngle at: 3];
	[self mapVarName: @"u_cc3Lights[3].spotCutoffAngleCosine" toSemantic: kCC3SemanticLightSpotCutoffAngleCosine at: 3];
	
	// APPLICATIONS CAN ADD MORE MAPPINGS FOR SHADERS THAT SUPPORT ADDITIONAL LIGHTS
	
	
	// TEXTURES --------------
	[self mapVarName: @"u_cc3TextureCount" toSemantic: kCC3SemanticTextureCount];
	[self mapVarName: @"s_cc3Texture" toSemantic: kCC3SemanticTextureSamplers];		// alias for s_cc3Textures[0]
	[self mapVarName: @"s_cc3Textures[0]" toSemantic: kCC3SemanticTextureSamplers];	// alias for s_cc3Texture
	
	// The semantics below mimic OpenGL ES 1.1 configuration functionality for combining texture units.
	// In most shaders, these will be left unused in favor of customized the texture combining in code.
	[self mapVarName: @"u_cc3TextureUnits[0].color" toSemantic: kCC3SemanticTexUnitConstantColor at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].mode" toSemantic: kCC3SemanticTexUnitMode at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha at: 0];
	[self mapVarName: @"u_cc3TextureUnits[0].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha at: 0];
	
	[self mapVarName: @"u_cc3TextureUnits[1].color" toSemantic: kCC3SemanticTexUnitConstantColor at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].mode" toSemantic: kCC3SemanticTexUnitMode at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha at: 1];
	[self mapVarName: @"u_cc3TextureUnits[1].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha at: 1];
	
	[self mapVarName: @"u_cc3TextureUnits[2].color" toSemantic: kCC3SemanticTexUnitConstantColor at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].mode" toSemantic: kCC3SemanticTexUnitMode at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha at: 2];
	[self mapVarName: @"u_cc3TextureUnits[2].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha at: 2];
	
	[self mapVarName: @"u_cc3TextureUnits[3].color" toSemantic: kCC3SemanticTexUnitConstantColor at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].mode" toSemantic: kCC3SemanticTexUnitMode at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].combineRGBFunction" toSemantic: kCC3SemanticTexUnitCombineRGBFunction at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].rgbSource0" toSemantic: kCC3SemanticTexUnitSource0RGB at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].rgbSource1" toSemantic: kCC3SemanticTexUnitSource1RGB at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].rgbSource2" toSemantic: kCC3SemanticTexUnitSource2RGB at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].rgbOperand0" toSemantic: kCC3SemanticTexUnitOperand0RGB at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].rgbOperand1" toSemantic: kCC3SemanticTexUnitOperand1RGB at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].rgbOperand2" toSemantic: kCC3SemanticTexUnitOperand2RGB at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].combineAlphaFunction" toSemantic: kCC3SemanticTexUnitCombineAlphaFunction at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].alphaSource0" toSemantic: kCC3SemanticTexUnitSource0Alpha at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].alphaSource1" toSemantic: kCC3SemanticTexUnitSource1Alpha at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].alphaSource2" toSemantic: kCC3SemanticTexUnitSource2Alpha at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].alphaOperand0" toSemantic: kCC3SemanticTexUnitOperand0Alpha at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].alphaOperand1" toSemantic: kCC3SemanticTexUnitOperand1Alpha at: 3];
	[self mapVarName: @"u_cc3TextureUnits[3].alphaOperand2" toSemantic: kCC3SemanticTexUnitOperand2Alpha at: 3];
	
	// APPLICATIONS CAN ADD MORE MAPPINGS FOR SHADERS THAT SUPPORT ADDITIONAL TEXTURE UNITS
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
	
