/*
 * CC3ShaderProgramMatcher.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3ShaderProgram.h"

@class CC3MeshNode, CC3NodeDrawingVisitor;

// Legacy naming support
#define CC3GLProgramMatcher				CC3ShaderProgramMatcher
#define CC3GLProgramMatcherBase			CC3ShaderProgramMatcherBase


#pragma mark -
#pragma mark CC3ShaderProgramMatcher

/**
 * CC3ShaderProgramMatcher describes the behaviour required to match nodes and materials to an
 * appropriate GL program for rendering a particular node.
 *
 * Under OpenGL ES 2, every drawable mesh node requires a CC3ShaderProgram to be rendered. Typically,
 * the application will deliberately assign a specific GL program to each material, through the
 * shaderProgram or shaderContext properties of the material, and in some cases, this may be
 * defined during model loading from resources.
 *
 * When a model is created or loaded without a specific CC3ShaderProgram assigned, the material will retrieve
 * an appropriate default shader from the shader cache. The shader cache maintains an instance of an
 * implementation of this protocol and delegates to it to match the model to a suitable GL program.
 */
@protocol CC3ShaderProgramMatcher <NSObject>

/**
 * Returns a shader program suitable for painting mesh nodes in a solid color.
 *
 * This shader program is used when a mesh node does not have a material, or when
 * painting a mesh node for node picking during user interaction.
 */
@property(nonatomic, retain, readonly) CC3ShaderProgram* pureColorProgram;

/**
 * Returns the shader program to use to draw the specified mesh node.
 *
 * If the specified mesh node does not have a material, the shader identified by the
 * pureColorProgram property is returned.
 *
 * If the specified mesh node has a material that already has a shader program assigned,
 * that shader program is returned. 
 *
 * If the material covering the specified mesh node does not have a shader program assigned
 * already, a shader program is selected, based on the characteristics of the mesh node and
 * the material, the selected shader program is set into the material, and is returned.
 *
 * The returned program will be compiled and linked, and will have a semantics delegate 
 * assigned in the semanticDelegate property.
 *
 * The implementation is responsible for determining how to match the specified mesh node to an
 * appropriate GL program, and each implementations may have a different matching methodology.
 *
 * Implementations are responsible for compiling, linking, and assigning a semantics
 * delegate to the program.
 */
-(CC3ShaderProgram*) programForMeshNode: (CC3MeshNode*) aMeshNode;

/** The semantic delegate that will be attached to any program created by this matcher. */
@property(nonatomic, retain) id<CC3ShaderProgramSemanticsDelegate> semanticDelegate;

@end


#pragma mark -
#pragma mark CC3ShaderProgramMatcherBase

/**
 * CC3ShaderProgramMatcherBase is a basic implementation of the CC3ShaderProgramMatcher protocol.
 *
 * It looks at aspects of the mesh node, such as number of texture units, bump-mapping, etc.
 * To determine the appropriate GL program for a particular mesh node. All programs matched
 * using this implementation will be assigned the semantics delegate from the semanticDelegate
 * property of this instance.
 */
@interface CC3ShaderProgramMatcherBase : NSObject <CC3ShaderProgramMatcher> {
	id<CC3ShaderProgramSemanticsDelegate> _semanticDelegate;
	CC3ShaderProgram* _pureColorProgram;
}

/**
 * Returns a program compiled and linked from the specified vertex and fragment shader files,
 * and attached to the delegate in the semanticDelegate property of this instance.
 *
 * The specified file paths may be either absolute paths, or relative to the application
 * resource directory. If the files are located directly in the application resources
 * directory, the specified file paths can simply be the names of the files.
 *
 * Programs are cached. If the program was already loaded and is in the cache, it is retrieved
 * and returned. If the program has not in the cache, it is loaded, compiled, and linked, placed
 * into the cache, and returned. It is therefore safe to invoke this method any time the program
 * is needed, without having to worry that the program will be repeatedly loaded and compiled
 * from the files.
 *
 * This method is invoked automatically from the programForMeshNode: method when a required
 * program needs to be established.
 */
-(CC3ShaderProgram*) programFromVertexShaderFile: (NSString*) vshFilePath
					   andFragmentShaderFile: (NSString*) fshFilePath;

/**
 * Property that determines the class of GL program to instantiate when required.
 *
 * This property returns the CC3ShaderProgram class. Subclasses may override.
 */
@property(nonatomic, readonly) Class programClass;

@end

