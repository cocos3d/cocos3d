/*
 * NodeGrid.m
 *
 * cocos3d 0.6.4
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file NodeGrid.h for full API documentation.
 */

#import "NodeGrid.h"


@implementation NodeGrid

-(void) populateWith: (CC3Node*) templateNode perSide: (uint) perSideCount {

	[self removeAllChildren];	// Get rid of any existing children

	// To help demonstrate that the hordes of nodes are being managed correctly,
	// log the current number of nodes, before the new nodes have been created.
	LogInfo(@"Before populating %@ with %u copies of %@ there are %i instances of CC3Identifiable subclasses in existance.",
			self, (perSideCount * perSideCount), templateNode, [CC3Identifiable instanceCount]);

	switch (perSideCount) {
		case 0:				// If we don't want any nodes, just leave
			break;
		case 1: {			// For one node, just place the single copy at the origin
			CC3Node* aNode = [templateNode copyAutoreleased];
			aNode.location = kCC3VectorZero;
			aNode.uniformScale *= 2.0;
			[self addChild: aNode];
			break;
		}
		default: {			// Otherwise...lay out a grid of copies
			GLfloat sideLength = 100.0f;
			GLfloat spacing = sideLength / (perSideCount - 1);
			GLfloat xOrg = -sideLength / 2.0f;
			GLfloat zOrg = -sideLength / 2.0f;

			// Scale the node down as the number grows larger, using 3 nodes per side as the standard scale
			GLfloat scaleFactor = 5.0f / (perSideCount * 2 - 1);
			
			// Create many copies (perSideCount ^ 2), and space them out in a grid pattern.
			for (int ix = 0; ix < perSideCount; ix++) {
				for (int iz = 0; iz < perSideCount; iz++) {
					GLfloat xLoc = xOrg + spacing * ix;
					GLfloat zLoc = zOrg + spacing * iz;
					
					CC3Node* aNode = [templateNode copyAutoreleased];
					aNode.location = cc3v(xLoc, 0.0f, zLoc);
					aNode.uniformScale *= scaleFactor;
					[self addChild: aNode];
				}
			}
			break;
		}
	}
	
	[self createGLBuffers];			// Copy vertex data to OpenGL VBO's.
	[self releaseRedundantData];	// Release vertex data from main memory.
	
	// To help demonstrate that the hordes of nodes are being managed correctly,
	// log the current number of nodes, before the new nodes have been created.
	LogInfo(@"After populating %@ there are %i instances of CC3Identifiable subclasses in existance.",
			self, [CC3Identifiable instanceCount]);

}

@end

