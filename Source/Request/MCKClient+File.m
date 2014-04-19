//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient+File.m
//|
//|             D.V.
//|             Copyright (c) 2014 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//---------------------------------------------------------------------------//

#import "MCKClient+File.h"
#import "MCKConstants.h"
#import "MCKResponseProcessor.h"
#import "MCKRequestStatus_Private.h"
#import "MCKFile.h"
#import "MCKFileFlags.h"

//---------------------------------------------------------------------------//
@implementation MCKClient (File)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Retrieving a File
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processFileInfosStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
{
    if (status.state != MCKRequestStateComplete)
        return nil;
    
    return ^(RACSubject *subject) {
        // Parse jsonData into Foundation objects.
        NSError *error = nil;
        NSDictionary *JSONDictionary;
        
        JSONDictionary = [MCKResponseProcessor parseJSONData:status.responseContents ofResponse:status.response expectedClass:NSDictionary.class client:client error:&error];
        if (!JSONDictionary) {
            [subject sendError:error];
            return;
        }
        
        for (NSString *objectID in JSONDictionary) {
            NSDictionary *value = JSONDictionary[objectID];
            
            if ([value isEqual:NSNull.null]) {
                [subject sendNext:RACTuplePack([NSURL URLWithString:objectID], value)];
                continue;
            }
            
            MCKFile *file = [MCKResponseProcessor parseJSONDictionary:value resultClass:MCKFile.class client:client error:&error];
            if (error) {
                [subject sendError:error];
                return;
            }
            
            [subject sendNext:RACTuplePack([NSURL URLWithString:objectID], file)];
        }
    };
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)fetchFilesWithIDs:(NSArray*)objectIDs
{
    if (objectIDs.count == 0)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSUUID *uuid;
        NSString *path = @"info";
        NSMutableString *list = [NSMutableString string];
        for (NSString *objectID in objectIDs) {
            [list appendString:objectID];
            if (objectID != [objectIDs lastObject])
                [list appendString:@","];
        }
        
        NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:@{@"list": list}];
        MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processFileInfosStatus:fromClient:) context:nil];
        
        RACSubject *req = [self enqueueDataRequest:request responseProcessor:processor identifier:&uuid];
        RACDisposable *d = [req subscribeNext:^(id next) {
            [subscriber sendNext:next];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return [RACCompoundDisposable compoundDisposableWithDisposables:@[d, [RACDisposable disposableWithBlock:^{
            [self cancelRequest:uuid withResumeData:NO];
        }]]];
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - File Flags
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)fetchFlagsForFileID:(NSString*)objectID
{
    if (!objectID)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSUUID *uuid;
        NSString *path = [NSString stringWithFormat:@"%@/flags", objectID];
        NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
        MCKResponseProcessor *processor = [MCKResponseProcessor jsonResponseProcessorThatExtractsKey:@"flags" andParsesItIntoClass:MCKFileFlags.class withOptions:nil];
        
        RACSubject *req = [self enqueueDataRequest:request responseProcessor:processor identifier:&uuid];
        RACDisposable *d = [req subscribeNext:^(id next) {
            [subscriber sendNext:next];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return [RACCompoundDisposable compoundDisposableWithDisposables:@[d, [RACDisposable disposableWithBlock:^{
            [self cancelRequest:uuid withResumeData:NO];
        }]]];
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)fetchFlagsForFile:(MCKFile*)file
{ return [self fetchFlagsForFileID:file.objectID]; }

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)applyEdit:(MCKFileFlagsEdit*)edit toFileWithID:(NSString*)objectID
{
    if (!objectID || !edit)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // Encode the new flags
        NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:edit];
        if (!parameters) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not apply changes.", @""),
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Could not encode %@", @""), edit]
            };
            [subscriber sendError:[NSError errorWithDomain:MCKErrorDomain code:MCKErrorJSONEncodeFailed userInfo:userInfo]];
            return nil;
        }
        
        NSString *path = [NSString stringWithFormat:@"%@/flags", objectID];
        NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
        MCKResponseProcessor *processor = [MCKResponseProcessor jsonResponseProcessorThatExtractsKey:@"flags" andParsesItIntoClass:MCKFileFlags.class withOptions:nil];
        
        RACSubject *req = [self enqueueDataRequest:request responseProcessor:processor identifier:NULL];
        RACDisposable *d = [req subscribeNext:^(id next) {
            [subscriber sendNext:next];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return d;
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)applyEdit:(MCKFileFlagsEdit*)edit toFile:(MCKFile*)file
{ return [self applyEdit:edit toFileWithID:file.objectID]; }

@end
