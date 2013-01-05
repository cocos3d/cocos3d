/******************************************************************************

 @File         PVRTPrint3DAPI.cpp

 @Title        OGLES/PVRTPrint3DAPI

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Displays a text string using 3D polygons. Can be done in two ways:
               using a window defined by the user or writing straight on the
               screen.

******************************************************************************/

/****************************************************************************
** Includes
****************************************************************************/
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "PVRTContext.h"
#include "PVRTFixedPoint.h"
#include "PVRTMatrix.h"
#include "PVRTPrint3D.h"
#include "PVRTglesExt.h"
#include "PVRTTexture.h"
#include "PVRTTextureAPI.h"
#include "PVRTMap.h"

/****************************************************************************
** Defines
****************************************************************************/
#define UNDEFINED_HANDLE 0xFAFAFAFA

/****************************************************************************
** Structures
****************************************************************************/

struct SPVRTPrint3DAPI
{
	GLuint			m_uFontTexture;

	struct SInstanceData
	{
		GLuint	uTextureIMGLogo;

		SInstanceData()
		{
			uTextureIMGLogo = UNDEFINED_HANDLE;
		}
	};

	SInstanceData*			m_pInstanceData;
	static SInstanceData	s_InstanceData;

	static bool				s_IsVGPSupported;
	static int				s_iRefCount;

	SPVRTPrint3DAPI() : m_pInstanceData(NULL) {}
	~SPVRTPrint3DAPI()
	{
		if(m_pInstanceData)
		{
			delete m_pInstanceData;
			m_pInstanceData = NULL;
		}
	}
};
bool SPVRTPrint3DAPI::s_IsVGPSupported			= false;
int SPVRTPrint3DAPI::s_iRefCount				= 0;
SPVRTPrint3DAPI::SInstanceData SPVRTPrint3DAPI::s_InstanceData;

const GLenum c_eMagTable[] =
{
	GL_NEAREST,
	GL_LINEAR,
};

const GLenum c_eMinTable[] =
{
	GL_NEAREST_MIPMAP_NEAREST,
	GL_LINEAR_MIPMAP_NEAREST,
	GL_NEAREST_MIPMAP_LINEAR,
	GL_LINEAR_MIPMAP_LINEAR,
	GL_NEAREST,
	GL_LINEAR,
};

/****************************************************************************
** Class: CPVRTPrint3D
****************************************************************************/
/*!***************************************************************************
 @Function			ReleaseTextures
 @Description		Deallocate the memory allocated in SetTextures(...)
*****************************************************************************/
void CPVRTPrint3D::ReleaseTextures()
{
#if !defined (DISABLE_PRINT3D)

	/* Only release textures if they've been allocated */
	if (!m_bTexturesSet) return;

	/* Release IndexBuffer */
	FREE(m_pwFacesFont);
	FREE(m_pPrint3dVtx);

	/* Delete textures */
	glDeleteTextures(1, &m_pAPI->m_uFontTexture);
	
	// Has local copy
	if(m_pAPI->m_pInstanceData)
	{
		glDeleteTextures(1, &m_pAPI->m_pInstanceData->uTextureIMGLogo);
	}
	else
	{
		if(SPVRTPrint3DAPI::s_iRefCount != 0)
		{
			// Just decrease the reference count
			SPVRTPrint3DAPI::s_iRefCount--;
		}
		else
		{
			// Release the textures
			if(m_pAPI->s_InstanceData.uTextureIMGLogo != UNDEFINED_HANDLE) 
				glDeleteTextures(1, &m_pAPI->s_InstanceData.uTextureIMGLogo);

			m_pAPI->s_InstanceData.uTextureIMGLogo = UNDEFINED_HANDLE;
		}
	}
	
	

	m_bTexturesSet = false;

	FREE(m_pVtxCache);

	APIRelease();

#endif
}

/*!***************************************************************************
 @Function			Flush
 @Description		Flushes all the print text commands
*****************************************************************************/
int CPVRTPrint3D::Flush()
{
#if !defined (DISABLE_PRINT3D)

	int		nTris, nVtx, nVtxBase, nTrisTot;

	_ASSERT((m_nVtxCache % 4) == 0);
	_ASSERT(m_nVtxCache <= m_nVtxCacheMax);

	/* Save render states */
	APIRenderStates(0);

	/* Set font texture */
	glBindTexture(GL_TEXTURE_2D, m_pAPI->m_uFontTexture);

	unsigned int uiIndex = m_eFilterMethod[eFilterProc_Min] + (m_eFilterMethod[eFilterProc_Mip]*2);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, c_eMagTable[m_eFilterMethod[eFilterProc_Mag]]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, c_eMinTable[uiIndex]);

	/* Set blending mode */
	glEnable(GL_BLEND);

	nTrisTot = m_nVtxCache >> 1;

	/*
		Render the text then. Might need several submissions.
	*/
	nVtxBase = 0;
	while(m_nVtxCache)
	{
		nVtx	= PVRT_MIN(m_nVtxCache, 0xFFFC);
		nTris	= nVtx >> 1;

		_ASSERT(nTris <= (PVRTPRINT3D_MAX_RENDERABLE_LETTERS*2));
		_ASSERT((nVtx % 4) == 0);

		/* Draw triangles */
		glVertexPointer(3,		VERTTYPEENUM,		sizeof(SPVRTPrint3DAPIVertex), &m_pVtxCache[nVtxBase].sx);
		glColorPointer(4,		GL_UNSIGNED_BYTE,	sizeof(SPVRTPrint3DAPIVertex), &m_pVtxCache[nVtxBase].color);
		glTexCoordPointer(2,	VERTTYPEENUM,		sizeof(SPVRTPrint3DAPIVertex), &m_pVtxCache[nVtxBase].tu);
		glDrawElements(GL_TRIANGLES, nTris * 3, GL_UNSIGNED_SHORT, m_pwFacesFont);
		if (glGetError())
		{
			_RPT0(_CRT_WARN,"glDrawElements(GL_TRIANGLES, (VertexCount/2)*3, GL_UNSIGNED_SHORT, m_pFacesFont); failed\n");
		}

		nVtxBase		+= nVtx;
		m_nVtxCache	-= nVtx;
	}

	/* Draw a logo if requested */
#if defined(FORCE_NO_LOGO)
	/* Do nothing */

#elif defined(FORCE_IMG_LOGO)
	APIDrawLogo(ePVRTPrint3DLogoIMG, 1);	/* IMG to the right */

#elif defined(FORCE_ALL_LOGOS)
	APIDrawLogo(ePVRTPrint3DLogoIMG, -1); /* IMG to the left */

#else
	/* User selected logos */
	switch (m_uLogoToDisplay)
	{
		case ePVRTPrint3DLogoNone:
			break;
		default:
		case ePVRTPrint3DLogoIMG:
			APIDrawLogo(ePVRTPrint3DLogoIMG, 1);	/* IMG to the right */
			break;
	}
#endif

	/* Restore render states */
	APIRenderStates(1);

	return nTrisTot;

#else
	return 0;
#endif
}

/*************************************************************
*					 PRIVATE FUNCTIONS						 *
**************************************************************/

/*!***************************************************************************
 @Function			APIInit
 @Description		Initialization and texture upload. Should be called only once
					for a given context.
*****************************************************************************/
bool CPVRTPrint3D::APIInit(const SPVRTContext	* const /*pContext*/, bool bMakeCopy)
{
	m_pAPI = new SPVRTPrint3DAPI;
	if(!m_pAPI)
		return false;

	if(bMakeCopy)
		m_pAPI->m_pInstanceData = new SPVRTPrint3DAPI::SInstanceData();

	SPVRTPrint3DAPI::s_IsVGPSupported = CPVRTglesExt::IsGLExtensionSupported("GL_IMG_vertex_program");

	return true;
}

/*!***************************************************************************
 @Function			APIRelease
 @Description		Deinitialization.
*****************************************************************************/
void CPVRTPrint3D::APIRelease()
{
	delete m_pAPI;
	m_pAPI = 0;
}

/*!***************************************************************************
 @Function			APIUpLoadIcons
 @Description		Initialization and texture upload. Should be called only once
					for a given context.
*****************************************************************************/
bool CPVRTPrint3D::APIUpLoadIcons(const PVRTuint8 * const pIMG)
{
	SPVRTPrint3DAPI::SInstanceData& Data = (m_pAPI->m_pInstanceData ? *m_pAPI->m_pInstanceData : SPVRTPrint3DAPI::s_InstanceData);

	/* Load Icon textures */
	if(Data.uTextureIMGLogo == UNDEFINED_HANDLE)		// Static, so might already be initialized.
		if(PVRTTextureLoadFromPointer((unsigned char*)pIMG, &Data.uTextureIMGLogo) != PVR_SUCCESS)
			return false;

	return true;
}

/*!***************************************************************************
@Function		APIUpLoadTexture
@Input			pSource
@Output			header
@Return			bool	true if successful.
@Description	Loads and uploads the font texture from a PVR file.
*****************************************************************************/
bool CPVRTPrint3D::APIUpLoadTexture(const PVRTuint8* pSource, const PVRTextureHeaderV3* header, CPVRTMap<PVRTuint32, CPVRTMap<PVRTuint32, MetaDataBlock> >& MetaDataMap)
{
	if(PVRTTextureLoadFromPointer(pSource, &m_pAPI->m_uFontTexture, header, true, 0U, NULL, &MetaDataMap) != PVR_SUCCESS)
		return false;

	/* Return status : OK */
	return true;
}

/*!***************************************************************************
 @Function			APIRenderStates
 @Description		Stores, writes and restores Render States
*****************************************************************************/
void CPVRTPrint3D::APIRenderStates(int nAction)
{
	PVRTMat4 mxOrtho;
	float fW, fH;
	// Saving or restoring states ?
	switch (nAction)
	{
	case 0:
		/******************************
		** SET PRINT3D RENDER STATES **
		******************************/
		// Set matrix with viewport dimensions
		fW = m_fScreenScale[0]*640.0f;
		fH = m_fScreenScale[1]*480.0f;

		mxOrtho = PVRTMat4::Ortho(0.0f, 0.0f, fW, -fH, -1.0f, 1.0f, PVRTMat4::OGL, m_bRotate);
		if(m_bRotate)
		{
			PVRTMat4 mxTrans = PVRTMat4::Translation(-fH,fW,0.0f);
			mxOrtho = mxOrtho * mxTrans;
		}

		// Set matrix modes
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		if(m_bUsingProjection)
			myglLoadMatrix(m_mProj.f);
		else
			myglLoadMatrix(mxOrtho.f);

		// Apply ModelView matrix (probably identity).
		glMultMatrixf(m_mModelView.f);

		// Reset
		m_bUsingProjection = false;
		PVRTMatrixIdentity(m_mModelView);

		// Disable lighting
		glDisable(GL_LIGHTING);

		// Culling
		glEnable(GL_CULL_FACE);
		glFrontFace(GL_CW);
		glCullFace(GL_FRONT);

		// Set client states
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);

		glClientActiveTexture(GL_TEXTURE0);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		// texture
		glActiveTexture(GL_TEXTURE1);
		glDisable(GL_TEXTURE_2D);
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
		myglTexEnv(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);

		// Blending mode
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		// Disable fog
		glDisable(GL_FOG);

		// Set Z compare properties
		glDisable(GL_DEPTH_TEST);

		// Disable vertex program
		if(m_pAPI->s_IsVGPSupported)
			glDisable(GL_VERTEX_PROGRAM_ARB);

#if defined(GL_OES_VERSION_1_1) || defined(GL_VERSION_ES_CM_1_1) || defined(GL_VERSION_ES_CL_1_1)
		// unbind the VBO for the mesh
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
#endif
		break;

	case 1:
		// Restore render states
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);

		// Restore matrix mode & matrix
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
		break;
	}
}

/****************************************************************************
** Local code
****************************************************************************/

/*!***************************************************************************
 @Function			APIDrawLogo
 @Description		nPos = -1 to the left
					nPos = +1 to the right
*****************************************************************************/
void CPVRTPrint3D::APIDrawLogo(unsigned int uLogoToDisplay, int nPos)
{
	if (uLogoToDisplay==ePVRTPrint3DLogoNone)
		return;

	SPVRTPrint3DAPI::SInstanceData& Data = (m_pAPI->m_pInstanceData ? *m_pAPI->m_pInstanceData : SPVRTPrint3DAPI::s_InstanceData);
	const float fLogoSizeHalf = 0.15f;
	const float fLogoShift = 0.05f;
	const float fLogoSizeHalfShifted = fLogoSizeHalf + fLogoShift;
	const float fLogoYScale = 45.0f / 64.0f;

	static VERTTYPE	Vertices[] =
		{
			f2vt(-fLogoSizeHalf), f2vt(fLogoSizeHalf) , f2vt(0.5f),
			f2vt(-fLogoSizeHalf), f2vt(-fLogoSizeHalf), f2vt(0.5f),
			f2vt(fLogoSizeHalf)	, f2vt(fLogoSizeHalf) , f2vt(0.5f),
	 		f2vt(fLogoSizeHalf)	, f2vt(-fLogoSizeHalf), f2vt(0.5f)
		};

	static VERTTYPE	Colours[] = {
			f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f),
			f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f),
			f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f),
	 		f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f)
		};

	static VERTTYPE	UVs[] = {
			f2vt(0.0f), f2vt(0.0f),
			f2vt(0.0f), f2vt(1.0f),
			f2vt(1.0f), f2vt(0.0f),
	 		f2vt(1.0f), f2vt(1.0f)
		};

	VERTTYPE *pVertices = ( (VERTTYPE*)&Vertices );
	VERTTYPE *pColours  = ( (VERTTYPE*)&Colours );
	VERTTYPE *pUV       = ( (VERTTYPE*)&UVs );
	GLuint	tex;

	tex = Data.uTextureIMGLogo;

	// Matrices
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	float fScreenScale = PVRT_MIN(m_ui32ScreenDim[0], m_ui32ScreenDim[1]) / 480.0f;
	float fScaleX = (640.0f / m_ui32ScreenDim[0]) * fScreenScale;
	float fScaleY = (480.0f / m_ui32ScreenDim[1]) * fScreenScale * fLogoYScale;

	if(m_bRotate)
		myglRotate(f2vt(90), f2vt(0), f2vt(0), f2vt(1));

	myglTranslate(f2vt(nPos - (fLogoSizeHalfShifted * fScaleX * nPos)), f2vt(-1.0f + (fLogoSizeHalfShifted * fScaleY)), f2vt(0.0f));
	myglScale(f2vt(fScaleX), f2vt(fScaleY), f2vt(1.0f));

	// Render states
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, tex);

	glDisable(GL_DEPTH_TEST);

	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD);

	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Vertices
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3,VERTTYPEENUM,0,pVertices);

	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4,VERTTYPEENUM,0,pColours);

	glClientActiveTexture(GL_TEXTURE0);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2,VERTTYPEENUM,0,pUV);

	glDrawArrays(GL_TRIANGLE_STRIP,0,4);

	glDisableClientState(GL_VERTEX_ARRAY);

	glDisableClientState(GL_COLOR_ARRAY);

	glClientActiveTexture(GL_TEXTURE0);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);

	// Restore render states
	glDisable (GL_BLEND);
	glEnable(GL_DEPTH_TEST);
}

/*****************************************************************************
 End of file (PVRTPrint3DAPI.cpp)
*****************************************************************************/

