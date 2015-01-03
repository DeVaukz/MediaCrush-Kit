//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKMediaFileSpec.m
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

SpecBegin(MCKMediaFile)

describe(@"from JSON", ^{
    NSDictionary *jsonRepresentation = @{
        @"file": @"/CPvuR5lRhmS0.mp4",
        @"url": @"https://mediacru.sh/CPvuR5lRhmS0.mp4",
        @"type": @"video/mp4"
    };
    
    __block MCKMediaFile *file;
    
    before(^{
        file = [MTLJSONAdapter modelOfClass:MCKMediaFile.class fromJSONDictionary:jsonRepresentation error:NULL];
        expect(file).toNot.beNil();
    });
    
    itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
        // MCKFileFlags does not inherit from MCKObject, but that should
        // not affect this test.
		return @{ MCKObjectKey: file };
	});
    
    it(@"should initialize", ^{
        expect(file.file).to.equal(@"/CPvuR5lRhmS0.mp4");
        expect(file.url).to.equal([NSURL URLWithString:@"https://mediacru.sh/CPvuR5lRhmS0.mp4"]);
        expect(file.type).to.equal(@"video/mp4");
    });
    
    it(@"should be equal to another object initialized from the same JSON", ^{
        expect(file).to.equal([MTLJSONAdapter modelOfClass:MCKMediaFile.class fromJSONDictionary:jsonRepresentation error:NULL]);
    });
});

SpecEnd