//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MediaCrush.h
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

#define MC_MEDIACRUSH   1

//---------------------------------------------------------------------------//
//! @defgroup MODEL Model Objects
//!
//! Representations of objects returned by the various API calls.
//---------------------------------------------------------------------------//

#import <MediaCrushKit/MCKConstants.h>
#import <MediaCrushKit/MCKClient.h>

#import <MediaCrushKit/MCKObject.h>
#import <MediaCrushKit/MCKRequestStatus.h>
#import <MediaCrushKit/MCKResponseProcessor.h>

#import <MediaCrushKit/MCKAlbum.h>
#import <MediaCrushKit/MCKFile.h>
#import <MediaCrushKit/MCKFileMetadata.h>
#import <MediaCrushKit/MCKFileFlags.h>
#import <MediaCrushKit/MCKMediaFile.h>

#import <MediaCrushKit/MCKClient+Object.h>
#import <MediaCrushKit/MCKClient+URL.h>
#import <MediaCrushKit/MCKClient+Album.h>
#import <MediaCrushKit/MCKClient+File.h>
#import <MediaCrushKit/MCKClient+Upload.h>
#import <MediaCrushKit/MCKClient+Download.h>

#import <MediaCrushKit/MCKServer.h>