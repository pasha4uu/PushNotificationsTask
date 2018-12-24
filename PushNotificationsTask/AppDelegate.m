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
  [FIRApp configure];
  [FIRMessaging messaging].delegate = self;
    [self registerForRemoteNotifications];
  return YES;
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
  NSString * tokenString = [deviceToken description];
  tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSLog(@"Push Notification tokenstring is %@",tokenString);
  [[NSUserDefaults standardUserDefaults]setObject:tokenString forKey:@"DeviceTokenFinal"];
    [[NSUserDefaults standardUserDefaults]synchronize];
  [FIRMessaging messaging].APNSToken = deviceToken;
  
//
//  if ([UNUserNotificationCenter class] != nil) {
//    // iOS 10 or later
//    // For iOS 10 display notification (sent via APNS)
//    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
//    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
//    UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
//    [[UNUserNotificationCenter currentNotificationCenter]
//     requestAuthorizationWithOptions:authOptions
//     completionHandler:^(BOOL granted, NSError * _Nullable error) {
//       // ...
//     }];
//  } else {
//    // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
//    UIUserNotificationType allNotificationTypes =
//    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//    UIUserNotificationSettings *settings =
//    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//    [application registerUserNotificationSettings:settings];
//  }
//    [application registerForRemoteNotifications];
}
- (void)registerForRemoteNotifications {
  if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
      if(!error){
        [[UIApplication sharedApplication] registerForRemoteNotifications];
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
  NSLog(@"User Info : %@",notification.request.content.userInfo);
  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
  [self handleRemoteNotification:[UIApplication sharedApplication] userInfo:notification.request.content.userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired till the user taps on the notification launching the application.
  // TODO: Handle data of notification
  
  // With swizzling disabled you must let Messaging know about the message, for Analytics
  // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
  
  // Print message ID.
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  
  // Print full message.
  NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired till the user taps on the notification launching the application.
  // TODO: Handle data of notification
  
  // With swizzling disabled you must let Messaging know about the message, for Analytics
  // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
  
  // Print message ID.
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  
  // Print full message.
  NSLog(@"%@", userInfo);
  
  completionHandler(UIBackgroundFetchResultNewData);
}

// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center
//       willPresentNotification:(UNNotification *)notification
//         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
//  NSDictionary *userInfo = notification.request.content.userInfo;
//
//  // With swizzling disabled you must let Messaging know about the message, for Analytics
//  // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
//
//  // Print message ID.
//  if (userInfo[kGCMMessageIDKey]) {
//    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
//  }
//
//  // Print full message.
//  NSLog(@"%@", userInfo);
//
//  // Change this to your preferred presentation option
//  completionHandler(UNNotificationPresentationOptionNone);
//}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  
  // Print full message.
  NSLog(@"%@", userInfo);
  
  completionHandler();
}
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
  NSLog(@"FCM registration token: %@", fcmToken);
  // Notify about received token.
  NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
  [[NSNotificationCenter defaultCenter] postNotificationName:
   @"FCMToken" object:nil userInfo:dataDict];
  // TODO: If necessary send token to application server.
  // Note: This callback is fired at each app startup and whenever a new token is generated.
  //
  //  [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
  //                                                      NSError * _Nullable error) {
  //    if (error != nil) {
  //      NSLog(@"Error fetching remote instance ID: %@", error);
  //    } else {
  //      NSLog(@"Remote instance ID token: %@", result.token);
  //      NSString* message =
  //      [NSString stringWithFormat:@"Remote InstanceID token: %@", result.token];
  //      self.instanceIDTokenMessage.text = message;
  //    }
  //  }];
}

-(void) handleRemoteNotification:(UIApplication *) application   userInfo:(NSDictionary *) remoteNotif {
  
  NSLog(@"handleRemoteNotification");
  
  NSLog(@"Handle Remote Notification Dictionary: %@", remoteNotif);
  
  // Handle Click of the Push Notification From Here…
  // You can write a code to redirect user to specific screen of the app here….
  
}


//Called to let your app know which action was selected by the user for a given notification.

//-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
//
//
//  NSLog(@"User Info : %@",response.notification.request.content.userInfo);
//
//  completionHandler();
//
//  [self handleRemoteNotification:[UIApplication sharedApplication] userInfo:response.notification.request.content.userInfo];
//
////  [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
////                                                      NSError * _Nullable error) {
////    if (error != nil) {
////      NSLog(@"Error fetching remote instance ID: %@", error);
////    } else {
////      NSLog(@"Remote instance ID token: %@", result.token);
////      NSString* message =
////      [NSString stringWithFormat:@"Remote InstanceID token: %@", result.token];
////      self.instanceIDTokenMessage.text = message;
////    }
////  }];
//
//}


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

//
//UIUserNotificationType allNotificationTypes =
//(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//UIUserNotificationSettings *settings =
//[UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//[[UIApplication sharedApplication] registerForRemoteNotifications];
//
//[FIRApp configure];
//
//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
//
//return YES;
//}
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//  
//  NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
//  [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
//  
//  NSLog(@"userInfo=>%@", userInfo);
//}
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//  
//  [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];
//  NSLog(@"deviceToken1 = %@",deviceToken);
//  
//}
//- (void)tokenRefreshNotification:(NSNotification *)notification {
//  NSLog(@"instanceId_notification=>%@",[notification object]);
//  InstanceID = [NSString stringWithFormat:@"%@",[notification object]];
//  
//  [self connectToFcm];
//}
//
//- (void)connectToFcm {
//  
//  [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
//    if (error != nil) {
//      NSLog(@"Unable to connect to FCM. %@", error);
//    } else {
//      
//      // you can send your token here with api or etc....
//      
//    }
//  }
@end
