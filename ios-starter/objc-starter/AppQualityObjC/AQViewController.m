//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AQViewController.h"
@import Firebase;

@interface AQViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation AQViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *paths = NSSearchPathForDirectoriesInDomains
  (NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = paths[0];

  //make a file name to write the data to using the documents directory
  NSString *fileName = [NSString stringWithFormat:@"%@/perfsamplelog.txt",
                        documentsDirectory];

  NSError *fileReadError;
  NSString *contents = [NSString stringWithContentsOfFile:fileName
                                                 encoding:NSUTF8StringEncoding
                                                    error:&fileReadError];

  if (fileReadError != nil) {
    NSLog(@"Log file doesn't exist yet %@: %@", fileName, fileReadError);
  }

  NSUInteger fileLength = 0;
  if (contents) {
    fileLength = contents.length;
  }


  NSString *target = @"https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_96dp.png";
  NSURL *targetUrl = [NSURL URLWithString:target];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:targetUrl];
  request.HTTPMethod = @"GET";

  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
    ^(NSData * _Nullable data,
      NSURLResponse * _Nullable response,
      NSError * _Nullable error) {

      if (error) {
        NSLog(@"%@", error.localizedDescription);
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.image = [UIImage imageWithData:data];
      });

      NSString *contentToWrite = [contents stringByAppendingString:response.URL.absoluteString];
      [contentToWrite writeToFile:fileName
                       atomically:NO
                         encoding:NSStringEncodingConversionAllowLossy
                            error:nil];
    }] resume];

}

- (IBAction)didPressCrash:(id)sender {
  NSLog(@"Crash button pressed!");
  assert(NO);
}

@end

