//
//  ViewController.m
//  ListViewController
//
//  Created by 朱振华 on 2019/2/10.
//  Copyright © 2019年 zhuzhenhua. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "ZZHCustomNaviBarView.h"
#import "TestViewController.h"
#import "ZZHListViewController.h"

@interface ViewController ()

@property (nonatomic, strong) ZZHCustomNaviBarView   *naviBarView;
@property (nonatomic, strong) ZZHListViewController *listController;
@property (nonatomic, strong) NSArray               *listContentControllers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    [self loadData];
    [self setupListContentController];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - 加载子控制器
- (void)setupSubChildController {
    [self addChildViewController:self.listController];
}

#pragma mark - 加载子视图
- (void)setupSubViews {
    [self.view addSubview:self.listController.view];
    [self.view addSubview:self.naviBarView];
    
    [self.naviBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(20);
        make.left.with.right.mas_offset(0);
        make.height.mas_equalTo(30);
    }];
    
    [self.listController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviBarView.mas_bottom);
        make.left.bottom.with.right.mas_offset(0);
    }];
}

#pragma mark - 加载列表内容容器
- (void)setupListContentController {
    NSMutableArray *contentContollers = [NSMutableArray array];
    NSMutableArray *contentViews      = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 11; i++) {
        TestViewController *vc = [TestViewController new];
        [contentContollers addObject:vc];
        [contentViews addObject:vc.view];
    }
    
    if ([self.listController addDelegates:contentContollers]) {
        [self.listController setupSubViews:contentViews];
    } else {
        return ;
    }
    
    self.listContentControllers = contentContollers;
    [self.listController setupHeaderView:[self createHeaderView]];
}

#pragma mark - 加载数据
- (void)loadData {
    NSArray *titles = @[@"第一组",@"第二组",@"第三组",@"第四组",@"第五组",@"第六组",@"第七组",@"第八组",@"第九组",@"第十组",@"第十一组"];
    [self.naviBarView initConfigWithShowArrowImg:NO titles:titles edgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.naviBarView setCurrentIndex:0 triggerClick:YES];
}

#pragma mark - 创建头视图
- (UIView *)createHeaderView {
    UIImage *image = [UIImage imageNamed:@"9.jpg"];
    CGFloat width  = CGRectGetWidth(self.view.bounds);
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width * image.size.height / image.size.width)];
    headerView.layer.contents = (__bridge id)image.CGImage;
    return headerView;
}

#pragma mark - 重写getter方法
- (ZZHCustomNaviBarView *)naviBarView {
    if (!_naviBarView) {
        _naviBarView = [[ZZHCustomNaviBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
        __weak typeof(& *self) weakSelf = self;
        _naviBarView.currentIndexChangeBlock = ^(NSInteger index) {
            if (weakSelf) {
                weakSelf.listController.currentIndex = index;
            }
        };
    }
    return _naviBarView;
}

- (ZZHListViewController *)listController {
    if (!_listController) {
        _listController = [ZZHListViewController new];
        __weak typeof(& *self) weakSelf = self;
        _listController.currentIndexChangeCall = ^(NSInteger Index) {
            if (weakSelf) {
                [weakSelf.naviBarView setCurrentIndex:Index triggerClick:NO];
            }
        };
    }
    return _listController;
}

@end
