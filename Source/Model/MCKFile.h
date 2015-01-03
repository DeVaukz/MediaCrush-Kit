//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKFile.h
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

#import "MCKObject.h"

@class MCKFileFlags;
@class MCKFileMetadata;

//---------------------------------------------------------------------------//
//! @name       Blob Types
//! @relates    MCKFile
//!
//! The various blob types.
//

//! A video blob.
extern NSString * const MCKFileTypeVideo;

//! An audio blob.
extern NSString * const MCKFileTypeAudio;

//! An image blob.
extern NSString * const MCKFileTypeImage;



//---------------------------------------------------------------------------//
//! @ingroup MODEL
//!
//! Representes a media blob, which may contain one or more media files.
//!
//! When a file is uploaded to MediaCrush, it enters a processing pipeline.
//! Various (lossless) tweaks and optimizations are done, and it's converted
//! into several browser-friendly formats. All the files associated with a
//! blob are included in the \ref files array. If you wish to display a file
//! to the user, examine the \ref blobType property. Iterate over the files
//! available and choose any mimetypes that match what your platform can
//! support.
//
@interface MCKFile : MCKObject

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing File Properties
//! @name       Accessing File Properties
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The blob type of the file.
//
//! Possible values are listed under \ref "Blob Types".
@property (nonatomic, readonly) NSString *blobType;

//! The ratio of the compressed file stored on the server and the original
//! file's size as measure at upload time.
@property (nonatomic, readonly) float compression;

//! An array of \ref MCKMediaFile instances; one for each representation
//! of the media file.
@property (nonatomic, readonly) NSArray *files;

//! Auxiliary files, such as a thumbnail or subtitles.
@property (nonatomic, readonly) NSDictionary *extras;

//! Various attributes that describe the media file.
//!
//! @see    MCKFileMetadata
@property (nonatomic, readonly) MCKFileMetadata *metadata;

//! A dictionary of flags that determine the behaviour of the player
//! relevant to the blob type.
//!
//! @see MCKFileFlags
@property (nonatomic, readonly) MCKFileFlags *flags;

//! The path to the original file, relative to base URL of the server.
@property (nonatomic, readonly) NSString *original;

//! The MIME type of the original file.  You should not base decisions on
//! this value.
@property (nonatomic, readonly) NSString *type;

@end
