//
//  DashboardViewController.m
//  NewsBlur
//
//  Created by Roy Yang on 7/10/12.
//  Copyright (c) 2012 NewsBlur. All rights reserved.
//

#import "DashboardViewController.h"
#import "NewsBlurAppDelegate.h"
#import "ActivityModule.h"
#import "InteractionsModule.h"
#import "UserProfileViewController.h"
#import "JSON.h"

#define FEEDBACK_URL @"http://dev.newsblur.com/about"

@implementation DashboardViewController

@synthesize appDelegate;
@synthesize interactionsModule;
@synthesize activitiesModule;
@synthesize feedbackWebView;
@synthesize toolbar;
@synthesize segmentedButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.toolbar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46 alpha:0.9];
    self.interactionsModule.hidden = NO;
    self.activitiesModule.hidden = YES;
    self.feedbackWebView.hidden = YES;
    self.feedbackWebView.delegate = self;
    
    // preload feedback
    self.feedbackWebView.scalesPageToFit = YES;
    
    
    NSString *urlAddress = FEEDBACK_URL;
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //Load the request in the UIWebView.
    [self.feedbackWebView loadRequest:requestObj];
}

- (void)viewDidUnload {
    [self setAppDelegate:nil];
    [self setInteractionsModule:nil];
    [self setActivitiesModule:nil];
    [self setToolbar:nil];
    [self setSegmentedButton:nil];
    [self setFeedbackWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.16f green:0.36f blue:0.46 alpha:0.9];
    
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = DASHBOARD_TITLE;
    self.navigationItem.titleView = label;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)doLogout:(id)sender {
    [appDelegate confirmLogout];
}

# pragma mark
# pragma mark Interactions

- (void)refreshInteractions {
    [self.interactionsModule fetchInteractionsDetail:1];    
}

- (void)requestFailed:(ASIHTTPRequest *)request {    
    NSLog(@"Error in finishLoadInteractions is %@", [request error]);
}

- (IBAction)tapSegmentedButton:(id)sender {
    int selectedSegmentIndex = [self.segmentedButton selectedSegmentIndex];
    
    if (selectedSegmentIndex == 0) {
        self.interactionsModule.hidden = NO;
        self.activitiesModule.hidden = YES;
        self.feedbackWebView.hidden = YES;
    } else if (selectedSegmentIndex == 1) {
        self.interactionsModule.hidden = YES;
        self.activitiesModule.hidden = NO;
        self.feedbackWebView.hidden = YES;
    } else if (selectedSegmentIndex == 2) {
        self.interactionsModule.hidden = YES;
        self.activitiesModule.hidden = YES;
        self.feedbackWebView.hidden = NO;
    }
}

# pragma mark
# pragma mark Activities

- (void)refreshActivity {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/social/activities?user_id=%@&limit=10",
                           NEWSBLUR_URL,
                           [appDelegate.dictUserProfile objectForKey:@"user_id"]];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDidFinishSelector:@selector(finishLoadActivities:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)finishLoadActivities:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    NSDictionary *results = [[NSDictionary alloc] 
                             initWithDictionary:[responseString JSONValue]];
    
    appDelegate.dictUserActivities = results;
    
    if (self.activitiesModule == nil) {
        ActivityModule *activity = [[ActivityModule alloc] init];
        activity.frame = CGRectMake(20, 510, 320, 320);
        self.activitiesModule = activity;
        [self.view addSubview:self.activitiesModule];
    }
    
    NSArray *activities = [appDelegate.dictUserActivities objectForKey:@"activities"];
    NSString *username = [appDelegate.dictUserActivities objectForKey:@"username"];
    if (!username) {
        username = [[appDelegate.dictUserActivities objectForKey:@"user_profile"] objectForKey:@"username"];
    }
    
    [self.activitiesModule refreshWithActivities:activities withUsername:username];

}

# pragma mark
# pragma mark Feedback

- (BOOL)webView:(UIWebView *)webView 
shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSString *urlString = [NSString stringWithFormat:@"%@", url];

    if ([urlString isEqualToString: FEEDBACK_URL]){
        return YES;
    } else {
        return NO;
    }
}
@end