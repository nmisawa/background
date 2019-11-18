//
//  AppDelegate.h
//  background
//
//  Created by Noriaki Misawa on 2019/09/05.
//  Copyright © 2019 MISAWA.NET All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier bgTaskIdentifier;
}
@property (strong, nonatomic) UIWindow *window;


@end

