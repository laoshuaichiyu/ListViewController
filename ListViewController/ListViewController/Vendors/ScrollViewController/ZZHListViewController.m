//
//  ZZHListViewController.m
//  ListViewController
//
//  Created by 朱振华 on 2019/3/13.
//  Copyright © 2019年 zhuzhenhua. All rights reserved.
//

#import "ZZHListViewController.h"
#import "ZZHListViewControllerDelegate.h"
#import "NSObject+ZZHListPageFlag.h"
#import <Masonry.h>

@interface ZZHListViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView; // 主滑动视图，用于决定当前应该显示哪个子滑动视图
@property (nonatomic, strong) UIView       *scrollContentView; // 容器视图，用于承载子滑动视图

@property (nonatomic, strong) NSHashTable<id<ZZHListViewControllerDelegate>>  *delegates; // 代理对象集合
@property (nonatomic, strong) NSArray      *subViews; // 子视图数据
@property (nonatomic, strong) NSArray      *subScrollViews; // 子滑动视图数组

@property (nonatomic, strong) UIView       *headerView; // 头视图

@property (nonatomic, assign) NSInteger    lastIndex;  // 上一个游标值

@end

@implementation ZZHListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 加载容器视图
    [self loadContentView];
    // Do any additional setup after loading the view.
}

#pragma make - 加载容器视图
- (void)loadContentView {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollContentView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
}

#pragma mark - method
#pragma mark 添加代理对象
- (BOOL)addDelegates:(NSArray *)delegates {
    NSHashTable    *hashTable = [NSHashTable weakObjectsHashTable];
    NSMutableArray *subScrollView = [NSMutableArray array];
    for (NSInteger i = 0; i < delegates.count; i++) {
        id delegate = [delegates objectAtIndex:i];
        [delegate setPageFlag:i];
        [hashTable addObject:delegate];
        
        NSAssert([delegate respondsToSelector:@selector(listController:scrollViewForObject:)], @"无法找到处理的对象");
        if ([delegate respondsToSelector:@selector(listController:scrollViewForObject:)]) {
            UIScrollView *scrollView = [delegate listController:self scrollViewForObject:delegate];
            [subScrollView addObject:scrollView];
        } else {
            // 如果不能得到预期的结果则终止,并返回NO
            return NO;
        }
    }
    // 移除之前对子滑动视图contentOffset属性的监控
    [self removeObserverForTheSubscrollView];
    // 重新设置子滑动视图
    self.subScrollViews = subScrollView;
    // 添加对新的子滑动视图contentOffset属性的监控
    [self addObserverForTheSubscrollView];
    
    [self.delegates removeAllObjects];
    [self.delegates unionHashTable:hashTable];
    return YES;
}

#pragma mark - 添加子视图
- (void)setupSubViews:(NSArray *)subViews {
    NSArray<UIView *> *oldSubViews = self.subViews;
    [oldSubViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.subViews = subViews;
    if (subViews.count == 0) {
        NSAssert(subViews.count > 0, @"无效的视图数组");
        return ;
    }
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.scrollContentView addSubview:obj];
    }];
    if (subViews.count == 1) {
        UIView *view = [subViews lastObject];
        view.frame = self.scrollView.bounds;
    } else {
        [subViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [subViews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.with.height.equalTo(self.scrollView);
        }];
    }
}

#pragma mark - 添加头视图
- (void)setupHeaderView:(UIView *)headerView {
    self.headerView = headerView;
    
    CGFloat headerHeight = CGRectGetHeight(headerView.bounds);
    NSArray<UIScrollView *> *subScrollViews = self.subScrollViews;
    [subScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        CGPoint contentOffset = obj.contentOffset;
        contentOffset.y -= headerHeight;
        obj.contentOffset = contentOffset;
        
        // 修正子滑动视图的内容高度
        [self patchSubScrollContentSizeWithScrollView:obj];
    }];
    
    [self.view addSubview:headerView];
}

#pragma mark - 清除子视图
- (void)clearSubViews {
    NSArray<UIView *> *subViews = self.subViews;
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.subViews = nil;
}

#pragma mark - 添加对子滑动视图contentOffset, contentSize属性的监控
- (void)addObserverForTheSubscrollView {
    NSArray<UIScrollView *> *subScrollViews = self.subScrollViews;
    [subScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)[NSString stringWithFormat:@"%ld", idx]];
        [obj addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)[NSString stringWithFormat:@"%ld", idx]];
    }];
}

#pragma mark - 移除对子滑动视图contentOffset, contentSize属性的监控
- (void)removeObserverForTheSubscrollView {
    NSArray<UIScrollView *> *subScrollViews = self.subScrollViews;
    [subScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [subScrollViews removeObserver:self forKeyPath:@"contentOffset"];
        [subScrollViews removeObserver:self forKeyPath:@"contentSize"];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint contentOffset = *targetContentOffset;
    CGFloat offsetX = contentOffset.x;
    CGFloat width   = CGRectGetWidth(scrollView.bounds);
    
    NSInteger currentIndex = offsetX / width;
    if (_currentIndex != currentIndex) {
        self.currentIndex = currentIndex;
        // 通知改变了游标值
        if (self.currentIndexChangeCall) {
            self.currentIndexChangeCall(currentIndex);
        }
    }
}

#pragma mark - KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self patchSubScrollContentSizeWithScrollView:(UIScrollView *)object];
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        if (!context) {
            return ;
        }
        // 如果没有设置头视图则不需要进行对齐
        if (!self.headerView) {
            return;
        }
        
        // 如果context 值得类型不为字符串则终止函数的执行
        if (![(__bridge id)context isKindOfClass:[NSString class]]) {
            return ;
        }
        NSInteger index = [(__bridge NSString *)context integerValue];
        
        // 如果收到的监控对象不是当前显示的对象则终止函数的执行
        if (index != self.currentIndex) {
            return ;
        }
        [self resetHeaderViewFrameWithScrollView:(UIScrollView *)object change:change];
    }
}

#pragma mark - 如果在有设置头视图的情况下，如果子滑动视图的contentSize的高度小于 自身的高度(contentInset影响)，则把其内容视图的高度置为 自身的高度
- (void)patchSubScrollContentSizeWithScrollView:(UIScrollView *)scrollView {
    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.bounds);
    CGSize  contentSize      = scrollView.contentSize;
    
    if (contentSize.height < scrollViewHeight) {
        contentSize.height = scrollViewHeight;
        scrollView.contentSize = contentSize;
    }
}

#pragma mark 在有设置头视图的时候需要在滑动的时候变更头视图的位置，并对其他的滑动进行对齐
- (void)resetHeaderViewFrameWithScrollView:(UIScrollView *)scrollView change:(NSDictionary<NSKeyValueChangeKey,id> *)change {
    UIView  *headerView  = self.headerView;
    CGRect  headerFrame  = headerView.frame;
    CGPoint headerOrigin = headerFrame.origin;
    CGFloat headerHeight = CGRectGetHeight(headerFrame);
    CGPoint beginOffset = CGPointMake(0, headerHeight * -1);
    
    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.bounds);
    CGPoint newContentOffset = scrollView.contentOffset;
    CGPoint oldContentOffset = [change objectForKey:NSKeyValueChangeOldKey] ? [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue] : beginOffset;
    
    // 消除因为放置头视图
    newContentOffset.y += headerHeight;
    oldContentOffset.y += headerHeight;
    
    // 以偏移量往大的方向为正向，反之亦然
    BOOL positive;
    // 是否是有效滑动
    BOOL validScroll;
    
    // 计算头视图的位置
    headerOrigin = [self takeHeaderViewPositionWithHeaderFrame:headerFrame scrollViewHeight:scrollViewHeight newContentOffset:newContentOffset oldContentOffset:oldContentOffset positive:&positive validScroll:&validScroll];
    // 重新设置头视图的位置
    headerFrame.origin = headerOrigin;
    self.headerView.frame = headerFrame;
    
    if (validScroll) {
        NSMutableArray<UIScrollView *> *subScrollViews = [self.subScrollViews mutableCopy];
        [subScrollViews removeObject:scrollView];
        NSArray *otherScrolViews = [subScrollViews copy];
        [self alignmentOtherScrollViews:otherScrolViews headerHeight:headerHeight prositive:positive scrollDis:(fabs(newContentOffset.y - oldContentOffset.y))];
    }
}

#pragma mark 根据相关参数计算头视图应该变更的位置
/**
 根据相关参数计算头视图应该变更的位置

 @param headerFrame 头视图frame
 @param newContentOffset 当前滑动视图的新偏移量
 @param oldContentOffset 当前滑动视图的旧偏移量
 @param positive 是否是正向滑动， 以偏移量往大的方向为正向，反之亦然
 @param validScroll 是否是有效滑动
 @return 计算结果
 */
- (CGPoint)takeHeaderViewPositionWithHeaderFrame:(CGRect)headerFrame scrollViewHeight:(CGFloat)scrollViewHeight newContentOffset:(CGPoint)newContentOffset oldContentOffset:(CGPoint)oldContentOffset positive:(BOOL *)positive validScroll:(BOOL *)validScroll {
    CGPoint headerOrigin = headerFrame.origin;
    CGFloat headerHeight = CGRectGetHeight(headerFrame);
    
    *positive = newContentOffset.y >= oldContentOffset.y;
    
    /* 在正方向滑动时如果头视图的originY的值在（（headerHeight * -1），0） 之间则 originY 应减去当前偏移量相较于上次偏移的距离，如果减去这个距离后 originY 小于 headerHeight * -1，则把originY置为headerHeight * -1
     * 如果是反方向滑动时，如果头视图的originY的值在（（headerHeight * -1），0） 之间则 originY 应加上当前偏移量相较于上次偏移的距离，如果加上这个距离后 originY 大于0，则把originY置为0
     * 反方向滑动时会出现一种情况，就是滑到最小偏移时，如果继续滑动，然后松开后会出发反弹，此时会引起正向滑动行为，此种滑动行为不应改变头视图的originY的值，在正向滑动操作中应该对这种情况进行判断
     * 正方向滑动滑到最大偏移时也有类似的情况，此时也应进行处理
     */
    CGFloat scrollDis = fabs(newContentOffset.y - oldContentOffset.y); // 滑动距离
    if (*positive) {
        *validScroll = newContentOffset.y > 0 && oldContentOffset.y > 0 && headerOrigin.y <= 0;
        if (*validScroll && headerOrigin.y >= headerHeight * -1) {
            headerOrigin.y -= scrollDis;
            if (headerOrigin.y < headerHeight * -1) {
                headerOrigin.y = headerHeight * -1;
            }
        }
    } else {
        *validScroll = (newContentOffset.y <= headerHeight);
        
        if (*validScroll && headerOrigin.y <= 0 && headerOrigin.y >= headerHeight * -1) {
            headerOrigin.y += scrollDis;
            if (headerOrigin.y > 0) {
                headerOrigin.y = 0;
            }
        }
    }
    return headerOrigin;
}

#pragma mark 对齐其他的滑动视图
- (void)alignmentOtherScrollViews:(NSArray *)otherScrollViews headerHeight:(CGFloat)headerHeight prositive:(BOOL)prositive scrollDis:(CGFloat)scrollDis {
    for (UIScrollView *scrollView in otherScrollViews) {
        CGPoint contentOffset    = scrollView.contentOffset;
        CGSize  contentSize      = scrollView.contentSize;
        CGFloat scrollViewHeight = CGRectGetHeight(scrollView.bounds);
        contentSize.height += headerHeight;
        contentOffset.y += headerHeight;
        /* 如果是正方向滑动，则把当前滑动视图的偏移量加上指定偏移距离，如果是反方向滑动则减去指定偏移距离
         * 正向滑动时偏移量不能超过正常最大偏移，如果超过则置为正常最大偏移。
         * 反向滑动时要考虑到不能小于初始偏移量
         */
        if (prositive) {
            contentOffset.y += scrollDis;
            if (contentOffset.y + scrollViewHeight > contentSize.height) {
                contentOffset.y = contentSize.height - scrollViewHeight;
            }
        } else {
            contentOffset.y -= scrollDis;
            if (contentOffset.y < 0) {
                contentOffset.y = 0;
            }
        }
        contentOffset.y -= headerHeight;
        scrollView.contentOffset = contentOffset;
    }
}

#pragma mark - 通知代理对象是显示和消失
- (void)notifyDelegateObjectDisplayed {
    NSInteger currentIndex = self.currentIndex;
    NSInteger lastIndex    = self.lastIndex;
    
    id<ZZHListViewControllerDelegate> currentDelegate = [self searchDelegateWithNonius:currentIndex];
    id<ZZHListViewControllerDelegate> lastDelegate    = [self searchDelegateWithNonius:lastIndex];
    
    // 通知代理对象已经是显示状态
    if (currentDelegate && [currentDelegate respondsToSelector:@selector(listController:displayed:)]) {
        [currentDelegate listController:self displayed:YES];
    }
    // 通知代理对象已经是非显示状态
    if (lastDelegate && [lastDelegate respondsToSelector:@selector(listController:displayed:)]) {
        [lastDelegate listController:self displayed:NO];
    }
}

#pragma mark - 查找指定位置的代理对象
- (id<ZZHListViewControllerDelegate>)searchDelegateWithNonius:(NSInteger)nonius {
    __block id <ZZHListViewControllerDelegate> delegate = nil;
    NSArray *delegates = [self.delegates allObjects];
    [delegates enumerateObjectsUsingBlock:^(NSObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pageFlag == nonius) {
            delegate = (id<ZZHListViewControllerDelegate>)obj;
            *stop = YES;
        }
    }];
    return delegate;
}

#pragma mark - 重写setter方法
- (void)setCurrentIndex:(NSInteger)currentIndex {
    self.lastIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    // 滑动容器视图到指定位置
    CGFloat scrollWidth = CGRectGetWidth(self.scrollView.bounds);
    [self.scrollView setContentOffset:CGPointMake(scrollWidth * currentIndex, 0) animated:YES];
    
    // 指定代理对象其视图的显示和消失
    [self notifyDelegateObjectDisplayed];
}

#pragma mark - 重写getter方法
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _scrollView;
}

- (UIView *)scrollContentView {
    if (!_scrollContentView) {
        _scrollContentView = [UIView new];
    }
    return _scrollContentView;
}

- (NSHashTable *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (CGFloat)headerHeight {
    if (_headerHeight == 0 && self.headerView) {
        return CGRectGetHeight(self.headerView.bounds);
    }
    return _headerHeight;
}

- (void)dealloc {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
