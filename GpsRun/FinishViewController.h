
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GlobalState.h"
@import GoogleMobileAds;

@interface FinishViewController : UIViewController<GADInterstitialDelegate> {
    AVSpeechUtterance *utterance;
    AVSpeechSynthesizer *synth;
}

@property(nonatomic, strong) GADInterstitial *interstitial;

- (IBAction)buttonShareAction:(id)sender;
- (IBAction)buttonSaveAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *labelSaved;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;


@end
