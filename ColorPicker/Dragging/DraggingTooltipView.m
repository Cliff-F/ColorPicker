//
//  TooltipView.m
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 09/10/31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DraggingTooltipView.h"
#import "UIView+Animation.h"
#import <QuartzCore/QuartzCore.h>
 
#define RGBA(r,g,b,a) [UIColor colorWithRed: r/255.0f green: g/255.0f blue: b/255.0f alpha: a]


@implementation DraggingTooltipView

@synthesize tooltipType = mTooltipType;
@synthesize tooltipLocation = mTooltipLocation;
//@synthesize screenRect = mScreenRect;
@synthesize text = mText;
@synthesize textSize = mTextSize;
@synthesize topArrow = mTopArrow;

void addFukidashiRoundedRectToPath(CGContextRef context, CGRect rect,
														CGFloat ovalWidth,CGFloat ovalHeight, CGPoint fukidashiPoint, CGFloat indicatorWidth_2);
void addRoundedRectToPath(CGContextRef context, CGRect rect,
                          CGFloat ovalWidth,CGFloat ovalHeight);
void addTopArrowFukidashiRoundedRectToPath(CGContextRef context, CGRect rect,
                                   CGFloat ovalWidth,CGFloat ovalHeight, CGPoint fukidashiPoint, CGFloat indicatorWidth_2);

#define MAX_WIDTH 250
#define ALPHA 0.9
#define FONT [UIFont systemFontOfSize:16]
#define ABOVE 25

#define SHOW_ANIMATION 0.2

#define INDICATOR_HEIGHT 15
#define INDICATOR_WIDTH_2 10
#define INDICATOR_SIDE_MARGIN 25
#define TOOLTIP_EDGE_MARGIN 10
#define STATUS_BAR_HEIGHT 20

+(DraggingTooltipView*)tooltip
{
	DraggingTooltipView *tooltipView = [[[DraggingTooltipView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)] autorelease];
	
	return tooltipView;
	
	
}
-(int)compareTextEffectsOrdering:(id)ordering {
  return 0;
}

- (int)textEffectsVisibilityLevel {
  return 0;
  
}

- (id)initWithFrame:(CGRect)frame {
	self = [super init];
	if (self) {
		tooltipLayer_ = [[CALayer layer] retain];
		tooltipLayer_.frame = frame;
		tooltipLayer_.delegate = self;
		tooltipLayer_.backgroundColor = [UIColor clearColor].CGColor;
		tooltipLayer_.opaque = NO;
		tooltipLayer_.opacity = 0;
		tooltipLayer_.zPosition = 22;
		tooltipLayer_.contentsScale = [[UIScreen mainScreen] scale];
		
		tooltipLayer_.actions = [[[NSDictionary alloc] initWithObjectsAndKeys:
										  //[NSNull null], @"onOrderIn",
										  //[NSNull null], @"onOrderOut",
										  [NSNull null], @"sublayers",
										  //[NSNull null], @"contents",
										  [NSNull null], @"position",
										  nil] autorelease];
		
		
		//		tooltipArrowLayer_ = [[CALayer layer] retain];
		//		tooltipArrowLayer_.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		//		tooltipArrowLayer_.delegate = self;
		//		tooltipArrowLayer_.backgroundColor = [UIColor clearColor].CGColor;
		//		tooltipArrowLayer_.opaque = NO;
		//		tooltipArrowLayer_.opacity = 0;
		//		tooltipArrowLayer_.zPosition = 22;
		//
		//
		//		tooltipArrowLayer_.actions = [[[NSDictionary alloc] initWithObjectsAndKeys:
		//								  //[NSNull null], @"onOrderIn",
		//								  //[NSNull null], @"onOrderOut",
		//								  [NSNull null], @"sublayers",
		//								  //[NSNull null], @"contents",
		//								  [NSNull null], @"position",
		//								  nil] autorelease];
		//
		//		[tooltipArrowLayer_ addSublayer: tooltipArrowLayer_];

	}
	return self;
}



-(void)dealloc
{
	
	tooltipLayer_.delegate = nil;
	[tooltipLayer_ removeFromSuperlayer];
	[tooltipLayer_ release];
	tooltipLayer_ = nil;
	
	//	tooltipArrowLayer_.delegate = nil;
	//	[tooltipArrowLayer_ removeFromSuperlayer];
	//	[tooltipArrowLayer_ release];
	//	tooltipArrowLayer_ = nil;
	
  self.text = nil;
	
	[super dealloc];
}




-(void)showDraggingTooltipAt:(CGPoint)location inView:(UIView*)view message:(NSString*)message type:(TooltipViewType)tooltipType afterDelay:(NSTimeInterval)delay
{
	
	
	BOOL shouldDraw = NO;
	
	if( ![self.text isEqualToString: message ] )  shouldDraw = YES;
	
	self.text = message;
	self.tooltipType = tooltipType;
	
	// Calc size
	
	CGSize textSize = [self.text sizeWithFont:FONT constrainedToSize:CGSizeMake(MAX_WIDTH, 300)];
	self.textSize = 	textSize;
	
	CGRect textRect = CGRectMake(10 + TOOLTIP_EDGE_MARGIN, 2+TOOLTIP_EDGE_MARGIN, textSize.width, textSize.height);
	
	
	textRect = CGRectIntegral(textRect);
	
	CGRect viewRect = CGRectMake(0, 0, textRect.size.width + 20, textRect.size.height + 4);
	
	// Add margin for shadow+ fukidashi
	viewRect.origin.x = viewRect.origin.x - TOOLTIP_EDGE_MARGIN;
	viewRect.origin.y = viewRect.origin.y - TOOLTIP_EDGE_MARGIN;
	viewRect.size.width += TOOLTIP_EDGE_MARGIN*2;
	viewRect.size.height += TOOLTIP_EDGE_MARGIN*2 + INDICATOR_HEIGHT;
	
	if( CGPointEqualToPoint(location, CGPointZero) )
	{
		viewRect.origin.y = tooltipLayer_.frame.origin.y;
		viewRect.origin.x = tooltipLayer_.frame.origin.x + viewRect.size.width/2;
	}else
	{
    
    if( mTopArrow ) {
      viewRect.origin.y = location.y + ABOVE;
      viewRect.origin.x = location.x - viewRect.size.width/2;

    }else {
      
      viewRect.origin.y = location.y - viewRect.size.height - ABOVE;
      viewRect.origin.x = location.x - viewRect.size.width/2;
    }
	}
	
	
	
	// Fit in Window
	
	
	CGRect containRect = view.bounds;
	
	if( viewRect.origin.x < containRect.origin.x ) viewRect.origin.x = containRect.origin.x;
	
	if( CGRectGetMaxX(viewRect) > CGRectGetMaxX(containRect))
		viewRect.origin.x = CGRectGetMaxX(containRect) - viewRect.size.width ;
	
	if( viewRect.origin.y < containRect.origin.y )
    viewRect.origin.y = containRect.origin.y ;
	if( CGRectGetMaxY(viewRect) > CGRectGetMaxY(containRect) )
    viewRect.origin.y = CGRectGetMaxY(containRect) - viewRect.size.height ;
  

	
	viewRect = CGRectIntegral(viewRect);
	tooltipLayer_.opacity = 1.0;
	tooltipLayer_.transform = CATransform3DIdentity;
	tooltipLayer_.frame = viewRect;
	mSize = viewRect.size;
	
	
	//
	
	self.tooltipLocation = [view.layer convertPoint:location toLayer:tooltipLayer_];
	if( CGPointEqualToPoint(location, CGPointZero) )
		self.tooltipLocation  = CGPointZero;
	
	
	
	if( shouldDraw )
		[tooltipLayer_ setNeedsDisplay];
	
	
	if( tooltipLayer_.superlayer == nil )
	{

		[view.layer addSublayer:tooltipLayer_];
		
		self.tooltipLocation = [view.layer convertPoint:location toLayer:tooltipLayer_];
		if( CGPointEqualToPoint(location, CGPointZero) )
			self.tooltipLocation  = CGPointZero;
		
		
		CGPoint centerToLocation = CGPointMake(self.tooltipLocation.x - viewRect.size.width/2, self.tooltipLocation.y - ABOVE-TOOLTIP_EDGE_MARGIN - viewRect.size.height/2);
		
    if( mTopArrow ) {
      centerToLocation = CGPointMake(self.tooltipLocation.x - viewRect.size.width/2, self.tooltipLocation.y - INDICATOR_HEIGHT);
    }
    
    
		
		CFTimeInterval firstDuration = 0.3;
		
		CABasicAnimation *animation = [CABasicAnimation animation];
		animation.keyPath = @"transform";
		CATransform3D t0 = CATransform3DIdentity;
		
		t0 = CATransform3DTranslate(t0, centerToLocation.x-centerToLocation.x * 0.1, centerToLocation.y-centerToLocation.y * 0.1 , 0);
		t0 = CATransform3DScale(t0, 0.1, 0.1, 1);
		
		
		
		animation.fromValue = [NSValue valueWithCATransform3D:t0];
		animation.toValue = [NSValue valueWithCATransform3D: CATransform3DIdentity];
		animation.duration = firstDuration;
		animation.removedOnCompletion = YES;
		animation.fillMode = kCAFillModeRemoved;
		animation.repeatCount = 1;
		
		CAMediaTimingFunction* function = [[[CAMediaTimingFunction alloc] initWithControlPoints:0.8 :2.3 :0.6 :0.5] autorelease];
		
		animation.timingFunction = function;
		
		[tooltipLayer_ addAnimation:animation forKey:@"appear1"];
		
	}
}



-(void)closeTooltip
{
	[UIView animateWithDuration:SHOW_ANIMATION
								 delay:0
							  options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionNone
						  animations:^(void)
	 {
		 tooltipLayer_.opacity = 0;
		 
		 
	 } completion:^(BOOL finished){
		 
		 [tooltipLayer_ performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:0.5 ];
	 }];
	
	
	
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	
	
	CGRect rect = layer.bounds;
	
	CGContextSaveGState(ctx);
	
	
	
	if( self.tooltipType == TooltipViewCommand )
	{
		
		CGContextSetFillColorWithColor(ctx, RGBA(0,0,0,1).CGColor);
		
	}
	else if( self.tooltipType == TooltipViewDestructive )
	{
		CGContextSetFillColorWithColor(ctx, RGBA(178,0,0,1).CGColor);
		
	}
	else//if( self.tooltipType == TooltipViewInformation )
	{
		CGContextSetFillColorWithColor(ctx, RGBA(0,0,0,0.4).CGColor);
		
	}
	
	
	CGContextSetStrokeColorWithColor(ctx, RGBA(178,178,178,1).CGColor);
	CGContextSetLineWidth(ctx, 1.5);
	
	//	if( self.tooltipType == TooltipViewInformation )
	//	{
	//		CGContextSetShadowWithColor(ctx, CGSizeMake(0,0), 0, [UIColor clearColor].CGColor);
	//
	//	}else
	{
		
//		CGContextSetShadowWithColor(ctx, CGSizeMake(0,+3), 6, [UIColor blackColor].CGColor);
		
	}
	
	
	
	// tooltipLocation
	
	CGPoint location = self.tooltipLocation;
	CGRect bodyRect = rect;
	
	
  if( mTopArrow )
  {
    if(! CGPointEqualToPoint(location, CGPointZero))
    {
      
      if( location.x < rect.origin.x + INDICATOR_SIDE_MARGIN + TOOLTIP_EDGE_MARGIN )
        location.x = rect.origin.x + INDICATOR_SIDE_MARGIN + TOOLTIP_EDGE_MARGIN;
      
      if( location.x > CGRectGetMaxX(rect) - INDICATOR_SIDE_MARGIN - TOOLTIP_EDGE_MARGIN)
        location.x = CGRectGetMaxX(rect) - INDICATOR_SIDE_MARGIN - TOOLTIP_EDGE_MARGIN;
      
      location.y = CGRectGetMinY(rect) + TOOLTIP_EDGE_MARGIN;
      
      
      // Round
      bodyRect = CGRectMake(rect.origin.x +TOOLTIP_EDGE_MARGIN,
                            rect.origin.y +TOOLTIP_EDGE_MARGIN+INDICATOR_HEIGHT,
                            rect.size.width-TOOLTIP_EDGE_MARGIN*2,
                            rect.size.height-TOOLTIP_EDGE_MARGIN*2-INDICATOR_HEIGHT);
      
    }
    
    
    CGContextSaveGState(ctx);
    CGPathRef bezierPath = nil;
    
    addTopArrowFukidashiRoundedRectToPath(ctx, bodyRect, 13,13, location, 10);
    bezierPath = CGContextCopyPath(ctx);
    CGContextRestoreGState(ctx);
    
    
    CGContextAddPath(ctx, bezierPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0,0), 0, [UIColor clearColor].CGColor);
    addTopArrowFukidashiRoundedRectToPath(ctx, bodyRect, 13,13, location, 10);
    
    CGContextAddPath(ctx, bezierPath);
      CGContextDrawPath(ctx, kCGPathStroke);
    
    UIGraphicsPushContext(ctx);
    [[UIColor whiteColor] set];
    //  CGContextSetShadow(ctx, CGSizeMake(0, +1), 2);
    
    [mText drawInRect:CGRectMake(bodyRect.origin.x+10, bodyRect.origin.y+2, mTextSize.width, mTextSize.height)
             withFont:FONT];
    UIGraphicsPopContext();
    
    CGContextRestoreGState(ctx);
    
    CFRelease(bezierPath);
    
    
  }else {
    if(! CGPointEqualToPoint(location, CGPointZero))
    {
      
      if( location.x < rect.origin.x + INDICATOR_SIDE_MARGIN + TOOLTIP_EDGE_MARGIN )
        location.x = rect.origin.x + INDICATOR_SIDE_MARGIN + TOOLTIP_EDGE_MARGIN;
      
      if( location.x > CGRectGetMaxX(rect) - INDICATOR_SIDE_MARGIN - TOOLTIP_EDGE_MARGIN)
        location.x = CGRectGetMaxX(rect) - INDICATOR_SIDE_MARGIN - TOOLTIP_EDGE_MARGIN;
      
      location.y = CGRectGetMaxY(rect) - TOOLTIP_EDGE_MARGIN;
      
      
      // Round
      bodyRect = CGRectMake(rect.origin.x +TOOLTIP_EDGE_MARGIN,
                            rect.origin.y +TOOLTIP_EDGE_MARGIN,
                            rect.size.width-TOOLTIP_EDGE_MARGIN*2,
                            rect.size.height-TOOLTIP_EDGE_MARGIN*2-INDICATOR_HEIGHT);
      
    }
    
    
    CGContextSaveGState(ctx);
    CGPathRef bezierPath = nil;
    
    addFukidashiRoundedRectToPath(ctx, bodyRect, 13,13, location, 10);
    bezierPath = CGContextCopyPath(ctx);
    CGContextRestoreGState(ctx);
    
    
    CGContextAddPath(ctx, bezierPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0,0), 0, [UIColor clearColor].CGColor);
    addFukidashiRoundedRectToPath(ctx, bodyRect, 13,13, location, 10);
    
    CGContextAddPath(ctx, bezierPath);
    //	CGContextDrawPath(ctx, kCGPathStroke);
    
    UIGraphicsPushContext(ctx);
    [[UIColor whiteColor] set];
    //	CGContextSetShadow(ctx, CGSizeMake(0, +1), 2);
    
    [mText drawInRect:CGRectMake(bodyRect.origin.x+10, bodyRect.origin.y+2, mTextSize.width, mTextSize.height)
             withFont:FONT];
    UIGraphicsPopContext();
    
    CGContextRestoreGState(ctx);
    
    CFRelease(bezierPath);
  }
}



@end

void addFukidashiRoundedRectToPath(CGContextRef context, CGRect rect,
                   CGFloat ovalWidth,CGFloat ovalHeight, CGPoint fukidashiPoint, CGFloat indicatorWidth_2)
{
  
  if( CGPointEqualToPoint(fukidashiPoint, CGPointZero) )
  {
    addRoundedRectToPath(context, rect,
               ovalWidth, ovalHeight);
    
    return;
  }
  
    CGFloat fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
    // 1
        CGContextAddRect(context, rect);
        return;
    }
  
  
  // Calc p1, p2
  CGPoint p1, p2;
  
  UIDeviceOrientation orientation = UIDeviceOrientationPortrait;
  
  if( fukidashiPoint.y > CGRectGetMaxY(rect) ) orientation = UIDeviceOrientationPortrait;
  if( fukidashiPoint.x < CGRectGetMinX(rect) ) orientation = UIDeviceOrientationLandscapeLeft;
  if( fukidashiPoint.x > CGRectGetMaxX(rect) ) orientation = UIDeviceOrientationLandscapeRight;
  
  
  if( orientation == UIDeviceOrientationPortrait )
  {
    p1 = CGPointMake( fukidashiPoint.x - indicatorWidth_2,  CGRectGetMaxY(rect));
    p2 = CGPointMake( fukidashiPoint.x + indicatorWidth_2,  CGRectGetMaxY(rect));
  }
  
  else if( orientation == UIDeviceOrientationLandscapeLeft )
  {
    p1 = CGPointMake( CGRectGetMinX(rect), fukidashiPoint.y - indicatorWidth_2 );
    p2 = CGPointMake( CGRectGetMinX(rect), fukidashiPoint.y + indicatorWidth_2 );
    
  }
  
  else if( orientation == UIDeviceOrientationLandscapeRight )
  {
    p1 = CGPointMake( CGRectGetMaxX(rect), fukidashiPoint.y - indicatorWidth_2 );
    p2 = CGPointMake( CGRectGetMaxX(rect), fukidashiPoint.y + indicatorWidth_2 );
    
  }
  
  
    CGContextSaveGState(context);
  
  
  // 4
    fw = CGRectGetWidth (rect) ;
  // 5
    fh = CGRectGetHeight (rect) ;
  // 6
  
  if( orientation == UIDeviceOrientationLandscapeRight )
  {
    CGContextMoveToPoint(context, fukidashiPoint.x, fukidashiPoint.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
  }
  else {
    CGContextMoveToPoint(context, fw+CGRectGetMinX(rect), fh/2+CGRectGetMinY(rect));
    
  }
  
  
  // 7
    CGContextAddArcToPoint(context, fw+CGRectGetMinX(rect), fh+CGRectGetMinY(rect), fw+CGRectGetMinX(rect)-ovalWidth, fh+CGRectGetMinY(rect), ovalWidth);
  
  if( orientation == UIDeviceOrientationPortrait )
  {
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextAddLineToPoint(context, fukidashiPoint.x, fukidashiPoint.y);
    CGContextAddLineToPoint(context, p1.x, p1.y);
  }
  
  // 8
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), fh+CGRectGetMinY(rect), CGRectGetMinX(rect), fh/2+CGRectGetMinY(rect), ovalWidth);
  
  if( orientation == UIDeviceOrientationLandscapeLeft )
  {
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextAddLineToPoint(context, fukidashiPoint.x, fukidashiPoint.y);
    CGContextAddLineToPoint(context, p1.x, p1.y);
  }
  
  
  // 9
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), fw+CGRectGetMinX(rect)-ovalWidth, CGRectGetMinY(rect), ovalWidth);
  // 10
  
  if( orientation == UIDeviceOrientationLandscapeRight )
  {
    CGContextAddArcToPoint(context, fw+CGRectGetMinX(rect), CGRectGetMinY(rect), fw+CGRectGetMinX(rect), p1.y, ovalWidth);
    
    CGContextAddLineToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, fukidashiPoint.x, fukidashiPoint.y);
    
  }else {
    CGContextAddArcToPoint(context, fw+CGRectGetMinX(rect), CGRectGetMinY(rect), fw+CGRectGetMinX(rect), fh/2+CGRectGetMinY(rect), ovalWidth);
    
  }
  
  // 11
    CGContextClosePath(context);
  // 12
    CGContextRestoreGState(context);
  // 13
}

void addTopArrowFukidashiRoundedRectToPath(CGContextRef context, CGRect rect,
                                   CGFloat ovalWidth,CGFloat ovalHeight, CGPoint fukidashiPoint, CGFloat indicatorWidth_2)
{
  
  if( CGPointEqualToPoint(fukidashiPoint, CGPointZero) )
  {
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
    return;
  }
  
  CGFloat fw, fh;
  if (ovalWidth == 0 || ovalHeight == 0) {
    // 1
    CGContextAddRect(context, rect);
    return;
  }
  
  
  // Calc p1, p2
  CGPoint p1, p2;
  
  
  p1 = CGPointMake( fukidashiPoint.x - indicatorWidth_2,  CGRectGetMinY(rect));
  p2 = CGPointMake( fukidashiPoint.x + indicatorWidth_2,  CGRectGetMinY(rect));
  
  
  CGContextSaveGState(context);
  
  
  // 4
  fw = CGRectGetWidth (rect) ;
  // 5
  fh = CGRectGetHeight (rect) ;
  // 6
  
  CGContextMoveToPoint(context, fw+CGRectGetMinX(rect), fh/2+CGRectGetMinY(rect));
  
  
  
  // 7
  CGContextAddArcToPoint(context, fw+CGRectGetMinX(rect), fh+CGRectGetMinY(rect), fw+CGRectGetMinX(rect)-ovalWidth, fh+CGRectGetMinY(rect), ovalWidth);
  
  
  // 8
  CGContextAddArcToPoint(context, CGRectGetMinX(rect), fh+CGRectGetMinY(rect), CGRectGetMinX(rect), fh/2+CGRectGetMinY(rect), ovalWidth);
  
  
  // 9
  CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), fw+CGRectGetMinX(rect)-ovalWidth, CGRectGetMinY(rect), ovalWidth);
  // 10
  
  
  CGContextAddLineToPoint(context, p1.x, p1.y);
  CGContextAddLineToPoint(context, fukidashiPoint.x, fukidashiPoint.y);
  CGContextAddLineToPoint(context, p2.x, p2.y);
  
  
  CGContextAddArcToPoint(context, fw+CGRectGetMinX(rect), CGRectGetMinY(rect), fw+CGRectGetMinX(rect), fh/2+CGRectGetMinY(rect), ovalWidth);
  
  
  // 11
  CGContextClosePath(context);
  // 12
  CGContextRestoreGState(context);
  // 13
}


void addRoundedRectToPath(CGContextRef context, CGRect rect,
              CGFloat ovalWidth,CGFloat ovalHeight)
{
    CGFloat fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
    // 1
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
  // 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect),
               // 3
               CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
  // 4
    fw = CGRectGetWidth (rect) / ovalWidth;
  // 5
    fh = CGRectGetHeight (rect) / ovalHeight;
  // 6
    CGContextMoveToPoint(context, fw, fh/2);
  // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
  // 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
  // 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
  // 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
  // 11
    CGContextClosePath(context);
  // 12
    CGContextRestoreGState(context);
  // 13
}
