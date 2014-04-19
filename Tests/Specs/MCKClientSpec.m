//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClientSpec.m
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

SpecBegin(MCKClient)

void (^stubResponseWithStatusCodeAndHeaders)(NSString *, NSString *, int, NSDictionary *) = ^(NSString *path, NSString *responseFilename, int statusCode, NSDictionary *headers)
{
	headers = [headers mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"Content-Type": @"application/json",
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqual:path];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest __unused *request) {
        NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:responseFilename.stringByDeletingPathExtension withExtension:responseFilename.pathExtension];
		return [[OHHTTPStubsResponse responseWithFileAtPath:[fileURL path] statusCode:statusCode headers:headers] responseTime:0];
    }];
};

void (^stubResponseWithStatusCode)(NSString *, int) = ^(NSString *path, int statusCode)
{
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
    };
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqual:path];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest __unused *request) {
		return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:statusCode headers:headers] responseTime:0];
    }];
};


__block BOOL success;
__block NSError *error;

beforeEach(^{
	success = NO;
	error = nil;
});

it(@"should not initialize without a server", ^{
    MCKClient *client = [[MCKClient alloc] initWithServer:nil identifier:@"client" allowBackgrounding:NO];
    expect(client).to.beNil();
});

describe(@"A generic MCKClient", ^{
    __block MCKClient *client;
    
    beforeAll(^{
        [MCKClient setSurrogateClasses:nil];
    });
    
    beforeEach(^{
        client = [[MCKClient alloc] initWithServer:MCKServer.defaultServer identifier:nil allowBackgrounding:NO];
        expect(client).notTo.beNil();
        expect(client.identifier).toNot.beNil();
        expect(client.background).to.beFalsy();
        expect(client.server).to.equal(MCKServer.defaultServer);
        expect(client.surrogateClasses).to.beNil();
    });
    
    it(@"should be able to create a GET request", ^{
        NSURLRequest *request = [client requestWithMethod:@"GET" path:@"anEndpoint" parameters:nil];
        expect(request).toNot.beNil();
        expect(request.URL).to.equal([NSURL URLWithString:@"https://mediacru.sh/api/anEndpoint"]);
    });
    
    it(@"should be able to create a POST request", ^{
        NSURLRequest *request = [client requestWithMethod:@"POST" path:@"anEndpoint" parameters:nil];
        expect(request).toNot.beNil();
        expect(request.URL).to.equal([NSURL URLWithString:@"https://mediacru.sh/api/anEndpoint"]);
    });
    
    it(@"should be able to create a DELETE request", ^{
        NSURLRequest *request = [client requestWithMethod:@"DELETE" path:@"anEndpoint" parameters:nil];
        expect(request).toNot.beNil();
        expect(request.URL).to.equal([NSURL URLWithString:@"https://mediacru.sh/api/anEndpoint"]);
    });
    
    it(@"should GET an endpoint", ^{
        stubResponseWithStatusCodeAndHeaders(@"/api/tVWMM_ziA3nm/exists", @"exists_true.json", 200, @{});
        
        NSURLRequest *request = [client requestWithMethod:@"GET" path:@"tVWMM_ziA3nm/exists" parameters:nil];
        RACSignal *signal = [client enqueueDataRequest:request responseProcessor:MCKResponseProcessor.nopProcessor identifier:NULL];
        expect(signal).toNot.beNil();
        
        __block id<MCKRequestStatus> lastStatus = nil;
        [signal subscribeNext:^(id<MCKRequestStatus> x) {
            expect(x).to.conformTo(@protocol(MCKRequestStatus));
            expect(x.uuid).toNot.beNil();
            lastStatus = x;
        }];
        expect([signal asynchronouslyWaitUntilCompleted:&error]).to.beTruthy();
        
        expect([lastStatus.result asynchronousFirstOrDefault:nil success:&success error:&error]).toNot.beNil();
		expect(success).to.beTruthy();
		expect(error).to.beNil();
    });
    
    describe(@"The /exists endpoint", ^{
        it(@"should return true if an objectID exists", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/tVWMM_ziA3nm/exists", @"exists_true.json", 200, @{});
            
            RACSignal *signal = [client existsObjectWithID:@"tVWMM_ziA3nm"];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.equal(@(YES));
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
        
        it(@"should return false if an objectID does not exist", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/idontexist/exists", @"exists_false.json", 200, @{});
            
            RACSignal *signal = [client existsObjectWithID:@"idontexist"];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.equal(@(NO));
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
        
        it(@"should fail gracefully", ^{
            stubResponseWithStatusCode(@"/api/causesanerror/exists", 500);
            
            RACSignal *signal = [client existsObjectWithID:@"causesanerror"];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil;
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
        });
    });
    
    describe(@"The /delete endpoint", ^{
        it(@"should delete and object", ^{
            stubResponseWithStatusCode(@"/api/deleteme", 200);
            
            RACSignal *signal = [client deleteObjectWithID:@"deleteme"];
            [signal asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
        
        it(@"should know when you don't have permission to delete an object", ^{
            stubResponseWithStatusCode(@"/api/deleteme", 401);
            
            RACSignal *signal = [client deleteObjectWithID:@"deleteme"];
            [signal asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
            expect(@([error code])).to.equal(@(MCKAPIErrorPermissionDenied));
        });
        
        it(@"should know when an object does not exist", ^{
            stubResponseWithStatusCode(@"/api/deleteme", 404);
            
            RACSignal *signal = [client deleteObjectWithID:@"deleteme"];
            [signal asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
            expect(@([error code])).to.equal(@(MCKAPIErrorObjectNotFound));
        });
    });
    
    describe(@"The /url/info endpoint", ^{
        it(@"should return information about given URLs", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/url/info", @"url-info_valid.json", 200, @{});
            
            RACSignal *signal = [client infoForURLs:@[[NSURL URLWithString:@"http://i.imgur.com/rctIj1M.jpg"], [NSURL URLWithString:@"http://does.not/exist.gif"]]];
            expect(signal).toNot.beNil();
            
            __block NSUInteger i = 0;
            [signal subscribeNext:^(RACTuple *objectIdFileTuple) {
                expect(@(i)).to.beLessThan(@(2));
                RACTupleUnpack(NSURL *url, MCKFile *file) = objectIdFileTuple;
                expect(url).to.beKindOf(NSURL.class);
                if (i++ == 0)
                    expect(file).to.beKindOf(NSNull.class);
                else
                    expect(file).to.beKindOf(MCKFile.class);
            }];
            
            expect([signal asynchronouslyWaitUntilCompleted:&error]).to.beTruthy();
            expect(@(i)).to.equal(@(2));
            expect(error).to.beNil();
        });
        
        it(@"should fail gracefully", ^{
            stubResponseWithStatusCode(@"/api/url/info", 500);
            
            RACSignal *signal = [client infoForURLs:@[[NSURL URLWithString:@"http://i.imgur.com/rctIj1M.jpg"]]];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil;
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
        });
    });
    
    describe(@"The album /info endpoint", ^{
        it(@"should return information about given URLs", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/info", @"album-info_valid.json", 200, @{});
            
            RACSignal *signal = [client infoForAlbumsWithIDs:@[@"tVWMM_ziA3nm", @"CPvuR5lRhmS0"]];
            expect(signal).toNot.beNil();
            
            __block NSUInteger i = 0;
            [signal subscribeNext:^(RACTuple *objectIdFileTuple) {
                expect(@(i)).to.beLessThan(@(2));
                RACTupleUnpack(NSURL *url, MCKFile *file) = objectIdFileTuple;
                expect(url).to.beKindOf(NSURL.class);
                if (i++ == 0)
                    expect(file).to.beKindOf(NSNull.class);
                else
                    expect(file).to.beKindOf(MCKAlbum.class);
            }];
            
            expect([signal asynchronouslyWaitUntilCompleted:&error]).to.beTruthy();
            expect(@(i)).to.equal(@(2));
            expect(error).to.beNil();
        });
        
        it(@"should fail gracefully", ^{
            stubResponseWithStatusCode(@"/api/info", 500);
            
            RACSignal *signal = [client infoForAlbumsWithIDs:@[@"tVWMM_ziA3nm", @"CPvuR5lRhmS0"]];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil;
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
        });
    });
    
    describe(@"The /album/create endpoint", ^{
        it(@"should create an album", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/album/create", @"album-create.json", 200, @{});
            
            RACSignal *signal = [client createAlbumContainingFilesWithIDs:@[@"LxqXxVPAvqqB", @"tVWMM_ziA3nm"]];
            expect(signal).toNot.beNil();
            
            MCKObject *result = [signal asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(result.objectID).to.equal(@"LxqXxVPAvqqC");
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
    });
    
    describe(@"The /flags endpoint", ^{
        it(@"should return flags for the given objectID", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/Ta-nbchtCw6d/flags", @"flags_valid.json", 200, @{});
            
            RACSignal *signal = [client fetchFlagsForFileID:@"Ta-nbchtCw6d"];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).toNot.beNil();
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
        
        it(@"should modify the flags for an ObjectID", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/Ta-nbchtCw6d/flags", @"flags_valid.json", 200, @{});
            
            MCKFileFlagsEdit *edit = [[MCKFileFlagsEdit alloc] init];
            edit.autoplay = YES;
            edit.loop = YES;
            edit.mute = YES;
            
            MCKFileFlags *flags = [[MCKFileFlags alloc] initWithDictionary:edit.dictionaryValue error:NULL];
            
            RACSignal *signal = [client applyEdit:edit toFileWithID:@"Ta-nbchtCw6d"];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.equal(flags);
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
        
        it(@"should fail gracefully", ^{
            stubResponseWithStatusCode(@"/api/derp/flags", 500);
            
            RACSignal *signal = [client fetchFlagsForFileID:@"derp"];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil;
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
        });
    });
    
    describe(@"The file /info endpoint", ^{
        it(@"should return information about given URLs", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/info", @"file-info_valid.json", 200, @{});
            
            RACSignal *signal = [client fetchFilesWithIDs:@[@"tVWMM_ziA3nm", @"CPvuR5lRhmS0"]];
            expect(signal).toNot.beNil();
            
            __block NSUInteger i = 0;
            [signal subscribeNext:^(RACTuple *objectIdFileTuple) {
                expect(@(i)).to.beLessThan(@(2));
                RACTupleUnpack(NSURL *url, MCKFile *file) = objectIdFileTuple;
                expect(url).to.beKindOf(NSURL.class);
                if (i++ == 0)
                    expect(file).to.beKindOf(NSNull.class);
                else
                    expect(file).to.beKindOf(MCKFile.class);
            }];
            
            expect([signal asynchronouslyWaitUntilCompleted:&error]).to.beTruthy();
            expect(@(i)).to.equal(@(2));
            expect(error).to.beNil();
        });
        
        it(@"should fail gracefully", ^{
            stubResponseWithStatusCode(@"/api/info", 500);
            
            RACSignal *signal = [client fetchFilesWithIDs:@[@"tVWMM_ziA3nm", @"CPvuR5lRhmS0"]];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.beNil;
            expect(success).to.beFalsy();
            expect(error).toNot.beNil();
        });
    });
    
    describe(@"The /status endpoint", ^{
        it(@"should return information about on-going processing", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/status", @"status_incomplete.json", 200, @{});
            
            RACSignal *signal = [client statusOfUploadsWithIDs:@[@"tVWMM_ziA3nm"]];
            RACTuple *result = [signal asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(result).toNot.beNil();
            expect(success).to.beTruthy();
            expect(error).to.beNil();
            
            RACTupleUnpack(NSString *objectID, NSString *status, MCKFile *file) = result;
            expect(objectID).to.equal(@"tVWMM_ziA3nm");
            expect(status).to.equal(MCKUploadStatusProcessing);
            expect(file).to.beNil();
        });
        
        it(@"should return information about a completed upload", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/status", @"status_complete.json", 200, @{});
            
            RACSignal *signal = [client statusOfUploadsWithIDs:@[@"CPvuR5lRhmS0"]];
            RACTuple *result = [signal asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(result).toNot.beNil();
            expect(success).to.beTruthy();
            expect(error).to.beNil();
            
            RACTupleUnpack(NSString *objectID, NSString *status, MCKFile *file) = result;
            expect(objectID).to.equal(@"CPvuR5lRhmS0");
            expect(status).to.equal(MCKUploadStatusDone);
            expect(file).toNot.beNil();
        });
    });
    
    describe(@"The /upload endpoint", ^{
        it(@"should upload a URL", ^{
            stubResponseWithStatusCodeAndHeaders(@"/api/upload/url", @"upload_valid.json", 200, @{});
            
            RACSignal *signal = [client uploadURL:[NSURL URLWithString:@"http://i.imgur.com/f7f568.jpg"]];
            expect([signal asynchronousFirstOrDefault:nil success:&success error:&error]).to.equal(@"LxqXxVPAvqqB");
            expect(success).to.beTruthy();
            expect(error).to.beNil();
        });
    });
    
});

SpecEnd