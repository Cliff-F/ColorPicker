//
//  TooltipView.h
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 09/10/31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef enum  {
  TooltipViewInformation = 0,
  TooltipViewCommand,
  TooltipViewDestructive
} TooltipViewType;


@interface DraggingTooltipView : NSObject <CALayerDelegate>{

	CALayer* tooltipLayer_;

	NSString* mText;
	CGSize mTextSize;
	
	TooltipViewType mTooltipType;
	CGPoint mTooltipLocation;
	CGSize mSize;
  
  BOOL mTopArrow;

}

+(DraggingTooltipView*)tooltip;
- (id)initWithFrame:(CGRect)frame ;
-(void)dealloc;
-(void)showDraggingTooltipAt:(CGPoint)location inView:(UIView*)view message:(NSString*)message type:(TooltipViewType)tooltipType afterDelay:(NSTimeInterval)delay ;
-(void)closeTooltip;
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;


@property (nonatomic, retain) 	NSString* text;

@property (nonatomic, readwrite) TooltipViewType tooltipType;
@property (nonatomic, readwrite) CGPoint tooltipLocation;
@property (nonatomic, readwrite) CGSize textSize;
@property (nonatomic, readwrite) BOOL topArrow;

@end
