//
//  KBADefaultManagedObjectPropertyMapping.m
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

#import "KBADefaultManagedObjectPropertyMapping.h"
#import "NSManagedObjectContext+KBAExtensions.h"
#import "NSManagedObjectContext+KBAImportExtensions.h"

#import <Stanley/KSTSnakeCaseToLlamaCaseValueTransformer.h>

#import <CoreData/CoreData.h>
#if (TARGET_OS_IPHONE)
#import <UIKit/UIImage.h>
#else
#import <AppKit/NSImage.h>
#endif

@implementation KBADefaultManagedObjectPropertyMapping

- (NSString *)entityPropertyKeyForJSONKey:(NSString *)JSONKey entityName:(NSString *)entityName {
    return [[NSValueTransformer valueTransformerForName:KSTSnakeCaseToLlamaCaseValueTransformerName] transformedValue:JSONKey];
}
- (NSString *)JSONKeyForEntityPropertyKey:(NSString *)propertyKey entityName:(NSString *)entityName {
    return [[NSValueTransformer valueTransformerForName:KSTSnakeCaseToLlamaCaseValueTransformerName] reverseTransformedValue:propertyKey];
}

- (id)entityPropertyValueForEntityPropertyKey:(NSString *)propertyKey value:(id)value entityName:(NSString *)entityName context:(NSManagedObjectContext *)context {
    if ([value isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSAttributeDescription *attributeDesc = entityDesc.attributesByName[propertyKey];
    NSRelationshipDescription *relationshipDesc = entityDesc.relationshipsByName[propertyKey];
    id retval = nil;
    
    if (attributeDesc) {
        switch (attributeDesc.attributeType) {
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
            case NSFloatAttributeType:
            case NSDoubleAttributeType:
            case NSBooleanAttributeType:
            case NSStringAttributeType:
                retval = value;
                break;
            case NSDecimalAttributeType:
                retval = [[NSDecimalNumber alloc] initWithString:value];
                break;
            case NSDateAttributeType:
                if ([value isKindOfClass:[NSString class]]) {
                    retval = [[NSManagedObjectContext KBA_defaultDateFormatter] dateFromString:value];
                }
                else if ([value isKindOfClass:[NSNumber class]]) {
                    retval = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
                }
                break;
            case NSBinaryDataAttributeType:
                retval = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                break;
            case NSTransformableAttributeType: {
                NSString *const kAttributeValueClassName = @"attributeValueClassName";
                
                if (attributeDesc.attributeValueClassName ||
                    attributeDesc.userInfo[kAttributeValueClassName]) {
#if (TARGET_OS_IPHONE)
                    if ([attributeDesc.userInfo[kAttributeValueClassName] isEqualToString:NSStringFromClass([UIImage class])]) {
                        retval = [[UIImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters]];
                    }
#else
                    if ([attributeDesc.userInfo[kAttributeValueClassName] isEqualToString:NSStringFromClass([NSImage class])]) {
                        retval = [[NSImage alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters]];
                    }
#endif
                    else if ([value isKindOfClass:[NSString class]]) {
                        retval = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    }
                    else if (attributeDesc.valueTransformerName) {
                        retval = [[NSValueTransformer valueTransformerForName:attributeDesc.valueTransformerName] transformedValue:value];
                    }
                    else {
                        retval = value;
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    else if (relationshipDesc) {
        NSString *destEntityName = relationshipDesc.destinationEntity.name;
        
        if (relationshipDesc.isToMany) {
            id destEntities = relationshipDesc.isOrdered ? [[NSMutableOrderedSet alloc] init] : [[NSMutableSet alloc] init];
            
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSManagedObject *destEntity = [context KBA_managedObjectWithDictionary:value entityName:destEntityName propertyMapping:self error:NULL];
                
                if (destEntity) {
                    [destEntities addObject:destEntity];
                }
            }
            else if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
                for (id destEntityIdentityOrDict in value) {
                    if ([destEntityIdentityOrDict isKindOfClass:[NSDictionary class]]) {
                        NSManagedObject *destEntity = [context KBA_managedObjectWithDictionary:destEntityIdentityOrDict entityName:destEntityName propertyMapping:self error:NULL];
                        
                        if (destEntity) {
                            [destEntities addObject:destEntity];
                        }
                    }
                    else if ([destEntityIdentityOrDict isKindOfClass:[NSNumber class]] ||
                             [destEntityIdentityOrDict isKindOfClass:[NSString class]]) {
                        
                        NSManagedObject *destEntity = [context KBA_fetchEntityNamed:destEntityName predicate:[NSPredicate predicateWithFormat:@"%K == %@",[NSManagedObjectContext KBA_defaultIdentityKey],destEntityIdentityOrDict] sortDescriptors:nil limit:1 error:NULL].firstObject;
                        
                        if (destEntity) {
                            [destEntities addObject:destEntity];
                        }
                    }
                }
            }
            else {
                destEntities = nil;
            }
            
            retval = destEntities;
        }
        else {
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSManagedObject *destEntity = [context KBA_managedObjectWithDictionary:value entityName:destEntityName propertyMapping:self error:NULL];
                
                retval = destEntity;
            }
            else if ([value isKindOfClass:[NSNumber class]] ||
                     [value isKindOfClass:[NSString class]]) {
                
                NSManagedObject *destEntity = [context KBA_fetchEntityNamed:destEntityName predicate:[NSPredicate predicateWithFormat:@"%K == %@",[NSManagedObjectContext KBA_defaultIdentityKey],value] sortDescriptors:nil limit:1 error:NULL].firstObject;
                
                retval = destEntity;
            }
        }
    }
    
    return retval;
}
- (id)JSONValueForEntityPropertyKey:(NSString *)propertyKey value:(id)value entityName:(NSString *)entityName context:(NSManagedObjectContext *)context {
    return nil;
}

@end
