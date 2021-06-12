//
//  KBAManagedObjectEntityMapping.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for objects that map JSON keys to entity names.
 */
@protocol KBAManagedObjectEntityMapping <NSObject>
@required
/**
 Return the entity name for JSON key. For example, `my_document` -> `MyDocument`.
 
 @parm JSONName The JSON name
 @return The entity name
 */
- (NSString *)entityNameForJSONEntityName:(NSString *)JSONName;
@optional
/**
 Return the JSON key for entity name. For example, `MyDocument` -> `my_document`.
 
 @param entityName The entity name
 @return The JSON name
 */
- (NSString *)JSONEntityNameForEntityName:(NSString *)entityName;
@end

NS_ASSUME_NONNULL_END
