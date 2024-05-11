//
//  MNDraggingWindow.m
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MNDraggingObject.h"


@interface MNDraggingLayer : CALayer
{
	
}

@end

@implementation MNDraggingLayer


@end





@implementation MNDraggingObject


@synthesize draggingLayer = mDraggingLayer;

@synthesize initialDraggingLocation = mInitialDraggingLocation, location = mLocation;

@synthesize source = mSource, destination = mDestination;

@synthesize userInfo = mUserInfo;
@synthesize imageOffset = mImageOffset;

@synthesize limitedInSource = mLimitedInSource;
@synthesize animateDropping = animateDropping_;

@synthesize parentViewController = parentViewController_;
@synthesize dragGesture;
@synthesize success = success_;

+(void)clearDraggingInWindow:(UIWindow*)window
{
//	NSArray* sublayers = [window.layer sublayers];
	
	NSMutableArray *draggingLayer = [NSMutableArray array];
	for( CALayer *layer in [window.layer sublayers] )
	{
	
		if( [layer isKindOfClass:[MNDraggingLayer class]] )
		{
			[draggingLayer addObject: layer];
		}
	}
	
	[draggingLayer makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	 
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		mUserInfo = [[NSMutableDictionary alloc] init];
		mDraggingLayer = [[MNDraggingLayer layer] retain];
		
		mDraggingLayer.actions = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
		  [NSNull null], @"onOrderOut",
		  [NSNull null], @"sublayers",
		  //[NSNull null], @"contents",
		  [NSNull null], @"position",
								   nil] autorelease];
		animateDropping_ = YES;
		

	}
	return self;
}

-(void)dealloc
{
	[mUserInfo release];
	self.source = nil;
	self.destination = nil;

	if( mDraggingLayer.superlayer )
		[mDraggingLayer removeFromSuperlayer];
	   
   [mDraggingLayer release];
	mDraggingLayer = nil;
	
	[originalImage release];
	originalImage = nil;
	
	self.parentViewController = nil;
	
	[super dealloc];
}

-(void)setInitialDraggingLocation:(CGPoint)point
{
	mInitialDraggingLocation = point;
	mLocation = point;
	mSlidebackOrigin = point;
}

-(void)setSource:(UIView<MNDraggingSource> *)source
{
	if( mSource == source ) return;
	
	[mSource release];
	mSource = [source retain];
	
	CGPoint sourceOrigin = [self.source.superview convertPoint: self.source.frame.origin toView: self.parentViewController.view];

	mInitialSourceOrigin = sourceOrigin;
}

-(void)setLocation:(CGPoint)point
{
	mLocation = point;
	
	if( mDraggingLayer.superlayer && !isEnding )
	{
		mDraggingLayer.position = point;
	}
}

-(void)setDraggingImage:(UIImage*)draggingImage location:(CGPoint)origin
{
	if( originalImage != draggingImage )
	{
		[originalImage release];
		originalImage = [draggingImage retain];
	}	
	originalImageLocation = origin;
	
	if( isEnding ) return;
	
	[mDraggingLayer setContents: (id)draggingImage.CGImage];

	mImageOffset = CGSizeMake(  mLocation.x - origin.x, mLocation.y -  origin.y );

	mDraggingLayer.frame = CGRectMake(origin.x, origin.y, draggingImage.size.width, draggingImage.size.height);
	mDraggingLayer.anchorPoint = CGPointMake( mImageOffset.width / draggingImage.size.width, mImageOffset.height / draggingImage.size.height);

	mDraggingLayer.position = mLocation;
	
	[[self.parentViewController.view layer] addSublayer: mDraggingLayer];
}

-(void)setTemporaryDraggingImage:(UIImage*)draggingImage offset:(CGPoint)offsetFromLocation 
{
	if( isEnding ) return;
	
	[mDraggingLayer setContents: (id)draggingImage.CGImage];
	
	mDraggingLayer.frame = CGRectMake(mLocation.x - offsetFromLocation.x, mLocation.y - offsetFromLocation.y, draggingImage.size.width, draggingImage.size.height);
	mDraggingLayer.anchorPoint = CGPointMake( offsetFromLocation.x / draggingImage.size.width, offsetFromLocation.y / draggingImage.size.height);
	
	mDraggingLayer.position = mLocation;
	
	isTemporaryImage_ = YES;
}

-(void)restoreDraggingImage
{
	if( isTemporaryImage_ )
	[self setDraggingImage:originalImage location:CGPointMake( mLocation.x - mImageOffset.width, mLocation.y - mImageOffset.height )];
}

-(void)setDraggingImage:(UIImage*)draggingImage location:(CGPoint)origin inView:(UIView*)view
{
	CGPoint location = [view convertPoint:origin toView:self.parentViewController.view];
	[self setDraggingImage:draggingImage location:location];
}

-(CGPoint)locationInView:(UIView*)view
{
  return [self.parentViewController.view convertPoint:self.location toView:view];
}

-(void)appearAnimation
{
  CATransform3D t0 = CATransform3DMakeScale(1, 1, 1);
  
  CATransform3D t1 = CATransform3DMakeScale(1.1, 1.1, 1);
  
  CABasicAnimation *animation = [CABasicAnimation animation];
  animation.keyPath = @"transform";
  animation.fromValue = [NSValue valueWithCATransform3D:t0];
  animation.toValue = [NSValue valueWithCATransform3D:t1];
  animation.duration = 0.2;
  animation.removedOnCompletion = NO;
  // leaves presentation layer in final state; preventing snap-back to original state
  animation.fillMode = kCAFillModeBoth;
  animation.repeatCount = 0;
  animation.autoreverses = YES;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  //animation.delegate = self;
  
  [mDraggingLayer addAnimation:animation forKey:@"appear"];
}

-(void)dropAnimation
{
  
  isEnding = YES;
  
  CATransform3D t0 = CATransform3DMakeScale(1, 1, 1);
  CATransform3D t1 = CATransform3DIdentity;
  
  if( [self.destination respondsToSelector:@selector(droppingDestination:)] )
  {
    CGPoint destination = [self.destination droppingDestination: self ];
    CGFloat x = CGRectGetMidX([mDraggingLayer frame]);
    CGFloat y = CGRectGetMidY([mDraggingLayer frame]);
    t1 = CATransform3DTranslate(t1, destination.x - x, destination.y - y, 0);
  }
  
  if( [self.destination respondsToSelector:@selector(droppingDestinationScale:)] )
  {
    CGFloat scale = [self.destination droppingDestinationScale: self];
    t1 = CATransform3DScale(t1, scale, scale, 1);
    
  }else {
    t1 = CATransform3DScale(t1, 0.01, 0.01, 1);
  }
  mDraggingLayer.transform = t1;
  
  CABasicAnimation *animation = [CABasicAnimation animation];
  animation.keyPath = @"transform";
  animation.fromValue = [NSValue valueWithCATransform3D:t0];
  animation.toValue = [NSValue valueWithCATransform3D:t1];
  animation.duration = 0.25;
  animation.removedOnCompletion = NO;
  // leaves presentation layer in final state; preventing snap-back to original state
  animation.fillMode = kCAFillModeBoth;
  animation.repeatCount = 0;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  animation.delegate = self;
  
  [mDraggingLayer addAnimation:animation forKey:@"drop"];

}

-(void)setSlidebackLocation:(CGPoint)location 
{
	mSlidebackOrigin = location;
}

-(void)adjustSlidebackLocation
{
	// Adjust slideback location for screen rotation
	if( !self.source.window || self.source.hidden )
	{
		mSlidebackOrigin.x = mLocation.x;
		mSlidebackOrigin.y = -10 - originalImage.size.height;

		return;
	}
	
	CGPoint sourceOrigin = [self.source.superview convertPoint: self.source.frame.origin toView: self.parentViewController.view];
	
	mSlidebackOrigin= sourceOrigin;
	
	mSlidebackOrigin.x -= (mInitialSourceOrigin.x - mInitialDraggingLocation.x);
	mSlidebackOrigin.y -= (mInitialSourceOrigin.y - mInitialDraggingLocation.y);
}

-(void)slideback
{
	isEnding = YES;
	mDraggingLayer.position = mSlidebackOrigin;
  
  CABasicAnimation *animation = [CABasicAnimation animation];
  animation.keyPath = @"position";
  animation.fromValue = [NSValue valueWithCGPoint: mLocation];
  animation.toValue = [NSValue valueWithCGPoint: mSlidebackOrigin];
  animation.duration = 0.25;
  animation.removedOnCompletion = NO;
  // leaves presentation layer in final state; preventing snap-back to original state
  animation.fillMode = kCAFillModeBoth;
  animation.repeatCount = 0;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  animation.delegate = self;
  
  [mDraggingLayer addAnimation:animation forKey:@"slideback"];
}

-(void)concludeDragging:(BOOL)success 
{
	success_ = success;
	
	if( [self.source respondsToSelector:@selector(concludeDragging:success:)] )
	{
		[self.source concludeDragging: self success:success];
	}
	
	// Retain now to prevent releaseing... then release when finishing the animation (*)
	[self retain];
	if( success )
	{
		if( animateDropping_ )
		{
			[self dropAnimation];
		}
		else
		{
			[self animationDidStop:nil finished:YES];
		}
	}
	else
	{
		[self slideback];
	}
	
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
	[self performSelector:@selector(callDidStartDelegateMethod) withObject:nil afterDelay:0];
}

-(void)callDidStartDelegateMethod
{
	
	if( [self.source respondsToSelector:@selector(concludeDraggingAnimationDidStart:)] )
	{
		[self.source concludeDraggingAnimationDidStart: self ];
	}
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	[mDraggingLayer removeAllAnimations];
	[mDraggingLayer removeFromSuperlayer];
	
	if( [self.source respondsToSelector:@selector(concludeDraggingAnimationDidFinish:)] )
	{
		[self.source concludeDraggingAnimationDidFinish: self ];
	}

  if( [self.destination respondsToSelector:@selector(concludeDroppingAnimationDidFinish:)] )
  {
    [self.destination concludeDroppingAnimationDidFinish: self ];
  }
  self.destination = nil;
	[self release]; // .... (*)
}

@end
