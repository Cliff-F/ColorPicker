//
//  DragGestureRecognizer.h
//  DragGesture
//
//  Created by Masatoshi Nishikata on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNDraggingProtocol.h"


extern  NSString* MNDraggingSourceViewChangedNotificationName;
extern  NSString* MNDraggingCancelNotificationName;

@class MNDraggingObject, MNDragGestureRecognizer;

@interface MNDraggingSourceView : UIView <MNDraggingSource>{

	
	MNDragGestureRecognizer* dragGesture;

	BOOL deferRemovingFromSuperview_;

}
-(void)setup;
- (id) initWithFrame:(CGRect)frame;
-(void)awakeFromNib;
-(void)removeFromSuperview;
-(void)viewControllerWillMove:(NSNotification*)notification;
-(BOOL)hasGestureRecognizer;


//---
-(BOOL)canBeginDraggingImmediately:(CGPoint)locationInView;

//---
-(BOOL)canBeginDragging:(CGPoint)locationInView;

// Tell source to begin.  Souce can change image 
-(void)beganDragging:(MNDraggingObject*)draggingObject;

// Source returns slideback point in window
-(BOOL)draggingObject:(MNDraggingObject*)draggingObject needsCustomSlideBackPointInView:(CGPoint*)pointPtr;

// This method is called periodically
-(void)draggingSourceUpdated:(MNDraggingObject*)draggingObject;

// Tell source the results, return animation block when snapback or drop animation finished
-(void)concludeDragging:(MNDraggingObject*)draggingObject success:(BOOL)success;



@end


