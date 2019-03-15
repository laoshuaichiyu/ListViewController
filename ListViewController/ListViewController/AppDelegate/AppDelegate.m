//
//  AppDelegate.m
//  ListViewController
//
//  Created by 朱振华 on 2019/2/10.
//  Copyright © 2019年 zhuzhenhua. All rights reserved.
//

#import "AppDelegate.h"

typedef struct _TreeNode {
    struct _TreeNode *left;
    struct _TreeNode *right;
    NSString *value;
} TreeNode;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

- (NSArray *)mergeSort:(NSArray *)array start:(NSInteger)start end:(NSInteger)end {
    if (start == end) {
        return [array subarrayWithRange:NSMakeRange(start, 1)];
    } else if (start > end) {
        return @[];
    }
    
    NSInteger mid = (start + end) / 2;
    NSArray *firstArray = [self mergeSort:array start:start end:mid];
    NSArray *secondArray = [self mergeSort:array start:mid + 1 end:end];
    NSMutableArray *sorts = [NSMutableArray array];
    NSInteger firstPosition = 0;
    NSInteger secondPosition = 0;
    while (1) {
        if (firstArray.count <= firstPosition || secondArray.count <= secondPosition) {
            break;
        }
        
        if ([[firstArray objectAtIndex:firstPosition] integerValue] < [[secondArray objectAtIndex:secondPosition] integerValue]) {
            [sorts addObject:[firstArray objectAtIndex:firstPosition]];
            firstPosition ++;
        } else {
            [sorts addObject:[secondArray objectAtIndex:secondPosition]];
            secondPosition ++;
        }
    }
    for (; firstPosition < firstArray.count; firstPosition++) {
        [sorts addObject:[firstArray objectAtIndex:firstPosition]];
    }
    for (; secondPosition < secondArray.count; secondPosition++) {
        [sorts addObject:[secondArray objectAtIndex:secondPosition]];
    }
    return [sorts copy];
}

- (void)createTree {
    NSArray *data = @[@"3", @"5", @"1", @"6", @"2", @"0", @"8", @"null", @"null", @"7", @"4"];
    TreeNode *root = [self createWithindex:0 data:data];
    [self printNode:root];
    TreeNode *p = [self searchNode:root value:@"2"];
    TreeNode *q = [self searchNode:root value:@"0"];
    TreeNode *node = [self lowestCommonAncestorRoot:root p:p q:q];
    NSLog(@"%@", node->value);
}

- (TreeNode *)searchNode:(TreeNode *)node value:(NSString *)value {
    if (node == NULL) {
        return node;
    }
    if ([node->value isEqualToString:value]) {
        return node;
    }
    TreeNode *left = [self searchNode:node->left value:value];
    if (left != NULL) {
        return left;
    }
    
    TreeNode *right = [self searchNode:node->right value:value];
    return right;
}

- (TreeNode *)lowestCommonAncestorRoot:(TreeNode *)root p:(TreeNode *)p q:(TreeNode *)q {
    if (root == NULL || root == p || root == q) {
        return root;
    }
    TreeNode *left = [self lowestCommonAncestorRoot:root->left p:p q:q];
    TreeNode *right = [self lowestCommonAncestorRoot:root->right p:p q:q];
    
    if (left == NULL && right == NULL) return NULL;
    if (left != NULL && right != NULL) return root;
    return left == NULL ? right : left;
}

- (TreeNode *)createWithindex:(NSInteger)index data:(NSArray *)data {
    if (2 * index + 1 >= data.count || 2 * index + 2 >= data.count) {
        NSString *value = [data objectAtIndex:index];
        TreeNode *node = (TreeNode *)malloc(sizeof(TreeNode));
        node->value = value;
        node->left = NULL;
        node->right = NULL;
        return node;
    }
    NSString *leftValue = [data objectAtIndex:2 * index + 1];
    NSString *rightValue = [data objectAtIndex:2 * index + 2];
    if ([leftValue isEqualToString:@"null"] || [rightValue isEqualToString:@"null"]) {
        NSString *value = [data objectAtIndex:index];
        TreeNode *node = (TreeNode *)malloc(sizeof(TreeNode));
        node->value = value;
        node->left = NULL;
        node->right = NULL;
        return node;
    }
    TreeNode *left = [self createWithindex:2 * index + 1 data:data];
    TreeNode *right = [self createWithindex:2 * index + 2 data:data];
    NSString *value = [data objectAtIndex:index];
    TreeNode *root = (TreeNode *)malloc(sizeof(TreeNode));
    root->left = left;
    root->right = right;
    root->value = value;
    return root;
}

- (void)printNode:(TreeNode *)node {
    if (node == NULL) {
        return ;
    }
    NSLog(@"%@", node->value);
    [self printNode:node->left];
    [self printNode:node->right];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
