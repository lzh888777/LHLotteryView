//
//  SNKSelectionAnimationView.h
//  SnakeGameSingle
//
//  Created by 刘志华 on 2019/10/30.
//  Copyright © 2019 WepieSnakeGame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHLotteryViewParam : NSObject

@property(nonatomic, assign) int row;   //排列的行数，默认3

@property(nonatomic, assign) int col;   //排列的列数，默认2

@property(nonatomic, assign) CGFloat verticalMargin; //垂直方向相互间距，默认10

@property(nonatomic, assign) CGFloat horizontalMargin; //水平方向相互间距10

@property(nonatomic, assign) CGSize itemViewSize; //每个格子的大小，默认（70，76）

@property(nonatomic, assign) int speedUpAniStep;  //加速步数，默认6

@property(nonatomic, assign) int speedDownAniStep;  //减速步数，默认8

@property(nonatomic, assign) int speedLinerAniCicle; //匀速圈数,默认4圈

@end

@interface LHLotteryView : UIView

@property(nonatomic, strong) NSArray *viewArr;    //格子view数组

@property(nonatomic, strong) LHLotteryViewParam *viewParam;   //动画及布局参数对象

@property(nonatomic, assign) int startViewIndex;    //抽奖开始的位置

- (instancetype)initWithViews:(NSArray<UIView *> *)views;

- (instancetype)initWithViews:(NSArray<UIView *> *)views param:(LHLotteryViewParam *)param;

//抽奖开始
/*
 *  @param index 最终落在格子数组的index
 *  @param completion 动画完成的回调
 */
- (void)startLotteryAnimationOnViewIndex:(int)index completion:(dispatch_block_t)completion;


//抽奖开始
/*
 *  @param index 最终落在格子数组的index
 *  @param lotteryBlock 动画完成的回调
 *  @param completion 动画完成的回调
 */
- (void)startLotteryAnimationOnViewIndex:(int)index lotteryBlock:(void(^)(UIView *view,NSInteger curIndex))lotteryBlock completion:(dispatch_block_t)completion;

//关闭定时器避免内存泄漏
- (void)killAnimation;

@end
