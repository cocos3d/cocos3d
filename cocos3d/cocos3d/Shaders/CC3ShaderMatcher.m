/*
 * CC3ShaderMatcher.m
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
 * See header file CC3ShaderMatcher.h for full API documentation.
 */

#import "CC3ShaderMatcher.h"
#import "CC3VertexSkinning.h"


#pragma mark -
#pragma mark CC3ShaderMatcherBase

@implementation CC3ShaderMatcherBase

@synthesize semanticDelegate=_semanticDelegate;

-(void) dealloc {
	[_semanticDelegate release];
	[super dealloc];
}

-(CC3ShaderProgram*) programForMeshNode: (CC3MeshNode*) aMeshNode {
	return [CC3ShaderProgram programWithSemanticDelegate: self.semanticDelegate
									fromVertexShaderFile: [self vertexShaderFileForMeshNode: aMeshNode]
								   andFragmentShaderFile: [self fragmentShaderFileForMeshNode: aMeshNode]];
}

-(NSString*) vertexShaderFileForMeshNode: (CC3MeshNode*) aMeshNode {

	if (aMeshNode.shouldDrawInClipSpace) return @"CC3ClipSpaceTexturable.vsh";
	
	if (aMeshNode.hasRigidSkeleton) return @"CC3TexturableRigidBones.vsh";
	
	if (aMeshNode.hasSkeleton) return @"CC3TexturableBones.vsh";
	
	if (aMeshNode.isDrawingPointSprites) return @"CC3PointSprites.vsh";
		
	return @"CC3Texturable.vsh";
}

-(NSString*) fragmentShaderFileForMeshNode: (CC3MeshNode*) aMeshNode {
	
	CC3Material* mat = aMeshNode.ensureMaterial;
	GLuint texCnt = mat.textureCount;
	BOOL shouldAlphaTest = !mat.shouldDrawLowAlpha;
	
	if (aMeshNode.shouldDrawInClipSpace)
		return (texCnt > 0) ? @"CC3ClipSpaceSingleTexture.fsh" : @"CC3ClipSpaceNoTexture.fsh";
	
	if (aMeshNode.isDrawingPointSprites)
		return shouldAlphaTest ? @"CC3PointSpritesAlphaTest.fsh" : @"CC3PointSprites.fsh";

	// Material without texture
	if (texCnt == 0) return shouldAlphaTest ? @"CC3NoTextureAlphaTest.fsh" : @"CC3NoTexture.fsh";

	// Reflection using cube-map texture
	if (mat.hasTextureCube) {
		if (texCnt > 1)
			return shouldAlphaTest ? @"CC3SingleTextureReflectAlphaTest.fsh" : @"CC3SingleTextureReflect.fsh";
		else
			return shouldAlphaTest ? @"CC3NoTextureReflectAlphaTest.fsh" : @"CC3NoTextureReflect.fsh";
	}
	
	// Bump-mapping using a tangent-space normal map texture.
	if (texCnt > 1 && aMeshNode.mesh.hasVertexTangents)
		return shouldAlphaTest ? @"CC3BumpMapTangentSpaceAlphaTest.fsh" : @"CC3BumpMapTangentSpace.fsh";
	
	// Bump-mapping using an object-space normal map texture.
	if (texCnt > 1 && mat.hasBumpMap)
		return shouldAlphaTest ? @"CC3BumpMapObjectSpaceAlphaTest.fsh" : @"CC3BumpMapObjectSpace.fsh";
	
	// Default to the basic single-texture shader program
	return shouldAlphaTest ? @"CC3SingleTextureAlphaTest.fsh" : @"CC3SingleTexture.fsh";
}

-(CC3ShaderProgram*) pureColorProgramMatching: (CC3ShaderProgram*) shaderProgram {
	return [[shaderProgram class] programWithSemanticDelegate: shaderProgram.semanticDelegate
										 fromVertexShaderFile: shaderProgram.vertexShader.name
										andFragmentShaderFile: @"CC3PureColor.fsh"];
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		[self initSemanticDelegate];
	}
	return self;
}

-(void) initSemanticDelegate {
	CC3ShaderSemanticsByVarName* sd = [CC3ShaderSemanticsByVarName new];
	[sd populateWithDefaultVariableNameMappings];
	_semanticDelegate = sd;			// retained from new
}

@end
