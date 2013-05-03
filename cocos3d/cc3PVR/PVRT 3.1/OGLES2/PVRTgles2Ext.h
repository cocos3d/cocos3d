/******************************************************************************

 @File         OGLES2/PVRTgles2Ext.h

 @Title        OGLES2/PVRTgles2Ext

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     Independent

 @Description  OpenGL ES 2.0 extensions

******************************************************************************/
#ifndef _PVRTGLES2EXT_H_
#define _PVRTGLES2EXT_H_

#include "CC3PVROpenGLFoundation.h"		// patched for cocos3d by Bill Hollings

#if CC3_OGLES_2							// patched for cocos3d by Bill Hollings

#ifdef __APPLE__
#ifdef TARGET_OS_IPHONE
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
// No binary shaders are allowed on the iphone and so this value is not defined
// Defining here allows for a more graceful fail of binary shader loading at runtime
// which can be recovered from instead of fail at compile time
#define GL_SGX_BINARY_IMG 0
#else
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <GLES2/gl2extimg.h>
#endif
#else
#if !defined(EGL_NOT_PRESENT)
#include <EGL/egl.h>
#endif
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <GLES2/gl2extimg.h>
#endif

#if defined(TARGET_OS_IPHONE)
// the extensions supported on the iPhone are treated as core functions of gl
// so use this macro to assign the function pointers in this class appropriately.
#define PVRGetProcAddress(x) ::x
#else

#if defined(EGL_NOT_PRESENT)

#if defined(__PALMPDK__)
#include "SDL.h"

#define PVRGetProcAddress(x) SDL_GLES_GetProcAddress(#x)
#else
#define PVRGetProcAddress(x) NULL
#endif

#else
#define PVRGetProcAddress(x) eglGetProcAddress(#x)
#endif

#endif

/****************************************************************************
** Build options
****************************************************************************/

#define GL_PVRTGLESEXT_VERSION 2

/**************************************************************************
****************************** GL EXTENSIONS ******************************
**************************************************************************/

class CPVRTgles2Ext
{

public:
    // Type definitions for pointers to functions returned by eglGetProcAddress
    typedef void (GL_APIENTRY *PFNGLMULTIDRAWELEMENTS) (GLenum mode, GLsizei *count, GLenum type, const GLvoid **indices, GLsizei primcount); // glvoid
    typedef void* (GL_APIENTRY *PFNGLMAPBUFFEROES)(GLenum target, GLenum access);
    typedef GLboolean (GL_APIENTRY *PFNGLUNMAPBUFFEROES)(GLenum target);
    typedef void (GL_APIENTRY *PFNGLGETBUFFERPOINTERVOES)(GLenum target, GLenum pname, void** params);
	typedef void (GL_APIENTRY * PFNGLMULTIDRAWARRAYS) (GLenum mode, GLint *first, GLsizei *count, GLsizei primcount); // glvoid
	typedef void (GL_APIENTRY * PFNGLDISCARDFRAMEBUFFEREXT)(GLenum target, GLsizei numAttachments, const GLenum *attachments);

	typedef void (GL_APIENTRYP PFNGLBINDVERTEXARRAYOES) (GLuint vertexarray);
	typedef void (GL_APIENTRYP PFNGLDELETEVERTEXARRAYSOES) (GLsizei n, const GLuint *vertexarrays);
	typedef void (GL_APIENTRYP PFNGLGENVERTEXARRAYSOES) (GLsizei n, GLuint *vertexarrays);
	typedef GLboolean (GL_APIENTRYP PFNGLISVERTEXARRAYOES) (GLuint vertexarray);

	typedef void (GL_APIENTRYP PFNGLRENDERBUFFERSTORAGEMULTISAMPLEIMG) (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);
	typedef void (GL_APIENTRYP PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEIMG) (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLsizei samples);

	// GL_EXT_multi_draw_arrays
	PFNGLMULTIDRAWELEMENTS				glMultiDrawElementsEXT;
	PFNGLMULTIDRAWARRAYS				glMultiDrawArraysEXT;

	// GL_EXT_multi_draw_arrays
    PFNGLMAPBUFFEROES                   glMapBufferOES;
    PFNGLUNMAPBUFFEROES                 glUnmapBufferOES;
    PFNGLGETBUFFERPOINTERVOES           glGetBufferPointervOES;

	// GL_EXT_discard_framebuffer
	PFNGLDISCARDFRAMEBUFFEREXT			glDiscardFramebufferEXT;

	// GL_OES_vertex_array_object
#if !defined(GL_OES_vertex_array_object)
	#define GL_VERTEX_ARRAY_BINDING_OES 0x85B5
#endif

	PFNGLBINDVERTEXARRAYOES glBindVertexArrayOES;
	PFNGLDELETEVERTEXARRAYSOES glDeleteVertexArraysOES;
	PFNGLGENVERTEXARRAYSOES glGenVertexArraysOES;
	PFNGLISVERTEXARRAYOES glIsVertexArrayOES;

	// GL_IMG_multisampled_render_to_texture
#if !defined(GL_IMG_multisampled_render_to_texture)
	#define GL_RENDERBUFFER_SAMPLES_IMG                 0x9133
	#define GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_IMG   0x9134
	#define GL_MAX_SAMPLES_IMG                          0x9135
	#define GL_TEXTURE_SAMPLES_IMG                      0x9136
#endif

	PFNGLRENDERBUFFERSTORAGEMULTISAMPLEIMG glRenderbufferStorageMultisampleIMG;
	PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEIMG glFramebufferTexture2DMultisampleIMG;

public:
	/*!***********************************************************************
	@Function			LoadExtensions
	@Description		Initialises IMG extensions
	*************************************************************************/
	void LoadExtensions();

	/*!***********************************************************************
	@Function			IsGLExtensionSupported
	@Input				extension extension to query for
	@Returns			True if the extension is supported
	@Description		Queries for support of an extension
	*************************************************************************/
	static bool IsGLExtensionSupported(const char * const extension);
};

#endif /* _PVRTGLES2EXT_H_ */

/*****************************************************************************
 End of file (PVRTgles2Ext.h)
*****************************************************************************/

#endif	// CC3_OGLES_2					// patched for cocos3d by Bill Hollings

