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
		[self populateFromProgram];
	}
	return self;
}

+(id) variableInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	return [[[self alloc] initInProgram: program atIndex: index] autorelease];
}

-(void) populateFromProgram {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ named %@ for semantic %@ of type %@ and size %i at index %i and location %i",
			self.class, _name, self.semanticName, NSStringFromGLEnum(_type), _size, _index, _location];
}

-(NSString*) fullDescription { return [NSString stringWithFormat: @"%@ in program %@", self, _program]; }

-(NSString*) semanticName { return nil; }

@end


#pragma mark -
#pragma mark CC3GLSLAttribute

@implementation CC3GLSLAttribute

-(NSString*) semanticName { return [_program.semanticDelegate nameOfAttributeSemantic: _semantic]; }

#if CC3_OGLES_2

-(void) populateFromProgram {
	_semantic = kCC3VertexContentSemanticNone;

	GLint maxNameLen = [_program maxAttributeNameLength];
	char* cName = calloc(maxNameLen, sizeof(char));

	glGetActiveAttrib(_program.program, _location, maxNameLen, NULL, &_size, &_type, cName);
	LogGLErrorTrace(@"while retrieving spec for attribute at index %i in %@", _index, self);
	
	_location = glGetAttribLocation(_program.program, cName);
	LogGLErrorTrace(@"while retrieving location of attribute named %s at index %i in %@", cName, _index, self);

	[_name release];
	_name = [[NSString stringWithUTF8String: cName] retain];	// retained
	free(cName);
}

#endif

@end


#pragma mark -
#pragma mark CC3GLSLUniform

@implementation CC3GLSLUniform

-(void) dealloc {
	free(_varState);
	[super dealloc];
}


#pragma mark Allocation and initialization

-(id) initInProgram: (CC3GLProgram*) program atIndex: (GLuint) index {
	_varState = NULL;		// Init before super because super invokes populateFromProgram:
	return [super initInProgram: program atIndex: index];
}

-(NSString*) semanticName { return [_program.semanticDelegate nameOfUniformSemantic: _semantic]; }

#if CC3_OGLES_2

-(void) populateFromProgram {
	_semantic = 0;
	
	GLint maxNameLen = [_program maxUniformNameLength];
	char* cName = calloc(maxNameLen, sizeof(char));
	
	glGetActiveUniform(_program.program, _index, maxNameLen, NULL, &_size, &_type, cName);
	LogGLErrorTrace(@"while retrieving spec for active uniform at index %i in %@", _index, self);

	_varLen = GLElementTypeSize(_type) * _size;
	free(_varState);
	_varState = calloc(_size, GLElementTypeSize(_type));

	_location = glGetUniformLocation(_program.program, cName);
	LogGLErrorTrace(@"while retrieving location of active uniform named %s at index %i in %@", cName, _index, self);
	
	[_name release];
	_name = [[NSString stringWithUTF8String: cName] retain];	// retained
	free(cName);
}

-(void) setFloats: (const GLfloat*) floats {
	switch (_type) {

		case GL_FLOAT:
		case GL_BOOL:
			if ( [self shouldUpdateState: floats] ) glUniform1fv(_location, _size, _varState);
			return;
		case GL_FLOAT_VEC2:
		case GL_BOOL_VEC2:
			if ( [self shouldUpdateState: floats] ) glUniform2fv(_location, _size, _varState);
			return;
		case GL_FLOAT_VEC3:
		case GL_BOOL_VEC3:
			if ( [self shouldUpdateState: floats] ) glUniform3fv(_location, _size, _varState);
			return;
		case GL_FLOAT_VEC4:
		case GL_BOOL_VEC4:
			if ( [self shouldUpdateState: floats] ) glUniform4fv(_location, _size, _varState);
			return;
			
		case GL_FLOAT_MAT2:
			if ( [self shouldUpdateState: floats] ) glUniformMatrix2fv(_location, _size, GL_FALSE, _varState);
			return;
		case GL_FLOAT_MAT3:
			if ( [self shouldUpdateState: floats] ) glUniformMatrix3fv(_location, _size, GL_FALSE, _varState);
			return;
		case GL_FLOAT_MAT4:
			if ( [self shouldUpdateState: floats] ) glUniformMatrix4fv(_location, _size, GL_FALSE, _varState);
			return;

		case GL_INT:
		case GL_INT_VEC2:
		case GL_INT_VEC3:
		case GL_INT_VEC4:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_CUBE:
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
			if ( [self shouldUpdateState: ints] ) glUniform1iv(_location, _size, _varState);
			return;
		case GL_INT_VEC2:
		case GL_BOOL_VEC2:
			if ( [self shouldUpdateState: ints] ) glUniform2iv(_location, _size, _varState);
			return;
		case GL_INT_VEC3:
		case GL_BOOL_VEC3:
			if ( [self shouldUpdateState: ints] ) glUniform3iv(_location, _size, _varState);
			return;
		case GL_INT_VEC4:
		case GL_BOOL_VEC4:
			if ( [self shouldUpdateState: ints] ) glUniform4iv(_location, _size, _varState);
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

/** 
 * Checks whether the specified new state content is different than the current cached GL state
 * for this uniform variable, updates the cached state content if it is, and returns YES if
 * the new state content was different, or NO if it was not.
 */
-(BOOL) shouldUpdateState: (const GLvoid*) newState {
	if (memcmp(newState, _varState, _varLen) != 0) {
		memcpy(_varState, newState, _varLen);
		return YES;
	}
	return NO;
}

-(void) setFloat: (GLfloat) value { [self setVector4: CC3Vector4Make(value, 0, 0, 1)]; }

-(void) setCGPoint: (CGPoint) value { [self setVector4: CC3Vector4Make(value.x, value.y, 0, 1)]; }

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

-(void) setVector: (CC3Vector) value { [self setVector4: CC3Vector4FromCC3Vector(value, 1)]; }

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
			for (int i = 0; i < _size; i++) v4s[i] = CC3Vector4FromCC3Vector(values[i], 1);
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

#endif

#if CC3_OGLES_1

-(void) setFloats: (const GLfloat*) floats {}

-(void) setIntegers: (const GLint*) ints {}

-(void) setFloat: (GLfloat) value {}

-(void) setCGPoint: (CGPoint) value {}

-(void) setCGPoints: (CGPoint*) values {}

-(void) setVector: (CC3Vector) value {}

-(void) setVectors: (CC3Vector*) values {}

-(void) setVector4: (CC3Vector4) value {}

-(void) setVector4s: (CC3Vector4*) values {}

-(void) setQuaternion: (CC3Quaternion) value {}

-(void) setQuaternions: (CC3Quaternion*) values {}

-(void) setMatrix3x3: (CC3Matrix3x3) value {}

-(void) setMatrices3x3: (CC3Matrix3x3*) values {}

-(void) setMatrix4x4: (CC3Matrix4x4) value {}

-(void) setMatrices4x4: (CC3Matrix4x4*) values {}

-(void) setInteger: (GLint) value {}

-(void) setByte: (GLbyte) value {}

-(void) setBoolean: (BOOL) value {}

-(void) setColor: (ccColor3B) value {}

-(void) setColor4B: (ccColor4B) value {}

-(void) setColor4F: (ccColor4F) value {}

#endif

@end
