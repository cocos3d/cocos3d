/*
 * CC3OpenGLFixedPipeline.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3OpenGL.h"

#if !CC3_GLSL

#define kMAX_GL_LIGHTS					8
#define kMAX_VTX_ATTRS_EX_TEXCOORD		6


/** CC3OpenGLFixedPipeline manages the OpenGLES 1.1 state for a single GL context. */
@interface CC3OpenGLFixedPipeline : CC3OpenGL {
@public
	
	GLuint value_NumNonTexVertexAttribs;

	GLbitfield value_GL_CLIP_PLANE;					// Track up to 32 clip planes
	GLbitfield isKnownCap_GL_CLIP_PLANE;			// Track up to 32 clip planes

	GLbitfield value_GL_TEXTURE_2D;					// Track up to 32 texture units
	GLbitfield isKnownCap_GL_TEXTURE_2D;			// Track up to 32 texture units
	
	GLbitfield value_GL_TEXTURE_COORD_ARRAY;		// Track up to 32 texture units
	GLbitfield isKnownCap_GL_TEXTURE_COORD_ARRAY;	// Track up to 32 texture units
	
	GLenum* values_GL_TEXTURE_ENV_MODE;
	GLbitfield isKnown_GL_TEXTURE_ENV_MODE;			// Track up to 32 texture units

	ccColor4F* values_GL_TEXTURE_ENV_COLOR;
	GLbitfield isKnown_GL_TEXTURE_ENV_COLOR;		// Track up to 32 texture units
	
	ccColor4F value_GL_CURRENT_COLOR;

	GLfloat value_GL_POINT_SIZE;
	CC3AttenuationCoefficients value_GL_POINT_DISTANCE_ATTENUATION;
	GLfloat value_GL_POINT_FADE_THRESHOLD_SIZE;
	GLfloat value_GL_POINT_SIZE_MIN;
	GLfloat value_GL_POINT_SIZE_MAX;
	GLenum value_GL_SHADE_MODEL;

	ccColor4F valueMat_GL_AMBIENT;
	ccColor4F valueMat_GL_DIFFUSE;
	ccColor4F valueMat_GL_SPECULAR;
	ccColor4F valueMat_GL_EMISSION;
	GLfloat valueMat_GL_SHININESS;
	GLenum value_GL_ALPHA_TEST_FUNC;
	GLfloat value_GL_ALPHA_TEST_REF;

	ccColor4F value_GL_LIGHT_MODEL_AMBIENT;
	GLbitfield value_GL_LIGHT;									// Track up to 32 lights
	GLbitfield isKnownCap_GL_LIGHT;								// Track up to 32 lights
	ccColor4F valueLight_GL_AMBIENT[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_AMBIENT;							// Track up to 32 lights
	ccColor4F valueLight_GL_DIFFUSE[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_DIFFUSE;							// Track up to 32 lights
	ccColor4F valueLight_GL_SPECULAR[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_SPECULAR;						// Track up to 32 lights
	CC3Vector4 valueLight_GL_POSITION[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_POSITION;						// Track up to 32 lights

	GLfloat valueLight_GL_CONSTANT_ATTENUATION[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_CONSTANT_ATTENUATION;			// Track up to 32 lights
	GLfloat valueLight_GL_LINEAR_ATTENUATION[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_LINEAR_ATTENUATION;				// Track up to 32 lights
	GLfloat valueLight_GL_QUADRATIC_ATTENUATION[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_QUADRATIC_ATTENUATION;			// Track up to 32 lights
	CC3Vector valueLight_GL_SPOT_DIRECTION[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_SPOT_DIRECTION;					// Track up to 32 lights
	GLfloat valueLight_GL_SPOT_EXPONENT[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_SPOT_EXPONENT;					// Track up to 32 lights
	GLfloat valueLight_GL_SPOT_CUTOFF[kMAX_GL_LIGHTS];
	GLbitfield isKnownLight_GL_SPOT_CUTOFF;						// Track up to 32 lights

	ccColor4F value_GL_FOG_COLOR;
	GLenum value_GL_FOG_MODE;
	GLfloat value_GL_FOG_DENSITY;
	GLfloat value_GL_FOG_START;
	GLfloat value_GL_FOG_END;

	GLenum value_GL_FOG_HINT;
	GLenum value_GL_LINE_SMOOTH_HINT;
	GLenum value_GL_PERSPECTIVE_CORRECTION_HINT;
	GLenum value_GL_POINT_SMOOTH_HINT;

	GLuint value_GL_CLIENT_ACTIVE_TEXTURE;
	
	GLenum value_GL_MATRIX_MODE;
	GLuint value_GL_MATRIX_PALETTE;

	BOOL value_GL_LIGHT_MODEL_TWO_SIDE : 1;

	BOOL valueCap_GL_ALPHA_TEST : 1;
	BOOL valueCap_GL_COLOR_LOGIC_OP : 1;
	BOOL valueCap_GL_COLOR_MATERIAL : 1;
	BOOL valueCap_GL_FOG : 1;
	BOOL valueCap_GL_LIGHTING : 1;
	BOOL valueCap_GL_LINE_SMOOTH : 1;
	BOOL valueCap_GL_MATRIX_PALETTE : 1;
	BOOL valueCap_GL_MULTISAMPLE : 1;
	BOOL valueCap_GL_NORMALIZE : 1;
	BOOL valueCap_GL_POINT_SMOOTH : 1;
	BOOL valueCap_GL_RESCALE_NORMAL : 1;
	BOOL valueCap_GL_SAMPLE_ALPHA_TO_ONE : 1;
	
	BOOL isKnownCap_GL_ALPHA_TEST : 1;
	BOOL isKnownCap_GL_COLOR_LOGIC_OP : 1;
	BOOL isKnownCap_GL_COLOR_MATERIAL : 1;
	BOOL isKnownCap_GL_FOG : 1;
	BOOL isKnownCap_GL_LIGHTING : 1;
	BOOL isKnownCap_GL_LINE_SMOOTH : 1;
	BOOL isKnownCap_GL_MATRIX_PALETTE : 1;
	BOOL isKnownCap_GL_MULTISAMPLE : 1;
	BOOL isKnownCap_GL_NORMALIZE : 1;
	BOOL isKnownCap_GL_POINT_SMOOTH : 1;
	BOOL isKnownCap_GL_RESCALE_NORMAL : 1;
	BOOL isKnownCap_GL_SAMPLE_ALPHA_TO_ONE : 1;

	BOOL isKnown_GL_CURRENT_COLOR : 1;
	BOOL isKnown_GL_POINT_SIZE : 1;
	BOOL isKnown_GL_POINT_DISTANCE_ATTENUATION : 1;
	BOOL isKnown_GL_POINT_FADE_THRESHOLD_SIZE : 1;
	BOOL isKnown_GL_POINT_SIZE_MIN : 1;
	BOOL isKnown_GL_POINT_SIZE_MAX : 1;
	BOOL isKnown_GL_SHADE_MODEL : 1;
	
	BOOL isKnownMat_GL_SPECULAR : 1;
	BOOL isKnownMat_GL_EMISSION : 1;
	BOOL isKnownMat_GL_SHININESS : 1;
	BOOL isKnownAlphaFunc : 1;

	BOOL isKnown_GL_LIGHT_MODEL_AMBIENT : 1;
	BOOL isKnown_GL_LIGHT_MODEL_TWO_SIDE : 1;
	BOOL isKnown_GL_FOG_COLOR : 1;
	BOOL isKnown_GL_FOG_MODE : 1;
	BOOL isKnown_GL_FOG_DENSITY : 1;
	BOOL isKnown_GL_FOG_START : 1;
	BOOL isKnown_GL_FOG_END : 1;

	BOOL isKnown_GL_FOG_HINT : 1;
	BOOL isKnown_GL_LINE_SMOOTH_HINT : 1;
	BOOL isKnown_GL_PERSPECTIVE_CORRECTION_HINT : 1;
	BOOL isKnown_GL_POINT_SMOOTH_HINT : 1;

	BOOL isKnown_GL_CLIENT_ACTIVE_TEXTURE : 1;
	
	BOOL isKnown_GL_MATRIX_MODE : 1;
	BOOL isKnown_GL_MATRIX_PALETTE : 1;

}


@end

#endif	// !CC3_GLSL
