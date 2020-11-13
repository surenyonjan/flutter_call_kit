//
//  CallManager.m
//  Runner
//
//  Created by Suren Yonjan on 11/6/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//
#import "CallManager.h"

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@implementation CallManager

static CallManager *_manager;

- (id) init {
  return self;
}

- (void)dealloc {
}

+ (void) rejectCall:(NSString *)uuidString
{

  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

  NSString *authUserIDKey = @"flutter.AUTH_USER_ID_KEY";
  NSString *userId = [preferences stringForKey:authUserIDKey];
  NSLog(@"[WP][Native] auth user id: %@", userId);

  if (userId == nil)
  {
    return;
  }
  // Create the request.
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://chat.mywolfpack.us/api/rejectCall"]];

  // Specify that it will be a POST request
  request.HTTPMethod = @"POST";

  // Setting a timeout
  request.timeoutInterval = 20.0;
  // This is how we set header fields
  [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

  // Convert your data and set your request's HTTPBody property
  NSDictionary *dictionary = @{ @"id": uuidString, @"senderId": userId };
  NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
  request.HTTPBody = requestBodyData;


  NSURLResponse * response = nil;
  NSError * error = nil;
  NSData * data = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&response
                                                    error:&error];

  if (error != nil)
  {
    NSLog(@"[WP][Native] failed to reject call. Error: %@", error);
  }
  NSLog(@"[WP][Native] finished rejecting call");
}

@end
