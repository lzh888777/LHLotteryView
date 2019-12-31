//
//  SNKSelectionAnimationView.m
//  SnakeGameSingle
//
//  Created by 刘志华 on 2019/10/30.
//  Copyright © 2019 WepieSnakeGame. All rights reserved.
//

#import "LHLotteryView.h"

#define kspeedForLinkStepLinear 1   //

@implementation LHLotteryViewParam

- (instancetype)init
{
    if (self = [super init]) {
        self.col = 3;
        self.row = 2;
        self.verticalMargin = 10;
        self.horizontalMargin = 48;
        self.itemViewSize = CGSizeMake(70, 76);
        self.speedUpAniStep = 6;
        self.speedDownAniStep = 6;
        self.speedLinerAniCicle = 4;
    }
    return self;
}

@end

@interface LHLotteryView ()

@property(nonatomic, strong) CADisplayLink *lotteryDisplayLink;
@property(nonatomic, assign) int speedForLinkStep;   //越小越快
@property(nonatomic, assign) int linkStep;
@property(nonatomic, assign) int curSelectionIndex;
@property(nonatomic, strong) UIView *selectionBgView;
@property(nonatomic, assign) int curAniCount;
@property(nonatomic, assign) int totalAniCount;
@property(nonatomic, copy) dispatch_block_t finishBlock;
@property(nonatomic, copy) void(^lotteryBlock)(UIView *view, NSInteger index);

@end

@implementation LHLotteryView

- (instancetype)initWithViews:(NSArray<UIView *> *)views
{
    return [self initWithViews:views param:nil];
}

- (instancetype)initWithViews:(NSArray<UIView *> *)views param:(nonnull LHLotteryViewParam *)param
{
    if (self = [super init]) {
        self.viewArr = views;
        self.clipsToBounds = NO;
        if (param == nil) {
            param = [[LHLotteryViewParam alloc] init];
        }
        self.viewParam = param;
        [self initSubViews];
        [self setUpConstraints];
        [self initDatas];
    }
    return self;
}

- (void)initDatas
{
    self.speedForLinkStep = kspeedForLinkStepLinear;
    self.curAniCount = 0;
    self.speedForLinkStep = self.speedForLinkStep + self.viewParam.speedUpAniStep;
    
}

- (void)initSubViews
{
    NSAssert(self.viewParam.col > 1 && self.viewParam.row > 1 , @"invalid param");
    if (self.viewParam.col >= 2 && self.viewParam.row >= 2) {
        NSAssert(self.viewParam.col * self.viewParam.row - (self.viewParam.col - 2) * (self.viewParam.row - 2) == self.viewArr.count , @"invalid param");
    }
    [self addSubview:self.selectionBgView];
    self.selectionBgView.frame = CGRectMake(0, 0, self.viewParam.itemViewSize.width +2, self.viewParam.itemViewSize.height + 2);
    for (UIView *view in self.viewArr) {
        [self addSubview:view];
    }
}

- (void)setUpConstraints
{
    
    for (int index = 0; index < self.viewArr.count ; index ++) {
        int row = 0;
        int col = 0;
        if (index < self.viewParam.col) {
            row = 0;
            col = index;
        }else if (index >= self.viewParam.col && index < self.viewParam.col + self.viewParam.row - 1) {
            col = self.viewParam.col - 1;
            row = index - self.viewParam.col + 1;
        }else if(index >= self.viewParam.col + self.viewParam.row - 1 && index < 2 * self.viewParam.col + self.viewParam.row - 2){
            row = self.viewParam.row - 1;
            col = self.viewParam.col - (index - (self.viewParam.col + self.viewParam.row - 1)) - 2;
        }else{
            col = 0;
            row = self.viewParam.row - (index - (2 * self.viewParam.col + self.viewParam.row - 2)) - 2;
        }
        UIView *curView = self.viewArr[index];
        CGFloat x = col * (self.viewParam.itemViewSize.width + self.viewParam.horizontalMargin);
        CGFloat y = row * (self.viewParam.itemViewSize.height + self.viewParam.verticalMargin);
        curView.frame = CGRectMake(x, y, self.viewParam.itemViewSize.width, self.viewParam.itemViewSize.height);
    }
}

- (void)setStartViewIndex:(int)startViewIndex
{
    if (startViewIndex >= 0&&startViewIndex < self.viewArr.count) {
        _startViewIndex = startViewIndex;
        UIView *view = self.viewArr[startViewIndex];
        self.selectionBgView.hidden = NO;
        self.selectionBgView.center = view.center;
    }else{
        self.selectionBgView.hidden = YES;
    }

}

- (void)killAnimation
{
    if (_lotteryDisplayLink) {
        [_lotteryDisplayLink invalidate];
        _lotteryDisplayLink = nil;
    }
}


- (void)startLotteryAnimationOnViewIndex:(int)index completion:(dispatch_block_t)completion
{
    [self startLotteryAnimationOnViewIndex:index lotteryBlock:nil completion:completion];
}


- (void)startLotteryAnimationOnViewIndex:(int)index lotteryBlock:(void(^)(UIView *view,NSInteger curIndex))lotteryBlock completion:(dispatch_block_t)completion{
    
    if (index >= self.viewArr.count||self.lotteryDisplayLink.isPaused == NO) {
        !completion ?: completion();
        return;
    }
    [self initDatas];
    int constAniCount = self.viewParam.speedUpAniStep + self.viewParam.speedDownAniStep + (int)(self.viewParam.speedLinerAniCicle* self.viewArr.count);
    int constMoveIndex = constAniCount % self.viewArr.count;
    int constCurSelectionIndex = (constMoveIndex + self.curSelectionIndex) % self.viewArr.count;
    int deltaIndex = index >= constCurSelectionIndex ? index - constCurSelectionIndex : (int)self.viewArr.count - constCurSelectionIndex + index;
    int totalAniCount = constAniCount + deltaIndex;
    self.totalAniCount = totalAniCount;
    self.selectionBgView.hidden = NO;
    
    [self.lotteryDisplayLink setPaused:NO];
    self.finishBlock = completion;
    self.lotteryBlock = lotteryBlock;
}

- (void)p_startLotteryAnimation
{
    if (self.linkStep == self.speedForLinkStep) {
        self.curSelectionIndex = (self.curSelectionIndex + 1) % self.viewArr.count;
        UIView *view = self.viewArr[self.curSelectionIndex];
        self.selectionBgView.center = view.center;
        self.linkStep = 0;
        self.curAniCount ++;
        !self.lotteryBlock ?: self.lotteryBlock(view,self.curSelectionIndex);
        if (self.curAniCount == self.totalAniCount) {
            [self.lotteryDisplayLink setPaused:YES];
            !self.finishBlock ?: self.finishBlock();
        }else if (self.speedForLinkStep > kspeedForLinkStepLinear && self.curAniCount <= self.viewParam.speedUpAniStep) {
            self.speedForLinkStep --;
        }else if (self.curAniCount == self.viewParam.speedUpAniStep + (self.viewParam.speedLinerAniCicle * self.viewArr.count)) {
            self.speedForLinkStep = kspeedForLinkStepLinear + kspeedForLinkStepLinear;
        }else if (self.curAniCount > self.totalAniCount - self.viewParam.speedDownAniStep) {
            self.speedForLinkStep = self.speedForLinkStep + 3;
        }
    }else{
        self.linkStep ++;
    }
}


- (CADisplayLink *)lotteryDisplayLink
{
    if (!_lotteryDisplayLink) {
        _lotteryDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_startLotteryAnimation)];
        [_lotteryDisplayLink setPaused:YES];
        [_lotteryDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _lotteryDisplayLink;
}

- (UIView *)selectionBgView
{
    if (!_selectionBgView) {
        _selectionBgView = [UIView new];
        _selectionBgView.layer.cornerRadius = 6;
        _selectionBgView.backgroundColor = [UIColor redColor];//UIColorFromHex(0xFFE73D);
        _selectionBgView.hidden = YES;
    }
    return _selectionBgView;
}


@end
