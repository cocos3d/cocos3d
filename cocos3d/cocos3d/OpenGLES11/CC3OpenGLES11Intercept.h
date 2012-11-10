/*
 * CC3OpenGLES11Intercept.h
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
 * See header file CC3OpenGLES11Intercept.h for full API documentation.
 */

/** @file */	// Doxygen marker

/**
 * This file adds the ability to intercept all OpenGL ES 1.1 gl* calls in order to
 * log the call to stdout, using printf, before actually making the call into the
 * OpenGL ES 1.1 library. The result is a log trace of all gl* calls, including
 * the parameters used in each call.
 *
 * Include this file at the top of any files that perform OopenGLES calls, or
 * in a header file that is subsequently included wherever GL calls are made.
 *
 * To be generically usable, this code is written in straight C. When including this
 * header in C++ (.cpp) or Objective-C++ (.mm) files, wrap the include statement in
 * an extern "C" declaration, as follows:
 *
 *   extern "C" {
 *     #include "CC3OpenGLES11Intercept.h"
 *   }
 *
 * This wrapping is NOT necessary when including this header in Objective-C (.m) files. 
 *
 * To enable logging all GL calls in any code that includes this file, set the compiler
 * switch GL_LOGGING_ENABLED to 1. This can be set either in code, or as a compiler
 * runtime parameter. Using a compiler runtime parameter is preferred.
 *
 * The call-intercepting behaviour is implemented by re-defining each gl* function
 * to an alias that generates the log entry before calling the original gl* function.
 * With the GL_LOGGING_ENABLED set to 0, this aliasing and redirecting is completely
 * skipped by the compiler. As a result, there is no runtime penalty incurred by this
 * code when GL_LOGGING_ENABLED is set to 0. You can safely leave this file included
 * in your header files at all times, even when building production code, provided
 * the GL_LOGGING_ENABLED switch is not set to 1.
 *
 * Logging all OpenGL libraries obviously incurs significant runtime overhead.
 * You should only set the GL_LOGGING_ENABLED switch to 1 when you specifically
 * need to log OpenGL calls. The default value of this switch is 0, so GL logging
 * is turned off by default.
 *
 * Use the compiler runtime parameter kPrintGLDataVertexCount to control how many
 * elements of the data should be logged when data is passed to GL calls as data
 * pointers (eg. glVertexPointer, glColorPointer, etc). The default value is 8.
 *
 * Since many of the GL pointer data functions accept offsets for the pointer when
 * used with data that has been bound, the compiler parameter kMinGLPointerAddress
 * sets the minimum value for a pointer to be considered an address rather than an
 * offset. For pointer values below this level, no attempt is made to extract data
 * at that address. The default value is 8192.
 *
 * Use the compiler parameter kPrintGLDataBufferDataCount to control how many elements
 * of the data should be logged when data is passed as buffer data (eg. glBufferData).
 * The default value is 64.
 */

#include <OpenGLES/ES1/gl.h>


#ifndef GL_LOGGING_ENABLED
#	define GL_LOGGING_ENABLED		0
#endif

#if defined(GL_LOGGING_ENABLED) && GL_LOGGING_ENABLED
 
#pragma mark OpenGLES base

#define glAlphaFunc glAlphaFuncLogged
void glAlphaFuncLogged(GLenum func, GLclampf ref);

#define glClearColor glClearColorLogged
void glClearColorLogged(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);

#define glClearDepthf glClearDepthfLogged
void glClearDepthfLogged(GLclampf depth);

#define glClipPlanef glClipPlanefLogged
void glClipPlanefLogged(GLenum plane, const GLfloat *equation);

#define glColor4f glColor4fLogged
void glColor4fLogged(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);

#define glDepthRangef glDepthRangefLogged
void glDepthRangefLogged(GLclampf zNear, GLclampf zFar);

#define glFogf glFogfLogged
void glFogfLogged(GLenum pname, GLfloat param);

#define glFogfv glFogfvLogged
void glFogfvLogged(GLenum pname, const GLfloat *params);

#define glFrustumf glFrustumfLogged
void glFrustumfLogged(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar);

#define glGetClipPlanef glGetClipPlanefLogged
void glGetClipPlanefLogged(GLenum pname, GLfloat *equation);

#define glGetFloatv glGetFloatvLogged
void glGetFloatvLogged(GLenum pname, GLfloat *params);

#define glGetLightfv glGetLightfvLogged
void glGetLightfvLogged(GLenum light, GLenum pname, GLfloat *params);

#define glGetMaterialfv glGetMaterialfvLogged
void glGetMaterialfvLogged(GLenum face, GLenum pname, GLfloat *params);

#define glGetTexEnvfv glGetTexEnvfvLogged
void glGetTexEnvfvLogged(GLenum env, GLenum pname, GLfloat *params);

#define glGetTexParameterfv glGetTexParameterfvLogged
void glGetTexParameterfvLogged(GLenum target, GLenum pname, GLfloat *params);

#define glLightModelf glLightModelfLogged
void glLightModelfLogged(GLenum pname, GLfloat param);

#define glLightModelfv glLightModelfvLogged
void glLightModelfvLogged(GLenum pname, const GLfloat *params);

#define glLightf glLightfLogged
void glLightfLogged(GLenum light, GLenum pname, GLfloat param);

#define glLightfv glLightfvLogged
void glLightfvLogged(GLenum light, GLenum pname, const GLfloat *params);

#define glLineWidth glLineWidthLogged
void glLineWidthLogged(GLfloat width);

#define glLoadMatrixf glLoadMatrixfLogged
void glLoadMatrixfLogged(const GLfloat *m);

#define glMaterialf glMaterialfLogged
void glMaterialfLogged(GLenum face, GLenum pname, GLfloat param);

#define glMaterialfv glMaterialfvLogged
void glMaterialfvLogged(GLenum face, GLenum pname, const GLfloat *params);

#define glMultMatrixf glMultMatrixfLogged
void glMultMatrixfLogged(const GLfloat *m);

#define glMultiTexCoord4f glMultiTexCoord4fLogged
void glMultiTexCoord4fLogged(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q);

#define glNormal3f glNormal3fLogged
void glNormal3fLogged(GLfloat nx, GLfloat ny, GLfloat nz);

#define glOrthof glOrthofLogged
void glOrthofLogged(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar);

#define glPointParameterf glPointParameterfLogged
void glPointParameterfLogged(GLenum pname, GLfloat param);

#define glPointParameterfv glPointParameterfvLogged
void glPointParameterfvLogged(GLenum pname, const GLfloat *params);

#define glPointSize glPointSizeLogged
void glPointSizeLogged(GLfloat size);

#define glPolygonOffset glPolygonOffsetLogged
void glPolygonOffsetLogged(GLfloat factor, GLfloat units);

#define glRotatef glRotatefLogged
void glRotatefLogged(GLfloat angle, GLfloat x, GLfloat y, GLfloat z);

#define glScalef glScalefLogged
void glScalefLogged(GLfloat x, GLfloat y, GLfloat z);

#define glTexEnvf glTexEnvfLogged
void glTexEnvfLogged(GLenum target, GLenum pname, GLfloat param);

#define glTexEnvfv glTexEnvfvLogged
void glTexEnvfvLogged(GLenum target, GLenum pname, const GLfloat *params);

#define glTexParameterf glTexParameterfLogged
void glTexParameterfLogged(GLenum target, GLenum pname, GLfloat param);

#define glTexParameterfv glTexParameterfvLogged
void glTexParameterfvLogged(GLenum target, GLenum pname, const GLfloat *params);

#define glTranslatef glTranslatefLogged
void glTranslatefLogged(GLfloat x, GLfloat y, GLfloat z);

#define glActiveTexture glActiveTextureLogged
void glActiveTextureLogged(GLenum texture);

#define glAlphaFuncx glAlphaFuncxLogged
void glAlphaFuncxLogged(GLenum func, GLclampx ref);

#define glBindBuffer glBindBufferLogged
void glBindBufferLogged(GLenum target, GLuint buffer);

#define glBindTexture glBindTextureLogged
void glBindTextureLogged(GLenum target, GLuint texture);

#define glBlendFunc glBlendFuncLogged
void glBlendFuncLogged(GLenum sfactor, GLenum dfactor);

#define glBufferData glBufferDataLogged
void glBufferDataLogged(GLenum target, GLsizeiptr size, const GLvoid *data, GLenum usage);

#define glBufferSubData glBufferSubDataLogged
void glBufferSubDataLogged(GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid *data);

#define glClear glClearLogged
void glClearLogged(GLbitfield mask);

#define glClearColorx glClearColorxLogged
void glClearColorxLogged(GLclampx red, GLclampx green, GLclampx blue, GLclampx alpha);

#define glClearDepthx glClearDepthxLogged
void glClearDepthxLogged(GLclampx depth);

#define glClearStencil glClearStencilLogged
void glClearStencilLogged(GLint s);

#define glClientActiveTexture glClientActiveTextureLogged
void glClientActiveTextureLogged(GLenum texture);

#define glClipPlanex glClipPlanexLogged
void glClipPlanexLogged(GLenum plane, const GLfixed *equation);

#define glColor4ub glColor4ubLogged
void glColor4ubLogged(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);

#define glColor4x glColor4xLogged
void glColor4xLogged(GLfixed red, GLfixed green, GLfixed blue, GLfixed alpha);

#define glColorMask glColorMaskLogged
void glColorMaskLogged(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);

#define glColorPointer glColorPointerLogged
void glColorPointerLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

#define glCompressedTexImage2D glCompressedTexImage2DLogged
void glCompressedTexImage2DLogged(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid *data);

#define glCompressedTexSubImage2D glCompressedTexSubImage2DLogged
void glCompressedTexSubImage2DLogged(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid *data);

#define glCopyTexImage2D glCopyTexImage2DLogged
void glCopyTexImage2DLogged(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);

#define glCopyTexSubImage2D glCopyTexSubImage2DLogged
void glCopyTexSubImage2DLogged(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);

#define glCullFace glCullFaceLogged
void glCullFaceLogged(GLenum mode);

#define glDeleteBuffers glDeleteBuffersLogged
void glDeleteBuffersLogged(GLsizei n, const GLuint *buffers);

#define glDeleteTextures glDeleteTexturesLogged
void glDeleteTexturesLogged(GLsizei n, const GLuint *textures);

#define glDepthFunc glDepthFuncLogged
void glDepthFuncLogged(GLenum func);

#define glDepthMask glDepthMaskLogged
void glDepthMaskLogged(GLboolean flag);

#define glDepthRangex glDepthRangexLogged
void glDepthRangexLogged(GLclampx zNear, GLclampx zFar);

#define glDisable glDisableLogged
void glDisableLogged(GLenum cap);

#define glDisableClientState glDisableClientStateLogged
void glDisableClientStateLogged(GLenum array);

#define glDrawArrays glDrawArraysLogged
void glDrawArraysLogged(GLenum mode, GLint first, GLsizei count);

#define glDrawElements glDrawElementsLogged
void glDrawElementsLogged(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices);

#define glEnable glEnableLogged
void glEnableLogged(GLenum cap);

#define glEnableClientState glEnableClientStateLogged
void glEnableClientStateLogged(GLenum array);

#define glFinish glFinishLogged
void glFinishLogged(void);

#define glFlush glFlushLogged
void glFlushLogged(void);

#define glFogx glFogxLogged
void glFogxLogged(GLenum pname, GLfixed param);

#define glFogxv glFogxvLogged
void glFogxvLogged(GLenum pname, const GLfixed *params);

#define glFrontFace glFrontFaceLogged
void glFrontFaceLogged(GLenum mode);

#define glFrustumx glFrustumxLogged
void glFrustumxLogged(GLfixed left, GLfixed right, GLfixed bottom, GLfixed top, GLfixed zNear, GLfixed zFar);

#define glGetBooleanv glGetBooleanvLogged
void glGetBooleanvLogged(GLenum pname, GLboolean *params);

#define glGetBufferParameteriv glGetBufferParameterivLogged
void glGetBufferParameterivLogged(GLenum target, GLenum pname, GLint *params);

#define glGetClipPlanex glGetClipPlanexLogged
void glGetClipPlanexLogged(GLenum pname, GLfixed eqn[4]);

#define glGenBuffers glGenBuffersLogged
void glGenBuffersLogged(GLsizei n, GLuint *buffers);

#define glGenTextures glGenTexturesLogged
void glGenTexturesLogged(GLsizei n, GLuint *textures);

#define glGetError glGetErrorLogged
GLenum glGetErrorLogged(void);

#define glGetFixedv glGetFixedvLogged
void glGetFixedvLogged(GLenum pname, GLfixed *params);

#define glGetIntegerv glGetIntegervLogged
void glGetIntegervLogged(GLenum pname, GLint *params);

#define glGetLightxv glGetLightxvLogged
void glGetLightxvLogged(GLenum light, GLenum pname, GLfixed *params);

#define glGetMaterialxv glGetMaterialxvLogged
void glGetMaterialxvLogged(GLenum face, GLenum pname, GLfixed *params);

#define glGetPointerv glGetPointervLogged
void glGetPointervLogged(GLenum pname, void **params);

#define glGetString glGetStringLogged
const GLubyte* glGetStringLogged(GLenum name);

#define glGetTexEnviv glGetTexEnvivLogged
void glGetTexEnvivLogged(GLenum env, GLenum pname, GLint *params);

#define glGetTexEnvxv glGetTexEnvxvLogged
void glGetTexEnvxvLogged(GLenum env, GLenum pname, GLfixed *params);

#define glGetTexParameteriv glGetTexParameterivLogged
void glGetTexParameterivLogged(GLenum target, GLenum pname, GLint *params);

#define glGetTexParameterxv glGetTexParameterxvLogged
void glGetTexParameterxvLogged(GLenum target, GLenum pname, GLfixed *params);

#define glHint glHintLogged
void glHintLogged(GLenum target, GLenum mode);

#define glIsBuffer glIsBufferLogged
GLboolean glIsBufferLogged(GLuint buffer);

#define glIsEnabled glIsEnabledLogged
GLboolean glIsEnabledLogged(GLenum cap);

#define glIsTexture glIsTextureLogged
GLboolean glIsTextureLogged(GLuint texture);

#define glLightModelx glLightModelxLogged
void glLightModelxLogged(GLenum pname, GLfixed param);

#define glLightModelxv glLightModelxvLogged
void glLightModelxvLogged(GLenum pname, const GLfixed *params);

#define glLightx glLightxLogged
void glLightxLogged(GLenum light, GLenum pname, GLfixed param);

#define glLightxv glLightxvLogged
void glLightxvLogged(GLenum light, GLenum pname, const GLfixed *params);

#define glLineWidthx glLineWidthxLogged
void glLineWidthxLogged(GLfixed width);

#define glLoadIdentity glLoadIdentityLogged
void glLoadIdentityLogged(void);

#define glLoadMatrixx glLoadMatrixxLogged
void glLoadMatrixxLogged(const GLfixed *m);

#define glLogicOp glLogicOpLogged
void glLogicOpLogged(GLenum opcode);

#define glMaterialx glMaterialxLogged
void glMaterialxLogged(GLenum face, GLenum pname, GLfixed param);

#define glMaterialxv glMaterialxvLogged
void glMaterialxvLogged(GLenum face, GLenum pname, const GLfixed *params);

#define glMatrixMode glMatrixModeLogged
void glMatrixModeLogged(GLenum mode);

#define glMultMatrixx glMultMatrixxLogged
void glMultMatrixxLogged(const GLfixed *m);

#define glMultiTexCoord4x glMultiTexCoord4xLogged
void glMultiTexCoord4xLogged(GLenum target, GLfixed s, GLfixed t, GLfixed r, GLfixed q);

#define glNormal3x glNormal3xLogged
void glNormal3xLogged(GLfixed nx, GLfixed ny, GLfixed nz);

#define glNormalPointer glNormalPointerLogged
void glNormalPointerLogged(GLenum type, GLsizei stride, const GLvoid *pointer);

#define glOrthox glOrthoxLogged
void glOrthoxLogged(GLfixed left, GLfixed right, GLfixed bottom, GLfixed top, GLfixed zNear, GLfixed zFar);

#define glPixelStorei glPixelStoreiLogged
void glPixelStoreiLogged(GLenum pname, GLint param);

#define glPointParameterx glPointParameterxLogged
void glPointParameterxLogged(GLenum pname, GLfixed param);

#define glPointParameterxv glPointParameterxvLogged
void glPointParameterxvLogged(GLenum pname, const GLfixed *params);

#define glPointSizex glPointSizexLogged
void glPointSizexLogged(GLfixed size);

#define glPolygonOffsetx glPolygonOffsetxLogged
void glPolygonOffsetxLogged(GLfixed factor, GLfixed units);

#define glPopMatrix glPopMatrixLogged
void glPopMatrixLogged(void);

#define glPushMatrix glPushMatrixLogged
void glPushMatrixLogged(void);

#define glReadPixels glReadPixelsLogged
void glReadPixelsLogged(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);

#define glRotatex glRotatexLogged
void glRotatexLogged(GLfixed angle, GLfixed x, GLfixed y, GLfixed z);

#define glSampleCoverage glSampleCoverageLogged
void glSampleCoverageLogged(GLclampf value, GLboolean invert);

#define glSampleCoveragex glSampleCoveragexLogged
void glSampleCoveragexLogged(GLclampx value, GLboolean invert);

#define glScalex glScalexLogged
void glScalexLogged(GLfixed x, GLfixed y, GLfixed z);

#define glScissor glScissorLogged
void glScissorLogged(GLint x, GLint y, GLsizei width, GLsizei height);

#define glShadeModel glShadeModelLogged
void glShadeModelLogged(GLenum mode);

#define glStencilFunc glStencilFuncLogged
void glStencilFuncLogged(GLenum func, GLint ref, GLuint mask);

#define glStencilMask glStencilMaskLogged
void glStencilMaskLogged(GLuint mask);

#define glStencilOp glStencilOpLogged
void glStencilOpLogged(GLenum fail, GLenum zfail, GLenum zpass);

#define glTexCoordPointer glTexCoordPointerLogged
void glTexCoordPointerLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

#define glTexEnvi glTexEnviLogged
void glTexEnviLogged(GLenum target, GLenum pname, GLint param);

#define glTexEnvx glTexEnvxLogged
void glTexEnvxLogged(GLenum target, GLenum pname, GLfixed param);

#define glTexEnviv glTexEnvivLogged
void glTexEnvivLogged(GLenum target, GLenum pname, const GLint *params);

#define glTexEnvxv glTexEnvxvLogged
void glTexEnvxvLogged(GLenum target, GLenum pname, const GLfixed *params);

#define glTexImage2D glTexImage2DLogged
void glTexImage2DLogged(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels);

#define glTexParameteri glTexParameteriLogged
void glTexParameteriLogged(GLenum target, GLenum pname, GLint param);

#define glTexParameterx glTexParameterxLogged
void glTexParameterxLogged(GLenum target, GLenum pname, GLfixed param);

#define glTexParameteriv glTexParameterivLogged
void glTexParameterivLogged(GLenum target, GLenum pname, const GLint *params);

#define glTexParameterxv glTexParameterxvLogged
void glTexParameterxvLogged(GLenum target, GLenum pname, const GLfixed *params);

#define glTexSubImage2D glTexSubImage2DLogged
void glTexSubImage2DLogged(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels);

#define glTranslatex glTranslatexLogged
void glTranslatexLogged(GLfixed x, GLfixed y, GLfixed z);

#define glVertexPointer glVertexPointerLogged
void glVertexPointerLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

#define glViewport glViewportLogged
void glViewportLogged(GLint x, GLint y, GLsizei width, GLsizei height);



#pragma mark OpenGLES extensions from gl.h base file

#define glCurrentPaletteMatrixOES glCurrentPaletteMatrixOESLogged
void glCurrentPaletteMatrixOESLogged(GLuint matrixpaletteindex);

#define glLoadPaletteFromModelViewMatrixOES glLoadPaletteFromModelViewMatrixOESLogged
void glLoadPaletteFromModelViewMatrixOESLogged(void);

#define glMatrixIndexPointerOES glMatrixIndexPointerOESLogged
void glMatrixIndexPointerOESLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

#define glWeightPointerOES glWeightPointerOESLogged
void glWeightPointerOESLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

#define glPointSizePointerOES glPointSizePointerOESLogged
void glPointSizePointerOESLogged(GLenum type, GLsizei stride, const GLvoid *pointer);

#define glDrawTexsOES glDrawTexsOESLogged
void glDrawTexsOESLogged(GLshort x, GLshort y, GLshort z, GLshort width, GLshort height);

#define glDrawTexiOES glDrawTexiOESLogged
void glDrawTexiOESLogged(GLint x, GLint y, GLint z, GLint width, GLint height);

#define glDrawTexxOES glDrawTexxOESLogged
void glDrawTexxOESLogged(GLfixed x, GLfixed y, GLfixed z, GLfixed width, GLfixed height);

#define glDrawTexsvOES glDrawTexsvOESLogged
void glDrawTexsvOESLogged(const GLshort *coords);

#define glDrawTexivOES glDrawTexivOESLogged
void glDrawTexivOESLogged(const GLint *coords);

#define glDrawTexxvOES glDrawTexxvOESLogged
void glDrawTexxvOESLogged(const GLfixed *coords);

#define glDrawTexfOES glDrawTexfOESLogged
void glDrawTexfOESLogged(GLfloat x, GLfloat y, GLfloat z, GLfloat width, GLfloat height);

#define glDrawTexfvOES glDrawTexfvOESLogged
void glDrawTexfvOESLogged(const GLfloat *coords);


#pragma mark OpenGLES extensions from glext.h extensions file

#define glBlendEquationOES glBlendEquationOESLogged
void glBlendEquationOESLogged(GLenum mode);

#define glIsRenderbufferOES glIsRenderbufferOESLogged
GLboolean glIsRenderbufferOESLogged(GLuint renderbuffer);

#define glBindRenderbufferOES glBindRenderbufferOESLogged
void glBindRenderbufferOESLogged(GLenum target, GLuint renderbuffer);

#define glDeleteRenderbuffersOES glDeleteRenderbuffersOESLogged
void glDeleteRenderbuffersOESLogged(GLsizei n, const GLuint* renderbuffers);

#define glGenRenderbuffersOES glGenRenderbuffersOESLogged
void glGenRenderbuffersOESLogged(GLsizei n, GLuint* renderbuffers);

#define glRenderbufferStorageOES glRenderbufferStorageOESLogged
void glRenderbufferStorageOESLogged(GLenum target, GLenum internalformat, GLsizei width, GLsizei height);

#define glGetRenderbufferParameterivOES glGetRenderbufferParameterivOESLogged
void glGetRenderbufferParameterivOESLogged(GLenum target, GLenum pname, GLint* params);

#define glIsFramebufferOES glIsFramebufferOESLogged
GLboolean glIsFramebufferOESLogged(GLuint framebuffer);

#define glBindFramebufferOES glBindFramebufferOESLogged
void glBindFramebufferOESLogged(GLenum target, GLuint framebuffer);

#define glDeleteFramebuffersOES glDeleteFramebuffersOESLogged
void glDeleteFramebuffersOESLogged(GLsizei n, const GLuint* framebuffers);

#define glGenFramebuffersOES glGenFramebuffersOESLogged
void glGenFramebuffersOESLogged(GLsizei n, GLuint* framebuffers);

#define glCheckFramebufferStatusOES glCheckFramebufferStatusOESLogged
GLenum glCheckFramebufferStatusOESLogged(GLenum target);

#define glFramebufferRenderbufferOES glFramebufferRenderbufferOESLogged
void glFramebufferRenderbufferOESLogged(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);

#define glFramebufferTexture2DOES glFramebufferTexture2DOESLogged
void glFramebufferTexture2DOESLogged(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);

#define glGetFramebufferAttachmentParameterivOES glGetFramebufferAttachmentParameterivOESLogged
void glGetFramebufferAttachmentParameterivOESLogged(GLenum target, GLenum attachment, GLenum pname, GLint* params);

#define glGenerateMipmapOES glGenerateMipmapOESLogged
void glGenerateMipmapOESLogged(GLenum target);

#define glGetBufferPointervOES glGetBufferPointervOESLogged
void glGetBufferPointervOESLogged(GLenum target, GLenum pname, GLvoid **params);

#define glMapBufferOES glMapBufferOESLogged
GLvoid* glMapBufferOESLogged(GLenum target, GLenum access);

#define glUnmapBufferOES glUnmapBufferOESLogged
GLboolean glUnmapBufferOESLogged(GLenum target);

#endif
