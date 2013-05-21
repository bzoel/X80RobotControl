//
//  X80MainViewController.h
//  RobotControl
//
//  Created by Billy Zoellers on 5/16/13.
//  Copyright (c) 2013 Transylvania University. All rights reserved.
//


#import "X80FlipsideViewController.h"
#import "X80API.h"

@interface X80MainViewController : UIViewController <X80FlipsideViewControllerDelegate, UIPopoverControllerDelegate,UIAccelerometerDelegate,UIWebViewDelegate>

- (IBAction)connect:(id)sender;
- (IBAction)refresh:(id)sender;

- (IBAction)fowardButtonDown:(id)sender;
- (IBAction)reverseButtonDown:(id)sender;
- (IBAction)leftButtonDown:(id)sender;
- (IBAction)rightButtonDown:(id)sender;
- (IBAction)fowardButtonUp:(id)sender;
- (IBAction)reverseButtonUp:(id)sender;
- (IBAction)leftButtonUp:(id)sender;
- (IBAction)rightButtonUp:(id)sender;
- (IBAction)stopButton:(id)sender;
- (IBAction)accelSwitchChanged:(id)sender;

- (void)signalNewData:(id)sender;

@property (nonatomic) int prevSpeed;
@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, retain) IBOutlet UIWebView *cameraView;
@property (nonatomic, retain) IBOutlet UISwitch *accelOn;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) X80API *robotAPI;
@property (strong, nonatomic) IBOutlet UISlider *speed;
@property (strong, nonatomic) IBOutlet UILabel *sonar0;
@property (strong, nonatomic) IBOutlet UILabel *sonar1;
@property (strong, nonatomic) IBOutlet UILabel *sonar2;
@property (strong, nonatomic) IBOutlet UILabel *sonar3;
@property (strong, nonatomic) IBOutlet UILabel *sonar4;
@property (strong, nonatomic) IBOutlet UILabel *sonar5;
@property (strong, nonatomic) IBOutlet UILabel *sonar6;
@property (strong, nonatomic) IBOutlet UILabel *sonar7;
@property (strong, nonatomic) IBOutlet UILabel *sonar8;
@property (strong, nonatomic) IBOutlet UILabel *sonar9;
@property (strong, nonatomic) IBOutlet UILabel *sonar10;
@property (strong, nonatomic) IBOutlet UILabel *sonar11;

@property (strong, nonatomic) IBOutlet UILabel *ir1;
@property (strong, nonatomic) IBOutlet UILabel *ir2;
@property (strong, nonatomic) IBOutlet UILabel *ir3;
@property (strong, nonatomic) IBOutlet UILabel *ir4;
@property (strong, nonatomic) IBOutlet UILabel *ir5;
@property (strong, nonatomic) IBOutlet UILabel *ir6;
@property (strong, nonatomic) IBOutlet UILabel *ir7;

@property (strong, nonatomic) IBOutlet UILabel *tiltX;
@property (strong, nonatomic) IBOutlet UILabel *tiltY;

@property (strong, nonatomic) IBOutlet UILabel *boardVolt;
@property (strong, nonatomic) IBOutlet UILabel *motorVolt;

@property (strong, nonatomic) IBOutlet UILabel *leftAlarm;
@property (strong, nonatomic) IBOutlet UILabel *rightAlarm;
@property (strong, nonatomic) IBOutlet UILabel *leftMotion;
@property (strong, nonatomic) IBOutlet UILabel *rightMotion;

@property (strong, nonatomic) IBOutlet UILabel *leftPos;
@property (strong, nonatomic) IBOutlet UILabel *leftSpeed;
@property (strong, nonatomic) IBOutlet UILabel *leftCurrent;
@property (strong, nonatomic) IBOutlet UILabel *rightPos;
@property (strong, nonatomic) IBOutlet UILabel *rightSpeed;
@property (strong, nonatomic) IBOutlet UILabel *rightCurrent;

@end
