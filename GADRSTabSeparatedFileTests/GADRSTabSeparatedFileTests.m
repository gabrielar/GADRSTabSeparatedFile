//
//  GADRSTabSeparatedFileTests.m
//  GADRSTabSeparatedFileTests
//
//  Created by Gabriel Radu on 27/04/2014.
//  Copyright (c) 2014 Gabriel Adrian Radu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GADRSTabSeparatedFile.h"

@interface GADRSTabSeparatedFileTests : XCTestCase

@end

@implementation GADRSTabSeparatedFileTests


#pragma mark Tests lifecycle

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark Tests

- (void)testValidFileReading
{
    NSString *filePath = [self pathForTestFileWithName:@"ValidTabSeparatedTestFile" ofType:@"txt"];
    GADRSTabSeparatedFile *tabSeparatedFile = [[GADRSTabSeparatedFile alloc] initForReadingWithPath:filePath];
    

    for (NSUInteger lineIdx = 0; lineIdx < 6; lineIdx++) {
        
        NSArray *columns = [tabSeparatedFile readColumnsInNextRow];
        XCTAssertEqual([columns count], 7, @"");
        
        for (NSUInteger columnIdx = 0; columnIdx < 7; columnIdx++) {
            NSString *column = columns[columnIdx];
            NSString *expectedColumn = [NSString stringWithFormat:@"Row%luColumn%lu", (unsigned long)lineIdx+1, (unsigned long)columnIdx+1];
            XCTAssertEqualObjects(column, expectedColumn, @"");
        }
        
    }
    
    NSArray *columns = [tabSeparatedFile readColumnsInNextRow];
    XCTAssertNil(columns, @"");
    
    [tabSeparatedFile close];
}

- (void)testValidFileReadingWithoutNewLineAtEOF
{
    NSString *filePath = [self pathForTestFileWithName:@"ValidTabSeparatedTestFileWithNoNewLineAtEOF" ofType:@"txt"];
    GADRSTabSeparatedFile *tabSeparatedFile = [[GADRSTabSeparatedFile alloc] initForReadingWithPath:filePath];
    
    
    for (NSUInteger lineIdx = 0; lineIdx < 6; lineIdx++) {
        
        NSArray *columns = [tabSeparatedFile readColumnsInNextRow];
        XCTAssertEqual([columns count], 7, @"");
        
        for (NSUInteger columnIdx = 0; columnIdx < 7; columnIdx++) {
            NSString *column = columns[columnIdx];
            NSString *expectedColumn = [NSString stringWithFormat:@"Row%luColumn%lu", (unsigned long)lineIdx+1, (unsigned long)columnIdx+1];
            XCTAssertEqualObjects(column, expectedColumn, @"");
        }
        
    }
    
    NSArray *columns = [tabSeparatedFile readColumnsInNextRow];
    XCTAssertNil(columns, @"");
    
    [tabSeparatedFile close];
}

- (void)testFileWriting
{
    NSString *filePath = [self pathToDocumentsDirectoryForFileWithName:@"testFileWriting_file.txt"];
    GADRSTabSeparatedFile *tabSeparatedFile = [[GADRSTabSeparatedFile alloc] initForWritingWithPath:filePath];
    
    [tabSeparatedFile writeRowWithColumns:@[@"Row1Column1", @"Row1Column2", @"Row1Column3"]];
    [tabSeparatedFile writeRowWithColumns:@[@"Row2Column1", @"Row2Column2", @"Row2Column3"]];
    [tabSeparatedFile writeRowWithColumns:@[@"Row3Column1", @"Row3Column2", @"Row3Column3"]];
    [tabSeparatedFile writeRowWithColumns:@[@"Row4Column1", @"Row4Column2", @"Row4Column3"]];
    
    [tabSeparatedFile close];
    
    
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *expectedFileConents = [NSString stringWithContentsOfFile:[self pathForTestFileWithName:@"ValidTabSeparatedTestFileSmall" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertEqualObjects(fileContents, expectedFileConents, @"");
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (void)testErrorForReadingNonexistentFile
{
    NSError *error = nil;
    
    NSString *filePath = @"/SomeNonExistingFile.txt";
    GADRSTabSeparatedFile *tabSeparatedFile = [[GADRSTabSeparatedFile alloc] initForReadingWithPath:filePath error:&error];
    
    XCTAssertNil(tabSeparatedFile, @"");
    XCTAssertNotNil(error, @"");
}

- (void)testErrorForReadingFileWithMismatchedColumnNumbers
{
    NSString *filePath = [self pathForTestFileWithName:@"InvalidTabSeparatedTestFileWithWrongNoOfColumns" ofType:@"txt"];
    GADRSTabSeparatedFile *tabSeparatedFile = [[GADRSTabSeparatedFile alloc] initForReadingWithPath:filePath];
    
    NSError *error = nil;
  
    XCTAssertTrue([tabSeparatedFile readColumnsInNextRowWithError:&error], @"");
    XCTAssertNil(error, @"");
    
    XCTAssertFalse([tabSeparatedFile readColumnsInNextRowWithError:&error], @"");
    XCTAssertNotNil(error, @"");
    
    [tabSeparatedFile close];

}

- (void)testErrorForWritingFileInReadOnlyDirectory
{
    NSError *error = nil;
    NSString *filePath = @"/ThisFileShouldNotBeCreated.txt";
    GADRSTabSeparatedFile *tabSeparatedFile = [[GADRSTabSeparatedFile alloc] initForWritingWithPath:filePath error:&error];
    
    XCTAssertNil([tabSeparatedFile readColumnsInNextRowWithError:&error], @"");
    XCTAssertNotNil(error, @"");
    
    [tabSeparatedFile close];
}


#pragma mark Utilities

- (NSString *)pathForTestFileWithName:(NSString *)name ofType:(NSString *)extension
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [testBundle pathForResource:name ofType:extension];
}

- (NSString *)pathToDocumentsDirectoryForFileWithName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}


@end










