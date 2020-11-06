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

  if ((self = [super init])) {
      NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"WolfPackDB.db"
          ofType:@"sqlite3"];
      
      if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
          NSLog(@"Failed to open database!");
      }
  }
  return self;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (NSString *) getCachedAuthId {
  
  NSString *userId;
  
  NSString *query = @"SELECT id FROM CachedAuth";
  sqlite3_stmt *statement;

  if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {

    while(sqlite3_step(statement) == SQLITE_ROW) {

      char *userIdChars = (char *) sqlite3_column_text(statement, 0);
      userId = [[NSString alloc] initWithUTF8String:userIdChars];
    }
    sqlite3_finalize(statement);
  }
  
  return userId;
}

+ (void) rejectCall:(NSString *)uuidString
{

  if (_manager == nil) {
    _manager = [[CallManager alloc] init];
  }
  
  NSString* userId = [_manager getCachedAuthId];

  // Create the request.
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://chat.wolfpack.mobi/api/rejectCall"]];

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

  // Create url connection and fire request
  NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
  NSURLSessionTask *task = [urlSession dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError* error) {
    if (error != nil) {
      NSLog(@"Failed to reject call");
    }
  }];
  
  [task resume];
  [urlSession finishTasksAndInvalidate];
}

@end
