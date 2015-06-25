//
//  AdvertisementData.m
//  BTLEUtility
//
//  Created by cerise guo on 6/7/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import "AdvertisementData.h"

@implementation AdvertisementData

@synthesize Name, RSSI, UUID;

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    AdvertisementData *other = (AdvertisementData*)object;
    
    if ([other.Name isEqualToString:self.Name] &&
        [other.UUID isEqualToString:self.UUID]) {
        return YES;
    }
    
    return NO;
}

@end
