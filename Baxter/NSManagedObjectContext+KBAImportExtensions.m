//
//  NSManagedObjectContext+KBAImportExtensions.m
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

#import "NSManagedObjectContext+KBAImportExtensions.h"
#import "NSManagedObjectContext+KBAExtensions.h"
#import "KBADefaultManagedObjectEntityMapping.h"
#import "KBADefaultManagedObjectPropertyMapping.h"

#import <Stanley/KSTLoggingMacros.h>
#import <Stanley/KSTFunctions.h>

#import <objc/runtime.h>

@interface NSManagedObjectContext (KBACoreDataImportExtensionsPrivate)
+ (NSMutableDictionary *)_KBA_propertyMappingDictionary;
@end

@implementation NSManagedObjectContext (KBAImportExtensions)

static void *kKBA_defaultIdentityKey = &kKBA_defaultIdentityKey;
+ (NSString *)KBA_defaultIdentityKey; {
    return objc_getAssociatedObject(self, kKBA_defaultIdentityKey);
}
+ (void)KBA_setDefaultIdentityKey:(NSString *)key; {
    objc_setAssociatedObject(self, kKBA_defaultIdentityKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void *kKBA_defaultDateFormatterKey = &kKBA_defaultDateFormatterKey;
+ (NSDateFormatter *)KBA_defaultDateFormatter; {
    NSDateFormatter *retval = objc_getAssociatedObject(self, kKBA_defaultDateFormatterKey);
    
    if (!retval) {
        static NSDateFormatter *kRetval;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kRetval = [[NSDateFormatter alloc] init];
            
            [kRetval setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        });
        
        retval = kRetval;
    }
    
    return retval;
}
+ (void)KBA_setDefaultDateFormatter:(NSDateFormatter *)dateFormatter; {
    objc_setAssociatedObject(self, kKBA_defaultDateFormatterKey, dateFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id<KBAManagedObjectPropertyMapping>)KBA_propertyMappingForEntityNamed:(NSString *)entityName; {
    return [self _KBA_propertyMappingDictionary][entityName] ?: [[KBADefaultManagedObjectPropertyMapping alloc] init];
}

+ (void)KBA_registerPropertyMapping:(id<KBAManagedObjectPropertyMapping>)propertyMapping forEntityNamed:(NSString *)entityName; {
    [[self _KBA_propertyMappingDictionary] setObject:propertyMapping forKey:entityName];
}

- (NSManagedObject *)KBA_managedObjectWithDictionary:(NSDictionary *)dictionary entityName:(NSString *)entityName propertyMapping:(id<KBAManagedObjectPropertyMapping>)propertyMapping error:(NSError *__autoreleasing *)error; {
    NSParameterAssert(dictionary);
    NSParameterAssert(entityName);
    NSParameterAssert(propertyMapping);
    
    NSString *const kIdentityKey = [self.class KBA_defaultIdentityKey];
    id identity = dictionary[[propertyMapping JSONKeyForEntityPropertyKey:kIdentityKey entityName:entityName]];
    
    NSParameterAssert(identity);
    
    NSError *outError;
    NSManagedObject *retval = [self KBA_fetchEntityNamed:entityName predicate:[NSPredicate predicateWithFormat:@"%K == %@",kIdentityKey,identity] sortDescriptors:nil limit:1 error:&outError].firstObject;
    
    if (!retval) {
        if (outError) {
            *error = outError;
            
            return nil;
        }
        
        retval = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
        
        [retval setValue:identity forKey:kIdentityKey];
        
        KSTLog(@"created entity %@ with identity %@",entityName,identity);
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *JSONKey, id JSONValue, BOOL *stop) {
        NSString *const kPropertyKey = [propertyMapping entityPropertyKeyForJSONKey:JSONKey entityName:entityName];
        
        if (entityDescription.propertiesByName[kPropertyKey] != nil) {
            id const kPropertyValue = [propertyMapping entityPropertyValueForEntityPropertyKey:kPropertyKey value:JSONValue entityName:entityName context:self];
            [retval setValue:kPropertyValue forKey:kPropertyKey];
        }
        
    }];
    
    return retval;
}

- (void)KBA_importJSON:(id<NSFastEnumeration,NSObject>)JSON entityOrder:(NSArray *)entityOrder entityMapping:(id<KBAManagedObjectEntityMapping>)entityMapping completion:(void(^)(BOOL success, NSError *error))completion; {
    NSParameterAssert([JSON isKindOfClass:[NSDictionary class]] || (JSON && entityOrder.count > 0));
    
    if (!entityMapping) {
        entityMapping = [[KBADefaultManagedObjectEntityMapping alloc] init];
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [context setUndoManager:nil];
    [context setParentContext:self];
    [context performBlock:^{
        NSMutableArray *entityNames = [[NSMutableArray alloc] init];
        
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            if (entityOrder.count > 0) {
                [entityNames addObjectsFromArray:entityOrder];
            }
            else {
                [entityNames addObjectsFromArray:[(NSDictionary *)JSON allKeys]];
            }
            
            for (NSString *JSONEntityName in entityNames) {
                NSString *const kEntityName = [entityMapping entityNameForJSONEntityName:JSONEntityName];
                id<KBAManagedObjectPropertyMapping> const kPropertyMapping = [self.class KBA_propertyMappingForEntityNamed:kEntityName];
                NSArray *const kEntityDicts = [(NSDictionary *)JSON objectForKey:JSONEntityName];
                
                for (NSDictionary *entityDict in kEntityDicts) {
                    NSError *outError;
                    if (![context KBA_managedObjectWithDictionary:entityDict entityName:kEntityName propertyMapping:kPropertyMapping error:&outError]) {
                        KSTLogObject(outError);
                    }
                }
            }
        }
        else {
            [entityNames addObjectsFromArray:entityOrder];
            
            NSString *const kEntityName = [entityMapping entityNameForJSONEntityName:entityOrder.lastObject];
            id<KBAManagedObjectPropertyMapping> const kPropertyMapping = [self.class KBA_propertyMappingForEntityNamed:kEntityName];
            
            for (NSDictionary *entityDict in JSON) {
                NSError *outError;
                if (![context KBA_managedObjectWithDictionary:entityDict entityName:kEntityName propertyMapping:kPropertyMapping error:&outError]) {
                    KSTLogObject(outError);
                }
            }
        }
        
        NSError *outError;
        if ([context KBA_saveRecursively:&outError]) {
            if (completion) {
                KSTDispatchMainAsync(^{
                    completion(YES,nil);
                });
            }
        }
        else {
            if (completion) {
                KSTDispatchMainAsync(^{
                    completion(NO,outError);
                });
            }
        }
    }];
}

@end

@implementation NSManagedObjectContext (KBAImportExtensionsPrivate)

static void *kKBA_registerPropertyMappingForEntityNamed = &kKBA_registerPropertyMappingForEntityNamed;
+ (NSMutableDictionary *)_KBA_propertyMappingDictionary; {
    NSMutableDictionary *retval = objc_getAssociatedObject(self, kKBA_registerPropertyMappingForEntityNamed);
    
    if (!retval) {
        retval = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kKBA_registerPropertyMappingForEntityNamed, retval, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return retval;
}

@end
