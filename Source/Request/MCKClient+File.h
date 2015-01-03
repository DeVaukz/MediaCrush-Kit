//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKClient+File.h
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

#import "MCKClient.h"

@class MCKFile;
@class MCKFileFlagsEdit;

//---------------------------------------------------------------------------//
@interface MCKClient (File)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Retrieving a File
//! @name       Retrieving a File
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Prepares a request that will load the files, represented by \ref MCKFile
//! objects, for the provided IDs.
//!
//! @param  objectIDs
//!         An array of \c NSString objects.
//! @return
//! A signal that sends a \c RACTuple(objectID, MCKFile) describing each
//! objectID, and complete.
- (RACSignal*)fetchFilesWithIDs:(NSArray*)objectIDs;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  File Flags
//! @name       File Flags
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Prepares a request that will load the flags for a file with the provided
//! ID.
//!
//! @return
//! A signal which will send a \ref MCKFileFlags object and complete.
- (RACSignal*)fetchFlagsForFileID:(NSString*)objectID;

//! Prepares a request that will load the flags for the file.
//!
//! @return
//! A signal which will send a \ref MCKFileFlags object and complete.
- (RACSignal*)fetchFlagsForFile:(MCKFile*)file;

//! Modifies the \ref MCKFileFlags pertaining to \a objectID.
//!
//! The request is disptached as soon as this method is invoked.
//!
//! @return
//! A signal which will send a \ref MCKFileFlags object with the updated flags
//! and complete.
- (RACSignal*)applyEdit:(MCKFileFlagsEdit*)edit toFileWithID:(NSString*)objectID;

//! Modifies the \ref MCKFileFlags pertaining to \a file.
//!
//! The request is disptached as soon as this method is invoked.
//!
//! A signal which will send a \ref MCKFileFlags object with the updated flags
//! and complete.
- (RACSignal*)applyEdit:(MCKFileFlagsEdit*)edit toFile:(MCKFile*)file;

@end
