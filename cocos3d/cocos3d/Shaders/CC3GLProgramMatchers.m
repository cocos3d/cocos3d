/*
 * CC3GLProgramMatchers.m
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
 * See header file CC3GLProgramMatchers.h for full API documentation.
 */

#import "CC3GLProgramMatchers.h"
#import "CC3MeshNode.h"


#pragma mark -
#pragma mark CC3GLProgramMatcherBase

@implementation CC3GLProgramMatcherBase

@synthesize semanticDelegate=_semanticDelegate;

-(void) dealloc {
	[_semanticDelegate release];
	[_pureColorProgram release];
	[super dealloc];
}

-(Class) programClass { return [CC3GLProgram class]; }

-(CC3GLProgram*) programForMeshNode: (CC3MeshNode*) aMeshNode {
	CC3Material* mat = aMeshNode.material;
	if ( !mat ) return self.pureColorProgram;
	
	CC3GLProgram* shaderProgram = mat.shaderProgram;
	if ( !shaderProgram ) {
		shaderProgram = [self selectProgramForMeshNode: aMeshNode];
		mat.shaderProgram = shaderProgram;
		LogRez(@"Shader program %@ automatically selected for %@", shaderProgram, aMeshNode);
	}
	return shaderProgram;
}

-(CC3GLProgram*) selectProgramForMeshNode: (CC3MeshNode*) aMeshNode {
		
	CC3Material* mat = aMeshNode.material;

	// No material
	if ( !mat ) return self.pureColorProgram;
	
	GLuint texCnt = mat.textureCount;
	BOOL shouldAlphaTest = !mat.shouldDrawLowAlpha;
	
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
	if (texCnt > 0 && aMeshNode.mesh.hasVertexTangents)
		return [self bumpMapTangentSpaceProgram: shouldAlphaTest];
	
	// Bump-mapping using an object-space normal map texture.
	if (texCnt > 0 && mat.hasBumpMap)
		return [self bumpMapObjectSpaceProgram: shouldAlphaTest];
	
	// Single texture with no configurable texture unit
	if (texCnt == 1 && !mat.texture.textureUnit)
		return [self singleTextureProgram: shouldAlphaTest];

	// Default to the most flexible, but least efficient shaders
	return [self configurableProgram: shouldAlphaTest];
}


#pragma mark Program options

/** This property is accessed quite frequently for activities like node picking, so cache the program here. */
-(CC3GLProgram*) pureColorProgram {
	if ( !_pureColorProgram )
		_pureColorProgram = [self programFromVertexShaderFile: @"CC3PureColor.vsh"
										andFragmentShaderFile: @"CC3PureColor.fsh"];
	return _pureColorProgram;
}

-(CC3GLProgram*) configurableProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: @"CC3MultiTextureConfigurable.fsh"];
}

-(CC3GLProgram*) singleTextureProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3SingleTextureAlphaTest.fsh"
											   : @"CC3SingleTexture.fsh")];
}

-(CC3GLProgram*) singleTextureReflectiveProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3SingleTextureReflectAlphaTest.fsh"
											   : @"CC3SingleTextureReflect.fsh")];
}

-(CC3GLProgram*) noTextureProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3NoTextureAlphaTest.fsh"
											   : @"CC3NoTexture.fsh")];
}

-(CC3GLProgram*) noTextureReflectiveProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3NoTextureReflectAlphaTest.fsh"
											   : @"CC3NoTextureReflect.fsh")];
}

-(CC3GLProgram*) pointSpriteProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3PointSprites.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3PointSpritesAlphaTest.fsh"
											   : @"CC3PointSprites.fsh")];
}

-(CC3GLProgram*) bumpMapObjectSpaceProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3BumpMapObjectSpaceAlphaTest.fsh"
											   : @"CC3BumpMapObjectSpace.fsh")];
}

-(CC3GLProgram*) bumpMapTangentSpaceProgram: (BOOL) shouldAlphaTest {
	return [self programFromVertexShaderFile: @"CC3TexturableMaterial.vsh"
					   andFragmentShaderFile: (shouldAlphaTest
											   ? @"CC3BumpMapTangentSpaceAlphaTest.fsh"
											   : @"CC3BumpMapTangentSpace.fsh")];
}

-(CC3GLProgram*) programFromVertexShaderFile: (NSString*) vshFilename
					   andFragmentShaderFile: (NSString*) fshFilename {
	Class progClz = self.programClass;
	
	// Fetch and return program from cache if it has already been loaded
	NSString* progName = [progClz programNameFromVertexShaderFile: vshFilename
											andFragmentShaderFile: fshFilename];
	CC3GLProgram* prog = [[progClz getProgramNamed: progName] retain];		// retained
	if (prog) return prog;
	
	// Compile, link and cache the program
	prog = [[progClz alloc] initWithName: progName
					 andSemanticDelegate: self.semanticDelegate
					fromVertexShaderFile: vshFilename
				   andFragmentShaderFile: fshFilename];
	[progClz addProgram: prog];		// Add the new program to the cache
	[prog release];
	return prog;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_pureColorProgram = nil;
		[self initSemanticDelegate];
	}
	return self;
}

-(void) initSemanticDelegate {
	CC3GLProgramSemanticsByVarName* sd = [CC3GLProgramSemanticsByVarName new];
	[sd populateWithDefaultVariableNameMappings];
	_semanticDelegate = sd;		// retained by "new" above
}

@end
