//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKClient+Object.h
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

#import "MCKClient.h"

@class MCKObject;

//---------------------------------------------------------------------------//
@interface MCKClient (Object)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Determining If An Object Is Already On The Server
//! @name       Determining If An Object Is Already On The Server
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Prepares a request that will ask the server if it has a file with the
//! given id.
//!
//! Returns a signal which will send a BOOL wrapped in an NSNumber and
//! complete.
- (RACSignal*)existsObjectWithID:(NSString*)objectID;

//! Queries the the server to determine whether \a object is present.
//!
//! Returns a signal which will send a BOOL wrapped in an NSNumber and
//! complete.
- (RACSignal*)existsObject:(MCKObject*)object;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Deleting an Object
//! @name       Deleting an Object
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Removes the object with \a objectID from the server.
//!
//! Returns a signal which will complete upon the successful removal of
//! \a objectID.
- (RACSignal*)deleteObjectWithID:(NSString*)objectID;

//! Removes \a object from the server.
//!
//! Returns a signal which will complete upon the successful removal of
//! \a object.
- (RACSignal*)deleteObject:(MCKObject*)object;

@end
