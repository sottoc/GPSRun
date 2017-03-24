
#import "AppDelegate.h"
#import "GlobalState.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if(![Settings boolForKey:@"firstload"]) {
        [Settings setBool:TRUE forKey:@"firstload"];
        
        [Settings setBool:FALSE forKey:@"adsRemoved"];
        
        /* settings */
        [Settings setBool:TRUE forKey:@"checkReminders"];
        [Settings setBool:TRUE forKey:@"checkVibration"];
        [Settings setBool:TRUE forKey:@"checkSounds"];
        [Settings setBool:TRUE forKey:@"checkInstructorTime"];
        [Settings setBool:TRUE forKey:@"checkInstructorDistance"];
        [Settings setBool:TRUE forKey:@"checkInstructorInterval"];
        [Settings synchronize];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([Settings boolForKey:@"checkReminders"]) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        [components setHour:12];
        [components setMinute:0];
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"Do you time to run?"];
        [notification setFireDate:[calendar dateFromComponents:components]];
        [notification setTimeZone:[NSTimeZone defaultTimeZone]];
        [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
        notification.repeatInterval = NSWeekdayCalendarUnit;
        
    }
    
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
