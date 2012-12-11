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
//#import "CC3Matrix4x4.h"

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
		case kCC3SemanticModelMatrix: return @"kCC3SemanticModelMatrix";
		case kCC3SemanticModelMatrixInv: return @"kCC3SemanticModelMatrixInv";
		case kCC3SemanticViewMatrix: return @"kCC3SemanticViewMatrix";
		case kCC3SemanticViewMatrixInv: return @"kCC3SemanticViewMatrixInv";
		case kCC3SemanticModelViewMatrix: return @"kCC3SemanticModelViewMatrix";
		case kCC3SemanticModelViewMatrixInv: return @"kCC3SemanticModelViewMatrixInv";
		case kCC3SemanticProjMatrix: return @"kCC3SemanticProjMatrix";
		case kCC3SemanticProjMatrixInv: return @"kCC3SemanticProjMatrixInv";
		case kCC3SemanticModelViewProjMatrix: return @"kCC3SemanticModelViewProjMatrix";
		case kCC3SemanticModelViewProjMatrixInv: return @"kCC3SemanticModelViewProjMatrixInv";
			
		case kCC3SemanticMaterialColorAmbient: return @"kCC3SemanticMaterialColorAmbient";
		case kCC3SemanticMaterialColorDiffuse: return @"kCC3SemanticMaterialColorDiffuse";
		case kCC3SemanticMaterialColorSpecular: return @"kCC3SemanticMaterialColorSpecular";
		case kCC3SemanticMaterialColorEmission: return @"kCC3SemanticMaterialColorEmission";
		case kCC3SemanticMaterialOpacity: return @"kCC3SemanticMaterialOpacity";
		case kCC3SemanticMaterialShininess: return @"kCC3SemanticMaterialShininess";

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
	GLenum semantic = uniform.semantic;
	switch (semantic) {
		case kCC3SemanticModelViewProjMatrix: {
			CC3Matrix4x4 mvpMtx;
			CC3Matrix4x4* pMVP = &mvpMtx;
			[visitor.camera.frustum.viewProjectionMatrix populateCC3Matrix4x4: pMVP];
			[visitor.currentNode.transformMatrix multiplyIntoCC3Matrix4x4: pMVP];
			[uniform setMatrices4x4: pMVP];
			return YES;
		}

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

		case kCC3SemanticMaterialColorDiffuse:
			[uniform setColor4F: visitor.currentMaterial.diffuseColor];
			return YES;

		default: return NO;
	}
}

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateByVarNames

@implementation CC3GLProgramSemanticsDelegateByVarNames

-(BOOL) assignAttributeSemantic: (CC3GLSLAttribute*) variable {
	CC3SetSemantic(@"a_position", kCC3VertexContentSemanticLocations);
	CC3SetSemantic(@"a_normal", kCC3VertexContentSemanticNormals);
	CC3SetSemantic(@"a_color", kCC3VertexContentSemanticColors);
	CC3SetSemantic(@"a_weight", kCC3VertexContentSemanticWeights);
	CC3SetSemantic(@"a_matrixIdx", kCC3VertexContentSemanticMatrices);
	CC3SetSemantic(@"a_pointSize", kCC3VertexContentSemanticPointSizes);
	CC3SetSemantic(@"a_texCoord", kCC3VertexContentSemanticTexture0);	// alias to a_texCoord0
	CC3SetSemantic(@"a_texCoord0", kCC3VertexContentSemanticTexture0);
	CC3SetSemantic(@"a_texCoord1", kCC3VertexContentSemanticTexture1);
	CC3SetSemantic(@"a_texCoord2", kCC3VertexContentSemanticTexture2);
	CC3SetSemantic(@"a_texCoord3", kCC3VertexContentSemanticTexture3);
	CC3SetSemantic(@"a_texCoord4", kCC3VertexContentSemanticTexture4);
	CC3SetSemantic(@"a_texCoord5", kCC3VertexContentSemanticTexture5);
	CC3SetSemantic(@"a_texCoord6", kCC3VertexContentSemanticTexture6);
	CC3SetSemantic(@"a_texCoord7", kCC3VertexContentSemanticTexture7);
	
	return NO;
}

-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) variable {
	CC3SetSemantic(@"u_mtxMVP", kCC3SemanticModelViewProjMatrix);

	CC3SetSemantic(@"u_matDiffuseColor", kCC3SemanticMaterialColorDiffuse);
	
	return NO;
}

@end
