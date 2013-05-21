//
//  X80FlipsideViewController.h
//  RobotControl
//
//  Created by Billy Zoellers on 5/16/13.
//  Copyright (c) 2013 Transylvania University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class X80FlipsideViewController;

@protocol X80FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(X80FlipsideViewController *)controller;
@end

@interface X80FlipsideViewController : UIViewController

@property (weak, nonatomic) id <X80FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
