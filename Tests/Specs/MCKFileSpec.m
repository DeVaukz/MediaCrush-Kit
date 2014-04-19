//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKFileSpec.m
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

SpecBegin(MCKFile)

describe(@"from JSON", ^{
    NSDictionary *jsonRepresentation = @{
        @"blob_type": @"video",
        @"compression": @(8.93),
        @"files": @[
            @{
                @"file": @"/CPvuR5lRhmS0.mp4",
                @"url": @"https://mediacru.sh/CPvuR5lRhmS0.mp4",
                @"type": @"video/mp4"
            },
            @{
                @"file": @"/CPvuR5lRhmS0.ogv",
                @"url": @"https://mediacru.sh/CPvuR5lRhmS0.ogv",
                @"type": @"video/ogg"
            },
            @{
                @"file": @"/CPvuR5lRhmS0.gif",
                @"url": @"https://mediacru.sh/CPvuR5lRhmS0.gif",
                @"type": @"image/gif"
            }
        ],
        @"extras": @[],
        @"metadata": @{
            @"dimensions": @{
                @"height": @(281),
                @"width": @(500)
            },
            @"has_audio": @(NO),
            @"has_video": @(YES)
        },
        @"flags": @{
            @"autoplay": @(YES),
            @"loop": @(YES),
            @"mute": @(YES)
        },
        @"original": @"/CPvuR5lRhmS0.gif",
        @"hash": @"CPvuR5lRhmS0",
        @"type": @"image/gif"
    };
    
    __block MCKFile *file;
    
    before(^{
        file = [MTLJSONAdapter modelOfClass:MCKFile.class fromJSONDictionary:jsonRepresentation error:NULL];
        expect(file).toNot.beNil();
    });
    
    itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
		return @{ MCKObjectKey: file };
	});
    
    it(@"should initialize", ^{
        expect(file.objectID).to.equal(@"CPvuR5lRhmS0");
        expect(file.blobType).to.equal(MCKFileTypeVideo);
        expect(file.compression).to.equal(@(8.93));
        expect(file.original).to.equal(@"/CPvuR5lRhmS0.gif");
        expect(file.type).to.equal(MCKMediaFileTypeImageGIF);
        
        for (NSUInteger i=0; i<3; i++) {
            MCKMediaFile *repMetaFile = [MTLJSONAdapter modelOfClass:MCKMediaFile.class fromJSONDictionary:jsonRepresentation[@"files"][i] error:NULL];
            expect(file.files[i]).to.equal(repMetaFile);
        }
        
        MCKFileMetadata *repMetaData = [MTLJSONAdapter modelOfClass:MCKFileMetadata.class fromJSONDictionary:jsonRepresentation[@"metadata"] error:NULL];
        expect(file.metadata).to.equal(repMetaData);
        
        MCKFileFlags *repFileFlags= [MTLJSONAdapter modelOfClass:MCKFileFlags.class fromJSONDictionary:jsonRepresentation[@"flags"] error:NULL];
        expect(file.flags).to.equal(repFileFlags);
    });
    
    it(@"should be equal to another object initialized from the same JSON", ^{
        expect(file).to.equal([MTLJSONAdapter modelOfClass:MCKFile.class fromJSONDictionary:jsonRepresentation error:NULL]);
    });
});

SpecEnd
