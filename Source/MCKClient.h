//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKClient.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2015 D.V. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class MCKServer;
@class MCKResponseProcessor;

//---------------------------------------------------------------------------//
//! Represents the communication channel between the application and a
//! MediaCrush server.
//
@interface MCKClient : NSObject <NSCoding>

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Client
//! @name       Creating a Client
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Initializes the receiver to send requests to the given \a server.
//!
//! This is the designated initializer for this class.
//!
//! @param  identifier
//!         An identifier for this client.  Must not be \c nil of
//!         \a allowBackgrounding is \c YES.  Behavior is undefined if two
//!         \c MCKClient objects share the same identifier.
//! @param  allowBackgrounding
//!         If YES, download and upload tasks can be performed in the
//!         background, including when the app is suspended or terminated.
- (id)initWithServer:(MCKServer*)server identifier:(NSString*)identifier allowBackgrounding:(BOOL)allowBackgrounding;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Networking Sessions
//! @name       Configuring Networking Sessions
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The configuration object used to initialize the AFHTTPSessionManager
//! for networking.
//!
//! @note
//! Modifying the returned configuration will have no effect on clients that
//! have already been created.
+ (NSURLSessionConfiguration*)sessionConfiguration;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Responding to Background Events
//! @name       Responding to Background Events
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Signal that sends RACUnit whenever the background session managed by this
//! client receives a -URLSessionDidFinishEventsForBackgroundURLSession:
//! delegate message.
//!
//! Your application should subscribe to to this signal in
//! -application:handleEventsForBackgroundURLSession:completionHandler: to
//! know when to invoke \c completionHandler.  The signal may arrive on
//! any thread.
@property (nonatomic, readonly) RACSignal *backgroundEventsDidFinish;

//! Returns a signal that sends RACTuple(identifier, subject) for each active
//! background request.
//!
//! Subscribe to 'subject' to rejoin a request and continue tracking its
//! progress.  You should call this method in your app delegate's
//! -application:handleEventsForBackgroundURLSession:completionHandler:
//! method.
- (RACSignal*)backgroundRequests;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Surrogate Classes
//! @name       Configuring Surrogate Classes
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Configures a mapping of surrogate classes for the app.
//!
//! The table below lists the classes for which surrogates may be provided.
//!
//! @param  surrogateClassMap
//!         Key value pairs must be in the form NSString => Class.  The
//!         key is the name of the original class.  The value is the class
//!         object of the surrogate class.
//!
//! @note
//! Caling this method has no effect on existing \e MCKClient instances.
+ (void)setSurrogateClasses:(NSDictionary*)surrogateClassMap;

//! The surrogate class map of the receiver.
@property (nonatomic, copy, readonly) NSDictionary *surrogateClasses;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Configuration Options
//! @name       Accessing Configuration Options
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The identifier provided to the client at initialization or a UUID if
//! no identifier was provided.
@property (nonatomic, copy, readonly) NSString *identifier;

//! Whether this client can execute download and upload tasks in the
//! background.
@property (nonatomic, readonly) BOOL background;

//! The server for this client.
@property (nonatomic, copy, readonly) MCKServer *server;

//! The request serializer for this client.
@property (nonatomic, strong, readonly) id<AFURLRequestSerialization> requestSerializer;

//! The response serializer for this client.
@property (nonatomic, strong, readonly) id<AFURLResponseSerialization> responseSerializer;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Making Requests
//! @name       Making Requests
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates a mutable url request for the given API endpoint with the given
//! parameters.
- (NSMutableURLRequest*)requestWithMethod:(NSString*)method path:(NSString*)path parameters:(NSDictionary*)parameters;

//! Enqueues a request to be sent to the server.
- (RACSubject*)enqueueDataRequest:(NSURLRequest*)request responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid;

//! Enqueues a request to be sent to the server.
- (RACSubject*)enqueueDownloadRequest:(NSURLRequest*)request inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid;

//! Enqueues a request to be sent to the server.
- (RACSubject*)enqueueDownloadRequestWithResumeData:(NSData*)resumeData inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid;

//! Enqueues a request to be sent to the server.
- (RACSubject*)enqueueUploadRequest:(NSURLRequest*)request fromFile:(NSURL*)file inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid;

//! Enqueues a request to be sent to the server.
- (RACSubject*)enqueueUploadRequest:(NSURLRequest*)request fromData:(NSData*)data inBackground:(BOOL)inBackground responseProcessor:(MCKResponseProcessor*)responseProcessor identifier:(NSUUID**)uuid;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Requests
//! @name       Configuring Requests
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Cancel the request with \a uuid, optionally producing resume data.
//
//! When a request is cancelled, a \ref MCKClientErrorRequestCancelled
//! error is sent by the signal for the request.
- (void)cancelRequest:(NSUUID*)uuid withResumeData:(BOOL)resumeData;

@end
