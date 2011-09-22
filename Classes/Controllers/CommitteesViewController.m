//
//  CommitteesViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteesViewController.h"
#import "CommitteeDetailViewController.h"
#import "SLFDataModels.h"

@implementation CommitteesViewController
@synthesize state;
@synthesize tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.state = newState;
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     SUNLIGHT_APIKEY,@"apikey", 
                                     newState.stateID,@"state", nil];
        self.resourcePath = RKMakePathWithObject(@"/committees?state=:state&apikey=:apikey", queryParams);
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.title = @"Loading...";
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.resourcePath = self.resourcePath;
    [self.tableViewModel setObjectMappingForClass:[SLFCommittee class]]; 
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.autoRefreshRate = 360;
    self.tableViewModel.pullToRefreshEnabled = YES;
    
    RKTableViewCellMapping *objCellMap = [RKTableViewCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        cellMapping.style = UITableViewCellStyleSubtitle;
        cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cellMapping mapKeyPath:@"committeeName" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"chamberShortName" toAttribute:@"detailTextLabel.text"];
        
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFCommittee *committee = object;
            CommitteeDetailViewController *vc = [[CommitteeDetailViewController alloc] initWithCommitteeID:committee.committeeID];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFCommittee class] toTableCellsWithMapping:objCellMap];    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]] autorelease];
	imageView.frame = CGRectOffset(imageView.frame, 0, -32.f);
    [self.view insertSubview:imageView belowSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableViewModel loadTable];
    self.title = [NSString stringWithFormat:@"%d %@ Committees",[[self.tableViewModel.fetchedResultsController fetchedObjects] count], self.state.name];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d %@ Committees",[[self.tableViewModel.fetchedResultsController fetchedObjects] count], self.state.name];
}

- (void)tableViewModel:(RKAbstractTableViewModel*)tableViewModel didFailLoadWithError:(NSError*)error {
    self.title = @"Load Error";
    RKLogError(@"Error loading table from resource path: %@", self.tableViewModel.resourcePath);
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

@end