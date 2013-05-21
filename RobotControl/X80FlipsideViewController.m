//
//  X80FlipsideViewController.m
//  RobotControl
//
//  Created by Billy Zoellers on 5/16/13.
//  Copyright (c) 2013 Transylvania University. All rights reserved.
//

#import "X80FlipsideViewController.h"

@interface X80FlipsideViewController ()

@end

@implementation X80FlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions


- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
