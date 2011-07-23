/******************************************************************************

 @File         PVRTTriStrip.h

 @Title        PVRTTriStrip

 @Version      

 @Copyright    Copyright (C)  Imagination Technologies Limited.

 @Platform     Independent

 @Description  Strips a triangle list.

******************************************************************************/
#ifndef _PVRTTRISTRIP_H_
#define _PVRTTRISTRIP_H_


/****************************************************************************
** Declarations
****************************************************************************/

/*!***************************************************************************
 @Function			PVRTTriStrip
 @Output			ppui32Strips
 @Output			ppnStripLen
 @Output			pnStripCnt
 @Input				pui32TriList
 @Input				nTriCnt
 @Description		Reads a triangle list and generates an optimised triangle strip.
*****************************************************************************/
void PVRTTriStrip(
	unsigned int			**ppui32Strips,
	unsigned int			**ppnStripLen,
	unsigned int			*pnStripCnt,
	const unsigned int	* const pui32TriList,
	const unsigned int		nTriCnt);


/*!***************************************************************************
 @Function			PVRTTriStripList
 @Modified			pui32TriList
 @Input				nTriCnt
 @Description		Reads a triangle list and generates an optimised triangle strip. Result is
 					converted back to a triangle list.
*****************************************************************************/
void PVRTTriStripList(unsigned int * const pui32TriList, const unsigned int nTriCnt);


#endif /* _PVRTTRISTRIP_H_ */

/*****************************************************************************
 End of file (PVRTTriStrip.h)
*****************************************************************************/

