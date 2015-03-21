//
//  AppDelegate.m
//  PushDemo
//
//  Created by gaoyanlong on 15-1-23.
//  Copyright (c) 2015年 shaowenle. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

//1.生成appID
//2.申请development证书
//3.钥匙串证书上传
//4.下载Provisioning Profiles文件
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //本地通知
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //设置时间表
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    //设置时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //设置重复间隔
    localNotification.repeatInterval = NSCalendarUnitWeekday;
    //设置推送声音(系统默认声音)
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //设置推送内容
    localNotification.alertBody = @"大力出奇迹";
    //设置推送角标
    localNotification.applicationIconBadgeNumber = 99;
    //设置推送用户消息
    localNotification.userInfo = @{                                                                                                                  };
    //*加入系统推送中
    [application scheduleLocalNotification:localNotification];
    
    //ios8之前版本的推送  注册
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [application registerForRemoteNotificationTypes:UIUserNotificationTypeBadge  |
         UIUserNotificationTypeSound  |
         UIUserNotificationTypeAlert];
    } else {
        [self registNotification];
    }
    
    
    return YES;
}
//获取Token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"token = %@", [deviceToken description]);
}
//获取Token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
}

- (void)registNotification
{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge  |
        UIUserNotificationTypeSound  |
        UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
