//
//  X80MainViewController.m
//  RobotControl
//
//  Created by Billy Zoellers on 5/16/13.
//  Copyright (c) 2013 Transylvania University. All rights reserved.
//

#import "X80MainViewController.h"

@interface X80MainViewController ()

@end

@implementation X80MainViewController
@synthesize robotAPI;
@synthesize sonar0,sonar1,sonar2,sonar3,sonar4,sonar5,sonar6,sonar7,sonar8,sonar9,sonar10,sonar11;
@synthesize ir1,ir2,ir3,ir4,ir5,ir6,ir7;
@synthesize leftAlarm,leftCurrent,leftMotion,leftPos,leftSpeed;
@synthesize rightAlarm,rightCurrent,rightMotion,rightPos,rightSpeed;
@synthesize tiltX,tiltY,boardVolt,motorVolt;
@synthesize speed,accelerometer,accelOn;
@synthesize cameraView;
@synthesize prevSpeed;

- (int)maxSpeed {
    
    return 2500;
}

// robot control
- (IBAction)connect:(id)sender {
    
    [robotAPI connectToRobotAtIP:@"10.130.100.36"];
    [robotAPI setTheView:self];
    
}

- (IBAction)refresh:(id)sender {
    
    NSString *urlAddress = [NSString stringWithFormat:@"http://10.130.100.37:8080/video2.mjpg"];
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [cameraView loadRequest:requestObj];
    
    [self signalNewData:nil];
    
}

- (IBAction)fowardButtonDown:(id)sender {

    [robotAPI moveForwardAtSpeed:([self maxSpeed]*[speed value])];
    
}

- (IBAction)reverseButtonDown:(id)sender {

    [robotAPI moveBackAtSpeed:([self maxSpeed]*[speed value])];
    
}

- (IBAction)leftButtonDown:(id)sender {
    
    [robotAPI turnLeftAtSpeed:([self maxSpeed]*[speed value])];
    
}

- (IBAction)rightButtonDown:(id)sender {
    
    [robotAPI turnRightAtSpeed:([self maxSpeed]*[speed value])];
    
}

- (IBAction)fowardButtonUp:(id)sender {
    
    [robotAPI stopMoving];
    
}

- (IBAction)reverseButtonUp:(id)sender {
    
    [robotAPI stopMoving];
    
}

- (IBAction)leftButtonUp:(id)sender {
    
    [robotAPI stopMoving];
    
}

- (IBAction)rightButtonUp:(id)sender {
    
    [robotAPI stopMoving];
    
}

- (IBAction)stopButton:(id)sender {
    
    [robotAPI stopMoving];
    
}

- (void)signalNewData:(id)sender {
    
    [sonar0 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar0]]];
    [sonar1 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar1]]];
    [sonar2 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar2]]];
    [sonar3 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar3]]];
    [sonar4 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar4]]];
    [sonar5 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar5]]];
    [sonar6 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar6]]];
    [sonar7 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar7]]];
    [sonar8 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar8]]];
    [sonar9 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar9]]];
    [sonar10 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar10]]];
    [sonar11 setText:[NSString stringWithFormat:@"%.02f",[robotAPI sonar11]]];
    
    [ir1 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir1]]];
    [ir2 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir2]]];
    [ir3 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir3]]];
    [ir4 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir4]]];
    [ir5 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir5]]];
    [ir6 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir6]]];
    [ir7 setText:[NSString stringWithFormat:@"%.02f",[robotAPI ir7]]];
    
    [tiltX setText:[NSString stringWithFormat:@"%d",[robotAPI tiltX]]];
    [tiltY setText:[NSString stringWithFormat:@"%d",[robotAPI tiltY]]];
    
    [leftAlarm setText:[NSString stringWithFormat:@"%d",[robotAPI leftHumanAlarm]]];
    [leftMotion setText:[NSString stringWithFormat:@"%d",[robotAPI leftHumanMotion]]];
    [rightAlarm setText:[NSString stringWithFormat:@"%d",[robotAPI rightHumanAlarm]]];
    [rightMotion setText:[NSString stringWithFormat:@"%d",[robotAPI rightHumanMotion]]];
    
    [leftPos setText:[NSString stringWithFormat:@"%d",[robotAPI leftEncPos]]];
    [leftSpeed setText:[NSString stringWithFormat:@"%d",[robotAPI leftEncSpeed]]];
    [rightPos setText:[NSString stringWithFormat:@"%d",[robotAPI rightEncPos]]];
    [rightSpeed setText:[NSString stringWithFormat:@"%d",[robotAPI rightEncSpeed]]];
    
}

// end robot control

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // init the API
    robotAPI = [[X80API alloc] init];
    
    // setup the accel switch
    [accelOn setOn:NO];
    
    // init the accelerometor
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = 120;
    self.accelerometer.delegate = self;
    
    // load the camera
    cameraView.delegate = self;
    NSString *urlAddress = [NSString stringWithFormat:@"http://10.130.100.37:8080/video2.mjpg"];
    [cameraView setScalesPageToFit:YES];
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [cameraView loadRequest:requestObj];

}

- (IBAction)accelSwitchChanged:(id)sender {
    
    if ([accelOn isOn]) {
        self.accelerometer.updateInterval = 1;
    } else {
        self.accelerometer.updateInterval = 120;
    }
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    if (![accelOn isOn]) {
        NSLog(@"accel OFF");
        return;
    }
    
    int newSpeed = (int)(2000*ABS(acceleration.y));
    
    NSLog(@"X: %f",acceleration.x);
    NSLog(@"Y: %f",acceleration.y);
    
    if (acceleration.y > 0.30) {
        // move forward
        if (prevSpeed != newSpeed) {
            [robotAPI moveForwardAtSpeed:newSpeed];
            prevSpeed = newSpeed;
        }
    } else if (acceleration.y < -0.30) {
        if (prevSpeed != newSpeed) {
            [robotAPI moveBackAtSpeed:newSpeed];
            prevSpeed = newSpeed;
        }
    } else {
        [robotAPI stopMoving];
    }

    if (acceleration.x > 0.30) {
        // move right
        [robotAPI turnRightAtSpeed:2000*ABS(acceleration.x)];
        
    } else if (acceleration.x < -0.30) {
        // move left
        [robotAPI turnLeftAtSpeed:2000*ABS(acceleration.x)];
    } else {
        [robotAPI stopMoving];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(X80FlipsideViewController *)controller
{
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
    self.flipsidePopoverController = nil;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.flipsidePopoverController = popoverController;
        popoverController.delegate = self;
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

# pragma web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"page is loading");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finished loading");
    
    // zoom correctly
    
    
}

@end
