//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//! @file       MCKClient+Album.h
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

@class MCKAlbum;

//---------------------------------------------------------------------------//
@interface MCKClient (Album)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Retrieving Information About an Album
//! @name       Retrieving Information About an Album
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Retrieves information about the albums with the given \a objectIDs.
//!
//! @param  objectIDs
//!         An array of \c NSString objects.
//! @return
//! A signal that sends a \c RACTuple(objectID, MCLAlbum or NSNull)
//! describing each objectID, and complete.
- (RACSignal*)infoForAlbumsWithIDs:(NSArray*)objectIDs;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating Albums
//! @name       Creating Albums
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates a new album contaning the files with the given \a objectIDs.
//!
//! @param  objectIDs
//!         An array of \c NSString objects.
//! @return
//! A signal that sends an \ref MCKObject with the new album's ID.
//! Pass the objectID to \c -infoForAlbumsWithIDs: to retrieve the
//! contents of the album.
- (RACSignal*)createAlbumContainingFilesWithIDs:(NSArray*)objectIDs;

//! Creates a new album contaning the files with the given \a files.
//!
//! @param  files
//!         An array of \c MCKFile objects.
//! @return
//! A signal that sends an \ref MCKObject with the new album's ID.
//! Pass the objectID to \c -infoForAlbumsWithIDs: to retrieve the
//! contents of the album.
- (RACSignal*)createAlbumContainingFiles:(NSArray*)files;

@end
