/*
 * CC3ModelSampleFactory.h
 *
 * cocos3d 0.7.2
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


#import "CC3VertexArrayMesh.h"
#import "CC3MeshNode.h"


/**
 * CC3ModelSampleFactory is a convenience utility for creating sample 3D models
 * for experimentation.
 * 
 * The design pattern is a singleton factory object, with methods for creating
 * instances of various 3D models.
 *
 * Access to the factory instance is through the factory class method.
 *
 * This class should be considered for testing and experimental use only.
 * Unless you really need teapots in your application, there is no need to include
 * this class, or the teapot.h data header file, in any finished application.
 * Doing so will just bloat the size of the application unnecessarily.
 */
@interface CC3ModelSampleFactory : NSObject {
	CC3VertexLocations* teapotVertexLocations;
	CC3VertexNormals* teapotVertexNormals;
	CC3VertexIndices* teapotVertexIndices;
	CC3VertexTextureCoordinates* teapotVertexTextureCoordinates;
	CC3VertexColors* teapotVertexColors;
	CC3VertexArrayMesh* texturedTeapotMesh;
	CC3VertexArrayMesh* multicoloredTeapotMesh;
	CC3VertexArrayMesh* unicoloredTeapotMesh;
}

/** Returns the singleton instance. */
+(CC3ModelSampleFactory*) factory;

/** An instance of a teapot mesh that includes a texture coordinate map. */
@property(nonatomic, readonly) CC3VertexArrayMesh* texturedTeapotMesh;

/** An instance of a teapot mesh that will be covered in a single color. */
@property(nonatomic, readonly) CC3VertexArrayMesh* unicoloredTeapotMesh;

/** An instance of a teapot mesh that includes a vertex color array. */
@property(nonatomic, readonly) CC3VertexArrayMesh* multicoloredTeapotMesh;

#pragma mark Factory methods

/** Returns an allocated, initialized, autoreleased instance of a teapot in a particular color. */
-(CC3MeshNode*) makeUniColoredTeapotNamed: (NSString*) aName withColor: (ccColor4F) color;

/** Returns an allocated, initialized, autoreleased instance of a teapot  painted with a funky color gradient. */
-(CC3MeshNode*) makeMultiColoredTeapotNamed: (NSString*) aName;

/** Returns an allocated, initialized, autoreleased instance of a teapot in a particular color. */
-(CC3MeshNode*) makeLogoTexturedTeapotNamed: (NSString*) aName;


@end
