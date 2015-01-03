//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKResponseProcessor.h
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

#import <Mantle/Mantle.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class MCKClient;

//---------------------------------------------------------------------------//
//! @relates    MCKResponseProcessor
//!
//! A block returned by a response processor's invocation, which sends the
//! processed data to the request's subject.
//
typedef void (^MCKResponseSender)(RACSubject *subject);



//---------------------------------------------------------------------------//
//! @name       Response Processor Options
//! @relates    MCKResponseProcessor
//

//! The description to use for any errors raised during processing.
//!
//! (Optional) Must be an \c NSString object if present.
extern NSString * const MCKResponseProcesorOptionErrorDescription;

//! A dictionary of failure reasons for specific error codes.
//!
//! (Optional).  Must be an \c NSDictionary mapping one or more
//! \c NSNumber => \c NSString or \c NSNull objects.  If a key maps to an
//! \c NSNull object, the error is ignored.
extern NSString * const MCKResponseProcesorOptionFailureReasonsForErrorCodes;



//---------------------------------------------------------------------------//
//! A \c MCKResponseProcessor encapsulates the act of processing the
//! response returned by an API request.
//
@interface MCKResponseProcessor : NSObject <NSCoding>

//! Creates and returns a response processor that invokes \a selector
//! on the \a target class.
//!
//! \a selector must accept two arguments, or three arguments if a
//! \a context is provided.  The order of arguments is as follows:
//!     1) A \c _MCKRequestStatus object containing the present state
//!        of the request.
//!     2) The \ref MCKClient from which the request originated.
//!
//! \a selector must return a \c MCKResponseSender or \c nil.
+ (instancetype)processorWithTarget:(Class)target selector:(SEL)selector context:(id<NSCoding>)context;

//! Creates and returns a response processor that performs no transformation
//! of the response.
+ (instancetype)nopProcessor;

//! Creates and returns a response processor that performs no parsing of the
//! response but will send errors if the response code is not \c 200.
+ (instancetype)responseProcessorThatChecksForErrorsWithOptions:(NSDictionary*)options;

//! Creates an returns a response processor that parses the returned JSON
//! and sends the value associated with a given key from the JSON,
//! optionally after creating an instance of a model class using the data.
//!
//! @param  key
//!         If this is not \c nil, the dictionary associated with this key
//!         is first extracted from the response.
//! @param  resultClass
//!         If this is not \c, the response or value associated with
//!         \c key is used an instanciate an instance of this model class.
+ (instancetype)jsonResponseProcessorThatExtractsKey:(NSString*)key andParsesItIntoClass:(Class)resultClass withOptions:(NSDictionary*)options;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Invoking a Processor
//! @name       Invoking a Processor
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Called by \ref MCKClient to process status changes of a response with
//! which the receiver is associated.
//!
//! You should not need to call this method yourself.
- (MCKResponseSender)processStatusUpdate:(id /*_MCKRequestStatus*/)requestStatus fromClient:(MCKClient*)client;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Utility
//! @name       Utility
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Parses the given \a JSONData returned by a response into Foundation
//! objects.
//!
//! @param  expectedClass
//!         Must be one of \c NSDictionary or \c NSArray.
//! @note
//! If this method returns nil, \a error will be set.
+ (id)parseJSONData:(NSData*)JSONData ofResponse:(NSHTTPURLResponse*)response expectedClass:(Class)expectedClass client:(MCKClient*)client error:(NSError**)error;

//! Decodes \a JSONDictionary into an instance of \c resultClass.
//!
//! This method also handles substititing \a resultClass with an appropriate
//! surrogate class from \a client as well as setting the \c server
//! property of a returned \ref MCKObject.
//!
//! \a resultClass must inherit from \c MTLModel.  c resultClass must not
//! be \c nil.
//!
+ (id)parseJSONDictionary:(NSDictionary*)JSONDictionary resultClass:(Class)resultClass client:(MCKClient*)client error:(NSError**)error;

@end
