//
//  KBAFetchedResultsController.h
//  Baxter
//
//  Created by William Towe on 8/27/20.
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
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KBARelationshipKeyPath is an NSObject subclass that represents a relationship key path to observe for changes.
 */
@interface KBARelationshipKeyPath : NSObject

/**
 Get the destination entity name. Given A is related to B, the destination entity name would be B.entity.name.
 */
@property (readonly,copy,nonatomic) NSString *destinationEntityName;
/**
 Get the destination property names to observe for changes. Given A is related to B, these should be names of properties on B.
 */
@property (readonly,copy,nonatomic) NSSet<NSString *> *destinationPropertyNames;
/**
 Get the inverse relationship key path. Given A is related to B, this should be relationship key path from B to A.
 */
@property (readonly,copy,nonatomic) NSString *inverseRelationshipKeyPath;

/**
 Create and return an instance of the receiver with the provided parameters.
 
 @param destinationEntityName The destination entity name
 @param destinationPropertyNames The destination property names
 @param inverseRelationshipKeyPath The inverse relationship key path
 @return The initialized instance
 */
- (instancetype)initWithDestinationEntityName:(NSString *)destinationEntityName destinationPropertyNames:(NSSet<NSString *> *)destinationPropertyNames inverseRelationshipKeyPath:(NSString *)inverseRelationshipKeyPath NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 KBAFetchedResultsController is a NSFetchedResultsController subclass that takes an additional argument in its initializer for observing relationship key paths for changes.
 */
@interface KBAFetchedResultsController<ResultType: id<NSFetchRequestResult>> : NSFetchedResultsController

/**
 Create and return an instance of the receiver with the provided parameters.
 
 @param fetchRequest The NSFetchRequest describing the primary entity to observe
 @param context The managed object context to observe
 @param sectionNameKeyPath The section name key path to use when grouping the observed entities into sections, must be non-nil if you want section info populated
 @param name The cache name to use when persisting section info to disk
 @param relationshipKeyPaths The set of KBARelationshipKeyPath objects representing relationship key paths to observe for changes
 @return The initialized instance
 */
- (instancetype)initWithFetchRequest:(NSFetchRequest<ResultType> *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath cacheName:(nullable NSString *)name relationshipKeyPaths:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFetchRequest:(NSFetchRequest<ResultType> *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath cacheName:(nullable NSString *)name NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
