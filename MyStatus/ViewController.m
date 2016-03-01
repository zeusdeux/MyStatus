//
//  ViewController.m
//  MyStatus
//
//  Created by Mudit Ameta on 24/02/16.
//  Copyright © 2016 Mudit Ameta. All rights reserved.
//

#import "ViewController.h"
#import "AFURLSessionManager.h"

@interface ViewController ()
- (IBAction)refreshBtn:(id)sender;
- (IBAction)sickBtn:(id)sender;
- (IBAction)boredBtn:(id)sender;
- (IBAction)asleepBtn:(id)sender;
- (IBAction)awakeBtn:(id)sender;
- (void)fetchCurrentStatus:(void(^)(NSString *))handler;
- (void)changeCurrentStatus:(NSString *)status;
- (void)updateCurrentStatus:(NSString *)encryptedStatusFilePath;
@property (weak, nonatomic) IBOutlet UILabel *lastStatus;

+ (NSString *)url;

@end

@implementation ViewController

+ (NSString *)url {
    return @"https://status.mudit.xyz/iam";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self fetchCurrentStatus:^(NSString *status){
        [self changeCurrentStatus:status];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeCurrentStatus:(NSString *)status {
    self.lastStatus.text = status;
}

- (void)fetchCurrentStatus:(void(^)(NSString *))handler {
    NSURL *apiUrl = [NSURL URLWithString:[ViewController url]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *fetchCurrStatusTask = [session dataTaskWithURL:apiUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(jsonData[@"status"]);
        });
    }];
    
    [fetchCurrStatusTask resume];
}

- (void)updateCurrentStatus:(NSString *)encryptedStatusFilePath {
    
    NSLog(@"%@", encryptedStatusFilePath);
    
    NSURL *bundle = [[NSBundle mainBundle] bundleURL];
    NSURL *file = [NSURL URLWithString:encryptedStatusFilePath relativeToURL:bundle];
    NSURL *absoluteFilePath = [file absoluteURL];
    
    NSLog(@"absolute file path: %@", absoluteFilePath);
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[ViewController url] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:absoluteFilePath name:@"status" error:nil];
    } error:nil];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask = [manager
        uploadTaskWithStreamedRequest:request
        progress:^(NSProgress * _Nonnull uploadProgress) {
            // This is not called back on the main queue.
            // You are responsible for dispatching to the main queue for UI updates
//                      dispatch_async(dispatch_get_main_queue(), ^{
//                          //Update the progress view
//                          [progressView setProgress:uploadProgress.fractionCompleted];
//                      });
        }
        completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSLog(@"%@", error);
            NSLog(@"%@", response);
            NSLog(@"%@", responseObject);
            if(error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self changeCurrentStatus:error.localizedDescription];
                });
            }
            else {
                [self fetchCurrentStatus:^(NSString *status) {
                    [self changeCurrentStatus:status];
                }];
            }
        }
    ];
    
    [uploadTask resume];
}


- (IBAction)refreshBtn:(id)sender {
    [self fetchCurrentStatus:^(NSString *status){
        [self changeCurrentStatus:status];
    }];
}

- (IBAction)sickBtn:(id)sender {
    [self updateCurrentStatus:@"encryptedStatuses.bundle/sick.encrypted"];
}

- (IBAction)boredBtn:(id)sender {
    [self updateCurrentStatus:@"encryptedStatuses.bundle/bored.encrypted"];
}

- (IBAction)asleepBtn:(id)sender {
    [self updateCurrentStatus:@"encryptedStatuses.bundle/asleep.encrypted"];
}

- (IBAction)awakeBtn:(id)sender {
    [self updateCurrentStatus:@"encryptedStatuses.bundle/awake.encrypted"];
}
@end
