/*
 * CC3PerformanceLayer.h
 *
 * Cocos3D 2.0.2
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


#import "CC3Layer.h"
#import "Joystick.h"
#import "CCNodeAdornments.h"

// In Cocos2D v1 & v2, buttons are actually menu items
#if CC3_CC2_CLASSIC
#	define CC_BUTTON_CLASS		AdornableMenuItemImage
#else
#	define CC_BUTTON_CLASS		AdornableButton
#endif	// CC3_CC2_CLASSIC

/**
 * This application-specific CC3Scene provides a platform for testing and displaying
 * various performance-related aspects of Cocos3D.
 *
 * Using buttons, the user can select one of various node types, and determine how
 * many copies of that node should be added to the 3D scene. Those copies are laid
 * out in a square grid within the scene. This app then collects various statistics
 * about the performance of the 3D scene. This customized CC3Layer extracts these
 * statistics and display them in real-time.
 *
 * Using another button, the user can also select whether the nodes in the scene are
 * animated or not. Animating the nodes adds load because the globalTransformMatrix
 * of each node must be updated during each update.
 *
 * This layer displays the following performance statistics:
 *
 * Drawing:
 *   - frames per second
 *   - count of nodes visited during drawing per frame
 *   - count of nodes drawn per frame
 *   - count of GL draw calls made to the GL engine per frame
 *   - count of primitive faces presented to the GL engine per frame
 *
 * Updating:
 *   - updates per second
 *   - count of nodes updated per update pass
 *   - count of nodes whose globalTransformMatrix was recalculated per update pass
 *
 * There are also two joystick controls that allow the user to control the 3D camera.
 * By moving the camera, the user can move some of the coped nodes out of view, and
 * can see the impact it makes on drawing performance, as those nodes are culled,
 * and not presented to the GL engine for drawing.
 */
@interface CC3PerformanceLayer : CC3Layer {
	Joystick* _directionJoystick;
	Joystick* _locationJoystick;
	CC_BUTTON_CLASS* _increaseNodesButton;
	CC_BUTTON_CLASS* _decreaseNodesButton;
	CC_BUTTON_CLASS* _nextNodeTypeButton;
	CC_BUTTON_CLASS* _prevNodeTypeButton;
	CC_BUTTON_CLASS* _animateNodesButton;
	CCLabelBMFont* _nodeNameLabel;
	CCLabelBMFont* _updateTitleLabel;
	CCLabelBMFont* _updateRateLabel;
	CCLabelBMFont* _nodesUpdatedLabel;
	CCLabelBMFont* _nodesTransformedLabel;
	CCLabelBMFont* _drawingTitleLabel;
	CCLabelBMFont* _frameRateLabel;
	CCLabelBMFont* _nodesVisitedForDrawingLabel;
	CCLabelBMFont* _nodesDrawnLabel;
	CCLabelBMFont* _drawCallsLabel;
	CCLabelBMFont* _facesPresentedLabel;
}

@end
