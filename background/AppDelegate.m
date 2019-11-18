//
//  AppDelegate.m
//  background
//
//  Created by Noriaki Misawa on 2019/09/05.
//  Copyright © 2019 MISAWA.NET All rights reserved.
//

#import "AppDelegate.h"
#import "background-Swift.h"

@import UserNotifications;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property (nonatomic) int badgeCount;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                         UNAuthorizationOptionSound |
                                         UNAuthorizationOptionAlert )
        completionHandler:^(BOOL granted, NSError * _Nullable error) {
         if (granted) {
             // APNSはここで設定するの？
         }
        }];
    
   [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocalPushNotifications:)
        name:@"handleProcessingTask"
        object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocalPushNotifications:)
        name:@"handleAppRefreshTask"
        object:nil];

    if (@available(iOS 13.0, *)) {
        BGTaskManager *bgTask = [ BGTaskManager shared ];
        [ bgTask registerBackgroundTaks ];
    } else {
        // Fallback on earlier versions
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIApplication*    app = [UIApplication sharedApplication];
    
    self->bgTaskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{
        // Synchronize the cleanup call on the main thread in case
        // the task actually finishes at around the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->bgTaskIdentifier != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:self->bgTaskIdentifier];
                self->bgTaskIdentifier = UIBackgroundTaskInvalid;
            }
        });
        
    }];
    
    if (@available(iOS 13.0, *)) {
        BGTaskManager *bgTask = [ BGTaskManager shared ];

        // まずキャンセルを
        [ bgTask cancelAllPandingBGTask ];
        
        // スケジュール登録
        [ bgTask scheduleAppRefresh ];
    } else {
        // Fallback on earlier versions
    }

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

- (void)onLocalPushNotifications:(NSNotification *)notification {
    
    self.badgeCount++;
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title    = [NSString localizedUserNotificationStringForKey:notification.name arguments:nil];
    content.body     = [NSString localizedUserNotificationStringForKey:@"Hello_message_body"
                                                             arguments:nil];
    content.subtitle = [NSString localizedUserNotificationStringForKey:@"Hello_subtitle"
                                                             arguments:nil];
    content.sound    = [UNNotificationSound defaultSound];
    content.badge = [NSNumber numberWithInt:self.badgeCount];
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"Local PushNotification" content:content trigger:nil];
     
    // Schedule the notification.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request
             withCompletionHandler:^(NSError * _Nullable error) {
                 if (!error) {
                     NSLog(@"notifer request sucess");
                 }
             }];
    

}
 
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // アプリがフォアグランドにいた場合の通知動作を指定する。
    completionHandler(UNNotificationPresentationOptionBadge |
                      UNNotificationPresentationOptionSound |
                      UNNotificationPresentationOptionAlert);
};


@end
