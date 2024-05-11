//
//  MNDragGestureRecognizer.m
//  TuiFramework
//
//  Created by Nishikata Masatoshi on 13/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNDragGestureRecognizer.h"
#import "MNDraggingObject.h"
#import "DraggingTooltipView.h"
#import <AVFoundation/AVFoundation.h>
#define DIFPOINTS(n1,n2) CGPointMake( n2.x - n1.x, n2.y - n1.y)
#define ADDPOINTS(n1,n2) CGPointMake( n2.x + n1.x, n2.y + n1.y)
#define CGPOINTINTEGRATE(n) CGPointMake( roundf(n.x), roundf(n.y))
#define DISTANCE(n) sqrtf( n.x*n.x + n.y*n.y )


NSString* MNDraggingSourceViewChangedNotificationName = @"MNDraggingSourceViewChanged";
NSString* MNDraggingCancelNotificationName = @"MNSyncWillResetNotificationName";


@implementation MNDragGestureRecognizer
//@synthesize parentViewController = parentViewController_;

@synthesize draggingObject = mDraggingObject;

- (id)initWithTarget:(id)target action:(SEL)action; {
    self = [super initWithTarget:(id)target action:(SEL)action];
    if (self) {
        
		allowableMovement = 20;
		minimumPressDuration_ = 0.5;
		minimumHintDuration_ = 0.25;
		
		[[NSNotificationCenter defaultCenter] addObserver: self
															  selector: @selector(update)
																	name: MNDraggingSourceViewChangedNotificationName
																 object: nil];

//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
															  selector: @selector(cancel)
																	name: MNDraggingCancelNotificationName
																 object: nil];
    }
    return self;
}

-(void)update
{
	if( self.state == UIGestureRecognizerStateChanged )
	{
		self.state = UIGestureRecognizerStateChanged;
	}
}

-(void)cancel
{
	self.state = UIGestureRecognizerStateCancelled;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mDraggingObject release];
	mDraggingObject = nil;
	
	[self resetTimer];
	
	[super dealloc];	
}

-(void)resetTimer
{
	[hintTimer invalidate];
	[hintTimer release];
	hintTimer = nil;
	
	[nagaoshiTimer invalidate];
	[nagaoshiTimer release];
	nagaoshiTimer = nil;
}

-(void)nagaoshi:(NSTimer*)timer
{
	
	self.state = UIGestureRecognizerStateBegan;
	
	[nagaoshiTimer release];
	nagaoshiTimer = nil;
}



-(void)hint:(NSTimer*)timer
{
	[hintTimer release];
	hintTimer = nil;
	
	self.state = UIGestureRecognizerStatePossible;
	
}

-(CGPoint)locationInView:(UIView*)aView
{
	if( aView == self.view ) return lastLocationInView;
	
	return [self.view convertPoint:lastLocationInView toView:aView];
}


-(CGPoint)location
{
	if( [self.view isKindOfClass:[UIWindow class]] ) return lastLocationInView;
	
	return [self.view convertPoint:lastLocationInView toView: mDraggingObject.parentViewController.view];
}

-(BOOL)lookForDestinationAt:(CGPoint)fingerLocation
{
	if( mDraggingObject.limitedInSource ){
		mDraggingObject.destination = nil;	
		return YES;
	}
	
	
	UIView  *destination = nil;
	destination = [ mDraggingObject.parentViewController.view hitTest: fingerLocation withEvent:nil];
	
	
	while( destination && ![destination conformsToProtocol:@protocol(MNDraggingDestination)] )
	{
		destination = destination.superview;
		
	}
	
	
	BOOL onSource = NO;
	BOOL canAccept = YES;
	if( [destination respondsToSelector:@selector(canAcceptDraggingObject:) ] )
	{
		canAccept = [(UIView  <MNDraggingDestination> *)destination canAcceptDraggingObject: mDraggingObject];
	}
	
	if( canAccept )
	{
		mDraggingObject.destination = (UIView  <MNDraggingDestination> *)destination;
	}
	else 
	{
		if( destination == mDraggingObject.source ) onSource = YES;
		mDraggingObject.destination = nil;
	}
	
	return onSource;
}

-(UIGestureRecognizerState)state
{
	return [super state];	
}

-(void)setState: (UIGestureRecognizerState)aState
{
	void(^finalizeDragging)(BOOL) = ^(BOOL success)
	{
		if( success ) [super setState: UIGestureRecognizerStateEnded];
		else  [super setState: UIGestureRecognizerStateCancelled];
		
		if( dragBegan )
			[[NSNotificationCenter defaultCenter] postNotificationName:MNDraggingDraggingEndedNotificationName object:nil];
		
		[mDraggingObject concludeDragging: success];
		
		[mDraggingObject release];
		mDraggingObject = nil;
		dragBegan = NO;
		
		[self reset];
	};
	
	CGPoint location  = [self location];
	mDraggingObject.location = location;
	
	if( [mDraggingObject.destination respondsToSelector:@selector(draggingObject:locationInView:imageOffsetFromLocation:)] )
	{
		CGPoint locationInView = [mDraggingObject.destination convertPoint:location fromView:mDraggingObject.parentViewController.view];
		CGPoint newLocationInView =  [mDraggingObject.destination draggingObject: mDraggingObject 
																  locationInView: locationInView 
														 imageOffsetFromLocation:mDraggingObject.imageOffset];
		
		mDraggingObject.location = [mDraggingObject.destination convertPoint:newLocationInView toView: mDraggingObject.parentViewController.view];
	}
	
	if( aState == UIGestureRecognizerStatePossible )
	{
		 [super setState: aState];

		//		CGPoint p0 = [self locationInWindow];
		//		UIImage* image = [UIImage imageNamed:@"TuiResources.bundle/Contents/Resources/hint.png"];
		//		
		//		p0.x -= image.size.width/3;
		//		p0.y -= image.size.height/3;
		//
		//		
		//		[mDraggingObject setDraggingImage: image
		//						 locationInWindow:p0];
		if( [mDraggingObject.source respondsToSelector:@selector(willBeginDraggingSoon:)] )
		{
			[mDraggingObject.source willBeginDraggingSoon: mDraggingObject];
		}
	}
	
	else if( aState == UIGestureRecognizerStateBegan )
	{
		[super setState: aState];

		// Began
		
//		if( [self.view.superview isKindOfClass:[UIScrollView class]] )
//			[(UIScrollView*)self.view.superview setCanCancelContentTouches:NO];
		
		
		dragBegan = YES;
		
		if( [mDraggingObject.source respondsToSelector:@selector(beganDragging:)] )
		{
			[mDraggingObject.source beganDragging: mDraggingObject];
		}
		[mDraggingObject appearAnimation];
    AudioServicesPlaySystemSound(1519);

		[[NSNotificationCenter defaultCenter] postNotificationName:MNDraggingDraggingStartedNotificationName 
															object:nil];
	}
	
	else if( aState == UIGestureRecognizerStateChanged )
	{
		[super setState: aState];
		
		UIView <MNDraggingDestination> *destBuffer = [[mDraggingObject.destination retain] autorelease];
		BOOL onSource =	[self lookForDestinationAt: [self locationInView: mDraggingObject.parentViewController.view]];
		
		// Send exit , enter  or update message
		if( mDraggingObject.destination != destBuffer )
		{

			if( destBuffer && [destBuffer respondsToSelector:@selector(draggingObjectExited:)] )
			{
				[destBuffer draggingObjectExited:mDraggingObject];
			}
			
			if( mDraggingObject.destination && [mDraggingObject.destination respondsToSelector:@selector(draggingObjectEntered:)] )
			{
				[mDraggingObject.destination draggingObjectEntered:mDraggingObject];
			}
		}
		else if( mDraggingObject.destination )
		{
			if( mDraggingObject.destination && [mDraggingObject.destination respondsToSelector:@selector(draggingDestinationUpdated:)] )
			{
				[mDraggingObject.destination draggingDestinationUpdated:mDraggingObject];
			}
		}
				
		if( [mDraggingObject.source respondsToSelector:@selector(draggingSourceUpdated:)] )
		{
			[mDraggingObject.source draggingSourceUpdated: mDraggingObject];
		}
		
		if( !onSource && !mDraggingObject.destination )
		{
//			DraggingTooltipView *tooltip = [mDraggingObject.userInfo objectForKey:@"tooltip"];
//
//			[tooltip showDraggingTooltipAt:mDraggingObject.location
//									inView:mDraggingObject.parentViewController.view 
//								   message:NSLocalizedString(@"Cancel" , @"")
//									  type:TooltipViewInformation
//								afterDelay:0];
		}
	}
	
	else if( aState == UIGestureRecognizerStateEnded  )
	{
		// Ask destination and decide end or cancelled
		
		// Customize snapback
		// 1. Current latest point
		
		[mDraggingObject adjustSlidebackLocation];
		
		// 2.
		
		if( [mDraggingObject.source respondsToSelector:@selector(draggingObject:needsCustomSlideBackPointInView:)] )
		{
			CGPoint pointInView = CGPointZero;
			BOOL needsCustomLocation = [mDraggingObject.source draggingObject: mDraggingObject needsCustomSlideBackPointInView: &pointInView];
			
			if( needsCustomLocation )
			{
				CGSize imageOffset = mDraggingObject.imageOffset;
				CGPoint imageOrigin = CGPointMake(pointInView.x + imageOffset.width, pointInView.y + imageOffset.height);
				
				[mDraggingObject setSlidebackLocation: [mDraggingObject.source convertPoint:imageOrigin toView: mDraggingObject.parentViewController.view]] ;
			}
		}	
		
		if( [mDraggingObject.destination respondsToSelector:@selector(draggingObjectDidDrop:onCompletion:)] )
		{
			[super setState: UIGestureRecognizerStateChanged]; // Pending
			
			[mDraggingObject.destination draggingObjectDidDrop: mDraggingObject
												  onCompletion: finalizeDragging];
			
		}else 
		{	
			
			BOOL success = mDraggingObject.destination? YES:NO;
      
      if( success ) [super setState: UIGestureRecognizerStateEnded];
      else [super setState: UIGestureRecognizerStateCancelled];
      
      finalizeDragging(success);
      dragBegan = NO;
    }
    
    //Finishing
    
    //		if( deferRemovingFromSuperview_ )
    //		{
    //			deferRemovingFromSuperview_ = NO;
    //			[self removeFromSuperview];
    //		}
  }
  
  else if( aState == UIGestureRecognizerStateCancelled || aState == UIGestureRecognizerStateFailed )
  {
    //if( [self state] >= UIGestureRecognizerStateBegan )
    {
      [mDraggingObject restoreDraggingImage];
      
      // cancel
      
      finalizeDragging(NO);
      
      dragBegan = NO;
    }
    
    [super setState: aState];
  }
  else
  {
    [super setState: aState];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%@ %@ %d",NSStringFromClass([self class]), NSStringFromSelector( _cmd ), __LINE__);
	
	// Ignore multiple touch
	if( [touches count] > 1 || self.state >= UIGestureRecognizerStateBegan )
	{
		for( UITouch* touch in touches )
		{
			[self ignoreTouch: touch forEvent:event];
		}
		
		return;
	}
	
	initialLocationInView = [(UITouch*)[touches anyObject] locationInView:self.view];
	lastLocationInView = initialLocationInView;
	
	self.state = UIGestureRecognizerStatePossible;
	
	[self resetTimer];
	
	BOOL result = [(UIView <MNDraggingSource> *)self.view canBeginDragging: initialLocationInView];
	
	if( result )
	{
		mDraggingObject = [[MNDraggingObject alloc] init];

		mDraggingObject.parentViewController = self.parentViewController;
		
		mDraggingObject.dragGesture = self;
		// Set location
		
		mDraggingObject.initialDraggingLocation = [self location];
		mDraggingObject.source = (UIView <MNDraggingSource> *)self.view;
	}
	else {
		for( UITouch* touch in touches )
		{
			[self ignoreTouch: touch forEvent:event];
		}
		return;
	}
	
	if( [(UIView <MNDraggingSource> *)self.view canBeginDraggingImmediately: initialLocationInView] )
	{
		[super touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event];
		
		self.state = UIGestureRecognizerStatePossible;
		[self nagaoshi:nil];
		
	}else
	{
		hintTimer = [NSTimer scheduledTimerWithTimeInterval: minimumHintDuration_ target:self selector:@selector(hint:) userInfo:nil repeats:NO];
		[hintTimer retain];
		
		nagaoshiTimer = [NSTimer scheduledTimerWithTimeInterval:minimumPressDuration_ target:self selector:@selector(nagaoshi:) userInfo:nil repeats:NO];
		[nagaoshiTimer retain];
		
		[super touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event];
	}
}

-(BOOL)overAllowableMovement
{
	CGPoint location = [self locationInView:self.view];
	
	CGFloat distance = sqrtf( powf( initialLocationInView.x-location.x, 2 )  + powf( initialLocationInView.y-location.y , 2));
	if( distance > allowableMovement ) return YES;
	
	return NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//	if( touchHash == 0 )
//	{
//		[super touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event];
//		return;	
//	}
	
	if( nagaoshiTimer )
	{
		if( [self overAllowableMovement] && self.state !=  UIGestureRecognizerStateCancelled )
		{
			[self resetTimer];
			self.state = UIGestureRecognizerStateCancelled;
		}
		
	}else {
		self.state = UIGestureRecognizerStateChanged;
	}
	
	if( self.state <= UIGestureRecognizerStateChanged )
	{
		for( UITouch *aTouch in touches )
		{
			
			if( [[aTouch gestureRecognizers] containsObject:self] )
			{
				lastLocationInView = [aTouch locationInView:self.view];
				break;
			}
		}
	}
	
	[super touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
//	BOOL myTouch = NO;
//	for( UITouch *touch in touches )
//	{
//		if( touchHash == [touch hash] )
//		{
//			myTouch = YES;
//			break;
//		}
//	}
//	
//	if( !myTouch )
//	{
//		[super touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
//		return;	
//	}
//	
	if( nagaoshiTimer )
	{
		[self resetTimer];
		self.state = UIGestureRecognizerStateFailed;
	}
	else if( self.state !=  UIGestureRecognizerStateCancelled && 
			self.state != UIGestureRecognizerStateFailed &&
			self.state != UIGestureRecognizerStateEnded  )
	{
		self.state = UIGestureRecognizerStateEnded;
	}
	
	[super touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{

//	BOOL myTouch = NO;
//	for( UITouch *touch in touches )
//	{
//		if( touchHash == [touch hash] )
//		{
//			myTouch = YES;
//			break;
//		}
//	}
//	
//	if( !myTouch )
//	{
//		[super touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event];
//		return;
//	}
//	
	
	[self resetTimer];
	if( self.state != UIGestureRecognizerStateFailed &&
	   self.state != UIGestureRecognizerStateEnded ) 
	{
		NSLog(@"dragging cancelled");
		
		self.state = UIGestureRecognizerStateCancelled;
	}
	[super touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event];
}

- (void)reset
{
	[super reset];
	
	[self resetTimer];
	[mDraggingObject release];
	mDraggingObject = nil;
	dragBegan = NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	if( self.state >= UIGestureRecognizerStateChanged ) return NO;
	
	return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
  if( self.state >= UIGestureRecognizerStateChanged )
  {
    return YES;
  }else {
    
    return NO;
  }
}
@end
