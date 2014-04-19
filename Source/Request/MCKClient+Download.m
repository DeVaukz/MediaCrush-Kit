//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient+Download.m
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

#import "MCKClient+Download.h"
#import "MCKConstants.h"
#import "MCKResponseProcessor.h"
#import "MCKRequestStatus_Private.h"
#import "MCKMediaFile.h"

//---------------------------------------------------------------------------//
@implementation MCKClient (Download)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Downloading Content
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processDownloadFileStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
{
#pragma unused (client)
    
    if (status.state != MCKRequestStateComplete)
        return ^(RACSubject *subject) { [subject sendNext:status]; };
    
    return ^(RACSubject *subject) {
        status.result = [RACSignal return:[NSData dataWithContentsOfURL:status.responseContents]];
        
        [subject sendNext:status];
    };
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)download:(MCKMediaFile*)file inBackground:(BOOL)background withIdentifier:(NSUUID**)identifier
{
    NSURLRequest *request = [NSURLRequest requestWithURL:file.url];
    if (!request)
        return [RACSignal empty];
    
    MCKResponseProcessor *processor = [MCKResponseProcessor processorWithTarget:self.class selector:@selector(_processDownloadFileStatus:fromClient:) context:nil];
    
    return [self enqueueDownloadRequest:request inBackground:background responseProcessor:processor identifier:identifier];
}

@end
