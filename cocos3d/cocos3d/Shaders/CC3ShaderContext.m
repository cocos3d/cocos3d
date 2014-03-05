/*
 * CC3ShaderContext.m
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
 * See header file CC3ShaderContext.h for full API documentation.
 */

#import "CC3ShaderContext.h"
#import "CC3ShaderMatcher.h"


#pragma mark -
#pragma mark CC3ShaderContext

@implementation CC3ShaderContext

@synthesize shouldEnforceCustomOverrides=_shouldEnforceCustomOverrides;
@synthesize shouldEnforceVertexAttributes=_shouldEnforceVertexAttributes;

-(void) dealloc {
	[_program release];
	[_pureColorProgram release];
	[_uniforms release];
	[_uniformsByName release];
	
	[super dealloc];
}

-(CC3ShaderProgram*) program { return _program; }

-(void) setProgram:(CC3ShaderProgram*) program {
	if (program == _program) return;

	[_program release];
	_program = [program retain];
	
	self.pureColorProgram = nil;
	
	[self removeAllOverrides];
}

#if CC3_GLSL
-(CC3ShaderProgram*) pureColorProgram {
	if ( !_pureColorProgram )
		self.pureColorProgram = [CC3ShaderProgram.shaderMatcher pureColorProgramMatching: self.program];
	return _pureColorProgram;
}
#else
-(CC3ShaderProgram*) pureColorProgram { return _pureColorProgram; }
#endif	// CC3GLSL

-(void) setPureColorProgram:(CC3ShaderProgram*) program {
	if (program == _pureColorProgram) return;
	[_pureColorProgram release];
	_pureColorProgram = [program retain];
}


#pragma mark Variables

-(CC3GLSLUniform*) uniformOverrideNamed: (NSString*) name {
	CC3GLSLUniform* rtnVar = [_uniformsByName objectForKey: name];
	return rtnVar ? rtnVar : [self addUniformOverrideFor: [_program uniformNamed: name]];
}

-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic at: (GLuint) semanticIndex {
	for (CC3GLSLUniform* var in _uniforms)
		if (var.semantic == semantic && var.semanticIndex == semanticIndex)
			return var;
	return [self addUniformOverrideFor: [_program uniformForSemantic: semantic at: semanticIndex]];
}

-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic {
	return [self uniformOverrideForSemantic: semantic at: 0];
}

-(CC3GLSLUniform*) uniformOverrideAtLocation: (GLint) uniformLocation {
	for (CC3GLSLUniform* var in _uniforms) if (var.location == uniformLocation) return var;
	return [self addUniformOverrideFor: [_program uniformAtLocation: uniformLocation]];
}

-(CC3GLSLUniform*)	addUniformOverrideFor: (CC3GLSLUniform*) uniform {
	return [[self addUniformOverride: [uniform copyAsClass: CC3GLSLUniformOverride.class]] autorelease];
}

-(CC3GLSLUniformOverride*) addUniformOverride: (CC3GLSLUniformOverride*) uniformOverride {
	if( !uniformOverride ) return nil;
	
	if ( !_uniforms ) _uniforms = [NSMutableArray new];						// retained
	if ( !_uniformsByName ) _uniformsByName = [NSMutableDictionary new];	// retained
		
	[_uniformsByName setObject: uniformOverride forKey: uniformOverride.name];
	[_uniforms addObject: uniformOverride];

	return uniformOverride;
}

-(void)	removeUniformOverride: (CC3GLSLUniform*) uniform {
	[_uniforms removeObjectIdenticalTo: uniform];
	[_uniformsByName removeObjectForKey: uniform.name];
	CC3Assert(_uniforms.count == _uniformsByName.count,
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

// Match based on location
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {
	
	// If the program is not the mine, don't look up the override.
	CC3ShaderProgram* uProg = uniform.program;
	if ( !(uProg == _program || uProg == _pureColorProgram) ) return NO;

	// Find the matching uniform override by comparing locations
	// and set the value of the incoming uniform from it
	for (CC3GLSLUniform* var in _uniforms) {
		if (var.location == uniform.location) {
			[uniform setValueFromUniform: var];
			return YES;
		}
	}

	// If the semantic is unknown, and no override was found, return whether a default is okay
	if (uniform.semantic == kCC3SemanticNone) return !_shouldEnforceCustomOverrides;
	
	return NO;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_program = nil;
		_pureColorProgram = nil;
		_uniforms = nil;
		_uniformsByName = nil;
		_shouldEnforceCustomOverrides = YES;
		_shouldEnforceVertexAttributes = YES;
	}
	return self;
}

+(id) context { return [[[self alloc] init] autorelease]; }

-(id) copyWithZone: (NSZone*) zone {
	CC3ShaderContext* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

// Protected properties for copying
-(NSArray*) uniforms { return _uniforms; }
-(CC3ShaderProgram*) rawPureColorProgram { return _pureColorProgram; }

-(void) populateFrom: (CC3ShaderContext*) another {
	[_program release];
	_program = [another.program retain];
	
	[_pureColorProgram release];
	_pureColorProgram = [another.rawPureColorProgram retain];

	_shouldEnforceCustomOverrides = another.shouldEnforceCustomOverrides;
	_shouldEnforceVertexAttributes = another.shouldEnforceVertexAttributes;

	for (CC3GLSLUniformOverride* uo in another.uniforms) [self addUniformOverride: [uo autoreleasedCopy]];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for program %@", self.class, _program];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ for program %@", self.class, _program.fullDescription];
}

@end
