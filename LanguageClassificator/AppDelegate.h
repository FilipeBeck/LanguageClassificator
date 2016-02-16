//
//  AppDelegate.h
//  LanguageClassificator
//
//  Created by Filipe Beck on 2/10/16.
//  Copyright © 2016 Beck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "floatfann.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) struct fann* ann;

@property (nonatomic) NSMutableArray<NSString*>* enData;
@property (nonatomic) NSMutableArray<NSString*>* ptData;

+ (AppDelegate*)shared;
+ (UITabBarController*)tabController;

@end

