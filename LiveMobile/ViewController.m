//
//  ViewController.m
//  LiveMobile
//
//  Created by Soroush Pour on 2/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UINavigationBar *clientNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    livem = [[LiveMobileSDK alloc] init];
    [livem initWithParentViewController:self NavigationBar:clientNavBar];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end