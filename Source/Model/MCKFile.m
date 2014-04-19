//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCFile.m
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

#import "MCKFile.h"
#import "MCKMediaFile.h"
#import "MCKFileMetadata.h"
#import "MCKFileFlags.h"

//---------------------------------------------------------------------------//
NSString * const MCKFileTypeVideo = @"video";
NSString * const MCKFileTypeAudio = @"audio";
NSString * const MCKFileTypeImage = @"image";



//---------------------------------------------------------------------------//
@implementation MCKFile

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MTLJSONSerializing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (NSDictionary*)JSONKeyPathsByPropertyKey
{
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"blobType": @"blob_type",
        @"compression": @"compression",
        @"files": @"files",
        @"extras": @"extras",
        @"metadata": @"metadata",
        @"flags": @"flags",
        @"original": @"original",
        @"type": @"type"
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSValueTransformer *)filesJSONTransformer
{
	NSValueTransformer *dictionaryTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:MCKMediaFile.class];
    
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSArray *mediaFilesArray) {
		if (![mediaFilesArray isKindOfClass:NSArray.class]) return nil;
        
		NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:mediaFilesArray.count];
		[mediaFilesArray enumerateObjectsUsingBlock:^(NSDictionary *fileDictionary, NSUInteger __unused idx, BOOL __unused *stop) {
			MCKMediaFile *file = [dictionaryTransformer transformedValue:fileDictionary];
			if (file != nil) [files addObject:file];
		}];
        
		return [files copy];
	} reverseBlock:^ id (NSArray *files) {
		if (![files isKindOfClass:NSArray.class]) return nil;
        
		NSMutableArray *filesArray = [[NSMutableArray alloc] initWithCapacity:files.count];
		for (MCKMediaFile *mediaFile in files) {
			NSDictionary *fileDictionary = [dictionaryTransformer reverseTransformedValue:mediaFile];
			if (fileDictionary == nil) return nil;
			
			[filesArray addObject:fileDictionary];
		}
        
		return filesArray;
	}];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSValueTransformer *)metadataJSONTransformer
{
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:MCKFileMetadata.class];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSValueTransformer *)flagsJSONTransformer
{
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:MCKFileFlags.class];
}

@end
