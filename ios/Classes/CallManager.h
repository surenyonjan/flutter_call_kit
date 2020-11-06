//
//  CallManager.h
//  Runner
//
//  Created by Suren Yonjan on 11/6/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#ifndef CallManager_h
#define CallManager_h


#endif /* CallManager_h */

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CallManager : NSObject {
  sqlite3 *_database;
}

+ (void) rejectCall:(NSString *)uuidString;
@end
