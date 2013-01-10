/*
 * CC3OpenGLES2Shaders.m
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
 * See header file CC3OpenGLESShaders.h for full API documentation.
 */

#import "CC3OpenGLES2Shaders.h"
#import "CC3OpenGLESEngine.h"

#if CC3_OGLES_2

#define kCC3DefaultGLProgramName				@"CC3DefaultGLProgram"
#define kCC3DefaultVertexShaderSourceFile		@"CC3ConfigurableWithDefaultVarNames.vsh"
#define kCC3DefaultFragmentShaderSourceFile		@"CC3ConfigurableWithDefaultVarNames.fsh"

#define kCC3PureColorGLProgramName				@"CC3PureColorGLProgram"
#define kCC3PureColorVertexShaderSourceFile		@"CC3PureColor.vsh"
#define kCC3PureColorFragmentShaderSourceFile	@"CC3PureColor.fsh"


#pragma mark -
#pragma mark CC3OpenGLES2Shaders

@implementation CC3OpenGLES2Shaders

-(void) dealloc {
	[_pureColorProgram release];
	[super dealloc];
}

-(CC3GLProgram*) defaultProgram {
	if ( !_defaultProgram ) [self addDefaultProgram];
	return _defaultProgram;
}

-(void) addDefaultProgram {
	if ( !(_defaultVertexShaderSourceFile && _defaultFragmentShaderSourceFile) ) return;

	_defaultProgram = [[CC3GLProgram alloc] initWithName: kCC3DefaultGLProgramName
									fromVertexShaderFile: _defaultVertexShaderSourceFile
								   andFragmentShaderFile: _defaultFragmentShaderSourceFile];
	_defaultProgram.semanticDelegate = [CC3GLProgramSemanticsByVarName sharedDefaultDelegate];
	[_defaultProgram link];
	[self addProgram: _defaultProgram];
}

-(void) addPureColorProgram {
	_pureColorProgram = [[CC3GLProgram alloc] initWithName: kCC3PureColorGLProgramName
									  fromVertexShaderFile: kCC3PureColorVertexShaderSourceFile
									 andFragmentShaderFile: kCC3PureColorFragmentShaderSourceFile];
	_pureColorProgram.semanticDelegate = [CC3GLProgramSemanticsByVarName sharedDefaultDelegate];
	[_pureColorProgram link];
	[self addProgram: _pureColorProgram];
}


#pragma mark Binding

-(void) bindPureColorProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[_pureColorProgram bindWithVisitor: visitor fromContext: nil];
}

-(void) unbind { ccGLUseProgram(0); }


#pragma mark Allocation and initialization

-(void) initializeTrackers {
	[super initializeTrackers];
	_defaultVertexShaderSourceFile = kCC3DefaultVertexShaderSourceFile;
	_defaultFragmentShaderSourceFile = kCC3DefaultFragmentShaderSourceFile;
	[self addPureColorProgram];
}

@end

#endif