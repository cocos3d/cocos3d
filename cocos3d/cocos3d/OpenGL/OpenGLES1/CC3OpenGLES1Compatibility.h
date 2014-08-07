/*
 * CC3OpenGLES1Compatibility.h
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
 * When compiling against OpenGL ES 1, this file adds some compatibility with declarations
 * and functionality provided by OpenGL or OpenGL ES 2 under cocos3d.
 */

#import "CC3Environment.h"

#if CC3_OGLES_1

// GL functions
#define glClearDepth					glClearDepthf
#define glGenerateMipmap				glGenerateMipmapOES
#define glBindVertexArray				glBindVertexArrayOES
#define glBlendFuncSeparate				glBlendFuncSeparateOES

// Framebuffers
#define glGenFramebuffers				glGenFramebuffersOES
#define glDeleteFramebuffers			glDeleteFramebuffersOES
#define glBindFramebuffer				glBindFramebufferOES
#define glGenRenderbuffers				glGenRenderbuffersOES
#define glDeleteRenderbuffers			glDeleteRenderbuffersOES
#define glBindRenderbuffer				glBindRenderbufferOES
#define glRenderbufferStorage			glRenderbufferStorageOES
#define glFramebufferRenderbuffer		glFramebufferRenderbufferOES
#define glFramebufferTexture2D			glFramebufferTexture2DOES
#define glCheckFramebufferStatus		glCheckFramebufferStatusOES
#define glGetRenderbufferParameteriv	glGetRenderbufferParameterivOES

// Undef first since core frameworks can include ES2 in later SDK's
#undef GL_FRAMEBUFFER
#undef GL_RENDERBUFFER
#undef GL_MAX_RENDERBUFFER_SIZE
#undef GL_RENDERBUFFER_WIDTH
#undef GL_RENDERBUFFER_HEIGHT

#define GL_FRAMEBUFFER					GL_FRAMEBUFFER_OES
#define GL_RENDERBUFFER					GL_RENDERBUFFER_OES
#define GL_MAX_RENDERBUFFER_SIZE		GL_MAX_RENDERBUFFER_SIZE_OES
#define GL_RENDERBUFFER_WIDTH			GL_RENDERBUFFER_WIDTH_OES
#define GL_RENDERBUFFER_HEIGHT			GL_RENDERBUFFER_HEIGHT_OES

// Undef first since core frameworks can include ES2 in later SDK's
#undef GL_FRAMEBUFFER_COMPLETE
#undef GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
#undef GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
#undef GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS
#undef GL_FRAMEBUFFER_INCOMPLETE_FORMATS
#undef GL_FRAMEBUFFER_UNSUPPORTED
#undef GL_INVALID_FRAMEBUFFER_OPERATION

#define GL_FRAMEBUFFER_COMPLETE							GL_FRAMEBUFFER_COMPLETE_OES
#define GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT			GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES
#define GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT	GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_OES
#define GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS			GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_OES
#define GL_FRAMEBUFFER_INCOMPLETE_FORMATS				GL_FRAMEBUFFER_INCOMPLETE_FORMATS_OES
#define GL_FRAMEBUFFER_UNSUPPORTED						GL_FRAMEBUFFER_UNSUPPORTED_OES
#define GL_INVALID_FRAMEBUFFER_OPERATION				GL_INVALID_FRAMEBUFFER_OPERATION_OES

#define GL_TEXTURE_CUBE_MAP                              0x8513
#define GL_TEXTURE_BINDING_CUBE_MAP                      0x8514
#define GL_TEXTURE_CUBE_MAP_POSITIVE_X                   0x8515
#define GL_TEXTURE_CUBE_MAP_NEGATIVE_X                   0x8516
#define GL_TEXTURE_CUBE_MAP_POSITIVE_Y                   0x8517
#define GL_TEXTURE_CUBE_MAP_NEGATIVE_Y                   0x8518
#define GL_TEXTURE_CUBE_MAP_POSITIVE_Z                   0x8519
#define GL_TEXTURE_CUBE_MAP_NEGATIVE_Z                   0x851A
#define GL_MAX_CUBE_MAP_TEXTURE_SIZE                     0x851C

// Color, depth and stencil buffers

// Undef first since core frameworks can include ES2 in later SDK's
#undef GL_RGB8
#undef GL_RGBA8
#undef GL_RGBA4
#undef GL_RGB5_A1
#undef GL_RGB565
#undef GL_DEPTH_STENCIL
#undef GL_DEPTH24_STENCIL8
#undef GL_UNSIGNED_INT_24_8
#undef GL_DEPTH_COMPONENT16
#undef GL_DEPTH_COMPONENT24
#undef GL_COLOR_ATTACHMENT0
#undef GL_DEPTH_ATTACHMENT
#undef GL_STENCIL_ATTACHMENT
#undef GL_FRAMEBUFFER_BINDING
#undef GL_RENDERBUFFER_BINDING
#undef GL_RENDERBUFFER_INTERNAL_FORMAT
#undef GL_RENDERBUFFER_RED_SIZE
#undef GL_RENDERBUFFER_GREEN_SIZE
#undef GL_RENDERBUFFER_BLUE_SIZE
#undef GL_RENDERBUFFER_ALPHA_SIZE
#undef GL_RENDERBUFFER_DEPTH_SIZE
#undef GL_RENDERBUFFER_STENCIL_SIZE
#undef GL_STENCIL_INDEX8

#define GL_RGB8								GL_RGB8_OES
#define GL_RGBA8							GL_RGBA8_OES
#define GL_RGBA4							GL_RGBA4_OES
#define GL_RGB5_A1							GL_RGB5_A1_OES
#define GL_RGB565							GL_RGB565_OES
#define GL_DEPTH_STENCIL					GL_DEPTH_STENCIL_OES
#define GL_DEPTH24_STENCIL8					GL_DEPTH24_STENCIL8_OES
#define GL_UNSIGNED_INT_24_8				GL_UNSIGNED_INT_24_8_OES
#define GL_DEPTH_COMPONENT16				GL_DEPTH_COMPONENT16_OES
#define GL_DEPTH_COMPONENT24				GL_DEPTH_COMPONENT24_OES
#define GL_COLOR_ATTACHMENT0				GL_COLOR_ATTACHMENT0_OES
#define GL_DEPTH_ATTACHMENT					GL_DEPTH_ATTACHMENT_OES
#define GL_STENCIL_ATTACHMENT				GL_STENCIL_ATTACHMENT_OES
#define GL_FRAMEBUFFER_BINDING				GL_FRAMEBUFFER_BINDING_OES
#define GL_RENDERBUFFER_BINDING				GL_RENDERBUFFER_BINDING_OES
#define GL_RENDERBUFFER_INTERNAL_FORMAT		GL_RENDERBUFFER_INTERNAL_FORMAT_OES
#define GL_RENDERBUFFER_RED_SIZE			GL_RENDERBUFFER_RED_SIZE_OES
#define GL_RENDERBUFFER_GREEN_SIZE			GL_RENDERBUFFER_GREEN_SIZE_OES
#define GL_RENDERBUFFER_BLUE_SIZE			GL_RENDERBUFFER_BLUE_SIZE_OES
#define GL_RENDERBUFFER_ALPHA_SIZE			GL_RENDERBUFFER_ALPHA_SIZE_OES
#define GL_RENDERBUFFER_DEPTH_SIZE			GL_RENDERBUFFER_DEPTH_SIZE_OES
#define GL_RENDERBUFFER_STENCIL_SIZE		GL_RENDERBUFFER_STENCIL_SIZE_OES
#define GL_STENCIL_INDEX8					GL_STENCIL_INDEX8_OES

#define GL_DEPTH_COMPONENT					0x1902
#define GL_DEPTH_COMPONENT32				0x81A7

#define GL_RGB4								0x804F
#define GL_RGB5								0x8050
#define GL_RGB16							0x8054
#define GL_RGBA2							0x8055
#define GL_RGB10_A2							0x8059
#define GL_RGBA12							0x805A
#define GL_RGBA16							0x805B

// Shaders
#define GL_FRAGMENT_SHADER                               0x8B30
#define GL_VERTEX_SHADER                                 0x8B31
#define GL_MAX_VERTEX_ATTRIBS                            0x8869
#define GL_MAX_VERTEX_UNIFORM_VECTORS                    0x8DFB
#define GL_MAX_VARYING_VECTORS                           0x8DFC
#define GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS              0x8B4D
#define GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS                0x8B4C
#define GL_MAX_TEXTURE_IMAGE_UNITS                       0x8872
#define GL_MAX_FRAGMENT_UNIFORM_VECTORS                  0x8DFD
#define GL_SHADER_TYPE                                   0x8B4F
#define GL_DELETE_STATUS                                 0x8B80
#define GL_LINK_STATUS                                   0x8B82
#define GL_VALIDATE_STATUS                               0x8B83
#define GL_ATTACHED_SHADERS                              0x8B85
#define GL_ACTIVE_UNIFORMS                               0x8B86
#define GL_ACTIVE_UNIFORM_MAX_LENGTH                     0x8B87
#define GL_ACTIVE_ATTRIBUTES                             0x8B89
#define GL_ACTIVE_ATTRIBUTE_MAX_LENGTH                   0x8B8A
#define GL_SHADING_LANGUAGE_VERSION                      0x8B8C
#define GL_CURRENT_PROGRAM                               0x8B8D

#define GL_COMPILE_STATUS                                0x8B81
#define GL_INFO_LOG_LENGTH                               0x8B84
#define GL_SHADER_SOURCE_LENGTH                          0x8B88
#define GL_SHADER_COMPILER                               0x8DFA

#define GL_INT								0x1404
#define GL_FLOAT_VEC2						0x8B50
#define GL_FLOAT_VEC3						0x8B51
#define GL_FLOAT_VEC4						0x8B52
#define GL_INT_VEC2							0x8B53
#define GL_INT_VEC3							0x8B54
#define GL_INT_VEC4							0x8B55
#define GL_BOOL								0x8B56
#define GL_BOOL_VEC2						0x8B57
#define GL_BOOL_VEC3						0x8B58
#define GL_BOOL_VEC4						0x8B59
#define GL_FLOAT_MAT2						0x8B5A
#define GL_FLOAT_MAT3						0x8B5B
#define GL_FLOAT_MAT4						0x8B5C
#define GL_SAMPLER_2D						0x8B5E
#define GL_SAMPLER_CUBE						0x8B60

// Shader Precision-Specified Types
#define GL_LOW_FLOAT                                     0x8DF0
#define GL_MEDIUM_FLOAT                                  0x8DF1
#define GL_HIGH_FLOAT                                    0x8DF2
#define GL_LOW_INT                                       0x8DF3
#define GL_MEDIUM_INT                                    0x8DF4
#define GL_HIGH_INT                                      0x8DF5

// Data types
#define GL_UNSIGNED_INT						0x1405

// Separate Blend Functions
#define GL_BLEND_DST_RGB                                 0x80C8
#define GL_BLEND_SRC_RGB                                 0x80C9
#define GL_BLEND_DST_ALPHA                               0x80CA
#define GL_BLEND_SRC_ALPHA                               0x80CB
#define GL_CONSTANT_COLOR                                0x8001
#define GL_ONE_MINUS_CONSTANT_COLOR                      0x8002
#define GL_CONSTANT_ALPHA                                0x8003
#define GL_ONE_MINUS_CONSTANT_ALPHA                      0x8004
#define GL_BLEND_COLOR                                   0x8005

// Vertex Arrays
#define GL_VERTEX_ATTRIB_ARRAY_ENABLED                   0x8622
#define GL_VERTEX_ATTRIB_ARRAY_SIZE                      0x8623
#define GL_VERTEX_ATTRIB_ARRAY_STRIDE                    0x8624
#define GL_VERTEX_ATTRIB_ARRAY_TYPE                      0x8625
#define GL_VERTEX_ATTRIB_ARRAY_NORMALIZED                0x886A
#define GL_VERTEX_ATTRIB_ARRAY_POINTER                   0x8645
#define GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING            0x889F

// Debug label extentions
#define GL_SHADER_OBJECT_EXT                                    0x8B48
#define GL_PROGRAM_OBJECT_EXT                                   0x8B40
#define GL_QUERY_OBJECT_EXT                                     0x9153

#define GL_PROGRAM_PIPELINE_OBJECT_EXT                          0x8A4F

// General symbolic constants
#ifndef GL_INCR_WRAP
#define GL_INCR_WRAP					GL_INCR_WRAP_OES
#endif

#ifndef GL_DECR_WRAP
#define GL_DECR_WRAP					GL_DECR_WRAP_OES
#endif

// Allow code to reference the following enums, even though they are not usable under OpenGL ES 1.1.
#ifndef GL_TEXTURE_CUBE_MAP
#define GL_TEXTURE_CUBE_MAP               0x8513
#endif

// Android compatibility

#if APPORTABLE

// GL_MAX_SAMPLES_APPLE is redefined to unusable value by Apportable. Set it back.
#undef GL_MAX_SAMPLES_APPLE
#define GL_MAX_SAMPLES_APPLE              0x8D57

#endif	// APPORTABLE

#endif	// CC3_OGLES_1
