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

  sqlite3 *_database;

static CallManager *_manager;

- (id) init {

  if ((self = [super init])) {
      NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"WolfPackDB.db"
          ofType:@"sqlite3"];
//    NSString *path = @"/var/mobile/Containers/Data/Application/42DA1EB0-97F9-45D6-AAF2-80293134B757/Documents/WolfPackDB.db";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Database filename can have extension db/sqlite.
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appDBPath = [documentsDirectory stringByAppendingPathComponent:@"WolfPackDB.db"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL fileExists = [fileManager fileExistsAtPath:appDBPath];
    if (fileExists) {
      NSLog(@"[WP][Native] file exists");
    } else {
      NSLog(@"[WP][Native] file does not exist");
    }
      
      int retOpen = sqlite3_open([appDBPath UTF8String], &_database);
      if (retOpen != SQLITE_OK) {
        NSLog(@"[WP][Native] Failed to open database: %d", retOpen);
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
  
  int retAPI = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);

  if (retAPI == SQLITE_OK) {

    NSLog(@"[WP][Native] database available");
    while(sqlite3_step(statement) == SQLITE_ROW) {

      NSLog(@"in loop");
      char *userIdChars = (char *) sqlite3_column_text(statement, 0);
      userId = [[NSString alloc] initWithUTF8String:userIdChars];
    }
    sqlite3_finalize(statement);
    NSLog(@"[WP][Native] Finished finalizing");
  } else {
    NSLog(@"[WP][Native] Failed to prepare database, reason = %d", retAPI);
  }
  
  return userId;
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
  // Create url connection and fire request
  // NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError* error) {
    // NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    // if (error != nil) {
      // NSLog(@"[WP][Native] Failed to reject call. Message: %@ request method: %@ request body: %@ URL: %@ Status code: %ld", error, request.HTTPMethod, request.HTTPBody, request.URL, (long)[httpResponse statusCode]);
    // } else {
      // NSLog(@"[WP][Native] response status code: %ld", (long)[httpResponse statusCode]);
    // }
  // }];
  
  // [task resume];
  // NSLog(@"[WP][Native] finished rejectCall");
}

@end
