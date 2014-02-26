/*
 * CC3CC2Extensions.h
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


/* Base library of extensions to cocos2d to support cocos3d. */

#import "CC3OSExtensions.h"
#import "CCTextureCache.h"

#if !(CC3_CC2_1 || CC3_CC2_2)
#	import "CCNode_Private.h"
#	import "CCDirector_Private.h"
#	import "CCTexture_Private.h"
#endif

#pragma mark -
#pragma mark CCGLView & CC3GLView

// Backwards compatibility to renamed Cocos2D entities
#if (CC3_CC2_1 || CC3_CC2_2)
typedef ccTime CCTime;
#define CCTexture CCTexture2D
#define viewSizeInPixels winSizeInPixels
#endif

#if !(CC3_CC2_1 || CC3_CC2_2)
@protocol CCRGBAProtocol <NSObject>
@end
#define CCLayer CCNode
#endif

#if CC3_IOS

/** Under cocos2d 1.x iOS, create an alias CCGLView for EAGLView. */
#if CC3_CC2_1
#	define CCGLView EAGLView
#endif	// CC3_CC2_1


/** Extension to support cocos3d functionality. */
@interface CCGLView (CC3)

/** Initializes this instance with the specified characteristics. */
-(id) initWithFrame: (CGRect) frame
		pixelFormat: (NSString*) colorFormat
		depthFormat: (GLenum) depthFormat
 preserveBackbuffer: (BOOL) isRetained
	numberOfSamples: (GLuint) sampleCount;

/** Allocates and initializes an instance with the specified characteristics. */
+(id) viewWithFrame: (CGRect) frame
		pixelFormat: (NSString*) colorFormat
		depthFormat: (GLenum) depthFormat
 preserveBackbuffer: (BOOL) isRetained
	numberOfSamples: (GLuint) sampleCount;

@end
#endif	// CC3_IOS

/** Add state caching aliases for compatiblity with 2.1 and above */
#if CC3_CC2_2 && COCOS2D_VERSION < 0x020100
#	define ccGLBindTexture2DN(texUnit, texID)		\
	ccGLActiveTexture(GL_TEXTURE0 + (texUnit));		\
	ccGLBindTexture2D(texID);
#endif

/** Draw calls per frame are tracked as of cocos2d 2.x. */
#if CC3_CC2_1
#	define CC3GLDraws()		0
#	define CC_INCREMENT_GL_DRAWS(__n__)
#else
#	define CC3GLDraws()		((GLuint)__ccNumberOfDraws)
#endif


#if !CC3_IOS || !((CC3_CC2_1 || CC3_CC2_2))
enum {
	kCCTouchBegan,
	kCCTouchMoved,
	kCCTouchEnded,
	kCCTouchCancelled,
	
	kCCTouchMax,
};
#endif	// !CC3_IOS || !((CC3_CC2_1 || CC3_CC2_2))

#if !CC3_IOS

#pragma mark -
#pragma mark Extensions for non-IOS environments

/** Added for iOS functionality in non-iOS environment. */

/** Add stub class for iOS functionality in non-iOS environment. */
@interface CCTouchDispatcher : NSObject
-(void) addTargetedDelegate: (id) delegate priority: (NSInteger) priority swallowsTouches: (BOOL) swallowsTouches;
+(id) sharedDispatcher;
@end

/** Extension category to add stubs for iOS functionality in non-iOS environment. */
@interface CCDirector (NonIOS)
@property (nonatomic, readonly) CCTouchDispatcher* touchDispatcher;
@end

/** Extension category to add stubs for iOS functionality in non-iOS environment. */
@interface CCNode (NonIOS)
-(CGPoint) convertTouchToNodeSpace: (UITouch*) touch;
@end

#endif		// !CC3_IOS


#pragma mark -
#pragma mark CC3CCSizeTo action

/** Animates a change to the contentSize of a CCNode. */
@interface CC3CCSizeTo : CCActionInterval {
	CGSize startSize_;
	CGSize endSize_;
	CGSize sizeChange_;
}

/**
 * Initializes this instance to change the contentSize property of the target to the specified
 * size, within the specified elapsed duration.
 */
-(id) initWithDuration: (CCTime) dur sizeTo: (CGSize) endSize;

/**
 * Allocates and initializes an autoreleased instance to change the contentSize property of
 * the target to the specified size, within the specified elapsed duration.
 */
+(id) actionWithDuration: (CCTime) dur sizeTo: (CGSize) endSize;

@end



#pragma mark -
#pragma mark CCNode extension

/** Extension category to support cocos3d functionality. */
@interface CCNode (CC3)

#if (CC3_CC2_1 || CC3_CC2_2)
/** Returns YES if the node is added to an active scene and neither it nor any of it's ancestors is paused. */
@property(nonatomic,readonly) BOOL isRunningInActiveScene;
#endif	// (CC3_CC2_1 || CC3_CC2_2)
	
#if CC3_CC2_2
/** cocos2d 2.x compatibility with pixel-based sizing. */
@property (nonatomic, readonly) CGSize contentSizeInPixels;

/** cocos2d 2.x compatibility with pixel-based sizing. */
@property (nonatomic, readonly) CGRect boundingBoxInPixels;
#endif

/**
 * Returns whether this node will receive touch events.
 *
 * This implementation returns NO.
 */
@property(nonatomic, readonly, getter=isTouchEnabled) BOOL touchEnabled;


/** Returns the bounding box of this CCNode, measured in pixels, in the global coordinate system. */
@property (nonatomic, readonly) CGRect globalBoundingBoxInPixels;

/**
 * Updates the viewport of any contained CC3Scene instances with the dimensions
 * of its CC3Layer and the device orientation.
 *
 * This CCNode implementation simply passes the notification along to its children.
 * Descendants that are CC3Layers will update their CC3Scene instances.
 */
-(void) updateViewport;

/**
 * Returns a point in the coordinate space of this node that corresponds to the specified point
 * in the coordinate space of the UIView, taking into consideration the orientation of the device.
 *
 * You can use this method to convert locations in a UIView, including those returned by touch
 * events and gestures, such as the locationInView: method on tap and long-press gestures, to
 * a location in this layer.
 */
-(CGPoint) cc3ConvertUIPointToNodeSpace: (CGPoint) viewPoint;

/**
 * Returns a point in the coordinate space of the UIView that corresponds to the specified point
 * in the coordinate space of this node, taking into consideration the orientation of the device.
 *
 * This method performs the inverse of the operation provided by the cc3ConvertUIPointToNodeSpace: method.
 */
-(CGPoint) cc3ConvertNodePointToUISpace: (CGPoint) glPoint;

/**
 * Returns a movement in the coordinate space of this layer that corresponds
 * to the specified movement in the coordinate space of the UIView, taking into
 * consideration the orientation of the device.
 *
 * You can use this method to convert movements in a UIView, including those
 * returned by touch events and gestures, such as the translationInView: and
 * velocityInView: methods of UIPanGestureRecognizer, to movement in this layer.
 */
-(CGPoint) cc3ConvertUIMovementToNodeSpace: (CGPoint) uiMovement;

/**
 * Normalizes the specified movement, which is in the coordinate space of the
 * UIView, so that the movement is made relative to the size of this node.
 *
 * The returned value is a fraction proportional to the size of this node.
 * A drag movement from one side of the node all the way to the other side would
 * return positive or negative one in the X or Y component of the returned point.
 * Similarly, a drag movement from the center to one side would return 0.5 in
 * the X or Y component of the returned point.
 *
 * This method allows you to convert drag movements to a measurement that is
 * independent of the absolute size of the node, and is of a scale useful for
 * processing as input that is not used as a direct positioning value.
 *
 * You can use this method to normalize movements in a UIView, including those
 * returned by touch events and gestures, such as the translationInView: and
 * velocityInView: methods of UIPanGestureRecognizer, so that they are proportional,
 * and independent of, the size of this node.
 *
 * This method takes into consideration the orientation of the device.
 */
-(CGPoint) cc3NormalizeUIMovement: (CGPoint) uiMovement;

/** Returns whether this node contains the specified UI touch location. */
-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint;

/**
 * Returns whether this node, or any of its descendants will consume a touch
 * event at the specified UIView location when presented with the event.
 *
 * This method is useful for testing whether a touch event should be handled
 * by a descendant node instead of a gesture recognizer. The result of this
 * method can be used to cancel the gesture recognizer.
 *
 * Based on cocos2d Gesture Recognizer ideas by Krzysztof Zabłocki at:
 * http://www.merowing.info/2012/03/using-gesturerecognizers-in-cocos2d/
 */
-(BOOL) cc3WillConsumeTouchEventAt: (CGPoint) viewPoint;

#if CC3_IOS
/**
 * Validates that the specified gesture is okay to proceed, and cancels the gesture
 * if not. Returns YES if the gesture is valid and okay to proceed. Returns NO if
 * the gesture was cancelled.
 *
 * Your gesture handling callback methods should use this method before processing
 * the gesture to ensure that there are no conflicts between the touch events of
 * the gesture and the touch events handled by this node or any of its descendants.
 *
 * For discrete gestures, such as tap gestures, you should use this method each
 * time the callback is invoked. For many discrete gestures, the callback is only
 * invoked when the gesture is in state UIGestureRecognizerStateEnded.
 *
 * For continuous gestures, such as pan or pinch gestures, you should use this method
 * when the callback is invoked and the gesture is in state UIGestureRecognizerStateBegan.
 * You do not need to revalidate the continuous gesture on each subsequent callback, when
 * the state of the gesture is UIGestureRecognizerStateChanged. Doing so is unnecessary.
 *
 * This implementation extracts the location of the touch point from the gesture and
 * uses the cc3WillConsumeTouchEventAt: method of this node to test if this node or
 * any of its descendants are interested in the touch event that triggerd the gesture.
 *
 * If neither this node nor any descendant is interested in the touch event, this
 * method returns YES. If this node or a descendant is interested in the touch event,
 * the gesture is cancelled and this method returns NO.
 */
-(BOOL) cc3ValidateGesture: (UIGestureRecognizer*) gesture;
#endif	// CC3_IOS

/** Converts an NSEvent (typically a mouse event) to the local coordinates of this node. */
-(CGPoint) cc3ConvertNSEventToNodeSpace: (NSEvent*) event;

/**
 * Invoked automatically when the window has been resized while running in OSX.
 * This implementation simply propagates the same method to the children.
 * Subclasses may override to actually do something when the window resizes.
 */
-(void) reshapeProjection: (CGSize) newWindowSize;

@end


#if (CC3_CC2_1 || CC3_CC2_2)

#pragma mark -
#pragma mark CCLayer extension

/** Extension category to support cocos3d functionality. */
@interface CCLayer (CC3)

#if COCOS2D_VERSION < 0x020100
/** Backwards compatibility for setter renamed in cocos2d 2.1. */
-(void) setTouchEnabled: (BOOL) isTouchEnabled;
#endif

#if CC3_IOS
/** Dummy property for compatibility with apps that run both OSX and IOS. */
@property (nonatomic, readwrite, getter=isMouseEnabled) BOOL mouseEnabled;
/** Dummy property for compatibility with apps that run both OSX and IOS. */
@property (nonatomic, assign) NSInteger mousePriority;
#endif	// CC3_IOS

#if CC3_OSX
#if COCOS2D_VERSION < 0x020100
/** Backwards compatibility for setter renamed in cocos2d 2.1. */
-(void) setMouseEnabled: (BOOL) isMouseEnabled;
/** Backwards compatibility for setter renamed in cocos2d 2.1. */
@property (nonatomic, assign) NSInteger mousePriority;
#endif
#endif	// CC3_OSX

@end


#pragma mark -
#pragma mark CCMenu extension

/** Extension category to support cocos3d functionality. */
@interface CCMenu (CC3)

/** 
 * Returns whether this node contains the specified UI touch location.
 *
 * Overridden to test the view point against the bounds of the child
 * menu items instead of against the bounds of the menu itself.
 */
-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint;

@end


#pragma mark -
#pragma mark CCMenu extension

/** Extension category to support cocos3d functionality. */
@interface CCMenuItemImage (CC3)
#if CC3_CC2_1
/** Backwards compatibility for constructor renamed in cocos2d 2.x. */
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2;

/** Backwards compatibility for constructor renamed in cocos2d 2.x. */
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;
#endif
@end

#endif	// (CC3_CC2_1 || CC3_CC2_2)


#pragma mark -
#pragma mark CCTexture extension

/** Extension category to support cocos3d functionality. */
@interface CCTexture (CC3)

/**
 * If a CCTexture with the specified name does not already exist in the CCTextureCache,
 * this texture is added to the CCTextureCache under that name.
 *
 * If a texture already exists in the cache under the specified name, or if the specified
 * name is nil, this texture is not added to the cache.
 */
-(void) addToCacheWithName: (NSString*) texName;

@end


#pragma mark -
#pragma mark CCTextureCache extension

/** Extension category to support cocos3d functionality. */
@interface CCTextureCache (CC3)

/** 
 * If a texture with the specified name does not already exist in this cache, the specified
 * texture is added under the specified name.
 *
 * If a texture already exists in this cache under the specified name, or if either the 
 * specified texture or specified name is nil, the texture is not added to the cache.
 */
-(void) addTexture: (CCTexture*) tex2D named: (NSString*) texName;

@end


#pragma mark -
#pragma mark CCDirector extension

/** Extension category to support cocos3d functionality. */
@interface CCDirector (CC3)

/** The OpenGL ES view, cast as the correct class. */
@property(nonatomic, retain) CCGLView* ccGLView;

/** Returns the time interval in seconds between the current render frame and the previous frame. */
-(CCTime) frameInterval;

/** Returns the current rendering perfromance in average frames per second. */
-(CCTime) frameRate;

/** Returns whether this director has a CCScene either running or queued up. */
-(BOOL) hasScene;

/** Returns the timestamp of this director as derived from the display link that provide animation. */
@property(nonatomic, readonly) NSTimeInterval displayLinkTime;


#if CC3_CC2_1

/** Alias to setDisplayFPS: */
-(void) setDisplayStats: (BOOL) displayFPS;

/** Consistent naming alias for the OpenGL ES view. */
@property(nonatomic, retain) CCGLView* view;

/** Returns the CCActionManager sharedManager singleton. */
@property (nonatomic, readonly) CCActionManager* actionManager;

#if CC3_IOS
/** Returns the CCTouchDispatcher sharedDispatcher singleton. */
@property (nonatomic, readonly) CCTouchDispatcher* touchDispatcher;
#endif	// CC3_IOS

/** Returns the CCScheduler sharedScheduler singleton. */
@property (nonatomic, readonly) CCScheduler* scheduler;

#if COCOS2D_VERSION < 0x010100
/**
 * Added for runtime compatibility with cocos2d version 1.1 features.
 *
 * In cocos2d versions prior to 1.1, this method does nothing.
 */
-(void) setRunLoopCommon: (BOOL) common;
#endif

#endif	// CC3_CC2_1

#if CC3_CC2_2 || CC3_OSX
/**
 * Adds support under cocos2d 2.x for legacy code that looks for device orientation under cocos2d 1.x.
 *
 * Always returns UIDeviceOrientationPortrait.
 */
-(UIDeviceOrientation) deviceOrientation;
#endif	// CC3_CC2_2 && CC3_IOS

@end

#if CC3_IOS

#pragma mark -
#pragma mark CCDirectorIOS extension

/** Extension category to support cocos3d functionality. */
@interface CCDirectorIOS (CC3)
@end

#endif		// CC3_IOS


#if CC3_OSX

#pragma mark -
#pragma mark CCDirectorMac extension

/** Extension category to support cocos3d functionality. */
@interface CCDirectorMac (CC3)
@end

#endif		// CC3_OSX


#pragma mark -
#pragma mark CCDirectorDisplayLink extension

/** Extension category to support cocos3d functionality. */
@interface CCDirectorDisplayLink (CC3)
@end


#pragma mark -
#pragma mark CCFileUtils extension

/** Extension category to support cocos3d functionality. */
@interface CCFileUtils (CC3)

#if CC3_CC2_1
/**
 * As of cocos2d 2.x, CCFileUtils changed from static class methods to a singleton instance.
 * For cocos2d 1.x, this method mimics the access to the singleton and simply returns this class itself.
 */
+(Class) sharedFileUtils;
#endif

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functions

/** Returns the name of the specified touch type. */
NSString* NSStringFromTouchType(uint tType);

#if CC3_CC2_1
/** Extend the iOS version enumerations for cocos2d 1.x. */
enum {
    kCCiOSVersion_5_0 = 0x05000000,
};
#endif // CC3_CC2_1

#if COCOS2D_VERSION < 0x010100
/** Extend the iOS version enumerations for cocos2d 1.0.1. */
enum {
    kCCiOSVersion_6_0_0 = 0x06000000
};

#define kCCTexture2DPixelFormat_RGB888	255

#endif // COCOS2D_VERSION < 0x010100
