//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKFileFlags.h
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

#import <Mantle/Mantle.h>

//---------------------------------------------------------------------------//
//! @ingroup MODEL
//!
//! Represents settings associated with a \ref MCKFile.
//
@interface MCKFileFlags : MTLModel <MTLJSONSerializing>

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Flags for Videos
//! @name       Flags for Videos
//!
//! @brief      These properties are only applicable to video files.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! A boolean value that indicates whether the video automatically begins
//! playback upon page load.
@property (nonatomic, readonly) BOOL autoplay;

//! A boolean value that indicates whether the video automatically resumes
//! playback from its begiining once the end is reached.
@property (nonatomic, readonly) BOOL loop;

//! A boolean value that indicates whether sound is muted by default.
@property (nonatomic, readonly) BOOL mute;

@end



//---------------------------------------------------------------------------//
//! @ingroup MODEL
//!
//! Represents modifications to a file's flags.
//
//! @note
//! This model only supports being transformed _to_ JSON. It cannot be
//! deserialized from JSON.
//
@interface MCKFileFlagsEdit : MTLModel <MTLJSONSerializing>

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Flags for Videos
//! @name       Flags for Videos
//!
//! @brief      These properties are only applicable to video files.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! A boolean value that indicates whether the video automatically begins
//! playback upon page load.
@property (atomic, readwrite) BOOL autoplay;

//! A boolean value that indicates whether the video automatically resumes
//! playback from its begiining once the end is reached.
@property (atomic, readwrite) BOOL loop;

//! A boolean value that indicates whether sound is muted by default.
@property (atomic, readwrite) BOOL mute;

@end
