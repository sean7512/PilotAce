//
//  NSUserDefaults+SecureNSUserDefaults.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/26/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (SecureNSUserDefaults)

- (void)setSecureFloat:(float)f forKey:(NSString *)key;
- (float)secureFloatForKey:(NSString *)key;
- (void)setSecureInt:(int64_t)i forKey:(NSString *)key;
- (int64_t)secureIntForKey:(NSString *)key;

@end
