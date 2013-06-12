//
//  PortraitBubbleSource.m
//  LiveMobile
//
//  Created by Soroush Pour on 11/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "BubbleDelegate.h"

@interface BubbleDelegate ()

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView;
- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row;

@end

@implementation BubbleDelegate

# pragma mark - UIBubbleTableViewDelegate methods

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [_bubbleMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [_bubbleMessages objectAtIndex:row];
    
}

@end
