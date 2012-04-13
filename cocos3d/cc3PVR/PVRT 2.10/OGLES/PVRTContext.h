/******************************************************************************

 @File         PVRTContext.h

 @Title        OGLES/PVRTContext

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Context specific stuff - i.e. 3D API-related.

******************************************************************************/
#ifndef _PVRTCONTEXT_H_
#define _PVRTCONTEXT_H_

// Ensure TARGET_OS_IPHONE directive is defined, instead of
// requiring all projects to set this compiler directive.
#ifndef TARGET_OS_IPHONE		// patched for cocos3d by Bill Hollings
#	define TARGET_OS_IPHONE		// patched for cocos3d by Bill Hollings
#endif							// patched for cocos3d by Bill Hollings

#include <stdio.h>
#if defined(__APPLE__)
#ifdef TARGET_OS_IPHONE
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#else
#include <EGL/egl.h>
#include <GLES/gl.h>
#include <GLES/glext.h>
#endif
#else
#if defined(__BADA__)
#include <FGraphicsOpengl.h>
using namespace Osp::Graphics::Opengl;
#else
#if !defined(EGL_NOT_PRESENT)
#include <EGL/egl.h>
#endif
#include <GLES/gl.h>
#endif
#endif

#include "PVRTglesExt.h"

/****************************************************************************
** Macros
****************************************************************************/
#define PVRTRGBA(r, g, b, a)   ((GLuint) (((a) << 24) | ((b) << 16) | ((g) << 8) | (r)))

/****************************************************************************
** Defines
****************************************************************************/

/****************************************************************************
** Enumerations
****************************************************************************/

/****************************************************************************
** Structures
****************************************************************************/
/*!**************************************************************************
@Struct SPVRTContext
@Brief A structure for storing API specific variables
****************************************************************************/
struct SPVRTContext
{
	CPVRTglesExt * pglesExt;
};

/****************************************************************************
** Functions
****************************************************************************/


#endif /* _PVRTCONTEXT_H_ */

/*****************************************************************************
 End of file (PVRTContext.h)
*****************************************************************************/

