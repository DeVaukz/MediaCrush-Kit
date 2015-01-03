//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient+Object.m
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

#import "MCKClient+Object.h"
#import "MCKConstants.h"
#import "MCKObject.h"
#import "MCKResponseProcessor.h"
#import "MCKRequestStatus_Private.h"

//---------------------------------------------------------------------------//
@implementation MCKClient (Object)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Determining If An Object Is Already On The Server
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)existsObjectWithID:(NSString*)objectID
{
    if (objectID == nil)
        return [RACSignal return:@(NO)];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSUUID *uuid;
        NSString *path = [NSString stringWithFormat:@"%@/exists", objectID];
        NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
        MCKResponseProcessor *processor = [MCKResponseProcessor jsonResponseProcessorThatExtractsKey:@"exists" andParsesItIntoClass:nil withOptions:@{
            MCKResponseProcesorOptionFailureReasonsForErrorCodes: @{@(404): NSNull.null}
        }];
        
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
- (RACSignal*)existsObject:(MCKObject*)object
{ return [self existsObjectWithID:object.objectID]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Deleting a File
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)deleteObjectWithID:(NSString*)objectID
{
    if (!objectID)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLRequest *request = [self requestWithMethod:@"DELETE" path:objectID parameters:nil];
        
        MCKResponseProcessor *processor = [MCKResponseProcessor responseProcessorThatChecksForErrorsWithOptions:@{
            MCKResponseProcesorOptionErrorDescription: NSLocalizedString(@"Could not remove the object.", @""),
            MCKResponseProcesorOptionFailureReasonsForErrorCodes: @{
                @(401): NSLocalizedString(@"Your IP address does not have permission to delete this object.", @""),
                @(404): NSLocalizedString(@"No object with the provided ID was found.", @""),
            }
        }];
        
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
- (RACSignal*)deleteObject:(MCKObject*)object
{ return [self deleteObjectWithID:object.objectID]; }

@end
