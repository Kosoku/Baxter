//
//  KBADefaultManagedObjectEntityMapping.m
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

#import "KBADefaultManagedObjectEntityMapping.h"

#import <Stanley/KSTSnakeCaseToLlamaCaseValueTransformer.h>

@implementation KBADefaultManagedObjectEntityMapping

- (NSString *)entityNameForJSONEntityName:(NSString *)JSONName {
    return [[[NSValueTransformer valueTransformerForName:KSTSnakeCaseToLlamaCaseValueTransformerName] transformedValue:JSONName] capitalizedString];
}

- (NSString *)JSONEntityNameForEntityName:(NSString *)entityName {
    return [[NSValueTransformer valueTransformerForName:KSTSnakeCaseToLlamaCaseValueTransformerName] reverseTransformedValue:entityName];
}

@end
