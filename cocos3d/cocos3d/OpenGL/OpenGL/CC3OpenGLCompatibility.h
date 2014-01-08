/*
 * CC3OpenGLCompatibility.h
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

/**
 * When compiling against OpenGL, this file adds backward compatiblity to declarations
 * and functionality provided by OpenGL ES 1 & 2 under cocos3d.
 */

#import "CC3Environment.h"

#if CC3_OGL

// General symbolic constants

#ifndef GL_FIXED
#define GL_FIXED						GL_INT
#endif

#ifndef GL_STACK_OVERFLOW
#define GL_STACK_OVERFLOW                 0x0503
#endif

#ifndef GL_STACK_UNDERFLOW
#define GL_STACK_UNDERFLOW                0x0504
#endif


// Color, depth and stencil buffers


#ifndef GL_RGB565
#define GL_RGB565                         0x8D62
#endif

#ifndef GL_DEPTH_STENCIL
#define GL_DEPTH_STENCIL				GL_DEPTH_STENCIL_EXT
#endif

#ifndef GL_DEPTH24_STENCIL8
#define GL_DEPTH24_STENCIL8				GL_DEPTH24_STENCIL8_EXT
#endif

#ifndef GL_UNSIGNED_INT_24_8
#define GL_UNSIGNED_INT_24_8			GL_UNSIGNED_INT_24_8_EXT
#endif

#ifndef GL_DEPTH_COMPONENT16_OES
#define GL_DEPTH_COMPONENT16_OES		GL_DEPTH_COMPONENT16
#endif

#ifndef GL_DEPTH_COMPONENT24_OES
#define GL_DEPTH_COMPONENT24_OES		GL_DEPTH_COMPONENT24
#endif


#ifndef GL_DEPTH24_STENCIL8_OES
#define GL_DEPTH24_STENCIL8_OES			GL_DEPTH24_STENCIL8
#endif

#ifndef GL_INCR_WRAP_OES
#define GL_INCR_WRAP_OES				GL_INCR_WRAP
#endif

#ifndef GL_DECR_WRAP_OES
#define GL_DECR_WRAP_OES				GL_DECR_WRAP
#endif


// Texture unit symbolic constants

#ifndef GL_TEXTURE_ENV_MODE
#define GL_TEXTURE_ENV_MODE               0x2200
#endif

#ifndef GL_TEXTURE_ENV_COLOR
#define GL_TEXTURE_ENV_COLOR              0x2201
#endif

#ifndef GL_TEXTURE_ENV
#define GL_TEXTURE_ENV                    0x2300
#endif

#ifndef GL_MODULATE
#define GL_MODULATE                       0x2100
#endif

#ifndef GL_DECAL
#define GL_DECAL                          0x2101
#endif

#ifndef GL_ADD
#define GL_ADD                            0x0104
#endif

#ifndef GL_SUBTRACT
#define GL_SUBTRACT                       0x84E7
#endif

#ifndef GL_COMBINE
#define GL_COMBINE                        0x8570
#endif

#ifndef GL_COMBINE_RGB
#define GL_COMBINE_RGB                    0x8571
#endif

#ifndef GL_COMBINE_ALPHA
#define GL_COMBINE_ALPHA                  0x8572
#endif

#ifndef GL_RGB_SCALE
#define GL_RGB_SCALE                      0x8573
#endif

#ifndef GL_ADD_SIGNED
#define GL_ADD_SIGNED                     0x8574
#endif

#ifndef GL_INTERPOLATE
#define GL_INTERPOLATE                    0x8575
#endif

#ifndef GL_CONSTANT
#define GL_CONSTANT                       0x8576
#endif

#ifndef GL_PRIMARY_COLOR
#define GL_PRIMARY_COLOR                  0x8577
#endif

#ifndef GL_PREVIOUS
#define GL_PREVIOUS                       0x8578
#endif

#ifndef GL_OPERAND0_RGB
#define GL_OPERAND0_RGB                   0x8590
#endif

#ifndef GL_OPERAND1_RGB
#define GL_OPERAND1_RGB                   0x8591
#endif

#ifndef GL_OPERAND2_RGB
#define GL_OPERAND2_RGB                   0x8592
#endif

#ifndef GL_OPERAND0_ALPHA
#define GL_OPERAND0_ALPHA                 0x8598
#endif

#ifndef GL_OPERAND1_ALPHA
#define GL_OPERAND1_ALPHA                 0x8599
#endif

#ifndef GL_OPERAND2_ALPHA
#define GL_OPERAND2_ALPHA                 0x859A
#endif

#ifndef GL_ALPHA_SCALE
#define GL_ALPHA_SCALE                    0x0D1C
#endif

#ifndef GL_SRC0_RGB
#define GL_SRC0_RGB                       0x8580
#endif

#ifndef GL_SRC1_RGB
#define GL_SRC1_RGB                       0x8581
#endif

#ifndef GL_SRC2_RGB
#define GL_SRC2_RGB                       0x8582
#endif

#ifndef GL_SRC0_ALPHA
#define GL_SRC0_ALPHA                     0x8588
#endif

#ifndef GL_SRC1_ALPHA
#define GL_SRC1_ALPHA                     0x8589
#endif

#ifndef GL_SRC2_ALPHA
#define GL_SRC2_ALPHA                     0x858A
#endif

#ifndef GL_DOT3_RGB
#define GL_DOT3_RGB                       0x86AE
#endif

#ifndef GL_DOT3_RGBA
#define GL_DOT3_RGBA                      0x86AF
#endif


// Fog symbolic constants

#ifndef GL_EXP
#define GL_EXP                            0x0800
#endif

#ifndef GL_EXP2
#define GL_EXP2                           0x0801
#endif


// Shading model symbolic constants

#ifndef GL_FLAT
#define GL_FLAT                           0x1D00
#endif

#ifndef GL_SMOOTH
#define GL_SMOOTH                         0x1D01
#endif

#ifndef GL_SHADE_MODEL
#define GL_SHADE_MODEL                    0x0B54
#endif



// Lighting and material symbolic constants

#ifndef GL_LIGHT_MODEL_AMBIENT
#define GL_LIGHT_MODEL_AMBIENT            0x0B53
#endif

#ifndef GL_AMBIENT
#define GL_AMBIENT                        0x1200
#endif

#ifndef GL_DIFFUSE
#define GL_DIFFUSE                        0x1201
#endif

#ifndef GL_SPECULAR
#define GL_SPECULAR                       0x1202
#endif

#ifndef GL_EMISSION
#define GL_EMISSION                       0x1600
#endif

#ifndef GL_SHININESS
#define GL_SHININESS                      0x1601
#endif

#ifndef GL_POSITION
#define GL_POSITION                       0x1203
#endif

#ifndef GL_SPOT_DIRECTION
#define GL_SPOT_DIRECTION                 0x1204
#endif

#ifndef GL_SPOT_EXPONENT
#define GL_SPOT_EXPONENT                  0x1205
#endif

#ifndef GL_SPOT_CUTOFF
#define GL_SPOT_CUTOFF                    0x1206
#endif

#ifndef GL_CONSTANT_ATTENUATION
#define GL_CONSTANT_ATTENUATION           0x1207
#endif

#ifndef GL_LINEAR_ATTENUATION
#define GL_LINEAR_ATTENUATION             0x1208
#endif

#ifndef GL_QUADRATIC_ATTENUATION
#define GL_QUADRATIC_ATTENUATION          0x1209
#endif


// Matrix symbolic constants

#ifndef GL_MODELVIEW
#define GL_MODELVIEW                      0x1700
#endif

#ifndef GL_PROJECTION
#define GL_PROJECTION                     0x1701
#endif

#endif	// CC3_OGL
