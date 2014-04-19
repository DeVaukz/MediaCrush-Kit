//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKConstants.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014 D.V. All rights reserved.
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

//! The domain for all errors originating from MediaCrush Kit.  This
//! includes errors resulting from invalid data beging returned from the
//! MediaCrush API.
extern NSString * const MCKErrorDomain;
//! The domain for all errors originating directly from the MediaCrush API.
extern NSString * const MCKAPIErrorDomain;

//! When a \ref MCKClientErrorRequestCancelled error is raised, the available
//! resume data is associated with this key.
extern NSString * const MCKClientErrorResumeDataKey;

//---------------------------------------------------------------------------//
//! @name       MediaCrush Kit Errors
//! @relates    MCKRequestStatus
//!
//! Error codes for the \ref MCKErrorDomain.
//
typedef NS_ENUM(NSUInteger, MCKErrorDomainCode) {
    //! The request was cancelled.
    MCKClientErrorRequestCancelled      = 444,
    //! The client failed to enqueue the request.
    MCKClientErrorRequestEnqueueFailed  = 666,
    MCKErrorEmptyResponse,
    MCKErrorJSONParsingFailed,
    MCKErrorInvalidJSON,
    MCKErrorJSONEncodeFailed,
};


//---------------------------------------------------------------------------//
//! @name       MediaCrush API Errors
//! @relates    MCKRequestStatus
//!
//! Error codes for the \ref MCKAPIErrorDomain.
//
typedef NS_ENUM(NSUInteger, MCKAPIErrorDomainCode) {
    //! Your IP address does not have permission to perform the operation.
    MCKAPIErrorPermissionDenied         = 401,
    //! At least one of the items could not be found.
    MCKAPIErrorObjectNotFound           = 404,
    //! The item already exists.
    MCKAPIErrorExists                   = 409,
    //! The item is too large.
    MCKAPIErrorSizeTooLarge             = 413,
    //! At least one of the items does not accept processing.
    MCKAPIErrorInvalidInput             = 415,
    //! The rate limit was exceeded.
    MCKAPIErrorRateLimitExceeded        = 420
};