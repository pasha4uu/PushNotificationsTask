//
//  AppDelegate.h
//  PushNotificationsTask
//
//  Created by PASHA on 24/12/18.
//  Copyright © 2018 Pasha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@import Firebase;
@import FirebaseMessaging;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strDeviceToken;

@end

