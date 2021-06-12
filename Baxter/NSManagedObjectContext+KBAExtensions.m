//
//  NSManagedObjectContext+KBAExtensions.m
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

#import "NSManagedObjectContext+KBAExtensions.h"

#import <Stanley/KSTScopeMacros.h>

@implementation NSManagedObjectContext (KBAExtensions)

- (BOOL)KBA_saveRecursively:(NSError *__autoreleasing *)error; {
    __block BOOL retval = YES;
    __block NSError *blockError = nil;
    
    if (self.hasChanges) {
        kstWeakify(self);
        [self performBlockAndWait:^{
            kstStrongify(self);
            
            NSError *outError;
            if ([self save:&outError]) {
                NSManagedObjectContext *parentContext = self.parentContext;
                
                while (parentContext) {
                    [parentContext performBlockAndWait:^{
                        [parentContext save:NULL];
                    }];
                    
                    parentContext = parentContext.parentContext;
                }
            }
            else {
                retval = NO;
                blockError = outError;
            }
        }];
        
        if (error) {
            *error = blockError;
        }
    }
    
    return retval;
}

- (NSArray *)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError *__autoreleasing *)error; {
    return [self KBA_fetchEntityNamed:entityName predicate:predicate sortDescriptors:sortDescriptors limit:0 offset:0 error:error];
}
- (NSArray *)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit error:(NSError *__autoreleasing *)error; {
    return [self KBA_fetchEntityNamed:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:0 error:error];
}
- (NSArray *)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset error:(NSError *__autoreleasing *)error; {
    NSFetchRequest *request = [NSFetchRequest KBA_fetchRequestForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
    
    return [self executeFetchRequest:request error:error];
}

- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors completion:(void(^)(NSArray<__kindof NSManagedObject *> *objects, NSError *error))completion; {
    [self KBA_fetchEntityNamed:entityName predicate:predicate sortDescriptors:sortDescriptors limit:0 offset:0 completion:completion];
}
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit completion:(void(^)(NSArray<__kindof NSManagedObject *> *objects, NSError *error))completion; {
    [self KBA_fetchEntityNamed:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:0 completion:completion];
}
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset completion:(void(^)(NSArray<__kindof NSManagedObject *> *objects, NSError *error))completion; {
    NSParameterAssert(completion);
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    if (NSClassFromString(@"NSAsynchronousFetchRequest")) {
        kstWeakify(self);
        NSFetchRequest *request = [NSFetchRequest KBA_fetchRequestForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
        NSAsynchronousFetchRequest *asyncFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:request completionBlock:^(NSAsynchronousFetchResult *result) {
            kstStrongify(self);
            [self performBlock:^{
                completion(result.finalResult,nil);
            }];
        }];
        
        [self performBlock:^{
            kstStrongify(self);
            NSError *outError;
            NSAsynchronousFetchResult *result = (NSAsynchronousFetchResult *)[self executeRequest:asyncFetchRequest error:&outError];
            
            if (!result) {
                completion(nil,outError);
            }
        }];
    }
    else {
        kstWeakify(self);
        [context setUndoManager:nil];
        [context setParentContext:self];
        [context performBlock:^{
            kstStrongify(self);
            NSFetchRequest *request = [NSFetchRequest KBA_fetchRequestForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:offset];
            
            [request setResultType:NSManagedObjectIDResultType];
            
            NSError *outError;
            NSArray *objectIDs = [context executeFetchRequest:request error:&outError];
            
            if (objectIDs) {
                [self performBlock:^{
                    kstStrongify(self);
                    NSMutableArray *objects = [[NSMutableArray alloc] init];
                    
                    for (NSManagedObjectID *objectID in objectIDs) {
                        NSManagedObject *object = [self existingObjectWithID:objectID error:NULL];
                        
                        if (object) {
                            [objects addObject:object];
                        }
                    }
                    
                    completion(objects,nil);
                }];
            }
            else {
                [self performBlock:^{
                    completion(nil,outError);
                }];
            }
        }];
    }
}

- (NSUInteger)KBA_countForEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate error:(NSError *__autoreleasing *)error; {
    NSFetchRequest *request = [NSFetchRequest KBA_fetchRequestForEntityName:entityName predicate:predicate sortDescriptors:nil limit:0 offset:0];
    
    [request setResultType:NSCountResultType];
    
    return [self countForFetchRequest:request error:error];
}

- (NSArray *)KBA_fetchPropertiesForEntityNamed:(NSString *)entityName properties:(NSArray *)properties predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError *__autoreleasing *)error; {
    NSParameterAssert(properties);
    
    NSFetchRequest *request = [NSFetchRequest KBA_fetchRequestForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors limit:0 offset:0];
    
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:properties];
    
    return [self executeFetchRequest:request error:error];
}

- (NSArray *)KBA_fetchWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey,id> *)options {
    return [self KBA_fetchWithOptions:options error:NULL];
}
- (NSArray *)KBA_fetchWithOptions:(NSDictionary<KBANSFetchRequestOptionsKey,id> *)options error:(NSError * _Nullable __autoreleasing *)error {
    NSFetchRequest *request = [NSFetchRequest KBA_fetchRequestWithOptions:options];
    
    return [self executeFetchRequest:request error:error];
}

@end
