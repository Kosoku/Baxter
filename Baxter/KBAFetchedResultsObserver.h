//
//  KBAFetchedResultsObserver.h
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

#import <TargetConditionals.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif
#import <CoreData/NSFetchedResultsController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KBAFetchedResultsObserverDelegate;

/**
 KBAFetchedResultsObserver is an NSObject subclass that wraps an instance of NSFetchedResultsController and handles updating  a view instance in response to its changes.
 */
@interface KBAFetchedResultsObserver<ResultType: id<NSFetchRequestResult>> : NSObject

/**
 Set and get the delegate of the receiver.
 
 @see KBAFetchedResultsObserverDelegate
 */
@property (weak,nonatomic,nullable) id<KBAFetchedResultsObserverDelegate> delegate;

/**
 Set and get the predicate of the original fetch request that was passed in during initialization. Setting this to a new value will reload the fetched objects.
 */
@property (strong,nonatomic,nullable) NSPredicate *predicate;
/**
 Set and get the table view instance the receiver should manage.
 */
@property (weak,nonatomic,nullable) UITableView *tableView;
/**
 Set and get the collection view instance the receiver should manage.
 */
@property (weak,nonatomic,nullable) UICollectionView *collectionView;

/**
 Get the fetched objects from the underlying fetched results controller.
 */
@property (readonly,nonatomic,nullable) NSArray<ResultType> *fetchedObjects;
/**
 Get the fetched sections from the underlying fetched results controller.
 */
@property (readonly,nonatomic,nullable) NSArray<id<NSFetchedResultsSectionInfo>> *fetchedSections;


/**
 Calls through to `initWithFetchRequest:context:sectionNameKeyPath:cacheName:`, passing nil for sectionNameKeyPath and cacheName.
 */
- (instancetype)initWithFetchRequest:(NSFetchRequest<ResultType> *)fetchRequest context:(NSManagedObjectContext *)context;
/**
 Creates and returns an initialized instance with the provided parameters.
 
 @param fetchRequest The fetch request to use when fetching objects from the context
 @param context The context from which to fetch objects
 @param sectionNameKeyPath The key path to use in order to group objects into sections
 @param cacheName The name to use when caching objects
 @return The initialized instance
 */
- (instancetype)initWithFetchRequest:(NSFetchRequest<ResultType> *)fetchRequest context:(NSManagedObjectContext *)context sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath cacheName:(nullable NSString *)cacheName NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Reload the fetched objects and any views being managed by the receiver.
 */
- (void)reloadFetchedObjects;

/**
 Returns the fetched object at the provided indexPath.
 
 @param indexPath The index path at which to fetch an object
 @return The fetched object
 */
- (ResultType)objectAtIndexPath:(NSIndexPath *)indexPath;
/**
 Returns the index path for the fetched object, or nil if no such index path exists.
 
 @param object The fetched object
 @return The corresponding index path or nil
 */
- (nullable NSIndexPath *)indexPathForObject:(ResultType)object;

@end

/**
 Protocol describing a change object.
 */
@protocol KBAFetchedResultsObserverChange <NSObject>
@required
/**
 The managed object that was changed.
 */
@property (readonly,nonatomic) __kindof NSManagedObject *changeObject;
/**
 The type of change.
 */
@property (readonly,nonatomic) NSFetchedResultsChangeType changeType;
/**
 The index path of the changed object. Will be nil for deletes.
 */
@property (readonly,nonatomic,nullable) NSIndexPath *changeIndexPath;
/**
 The new index path for the changed object. Will be non-nil only for moves.
 */
@property (readonly,nonatomic,nullable) NSIndexPath *changeNewIndexPath;
@end

@protocol KBAFetchedResultsObserverDelegate <NSObject>
@optional
/**
 Called before the fetched results observer updates its content. Corresponds to the `controllerWillChangeContent:` NSFetchedResultsControllerDelegate method.
 
 @param observer The sender of the message
 */
- (void)fetchedResultsObserverWillChange:(KBAFetchedResultsObserver *)observer;
/**
 Called after the fetched results observer updates its content. Corresponds to the `controllerDidChangeContent:` NSFetchedResultsControllerDelegate method.
 
 @param observer The sender of the message
 */
- (void)fetchedResultsObserverDidChange:(KBAFetchedResultsObserver *)observer;
/**
 Called after the fetched results observer updates its content, provides a an array of objects conforming to KBAFetchedResultsObserverChange protocol that describe each individual change.
 
 This method is preferred over fetchedResultsObserverDidChange: and will be called instead of fetchedResultsObserverDidChange: if the delegate implements both.
 
 @param observer The sender of the message
 @param changes The array of change objects
 */
- (void)fetchedResultsObserver:(KBAFetchedResultsObserver *)observer didObserveChanges:(NSArray<id<KBAFetchedResultsObserverChange>> *)changes;
@end

NS_ASSUME_NONNULL_END
