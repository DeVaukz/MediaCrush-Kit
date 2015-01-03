//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKFileMetadataSpec.m
//|
//|             D.V.
//|             Copyright (c) 2015 D.V. All rights reserved.
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

SpecBegin(MCKFileMetadata)

describe(@"from JSON", ^{
    NSDictionary *jsonRepresentation = @{
        @"dimensions": @{
            @"height": @(281),
            @"width": @(500)
        },
        @"has_audio": @(NO),
        @"has_video": @(YES)
    };
    
    __block MCKFileMetadata *metadata;
    
    before(^{
        metadata = [MTLJSONAdapter modelOfClass:MCKFileMetadata.class fromJSONDictionary:jsonRepresentation error:NULL];
        expect(metadata).toNot.beNil();
    });
    
    itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
        // MCKFileMetadata does not inherit from MCKObject, but that should
        // not affect this test.
		return @{ MCKObjectKey: metadata };
	});
    
    it(@"should initialize", ^{
        expect(metadata.dimensions.height).to.equal(281);
        expect(metadata.dimensions.width).to.equal(500);
        expect(metadata.hasAudio).to.beFalsy();
        expect(metadata.hasVideo).to.beTruthy();
    });
    
    it(@"should be equal to another object initialized from the same JSON", ^{
        expect(metadata).to.equal([MTLJSONAdapter modelOfClass:MCKFileMetadata.class fromJSONDictionary:jsonRepresentation error:NULL]);
    });
});

SpecEnd