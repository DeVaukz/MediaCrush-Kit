//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKFileMetadata.h
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
//! @ingroup MODEL
//!
//! Represents various meta data associated with a \ref MCKFile.
//!
//! Each media type will have different metadata, and some or all of it may
//! not be present.
//
@interface MCKFileMetadata : MTLModel <MTLJSONSerializing>

//! The dimensions of the media in pixels.
@property (nonatomic, readonly) NSSize dimensions;

//! A boolean value that indicates whether the media has audio.
@property (nonatomic, readonly) BOOL hasAudio;

//! A boolean value that indicates whether the media has video.
@property (nonatomic, readonly) BOOL hasVideo;

@end
