/*
 * CC3OpenGLESShaders.m
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

#import "CC3OpenGLESShaders.h"


#pragma mark -
#pragma mark CC3OpenGLESShaders

@implementation CC3OpenGLESShaders

@synthesize activeProgram=_activeProgram, defaultProgram=_defaultProgram;
@synthesize defaultVertexShaderSourceFile=_defaultVertexShaderSourceFile;
@synthesize defaultFragmentShaderSourceFile=_defaultFragmentShaderSourceFile;

-(void) dealloc {
	[_programsByName release];
	[_defaultProgram release];
	_activeProgram = nil;		// retained in collection
	[_defaultVertexShaderSourceFile release];
	[_defaultFragmentShaderSourceFile release];
	[super dealloc];
}

-(void) setActiveProgram: (CC3GLProgram*) aProgram { _activeProgram = aProgram; }

-(void) addProgram: (CC3GLProgram*) program {
	CC3Assert( ![self getProgramNamed: program.name], @"%@ already contains a program named %@", self, program.name);
	[_programsByName setObject: program forKey: program.name];
}

-(CC3GLProgram*) getProgramNamed: (NSString*) name { return [_programsByName objectForKey: name]; }

-(void) removeProgram: (CC3GLProgram*) program { [self removeProgramNamed: program.name]; }

-(void) removeProgramNamed: (NSString*) name { [_programsByName removeObjectForKey: name]; }

-(CC3GLProgram*) defaultProgram { return nil; }


#pragma mark Binding

-(void) bindPureColorProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) unbind {}


#pragma mark Allocation and initialization

-(void) initializeTrackers {
	_programsByName = [NSMutableDictionary new];		// retained
	_defaultVertexShaderSourceFile = nil;
	_defaultFragmentShaderSourceFile = nil;
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@:", [self class]];
	for (id p in _programsByName) [desc appendFormat: @"\n    %@ ", p];
	return desc;
}

@end
