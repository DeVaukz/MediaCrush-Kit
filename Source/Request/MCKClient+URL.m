//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient+URL.m
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

#import "MCKClient+URL.h"
#import "MCKConstants.h"
#import "MCKResponseProcessor.h"
#import "MCKRequestStatus_Private.h"
#import "MCKFile.h"

//---------------------------------------------------------------------------//
@implementation MCKClient (URL)

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processURLInfosStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
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
- (RACSignal*)infoForURLs:(NSArray*)urls
{
    if (urls.count == 0)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSUUID *uuid;
        NSString *path = @"url/info";
        NSMutableString *list = [NSMutableString string];
        for (NSURL *url in urls) {
            [list appendString:[url absoluteString]];
            if (url != [urls lastObject])
                [list appendString:@","];
        }
        
        NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:@{@"list": list}];
        MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processURLInfosStatus:fromClient:) context:nil];
        
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
