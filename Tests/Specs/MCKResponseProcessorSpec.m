//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKResponseProcessorSpec.m
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

#import <MediaCrushKit/MCKRequestStatus_Private.h>

@interface MCKResponseProcessor_TestClass : NSObject
@property (nonatomic, strong) id<AFURLResponseSerialization> responseSerializer;
@property (nonatomic, copy) NSDictionary *surrogateClasses;
@property (nonatomic, copy) MCKServer *server;

@property (nonatomic, strong) id lastNext;
@property (nonatomic, strong) id lastError;
@end
@implementation MCKResponseProcessor_TestClass

//|++++++++++++++++++++++++++++++++++++|//
- (void)sendNext:(id)next
{ self.lastNext = next; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)sendError:(id)error
{ self.lastError = error; }

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)processStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client context:(id)context
{
#pragma unused (status)
#pragma unused (client)
    
    return ^(RACSubject *subject) { [subject sendNext:context]; };
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)processStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
{
#pragma unused (status)
#pragma unused (client)
    
    return ^(RACSubject *subject) { [subject sendNext:@(YES)]; };
}

@end


//---------------------------------------------------------------------------//
SpecBegin(MCKResponseProcessor)

__block MCKClient *client;
__block _MCKRequestStatus *status;

before(^{
    NSURL *url = [NSURL URLWithString:@"http://localhost"];
    NSDictionary *headerFields = @{@"content-type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:headerFields];
    
    client = (MCKClient*)[[MCKResponseProcessor_TestClass alloc] init];
    [(MCKResponseProcessor_TestClass*)client setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    status = [[_MCKRequestStatus alloc] init];
    status.response = response;
});

describe(@"A nop processor", ^{
    __block MCKResponseProcessor *processor;
    
    before(^{
        processor = MCKResponseProcessor.nopProcessor;
        expect(processor).toNot.beNil();
    });
    
    beforeEach(^{
        ((MCKResponseProcessor_TestClass*)client).lastNext = nil;
        ((MCKResponseProcessor_TestClass*)client).lastError = nil;
    });
    
    it(@"should pass any input through", ^{
        MCKResponseSender sender = [processor processStatusUpdate:status fromClient:client];
        expect(sender).toNot.beNil();
        
        sender((RACSubject*)client);
		expect(((MCKResponseProcessor_TestClass*)client).lastNext).to.equal(status);
		expect(((MCKResponseProcessor_TestClass*)client).lastError).to.beNil();
    });
});

describe(@"A custom processor", ^{
    __block MCKResponseProcessor *processor;
    
    before(^{
        processor = [MCKResponseProcessor processorWithTarget:MCKResponseProcessor_TestClass.class
                                                     selector:@selector(processStatus:fromClient:)
                                                      context:nil];
        expect(processor).toNot.beNil();
    });
    
    beforeEach(^{
        ((MCKResponseProcessor_TestClass*)client).lastNext = nil;
        ((MCKResponseProcessor_TestClass*)client).lastError = nil;
    });
    
    it(@"should process its input", ^{
        MCKResponseSender sender = [processor processStatusUpdate:status fromClient:client];
        expect(sender).toNot.beNil();
        
        sender((RACSubject*)client);
		expect(((MCKResponseProcessor_TestClass*)client).lastNext).to.equal(@(YES));
		expect(((MCKResponseProcessor_TestClass*)client).lastError).to.beNil();
    });
});

describe(@"A custom processor with context", ^{
    __block MCKResponseProcessor *processor;
    
    before(^{
        processor = [MCKResponseProcessor processorWithTarget:MCKResponseProcessor_TestClass.class
                                                     selector:@selector(processStatus:fromClient:context:)
                                                      context:@"SomeContext"];
        expect(processor).toNot.beNil();
    });
    
    beforeEach(^{
        ((MCKResponseProcessor_TestClass*)client).lastNext = nil;
        ((MCKResponseProcessor_TestClass*)client).lastError = nil;
    });
    
    it(@"should process its input", ^{
        MCKResponseSender sender = [processor processStatusUpdate:status fromClient:client];
        
		sender((RACSubject*)client);
		expect(((MCKResponseProcessor_TestClass*)client).lastNext).to.equal(@"SomeContext");
		expect(((MCKResponseProcessor_TestClass*)client).lastError).to.beNil();
    });
});

SpecEnd
