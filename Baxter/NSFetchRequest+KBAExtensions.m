//
//  NSFetchRequest+KBAExtensions.m
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

#import "NSFetchRequest+KBAExtensions.h"

KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyEntityName = @"KBANSFetchRequestOptionsKeyEntityName";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyIncludesSubentities = @"KBANSFetchRequestOptionsKeyIncludesSubentities";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyPredicate = @"KBANSFetchRequestOptionsKeyPredicate";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyFetchLimit = @"KBANSFetchRequestOptionsKeyFetchLimit";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyFetchOffset = @"KBANSFetchRequestOptionsKeyFetchOffset";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyFetchBatchSize = @"KBANSFetchRequestOptionsKeyFetchBatchSize";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeySortDescriptors = @"KBANSFetchRequestOptionsKeySortDescriptors";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyRelationshipKeyPathsForPrefetching = @"KBANSFetchRequestOptionsKeyRelationshipKeyPathsForPrefetching";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyResultType = @"KBANSFetchRequestOptionsKeyResultType";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyIncludesPendingChanges = @"KBANSFetchRequestOptionsKeyIncludesPendingChanges";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyPropertiesToFetch = @"KBANSFetchRequestOptionsKeyPropertiesToFetch";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyReturnsDistinctResults = @"KBANSFetchRequestOptionsKeyReturnsDistinctResults";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyIncludesPropertyValues = @"KBANSFetchRequestOptionsKeyIncludesPropertyValues";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyShouldRefreshRefetchedObjects = @"KBANSFetchRequestOptionsKeyShouldRefreshRefetchedObjects";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyReturnsObjectsAsFaults = @"KBANSFetchRequestOptionsKeyReturnsObjectsAsFaults";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyPropertiesToGroupBy = @"KBANSFetchRequestOptionsKeyPropertiesToGroupBy";
KBANSFetchRequestOptionsKey const KBANSFetchRequestOptionsKeyHavingPredicate = @"KBANSFetchRequestOptionsKeyHavingPredicate";

@implementation NSFetchRequest (KBAExtensions)

+ (instancetype)KBA_fetchRequestForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset; {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{KBANSFetchRequestOptionsKeyEntityName: entityName}];
    
    if (predicate != nil) {
        options[KBANSFetchRequestOptionsKeyPredicate] = predicate;
    }
    if (sortDescriptors != nil) {
        options[KBANSFetchRequestOptionsKeySortDescriptors] = sortDescriptors;
    }
    if (limit > 0) {
        options[KBANSFetchRequestOptionsKeyFetchLimit] = @(limit);
    }
    if (offset > 0) {
        options[KBANSFetchRequestOptionsKeyFetchOffset] = @(offset);
    }
    
    return [self KBA_fetchRequestWithOptions:options];
}
+ (instancetype)KBA_fetchRequestWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey,id> *)options {
    NSParameterAssert(options[KBANSFetchRequestOptionsKeyEntityName] != nil);
    
    NSFetchRequest *retval = [[[self class] alloc] initWithEntityName:options[KBANSFetchRequestOptionsKeyEntityName]];
    
    if (options[KBANSFetchRequestOptionsKeyIncludesSubentities] != nil) {
        retval.includesSubentities = [options[KBANSFetchRequestOptionsKeyIncludesSubentities] boolValue];
    }
    if (options[KBANSFetchRequestOptionsKeyPredicate] != nil) {
        retval.predicate = options[KBANSFetchRequestOptionsKeyPredicate];
    }
    if (options[KBANSFetchRequestOptionsKeyFetchLimit] != nil) {
        retval.fetchLimit = [options[KBANSFetchRequestOptionsKeyFetchLimit] unsignedIntegerValue];
    }
    if (options[KBANSFetchRequestOptionsKeyFetchOffset] != nil) {
        retval.fetchOffset = [options[KBANSFetchRequestOptionsKeyFetchOffset] unsignedIntegerValue];
    }
    if (options[KBANSFetchRequestOptionsKeyFetchBatchSize] != nil) {
        retval.fetchBatchSize = [options[KBANSFetchRequestOptionsKeyFetchBatchSize] unsignedIntegerValue];
    }
    if (options[KBANSFetchRequestOptionsKeySortDescriptors] != nil) {
        retval.sortDescriptors = options[KBANSFetchRequestOptionsKeySortDescriptors];
    }
    if (options[KBANSFetchRequestOptionsKeyRelationshipKeyPathsForPrefetching] != nil) {
        retval.relationshipKeyPathsForPrefetching = options[KBANSFetchRequestOptionsKeyRelationshipKeyPathsForPrefetching];
    }
    if (options[KBANSFetchRequestOptionsKeyResultType] != nil) {
        retval.resultType = [options[KBANSFetchRequestOptionsKeyResultType] unsignedIntegerValue];
    }
    if (options[KBANSFetchRequestOptionsKeyIncludesPendingChanges] != nil) {
        retval.includesPendingChanges = [options[KBANSFetchRequestOptionsKeyIncludesPendingChanges] boolValue];
    }
    if (options[KBANSFetchRequestOptionsKeyPropertiesToFetch] != nil) {
        retval.propertiesToFetch = options[KBANSFetchRequestOptionsKeyPropertiesToFetch];
    }
    if (options[KBANSFetchRequestOptionsKeyReturnsDistinctResults] != nil) {
        retval.returnsDistinctResults = [options[KBANSFetchRequestOptionsKeyReturnsDistinctResults] boolValue];
    }
    if (options[KBANSFetchRequestOptionsKeyIncludesPropertyValues] != nil) {
        retval.includesPropertyValues = [options[KBANSFetchRequestOptionsKeyIncludesPropertyValues] boolValue];
    }
    if (options[KBANSFetchRequestOptionsKeyShouldRefreshRefetchedObjects] != nil) {
        retval.shouldRefreshRefetchedObjects = [options[KBANSFetchRequestOptionsKeyShouldRefreshRefetchedObjects] boolValue];
    }
    if (options[KBANSFetchRequestOptionsKeyReturnsObjectsAsFaults] != nil) {
        retval.returnsObjectsAsFaults = [options[KBANSFetchRequestOptionsKeyReturnsObjectsAsFaults] boolValue];
    }
    if (options[KBANSFetchRequestOptionsKeyPropertiesToGroupBy] != nil) {
        retval.propertiesToGroupBy = options[KBANSFetchRequestOptionsKeyPropertiesToGroupBy];
    }
    if (options[KBANSFetchRequestOptionsKeyHavingPredicate] != nil) {
        retval.havingPredicate = options[KBANSFetchRequestOptionsKeyHavingPredicate];
    }
    
    return retval;
}

@end
