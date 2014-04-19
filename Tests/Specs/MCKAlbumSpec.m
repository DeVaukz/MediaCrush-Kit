//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKAlbumSpec.m
//|
//|             D.V.
//|             Copyright (c) 2014 D.V. All rights reserved.
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

#import "MCKObjectSpec.h"

SpecBegin(MCKAlbum)

describe(@"from JSON", ^{
    NSURL *exampleAlbumURL = [[NSBundle bundleForClass:self.class] URLForResource:@"example_album" withExtension:@"json"];
    NSDictionary *jsonRepresentation = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:exampleAlbumURL] options:0 error:NULL];
    
    __block MCKAlbum *album;
    
    before(^{
        album = [MTLJSONAdapter modelOfClass:MCKAlbum.class fromJSONDictionary:jsonRepresentation error:NULL];
        expect(album).toNot.beNil();
    });
    
    itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
		return @{ MCKObjectKey: album };
	});
    
    it(@"should initialize", ^{
        expect(album.objectID).to.equal(@"6ecd2bbd34ec");
        expect(album.type).to.equal(MCKObjectTypeApplicationAlbum);
        
        for (NSUInteger i=0; i<3; i++) {
            MCKFile *repFile = [MTLJSONAdapter modelOfClass:MCKFile.class fromJSONDictionary:jsonRepresentation[@"files"][i] error:NULL];
            expect(album.files[i]).to.equal(repFile);
        }
    });
    
    it(@"should be equal to another object initialized from the same JSON", ^{
        expect(album).to.equal([MTLJSONAdapter modelOfClass:MCKAlbum.class fromJSONDictionary:jsonRepresentation error:NULL]);
    });
});

SpecEnd
