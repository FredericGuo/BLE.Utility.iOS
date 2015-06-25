//
//  DetailViewControllerTableViewController.m
//  BLEUtility
//
//  Created by cerise guo on 6/14/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import "BLEDetailViewController.h"
#import "CoreBluetooth/CBCentralManager.h"
#import "CoreBluetooth/CBPeripheral.h"
#import "CoreBluetooth/CBUUID.h"
#import "CoreBluetooth/CBService.h"
#import "CoreBluetooth/CBCharacteristic.h"

@interface BLEDetailViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
- (IBAction)ClickConnect:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *detailTableView;

@end

@implementation BLEDetailViewController
{
    CBCentralManager * manager;
    dispatch_queue_t btQueue;
    CBPeripheral * currentPeripheral;
    NSMutableArray * characteristics;
}

@synthesize bleDataFromParent;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = self.bleDataFromParent.Name;

    currentPeripheral = nil;
    characteristics = [NSMutableArray arrayWithCapacity:1];
    btQueue = dispatch_queue_create("btConnectionQueue", DISPATCH_QUEUE_CONCURRENT);
    manager = manager = [[CBCentralManager alloc] initWithDelegate:self queue:btQueue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * identifier = @"BLEDetailCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSLog(@"can not get cell");
    }
    
    if( 0 == indexPath.row )
    {
        UILabel * cellLabel1 = (UILabel*)[cell.contentView viewWithTag:200];
        cellLabel1.text = @"Characteristic Attributes :";
        cellLabel1.textColor = [UIColor blueColor];
        cellLabel1.numberOfLines = 0;
        cellLabel1.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }
    
    CBCharacteristic * character = [characteristics objectAtIndex:indexPath.row];
    
    UILabel * cellLabel1 = (UILabel*)[cell.contentView viewWithTag:200];
    NSMutableString * UUIDStr = [NSMutableString stringWithCapacity:16];
    
    NSData * data = character.UUID.data;
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
    [UUIDStr appendString:@"  ==> "];
    
    //UILabel * cellLabel2 = (UILabel*)[cell.contentView viewWithTag:201];
    //NSMutableString * attr = [[NSMutableString alloc] init];
    if (character.properties & CBCharacteristicPropertyWrite) {
        [UUIDStr appendString:@" Writable"];
    }
    if (character.properties & CBCharacteristicPropertyRead) {
        [UUIDStr appendString:@" Readble"];
    }
    if (character.properties & CBCharacteristicPropertyNotify) {
        [UUIDStr appendString:@" Notify"];
    }
    if (character.properties & CBCharacteristicPropertyIndicate) {
        [UUIDStr appendString:@" Indicate"];
    }
    //cellLabel2.text = attr;
    cellLabel1.text = UUIDStr;
    cellLabel1.numberOfLines = 0;
    
    return cell;
}


- (IBAction)ClickConnect:(id)sender {
    NSLog(@"Click Connection buttoin");
    
    NSLog(@"Data: %@", self.bleDataFromParent.Name);
    NSLog(@"Data: %@", self.bleDataFromParent.UUID);
    NSLog(@"Data: %@", self.bleDataFromParent.Identifier);
    NSLog(@"Data: %@", [self.bleDataFromParent.RSSI stringValue]);
    
    {
        [characteristics removeAllObjects];
        [self.detailTableView reloadData];
    }
    
    if (nil != self.bleDataFromParent.Identifier) {
        NSArray * array = [[NSArray alloc] initWithObjects:self.bleDataFromParent.Identifier, nil];
        NSArray * peripherals = [manager retrievePeripheralsWithIdentifiers:array];
        if (nil != peripherals && 0 < peripherals.count ) {
            currentPeripheral = peripherals[0];
            [manager connectPeripheral:currentPeripheral options:nil];
        }
    }
}

#pragma mark - CoreBT Delegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to : %@", peripheral.identifier);
    
    currentPeripheral = peripheral;
    currentPeripheral.delegate = self;
    [currentPeripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (nil != error) {
        NSLog( @"Error in discover services : %@:%d", error.domain, error.code);
        return;
    }
    
    for( CBService * serv in peripheral.services )
    {
        NSLog(@"Discovered service : %@", serv.UUID);
        [peripheral discoverCharacteristics:nil forService:serv];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (nil != error) {
        NSLog( @"Error in discover characteristic : %@:%d", error.domain, error.code);
        return;
    }
    
    NSLog(@"For service : %@ ========", service.UUID);
    for (CBCharacteristic * character in service.characteristics) {
        NSLog(@"Discovered characterstic : %@", character.UUID);
        [characteristics addObject:character];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.detailTableView reloadData];
    });

}
@end
