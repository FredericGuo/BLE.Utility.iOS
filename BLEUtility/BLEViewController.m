//
//  PlayerViewControllerTableViewController.m
//  BLEUtility
//
//  Created by cerise guo on 6/13/15.
//  Copyright (c) 2015 cerise guo. All rights reserved.
//

#import "BLEViewController.h"
//#import "BLEInfo.h"
#import "AdvertisementData.h"
#import "BLEActor.h"
#import "BLEDetailViewController.h"

@interface BLEViewController ()  <UITableViewDataSource, UITableViewDelegate>

//@property (strong, nonatomic) NSMutableArray * bleInfo;
@property (strong, nonatomic) NSMutableArray * bluetoothDevices;
@property (strong, nonatomic) IBOutlet UITableView *btTableView;
@property (strong, nonatomic) IBOutlet UITextView *logView;

- (IBAction)OnStartScan:(id)sender;
- (IBAction)OnStopScan:(id)sender;

@end

@implementation BLEViewController
{
    NSNotificationCenter * noteCenter;
    BLEActor * m_bleActor;
    
    const NSNumber * RSSI_STRONG;
    const NSNumber * RSSI_GOOD;
    const NSNumber * RSSI_UNSTABLE;
    const NSNumber * RSSI_BAD;
}

//@synthesize bleInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RSSI_STRONG = [[NSNumber alloc] initWithInt:-60];
    RSSI_GOOD = [[NSNumber alloc] initWithInt:-70];
    RSSI_UNSTABLE = [[NSNumber alloc] initWithInt:-90];
    RSSI_BAD = [[NSNumber alloc] initWithInt:-110];
    
    [self setupTableView];
    [self setupBTLE];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*self.bleInfo = [NSMutableArray arrayWithCapacity:2];
    
     BLEInfo * device = [[BLEInfo alloc] init];
     device.name = @"MI";
     device.advertisementUUID = @"1234-567-890-1111";
     device.RSSI = [NSNumber numberWithInt:-90]; //[[NSNumber alloc]initWithInt:-89];
     device.identifier = @"identifier";
     
     [self.bleInfo addObject:device];
     
     device = [[BLEInfo alloc] init];
     device.name = @"MDT";
     device.advertisementUUID = @"0000-222-444-6666";
     device.RSSI = [NSNumber numberWithInt:-104];//[[NSNumber alloc]initWithInt:-104];
     device.identifier = @"identifier";
     
     [self.bleInfo addObject:device];*/
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImage *)imageForRSSI:(NSNumber*)RSSILevel
{
    if (nil == RSSILevel) {
        return [UIImage imageNamed:@"signal0.jpg"];
    }
    
    if (NSOrderedAscending == [RSSI_STRONG compare:RSSILevel]) {
        return [UIImage imageNamed:@"signal5.jpg"];
    }
    else if(NSOrderedAscending == [RSSI_GOOD compare:RSSILevel]){
        return [UIImage imageNamed:@"signal4.jpg"];
    }
    else if(NSOrderedAscending == [RSSI_UNSTABLE compare:RSSILevel]){
        return [UIImage imageNamed:@"signal3.jpg"];
    }
    else if(NSOrderedAscending == [RSSI_BAD compare:RSSILevel]){
        return [UIImage imageNamed:@"signal2.jpg"];
    }
    
    //else
    return [UIImage imageNamed:@"signal1.jpg"];
}

- (void)setupBTLE
{
    m_bleActor = [[BLEActor alloc]init];
    noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserver:self selector:@selector(foundDevice:) name:m_bleActor.DiscoveredEvent object:nil];
    [noteCenter addObserver:self selector:@selector(LogEvent:) name:m_bleActor.LogEvent object:nil];
}

- (void)setupTableView
{
    if ([self.btTableView respondsToSelector:@selector(separatorInset)]) {
        [self.btTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.bluetoothDevices = [NSMutableArray arrayWithCapacity:3];
}

- (void)logMessage:(NSString*)msg
{
    if (nil == msg) {
        return;
    }
    
    NSMutableDictionary * logMessage = [NSMutableDictionary dictionaryWithCapacity:1];
    [logMessage setObject:msg forKey:@"MSG"];
    [noteCenter postNotificationName:m_bleActor.LogEvent object:self userInfo:logMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToDetailView"]) {
        NSIndexPath *indexPath = [self.btTableView indexPathForSelectedRow];
        BLEDetailViewController *detailViewController = segue.destinationViewController;
        AdvertisementData * data = [[self bluetoothDevices] objectAtIndex:indexPath.row];
        detailViewController.bleDataFromParent = data; //[recipes objectAtIndex:indexPath.row];
    }
}

#pragma mark - BT Events
- (void)foundDevice:(NSNotification *)notif
{
    NSDictionary * dict = [notif userInfo];
    
    [self logMessage:[NSString stringWithFormat:@"Found device : %@",[dict objectForKey:@"LOCAL_NAME"]]];
    
    AdvertisementData * newData = [[AdvertisementData alloc]init];
    newData.Name = [dict objectForKey:@"LOCAL_NAME"];
    newData.UUID = [dict objectForKey:@"ADV_UUID"];
    newData.RSSI = [dict objectForKey:@"RSSI"];
    newData.Identifier = [dict objectForKey:@"identifier"];
    
    NSInteger index = [self.bluetoothDevices indexOfObject:newData];
    if (NSNotFound != index) {
        AdvertisementData * oldData = [self.bluetoothDevices objectAtIndex:index];
        
        [self logMessage:[NSString stringWithFormat:@"=========== old vs new RSSI : %@ , %@", oldData.RSSI.stringValue, newData.RSSI.stringValue]];
        
        if ( ![oldData.RSSI isEqualToNumber:newData.RSSI] ) {
            [self.bluetoothDevices replaceObjectAtIndex:index withObject:newData];
            
            NSIndexPath * ipath = [NSIndexPath indexPathForRow:index inSection:0]; //[NSIndexPath indexPathWithIndex:index];
            NSArray * indexs = [NSArray arrayWithObjects:ipath, nil];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [self.btTableView reloadRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationNone];
            });
        }
        
        return;
    }
    
    [self.bluetoothDevices addObject:newData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Add and update table view : %@", newData.Name);
        [self.btTableView reloadData];
    });
}

- (void)LogEvent:(NSNotification *)notif
{
    NSDictionary * dict = [notif userInfo];
    
    NSLog(@"Log message : %@", [dict objectForKey:@"MSG"]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.logView.text = [self.logView.text stringByAppendingString:@"\r\nlog something"];
        
        NSObject * obj = [dict objectForKey:@"MSG"];
        
        if (nil != obj )
        {
            if( [obj isKindOfClass:[NSString class]] )
            {
                NSString * msg = [NSString stringWithFormat:@"\r\n%@", (NSMutableString*)obj];
                self.logView.text = [self.logView.text stringByAppendingString:msg];
            }
        }
    });
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row : %d", indexPath.row );
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bluetoothDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * identifier = @"BLEScanCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSLog(@"can not get cell");
    }
    
    AdvertisementData * data = [self.bluetoothDevices objectAtIndex:indexPath.row];
    
    UILabel * cellLabel1 = (UILabel*)[cell.contentView viewWithTag:100];
    cellLabel1.text = data.Name;
    
    UILabel * cellLabel2 = (UILabel*)[cell.contentView viewWithTag:101];
    cellLabel2.text = data.UUID;
    
    UILabel * RSSILable = (UILabel*)[cell.contentView viewWithTag:103];
    RSSILable.text = data.RSSI.stringValue;
    [self logMessage:[NSString stringWithFormat:@">>>>>>>>>>>>>>>> %@ RSSI : %@", cellLabel1.text, RSSILable.text]];
    
    UIImageView * RSSIImageView = (UIImageView*)[cell.contentView viewWithTag:102];
    [RSSIImageView setImage: [self imageForRSSI:data.RSSI]];
    //[RSSIImageView setImage:[UIImage imageNamed:@"signal3.jpg"]];
    
    //-40 to -55 is a very strong connection 0 ~ -60
    //-70 and above represents a good connection  -61 ~ -70
    //-100 and below represents a bad connection   -71 ~ -90
    //-110 and below is almost unusable  -90 ~ less
    /*
    NSNumber * strongRSSI = [[NSNumber alloc] initWithInt:-60];
    NSNumber * goodRSSI = [[NSNumber alloc] initWithInt:-70];
    NSNumber * badRSSI = [[NSNumber alloc] initWithInt:-90];
    NSNumber * unusableRSSI = [[NSNumber alloc] initWithInt:-110];
    
    UIImageView * view = (UIImageView*)[cell.contentView viewWithTag:102];
    if (NSOrderedAscending == [strongRSSI compare:data.RSSI]) {
        [view setImage:[UIImage imageNamed:@"signal5.jpg"]];
    }
    else if(NSOrderedAscending == [goodRSSI compare:data.RSSI]){
        [view setImage:[UIImage imageNamed:@"signal4.jpg"]];
    }
    else if(NSOrderedAscending == [badRSSI compare:data.RSSI]){
        [view setImage:[UIImage imageNamed:@"signal3.jpg"]];
    }
    else if(NSOrderedAscending == [unusableRSSI compare:data.RSSI]){
        [view setImage:[UIImage imageNamed:@"signal2.jpg"]];
    }
    else{
        [view setImage:[UIImage imageNamed:@"signal1.jpg"]];
    }*/
    
    return cell;
}


- (IBAction)OnStartScan:(id)sender {
    NSLog(@"Enter OnStartScan()" );
    
    //clear view content
    {
        self.logView.text = @"";
        [self.bluetoothDevices removeAllObjects];
        [self.btTableView reloadData];
    }
    
    [m_bleActor StopScan];
    [m_bleActor ScanBLEDevice];
}

- (IBAction)OnStopScan:(id)sender {
    NSLog(@"Enter OnStopScan()" );
    [m_bleActor StopScan];
}


/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self bleInfo] count];
}

- (void)loadView{
    [super loadView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BLEScanCell"];
    
    BLEInfo *bleinformation = [self.bleInfo objectAtIndex:indexPath.row];// (self.bleInfo)[indexPath.row];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    nameLabel.text = bleinformation.name;
    
    UILabel *advUUID = (UILabel *)[cell viewWithTag:101];
    advUUID.text = bleinformation.advertisementUUID;
    
    UIImageView *RSSIImageView = (UIImageView *)[cell viewWithTag:102];
    [RSSIImageView setImage: [self imageForRSSI:bleinformation.RSSI]];
    
    //NSNumber * anum = bleinformation.RSSI;//[[NSNumber alloc]initWithInt:-88];
    //RSSIImageView.image = [self imageForRSSI:anum];
    //RSSIImageView.image = [self imageForRSSI:bleinformation.RSSI];
    
    UILabel *RSSILabel = (UILabel *)[cell viewWithTag:103];
    RSSILabel.text = [bleinformation.RSSI stringValue] ;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
       // [self.nameTextField becomeFirstResponder];
    }
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
