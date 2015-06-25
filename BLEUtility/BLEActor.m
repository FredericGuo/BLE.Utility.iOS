//
//  BLEActor.m
//  BTLEUtility
//
//  Created by cerise guo on 6/6/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import "BLEActor.h"
#import "CoreBluetooth/CBCentralManager.h"
#import "CoreBluetooth/CBPeripheral.h"
#import "CoreBluetooth/CBUUID.h"

static const NSString * DISCOVERED_BLE_DEVICE = @"Discovered.BLE.Device";
static const NSString * LOG_MESSAGE = @"Log.Message";

@interface BLEActor () <CBCentralManagerDelegate>//, CBPeripheralDelegate>

//@property (strong, nonatomic) IBOutlet UITableView *btTableView;

- (void)logMessage:(NSObject*)msg;

@end

@implementation BLEActor
{
    CBCentralManager * manager;
    dispatch_queue_t btQueue;
    NSNotificationCenter * noteCenter;
}

@synthesize DiscoveredEvent = _DiscoveredEvent;
@synthesize LogEvent = _LogEvent;

- (id)init {
    self = [super init];
    if (self) {
        [self initBT];
    }
    
    noteCenter = [NSNotificationCenter defaultCenter];
    
    _DiscoveredEvent = (NSString*)DISCOVERED_BLE_DEVICE;
    _LogEvent = (NSString*)LOG_MESSAGE;
    
    return self;
}

- (void)initBT
{
    btQueue = dispatch_queue_create("btDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    manager = manager = [[CBCentralManager alloc] initWithDelegate:self queue:btQueue];
}

- (void)logMessage:(NSString*)msg
{
    if (nil == msg) {
        return;
    }
    
    NSMutableDictionary * logMessage = [NSMutableDictionary dictionaryWithCapacity:1];
    [logMessage setObject:msg forKey:@"MSG"];
    [noteCenter postNotificationName:[self LogEvent] object:self userInfo:logMessage];
}

#pragma mark - public interfaces
-(void)ScanBLEDevice
{
    [self logMessage:@"Enter ScanBLEDevice()"];
    [manager scanForPeripheralsWithServices:nil options:nil];
}

-(void)StopScan
{
    [self logMessage:@"Enter StopScan()"];
    [manager stopScan];
}

#pragma mark - CBCentralManager delegate methods

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    //[self isLECapableHardware];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Enter didDiscoverPeripheral : %@ , RSSI: %@", peripheral.name, RSSI.stringValue );
    [self logMessage:peripheral.name ];
    
    NSArray * uuids = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSString * UUIDStringResult = @"";
    
    if (nil != uuids)
    {
        NSMutableString * UUIDStr = [NSMutableString stringWithCapacity:16];
        for( CBUUID *uuid in uuids)
        {
            NSData * data = uuid.data;
            NSUInteger bytesToConvert = [data length];
            const unsigned char *uuidBytes = [data bytes];
            
            for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
            {
                switch (currentByteIndex)
                {
                    case 3:
                    case 5:
                    case 7:
                    case 9:[UUIDStr appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
                    default:[UUIDStr appendFormat:@"%02x", uuidBytes[currentByteIndex]];
                }
                
            }
            
            [UUIDStr appendString:@"-"];
        }
        
        UUIDStringResult = [UUIDStr substringToIndex:[UUIDStr length] -1]; //remove the last '-'
    }
    
    [self logMessage: UUIDStringResult];
    
    NSMutableDictionary * info = [NSMutableDictionary dictionaryWithCapacity:2];
    
    //NSString * advUUID = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    //if (nil == advUUID) {
    //    advUUID = @"";
    //}
    [info setObject:UUIDStringResult forKey:@"ADV_UUID"];
    
    NSString * name = peripheral.name;//[advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (nil == name) {
        name = @"";
    }
    [info setObject:name forKey:@"LOCAL_NAME"];
    [info setObject:RSSI forKey:@"RSSI"];
    [info setObject:peripheral.identifier forKey:@"identifier"];
    
    [noteCenter postNotificationName:[self DiscoveredEvent] object:self userInfo:info];
    //[note postNotificationName:@"Discovered.BLE.Device" object:self userInfo:info];
}

@end
