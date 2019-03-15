//
//  ZZHListViewController.h
//  ListViewController
//
//  Created by 朱振华 on 2019/3/13.
//  Copyright © 2019年 zhuzhenhua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CurrentIndexChangeCall)(NSInteger Index);

NS_ASSUME_NONNULL_BEGIN

@interface ZZHListViewController : UIViewController

@property (nonatomic, assign) NSInteger currentIndex; // 游标,标记当前滑到的位置
@property (nonatomic, assign) CGFloat   headerHeight; // 头视图的高度，决定子滑动视图的对齐位置
@property (nonatomic, copy)   CurrentIndexChangeCall currentIndexChangeCall; // 游标改变通知，在游标值发生变动的时候会调用该block

// 代理对象的顺序应该是和子视图数组中对应的子视图的位置是一致的
/**
 添加代理对象

 @param delegates 代理对象
 @return 是否添加成功
 */

- (BOOL)addDelegates:(NSArray *)delegates;


/**
 设置子视图

 @param subViews 子视图
 */
- (void)setupSubViews:(NSArray *)subViews;

/**
 添加头视图

 @param headerView 头视图
 */
- (void)setupHeaderView:(UIView *)headerView;

@end

NS_ASSUME_NONNULL_END
