
#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self restoreSettings];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self SaveSettings];
}

- (void)restoreSettings {
    
    if ([Settings boolForKey:@"checkReminders"]) { self.checkReminders.on = TRUE; }
    else { self.checkReminders.on = FALSE; }
    if ([Settings boolForKey:@"checkVibration"]) { self.checkVibration.on = TRUE; }
    else { self.checkVibration.on = FALSE; }
    if ([Settings boolForKey:@"checkSounds"]) { self.checkSounds.on = TRUE; }
    else { self.checkSounds.on = FALSE; }
    
    if ([Settings boolForKey:@"checkInstructorTime"]) { self.checkVoiseTime.on = TRUE; }
    else { self.checkVoiseTime.on = FALSE; }
    if ([Settings boolForKey:@"checkInstructorDistance"]) { self.checkVoiseDistance.on = TRUE; }
    else { self.checkVoiseDistance.on = FALSE; }
    if ([Settings boolForKey:@"checkInstructorInterval"]) { self.checkVoiseInterval.on = TRUE; }
    else { self.checkVoiseInterval.on = FALSE; }
    
}

- (void)SaveSettings {
    
    if (self.checkReminders.on) { [Settings setBool:TRUE forKey:@"checkReminders"]; }
    else { [Settings setBool:FALSE forKey:@"checkReminders"]; }
    if (self.checkVibration.on) { [Settings setBool:TRUE forKey:@"checkVibration"]; }
    else { [Settings setBool:FALSE forKey:@"checkVibration"]; }
    if (self.checkSounds.on) { [Settings setBool:TRUE forKey:@"checkSounds"]; }
    else { [Settings setBool:FALSE forKey:@"checkSounds"]; }
    
    if (self.checkVoiseTime.on) { [Settings setBool:TRUE forKey:@"checkInstructorTime"]; }
    else { [Settings setBool:FALSE forKey:@"checkInstructorTime"]; }
    if (self.checkVoiseDistance.on) { [Settings setBool:TRUE forKey:@"checkInstructorDistance"]; }
    else { [Settings setBool:FALSE forKey:@"checkInstructorDistance"]; }
    if (self.checkVoiseInterval.on) { [Settings setBool:TRUE forKey:@"checkInstructorInterval"]; }
    else { [Settings setBool:FALSE forKey:@"checkInstructorInterval"]; }
    
    if (!self.checkVoiseTime.on & !self.checkVoiseDistance.on & !self.checkVoiseInterval.on) { [Settings setBool:FALSE forKey:@"checkSounds"]; }
    
    [Settings synchronize];
}

- (IBAction)checkVoiseChange:(id)sender {
    if (!self.checkVoiseTime.on & !self.checkVoiseDistance.on & !self.checkVoiseInterval.on) { self.checkSounds.on = FALSE; }
    else { self.checkSounds.on = TRUE;  }
}

- (IBAction)checkSoundsChange:(id)sender {
    if (self.checkSounds.on) {
        self.checkVoiseTime.on = TRUE;
        self.checkVoiseDistance.on = TRUE;
        self.checkVoiseInterval.on = TRUE;
    }
    else {
        self.checkVoiseTime.on = FALSE;
        self.checkVoiseDistance.on = FALSE;
        self.checkVoiseInterval.on = FALSE;
    }
}


@end
