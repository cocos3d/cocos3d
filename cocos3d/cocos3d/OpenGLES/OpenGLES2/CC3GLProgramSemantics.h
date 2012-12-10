/*
 * CC3GLProgramSemantics.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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


@class CC3GLSLUniform, CC3GLSLAttribute, CC3NodeDrawingVisitor;

/**
 * Indicates the semantic usage for a particular vertex array type.
 *
 * Under OpenGL ES 2, these values are used to match a vertex array to its semantic usage
 * within a GLSL vertex shader.
 *
 * The semantic value kCC3VertexContentSemanticAppBase and kCC3VertexContentSemanticMax define
 * a range of values that can be used by the application to match custom app-specific semantics.
 * The framework will not automatically assign or use values within this range, so it can be
 * used by the app to indicate an app-specific semantic usage.
 */
typedef enum {
	kCC3VertexContentSemanticNone = 0,		/**< No defined semantic usage. */
	kCC3VertexContentSemanticLocations,		/**< Vertex locations. */
	kCC3VertexContentSemanticNormals,		/**< Vertex normals. */
	kCC3VertexContentSemanticColors,		/**< Vertex colors. */
	kCC3VertexContentSemanticPointSizes,	/**< Vertex point sizes. */
	kCC3VertexContentSemanticWeights,		/**< Vertex skinning weights. */
	kCC3VertexContentSemanticMatrices,		/**< Vertex skinning matrices. */
	kCC3VertexContentSemanticTexture0,		/**< Vertex texture coordinates for texture unit 0. */
	kCC3VertexContentSemanticTexture1,		/**< Vertex texture coordinates for texture unit 1. */
	kCC3VertexContentSemanticTexture2,		/**< Vertex texture coordinates for texture unit 2. */
	kCC3VertexContentSemanticTexture3,		/**< Vertex texture coordinates for texture unit 3. */
	kCC3VertexContentSemanticTexture4,		/**< Vertex texture coordinates for texture unit 4. */
	kCC3VertexContentSemanticTexture5,		/**< Vertex texture coordinates for texture unit 5. */
	kCC3VertexContentSemanticTexture6,		/**< Vertex texture coordinates for texture unit 6. */
	kCC3VertexContentSemanticTexture7,		/**< Vertex texture coordinates for texture unit 7. */
	kCC3VertexContentSemanticAppBase,		/**< First semantic of app-specific custom semantics. */
	kCC3VertexContentSemanticMax = 0xFF		/**< The maximum value for an app-specific custom semantic. */
} CC3VertexContentSemantic;


typedef enum {
	kCC3StateSemanticNone = 0,						/**< No defined semantic usage. */
	kCC3StateSemanticModelMatrix,					/**< Current model-to-world matrix. */
	kCC3StateSemanticModelMatrixInv,				/**< Inverse of current model-to-world matrix. */
	kCC3StateSemanticViewMatrix,					/**< Camera view matrix. */
	kCC3StateSemanticViewMatrixInv,					/**< Inverse of camera view matrix. */
	kCC3StateSemanticModelViewMatrix,				/**< Current modelview matrix. */
	kCC3StateSemanticModelViewMatrixInv,			/**< Inverse of current modelview matrix. */
	kCC3StateSemanticProjMatrix,					/**< Camera projection matrix. */
	kCC3StateSemanticProjMatrixInv,					/**< Inverse of camera projection matrix. */
	kCC3StateSemanticModelViewProjMatrix,			/**< Current modelview-projection matrix. */
	kCC3StateSemanticModelViewProjMatrixInv,		/**< Inverse of current modelview-projection matrix. */
	
	kCC3StateSemanticMaterialColorAmbient,			/**< Ambient color of the material. */
	kCC3StateSemanticMaterialColorDiffuse,			/**< Diffuse color of the material. */
	kCC3StateSemanticMaterialColorSpecular,			/**< Specular color of the material. */
	kCC3StateSemanticMaterialColorEmission,			/**< Emission color of the material. */
	kCC3StateSemanticMaterialOpacity,				/**< Opacity of the material. */
	kCC3StateSemanticMaterialShininess,				/**< Shininess of the material. */
	
	
	kCC3StateSemanticAppBase,					/**< First semantic of app-specific custom semantics. */
	kCC3StateSemanticMax = 0xFFFF				/**< The maximum value for an app-specific custom semantic. */
} CC3StateSemantic;

/** Returns a string representation of the specified vertex content semantic. */
NSString* NSStringFromCC3VertexContentSemantic(CC3VertexContentSemantic semantic);

/** Returns a string representation of the specified state semantic. */
NSString* NSStringFromCC3StateSemantic(CC3StateSemantic semantic);


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegate protocol

/**
 * Defines the behaviour required for an object that manages the semantics for a CC3GLProgram.
 *
 * Each CC3GLProgram delegates to an object that implements this protocol when it needs to
 * populate the current value of a uniform variable from content within the 3D scene.
 */
@protocol CC3GLProgramSemanticsDelegate <NSObject>

/**
 * Assigns the semantic property for the specified uniform.
 *
 * Implementers should attempt to match the specified uniform variable with a semantic and,
 * if found, should set the semantic property on the uniform variable, and return YES. If an
 * impementation cannot determine the appropriate semantic, it should avoid setting the semantic
 * property of the uniform and should return NO.
 *
 * Returns whether the semantic could be assigned. When delegating to superclasses or other
 * delegates, implementers can use this return code to determine whether or not to continue
 * attempting to determine the semantic for the specified variable.
 *
 * This method is invoked automatically after the GLSL program has been compiled and linked.
 */
-(BOOL) assignUniformSemantic: (CC3GLSLUniform*) uniform;

/** 
 * Assigns the semantic property for the specified attribute.
 *
 * Implementers should attempt to match the specified attribute variable with a semantic and,
 * if found, should set the semantic property on the attribute variable, and return YES. If an
 * impementation cannot determine the appropriate semantic, it should avoid setting the semantic
 * property of the attribute and should return NO.
 *
 * Returns whether the semantic could be assigned. When delegating to superclasses or other
 * delegates, implementers can use this return code to determine whether or not to continue
 * attempting to determine the semantic for the specified variable.
 *
 * The value set into the semantic property must follow the guidelines described
 * in the notes for the CC3VertexContentSemantic enumeration.
 *
 * This method is invoked automatically after the GLSL program has been compiled and linked.
 */
-(BOOL) assignAttributeSemantic: (CC3GLSLAttribute*) attribute;

/**
 * Populates the specified uniform.
 *
 * The semantic property of the specified uniform can be used to determine what content is
 * expected by the GLSL program for that uniform. The implementor then retrieves the required
 * content from the GL state caches found via the CC3OpenGLESEngine state machine structures,
 * or from the scene content accessed via the specified visitor.
 *
 * In the specified visitor, the camera property contains the active camera, the currentNode
 * property contains the node currently being drawn, the startingNode property contains the
 * CC3Scene, and the textureUnitCount property contains the number of texture units being
 * drawn for the current node.
 *
 * Implementers of this method can use the various set... methods on the specified uniform
 * to set the content into the specified uniform variable. The implementor does not need to
 * manage the current value of the uniform, as it is managed automatically, and the GL engine
 * is only updated if the value has changed.
 *
 * Implementers should return YES if a value was set into the specified uniform variable,
 * and NO if otherwise. When delegating to superclasses or other delegates, implementers
 * can use this return code to determine whether or not to continue attempting to determine
 * and set the value of the uniform variable.
 *
 * This method is invoked automatically on every rendering loop. Keep it tight.
 */
-(BOOL) populateUniform: (CC3GLSLUniform*) uniform withVisitor: (CC3NodeDrawingVisitor*) visitor;

/** Returns a string description of the specified uniform semantic. */
-(NSString*) nameOfUniformSemantic: (GLenum) semantic;

/** Returns a string description of the specified attribute semantic. */
-(NSString*) nameOfAttributeSemantic: (GLenum) semantic;

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateBase

/**
 * CC3GLProgramSemanticsDelegateBase is an abstract implementation of the CC3GLProgramSemanticsDelegate
 * protocol, that retrieves common uniform values from the scene based on those semantics.
 *
 * This implementation does not provide any behaviour for the assignUniformSemantic: and
 * assignAttributeSemantic:. Both method implementations do nothing, and always return NO.
 *
 * This implementation can be used as a superclass for other implementations. Semantic assigment
 * heuristics may be radically different across implementations, but there is much commonality in
 * the retrieval and assignement of uniform variables using the populateUniform:withVisitor: method.
 * In many cases, subclassing this implementation, and using the inherited populateUniform:withVisitor:
 * method, possibly overriding to provide additional variable assignment behaviour, can provide
 * significant useful functionality.
 */
@interface CC3GLProgramSemanticsDelegateBase : NSObject<CC3GLProgramSemanticsDelegate> {
}

/** Allocates and initializes an autoreleased instance. */
+(id) semanticsDelegate;

@end


#pragma mark -
#pragma mark CC3GLProgramSemanticsDelegateByVarNames

/**
 * CC3GLProgramSemanticsDelegateByVarNames extends CC3GLProgramSemanticsDelegateBase to add
 * the assignment of semantics to uniform and attribute variables based on matching specific
 * variable names within the GLSL source code.
 *
 * Since the semantics are determined by GLSL variable name, it is critical that the GLSL shader
 * code use very specific attribute and uniform variable names.
 */
@interface CC3GLProgramSemanticsDelegateByVarNames : CC3GLProgramSemanticsDelegateBase {
}

@end

/**
 * Convenience macro for testing and setting a semantic in a CC3GLSLVariable.
 *
 * Given a CC3GLSLVariable "variable", If the variable's name matches "name", the variable's
 * semantic property is set to "sem", and returns YES all the way out of the method or function
 * that invokes this macro (this last part is why this is a macro and not an inline).
 */
#define CC3SetSemantic(_name, _sem)						\
	if ( [variable.name isEqualToString: (_name)] ) {	\
		variable.semantic = (_sem);						\
		return YES;										\
	}
