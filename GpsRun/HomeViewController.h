
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "GlobalState.h"

@interface HomeViewController : UIViewController
- (IBAction)buttonStartAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleTotalDistance;
@property (weak, nonatomic) IBOutlet UILabel *titleLastRun;

@end
