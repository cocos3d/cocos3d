/******************************************************************************

 @File         PVRTHash.h

 @Title        PVRTHash

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     All

 @Description  A simple hash class which uses TEA to hash a string or given  data
               in to a 32-bit unsigned int.

******************************************************************************/

#ifndef PVRTHASH_H
#define PVRTHASH_H

#include "PVRTString.h"
#include "PVRTGlobal.h"

/*!****************************************************************************
Class CPVRTHash
******************************************************************************/
class CPVRTHash
{
public:
	/*!***************************************************************************
	@Function		CPVRTHash
	@Description	Constructor
	*****************************************************************************/
	CPVRTHash() : m_uiHash(0) {}

	/*!***************************************************************************
	@Function		CPVRTHash
	@Input			rhs
	@Description	Copy Constructor
	*****************************************************************************/
	CPVRTHash(const CPVRTHash& rhs) : m_uiHash(rhs.m_uiHash) {}

	/*!***************************************************************************
	@Function		CPVRTHash
	@Input			String
	@Description	Overloaded constructor
	*****************************************************************************/
	CPVRTHash(const CPVRTString& String) : m_uiHash(0)
	{
		if(String.length() > 0)		// Empty string. Don't set.
		{
			m_uiHash = MakeHash(String);
		}
	}

	/*!***************************************************************************
	@Function		CPVRTHash
	@Input			c_pszString
	@Description	Overloaded constructor
	*****************************************************************************/
	CPVRTHash(const char* c_pszString) : m_uiHash(0)
	{
		_ASSERT(c_pszString);
		if(c_pszString[0] != 0)		// Empty string. Don't set.
		{
			m_uiHash = MakeHash(c_pszString);	
		}
	}

	/*!***************************************************************************
	@Function		CPVRTHash
	@Input			pData
	@Input			dataSize
	@Input			dataCount
	@Description	Overloaded constructor
	*****************************************************************************/
	CPVRTHash(const void* pData, unsigned int dataSize, unsigned int dataCount) : m_uiHash(0)
	{
		_ASSERT(pData);
		_ASSERT(dataSize > 0);

		if(dataCount > 0)
		{
			m_uiHash = MakeHash(pData, dataSize, dataCount);
		}
	}

	/*!***************************************************************************
	@Function		operator=
	@Input			rhs
	@Return			CPVRTHash &	
	@Description	Overloaded assignment.
	*****************************************************************************/
	CPVRTHash& operator=(const CPVRTHash& rhs)
	{
		if(this != &rhs)
		{
			m_uiHash = rhs.m_uiHash;
		}

		return *this;
	}

	/*!***************************************************************************
	@Function		operator unsigned int
	@Return			int	
	@Description	Converts to unsigned int.
	*****************************************************************************/
	operator unsigned int() const
	{
		return m_uiHash;
	}

	/*!***************************************************************************
	@Function		MakeHash
	@Input			String
	@Return			unsigned int			The hash.
	@Description	Generates a hash from a CPVRTString.
	*****************************************************************************/
	static CPVRTHash MakeHash(const CPVRTString& String)
	{
		if(String.length() > 0)
			return MakeHash(String.c_str(), sizeof(char), (unsigned int) String.length());

		return CPVRTHash();
	}

	/*!***************************************************************************
	@Function		MakeHash
	@Input			c_pszString
	@Return			unsigned int			The hash.
	@Description	Generates a hash from a null terminated char array.
	*****************************************************************************/
	static CPVRTHash MakeHash(const char* c_pszString)
	{
		_ASSERT(c_pszString);

		if(c_pszString[0] == 0)
			return CPVRTHash();

		const char* pCursor = c_pszString;
		while(*pCursor) pCursor++;
		return MakeHash(c_pszString, sizeof(char), (unsigned int) (pCursor - c_pszString));
	}
		
	/*!***************************************************************************
	@Function		MakeHash
	@Input			pData
	@Input			dataSize
	@Input			dataCount
	@Return			unsigned int			The hash.
	@Description	Generates a hash from generic data. This function uses the
					32-bit Fowler/Noll/Vo algorithm which trades efficiency for
					slightly increased risk of collisions. This algorithm is
					public domain. More information can be found at:
					http://www.isthe.com/chongo/tech/comp/fnv/.
	*****************************************************************************/
	static CPVRTHash MakeHash(const void* pData, unsigned int dataSize, unsigned int dataCount)
	{
		_ASSERT(pData);
		_ASSERT(dataSize > 0);

#define FNV_PRIME		16777619U
#define FNV_OFFSETBIAS	2166136261U

		if(dataCount == 0)
			return CPVRTHash();

		CPVRTHash pvrHash;
		unsigned char* p = (unsigned char*)pData;
		pvrHash.m_uiHash = FNV_OFFSETBIAS;
		for(unsigned int i = 0; i < dataSize * dataCount; ++i)
		{
			pvrHash.m_uiHash = (pvrHash.m_uiHash * FNV_PRIME) ^ p[i];
		}
		
		return pvrHash;
	}

private:
	unsigned int		m_uiHash;		/// The hashed data.
};

#endif

