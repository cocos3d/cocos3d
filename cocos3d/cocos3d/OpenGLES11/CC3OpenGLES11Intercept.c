/*
 * CC3OpenGLES11Intercept.c
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

#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include "CC3OpenGLES11Utility.h"
// This file deliberately does NOT include the CC3OpenGLES11Intercept.h file
// because doing so would swap out the actual gl* calls! This implementation
// file must have access to the actual gl* functions.

#ifndef kPrintGLDataVertexCount
#	define kPrintGLDataVertexCount 8
#endif

#ifndef kPrintGLDataBufferDataCount
#	define kPrintGLDataBufferDataCount 64
#endif

#ifndef kMinGLPointerAddress
#	define kMinGLPointerAddress 8192
#endif

void PrintGLData(GLint elemSize, GLenum dataType, GLsizei stride, GLuint elemCount, const GLvoid* pointer) {
	if (pointer > (GLvoid*)kMinGLPointerAddress && elemCount) {
		size_t dataTypeSize = GLElementTypeSize(dataType);
		if (dataTypeSize == 0) {
			printf("Illegal GL data type %u", dataType);
			return;
		}
		GLsizei dataTypeStride = stride ? (stride / dataTypeSize) : elemSize; 
		GLvoid* p = (GLvoid*)pointer;
		GLuint printCount = elemCount * dataTypeStride;
		printf("\t(");
		for (GLuint i = 0; i < printCount; i++, p += dataTypeSize) {
			if (i > 0) printf(", ");
			if (dataTypeStride > 1 && (i % dataTypeStride == 0)) {
				printf("[");
			}
			switch (dataType) {
				case GL_BYTE:
					printf("%i", *(GLbyte*)p);
					break;
				case GL_UNSIGNED_BYTE:
					printf("%u", *(GLubyte*)p);
					break;
				case GL_SHORT:
					printf("%i", *(GLshort*)p);
					break;
				case GL_UNSIGNED_SHORT:
					printf("%u", *(GLushort*)p);
					break;
				case GL_FLOAT:
					printf("%.4f", *(GLfloat*)p);
					break;
				case GL_FIXED:
					printf("%i", *(GLfixed*)p);
					break;
				default:
					printf("Cannot print data from illegal data type %u", dataType);
			}	
			
			if (dataTypeStride > 1 && (i % dataTypeStride == (elemSize - 1))) {
				printf("]");
			}
		}
		printf("...)\n");
	}
}


#pragma mark OpenGLES base

void glAlphaFuncLogged(GLenum func, GLclampf ref) {
	printf("glAlphaFunc(%s, %.2f)\n", GLEnumName(func), ref);
	glAlphaFunc(func, ref);
}

void glClearColorLogged(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) {
	printf("glClearColor(%.2f, %.2f, %.2f, %.2f)\n", red, green, blue, alpha);
	glClearColor(red, green, blue, alpha);
}

void glClearDepthfLogged(GLclampf depth) {
	printf("glClearDepthf(%.2f)\n", depth);
	glClearDepthf(depth);
}

void glClipPlanefLogged(GLenum plane, const GLfloat *equation) {
	printf("glClipPlanef(%s, %p)\n", GLEnumName(plane), equation);
	glClipPlanef(plane, equation);
}

void glColor4fLogged(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	printf("glColor4f(%.2f, %.2f, %.2f, %.2f)\n", red, green, blue, alpha);
	glColor4f(red, green, blue, alpha);
}

void glDepthRangefLogged(GLclampf zNear, GLclampf zFar) {
	printf("glDepthRangef(%.2f, %.2f)\n", zNear, zFar);
	glDepthRangef(zNear, zFar);
}

void glFogfLogged(GLenum pname, GLfloat param) {
	printf("glFogf(%s, %.2f)\n", GLEnumName(pname), param);
	glFogf(pname, param);
}

void glFogfvLogged(GLenum pname, const GLfloat *params) {
	printf("glFogfv(%s, %p)\n", GLEnumName(pname), params);
	glFogfv(pname, params);
}

void glFrustumfLogged(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar) {
	printf("glFrustumf(%.2f, %.2f, %.2f, %.2f, %.2f, %.2f)\n", left, right, bottom, top, zNear, zFar);
	glFrustumf(left, right, bottom, top, zNear, zFar);
}

void glGetClipPlanefLogged(GLenum pname, GLfloat *equation) {
	printf("glGetClipPlanef(%s, %p)\n", GLEnumName(pname), equation);
	glGetClipPlanef(pname, equation);
}

void glGetFloatvLogged(GLenum pname, GLfloat *params) {
	printf("glGetFloatv(%s, %p)\n", GLEnumName(pname), params);
	glGetFloatv(pname, params);
}

void glGetLightfvLogged(GLenum light, GLenum pname, GLfloat *params) {
	printf("glGetLightfv(%s, %s, %p)\n", GLEnumName(light), GLEnumName(pname), params);
	glGetLightfv(light, pname, params);
}

void glGetMaterialfvLogged(GLenum face, GLenum pname, GLfloat *params) {
	printf("glGetMaterialfv(%s, %s, %p)\n", GLEnumName(face), GLEnumName(pname), params);
	glGetMaterialfv(face, pname, params);
}

void glGetTexEnvfvLogged(GLenum env, GLenum pname, GLfloat *params) {
	printf("glGetTexEnvfv(%s, %s, %p)\n", GLEnumName(env), GLEnumName(pname), params);
	glGetTexEnvfv(env, pname, params);
}

void glGetTexParameterfvLogged(GLenum target, GLenum pname, GLfloat *params) {
	printf("glGetTexParameterfv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glGetTexParameterfv(target, pname, params);
}

void glLightModelfLogged(GLenum pname, GLfloat param) {
	printf("glLightModelf(%s, %.2f)\n", GLEnumName(pname), param);
	glLightModelf(pname, param);
}

void glLightModelfvLogged(GLenum pname, const GLfloat *params) {
	printf("glLightModelfv(%s, %p)\n", GLEnumName(pname), params);
	glLightModelfv(pname, params);
}

void glLightfLogged(GLenum light, GLenum pname, GLfloat param) {
	printf("glLightf(%s, %s, %.2f)\n", GLEnumName(light), GLEnumName(pname), param);
	glLightf(light, pname, param);
}

void glLightfvLogged(GLenum light, GLenum pname, const GLfloat *params) {
	printf("glLightfv(%s, %s, %p)\n", GLEnumName(light), GLEnumName(pname), params);
	PrintGLData(1, GL_FLOAT, 0, 4, params);
	glLightfv(light, pname, params);
}

void glLineWidthLogged(GLfloat width) {
	printf("glLineWidth(%.2f)\n", width);
	glLineWidth(width);
}

void glLoadMatrixfLogged(const GLfloat *m) {
	printf("glLoadMatrixf(%p)\n", m);
	glLoadMatrixf(m);
}

void glMaterialfLogged(GLenum face, GLenum pname, GLfloat param) {
	printf("glMaterialf(%s, %s, %.2f)\n", GLEnumName(face), GLEnumName(pname), param);
	glMaterialf(face, pname, param);
}

void glMaterialfvLogged(GLenum face, GLenum pname, const GLfloat *params) {
	printf("glMaterialfv(%s, %s, %p)\n", GLEnumName(face), GLEnumName(pname), params);
	PrintGLData(1, GL_FLOAT, 0, 4, params);
	glMaterialfv(face, pname, params);
}

void glMultMatrixfLogged(const GLfloat *m) {
	printf("glMultMatrixf(%p)\n", m);
	glMultMatrixf(m);
}

void glMultiTexCoord4fLogged(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q) {
	printf("glMultiTexCoord4f(%s, %.2f, %.2f, %.2f, %.2f)\n", GLEnumName(target), s, t, r, q);
	glMultiTexCoord4f(target, s, t, r, q);
}

void glNormal3fLogged(GLfloat nx, GLfloat ny, GLfloat nz) {
	printf("glNormal3f(%.2f, %.2f, %.2f)\n", nx, ny, nz);
	glNormal3f(nx, ny, nz);
}

void glOrthofLogged(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar) {
	printf("glOrthof(%.2f, %.2f, %.2f, %.2f, %.2f, %.2f)\n", left, right, bottom, top, zNear, zFar);
	glOrthof(left, right, bottom, top, zNear, zFar);
}

void glPointParameterfLogged(GLenum pname, GLfloat param) {
	printf("glPointParameterf(%s, %.2f)\n", GLEnumName(pname), param);
	glPointParameterf(pname, param);
}

void glPointParameterfvLogged(GLenum pname, const GLfloat *params) {
	printf("glPointParameterfv(%s, %p)\n", GLEnumName(pname), params);
	glPointParameterfv(pname, params);
}

void glPointSizeLogged(GLfloat size) {
	printf("glPointSize(%.2f)\n", size);
	glPointSize(size);
}

void glPolygonOffsetLogged(GLfloat factor, GLfloat units) {
	printf("glPolygonOffset(%.2f, %.2f)\n", factor, units);
	glPolygonOffset(factor, units);
}

void glRotatefLogged(GLfloat angle, GLfloat x, GLfloat y, GLfloat z) {
	printf("glRotatef(%.2f, %.2f, %.2f, %.2f)\n", angle, x, y, z);
	glRotatef(angle, x, y, z);
}

void glScalefLogged(GLfloat x, GLfloat y, GLfloat z) {
	printf("glScalef(%.2f, %.2f, %.2f)\n", x, y, z);
	glScalef(x, y, z);
}

void glTexEnvfLogged(GLenum target, GLenum pname, GLfloat param) {
	printf("glTexEnvf(%s, %s, %.2f)\n", GLEnumName(target), GLEnumName(pname), param);
	glTexEnvf(target, pname, param);
}

void glTexEnvfvLogged(GLenum target, GLenum pname, const GLfloat *params) {
	printf("glTexEnvfv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glTexEnvfv(target, pname, params);
}

void glTexParameterfLogged(GLenum target, GLenum pname, GLfloat param) {
	printf("glTexParameterf(%s, %s, %.2f)\n", GLEnumName(target), GLEnumName(pname), param);
	glTexParameterf(target, pname, param);
}

void glTexParameterfvLogged(GLenum target, GLenum pname, const GLfloat *params) {
	printf("glTexParameterfv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glTexParameterfv(target, pname, params);
}

void glTranslatefLogged(GLfloat x, GLfloat y, GLfloat z) {
	printf("glTranslatef(%.2f, %.2f, %.2f)\n", x, y, z);
	glTranslatef(x, y, z);
}

void glActiveTextureLogged(GLenum texture) {
	printf("glActiveTexture(%s)\n", GLEnumName(texture));
	glActiveTexture(texture);
}

void glAlphaFuncxLogged(GLenum func, GLclampx ref) {
	printf("glAlphaFuncx(%s, %i)\n", GLEnumName(func), ref);
	glAlphaFuncx(func, ref);
}

void glBindBufferLogged(GLenum target, GLuint buffer) {
	printf("glBindBuffer(%s, %u)\n", GLEnumName(target), buffer);
	glBindBuffer(target, buffer);
}

void glBindTextureLogged(GLenum target, GLuint texture) {
	printf("glBindTexture(%s, %u)\n", GLEnumName(target), texture);
	glBindTexture(target, texture);
}

void glBlendFuncLogged(GLenum sfactor, GLenum dfactor) {
	printf("glBlendFunc(%s, %s)\n", GLEnumName(sfactor), GLEnumName(dfactor));
	glBlendFunc(sfactor, dfactor);
}

void glBufferDataLogged(GLenum target, GLsizeiptr size, const GLvoid *data, GLenum usage) {
	printf("glBufferData(%s, %ld, %p, %s)\n", GLEnumName(target), (long)size, data, GLEnumName(usage));
	switch (target) {
		case GL_ARRAY_BUFFER:
			printf("As floats:");
			PrintGLData(1, GL_FLOAT, 0, kPrintGLDataBufferDataCount, data);
			break;
		case GL_ELEMENT_ARRAY_BUFFER:
			printf("As shorts:");
			PrintGLData(1, GL_UNSIGNED_SHORT, 0, kPrintGLDataBufferDataCount, data);
			break;
		default:
			break;
	}
	glBufferData(target, size, data, usage);
}

void glBufferSubDataLogged(GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid *data) {
	printf("glBufferSubData(%s, %ld, %ld, %p)\n", GLEnumName(target), (long)offset, (long)size, data);
	switch (target) {
		case GL_ARRAY_BUFFER:
			printf("As floats:");
			PrintGLData(1, GL_FLOAT, 0, kPrintGLDataBufferDataCount, data + offset);
			break;
		case GL_ELEMENT_ARRAY_BUFFER:
			printf("As shorts:");
			PrintGLData(1, GL_UNSIGNED_SHORT, 0, kPrintGLDataBufferDataCount, data + offset);
			break;
		default:
			break;
	}
	glBufferSubData(target, offset, size, data);
}

void glClearLogged(GLbitfield mask) {
	printf("glClear(%X)\n", mask);
	glClear(mask);
}

void glClearColorxLogged(GLclampx red, GLclampx green, GLclampx blue, GLclampx alpha) {
	printf("glClearColorx(%i, %i, %i, %i)\n", red, green, blue, alpha);
	glClearColorx(red, green, blue, alpha);
}

void glClearDepthxLogged(GLclampx depth) {
	printf("glClearDepthx(%i)\n", depth);
	glClearDepthx(depth);
}

void glClearStencilLogged(GLint s) {
	printf("glClearStencil(%i)\n", s);
	glClearStencil(s);
}

void glClientActiveTextureLogged(GLenum texture) {
	printf("glClientActiveTexture(%s)\n", GLEnumName(texture));
	glClientActiveTexture(texture);
}

void glClipPlanexLogged(GLenum plane, const GLfixed *equation) {
	printf("glClipPlanex(%s, %p)\n", GLEnumName(plane), equation);
	glClipPlanex(plane, equation);
}

void glColor4ubLogged(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha) {
	printf("glColor4ub(%u, %u, %u, %u)\n", red, green, blue, alpha);
	glColor4ub(red, green, blue, alpha);
}

void glColor4xLogged(GLfixed red, GLfixed green, GLfixed blue, GLfixed alpha) {
	printf("glColor4x(%i, %i, %i, %i)\n", red, green, blue, alpha);
	glColor4x(red, green, blue, alpha);
}

void glColorMaskLogged(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) {
	printf("glColorMask(%u, %u, %u, %u)\n", red, green, blue, alpha);
	glColorMask(red, green, blue, alpha);
}

void glColorPointerLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glColorPointer(%i, %s, %i, %p)\n", size, GLEnumName(type), stride, pointer);
	PrintGLData(size, type, stride, kPrintGLDataVertexCount, pointer);
	glColorPointer(size, type, stride, pointer);
}

void glCompressedTexImage2DLogged(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid *data) {
	printf("glCompressedTexImage2D(%s, %i, %s, %i, %i, %i, %i, %p)\n", GLEnumName(target), level, GLEnumName(internalformat), width, height, border, imageSize, data);
	glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
}

void glCompressedTexSubImage2DLogged(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid *data) {
	printf("glCompressedTexSubImage2D(%s, %i, %i, %i, %i, %i, %s, %i, %p)\n", GLEnumName(target), level, xoffset, yoffset, width, height, GLEnumName(format), imageSize, data);
	glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, imageSize, data);
}

void glCopyTexImage2DLogged(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border) {
	printf("glCopyTexImage2D(%s, %i, %s, %i, %i, %i, %i, %i)\n", GLEnumName(target), level, GLEnumName(internalformat), x, y, width, height, border);
	glCopyTexImage2D(target, level, internalformat, x, y, width, height, border);
}

void glCopyTexSubImage2DLogged(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height) {
	printf("glCopyTexSubImage2D(%s, %i, %i, %i, %i, %i, %i, %i)\n", GLEnumName(target), level, xoffset, yoffset, x, y, width, height);
	glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
}

void glCullFaceLogged(GLenum mode) {
	printf("glCullFace(%s)\n", GLEnumName(mode));
	glCullFace(mode);
}

void glDeleteBuffersLogged(GLsizei n, const GLuint *buffers) {
	printf("glDeleteBuffers(%i, %p)\n", n, buffers);
	glDeleteBuffers(n, buffers);
}

void glDeleteTexturesLogged(GLsizei n, const GLuint *textures) {
	printf("glDeleteTextures(%i, %p)\n", n, textures);
	glDeleteTextures(n, textures);
}

void glDepthFuncLogged(GLenum func) {
	printf("glDepthFunc(%s)\n", GLEnumName(func));
	glDepthFunc(func);
}

void glDepthMaskLogged(GLboolean flag) {
	printf("glDepthMask(%u)\n", flag);
	glDepthMask(flag);
}

void glDepthRangexLogged(GLclampx zNear, GLclampx zFar) {
	printf("glDepthRangex()\n");
	glDepthRangex(zNear, zFar);
}

void glDisableLogged(GLenum cap) {
	printf("glDisable(%s)\n", GLEnumName(cap));
	glDisable(cap);
}

void glDisableClientStateLogged(GLenum array) {
	printf("glDisableClientState(%s)\n", GLEnumName(array));
	glDisableClientState(array);
}

void glDrawArraysLogged(GLenum mode, GLint first, GLsizei count) {
	printf("glDrawArrays(%s, %i, %i)\n", GLEnumName(mode), first, count);
	glDrawArrays(mode, first, count);
}

void glDrawElementsLogged(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices) {
	printf("glDrawElements(%s, %i, %s, %p)\n", GLEnumName(mode), count, GLEnumName(type), indices);
	PrintGLData(1, type, 0, kPrintGLDataVertexCount, indices);
	glDrawElements(mode, count, type, indices);
}

void glEnableLogged(GLenum cap) {
	printf("glEnable(%s)\n", GLEnumName(cap));
	glEnable(cap);
}

void glEnableClientStateLogged(GLenum array) {
	printf("glEnableClientState(%s)\n", GLEnumName(array));
	glEnableClientState(array);
}

void glFinishLogged() {
	printf("glFinish()\n");
	glFinish();
}

void glFlushLogged() {
	printf("glFlush()\n");
	glFlush();
}

void glFogxLogged(GLenum pname, GLfixed param) {
	printf("glFogx(%s, %i)\n", GLEnumName(pname), param);
	glFogx(pname, param);
}

void glFogxvLogged(GLenum pname, const GLfixed *params) {
	printf("glFogxv(%s, %p)\n", GLEnumName(pname), params);
	glFogxv(pname, params);
}

void glFrontFaceLogged(GLenum mode) {
	printf("glFrontFace(%s)\n", GLEnumName(mode));
	glFrontFace(mode);
}

void glFrustumxLogged(GLfixed left, GLfixed right, GLfixed bottom, GLfixed top, GLfixed zNear, GLfixed zFar) {
	printf("glFrustumx(%i, %i, %i, %i, %i, %i)\n", left, right, bottom, top, zNear, zFar);
	glFrustumx(left, right, bottom, top, zNear, zFar);
}

void glGetBooleanvLogged(GLenum pname, GLboolean *params) {
	printf("glGetBooleanv(%s, %p)\n", GLEnumName(pname), params);
	glGetBooleanv(pname, params);
}

void glGetBufferParameterivLogged(GLenum target, GLenum pname, GLint *params) {
	printf("glGetBufferParameteriv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glGetBufferParameteriv(target, pname, params);
}

void glGetClipPlanexLogged(GLenum pname, GLfixed eqn[4]) {
	printf("glGetClipPlanex(%s, %i, %i, %i, %i)\n", GLEnumName(pname), eqn[0], eqn[1], eqn[2], eqn[3]);
	glGetClipPlanex(pname, eqn);
}

void glGenBuffersLogged(GLsizei n, GLuint *buffers) {
	printf("glGenBuffers(%i, %p)\n", n, buffers);
	glGenBuffers(n, buffers);
}

void glGenTexturesLogged(GLsizei n, GLuint *textures) {
	printf("glGenTextures(%i, %p)\n", n, textures);
	glGenTextures(n, textures);
}

GLenum glGetErrorLogged() {
	printf("glGetError()\n");
	return glGetError();
}

void glGetFixedvLogged(GLenum pname, GLfixed *params) {
	printf("glGetFixedv()\n");
	glGetFixedv(pname, params);
}

void glGetIntegervLogged(GLenum pname, GLint *params) {
	printf("glGetIntegerv(%s, %p)\n", GLEnumName(pname), params);
	glGetIntegerv(pname, params);
}

void glGetLightxvLogged(GLenum light, GLenum pname, GLfixed *params) {
	printf("glGetLightxv(%s, %s, %p)\n", GLEnumName(light), GLEnumName(pname), params);
	glGetLightxv(light, pname, params);
}

void glGetMaterialxvLogged(GLenum face, GLenum pname, GLfixed *params) {
	printf("glGetMaterialxv(%s, %s, %p)\n", GLEnumName(face), GLEnumName(pname), params);
	PrintGLData(1, GL_FIXED, 0, 4, params);
	glGetMaterialxv(face, pname, params);
}

void glGetPointervLogged(GLenum pname, void **params) {
	printf("glGetPointerv(%s, %p)\n", GLEnumName(pname), params);
	glGetPointerv(pname, params);
}

const GLubyte* glGetStringLogged(GLenum name) {
	const GLubyte* str = glGetString(name);
	printf("glGetString(%s) = %s", GLEnumName(name), str);
	return str;
}

void glGetTexEnvivLogged(GLenum env, GLenum pname, GLint *params) {
	printf("glGetTexEnviv(%s, %s, %p)\n", GLEnumName(env), GLEnumName(pname), params);
	glGetTexEnviv(env, pname, params);
}

void glGetTexEnvxvLogged(GLenum env, GLenum pname, GLfixed *params) {
	printf("glGetTexEnvxv(%s, %s, %p)\n", GLEnumName(env), GLEnumName(pname), params);
	glGetTexEnvxv(env, pname, params);
}

void glGetTexParameterivLogged(GLenum target, GLenum pname, GLint *params) {
	printf("glGetTexParameteriv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glGetTexParameteriv(target, pname, params);
}

void glGetTexParameterxvLogged(GLenum target, GLenum pname, GLfixed *params) {
	printf("glGetTexParameterxv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glGetTexParameterxv(target, pname, params);
}

void glHintLogged(GLenum target, GLenum mode) {
	printf("glHint(%s, %s)\n", GLEnumName(target), GLEnumName(mode));
	glHint(target, mode);
}

GLboolean glIsBufferLogged(GLuint buffer) {
	printf("glIsBuffer(%u)\n", buffer);
	return glIsBuffer(buffer);
}

GLboolean glIsEnabledLogged(GLenum cap) {
	printf("glIsEnabled(%s)\n", GLEnumName(cap));
	return glIsEnabled(cap);
}

GLboolean glIsTextureLogged(GLuint texture) {
	printf("glIsTexture(%u)\n", texture);
	return glIsTexture(texture);
}

void glLightModelxLogged(GLenum pname, GLfixed param) {
	printf("glLightModelx(%s, %i)\n", GLEnumName(pname), param);
	glLightModelx(pname, param);
}

void glLightModelxvLogged(GLenum pname, const GLfixed *params) {
	printf("glLightModelxv(%s, %p)\n", GLEnumName(pname), params);
	glLightModelxv(pname, params);
}

void glLightxLogged(GLenum light, GLenum pname, GLfixed param) {
	printf("glLightx(%s, %s, %i)\n", GLEnumName(light), GLEnumName(pname), param);
	glLightx(light, pname, param);
}

void glLightxvLogged(GLenum light, GLenum pname, const GLfixed *params) {
	printf("glLightxv(%s, %s, %p)\n", GLEnumName(light), GLEnumName(pname), params);
	PrintGLData(1, GL_FIXED, 0, 4, params);
	glLightxv(light, pname, params);
}

void glLineWidthxLogged(GLfixed width) {
	printf("glLineWidthx(%i)\n", width);
	glLineWidthx(width);
}

void glLoadIdentityLogged() {
	printf("glLoadIdentity()\n");
	glLoadIdentity();
}

void glLoadMatrixxLogged(const GLfixed *m) {
	printf("glLoadMatrixx(%p)\n", m);
	glLoadMatrixx(m);
}

void glLogicOpLogged(GLenum opcode) {
	printf("glLogicOp(%s)\n", GLEnumName(opcode));
	glLogicOp(opcode);
}

void glMaterialxLogged(GLenum face, GLenum pname, GLfixed param) {
	printf("glMaterialx(%s, %s, %i)\n", GLEnumName(face), GLEnumName(pname), param);
	glMaterialx(face, pname, param);
}

void glMaterialxvLogged(GLenum face, GLenum pname, const GLfixed *params) {
	printf("glMaterialxv(%s, %s, %p)\n", GLEnumName(face), GLEnumName(pname), params);
	glMaterialxv(face, pname, params);
}

void glMatrixModeLogged(GLenum mode) {
	printf("glMatrixMode(%s)\n", GLEnumName(mode));
	glMatrixMode(mode);
}

void glMultMatrixxLogged(const GLfixed *m) {
	printf("glMultMatrixx(%p)\n", m);
	glMultMatrixx(m);
}

void glMultiTexCoord4xLogged(GLenum target, GLfixed s, GLfixed t, GLfixed r, GLfixed q) {
	printf("glMultiTexCoord4x(%s, %i, %i, %i, %i)\n", GLEnumName(target), s, t, r, q);
	glMultiTexCoord4x(target, s, t, r, q);
}

void glNormal3xLogged(GLfixed nx, GLfixed ny, GLfixed nz) {
	printf("glNormal3x(%i, %i, %i)\n", nx, ny, nz);
	glNormal3x(nx, ny, nz);
}

void glNormalPointerLogged(GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glNormalPointer(%s, %i, %p)\n", GLEnumName(type), stride, pointer);
	PrintGLData(3, type, stride, kPrintGLDataVertexCount, pointer);
	glNormalPointer(type, stride, pointer);
}

void glOrthoxLogged(GLfixed left, GLfixed right, GLfixed bottom, GLfixed top, GLfixed zNear, GLfixed zFar) {
	printf("glOrthox(%i, %i, %i, %i, %i, %i)\n", left, right, bottom, top, zNear, zFar);
	glOrthox(left, right, bottom, top, zNear, zFar);
}

void glPixelStoreiLogged(GLenum pname, GLint param) {
	printf("glPixelStorei(%s, %i)\n", GLEnumName(pname), param);
	glPixelStorei(pname, param);
}

void glPointParameterxLogged(GLenum pname, GLfixed param) {
	printf("glPointParameterx(%s, %i)\n", GLEnumName(pname), param);
	glPointParameterx(pname, param);
}

void glPointParameterxvLogged(GLenum pname, const GLfixed *params) {
	printf("glPointParameterxv(%s, %p)\n", GLEnumName(pname), params);
	glPointParameterxv(pname, params);
}

void glPointSizexLogged(GLfixed size) {
	printf("glPointSizex(%i)\n", size);
	glPointSizex(size);
}

void glPolygonOffsetxLogged(GLfixed factor, GLfixed units) {
	printf("glPolygonOffsetx(%i, %i)\n", factor, units);
	glPolygonOffsetx(factor, units);
}

void glPopMatrixLogged() {
	printf("glPopMatrix()\n");
	glPopMatrix();
}

void glPushMatrixLogged() {
	printf("glPushMatrix()\n");
	glPushMatrix();
}

void glReadPixelsLogged(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels) {
	printf("glReadPixels(%i, %i, %i, %i, %s, %s, %p)\n", x, y, width, height, GLEnumName(format), GLEnumName(type), pixels);
	glReadPixels(x, y, width, height, format, type, pixels);
}

void glRotatexLogged(GLfixed angle, GLfixed x, GLfixed y, GLfixed z) {
	printf("glRotatex(%i, %i, %i, %i)\n", angle, x, y, z);
	glRotatex(angle, x, y, z);
}

void glSampleCoverageLogged(GLclampf value, GLboolean invert) {
	printf("glSampleCoverage(%.2f, %u)\n", value, invert);
	glSampleCoverage(value, invert);
}

void glSampleCoveragexLogged(GLclampx value, GLboolean invert) {
	printf("glSampleCoveragex(%i, %u)\n", value, invert);
	glSampleCoveragex(value, invert);
}

void glScalexLogged(GLfixed x, GLfixed y, GLfixed z) {
	printf("glScalex(%i, %i, %i)\n", x, y, z);
	glScalex(x, y, z);
}

void glScissorLogged(GLint x, GLint y, GLsizei width, GLsizei height) {
	printf("glScissor(%i, %i, %i, %i)\n", x, y, width, height);
	glScissor(x, y, width, height);
}

void glShadeModelLogged(GLenum mode) {
	printf("glShadeModel(%s)\n", GLEnumName(mode));
	glShadeModel(mode);
}

void glStencilFuncLogged(GLenum func, GLint ref, GLuint mask) {
	printf("glStencilFunc(%s, %i, %u)\n", GLEnumName(func), ref, mask);
	glStencilFunc( func, ref, mask);
}

void glStencilMaskLogged(GLuint mask) {
	printf("glStencilMask(%u)\n", mask);
	glStencilMask(mask);
}

void glStencilOpLogged(GLenum fail, GLenum zfail, GLenum zpass) {
	printf("glStencilOp(%s, %s, %s)\n", GLEnumName(fail), GLEnumName(zfail), GLEnumName(zpass));
	glStencilOp(fail, zfail, zpass);
}

void glTexCoordPointerLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glTexCoordPointer(%i, %s, %i, %p)\n", size, GLEnumName(type), stride, pointer);
	PrintGLData(size, type, stride, kPrintGLDataVertexCount, pointer);
	glTexCoordPointer(size, type, stride, pointer);
}

void glTexEnviLogged(GLenum target, GLenum pname, GLint param) {
	printf("glTexEnvi(%s, %s, %i)\n", GLEnumName(target), GLEnumName(pname), param);
	glTexEnvi(target, pname, param);
}

void glTexEnvxLogged(GLenum target, GLenum pname, GLfixed param) {
	printf("glTexEnvx(%s, %s, %i)\n", GLEnumName(target), GLEnumName(pname), param);
	glTexEnvx(target, pname, param);
}

void glTexEnvivLogged(GLenum target, GLenum pname, const GLint *params) {
	printf("glTexEnviv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glTexEnviv(target, pname, params);
}

void glTexEnvxvLogged(GLenum target, GLenum pname, const GLfixed *params) {
	printf("glTexEnvxv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glTexEnvxv(target, pname, params);
}

void glTexImage2DLogged(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels) {
	printf("glTexImage2D(%s, %i, %i, %i, %i, %i, %s, %s, %p)\n", GLEnumName(target), level, internalformat, width, height, border, GLEnumName(format), GLEnumName(type), pixels);
	glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
}

void glTexParameteriLogged(GLenum target, GLenum pname, GLint param) {
	printf("glTexParameteri(%s, %s, %i)\n", GLEnumName(target), GLEnumName(pname), param);
	glTexParameteri(target, pname, param);
}

void glTexParameterxLogged(GLenum target, GLenum pname, GLfixed param) {
	printf("glTexParameterx(%s, %s, %i)\n", GLEnumName(target), GLEnumName(pname), param);
	glTexParameterx(target, pname, param);
}

void glTexParameterivLogged(GLenum target, GLenum pname, const GLint *params) {
	printf("glTexParameteriv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glTexParameteriv(target, pname, params);
}

void glTexParameterxvLogged(GLenum target, GLenum pname, const GLfixed *params) {
	printf("glTexParameterxv(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glTexParameterxv(target, pname, params);
}

void glTexSubImage2DLogged(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels) {
	printf("glTexSubImage2D(%s, %i, %i, %i, %i, %i, %s, %s, %p)\n", GLEnumName(target), level, xoffset, yoffset, width, height, GLEnumName(format), GLEnumName(type), pixels);
	glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels);
}

void glTranslatexLogged(GLfixed x, GLfixed y, GLfixed z) {
	printf("glTranslatex(%i, %i, %i)\n", x, y, z);
	glTranslatex(x, y, z);
}

void glVertexPointerLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glVertexPointer(%i, %s, %i, %p)\n", size, GLEnumName(type), stride, pointer);
	PrintGLData(size, type, stride, kPrintGLDataVertexCount, pointer);
	glVertexPointer(size, type, stride, pointer);
}

void glViewportLogged(GLint x, GLint y, GLsizei width, GLsizei height) {
	printf("glViewport(%i, %i, %i, %i)\n", x, y, width, height);
	glViewport(x, y, width, height);
}


#pragma mark OpenGLES extensions from gl.h base file

void glCurrentPaletteMatrixOESLogged(GLuint matrixpaletteindex) {
	printf("glCurrentPaletteMatrixOES(%u)\n", matrixpaletteindex);
	glCurrentPaletteMatrixOES(matrixpaletteindex);
}

void glLoadPaletteFromModelViewMatrixOESLogged() {
	printf("glLoadPaletteFromModelViewMatrixOES()\n");
	glLoadPaletteFromModelViewMatrixOES();
}

void glMatrixIndexPointerOESLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glMatrixIndexPointerOES(%i, %s, %i, %p)\n", size, GLEnumName(type), stride, pointer);
	PrintGLData(size, type, stride, kPrintGLDataVertexCount, pointer);
	glMatrixIndexPointerOES(size, type, stride, pointer);
}

void glWeightPointerOESLogged(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glWeightPointerOES(%i, %s, %i, %p)\n", size, GLEnumName(type), stride, pointer);
	PrintGLData(size, type, stride, kPrintGLDataVertexCount, pointer);
	glWeightPointerOES(size, type, stride, pointer);
}

void glPointSizePointerOESLogged(GLenum type, GLsizei stride, const GLvoid *pointer) {
	printf("glPointSizePointerOES(%s, %i, %p)\n", GLEnumName(type), stride, pointer);
	PrintGLData(1, type, stride, kPrintGLDataVertexCount, pointer);
	glPointSizePointerOES(type, stride, pointer);
}

void glDrawTexsOESLogged(GLshort x, GLshort y, GLshort z, GLshort width, GLshort height) {
	printf("glDrawTexsOES(%i, %i, %i, %i, %i)\n", x, y, z, width, height);
	glDrawTexsOES(x, y, z, width, height);
}

void glDrawTexiOESLogged(GLint x, GLint y, GLint z, GLint width, GLint height) {
	printf("glDrawTexiOES(%i, %i, %i, %i, %i)\n", x, y, z, width, height);
	glDrawTexiOES(x, y, z, width, height);
}

void glDrawTexxOESLogged(GLfixed x, GLfixed y, GLfixed z, GLfixed width, GLfixed height) {
	printf("glDrawTexxOES(%i, %i, %i, %i, %i)\n", x, y, z, width, height);
	glDrawTexxOES(x, y, z, width, height);
}

void glDrawTexsvOESLogged(const GLshort *coords) {
	printf("glDrawTexsvOES(%p)\n", coords);
	glDrawTexsvOES(coords);
}

void glDrawTexivOESLogged(const GLint *coords) {
	printf("glDrawTexivOES(%p)\n", coords);
	glDrawTexivOES(coords);
}

void glDrawTexxvOESLogged(const GLfixed *coords) {
	printf("glDrawTexxvOES(%p)\n", coords);
	glDrawTexxvOES(coords);
}

void glDrawTexfOESLogged(GLfloat x, GLfloat y, GLfloat z, GLfloat width, GLfloat height) {
	printf("glDrawTexfOES(%.2f, %.2f, %.2f, %.2f, %.2f)\n", x, y, z, width, height);
	glDrawTexfOES(x, y, z, width, height);
}

void glDrawTexfvOESLogged(const GLfloat *coords) {
	printf("glDrawTexfvOES(%p)\n", coords);
	glDrawTexfvOES(coords);
}


#pragma mark OpenGLES extensions from glext.h extensions file

void glBlendEquationOESLogged(GLenum mode) {
	printf("glBlendEquationOES(%s)\n", GLEnumName(mode));
	glBlendEquationOES(mode);
}

GLboolean glIsRenderbufferOESLogged(GLuint renderbuffer) {
	printf("glIsRenderbufferOES(%u)\n", renderbuffer);
	return glIsRenderbufferOES(renderbuffer);
}

void glBindRenderbufferOESLogged(GLenum target, GLuint renderbuffer) {
	printf("glBindRenderbufferOES(%s, %u)\n", GLEnumName(target), renderbuffer);
	glBindRenderbufferOES(target, renderbuffer);
}

void glDeleteRenderbuffersOESLogged(GLsizei n, const GLuint* renderbuffers) {
	printf("glDeleteRenderbuffersOES(%i, %p)\n", n, renderbuffers);
	glDeleteRenderbuffersOES(n, renderbuffers);
}

void glGenRenderbuffersOESLogged(GLsizei n, GLuint* renderbuffers) {
	printf("glGenRenderbuffersOES(%i, %p)\n", n, renderbuffers);
	glGenRenderbuffersOES(n, renderbuffers);
}

void glRenderbufferStorageOESLogged(GLenum target, GLenum internalformat, GLsizei width, GLsizei height) {
	printf("glRenderbufferStorageOES(%s, %s, %i, %i)\n", GLEnumName(target), GLEnumName(internalformat), width, height);
	glRenderbufferStorageOES(target, internalformat, width, height);
}

void glGetRenderbufferParameterivOESLogged(GLenum target, GLenum pname, GLint* params) {
	printf("glGetRenderbufferParameterivOES(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glGetRenderbufferParameterivOES(target, pname, params);
}

GLboolean glIsFramebufferOESLogged(GLuint framebuffer) {
	printf("glIsFramebufferOES(%u)\n", framebuffer);
	return glIsFramebufferOES(framebuffer);
}

void glBindFramebufferOESLogged(GLenum target, GLuint framebuffer) {
	printf("glBindFramebufferOES(%s, %u)\n", GLEnumName(target), framebuffer);
	glBindFramebufferOES(target, framebuffer);
}

void glDeleteFramebuffersOESLogged(GLsizei n, const GLuint* framebuffers) {
	printf("glDeleteFramebuffersOES(%i, %p)\n", n, framebuffers);
	glDeleteFramebuffersOES(n, framebuffers);
}

void glGenFramebuffersOESLogged(GLsizei n, GLuint* framebuffers) {
	printf("glGenFramebuffersOES(%i, %p)\n", n, framebuffers);
	glGenFramebuffersOES(n, framebuffers);
}

GLenum glCheckFramebufferStatusOESLogged(GLenum target) {
	printf("glCheckFramebufferStatusOES(%s)\n", GLEnumName(target));
	return glCheckFramebufferStatusOES(target);
}

void glFramebufferRenderbufferOESLogged(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer) {
	printf("glFramebufferRenderbufferOES(%s, %s, %s, %u)\n", GLEnumName(target), GLEnumName(attachment), GLEnumName(renderbuffertarget), renderbuffer);
	glFramebufferRenderbufferOES(target, attachment, renderbuffertarget, renderbuffer);
}

void glFramebufferTexture2DOESLogged(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level) {
	printf("glFramebufferTexture2DOES(%s, %s, %s, %u, %i)\n", GLEnumName(target), GLEnumName(attachment), GLEnumName(textarget), texture, level);
	glFramebufferTexture2DOES(target, attachment, textarget, texture, level);
}

void glGetFramebufferAttachmentParameterivOESLogged(GLenum target, GLenum attachment, GLenum pname, GLint* params) {
	printf("glGetFramebufferAttachmentParameterivOES(%s, %s, %s, %p)\n", GLEnumName(target), GLEnumName(attachment), GLEnumName(pname), params);
	glGetFramebufferAttachmentParameterivOES(target, attachment, pname, params);
}

void glGenerateMipmapOESLogged(GLenum target) {
	printf("glGenerateMipmapOES(%s)\n", GLEnumName(target));
	glGenerateMipmapOES(target);
}

void glGetBufferPointervOESLogged(GLenum target, GLenum pname, GLvoid **params) {
	printf("glGetBufferPointervOES(%s, %s, %p)\n", GLEnumName(target), GLEnumName(pname), params);
	glGetBufferPointervOES(target, pname, params);
}

GLvoid* glMapBufferOESLogged(GLenum target, GLenum access) {
	printf("glMapBufferOES(%s, %s)\n", GLEnumName(target), GLEnumName(access));
	return glMapBufferOES(target, access);
}

GLboolean glUnmapBufferOESLogged(GLenum target) {
	printf("glUnmapBufferOES(%s)\n", GLEnumName(target));
	return glUnmapBufferOES(target);
}



