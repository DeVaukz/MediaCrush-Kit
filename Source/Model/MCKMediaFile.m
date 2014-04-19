//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCMediaFile.m
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

#import "MCKMediaFile.h"

//---------------------------------------------------------------------------//
NSString * const MCKMediaFileTypeAudioMP3 = @"audio/mpeg";
NSString * const MCKMediaFileTypeAudioOGG = @"audio/ogg";
NSString * const MCKMediaFileTypeImageGIF = @"image/gif";
NSString * const MCKMediaFileTypeImageJPEG = @"image/jpeg";
NSString * const MCKMediaFileTypeImagePNG = @"image/png";
NSString * const MCKMediaFileTypeImageSVG_XML = @"image/svg+xml";
NSString * const MCKMediaFileTypeVideoMP4 = @"video/mp4";
NSString * const MCKMediaFileTypeVideoOGG = @"video/ogg";
NSString * const MCKMediaFileTypeVideoWEBM = @"video/webm";



//---------------------------------------------------------------------------//
@implementation MCKMediaFile

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MTLModel
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (NSUInteger)modelVersion
{ return MCK_VERSION; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MTLJSONSerializing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (NSDictionary*)JSONKeyPathsByPropertyKey
{
	return @{
        @"file": @"file",
        @"url": @"url",
        @"type": @"type"
    };
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSValueTransformer *)urlJSONTransformer
{
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *string) {
        return [NSURL URLWithString:string];
    } reverseBlock:^id(NSURL *url) {
        return [url description];
    }];
}

@end
