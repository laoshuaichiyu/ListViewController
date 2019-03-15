//
//  ZZHListViewControllerDelegate.h
//  ListViewController
//
//  Created by 朱振华 on 2019/3/13.
//  Copyright © 2019年 zhuzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZZHListViewControllerDelegate <NSObject>

@required

/**
 获取要处理的滑动视图

 @param listController listController
 @param object object 该滑动视图所在的上层对象
 @return return scrollView
 */
- (UIScrollView *)listController:(UIViewController *)listController scrollViewForObject:(id)object;

@optional
- (void)listController:(UIViewController *)listController displayed:(BOOL)displayed;

@end

NS_ASSUME_NONNULL_END
