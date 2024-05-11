//
//  DragGestureRecognizer.m
//  DragGesture
//
//  Created by Masatoshi Nishikata on 30/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MNDraggingSourceView.h"
#import "MNDraggingObject.h"
#import "DraggingTooltipView.h"
#import "MNDragGestureRecognizer.h"

@implementation MNDraggingSourceView



#pragma mark - Setup

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:(CGRect)frame];
	if (self != nil) {
		[self setup];
	}
	return self;
}

-(void)awakeFromNib
{
	[self setup];
	[super awakeFromNib];	
}

-(void)setup
{
	
	if( [self hasGestureRecognizer] )
	{
		dragGesture = [[[MNDragGestureRecognizer alloc] initWithTarget:nil action:nil] autorelease];
		[self addGestureRecognizer: dragGesture];

	}
	
	[[NSNotificationCenter defaultCenter] addObserver: self
														  selector: @selector(viewControllerWillMove:)
																name: @"MNSplitViewControllerWillChangeView"
															 object: nil];
	
}


-(void)dealloc
{
	dragGesture = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(void)viewControllerWillMove:(NSNotification*)notification
{
	if( deferRemovingFromSuperview_ ) return;
	if( !self.window ) return;
	
	UIViewController* object = [notification object];
	
	UIView* mySuperview = self;
	BOOL isChild = NO;
	
	while( mySuperview )
	{

		if( mySuperview == object.view )
		{
			isChild = YES;
			break;
		}
		mySuperview = mySuperview.superview;
	}
	
	
	if( !isChild ) return;
	
	// 未だドラッグ中なら、場所を移して透明化する
		  
	UIGestureRecognizerState state = dragGesture.state;
	
	
	if( ( state == UIGestureRecognizerStateBegan) || (state == UIGestureRecognizerStateChanged) )
	{
		
		deferRemovingFromSuperview_ = YES;
		
		self.hidden = YES;
		[dragGesture.draggingObject.parentViewController.view.window addSubview: self];
		

		return;	
	}
}

-(void)removeFromSuperview
{
	
	// 未だドラッグ中なら、場所を移して透明化する
	
	UIGestureRecognizerState state = dragGesture.state;

	if( ( state == UIGestureRecognizerStateBegan) || (state == UIGestureRecognizerStateChanged) )
	{
		
		deferRemovingFromSuperview_ = YES;
		
		self.hidden = YES;
		[dragGesture.draggingObject.parentViewController.view.window addSubview: self];

		return;	
	}
	
	
	
	[super removeFromSuperview];	

}


-(BOOL)hasGestureRecognizer
{
	return YES;
}


#pragma mark - Dragging Source

-(BOOL)canBeginDraggingImmediately:(CGPoint)locationInView
{
	return NO;
}
											
-(BOOL)canBeginDragging:(CGPoint)locationInView
{
	return YES;
}

// Tell source to begin.  Souce can change image 
-(void)beganDragging:(MNDraggingObject*)draggingObject
{
	
	//[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2.];
		
	
	CGPoint p0 = [draggingObject.dragGesture location];
	UIImage* image = [UIImage imageNamed:@"TuiResources.bundle/hint.png"];
	
	p0.x -= image.size.width/2;
	p0.y -= image.size.height/2;
	
	
	[draggingObject setDraggingImage: image
							 location:p0];
	
	
	DraggingTooltipView *tooltip = [draggingObject.userInfo objectForKey:@"tooltip"];
	
	[tooltip showDraggingTooltipAt: draggingObject.location
									inView: draggingObject.parentViewController.view
								  message: @"Dragging began"
									  type: TooltipViewInformation
							  afterDelay: 0];

	
}

// Source returns slideback point in window
-(BOOL)draggingObject:(MNDraggingObject*)draggingObject needsCustomSlideBackPointInView:(CGPoint*)pointPtr
{
	return NO;
}

// This method is called periodically
-(void)draggingSourceUpdated:(MNDraggingObject*)draggingObject
{
	if( !draggingObject.destination )
	{
		DraggingTooltipView *tooltip = [draggingObject.userInfo objectForKey:@"tooltip"];
		[tooltip showDraggingTooltipAt: draggingObject.location
										inView: draggingObject.parentViewController.view
									  message: @"Dragging..."
										  type: TooltipViewInformation
								  afterDelay: 0];
	}
	

}

// Tell source the results
-(void)concludeDragging:(MNDraggingObject*)draggingObject success:(BOOL)success
{
	DraggingTooltipView *tooltip = [draggingObject.userInfo objectForKey:@"tooltip"];
	[tooltip closeTooltip];
	
	if( deferRemovingFromSuperview_ )
	{
		deferRemovingFromSuperview_ = NO;
		[self removeFromSuperview];
	}

}

-(void)willBeginDraggingSoon:(MNDraggingObject*)draggingObject;
{
//	CGPoint p0 = [self location];
//	UIImage* image = [UIImage imageNamed:@"TuiResources.bundle/Contents/Resources/hint.png"];
//	
//	p0.x -= image.size.width/2;
//	p0.y -= image.size.height/2;
	
	
	//	[mDraggingObject setDraggingImage: image
	//					 location:p0];
	
	
	DraggingTooltipView *tooltip = [DraggingTooltipView  tooltip];
	[tooltip showDraggingTooltipAt: draggingObject.location
									inView: draggingObject.parentViewController.view
								  message: @"Hold to drag"
									  type: TooltipViewInformation
							  afterDelay: 0];
	
	[draggingObject.userInfo setObject:tooltip forKey:@"tooltip"];
	
}


@end
