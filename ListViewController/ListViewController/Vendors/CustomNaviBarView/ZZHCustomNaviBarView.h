//
//  ZZHCustomNaviBarView.h
//  zhuzhenhua
//
//  Created by apple on 2018/5/15.
//  Copyright © 2018年 zhuzhenhua. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString *kBottomLineColor;    // 下划线的颜色
extern const NSString *kSelectedTitleColor; // 选中状态下文本的颜色
extern const NSString *kNormalTitleColor;   // 普通状态下文本的颜色
extern const NSString *kBackgroundColor;    // 背景颜色
extern const NSString *kShowArrowImg;       // 右侧按钮图片
extern const NSString *kSeparateLineColor;  // 下方分割线颜色

@interface ZZHCustomNaviBarView : UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView;// 滑动视图，作为所有item的父视图
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *allItems;
@property (nonatomic, strong) UIImage *rightImage;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) NSDictionary *style;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, copy) void(^currentIndexChangeBlock)(NSInteger index);
@property (nonatomic, copy)             dispatch_block_t rightBtnClickBlock;
@property (nonatomic, assign) BOOL showSeparateLine;

- (void)initConfigWithShowArrowImg:(BOOL)show titles:(NSArray *)titles edgeInsets:(UIEdgeInsets)edgeInsets;

- (void)setCurrentIndex:(NSInteger)currentIndex triggerClick:(BOOL)triggerClick;
- (NSInteger)currentIndex;

- (void)btnAction:(UIButton *)sender;

// 重新设置所有item
- (void)resetItems;
// 重新布局items
- (void)updateItemsLayout;

@end
