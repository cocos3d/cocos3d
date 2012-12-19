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
	[_uniforms release];
	[_uniformsByName release];
	[super dealloc];
}

-(CC3GLProgram*) program { return _program; }

-(void) setProgram:(CC3GLProgram*) program {
	if (program == _program) return;
	[_program release];
	_program = [program retain];
	[self removeAllOverrides];
}


#pragma mark Variables

-(CC3GLSLUniform*) uniformOverrideNamed: (NSString*) name {
	CC3GLSLUniform* rtnVar = [_uniformsByName objectForKey: name];
	return rtnVar ? rtnVar : [self addUniformOverrideFor: [_program uniformNamed: name]];
}

-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic {
	for (CC3GLSLUniform* var in _uniforms) if (var.semantic == semantic) return var;
	return [self addUniformOverrideFor: [_program uniformForSemantic: semantic]];
}

-(CC3GLSLUniform*) uniformOverrideAtLocation: (GLint) uniformLocation {
	for (CC3GLSLUniform* var in _uniforms) if (var.location == uniformLocation) return var;
	return [self addUniformOverrideFor: [_program uniformAtLocation: uniformLocation]];
}

-(CC3GLSLUniform*)	addUniformOverrideFor: (CC3GLSLUniform*) uniform {
	if( !uniform ) return nil;		// Don't add override for non-existant uniform
	
	if ( !_uniforms ) _uniforms = [CCArray new];							// retained
	if ( !_uniformsByName ) _uniformsByName = [NSMutableDictionary new];	// retained

	CC3GLSLUniform* newUniform = [uniform copyAsClass: CC3GLSLUniform.class];
	[_uniformsByName setObject: newUniform forKey: newUniform.name];
	[_uniforms addObject: newUniform];
	[newUniform release];
	return newUniform;
}

-(void)	removeUniformOverride: (CC3GLSLUniform*) uniform {
	[_uniforms removeObjectIdenticalTo: uniform];
	[_uniformsByName removeObjectForKey: uniform.name];
	NSAssert2(_uniforms.count == _uniformsByName.count,
			  @"%@ was not completely removed from %@", uniform, self);
	if (_uniforms.count == 0) [self removeAllOverrides];	// Remove empty collections
}

-(void) removeAllOverrides {
	[_uniformsByName release];
	_uniformsByName = nil;
	[_uniforms release];
	_uniforms = nil;
}


#pragma mark Drawing

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[_program bindWithVisitor: visitor fromContext: self];
}

// Match based on location
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	for (CC3GLSLUniform* var in _uniforms) {
		if (var.location == uniform.location) {
			[var setValueInto: uniform];
			return YES;
		}
	}
	return NO;
}


#pragma mark Allocation and initialization

-(id) init { return [self initForProgram: nil]; }

-(id) initForProgram: (CC3GLProgram*) program {
	if ( (self = [super init]) ) {
		self.program = program;								// retained
		_uniforms = nil;
		_uniformsByName = nil;
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
