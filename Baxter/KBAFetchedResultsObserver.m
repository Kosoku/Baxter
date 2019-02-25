//
//  KBAFetchedResultsObserver.m
//  Baxter-iOS
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

#import "KBAFetchedResultsObserver.h"

#import <Stanley/Stanley.h>

@interface KBAFetchedResultsObserver () <NSFetchedResultsControllerDelegate>
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong,nonatomic) NSMutableArray<NSDictionary *> *itemChanges;

- (void)_generateKVOForFetchedObjects;
- (void)_reloadView;
@end

@implementation KBAFetchedResultsObserver
#pragma mark *** Subclass Overrides ***
#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.itemChanges = [[NSMutableArray alloc] init];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeMove:
            [self.itemChanges addObject:@{@(type): @[indexPath, newIndexPath]}];
            break;
        case NSFetchedResultsChangeDelete:
            [self.itemChanges addObject:@{@(type): @[indexPath]}];
            break;
        case NSFetchedResultsChangeInsert:
            [self.itemChanges addObject:@{@(type): @[newIndexPath]}];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.itemChanges addObject:@{@(type): @[indexPath]}];
            break;
        default:
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
#if TARGET_OS_IPHONE
    if (self.tableView != nil) {
        void(^block)(void) = ^{
            for (NSDictionary *change in self.itemChanges) {
                NSFetchedResultsChangeType type = [change.allKeys.firstObject unsignedIntegerValue];
                NSArray *indexPaths = change.allValues.firstObject;
                
                switch (type) {
                    case NSFetchedResultsChangeUpdate:
                        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    case NSFetchedResultsChangeInsert:
                        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    case NSFetchedResultsChangeMove:
                        if (![indexPaths.firstObject isEqual:indexPaths.lastObject]) {
                            [self.tableView moveRowAtIndexPath:indexPaths.firstObject toIndexPath:indexPaths.lastObject];
                        }
                        break;
                    default:
                        break;
                }
            }
        };
        
        if (@available(iOS 11.0, *)) {
            [self.tableView performBatchUpdates:block completion:nil];
        } else {
            [self.tableView beginUpdates];
            
            block();
            
            [self.tableView endUpdates];
        }
    }
    if (self.collectionView != nil) {
        [self.collectionView performBatchUpdates:^{
            for (NSDictionary *change in self.itemChanges) {
                NSFetchedResultsChangeType type = [change.allKeys.firstObject unsignedIntegerValue];
                NSArray *indexPaths = change.allValues.firstObject;
                
                switch (type) {
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
                        break;
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:indexPaths];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
                        break;
                    case NSFetchedResultsChangeMove:
                        if (![indexPaths.firstObject isEqual:indexPaths.lastObject]) {
                            [self.collectionView moveItemAtIndexPath:indexPaths.firstObject toIndexPath:indexPaths.lastObject];
                        }
                        break;
                    default:
                        break;
                }
            }
        } completion:nil];
    }
#else
    // TODO: add NS equivalents
#endif
    
    self.itemChanges = nil;
    
    [self _generateKVOForFetchedObjects];
    
    if ([self.delegate respondsToSelector:@selector(fetchedResultsObserverDidChange:)]) {
        [self.delegate fetchedResultsObserverDidChange:self];
    }
}
#pragma mark *** Public Methods ***
- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest context:(NSManagedObjectContext *)context {
    return [self initWithFetchRequest:fetchRequest context:context sectionNameKeyPath:nil cacheName:nil];
}
- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest context:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName {
    if (!(self = [super init]))
        return nil;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
    _fetchedResultsController.delegate = self;
    
    return self;
}

- (void)reloadFetchedObjects {
    [self.fetchedResultsController performFetch:NULL];
    [self _reloadView];
}

- (id<NSFetchRequestResult>)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}
- (NSIndexPath *)indexPathForObject:(id<NSFetchRequestResult>)object {
    return [self.fetchedResultsController indexPathForObject:object];
}
#pragma mark Properties
@dynamic predicate;
- (NSPredicate *)predicate {
    return self.fetchedResultsController.fetchRequest.predicate;
}
- (void)setPredicate:(NSPredicate *)predicate {
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    
    [self reloadFetchedObjects];
}
#if TARGET_OS_IPHONE
- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    
    if (_tableView != nil) {
        [self reloadFetchedObjects];
    }
}
- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    
    if (_collectionView != nil) {
        [self reloadFetchedObjects];
    }
}
#else
// TODO: add NS equivalents
#endif

- (NSArray *)fetchedObjects {
    return self.fetchedResultsController.fetchedObjects;
}
#pragma mark *** Private Methods ***
- (void)_generateKVOForFetchedObjects; {
    [self willChangeValueForKey:@kstKeypath(self,fetchedObjects)];
    [self didChangeValueForKey:@kstKeypath(self,fetchedObjects)];
}
- (void)_reloadView; {
    [self _generateKVOForFetchedObjects];
    
#if TARGET_OS_IPHONE
    if (self.tableView != nil) {
        [self.tableView reloadData];
    }
    if (self.collectionView != nil) {
        [self.collectionView reloadData];
    }
#else
    // TODO: add NS equivalents
#endif
}

@end
