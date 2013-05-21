//
//  X80API.m
//  RobotControl
//
//  Created by Billy Zoellers on 5/16/13.
//  Copyright (c) 2013 Transylvania University. All rights reserved.
//

#import "X80API.h"
#import "X80MainViewController.h"

@implementation X80API
@synthesize primarySock, secondarySock;
@synthesize theView;
@synthesize sonar1,sonar2,sonar3,sonar4,sonar5,sonar6,sonar7,sonar8,sonar9,sonar10,sonar11,sonar0;
@synthesize ir1,ir2,ir3,ir4,ir5,ir6,ir7;
@synthesize leftEncCurrent,leftEncPos,leftEncSpeed,rightEncSpeed,rightEncCurrent,rightEncPos;
@synthesize tiltY,tiltX;
@synthesize leftHumanAlarm,leftHumanMotion,rightHumanAlarm,rightHumanMotion;

- (BOOL)connectToRobotAtIP:(NSString *)ip
{
    
    // create the nescessary sockets
    primarySock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    secondarySock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // bind to the appropriate ports
    [primarySock bindToPort:10001 error:nil];
    [secondarySock bindToPort:10002 error:nil];
    
    // open sockets to continuously recieve packets
    [primarySock beginReceiving:nil];
    [secondarySock beginReceiving:nil];
    
    // send init packets
    Byte msg[9];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1; // RID
    msg[3] = 0;
    msg[4] = 125;
    msg[5] = 0; // Length
    
    msg[6] = [self calculateCRCwithBuffer:msg andSize:9]; //Checksum
    
	msg[7] = 94;
    msg[8] = 13;
    
    NSData *theData = [NSData dataWithBytes:msg length:9];
    
    NSLog(@"sending sensor data requests..");
    [primarySock sendData:theData toHost:ip port:10001 withTimeout:-1 tag:0];
    [secondarySock sendData:theData toHost:ip port:10002 withTimeout:-1 tag:0];
    
    return YES;
}

- (void)setMotorToVelocityControlMode:(int)motor {
    
    int msgsize = 12;
    
    Byte msg[msgsize];
    
    // send message to set motor control mode to velocity
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1;
	msg[3] = 0;
	msg[4] = 7; // WIROBOT_CMD_SET_SYS_PARAMS
	msg[5] = 3;
	msg[6] = 0x0E;	// WIROBOT_CMD_SET_MOTOR_CONTROL_MODE
	msg[7] = (Byte)motor; // left wheel
	msg[8] = 2; // velocity control
    
    msg[9] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[10] = 94;
    msg[11] = 13;
    
    // send the command
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    [self sendCommand:theData];
}

- (void)setMotor:(int)motor toPolarity:(bool)positive {
    
    int msgsize = 12;
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1;	// WIROBOT_RID_SENSOR_MOTOR
	msg[3] = 0;							// Reserved
	msg[4] = 7;	// WIROBOT_CMD_SET_SYS_PARAMS
	msg[5] = 3;							// Length
	msg[6] = 0x06;	// WIROBOT_CMD_SET_MOTOR_POLARITY
	msg[7] = (Byte) motor;
    if (positive) {
        msg[8] = (Byte) 1;
    } else {
         msg[8] = (Byte) 0xFF;
    }
    
    msg[9] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
    msg[10] = 94;
    msg[11] = 13;
    
    // send the command
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    [self sendCommand:theData];

    
}

- (void)suspendMotor:(bool)suspend {
    
    int msgsize = 13;
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
	msg[2] = 1;
	msg[3] = 0;
	msg[4] = 30; // WIROBOT_CMD_SUSPEND_RESUME
	msg[5] = 4;
	// Data
	if (suspend)
		msg[6] = 0;		// Suspend or Disable
	else
		msg[6] = 1;		// Resume or Enable
	msg[7] = 0;			// Channel
	// Data
	if (suspend)
		msg[8] = 0;		// Suspend or Disable
	else
		msg[8] = 1;		// Resume or Enable
	msg[9] = 1;			// Channel
    
    msg[10] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[11] = 94;
    msg[12] = 13;
    
    // send the command
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    [self sendCommand:theData];
    
    
}

- (void)moveForwardAtSpeed:(int)speed {
    
    [self setMotor:0 toPolarity:YES];
    [self setMotor:1 toPolarity:YES];
    
    [self setMotorToVelocityControlMode:0]; // set left wheel
    [self setMotorToVelocityControlMode:1]; // set right wheel
    
    int msgsize = 21;
    
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1; // RID
    msg[3] = 0;
    msg[4] = 27; // move all DC motors w/ velocity control
    msg[5] = 12; // Length
    
    // ** DATA ** //
    
    int cmd1 = -speed;
    int cmd2 = speed;
    int cmd3 = 65535;
    int cmd4 = 65535;
    int cmd5 = 65535;
    int cmd6 = 65535;
    
    msg[6] = (Byte)(cmd1 & 0xff);               //channel 1
    msg[7] = (Byte)((cmd1 >> 8) & 0xff);
    msg[8] = (Byte)(cmd2 & 0xff);               //channel 2
    msg[9] = (Byte)((cmd2 >> 8) & 0xff);
    msg[10] = (Byte)(cmd3 & 0xff);               //channel 3
    msg[11] = (Byte)((cmd3 >> 8) & 0xff);
    msg[12] = (Byte)(cmd4 & 0xff);               //channel 4
    msg[13] = (Byte)((cmd4 >> 8) & 0xff);
    msg[14] = (Byte)(cmd5 & 0xff);               //channel 5
    msg[15] = (Byte)((cmd5 >> 8) & 0xff);
    msg[16] = (Byte)(cmd6 & 0xff);               //channel 6
    msg[17] = (Byte)((cmd6 >> 8) & 0xff);
	
	msg[18] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[19] = 94;
    msg[20] = 13;
    
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    
    [self sendCommand:theData];
    
}

- (void)turnLeftAtSpeed:(int)speed {
    
    [self suspendMotor:NO];
    
    [self setMotor:0 toPolarity:YES];
    [self setMotor:1 toPolarity:YES];
    
    [self setMotorToVelocityControlMode:0]; // set left wheel
    [self setMotorToVelocityControlMode:1]; // set right wheel
    
    int msgsize = 21;
    
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1; // RID
    msg[3] = 0;
    msg[4] = 27; // move all DC motors w/ velocity control
    msg[5] = 12; // Length
    
    // ** DATA ** //
    
    int cmd1 = speed;
    int cmd2 = speed;
    int cmd3 = 65535;
    int cmd4 = 65535;
    int cmd5 = 65535;
    int cmd6 = 65535;
    
    msg[6] = (Byte)(cmd1 & 0xff);               //channel 1
    msg[7] = (Byte)((cmd1 >> 8) & 0xff);
    msg[8] = (Byte)(cmd2 & 0xff);               //channel 2
    msg[9] = (Byte)((cmd2 >> 8) & 0xff);
    msg[10] = (Byte)(cmd3 & 0xff);               //channel 3
    msg[11] = (Byte)((cmd3 >> 8) & 0xff);
    msg[12] = (Byte)(cmd4 & 0xff);               //channel 4
    msg[13] = (Byte)((cmd4 >> 8) & 0xff);
    msg[14] = (Byte)(cmd5 & 0xff);               //channel 5
    msg[15] = (Byte)((cmd5 >> 8) & 0xff);
    msg[16] = (Byte)(cmd6 & 0xff);               //channel 6
    msg[17] = (Byte)((cmd6 >> 8) & 0xff);
	
	msg[18] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[19] = 94;
    msg[20] = 13;
    
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    
    [self sendCommand:theData];

    
}

- (void)turnRightAtSpeed:(int)speed {
    
    [self setMotor:0 toPolarity:YES];
    [self setMotor:1 toPolarity:YES];
    
    [self setMotorToVelocityControlMode:0]; // set left wheel
    [self setMotorToVelocityControlMode:1]; // set right wheel
    
    int msgsize = 21;
    
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1; // RID
    msg[3] = 0;
    msg[4] = 27; // move all DC motors w/ velocity control
    msg[5] = 12; // Length
    
    // ** DATA ** //
    
    int cmd1 = -speed;
    int cmd2 = -speed;
    int cmd3 = 65535;
    int cmd4 = 65535;
    int cmd5 = 65535;
    int cmd6 = 65535;
    
    msg[6] = (Byte)(cmd1 & 0xff);               //channel 1
    msg[7] = (Byte)((cmd1 >> 8) & 0xff);
    msg[8] = (Byte)(cmd2 & 0xff);               //channel 2
    msg[9] = (Byte)((cmd2 >> 8) & 0xff);
    msg[10] = (Byte)(cmd3 & 0xff);               //channel 3
    msg[11] = (Byte)((cmd3 >> 8) & 0xff);
    msg[12] = (Byte)(cmd4 & 0xff);               //channel 4
    msg[13] = (Byte)((cmd4 >> 8) & 0xff);
    msg[14] = (Byte)(cmd5 & 0xff);               //channel 5
    msg[15] = (Byte)((cmd5 >> 8) & 0xff);
    msg[16] = (Byte)(cmd6 & 0xff);               //channel 6
    msg[17] = (Byte)((cmd6 >> 8) & 0xff);
	
	msg[18] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[19] = 94;
    msg[20] = 13;
    
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    
    [self sendCommand:theData];
    
    [self suspendMotor:NO];

    
}

- (void)moveBackAtSpeed:(int)speed {
    
    [self setMotor:0 toPolarity:YES];
    [self setMotor:1 toPolarity:YES];
    
    [self setMotorToVelocityControlMode:0]; // set left wheel
    [self setMotorToVelocityControlMode:1]; // set right wheel
    
    int msgsize = 21;
    
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1; // RID
    msg[3] = 0;
    msg[4] = 27; // move all DC motors w/ velocity control
    msg[5] = 12; // Length
    
    // ** DATA ** //
    
    int cmd1 = speed;
    int cmd2 = -speed;
    int cmd3 = 65535;
    int cmd4 = 65535;
    int cmd5 = 65535;
    int cmd6 = 65535;
    
    msg[6] = (Byte)(cmd1 & 0xff);               //channel 1
    msg[7] = (Byte)((cmd1 >> 8) & 0xff);
    msg[8] = (Byte)(cmd2 & 0xff);               //channel 2
    msg[9] = (Byte)((cmd2 >> 8) & 0xff);
    msg[10] = (Byte)(cmd3 & 0xff);               //channel 3
    msg[11] = (Byte)((cmd3 >> 8) & 0xff);
    msg[12] = (Byte)(cmd4 & 0xff);               //channel 4
    msg[13] = (Byte)((cmd4 >> 8) & 0xff);
    msg[14] = (Byte)(cmd5 & 0xff);               //channel 5
    msg[15] = (Byte)((cmd5 >> 8) & 0xff);
    msg[16] = (Byte)(cmd6 & 0xff);               //channel 6
    msg[17] = (Byte)((cmd6 >> 8) & 0xff);
	
	msg[18] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[19] = 94;
    msg[20] = 13;
    
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    
    [self sendCommand:theData];

    
}

// has not been tested
- (void)moveWheelsWithLeftSpeed:(int)leftSpeed andRightSpeed:(int)rightSpeed {
    [self setMotor:0 toPolarity:YES];
    [self setMotor:1 toPolarity:YES];
    
    [self setMotorToVelocityControlMode:0]; // set left wheel
    [self setMotorToVelocityControlMode:1]; // set right wheel
    
    int msgsize = 21;
    Byte msg[msgsize];
    
    msg[0] = 94;
    msg[1] = 2;
    msg[2] = 1; // RID
    msg[3] = 0;
    msg[4] = 27; // move all DC motors w/ velocity control
    msg[5] = 12; // Length
    
    // ** DATA ** //
    
    int cmd1 = -leftSpeed;
    int cmd2 = rightSpeed;
    int cmd3 = 65535;
    int cmd4 = 65535;
    int cmd5 = 65535;
    int cmd6 = 65535;
    
    msg[6] = (Byte)(cmd1 & 0xff);               //channel 1
    msg[7] = (Byte)((cmd1 >> 8) & 0xff);
    msg[8] = (Byte)(cmd2 & 0xff);               //channel 2
    msg[9] = (Byte)((cmd2 >> 8) & 0xff);
    msg[10] = (Byte)(cmd3 & 0xff);               //channel 3
    msg[11] = (Byte)((cmd3 >> 8) & 0xff);
    msg[12] = (Byte)(cmd4 & 0xff);               //channel 4
    msg[13] = (Byte)((cmd4 >> 8) & 0xff);
    msg[14] = (Byte)(cmd5 & 0xff);               //channel 5
    msg[15] = (Byte)((cmd5 >> 8) & 0xff);
    msg[16] = (Byte)(cmd6 & 0xff);               //channel 6
    msg[17] = (Byte)((cmd6 >> 8) & 0xff);
	
	msg[18] = [self calculateCRCwithBuffer:msg andSize:msgsize]; //Checksum
    
	msg[19] = 94;
    msg[20] = 13;
    
    NSData *theData = [NSData dataWithBytes:msg length:msgsize];
    [self sendCommand:theData];
}

- (void)stopMoving {
    
    [self suspendMotor:YES];
    
}

- (BOOL)sendCommand:(NSData *)command {
    
    [primarySock sendData:command toHost:@"10.130.100.36" port:10001 withTimeout:-1 tag:0];
    
    return YES;
}

# pragma delegate

// BEGIN: For recieving data - invoked each time a packet is recieved
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    Byte msg[400];
    
    // convert from NSData to byte
    [data getBytes:msg length:255];
    
    NSLog(@"DID: %i",msg[4]);
    NSLog(@"Length: %i",msg[5]);
    
    int dataID = (int)msg[4];
    int dataLength = (int)msg[5];
    Byte *dataPtr = &msg[6];
    
    // grab the databuffer from the message
    NSData *dataBuffer = [NSData dataWithBytes:dataPtr length:dataLength];

    
    if (sock == primarySock) {
        // This packet is coming from port 10001
        switch (dataID) {
            case 123:
                [self parseMotorControlPkt:dataBuffer withLength:dataLength];
            
                break;
            case 124:
                // custom I/O feedback
                [self parseCustomIOFeedback:dataBuffer withLength:dataLength];
                
                break;
            case 125:
                [self parseSensorDataFeedback:dataBuffer withLength:dataLength];
            
                break;
            case 127:
                [self parseAllSensorDataFeedback:dataBuffer withLength:dataLength];
            
                break;
        }
    } else {
        // This packet is coming from port 10002 - should be 6 sonar only
        switch (dataID) {
            case 123:
                
                break;
            case 124:
                
                break;
            case 125:
                [self parseSensorDataFeedbackFromSecondary:dataBuffer withLength:dataLength];
                
                break;
            case 127:
                
                break;
                
        }
    }
    
    [theView signalNewData:nil];
    return;
}

- (void)parseMotorControlPkt:(NSData *)packet withLength:(int)length {
    // convert the NSData to bytes - cannot be more than 255, but we could do length here for memory efficiency
    Byte msg[255];
    [packet getBytes:msg length:length];
    
    // REMINDER: the msg[byte] is one off here when comared to the doc. We start with 0 here, the doc starts with 1. Might be a better way to do this to prettify the code. i.e. msg[1 -1] ?
    
    [self setLeftEncPos:(msg[27] << 8 ) | (msg[26] & 0xff)];
    [self setLeftEncSpeed:(msg[29] << 8 ) | (msg[28] & 0xff)];
    
    [self setRightEncPos:(msg[31] << 8 ) | (msg[30] & 0xff)];
    [self setRightEncSpeed:(msg[33] << 8 ) | (msg[32] & 0xff)];
    
}

- (void)parseSensorDataFeedback:(NSData *)packet withLength:(int)length {
    // convert the NSData to bytes - cannot be more than 255, but we could do length here for memory efficiency    
    Byte msg[255];
    [packet getBytes:msg length:length];
    
    // REMINDER: the msg[byte] is one off here when comared to the doc. We start with 0 here, the doc starts with 1. Might be a better way to do this to prettify the code. i.e. msg[1 -1] ?
    
    // get sonar 0-5
    [self setSonar0:(double)msg[0] / 100];
    [self setSonar1:(double)msg[1] / 100];
    [self setSonar2:(double)msg[2] / 100];
    [self setSonar3:(double)msg[3] / 100];
    [self setSonar4:(double)msg[4] / 100];
    [self setSonar5:(double)msg[5] / 100];
    
    // human sensors
    [self setLeftHumanAlarm:(msg[7] << 8 ) | (msg[6] & 0xff)];
    [self setLeftHumanMotion:(msg[9] << 8 ) | (msg[8] & 0xff)];
    [self setRightHumanAlarm:(msg[11] << 8 ) | (msg[10] & 0xff)];
    [self setRightHumanMotion:(msg[13] << 8 ) | (msg[12] & 0xff)];
    
    // IR #1
    int temp = (msg[27] << 8 ) | (msg[26] & 0xff);
    NSLog(@"IR 1: %i",temp);
    
    // tilt sensors
    [self setTiltX:(msg[15] << 8 ) | (msg[14] & 0xff)];
    [self setTiltY:(msg[17] << 8 ) | (msg[16] & 0xff)];
    
}

- (void)parseSensorDataFeedbackFromSecondary:(NSData *)packet withLength:(int)length {
    // convert the NSData to bytes - cannot be more than 255, but we could do length here for memory efficiency
    Byte msg[255];
    [packet getBytes:msg length:length];
    
    // get sonary 6-11
    [self setSonar6:(double)msg[0] / 100];
    [self setSonar7:(double)msg[1] / 100];
    [self setSonar8:(double)msg[2] / 100];
    [self setSonar9:(double)msg[3] / 100];
    [self setSonar10:(double)msg[4] / 100];
    [self setSonar11:(double)msg[5] / 100];
    
}

- (void)parseAllSensorDataFeedback:(NSData *)packet withLength:(int)length {

    
}

- (void)parseCustomIOFeedback:(NSData *)packet withLength:(int)length {
    
    // convert the NSData to bytes - cannot be more than 255, but we could do length here for memory efficiency
    Byte msg[255];
    [packet getBytes:msg length:length];
    
    // REMINDER: the msg[byte] is one off here when comared to the doc. We start with 0 here, the doc starts with 1. Might be a better way to do this to prettify the code. i.e. msg[1 -1] ?
    
    // IR 2-7
    int temp;
    temp = (msg[7] << 8 ) | (msg[6] & 0xff);
    NSLog(@"IR #2: %i",temp);
    
    
    [self setIr2:(double)temp / 100];
    NSLog(@"IR #2 convert: %0.2f",[self ir2]);
    temp = (msg[9] << 8 ) | (msg[8] & 0xff);
    [self setIr3:(double)temp / 100];
    temp = (msg[11] << 8 ) | (msg[10] & 0xff);
    [self setIr4:(double)temp / 100];
    temp = (msg[13] << 8 ) | (msg[12] & 0xff);
    [self setIr5:(double)temp / 100];
    temp = (msg[15] << 8 ) | (msg[14] & 0xff);
    [self setIr6:(double)temp / 100];
    temp = (msg[17] << 8 ) | (msg[16] & 0xff);
    [self setIr7:(double)temp / 100];
    
}


// END: For recieving data

- (Byte)calculateCRCwithBuffer:(Byte *)buffer andSize:(int)size {
    
    Byte shift_reg,sr_lsb,data_bit,v;
    int i,j;
    Byte fb_bit;
    
    shift_reg = 0; // init the shift register
    
    for (i=0; i < size; i++) {
        
        v = (Byte)(buffer[i] & 0x0000FFFF);
        for (j=0; j < 8; j++) {// for each bit
            
            data_bit = v & 0x01; // isolate least sign bit
            sr_lsb = shift_reg & 0x01;
            fb_bit = (data_bit & sr_lsb) & 0x01; // calculate feedback
            shift_reg = shift_reg >> 1;
            if (fb_bit == 1) {
                shift_reg = shift_reg & 0x8C;
            }
            v = v >> 1;
        }
    }
    
    NSLog(@"Returning checksum as: %i",shift_reg);
    return shift_reg;
}

@end