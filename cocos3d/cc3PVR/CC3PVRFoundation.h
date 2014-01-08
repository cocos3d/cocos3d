/*
 * CC3PVRFoundation.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Foundation.h"


#pragma mark -
#pragma mark POD Structures and functions

/** Indicates a POD index that references nil. */
#define kCC3PODNilIndex -1

/**
 * A pointer to a generic C++ structure containing PVR POD data, defined as a void pointer so that
 * it can be imported into header files without the need for the including file to support C++.
 */
typedef void* PODStructPtr;

/**
 * A pointer to a generic C++ class containing PVR POD data, defined as a void pointer so that
 * it can be imported into header files without the need for the including file to support C++.
 */
typedef void* PODClassPtr;

/** Returns a string description of the specified SPODNode structure. */
NSString* NSStringFromSPODNode(PODStructPtr pSPODNode);

/** Returns a string description of the specified SPODMesh structure. */
NSString* NSStringFromSPODMesh(PODStructPtr pSPODMesh);

/** Returns a string description of the specified CPODData structure. */
NSString* NSStringFromCPODData(PODClassPtr aCPODData);

/** Returns a string description of the specified CPVRTBoneBatches structure. */
NSString* NSStringFromCPVRTBoneBatches(PODClassPtr aCPVRTBoneBatches);

/**
 * Maps the specified ePVRTDataType to a valid GL data type, and returns the GL value.
 *
 * Thanks to cocos3d user esmrg who contributed additional type mappings.
 */
GLenum GLElementTypeFromEPVRTDataType(uint ePVRTDataType);

/** 
 * Returns whether the specified is a data type that should be normalized during drawing.
 *
 * Optional vertex content normalization is a property of OpenGL ES 2.0 vertex attributes.
 */
BOOL CC3ShouldNormalizeEPVRTDataType(uint ePVRTDataType);

/**
 * Returns the name of the specified ePVRTDataType enumeration.
 *
 * Thanks to cocos3d user esmrg who contributed additional type mappings.
 */
NSString* NSStringFromEPVRTDataType(uint ePVRTDataType);

/** Extracts and returns the appropriate GL drawing mode from the specified SPODMesh structure. */
GLenum GLDrawingModeForSPODMesh(PODStructPtr aSPODMesh);

/** Returns a string description of the specified SPODMaterial structure. */
NSString* NSStringFromSPODMaterial(PODStructPtr pSPODMaterial);

/** Maps the specified ePODBlendFunc to a valid GL blend function, and returns the GL value. */
GLenum GLBlendFuncFromEPODBlendFunc(uint ePODBlendFunc);

/** Returns the name of the specified ePODBlendFunc enumeration. */
NSString* NSStringFromEPODBlendFunc(uint ePODBlendFunc);

/** Returns the name of the specified ePODBlendOp blend operation. */
NSString* NSStringFromEPODBlendOp(uint ePODBlendOp);

/** Returns a string description of the specified SPODTexture structure. */
NSString* NSStringFromSPODTexture(PODStructPtr pSPODTexture);

/** Returns a string description of the specified SPODCamera structure. */
NSString* NSStringFromSPODCamera(PODStructPtr pSPODCamera);

/** Returns a string description of the specified SPODLight structure. */
NSString* NSStringFromSPODLight(PODStructPtr pSPODLight);

/** Returns the name of the specified ePODLight light type operation. */
NSString* NSStringFromEPODLight(uint ePODLight);


#pragma mark -
#pragma mark PFX Structures and functions

/**
 * A pointer to a generic C++ class containing PVR PFX data, defined as a void pointer so that
 * it can be imported into header files without the need for the including file to support C++.
 */
typedef void* PFXClassPtr;

/** Returns a string description of the specified SPVRTPFXParserEffect class. */
NSString* NSStringFromSPVRTPFXParserEffect(PFXClassPtr pSPVRTPFXParserEffect);

/**
 * Returns a string description of the specified SPVRTPFXParserSemantic class.
 * The typeName is the variable type (typically @"uniform" or @"attribute").
 */
NSString* NSStringFromSPVRTPFXParserSemantic(PFXClassPtr pSPVRTPFXParserSemantic, NSString* typeName);

/** Returns a string description of the specified SPVRTPFXParserEffectTexture class. */
NSString* NSStringFromSPVRTPFXParserEffectTexture(PFXClassPtr pSPVRTPFXParserEffectTexture);

/** Returns a string description of the specified SPVRTPFXParserShader class. */
NSString* NSStringFromSPVRTPFXParserShader(PFXClassPtr pSPVRTPFXParserShader);

/** Returns a string description of the specified SPVRTPFXParserTexture class. */
NSString* NSStringFromSPVRTPFXParserTexture(PFXClassPtr pSPVRTPFXParserTexture);

/** Returns a string description of the specified SPVRTPFXRenderPass class. */
NSString* NSStringFromSPVRTPFXRenderPass(PFXClassPtr pSPVRTPFXRenderPass);

/** Maps the specified ETextureWrap to a valid GL texture wrap, and returns the GL value. */
GLenum GLTextureWrapFromETextureWrap(uint eTextureWrap);

/** Returns the name of the specified ETextureWrap enumeration. */
NSString* NSStringFromETextureWrap(uint eTextureWrap);

/** Maps the specified ETextureFilter to a valid GL texture magnifying function, and returns the GL value. */
GLenum GLMagnifyingFunctionFromETextureFilter(uint eTextureFilter);
	
/** Maps the specified ETextureFilters to a valid GL texture minifying function, and returns the GL value. */
GLenum GLMinifyingFunctionFromMinAndMipETextureFilters(uint minETextureFilter, uint mipETextureFilter);

/** Returns the name of the specified ETextureFilter enumeration. */
NSString* NSStringFromETextureFilter(uint eTextureFilter);

