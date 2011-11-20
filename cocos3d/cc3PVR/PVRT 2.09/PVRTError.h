/******************************************************************************

 @File         PVRTError.h

 @Title        PVRTError

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  

******************************************************************************/
#ifndef _PVRTERROR_H_
#define _PVRTERROR_H_

#if defined(__BADA__)
#include <FApp.h>
#include <stdio.h>
#else
#if defined(__SYMBIAN32__)
#include <e32debug.h>
#elif defined(_WIN32) && !defined(UNDER_CE)
#include <windows.h>
#else
#include <stdio.h>
#endif
#endif
/*!***************************************************************************
 Macros
*****************************************************************************/

/*! Outputs a string to the standard error if built for debugging. */
#ifndef PVRTERROR_OUTPUT_DEBUG
	#if defined(_DEBUG) || defined(DEBUG)
		#if defined(__SYMBIAN32__)
			#define PVRTERROR_OUTPUT_DEBUG(A) RDebug::Printf(A);
		#elif defined(__BADA__)
			#define PVRTERROR_OUTPUT_DEBUG(A) AppLog(A);
		#elif defined(_WIN32) && !defined(UNDER_CE)
			#define PVRTERROR_OUTPUT_DEBUG(A) OutputDebugStringA(A);
		#else
			#define PVRTERROR_OUTPUT_DEBUG(A) fprintf(stderr,A);
		#endif
	#else
		#define PVRTERROR_OUTPUT_DEBUG(A)
	#endif
#endif


/*!***************************************************************************
 Enums
*****************************************************************************/
/*! Enum error codes */
enum EPVRTError
{
	PVR_SUCCESS = 0,
	PVR_FAIL = 1,
	PVR_OVERFLOW = 2
};

/*!***************************************************************************
 @Function			PVRTErrorOutputDebug
 @Input				format		printf style format followed by arguments it requires
 @Description		Outputs a string to the standard error.
*****************************************************************************/
void PVRTErrorOutputDebug(char const * const format, ...);

#endif // _PVRTERROR_H_

/*****************************************************************************
End of file (PVRTError.h)
*****************************************************************************/

