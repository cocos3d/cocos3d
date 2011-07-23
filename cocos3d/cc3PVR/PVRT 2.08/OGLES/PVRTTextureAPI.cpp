/******************************************************************************

 @File         PVRTTextureAPI.cpp

 @Title        OGLES/PVRTTextureAPI

 @Version      

 @Copyright    Copyright (C)  Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  OGLES texture loading.

******************************************************************************/

#include <string.h>
#include <stdlib.h>

#include "PVRTContext.h"
#include "PVRTglesExt.h"
#include "PVRTTexture.h"
#include "PVRTTextureAPI.h"
#include "PVRTDecompress.h"
#include "PVRTFixedPoint.h"
#include "PVRTMatrix.h"
#include "PVRTMisc.h"
#include "PVRTResourceFile.h"

/*****************************************************************************
** Functions
****************************************************************************/


/*!***************************************************************************
@Function		PVRTTextureTile
@Modified		pOut		The tiled texture in system memory
@Input			pIn			The source texture
@Input			nRepeatCnt	Number of times to repeat the source texture
@Description	Allocates and fills, in system memory, a texture large enough
				to repeat the source texture specified number of times.
*****************************************************************************/
void PVRTTextureTile(
	PVR_Texture_Header			**pOut,
	const PVR_Texture_Header	* const pIn,
	const int					nRepeatCnt)
{
	unsigned int		nFormat = 0, nType = 0, nBPP, nSize, nElW = 0, nElH = 0;
	PVRTuint8		*pMmSrc, *pMmDst;
	unsigned int		nLevel;
	PVR_Texture_Header	*psTexHeaderNew;

	_ASSERT(pIn->dwWidth);
	_ASSERT(pIn->dwWidth == pIn->dwHeight);
	_ASSERT(nRepeatCnt > 1);

	switch(pIn->dwpfFlags & PVRTEX_PIXELTYPE)
	{
	case OGL_RGBA_5551:
		nFormat		= GL_UNSIGNED_SHORT_5_5_5_1;
		nType		= GL_RGBA;
		nElW		= 1;
		nElH		= 1;
		break;
	case OGL_RGBA_8888:
		nFormat		= GL_UNSIGNED_BYTE;
		nType		= GL_RGBA;
		nElW		= 1;
		nElH		= 1;
		break;
	case OGL_PVRTC2:
		nFormat		= GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
		nType		= 0;
		nElW		= 8;
		nElH		= 4;
		break;
	case OGL_PVRTC4:
		nFormat		= GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
		nType		= 0;
		nElW		= 4;
		nElH		= 4;
		break;
	}

	nBPP = PVRTTextureFormatGetBPP(nFormat, nType);
	nSize = pIn->dwWidth * nRepeatCnt;

	psTexHeaderNew	= PVRTTextureCreate(nSize, nSize, nElW, nElH, nBPP, true);
	*psTexHeaderNew	= *pIn;
	pMmDst	= (PVRTuint8*)psTexHeaderNew + sizeof(*psTexHeaderNew);
	pMmSrc	= (PVRTuint8*)pIn + sizeof(*pIn);

	for(nLevel = 0; ((unsigned int)1 << nLevel) < nSize; ++nLevel)
	{
		int nBlocksDstW = PVRT_MAX((unsigned int)1, (nSize >> nLevel) / nElW);
		int nBlocksDstH = PVRT_MAX((unsigned int)1, (nSize >> nLevel) / nElH);
		int nBlocksSrcW = PVRT_MAX((unsigned int)1, (pIn->dwWidth >> nLevel) / nElW);
		int nBlocksSrcH = PVRT_MAX((unsigned int)1, (pIn->dwHeight >> nLevel) / nElH);
		int nBlocksS	= nBPP * nElW * nElH / 8;

		PVRTTextureLoadTiled(
			pMmDst,
			nBlocksDstW,
			nBlocksDstH,
			pMmSrc,
			nBlocksSrcW,
			nBlocksSrcH,
			nBlocksS,
			(pIn->dwpfFlags & PVRTEX_TWIDDLE) ? true : false);

		pMmDst += nBlocksDstW * nBlocksDstH * nBlocksS;
		pMmSrc += nBlocksSrcW * nBlocksSrcH * nBlocksS;
	}

	psTexHeaderNew->dwWidth = nSize;
	psTexHeaderNew->dwHeight = nSize;
	psTexHeaderNew->dwMipMapCount = nLevel;
	*pOut = psTexHeaderNew;
}

/*!***************************************************************************
 @Function		PVRTTextureLoadFromPointer
 @Input			pointer				Pointer to header-texture's structure
 @Modified		texName				the OpenGL ES texture name as returned by glBindTexture
 @Modified		psTextureHeader		Pointer to a PVR_Texture_Header struct. Modified to
									contain the header data of the returned texture Ignored if NULL.
 @Input			bAllowDecompress	Allow decompression if PVRTC is not supported in hardware.
 @Input			nLoadFromLevel		Which mipmap level to start loading from (0=all)
 @Input			texPtr				If null, texture follows header, else texture is here.
 @Return		PVR_SUCCESS on success
 @Description	Allows textures to be stored in C header files and loaded in. Can load parts of a
				mipmaped texture (ie skipping the highest detailed levels). In OpenGL Cube Map, each
				texture's up direction is defined as next (view direction, up direction),
				(+x,-y)(-x,-y)(+y,+z)(-y,-z)(+z,-y)(-z,-y).
				Sets the texture MIN/MAG filter to GL_LINEAR_MIPMAP_NEAREST/GL_LINEAR
				if mipmaps are present, GL_LINEAR/GL_LINEAR otherwise.
*****************************************************************************/
EPVRTError PVRTTextureLoadFromPointer(	const void* pointer,
										GLuint *const texName,
										const void *psTextureHeader,
										bool bAllowDecompress,
										const unsigned int nLoadFromLevel,
										const void * const texPtr)
{
	PVR_Texture_Header* psPVRHeader = (PVR_Texture_Header*)pointer;
	PVRTuint32* pData = (PVRTuint32*) pointer;
	unsigned int u32NumSurfs;

	// perform checks for old PVR psPVRHeader
	if(psPVRHeader->dwHeaderSize!=sizeof(PVR_Texture_Header))
	{	// Header V1
		if(psPVRHeader->dwHeaderSize==PVRTEX_V1_HEADER_SIZE)
		{	// react to old psPVRHeader: i.e. fill in numsurfs as this is missing from old header
			PVRTErrorOutputDebug("PVRTTextureLoadFromPointer warning: this is an old pvr"
				" - you can use PVRTexTool to update its header.\n");
			if(psPVRHeader->dwpfFlags&PVRTEX_CUBEMAP)
				u32NumSurfs = 6;
			else
				u32NumSurfs = 1;
		}
		else
		{	// not a pvr at all
			PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: not a valid pvr.\n");
			return PVR_FAIL;
		}
	}
	else
	{	// Header V2
		if(psPVRHeader->dwNumSurfs<1)
		{	// encoded with old version of PVRTexTool before zero numsurfs bug found.
			if(psPVRHeader->dwpfFlags & PVRTEX_CUBEMAP)
				u32NumSurfs = 6;
			else
				u32NumSurfs = 1;
		}
		else
		{
			u32NumSurfs = psPVRHeader->dwNumSurfs;
		}
	}

	GLuint textureName;
	GLenum eTextureFormat = 0;
	GLenum eTextureInternalFormat = 0;	// often this is the same as textureFormat, but not for BGRA8888 on the iPhone, for instance
	GLenum eTextureType = 0;

	bool bIsPVRTCSupported = CPVRTglesExt::IsGLExtensionSupported("GL_IMG_texture_compression_pvrtc");
#ifndef TARGET_OS_IPHONE
	bool bIsBGRA8888Supported  = CPVRTglesExt::IsGLExtensionSupported("GL_IMG_texture_format_BGRA8888");
#else
	bool bIsBGRA8888Supported  = CPVRTglesExt::IsGLExtensionSupported("GL_APPLE_texture_format_BGRA8888");
#endif

	*texName = 0;	// install warning value
	bool bIsCompressedFormatSupported = false, bIsCompressedFormat = false;
	/* Only accept untwiddled data UNLESS texture format is PVRTC */
	if ( ((psPVRHeader->dwpfFlags & PVRTEX_TWIDDLE) == PVRTEX_TWIDDLE)
		&& ((psPVRHeader->dwpfFlags & PVRTEX_PIXELTYPE)!=OGL_PVRTC2)
		&& ((psPVRHeader->dwpfFlags & PVRTEX_PIXELTYPE)!=OGL_PVRTC4) )
	{
		// We need to load untwiddled textures -- hw will twiddle for us.
		PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: texture should be untwiddled.\n");
		return PVR_FAIL;
	}

	unsigned int ePixelType = psPVRHeader->dwpfFlags & PVRTEX_PIXELTYPE;

	switch(ePixelType)
	{
	case OGL_RGBA_4444:
		eTextureFormat = eTextureInternalFormat = GL_RGBA;
		eTextureType = GL_UNSIGNED_SHORT_4_4_4_4;
		break;

	case OGL_RGBA_5551:
		eTextureFormat = eTextureInternalFormat = GL_RGBA ;
		eTextureType = GL_UNSIGNED_SHORT_5_5_5_1;
		break;

	case OGL_RGBA_8888:
		eTextureFormat = eTextureInternalFormat = GL_RGBA;
		eTextureType = GL_UNSIGNED_BYTE ;
		break;

	// New OGL Specific Formats Added

	case OGL_RGB_565:
		eTextureFormat = eTextureInternalFormat = GL_RGB ;
		eTextureType = GL_UNSIGNED_SHORT_5_6_5;
		break;

	case OGL_RGB_555:
		PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: pixel type OGL_RGB_555 not supported.\n");
		return PVR_FAIL; // Deal with exceptional case

	case OGL_RGB_888:
		eTextureFormat = eTextureInternalFormat = GL_RGB ;
		eTextureType = GL_UNSIGNED_BYTE;
		break;

	case OGL_I_8:
		eTextureFormat = eTextureInternalFormat = GL_LUMINANCE;
		eTextureType = GL_UNSIGNED_BYTE;
		break;

	case OGL_AI_88:
		eTextureFormat = eTextureInternalFormat = GL_LUMINANCE_ALPHA ;
		eTextureType = GL_UNSIGNED_BYTE;
		break;

	case MGLPT_PVRTC2:
	case OGL_PVRTC2:
		if(bIsPVRTCSupported)
		{
			bIsCompressedFormatSupported = bIsCompressedFormat = true;
			eTextureFormat = psPVRHeader->dwAlphaBitMask==0 ? GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG ;	// PVRTC2
		}
		else
		{
			if(bAllowDecompress)
			{
				bIsCompressedFormatSupported = false;
				bIsCompressedFormat = true;
				eTextureFormat = eTextureInternalFormat = GL_RGBA;
				eTextureType = GL_UNSIGNED_BYTE;
				PVRTErrorOutputDebug("PVRTTextureLoadFromPointer warning: PVRTC2 not supported. Converting to RGBA8888 instead.\n");
			}
			else
			{
				PVRTErrorOutputDebug("PVRTTextureLoadFromPointer error: PVRTC2 not supported.\n");
				return PVR_FAIL;
			}
		}
		break;
	case MGLPT_PVRTC4:
	case OGL_PVRTC4:
		if(bIsPVRTCSupported)
		{
			bIsCompressedFormatSupported = bIsCompressedFormat = true;
			eTextureFormat = psPVRHeader->dwAlphaBitMask==0 ? GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG ;	// PVRTC4
		}
		else
		{
			if(bAllowDecompress)
			{
				bIsCompressedFormatSupported = false;
				bIsCompressedFormat = true;
				eTextureFormat = eTextureInternalFormat = GL_RGBA;
				eTextureType = GL_UNSIGNED_BYTE;
				PVRTErrorOutputDebug("PVRTTextureLoadFromPointer warning: PVRTC4 not supported. Converting to RGBA8888 instead.\n");
			}
			else
			{
				PVRTErrorOutputDebug("PVRTTextureLoadFromPointer error: PVRTC4 not supported.\n");
				return PVR_FAIL;
			}
		}
		break;
	case OGL_A_8:
		eTextureFormat = eTextureInternalFormat = GL_ALPHA;
		eTextureType = GL_UNSIGNED_BYTE;
		break;
	case OGL_BGRA_8888:
		if(bIsBGRA8888Supported)
		{
			eTextureType = GL_UNSIGNED_BYTE;
#ifndef __APPLE__
			eTextureFormat = eTextureInternalFormat = GL_BGRA;
#else
			eTextureFormat = GL_BGRA;
			eTextureInternalFormat = GL_RGBA;
#endif
		}
		else
		{
			PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: Unable to load GL_BGRA texture as extension GL_IMG_texture_format_BGRA8888 is unsupported.\n");
			return PVR_FAIL;
		}
		break;

	default:											// NOT SUPPORTED
		PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: pixel type not supported.\n");
		return PVR_FAIL;
	}

	// load the texture up
	glPixelStorei(GL_UNPACK_ALIGNMENT,1);				// Never have row-aligned in psPVRHeaders

	glGenTextures(1, &textureName);

	//  check that this data is cube map data or not.
	if(psPVRHeader->dwpfFlags & PVRTEX_CUBEMAP)
	{ // not in OGLES you don't
		PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: cube map textures are not available in OGLES1.x.\n");
		return PVR_FAIL;
	}
	else
	{
		glBindTexture(GL_TEXTURE_2D, textureName);
	}

	if(glGetError())
	{
		PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: glBindTexture() failed.\n");
		return PVR_FAIL;
	}

	for(unsigned int i=0; i<u32NumSurfs; i++)
	{
		PVRTuint8 *theTexturePtr = (texPtr? (PVRTuint8*)texPtr :  (PVRTuint8*)pData + psPVRHeader->dwHeaderSize) + psPVRHeader->dwTextureDataSize * i;
		PVRTuint8 *theTextureToLoad = 0;
		int		nMIPMapLevel;
		int		nTextureLevelsNeeded = (psPVRHeader->dwpfFlags & PVRTEX_MIPMAP)? psPVRHeader->dwMipMapCount : 0;
		unsigned int		nSizeX= psPVRHeader->dwWidth, nSizeY = psPVRHeader->dwHeight;
		unsigned int		CompressedImageSize = 0;

		for(nMIPMapLevel = 0; nMIPMapLevel <= nTextureLevelsNeeded; nSizeX = PVRT_MAX(nSizeX/2, (unsigned int)1), nSizeY = PVRT_MAX(nSizeY/2, (unsigned int)1), nMIPMapLevel++)
		{
			// Do Alpha-swap if needed

			theTextureToLoad = theTexturePtr;

			// Load the Texture
			/* If the texture is PVRTC then use GLCompressedTexImage2D */
			if(bIsCompressedFormat)
			{
				/* Calculate how many bytes this MIP level occupies */
				if ((psPVRHeader->dwpfFlags & PVRTEX_PIXELTYPE)==OGL_PVRTC2)
				{
					CompressedImageSize = ( PVRT_MAX(nSizeX, PVRTC2_MIN_TEXWIDTH) * PVRT_MAX(nSizeY, PVRTC2_MIN_TEXHEIGHT) * psPVRHeader->dwBitCount + 7) / 8;
				}
				else
				{// PVRTC4 case
					CompressedImageSize = ( PVRT_MAX(nSizeX, PVRTC4_MIN_TEXWIDTH) * PVRT_MAX(nSizeY, PVRTC4_MIN_TEXHEIGHT) * psPVRHeader->dwBitCount + 7) / 8;
				}

				if(((signed int)nMIPMapLevel - (signed int)nLoadFromLevel) >= 0)
				{
					if(bIsCompressedFormatSupported)
					{
						/* Load compressed texture data at selected MIP level */
						glCompressedTexImage2D(GL_TEXTURE_2D, nMIPMapLevel-nLoadFromLevel, eTextureFormat, nSizeX, nSizeY, 0,
										CompressedImageSize, theTextureToLoad);

					}
					else
					{
						// Convert PVRTC to 32-bit
						PVRTuint8 *u8TempTexture = (PVRTuint8*)malloc(nSizeX*nSizeY*4);
						if ((psPVRHeader->dwpfFlags & PVRTEX_PIXELTYPE)==OGL_PVRTC2)
						{
							PVRTDecompressPVRTC(theTextureToLoad, 1, nSizeX, nSizeY, u8TempTexture);
						}
						else
						{// PVRTC4 case
							PVRTDecompressPVRTC(theTextureToLoad, 0, nSizeX, nSizeY, u8TempTexture);
						}


						//if(psPVRHeader->dwpfFlags&PVRTEX_CUBEMAP)
						//{// Load compressed cubemap data at selected MIP level
						//	// Upload the texture as 32-bits
						//	glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X+i,nMIPMapLevel-nLoadFromLevel,GL_RGBA,
						//		nSizeX,nSizeY,0, GL_RGBA,GL_UNSIGNED_BYTE,u8TempTexture);
						//	FREE(u8TempTexture);
						//}
						//else
						{// Load compressed 2D data at selected MIP level
							// Upload the texture as 32-bits
							glTexImage2D(GL_TEXTURE_2D,nMIPMapLevel-nLoadFromLevel,GL_RGBA,
								nSizeX,nSizeY,0, GL_RGBA,GL_UNSIGNED_BYTE,u8TempTexture);
							FREE(u8TempTexture);
						}
					}
				}
			}
			else
			{
				if(((signed int)nMIPMapLevel - (signed int)nLoadFromLevel) >= 0)
				{
					/* Load uncompressed texture data at selected MIP level */
						glTexImage2D(GL_TEXTURE_2D,nMIPMapLevel-nLoadFromLevel,eTextureInternalFormat,nSizeX,nSizeY,0,eTextureFormat,eTextureType,theTextureToLoad);
				}
			}



			if(glGetError())
			{
				PVRTErrorOutputDebug("PVRTTextureLoadFromPointer failed: glTexImage2D() failed.\n");
				return PVR_FAIL;
			}

			// offset the texture pointer by one mip-map level
			/* PVRTC case */
			if ( bIsCompressedFormat )
			{
				theTexturePtr += CompressedImageSize;
			}
			else
			{
				/* New formula that takes into account bit counts inferior to 8 (e.g. 1 bpp) */
				theTexturePtr += (nSizeX * nSizeY * psPVRHeader->dwBitCount + 7) / 8;
			}
		}
	}

	*texName = textureName;

	if(psTextureHeader)
	{
		*(PVR_Texture_Header*)psTextureHeader = *psPVRHeader;
		((PVR_Texture_Header*)psTextureHeader)->dwPVR = PVRTEX_IDENTIFIER;
		((PVR_Texture_Header*)psTextureHeader)->dwNumSurfs = u32NumSurfs;
	}

	if(!psPVRHeader->dwMipMapCount)
	{
		myglTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		myglTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	else
	{
		myglTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
		myglTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}

	return PVR_SUCCESS;
}

/*!***************************************************************************
 @Function		PVRTTextureLoadFromPVR
 @Input			filename			Filename of the .PVR file to load the texture from
 @Modified		texName				the OpenGL ES texture name as returned by glBindTexture
 @Modified		psTextureHeader		Pointer to a PVR_Texture_Header struct. Modified to
									contain the header data of the returned texture Ignored if NULL.
 @Input			bAllowDecompress	Allow decompression if PVRTC is not supported in hardware.
 @Input			nLoadFromLevel		Which mipmap level to start loading from (0=all)
 @Return		PVR_SUCCESS on success
 @Description	Allows textures to be stored in binary PVR files and loaded in. Can load parts of a
				mipmaped texture (ie skipping the highest detailed levels).
				Sets the texture MIN/MAG filter to GL_LINEAR_MIPMAP_NEAREST/GL_LINEAR
				if mipmaps are present, GL_LINEAR/GL_LINEAR otherwise.
*****************************************************************************/
EPVRTError PVRTTextureLoadFromPVR(	const char * const filename,
									GLuint * const texName,
									const void *psTextureHeader,
									bool bAllowDecompress,
									const unsigned int nLoadFromLevel)
{
	CPVRTResourceFile TexFile(filename);
	if (!TexFile.IsOpen()) return PVR_FAIL;

	if(!PVRTIsLittleEndian()) // If we're on a big endian platform we need to do some conversion
	{
		unsigned int i;
		PVR_Texture_Header PVRHeader;
		PVR_Texture_Header* psPVRHeader;

		// Convert the header
		PVRHeader = *((PVR_Texture_Header*) TexFile.DataPtr());
		psPVRHeader = (PVR_Texture_Header*) &PVRHeader;
		PVRTuint32* psPVRHeader32 = (PVRTuint32*) psPVRHeader;

		unsigned int ui32HeaderSize = sizeof(PVRHeader) / sizeof(PVRTuint32);

		for(i = 0; i < ui32HeaderSize; ++i)
			PVRTByteSwap((PVRTuint8*) &psPVRHeader32[i], sizeof(PVRTuint32));

		// Convert the data if needed
		switch(PVRHeader.dwpfFlags & PVRTEX_PIXELTYPE)
		{
			case OGL_RGBA_4444:
			case OGL_RGBA_5551:
			case OGL_RGB_565:
			{
				PVRTuint16* pOrigData16 = (PVRTuint16*) (((PVRTuint8*)TexFile.DataPtr()) + psPVRHeader->dwHeaderSize);
				PVRTuint16* pNewData16 = (PVRTuint16*) malloc(PVRHeader.dwTextureDataSize);

				for(i = 0; i < PVRHeader.dwTextureDataSize / 2; ++i)
					pNewData16[i] = PVRTByteSwap16(pOrigData16[i]);

				EPVRTError err = PVRTTextureLoadFromPointer(psPVRHeader, texName, psTextureHeader, bAllowDecompress, nLoadFromLevel, pNewData16);
				FREE(pNewData16);
				return err;
			}

			default: // No conversion needed so just use the data
				return PVRTTextureLoadFromPointer(psPVRHeader, texName, psTextureHeader, bAllowDecompress, nLoadFromLevel, ((PVRTuint8*) TexFile.DataPtr()) + psPVRHeader->dwHeaderSize);
		}
	}

	return PVRTTextureLoadFromPointer(TexFile.DataPtr(), texName, psTextureHeader, bAllowDecompress, nLoadFromLevel);
}

/*!***************************************************************************
 @Function			PVRTTextureFormatGetBPP
 @Input				nFormat
 @Input				nType
 @Description		Returns the bits per pixel (BPP) of the format.
*****************************************************************************/
unsigned int PVRTTextureFormatGetBPP(const GLuint nFormat, const GLuint nType)
{
	switch(nFormat)
	{
	case GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG:
	case GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG:
		return 2;
	case GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG:
	case GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG:
		return 4;
	case GL_UNSIGNED_BYTE:
		switch(nType)
		{
		case GL_RGBA:
		case GL_BGRA:
			return 32;
		}
	case GL_UNSIGNED_SHORT_5_5_5_1:
		switch(nType)
		{
		case GL_RGBA:
			return 16;
		}
	}

	return 0xFFFFFFFF;
}


/*****************************************************************************
 End of file (PVRTTextureAPI.cpp)
*****************************************************************************/

