/*
 * CC3GLSLVariable.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Foundation.h"
#import "CC3OpenGLESUtility.h"
#import "CC3Matrix4x4.h"

@class CC3GLProgram;

#pragma mark -
#pragma mark CC3GLSLVariable

/**
 * Represents a variable used in a GLSL shader program. Different subclasses are used for
 * uniform variables and attribute variables.
 */
@interface CC3GLSLVariable : NSObject <NSCopying> {
	CC3GLProgram* _program;
	NSString* _name;
	GLuint _index;
	GLint _location;
	GLenum _type;
	GLint _size;
	GLenum _semantic;
}

/** The GL program object containing this variable. */
@property(nonatomic, assign, readonly) CC3GLProgram* program;

/**
 * The index of this variable within the GL program object.
 * This is distinct from the location property.
 */
@property(nonatomic, assign, readonly) GLuint index;

/** 
 * The location of this variable within the GL program object.
 * This is distinct from the index property.
 */
@property(nonatomic, assign, readonly) GLint location;

/** The name of this variable in the GLSL shader source code. */
@property(nonatomic, retain, readonly) NSString* name;

/**
 * Returns a symbolic constant indicating the type of content held by this variable.
 *
 * The returned value depends on the type of variable being tracked, as determined by the
 * subclass. See the notes for this property in each subclass for more specific information.
 */
@property(nonatomic, readonly) GLenum type;

/** 
 * Returns the size of the variable content, in units of the type indicated by the type property.
 *
 * If the variable is an array, this property will return the size of that array in the GLSL
 * program, otherwise it will return the value 1.
 */
@property(nonatomic, readonly) GLint size;

/**
 * A symbolic constant indicating the semantic meaning of this variable.
 *
 * The value of this property is typically one of values in the CC3Semantic enumeration,
 * but an application can define and use additional semantics beyond the values defined
 * by CC3Semantic. Additional semantics defined by the application should fall with the
 * range defined by the kCC3SemanticAppBase and kCC3SemanticMax constants, inclusively.
 *
 * The initial value of this property is kCC3SemanticNone.
 */
@property(nonatomic, assign) GLenum semantic;


#pragma mark Allocation and initialization

/** Initializes this instance at the specified index within the specified program. */
-(id) initInProgram: (CC3GLProgram*) program atIndex: (GLuint) index;

/** Allocates and initializes an autoreleased instance at the specified index within the specified program. */
+(id) variableInProgram: (CC3GLProgram*) program atIndex: (GLuint) index;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will be an instance
 * of the specified class, whose content is copied from this instance.
 *
 * Care should be taken when choosing the class to be instantiated. If the class is different
 * than that of this instance, the populateFrom: method of that class must be compatible with
 * the contents of this instance.
 *
 * As with all copy behaviour, the returned instance is retained. It is the responsiblity of the
 * invoker to manage the lifecycle of the returned instance and perform the corresponding invocation
 * of the release method at the appropriate time.
 *
 * Subclasses that extend copying should not override this method, but should override the
 * populateFrom: method instead.
 */
-(id) copyAsClass: (Class) aClass;

/**
 * Returns a newly allocated (retained) copy of this instance. The new copy will be an instance
 * of the specified class, whose content is copied from this instance.
 *
 * Care should be taken when choosing the class to be instantiated. If the class is different
 * than that of this instance, the populateFrom: method of that class must be compatible with
 * the contents of this instance.
 *
 * As with all copy behaviour, the returned instance is retained. It is the responsiblity of the
 * invoker to manage the lifecycle of the returned instance and perform the corresponding invocation
 * of the release method at the appropriate time.
 *
 * Subclasses that extend copying should not override this method, but should override the
 * populateFrom: method instead.
 */
-(id) copyWithZone: (NSZone*) zone asClass: (Class) aClass;

/**
 * Template method that populates this instance from the specified other instance.
 *
 * This method is invoked automatically during object copying via the copy or copyWithZone: method.
 * In most situations, the application should use the copy method, and should never need to invoke
 * this method directly.
 *
 * Subclasses that add additional instance state (instance variables) should extend copying by
 * overriding this method to copy that additional state. Superclass that override this method should
 * be sure to invoke the superclass implementation to ensure that superclass state is copied as well.
 */
-(void) populateFrom: (CC3GLSLVariable*) another;

/** Returns a detailed description of this instance. */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark CC3GLSLAttribute

/** Represents an attribute variable used in a GLSL shader program.  */
@interface CC3GLSLAttribute : CC3GLSLVariable

/**
 * Returns a symbolic constant indicating the type of content held by this variable.
 *
 * The returned value will be one of the following symbolic constants:
 *   - GL_FLOAT, GL_FLOAT_VEC2, GL_FLOAT_VEC3, GL_FLOAT_VEC4,
 *   - GL_FLOAT_MAT2, GL_FLOAT_MAT3, or GL_FLOAT_MAT4
 */
@property(nonatomic, readonly) GLenum type;

@end


#pragma mark -
#pragma mark CC3GLSLUniform

/** Represents a uniform variable used in a GLSL shader program.  */
@interface CC3GLSLUniform : CC3GLSLVariable {
	size_t _varLen;
	GLvoid* _varValue;
}

/**
 * Returns a symbolic constant indicating the type of content held by this variable.
 *
 * The returned value will be one of the following symbolic constants:
 *   - GL_FLOAT, GL_FLOAT_VEC2, GL_FLOAT_VEC3, GL_FLOAT_VEC4,
 *   - GL_INT, GL_INT_VEC2, GL_INT_VEC3, GL_INT_VEC4,
 *   - GL_BOOL, GL_BOOL_VEC2, GL_BOOL_VEC3, GL_BOOL_VEC4,
 *   - GL_FLOAT_MAT2, GL_FLOAT_MAT3, GL_FLOAT_MAT4,
 *   - GL_SAMPLER_2D, GL_SAMPLER_CUBE
 */
@property(nonatomic, readonly) GLenum type;


#pragma mark Accessing uniform values

/**
 * Sets the value of this uniform variable in the GL engine to the specified array of floats.
 *
 * The number of floats required is determined by the type and size properties of this instance,
 * and the specified array must contain at least that many elements.
 *
 * If the type property indicates that this instance is float-based (including float matrix
 * types) or boolean-based, and the values are different than previously set, the values are
 * sent to the GL engine.
 *
 * If the type property indicates that this instance is integer-based, the values are first
 * converted to integers (on a one-by-one basis) and the setIntegers: method is invoked with
 * the resulting integer array.
 *
 * This is one of two primary setter methods (the other being setIntegers:). All other uniform
 * value setter methods invoke one of these two primary methods.
 */
-(void) setFloats: (const GLfloat*) floats;

/**
 * Sets the value of this uniform variable in the GL engine to the specified array of integers.
 *
 * The number of integers required is determined by the type and size properties of this instance,
 * and the specified array must contain at least that many elements.
 *
 * If the type property indicates that this instance is integers-based or boolean-based, and the
 * values are different than previously set, the values are sent to the GL engine.
 *
 * If the type property indicates that this instance is float-based, the values are first converted
 * to floats (on a one-by-one basis) and the setFloats: method is invoked with the resulting float array.
 *
 * This is one of two primary setter methods (the other being setFloats:). All other uniform
 * value setter methods invoke one of these two primary methods.
 */
-(void) setIntegers: (const GLint*) ints;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the float is converted to an integer.
 * If the type property indicates a vector type with more than one component, the second
 * and third components are set to zero and the fourth component is set to one.
 *
 * The size property of this instance must be 1.
 */
-(void) setFloat: (GLfloat) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of the specified point is used.
 * If the type property indicates a vector type with more than two components, the third
 * component is set to zero and the fourth component is set to one.
 *
 * The size property of this instance must be 1.
 */
-(void) setCGPoint: (CGPoint) value;

/**
 * Sets the value of this uniform in the GL engine to the specified array.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of each point is used. If the
 * type property indicates a vector type with more than two components, the third component
 * is set to zero and the fourth component of each vector is set to one, in each vector.
 *
 * The length of the specified array must be at least as large as the size property of this instance.
 */
-(void) setCGPoints: (CGPoint*) values;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of the specified vector is used.
 * If the type property indicates a vector type with fewer than three components, the X & Y
 * components will be used. If the type property indicates a vector type with more than three
 * components, fourth component is set to one.
 *
 * The size property of this instance must be 1.
 */
-(void) setVector: (CC3Vector) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of each vector is used.
 * If the type property indicates a vector type with fewer than three components, the X & Y
 * components of each vector are used. If the type property indicates a vector type with
 * more than three components, fourth component of each vector is set to one.
 *
 * The length of the specified array must be at least as large as the size property of this instance.
 */
-(void) setVectors: (CC3Vector*) values;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of the specified vector is used.
 * If the type property indicates a vector type with fewer than four components, the X & Y,
 * or X, Y & Z components are used.
 *
 * The size property of this instance must be 1.
 */
-(void) setVector4: (CC3Vector4) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of each vector is used.
 * If the type property indicates a vector type with fewer than four components, the X & Y,
 * or X, Y & Z components of each vector are used.
 *
 * The length of the specified array must be at least as large as the size property of this instance.
 */
-(void) setVector4s: (CC3Vector4*) values;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of the specified vector is used.
 * If the type property indicates a vector type with fewer than four components, the X & Y,
 * or X, Y & Z components are used.
 *
 * The size property of this instance must be 1.
 */
-(void) setQuaternion: (CC3Quaternion) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers.
 * If the type property indicates a scalar, the X component of each vector is used.
 * If the type property indicates a vector type with fewer than four components, the X & Y,
 * or X, Y & Z components of each vector are used.
 *
 * The length of the specified array must be at least as large as the size property of this instance.
 */
-(void) setQuaternions: (CC3Quaternion*) values;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance must be GL_FLOAT_MAT3.
 *
 * The size property of this instance must be 1.
 */
-(void) setMatrix3x3: (CC3Matrix3x3) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance must be GL_FLOAT_MAT3.
 *
 * The length of the specified array must be at least as large as the size property of this instance.
 */
-(void) setMatrices3x3: (CC3Matrix3x3*) values;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance must be GL_FLOAT_MAT4.
 *
 * The size property of this instance must be 1.
 */
-(void) setMatrix4x4: (CC3Matrix4x4) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance must be GL_FLOAT_MAT4.
 *
 * The length of the specified array must be at least as large as the size property of this instance.
 */
-(void) setMatrices4x4: (CC3Matrix4x4*) values;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an float type, the integer is converted to a float.
 * If the type property indicates a vector type with more than one component, the remaining
 * components are set to zero.
 *
 * The size property of this instance must be 1.
 */
-(void) setInteger: (GLint) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an float type, the integer is converted to a float.
 * If the type property indicates a vector type with more than one component, the remaining
 * components are set to zero.
 *
 * The size property of this instance must be 1.
 */
-(void) setByte: (GLbyte) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an float type, the integer is converted to a float.
 * If the type property indicates a vector type with more than one component, the remaining
 * components are set to GL_FALSE.
 *
 * The size property of this instance must be 1.
 */
-(void) setBoolean: (BOOL) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an float type, the integers are normalized to floats between
 * 0 and 1. If the type property indicates a scalar, the R component of the specified color is
 * used. If the type property indicates a vector type with fewer than three components, the
 * R & G components are used. If the type property indicates a vector type with four components,
 * the A component is set to 255.
 *
 * The size property of this instance must be 1.
 */
-(void) setColor: (ccColor3B) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an float type, the integers are normalized to floats between
 * 0 and 1. If the type property indicates a scalar, the R component of the specified color is used.
 * If the type property indicates a vector type with fewer than four components, the R & G,
 * or R, G & B components are used.
 *
 * The size property of this instance must be 1.
 */
-(void) setColor4B: (ccColor4B) value;

/**
 * Sets the value of this uniform in the GL engine to the specified value.
 *
 * The type property of this instance can be any value other than one of matrix types.
 * If the type property indicates an integer type, the floats are converted to integers
 * in the range 0 to 255. If the type property indicates a scalar, the R component of the
 * specified color is used. If the type property indicates a vector type with fewer than
 * four components, the R & G, or R, G & B components are used.
 *
 * The size property of this instance must be 1.
 */
-(void) setColor4F: (ccColor4F) value;

/** Sets the value of the specified uniform from the value of this uniform. */
-(void) setValueInto: (CC3GLSLUniform*) uniform;

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerGLSLAttribute

/** Tracks the GL engine state for a attribute variable used in a GLSL shader program.  */
@interface CC3OpenGLESStateTrackerGLSLAttribute : CC3GLSLAttribute
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerGLSLUniform

/**
 * Tracks the GL engine state for a uniform variable used in a GLSL shader program.
 *
 * Adds the ability to set the variable value in the GL engine.
 *
 * All of the set... methods permit the writing of new state regardless of the semantic.
 */
@interface CC3OpenGLESStateTrackerGLSLUniform : CC3GLSLUniform
@end

