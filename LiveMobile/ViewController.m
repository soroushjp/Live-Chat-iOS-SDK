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
    
    //The client creates a navigation bar and navigation item into which we can add our Live Chat button
    UINavigationBar *clientNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:clientNavBar];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Fashionista"];
    [clientNavBar  pushNavigationItem:navItem animated:NO];
    
    //Add the LiveChat button and functionality behind button.
    livem = [[LiveMobileSDK alloc] initWithParentViewController:self NavigationItem:navItem];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end