//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient+Album.m
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

#import "MCKClient+Album.h"
#import "MCKConstants.h"
#import "MCKResponseProcessor.h"
#import "MCKRequestStatus_Private.h"
#import "MCKAlbum.h"
#import "MCKFile.h"

//---------------------------------------------------------------------------//
@implementation MCKClient (Album)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Retrieving Information About a Album
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processAlbumInfosStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
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
            
            MCKAlbum *album = [MCKResponseProcessor parseJSONDictionary:value resultClass:MCKAlbum.class client:client error:&error];
            if (error) {
                [subject sendError:error];
                return;
            }
            
            [subject sendNext:RACTuplePack([NSURL URLWithString:objectID], album)];
        }
    };
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)infoForAlbumsWithIDs:(NSArray*)objectIDs
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
        MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processAlbumInfosStatus:fromClient:) context:nil];
        
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
#pragma mark - Creating Albums
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)createAlbumContainingFilesWithIDs:(NSArray*)objectIDs
{
    if (objectIDs.count == 0)
        return [RACSignal empty];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableString *list = [NSMutableString string];
        for (NSString *objectID in objectIDs) {
            [list appendString:objectID];
            if (objectID != [objectIDs lastObject])
                [list appendString:@","];
        }
        
        NSString *path = @"album/create";
        NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:@{@"list": list}];
        MCKResponseProcessor *processor = [MCKResponseProcessor jsonResponseProcessorThatExtractsKey:nil andParsesItIntoClass:MCKObject.class withOptions:@{
            MCKResponseProcesorOptionErrorDescription: NSLocalizedString(@"Could not create album.", @""),
            MCKResponseProcesorOptionFailureReasonsForErrorCodes: @{
                @(404): NSLocalizedString(@"At least one of the provided items does not exist.", @""),
                @(413): NSLocalizedString(@"An attempt was made to create an album that was too large.", @""),
                @(415): NSLocalizedString(@"At least one of the items in the list is not a File.", @"")
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
- (RACSignal*)createAlbumContainingFiles:(NSArray*)files
{
    return [self createAlbumContainingFilesWithIDs:[files.rac_sequence map:^id(MCKFile *file) {
        return file.objectID;
    }].array];
}

@end
