//
//  NSFetchRequest+KBAExtensions.h
//  Baxter
//
//  Created by William Towe on 3/17/17.
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

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Typedef for fetch request options key that should be used with KBA_fetchRequestWithOptions:.
 */
typedef NSString* KBANSFetchRequestOptionsKey NS_STRING_ENUM;

/**
 The entity name. This should be an NSString.
 
 @see [NSFetchRequest entityName]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyEntityName;
/**
 Whether to include subentities. This should be a NSNumber wrapping a BOOL value.
 
 @see [NSFetchRequest includesSubentities]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyIncludesSubentities;
/**
 The NSPredicate to filter the fetch request.
 
 @see [NSFetchRequest predicate]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyPredicate;
/**
 The fetch limit. This should be a NSNumber wrapping an unsigned integer.
 
 @see [NSFetchRequest fetchLimit]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyFetchLimit;
/**
 The fetch offset. This should be a NSNumber wrapping an unsigned integer.
 
 @see [NSFetchRequest fetchOffset]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyFetchOffset;
/**
 The fetch batch size. This should be a NSNumber wrapping an unsigned integer.
 
 @see [NSFetchRequest fetchBatchSize]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyFetchBatchSize;
/**
 The NSArray of NSSortDescriptor instances for the fetch request.
 
 @see [NSFetchRequest sortDescriptors]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeySortDescriptors;
/**
 The NSArray of NSString instances used for relationship prefetching.
 
 @see [NSFetchRequest relationshipKeyPathsForPrefetching]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyRelationshipKeyPathsForPrefetching;
/**
 The result type of the fetch request. This should be a NSNumber wrapping a NSFetchRequestResultType value.
 
 @see [NSFetchRequest resultType]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyResultType;
/**
 Whether to include pending changes. This should be a NSNumber wrapping a BOOL value.
 
 @see [NSFetchRequest includesPendingChanges]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyIncludesPendingChanges;
/**
 The NSArray of NSString instances for the properties to fetch.
 
 @see [NSFetchRequest propertiesToFetch]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyPropertiesToFetch;
/**
 Whether to return distinct results. This should be a NSNumber wrapping a BOOL value.
 
 @see [NSFetchRequest returnsDistinctResults]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyReturnsDistinctResults;
/**
 Whether to include property values. This should be a NSNumber wrapping a BOOL value.
 
 @see [NSFetchRequest includesPropertyValues]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyIncludesPropertyValues;
/**
 Whether to refresh refetched objects. This should be a NSNumber wrapping a BOOL value.
 
 @see [NSFetchRequest shouldRefreshRefetchedObjects]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyShouldRefreshRefetchedObjects;
/**
 Whether to return objects as faults. This should be a NSNumber wrapping a BOOL value.
 
 @see [NSFetchRequest returnsObjectsAsFaults]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyReturnsObjectsAsFaults;
/**
 The NSArray of NSString instances for the properties to group by.
 
 @see [NSFetchRequest propertiesToGroupBy]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyPropertiesToGroupBy;
/**
 The having NSPredicate.
 
 @see [NSFetchRequest havingPredicate]
 */
FOUNDATION_EXTERN KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyHavingPredicate;

@interface NSFetchRequest (KBAExtensions)

/**
 Create and return a NSFetchRequest with the provided parameters. Calls through to KBA_fetchRequestWithOptions: with the appropriate options dictionary.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate to apply to the fetch request
 @param sortDescriptors The sort descriptors to apply to the fetch request
 @param limit The fetch limit to apply to the fetch request
 @param offset The fetch offset to apply to the fetch request
 @return The fetch request
 */
+ (instancetype)KBA_fetchRequestForEntityName:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset;
/**
 Create and return a fetch request with the provided options.
 
 @param options The dictionary of options to use when creating the fetch request
 @return The fetch request
 */
+ (instancetype)KBA_fetchRequestWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey, id> *)options;

@end

NS_ASSUME_NONNULL_END
