/*
 * CC3GLProgramMatchers.h
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

#import "CC3GLProgram.h"

@class CC3MeshNode, CC3NodeDrawingVisitor;


#pragma mark -
#pragma mark CC3GLProgramMatcher

/**
 * CC3GLProgramMatcher describes the behaviour required to match nodes and materials to an
 * appropriate GL program for rendering a particular node.
 *
 * Under OpenGL ES 2, every drawable mesh node requires a CC3GLProgram to be rendered. Typically,
 * the application will deliberately assign a specific GL program to each material, through the
 * shaderProgram or shaderContext properties of the material, and in some cases, this may be
 * defined during model loading from resources.
 *
 * When a model is created or loaded without a specific CC3GLProgram assigned, the material will retrieve
 * an appropriate default shader from the shader cache. The shader cache maintains an instance of an
 * implementation of this protocol and delegates to it to match the model to a suitable GL program.
 */
@protocol CC3GLProgramMatcher <NSObject>

/**
 * Returns the CC3GLProgram to use for the specified mesh node. The application can use this as
 * a convenient way to determine a suitable program to attach to the material of each mesh node.
 *
 * The returned program will be compiled and linked, and will have a semantics delegate assigned
 * in the semanticDelegate property.
 *
 * The implementation is responsible for determining how to match the specified mesh node to an 
 * appropriate GL program, and each implementations may have a different matching methodology.
 *
 * This method does not have each access to scene content such as lighting conditions. Because of
 * this, the application may choose to avoid using this method, and allow a suitable program to
 * be selected by the programForVisitor: method. 
 *
 * Implementations are also responsible for compiling, linking, and assigning a semantics
 * delegate to the program.
 */
-(CC3GLProgram*) programForMeshNode: (CC3MeshNode*) aMeshNode;

/**
 * Returns the CC3GLProgram to use for the specified node drawing visitor.
 *
 * The returned program will be compiled and linked, and will have a semantics delegate
 * assigned in the semanticDelegate property.
 *
 * Implementations are responsible for selecting the appropriate GL program for the current
 * state of the specified visitor. The implementation can query the visitor for current state
 * such as the currentMaterial, currentMeshNode, lightCount, or shouldDecorateNode properties,
 * etc, to determine the appropriate program to return.
 *
 * This method is invoked automatically the first time a mesh node is rendered if it does not
 * have a program assigned to its material. Since the attached visitor has access to scene state,
 * in addition to information about the mesh node, the application may choose to skip setting the
 * program into the mesh node material at initialization time, and may instead allow this method
 * to determine the most suitable program the first time the node is rendered.
 *
 * Implementations are also responsible for compiling, linking, and assigning a semantics
 * delegate to the program.
 */
-(CC3GLProgram*) programForVisitor: (CC3NodeDrawingVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3GLProgramMatcherBase

/**
 * CC3GLProgramMatcherBase is a basic implementation of the CC3GLProgramMatcher protocol.
 *
 * It looks at aspects of the mesh node, such as number of texture units, bump-mapping, etc.
 * To determine the appropriate GL program for a particular mesh node. All programs matched
 * using this implementation will be assigned the semantics delegate from the semanticDelegate
 * property of this instance.
 */
@interface CC3GLProgramMatcherBase : NSObject <CC3GLProgramMatcher> {
	id<CC3GLProgramSemanticsDelegate> _semanticDelegate;
	CC3GLProgram* _pureColorProgram;
}

/**
 * Returns a program compiled from the specified vertex and fragment shader files.
 *
 * The program name is constructed from the vertex and fragment shader filenames using the
 * programNameFromVertexShaderFile:andFragmentShaderFile: method of the class in the
 * glProgramClass property, and the program is retrieved from the program cache on that class.
 *
 * If a program with that name has not yet been cached, and instance of the program class is
 * created and compiled from the two shader files, the shaderDelegate property of the program
 * is set to the semanticDelegate property of this instance, the program is linked, and added
 * to the cache in the program class.
 *
 * This method is invoked automatically from the programForMeshNode: method when a required
 * program needs to be established. Generally, this instance caches the resulting program
 * each time this method is invoked, so it is only invoked once for any particular pair of
 * vertex and fragment shader filenames.
 */
-(CC3GLProgram*) programFromVertexShaderFile: (NSString*) vshFilename
					   andFragmentShaderFile: (NSString*) fshFilename;

/**
 * Property that determines the class of GL program to instantiate when required.
 *
 * This property returns the CC3GLProgram class. Subclasses may override.
 */
@property(nonatomic, readonly) Class programClass;

/**
 * The semantic delegate that will be attached to any program created by this instance.
 *
 * This initial value of this property is set to an instance of CC3GLProgramSemanticsByVarName.
 */
@property(nonatomic, retain) id<CC3GLProgramSemanticsDelegate> semanticDelegate;

@end

