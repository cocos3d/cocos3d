/******************************************************************************

 @File         PVRTResourceFile.h

 @Title        PVRTResourceFile

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Simple resource file wrapper

******************************************************************************/
#ifndef _PVRTRESOURCEFILE_H_
#define _PVRTRESOURCEFILE_H_

#include <stdlib.h>
#include "PVRTString.h"

typedef void* (*PFNLoadFileFunc)(const char*, char** pData, size_t &size);
typedef bool  (*PFNReleaseFileFunc)(void* handle);

/*!***************************************************************************
 @Class CPVRTResourceFile
 @Brief Simple resource file wrapper
*****************************************************************************/
class CPVRTResourceFile
{
public:
	/*!***************************************************************************
	@Function			SetReadPath
	@Input				pszReadPath The path where you would like to read from
	@Description		Sets the read path
	*****************************************************************************/
	static void SetReadPath(const char* pszReadPath);

	/*!***************************************************************************
	@Function			GetReadPath
	@Returns			The currently set read path
	@Description		Returns the currently set read path
	*****************************************************************************/
	static CPVRTString GetReadPath();

	/*!***************************************************************************
	@Function			SetLoadReleaseFunctions
	@Input				pLoadFileFunc Function to use for opening a file
	@Input				pReleaseFileFunc Function to release any data allocated by the load function
	@Description		This function is used to override the CPVRTResource file loading functions. If
	                    you pass NULL in as the load function CPVRTResource will use the default functions.
	*****************************************************************************/
	static void SetLoadReleaseFunctions(void* pLoadFileFunc, void* pReleaseFileFunc);

	/*!***************************************************************************
	@Function			CPVRTResourceFile
	@Input				pszFilename Name of the file you would like to open
	@Description		Constructor
	*****************************************************************************/
	CPVRTResourceFile(const char* pszFilename);

	/*!***************************************************************************
	@Function			CPVRTResourceFile
	@Input				pData A pointer to the data you would like to use
	@Input				i32Size The size of the data
	@Description		Constructor
	*****************************************************************************/
	CPVRTResourceFile(const char* pData, size_t i32Size);

	/*!***************************************************************************
	@Function			~CPVRTResourceFile
	@Description		Destructor
	*****************************************************************************/
	virtual ~CPVRTResourceFile();

	/*!***************************************************************************
	@Function			IsOpen
	@Returns			true if the file is open
	@Description		Is the file open
	*****************************************************************************/
	bool IsOpen() const;

	/*!***************************************************************************
	@Function			IsMemoryFile
	@Returns			true if the file was opened from memory
	@Description		Was the file opened from memory
	*****************************************************************************/
	bool IsMemoryFile() const;

	/*!***************************************************************************
	@Function			Size
	@Returns			The size of the opened file
	@Description		Returns the size of the opened file
	*****************************************************************************/
	size_t Size() const;

	/*!***************************************************************************
	@Function			DataPtr
	@Returns			A pointer to the file data
	@Description		Returns a pointer to the file data. If the data is expected
						to be a string don't assume that it is null-terminated.
	*****************************************************************************/
	const void* DataPtr() const;

	/*!***************************************************************************
	@Function			Close
	@Description		Closes the file
	*****************************************************************************/
	void Close();

protected:
	bool m_bOpen;
	bool m_bMemoryFile;
	size_t m_Size;
	const char* m_pData;
	void *m_Handle;

	static CPVRTString s_ReadPath;
	static PFNLoadFileFunc s_pLoadFileFunc;
	static PFNReleaseFileFunc s_pReleaseFileFunc;
};

#endif // _PVRTRESOURCEFILE_H_

/*****************************************************************************
 End of file (PVRTResourceFile.h)
*****************************************************************************/

