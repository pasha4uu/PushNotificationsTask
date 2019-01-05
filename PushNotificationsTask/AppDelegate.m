//
//  AppDelegate.m
//  PushNotificationsTask
//
//  Created by PASHA on 24/12/18.
//  Copyright © 2018 Pasha. All rights reserved.
//

#import "AppDelegate.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@end
//NSString *const kGCMMessageIDKey = @"gcm.message_id";
NSString *const kGCMMessageIDKey = @"357011116587";
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Use Firebase library to configure APIs
  if ([FIRApp defaultApp] == nil) {
    [FIRApp configure];
  }
  [FIRMessaging messaging].delegate = self;
  [self registerForRemoteNotifications];
  return YES;
}
//// adding for pushnotifications
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
  NSString * tokenString = [deviceToken description];
  tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSLog(@"Push Notification tokenstring is %@",tokenString);
  [[NSUserDefaults standardUserDefaults]setObject:tokenString forKey:@"DeviceTokenFinal"];
  [[NSUserDefaults standardUserDefaults]synchronize];
  [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)registerForRemoteNotifications {
  if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
      if(!error){
        dispatch_async(dispatch_get_main_queue(), ^{
          [[UIApplication sharedApplication] registerForRemoteNotifications];
        });
      }
      else
      {
        NSLog(@"error message: %@",error.localizedDescription);
      }
    }];
  }
  else {
    // Code for old versions
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
}

//Called when a notification is delivered to a foreground app.

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
  NSLog(@"Foreground User Info : %@",notification.request.content.userInfo);
  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

////Called when a notification is delivered to a background app.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  // Print full message.
  NSLog(@"background user info is : %@", userInfo);
  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
  completionHandler(UIBackgroundFetchResultNewData);
  [self registerForRemoteNotifications];
}
// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  // Print full message.
  NSLog(@"after display tapped by user  :%@", userInfo);
  completionHandler();
}
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
  NSLog(@"FCM registration token: %@", fcmToken);
  // Notify about received token.
  NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
  [[NSNotificationCenter defaultCenter] postNotificationName:
   @"FCMToken" object:nil userInfo:dataDict];
  //[AppManager sharedManager].appToken = fcmToken;
}
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  NSLog(@"application error is :%@",error);
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

//======== FOR CUSTOM NOTIFICATIONS OR CONNECT TO BACKEND NOTIFICATIONS ===============

//-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//{
//  NSString * tokenString = [deviceToken description];
//  tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//  tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
//  NSLog(@"Push Notification tokenstring is %@",tokenString);
//  [[NSUserDefaults standardUserDefaults]setObject:tokenString forKey:@"DeviceTokenFinal"];
//  [[NSUserDefaults standardUserDefaults]synchronize];
//  [FIRMessaging messaging].APNSToken = deviceToken;
//}
//
//- (void)registerForRemoteNotifications {
//  if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    center.delegate = self;
//    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
//      if(!error){
//        dispatch_async(dispatch_get_main_queue(), ^{
//          [[UIApplication sharedApplication] registerForRemoteNotifications];
//        });
//      }
//    }];
//  }
//  else {
//    // Code for old versions
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                    UIUserNotificationTypeBadge |UIUserNotificationTypeSound);
//
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//  }
//}
//
////Called when a notification is delivered to a foreground app.
//
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
//  NSLog(@"Foreground User Info : %@",notification.request.content.userInfo);
//  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
//}
//
//////Called when a notification is delivered to a background app.
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//  // If you are receiving a notification message while your app is in the background,
//  // this callback will not be fired till the user taps on the notification launching the application.
//  // TODO: Handle data of notification
//  // With swizzling disabled you must let Messaging know about the message, for Analytics
//  [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
//  // Print message ID.
//  if (userInfo[kGCMMessageIDKey]) {
//    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
//  }
//  // Print full message.
//  NSLog(@"background user info is : %@", userInfo);
//  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
//  // completionHandler(UIBackgroundFetchResultNewData);
//  [self registerForRemoteNotifications];
//}
//
//// Handle notification messages after display notification is tapped by the user.
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center
//didReceiveNotificationResponse:(UNNotificationResponse *)response
//         withCompletionHandler:(void(^)(void))completionHandler {
//  NSDictionary *userInfo = response.notification.request.content.userInfo;
//  [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
//  if (userInfo[kGCMMessageIDKey]) {
//    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
//  }
//  // Print full message.
//  NSLog(@"after display tapped by user  :%@", userInfo);
//
////  NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
////  if([[user objectForKey:@"isLogin"] isEqualToString:@"yes"]) {
////    [AppManager sharedManager].vendorId = [user objectForKey:@"vendorId"];
////    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
////    BusiFeedbackView * VHV = [mainStoryboard instantiateViewControllerWithIdentifier:@"BusiFeedbackView"];
////    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:VHV];
////    self.window.rootViewController = navController;
////  }
//  completionHandler();
//}
//- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
//  NSLog(@"FCM registration token: %@", fcmToken);
//  // Notify about received token.
//  NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
//  [[NSNotificationCenter defaultCenter] postNotificationName:
//   @"FCMToken" object:nil userInfo:dataDict];
//  [AppManager sharedManager].appToken = fcmToken;
//}
//
//- (void)application:(UIApplication *)application
//didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//{
//  NSLog(@"application error is :%@",error);
//}

@end
