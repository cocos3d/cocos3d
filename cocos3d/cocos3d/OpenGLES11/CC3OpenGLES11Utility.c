/*
 * CC3OpenGLES11Utility.c
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLES11Utility.h for full API documentation.
 */

#include "CC3OpenGLES11Utility.h"


char* GLEnumName(GLenum gle) {
	switch (gle) {
		case GL_ZERO: return "GL_ZERO";
		case GL_ONE: return "GL_ONE";
//		case GL_TRUE: return "GL_TRUE";
//		case GL_FALSE: return "GL_FALSE";
			
		// Drawing Mode
//		case GL_POINTS: return "GL_POINTS";
//		case GL_LINES: return "GL_LINES";
		case GL_LINE_LOOP: return "GL_LINE_LOOP";
		case GL_LINE_STRIP: return "GL_LINE_STRIP";
		case GL_TRIANGLES: return "GL_TRIANGLES";
		case GL_TRIANGLE_STRIP: return "GL_TRIANGLE_STRIP";
		case GL_TRIANGLE_FAN: return "GL_TRIANGLE_FAN";

		// Alpha and Depth Function
		case GL_DEPTH_FUNC: return "GL_DEPTH_FUNC";
		case GL_NEVER: return "GL_NEVER";
		case GL_LESS: return "GL_LESS";
		case GL_EQUAL: return "GL_EQUAL";
		case GL_LEQUAL: return "GL_LEQUAL";
		case GL_GREATER: return "GL_GREATER";
		case GL_NOTEQUAL: return "GL_NOTEQUAL";
		case GL_GEQUAL: return "GL_GEQUAL";
		case GL_ALWAYS: return "GL_ALWAYS";

		case GL_POLYGON_OFFSET_FACTOR: return "GL_POLYGON_OFFSET_FACTOR";
		case GL_POLYGON_OFFSET_UNITS: return "GL_POLYGON_OFFSET_UNITS";
			
		// Blending
//		case GL_ZERO: return "GL_ZERO";
//		case GL_ONE: return "GL_ONE";
		case GL_SRC_COLOR: return "GL_SRC_COLOR";
		case GL_ONE_MINUS_SRC_COLOR: return "GL_ONE_MINUS_SRC_COLOR";
		case GL_SRC_ALPHA: return "GL_SRC_ALPHA";
		case GL_ONE_MINUS_SRC_ALPHA: return "GL_ONE_MINUS_SRC_ALPHA";
		case GL_DST_ALPHA: return "GL_DST_ALPHA";
		case GL_ONE_MINUS_DST_ALPHA: return "GL_ONE_MINUS_DST_ALPHA";
		case GL_DST_COLOR: return "GL_DST_COLOR";
		case GL_ONE_MINUS_DST_COLOR: return "GL_ONE_MINUS_DST_COLOR";
		case GL_SRC_ALPHA_SATURATE: return "GL_SRC_ALPHA_SATURATE";

		// Cull face mode
		case GL_CULL_FACE_MODE: return "GL_CULL_FACE_MODE";
		case GL_FRONT: return "GL_FRONT";
		case GL_BACK: return "GL_BACK";
		case GL_FRONT_AND_BACK: return "GL_FRONT_AND_BACK";
			
		// Capabilities
		case GL_FOG: return "GL_FOG";
		case GL_LIGHTING: return "GL_LIGHTING";
		case GL_TEXTURE_2D: return "GL_TEXTURE_2D";
		case GL_CULL_FACE: return "GL_CULL_FACE";
		case GL_ALPHA_TEST: return "GL_ALPHA_TEST";
		case GL_BLEND: return "GL_BLEND";
		case GL_COLOR_LOGIC_OP: return "GL_COLOR_LOGIC_OP";
		case GL_DITHER: return "GL_DITHER";
		case GL_STENCIL_TEST: return "GL_STENCIL_TEST";
		case GL_DEPTH_TEST: return "GL_DEPTH_TEST";
		case GL_DEPTH_WRITEMASK: return "GL_DEPTH_WRITEMASK";
		case GL_POINT_SMOOTH: return "GL_POINT_SMOOTH";
		case GL_POINT_SPRITE_OES: return "GL_POINT_SPRITE_OES";
		case GL_LINE_SMOOTH: return "GL_LINE_SMOOTH";
		case GL_SCISSOR_TEST: return "GL_SCISSOR_TEST";
		case GL_COLOR_MATERIAL: return "GL_COLOR_MATERIAL";
		case GL_NORMALIZE: return "GL_NORMALIZE";
		case GL_RESCALE_NORMAL: return "GL_RESCALE_NORMAL";
		case GL_POLYGON_OFFSET_FILL: return "GL_POLYGON_OFFSET_FILL";
		case GL_VERTEX_ARRAY: return "GL_VERTEX_ARRAY";
		case GL_NORMAL_ARRAY: return "GL_NORMAL_ARRAY";
		case GL_COLOR_ARRAY: return "GL_COLOR_ARRAY";
		case GL_POINT_SIZE_ARRAY_OES: return "GL_POINT_SIZE_ARRAY_OES";
		case GL_TEXTURE_COORD_ARRAY: return "GL_TEXTURE_COORD_ARRAY";
		case GL_MULTISAMPLE: return "GL_MULTISAMPLE";
		case GL_SAMPLE_ALPHA_TO_COVERAGE: return "GL_SAMPLE_ALPHA_TO_COVERAGE";
		case GL_SAMPLE_ALPHA_TO_ONE: return "GL_SAMPLE_ALPHA_TO_ONE";
		case GL_SAMPLE_COVERAGE: return "GL_SAMPLE_COVERAGE";

		// Front face winding
		case GL_FRONT_FACE: return "GL_FRONT_FACE";
		case GL_CW: return "GL_CW";
		case GL_CCW: return "GL_CCW";

			/* Misc GL state */
		case GL_LINE_WIDTH: return "GL_LINE_WIDTH";
		case GL_POINT_SIZE: return "GL_POINT_SIZE";
		case GL_POINT_DISTANCE_ATTENUATION: return "GL_POINT_DISTANCE_ATTENUATION";
		case GL_POINT_FADE_THRESHOLD_SIZE: return "GL_POINT_FADE_THRESHOLD_SIZE";
		case GL_POINT_SIZE_MAX: return "GL_POINT_SIZE_MAX";
		case GL_POINT_SIZE_MIN: return "GL_POINT_SIZE_MIN";
		case GL_SCISSOR_BOX: return "GL_SCISSOR_BOX";

		// Fog
		case GL_FOG_COLOR: return "GL_FOG_COLOR";
		case GL_FOG_MODE: return "GL_FOG_MODE";
		case GL_FOG_DENSITY: return "GL_FOG_DENSITY";
		case GL_FOG_START: return "GL_FOG_START";
		case GL_FOG_END: return "GL_FOG_END";
		case GL_EXP: return "GL_EXP";
		case GL_EXP2: return "GL_EXP2";
			
		// Hint Mode and Target
		case GL_DONT_CARE: return "GL_DONT_CARE";
		case GL_FASTEST: return "GL_FASTEST";
		case GL_NICEST: return "GL_NICEST";
		case GL_PERSPECTIVE_CORRECTION_HINT: return "GL_PERSPECTIVE_CORRECTION_HINT";
		case GL_POINT_SMOOTH_HINT: return "GL_POINT_SMOOTH_HINT";
		case GL_LINE_SMOOTH_HINT: return "GL_LINE_SMOOTH_HINT";
		case GL_FOG_HINT: return "GL_FOG_HINT";
		case GL_GENERATE_MIPMAP_HINT: return "GL_GENERATE_MIPMAP_HINT";
			
		// Light parameter
		case GL_LIGHT_MODEL_AMBIENT: return "GL_LIGHT_MODEL_AMBIENT";
		case GL_LIGHT_MODEL_TWO_SIDE: return "GL_LIGHT_MODEL_TWO_SIDE";
		case GL_AMBIENT: return "GL_AMBIENT";
		case GL_DIFFUSE: return "GL_DIFFUSE";
		case GL_SPECULAR: return "GL_SPECULAR";
		case GL_POSITION: return "GL_POSITION";
		case GL_SPOT_DIRECTION: return "GL_SPOT_DIRECTION";
		case GL_SPOT_EXPONENT: return "GL_SPOT_EXPONENT";
		case GL_SPOT_CUTOFF: return "GL_SPOT_CUTOFF";
		case GL_CONSTANT_ATTENUATION: return "GL_CONSTANT_ATTENUATION";
		case GL_LINEAR_ATTENUATION: return "GL_LINEAR_ATTENUATION";
		case GL_QUADRATIC_ATTENUATION: return "GL_QUADRATIC_ATTENUATION";

		// Data type
		case GL_BYTE: return "GL_BYTE";
		case GL_UNSIGNED_BYTE: return "GL_UNSIGNED_BYTE";
		case GL_SHORT: return "GL_SHORT";
		case GL_UNSIGNED_SHORT: return "GL_UNSIGNED_SHORT";
		case GL_FLOAT: return "GL_FLOAT";
		case GL_FIXED: return "GL_FIXED";

		// LogicOp
		case GL_CLEAR: return "GL_CLEAR";
		case GL_AND: return "GL_AND";
		case GL_AND_REVERSE: return "GL_AND_REVERSE";
		case GL_COPY: return "GL_COPY";
		case GL_AND_INVERTED: return "GL_AND_INVERTED";
		case GL_NOOP: return "GL_NOOP";
		case GL_XOR: return "GL_XOR";
		case GL_OR: return "GL_OR";
		case GL_NOR: return "GL_NOR";
		case GL_EQUIV: return "GL_EQUIV";
		case GL_INVERT: return "GL_INVERT";
		case GL_OR_REVERSE: return "GL_OR_REVERSE";
		case GL_COPY_INVERTED: return "GL_COPY_INVERTED";
		case GL_OR_INVERTED: return "GL_OR_INVERTED";
		case GL_NAND: return "GL_NAND";
		case GL_SET: return "GL_SET";

		// MaterialParameter
		case GL_EMISSION: return "GL_EMISSION";
		case GL_SHININESS: return "GL_SHININESS";
		case GL_AMBIENT_AND_DIFFUSE: return "GL_AMBIENT_AND_DIFFUSE";
		case GL_BLEND_SRC: return "GL_BLEND_SRC";
		case GL_BLEND_DST: return "GL_BLEND_DST";
			
		// MatrixMode
		case GL_MODELVIEW: return "GL_MODELVIEW";
		case GL_PROJECTION: return "GL_PROJECTION";
		case GL_TEXTURE: return "GL_TEXTURE";
			
		// PixelFormat
		case GL_ALPHA: return "GL_ALPHA";
		case GL_RGB: return "GL_RGB";
		case GL_RGBA: return "GL_RGBA";
		case GL_LUMINANCE: return "GL_LUMINANCE";
		case GL_LUMINANCE_ALPHA: return "GL_LUMINANCE_ALPHA";
			
		// Shading Model
		case GL_SHADE_MODEL: return "GL_SHADE_MODEL";
		case GL_FLAT: return "GL_FLAT";
		case GL_SMOOTH: return "GL_SMOOTH";
			
		// TextureUnits
		case GL_TEXTURE_BINDING_2D: return "GL_TEXTURE_BINDING_2D";
		case GL_ACTIVE_TEXTURE: return "GL_ACTIVE_TEXTURE";
		case GL_CLIENT_ACTIVE_TEXTURE: return "GL_CLIENT_ACTIVE_TEXTURE";
		case GL_MAX_TEXTURE_UNITS: return "GL_MAX_TEXTURE_UNITS";
		case GL_TEXTURE0: return "GL_TEXTURE0";
		case GL_TEXTURE1: return "GL_TEXTURE1";
		case GL_TEXTURE2: return "GL_TEXTURE2";
		case GL_TEXTURE3: return "GL_TEXTURE3";
		case GL_TEXTURE4: return "GL_TEXTURE4";
		case GL_TEXTURE5: return "GL_TEXTURE5";
		case GL_TEXTURE6: return "GL_TEXTURE6";
		case GL_TEXTURE7: return "GL_TEXTURE7";

		// Texture Environment parameters
		case GL_TEXTURE_MIN_FILTER: return "GL_TEXTURE_MIN_FILTER";
		case GL_TEXTURE_MAG_FILTER: return "GL_TEXTURE_MAG_FILTER";
		case GL_NEAREST: return "GL_NEAREST";
		case GL_LINEAR: return "GL_LINEAR";
		case GL_NEAREST_MIPMAP_NEAREST: return "GL_NEAREST_MIPMAP_NEAREST";
		case GL_LINEAR_MIPMAP_NEAREST: return "GL_LINEAR_MIPMAP_NEAREST";
		case GL_NEAREST_MIPMAP_LINEAR: return "GL_NEAREST_MIPMAP_LINEAR";
		case GL_LINEAR_MIPMAP_LINEAR: return "GL_LINEAR_MIPMAP_LINEAR";
		case GL_TEXTURE_WRAP_S: return "GL_TEXTURE_WRAP_S";
		case GL_TEXTURE_WRAP_T: return "GL_TEXTURE_WRAP_T";
		case GL_CLAMP_TO_EDGE: return "GL_CLAMP_TO_EDGE";
		case GL_REPEAT: return "GL_REPEAT";
		case GL_GENERATE_MIPMAP: return "GL_GENERATE_MIPMAP";
//		case GL_TRUE: return "GL_TRUE";
//		case GL_FALSE: return "GL_FALSE";

		// Texture Environment parameters
		case GL_TEXTURE_ENV: return "GL_TEXTURE_ENV";
		case GL_TEXTURE_ENV_MODE: return "GL_TEXTURE_ENV_MODE";
		case GL_TEXTURE_ENV_COLOR: return "GL_TEXTURE_ENV_COLOR";
		case GL_MODULATE: return "GL_MODULATE";
		case GL_DECAL: return "GL_DECAL";
//		case GL_BLEND: return "GL_BLEND";
		case GL_ADD: return "GL_ADD";
		case GL_REPLACE: return "GL_REPLACE";
		case GL_COMBINE: return "GL_COMBINE";
		
		case GL_SUBTRACT: return "GL_SUBTRACT";
		case GL_COMBINE_RGB: return "GL_COMBINE_RGB";
		case GL_COMBINE_ALPHA: return "GL_COMBINE_ALPHA";
		case GL_ADD_SIGNED: return "GL_ADD_SIGNED";
		case GL_INTERPOLATE: return "GL_INTERPOLATE";
		case GL_CONSTANT: return "GL_CONSTANT";
		case GL_PRIMARY_COLOR: return "GL_PRIMARY_COLOR";
		case GL_PREVIOUS: return "GL_PREVIOUS";
		case GL_DOT3_RGB: return "GL_DOT3_RGB";
		case GL_DOT3_RGBA: return "GL_DOT3_RGBA";

		case GL_SRC0_RGB: return "GL_SRC0_RGB";
		case GL_SRC1_RGB: return "GL_SRC1_RGB";
		case GL_SRC2_RGB: return "GL_SRC2_RGB";
		case GL_OPERAND0_RGB: return "GL_OPERAND0_RGB";
		case GL_OPERAND1_RGB: return "GL_OPERAND1_RGB";
		case GL_OPERAND2_RGB: return "GL_OPERAND2_RGB";
		case GL_RGB_SCALE: return "GL_RGB_SCALE";

		case GL_SRC0_ALPHA: return "GL_SRC0_ALPHA";
		case GL_SRC1_ALPHA: return "GL_SRC1_ALPHA";
		case GL_SRC2_ALPHA: return "GL_SRC2_ALPHA";
		case GL_OPERAND0_ALPHA: return "GL_OPERAND0_ALPHA";
		case GL_OPERAND1_ALPHA: return "GL_OPERAND1_ALPHA";
		case GL_OPERAND2_ALPHA: return "GL_OPERAND2_ALPHA";
		case GL_ALPHA_SCALE: return "GL_ALPHA_SCALE";
		case GL_COORD_REPLACE_OES: return "GL_COORD_REPLACE_OES";

		// Lights
		case GL_MAX_LIGHTS: return "GL_MAX_LIGHTS";
		case GL_LIGHT0: return "GL_LIGHT0";
		case GL_LIGHT1: return "GL_LIGHT1";
		case GL_LIGHT2: return "GL_LIGHT2";
		case GL_LIGHT3: return "GL_LIGHT3";
		case GL_LIGHT4: return "GL_LIGHT4";
		case GL_LIGHT5: return "GL_LIGHT5";
		case GL_LIGHT6: return "GL_LIGHT6";
		case GL_LIGHT7: return "GL_LIGHT7";
			
		// ClipPlane
		case GL_MAX_CLIP_PLANES: return "GL_MAX_CLIP_PLANES";
		case GL_CLIP_PLANE0: return "GL_CLIP_PLANE0";
		case GL_CLIP_PLANE1: return "GL_CLIP_PLANE1";
		case GL_CLIP_PLANE2: return "GL_CLIP_PLANE2";
		case GL_CLIP_PLANE3: return "GL_CLIP_PLANE3";
		case GL_CLIP_PLANE4: return "GL_CLIP_PLANE4";
		case GL_CLIP_PLANE5: return "GL_CLIP_PLANE5";
			
		// Buffer Objects
		case GL_ARRAY_BUFFER: return "GL_ARRAY_BUFFER";
		case GL_ELEMENT_ARRAY_BUFFER: return "GL_ELEMENT_ARRAY_BUFFER";
		case GL_ARRAY_BUFFER_BINDING: return "GL_ARRAY_BUFFER_BINDING";
		case GL_ELEMENT_ARRAY_BUFFER_BINDING: return "GL_ELEMENT_ARRAY_BUFFER_BINDING";
		case GL_VERTEX_ARRAY_BUFFER_BINDING: return "GL_VERTEX_ARRAY_BUFFER_BINDING";
		case GL_NORMAL_ARRAY_BUFFER_BINDING: return "GL_NORMAL_ARRAY_BUFFER_BINDING";
		case GL_COLOR_ARRAY_BUFFER_BINDING: return "GL_COLOR_ARRAY_BUFFER_BINDING";
		case GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING: return "GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING";
		case GL_STATIC_DRAW: return "GL_STATIC_DRAW";
		case GL_DYNAMIC_DRAW: return "GL_DYNAMIC_DRAW";
		case GL_BUFFER_SIZE: return "GL_BUFFER_SIZE";
		case GL_BUFFER_USAGE: return "GL_BUFFER_USAGE";

		// Vertex arrays
		case GL_VERTEX_ARRAY_SIZE: return "GL_VERTEX_ARRAY_SIZE";
		case GL_VERTEX_ARRAY_TYPE: return "GL_VERTEX_ARRAY_TYPE";
		case GL_VERTEX_ARRAY_STRIDE: return "GL_VERTEX_ARRAY_STRIDE";
		case GL_NORMAL_ARRAY_TYPE: return "GL_NORMAL_ARRAY_TYPE";
		case GL_NORMAL_ARRAY_STRIDE: return "GL_NORMAL_ARRAY_STRIDE";
		case GL_COLOR_ARRAY_SIZE: return "GL_COLOR_ARRAY_SIZE";
		case GL_COLOR_ARRAY_TYPE: return "GL_COLOR_ARRAY_TYPE";
		case GL_COLOR_ARRAY_STRIDE: return "GL_COLOR_ARRAY_STRIDE";
		case GL_TEXTURE_COORD_ARRAY_SIZE: return "GL_TEXTURE_COORD_ARRAY_SIZE";
		case GL_TEXTURE_COORD_ARRAY_TYPE: return "GL_TEXTURE_COORD_ARRAY_TYPE";
		case GL_TEXTURE_COORD_ARRAY_STRIDE: return "GL_TEXTURE_COORD_ARRAY_STRIDE";
		case GL_POINT_SIZE_ARRAY_TYPE_OES: return "GL_POINT_SIZE_ARRAY_TYPE_OES";
		case GL_POINT_SIZE_ARRAY_STRIDE_OES: return "GL_POINT_SIZE_ARRAY_STRIDE_OES";

		// Get pnames
		case GL_CURRENT_COLOR: return "GL_CURRENT_COLOR";
		case GL_VIEWPORT: return "GL_VIEWPORT";
		case GL_MATRIX_MODE: return "GL_MATRIX_MODE";
		case GL_MODELVIEW_MATRIX: return "GL_MODELVIEW_MATRIX";
		case GL_PROJECTION_MATRIX: return "GL_PROJECTION_MATRIX";
		case GL_TEXTURE_MATRIX: return "GL_TEXTURE_MATRIX";
		case GL_MODELVIEW_STACK_DEPTH: return "GL_MODELVIEW_STACK_DEPTH";
		case GL_PROJECTION_STACK_DEPTH: return "GL_PROJECTION_STACK_DEPTH";
		case GL_TEXTURE_STACK_DEPTH: return "GL_TEXTURE_STACK_DEPTH";
		case GL_ALPHA_TEST_FUNC: return "GL_ALPHA_TEST_FUNC";
		case GL_ALPHA_TEST_REF: return "GL_ALPHA_TEST_REF";

		// Clearing values
		case GL_COLOR_CLEAR_VALUE: return "GL_COLOR_CLEAR_VALUE";
		case GL_DEPTH_CLEAR_VALUE: return "GL_DEPTH_CLEAR_VALUE";
		case GL_STENCIL_CLEAR_VALUE: return "GL_STENCIL_CLEAR_VALUE";

		// Stencils
		case GL_STENCIL_FUNC: return "GL_STENCIL_FUNC";
		case GL_STENCIL_REF: return "GL_STENCIL_REF";
		case GL_STENCIL_VALUE_MASK: return "GL_STENCIL_VALUE_MASK";
		case GL_STENCIL_FAIL: return "GL_STENCIL_FAIL";
		case GL_STENCIL_PASS_DEPTH_FAIL: return "GL_STENCIL_PASS_DEPTH_FAIL";
		case GL_STENCIL_PASS_DEPTH_PASS: return "GL_STENCIL_PASS_DEPTH_PASS";
		case GL_KEEP: return "GL_KEEP";
		case GL_INCR: return "GL_INCR";
		case GL_DECR: return "GL_DECR";
		case GL_INCR_WRAP_OES: return "GL_INCR_WRAP_OES";
		case GL_DECR_WRAP_OES: return "GL_DECR_WRAP_OES";
			
		// OES_matrix_palette
		case GL_MAX_VERTEX_UNITS_OES: return "GL_MAX_VERTEX_UNITS_OES";
		case GL_MAX_PALETTE_MATRICES_OES: return "GL_MAX_PALETTE_MATRICES_OES";
		case GL_MATRIX_PALETTE_OES: return "GL_MATRIX_PALETTE_OES";
		case GL_MATRIX_INDEX_ARRAY_OES: return "GL_MATRIX_INDEX_ARRAY_OES";
		case GL_WEIGHT_ARRAY_OES: return "GL_WEIGHT_ARRAY_OES";
		case GL_CURRENT_PALETTE_MATRIX_OES: return "GL_CURRENT_PALETTE_MATRIX_OES";

		case GL_MATRIX_INDEX_ARRAY_SIZE_OES: return "GL_MATRIX_INDEX_ARRAY_SIZE_OES";
		case GL_MATRIX_INDEX_ARRAY_TYPE_OES: return "GL_MATRIX_INDEX_ARRAY_TYPE_OES";
		case GL_MATRIX_INDEX_ARRAY_STRIDE_OES: return "GL_MATRIX_INDEX_ARRAY_STRIDE_OES";
		case GL_MATRIX_INDEX_ARRAY_POINTER_OES: return "GL_MATRIX_INDEX_ARRAY_POINTER_OES";
		case GL_MATRIX_INDEX_ARRAY_BUFFER_BINDING_OES: return "GL_MATRIX_INDEX_ARRAY_BUFFER_BINDING_OES";
			
		case GL_WEIGHT_ARRAY_SIZE_OES: return "GL_WEIGHT_ARRAY_SIZE_OES";
		case GL_WEIGHT_ARRAY_TYPE_OES: return "GL_WEIGHT_ARRAY_TYPE_OES";
		case GL_WEIGHT_ARRAY_STRIDE_OES: return "GL_WEIGHT_ARRAY_STRIDE_OES";
		case GL_WEIGHT_ARRAY_POINTER_OES: return "GL_WEIGHT_ARRAY_POINTER_OES";
		case GL_WEIGHT_ARRAY_BUFFER_BINDING_OES: return "GL_WEIGHT_ARRAY_BUFFER_BINDING_OES";

		// Miscellaneous & extensions
		case GL_MAX_SAMPLES_APPLE: return "GL_MAX_SAMPLES_APPLE";
			
		default:
			printf("***ERROR: UNKNOWN_GLENUM (0x%x)\n", gle);
			return "UNKNOWN_GLENUM";
	}
}

size_t GLElementTypeSize(GLenum dataType) {
	switch (dataType) {
		case GL_BYTE: return sizeof(GLbyte);
		case GL_UNSIGNED_BYTE: return sizeof(GLubyte);
		case GL_SHORT: return sizeof(GLshort);
		case GL_UNSIGNED_SHORT: return sizeof(GLushort);
		case GL_FLOAT: return sizeof(GLfloat);
		case GL_FIXED: return sizeof(GLfixed);
		default: return 0;
	}	
}
