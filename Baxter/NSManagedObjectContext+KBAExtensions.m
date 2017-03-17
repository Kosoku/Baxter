//
//  NSManagedObjectContext+KBAExtensions.m
//  Baxter
//
//  Created by William Towe on 3/17/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NSManagedObjectContext+KBAExtensions.h"
#import "NSFetchRequest+KBAExtensions.h"

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

- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors completion:(void(^)(NSArray *objects, NSError *error))completion; {
    [self KBA_fetchEntityNamed:entityName predicate:predicate sortDescriptors:sortDescriptors limit:0 offset:0 completion:completion];
}
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit completion:(void(^)(NSArray *objects, NSError *error))completion; {
    [self KBA_fetchEntityNamed:entityName predicate:predicate sortDescriptors:sortDescriptors limit:limit offset:0 completion:completion];
}
- (void)KBA_fetchEntityNamed:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset completion:(void(^)(NSArray *objects, NSError *error))completion; {
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

@end
