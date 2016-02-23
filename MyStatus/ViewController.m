//
//  ViewController.m
//  MyStatus
//
//  Created by Mudit Ameta on 24/02/16.
//  Copyright © 2016 Mudit Ameta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)refreshBtn:(id)sender;
- (IBAction)sickBtn:(id)sender;
- (IBAction)boredBtn:(id)sender;
- (IBAction)asleepBtn:(id)sender;
- (IBAction)awakeBtn:(id)sender;
- (void)updateCurrentStatus;
@property (weak, nonatomic) IBOutlet UILabel *lastStatus;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateCurrentStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCurrentStatus {
    NSURL *apiUrl = [NSURL URLWithString:@"https://status.mudit.xyz/iam"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *fetchCurrStatusTask = [session dataTaskWithURL:apiUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lastStatus.text = jsonData[@"status"];
        });
    }];
    
    [fetchCurrStatusTask resume];
}

- (IBAction)refreshBtn:(id)sender {
    [self updateCurrentStatus];
}

- (IBAction)sickBtn:(id)sender {
    self.lastStatus.text = @"sick";
}

- (IBAction)boredBtn:(id)sender {
    self.lastStatus.text = @"bored";
}

- (IBAction)asleepBtn:(id)sender {
    self.lastStatus.text = @"asleep";
}

- (IBAction)awakeBtn:(id)sender {
    self.lastStatus.text = @"awake";
}
@end
