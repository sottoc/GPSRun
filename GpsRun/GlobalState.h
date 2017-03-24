
#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define Settings [NSUserDefaults standardUserDefaults]
NSString *databasePath;
sqlite3 *workoutDB;
long run_time;
float run_distance;
long run_calories;
float avg_speed;
UIColor *bcolor;
NSMutableArray *run_locations;
NSMutableArray *photo_datas;
int current_run;
static long const speak_interval = 300;
static float const speak_speed = 0.28;
UIImage* lastScreenshot;

#define orange_color [UIColor colorWithRed:(255/255.0) green:(108/255.0) blue:(0/255.0) alpha:1]

// Used from Itunes Connect app dashboard
static NSString * const InApp_id = @"com.app.template.pro";

// Admob id
static NSString * const Admob_id = @"ca-app-pub-111111111111111111/22222222222";

