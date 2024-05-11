//
//  UIView+Animation.h
//  CalendarTest
//
//  Created by Masatoshi Nishikata on 09/08/24.
//  Copyright 2009 Catalystwo Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Animation)

-(void)rejectSwipeUp;
-(void)rejectSwipeDown;
-(void)rejectSwipeLeft;
-(void)rejectSwipeRight;
-(void)appearAnimation:(CGFloat)startScale startAlpha:(CGFloat)startAlpha;
-(void)popupAppearAnimation:(CGFloat)startScale from:(CGPoint)locationInWindow startAlpha:(CGFloat)startAlpha delay:(NSTimeInterval)delay;
-(void)tooltipAppearAnimation:(CGFloat)startScale startAlpha:(CGFloat)startAlpha delay:(NSTimeInterval)delay orientation:(UIInterfaceOrientation)orientation;
-(void)moveToCenter;
-(void)dragStartAnimation;
-(void)dragAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)dragAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)dragCornerStartAnimation;
-(void)dragCornerStartAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)dragCornerStartAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)shakeAnimation;
-(void)shakeAnimation1:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)shakeAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)bounceBack;
-(void)bounceBackAnimation:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)bounceBackAnimation2:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(void)bounceBackAnimation3:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
-(UIImage*)createGrayViewImageWithProvider;
-(UIImage*)createColorViewImageWithProvider:(CGFloat)scaleFactor;

-(void)mn_rejectAnimation;

@end
