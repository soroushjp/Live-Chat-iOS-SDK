//
//  ChatView.m
//  LiveMobile
//
//  Created by Soroush Pour on 5/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "ChatView.h"

@interface ChatView () {
    
    UIViewController *parentViewController;
    NSInteger viewHeight;
    NSInteger viewWidth;
    NSInteger  windowWidth;
    NSInteger  windowHeight;
    
    
    NSMutableArray* bubbleMessages;
    
    BubbleDelegate* portraitDelegate;
    BubbleDelegate* landscapeDelegate;
    
     //Portrait view UI elements
    FPPopoverController *fpp;
    UIBubbleTableView* myChat;
    ChatViewController *portraitViewController;
    UILabel* lblTitle;
    CALayer *upperBG;
    UITextField *msgBox;
    CALayer *lowerBG;
    CALayer *topBorder;
    UIButton *sendMsgBtn;
    UIButton *hideBtn;
    
    //Landscape view UI elements
    FPPopoverController *fpp2;
    UIBubbleTableView* myChat2;
    ChatViewController *landscapeViewController;
    UILabel* lblTitle2;    
    CALayer *upperBG2;
    UITextField *msgBox2;
    CALayer *lowerBG2;
    CALayer *topBorder2;    
    UIButton *sendMsgBtn2;
    UIButton *hideBtn2;
    
    //Current view status
    UIDeviceOrientation currentOrientation;
    BOOL landscapeIsShrunk;
    BOOL portraitIsShrunk;

}


- (NSMutableArray*) createBubbleArrayFromMessageArray:(NSMutableArray*) array;
- (void) addLiveChatBtnOnNavItem:(UINavigationItem*)navItem;
- (void) addListeners;
- (IBAction)startChatBtnPressed:(id)sender;
- (BOOL) startChat;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)keyboardShow:(NSNotification *)notification;
- (void)keyboardHide:(NSNotification *)notification;
-(void)dismissKeyboard;
    
@end

@implementation ChatView

//Synthesize not necessary in iOS 6 but key to access property as myChat, not _myChat.
@synthesize delegate;

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem initialMessages:passedMessages delegate:(id <ChatViewDelegate>)ChatViewDelegate {
    
    self = [super init];
    if(!self) return nil;

    delegate = ChatViewDelegate;
    
    parentViewController = passedViewController;
    viewWidth = parentViewController.view.frame.size.width;
    viewHeight = parentViewController.view.frame.size.height;
    windowWidth = [[UIScreen mainScreen ] bounds].size.width;
    windowHeight = [[UIScreen mainScreen ] bounds].size.height - 20;
    
    bubbleMessages = [[NSMutableArray alloc] init];
    
    
    bubbleMessages = [self createBubbleArrayFromMessageArray: passedMessages];
    
    //Need a separate class with delegate methods for UIBubbleTableView since we have two separate UIBubbleTableView views, myChat and myChat2 for portrait and landscape, respectively.
    portraitDelegate = [[BubbleDelegate alloc] init];
    [portraitDelegate setBubbleMessages:bubbleMessages];
    landscapeDelegate = [[BubbleDelegate alloc] init];
    [landscapeDelegate setBubbleMessages:bubbleMessages];
    
    [self addLiveChatBtnOnNavItem:navItem];
    [self addListeners];

    return self;
}

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem delegate:(id <ChatViewDelegate>)ChatViewDelegate {
    
    return [self initWithParentViewController:passedViewController NavigationItem:navItem initialMessages:[NSMutableArray array] delegate:ChatViewDelegate];
    
}


- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem {
    
    return [self initWithParentViewController:passedViewController NavigationItem:navItem delegate:nil];
    
}

- (NSMutableArray*) createBubbleArrayFromMessageArray:(NSMutableArray*) array {
    
    NSBubbleData* tempMsg;
    NSString* tempText;
    NSDate* tempDate;
    NSString* tempType;
    NSBubbleType tempBubbleType;
    NSMutableArray* tempBubbleMessages = [[NSMutableArray alloc] init];

    for(int i=0;i<[array count];i++) {
        
        tempText = [array[i] objectForKey:@"dataWithText"];
        tempDate = [array[i] objectForKey:@"date"];
        tempType = [array[i] objectForKey:@"type"];
        
        if([tempType isEqualToString:@"customer"]) tempBubbleType = BubbleTypeMine;
        else tempBubbleType = BubbleTypeSomeoneElse;
        
        tempMsg = [NSBubbleData dataWithText:tempText date:tempDate type:tempBubbleType];
        
        
        [tempBubbleMessages insertObject:tempMsg atIndex:i];
    }
    
    return tempBubbleMessages;
    
}

- (void) addLiveChatBtnOnNavItem:(UINavigationItem*)navItem {

    UIBarButtonItem *startChatBtn = [[UIBarButtonItem alloc] initWithTitle:@"Live Help"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(startChatBtnPressed:)];
    navItem.rightBarButtonItem = startChatBtn;
    
    
}

- (void) addListeners {

    //Attach observers to keyboard opening/closing so we can adjust chat window based on whether keyboard is open
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //Attach observer for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    //Attach tap gesture listener so we can dismiss keyboard when user clicks outside its area
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [parentViewController.view addGestureRecognizer:tap];

}

- (IBAction)startChatBtnPressed:(id)sender {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIDeviceOrientationIsPortrait(orientation) && fpp.view.hidden) {
        [fpp.view setHidden:NO];
    } else if (UIDeviceOrientationIsLandscape(orientation) && fpp2.view.hidden) {
        [fpp2.view setHidden:NO];
    } else {
        [self startChat];
    }
    
}

- (BOOL) startChat {
    
    //Call functions to create controller, insert chat UI into controller as subview and call up Popover containing chat.
    
    portraitViewController = [[ChatViewController alloc]init];    
    [self createPortraitChatView];

    
//    double delayInSeconds = 0.4;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
            landscapeViewController = [[ChatViewController alloc]init];
            [self createLandscapeChatView];
//
//    });
//    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIDeviceOrientationIsPortrait(orientation)) {
    
        [fpp2.view setHidden:YES];
        
    } else if (UIDeviceOrientationIsLandscape(orientation)) {
    
        
        [fpp.view setHidden:YES];
        
    }
    
    return YES;
}

- (BOOL) createPortraitChatView {
    
    viewWidth = parentViewController.view.frame.size.width;
    viewHeight = parentViewController.view.frame.size.height;
    
    //Create upper area with title and top buttons
    upperBG = [CALayer layer];
    upperBG.frame = CGRectMake(1, 0, viewWidth, 40);
    upperBG.backgroundColor = [[UIColor colorWithWhite:0.95 alpha:1] CGColor];
    [portraitViewController.view.layer addSublayer:upperBG];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80,5,180, 30)];
    [lblTitle setText:@"Live Chat Support"];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont systemFontOfSize:18.0]];
    [lblTitle setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [portraitViewController.view addSubview: lblTitle];
    
    hideBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hideBtn setFrame:CGRectMake(10,5,55,30)];
    [hideBtn setTitle:@"Hide" forState:UIControlStateNormal];
    [hideBtn addTarget:self action:@selector(hideBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[lblTitle setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [hideBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [portraitViewController.view addSubview:hideBtn];
    
    // Create our chat UIBubbleTableView UI
    myChat = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(10,upperBG.frame.size.height,viewWidth-40,viewHeight-127)];
    [myChat setBubbleDataSource:portraitDelegate];
    [myChat setBounces:NO];
    [portraitViewController.view addSubview:myChat];
    //    [myChat setBackgroundColor:[UIColor blackColor]];
    
    //Create lower message text and send button area
    topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, myChat.frame.size.height + upperBG.frame.size.height, viewWidth, 3.0f);
    topBorder.backgroundColor = [[UIColor colorWithWhite:0.3 alpha:1] CGColor];
    [portraitViewController.view.layer addSublayer:topBorder];
    
    lowerBG = [CALayer layer];
    lowerBG.frame = CGRectMake(1, myChat.frame.size.height + upperBG.frame.size.height+topBorder.frame.size.height, viewWidth-22, 53);
    lowerBG.backgroundColor = [[UIColor colorWithWhite:0.85 alpha:1] CGColor];
    [portraitViewController.view.layer addSublayer:lowerBG];
    
    msgBox = [[UITextField alloc] initWithFrame:CGRectMake(10, myChat.frame.size.height + upperBG.frame.size.height+topBorder.frame.size.height+7, viewWidth-100, 40)];
    [msgBox setBorderStyle: UITextBorderStyleRoundedRect];
    [msgBox setFont:[UIFont systemFontOfSize:15]];
    [msgBox setText:@""];
    [msgBox setAutocorrectionType: UITextAutocorrectionTypeNo];
    [msgBox setKeyboardType: UIKeyboardTypeDefault];
    [msgBox setReturnKeyType: UIReturnKeySend];
    [msgBox setClearButtonMode: UITextFieldViewModeWhileEditing];
    [msgBox setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [msgBox setDelegate: self];
    [portraitViewController.view addSubview:msgBox];
    
    sendMsgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendMsgBtn setFrame:CGRectMake(viewWidth-85, myChat.frame.size.height + upperBG.frame.size.height+topBorder.frame.size.height+7, 60, 40)];
    [sendMsgBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendMsgBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [sendMsgBtn addTarget:self action:@selector(sendMsgBtnReturn:) forControlEvents:UIControlEventTouchUpInside];
    [portraitViewController.view addSubview:sendMsgBtn];
    
    fpp = [[FPPopoverController alloc] initWithViewController:portraitViewController];
    
    [fpp setContentSize:CGSizeMake(viewWidth,viewHeight-10)];
    [fpp setArrowDirection:FPPopoverNoArrow];
    [fpp setBorder:NO];
    [fpp setTint:FPPopoverLightGrayTint];
    [fpp setAlpha:0.85];
    [fpp presentPopoverFromPoint:CGPointMake(0, 0)];
    
    return YES;
}

- (BOOL) createLandscapeChatView {
    
    
    
    viewWidth = 300;
    viewHeight = 568;
    
    //Create upper area with title and top buttons
    upperBG2 = [CALayer layer];
    upperBG2.frame = CGRectMake(1, 0, viewHeight, 40);
    upperBG2.backgroundColor = [[UIColor colorWithWhite:0.95 alpha:1] CGColor];
    [landscapeViewController.view.layer addSublayer:upperBG2];
    
    lblTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(200,5,180, 30)];
    [lblTitle2 setText:@"Live Chat Support"];
    [lblTitle2 setBackgroundColor:[UIColor clearColor]];
    [lblTitle2 setFont:[UIFont systemFontOfSize:18.0]];
    [lblTitle2 setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [landscapeViewController.view addSubview: lblTitle2];
    
    hideBtn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hideBtn2 setFrame:CGRectMake(10,5,55,30)];
    [hideBtn2 setTitle:@"Hide" forState:UIControlStateNormal];
    [hideBtn2 addTarget:self action:@selector(hideBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[lblTitle setTextColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [hideBtn2.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [landscapeViewController.view addSubview:hideBtn2];
    
    // Create our chat UIBubbleTableView UI
    myChat2 = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(10,upperBG2.frame.size.height,viewHeight-40,viewWidth-127)];
    [myChat2 setBubbleDataSource:landscapeDelegate];
    [myChat2 setBounces:NO];
    [landscapeViewController.view addSubview:myChat2];
    //    [myChat2 setBackgroundColor:[UIColor blackColor]];
    
    //Create lower message text and send button area
    topBorder2 = [CALayer layer];
    topBorder2.frame = CGRectMake(0, myChat2.frame.size.height + upperBG2.frame.size.height, viewHeight, 3.0f);
    topBorder2.backgroundColor = [[UIColor colorWithWhite:0.3 alpha:1] CGColor];
    [landscapeViewController.view.layer addSublayer:topBorder2];
    
    lowerBG2 = [CALayer layer];
    lowerBG2.frame = CGRectMake(1, myChat2.frame.size.height + upperBG2.frame.size.height+topBorder2.frame.size.height, viewHeight-22, 53);
    lowerBG2.backgroundColor = [[UIColor colorWithWhite:0.85 alpha:1] CGColor];
    [landscapeViewController.view.layer addSublayer:lowerBG2];
    
    msgBox2 = [[UITextField alloc] initWithFrame:CGRectMake(10, myChat2.frame.size.height + upperBG2.frame.size.height+topBorder2.frame.size.height+7, viewHeight-100, 40)];
    [msgBox2 setBorderStyle: UITextBorderStyleRoundedRect];
    [msgBox2 setFont:[UIFont systemFontOfSize:15]];
    [msgBox2 setText:@""];
    [msgBox2 setAutocorrectionType: UITextAutocorrectionTypeNo];
    [msgBox2 setKeyboardType: UIKeyboardTypeDefault];
    [msgBox2 setReturnKeyType: UIReturnKeySend];
    [msgBox2 setClearButtonMode: UITextFieldViewModeWhileEditing];
    [msgBox2 setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [msgBox2 setDelegate: self];
    [landscapeViewController.view addSubview:msgBox2];
    
    sendMsgBtn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendMsgBtn2 setFrame:CGRectMake(viewHeight-85, myChat2.frame.size.height + upperBG2.frame.size.height+topBorder2.frame.size.height+7, 60, 40)];
    [sendMsgBtn2 setTitle:@"Send" forState:UIControlStateNormal];
    [sendMsgBtn2.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [sendMsgBtn2 addTarget:self action:@selector(sendMsgBtnReturn:) forControlEvents:UIControlEventTouchUpInside];
    [landscapeViewController.view addSubview:sendMsgBtn2];
    
    fpp2 = [[FPPopoverController alloc] initWithViewController:landscapeViewController];
    
    [fpp2 setContentSize:CGSizeMake(viewHeight,viewWidth-10)];
    [fpp2 setArrowDirection:FPPopoverNoArrow];
    [fpp2 setBorder:NO];
    [fpp2 setTint:FPPopoverLightGrayTint];
    [fpp2 setAlpha:0.85];
    [fpp2 presentPopoverFromPoint:CGPointMake(0, 0)];
    
    return YES;
}

//Used to route return from Send button to common textfield return function textFieldShouldReturn
- (IBAction)hideBtnPressed:(id)sender {
    
    [fpp.view setHidden:YES];
    [fpp2.view setHidden:YES];
    
}

//Used to route return from Send button to common textfield return function textFieldShouldReturn
- (IBAction)sendMsgBtnReturn:(id)sender {
    
    [self textFieldShouldReturn:msgBox];
}

//Dismiss keyboard on Done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if([[textField text] isEqualToString:@""]) return NO;
    
    BOOL success = [self addMsgToViewWithText:[textField text] date:[NSDate dateWithTimeIntervalSinceNow:0] author:@"customer"];
    
    if(delegate != nil && [delegate respondsToSelector:@selector(userDidTypeMessage:date:)]) {
        [delegate userDidTypeMessage:[textField text] date:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
    
    if(success) [textField setText:@""];
    
    return YES;
}

- (BOOL) addMsgToViewWithText:(NSString*)text date:(NSDate*)date author:(NSString*)author {
    
    NSBubbleType messageType;

    if([author isEqualToString:@"agent"]) messageType = BubbleTypeSomeoneElse;
    else if ([author isEqualToString:@"customer"]) messageType = BubbleTypeMine;
    else return NO;
    
    
    NSBubbleData *newMsg = [NSBubbleData dataWithText:text date:date type:messageType];
    
    [bubbleMessages addObject:newMsg];
    [myChat reloadData];
 //   [myChat2 reloadData];

    return YES;
}

# pragma mark - Notification listeners - keyboard show/hide notifcation, dismiss keyboard, orientation change

//Adjust the chat window height when keyboard appears
- (void)keyboardShow:(NSNotification *)notification
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIDeviceOrientationIsPortrait(orientation)) {
        
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect myChatFrame = [myChat frame];
        myChatFrame.size.height -= keyboardSize.height;
        [myChat setFrame:myChatFrame];
        
        //Disable CALayer implicit animations
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        
        CGRect lowerBGFrame = [lowerBG frame];
        lowerBGFrame.origin.y -= keyboardSize.height;
        [lowerBG setFrame:lowerBGFrame];
        
        CGRect topBorderFrame = [topBorder frame];
        topBorderFrame.origin.y -= keyboardSize.height;
        [topBorder setFrame:topBorderFrame];
        
        [CATransaction commit];
        
        CGRect msgBoxFrame = [msgBox frame];
        msgBoxFrame.origin.y -= keyboardSize.height;
        [msgBox setFrame:msgBoxFrame];
        
        CGRect sendMsgBtnFrame = [sendMsgBtn frame];
        sendMsgBtnFrame.origin.y -= keyboardSize.height;
        [sendMsgBtn setFrame:sendMsgBtnFrame];
        
        CGSize fppSize = [fpp contentSize];
        fppSize.height -= keyboardSize.height;
        [fpp setContentSize:fppSize];
        [fpp setupView];
        
        [myChat scrollToBottomWithAnimation:NO];
        
    } else if (UIDeviceOrientationIsLandscape(orientation)) {
    
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect myChatFrame = [myChat2 frame];
        myChatFrame.size.height -= keyboardSize.width;
        [myChat2 setFrame:myChatFrame];
        
        //Disable CALayer implicit animations
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        
        CGRect lowerBGFrame = [lowerBG2 frame];
        lowerBGFrame.origin.y -= keyboardSize.width;
        [lowerBG2 setFrame:lowerBGFrame];
        
        CGRect topBorderFrame = [topBorder2 frame];
        topBorderFrame.origin.y -= keyboardSize.width;
        [topBorder2 setFrame:topBorderFrame];
        
        [CATransaction commit];
        
        CGRect msgBoxFrame = [msgBox2 frame];
        msgBoxFrame.origin.y -= keyboardSize.width;
        [msgBox2 setFrame:msgBoxFrame];
        
        CGRect sendMsgBtnFrame = [sendMsgBtn2 frame];
        sendMsgBtnFrame.origin.y -= keyboardSize.width;
        [sendMsgBtn2 setFrame:sendMsgBtnFrame];
        
        CGSize fppSize = [fpp2 contentSize];
        fppSize.height -= keyboardSize.width;
        [fpp2 setContentSize:fppSize];
        [fpp2 setupView];
        
        [myChat2 scrollToBottomWithAnimation:NO];
    
    }
    
}

//Adjust the chat window height when keyboard disappears
- (void)keyboardHide:(NSNotification *)notification
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIDeviceOrientationIsPortrait(orientation)) {
        
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect myChatFrame = [myChat frame];
        myChatFrame.size.height += keyboardSize.height;
        [myChat setFrame:myChatFrame];
        
        //Disable CALayer implicit animations
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        
        CGRect lowerBGFrame = [lowerBG frame];
        lowerBGFrame.origin.y += keyboardSize.height;
        [lowerBG setFrame:lowerBGFrame];
        
        CGRect topBorderFrame = [topBorder frame];
        topBorderFrame.origin.y += keyboardSize.height;
        [topBorder setFrame:topBorderFrame];
        
        [CATransaction commit];
        //Done disabling implicit animations
        
        CGRect msgBoxFrame = [msgBox frame];
        msgBoxFrame.origin.y += keyboardSize.height;
        [msgBox setFrame:msgBoxFrame];
        
        CGRect sendMsgBtnFrame = [sendMsgBtn frame];
        sendMsgBtnFrame.origin.y += keyboardSize.height;
        [sendMsgBtn setFrame:sendMsgBtnFrame];
        
        CGSize fppSize = [fpp contentSize];
        fppSize.height += keyboardSize.height;
        [fpp setContentSize:fppSize];
        [fpp setupView];
        
    }
}


//Dismiss keyboard from message box if a user taps anywhere but keyboard on screen
-(void)dismissKeyboard {
    [msgBox resignFirstResponder];
}

- (void) reorientChat {
    
    viewWidth = parentViewController.view.frame.size.width;
    viewHeight = parentViewController.view.frame.size.height;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(UIDeviceOrientationIsLandscape(orientation)) {
        //This means new orientation is landscape (old orientation was portrait).
        
        if (portraitViewController.isViewLoaded && portraitViewController.view.window && fpp.view.hidden == NO) {
            [fpp.view setHidden:YES];
        }
        if (landscapeViewController.isViewLoaded && landscapeViewController.view.window && fpp2.view.hidden == YES) {
            //[fpp2.view setHidden:NO];
            
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [fpp2.view setHidden:NO];
                
            });
        
        }
        
    } else if (UIDeviceOrientationIsPortrait(orientation)) {
        //This means new orientation is portrait (old orientation was landscape).
        
        if (landscapeViewController.isViewLoaded && landscapeViewController.view.window && fpp2.view.hidden == NO) {
            [fpp2.view setHidden:YES];
        }
        if (portraitViewController.isViewLoaded && portraitViewController.view.window && fpp.view.hidden == YES) {
            
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [fpp.view setHidden:NO];
                
            });
            
        }

    }

}

- (void)orientationChange:(NSNotification *)notification {
    
    //We don't care about orientation if not chat views are open
    if (fpp.view.hidden && fpp2.view.hidden) return;
    
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //Ignoring specific orientations
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object:nil];
    //Responding only to changes in landscape or portrait
    currentOrientation = orientation;
    //
    [self performSelector:@selector(reorientChat) withObject:nil afterDelay:0];
}

@end
