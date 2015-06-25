//
//  BLEActor.h
//  BTLEUtility
//
//  Created by cerise guo on 6/6/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEActor : NSObject
{
}

@property (readonly) NSString * DiscoveredEvent;
@property (readonly) NSString * LogEvent;


-(void)ScanBLEDevice;
-(void)StopScan;

@end
