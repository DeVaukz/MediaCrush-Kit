//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKServerSpec.m
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

SpecBegin(MCKServer)

it(@"should have a defaultServer", ^{
    MCKServer *defaultServer = MCKServer.defaultServer;
    
    expect(defaultServer).toNot.beNil();
    expect(defaultServer.baseURL).to.equal([NSURL URLWithString:@"https://mediacru.sh"]);
    expect(defaultServer.APIEndpoint).to.equal([NSURL URLWithString:@"https://mediacru.sh/api/"]);
    expect(defaultServer.baseWebURL).to.equal([NSURL URLWithString:@"https://mediacru.sh"]);
});

it(@"should be the only defaultServer", ^{
    MCKServer *defaultServer = [[MCKServer alloc] initWithBaseURL:nil];
    
    expect(defaultServer).to.equal(MCKServer.defaultServer);
});

it(@"can be a custom instance", ^{
    MCKServer *customServer = [[MCKServer alloc] initWithBaseURL:[NSURL URLWithString:@"https://mymediacru.sh"]];
    
    expect(customServer).toNot.beNil();
    expect(customServer).toNot.equal(MCKServer.defaultServer);
    expect(customServer.baseURL).to.equal([NSURL URLWithString:@"https://mymediacru.sh"]);
    expect(customServer.APIEndpoint).to.equal([NSURL URLWithString:@"https://mymediacru.sh/api/"]);
    expect(customServer.baseWebURL).to.equal([NSURL URLWithString:@"https://mymediacru.sh"]);
});

it(@"should use baseURL for equality", ^{
    MCKServer *defaultServer = MCKServer.defaultServer;
    MCKServer *manualDefaultServer = [[MCKServer alloc] initWithBaseURL:[NSURL URLWithString:@"https://mediacru.sh"]];
    
    MCKServer *aCustomServer = [[MCKServer alloc] initWithBaseURL:[NSURL URLWithString:@"https://mymediacru.sh"]];
    MCKServer *anotherCustomServer = [[MCKServer alloc] initWithBaseURL:[NSURL URLWithString:@"https://mymediacru.sh"]];
    MCKServer *aThirdCustomServer = [[MCKServer alloc] initWithBaseURL:[NSURL URLWithString:@"https://localhost"]];
    
    expect(defaultServer).to.equal(manualDefaultServer);
    expect(defaultServer).toNot.equal(aCustomServer);
    expect(defaultServer).toNot.equal(anotherCustomServer);
    expect(defaultServer).toNot.equal(aThirdCustomServer);
    
    expect(aCustomServer).to.equal(anotherCustomServer);
    expect(aCustomServer).toNot.equal(aThirdCustomServer);
    
    expect(anotherCustomServer).toNot.equal(aThirdCustomServer);
});

it(@"should be encodable", ^{
    MCKServer *aServer = [[MCKServer alloc] initWithBaseURL:nil];
    NSData *encodedServerData = [NSKeyedArchiver archivedDataWithRootObject:aServer];
    MCKServer *theSameServer = [NSKeyedUnarchiver unarchiveObjectWithData:encodedServerData];
    
    expect(aServer).to.equal(theSameServer);
});

it(@"should be copyable", ^{
    MCKServer *aServer = [[MCKServer alloc] initWithBaseURL:nil];
    MCKServer *aCopyOfServer = [aServer copy];
    
    expect(aServer).to.equal(aCopyOfServer);
});

SpecEnd
