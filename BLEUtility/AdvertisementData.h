//
//  AdvertisementData.h
//  BTLEUtility
//
//  Created by cerise guo on 6/7/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvertisementData : NSObject

@property (strong, nonatomic) NSString * UUID;
@property (strong, nonatomic) NSString * Name;
@property (strong, nonatomic) NSNumber * RSSI;
@property (strong, nonatomic) NSUUID * Identifier;

- (BOOL)isEqual:(id)object;

@end
