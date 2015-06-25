//
//  Player.h
//  BLEUtility
//
//  Created by cerise guo on 6/13/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEInfo : NSObject

@property (nonatomic,copy)NSString* name;
@property (nonatomic,copy)NSString* identifier;
@property (nonatomic,copy)NSString* advertisementUUID;
@property (nonatomic,strong)NSNumber* RSSI;

@end
