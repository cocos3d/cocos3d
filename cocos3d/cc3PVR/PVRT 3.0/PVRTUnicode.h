/******************************************************************************

 @File         PVRTUnicode.h

 @Title        PVRTUnicode

 @Version       @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     All

 @Description  A small collection of functions used to decode Unicode formats to
               individual code points.

******************************************************************************/
#ifndef _PVRTUNICODE_H_
#define _PVRTUNICODE_H_

#include "PVRTGlobal.h"
#include "PVRTError.h"
#include "PVRTArray.h"

/****************************************************************************
** Functions
****************************************************************************/

/*!***************************************************************************
 @Function			PVRTUnicodeUTF8ToUTF32
 @Input				pUTF8			A UTF8 string, which is null terminated.
 @Output			aUTF32			An array of Unicode code points.
 @Returns			Success or failure. 
 @Description		Decodes a UTF8-encoded string in to Unicode code points
					(UTF32). If pUTF8 is not null terminated, the results are 
					undefined.
*****************************************************************************/
EPVRTError PVRTUnicodeUTF8ToUTF32(	const PVRTuint8* const pUTF8, CPVRTArray<PVRTuint32>& aUTF32);

/*!***************************************************************************
 @Function			PVRTUnicodeUTF16ToUTF32
 @Input				pUTF16			A UTF16 string, which is null terminated.
 @Output			aUTF32			An array of Unicode code points.
 @Returns			Success or failure. 
 @Description		Decodes a UTF16-encoded string in to Unicode code points
					(UTF32). If pUTF16 is not null terminated, the results are 
					undefined.
*****************************************************************************/
EPVRTError PVRTUnicodeUTF16ToUTF32(const PVRTuint16* const pUTF16, CPVRTArray<PVRTuint32>& aUTF32);

/*!***************************************************************************
 @Function			PVRTUnicodeUTF8Length
 @Input				pUTF8			A UTF8 string, which is null terminated.
 @Returns			The length of the string, in Unicode code points.
 @Description		Calculates the length of a UTF8 string. If pUTF8 is 
					not null terminated, the results are undefined.
*****************************************************************************/
unsigned int PVRTUnicodeUTF8Length(const PVRTuint8* const pUTF8);

/*!***************************************************************************
 @Function			PVRTUnicodeUTF16Length
 @Input				pUTF16			A UTF16 string, which is null terminated.
 @Returns			The length of the string, in Unicode code points.
 @Description		Calculates the length of a UTF16 string.
					If pUTF16 is not null terminated, the results are 
					undefined.
*****************************************************************************/
unsigned int PVRTUnicodeUTF16Length(const PVRTuint16* const pUTF16);

/*!***************************************************************************
 @Function			PVRTUnicodeValidUTF8
 @Input				pUTF8			A UTF8 string, which is null terminated.
 @Returns			true or false
 @Description		Checks whether the encoding of a UTF8 string is valid.
					If pUTF8 is not null terminated, the results are undefined.
*****************************************************************************/
bool PVRTUnicodeValidUTF8(const PVRTuint8* const pUTF8);

#endif /* _PVRTUNICODE_H_ */

/*****************************************************************************
 End of file (PVRTUnicode.h)
*****************************************************************************/

