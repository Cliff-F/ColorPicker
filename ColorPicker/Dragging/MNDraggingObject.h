//
//  MNDraggingWindow.h
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MNDraggingProtocol.h"
#import "DraggingTooltipView.h"


@class MNDraggingLayer, MNDragGestureRecognizer;

@interface MNDraggingObject : NSObject <CAAnimationDelegate> {
	
	// Dragging properties
	
@public
	NSMutableDictionary* mUserInfo;
	UIView <MNDraggingSource> *mSource; 
	UIView <MNDraggingDestination> *mDestination; 

	UIViewController* parentViewController_;
	
	
	
	BOOL mLimitedInSource;
	
	CGPoint	mInitialDraggingLocation;
	CGPoint mInitialSourceOrigin;
	CGPoint	mLocation;
	BOOL animateDropping_;
	BOOL success_;

@private
	MNDraggingLayer *mDraggingLayer;
	
	BOOL isEnding;
	CGSize mImageOffset;
	CGPoint mSlidebackOrigin;
	
	
//	NSTimer *selfDestructionTimer;
	
	
	UIImage* originalImage;
	CGPoint originalImageLocation;
	
	BOOL isTemporaryImage_;
	
}
+(void)clearDraggingInWindow:(UIWindow*)window;
- (id) init;
-(void)dealloc;
-(void)setInitialDraggingLocation:(CGPoint)point;
-(void)setSource:(UIView<MNDraggingSource> *)source;
-(void)setLocation:(CGPoint)point;
-(void)setDraggingImage:(UIImage*)draggingImage location:(CGPoint)origin ;
-(void)setTemporaryDraggingImage:(UIImage*)draggingImage offset:(CGPoint)offsetFromLocation ;
-(void)restoreDraggingImage;
-(void)setDraggingImage:(UIImage*)draggingImage location:(CGPoint)origin inView:(UIView*)view;
-(CGPoint)locationInView:(UIView*)view;
-(void)appearAnimation;
-(void)dropAnimation;
-(void)setSlidebackLocation:(CGPoint)location ;
-(void)adjustSlidebackLocation;
-(void)slideback;
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
-(void)concludeDragging:(BOOL)success ;


@property (nonatomic, assign) MNDragGestureRecognizer* dragGesture;

@property (nonatomic, readonly) CALayer *draggingLayer;

@property ( nonatomic,readwrite) CGPoint initialDraggingLocation;
@property ( nonatomic,readwrite) CGPoint location;
@property ( nonatomic,readwrite) BOOL limitedInSource;
@property ( nonatomic,readwrite) BOOL animateDropping;

@property (nonatomic, assign) UIView <MNDraggingSource> *source; 
@property (nonatomic, retain) UIView <MNDraggingDestination> *destination; 
@property (nonatomic, readonly) NSMutableDictionary* userInfo;
@property (nonatomic, readonly) CGSize imageOffset;

@property (nonatomic, retain) UIViewController* parentViewController;

@property (nonatomic, readonly) BOOL success;

@end



