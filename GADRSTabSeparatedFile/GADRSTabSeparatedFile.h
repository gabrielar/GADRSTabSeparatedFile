//
//  GADRSTabSeparatedFile.h
//  GADRSTabSeparatedFile
//
//  Created by Gabriel Radu on 27/04/2014.
//  Copyright (c) 2014 Gabriel Adrian Radu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const GADRSTabSeparatedFileErrorDomain;

typedef NS_OPTIONS(NSUInteger, GADRSTabSeparatedFileError) {
    GADRSTabSeparatedFileError_CouldNotOpenFileForReading = 1,
    GADRSTabSeparatedFileError_CouldNotOpenFileForWriting,
    GADRSTabSeparatedFileError_TryingToOpenFileForWritingWhileFileAlreadyExists,
    GADRSTabSeparatedFileError_NumberOfColumnsDoseNotMatchPreviousLine,
};


@interface GADRSTabSeparatedFile : NSObject

- (instancetype)initForReadingWithPath:(NSString*)path;
- (instancetype)initForReadingWithPath:(NSString*)path error:(NSError *__autoreleasing*)error;

- (instancetype)initForWritingWithPath:(NSString*)path;
- (instancetype)initForWritingWithPath:(NSString*)path error:(NSError *__autoreleasing*)error;

- (NSArray *)readColumnsInNextRow;
- (NSArray *)readColumnsInNextRowWithError:(NSError *__autoreleasing*)error;

- (BOOL)writeRowWithColumns:(NSArray*)columns;
- (BOOL)writeRowWithColumns:(NSArray*)columns error:(NSError *__autoreleasing*)error;

- (void)close;

@end










