//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCAlbum.m
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

#import "MCKAlbum.h"
#import "MCKFile.h"

//---------------------------------------------------------------------------//
NSString * const MCKObjectTypeApplicationAlbum = @"application/album";



//---------------------------------------------------------------------------//
@implementation MCKAlbum

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MTLJSONSerializing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (NSDictionary*)JSONKeyPathsByPropertyKey
{
	return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"files": @"files",
        @"type": @"type",
    }];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSValueTransformer *)filesJSONTransformer
{
	NSValueTransformer *dictionaryTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:MCKFile.class];
    
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^ id (NSArray *filesArray) {
		if (![filesArray isKindOfClass:NSArray.class]) return nil;
        
		NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:filesArray.count];
		[filesArray enumerateObjectsUsingBlock:^(NSDictionary *fileDictionary, NSUInteger __unused idx, BOOL __unused *stop) {
			MCKFile *file = [dictionaryTransformer transformedValue:fileDictionary];
			if (file != nil) [files addObject:file];
		}];
        
		return [files copy];
	} reverseBlock:^ id (NSArray *files) {
		if (![files isKindOfClass:NSArray.class]) return nil;
        
		NSMutableArray *filesArray = [[NSMutableArray alloc] initWithCapacity:files.count];
		for (MCKFile *file in files) {
			NSDictionary *fileDictionary = [dictionaryTransformer reverseTransformedValue:file];
			if (fileDictionary == nil) return nil;
			
			[filesArray addObject:fileDictionary];
		}
        
		return filesArray;
	}];
}

@end
