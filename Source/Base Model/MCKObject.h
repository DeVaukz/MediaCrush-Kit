//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKObject.h
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

@class MCKServer;

//---------------------------------------------------------------------------//
//! @ingroup MODEL
//!
//! A generic class which represents a data blob that is associated with an
//! identifier.
//!
//! Instances of \c MCKObjects are identified by their \ref objectID, or
//! \e hash in MediaCrush API parlance.  An object is always associated with
//! the server from which it was retrieved and its \ref objectID is unqiue
//! across that server.  Two instances of \c MCKObject are equal if they
//! both originate from the same server and have identical \c objectIDs.
//
@interface MCKObject : MTLModel <MTLJSONSerializing>

//! A value which uniquely identifies the object on the server it was
//! retrived from.
//
//! In MediaCrush API parlance, the object's \e hash.
@property (nonatomic, copy, readonly) NSString *objectID;

//! The server that the object originated from.
//
//! This property is not encoded into JSON.
@property (nonatomic, strong, readonly) MCKServer *server;

@end
