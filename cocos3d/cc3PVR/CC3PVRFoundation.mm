/*
 * CC3PVRFoundation.mm
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
	#import "CC3OpenGLFoundation.h"
	#import "CC3Matrix4x4.h"
}
#import "CC3PVRFoundation.h"
#import "CC3PVRTModelPOD.h"
#import "CC3PVRTPFXParser.h"


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
	[desc appendFormat: @", scale: %@", (psn->pfAnimScale ? NSStringFromCC3Vector(*(CC3Vector*)psn->pfAnimScale) : @"none")];
	[desc appendFormat: @", matrix: %@", (psn->pfAnimMatrix ? NSStringFromCC3Matrix4x4((CC3Matrix4x4*)psn->pfAnimMatrix) : @"none")];
	[desc appendFormat: @", %i bytes of user data at %p", psn->nUserDataSize, psn->pUserData];
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
		case EPODDataUBYTE4:
			return GL_UNSIGNED_BYTE;
		case EPODDataShort:
		case EPODDataShortNorm:
			return GL_SHORT;
		case EPODDataUnsignedShort:
		case EPODDataUnsignedShortNorm:
			return GL_UNSIGNED_SHORT;
		default:
			CC3AssertC(NO, @"Unexpected EPVRTDataType '%@'", NSStringFromEPVRTDataType(ePVRTDataType));
			return GL_UNSIGNED_BYTE;
	}
}

BOOL CC3ShouldNormalizeEPVRTDataType(uint ePVRTDataType) {
	switch (ePVRTDataType) {
		case EPODDataByteNorm:
		case EPODDataUnsignedByteNorm:
		case EPODDataShortNorm:
		case EPODDataUnsignedShortNorm:
		case EPODDataARGB:
		case EPODDataRGBA:
			return YES;

		default: return NO;
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
			return GL_TRIANGLES;
	}
}

NSString* NSStringFromSPODCamera(PODStructPtr pSPODCamera) {
	SPODCamera* psc = (SPODCamera*)pSPODCamera;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPODCamera fov: %.2f", psc->fFOV];
	[desc appendFormat: @", near: %.2f", psc->fNear];
	[desc appendFormat: @", far: %.2f", psc->fFar];
	[desc appendFormat: @", target index: %i", psc->nIdxTarget];
	[desc appendFormat: @", FOV is %@animated", (psc->pfAnimFOV ? @"" : @"not ")];
	return desc;
}

NSString* NSStringFromSPODLight(PODStructPtr pSPODLight) {
	SPODLight* psl = (SPODLight*)pSPODLight;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPODLight type: %@", NSStringFromEPODLight(psl->eType)];
	[desc appendFormat: @", color: (%.3f, %.3f, %.3f)", psl->pfColour[0], psl->pfColour[1], psl->pfColour[2]];
	[desc appendFormat: @", falloff angle: %.3f", psl->fFalloffAngle];
	[desc appendFormat: @", falloff expo: %.3f", psl->fFalloffExponent];
	[desc appendFormat: @", const atten: %.3f", psl->fConstantAttenuation];
	[desc appendFormat: @", linear atten: %.3f", psl->fLinearAttenuation];
	[desc appendFormat: @", quad atten: %3f", psl->fQuadraticAttenuation];
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


#pragma mark -
#pragma mark PFX Structures and functions

NSString* NSStringFromSPVRTPFXParserEffect(PFXClassPtr pSPVRTPFXParserEffect) {
	SPVRTPFXParserEffect* pfxEffect = (SPVRTPFXParserEffect*)pSPVRTPFXParserEffect;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"SPVRTPFXParserEffect"];
	[desc appendFormat: @" named %@", [NSString stringWithUTF8String: pfxEffect->Name.c_str()]];
	[desc appendFormat: @"\n\tvertex shader: %@", [NSString stringWithUTF8String: pfxEffect->VertexShaderName.c_str()]];
	[desc appendFormat: @"\n\tfragment shader: %@", [NSString stringWithUTF8String: pfxEffect->FragmentShaderName.c_str()]];
	
	CPVRTArray<SPVRTPFXParserSemantic> attributes = pfxEffect->Attributes;
	GLuint attrCount = attributes.GetSize();
	[desc appendFormat: @"\n\twith %u attributes:", attrCount];
	for(GLuint i = 0; i < attrCount; i++) {
		[desc appendFormat: @"\n\t\t%@:", NSStringFromSPVRTPFXParserSemantic(&attributes[i], @"attribute")];
	}

	CPVRTArray<SPVRTPFXParserSemantic> uniforms = pfxEffect->Uniforms;
	GLuint uniformCount = uniforms.GetSize();
	[desc appendFormat: @"\n\twith %u uniforms:", uniformCount];
	for(GLuint i = 0; i < uniformCount; i++) {
		[desc appendFormat: @"\n\t\t%@:", NSStringFromSPVRTPFXParserSemantic(&uniforms[i], @"uniform")];
	}
	
	CPVRTArray<SPVRTPFXParserEffectTexture> textures = pfxEffect->Textures;
	GLuint texCount = textures.GetSize();
	[desc appendFormat: @"\n\twith %u textures:", texCount];
	for(GLuint i = 0; i < texCount; i++) {
		[desc appendFormat: @"\n\t\t%@:", NSStringFromSPVRTPFXParserEffectTexture(&textures[i])];
	}
	
	CPVRTArray<SPVRTTargetPair> targets = pfxEffect->Targets;
	GLuint targCount = targets.GetSize();
	[desc appendFormat: @"\n\twith %u targets:", targCount];
	for(GLuint i = 0; i < targCount; i++) {
		[desc appendFormat: @"\n\t\ttarget named %@ of type %@",
		 [NSString stringWithUTF8String: targets[i].TargetName.c_str()],
		 [NSString stringWithUTF8String: targets[i].BufferType.c_str()]];
	}

	[desc appendFormat: @"\n\tannotation: %@", [NSString stringWithUTF8String: pfxEffect->Annotation.c_str()]];
	return desc;
}

NSString* NSStringFromSPVRTPFXParserSemantic(PFXClassPtr pSPVRTPFXParserSemantic, NSString* typeName) {
	SPVRTPFXParserSemantic* pfxSemantic = (SPVRTPFXParserSemantic*)pSPVRTPFXParserSemantic;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPVRTPFXParserSemantic"];
	[desc appendFormat: @" for GLSL %@ %@", typeName, [NSString stringWithUTF8String: pfxSemantic->pszName]];
	[desc appendFormat: @" with semantic %@", [NSString stringWithUTF8String: pfxSemantic->pszValue]];
	[desc appendFormat: @" at %u", pfxSemantic->nIdx];
	return desc;
}

NSString* NSStringFromSPVRTPFXParserEffectTexture(PFXClassPtr pSPVRTPFXParserEffectTexture) {
	SPVRTPFXParserEffectTexture* pfxTex = (SPVRTPFXParserEffectTexture*)pSPVRTPFXParserEffectTexture;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPVRTPFXParserEffectTexture"];
	[desc appendFormat: @" named %@", [NSString stringWithUTF8String: pfxTex->Name.c_str()]];
	[desc appendFormat: @" in texture unit %u", pfxTex->nNumber];
	return desc;
}

NSString* NSStringFromSPVRTPFXParserShader(PFXClassPtr pSPVRTPFXParserShader) {
	SPVRTPFXParserShader* pfxShader = (SPVRTPFXParserShader*)pSPVRTPFXParserShader;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPVRTPFXParserShader"];
	[desc appendFormat: @" named %@", [NSString stringWithUTF8String: pfxShader->Name.c_str()]];
	if (pfxShader->bUseFileName) {
		[desc appendFormat: @" from file %@", [NSString stringWithUTF8String: pfxShader->pszGLSLfile]];
	} else {
		[desc appendFormat: @" from embedded GLSL source code"];
	}
	return desc;
}

NSString* NSStringFromSPVRTPFXParserTexture(PFXClassPtr pSPVRTPFXParserTexture) {
	SPVRTPFXParserTexture* pfxTex = (SPVRTPFXParserTexture*)pSPVRTPFXParserTexture;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 150];
	[desc appendFormat: @"SPVRTPFXParserTexture"];
	[desc appendFormat: @" named %@", [NSString stringWithUTF8String: pfxTex->Name.c_str()]];
	[desc appendFormat: @" from file %@", [NSString stringWithUTF8String: pfxTex->FileName.c_str()]];
	[desc appendFormat: @" wrap (S,T,R): (%@, %@, %@)", NSStringFromETextureWrap(pfxTex->nWrapS),
														NSStringFromETextureWrap(pfxTex->nWrapT),
														NSStringFromETextureWrap(pfxTex->nWrapR)];
	[desc appendFormat: @" min: %@", NSStringFromETextureFilter(pfxTex->nMin)];
	[desc appendFormat: @" mag: %@", NSStringFromETextureFilter(pfxTex->nMag)];
	[desc appendFormat: @" mipmap: %@", NSStringFromETextureFilter(pfxTex->nMIP)];
	[desc appendFormat: @" is render target: %@", NSStringFromBoolean(pfxTex->bRenderToTexture)];
	return desc;
}

NSString* NSStringFromSPVRTPFXRenderPass(PFXClassPtr pSPVRTPFXRenderPass) {
	SPVRTPFXRenderPass* pfxPass = (SPVRTPFXRenderPass*)pSPVRTPFXRenderPass;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 100];
	[desc appendFormat: @"SPVRTPFXRenderPass"];
	[desc appendFormat: @" to texture %@", [NSString stringWithUTF8String: pfxPass->pTexture->Name.c_str()]];
	return desc;
}

GLenum GLTextureWrapFromETextureWrap(uint eTextureWrap) {
	switch (eTextureWrap) {
		case eWrap_Clamp:
			return GL_CLAMP_TO_EDGE;
		case eWrap_Repeat:
			return GL_REPEAT;
		default:
			LogError(@"Unknown ETextureWrap '%@'", NSStringFromETextureWrap(eTextureWrap));
			return GL_REPEAT;
	}
}

NSString* NSStringFromETextureWrap(uint eTextureWrap) {
	switch (eTextureWrap) {
		case eWrap_Clamp:
			return @"eWrap_Clamp";
		case eWrap_Repeat:
			return @"eWrap_Repeat";
		default:
			return [NSString stringWithFormat: @"unknown ETextureWrap (%u)", eTextureWrap];
	}
}

GLenum GLMagnifyingFunctionFromETextureFilter(uint eTextureFilter) {
	switch (eTextureFilter) {
		case eFilter_Nearest:
			return GL_NEAREST;
		case eFilter_Linear:
			return GL_LINEAR;
		default:
			LogError(@"Unknown ETextureFilter '%@'", NSStringFromETextureFilter(eTextureFilter));
			return GL_LINEAR;
	}
}

GLenum GLMinifyingFunctionFromMinAndMipETextureFilters(uint minETextureFilter, uint mipETextureFilter) {
	switch(mipETextureFilter) {
			
		case eFilter_Nearest:							// Standard mipmapping
			switch(minETextureFilter) {
				case eFilter_Nearest:
					return GL_NEAREST_MIPMAP_NEAREST;	// Nearest	- std. Mipmap
				case eFilter_Linear:
				default:
					return GL_LINEAR_MIPMAP_NEAREST;	// Bilinear - std. Mipmap
		}

		case eFilter_Linear:							// Trilinear mipmapping
			switch(minETextureFilter) {
				case eFilter_Nearest:
					return GL_NEAREST_MIPMAP_LINEAR;	// Nearest - Trilinear
				case eFilter_Linear:
				default:
					return GL_LINEAR_MIPMAP_LINEAR;		// Bilinear - Trilinear
		}

		case eFilter_None:								// No mipmapping
		default:
			switch(minETextureFilter) {
				case eFilter_Nearest:
					return GL_NEAREST;					// Nearest - no Mipmap
				case eFilter_Linear:
				default:
					return GL_LINEAR;					// Bilinear - no Mipmap
			}
	}
}

NSString* NSStringFromETextureFilter(uint eTextureFilter) {
	switch (eTextureFilter) {
		case eFilter_Nearest:
			return @"eFilter_Nearest";
		case eFilter_Linear:
			return @"eFilter_Linear";
		case eFilter_None:
			return @"eFilter_None";
		default:
			return [NSString stringWithFormat: @"unknown ETextureFilter (%u)", eTextureFilter];
	}
}

