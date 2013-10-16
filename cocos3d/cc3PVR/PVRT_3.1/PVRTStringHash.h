/******************************************************************************

 @File         PVRTStringHash.h

 @Title        String Hash

 @Version       @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     All

 @Description  Inherits from PVRTString to include PVRTHash functionality for
               quick string compares.

******************************************************************************/
#ifndef PVRTSTRINGHASH_H
#define PVRTSTRINGHASH_H

#include "PVRTString.h"
#include "PVRTHash.h"

class CPVRTStringHash
{
public:
	/*!***********************************************************************
	@Function			CPVRTString
	@Input				_Ptr	A string
	@Input				_Count	Length of _Ptr
	@Description		Constructor
	************************************************************************/
	explicit CPVRTStringHash(const char* _Ptr, size_t _Count = CPVRTString::npos);

	/*!***********************************************************************
	@Function			CPVRTString
	@Input				_Right	A string
	@Description		Constructor
	************************************************************************/
	explicit CPVRTStringHash(const CPVRTString& _Right);

	/*!***********************************************************************
	@Function			CPVRTString
	@Description		Constructor
	************************************************************************/
	CPVRTStringHash();

	/*!***********************************************************************
	@Function			append
	@Input				_Ptr	A string
	@Returns			Updated string
	@Description		Appends a string
	*************************************************************************/
	CPVRTStringHash& append(const char* _Ptr);

	/*!***********************************************************************
	@Function			append
	@Input				_Str	A string
	@Returns			Updated string
	@Description		Appends a string
	*************************************************************************/
	CPVRTStringHash& append(const CPVRTString& _Str);

	/*!***********************************************************************
	@Function			assign
	@Input				_Ptr A string
	@Returns			Updated string
	@Description		Assigns the string to the string _Ptr
	*************************************************************************/
	CPVRTStringHash& assign(const char* _Ptr);

	/*!***********************************************************************
	@Function			assign
	@Input				_Str A string
	@Returns			Updated string
	@Description		Assigns the string to the string _Str
	*************************************************************************/
	CPVRTStringHash& assign(const CPVRTString& _Str);

	/*!***********************************************************************
	@Function		==
	@Input			_Str 	A hashed string to compare with
	@Returns		True if they match
	@Description	== Operator. This function compares the hash values of
					the string.
	*************************************************************************/
	bool operator==(const CPVRTStringHash& _Str) const;

	/*!***********************************************************************
	@Function		==
	@Input			_Str 	A string to compare with
	@Returns		True if they match
	@Description	== Operator. This function performs a strcmp()
					as it's more efficient to strcmp than to hash the string
					for every comparison.
	*************************************************************************/
	bool operator==(const char* _Str) const;

	/*!***********************************************************************
	@Function		==
	@Input			_Str 	A string to compare with
	@Returns		True if they match
	@Description	== Operator. This function performs a strcmp()
					as it's more efficient to strcmp than to hash the string
					for every comparison.
	*************************************************************************/
	bool operator==(const CPVRTString& _Str) const;

	/*!***********************************************************************
	@Function		==
	@Input			Hash 	A Hash to compare with
	@Returns		True if they match
	@Description	== Operator. This function compares the hash values of
					the string.
	*************************************************************************/
	bool operator==(const CPVRTHash& Hash) const;

	/*!***********************************************************************
	@Function			!=
	@Input				_Str 	A string to compare with
	@Returns			True if they don't match
	@Description		!= Operator
	*************************************************************************/
	bool operator!=(const CPVRTStringHash& _Str) const;

	/*!***********************************************************************
	@Function		!=
	@Input			Hash 	A Hash to compare with
	@Returns		True if they match
	@Description	!= Operator. This function compares the hash values of
					the string.
	*************************************************************************/
	bool operator!=(const CPVRTHash& Hash) const;

	/*!***********************************************************************
	@Function			String
	@Returns			The original string
	@Description		Returns the original, base string.
	*************************************************************************/
	const CPVRTString& String() const;

	/*!***********************************************************************
	@Function			Hash
	@Returns			The hash
	@Description		Returns the hash of the base string
	*************************************************************************/
	const CPVRTHash& Hash() const;

	/*!***************************************************************************
	@Function		c_str
	@Return			The original string.
	@Description	Returns the base string as a const char*.
	*****************************************************************************/
	const char* c_str() const;

private:
	CPVRTString			m_String;
	CPVRTHash			m_Hash;
};

#endif

