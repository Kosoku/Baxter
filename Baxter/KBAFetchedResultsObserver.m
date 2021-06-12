//
//  KBAFetchedResultsObserver.m
//  Baxter-iOS
//
//  Created by William Towe on 2/20/19.
//  Copyright © 2021 Kosoku Interactive, LLC. All rights reserved.
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

@interface KBAFetchedResultsObserverChangeImpl : NSObject <KBAFetchedResultsObserverChange>
@property (strong,nonatomic) __kindof NSManagedObject *changeObject;
@property (assign,nonatomic) NSFetchedResultsChangeType changeType;
@property (strong,nonatomic) NSIndexPath *changeIndexPath;
@property (strong,nonatomic) NSIndexPath *changeNewIndexPath;

- (instancetype)initWithObject:(__kindof NSManagedObject *)object type:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

@implementation KBAFetchedResultsObserverChangeImpl

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> object=%@ type=%@ indexPath=%@ newIndexPath=%@", NSStringFromClass(self.class), self, self.changeObject, @(self.changeType), self.changeIndexPath, self.changeNewIndexPath];
}

- (instancetype)initWithObject:(__kindof NSManagedObject *)object type:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath {
    if (!(self = [super init]))
        return nil;
    
    _changeObject = object;
    _changeType = type;
    _changeIndexPath = indexPath;
    _changeNewIndexPath = newIndexPath;
    
    return self;
}

@end

@interface KBAFetchedResultsObserver () <NSFetchedResultsControllerDelegate>
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong,nonatomic) NSMutableArray<NSDictionary *> *itemChanges;
@property (strong,nonatomic) NSMutableArray<KBAFetchedResultsObserverChangeImpl *> *changeImpls;

- (void)_generateKVOForFetchedObjects;
- (void)_reloadView;
@end

@implementation KBAFetchedResultsObserver
#pragma mark *** Subclass Overrides ***
#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.itemChanges = [[NSMutableArray alloc] init];
    
    if ([self.delegate respondsToSelector:@selector(fetchedResultsObserverWillChange:)]) {
        [self.delegate fetchedResultsObserverWillChange:self];
    }
    if ([self.delegate respondsToSelector:@selector(fetchedResultsObserver:didObserveChanges:)]) {
        self.changeImpls = [[NSMutableArray alloc] init];
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (self.changeImpls != nil) {
        [self.changeImpls addObject:[[KBAFetchedResultsObserverChangeImpl alloc] initWithObject:anObject type:type indexPath:indexPath newIndexPath:newIndexPath]];
    }
    
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            [self.itemChanges addObject:@{@(type): @[indexPath]}];
            break;
        case NSFetchedResultsChangeInsert:
            [self.itemChanges addObject:@{@(type): @[newIndexPath]}];
            break;
        case NSFetchedResultsChangeDelete:
            [self.itemChanges addObject:@{@(type): @[indexPath]}];
            break;
        case NSFetchedResultsChangeMove:
            [self.itemChanges addObject:@{@(type): @[indexPath, newIndexPath]}];
            break;
        default:
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    void(^block)(UIView *) = ^(UIView *view){
#if TARGET_OS_IPHONE
        UITableView *tableView = [view isKindOfClass:UITableView.class] ? (UITableView *)view : nil;
        UICollectionView *collectionView = [view isKindOfClass:UICollectionView.class] ? (UICollectionView *)view : nil;
#endif
        
        for (NSDictionary *change in self.itemChanges) {
            NSFetchedResultsChangeType type = [change.allKeys.firstObject unsignedIntegerValue];
            NSArray *indexPaths = change.allValues.firstObject;
            
            switch (type) {
                case NSFetchedResultsChangeUpdate:
#if TARGET_OS_IPHONE
                    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [collectionView reloadItemsAtIndexPaths:indexPaths];
#endif
                    break;
                case NSFetchedResultsChangeInsert:
#if TARGET_OS_IPHONE
                    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [collectionView insertItemsAtIndexPaths:indexPaths];
#endif
                    break;
                case NSFetchedResultsChangeDelete:
#if TARGET_OS_IPHONE
                    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [collectionView deleteItemsAtIndexPaths:indexPaths];
#endif
                    break;
                case NSFetchedResultsChangeMove:
#if TARGET_OS_IPHONE
                    if (![indexPaths.firstObject isEqual:indexPaths.lastObject]) {
                        [tableView moveRowAtIndexPath:indexPaths.firstObject toIndexPath:indexPaths.lastObject];
                        [collectionView moveItemAtIndexPath:indexPaths.firstObject toIndexPath:indexPaths.lastObject];
                    }
#endif
                    break;
                default:
                    break;
            }
        }
    };
    void(^completion)(UIView *) = ^(UIView *view){
#if TARGET_OS_IPHONE
        UITableView *tableView = [view isKindOfClass:UITableView.class] ? (UITableView *)view : nil;
        UICollectionView *collectionView = [view isKindOfClass:UICollectionView.class] ? (UICollectionView *)view : nil;
#endif
        
        for (NSDictionary *change in self.itemChanges) {
            NSFetchedResultsChangeType type = [change.allKeys.firstObject unsignedIntegerValue];
            NSArray *indexPaths = change.allValues.firstObject;
            
            switch (type) {
                case NSFetchedResultsChangeMove:
#if TARGET_OS_IPHONE
                    if (![indexPaths.firstObject isEqual:indexPaths.lastObject]) {
                        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        [collectionView reloadItemsAtIndexPaths:indexPaths];
                    }
#endif
                    break;
                default:
                    break;
            }
        }
    };
#if TARGET_OS_IPHONE
    if (self.tableView != nil) {
        if (@available(iOS 11.0, *)) {
            [self.tableView performBatchUpdates:^{
                block(self.tableView);
            } completion:^(BOOL finished) {
                completion(self.tableView);
                
                self.itemChanges = nil;
            }];
        } else {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                completion(self.tableView);
                
                self.itemChanges = nil;
            }];
            
            [self.tableView beginUpdates];
            
            block(self.tableView);
            
            [self.tableView endUpdates];
            
            [CATransaction commit];
        }
    }
    if (self.collectionView != nil) {
        [self.collectionView performBatchUpdates:^{
            block(self.collectionView);
        } completion:^(BOOL finished) {
            completion(self.collectionView);
            
            self.itemChanges = nil;
        }];
    }
#else
    // TODO: add NS equivalents
#endif
    [self _generateKVOForFetchedObjects];
    
    if ([self.delegate respondsToSelector:@selector(fetchedResultsObserver:didObserveChanges:)]) {
        [self.delegate fetchedResultsObserver:self didObserveChanges:self.changeImpls];
        
        self.changeImpls = nil;
    }
    else if ([self.delegate respondsToSelector:@selector(fetchedResultsObserverDidChange:)]) {
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

- (NSArray<id<NSFetchedResultsSectionInfo>> *)fetchedSections {
    return self.fetchedResultsController.sections;
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
