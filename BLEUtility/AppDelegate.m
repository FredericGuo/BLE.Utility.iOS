//
//  AppDelegate.m
//  BLEUtility
//
//  Created by cerise guo on 6/13/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import "AppDelegate.h"
#import "BLEInfo.h"
#import "BLEViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    //NSMutableArray * _BLEDevices;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /*_BLEDevices = [NSMutableArray arrayWithCapacity:20];
    
    BLEInfo * device = [[BLEInfo alloc] init];
    device.name = @"MI";
    device.advertisementUUID = @"1234-567-890-1111";
    device.RSSI = [[NSNumber alloc]initWithInt:-89];
    device.identifier = @"identifier";
    
    [_BLEDevices addObject:device];
    
    device = [[BLEInfo alloc] init];
    device.name = @"MDT";
    device.advertisementUUID = @"0000-222-444-6666";
    device.RSSI = [[NSNumber alloc]initWithInt:-104];
    device.identifier = @"identifier";
    
    [_BLEDevices addObject:device];
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = [tabBarController viewControllers][0];
    BLEViewController *bleViewController = [navigationController viewControllers][0];
    bleViewController.bleInfo = _BLEDevices;
    */
    return YES;
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
