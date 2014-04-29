//
//  GADRSTabSeparatedFile.m
//  GADRSTabSeparatedFile
//
//  Created by Gabriel Radu on 27/04/2014.
//  Copyright (c) 2014 Gabriel Adrian Radu. All rights reserved.
//

#import "GADRSTabSeparatedFile.h"


NSString *const GADRSTabSeparatedFileErrorDomain = @"CSVReaderWriterErrorDomain";

@interface NSError (GADRSTabSeparatedFile)
+ (instancetype)GADRSTabSeparatedFileErrorWithCode:(NSInteger)code userInfo:(NSDictionary *)dict;
@end

@implementation NSError (GADRSTabSeparatedFile)

+ (instancetype)GADRSTabSeparatedFileErrorWithCode:(NSInteger)code userInfo:(NSDictionary *)dict
{
    return [NSError errorWithDomain:GADRSTabSeparatedFileErrorDomain code:code userInfo:dict];
}

@end



@interface GADRSTabSeparatedFile () {
    NSString *_filePath;
    NSFileHandle *_fileHandle;
    NSMutableArray *_linesBuffer;
    NSMutableData *_lineReminder;
    NSUInteger _numberOfColumnsPerLine;
}
@end

@implementation GADRSTabSeparatedFile


#pragma mark Object life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert2(FALSE, @"Object of the %@ class should not be initialised with %@. Please use one of the initWithPath: methods.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    return self;
}

- (instancetype)initWithPath:(NSString*)path
{
    self = [super init];
    if (self) {
        _filePath = [path copy];
    }
    return self;
}

- (instancetype)initForReadingWithPath:(NSString*)path
{
    self = [self initForReadingWithPath:path error:nil];
    if (self) {
    }
    return self;
}

- (instancetype)initForReadingWithPath:(NSString*)path error:(NSError *__autoreleasing*)error
{
    self = [self initWithPath:path];
    if (self) {
        if (![self openForReadingWithError:error]) self = nil;
    }
    return self;
}

- (instancetype)initForWritingWithPath:(NSString*)path
{
    self = [self initForWritingWithPath:path error:nil];
    if (self) {
    }
    return self;
}

- (instancetype)initForWritingWithPath:(NSString*)path error:(NSError *__autoreleasing*)error
{
    self = [self initWithPath:path];
    if (self) {
        if (![self openForWritingWithError:error]) self = nil;
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

- (BOOL)openForReadingWithError:(NSError *__autoreleasing*)error
{
    NSAssert1(!_fileHandle, @"Trying to open an %@ object for reading while it is already open.", NSStringFromClass([self class]));
    
    _fileHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath];
    if (!_fileHandle) {
        if (error) *error = [NSError
                             GADRSTabSeparatedFileErrorWithCode:GADRSTabSeparatedFileError_CouldNotOpenFileForReading
                             userInfo:nil];
        return NO;
    }
    
    _numberOfColumnsPerLine = NSNotFound;
    _linesBuffer = [NSMutableArray new];
    _lineReminder = [NSMutableData new];
    
    return YES;
}

- (BOOL)openForWritingWithError:(NSError *__autoreleasing*)error
{
    NSAssert1(!_fileHandle, @"Trying to open an %@ object for writing while it is already open", NSStringFromClass([self class]));
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:_filePath]) {
        if (error) *error = [NSError
                             GADRSTabSeparatedFileErrorWithCode:GADRSTabSeparatedFileError_TryingToOpenFileForWritingWhileFileAlreadyExists
                             userInfo:nil];
        return NO;
    }
    
    [defaultManager createFileAtPath:_filePath contents:nil attributes:nil];
    
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    if (!_fileHandle) {
        if (error) *error = [NSError
                             GADRSTabSeparatedFileErrorWithCode:GADRSTabSeparatedFileError_CouldNotOpenFileForWriting
                             userInfo:nil];
        return NO;
    }
    
    _numberOfColumnsPerLine = NSNotFound;
    
    return YES;

}

- (void)close
{
    _numberOfColumnsPerLine = NSNotFound;
    [_fileHandle closeFile];
}


#pragma mark Read methods

- (NSArray *)readColumnsInNextRow
{
    return [self readColumnsInNextRowWithError:nil];
}

- (NSArray *)readColumnsInNextRowWithError:(NSError *__autoreleasing*)error
{
    if (![self readAtLeastOneLineIntoBuffersIfInsufficientDataInBuffersWithError:error])
        return nil;
    
    NSMutableData* lineData = [_linesBuffer firstObject];
    if (!lineData) {
        return nil;
    }
    else {
        [_linesBuffer removeObject:lineData];
    }
    
    NSString *line = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
    NSArray *columns = [line componentsSeparatedByString:@"\t"];
    
    if (_numberOfColumnsPerLine == NSNotFound) {
        _numberOfColumnsPerLine = [columns count];
    }
    else if (_numberOfColumnsPerLine != [columns count]){
        if (error) *error = [NSError
                             GADRSTabSeparatedFileErrorWithCode:GADRSTabSeparatedFileError_NumberOfColumnsDoseNotMatchPreviousLine
                             userInfo:nil];
        columns = nil;
    }
    
    return columns;
}

- (BOOL)readOneChunkIntoBuffersWithError:(NSError *__autoreleasing*)error
{
    NSAssert1(_fileHandle, @"Trying to read form an object of class %@ while it is not open for reading.", NSStringFromClass([self class]));
    
    const static NSUInteger tmpBufferSize = 1024*4;
    
    NSData *tempDataBuffer = [_fileHandle readDataOfLength:tmpBufferSize];
    const uint8_t *tmpBuffer = [tempDataBuffer bytes];
    NSUInteger noOfBytesRead = [tempDataBuffer length];
    
    if (noOfBytesRead > 0) {
        
        for (NSInteger tmpBufferIdx = 0; tmpBufferIdx < noOfBytesRead; tmpBufferIdx++) {
            uint8_t ch = tmpBuffer[tmpBufferIdx];
            if (ch == '\n') {
                [_linesBuffer addObject:_lineReminder];
                _lineReminder = [NSMutableData new];
                continue;
            }
            if (ch == '\r') {
                continue;
            }
            
            [_lineReminder appendBytes:&ch length:1];
        }
    }
    else if ([_lineReminder length] > 0) {
        [_linesBuffer addObject:_lineReminder];
        _lineReminder = nil;
    }
    else {
        _lineReminder = nil;
    }
    
    return YES;
}

- (BOOL)readAtLeastOneLineIntoBuffersIfInsufficientDataInBuffersWithError:(NSError *__autoreleasing*)error
{
    while (_lineReminder != nil && [_linesBuffer count] < 1) {
        if (![self readOneChunkIntoBuffersWithError:error])
            return NO;
    }
    return YES;
}


#pragma mark Write methods

- (BOOL)writeRowWithColumns:(NSArray *)columns
{
    return [self writeRowWithColumns:columns error:nil];
}

- (BOOL)writeRowWithColumns:(NSArray *)columns error:(NSError *__autoreleasing*)error
{
    NSAssert1(_fileHandle, @"Trying to write to an object of class %@ while it is not open for writing.", NSStringFromClass([self class]));
    
    if (_numberOfColumnsPerLine == NSNotFound) {
        _numberOfColumnsPerLine = [columns count];
    }
    else if (_numberOfColumnsPerLine != [columns count]) {
        if (error) *error = [NSError
                             GADRSTabSeparatedFileErrorWithCode:GADRSTabSeparatedFileError_NumberOfColumnsDoseNotMatchPreviousLine
                             userInfo:nil];
        return NO;
    }
    
    NSString *line = [columns componentsJoinedByString:@"\t"];
    line = [line stringByAppendingString:@"\n"];
    NSData *lineData = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    [_fileHandle writeData:lineData];
    
    return YES;
}

@end





