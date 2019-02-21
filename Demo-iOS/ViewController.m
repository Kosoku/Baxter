//
//  ViewController.m
//  Demo-iOS
//
//  Created by William Towe on 2/20/19.
//  Copyright © 2019 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "ViewController.h"
#import "Row.h"

#import <Baxter/Baxter.h>
#import <Stanley/Stanley.h>

@interface ViewController ()
@property (strong,nonatomic) KBAFetchedResultsObserver *fetchedResultsObserver;

@property (strong,nonatomic) NSPersistentContainer *persistentContainer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Baxter";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(_addItemAction:)];
    
    self.navigationItem.rightBarButtonItems = @[addItem, self.editButtonItem];
    
    self.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Model"];
    
    NSPersistentStoreDescription *desc = [[NSPersistentStoreDescription alloc] initWithURL:[NSFileManager.defaultManager.KST_applicationSupportDirectoryURL URLByAppendingPathComponent:@"Model.sqlite"]];
    
    desc.type = NSInMemoryStoreType;
    desc.shouldAddStoreAsynchronously = NO;
    desc.shouldMigrateStoreAutomatically = YES;
    desc.shouldInferMappingModelAutomatically = YES;
    
    self.persistentContainer.persistentStoreDescriptions = @[desc];
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull psd, NSError * _Nullable error) {
        KSTLog(@"%@ %@",psd,error);
    }];
    
    self.tableView.estimatedRowHeight = 44.0;
    
    self.fetchedResultsObserver = [[KBAFetchedResultsObserver alloc] initWithFetchRequest:Row.fetchRequestForRowsSortedByCreatedAt context:self.persistentContainer.viewContext];
    self.fetchedResultsObserver.tableView = self.tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsObserver.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *retval = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    
    if (retval == nil) {
        retval = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
    
    Row *entity = [self.fetchedResultsObserver objectAtIndexPath:indexPath];
    
    retval.textLabel.numberOfLines = 0;
    retval.textLabel.text = entity.title;
    retval.detailTextLabel.numberOfLines = 0;
    retval.detailTextLabel.text = entity.summary;
    
    return retval;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Row *entity = [self.fetchedResultsObserver objectAtIndexPath:indexPath];
        
        [entity.managedObjectContext deleteObject:entity];
    }
}

- (IBAction)_addItemAction:(id)sender {
    [Row insertInManagedObjectContext:self.persistentContainer.viewContext];
}

@end
