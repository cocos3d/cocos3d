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
	[_uniformOverrides release];
	[_uniformOverridesByName release];
	
	[super dealloc];
}

-(CC3ShaderProgram*) program { return _program; }

-(void) setProgram:(CC3ShaderProgram*) program {
	if (program == _program) return;

	[_program release];
	_program = [program retain];
	
	self.pureColorProgram = nil;
	
	[self removeAllUniformOverrides];
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
	CC3GLSLUniform* rtnVar = [_uniformOverridesByName objectForKey: name];
	return rtnVar ? rtnVar : [self addUniformOverrideFor: [self.program uniformNamed: name]];
}

-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic at: (GLuint) semanticIndex {
	for (CC3GLSLUniform* var in _uniformOverrides)
		if (var.semantic == semantic && var.semanticIndex == semanticIndex) return var;
	return [self addUniformOverrideFor: [self.program uniformForSemantic: semantic at: semanticIndex]];
}

-(CC3GLSLUniform*) uniformOverrideForSemantic: (GLenum) semantic {
	return [self uniformOverrideForSemantic: semantic at: 0];
}

-(CC3GLSLUniform*) uniformOverrideAtLocation: (GLint) uniformLocation {
	for (CC3GLSLUniform* var in _uniformOverrides) if (var.location == uniformLocation) return var;
	return [self addUniformOverrideFor: [self.program uniformAtLocation: uniformLocation]];
}

-(CC3GLSLUniform*)	addUniformOverrideFor: (CC3GLSLUniform*) uniform {
	if( !uniform ) return nil;
	
	CC3GLSLUniform* pureColorUniform = [self.pureColorProgram uniformNamed: uniform.name];
	CC3GLSLUniformOverride* override = [CC3GLSLUniformOverride uniformOverrideForProgramUniform: uniform
																	 andPureColorProgramUniform: pureColorUniform];
	[self addUniformOverride: override];
	return override;
}

-(void) addUniformOverride: (CC3GLSLUniformOverride*) uniformOverride {
	if( !uniformOverride ) return;
	
	if ( !_uniformOverrides ) _uniformOverrides = [NSMutableArray new];						// retained
	if ( !_uniformOverridesByName ) _uniformOverridesByName = [NSMutableDictionary new];	// retained
		
	[_uniformOverridesByName setObject: uniformOverride forKey: uniformOverride.name];
	[_uniformOverrides addObject: uniformOverride];
}

-(void)	removeUniformOverride: (CC3GLSLUniform*) uniform {
	[_uniformOverrides removeObjectIdenticalTo: uniform];
	[_uniformOverridesByName removeObjectForKey: uniform.name];
	CC3Assert(_uniformOverrides.count == _uniformOverridesByName.count, @"%@ was not completely removed from %@", uniform, self);
	if (_uniformOverrides.count == 0) [self removeAllUniformOverrides];	// Remove empty collections
}

-(void) removeAllUniformOverrides {
	[_uniformOverridesByName release];
	_uniformOverridesByName = nil;
	[_uniformOverrides release];
	_uniformOverrides = nil;
}


#pragma mark Drawing

-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor {

	// If any of the uniform overrides are overriding the uniform, update the value of the
	// uniform from the override, and return that we've done so.
	for (CC3GLSLUniformOverride* var in _uniformOverrides)
		if ( [var updateIfOverriding: uniform] ) return YES;

	// If the semantic is unknown, and no override was found, return whether a default is okay
	if (uniform.semantic == kCC3SemanticNone) return !_shouldEnforceCustomOverrides;
	
	return NO;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_program = nil;
		_pureColorProgram = nil;
		_uniformOverrides = nil;
		_uniformOverridesByName = nil;
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
-(NSArray*) uniformOverrides { return _uniformOverrides; }
-(CC3ShaderProgram*) rawPureColorProgram { return _pureColorProgram; }

-(void) populateFrom: (CC3ShaderContext*) another {
	[_program release];
	_program = [another.program retain];
	
	[_pureColorProgram release];
	_pureColorProgram = [another.rawPureColorProgram retain];

	_shouldEnforceCustomOverrides = another.shouldEnforceCustomOverrides;
	_shouldEnforceVertexAttributes = another.shouldEnforceVertexAttributes;

	for (CC3GLSLUniformOverride* uo in another.uniformOverrides)
		[self addUniformOverride: [uo autoreleasedCopy]];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for program %@", self.class, _program];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ for program %@", self.class, _program.fullDescription];
}

@end
