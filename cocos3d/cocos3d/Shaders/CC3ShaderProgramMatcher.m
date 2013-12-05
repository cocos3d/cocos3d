/*
 * CC3ShaderProgramMatchers.m
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
 * See header file CC3ShaderProgramMatcher.h for full API documentation.
 */

#import "CC3ShaderProgramMatcher.h"
#import "CC3MeshNode.h"


#pragma mark -
#pragma mark CC3ShaderProgramMatcherBase

@implementation CC3ShaderProgramMatcherBase

@synthesize semanticDelegate=_semanticDelegate;

-(CC3ShaderProgram*) pureColorProgramMatching: (CC3ShaderProgram*) shaderProgram {
	return [[shaderProgram class] programWithSemanticDelegate: shaderProgram.semanticDelegate
										 fromVertexShaderFile: shaderProgram.vertexShader.name
										andFragmentShaderFile: @"CC3PureColor.fsh"];
}

-(CC3ShaderProgram*) programForMeshNode: (CC3MeshNode*) aMeshNode {
	
	CC3Material* mat = aMeshNode.ensureMaterial;
	GLuint texCnt = mat.textureCount;
	
	BOOL shouldAlphaTest = !mat.shouldDrawLowAlpha;
	
	if (aMeshNode.shouldDrawInClipSpace) {
		if (texCnt == 0) return [self clipSpaceNoTextureProgram: shouldAlphaTest];
		if (texCnt == 1) return [self clipSpaceSingleTextureProgram: shouldAlphaTest];
	}
	
	// Material without texture
	if (texCnt == 0) return [self noTextureProgram: shouldAlphaTest];
	
	// Point sprites
	if (aMeshNode.isDrawingPointSprites) return [self pointSpriteProgram: shouldAlphaTest];
	
	// Reflection using cube-map texture
	if (mat.hasTextureCube) {
		if (texCnt > 1)
			return [self singleTextureReflectiveProgram: shouldAlphaTest];
		else
			return [self noTextureReflectiveProgram: shouldAlphaTest];
	}
	
	// Bump-mapping using a tangent-space normal map texture.
	if (texCnt > 1 && aMeshNode.mesh.hasVertexTangents)
		return [self bumpMapTangentSpaceProgram: shouldAlphaTest];
	
	// Bump-mapping using an object-space normal map texture.
	if (texCnt > 1 && mat.hasBumpMap)
		return [self bumpMapObjectSpaceProgram: shouldAlphaTest];

	// Default to the basic single-texture shader program
	return [self singleTextureProgram: shouldAlphaTest];
}


#pragma mark Program options

-(CC3ShaderProgram*) singleTextureProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3Texturable.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3SingleTextureAlphaTest.fsh"
											   : @"CC3SingleTexture.fsh")];
}

-(CC3ShaderProgram*) singleTextureReflectiveProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3Texturable.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3SingleTextureReflectAlphaTest.fsh"
											   : @"CC3SingleTextureReflect.fsh")];
}

-(CC3ShaderProgram*) noTextureProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3Texturable.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3NoTextureAlphaTest.fsh"
											   : @"CC3NoTexture.fsh")];
}

-(CC3ShaderProgram*) noTextureReflectiveProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3Texturable.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3NoTextureReflectAlphaTest.fsh"
											   : @"CC3NoTextureReflect.fsh")];
}

-(CC3ShaderProgram*) pointSpriteProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3PointSprites.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3PointSpritesAlphaTest.fsh"
											   : @"CC3PointSprites.fsh")];
}

-(CC3ShaderProgram*) bumpMapObjectSpaceProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3Texturable.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3BumpMapObjectSpaceAlphaTest.fsh"
											   : @"CC3BumpMapObjectSpace.fsh")];
}

-(CC3ShaderProgram*) bumpMapTangentSpaceProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3Texturable.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3BumpMapTangentSpaceAlphaTest.fsh"
											   : @"CC3BumpMapTangentSpace.fsh")];
}

-(CC3ShaderProgram*) clipSpaceSingleTextureProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3ClipSpaceTexturable.vsh"
					   andFragmentShaderFile: @"CC3ClipSpaceSingleTexture.fsh"];
}

-(CC3ShaderProgram*) clipSpaceNoTextureProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3ClipSpaceTexturable.vsh"
					   andFragmentShaderFile: @"CC3ClipSpaceNoTexture.fsh"];
}

-(CC3ShaderProgram*) programFromVertexShaderFile: (NSString*) vshFilePath
					   andFragmentShaderFile: (NSString*) fshFilePath {
	return [CC3ShaderProgram programWithSemanticDelegate: self.semanticDelegate
									fromVertexShaderFile: vshFilePath
								   andFragmentShaderFile: fshFilePath];
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		[self initSemanticDelegate];
	}
	return self;
}

-(void) initSemanticDelegate {
	CC3ShaderProgramSemanticsByVarName* sd = [CC3ShaderProgramSemanticsByVarName new];
	[sd populateWithDefaultVariableNameMappings];
	_semanticDelegate = sd;		// retained by "new" above
}

@end
