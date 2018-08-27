//
//  NSFetchRequest+KBAExtensions.m
//  Baxter
//
//  Created by William Towe on 3/17/17.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

+ (NSFetchRequest *)KBA_fetchRequestForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset; {
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
+ (NSFetchRequest *)KBA_fetchRequestWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey,id> *)options {
    NSParameterAssert(options[KBANSFetchRequestOptionsKeyEntityName] != nil);
    
    NSFetchRequest *retval = [[NSFetchRequest alloc] initWithEntityName:options[KBANSFetchRequestOptionsKeyEntityName]];
    
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
