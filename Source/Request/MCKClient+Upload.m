//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient+File.m
//|
//|             D.V.
//|             Copyright (c) 2015 D.V. All rights reserved.
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

#import "MCKClient+Upload.h"
#import "MCKConstants.h"
#import "MCKResponseProcessor.h"
#import "MCKRequestStatus_Private.h"
#import "MCKFile.h"

//---------------------------------------------------------------------------//
NSString * const MCKUploadStatusPending = @"pending";
NSString * const MCKUploadStatusProcessing = @"processing";
NSString * const MCKUploadStatusDone = @"done";



//---------------------------------------------------------------------------//
@implementation MCKClient (Upload)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Uploading Content
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processUploadURLStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
{
    if (status.state != MCKRequestStateComplete)
        return nil;
    
    return ^(RACSubject *subject) {
        // Parse jsonData into Foundation objects.
        NSError *error = nil;
        NSDictionary *JSONDictionary;
        
        if (status.response.statusCode != 200 && status.response.statusCode != 409) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not upload URL.", @""),
            };
            [subject sendError:[NSError errorWithDomain:MCKAPIErrorDomain code:status.response.statusCode userInfo:userInfo]];
            return;
        }
        
        JSONDictionary = [MCKResponseProcessor parseJSONData:status.responseContents ofResponse:status.response expectedClass:NSDictionary.class client:client error:&error];
        if (!JSONDictionary) {
            [subject sendError:error];
            return;
        }
        
        if (JSONDictionary[@"hash"] == nil) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"The server returned an invalid response.", @""),
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Response did not contain an '%@' key", @""), @"hash"]
            };
            [subject sendError:[NSError errorWithDomain:MCKErrorDomain code:MCKErrorInvalidJSON userInfo:userInfo]];
            return;
        }
        
        [subject sendNext:JSONDictionary[@"hash"]];
    };
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)uploadURL:(NSURL*)url
{
    if (!url)
        return [RACSignal empty];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLRequest *request = [self requestWithMethod:@"POST" path:@"upload/url" parameters:@{@"url": url.absoluteString}];
        MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processUploadURLStatus:fromClient:) context:nil];
        
        RACSubject *req = [self enqueueDataRequest:request responseProcessor:processor identifier:NULL];
        RACDisposable *d = [req subscribeNext:^(id next) {
            [subscriber sendNext:next];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return d;
    }] replay];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processUploadFileStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
{
    if (status.state != MCKRequestStateComplete)
        return ^(RACSubject *subject) { [subject sendNext:status]; };
    
    return ^(RACSubject *subject) {
        status.result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // Parse jsonData into Foundation objects.
            NSError *error = nil;
            NSDictionary *JSONDictionary;
            
            if (status.response.statusCode != 200 && status.response.statusCode != 409) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Could not upload file.", @""),
                };
                [subscriber sendError:[NSError errorWithDomain:MCKAPIErrorDomain code:status.response.statusCode userInfo:userInfo]];
                return nil;
            }
            
            JSONDictionary = [MCKResponseProcessor parseJSONData:status.responseContents ofResponse:status.response expectedClass:NSDictionary.class client:client error:&error];
            if (!JSONDictionary) {
                [subscriber sendError:error];
                return nil;
            }
            
            if (JSONDictionary[@"hash"] == nil) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"The server returned an invalid response.", @""),
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Response did not contain an '%@' key", @""), @"hash"]
                };
                [subscriber sendError:[NSError errorWithDomain:MCKErrorDomain code:MCKErrorInvalidJSON userInfo:userInfo]];
                return nil;
            }
            
            [subscriber sendNext:JSONDictionary[@"hash"]];
            return nil;
        }];
        
        [subject sendNext:status];
    };
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)upload:(NSData*)fileData inBackground:(BOOL)background withIdentifier:(NSUUID**)identifier
{
    if (fileData.length == 0)
        return [RACSignal empty];
    
    NSURLRequest *request = [self requestWithMethod:@"POST" path:@"upload/file" parameters:@{@"file": fileData}];
    MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processUploadFileStatus:fromClient:) context:nil];
    
    return [self enqueueUploadRequest:request fromData:request.HTTPBody inBackground:background responseProcessor:processor identifier:identifier];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Checking the Status of an Upload
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processUploadsStatusStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
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
            
            if (value[@"status"] == nil) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"The server returned an invalid response.", @""),
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Response did not contain an '%@' key", @""), @"status"]
                };
                [subject sendError:[NSError errorWithDomain:MCKErrorDomain code:MCKErrorInvalidJSON userInfo:userInfo]];
                return;
            }
            
            MCKFile *file = nil;
            if (value[@"file"]) {
                file = [MCKResponseProcessor parseJSONDictionary:value[@"file"] resultClass:MCKFile.class client:client error:&error];
                if (error) {
                    [subject sendError:error];
                    return;
                }
            }
            
            [subject sendNext:RACTuplePack(objectID, value[@"status"], file)];
        }
    };
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)statusOfUploadsWithIDs:(NSArray*)objectIDs
{
    if (objectIDs.count == 0)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSUUID *uuid;
        NSMutableString *list = [NSMutableString string];
        for (NSString *objectID in objectIDs) {
            [list appendString:objectID];
            if (objectID != [objectIDs lastObject])
                [list appendString:@","];
        }
        
        NSURLRequest *request = [self requestWithMethod:@"GET" path:@"status" parameters:@{@"list": list}];
        MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processUploadsStatusStatus:fromClient:) context:nil];
        
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

@end
