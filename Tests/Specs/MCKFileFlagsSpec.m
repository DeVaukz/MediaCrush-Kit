//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKFileFlagsSpec.m
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

//---------------------------------------------------------------------------//
SpecBegin(MCKFileFlags)

describe(@"from JSON", ^{
    NSDictionary *jsonRepresentation = @{
        @"autoplay": @(YES),
        @"loop": @(YES),
        @"mute": @(NO)
    };
    
    __block MCKFileFlags *fileFlags;
    
    before(^{
        fileFlags = [MTLJSONAdapter modelOfClass:MCKFileFlags.class fromJSONDictionary:jsonRepresentation error:NULL];
        expect(fileFlags).toNot.beNil();
    });
    
    itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
        // MCKFileFlags does not inherit from MCKObject, but that should
        // not affect this test.
		return @{ MCKObjectKey: fileFlags };
	});
    
    it(@"should initialize", ^{
        expect(fileFlags.autoplay).to.beTruthy();
        expect(fileFlags.loop).to.beTruthy();
        expect(fileFlags.mute).to.beFalsy();
    });
    
    it(@"should be equal to another object initialized from the same JSON", ^{
        expect(fileFlags).to.equal([MTLJSONAdapter modelOfClass:MCKFileFlags.class fromJSONDictionary:jsonRepresentation error:NULL]);
    });
});

SpecEnd


//---------------------------------------------------------------------------//
SpecBegin(MCKFileFlagsEdit)

describe(@"to JSON", ^{
    NSDictionary *jsonRepresentation = @{
        @"autoplay": @(YES),
        @"loop": @(YES),
        @"mute": @(NO)
    };
    
    __block MCKFileFlagsEdit *fileFlagsEdit;
    
    before(^{
        fileFlagsEdit = [[MCKFileFlagsEdit alloc] init];
        expect(fileFlagsEdit).toNot.beNil();
        
        fileFlagsEdit.autoplay = YES;
        fileFlagsEdit.loop = YES;
        fileFlagsEdit.mute = NO;
    });
    
    itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
        // MCKFileFlagsEdit does not inherit from MCKObject, but that
        // should not affect this test.
		return @{ MCKObjectKey: fileFlagsEdit };
	});
    
    itShouldBehaveLike(MCKObjectExternalRepresentationSharedExamplesName, ^{
		return @{ MCKObjectKey: fileFlagsEdit, MCKObjectExternalRepresentationKey: jsonRepresentation };
	});
});

SpecEnd
