//
//  NSManagedObjectContext+KBAExtensions.h
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

#import <Baxter/NSFetchRequest+KBAExtensions.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Typedef for a block used when performing asynchronous fetches.
 
 @param objects The managed objects
 @param error If the fetch could not be completed, an error containing more information
 */
typedef void(^KBACoreDataCompletionBlock)(NSArray<__kindof NSManagedObject *> *objects, NSError *_Nullable error);

@interface NSManagedObjectContext (KBAExtensions)

/**
 Recursively saves the receiver and its `parentContext`.
 
 This is a blocking call.
 
 @param error On failure, the `NSError` object explaining the reason for failure
 @return YES if the save was successful, otherwise NO
 */
- (BOOL)KBA_saveRecursively:(NSError *__autoreleasing *)error;

/**
 Calls KBA_fetchEntityNamed:predicate:sortDescriptors:limit:offset:error:, passing _entityName_, _predicate_, _sortDescriptors_, and _error_ respectively.
 
 @param entityName The name of the entity of fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors An array of sort descriptors to apply to the resulting set of objects
 @param error On failure, the NSError object explaining the reason for failure
 @return The resulting set of NSManagedObject instances
 @exception NSException Thrown if _entityName_ is nil
 */
- (nullable NSArray<__kindof NSManagedObject *> *)KBA_fetchEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors error:(NSError *__autoreleasing *)error;
/**
 Calls KBA_fetchEntityNamed:predicate:sortDescriptors:limit:offset:error:, passing _entityName_, _predicate_, _sortDescriptors_, _limit_, and _error_ respectively.
 
 @param entityName The name of the entity of fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors An array of sort descriptors to apply to the resulting set of objects
 @param limit If _limit_ > 0, constrain the resulting set of objects to _limit_ count
 @param error On failure, the NSError object explaining the reason for failure
 @return The resulting set of NSManagedObject instances
 @exception NSException Thrown if _entityName_ is nil
 */
- (nullable NSArray<__kindof NSManagedObject *> *)KBA_fetchEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit error:(NSError *__autoreleasing *)error;
/**
 Constructs and executes a NSFetchRequest using _entityName_, _predicate_, _sortDescriptors_, _limit_, _offset_, and _error_.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors An array of sort descriptors to apply to the resulting set of objects
 @param limit If _limit_ > 0, constrain the resulting set of objects to _limit_ count
 @param offset If _offset_ > 0, start fetching the resulting set of objects from index _offset_
 @param error On failure, the NSError object explaining the reason for failure
 @return The resulting set of NSManagedObject instances
 @exception NSException Thrown if _entityName_ is nil
 */
- (nullable NSArray<__kindof NSManagedObject *> *)KBA_fetchEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset error:(NSError *__autoreleasing *)error;

/**
 Calls `KBA_fetchEntityNamed:predicate:sortDescriptors:limit:offset:completion:`, passing `entityName`, `predicate`, `sortDescriptors`, 0, 0, and `completion` respectively.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors The sort descriptors to apply to the resulting set of objects
 @param completion The completion block that is invoked when the operation is complete, objects contains NSManagedObject instance, if nil, error contains information about the reason for failure
 @exception NSException Thrown if entityName or completion are nil
 */
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors completion:(KBACoreDataCompletionBlock)completion;
/**
 Calls `KBA_fetchEntityNamed:predicate:sortDescriptors:limit:offset:completion:`, passing `entityName`, `predicate`, `sortDescriptors`, `limit`, 0, and `completion` respectively.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors The sort descriptors to apply to the resulting set of objects
 @param limit The fetch limit to apply to the fetch request
 @param completion The completion block that is invoked when the operation is complete, objects contains NSManagedObject instance, if nil, error contains information about the reason for failure
 @exception NSException Thrown if entityName or completion are nil
 */
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit completion:(KBACoreDataCompletionBlock)completion;
/**
 Performs an asynchronous fetch request, using NSAsynchronousFetchRequest if it is available. Falls back to fetching object IDs and converting them to managed objects on the calling thread.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors The sort descriptors to apply to the resulting set of objects
 @param limit The fetch limit to apply to the fetch request
 @param offset The fetch offset to apply to the fetch request
 @param completion The completion block that is invoked when the operation is complete, objects contains NSManagedObject instance, if nil, error contains information about the reason for failure
 @exception NSException Thrown if entityName or completion are nil
 */
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset completion:(KBACoreDataCompletionBlock)completion;

/**
 Constructs and executes a NSFetchRequest using _entityName_, _predicate_, and _error_.
 
 The result type is set to NSCountResultType.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param error On failure, the NSError object explaining the reason for failure
 @return The number of objects in the result set
 @exception NSException Thrown if _entityName_ is nil
 */
- (NSUInteger)KBA_countForEntityNamed:(NSString *)entityName predicate:(nullable NSPredicate *)predicate error:(NSError *__autoreleasing *)error;

/**
 Constructs and executes a NSFetchRequest using _entityName_, _predicate_, _sortDescriptors_, and _error_.
 
 The result type is set to NSDictionaryResultType and _properties_ are used for `propertiesToFetch`.
 
 @param entityName The name of the entity to fetch
 @param properties The properties to fetch
 @param predicate The predicate that will constrain the resulting set of objects
 @param sortDescriptors An array of sort descriptors to apply to the resulting set of objects
 @param error On failure, the NSError object explaining the reason for failure
 @return The resulting set of NSManagedObject instances
 @exception NSException Thrown if _entityName_ or _properties_ are nil
 */
- (NSArray<NSDictionary<NSString *, id> *> *)KBA_fetchPropertiesForEntityNamed:(NSString *)entityName properties:(NSArray *)properties predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors error:(NSError *__autoreleasing *)error;

/**
 Creates and executes a NSFetchRequest with the provided *options*.
 
 @param options The options to use when creating the fetch request
 @return The result of executing the fetch request
 */
- (NSArray *)KBA_fetchWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey, id> *)options;
/**
 Creates and executes a NSFetchRequest with the provided *options* and *error*.
 
 @param options The options to use when creating the fetch request
 @param error The error that resulted from executing the fetch request
 @return The result of executing the fetch request
 */
- (NSArray *)KBA_fetchWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey, id> *)options error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
