//
//  X80API.h
//  RobotControl
//
//  Created by Billy Zoellers on 5/16/13.
//  Copyright (c) 2013 Transylvania University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
@class X80MainViewController;

@interface X80API : NSObject <GCDAsyncUdpSocketDelegate>

// ** robot methods ** //
// initiates a connection to the  X80 at the specified ip address
- (BOOL)connectToRobotAtIP:(NSString *)ip;

// moves wheels forwards in tandem at indicated speed
- (void)moveForwardAtSpeed:(int)speed;

// rotates left on the spot at indicated speed
- (void)turnLeftAtSpeed:(int)speed;

// rotates right on the spot at indicated speed
- (void)turnRightAtSpeed:(int)speed;

// moves wheels backwards in tandem at indicated speed
- (void)moveBackAtSpeed:(int)speed;

// moves wheels forward at different speeds
- (void)moveWheelsWithLeftSpeed:(int)speed andRightSpeed:(int)speed;

// issues a "stop" command to both wheel motors
- (void)stopMoving;


// ** application properties ** //
// primary socket - port 10001
@property (nonatomic,retain) GCDAsyncUdpSocket *primarySock;
// secondary socket - port 10002
@property (nonatomic,retain) GCDAsyncUdpSocket *secondarySock;
// reference back to the view controller (for updating)
@property (nonatomic,retain) X80MainViewController *theView;

// ** robot properties ** //
// SONAR
@property (nonatomic) double sonar0;
@property (nonatomic) double sonar1;
@property (nonatomic) double sonar2;
@property (nonatomic) double sonar3;
@property (nonatomic) double sonar4;
@property (nonatomic) double sonar5;
@property (nonatomic) double sonar6;
@property (nonatomic) double sonar7;
@property (nonatomic) double sonar8;
@property (nonatomic) double sonar9;
@property (nonatomic) double sonar10;
@property (nonatomic) double sonar11;

// IR
@property (nonatomic) double ir1;
@property (nonatomic) double ir2;
@property (nonatomic) double ir3;
@property (nonatomic) double ir4;
@property (nonatomic) double ir5;
@property (nonatomic) double ir6;
@property (nonatomic) double ir7;

// Human Detection
@property (nonatomic) int leftHumanAlarm;
@property (nonatomic) int leftHumanMotion;
@property (nonatomic) int rightHumanAlarm;
@property (nonatomic) int rightHumanMotion;

// Tilt
@property (nonatomic) int tiltX;
@property (nonatomic) int tiltY;

// Encoders
@property (nonatomic) int leftEncPos;
@property (nonatomic) int rightEncPos;
@property (nonatomic) int leftEncSpeed;
@property (nonatomic) int rightEncSpeed;
@property (nonatomic) double leftEncCurrent;
@property (nonatomic) double rightEncCurrent;


@end
