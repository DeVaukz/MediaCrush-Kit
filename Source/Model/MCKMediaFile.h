//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKMediaFile.h
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

//---------------------------------------------------------------------------//
//! @name       Media Types
//! @relates    MCKMediaFile
//!
//! The MIME types that can be uploaded to MediaCrush. Only a subset of
//! these types are vended by MediaCrush; the remainder are converted to
//! a supported type upon upload.
//

//! MIME type for mp3 files, \c audio/mpeg.
extern NSString * const MCKMediaFileTypeAudioMP3;

//! MIME type for ogg files, \c audio/ogg.
extern NSString * const MCKMediaFileTypeAudioOGG;

//! MIME type for gif files, \c image/gif.
extern NSString * const MCKMediaFileTypeImageGIF;

//! MIME type for jpeg and jpg files, \c image/jpeg.
extern NSString * const MCKMediaFileTypeImageJPEG;

//! MIME type for png files, \c image/png.
extern NSString * const MCKMediaFileTypeImagePNG;

//! MIME type for svg files, \c image/svg+xml.
extern NSString * const MCKMediaFileTypeImageSVG_XML;

//! MIME type for mp4 files, \c video/mp4.
extern NSString * const MCKMediaFileTypeVideoMP4;

//! MIME type for ogv files, \c video/ogg.
extern NSString * const MCKMediaFileTypeVideoOGG;

//! MIME type for webm files, \c video/webm.
extern NSString * const MCKMediaFileTypeVideoWEBM;



//---------------------------------------------------------------------------//
//! @ingroup MODEL
//!
//! Represents a downloadable media file on the server.
//
@interface MCKMediaFile : MTLModel <MTLJSONSerializing>

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Media File Properties
//! @name       Accessing Media File Properties
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The path to the file relative to the base URL of the \ref MCKServer
//! it was retireved from.
@property (nonatomic, readonly) NSString *file;

//! The absolute URL to the file.
//
//! The base of this url may be different than the server's base URL. The
//! value of this property should be preferred over \ref file when
//! establishing a URL from which to download the media file.
@property (nonatomic, readonly) NSURL *url;

//! The MIME type of the file.
//
//! Possible values are listed in \ref 'Media Types'.
@property (nonatomic, readonly) NSString *type;

@end
