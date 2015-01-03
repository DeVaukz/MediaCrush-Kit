//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             NSURLSessionConfiguration+MCKCopying.m
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

#import "NSURLSessionConfiguration+MCKCopying.h"

//|++++++++++++++++++++++++++++++++++++|//
void NSURLSessionCopyConfiguration(NSURLSessionConfiguration *destination, NSURLSessionConfiguration *source)
{
    destination.HTTPAdditionalHeaders = source.HTTPAdditionalHeaders;
    destination.networkServiceType = source.networkServiceType;
    destination.allowsCellularAccess = source.allowsCellularAccess;
    destination.timeoutIntervalForRequest = source.timeoutIntervalForRequest;
    destination.timeoutIntervalForResource = source.timeoutIntervalForResource;
    
    destination.HTTPCookieAcceptPolicy = source.HTTPCookieAcceptPolicy;
    destination.HTTPCookieStorage = source.HTTPCookieStorage;
    destination.HTTPShouldSetCookies = source.HTTPShouldSetCookies;
    
    destination.TLSMaximumSupportedProtocol = source.TLSMaximumSupportedProtocol;
    destination.TLSMinimumSupportedProtocol = source.TLSMinimumSupportedProtocol;
    destination.URLCredentialStorage = source.URLCredentialStorage;
    
    destination.URLCache = source.URLCache;
    destination.requestCachePolicy = source.requestCachePolicy;
    
    destination.protocolClasses = source.protocolClasses;
    
    destination.HTTPMaximumConnectionsPerHost = source.HTTPMaximumConnectionsPerHost;
    destination.HTTPShouldUsePipelining = source.HTTPShouldUsePipelining;
    destination.connectionProxyDictionary = source.connectionProxyDictionary;
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    destination.discretionary = source.discretionary;
    
    destination.sessionSendsLaunchEvents = source.sessionSendsLaunchEvents;
#endif
}
