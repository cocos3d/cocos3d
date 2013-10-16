/******************************************************************************

 @File         PVRTPFXParser.h

 @Title        PVRTPFXParser

 @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Declaration of PFX file parser

******************************************************************************/

#ifndef _PVRTPFXPARSER_H_
#define _PVRTPFXPARSER_H_


/*****************************************************************************
** Includes
******************************************************************************/

#include "PVRTArray.h"
#include "PVRTString.h"
#include "PVRTError.h"
#include "PVRTTexture.h"
#include "PVRTVector.h"
#include "PVRTSkipGraph.h"
#include "PVRTStringHash.h"

/****************************************************************************
** Helper Funcions
****************************************************************************/
void PVRTPFXCreateStringCopy(char** ppDst, const char* pSrc);

/****************************************************************************
** Enumeration
****************************************************************************/
/*!**************************************************************************
@Enum	ESemanticDefaultDataType
@Brief  Enum values for the various variable types supported
****************************************************************************/
enum ESemanticDefaultDataType
{
	eDataTypeMat2,
	eDataTypeMat3,
	eDataTypeMat4,
	eDataTypeVec2,
	eDataTypeVec3,
	eDataTypeVec4,
	eDataTypeIvec2,
	eDataTypeIvec3,
	eDataTypeIvec4,
	eDataTypeBvec2,
	eDataTypeBvec3,
	eDataTypeBvec4,
	eDataTypeFloat,
	eDataTypeInt,
	eDataTypeBool,

	eNumDefaultDataTypes,
	eDataTypeNone,

	// Conceptual data types
	eDataTypeRGB,
	eDataTypeRGBA,
};

/*!**************************************************************************
@Enum   EDefaultDataInternalType
@Brief  Enum values for defining whether a variable is float, interger or bool
****************************************************************************/
enum EDefaultDataInternalType
{
	eFloating,
	eInteger,
	eBoolean
};

/*!**************************************************************************
@enum	EPVRTPFXPassType
@Brief  Decribes the type of render required
****************************************************************************/
enum EPVRTPFXPassType
{
	eNULL_PASS,
	eCAMERA_PASS,
	ePOSTPROCESS_PASS,
	eENVMAPCUBE_PASS,
	eENVMAPSPH_PASS
};

/*!**************************************************************************
@enum	EPVRTPFXPassType
@Brief  Decribes the type of render required
****************************************************************************/
enum EPVRTPFXPassView
{
	eVIEW_CURRENT,			// The scene's active camera is used
	eVIEW_POD_CAMERA,		// The specified camera is used
	eVIEW_NONE				// No specified view
};

/****************************************************************************
** Structures
****************************************************************************/
/*!**************************************************************************
@Struct SPVRTPFXParserHeader
@Brief  Struct for storing PFX file header data
****************************************************************************/
struct SPVRTPFXParserHeader
{
	CPVRTString			Version;
	CPVRTString			Description;
	CPVRTString			Copyright;
};

/*!**************************************************************************
@Struct SPVRTPFXParserTexture
@Brief  Struct for storing PFX data from the texture block
****************************************************************************/
struct SPVRTPFXParserTexture
{
	CPVRTStringHash		Name;
	CPVRTStringHash		FileName;
	bool				bRenderToTexture;
	unsigned int		nMin, nMag, nMIP;
	unsigned int		nWrapS, nWrapT, nWrapR;	// either GL_CLAMP or GL_REPEAT
	unsigned int		uiWidth, uiHeight;
	unsigned int		uiFlags;
};

/*!**************************************************************************
@Struct SPVRTPFXParserEffectTexture
@Brief  Stores effect texture information
****************************************************************************/
struct SPVRTPFXParserEffectTexture
{
	CPVRTStringHash				Name;				// Name of texture.
	unsigned int				nNumber;			// Texture number to set
};

/*!**************************************************************************
@Struct SPVRTPFXParserShader
@Brief  Struct for storing PFX data from the shader block
****************************************************************************/
struct SPVRTPFXParserShader
{
	CPVRTStringHash			Name;
	bool					bUseFileName;
	char*					pszGLSLfile;
	char*					pszGLSLBinaryFile;
	char*					pszGLSLcode;
	char*					pbGLSLBinary;
	unsigned int			nGLSLBinarySize;
	unsigned int			nFirstLineNumber;	// Line number in the text file where this code began; use to correct line-numbers in compiler errors

	SPVRTPFXParserShader();
	~SPVRTPFXParserShader();
	SPVRTPFXParserShader(const SPVRTPFXParserShader& rhs);
	SPVRTPFXParserShader& operator=(const SPVRTPFXParserShader& rhs);

	void Copy(const SPVRTPFXParserShader& rhs);
};

/*!**************************************************************************
@Struct SPVRTSemanticDefaultDataTypeInfo
@Brief  Struct for storing default data types
****************************************************************************/
struct SPVRTSemanticDefaultDataTypeInfo
{
	ESemanticDefaultDataType	eType;
	const char					*pszName;
	unsigned int				nNumberDataItems;
	EDefaultDataInternalType	eInternalType;
};

/*!**************************************************************************
@Struct SPVRTSemanticDefaultData
@Brief  Stores a default value
****************************************************************************/
struct SPVRTSemanticDefaultData
{
	float						pfData[16];
	int							pnData[4];
	bool						pbData[4];
	ESemanticDefaultDataType	eType;

	SPVRTSemanticDefaultData();
	SPVRTSemanticDefaultData(const SPVRTSemanticDefaultData& rhs);
	SPVRTSemanticDefaultData& operator=(const SPVRTSemanticDefaultData& rhs);

	void Copy(const SPVRTSemanticDefaultData& rhs);
};

/*!**************************************************************************
@Struct SPVRTPFXParserSemantic
@Brief  Stores semantic information
****************************************************************************/
struct SPVRTPFXParserSemantic
{
	char						*pszName;				/*!< The variable name as used in the shader-language code */
	char						*pszValue;				/*!< For example: LIGHTPOSITION */
	unsigned int				nIdx;					/*!< Index; for example two semantics might be LIGHTPOSITION0 and LIGHTPOSITION1 */
	SPVRTSemanticDefaultData	sDefaultValue;			/*!< Default value */

	SPVRTPFXParserSemantic();
	~SPVRTPFXParserSemantic();
	SPVRTPFXParserSemantic(const SPVRTPFXParserSemantic& rhs);
	SPVRTPFXParserSemantic& operator=(const SPVRTPFXParserSemantic& rhs);

	void Copy(const SPVRTPFXParserSemantic& rhs);
};


struct SPVRTPFXParserEffect;	// Forward declaration
/*!**************************************************************************
@Struct SPVRTPFXRenderPass
@Brief  Stores render pass information
****************************************************************************/
struct SPVRTPFXRenderPass
{
	EPVRTPFXPassType		eRenderPassType;			// Type of pass.
	EPVRTPFXPassView		eViewType;					// View type.
	PVRTuint32				uiFormatFlags;				// Surface Type.
	SPVRTPFXParserEffect*	pEffect;					// Matched pass. Needed but determined from effect block.
	SPVRTPFXParserTexture*	pTexture;					// The RTT target for this pass.
	CPVRTString				NodeName;					// POD Camera name.
	CPVRTString				SemanticName;				// Name of this pass.
	
	SPVRTPFXRenderPass();
};

/*!**************************************************************************
@Struct SPVRTTargetPair
@Brief  Stores a buffer type and name for a render target.
****************************************************************************/
struct SPVRTTargetPair
{
	CPVRTString				BufferType;
	CPVRTString				TargetName;
};

/*!**************************************************************************
@Struct SPVRTPFXParserEffect
@Brief  Stores effect information
****************************************************************************/
struct SPVRTPFXParserEffect
{
	CPVRTStringHash							Name;
	CPVRTString								Annotation;

	CPVRTStringHash							VertexShaderName;
	CPVRTStringHash							FragmentShaderName;

	CPVRTArray<SPVRTPFXParserSemantic>		Uniforms;
	CPVRTArray<SPVRTPFXParserSemantic>		Attributes;
	CPVRTArray<SPVRTPFXParserEffectTexture>	Textures;
	CPVRTArray<SPVRTTargetPair>				Targets;

	SPVRTPFXParserEffect();
};

/****************************************************************************
** Constants
****************************************************************************/
const PVRTuint32 PVRPFXTEX_COLOUR = PVRTuint32(1<<30);
const PVRTuint32 PVRPFXTEX_DEPTH  = PVRTuint32(1<<31);

const static SPVRTSemanticDefaultDataTypeInfo c_psSemanticDefaultDataTypeInfo[] =
{
	{ eDataTypeMat2,		"mat2",			4,		eFloating },
	{ eDataTypeMat3,		"mat3",			9,		eFloating },
	{ eDataTypeMat4,		"mat4",			16,		eFloating },
	{ eDataTypeVec2,		"vec2",			2,		eFloating },
	{ eDataTypeVec3,		"vec3",			3,		eFloating },
	{ eDataTypeVec4,		"vec4",			4,		eFloating },
	{ eDataTypeIvec2,		"ivec2",		2,		eInteger },
	{ eDataTypeIvec3,		"ivec3",		3,		eInteger },
	{ eDataTypeIvec4,		"ivec4",		4,		eInteger },
	{ eDataTypeBvec2,		"bvec2",		2,		eBoolean },
	{ eDataTypeBvec3,		"bvec3",		3,		eBoolean },
	{ eDataTypeBvec4,		"bvec4",		4,		eBoolean },
	{ eDataTypeFloat,		"float",		1,		eFloating },
	{ eDataTypeInt,			"int",			1,		eInteger },
	{ eDataTypeBool,		"bool",			1,		eBoolean },
};


class CPVRTPFXParserReadContext;

/*!**************************************************************************
@Class CPVRTPFXParser
@Brief PFX parser
****************************************************************************/
class CPVRTPFXParser
{
public:
	/*!***************************************************************************
	@Function			CPVRTPFXParser
	@Description		Sets initial values.
	*****************************************************************************/
	CPVRTPFXParser();

	/*!***************************************************************************
	@Function			~CPVRTPFXParser
	@Description		Frees memory used.
	*****************************************************************************/
	~CPVRTPFXParser();

	/*!***************************************************************************
	@Function			ParseFromMemory
	@Input				pszScript		PFX script
	@Output				pReturnError	error string
	@Return				PVR_SUCCESS for success parsing file
						PVR_FAIL if file doesn't exist or is invalid
	@Description		Parses a PFX script from memory.
	*****************************************************************************/
	EPVRTError ParseFromMemory(const char * const pszScript, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseFromFile
	@Input				pszFileName		PFX file name
	@Output				pReturnError	error string
	@Return				PVR_SUCCESS for success parsing file
						PVR_FAIL if file doesn't exist or is invalid
	@Description		Reads the PFX file and calls the parser.
	*****************************************************************************/
	EPVRTError ParseFromFile(const char * const pszFileName, CPVRTString * const pReturnError);

	/*!***************************************************************************
	 @Function			SetViewportSize
	 @Input				uiWidth				New viewport width
	 @Input				uiHeight			New viewport height
	 @Return			bool				True on success				
	 @Description		Allows the current viewport size to be set. This value
						is used for calculating relative texture resolutions						
	*****************************************************************************/
	bool SetViewportSize(unsigned int uiWidth, unsigned int uiHeight);

	/*!***************************************************************************
	@Function		FindTextureIndex
	@Input			TextureName		The name of the texture to find
	@Input			uiEffect		The effect block to look for the texture in
	@Return			Index in to the effect.Texture array.
	@Description	Returns the index in to the texture array within the effect 
					block where the given texture resides.
	*****************************************************************************/
	unsigned int FindTextureIndex(const CPVRTStringHash& TextureName, unsigned int uiEffect) const;
	
	/*!***************************************************************************
	@Function			RetrieveRenderPassDependencies
	@Output				aRequiredRenderPasses	Dynamic array of required render passes
	@Input				aszActiveEffectStrings	Dynamic array containing names of active
												effects in the application
	@Return				success of failure
	@Description		Takes an array of strings containing the names of active
						effects for this PFX in a given application and then outputs
						an array of the render passes the application needs to perform that is sorted
						into the order they need to be executed (where [0] is the first to be executed,
						and [n] is the last).
						In addition to determining the order of dependent passes
						(such as POSTPROCESS render passes), this function should check if
						CAMERA passes are referenced by active EFFECT blocks and use this information
						to strip redundant passes.
	*****************************************************************************/
	bool RetrieveRenderPassDependencies(CPVRTArray<SPVRTPFXRenderPass*> &aRequiredRenderPasses,
										CPVRTArray<CPVRTStringHash> &aszActiveEffectStrings);

	/*!***************************************************************************
	@Function		GetNumberRenderPasses
	@Return			The number of render passes required
	@Description	Returns the number of render passes within this PFX.
	*****************************************************************************/
	unsigned int GetNumberRenderPasses() const;

	/*!***************************************************************************
	@Function		GetNumberRenderPasses
	@Input			uiIndex				The render pass index.
	@Return			A given render pass.
	@Description	Returns the given render pass.
	*****************************************************************************/
	const SPVRTPFXRenderPass& GetRenderPass(unsigned int uiIndex) const;

	/*!***************************************************************************
	@Function		GetNumberFragmentShaders
	@Return			Number of fragment shaders.
	@Description	Returns the number of fragment shaders referenced in the PFX.
	*****************************************************************************/
	unsigned int GetNumberFragmentShaders() const;

	/*!***************************************************************************
	@Function		GetFragmentShader
	@Input			uiIndex		The index of this shader.
	@Return			The PFX fragment shader.
	@Description	Returns a given fragment shader.
	*****************************************************************************/
	SPVRTPFXParserShader& GetFragmentShader(unsigned int uiIndex);

	/*!***************************************************************************
	@Function		GetNumberVertexShaders
	@Return			Number of vertex shaders.
	@Description	Returns the number of vertex shaders referenced in the PFX.
	*****************************************************************************/
	unsigned int GetNumberVertexShaders() const;

	/*!***************************************************************************
	@Function		GetVertexShader
	@Input			uiIndex		The index of this shader.
	@Return			The PFX vertex shader.
	@Description	Returns a given vertex shader.
	*****************************************************************************/
	SPVRTPFXParserShader& GetVertexShader(unsigned int uiIndex);
 
	/*!***************************************************************************
	@Function		GetNumberEffects
	@Return			Number of effects.
	@Description	Returns the number of effects referenced in the PFX.
	*****************************************************************************/
	unsigned int GetNumberEffects() const;

	/*!***************************************************************************
	@Function		GetEffect
	@Input			uiIndex		The index of this effect.
	@Return			The PFX effect.
	@Description	Returns a given effect.
	*****************************************************************************/
	const SPVRTPFXParserEffect& GetEffect(unsigned int uiIndex) const;

	/*!***************************************************************************
	@Function		FindEffectByName
	@Input			Name		Name of the effect.
	@Return			int	
	@Description	Returns the index of the given string. Returns -1 on failure.
	*****************************************************************************/
	int FindEffectByName(const CPVRTStringHash& Name) const;

	/*!***************************************************************************
	@Function		FindTextureByName
	@Input			Name		Name of the texture.
	@Return			int	
	@Description	Returns the index of the given texture. Returns -1 on failure.
	*****************************************************************************/
	int FindTextureByName(const CPVRTStringHash& Name) const;

	/*!***************************************************************************
	@Function		GetNumberTextures
	@Return			Number of effects.
	@Description	Returns the number of textures referenced in the PFX.
	*****************************************************************************/
	unsigned int GetNumberTextures() const;

	/*!***************************************************************************
	@Function		GetTexture
	@Input			uiIndex		The index of this texture
	@Return			The PFX texture.
	@Description	Returns a given texture.
	*****************************************************************************/
	const SPVRTPFXParserTexture* GetTexture(unsigned int uiIndex) const;

	/*!***************************************************************************
	@Function		GetPFXFileName
	@Return			The filename for this PFX file
	@Description	Returns the PFX file name associated with this object.
	*****************************************************************************/
	const CPVRTString& GetPFXFileName() const;

	/*!***************************************************************************
	@Function		GetPostProcessNames
	@Return			An array of post process names
	@Description	Returns a list of prost process effect names.
	*****************************************************************************/
	const CPVRTArray<CPVRTString>& GetPostProcessNames() const;

public:
	static const unsigned int							VIEWPORT_SIZE;
		
private:	
    SPVRTPFXParserHeader								m_sHeader;

	CPVRTArrayManagedPointers<SPVRTPFXParserTexture>	m_psTexture;
	CPVRTArray<SPVRTPFXParserShader>					m_psFragmentShader;
	CPVRTArray<SPVRTPFXParserShader>					m_psVertexShader;
	CPVRTArray<SPVRTPFXParserEffect>					m_psEffect;
	CPVRTArray<SPVRTPFXRenderPass>						m_RenderPasses;

	CPVRTString											m_szFileName;
	CPVRTPFXParserReadContext*							m_psContext;
	CPVRTArray<CPVRTString>								m_aszPostProcessNames;
	
	unsigned int										m_uiViewportWidth;
	unsigned int										m_uiViewportHeight;
	CPVRTSkipGraphRoot<SPVRTPFXRenderPass*>				m_renderPassSkipGraph;

	/*!***************************************************************************
	@Function			Parse
	@Output				pReturnError	error string
	@Return				true for success parsing file
	@Description		Parses a loaded PFX file.
	*****************************************************************************/
	bool Parse(	CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ReduceWhitespace
	@Output				line		output text
	@Description		Reduces all white space characters in the string to one
						blank space.
	*****************************************************************************/
	void ReduceWhitespace(char *line);

	/*!***************************************************************************
	@Function			GetEndTag
	@Input				pszTagName		tag name
	@Input				nStartLine		start line
	@Output				pnEndLine		line end tag found
	@Return				true if tag found
	@Description		Searches for end tag pszTagName from line nStartLine.
						Returns true and outputs the line number of the end tag if
						found, otherwise returning false.
	*****************************************************************************/
	bool GetEndTag(const char *pszTagName, int nStartLine, int *pnEndLine);

	/*!***************************************************************************
	 @Function			ReturnParameter
	 @Output			aszSourceString		The string to search
	 @Input				parameterTag		The tag to find
	 @Input				delimiter			Delimiters
	 @Return			Found parameter or empty string
	 @Description		Finds the parameter after the specified delimiting character and
						returns the parameter as a string. An empty string is returned
						if a parameter cannot be found
						
	*****************************************************************************/
	CPVRTString FindParameter(char *aszSourceString, const CPVRTString &parameterTag, const CPVRTString &delimiter);

	/*!***************************************************************************
	 @Function			ReadStringToken
	 @Input				pszSource			Parameter string to process
	 @Output			output				Processed string
	 @Output			ErrorStr			String containing errors
	 @Input				iLine				The line to read
	 @Input				pCaller				The caller's name or identifier
	 @Return			Returns true on success
	 @Description		Processes the null terminated char array as if it's a
						formatted string array. Quote marks are determined to be
						start and end of strings. If no quote marks are found the
						string is delimited by whitespace.
	*****************************************************************************/
	bool ReadStringToken(char* pszSource, CPVRTString& output, CPVRTString &ErrorStr, int iLine, const char* pCaller);

	/*!***************************************************************************
	@Function			ParseHeader
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses the HEADER section of the PFX file.
	*****************************************************************************/
	bool ParseHeader(int nStartLine, int nEndLine, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseTextures		** DEPRECATED **
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses the TEXTURES section of the PFX file.
						This style is deprecated but remains for backwards
						compatibility.
	*****************************************************************************/
	bool ParseTextures(int nStartLine, int nEndLine, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseTexture
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses the TEXTURE section of the PFX file.
	*****************************************************************************/
	bool ParseTexture(int nStartLine, int nEndLine, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseTarget
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses the TARGET section of the PFX file.
	*****************************************************************************/
	bool ParseTarget(int nStartLine, int nEndLine, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseGenericSurface
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				Params			Structure containing PFXTexture parameters
	@Output				KnownCmds		An array of unknown commands for the caller
										to check.
	@Input				pCaller			The caller's description for error messages.
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses generic data from TARGET and TEXTURE blocks. Namely
						wrapping and filter commands.
	*****************************************************************************/
	bool ParseGenericSurface(int nStartLine, int nEndLine, SPVRTPFXParserTexture& Params, CPVRTArray<CPVRTHash>& KnownCmds, 
							 const char* pCaller, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseShader
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				pReturnError	error string
	@Output				shader			shader data object
	@Input				pszBlockName	name of block in PFX file
	@Return				true if parse is successful
	@Description		Parses the VERTEXSHADER or FRAGMENTSHADER section of the
						PFX file.
	*****************************************************************************/
	bool ParseShader(int nStartLine, int nEndLine, CPVRTString *pReturnError, SPVRTPFXParserShader &shader, const char * const pszBlockName);

	/*!***************************************************************************
	@Function			ParseSemantic
	@Output				semantic		semantic data object
	@Input				nStartLine		start line number
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses a semantic.
	*****************************************************************************/
	bool ParseSemantic(SPVRTPFXParserSemantic &semantic, const int nStartLine, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function			ParseEffect
	@Output				effect			effect data object
	@Input				nStartLine		start line number
	@Input				nEndLine		end line number
	@Output				pReturnError	error string
	@Return				true if parse is successful
	@Description		Parses the EFFECT section of the PFX file.
	*****************************************************************************/
	bool ParseEffect(SPVRTPFXParserEffect &effect, const int nStartLine, const int nEndLine, CPVRTString * const pReturnError);

	/*!***************************************************************************
	@Function		ParseTextureFlags
	@Input			c_pszRemainingLine		Pointer to the remaining string
	@Output			ppFlagsOut				Resultant flags set
	@Input			uiNumFlags				Number of flags to set
	@Input			c_ppszFlagNames			Flag names			
	@Input			uiNumFlagNames			Number of flag names
	@Input			pReturnError			Return error to set
	@Input			iLineNum				The line number for error reporting
	@Return			true if successful
	@Description	Parses the texture flag sections.
	*****************************************************************************/
	bool ParseTextureFlags(	const char* c_pszRemainingLine, unsigned int** ppFlagsOut, unsigned int uiNumFlags, const char** c_ppszFlagNames, unsigned int uiNumFlagNames, 
							CPVRTString * const pReturnError, int iLineNum);
	/*!***************************************************************************
	 @Function		DetermineRenderPassDependencies
	 @Output			pReturnError
	 @Return		True if dependency tree is valid. False if there are errors
					in the dependency tree (e.g. recursion)
	 @Description	Looks through all of the effects in the .pfx and determines
					the order of render passes that have been declared with
					the RENDER tag (found in [TEXTURES]. 
	*****************************************************************************/
	bool DetermineRenderPassDependencies(CPVRTString * const pReturnError);

	/*!***************************************************************************
	 @Function		AddRenderPassNodeDependancies
	 @Input			aRequiredRenderPasses
	 @Input			renderPassNode
	 @Description	Recursively look through dependencies until leaf nodes are
					encountered. At this point, add a given leaf node to the
					aRequiredRenderPasses array and return. Repeat this process
					until all dependencies are added to the array.
	*****************************************************************************/
	void AddRenderPassNodeDependencies(	CPVRTArray<SPVRTPFXRenderPass*> &aRequiredRenderPasses,
										CPVRTSkipGraphNode<SPVRTPFXRenderPass*> &renderPassNode);
};


#endif /* _PVRTPFXPARSER_H_ */

/*****************************************************************************
 End of file (PVRTPFXParser.h)
*****************************************************************************/

