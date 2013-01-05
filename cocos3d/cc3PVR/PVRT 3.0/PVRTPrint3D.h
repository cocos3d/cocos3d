/******************************************************************************

 @File         PVRTPrint3D.h

 @Title        PVRTPrint3D

 @Version       @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Code to print text through the 3D interface.

******************************************************************************/
#ifndef _PVRTPRINT3D_H_
#define _PVRTPRINT3D_H_

#include "PVRTGlobal.h"
#include "PVRTError.h"
#include "PVRTMatrix.h"
#include "PVRTVector.h"
#include "PVRTArray.h"

struct MetaDataBlock;
template <typename KeyType, typename DataType>
class CPVRTMap;

/****************************************************************************
** Enums
****************************************************************************/
#define PVRTPRINT3D_MAX_RENDERABLE_LETTERS	(0xFFFF >> 2)

/*!***************************************************************************
 Logo flags for DisplayDefaultTitle
*****************************************************************************/
typedef enum {
	ePVRTPrint3DLogoNone	= 0x00,
	ePVRTPrint3DLogoIMG		= 0x04,
	ePVRTPrint3DSDKLogo		= ePVRTPrint3DLogoIMG
} EPVRTPrint3DLogo;

/****************************************************************************
** Constants
****************************************************************************/
const PVRTuint32 PVRTPRINT3D_HEADER			= 0xFCFC0050;
const PVRTuint32 PVRTPRINT3D_CHARLIST		= 0xFCFC0051;
const PVRTuint32 PVRTPRINT3D_RECTS			= 0xFCFC0052;
const PVRTuint32 PVRTPRINT3D_METRICS		= 0xFCFC0053;
const PVRTuint32 PVRTPRINT3D_YOFFSET		= 0xFCFC0054;
const PVRTuint32 PVRTPRINT3D_KERNING		= 0xFCFC0055;

const PVRTuint32 PVRTPRINT3D_VERSION		= 1;

/****************************************************************************
** Structures
****************************************************************************/
/*!**************************************************************************
@Struct SPVRTPrint3DHeader
@Brief A structure for information describing with the loaded font.
****************************************************************************/
struct SPVRTPrint3DHeader				// 12 bytes
{
	PVRTuint8	uVersion;				// Version of PVRFont.
	PVRTuint8	uSpaceWidth;			// The width of the 'Space' character
	PVRTint16	wNumCharacters;			// Total number of characters contained in this file
	PVRTint16	wNumKerningPairs;		// Number of characters which kern against each other
	PVRTint16	wAscent;				// The height of the character, in pixels, from the base line
	PVRTint16	wLineSpace;				// The base line to base line dimension, in pixels.
	PVRTint16	wBorderWidth;			// px Border around each character
};
/*!**************************************************************************
@Struct SPVRTPrint3DAPIVertex
@Brief A structure for Print3Ds vertex type
****************************************************************************/
struct SPVRTPrint3DAPIVertex
{
	VERTTYPE		sx, sy, sz, rhw;
	unsigned int	color;
	VERTTYPE		tu, tv;
};

struct PVRTextureHeaderV3;
struct SPVRTPrint3DAPI;
struct SPVRTContext;

/*!***************************************************************************
 @Class CPVRTPrint3D
 @Brief Display text/logos on the screen
*****************************************************************************/
class CPVRTPrint3D
{
public:
	/*!***************************************************************************
	 @Function			CPVRTPrint3D
	 @Description		Init some values.
	*****************************************************************************/
	CPVRTPrint3D();
	/*!***************************************************************************
	 @Function			~CPVRTPrint3D
	 @Description		De-allocate the working memory
	*****************************************************************************/
	~CPVRTPrint3D();

	/*!***************************************************************************
	 @Function			SetTextures
	 @Input				pContext		Context
	 @Input				dwScreenX		Screen resolution along X
	 @Input				dwScreenY		Screen resolution along Y
	 @Input				bRotate			Rotate print3D by 90 degrees
	 @Input				bMakeCopy		This instance of Print3D creates a copy
										of it's data instead of sharing with previous
										contexts. Set this parameter if you require
										thread safety.										
	 @Return			PVR_SUCCESS or PVR_FAIL
	 @Description		Initialization and texture upload of default font data. 
						Should be called only once for a Print3D object.
	*****************************************************************************/
	EPVRTError SetTextures(
		const SPVRTContext	* const pContext,
		const unsigned int	dwScreenX,
		const unsigned int	dwScreenY,
		const bool bRotate = false,
		const bool bMakeCopy = false);

	/*!***************************************************************************
	 @Function			SetTextures
	 @Input				pContext		Context
	 @Input				pTexData		User-provided font texture
	 @Input				dwScreenX		Screen resolution along X
	 @Input				dwScreenY		Screen resolution along Y
	 @Input				bRotate			Rotate print3D by 90 degrees
	 @Input				bMakeCopy		This instance of Print3D creates a copy
										of it's data instead of sharing with previous
										contexts. Set this parameter if you require
										thread safety.	
	 @Return			PVR_SUCCESS or PVR_FAIL
	 @Description		Initialization and texture upload of user-provided font 
						data. Should be called only once for a Print3D object.
	*****************************************************************************/
	EPVRTError SetTextures(
		const SPVRTContext	* const pContext,
		const void * const pTexData,
		const unsigned int	dwScreenX,
		const unsigned int	dwScreenY,
		const bool bRotate = false,
		const bool bMakeCopy = false);

	/*!***************************************************************************
	 @Function			SetProjection
	 @Input				mProj			Projection matrix
	 @Description		Sets the projection matrix for the proceeding flush().
	*****************************************************************************/
	void SetProjection(const PVRTMat4& mProj);

	/*!***************************************************************************
	 @Function			SetModelView
	 @Input				mModelView			Model View matrix
	 @Description		Sets the model view matrix for the proceeding flush().
	*****************************************************************************/
	void SetModelView(const PVRTMat4& mModelView);

	/*!***************************************************************************
	 @Function			SetFiltering
	 @Input				eMin	The method of texture filtering for minification
	 @Input				eMag	The method of texture filtering for minification
	 @Input				eMip	The method of texture filtering for minification
	 @Description		Sets the method of texture filtering for the font texture.
						Print3D will attempt to pick the best method by default
						but this method allows the user to override this.
	*****************************************************************************/
	void SetFiltering(ETextureFilter eMin, ETextureFilter eMag, ETextureFilter eMip);

	/*!***************************************************************************
	 @Function			Print3D
	 @Input				fPosX		Position of the text along X
	 @Input				fPosY		Position of the text along Y
	 @Input				fScale		Scale of the text
	 @Input				Colour		Colour of the text
	 @Input				pszFormat	Format string for the text
	 @Return			PVR_SUCCESS or PVR_FAIL
	 @Description		Display 3D text on screen.
						CPVRTPrint3D::SetTextures(...) must have been called
						beforehand.
						This function accepts formatting in the printf way.
	*****************************************************************************/
	EPVRTError Print3D(float fPosX, float fPosY, const float fScale, unsigned int Colour, const char * const pszFormat, ...);


	/*!***************************************************************************
	 @Function			Print3D
	 @Input				fPosX		Position of the text along X
	 @Input				fPosY		Position of the text along Y
	 @Input				fScale		Scale of the text
	 @Input				Colour		Colour of the text
	 @Input				pszFormat	Format string for the text
	 @Return			PVR_SUCCESS or PVR_FAIL
	 @Description		Display wide-char 3D text on screen.
						CPVRTPrint3D::SetTextures(...) must have been called
						beforehand.
						This function accepts formatting in the printf way.
	*****************************************************************************/
	EPVRTError Print3D(float fPosX, float fPosY, const float fScale, unsigned int Colour, const wchar_t * const pszFormat, ...);

	/*!***************************************************************************
	 @Function			DisplayDefaultTitle
	 @Input				pszTitle			Title to display
	 @Input				pszDescription		Description to display
	 @Input				uDisplayLogo		1 = Display the logo
	 @Return			PVR_SUCCESS or PVR_FAIL
	 @Description		Creates a default title with predefined position and colours.
						It displays as well company logos when requested:
						0 = No logo
						1 = PowerVR logo
						2 = Img Tech logo
	*****************************************************************************/
	 EPVRTError DisplayDefaultTitle(const char * const pszTitle, const char * const pszDescription, const unsigned int uDisplayLogo);

	 /*!***************************************************************************
	 @Function			MeasureText
	 @Output			pfWidth				Width of the string in pixels
	 @Output			pfHeight			Height of the string in pixels
	 @Input				fScale				A value to scale the font by
	 @Input				pszUTF8				UTF8 string to take the size of
	 @Description		Returns the size of a string in pixels.
	*****************************************************************************/
	void MeasureText(
		float		* const pfWidth,
		float		* const pfHeight,
		float				fScale,
		const char	* const pszUTF8);

	/*!***************************************************************************
	 @Function			MeasureText
	 @Output			pfWidth				Width of the string in pixels
	 @Output			pfHeight			Height of the string in pixels
	 @Input				fScale				A value to scale the font by
	 @Input				pszUnicode			Wide character string to take the
											length of.
	 @Description		Returns the size of a string in pixels.
	*****************************************************************************/
	void MeasureText(
		float		* const pfWidth,
		float		* const pfHeight,
		float				fScale,
		const wchar_t* const pszUnicode);

	/*!***************************************************************************
	@Function		GetFontAscent
	@Return			The ascent.
	@Description	Returns the 'ascent' of the font. This is typically the 
					height from the baseline of the larget glyph in the set.
	*****************************************************************************/
	unsigned int GetFontAscent();

	/*!***************************************************************************
	@Function		GetFontLineSpacing
	@Return			The line spacing.
	@Description	Returns the default line spacing (i.e baseline to baseline) 
					for the font.
	*****************************************************************************/
	unsigned int GetFontLineSpacing();

	/*!***************************************************************************
	 @Function			GetAspectRatio
	 @Output			dwScreenX		Screen resolution X
	 @Output			dwScreenY		Screen resolution Y
	 @Description		Returns the current resolution used by Print3D
	*****************************************************************************/
	void GetAspectRatio(unsigned int *dwScreenX, unsigned int *dwScreenY);

	/*!***************************************************************************
	 @Function			ReleaseTextures
	 @Description		Deallocate the memory allocated in SetTextures(...)
	*****************************************************************************/
	void ReleaseTextures();

	/*!***************************************************************************
	 @Function			Flush
	 @Description		Flushes all the print text commands
	*****************************************************************************/
	int Flush();

private:
	/*!***************************************************************************
	 @Function			UpdateLine
	 @Input				fZPos
	 @Input				XPos
	 @Input				YPos
	 @Input				fScale
	 @Input				Colour
	 @Input				Text
	 @Input				pVertices
	 @Description
	*****************************************************************************/
	unsigned int UpdateLine(const float fZPos, float XPos, float YPos, const float fScale, const unsigned int Colour, const CPVRTArray<PVRTuint32>& Text, SPVRTPrint3DAPIVertex * const pVertices);

	/*!***************************************************************************
	 @Function			DrawLineUP
	 @Return			true or false
	 @Description		Draw a single line of text.
	*****************************************************************************/
	bool DrawLine(SPVRTPrint3DAPIVertex *pVtx, unsigned int nVertices);

	/*!***************************************************************************
	@Function		LoadFontData
	@Input			texHeader
	@Input			MetaDataMap
	@Return			bool	true if successful.
	@Description	Loads font data bundled with the texture file.
	*****************************************************************************/
	bool LoadFontData(const PVRTextureHeaderV3* texHeader, CPVRTMap<PVRTuint32, CPVRTMap<PVRTuint32, MetaDataBlock> >& MetaDataMap);

	/*!***************************************************************************
	@Function		ReadMetaBlock
	@Input			pDataCursor
	@Return			bool	true if successful.
	@Description	Reads a single meta data block from the data file.
	*****************************************************************************/
	bool ReadMetaBlock(const PVRTuint8** pDataCursor);

	/*!***************************************************************************
	@Function		FindCharacter
	@Input			character
	@Return			The character index, or PVRPRINT3D_INVALID_CHAR if not found.
	@Description	Finds a given character in the binary data and returns it's
					index.
	*****************************************************************************/
	PVRTuint32 FindCharacter(PVRTuint32 character) const;

	/*!***************************************************************************
	@Function		CharacterCompareFunc
	@Input			pA
	@Input			pB
	@Return			PVRTint32	
	@Description	Compares two characters for binary search.
	*****************************************************************************/
	static PVRTint32 CharacterCompareFunc(const void* pA, const void* pB);
	
	/*!***************************************************************************
	@Function		KerningCompareFunc
	@Input			pA
	@Input			pB
	@Return			PVRTint32	
	@Description	Compares two kerning pairs for binary search.
	*****************************************************************************/
	static PVRTint32 KerningCompareFunc(const void* pA, const void* pB);

	/*!***************************************************************************
	@Function		ApplyKerning
	@Input			cA
	@Input			cB
	@Output			fOffset
	@Description	Calculates kerning offset.
	*****************************************************************************/
	void ApplyKerning(const PVRTuint32 cA, const PVRTuint32 cB, float& fOffset) const;

	/*!***************************************************************************
	 @Function			GetSize
	 @Output			pfWidth				Width of the string in pixels
	 @Output			pfHeight			Height of the string in pixels
	 @Input				fScale				Font size
	 @Input				utf32				UTF32 string to take the size of.
	 @Description		Returns the size of a string in pixels.
	*****************************************************************************/
	void MeasureText(
		float		* const pfWidth,
		float		* const pfHeight,
		float				fScale,
		const CPVRTArray<PVRTuint32>& utf32);
	
	/*!***************************************************************************
	@Function		Print3D
	@Input			fPosX		X Position
	@Input			fPosY		Y Position
	@Input			fScale		Text scale
	@Input			Colour		ARGB colour
	@Input			UTF32		Array of UTF32 characters
	@Input			bUpdate		Whether to update the vertices
	@Return			EPVRTError	Success of failure
	@Description	Takes an array of UTF32 characters and generates the required mesh.
	*****************************************************************************/
	EPVRTError Print3D(float fPosX, float fPosY, const float fScale, unsigned int Colour, const CPVRTArray<PVRTuint32>& UTF32, bool bUpdate);

/*!***************************************************************************
@Brief			Structures and enums for font data
@Description	The following structures are used to provide layout
				information for associated fonts.
*****************************************************************************/
private:
	struct CharacterUV
	{
		float fUL;
		float fVT;
		float fUR;
		float fVB;
	};

	struct Rectanglei
	{
		int	nX;
		int	nY;
		int	nW;
		int	nH;
	};

#pragma pack(push, 4)		// Force 4byte alignment.
	struct KerningPair
	{
		unsigned long long	uiPair;				// OR'd pair for 32bit characters
		int				 	iOffset;			// Kerning offset (in pixels)
	};
#pragma pack(pop)

	struct CharMetrics
	{
		short nXOff;						// Prefix offset
		unsigned short nAdv;				// Character width
	};

	enum
	{
		eFilterProc_Min,
		eFilterProc_Mag,
		eFilterProc_Mip,

		eFilterProc_Size
	};

private:
	// Mesh parameters
	SPVRTPrint3DAPI			*m_pAPI;
	unsigned int			m_uLogoToDisplay;
	unsigned short			*m_pwFacesFont;
	SPVRTPrint3DAPIVertex	*m_pPrint3dVtx;
	float					m_fScreenScale[2];
	unsigned int			m_ui32ScreenDim[2];
	bool					m_bTexturesSet;
	SPVRTPrint3DAPIVertex	*m_pVtxCache;
	int						m_nVtxCache;
	int						m_nVtxCacheMax;
	bool					m_bRotate;

	// Cached memory
	CPVRTArray<PVRTuint32>	m_CachedUTF32;
	int						m_nCachedNumVerts;
	wchar_t*				m_pwzPreviousString;
	char*					m_pszPreviousString;
	float					m_fPrevScale;
	float					m_fPrevX;
	float					m_fPrevY;
	unsigned int			m_uiPrevCol;

	// Font parameters
	CharacterUV*			m_pUVs;
	KerningPair*			m_pKerningPairs;
	CharMetrics*			m_pCharMatrics;
	
	float					m_fTexW;
	float					m_fTexH;

	Rectanglei*				m_pRects;
	int*					m_pYOffsets;
	int						m_uiNextLineH;

	unsigned int			m_uiSpaceWidth;	
	unsigned int			m_uiNumCharacters;
	unsigned int			m_uiNumKerningPairs;
	unsigned int			m_uiAscent;
	PVRTuint32*				m_pszCharacterList;
	bool					m_bHasMipmaps;
	
	// View parameters
	PVRTMat4				m_mProj;
	PVRTMat4				m_mModelView;
	bool					m_bUsingProjection;
	ETextureFilter			m_eFilterMethod[eFilterProc_Size];

/*!***************************************************************************
@Brief			API specific code
@Description	The following functions are API specific. Their implementation
				can be found in the directory *CurrentAPI*\PVRTPrint3DAPI
*****************************************************************************/
private:
	/*!***************************************************************************
	 @Function			APIInit
	 @Input				pContext
	 @Input				bMakeCopy
	 @Return			true or false
	 @Description		Initialization and texture upload. Should be called only once
						for a given context.
	*****************************************************************************/
	bool APIInit(const SPVRTContext	* const pContext, bool bMakeCopy);

	/*!***************************************************************************
	 @Function			APIRelease
	 @Description		Deinitialization.
	*****************************************************************************/
	void APIRelease();

	/*!***************************************************************************
	 @Function			APIUpLoadIcons
	 @Input				pIMG
	 @Return			true or false
	 @Description		Initialization and texture upload. Should be called only once
						for a given context.
	*****************************************************************************/
	bool APIUpLoadIcons(const PVRTuint8 * const pIMG);

	/*!***************************************************************************
	 @Function			APIUpLoadTexture
	 @Input				pSource
	 @Input				header
	 @Input				MetaDataMap
	 @Return			true if successful, false otherwise.
	 @Description		Reads texture data from *.dat and loads it in
						video memory.
	*****************************************************************************/
	bool APIUpLoadTexture(const PVRTuint8* pSource, const PVRTextureHeaderV3* header, CPVRTMap<PVRTuint32, CPVRTMap<PVRTuint32, MetaDataBlock> >& MetaDataMap);


	/*!***************************************************************************
	 @Function			APIRenderStates
	 @Input				nAction
	 @Description		Stores, writes and restores Render States
	*****************************************************************************/
	void APIRenderStates(int nAction);

	/*!***************************************************************************
	 @Function			APIDrawLogo
	 @Input				uLogoToDisplay
	 @Input				nPod
	 @Description		nPos = -1 to the left
						nPos = +1 to the right
	*****************************************************************************/
	void APIDrawLogo(unsigned int uLogoToDisplay, int nPos);
};


#endif /* _PVRTPRINT3D_H_ */

/*****************************************************************************
 End of file (PVRTPrint3D.h)
*****************************************************************************/

