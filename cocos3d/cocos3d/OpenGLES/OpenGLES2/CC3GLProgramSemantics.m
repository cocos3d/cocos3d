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

NSString* NSStringFromCC3StateSemantic(CC3StateSemantic semantic) {
	switch (semantic) {
		case kCC3StateSemanticNone: return @"kCC3StateSemanticNone";
		case kCC3StateSemanticModelMatrix: return @"kCC3StateSemanticModelMatrix";
		case kCC3StateSemanticModelMatrixInv: return @"kCC3StateSemanticModelMatrixInv";
		case kCC3StateSemanticViewMatrix: return @"kCC3StateSemanticViewMatrix";
		case kCC3StateSemanticViewMatrixInv: return @"kCC3StateSemanticViewMatrixInv";
		case kCC3StateSemanticModelViewMatrix: return @"kCC3StateSemanticModelViewMatrix";
		case kCC3StateSemanticModelViewMatrixInv: return @"kCC3StateSemanticModelViewMatrixInv";
		case kCC3StateSemanticProjMatrix: return @"kCC3StateSemanticProjMatrix";
		case kCC3StateSemanticProjMatrixInv: return @"kCC3StateSemanticProjMatrixInv";
		case kCC3StateSemanticModelViewProjMatrix: return @"kCC3StateSemanticModelViewProjMatrix";
		case kCC3StateSemanticModelViewProjMatrixInv: return @"kCC3StateSemanticModelViewProjMatrixInv";
			
		case kCC3StateSemanticMaterialColorAmbient: return @"kCC3StateSemanticMaterialColorAmbient";
		case kCC3StateSemanticMaterialColorDiffuse: return @"kCC3StateSemanticMaterialColorDiffuse";
		case kCC3StateSemanticMaterialColorSpecular: return @"kCC3StateSemanticMaterialColorSpecular";
		case kCC3StateSemanticMaterialColorEmission: return @"kCC3StateSemanticMaterialColorEmission";
		case kCC3StateSemanticMaterialOpacity: return @"kCC3StateSemanticMaterialOpacity";
		case kCC3StateSemanticMaterialShininess: return @"kCC3StateSemanticMaterialShininess";
			
		case kCC3StateSemanticAppBase: return @"kCC3StateSemanticAppBase";
		case kCC3StateSemanticMax: return @"kCC3StateSemanticMax";
		default: return [NSString stringWithFormat: @"Unknown state semantic (%u)", semantic];
	}
}


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateBase

@implementation CC3GLProgramSemanticsDelegateBase

+(id) semanticsDelegate { return [[[self alloc] init] autorelease]; }

-(NSString*) nameOfUniformSemantic: (GLenum) semantic { return NSStringFromCC3StateSemantic(semantic); }

-(NSString*) nameOfAttributeSemantic: (GLenum) semantic { return NSStringFromCC3VertexContentSemantic(semantic); }

-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) uniform { return NO; }

-(BOOL) assignAttributeSemantic: (CC3GLSLAttribute*) attribute { return NO; }

-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	switch (uniform.semantic) {
		case kCC3StateSemanticModelViewProjMatrix: {
			CC3Matrix4x4 mvpMtx;
			CC3Matrix4x4* pMVP = &mvpMtx;
			[visitor.camera.frustum.viewProjectionMatrix populateCC3Matrix4x4: pMVP];
			[visitor.currentNode.transformMatrix multiplyIntoCC3Matrix4x4: pMVP];
			[uniform setMatrices4x4: pMVP];
			return YES;
		}
		case kCC3StateSemanticMaterialColorDiffuse:
			[uniform setColor4F: visitor.currentMaterial.ambientColor];
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
	
	return NO;
}

-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) variable {
	CC3SetSemantic(@"u_mtxMVP", kCC3StateSemanticModelViewProjMatrix);

	CC3SetSemantic(@"u_matDiffuseColor", kCC3StateSemanticMaterialColorDiffuse);
	
	return NO;
}

@end
