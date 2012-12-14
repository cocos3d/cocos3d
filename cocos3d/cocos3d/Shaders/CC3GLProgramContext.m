/*
 * CC3GLProgramContext.m
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
 * See header file CC3GLProgramContext.h for full API documentation.
 */

#import "CC3GLProgramContext.h"


#pragma mark -
#pragma mark CC3GLProgramContext

@implementation CC3GLProgramContext

-(void) dealloc {
	[_program release];
	[_uniformsByName release];
	[super dealloc];
}

-(CC3GLProgram*) program { return _program; }

-(void) setProgram:(CC3GLProgram*) program {
	if (program == _program) return;
	[_program release];
	_program = [program retain];
	[self removeAllVariables];
}


#pragma mark Variables

-(CC3GLSLUniform*) uniformNamed: (NSString*) name {
	CC3GLSLUniform* rtnVar = [_uniformsByName objectForKey: name];
	return rtnVar ? rtnVar : [self addUniformCopiedFrom: [_program uniformNamed: name]];
}

-(CC3GLSLUniform*) uniformWithSemantic: (GLenum) semantic {
	__block CC3GLSLUniform* rtnVar = nil;
	[_uniformsByName enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		if (((CC3GLSLUniform*)obj).semantic == semantic) {
			rtnVar = obj;
			*stop = YES;
		}
	}];
	return rtnVar ? rtnVar : [self addUniformCopiedFrom: [_program uniformWithSemantic: semantic]];
}

/*
-(CC3GLSLUniform*) uniformWithSemantic: (GLenum) semantic {
	for (id key in _uniformsByName) {
		CC3GLSLUniform* var = [_uniformsByName objectForKey: key];
		if (var.semantic == semantic) return var;
	}
	return [self addUniformCopiedFrom: [_program uniformWithSemantic: semantic]];
}
*/

-(CC3GLSLUniform*) uniformAtLocation: (GLint) uniformLocation {
	__block CC3GLSLUniform* rtnVar = nil;
	[_uniformsByName enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		if (((CC3GLSLUniform*)obj).location == uniformLocation) {
			rtnVar = obj;
			*stop = YES;
		}
	}];
	return rtnVar ? rtnVar : [self addUniformCopiedFrom: [_program uniformAtLocation: uniformLocation]];
}

/*
-(CC3GLSLUniform*) uniformAtLocation: (GLint) uniformLocation {
	for (id key in _uniformsByName) {
		CC3GLSLUniform* var = [_uniformsByName objectForKey: key];
		if (var.location == uniformLocation) return var;
	}
	return [self addUniformCopiedFrom: [_program uniformAtLocation: uniformLocation]];
}
*/

-(CC3GLSLUniform*)	addUniformCopiedFrom: (CC3GLSLUniform*) uniform {
	CC3GLSLUniform* newUniform = [uniform copyAsClass: CC3GLSLUniform.class];
	[_uniformsByName setObject: newUniform forKey: newUniform.name];
	[newUniform release];
	return newUniform;
}


-(void) removeAllVariables { [_uniformsByName removeAllObjects]; }


#pragma mark Drawing

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[_program bindWithVisitor: visitor];
}


#pragma mark Allocation and initialization

-(id) init { return [self initForProgram: nil]; }

-(id) initForProgram: (CC3GLProgram*) program {
	if ( (self = [super init]) ) {
		self.program = program;								// retained
		_uniformsByName = [NSMutableDictionary new];		// retained
	}
	return self;
}

+(id) contextForProgram: (CC3GLProgram*) program {
	return [[[self alloc] initForProgram: program] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for program %@", self.class, _program];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ for program %@", self.class, _program.fullDescription];
}

@end
