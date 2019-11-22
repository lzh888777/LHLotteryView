//
//  ViewController.m
//  LHLotteryViewDemo
//
//  Created by 刘志华 on 2019/11/22.
//  Copyright © 2019 刘志华. All rights reserved.
//

#import "ViewController.h"
#import "LHLotteryView.h"

@interface ViewController ()

@property(nonatomic, strong) LHLotteryView *lotteryView;

@property(nonatomic, weak) UIView *selectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.lotteryView.frame = CGRectMake(30, 100, 306, 162);
    [self.view addSubview:self.lotteryView];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(0, 0, 160, 42);
    startBtn.layer.cornerRadius = 21;
    startBtn.center = CGPointMake(self.lotteryView.center.x, self.view.bounds.size.height - 100);
    [startBtn setTitle:@"start" forState:UIControlStateNormal];
    startBtn.backgroundColor = [UIColor redColor];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
}

- (void)setSelectionView:(UIView *)selectionView
{
    if (![_selectionView isEqual:selectionView]) {
        _selectionView.backgroundColor = [UIColor yellowColor];
        selectionView.backgroundColor = [UIColor orangeColor];
        _selectionView = selectionView;
    }
}

- (void)startBtnClick:(UIButton *)sender{
    sender.alpha = 0.8;
    sender.enabled = NO;
//    [self.lotteryView startLotteryAnimationOnViewIndex:3 completion:^{
//        sender.alpha = 1.0;
//        sender.enabled = YES;
//    }];
    [self.lotteryView startLotteryAnimationOnViewIndex:3 lotteryBlock:^(UIView *view, NSInteger curIndex) {
        self.selectionView = view;
        NSLog(@"the index is %ld",(long)curIndex);
    } completion:^{
        sender.alpha = 1.0;
        sender.enabled = YES;
    }];
}

- (LHLotteryView *)lotteryView
{
    if (!_lotteryView) {
        NSMutableArray *views = [NSMutableArray arrayWithCapacity:6];
        for (NSInteger index = 0; index < 8 ; index ++) {
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor yellowColor];
            view.layer.cornerRadius = 6;
            [views addObject:view];
        }
//        _lotteryView = [[LHLotteryView alloc] initWithViews:views];
        LHLotteryViewParam *param = [LHLotteryViewParam new];
        param.speedUpAniStep = (int)views.count;
        param.speedDownAniStep = (int)views.count;
        param.col = 3;
        param.row = 3;
        param.speedLinerAniCicle = 5;
        _lotteryView = [[LHLotteryView alloc] initWithViews:views param:param];
    }
    return _lotteryView;
}


@end
