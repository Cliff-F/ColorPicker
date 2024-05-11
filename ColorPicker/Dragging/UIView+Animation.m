//
//  UIView+Animation.m
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 09/08/24.
//  Copyright 2009 Catalystwo Ltd. All rights reserved.
//

#import "UIView+Animation.h"
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_SPEED1 0.2
#define ANIMATION_SPEED2  0.1

#define POPUP_ANIMATION_SPEED1 0.1
#define POPUP_ANIMATION_SPEED2  0.075


#define SHAKE_ANIMATION_SPEED2  0.2

void WindowDataProviderReleaseData (
									void *info,
									const void *data,
									size_t size
									);

@implementation UIView (Animation)


-(void)rejectSwipeUp
{
	CGAffineTransform transform = self.transform;

	[UIView animateWithDuration:ANIMATION_SPEED1
						  delay:0
						options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
					 animations:^(void)
	 {
		 self.transform = CGAffineTransformTranslate(transform, 0, -30);

		 
		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
		 [UIView animateWithDuration:ANIMATION_SPEED1*1.5
							   delay:0
							 options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
						  animations:^(void)
		  {
			  self.transform = transform;
			  			  
		  } completion:^(BOOL finished){
			  
			  
		  }];
		 }
		 
	 }];
	
	
}




-(void)rejectSwipeDown
{
	CGAffineTransform transform = self.transform;
	
	[UIView animateWithDuration:ANIMATION_SPEED1
						  delay:0
						options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
					 animations:^(void)
	 {
		 self.transform = CGAffineTransformTranslate(transform, 0, +30);
		 
		 
		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
			 [UIView animateWithDuration:ANIMATION_SPEED1*1.5
								   delay:0
								 options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
							  animations:^(void)
			  {
				  self.transform = transform;
				  
			  } completion:^(BOOL finished){
				  
				  
			  }];
		 }
		 
	 }];
	

}



-(void)rejectSwipeLeft
{
	CGAffineTransform transform = self.transform;
	
	[UIView animateWithDuration:ANIMATION_SPEED1
								 delay:0
							  options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
						  animations:^(void)
	 {
		 self.transform = CGAffineTransformTranslate(transform, -20, 0);
		 
		 
		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
			 [UIView animateWithDuration:ANIMATION_SPEED1*1.5
										  delay:0
										options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
									animations:^(void)
			  {
				  self.transform = transform;
				  
			  } completion:^(BOOL finished){
				  
				  
			  }];
		 }
		 
	 }];
	
	
}




-(void)rejectSwipeRight
{
	CGAffineTransform transform = self.transform;
	
	[UIView animateWithDuration:ANIMATION_SPEED1
								 delay:0
							  options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
						  animations:^(void)
	 {
		 self.transform = CGAffineTransformTranslate(transform, +20, 0);
		 
		 
		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
			 [UIView animateWithDuration:ANIMATION_SPEED1*1.5
										  delay:0
										options:UIViewAnimationCurveEaseOut|UIViewAnimationOptionTransitionNone
									animations:^(void)
			  {
				  self.transform = transform;
				  
			  } completion:^(BOOL finished){
				  
				  
			  }];
		 }
		 
	 }];
	
	
}




-(void)appearAnimation:(CGFloat)startScale startAlpha:(CGFloat)startAlpha
{
	CGAffineTransform originalTransform = self.transform;
	self.transform = CGAffineTransformScale(originalTransform, startScale, startScale);
	self.alpha = startAlpha;

	
	[UIView animateWithDuration:ANIMATION_SPEED1
						  delay:0
						options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionNone
					 animations:^(void)
	 {
		 self.transform = CGAffineTransformScale(originalTransform, 1.05, 1.05);
		 self.alpha = (1.0f+startAlpha)/2.0f;
		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
			 [UIView animateWithDuration:ANIMATION_SPEED2
								   delay:0
								 options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionNone
							  animations:^(void)
			  {
				  CGAffineTransform transform = self.transform;
				  transform.a = 1;
				  transform.b = 0;
				  transform.c = 0;
				  transform.d = 1;
				  
				  
				  self.transform = transform;
				  self.alpha = 1.0f;				  
				  
				  
			  } completion:^(BOOL finished){
				  
			  }];
		 }
		 
	 }];
	
//	////
//	
//	
//	CGAffineTransform originalTransform = self.transform;
//	
//	self.transform = CGAffineTransformScale(originalTransform, startScale, startScale);
//	self.alpha = startAlpha;
//	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration: ANIMATION_SPEED1 ];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(animation1:  finished:  context:)];
//
//
//	self.transform = CGAffineTransformScale(originalTransform, 1.05, 1.05);
//	self.alpha = (1.0f+startAlpha)/2.0f;
//	
//	[UIView commitAnimations]; 

}

//-(void)animation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context
//{
//	
//	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration: ANIMATION_SPEED2 ];
//	[UIView setAnimationDelegate:self];
//
//	CGAffineTransform transform = self.transform;
//	transform.a = 1;
//	transform.b = 0;
//	transform.c = 0;
//	transform.d = 1;
//	
//	
//	self.transform = transform;
//	self.alpha = 1.0f;
//	
//	[UIView commitAnimations]; 
//}

-(void)popupAppearAnimation:(CGFloat)startScale from:(CGPoint)locationInWindow startAlpha:(CGFloat)startAlpha delay:(NSTimeInterval)delay
{
	
	CGRect frame = self.frame;
	CGRect frameInWindow = [self.superview convertRect:frame toView:nil];
	
	CGPoint center = CGPointMake(CGRectGetMidX(frameInWindow), CGRectGetMidY(frameInWindow));
	
	CGPoint fukidashiPoint = CGPointMake( locationInWindow.x - center.x, locationInWindow.y - center.y);
	CGPoint initialFukidashiPoint = CGPointMake(fukidashiPoint.x*startScale, fukidashiPoint.y*startScale);	
	CGPoint maxFukidashiPoint = CGPointMake(fukidashiPoint.x*1.08, fukidashiPoint.y*1.08);	

	CGAffineTransform originalTransform = self.transform;
	
	self.alpha = startAlpha;
	
	self.transform = CGAffineTransformTranslate(originalTransform, fukidashiPoint.x - initialFukidashiPoint.x, fukidashiPoint.y - initialFukidashiPoint.y);
	self.transform = CGAffineTransformScale(self.transform, startScale, startScale);
	
	
	
	
	
	[UIView animateWithDuration:POPUP_ANIMATION_SPEED1
						  delay:delay
						options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionNone
					 animations:^(void)
	 {
		 CGAffineTransform transform = CGAffineTransformTranslate(originalTransform, maxFukidashiPoint.x - fukidashiPoint.x, maxFukidashiPoint.y - fukidashiPoint.y);
		 self.transform = CGAffineTransformScale(transform, 1.08, 1.08);
		 
		 self.alpha = 0.9f;
		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
			 [UIView animateWithDuration:ANIMATION_SPEED2
								   delay:0
								 options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionNone
							  animations:^(void)
			  {
				  self.transform = CGAffineTransformIdentity;
				  self.alpha = 1.0f;				  
			  } completion:^(BOOL finished){
				  
				  
			  }];
		 }
		 
	 }];

	
	
	
	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration: POPUP_ANIMATION_SPEED1 ];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDelay: delay];
//	
//	[UIView setAnimationDidStopSelector:@selector(popupAppearAnimation1:  finished:  context:)];
//	
//	CGAffineTransform transform = CGAffineTransformTranslate(originalTransform, maxFukidashiPoint.x - fukidashiPoint.x, maxFukidashiPoint.y - fukidashiPoint.y);
//	self.transform = CGAffineTransformScale(transform, 1.08, 1.08);
//
//	self.alpha = 0.9f;
//	
//	[UIView commitAnimations]; 
	
}


//-(void)popupAppearAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context
//{
//	
//	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration: POPUP_ANIMATION_SPEED2 ];
//	[UIView setAnimationDelegate:self];
//	
//
//	self.transform = CGAffineTransformIdentity;
//	self.alpha = 1.0f;
//	
//	[UIView commitAnimations]; 
//}


-(void)tooltipAppearAnimation:(CGFloat)startScale startAlpha:(CGFloat)startAlpha delay:(NSTimeInterval)delay orientation:(UIInterfaceOrientation)orientation
{
	
	CGAffineTransform originalTransform = self.transform;
	
	self.alpha = startAlpha;
	
	if( orientation == UIDeviceOrientationPortrait )
	self.transform = CGAffineTransformTranslate(originalTransform, 0, self.frame.size.height/2);
	
	if( orientation == UIDeviceOrientationLandscapeLeft )
		self.transform = CGAffineTransformTranslate(originalTransform, -self.frame.size.width/2, 0);
	
	if( orientation == UIDeviceOrientationLandscapeRight )
		self.transform = CGAffineTransformTranslate(originalTransform, self.frame.size.width/2, 0);

	
	self.transform = CGAffineTransformScale(self.transform, startScale, startScale);

	
	
	
	[UIView animateWithDuration:ANIMATION_SPEED1
						  delay:delay
						options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionNone
					 animations:^(void)
	 {
		 self.transform = CGAffineTransformScale(originalTransform, 1.08, 1.08);
		 self.alpha = 0.9f;

		 
	 } completion:^(BOOL finished){
		 
		 if( finished )
		 {
			 [UIView animateWithDuration:ANIMATION_SPEED2
								   delay:0
								 options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionTransitionNone
							  animations:^(void)
			  {
				  CGAffineTransform transform = self.transform;
				  transform.a = 1;
				  transform.b = 0;
				  transform.c = 0;
				  transform.d = 1;
				  
				  
				  self.transform = transform;
				  self.alpha = 1.0f;
				  
			  } completion:^(BOOL finished){
				  
				  
			  }];
		 }
		 
	 }];
	

	
//	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration: ANIMATION_SPEED1 ];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDelay: delay];
//
//	[UIView setAnimationDidStopSelector:@selector(tooltipAppearAnimation1:  finished:  context:)];
//	
//	
//	self.transform = CGAffineTransformScale(originalTransform, 1.08, 1.08);
//	self.alpha = 0.9f;
//	
//	[UIView commitAnimations]; 
	
}

//-(void)tooltipAppearAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context
//{
//	
//	
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration: ANIMATION_SPEED2 ];
//	[UIView setAnimationDelegate:self];
//	
//	CGAffineTransform transform = self.transform;
//	transform.a = 1;
//	transform.b = 0;
//	transform.c = 0;
//	transform.d = 1;
//	
//	
//	self.transform = transform;
//	self.alpha = 1.0f;
//	
//	[UIView commitAnimations]; 
//}

-(void)moveToCenter
{
	CGPoint center = CGPointMake( self.superview.bounds.size.width/2,  self.superview.bounds.size.height/2 );
	self.center= center;
}


#pragma mark// ==================================
#pragma mark// Drag start animation
#pragma mark// ==================================

-(void)dragStartAnimation
{
	[self retain];
	
	
	//self.transform = CGAffineTransformScale(originalTransform, 1.0, 1.0);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: ANIMATION_SPEED1 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dragAnimation1:  finished:  context:)];
	
	
	CGAffineTransform transform = self.transform;
	transform.a = 0.9;
	transform.b = 0;
	transform.c = 0;
	transform.d = 1.1;
	
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
	
}


-(void)dragAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: ANIMATION_SPEED2 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dragAnimation2:  finished:  context:)];
	
	CGAffineTransform transform = self.transform;
	transform.a = 1;
	transform.b = 0;
	transform.c = 0;
	transform.d = 1;
	
	self.transform = transform;
	self.alpha = 0.6;
	[UIView commitAnimations]; 
}

-(void)dragAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[self autorelease];
	
}


#pragma mark// ==================================
#pragma mark// Change End date start animation
#pragma mark// ==================================

-(void)dragCornerStartAnimation
{
	return;
	
	[self retain];
	
	
	//self.transform = CGAffineTransformScale(originalTransform, 1.0, 1.0);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: ANIMATION_SPEED1 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dragCornerStartAnimation1:  finished:  context:)];
	
	
	CGAffineTransform transform = self.transform;
	transform.a = 1;
	transform.b = 0;
	transform.c = 0;
	transform.d = 1.1;
	
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
	
}


-(void)dragCornerStartAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: ANIMATION_SPEED2 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dragCornerStartAnimation2:  finished:  context:)];
	
	CGAffineTransform transform = self.transform;
	transform.a = 1;
	transform.b = 0;
	transform.c = 0;
	transform.d = 1;
	
	self.transform = transform;

	[UIView commitAnimations]; 
}

-(void)dragCornerStartAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[self autorelease];
	
}


#pragma mark// ==================================
#pragma mark// Shake animation
#pragma mark// ==================================

-(void)shakeAnimation
{
	
	CGAffineTransform originalTransform = self.transform;
	
	NSUInteger *context = malloc(sizeof(NSUInteger));
	*context = 0;
	
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration: SHAKE_ANIMATION_SPEED2 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(shakeAnimation1:  finished:  context:)];

	CGFloat shakeSize;
	if( self.bounds.size.width  < 50 && self.bounds.size.height )
		shakeSize = 1.2;
	else shakeSize = 1.05;
	
	self.transform = CGAffineTransformScale(originalTransform, shakeSize, shakeSize);
	
	[UIView commitAnimations]; 
	
}



-(void)shakeAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	
	
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration: SHAKE_ANIMATION_SPEED2 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(shakeAnimation2:  finished:  context:)];

	CGAffineTransform transform = self.transform;
	transform.a = 1;
	transform.b = 0;
	transform.c = 0;
	transform.d = 1;
	
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
}

-(void)shakeAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
		
		(*(NSUInteger*)context) ++;
		 if(  (*(NSUInteger*)context) > 5 || !self.window )
		 {
		
			 free(context);
			 return;
		 }
		
		CGAffineTransform originalTransform = self.transform;

		[UIView beginAnimations:nil context:context];
		[UIView setAnimationDuration: SHAKE_ANIMATION_SPEED2 ];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(shakeAnimation1:  finished:  context:)];
		
	CGFloat shakeSize;
	if( self.bounds.size.width  < 50 && self.bounds.size.height )
		shakeSize = 1.2;
	else shakeSize = 1.05;
	
	
		self.transform = CGAffineTransformScale(originalTransform, shakeSize, shakeSize);
		
		[UIView commitAnimations]; 
	
}


#pragma mark// ==================================
#pragma mark// Reject animation
#pragma mark// ==================================

-(void)mn_rejectAnimation
{
	CGFloat shakeSize = 16;
	CGFloat shakeUnitTime = 0.05;
	
	CGAffineTransform originalTransform = self.transform;
	
	
	[UIView animateWithDuration:shakeUnitTime animations:^{
		
		self.transform = CGAffineTransformTranslate(originalTransform, 0, shakeSize);
		
		
	} completion:^(BOOL finished) {
		
		
		
		[UIView animateWithDuration:shakeUnitTime*2 animations:^{
			
			self.transform = CGAffineTransformTranslate(originalTransform, 0, -shakeSize * 0.6);
			
			
		} completion:^(BOOL finished) {
			
			
			[UIView animateWithDuration:shakeUnitTime*2 animations:^{
				
				self.transform = CGAffineTransformTranslate(originalTransform, 0, +shakeSize * 0.3);
				
				
			} completion:^(BOOL finished) {
				
				[UIView animateWithDuration:shakeUnitTime*2 animations:^{
					
					self.transform = CGAffineTransformTranslate(originalTransform, 0, -shakeSize *0.15);
					
					
				} completion:^(BOOL finished) {
					
					[UIView animateWithDuration:shakeUnitTime*2 animations:^{
						
						self.transform = CGAffineTransformTranslate(originalTransform, 0, 0);
						
						
					} completion:^(BOOL finished) {
						
						
					}];
				}];
			}];			
		}];
	}];
	
	
}


#pragma mark// ==================================
#pragma mark// Bounce back
#pragma mark// ==================================

#define BOUNCE_BACK_ANIMATION_SPEED1 0.1
#define BOUNCE_BACK_ANIMATION_SPEED2 0.15


-(void)bounceBack
{
	CGAffineTransform transform = self.transform;
//	float distance = 	sqrt(transform.tx*transform.tx + transform.ty*transform.ty);
//
//	// Threashold
//	
//	distance = fminf( distance, 50);
//	NSLog(@"distance %f",distance);
//	
//	NSUInteger *context = malloc(sizeof(float));
//	*context = distance;
	
	transform.tx =  - transform.tx * 0.3f;
	transform.ty =  - transform.ty * 0.3f;
	//MNLOG(@"transform %f, %f",transform.tx, transform.ty);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: BOUNCE_BACK_ANIMATION_SPEED1 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceBackAnimation:  finished:  context:)];
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
}

-(void)bounceBackAnimation:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{

	
	if( !self.window )
	{
//		free(context);
		return;
	}
	
//	float distance = *(float*)context;
	CGAffineTransform transform = self.transform;
	
	transform.tx =  - transform.tx * 0.28f;
	transform.ty =  - transform.ty * 0.28f;
	//MNLOG(@"transform %f, %f",transform.tx, transform.ty);

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: BOUNCE_BACK_ANIMATION_SPEED2 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceBackAnimation2:  finished:  context:)];
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
	
}

-(void)bounceBackAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	
	if( !self.window )
	{
		//		free(context);
		return;
	}
	
	//	float distance = *(float*)context;
	CGAffineTransform transform = self.transform;
	
	transform.tx =  - transform.tx * 0.2f;
	transform.ty =  - transform.ty * 0.2f;
	//MNLOG(@"transform %f, %f",transform.tx, transform.ty);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: BOUNCE_BACK_ANIMATION_SPEED2 ];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceBackAnimation3:  finished:  context:)];
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
}
-(void)bounceBackAnimation3:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
//	free(context);

	CGAffineTransform transform = self.transform;
	transform.tx = 0;
	transform.ty = 0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: BOUNCE_BACK_ANIMATION_SPEED1 ];
	
	self.transform = transform;
	
	[UIView commitAnimations]; 
}

#pragma mark// ==================================
#pragma mark// Texture
#pragma mark// ==================================



void WindowDataProviderReleaseData (
							void *info,
							const void *data,
							size_t size
							)
{
	//printf("message");
	free((void *)data);	 // CalendarDayView's image 
}



-(UIImage*)createGrayViewImageWithProvider
{
	// The caller method must release provider when finish using.
	
	CGFloat scaleFactor = [[UIScreen mainScreen] scale];
	
	
	// Prepare CGImage
	CGSize size = self.bounds.size;
	size_t width, height;
	width = (int)size.width*scaleFactor;
	height = (int)size.height*scaleFactor;
	


	size_t	bitsPPixel, bytesPRow;
	bytesPRow = width * 1;
	bitsPPixel = 8*1;
	void * textureBytes		= calloc(bytesPRow * height, 1 );
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	
	
	CGContextRef ctx = CGBitmapContextCreate(textureBytes,
											 width,
											 height,
											 8,
											 bytesPRow,
											 colorSpace,
											 kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	
	UIGraphicsPushContext(ctx);
	
	CGAffineTransform t;
	t = CGAffineTransformMakeScale(scaleFactor, -scaleFactor);
	t = CGAffineTransformTranslate(t, 0, -size.height);
	CGContextConcatCTM(ctx, t);
	
	[self.layer renderInContext: ctx ];
	UIGraphicsPopContext();

	
	
	CGDataProviderRef provider = CGDataProviderCreateWithData(nil, textureBytes, bytesPRow * height, WindowDataProviderReleaseData);
	
	 CGImageRef cgimage = CGImageCreate(width, height, 8, 8, bytesPRow, colorSpace, 0, provider, nil, false, kCGRenderingIntentDefault);
	
	CGContextRelease(ctx); 
	//CGDataProviderRelease(provider);

	
	UIImage* image = [UIImage imageWithCGImage: cgimage];
	
	CGImageRelease(cgimage);
	return image;
	
}

-(UIImage*)createColorViewImageWithProvider:(CGFloat)scaleFactor
{
	// The caller method must release provider when finish using.
	
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scaleFactor);
	[self.layer renderInContext: UIGraphicsGetCurrentContext() ];

	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end
