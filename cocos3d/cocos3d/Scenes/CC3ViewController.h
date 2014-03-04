/*
 * CC3ViewController.h
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

#import "CC3GLView.h"

// The superclass of the CC3ViewController depends on the platform
#if CC3_OGLES_2
#	define CC3VCSuperclass CCDirectorDisplayLink
#endif
#if CC3_OGLES_1
#	define CC3VCSuperclass UIViewController
#endif
#if CC3_OGL
#	define CC3VCSuperclass NSViewController
#endif


#pragma mark -
#pragma mark CC3ViewController interface

/** An instance of CC3ViewController manages the CC3GLView to support the 3D environment. */
@interface CC3ViewController : CC3VCSuperclass {
	CCNode* _controlledNode;
}

/**
 * The CCNode that is being controlled by this controller. This is typically an instance of CCLayer.
 *
 * The application should keep this property synchronized with changes in the running scene of the
 * shared CCDirector.
 */
@property(nonatomic, retain) CCNode* controlledNode;

/**
 * Indicates whether this controller is overlaying the view of the device camera.
 *
 * This base implementation always returns NO, indicating that the device camera is not being
 * displayed, and setting this property has no effect. Subclasses that support device camera
 * overlay can override.
 */
@property(nonatomic, assign) BOOL isOverlayingDeviceCamera;

/** The view of a CC3ViewController must be of type CC3GLView. */
@property(nonatomic, retain) CC3GLView* view;

/**
 * Starts the cocos2d/3d animation.
 *
 * You should invoke this method when the application enters the foreground.
 *
 * Use the stopAnimation method to stop the animation.
 */
-(void) startAnimation;

/**
 * Reduces cocos2d/3d animation to a minimum.
 *
 * Invoke this method when you want to reliquish CPU to perform some other task, such as
 * displaying other views or windows. To ensure a responsive UI, you should invoke this
 * method just before displaying other view components, such as modal or popover controllers.
 *
 * Use the resumeAnimation method to restore the original animation level.
 */
-(void) pauseAnimation;

/**
 * Restores cocos2d/3d animation to its original operating level, after having been
 * temporarily reduced by a prior invocation of the pauseAnimation method.
 */
-(void) resumeAnimation;

/** 
 * Stops the cocos2d/3d animation.
 *
 * You should invoke this method when the application will enter the background.
 *
 * Use the startAnimation method to start the animation again.
 */
-(void) stopAnimation;

/**
 * Terminates the current use of OpenGL by this application.
 *
 * Releases the object in the controlledNode property, releases the view of this controller,
 * ends the CCDirector session, terminates OpenGL and deletes all GL contexts, serving all
 * threads, and clears all caches that contain content that uses OpenGL, including:
 * 	 - CC3Resource
 *   - CC3Texture
 *   - CC3ShaderProgram
 *   - CC3Shader
 *   - CC3ShaderSourceCode
 *
 * You can invoke this method when your app no longer needs support for OpenGL, or will not
 * use OpenGL for a significant amount of time, in order to free up app and OpenGL memory 
 * used by your application.
 *
 * To ensure that that the current GL activity has finished before pulling the rug out from
 * under it, this request is queued for each existing GL context, on the thread for which 
 * the context was created, and will only be executed once any currently running tasks on 
 * the queue have been completed.
 *
 * In addition, once dequeued, a short delay is imposed, before the GL context instance is
 * actually released and deallocated, to provide time for object deallocation and cleanup
 * after the caches have been cleared, and autorelease pools have been drained. The length
 * of this delay may be different for each context instance, and is specified by the
 * CC3OpenGL deletionDelay property of each instance.
 *
 * Since much of the processing of this method is handled through queued operations, as
 * described above, this method will return as soon as the requests are queued, and well
 * before the operations have completed, and OpenGL has been terminated.
 *
 * You can choose to be notified once all operations triggered by this method have completed,
 * and OpenGL has been terminated, by registering a delegate object using the CC3OpenGL 
 * setDelegate: class method. The delegate object will be sent the didTerminateOpenGL method
 * once  all operations triggered by this method have completed, and OpenGL has been terminated.
 * You should use this delegate notification if you intend to make use of OpenGL again, as you
 * must wait for one OpenGL session to terminate before starting another.
 *
 * Note that, in order to ensure that OpenGL is free to shutdown, this method forces the
 * CC3Texture shouldCacheAssociatedCCTextures class-side property to NO, so that any
 * background loading that is currently occurring will not cache cocos2d textures. 
 * If you had set this property to YES, and intend to restart OpenGL at some point, then
 * you might want to set it back to YES before reloading 3D resources again.
 *
 * Use this method with caution, as creating the GL contexts again will require significant overhead.
 */
-(void) terminateOpenGL;

@end

