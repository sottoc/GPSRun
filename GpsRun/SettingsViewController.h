
#import <UIKit/UIKit.h>
#import "GlobalState.h"

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *checkReminders;
@property (weak, nonatomic) IBOutlet UISwitch *checkVibration;
@property (weak, nonatomic) IBOutlet UISwitch *checkSounds;

@property (weak, nonatomic) IBOutlet UISwitch *checkVoiseTime;
@property (weak, nonatomic) IBOutlet UISwitch *checkVoiseDistance;
@property (weak, nonatomic) IBOutlet UISwitch *checkVoiseInterval;

- (IBAction)checkVoiseChange:(id)sender;
- (IBAction)checkSoundsChange:(id)sender;

@end
