//
//  NSManagedObjectContext+KBAImportExtensions.m
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

#import "NSManagedObjectContext+KBAImportExtensions.h"
#import "NSManagedObjectContext+KBAExtensions.h"
#import "KBADefaultManagedObjectEntityMapping.h"
#import "KBADefaultManagedObjectPropertyMapping.h"

#import <Stanley/KSTLoggingMacros.h>
#import <Stanley/KSTFunctions.h>

#import <objc/runtime.h>

static void *kKBA_defaultIdentityKey = &kKBA_defaultIdentityKey;
static void *kKBA_defaultDateFormatterKey = &kKBA_defaultDateFormatterKey;

@interface NSManagedObjectContext (KBACoreDataImportExtensionsPrivate)
+ (NSString *)_KBA_defaultIdentity;
+ (NSDateFormatter *)_KBA_defaultDateFormatter;
+ (NSMutableDictionary *)_KBA_propertyMappingDictionary;
@end

@implementation NSManagedObjectContext (KBAImportExtensions)

+ (void)load {
    [self setKBA_defaultIdentityKey:[self _KBA_defaultIdentity]];
    [self setKBA_defaultDateFormatter:[self _KBA_defaultDateFormatter]];
}

+ (NSString *)KBA_defaultIdentityKey; {
    return objc_getAssociatedObject(self, kKBA_defaultIdentityKey);
}
+ (void)setKBA_defaultIdentityKey:(NSString *)key; {
    key = key.length > 0 ? key : [self _KBA_defaultIdentity];
    
    objc_setAssociatedObject(self, kKBA_defaultIdentityKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (NSDateFormatter *)KBA_defaultDateFormatter; {
    return objc_getAssociatedObject(self, kKBA_defaultDateFormatterKey);
}
+ (void)setKBA_defaultDateFormatter:(NSDateFormatter *)dateFormatter; {
    dateFormatter = dateFormatter ?: [self _KBA_defaultDateFormatter];
    
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

+ (NSString *)_KBA_defaultIdentity; {
    return @"identity";
}
+ (NSDateFormatter *)_KBA_defaultDateFormatter; {
    NSDateFormatter *retval = [[NSDateFormatter alloc] init];
    
    [retval setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    return retval;
}

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
