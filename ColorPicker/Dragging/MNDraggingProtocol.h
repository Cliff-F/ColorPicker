//
//  MNDraggingProtocol.h
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MNDraggingDraggingStartedNotificationName @"MNDraggingDraggingStartedNotificationName"
#define MNDraggingDraggingEndedNotificationName @"MNDraggingDraggingEndedNotificationName"





@class MNDraggingObject;

@protocol MNDraggingSource

@optional

-(BOOL)canBeginDraggingImmediately:(CGPoint)locationInView;

-(BOOL)canBeginDragging:(CGPoint)locationInView;

-(void)willBeginDraggingSoon:(MNDraggingObject*)draggingObject;

// Tell source to begin.  Souce can change image 
-(void)beganDragging:(MNDraggingObject*)draggingObject;

// Source returns slideback point in window
-(BOOL)draggingObject:(MNDraggingObject*)draggingObject needsCustomSlideBackPointInView:(CGPoint*)pointPtr;

// This method is called periodically
-(void)draggingSourceUpdated:(MNDraggingObject*)draggingObject;

// Tell source the results
-(void)concludeDragging:(MNDraggingObject*)draggingObject success:(BOOL)success;

-(void)concludeDraggingAnimationDidStart:(MNDraggingObject*)draggingObject;

-(void)concludeDraggingAnimationDidFinish:(MNDraggingObject*)draggingObject;

@end



@protocol MNDraggingDestination

-(BOOL)canAcceptDraggingObject:(MNDraggingObject*)draggingObject;
-(void)draggingObjectEntered:(MNDraggingObject*)draggingObject;
-(void)draggingDestinationUpdated:(MNDraggingObject*)draggingObject;
-(void)draggingObjectExited:(MNDraggingObject*)draggingObject;
-(void)draggingObjectDidDrop:(MNDraggingObject*)draggingObject onCompletion:(void (^)(BOOL finished))blockToExecute;

@optional
-(CGPoint)draggingObject:(MNDraggingObject*)draggingObject locationInView:(CGPoint)point imageOffsetFromLocation:(CGSize)offset;

-(CGPoint)droppingDestination:(MNDraggingObject*)draggingObject;
-(CGFloat)droppingDestinationScale:(MNDraggingObject*)draggingObject;

-(void)concludeDroppingAnimationDidFinish:(MNDraggingObject*)draggingObject;

// Implement expensive process here

@end
