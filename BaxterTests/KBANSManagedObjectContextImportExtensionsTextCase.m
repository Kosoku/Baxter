//
//  KBANSManagedObjectContextImportExtensionsTextCase.m
//  BaxterTests
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

#import <XCTest/XCTest.h>

#import <Baxter/Baxter.h>

@interface KBANSManagedObjectContextImportExtensionsTextCase : XCTestCase

@end

@implementation KBANSManagedObjectContextImportExtensionsTextCase

- (void)testClassProperties {
    [NSManagedObjectContext setKBA_defaultIdentityKey:@"id"];
    
    XCTAssertEqualObjects(NSManagedObjectContext.KBA_defaultIdentityKey, @"id");
    
    [NSManagedObjectContext setKBA_defaultIdentityKey:nil];
    
    XCTAssertEqualObjects(NSManagedObjectContext.KBA_defaultIdentityKey, @"identity");
    
    [NSManagedObjectContext setKBA_defaultDateFormatter:nil];
    
    XCTAssertNotNil(NSManagedObjectContext.KBA_defaultDateFormatter);
}
- (void)testCoreDataImport {
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"Test" withExtension:@"mom"]]];
    
    [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [context setPersistentStoreCoordinator:coordinator];
    [context setUndoManager:nil];
    
    [NSManagedObjectContext setKBA_defaultIdentityKey:@"id"];
    
    NSString *const kID = @"4E44DCEB-695D-4CA1-B672-5383230C4EC5";
    NSString *const kName = @"Project Name";
    NSNumber *const kNumberOfIssues = @1234;
    NSNumber *const kIsCurrent = @YES;
    
    NSString *const kIssueID = @"4F77CB74-5449-4429-BF49-BB7B13E10A4A";
    
    NSString *const kUserID = @"01148E51-DFBF-4695-89F9-846921AA73CF";
    
    NSDictionary *const kDict = @{@"project": @[@{@"id": kID,
                                                  @"name": kName,
                                                  @"number_of_issues": kNumberOfIssues,
                                                  @"is_current": kIsCurrent,
                                                  @"issues": @[@{@"id": kIssueID,
                                                                 @"name": @"Fix all the things"}],
                                                  @"user": @{@"id": kUserID,
                                                             @"first_name": @"John",
                                                             @"last_name": @"Smith"}}]};
    
    XCTestExpectation *expect = [self expectationWithDescription:@"Testing core data import"];
    
    [context KBA_importJSON:kDict entityOrder:nil entityMapping:nil completion:^(BOOL success, NSError *error) {
        NSManagedObject *project = [context KBA_fetchEntityNamed:@"Project" predicate:[NSPredicate predicateWithFormat:@"%K == %@",@"id",kID] sortDescriptors:nil limit:1 error:NULL].firstObject;
        
        XCTAssertEqualObjects([project valueForKey:@"id"], kID);
        XCTAssertEqualObjects([project valueForKey:@"name"], kName);
        XCTAssertEqualObjects([project valueForKey:@"numberOfIssues"], kNumberOfIssues);
        XCTAssertEqualObjects([project valueForKey:@"isCurrent"], kIsCurrent);
        
        XCTAssertEqualObjects([project valueForKeyPath:@"issues.id"] , [NSSet setWithArray:@[kIssueID]]);
        
        XCTAssertEqualObjects([project valueForKeyPath:@"user.id"], kUserID);
        
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
