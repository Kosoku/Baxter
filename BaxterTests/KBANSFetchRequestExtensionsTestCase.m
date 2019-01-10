//
//  KBANSFetchRequestExtensionsTestCase.m
//  Baxter
//
//  Created by William Towe on 4/21/17.
//  Copyright © 2019 Kosoku Interactive, LLC. All rights reserved.
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

#import <XCTest/XCTest.h>

#import <Baxter/NSFetchRequest+KBAExtensions.h>

@interface KBANSFetchRequestExtensionsTestCase : XCTestCase

@end

@implementation KBANSFetchRequestExtensionsTestCase

- (void)testFetchRequest {
    XCTAssertNotNil([NSFetchRequest KBA_fetchRequestForEntityName:@"Project" predicate:nil sortDescriptors:nil limit:0 offset:0]);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"identity",[[NSUUID UUID] UUIDString]];
    
    XCTAssertEqualObjects([NSFetchRequest KBA_fetchRequestForEntityName:@"Project" predicate:predicate sortDescriptors:nil limit:0 offset:0].predicate.predicateFormat, predicate.predicateFormat);
}

@end
