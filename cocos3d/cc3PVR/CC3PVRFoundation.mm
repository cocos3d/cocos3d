/*
 * CC3PVRFoundation.mm
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://en.wikipedia.org/wiki/MIT_License
 * 
 * See header file CC3PVRFoundation.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#import "CC3PVRFoundation.h"
#import "CC3PVRTModelPOD.h"
#import "CC3Matrix4x4.h"


NSString* NSStringFromSPODNode(PODStructPtr pSPODNode) {
	SPODNode* psn = (SPODNode*)pSPODNode;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"SPODNode named %@", [NSString stringWithUTF8String: psn->pszName]];
	[desc appendFormat: @", parent index: %i ", psn->nIdxParent];
	[desc appendFormat: @", content index: %i ", psn->nIdx];
	[desc appendFormat: @", material index: %i ", psn->nIdxMaterial];
	[desc appendFormat: @",\n\tanimation flags: %i", psn->nAnimFlags];
	BOOL first = YES;
	if (psn->nAnimFlags & ePODHasPositionAni) {
		[desc appendFormat: @"%@", first ? @" (" : @" + "];
		[desc appendFormat: @"ePODHasPositionAni"];
		first = NO;
	}
	if (psn->nAnimFlags & ePODHasRotationAni) {
		[desc appendFormat: @"%@", first ? @" (" : @" + "];
		[desc appendFormat: @"ePODHasRotationAni"];
		first = NO;
	}
	if (psn->nAnimFlags & ePODHasScaleAni) {
		[desc appendFormat: @"%@", first ? @" (" : @" + "];
		[desc appendFormat: @"ePODHasScaleAni"];
		first = NO;
	}
	if (psn->nAnimFlags & ePODHasMatrixAni) {
		[desc appendFormat: @"%@", first ? @" (" : @" + "];
		[desc appendFormat: @"ePODHasMatrixAni"];
		first = NO;
	}
	[desc appendFormat: @"%@", first ? @"" : @")"];
	[desc appendFormat: @"\n\tposition: %@", (psn->pfAnimPosition ? NSStringFromCC3Vector(*(CC3Vector*)psn->pfAnimPosition) : @"none")];
	[desc appendFormat: @", quaternion: %@", (psn->pfAnimRotation ? NSStringFromCC3Vector4(*(CC3Vector4*)psn->pfAnimRotation) : @"none")];
	[desc appendFormat: @", scale: %@)", (psn->pfAnimScale ? NSStringFromCC3Vector(*(CC3Vector*)psn->pfAnimScale) : @"none")];
	[desc appendFormat: @", matrix: %@)", (psn->pfAnimMatrix ? NSStringFromCC3Matrix4x4((CC3Matrix4x4*)psn->pfAnimMatrix) : @"none")];
	return desc;
}

NSString* NSStringFromSPODMesh(PODStructPtr pSPODNode) {
	SPODMesh* psm = (SPODMesh*)pSPODNode;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"SPODMesh drawing "];
	switch (psm->ePrimitiveType) {
		case ePODTriangles:
			[desc appendFormat: @"ePODTriangles"];
			break;
//		case ePODLines:				// ePODLines not supported as of PVR 2.09
//			[desc appendFormat: @"ePODLines"];
			break;
		default:
			[desc appendFormat: @"unknown ePrimitiveType (%u)", psm->ePrimitiveType];
			break;
	}
	[desc appendFormat: @"\n\tvertices: %u (%@)", psm->nNumVertex, NSStringFromCPODData(&psm->sVertex)];
	[desc appendFormat: @"\n\t\tnormals: (%@)", NSStringFromCPODData(&psm->sNormals)];
	[desc appendFormat: @"\n\t\ttangents: (%@)", NSStringFromCPODData(&psm->sTangents)];
	[desc appendFormat: @"\n\t\tbinormals: (%@)", NSStringFromCPODData(&psm->sBinormals)];
	[desc appendFormat: @"\n\t\tcolors: (%@)", NSStringFromCPODData(&psm->sVtxColours)];
	for (uint i = 0; i < psm->nNumUVW; i++) {
		[desc appendFormat: @"\n\t\ttexmap%u: (%@)", i, NSStringFromCPODData(&psm->psUVW[i])];
	}
	[desc appendFormat: @"\n\t\tboneIndices: (%@)", NSStringFromCPODData(&psm->sBoneIdx)];
	[desc appendFormat: @"\n\t\tboneWeights: (%@)", NSStringFromCPODData(&psm->sBoneWeight)];
	[desc appendFormat: @"\n\tfaces: %u (%@)", psm->nNumFaces, NSStringFromCPODData(&psm->sFaces)];
	[desc appendFormat: @"\n\tstrips: %u", psm->nNumStrips];
	[desc appendFormat: @", texture channels: %u", psm->nNumUVW];
	[desc appendFormat: @", interleaved data: %p", psm->pInterleaved];
	
	int batchCount = psm->sBoneBatches.nBatchCnt;
	[desc appendFormat: @", bone batches: %i", batchCount];
	
	for (int bbi = 0; bbi < psm->sBoneBatches.nBatchCnt; bbi++) {
		int boneCount = psm->sBoneBatches.pnBatchBoneCnt[bbi];
		[desc appendFormat: @"\n\t\tbatch with %i bone nodes:", boneCount];
		BOOL firstBone = YES;
		for (int bi = 0; bi < boneCount; bi++) {
			[desc appendFormat: @"%@", firstBone ? @" (" : @", "];
			[desc appendFormat: @"%i", psm->sBoneBatches.pnBatches[bbi * psm->sBoneBatches.nBatchBoneMax + bi]];
			firstBone = NO;
		}
		[desc appendFormat: @"%@", firstBone ? @"" : @")"];
	}
	return desc;
}

NSString* NSStringFromCPODData(PODClassPtr aCPODData) {
	CPODData* pcd = (CPODData*)aCPODData;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"CPODData type: %@", NSStringFromEPVRTDataType(pcd->eType)];
	[desc appendFormat: @", size: %i", pcd->n];
	[desc appendFormat: @", stride: %i", pcd->nStride];
	[desc appendFormat: @", data ptr: %p", pcd->pData];
	return desc;
}

NSString* NSStringFromCPVRTBoneBatches(PODClassPtr aCPVRTBoneBatches) {
	CPVRTBoneBatches* pbb = (CPVRTBoneBatches*)aCPVRTBoneBatches;
	int batchCount = pbb->nBatchCnt;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"CPVRTBoneBatches with %i batches of max %i bones per batch at: %p",
			batchCount, pbb->nBatchBoneMax, pbb->pnBatches];

	if (batchCount) {
		[desc appendFormat: @"\n\t\tbone counts: (%i", pbb->pnBatchBoneCnt[0]];
		for (int i = 1; i < batchCount; i++) {
			[desc appendFormat: @", %i", pbb->pnBatchBoneCnt[i]];
		}
		[desc appendFormat: @")"];

		[desc appendFormat: @"\n\t\tbone vertex offsets: (%i", pbb->pnBatchOffset[0]];
		for (int i = 1; i < batchCount; i++) {
			[desc appendFormat: @", %i", pbb->pnBatchOffset[i]];
		}
		[desc appendFormat: @")"];
	}
	return desc;
}

GLenum GLElementTypeFromEPVRTDataType(uint ePVRTDataType) {
	switch (ePVRTDataType) {
		case EPODDataFloat:
			return GL_FLOAT;
		case EPODDataInt:
		case EPODDataUnsignedInt:
			return GL_FIXED;
		case EPODDataByte:
		case EPODDataByteNorm:
			return GL_BYTE;
		case EPODDataUnsignedByte:
		case EPODDataUnsignedByteNorm:
		case EPODDataARGB:
		case EPODDataRGBA:
			return GL_UNSIGNED_BYTE;
		case EPODDataShort:
		case EPODDataShortNorm:
			return GL_SHORT;
		case EPODDataUnsignedShort:
		case EPODDataUnsignedShortNorm:
			return GL_UNSIGNED_SHORT;
		default:
			LogError(@"Unknown EPVRTDataType '%@'", NSStringFromEPVRTDataType(ePVRTDataType));
			return GL_BYTE;
	}
}

NSString* NSStringFromEPVRTDataType(uint ePVRTDataType) {
	switch (ePVRTDataType) {
		case EPODDataNone:
			return @"EPODDataNone";
		case EPODDataFloat:
			return @"EPODDataFloat";
		case EPODDataInt:
			return @"EPODDataInt";
		case EPODDataUnsignedInt:
			return @"EPODDataUnsignedInt";
		case EPODDataByte:
			return @"EPODDataByte";
		case EPODDataByteNorm:
			return @"EPODDataByteNorm";
		case EPODDataUnsignedByte:
			return @"EPODDataUnsignedByte";
		case EPODDataUnsignedByteNorm:
			return @"EPODDataUnsignedByteNorm";
		case EPODDataShort:
			return @"EPODDataShort";
		case EPODDataShortNorm:
			return @"EPODDataShortNorm";
		case EPODDataUnsignedShort:
			return @"EPODDataUnsignedShort";
		case EPODDataUnsignedShortNorm:
			return @"EPODDataUnsignedShortNorm";
		case EPODDataRGBA:
			return @"EPODDataRGBA";
		case EPODDataARGB:
			return @"EPODDataARGB";
		case EPODDataD3DCOLOR:
			return @"EPODDataD3DCOLOR";
		case EPODDataUBYTE4:
			return @"EPODDataUBYTE4";
		case EPODDataDEC3N:
			return @"EPODDataDEC3N";
		case EPODDataFixed16_16:
			return @"EPODDataFixed16_16";
		default:
			return [NSString stringWithFormat: @"unknown EPVRTDataType (%u)", ePVRTDataType];
	}
}

GLenum GLDrawingModeForSPODMesh(PODStructPtr aSPODMesh) {
	SPODMesh* psm = (SPODMesh*)aSPODMesh;
	BOOL usingStrips = psm->nNumStrips > 0;
	switch (psm->ePrimitiveType) {
		case ePODTriangles:
			return usingStrips ? GL_TRIANGLE_STRIP : GL_TRIANGLES;
//		case ePODLines:								// ePODLines not supported as of PVR 2.09
//			return usingStrips ? GL_LINE_STRIP : GL_LINES;
		default:
			LogError(@"Unknown EPODPrimitiveType %u", psm->ePrimitiveType);
			return GL_TRIANGLE_STRIP;
	}
}

NSString* NSStringFromSPODCamera(PODStructPtr pSPODCamera) {
	SPODCamera* psc = (SPODCamera*)pSPODCamera;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPODCamera fov: %.2f", psc->fFOV];
	[desc appendFormat: @", near: %.2f", psc->fNear];
	[desc appendFormat: @", far: %.2f", psc->fFar];
	[desc appendFormat: @", target index: %i", psc->nIdxTarget];
	return desc;
}

NSString* NSStringFromSPODLight(PODStructPtr pSPODLight) {
	SPODLight* psl = (SPODLight*)pSPODLight;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPODLight type: %@", NSStringFromEPODLight(psl->eType)];
	[desc appendFormat: @", color: (%.2f, %.2f, %.2f)", psl->pfColour[0], psl->pfColour[1], psl->pfColour[2]];
	[desc appendFormat: @", falloff angle: %.2f", psl->fFalloffAngle];
	[desc appendFormat: @", falloff expo: %.2f", psl->fFalloffExponent];
	[desc appendFormat: @", const atten: %.2f", psl->fConstantAttenuation];
	[desc appendFormat: @", linear atten: %.2f", psl->fLinearAttenuation];
	[desc appendFormat: @", quad atten: %.2f", psl->fQuadraticAttenuation];
	[desc appendFormat: @", target index: %i", psl->nIdxTarget];
	return desc;
}

NSString* NSStringFromEPODLight(uint ePODLight) {
	switch (ePODLight) {
		case ePODPoint:
			return @"ePODPoint";
		case ePODDirectional:
			return @"ePODDirectional";
		case ePODSpot:
			return @"ePODSpot";
		default:
			return [NSString stringWithFormat: @"unknown EPODLight (%u)", ePODLight];
	}
}

NSString* NSStringFromSPODMaterial(PODStructPtr pSPODMaterial) {
	SPODMaterial* psm = (SPODMaterial*)pSPODMaterial;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"SPODMaterial named %@", [NSString stringWithUTF8String: psm->pszName]];
	[desc appendFormat: @"\n\tambient: (%.2f, %.2f, %.2f)", psm->pfMatAmbient[0], psm->pfMatAmbient[1], psm->pfMatAmbient[2]];
	[desc appendFormat: @", diffuse: (%.2f, %.2f, %.2f)", psm->pfMatDiffuse[0], psm->pfMatDiffuse[1], psm->pfMatDiffuse[2]];
	[desc appendFormat: @", specular: (%.2f, %.2f, %.2f)", psm->pfMatSpecular[0], psm->pfMatSpecular[1], psm->pfMatSpecular[2]];
	[desc appendFormat: @", opacity: %.2f", psm->fMatOpacity];
	[desc appendFormat: @", shininess: %.2f", psm->fMatShininess];
	[desc appendFormat: @"\n\tsrc RGB blend: %@", NSStringFromEPODBlendFunc(psm->eBlendSrcRGB)];
	[desc appendFormat: @", src alpha blend: %@", NSStringFromEPODBlendFunc(psm->eBlendSrcA)];
	[desc appendFormat: @"\n\tdest RGB blend: %@", NSStringFromEPODBlendFunc(psm->eBlendDstRGB)];
	[desc appendFormat: @", dest alpha blend: %@", NSStringFromEPODBlendFunc(psm->eBlendDstA)];
	[desc appendFormat: @"\n\toperation RGB blend: %@", NSStringFromEPODBlendOp(psm->eBlendOpRGB)];
	[desc appendFormat: @", operation alpha blend: %@", NSStringFromEPODBlendOp(psm->eBlendOpA)];
	[desc appendFormat: @"\n\tblend color: (%.2f, %.2f, %.2f, %.2f)", psm->pfBlendColour[0], psm->pfBlendColour[1], psm->pfBlendColour[2], psm->pfBlendColour[3]];
	[desc appendFormat: @", blend factor: (%.2f, %.2f, %.2f, %.2f)", psm->pfBlendFactor[0], psm->pfBlendFactor[1], psm->pfBlendFactor[2], psm->pfBlendFactor[3]];
	[desc appendFormat: @"\n\ttexture indices: (diffuse: %i", psm->nIdxTexDiffuse];
	[desc appendFormat: @", ambient: %i", psm->nIdxTexAmbient];
	[desc appendFormat: @", ambient: %i", psm->nIdxTexAmbient];
	[desc appendFormat: @", specular color: %i", psm->nIdxTexSpecularColour];
	[desc appendFormat: @", specular level: %i", psm->nIdxTexSpecularLevel];
	[desc appendFormat: @", bump: %i", psm->nIdxTexBump];
	[desc appendFormat: @", emissive: %i", psm->nIdxTexEmissive];
	[desc appendFormat: @", gloss: %i", psm->nIdxTexGlossiness];
	[desc appendFormat: @", opacity: %i", psm->nIdxTexOpacity];
	[desc appendFormat: @", reflection: %i", psm->nIdxTexReflection];
	[desc appendFormat: @", refraction: %i)", psm->nIdxTexRefraction];
	[desc appendFormat: @"\n\tflags: %i", psm->nFlags];
	[desc appendFormat: @", effect %@ in file %@",
			(psm->pszEffectName ? [NSString stringWithUTF8String: psm->pszEffectName] : @"none"),
			(psm->pszEffectFile ? [NSString stringWithUTF8String: psm->pszEffectFile] : @"none")];
	
	return desc;
}

GLenum GLBlendFuncFromEPODBlendFunc(uint ePODBlendFunc) {
	switch (ePODBlendFunc) {
		case ePODBlendFunc_ZERO:
		case ePODBlendFunc_ONE:
		case ePODBlendFunc_SRC_COLOR:
		case ePODBlendFunc_ONE_MINUS_SRC_COLOR:
		case ePODBlendFunc_SRC_ALPHA:
		case ePODBlendFunc_ONE_MINUS_SRC_ALPHA:
		case ePODBlendFunc_DST_ALPHA:
		case ePODBlendFunc_ONE_MINUS_DST_ALPHA:
		case ePODBlendFunc_DST_COLOR:
		case ePODBlendFunc_ONE_MINUS_DST_COLOR:
		case ePODBlendFunc_SRC_ALPHA_SATURATE:
			return (GLenum)ePODBlendFunc;
		default:
			LogError(@"Unknown EPODBlendFunc %u", ePODBlendFunc);
			return GL_ONE;
	}
}

NSString* NSStringFromEPODBlendFunc(uint ePODBlendFunc) {
	switch (ePODBlendFunc) {
		case ePODBlendFunc_ZERO:
			return @"ePODBlendFunc_ZERO";
		case ePODBlendFunc_ONE:
			return @"ePODBlendFunc_ONE";
		case ePODBlendFunc_BLEND_FACTOR:
			return @"ePODBlendFunc_BLEND_FACTOR";
		case ePODBlendFunc_ONE_MINUS_BLEND_FACTOR:
			return @"ePODBlendFunc_ONE_MINUS_BLEND_FACTOR";
		case ePODBlendFunc_SRC_COLOR:
			return @"ePODBlendFunc_SRC_COLOR";
		case ePODBlendFunc_ONE_MINUS_SRC_COLOR:
			return @"ePODBlendFunc_ONE_MINUS_SRC_COLOR";
		case ePODBlendFunc_SRC_ALPHA:
			return @"ePODBlendFunc_SRC_ALPHA";
		case ePODBlendFunc_ONE_MINUS_SRC_ALPHA:
			return @"ePODBlendFunc_ONE_MINUS_SRC_ALPHA";
		case ePODBlendFunc_DST_ALPHA:
			return @"ePODBlendFunc_DST_ALPHA";
		case ePODBlendFunc_ONE_MINUS_DST_ALPHA:
			return @"ePODBlendFunc_ONE_MINUS_DST_ALPHA";
		case ePODBlendFunc_DST_COLOR:
			return @"ePODBlendFunc_DST_COLOR";
		case ePODBlendFunc_ONE_MINUS_DST_COLOR:
			return @"ePODBlendFunc_ONE_MINUS_DST_COLOR";
		case ePODBlendFunc_SRC_ALPHA_SATURATE:
			return @"ePODBlendFunc_SRC_ALPHA_SATURATE";
		case ePODBlendFunc_CONSTANT_COLOR:
			return @"ePODBlendFunc_CONSTANT_COLOR";
		case ePODBlendFunc_ONE_MINUS_CONSTANT_COLOR:
			return @"ePODBlendFunc_ONE_MINUS_CONSTANT_COLOR";
		case ePODBlendFunc_CONSTANT_ALPHA:
			return @"ePODBlendFunc_CONSTANT_ALPHA";
		case ePODBlendFunc_ONE_MINUS_CONSTANT_ALPHA:
			return @"ePODBlendFunc_ONE_MINUS_CONSTANT_ALPHA";
		default:
			return [NSString stringWithFormat: @"unknown EPODBlendFunc (%u)", ePODBlendFunc];
	}
}

NSString* NSStringFromEPODBlendOp(uint ePODBlendOp) {
	switch (ePODBlendOp) {
		case ePODBlendOp_ADD:
			return @"ePODBlendOp_ADD";
		case ePODBlendOp_MIN:
			return @"ePODBlendOp_MIN";
		case ePODBlendOp_MAX:
			return @"ePODBlendOp_MAX";
		case ePODBlendOp_SUBTRACT:
			return @"ePODBlendOp_SUBTRACT";
		case ePODBlendOp_REVERSE_SUBTRACT:
			return @"ePODBlendOp_REVERSE_SUBTRACT";
		default:
			return [NSString stringWithFormat: @"unknown EPODBlendOp (%u)", ePODBlendOp];
	}
}

NSString* NSStringFromSPODTexture(PODStructPtr pSPODTexture) {
	SPODTexture* pst = (SPODTexture*)pSPODTexture;
	return [NSString stringWithFormat: @"\nSPODTexture filename %@",
			[NSString stringWithUTF8String: pst->pszName]];
}


