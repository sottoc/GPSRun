
#import <UIKit/UIKit.h>
#import "SimpleBarChart.h"
#import "GlobalState.h"

@interface ActivityViewController : UIViewController<SimpleBarChartDataSource, SimpleBarChartDelegate> {
    NSArray *_values;
    SimpleBarChart *_chart;
    NSArray *_barColors;
    NSInteger _currentBarColor;
}

@property (weak, nonatomic) IBOutlet UIView *chartViewBlock;
@property (weak, nonatomic) IBOutlet UILabel *labelWorkouts;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelCalories;

@end
