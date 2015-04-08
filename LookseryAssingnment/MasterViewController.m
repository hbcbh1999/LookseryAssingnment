//
//  MasterViewController.m
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import "MasterViewController.h"
#import "PersonViewController.h"
#import "Person.h"
#import "PersonsDatabase.h"

NSString *kNameNotSet = @"Имя не указано";

@interface MasterViewController () <PersonViewControllerDelegate> {
    PersonsDatabase *database;
}
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    database = [PersonsDatabase singleton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *n = (UINavigationController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"NavigationControllerWithPersonViewController"];
    PersonViewController *personViewController = (PersonViewController*)n.topViewController;
    personViewController.personViewControllerDelegate = self;
    [self presentViewController:n animated:YES completion:NULL];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Person *person = [database personWithOffset:indexPath.row];
        PersonViewController *controller = (PersonViewController *)[segue destinationViewController];
        [controller setPerson:person];
        controller.personViewControllerDelegate = self;
        [controller addEditButtonAndRemoveCancelButton];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [database personsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Person *person = [database personWithOffset:indexPath.row];
    NSString *trimmed_name = [person.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cell.textLabel.text = trimmed_name==nil || [trimmed_name isEqualToString:@""] ? kNameNotSet : person.name;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [database removePersonWithOffset:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    }
}

#pragma mark - PersonlViewControllerDelegate

- (void)personViewController:(PersonViewController*)personViewController updatePerson:(Person*)person {
    [database updatePerson:person];
    [self.tableView reloadData];
}

- (void)personViewController:(PersonViewController*)personViewController addPerson:(Person*)person {
    [database addPerson:person];
    [self.tableView reloadData];
}

@end
