//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKClient.m
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

#import "MCKClient.h"
#import "MCKConstants.h"
#import "MCKServer.h"
#import "MCKObject_Private.h"
#import "NSURLSessionConfiguration+MCKCopying.h"
#import "MCKRequestStatus_Private.h"
#import "MCKResponseProcessor.h"

#import <objc/runtime.h>

// Used to access the _MCKRequest associated with an NSURLSessionTask.
const char * const MCKRequestAssociationKey = "MCKRequestAssociationKey";

static NSDictionary *SurrogateClasses = nil;


//---------------------------------------------------------------------------//
// Private methods from RACReplaySubject.
@interface RACReplaySubject (Intenral)
- (instancetype)initWithCapacity:(NSUInteger)capacity;
@end



//---------------------------------------------------------------------------//
@interface _MCKRequest : RACReplaySubject <NSCoding> {
    // Private queue for handling task delegate methods.
    dispatch_queue_t _queue;
}
@property (nonatomic, strong, readonly) NSUUID *uuid;
@property (nonatomic, strong, readonly) MCKResponseProcessor *responseProcessor;
+ (id)decodeFromString:(NSString*)aString;
+ (NSString*)encodeToString:(_MCKRequest*)aRequest;
- (instancetype)initWithUUID:(NSUUID*)uuid responseProcessor:(MCKResponseProcessor*)responseProcessor;
/* Delegate Callbacks */
/* All of these callbacks occur on the client's delegate queue. */
- (void)client:(MCKClient*)client taskDidResume:(NSURLSessionTask*)task;
- (void)client:(MCKClient*)client task:(NSURLSessionTask*)task didCancelWithResumeData:(NSData*)resumeData;
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
@end


@implementation _MCKRequest

//|++++++++++++++++++++++++++++++++++++|//
+ (id)decodeFromString:(NSString*)aString
{
    NSData *archiveData = [[NSData alloc] initWithBase64EncodedString:aString options:0];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archiveData];
    Class classToUnarchive = NSClassFromString([unarchiver decodeObjectForKey:@"Class"]);
    return [[classToUnarchive alloc] initWithCoder:unarchiver];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)encodeToString:(_MCKRequest*)aRequest
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:aRequest];
    return [encodedObject base64EncodedStringWithOptions:0];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithUUID:(NSUUID*)uuid responseProcessor:(MCKResponseProcessor*)responseProcessor
{
    self = [super initWithCapacity:1];
    if (self == nil) return nil;
    
    _uuid = [uuid copy];
    _responseProcessor = responseProcessor;
    
    _queue = dispatch_queue_create("com.mediacrushkit._MCKRequest", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCapacity:1];
    if (self == nil) return nil;
    
    _uuid = [aDecoder decodeObjectForKey:@"UUID"];
    _responseProcessor = [aDecoder decodeObjectForKey:@"ResponseProcessor"];
    
    _queue = dispatch_queue_create("com.mediacrushkit._MCKRequest", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    /* Always record the version number. */
    [aCoder encodeObject:[NSString stringWithUTF8String:metamacro_stringify(MCK_VERSION)] forKey:@"Version"];
    [aCoder encodeObject:NSStringFromClass([self class]) forKey:@"Class"];
    
    [aCoder encodeObject:_uuid forKey:@"UUID"];
    [aCoder encodeObject:_responseProcessor forKey:@"ResponseProcessor"];
}

//|++++++++++++++++++++++++++++++++++++|//
- (MCKResponseSender)_nextForTask:(NSURLSessionTask*)task state:(MCKRequestState)state content:(id)content client:(MCKClient*)client
{
    NSParameterAssert(task);
    NSParameterAssert(client);
    
    _MCKRequestStatus *status = [[_MCKRequestStatus alloc] init];
    
    status.uuid = self.uuid;
    status.state = state;
    status.response = (NSHTTPURLResponse*)task.response;
    status.responseContents = content;
    
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        status.expectedSize = task.countOfBytesExpectedToReceive;
        status.fractionCompleted = (float)task.countOfBytesReceived / task.countOfBytesExpectedToReceive;
    } else {
        status.expectedSize = task.countOfBytesExpectedToReceive;
        status.fractionCompleted = (float)task.countOfBytesSent / task.countOfBytesExpectedToSend;
    }
    
    MCKResponseSender retValue = [self.responseProcessor processStatusUpdate:status fromClient:client];
    if (retValue)
        return retValue;
    else
        return ^(RACSubject __unused *subject) { return; };
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client taskDidResume:(NSURLSessionTask*)task
{
    dispatch_async(_queue, ^{
        [self _nextForTask:task state:MCKRequestStateRunning content:nil client:client](self);
    });
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionTask*)task didCancelWithResumeData:(NSData*)resumeData
{
#pragma unused (task)
#pragma unused (client)
    
    dispatch_async(_queue, ^{
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: NSLocalizedString(@"The request was cancelled", @"")
        };
        if (resumeData) {
            userInfo = [userInfo mtl_dictionaryByAddingEntriesFromDictionary:@{
                MCKClientErrorResumeDataKey: resumeData
            }];
        }
        [self sendError:[NSError errorWithDomain:MCKErrorDomain code:MCKClientErrorRequestCancelled userInfo:userInfo]];
    });
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#pragma unused (client)
#pragma unused (task)
#pragma unused (error)
    NSAssert(NO, @"Subclasses must override %@", NSStringFromSelector(_cmd));
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
#pragma unused (client)
#pragma unused (bytesSent)
#pragma unused (totalBytesSent)
#pragma unused (totalBytesExpectedToSend)
    
    dispatch_async(_queue, ^{
        [self _nextForTask:task state:MCKRequestStateRunning content:nil client:client](self);
    });
}

@end



//---------------------------------------------------------------------------//
@interface _MCKDataRequest : _MCKRequest
@property (nonatomic, strong) NSMutableData *data;
/* Delegate Callbacks */
- (void)client:(MCKClient*)client task:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
- (void)client:(MCKClient*)client task:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
@end
@implementation _MCKDataRequest

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
#pragma unused (client)
#pragma unused (response)
    
    dispatch_async(_queue, ^{
        self.data = [[NSMutableData alloc] initWithCapacity:(dataTask.countOfBytesExpectedToReceive != NSURLSessionTransferSizeUnknown) ?: 0];
        [self _nextForTask:dataTask state:MCKRequestStateRunning content:self.data client:client](self);
        completionHandler(NSURLSessionResponseAllow);
    });
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
#pragma unused (client)
#pragma unused (dataTask)
    
    dispatch_async(_queue, ^{
        [self.data appendData:data];
        [self _nextForTask:dataTask state:MCKRequestStateRunning content:self.data client:client](self);
    });
}

//|++++++++++++++++++++++++++++++++++++|//
// Override
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#pragma unused (client)
    
    dispatch_async(_queue, ^{
        if (error) {
            [self sendError:error];
        } else {
            [self _nextForTask:task state:MCKRequestStateComplete content:self.data client:client](self);
            [self sendCompleted];
        }
    });
}

@end



//---------------------------------------------------------------------------//
@interface _MCKDownloadRequest : _MCKRequest
- (void)client:(MCKClient*)client task:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;
- (void)client:(MCKClient*)client task:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
- (void)client:(MCKClient*)client task:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
@end
@implementation _MCKDownloadRequest

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
#pragma unused (client)
#pragma unused (fileOffset)
#pragma unused (expectedTotalBytes)
    
    dispatch_async(_queue, ^{
        [self _nextForTask:downloadTask state:MCKRequestStateRunning content:nil client:client](self);
    });
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
#pragma unused (client)
#pragma unused (bytesWritten)
#pragma unused (totalBytesWritten)
#pragma unused (totalBytesExpectedToWrite)
    
    dispatch_async(_queue, ^{
        [self _nextForTask:downloadTask state:MCKRequestStateRunning content:nil client:client](self);
    });
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)client:(MCKClient*)client task:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    /* Must execute before this method returns. */
    MCKResponseSender invocation = [self _nextForTask:downloadTask state:MCKRequestStateComplete content:location client:client];
    
    dispatch_async(_queue, ^{
        invocation(self);
        [self sendCompleted];
    });
    
}

//|++++++++++++++++++++++++++++++++++++|//
// Override
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#pragma unused (client)
#pragma unused (task)
    
    if (error)
        dispatch_async(_queue, ^{
            [self sendError:error];
        });
    /* Don't do anything; -task:didFinishDownloadingToURL: is where the
     * action happens for download tasks. */
}

@end



//---------------------------------------------------------------------------//
@interface _MCKUploadRequest : _MCKDataRequest
@end
@implementation _MCKUploadRequest

//|++++++++++++++++++++++++++++++++++++|//
// Override
- (void)client:(MCKClient*)client task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#pragma unused (client)
    
    dispatch_async(_queue, ^{
        if (error) {
            [self sendError:error];
        } else {
            [self _nextForTask:task state:MCKRequestStateComplete content:self.data client:client](self);
            [self sendCompleted];
        }
    });
}

@end



//---------------------------------------------------------------------------//
@interface MCKClient () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
{
    RACSubject *_backgroundEventsDidFinishSubject;
}
/* State */
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) MCKServer *server;
@property (nonatomic, copy) NSDictionary *surrogateClasses;
@property (nonatomic, strong) NSMutableDictionary *tasksByIdentifier;
/* Temporary */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, strong) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSURLSession *dataSession;
@property (nonatomic, strong) NSURLSession *bulkSession;
@end


@implementation MCKClient

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Creating a Client
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)_commonInitWithServer:(MCKServer*)server identifier:(NSString*)identifier allowBackgrounding:(BOOL)allowBackgrounding
{
    if (server == nil) return nil;
    if (identifier.length == 0) return nil;
    
    _identifier = identifier;
    _server = server;
    
    @synchronized([self class]) {
        _surrogateClasses = [SurrogateClasses copy];
    }
    
    _tasksByIdentifier = [[NSMutableDictionary alloc] init];
    
    // TODO - Get this from the server once cert. pinning is implemented
    _securityPolicy = [AFSecurityPolicy defaultPolicy];
    
    _requestSerializer = [AFJSONRequestSerializer serializer];
    _responseSerializer = [AFJSONResponseSerializer serializer];
    
    _lock = [[NSLock alloc] init];
    _lock.name = [NSString stringWithFormat:@"MCKClient (%@) Lock", identifier];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    /* If this isn't 1, the session will create another queue behind our 
     * back. */
    _operationQueue.maxConcurrentOperationCount = 1;
    _operationQueue.name = identifier;
    
    NSURLSessionConfiguration *currentConfiguration = [[[self class] sessionConfiguration] copy];
    _dataSession = [NSURLSession sessionWithConfiguration:currentConfiguration delegate:self delegateQueue:_operationQueue];
    _bulkSession = _dataSession;
    
    if (allowBackgrounding) {
        _backgroundEventsDidFinishSubject = [RACSubject subject];
        
        NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
        NSURLSessionCopyConfiguration(backgroundConfiguration, currentConfiguration);
        
        _bulkSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:_operationQueue];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (id)init
{ NSAssert(NO, @"Use -initWithServer:identifier:allowBackgrounding: instead."); return nil; }

//|++++++++++++++++++++++++++++++++++++|//
- (id)initWithServer:(MCKServer*)server identifier:(NSString*)identifier allowBackgrounding:(BOOL)allowBackgrounding
{
    self = [super init];
    if (self == nil) return nil;
    
    if (!identifier || identifier.length < 1)
        identifier = [[NSUUID UUID] UUIDString];
    
    return [self _commonInitWithServer:[server copy]
                            identifier:[identifier copy]
                    allowBackgrounding:allowBackgrounding];
    
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSCoding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self == nil) return nil;
    
    NSString *identifier = [aDecoder decodeObjectForKey:@"Identifier"];
    MCKServer *server = [aDecoder decodeObjectForKey:@"Server"];
    BOOL background = [aDecoder decodeBoolForKey:@"Background"];
    
    return [self _commonInitWithServer:server identifier:identifier allowBackgrounding:background];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    /* Always record the version number. */
    [aCoder encodeObject:[NSString stringWithUTF8String:metamacro_stringify(MCK_VERSION)] forKey:@"Version"];
        
    [aCoder encodeObject:self.identifier forKey:@"Identifier"];
    [aCoder encodeObject:self.server forKey:@"Server"];
    [aCoder encodeBool:self.background forKey:@"Background"];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Configuring Networking Sessions
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)_userAgent
{
    NSString *userAgent = NSProcessInfo.processInfo.environment[@"MCK_API_USER_AGENT"];
    if (userAgent)
        NSLog(@"* MCKClient: Using custom user agent from environment - %@", userAgent);
    else
        userAgent = [NSString stringWithFormat:@"MediaCrushKit/%s (Macintosh; %@)", metamacro_stringify(MCK_VERSION), NSProcessInfo.processInfo.operatingSystemVersionString];
    
    return userAgent;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSURLSessionConfiguration*)sessionConfiguration
{
    static NSURLSessionConfiguration *SessionConfiguration;
    if (SessionConfiguration == nil) {
        SessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        [SessionConfiguration setHTTPAdditionalHeaders:@{@"User-Agent": self._userAgent,
                                                         @"Accept": @"text/json"}];
        [SessionConfiguration setHTTPCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
    }
    return SessionConfiguration;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Responding to Background Events
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)backgroundEventsDidFinish
{ return _backgroundEventsDidFinishSubject; }

//|++++++++++++++++++++++++++++++++++++|//
- (RACSignal*)backgroundRequests
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [_bulkSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            for (NSURLSessionTask *task in dataTasks) {
                _MCKRequest *request = [self _requestForTask:task];
                if (!request) {
                    NSLog(@"MCKClient: Could not lookup request for data task %@", task);
                    continue;
                }
                [subscriber sendNext:RACTuplePack(request.uuid, request)];
            }
            for (NSURLSessionTask *task in uploadTasks) {
                _MCKRequest *request = [self _requestForTask:task];
                if (!request) {
                    NSLog(@"MCKClient: Could not lookup request for upload task %@", task);
                    continue;
                }
                [subscriber sendNext:RACTuplePack(request.uuid, request)];
            }
            for (NSURLSessionTask *task in downloadTasks) {
                _MCKRequest *request = [self _requestForTask:task];
                if (!request) {
                    NSLog(@"MCKClient: Could not lookup request for download task %@", task);
                    continue;
                }
                [subscriber sendNext:RACTuplePack(request.uuid, request)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Configuring Surrogate Classes
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (void)setSurrogateClasses:(NSDictionary*)surrogateClassMap
{
    @synchronized(self) {
        SurrogateClasses = [surrogateClassMap copy];
    }
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Accessing Configuration Options
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)background
{ return _dataSession != _bulkSession; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Requests
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
// Safe to call from any thread.
- (_MCKRequest*)_requestForTask:(NSURLSessionTask*)aTask
{
    _MCKRequest *retValue = objc_getAssociatedObject(aTask, MCKRequestAssociationKey);
    if (retValue)
        return retValue;
    
    /* Slow path */
    [self.lock lock];
    {
        /* In case another thread beat us to it. */
        retValue = objc_getAssociatedObject(aTask, MCKRequestAssociationKey);
        if (retValue == nil) {
            retValue = [_MCKRequest decodeFromString:aTask.taskDescription];
            if (retValue) {
                objc_setAssociatedObject(aTask, MCKRequestAssociationKey, retValue, OBJC_ASSOCIATION_RETAIN);
                self.tasksByIdentifier[retValue.uuid] = aTask;
            }
        }
    }
    [self.lock unlock];
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
// Safe to call from any thread.
- (BOOL)_addRequest:(_MCKRequest*)request forTask:(NSURLSessionTask*)aTask
{
    if (!request || !aTask) return NO;
    
    BOOL retValue = NO;
    [self.lock lock];
    {
        NSString *encodedRequest = [_MCKRequest encodeToString:request];
        if (encodedRequest) {
            aTask.taskDescription = encodedRequest;
            objc_setAssociatedObject(aTask, MCKRequestAssociationKey, request, OBJC_ASSOCIATION_RETAIN);
            self.tasksByIdentifier[request.uuid] = aTask;
            retValue = YES;
        }
    }
    [self.lock unlock];
    NSAssert(retValue, @"Failed to encode request %@.  This is likely a bug.", request);
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
// Safe to call from any thread.
- (void)_disassociateTaskWithUUID:(NSUUID*)uuid
{
    if (!uuid) return;
    
    [self.lock lock];
    [self.tasksByIdentifier removeObjectForKey:uuid];
    [self.lock unlock];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Making Requests
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSMutableURLRequest*)requestWithMethod:(NSString*)method path:(NSString*)path parameters:(NSDictionary*)parameters
{
    NSParameterAssert(method != nil);
    
    return [(AFHTTPRequestSerializer*)self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:self.server.APIEndpoint] absoluteString] parameters:parameters error:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
//  Creating tasks using NSURLSession is thread safe.
- (RACSubject*)_enqueueRequestReturnedByCreator:(RACTuple* (^)(void))requestCreator
{
    _MCKRequest *retValue;
    RACTupleUnpack(NSURLSessionTask *task, _MCKRequest *request) = requestCreator();
    
    if (!task) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Could not create a task for the request.", @""), };
        retValue = (_MCKRequest*)[RACSignal error:[NSError errorWithDomain:MCKErrorDomain code:MCKClientErrorRequestEnqueueFailed userInfo:userInfo]];
    }
    else if (![self _addRequest:request forTask:task]) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Could not enqueue the request.", @""), };
        retValue = (_MCKRequest*)[RACSignal error:[NSError errorWithDomain:MCKErrorDomain code:MCKClientErrorRequestEnqueueFailed userInfo:userInfo]];
        [task cancel];
    }
    else /* Success */ {
        retValue = request;
        [task resume];
        [request client:self taskDidResume:task];
    }
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSubject*)enqueueDataRequest:(NSURLRequest*)request responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid
{
    NSUUID *requestUUID = [NSUUID UUID];
    if (uuid) *uuid = requestUUID;
    
    @weakify(self);
    return [self _enqueueRequestReturnedByCreator:^RACTuple *{
        @strongify(self);
        NSURLSessionTask *task = [self.dataSession dataTaskWithRequest:request];
        return RACTuplePack(task, [[_MCKDataRequest alloc] initWithUUID:requestUUID responseProcessor:responseProcessor]);
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSubject*)enqueueDownloadRequest:(NSURLRequest*)request inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid
{
    NSUUID *requestUUID = [NSUUID UUID];
    if (uuid) *uuid = requestUUID;
    
    @weakify(self);
    return [self _enqueueRequestReturnedByCreator:^RACTuple *{
        @strongify(self);
        NSURLSession *session = (inBackground ? self.bulkSession : self.dataSession);
        NSURLSessionTask *task = [session downloadTaskWithRequest:request];
        return RACTuplePack(task, [[_MCKDownloadRequest alloc] initWithUUID:requestUUID responseProcessor:responseProcessor]);
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSubject*)enqueueDownloadRequestWithResumeData:(NSData*)resumeData inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid
{
    NSUUID *requestUUID = [NSUUID UUID];
    if (uuid) *uuid = requestUUID;
    
    @weakify(self);
    return [self _enqueueRequestReturnedByCreator:^RACTuple *{
        @strongify(self);
        NSURLSession *session = (inBackground ? self.bulkSession : self.dataSession);
        NSURLSessionTask *task = [session downloadTaskWithResumeData:resumeData];
        return RACTuplePack(task, [[_MCKDownloadRequest alloc] initWithUUID:requestUUID responseProcessor:responseProcessor]);
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSubject*)enqueueUploadRequest:(NSURLRequest*)request fromFile:(NSURL*)file inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid
{
    NSUUID *requestUUID = [NSUUID UUID];
    if (uuid) *uuid = requestUUID;
    
    @weakify(self);
    return [self _enqueueRequestReturnedByCreator:^RACTuple *{
        @strongify(self);
        NSURLSession *session = (inBackground ? self.bulkSession : self.dataSession);
        NSURLSessionTask *task = [session uploadTaskWithRequest:request fromFile:file];
        return RACTuplePack(task, [[_MCKUploadRequest alloc] initWithUUID:requestUUID responseProcessor:responseProcessor]);
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
- (RACSubject*)enqueueUploadRequest:(NSURLRequest*)request fromData:(NSData*)data inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid
{
    NSUUID *requestUUID = [NSUUID UUID];
    if (uuid) *uuid = requestUUID;
    
    @weakify(self);
    return [self _enqueueRequestReturnedByCreator:^RACTuple *{
        @strongify(self);
        NSURLSession *session = (inBackground ? self.bulkSession : self.dataSession);
        NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:data];
        return RACTuplePack(task, [[_MCKUploadRequest alloc] initWithUUID:requestUUID responseProcessor:responseProcessor]);
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Configuring Requests
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)cancelRequest:(NSUUID*)uuid withResumeData:(BOOL)resumeData
{
    [self.lock lock];
    NSURLSessionTask *task = self.tasksByIdentifier[uuid];
    [self.lock unlock];
    if (task == nil)
        return;
    
    _MCKRequest *request = [self _requestForTask:task];
    
    // Disavow any knowledge of the task
    [self _disassociateTaskWithUUID:uuid];
    
    if (resumeData && [task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        [(NSURLSessionDownloadTask*)task cancelByProducingResumeData:^(NSData *resumeData) {
            [request client:self task:task didCancelWithResumeData:resumeData];
        }];
    } else {
        [task cancel];
        [self.operationQueue addOperationWithBlock:^{
            [request client:self task:task didCancelWithResumeData:nil];
        }];
    }
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSURLSessionDelegate
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
#pragma unused (session)

    [_backgroundEventsDidFinishSubject sendNext:[RACUnit defaultUnit]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSURLSessionTaskDelegate
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#pragma unused (session)

    _MCKRequest *request = [self _requestForTask:task];
    
    // Disavow any knowledge of the task
    [self _disassociateTaskWithUUID:request.uuid];
    
    [request client:self task:task didCompleteWithError:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
#pragma unused (session)
    
    [[self _requestForTask:task] client:self task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSURLSessionDataDelegate
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
#pragma unused (session)
    
    _MCKRequest *request = [self _requestForTask:dataTask];
    if ([request respondsToSelector:@selector(client:task:didReceiveResponse:completionHandler:)])
        [(_MCKDataRequest*)request client:self task:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
#pragma unused (session)
    
    _MCKRequest *request = [self _requestForTask:dataTask];
    if ([request respondsToSelector:@selector(client:task:didReceiveData:)])
        [(_MCKDataRequest*)request client:self task:dataTask didReceiveData:data];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSURLSessionDownloadDelegate
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
#pragma unused (session)
    
    _MCKRequest *request = [self _requestForTask:downloadTask];
    if ([request respondsToSelector:@selector(client:task:didResumeAtOffset:expectedTotalBytes:)])
        [(_MCKDownloadRequest*)request client:self task:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
#pragma unused (session)
    
    _MCKRequest *request = [self _requestForTask:downloadTask];
    if ([request respondsToSelector:@selector(client:task:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)])
        [(_MCKDownloadRequest*)request client:self task:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
#pragma unused (session)
    
    _MCKRequest *request = [self _requestForTask:downloadTask];
    if ([request respondsToSelector:@selector(client:task:didFinishDownloadingToURL:)])
        [(_MCKDownloadRequest*)request client:self task:downloadTask didFinishDownloadingToURL:location];
}

@end
