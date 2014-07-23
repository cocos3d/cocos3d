/*
 * CC3CC2Extensions.m
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
 * 
 * See header file CC3CC2Extensions.h for full API documentation.
 */

#import "CC3CC2Extensions.h"
#import "CC3RenderSurfaces.h"
#import "CC3Logging.h"
#import "CC3OpenGLUtility.h"
#import "CC3ViewController.h"
#import "uthash.h"

#if CC3_CC2_1
#	import "ES1Renderer.h"
#else
#	import "CCES2Renderer.h"
#endif

#if CC3_CC2_RENDER_QUEUE
#else

@implementation CCRenderer

-(void) invalidateState {}

-(void) flush {}

@end

#endif	// CC3_CC2_RENDER_QUEUE


#if !CC3_CC2_CLASSIC

// Dummy class for backwards compatibility
@implementation CCLayer

/** Assume layer covers the entire window. */
-(id) init {
	if ( (self = [ super init ]) ){
		self.anchorPoint = ccp(0.0f, 0.0f);
		[self setContentSize: CCDirector.sharedDirector.designSize];
	}
	
	return( self );
}

@end

#endif	// !CC3_CC2_CLASSIC

#if CC3_CC2_1
#	define CCESRendererImpl		ES1Renderer
#else
#	define CCESRendererImpl		CCES2Renderer
#endif	// CC3_CC2_1

#if COCOS2D_VERSION < 0x020100
#	define CC2_DEPTH_BUFFER		depthBuffer_
#	define CC2_SAMPLES_TO_USE	samplesToUse_
#else
#	define CC2_DEPTH_BUFFER		_depthBuffer
#	define CC2_SAMPLES_TO_USE	_samplesToUse
#endif

#if CC3_OGLES_2
@implementation CCES2Renderer (CC3)
-(GLuint) depthBuffer { return CC2_DEPTH_BUFFER; }
-(GLuint) pixelSamples { return CC2_SAMPLES_TO_USE; }
@end
#endif // CC3_OGLES_2

#if CC3_OGLES_1
@implementation ES1Renderer (CC3)
-(GLuint) depthBuffer { return CC2_DEPTH_BUFFER; }
-(GLuint) pixelSamples { return CC2_SAMPLES_TO_USE; }
@end
#endif // CC3_OGLES_1


@interface CCGLView (TemplateMethods)
-(unsigned int) convertPixelFormat:(NSString*) pixelFormat;
@end

#if COCOS2D_VERSION < 0x020100
#	define CC2_REQUESTED_SAMPLES	requestedSamples_
#	define CC2_PIXEL_FORMAT			pixelformat_
#	define CC2_DEPTH_FORMAT			depthFormat_
#	define CC2_CONTEXT				context_
#	define CC2_RENDERER				renderer_
#	define CC2_SIZE					size_
#	define CC2_PRESERVE_BACKBUFFER	preserveBackbuffer_
#else
#	define CC2_REQUESTED_SAMPLES	_requestedSamples
#	define CC2_PIXEL_FORMAT			_pixelformat
#	define CC2_DEPTH_FORMAT			_depthFormat
#	define CC2_CONTEXT				_context
#	define CC2_RENDERER				_renderer
#	define CC2_SIZE					_size
#	define CC2_PRESERVE_BACKBUFFER	_preserveBackbuffer
#endif

@implementation CCGLView (CC3)

#if CC3_IOS

-(GLenum) pixelColorFormat { return [self convertPixelFormat: CC2_PIXEL_FORMAT]; }

-(GLenum) pixelDepthFormat { return self.depthFormat; }

-(GLuint) defaultFrameBuffer { return [CC2_RENDERER defaultFrameBuffer]; }

-(GLuint) msaaFrameBuffer { return [CC2_RENDERER msaaFrameBuffer]; }

-(GLuint) colorRenderBuffer { return [CC2_RENDERER colorRenderBuffer]; }

-(GLuint) msaaColorBuffer { return [CC2_RENDERER msaaColorBuffer]; }

-(GLuint) requestedSamples { return CC2_REQUESTED_SAMPLES; }

-(GLuint) depthBuffer { return [(CCESRendererImpl*)CC2_RENDERER depthBuffer]; }

-(GLuint) pixelSamples { return [(CCESRendererImpl*)CC2_RENDERER pixelSamples]; }

-(id) initWithFrame: (CGRect) frame
		pixelFormat: (NSString*) colorFormat
		depthFormat: (GLenum) depthFormat
 preserveBackbuffer: (BOOL) isRetained
	numberOfSamples: (GLuint) sampleCount {
	return [self initWithFrame: frame
				   pixelFormat: colorFormat
				   depthFormat: depthFormat
			preserveBackbuffer: isRetained
					sharegroup: nil
				 multiSampling: (sampleCount > 1)
			   numberOfSamples: sampleCount];
}

+(id) viewWithFrame: (CGRect) frame
		pixelFormat: (NSString*) colorFormat
		depthFormat: (GLenum) depthFormat
 preserveBackbuffer: (BOOL) isRetained
	numberOfSamples: (GLuint) sampleCount {
	return [[[self alloc] initWithFrame: frame
							pixelFormat: colorFormat
							depthFormat: depthFormat
					 preserveBackbuffer: isRetained
						numberOfSamples: sampleCount] autorelease];
}

#endif	// CC3_IOS

#if CC3_OSX

-(GLenum) pixelColorFormat {
	GLint screenIdx = 0;
	GLint colorSize;
	GLint alphaSize;
	
	NSOpenGLPixelFormat* pixFmt = self.pixelFormat;
	[pixFmt getValues: &colorSize forAttribute:NSOpenGLPFAColorSize forVirtualScreen: screenIdx];
	[pixFmt getValues: &alphaSize forAttribute:NSOpenGLPFAAlphaSize forVirtualScreen: screenIdx];
	
	return CC3GLColorFormatFromBitPlanes(colorSize, alphaSize);
}
									 
-(GLenum) pixelDepthFormat {
	GLint screenIdx = 0;
	GLint depthSize;
	GLint stencilSize;
	
	NSOpenGLPixelFormat* pixFmt = self.pixelFormat;
	[pixFmt getValues: &depthSize forAttribute:NSOpenGLPFADepthSize forVirtualScreen: screenIdx];
	[pixFmt getValues: &stencilSize forAttribute:NSOpenGLPFAStencilSize forVirtualScreen: screenIdx];
	
	return CC3GLDepthFormatFromBitPlanes(depthSize, stencilSize);
}

-(GLuint) defaultFrameBuffer { return 0; }

-(GLuint) msaaFrameBuffer { return 0; }

-(GLuint) colorRenderBuffer { return 0; }

-(GLuint) msaaColorBuffer { return 0; }

-(GLuint) depthBuffer { return 0; }

-(CGSize) surfaceSize { return NSSizeToCGSize(self.bounds.size); }

-(CC3GLContext*) context { return (CC3GLContext*)self.openGLContext; }

-(void) addGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer {}

-(void) removeGestureRecognizer: (UIGestureRecognizer*) gestureRecognizer {}

#endif	// CC3_OSX



@end

#if !CC3_IOS

#pragma mark -
#pragma mark Extensions for non-IOS environments

@implementation CCTouchDispatcher
-(void) addTargetedDelegate: (id) delegate priority: (NSInteger) priority swallowsTouches: (BOOL) swallowsTouches {}
+(id) sharedDispatcher { return nil; }
@end

@implementation CCDirector (NonIOS)
-(CCTouchDispatcher*) touchDispatcher { return nil; }
@end

@implementation CCNode (NonIOS)
-(CGPoint) convertTouchToNodeSpace: (UITouch*) touch { return CGPointZero; }
@end

#endif		// !CC3_IOS


#if CC3_CC2_CLASSIC

#pragma mark -
#pragma mark CCActionTintTo extension

@implementation CCActionTintTo (CC2_CLASSIC)

-(id) initWithDuration: (CCTime) duration color: (ccColor3B) color {
	return [self initWithDuration: duration red: color.r green: color.g blue: color.b];
}

+(id) actionWithDuration: (CCTime) duration color: (ccColor3B) color {
	return [[[self alloc] initWithDuration: duration color: color] autorelease];
}

@end

#endif	// CC3_CC2_CLASSIC


#pragma mark -
#pragma mark CCNode extension

@implementation CCNode (CC3)

-(CCScene*) asCCScene {
	CCScene *scene = [CCScene node];
	[scene addChild: self];
	return scene;
}

#if !CC3_CC2_RENDER_QUEUE

-(void) visit: (CCRenderer*) renderer parentTransform: (const GLKMatrix4*)parentTransform {
	[self visit];
}

#endif	// !CC3_CC2_RENDER_QUEUE

#if CC3_CC2_CLASSIC

-(void) contentSizeChanged {}

-(BOOL) isRunningInActiveScene { return self.isRunning; }

-(BOOL) paused { return self.isRunning; }

-(void) setPaused: (BOOL) shouldPause {}

-(BOOL) isUserInteractionEnabled { return self.isTouchEnabled || self.isMouseEnabled; }

-(void) setUserInteractionEnabled: (BOOL) shouldEnable {
	self.touchEnabled = shouldEnable;
	self.mouseEnabled = shouldEnable;
}


#endif	// CC3_CC2_CLASSIC

#if !CC3_CC2_CLASSIC
-(void) scheduleUpdate {}
-(NSInteger) mousePriority { return 0; }
-(void) setMousePriority: (NSInteger) priority {}
-(BOOL) ignoreAnchorPointForPosition { return NO; }
-(void) setIgnoreAnchorPointForPosition: (BOOL) ignore {}
#endif	// !CC3_CC2_CLASSIC

#if CC3_CC2_3
-(CGSize) contentSizeInPixels {
	return CC_SIZE_SCALE(self.contentSize, CCDirector.sharedDirector.contentScaleFactor);
}

-(CGRect) boundingBoxInPixels {
	return CC_RECT_SCALE(self.boundingBox, CCDirector.sharedDirector.contentScaleFactor);
}
#endif	// CC3_CC2_3
#if CC3_CC2_2
-(CGSize) contentSizeInPixels { return CC_SIZE_POINTS_TO_PIXELS(self.contentSize); }

-(CGRect) boundingBoxInPixels { return CC_RECT_POINTS_TO_PIXELS(self.boundingBox); }
#endif	// CC3_CC2_2

#if CC3_CC2_1
-(CGPoint) anchorPointInPoints { return ccpCompMult(ccpFromSize(self.contentSize), self.anchorPoint); }
-(BOOL) ignoreAnchorPointForPosition { return !self.isRelativeAnchorPoint; }
-(void) setIgnoreAnchorPointForPosition: (BOOL) ignore { self.isRelativeAnchorPoint = !ignore; }
#endif	// !CC3_CC2_1

-(BOOL) isTouchEnabled { return NO; }

-(void) setTouchEnabled: (BOOL) touchEnabled {}

-(BOOL) isMouseEnabled { return NO; }

-(void) setMouseEnabled: (BOOL) isMouseEnabled {}

#if CC3_CC2_3
-(CGRect) globalBoundingBoxInPixels {
	CGSize cs = self.contentSize;
	CGRect rect = CGRectMake(0, 0, cs.width, cs.height);
	rect = CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
	return CC_RECT_SCALE(rect, CCDirector.sharedDirector.contentScaleFactor);
}
#endif	// CC3_CC2_3
#if CC3_CC2_2
-(CGRect) globalBoundingBoxInPixels {
	CGSize cs = self.contentSize;
	CGRect rect = CGRectMake(0, 0, cs.width, cs.height);
	rect = CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
	return CC_RECT_POINTS_TO_PIXELS(rect);
}
#endif	// CC3_CC2_2
#if CC3_CC2_1	// Under cocos2d 1.x, don't Retina-scale rect origin!
-(CGRect) globalBoundingBoxInPixels {
	CGSize cs = self.contentSize;
	CGRect rect = CGRectMake(0, 0, cs.width, cs.height);
	rect = CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
	rect.size.width *= CCDirector.sharedDirector.contentScaleFactor;
	rect.size.height *= CCDirector.sharedDirector.contentScaleFactor;
	return rect;
}
#endif	// CC3_CC2_1

-(void) updateViewport { [self.children makeObjectsPerformSelector:@selector(updateViewport)]; }

-(CGPoint) cc3ConvertUIPointToNodeSpace: (CGPoint) viewPoint {
	CGPoint glPoint = [[CCDirector sharedDirector] convertToGL: viewPoint];
	return [self convertToNodeSpace: glPoint];
}

-(CGPoint) cc3ConvertNodePointToUISpace: (CGPoint) glPoint {
	CGPoint gblPoint = [self convertToWorldSpace: glPoint];
	return [[CCDirector sharedDirector] convertToUI: gblPoint];
}

-(CGPoint) cc3ConvertUIMovementToNodeSpace: (CGPoint) uiMovement {
	switch ( CCDirector.sharedDirector.deviceOrientation ) {
		case UIDeviceOrientationLandscapeLeft:
			return ccp( uiMovement.y, uiMovement.x );
		case UIDeviceOrientationLandscapeRight:
			return ccp( -uiMovement.y, -uiMovement.x );
		case UIDeviceOrientationPortraitUpsideDown:
			return ccp( -uiMovement.x, uiMovement.y );
		case UIDeviceOrientationPortrait:
		default:
			return ccp( uiMovement.x, -uiMovement.y );
	}
}

-(CGPoint) cc3NormalizeUIMovement: (CGPoint) uiMovement {
	CGSize cs = self.contentSize;
	CGPoint glMovement = [self cc3ConvertUIMovementToNodeSpace: uiMovement];
	return ccp(glMovement.x / cs.width, glMovement.y / cs.height);
}

/**
 * Based on cocos2d Gesture Recognizer ideas by Krzysztof Zabłocki at:
 * http://www.merowing.info/2012/03/using-gesturerecognizers-in-cocos2d/
 */
-(BOOL) cc3WillConsumeTouchEventAt: (CGPoint) viewPoint {
	
	if (self.isUserInteractionEnabled &&
		self.visible &&
		self.isRunningInActiveScene &&
		[self cc3ContainsTouchPoint: viewPoint] ) return YES;
	
	id myKids = self.children;		// Covers both NSArray & CCArray
	for (CCNode* child in myKids)
		if ( [child cc3WillConsumeTouchEventAt: viewPoint] ) return YES;

	LogTrace(@"%@ will NOT consume event at %@", [self class], NSStringFromCGPoint(viewPoint));

	return NO;
}

-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint {
	CGPoint nodePoint = [self cc3ConvertUIPointToNodeSpace: viewPoint];
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	if (CGRectContainsPoint(nodeBounds, nodePoint)) {
		LogTrace(@"%@ will consume event at %@ in bounds %@",
					  [self class],
					  NSStringFromCGPoint(nodePoint),
					  NSStringFromCGRect(nodeBounds));
		return YES;
	}
	return NO;
}

#if CC3_IOS
-(BOOL) cc3ValidateGesture: (UIGestureRecognizer*) gesture {
	if ( [self cc3WillConsumeTouchEventAt: gesture.location] ) {
		[gesture cancel];
		return NO;
	} else {
		return YES;
	}
}
#endif	// CC3_IOS

-(CGPoint) cc3ConvertNSEventToNodeSpace: (NSEvent*) event {
#if CC3_OSX
	return [self convertToNodeSpace: [CCDirector.sharedDirector convertEventToGL: event]];
#else
	return CGPointZero;
#endif	// CC3_OSX
}

#if (COCOS2D_VERSION < 0x030100)
-(void) viewDidResizeTo: (CGSize) newViewSize {
	for (CCNode* child in self.children) [child viewDidResizeTo: newViewSize];
}
#endif	// (COCOS2D_VERSION < 0x030100)

@end


#pragma mark -
#pragma mark CCLayer extension

@implementation CCLayer (CC3)

-(CC3ViewController*) controller {
#if (CC3_IOS && !CC3_CC2_1)
	CC3ViewController* vc = (CC3ViewController*)(CCDirector.sharedDirector);
	if ( [vc isKindOfClass: [CC3ViewController class]] ) return vc;
#endif	// (CC3_IOS && !CC3_CC2_1)
	return nil;
}

-(CCGLView*) view { return (CCGLView*)self.controller.view; }

+(id) layer { return [[[self alloc] init] autorelease]; }

/** Invoke callbacks when size changes. */
-(void) setContentSize: (CGSize) aSize {
	CGSize oldSize = self.contentSize;
	[super setContentSize: aSize];
	if( !CGSizeEqualToSize(aSize, oldSize) ) {
		[self didUpdateContentSizeFrom: oldSize];	// Legacy callback support
#if CC3_CC2_CLASSIC
		[self contentSizeChanged];					// Invoked by super in Cocos2D v3
#endif	// CC3_CC2_CLASSIC
	}
}

// Deprecated
-(void) didUpdateContentSizeFrom: (CGSize) oldSize {}

#if CC3_CC2_CLASSIC

#if CC3_IOS
-(NSInteger) mousePriority { return 0; }
-(void) setMousePriority: (NSInteger) priority {}
#endif	// CC3_IOS

#if (COCOS2D_VERSION < 0x020100)
-(void) setTouchEnabled: (BOOL) isTouchEnabled { self.isTouchEnabled = isTouchEnabled; }

#if CC3_OSX
-(void) setMouseEnabled: (BOOL) isMouseEnabled { self.isMouseEnabled = isMouseEnabled; }
-(NSInteger) mousePriority { return 0; }
-(void) setMousePriority: (NSInteger) priority {}
#endif	// CC3_OSX

#endif	// (COCOS2D_VERSION < 0x020100)

#endif	// CC3_CC2_CLASSIC

@end


#pragma mark -
#pragma mark CCScene extension

@implementation CCScene (CC3)

-(CCScene*) asCCScene { return self; }

/** Invoke callbacks when size changes. */
#if CC3_CC2_CLASSIC
-(void) setContentSize: (CGSize) aSize {
	CGSize oldSize = self.contentSize;
	[super setContentSize: aSize];
	if( !CGSizeEqualToSize(aSize, oldSize) ) {
		[self contentSizeChanged];					// Invoked by super in Cocos2D v3
	}
}
#endif	// CC3_CC2_CLASSIC

@end


#if CC3_CC2_CLASSIC

#pragma mark -
#pragma mark CCSprite extension

@implementation CCSprite (CC3)

+(id) spriteWithImageNamed: (NSString*) fileName { return [self spriteWithFile: fileName]; }

@end


#pragma mark -
#pragma mark CCMenu extension

@implementation CCMenu (CC3)

-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint {
	id myKids = self.children;		// Covers both NSArray & CCArray
	for (CCNode* child in myKids)
		if ( [child cc3ContainsTouchPoint: viewPoint] ) return YES;
	return NO;
}

@end


#pragma mark -
#pragma mark CCMenu extension

@implementation CCMenuItemImage (CC3)
#if CC3_CC2_1
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 {
	return [self itemFromNormalImage:value selectedImage:value2];
}
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s {
	return [self itemFromNormalImage:value selectedImage:value2 target:r selector:s];
}
#endif
@end

#endif	// CC3_CC2_CLASSIC


#pragma mark -
#pragma mark CCDirector extension

#if COCOS2D_VERSION < 0x020100
#	define CC2_DT dt
#	define CC2_FRAME_RATE frameRate_
#	define CC2_RUNNING_SCENE runningScene_
#	define CC2_NEXT_SCENE nextScene_
#	define CC2_LAST_DISPLAY_TIME lastDisplayTime_
#else
#	define CC2_DT _dt
#	define CC2_FRAME_RATE _frameRate
#	define CC2_RUNNING_SCENE _runningScene
#	define CC2_NEXT_SCENE _nextScene
#	define CC2_LAST_DISPLAY_TIME _lastDisplayTime
#endif

#if !CC3_IOS
#	undef CC2_LAST_DISPLAY_TIME
#	define CC2_LAST_DISPLAY_TIME 0
#endif

@implementation CCDirector (CC3)

-(CCGLView*) ccGLView { return (CCGLView*)self.view; }

-(void) setCcGLView: (CCGLView*) ccGLView { self.view = ccGLView; }

-(CCTime) frameInterval { return CC2_DT; }

-(CCTime) frameRate { return CC2_FRAME_RATE; }

-(BOOL) hasScene { return !((CC2_RUNNING_SCENE == nil) && (CC2_NEXT_SCENE == nil)); }

-(NSTimeInterval) displayLinkTime { return [NSDate timeIntervalSinceReferenceDate]; }

#if CC3_CC2_1
-(void) setDisplayStats: (BOOL) displayFPS { [self setDisplayFPS: displayFPS]; }

-(CCGLView*) view { return (CCGLView*)self.openGLView; }

-(void) setView: (CCGLView*) view { self.openGLView = (CCGLView*)view; }

-(CCActionManager*) actionManager { return CCActionManager.sharedManager; }

#if CC3_IOS
-(CCTouchDispatcher*) touchDispatcher { return CCTouchDispatcher.sharedDispatcher; }
#endif	// CC3_IOS

-(CCScheduler*) scheduler { return CCScheduler.sharedScheduler; }

#if COCOS2D_VERSION < 0x010100
-(void) setRunLoopCommon: (BOOL) common {}
#endif

#endif	// CC3_CC2_1

#if !CC3_CC2_1
-(UIDeviceOrientation) deviceOrientation { return UIDeviceOrientationPortrait; }
#endif	// !CC3_CC2_1

#if CC3_CC2_CLASSIC

-(CGFloat) contentScaleFactor { return CC_CONTENT_SCALE_FACTOR(); }

-(void) setContentScaleFactor: (CGFloat) contentScaleFactor {}

-(CGSize) designSize { return self.winSize; }


#endif	//CC3_CC2_CLASSIC

@end


#if CC3_OGLES_1

#pragma mark -
#pragma mark CCDirectorIOS extension

@implementation CCDirectorIOS (CC3)

/**
 * Overridden to use a different font file (fps_images_1.png) when using cocos2d 1.x.
 *
 * Both cocos2d 1.x & 2.x use a font file named fps_images.png, which are different and
 * incompatible with each other. This allows a project to include both versions of the file,
 * and use the font file version that is appropriate for the cocos2d version.
 */
-(void) setGLDefaultValues {

#if CC_DIRECTOR_FAST_FPS
    if (!FPSLabel_) {
		CCTexture2DPixelFormat currentFormat = [CCTexture defaultAlphaPixelFormat];
		[CCTexture setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		FPSLabel_ = [[CCLabelAtlas labelWithString: @"00.0"
									   charMapFile: @"fps_images_1.png"
										 itemWidth: 16
										itemHeight: 24
									  startCharMap:'.'] retain];
		[CCTexture setDefaultAlphaPixelFormat:currentFormat];
	}
#endif	// CC_DIRECTOR_FAST_FPS

	[super setGLDefaultValues];
}

@end

#endif		// CC3_OGLES_1


#if CC3_OSX

#pragma mark -
#pragma mark CCDirectorMac extension

@implementation CCDirectorMac (CC3)

#if (COCOS2D_VERSION < 0x030100)
-(void) reshapeProjection: (CGSize) newViewSize {
	[super reshapeProjection: newViewSize];
	if (self.resizeMode == kCCDirectorResize_NoScale)
		[self.runningScene viewDidResizeTo: newViewSize];
}
#endif	// (COCOS2D_VERSION < 0x030100)

@end

#endif		// CC3_OSX


#pragma mark -
#pragma mark CCDirectorDisplayLink extension

@implementation CCDirectorDisplayLink (CC3)

#if !CC3_CC2_1
-(NSTimeInterval) displayLinkTime { return CC2_LAST_DISPLAY_TIME; }
#endif

#if (COCOS2D_VERSION < 0x030100)
-(void) reshapeProjection: (CGSize) newViewSize {
	[super reshapeProjection: newViewSize];
	[self.runningScene viewDidResizeTo: newViewSize];
}
#endif	// (COCOS2D_VERSION < 0x030100)

/** Uncomment to log a debug message whenever the frame time is unexpectedly extended. */
//-(void) drawScene {
//	NSTimeInterval tooSlow = 0.0667;	// 15 fps - change as you like
//	MarkDebugActivityStart();
//	[super drawScene];
//	NSTimeInterval drawDur = GetDebugActivityDuration();
//	if (drawDur > tooSlow)
//		LogDebug(@"Slow scene update and draw in %.3f ms (%.1f fps)",
//				 drawDur * 1000.0, 1.0 / drawDur);
//}

@end


#pragma mark -
#pragma mark CCScheduler extension

@implementation CCScheduler (CC3)

#if !CC3_CC2_CLASSIC
-(void) pauseTarget:(id)target { [self setPaused: YES target: target]; }

-(void) resumeTarget:(id)target { [self setPaused: NO target: target]; }
#endif	// !CC3_CC2_CLASSIC

@end


#pragma mark -
#pragma mark CCFileUtils extension

/** Extension category to support cocos3d functionality. */
@implementation CCFileUtils (CC3)

#if CC3_CC2_1
+(Class) sharedFileUtils { return self; }
#endif

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functions

NSString* NSStringFromTouchType(uint tType) {
	switch (tType) {
		case kCCTouchBegan:
			return @"kCCTouchBegan";
		case kCCTouchMoved:
			return @"kCCTouchMoved";
		case kCCTouchEnded:
			return @"kCCTouchEnded";
		case kCCTouchCancelled:
			return @"kCCTouchCancelled";
		default:
			return [NSString stringWithFormat: @"unknown touch type (%u)", tType];
	}
}

