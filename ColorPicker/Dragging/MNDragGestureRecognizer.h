//
//  MNDragGestureRecognizer.h
//  TuiFramework
//
//  Created by Nishikata Masatoshi on 13/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNDraggingProtocol.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <UIKit/UIGestureRecognizer.h>


extern  NSString* _Nonnull MNDraggingSourceViewChangedNotificationName;
extern  NSString* _Nonnull MNDraggingCancelNotificationName;

@class MNDraggingObject;


@interface MNDragGestureRecognizer : UIGestureRecognizer
{
	
	CGFloat  allowableMovement;
	
	NSTimeInterval minimumPressDuration_;
	NSTimeInterval minimumHintDuration_;
	
	MNDraggingObject *mDraggingObject;

	
	
	NSTimer *nagaoshiTimer;
	NSTimer *hintTimer;
	
	CGPoint initialLocationInView;
	
//	NSUInteger touchHash;
	CGPoint lastLocationInView;
	BOOL dragBegan;
	

}
- (id _Nonnull)initWithTarget:(id _Nullable)target action:(SEL _Nullable)action; ;
-(void)cancel;
-(void)dealloc;
-(void)resetTimer;
-(void)nagaoshi:(NSTimer * _Nullable)timer;
-(void)hint:(NSTimer * _Nonnull)timer;
-(CGPoint)locationInView:(UIView * _Nullable)aView;
-(CGPoint)location;
-(BOOL)lookForDestinationAt:(CGPoint)fingerLocation;
-(UIGestureRecognizerState)state;
-(void)setState: (UIGestureRecognizerState)aState;
- (void)touchesBegan:(NSSet * _Nonnull)touches withEvent:(UIEvent * _Nonnull)event;
-(BOOL)overAllowableMovement;
- (void)touchesMoved:(NSSet * _Nonnull)touches withEvent:(UIEvent * _Nonnull)event;
- (void)touchesEnded:(NSSet * _Nonnull)touches withEvent:(UIEvent * _Nonnull)event;
- (void)touchesCancelled:(NSSet * _Nonnull)touches withEvent:(UIEvent * _Nonnull)event;;
- (void)reset;
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer * _Nonnull)preventingGestureRecognizer;
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer * _Nonnull)preventingGestureRecognizer;


//@property(nonatomic, retain) UIViewController* parentViewController;
@property(nonatomic,readwrite) UIGestureRecognizerState state;
@property(nonatomic,readonly) MNDraggingObject * _Nonnull draggingObject;
@property(nonatomic,weak) UIViewController * _Nullable parentViewController;


@end
