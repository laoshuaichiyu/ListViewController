//
//  ZZHCustomNaviBarView.m
//  zhuzhenhua
//
//  Created by apple on 2018/5/15.
//  Copyright © 2018年 zhuzhenhua. All rights reserved.
//

#import "ZZHCustomNaviBarView.h"

#define RGBCOLOR(color) [UIColor colorWithRed:((color & 0xff0000) >> 16) / 255.0 green:((color & 0xff00) >> 8) / 255.0 blue:(color & 0xff) / 255.0 alpha:1]

const NSString *kBottomLineColor = @"kBottomLineColor";    // 下划线的颜色
const NSString *kSelectedTitleColor = @"kSelectedTitleColor"; // 选中状态下文本的颜色
const NSString *kNormalTitleColor = @"kNormalTitleColor";   // 普通状态下文本的颜色
const NSString *kBackgroundColor = @"kBackgroundColor";    // 背景颜色
const NSString *kShowArrowImg = @"kShowArrowImg";       // 右侧按钮图片
const CGFloat bottomLineWidth = 18;
const NSString *kSeparateLineColor = @"kSeparateLineColor";

@interface ZZHCustomNaviBarView ()<UIScrollViewDelegate> {
    UIButton *_lastItem; // 记录当前点击的item，即又一次点击时，这个item就是相对的上一次的
    UIEdgeInsets _edgeInsets;
    BOOL _showArrowImg;
}

@property (nonatomic, strong) UIScrollView *scrollView;// 滑动视图，作为所有item的父视图
@property (nonatomic, strong) UIView   *separateLine;
@property (nonatomic, strong) UIView   *currentLineView;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation ZZHCustomNaviBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        kBottomLineColor = @"asdfa";
        self.lineHeight = 1.5;
        self.fontSize = 16;
    }
    return self;
}

- (void)initConfigWithShowArrowImg:(BOOL)show titles:(NSArray *)titles edgeInsets:(UIEdgeInsets)edgeInsets {
    
    _showArrowImg = show;
    _titles = titles;
    _edgeInsets = edgeInsets;
    
    [self setupSubViews];
    [self resetItems];
    [self updateItemsLayout];
}

- (void)setupSubViews {
    CGFloat oneSelfWidth = CGRectGetWidth(self.bounds);
    CGFloat oneSelfHeight = CGRectGetHeight(self.bounds);
    CGRect scrollViewFrame = CGRectMake(0, 0, oneSelfWidth - _edgeInsets.right - (_showArrowImg ? oneSelfHeight : 0), oneSelfHeight);
    CGFloat scrollHeight = CGRectGetHeight(scrollViewFrame);
    
    self.scrollView.frame = scrollViewFrame;
    self.scrollView.contentInset = _edgeInsets;
    [self addSubview:self.scrollView];
    
    self.rightBtn.hidden = !_showArrowImg;
    [self.rightBtn setImage:self.rightImage forState:UIControlStateNormal];
    self.rightBtn.frame = CGRectMake(oneSelfWidth - oneSelfHeight, 0, oneSelfHeight, oneSelfHeight);
    [self addSubview:self.rightBtn];
    
    CGRect currentLineViewFrame = self.currentLineView.frame;;
    currentLineViewFrame.size.width = bottomLineWidth;
    currentLineViewFrame.size.height = self.lineHeight;
    currentLineViewFrame.origin.y = scrollHeight - self.lineHeight;
    self.currentLineView.frame = currentLineViewFrame;
    [_scrollView addSubview:self.currentLineView];
    
    self.backgroundColor = [self takeBackgroundColor];
    _scrollView.backgroundColor = [self takeBackgroundColor];
    if (self.showSeparateLine) {
        [self addSubview:self.separateLine];
    }
}

#pragma mark - 重新设置所有item
- (void)resetItems {
    NSMutableArray *allItems = [self.allItems mutableCopy];
    for (UIView *view in allItems) {
        [view removeFromSuperview];
    }
    NSArray *titles = self.titles;
    CGFloat fontSize = self.fontSize;
    NSInteger diff = titles.count - allItems.count;
    for (NSInteger i = 0; i < diff; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[self takeNormalTitleColor] forState:UIControlStateNormal];
        [btn setTitleColor:[self takeSelectedTitleColor] forState:UIControlStateSelected];
        [btn setTitleColor:[self takeSelectedTitleColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        btn.showsTouchWhenHighlighted = YES;
        [allItems addObject:btn];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (NSInteger i = 0; i < titles.count; i++) {
        NSString *title = [titles objectAtIndex:i];
        UIButton *btn   = [allItems objectAtIndex:i];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateSelected];
        [btn setTitle:title forState:UIControlStateSelected | UIControlStateHighlighted];
        CGFloat textWidth = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}].width;
        CGRect btnFrame = btn.frame;
        btnFrame.size.width = textWidth;
        btn.frame = btnFrame;
    }
    
    self.allItems = [allItems copy];
}

#pragma mark - 更新items布局
- (void)updateItemsLayout {
    CGFloat height = CGRectGetHeight(self.scrollView.frame);
    CGFloat originX = 0;
    CGFloat innerSpace = 25;
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.allItems];
    for (NSInteger i = 0; i < _titles.count; i++) {
        
        if (originX > 0) {
            originX += innerSpace;
        }
        UIButton *btn = [items objectAtIndex:i];
        
        CGRect btnFrame = btn.frame;
        btnFrame.origin.x = originX;
        btnFrame.origin.y = 0;
        btnFrame.size.height = height;
        btn.frame = btnFrame;
        originX += btnFrame.size.width;
        [_scrollView addSubview:btn];
    }
    self.allItems = items;
    if (originX == 0) {
        originX = CGRectGetWidth(_scrollView.bounds);
    }
    _scrollView.contentSize = CGSizeMake(originX, height);
}

- (void)btnAction:(UIButton *)sender {
    if (sender == nil) {
        return ;
    }
    
    [self scrollToPotionByItem:sender];
    
    if (self.currentIndexChangeBlock) {
        self.currentIndexChangeBlock(self.currentIndex);
    }
}

#pragma mark - 滑动到指定按钮的位置
- (void)scrollToPotionByItem:(UIButton *)item {
    
    _lastItem.selected = NO;
    item.selected = YES;
    _lastItem = item;
    
    CGFloat itemWidth = CGRectGetWidth(item.bounds);
    CGFloat itemHeight = CGRectGetHeight(item.bounds);
    CGFloat scrollViewWidth = CGRectGetWidth(_scrollView.bounds);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.currentLineView.center = CGPointMake(item.center.x, self.currentLineView.center.y);
    }];
    
    CGPoint position = [item convertPoint:CGPointMake(itemWidth / 2, itemHeight / 2) toView:self];
    CGFloat centerX = scrollViewWidth / 2;
    CGFloat differ = centerX - position.x;
    if (_scrollView.contentOffset.x - differ + _edgeInsets.left > 0 && (_scrollView.contentOffset.x + scrollViewWidth) - differ - _edgeInsets.right < _scrollView.contentSize.width) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x - differ, _scrollView.contentOffset.y) animated:YES];
    } else if (differ > 0) {
        [_scrollView setContentOffset:CGPointMake(-1 * _edgeInsets.left, _scrollView.contentOffset.y) animated:YES];
    } else if (differ < 0) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentSize.width - scrollViewWidth, _scrollView.contentOffset.y) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.contentOffset = CGPointMake(scrollView.contentOffset.x + _edgeInsets.left, scrollView.contentOffset.y);
}

#pragma mark - rightBtnAction
- (void)rightBtnAction:(UIButton *)sender {
    if (self.rightBtnClickBlock) {
        self.rightBtnClickBlock();
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex triggerClick:(BOOL)triggerClick {
    UIButton *item = (currentIndex >= self.allItems.count  ? [self.allItems lastObject] : [self.allItems objectAtIndex:currentIndex]);
    if (triggerClick) {
        [self btnAction:item];
    } else {
        [self scrollToPotionByItem:item];
    }
}

#pragma mark - 获取相关样式
#pragma mark 获取下划线颜色
- (UIColor *)takeBottomLineColor {
    UIColor *bottomLineColor = [self.style objectForKey:kBottomLineColor];
    if (bottomLineColor == nil) {
        bottomLineColor = RGBCOLOR(0x2f74e9);
    }
    return bottomLineColor;
}

#pragma mark 获取背景颜色
- (UIColor *)takeBackgroundColor {
    UIColor *backgroundColor = [self.style objectForKey:kBackgroundColor];
    if (backgroundColor == nil) {
        backgroundColor = RGBCOLOR(0xffffff);;
    }
    return backgroundColor;
}

#pragma mark 获取右侧图片
- (UIImage *)takeShowArrawImg {
    UIImage *img = [self.style objectForKey:kShowArrowImg];
    if (img == nil) {
        img = _rightBtn.currentImage;
    }
    return img;
}

#pragma mark 获取普通状态下Item的文本颜色
- (UIColor *)takeNormalTitleColor {
    UIColor *normalTitleColor = [self.style objectForKey:kNormalTitleColor];
    
    if (normalTitleColor == nil) {
        normalTitleColor = RGBCOLOR(0x333333);
    }
    return  normalTitleColor;
}

#pragma mark - 获取选中状态下item的文本颜色
- (UIColor *)takeSelectedTitleColor {
    UIColor *selectedTitleColor = [self.style objectForKey:kSelectedTitleColor];
    if (selectedTitleColor == nil) {
        selectedTitleColor = RGBCOLOR(0x2f74e9);
    }
    return selectedTitleColor;
}

- (void)layoutSubviews {
    [self setupSubViews];
    [self updateItemsLayout];
    
    self.separateLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5, CGRectGetWidth(self.bounds), 0.5);
}

#pragma mark - 重写setter方法
#pragma mark - 设置相关颜色
- (void)setStyle:(NSDictionary *)style {
    _style = style;
    UIColor *bottomLineColor = [style objectForKey:kBottomLineColor];
    UIColor *selectedTitleColor = [style objectForKey:kSelectedTitleColor];
    UIColor *normalTitleColor = [style objectForKey:kNormalTitleColor];
    UIColor *backgroundColor = [style objectForKey:kBackgroundColor];
    UIImage *rightImg = [style objectForKey:kShowArrowImg];
    rightImg = rightImg ? rightImg : _rightBtn.currentImage;
    self.rightImage = rightImg;
    self.backgroundColor = backgroundColor ? backgroundColor : [UIColor whiteColor];
    _scrollView.backgroundColor = backgroundColor ? backgroundColor : [UIColor whiteColor];
    
    [_rightBtn setImage:rightImg forState:UIControlStateNormal];
    
    if (bottomLineColor) {
        _currentLineView.backgroundColor = bottomLineColor;
    }
    
    for (UIButton *btn in self.allItems) {
        if (selectedTitleColor) {
            [btn setTitleColor:selectedTitleColor forState:UIControlStateSelected];
            
            [btn setTitleColor:selectedTitleColor forState:UIControlStateSelected | UIControlStateHighlighted];
        }
        if (normalTitleColor) {
            [btn setTitleColor:normalTitleColor forState:UIControlStateNormal];
        }
    }
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    _scrollView.bounces = bounces;
}

- (void)setLineHeight:(CGFloat)lineHeight {
    _lineHeight = lineHeight;
    CGFloat scrollViewHeight = CGRectGetHeight(_scrollView.bounds);
    if (_currentLineView) {
        CGRect currentLineViewFrame = _currentLineView.frame;
        currentLineViewFrame.size.height = lineHeight;
        currentLineViewFrame.origin.y = scrollViewHeight - lineHeight;
    }
}

- (void)setRightImage:(UIImage *)rightImage {
    _rightImage = rightImage;
    if (_rightBtn) {
        [_rightBtn setImage:rightImage forState:UIControlStateNormal];
    }
}

- (void)setShowSeparateLine:(BOOL)showSeparateLine {
    _showSeparateLine = showSeparateLine;
    if (showSeparateLine) {
        [self addSubview:self.separateLine];
    }
}

#pragma mark - 重写getter方法
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIButton *)rightBtn {
    if (_rightBtn == nil) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UIView *)separateLine {
    if (_separateLine == nil) {
        _separateLine = [UIView new];
        if ([self.style objectForKey:kSeparateLineColor]) {
            _separateLine.backgroundColor = [self.style objectForKey:kSeparateLineColor];
        }
    }
    return _separateLine;
}

- (UIView *)currentLineView {
    if (_currentLineView == nil) {
        _currentLineView = [UIView new];
        _currentLineView.backgroundColor = [self takeBottomLineColor];
    }
    return _currentLineView;
}

-  (NSInteger)currentIndex {
    NSString *currentTitle = _lastItem.currentTitle;
    return [self.titles indexOfObject:currentTitle] == NSNotFound ? 0 : [self.titles indexOfObject:currentTitle];
}

- (NSArray *)allItems {
    if (_allItems == nil) {
        _allItems = @[];
    }
    return _allItems;
}

#pragma mark - 请求按钮
- (void)clear {
    for (UIButton *btn in self.allItems) {
        [btn removeFromSuperview];
    }
    self.allItems = @[];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
