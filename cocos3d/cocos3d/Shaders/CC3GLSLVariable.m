/*
 * CC3GLSLVariable.m
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
 * See header file CC3GLSLVariable.h for full API documentation.
 */

#import "CC3GLSLVariable.h"
#import "CC3GLProgram.h"
#import "CC3OpenGLESVertexArrays.h"


#pragma mark -
#pragma mark CC3GLSLVariable

@implementation CC3GLSLVariable

@synthesize program=_program, index=_index, location=_location, name=_name;
@synthesize type=_type, size=_size, semantic=_semantic;

-(void) dealloc {
	_program = nil;			// not retained
	[_name release];
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) initInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	if ( (self = [super init]) ) {
		_program = program;			// not retained
		_index = index;
		_semantic = kCC3SemanticNone;
	}
	return self;
}

+(id) variableInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	return [[[self alloc] initInProgram: program atIndex: index] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [self copyWithZone: zone asClass: self.class];
}

-(id) copyAsClass: (Class) aClass { return [self copyWithZone: nil asClass: aClass]; }

-(id) copyWithZone: (NSZone*) zone asClass: (Class) aClass {
	CC3GLSLVariable* aCopy = [[aClass allocWithZone: zone] initInProgram: _program atIndex: _index];
	[aCopy populateFrom: self];
	return aCopy;
}

-(void) populateFrom: (CC3GLSLVariable*) another {
	// _program, _index set during init
	_location = another.location;
	_type = another.type;
	_size = another.size;

	[_name release];
	_name = [another.name retain];
}

-(void) populateFromProgram {}

-(NSString*) description { return [NSString stringWithFormat: @"%@ named %@", self.class, _name]; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @"\n\t\tSemantic: %@", self.semanticName];
	[desc appendFormat: @"\n\t\tType: %@", NSStringFromGLEnum(_type)];
	[desc appendFormat: @"\n\t\tSize: %i", _size];
	[desc appendFormat: @"\n\t\tLocation: %i", _location];
	[desc appendFormat: @"\n\t\tIndex: %i", _index];
	return desc;
}

-(NSString*) semanticName { return [_program.semanticDelegate nameOfSemantic: _semantic]; }

@end


#pragma mark -
#pragma mark CC3GLSLAttribute

@implementation CC3GLSLAttribute
@end


#pragma mark -
#pragma mark CC3GLSLUniform

@implementation CC3GLSLUniform

-(void) dealloc {
	free(_varValue);
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) initInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	if ( (self = [super initInProgram: program atIndex: index]) ) {
		_varLen = 0;
		_varValue = NULL;
	}
	return self;
}

-(void) populateFrom: (CC3GLSLUniform*) another {
	[super populateFrom: another];
	_varLen = GLElementTypeSize(_type) * _size;
	free(_varValue);
	_varValue = calloc(_varLen, 1);
}


#pragma mark Accessing uniform values

-(void) setFloats: (const GLfloat*) floats {
	switch (_type) {

		case GL_FLOAT:
		case GL_FLOAT_VEC2:
		case GL_FLOAT_VEC3:
		case GL_FLOAT_VEC4:
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			[self updateValue: floats];
			return;

		case GL_INT:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
		case GL_BOOL:
		case GL_BOOL_VEC2:
		case GL_BOOL_VEC3:
		case GL_BOOL_VEC4:
			[self setIntegersFromFloats: floats];
			return;

		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setIntegers: (const GLint*) ints {
	switch (_type) {
			
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
		case GL_BOOL:
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
		case GL_INT_VEC4:
		case GL_BOOL_VEC4:
			[self updateValue: ints];
			return;

		case GL_FLOAT:
		case GL_FLOAT_VEC2:
		case GL_FLOAT_VEC3:
		case GL_FLOAT_VEC4:
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			[self setFloatsFromIntegers: ints];
			return;
			
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setValueInto: (CC3GLSLUniform*) uniform {
	NSAssert2(uniform.type == _type, @"Cannot update %@ from %@ because uniforms are not of the same type",
			  uniform.fullDescription, self.fullDescription);
	NSAssert2(uniform.size == _size, @"Cannot update %@ from %@ because uniforms are not of the same size",
			  uniform.fullDescription, self.fullDescription);
	[uniform updateValue: _varValue];
}

/**
 * Checks whether the specified new content is different than the current cached GL content for this
 * uniform variable, updates the cached content if it is, and returns whether the content was changed.
 */
-(BOOL) updateValue: (const GLvoid*) newValue {
	if (memcmp(newValue, _varValue, _varLen) != 0) {
		memcpy(_varValue, newValue, _varLen);
		return YES;
	}
	return NO;
}

/**
 * Sets the integer content of this uniform from the specified array of floats.
 *
 * If the content of this uniform is integer-based, the specified float array is converted
 * to an integer array, (by converting each float in the float array to an integer), and
 * the setIntegers: method is invoked on the resulting integer array. The original float
 * array remains unchanged during the conversion to integers.
 *
 * If the content of this uniform is float-based, this method delegates to the setFloats: method.
 */
-(void) setIntegersFromFloats: (const GLfloat*) floats {
	GLuint iCnt;
	switch (_type) {
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
			iCnt = _size * 1;
			break;
		case GL_INT_VEC2:
			iCnt = _size * 2;
			break;
		case GL_INT_VEC3:
			iCnt = _size * 3;
			break;
		case GL_INT_VEC4:
			iCnt = _size * 4;
			break;
		default:
			[self setFloats: floats];
			return;
	}
	
	GLint* ints = malloc(iCnt * sizeof(GLint));
	for (int i = 0; i < iCnt; i++) ints[i] = floats[i];
	[self setIntegers: ints];
	free(ints);
}

/**
 * Sets the floating point content of this uniform from the specified array of integers.
 *
 * If the content of this uniform is float-based, the specified integer array is converted
 * to a float array, (by converting each integer in the integer array to a float), and the
 * setFloats: method is invoked on the resulting float array. The original integer array
 * remains unchanged during the conversion to floats.
 *
 * If the content of this uniform is integer-based, this method delegates to the setIntegers: method.
 */
-(void) setFloatsFromIntegers: (const GLint*) ints {
	GLuint fCnt;
	switch (_type) {
		case GL_FLOAT:
			fCnt = _size * 1;
			break;
		case GL_FLOAT_VEC2:
			fCnt = _size * 2;
			break;
		case GL_FLOAT_VEC3:
			fCnt = _size * 3;
			break;
		case GL_FLOAT_VEC4:
			fCnt = _size * 4;
			break;
			
		case GL_FLOAT_MAT2:
			fCnt = _size * 2 * 2;
			break;
		case GL_FLOAT_MAT3:
			fCnt = _size * 3 * 3;
			break;
		case GL_FLOAT_MAT4:
			fCnt = _size *  4 * 4;
			break;

		default:
			[self setIntegers: ints];
			return;
	}
	
	GLfloat* floats = malloc(fCnt * sizeof(GLfloat));
	for (int i = 0; i < fCnt; i++) floats[i] = ints[i];
	[self setFloats: floats];
	free(floats);
}

-(void) setFloat: (GLfloat) value { [self setVector4: CC3Vector4Make(value, 0, 0, 1)]; }

-(void) setCGPoint: (CGPoint) value { [self setVector4: CC3Vector4Make(value.x, value.y, 0, 1)]; }

/** Converts the points to the correct type if needed. */
-(void) setCGPoints: (CGPoint*) values {
	switch (_type) {
		case GL_FLOAT:
		case GL_BOOL:
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE: {
			GLfloat* floats = malloc(_varLen);
			for (int i = 0; i < _size; i++) floats[i] = values[i].x;
			[self setFloats: floats];
			free(floats);
			return;
		}
		case GL_FLOAT_VEC2:
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
			[self setFloats: (GLfloat*)values];
			return;

		case GL_FLOAT_VEC3:
		case GL_INT_VEC3:
		case GL_BOOL_VEC3: {
			CC3Vector* v3s = malloc(_varLen);
			for (int i = 0; i < _size; i++) v3s[i] = cc3v(values[i].x, values[i].y, 0);
			[self setFloats: (GLfloat*)v3s];
			free(v3s);
			return;
		}
		case GL_FLOAT_VEC4:
		case GL_INT_VEC4:
		case GL_BOOL_VEC4: {
			CC3Vector4* v4s = malloc(_varLen);
			for (int i = 0; i < _size; i++) v4s[i] = CC3Vector4Make(values[i].x, values[i].y, 0, 1);
			[self setFloats: (GLfloat*)v4s];
			free(v4s);
			return;
		}
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set vector when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setVector: (CC3Vector) value { [self setVector4: CC3Vector4FromLocation(value)]; }

/** Converts the vectors to the correct type if needed. */
-(void) setVectors: (CC3Vector*) values {
	switch (_type) {
		case GL_FLOAT:
		case GL_BOOL:
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE: {
			GLfloat* floats = malloc(_varLen);
			for (int i = 0; i < _size; i++) floats[i] = values[i].x;
			[self setFloats: floats];
			free(floats);
			return;
		}
		case GL_FLOAT_VEC2:
		case GL_INT_VEC2:
		case GL_BOOL_VEC2: {
			CGPoint* p = malloc(_varLen);
			for (int i = 0; i < _size; i++) p[i] = ccp(values[i].x, values[i].y);
			[self setFloats: (GLfloat*)p];
			free(p);
			return;
		}
		case GL_FLOAT_VEC3:
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
			[self setFloats: (GLfloat*)values];
			return;

		case GL_FLOAT_VEC4:
		case GL_INT_VEC4:
		case GL_BOOL_VEC4: {
			CC3Vector4* v4s = malloc(_varLen);
			for (int i = 0; i < _size; i++) v4s[i] = CC3Vector4FromLocation(values[i]);
			[self setFloats: (GLfloat*)v4s];
			free(v4s);
			return;
		}
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set vector when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setVector4: (CC3Vector4) value {
	NSAssert(_size == 1, @"%@ attempted to set single value when array expected.", self);
	switch (_type) {
		case GL_FLOAT:
		case GL_BOOL:
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
		case GL_FLOAT_VEC2:
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
		case GL_FLOAT_VEC3:
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
		case GL_FLOAT_VEC4:
		case GL_INT_VEC4:
		case GL_BOOL_VEC4:
			[self setFloats: (GLfloat*)&value];
			return;
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set scalar or vector when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

/** Converts the vectors to the correct type if needed. */
-(void) setVector4s: (CC3Vector4*) values {
	switch (_type) {
		case GL_FLOAT:
		case GL_BOOL:
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE: {
			GLfloat* floats = malloc(_varLen);
			for (int i = 0; i < _size; i++) floats[i] = values[i].x;
			[self setFloats: floats];
			free(floats);
			return;
		}
		case GL_FLOAT_VEC2:
		case GL_INT_VEC2:
		case GL_BOOL_VEC2: {
			CGPoint* p = malloc(_varLen);
			for (int i = 0; i < _size; i++) p[i] = ccp(values[i].x, values[i].y);
			[self setFloats: (GLfloat*)p];
			free(p);
			return;
		}
		case GL_FLOAT_VEC3:
		case GL_INT_VEC3:
		case GL_BOOL_VEC3: {
			CC3Vector* v3s = malloc(_varLen);
			for (int i = 0; i < _size; i++) v3s[i] = CC3VectorFromTruncatedCC3Vector4(values[i]);
			[self setFloats: (GLfloat*)v3s];
			free(v3s);
			return;
		}
		case GL_FLOAT_VEC4:
		case GL_INT_VEC4:
		case GL_BOOL_VEC4:
			[self setFloats: (GLfloat*)values];
			return;
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set vector when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setQuaternion: (CC3Quaternion) value { [self setVector4: value]; }

-(void) setQuaternions: (CC3Quaternion*) values { [self setVector4s: values]; }

-(void) setMatrix3x3: (CC3Matrix3x3) value {
	NSAssert(_size == 1, @"%@ attempted to set single value when array expected.", self);
	switch (_type) {
		case GL_FLOAT_MAT3:
			[self setFloats: (GLfloat*)&value];
			return;
		default:
			NSAssert(NO, @"%@ attempted to set 3x3 matrix when other type expected.", self);
			return;
	}
}
	

-(void) setMatrices3x3: (CC3Matrix3x3*) values {
	switch (_type) {
		case GL_FLOAT_MAT3:
			[self setFloats: (GLfloat*)values];
			return;
		default:
			NSAssert(NO, @"%@ attempted to set 3x3 matrix when other type expected.", self);
			return;
	}
}

-(void) setMatrix4x4: (CC3Matrix4x4) value {
	NSAssert(_size == 1, @"%@ attempted to set single value when array expected.", self);
	switch (_type) {
		case GL_FLOAT_MAT4:
			[self setFloats: (GLfloat*)&value];
			return;
		default:
			NSAssert(NO, @"%@ attempted to set 4x4 matrix when other type expected.", self);
			return;
	}
}

-(void) setMatrices4x4: (CC3Matrix4x4*) values {
	switch (_type) {
		case GL_FLOAT_MAT4:
			[self setFloats: (GLfloat*)values];
			return;
		default:
			NSAssert(NO, @"%@ attempted to set 4x4 matrix when other type expected.", self);
			return;
	}
}

-(void) setInteger: (GLint) value {
	NSAssert(_size == 1, @"%@ attempted to set single value when array expected.", self);
	switch (_type) {
		case GL_FLOAT:
		case GL_BOOL:
		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
			[self setIntegers: &value];
			return;
		case GL_FLOAT_VEC2:
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
		case GL_FLOAT_VEC3:
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
		case GL_FLOAT_VEC4:
		case GL_INT_VEC4:
		case GL_BOOL_VEC4: {
			GLint ints[4] = {value, 0, 0, 0};
			[self setIntegers: ints];
			return;
		}
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set integer when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setByte: (GLbyte) value { [self setInteger: value]; }

-(void) setBoolean: (BOOL) value { [self setInteger: value]; }

-(void) setColor: (ccColor3B) value { [self setColor4B: ccc4(value.r, value.g, value.b, 255)]; }

-(void) setColor4B: (ccColor4B) value {
	switch (_type) {
		case GL_INT:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE: {
			GLint ints[4] = {value.r, value.g, value.b, value.a};
			[self setIntegers: ints];
			return;
		}
		case GL_FLOAT:
		case GL_BOOL:
		case GL_FLOAT_VEC2:
		case GL_BOOL_VEC2:
		case GL_FLOAT_VEC3:
		case GL_BOOL_VEC3:
		case GL_FLOAT_VEC4:
		case GL_BOOL_VEC4: {
			[self setColor4F: CCC4FFromCCC4B(value)];
			return;
		}
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set color when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

-(void) setColor4F: (ccColor4F) value {
	switch (_type) {
		case GL_INT:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
			[self setColor4B: CCC4BFromCCC4F(value)];
			return;
		case GL_FLOAT:
		case GL_BOOL:
		case GL_FLOAT_VEC2:
		case GL_BOOL_VEC2:
		case GL_FLOAT_VEC3:
		case GL_BOOL_VEC3:
		case GL_FLOAT_VEC4:
		case GL_BOOL_VEC4: {
			[self setFloats: (GLfloat*)&value];
			return;
		}
		case GL_FLOAT_MAT2:
		case GL_FLOAT_MAT3:
		case GL_FLOAT_MAT4:
			NSAssert(NO, @"%@ attempted to set color when matrix expected.", self);
			return;
		default:
			NSAssert2(NO, @"%@ could not set value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerGLSLAttribute

@implementation CC3OpenGLESStateTrackerGLSLAttribute


#pragma mark Allocation and initialization

-(id) initInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	if ( (self = [super initInProgram: program atIndex: index]) ) {
		[self populateFromProgram];
	}
	return self;
}

#if CC3_OGLES_2

-(void) populateFromProgram {
	_semantic = kCC3SemanticNone;
	
	GLint maxNameLen = [_program maxAttributeNameLength];
	char* cName = calloc(maxNameLen, sizeof(char));
	
	glGetActiveAttrib(_program.program, _index, maxNameLen, NULL, &_size, &_type, cName);
	LogGLErrorTrace(@"while retrieving spec for attribute at index %i in %@", _index, self);
	
	_location = glGetAttribLocation(_program.program, cName);
	LogGLErrorTrace(@"while retrieving location of attribute named %s at index %i in %@", cName, _index, self);
	
	[_name release];
	_name = [[NSString stringWithUTF8String: cName] retain];	// retained
	free(cName);
}

#endif

#if CC3_OGLES_1

-(void) populateFromProgram {}

#endif

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerGLSLUniform

@implementation CC3OpenGLESStateTrackerGLSLUniform

-(id) initInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	if ( (self = [super initInProgram: program atIndex: index]) ) {
		[self populateFromProgram];
	}
	return self;
}

#if CC3_OGLES_2

-(void) populateFromProgram {
	_semantic = 0;
	
	GLint maxNameLen = [_program maxUniformNameLength];
	char* cName = calloc(maxNameLen, sizeof(char));
	
	glGetActiveUniform(_program.program, _index, maxNameLen, NULL, &_size, &_type, cName);
	LogGLErrorTrace(@"while retrieving spec for active uniform at index %i in %@", _index, self);
	
	_varLen = GLElementTypeSize(_type) * _size;
	free(_varValue);
	_varValue = calloc(_varLen, 1);
	
	_location = glGetUniformLocation(_program.program, cName);
	LogGLErrorTrace(@"while retrieving location of active uniform named %s at index %i in %@", cName, _index, self);
	
	[_name release];
	_name = [[NSString stringWithUTF8String: cName] retain];	// retained
	free(cName);
}

/** Overridden to update the GL state engine if the value was changed. */
-(BOOL) updateValue: (const GLvoid*) newValue {
	BOOL wasChanged = [super updateValue: newValue];
	if (wasChanged) [self setGLValue];
	return wasChanged;
}

-(void) setGLValue {
	switch (_type) {
			
		case GL_FLOAT:
			glUniform1fv(_location, _size, _varValue);
			return;
		case GL_FLOAT_VEC2:
			glUniform2fv(_location, _size, _varValue);
			return;
		case GL_FLOAT_VEC3:
			glUniform3fv(_location, _size, _varValue);
			return;
		case GL_FLOAT_VEC4:
			glUniform4fv(_location, _size, _varValue);
			return;
			
		case GL_FLOAT_MAT2:
			glUniformMatrix2fv(_location, _size, GL_FALSE, _varValue);
			return;
		case GL_FLOAT_MAT3:
			glUniformMatrix3fv(_location, _size, GL_FALSE, _varValue);
			return;
		case GL_FLOAT_MAT4:
			glUniformMatrix4fv(_location, _size, GL_FALSE, _varValue);
			return;

		case GL_INT:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
		case GL_BOOL:
			glUniform1iv(_location, _size, _varValue);
			return;
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
			glUniform2iv(_location, _size, _varValue);
			return;
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
			glUniform3iv(_location, _size, _varValue);
			return;
		case GL_INT_VEC4:
		case GL_BOOL_VEC4:
			glUniform4iv(_location, _size, _varValue);
			return;
			
		default:
			NSAssert2(NO, @"%@ could not set GL engine state value because type %@ is not understood",
					  self, NSStringFromGLEnum(_type));
			return;
	}
}

#endif


#if CC3_OGLES_1

-(void) populateFromProgram {}

#endif
@end

