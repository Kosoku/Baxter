//
//  KBAManagedObjectPropertyMapping.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for objects that map JSON keys to managed object property names.
 */
@protocol KBAManagedObjectPropertyMapping <NSObject>
@required
/**
 Return the entity property name for the JSON key. For example, `first_name` -> `firstName`.
 
 @param JSONKey The JSON key
 @param entityName The entity name
 @return The entity property name
 */
- (NSString *)entityPropertyKeyForJSONKey:(NSString *)JSONKey entityName:(NSString *)entityName;
/**
 Return the JSON key for the entity property name. For example, `firstName` -> `first_name`.
 
 @param propertyKey The JSON key
 @param entityName The entity name
 @return The JSON key
 */
- (NSString *)JSONKeyForEntityPropertyKey:(NSString *)propertyKey entityName:(NSString *)entityName;

/**
 Return the entity property value for property key and entity name in context.
 
 @param propertyKey The entity property key
 @param value The JSON value
 @param entityName The entity name
 @param context The managed object context
 @return The entity property value
 */
- (id)entityPropertyValueForEntityPropertyKey:(NSString *)propertyKey value:(nullable id)value entityName:(NSString *)entityName context:(NSManagedObjectContext *)context;

@optional
/**
 Return the JSON value for the entity property key, value, and entity name in context.
 
 @param propertyKey The entity property key
 @param value The entity property value
 @param entityName The entity name
 @param context The managed object context
 @return The JSON value
 */
- (id)JSONValueForEntityPropertyKey:(NSString *)propertyKey value:(nullable id)value entityName:(NSString *)entityName context:(NSManagedObjectContext *)context;
@end

NS_ASSUME_NONNULL_END
