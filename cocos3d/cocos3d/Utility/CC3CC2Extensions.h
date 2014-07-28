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
#import "CC3ViewController.h"
#import "CCTextureCache.h"
#import "CC3EAGLView.h"
#import <GLKit/GLKMatrix4.h>

#if !CC3_CC2_CLASSIC
#	import "CCNode_Private.h"
#	import "CCDirector_Private.h"
#	import "CCTexture_Private.h"
#endif	// !CC3_CC2_CLASSIC


#if CC3_CC2_RENDER_QUEUE

#define kCCVertexAttrib_MAX			4
#define CC_BLEND_SRC				GL_ONE
#define CC_BLEND_DST				GL_ONE_MINUS_SRC_ALPHA
#define ccGLUseProgram(P)

#else

/** Dummy protocol for backwards compatibility with Cocos2D 3.x renderer. */
@protocol CCRenderCommand <NSObject>
@end

/** Dummy class for backwards compatibility with Cocos2D 3.x renderer. */
@interface CCRenderer : NSObject

/** Mark the renderer's cached GL state as invalid executing custom OpenGL code. */
-(void) invalidateState;

/** Render any currently queued commands. */
-(void) flush;

@end

#endif	// CC3_CC2_RENDER_QUEUE


// Backwards compatibility to renamed Cocos2D entities
#if CC3_CC2_CLASSIC
typedef ccTime CCTime;

#define CCNextPOT			ccNextPOT
#define CCTexture			CCTexture2D
#define viewSize			winSize
#define viewSizeInPixels	winSizeInPixels

#define CCTexturePixelFormat			CCTexture2DPixelFormat
#define CCTexturePixelFormat_RGBA8888	kCCTexture2DPixelFormat_RGBA8888
#define CCTexturePixelFormat_RGB888		kCCTexture2DPixelFormat_RGB888
#define CCTexturePixelFormat_RGB565		kCCTexture2DPixelFormat_RGB565
#define CCTexturePixelFormat_A8			kCCTexture2DPixelFormat_A8
#define CCTexturePixelFormat_I8			kCCTexture2DPixelFormat_I8
#define CCTexturePixelFormat_AI88		kCCTexture2DPixelFormat_AI88
#define CCTexturePixelFormat_RGBA4444	kCCTexture2DPixelFormat_RGBA4444
#define CCTexturePixelFormat_RGB5A1		kCCTexture2DPixelFormat_RGB5A1
#define CCTexturePixelFormat_PVRTC4		kCCTexture2DPixelFormat_PVRTC4
#define CCTexturePixelFormat_PVRTC2		kCCTexture2DPixelFormat_PVRTC2
#define CCTexturePixelFormat_Default	kCCTexture2DPixelFormat_Default

#define CCActionFadeTo			CCFadeTo
#define CCActionFadeIn			CCFadeIn
#define CCActionFadeOut			CCFadeOut
#define CCActionHide			CCHide
#define CCActionTintTo			CCTintTo
#define CCActionMoveTo			CCMoveTo
#define CCActionScaleTo			CCScaleTo
#define CCActionSequence		CCSequence
#define CCActionRepeat			CCRepeat
#define CCActionRepeatForever	CCRepeatForever
#define CCActionEaseOut			CCEaseOut
#define CCActionEaseIn			CCEaseIn
#define CCActionEaseInOut		CCEaseInOut
#define CCActionEaseBounceOut	CCEaseBounceOut
#define CCActionEaseElasticOut	CCEaseElasticOut
#define CCActionCallFunc		CCCallFunc

#define CCSystemVersion_iOS_5_0 kCCiOSVersion_5_0
#define CCSystemVersion_iOS_6_0 kCCiOSVersion_6_0_0

#endif	// CC3_CC2_CLASSIC

#if !CC3_CC2_CLASSIC
@protocol CCRGBAProtocol <NSObject>
@end

// Dummy class for backwards compatibility
@interface CCLayer : CCNode
@end

#endif	// !CC3_CC2_CLASSIC


#if CC3_CC2_CLASSIC

/** In Cocos2D v1 & v2, opacity is defined as an integer value between 0 and 255. */
typedef GLubyte CCOpacity;

/** Maximum opacity value (GLubyte 255) in Cocos2D v1 & v2. */
#define kCCOpacityFull					255

/** Convert GLfloat to CCOpacity (GLubyte) in Cocos2D v1 & v2. */
#define CCOpacityFromGLfloat(glf)		CCColorByteFromFloat(glf)

/** Convert CCOpacity (GLubyte) to GLfloat in Cocos2D v1 & v2. */
#define GLfloatFromCCOpacity(ccOp)		CCColorFloatFromByte(ccOp)

/** Convert GLubyte to CCOpacity (GLubyte) in Cocos2D v1 & v2. */
#define CCOpacityFromGLubyte(glub)		(glub)

/** Convert CCOpacity (GLubyte) to GLubyte in Cocos2D v1 & v2. */
#define GLubyteFromCCOpacity(ccOp)		(ccOp)

/** In Cocos2D v1 & v2, color is defined as a ccColor3B structure containing 3 GLubyte color components. */
typedef ccColor3B CCColorRef;

/** Convert ccColor4F to CCColorRef (ccColor3B) in Cocos2D v1 & v2. */
#define CCColorRefFromCCC4F(c4f)		CCC3BFromCCC4F(c4f)

/** Convert CCColorRef (ccColor3B) to ccColor4F in Cocos2D v1 & v2. */
#define CCC4FFromCCColorRef(ccRef)		CCC4FFromColorAndOpacity(ccRef, kCCOpacityFull)

/** Convert ccColor4B to CCColorRef (ccColor3B) in Cocos2D v1 & v2. */
#define CCColorRefFromCCC4B(c4b)		CCC3BFromCCC4B(c4b)

/** Convert CCColorRef (ccColor3B) to ccColor4B in Cocos2D v1 & v2. */
#define CCC4BFromCCColorRef(ccRef)		CCC4BFromColorAndOpacity(ccRef, kCCOpacityFull)

#else

/** In Cocos2D v3 and above, opacity is defined as a CGFloat value between 0.0 and 1.0. */
typedef CGFloat CCOpacity;

/** Maximum opacity value (CGFloat 1.0) in Cocos2D v3. */
#define kCCOpacityFull					1.0

/** Convert GLfloat to CCOpacity (CGFloat) in Cocos2D v3. */
#define CCOpacityFromGLfloat(glf)		((CCOpacity)(glf))

/** Convert CCOpacity (CGFloat) to GLfloat in Cocos2D v3. */
#define GLfloatFromCCOpacity(ccOp)		((GLfloat)(ccOp))

/** Convert GLubyte to CCOpacity (CGFloat) in Cocos2D v3. */
#define CCOpacityFromGLubyte(glub)		((CCOpacity)CCColorFloatFromByte(glub))

/** Convert CCOpacity (CGFloat) to GLubyte in Cocos2D v3. */
#define GLubyteFromCCOpacity(ccOp)		CCColorByteFromFloat((GLfloat)(ccOp))

/** In Cocos2D v3 and above, color is defined as an instance of the CCColor class. */
typedef CCColor* CCColorRef;

/** Convert ccColor4F to CCColorRef (CCColor*) in Cocos2D v3. */
#define CCColorRefFromCCC4F(c4f)		[CCColor colorWithCcColor4f: c4f]

/** Convert CCColorRef (CCColor*) to ccColor4F in Cocos2D v3. */
#define CCC4FFromCCColorRef(ccRef)		[ccRef ccColor4f]

/** Convert ccColor4B to CCColorRef (CCColor*) in Cocos2D v3. */
#define CCColorRefFromCCC4B(c4b)		[CCColor colorWithCcColor4b: c4b]

/** Convert CCColorRef (CCColor*) to ccColor4B in Cocos2D v3. */
#define CCC4BFromCCColorRef(ccRef)		[ccRef ccColor4b]

#endif	// CC3_CC2_CLASSIC


#pragma mark -
#pragma mark CCGLView

/** Extension to support cocos3d functionality. */
@interface CCGLView (CC3)

/** Returns the GL color format of the pixels. */
@property(nonatomic, readonly) GLenum pixelColorFormat;

/** Returns the GL depth format of the pixels. */
@property(nonatomic, readonly) GLenum pixelDepthFormat;

/** Default Renderbuffer */
@property (nonatomic,readonly) GLuint defaultFrameBuffer;

/** MSAA Framebuffer */
@property (nonatomic,readonly) GLuint msaaFrameBuffer;

/** Color Renderbuffer */
@property (nonatomic,readonly) GLuint colorRenderBuffer;

/** MSAA Color Buffer */
@property (nonatomic,readonly) GLuint msaaColorBuffer;

/** Depth Buffer */
@property (nonatomic,readonly) GLuint depthBuffer;

/** The underlying view rendering surface. */
//@property(nonatomic, retain, readonly) CC3SurfaceManager* surfaceManager;

#if CC3_IOS

/**
 * Returns the number of samples that was requested to be used to define each pixel.
 *
 * This may return a value that is different than the value returned by the pixelSamples
 * property because that property is limited by the capabilities of the platform.
 */
@property(nonatomic, readonly) GLuint requestedSamples;

/**
 * Returns the actual number of samples used to define each pixel.
 *
 * This may return a value that is different than the value returned by the requestedSamples
 * property because this property is limited by the capabilities of the platform.
 */
@property(nonatomic, readonly) GLuint pixelSamples;

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

#endif	// CC3_IOS

#if CC3_OSX

/** returns surface size in pixels */
@property(nonatomic,readonly) CGSize surfaceSize;

/** The OpenGL context used by this view. */
@property(nonatomic, retain, readonly) CC3GLContext* context;

/** Dummy method for compatibility with iOS. */
-(void) addGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer;

/** Dummy method for compatibility with iOS. */
-(void) removeGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer;

#endif	// CC3_OSX

@end

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


#if !CC3_IOS || !CC3_CC2_CLASSIC
enum {
	kCCTouchBegan,
	kCCTouchMoved,
	kCCTouchEnded,
	kCCTouchCancelled,
	
	kCCTouchMax,
};
#endif	// !CC3_IOS || !CC3_CC2_CLASSIC

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


#if CC3_CC2_CLASSIC

#pragma mark -
#pragma mark CCActionTintTo extension

/** Extension category to support cocos3d functionality. */
@interface CCActionTintTo (CC2_CLASSIC)

/**
 *  Initalizes a tint to action.
 *  Compatible with Cocos2D v3 implementation.
 *
 *  @param duration     Action duration.
 *  @param color		Destination color tint to.
 *
 *  @return New tint to action.
 */
-(id) initWithDuration: (CCTime) duration color: (ccColor3B) color;

/**
 *  Creates a tint to action.
 *  Compatible with Cocos2D v3 implementation.
 *
 *  @param duration     Action duration.
 *  @param color		Destination color tint to.
 *
 *  @return New tint to action.
 */
+(id) actionWithDuration: (CCTime) duration color: (ccColor3B) color;

@end

#endif	// CC3_CC2_CLASSIC


#pragma mark -
#pragma mark CCNode extension

/** Extension category to support cocos3d functionality. */
@interface CCNode (CC3)

/**
 * Convenience method that wraps this node in a CCScene instance, and returns the CCScene instance.
 *
 * This node will be held as a child node of the returned CCScene instance.
 */
-(CCScene*) asCCScene;

#if !CC3_CC2_RENDER_QUEUE

/** Backwards compatibility with Cocos2D 3.x renderer. Simply invoks visit. */
-(void) visit: (CCRenderer*) renderer parentTransform: (const GLKMatrix4*)parentTransform;

#endif	// !CC3_CC2_RENDER_QUEUE

#if CC3_CC2_CLASSIC

/** Returns YES if the node is added to an active scene and neither it nor any of it's ancestors is paused. */
@property(nonatomic,readonly) BOOL isRunningInActiveScene;

/** 
 * If paused, no callbacks will be called, and no actions will be run.
 * For compatibility with Cocos2D v3. Setting this property does nothing.
 */
@property(nonatomic, assign) BOOL paused;

/** Enables user interaction (either touch or mouse) on a node. */
@property ( nonatomic, assign, getter = isUserInteractionEnabled ) BOOL userInteractionEnabled;

#endif	// CC3_CC2_CLASSIC

#if !CC3_CC2_CLASSIC

/** For backwards compatibility with prior Cocos2D versions. Does nothing. */
-(void) scheduleUpdate;

/** Dummy property for compatibility with prior Cocos2D versions. Does nothing */
@property (nonatomic, assign) NSInteger mousePriority;

/**
 * Use (0,0) when you position the CCNode.
 * Does nothing. Provided for backwards compatibility.
 */
@property(nonatomic,readwrite,assign) BOOL ignoreAnchorPointForPosition;

#endif	// !CC3_CC2_CLASSIC

#if !CC3_CC2_1
/** cocos2d 2.x compatibility with pixel-based sizing. */
@property (nonatomic, readonly) CGSize contentSizeInPixels;

/** cocos2d 2.x compatibility with pixel-based sizing. */
@property (nonatomic, readonly) CGRect boundingBoxInPixels;
#endif	// !CC3_CC2_1

#if CC3_CC2_1
/** The anchorPoint in absolute points. */
@property(nonatomic,readonly) CGPoint anchorPointInPoints;

/**
 * Use (0,0) when you position the CCNode.
 * Does nothing. Provided for backwards compatibility.
 */
@property(nonatomic,readwrite,assign) BOOL ignoreAnchorPointForPosition;
#endif	// CC3_CC2_1

/**
 * Returns whether this node will receive touch events.
 *
 * This implementation returns NO.
 */
@property(nonatomic, readwrite, getter=isTouchEnabled) BOOL touchEnabled;

/**
 * Returns whether this node will receive mouse events.
 *
 * This implementation returns NO.
 */
@property (nonatomic, readwrite, getter=isMouseEnabled) BOOL mouseEnabled;

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

#if (COCOS2D_VERSION < 0x030100)
/**
 * Invoked automatically when the OS view has been resized.
 *
 * This implementation simply propagates the same method to the children.
 * Subclasses may override to actually do something when the view resizes.
 */
-(void) viewDidResizeTo: (CGSize) newViewSize;
#endif	// (COCOS2D_VERSION < 0x030100)

@end


#pragma mark -
#pragma mark CCLayer extension

/** Extension category to support cocos3d functionality. */
@interface CCLayer (CC3)

/** 
 * The controller controlling the scene.
 *
 * Under iOS and Cocos2D v2 & v3, returns the CCDirector singleton.
 * Setting this property has no effect.
 */
@property(nonatomic, readonly) CC3ViewController* controller __deprecated;

/** The view displaying this layer. */
@property(nonatomic, readonly) CCGLView* view __deprecated;

/** Allocates and initializes a layer. */
+(id) layer;

#if CC3_CC2_CLASSIC

#if CC3_IOS
/** Dummy property for compatibility with apps that run both OSX and IOS. */
@property (nonatomic, assign) NSInteger mousePriority;
#endif	// CC3_IOS

#if (COCOS2D_VERSION < 0x020100)
/** Backwards compatibility for setter renamed in cocos2d 2.1. */
-(void) setTouchEnabled: (BOOL) isTouchEnabled;

#if CC3_OSX
/** Backwards compatibility for setter renamed in cocos2d 2.1. */
-(void) setMouseEnabled: (BOOL) isMouseEnabled;
/** Backwards compatibility for setter renamed in cocos2d 2.1. */
@property (nonatomic, assign) NSInteger mousePriority;
#endif	// CC3_OSX

#endif	// (COCOS2D_VERSION < 0x020100)

#endif	// CC3_CC2_CLASSIC

@end


#if CC3_CC2_CLASSIC

#pragma mark -
#pragma mark CCSprite extension

/** Extension category to support cocos3d functionality. */
@interface CCSprite (CC3)

/** 
 * Allocates and initializes an autoreleased instance created from the image
 * in the specified file. For compatibility with Cocos2D v3 and above.
 */
+(id) spriteWithImageNamed: (NSString*) fileName;

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

#endif	// CC3_CC2_CLASSIC


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

#if !CC3_CC2_1
/**
 * Adds support above cocos2d 1.x for legacy code that looks for device orientation under cocos2d 1.x.
 *
 * Always returns UIDeviceOrientationPortrait.
 */
-(UIDeviceOrientation) deviceOrientation;
#endif	// !CC3_CC2_1

#if CC3_CC2_CLASSIC

/** Content scaling factor. Does nothing, as content scaling factor only applies to CCDirectorIOS. */
@property(nonatomic, assign) CGFloat contentScaleFactor;

/** The size of the view. */
@property(nonatomic, readonly) CGSize designSize;

#endif	//CC3_CC2_CLASSIC

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
#pragma mark CCScheduler extension

@interface CCScheduler (CC3)

#if !CC3_CC2_CLASSIC
/** Pauses the target. */
-(void) pauseTarget:(id)target;

/** Resumes the target. */
-(void) resumeTarget:(id)target;
#endif	// !CC3_CC2_CLASSIC

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

/** 
 * Returns the size of a CCNode that will cover the specified view size, 
 * taking into consideration whether the view is a Retina view.
 */
static inline CGSize CCNodeSizeFromViewSize(CGSize viewSize) {
	GLfloat viewScaleFactor = 1.0f / CCDirector.sharedDirector.contentScaleFactor;
	return CGSizeMake(viewSize.width * viewScaleFactor,
					  viewSize.height * viewScaleFactor);
}

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
