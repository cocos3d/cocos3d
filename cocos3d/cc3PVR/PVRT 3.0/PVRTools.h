/******************************************************************************

 @File         PVRTools.h

 @Title        PVRTools

 @Version       @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Header file to include a particular API tools header

******************************************************************************/
#ifndef PVRTOOLS_H
#define PVRTOOLS_H

#if defined(BUILD_OGLES3)
	#include "OGLES3Tools.h"
#elif defined(BUILD_OGLES2)
	#include "OGLES2Tools.h"
#elif defined(BUILD_OGLES)
	#include "OGLESTools.h"
#elif defined(BUILD_OGL)
	#include "OGLTools.h"
#elif defined(BUILD_D3DM)
	#include "D3DMTools.h"
#elif defined(BUILD_DX9)
	#include "DX9Tools.h"
#elif defined(BUILD_DX10)
	#include "DX10Tools.h"
#elif defined(BUILD_DX11)
	#include "DX11Tools.h"
#endif

#endif /* PVRTOOLS_H*/

/*****************************************************************************
 End of file (Tools.h)
*****************************************************************************/

