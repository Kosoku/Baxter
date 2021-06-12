//
//  NSManagedObjectContext+KBAImportExtensions.h
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

#import <Baxter/KBAManagedObjectEntityMapping.h>
#import <Baxter/KBAManagedObjectPropertyMapping.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectContext (KBAImportExtensions)

/**
 Set and get the key used for testing equality when importing. If you require a custom key, this should be set before calling `KBA_importJSON:entityOrder:entityMapping:completion:`.
 
 The default is @"identity".
 */
@property (class,copy,nonatomic,null_resettable) NSString *KBA_defaultIdentityKey;
/**
 Set and get the date formatter used to convert between JSON and NSDate objects.
 
 The default is an NSDateFormatter with @"yyyy-MM-dd'T'HH:mm:ssZZZZZ" as its date format.
 */
@property (class,strong,nonatomic,null_resettable) NSDateFormatter *KBA_defaultDateFormatter;

/**
 Get the object responsible for mapping between entity properties and JSON keys.
 
 The default is an instance of KBADefaultManagedObjectPropertyMapping.
 
 @param entityName The name of the entity
 @return The property mapping object for the entity with name
 */
+ (id<KBAManagedObjectPropertyMapping>)KBA_propertyMappingForEntityNamed:(NSString *)entityName;
/**
 Register a property mapping for a particular entity.
 
 @param propertyMapping An object conforming to KBAManagedObjectPropertyMapping
 @param entityName The name of the entity
 */
+ (void)KBA_registerPropertyMapping:(nullable id<KBAManagedObjectPropertyMapping>)propertyMapping forEntityNamed:(NSString *)entityName;

/**
 Returns a NSManagedObject of entityName by mapping keys and values in dictionary using propertyMapping.
 
 @param dictionary The dictionary of property/relationship key/value pairs
 @param entityName The name of the entity to create
 @param propertyMapping The property mapping to use during creation
 @param error If the method returns nil, an error describing the reason for failure
 @return The managed object
 */
- (nullable __kindof NSManagedObject *)KBA_managedObjectWithDictionary:(NSDictionary *)dictionary entityName:(NSString *)entityName propertyMapping:(id<KBAManagedObjectPropertyMapping>)propertyMapping error:(NSError *__autoreleasing *)error;

/**
 Imports the provided JSON, creating managed objects for each entry using entityMapping, which maps between JSON keys and entity names. Invokes the completion block when the operation is finished.
 
 @param JSON A collection conforming to NSFastEnumeration, if a NSDictionary is provided, entityOrder can be nil
 @param entityOrder The order to import the entities in JSON
 @param entityMapping The entity mapping
 @param completion The completion block invoked when the operation is finished
 */
- (void)KBA_importJSON:(id<NSFastEnumeration,NSObject>)JSON entityOrder:(nullable NSArray *)entityOrder entityMapping:(nullable id<KBAManagedObjectEntityMapping>)entityMapping completion:(void(^)(BOOL success, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
