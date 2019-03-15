//
//  NSObject+ZZHListPageFlag.m
//  ListViewController
//
//  Created by 朱振华 on 2019/3/13.
//  Copyright © 2019年 zhuzhenhua. All rights reserved.
//

#import "NSObject+ZZHListPageFlag.h"
#import <objc/runtime.h>

@implementation NSObject (ZZHListPageFlag)
@dynamic pageFlag;

- (void)setPageFlag:(NSInteger)pageFlag {
    objc_setAssociatedObject(self, @selector(pageFlag), @(pageFlag), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)pageFlag {
    id pageFlag = objc_getAssociatedObject(self, @selector(pageFlag));
    return pageFlag ? [pageFlag integerValue] : NSNotFound;
}

@end
