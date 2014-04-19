//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKClient+Upload.h
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

//---------------------------------------------------------------------------//
//! @name       Status Values
//! @relates    MCKClient
//!
//! Possible processing states.
//

//! Processing has not yet started.
extern NSString * const MCKUploadStatusPending;

//! Processing is ongoing.
extern NSString * const MCKUploadStatusProcessing;

//! Processing is complete.
extern NSString * const MCKUploadStatusDone;



//---------------------------------------------------------------------------//
@interface MCKClient (Upload)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Uploading Content
//! @name       Uploading Content
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Uploads the media file at the given \a url.
//!
//! Returns a signal which will send the objectID of the new file.
- (RACSignal*)uploadURL:(NSURL*)url;

//! Uploads the file encoded in \a data.
//!
//! Returns a signal which will send instances of \ref MCKRequestStatus
//! indicating the progress of the upload.  The \ref result property of
//! the final status update will contain a signal which will send the objectID
//! of the new file.
- (RACSignal*)upload:(NSData*)fileData inBackground:(BOOL)background withIdentifier:(NSUUID**)identifier;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Checking the Status of an Upload
//! @name       Checking the Status of an Upload
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Retrieves the current processing status for uploads the given
//! \a objectIDs.
//!
//! Returns a signal which will send a RACTuple(objectID, status, file)
//! for each objectID.  File will be nil if processing has not
//! completed.
//!
//! @param  objectIDs
//!         An array of \c NSString objects.
- (RACSignal*)statusOfUploadsWithIDs:(NSArray*)objectIDs;

@end
