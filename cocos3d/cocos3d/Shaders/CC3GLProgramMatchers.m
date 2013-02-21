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
	[_configugurableProgram release];
	[_singleTextureProgram release];
	[_singleTextureAlphaTestProgram release];
	[_noTextureProgram release];
	[_noTextureAlphaTestProgram release];
	[_pointSpriteProgram release];
	[_pointSpriteAlphaTestProgram release];
	[_pureColorProgram release];
	[super dealloc];
}

-(Class) programClass { return [CC3GLProgram class]; }

-(CC3GLProgram*) programForMeshNode: (CC3MeshNode*) aMeshNode {
	CC3Material* mat = aMeshNode.material;

	// No material
	if ( !mat ) return self.pureColorProgram;
	
	GLuint texCnt = mat.textureCount;
	BOOL shouldAlphaTest = !mat.shouldDrawLowAlpha;
	
	// Point sprites
	if (texCnt > 0 && aMeshNode.drawingMode == GL_POINTS)
		return shouldAlphaTest ? self.pointSpriteAlphaTestProgram :  self.pointSpriteProgram;
	
	// Material without texture
	if (texCnt == 0)
		return shouldAlphaTest ? self.noTextureAlphaTestProgram :  self.noTextureProgram;

	// Single texture with no configurable texture unit
	if (texCnt == 1 && !mat.texture.textureUnit)
		return shouldAlphaTest ? self.singleTextureAlphaTestProgram :  self.singleTextureProgram;

	return self.configurableProgram;
}

-(CC3GLProgram*) programForVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( !visitor.shouldDecorateNode ) return self.pureColorProgram;
	return [self programForMeshNode: visitor.currentMeshNode];
}


#pragma mark Program options

-(CC3GLProgram*) configurableProgram {
	if ( !_configugurableProgram )
		_configugurableProgram = [self programFromVertexShaderFile: @"CC3MultiTextureConfigurable.vsh"
											 andFragmentShaderFile: @"CC3MultiTextureConfigurable.fsh"];
	return _configugurableProgram;
}

-(CC3GLProgram*) singleTextureProgram {
	if ( !_singleTextureProgram )
		_singleTextureProgram = [self programFromVertexShaderFile: @"CC3SingleTexture.vsh"
											andFragmentShaderFile: @"CC3SingleTexture.fsh"];
	return _singleTextureProgram;
}

-(CC3GLProgram*) singleTextureAlphaTestProgram {
	if ( !_singleTextureAlphaTestProgram )
		_singleTextureAlphaTestProgram = [self programFromVertexShaderFile: @"CC3SingleTexture.vsh"
													 andFragmentShaderFile: @"CC3SingleTextureWithAlphaTest.fsh"];
	return _singleTextureAlphaTestProgram;
}

-(CC3GLProgram*) noTextureProgram {
	if ( !_noTextureProgram )
		_noTextureProgram = [self programFromVertexShaderFile: @"CC3NoTexture.vsh"
										andFragmentShaderFile: @"CC3NoTexture.fsh"];
	return _noTextureProgram;
}

-(CC3GLProgram*) noTextureAlphaTestProgram {
	if ( !_noTextureAlphaTestProgram )
		_noTextureAlphaTestProgram = [self programFromVertexShaderFile: @"CC3NoTexture.vsh"
												 andFragmentShaderFile: @"CC3NoTextureWithAlphaTest.fsh"];
	return _noTextureAlphaTestProgram;
}

-(CC3GLProgram*) pointSpriteProgram {
	if ( !_pointSpriteProgram )
		_pointSpriteProgram = [self programFromVertexShaderFile: @"CC3PointSprites.vsh"
										  andFragmentShaderFile: @"CC3PointSprites.fsh"];
	return _pointSpriteProgram;
}

-(CC3GLProgram*) pointSpriteAlphaTestProgram {
	if ( !_pointSpriteAlphaTestProgram )
		_pointSpriteAlphaTestProgram = [self programFromVertexShaderFile: @"CC3PointSprites.vsh"
												   andFragmentShaderFile: @"CC3PointSpritesWithAlphaTest.fsh"];
	return _pointSpriteAlphaTestProgram;
}

-(CC3GLProgram*) pureColorProgram {
	if ( !_pureColorProgram )
		_pureColorProgram = [self programFromVertexShaderFile: @"CC3PureColor.vsh"
										andFragmentShaderFile: @"CC3PureColor.fsh"];
	return _pureColorProgram;
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
		_configugurableProgram = nil;
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
