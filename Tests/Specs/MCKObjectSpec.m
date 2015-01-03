//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKObjectSpec.m
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

#import <MediaCrushKit/MCKObject_Private.h>

NSString * const MCKObjectArchivingSharedExamplesName = @"MCKObject archiving";
NSString * const MCKObjectExternalRepresentationSharedExamplesName = @"MCKObject externalRepresentation";
NSString * const MCKObjectKey = @"object";
NSString * const MCKObjectExternalRepresentationKey = @"externalRepresentation";


//---------------------------------------------------------------------------//
SharedExamplesBegin(MCKObjectSharedExamples)

sharedExamplesFor(MCKObjectArchivingSharedExamplesName, ^(NSDictionary *data) {
    __block MCKObject *obj;
    
    beforeEach(^{
        obj = data[MCKObjectKey];
        expect(obj).notTo.beNil();
    });
    
    it(@"should implement <NSCoding>", ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
		expect(data).notTo.beNil();
        
		MCKObject *unarchivedObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		expect(unarchivedObj).to.equal(obj);
    });
});

sharedExamplesFor(MCKObjectExternalRepresentationSharedExamplesName, ^(NSDictionary *data){
	__block MCKObject *obj;
	__block NSDictionary *representation;
	
	beforeEach(^{
		obj = data[MCKObjectKey];
		expect(obj).notTo.beNil();
        
		representation = data[MCKObjectExternalRepresentationKey];
		expect(representation).notTo.beNil();
	});
    
	it(@"should be equal in all values that exist in both external representations", ^{
		NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:obj];
        
		[representation enumerateKeysAndObjectsUsingBlock:^(NSString *key, id expectedValue, BOOL __unused *stop) {
			id value = JSONDictionary[key];
			if (value == nil) return;
            
			expect(value).to.equal(expectedValue);
		}];
	});
});

SharedExamplesEnd


//---------------------------------------------------------------------------//
SpecBegin(MCKObject)

describe(@"with an hash from JSON", ^{
	NSDictionary *representation = @{ @"hash": @"12345" };
    
	__block MCKObject *obj;
	
	before(^{
		obj = [MTLJSONAdapter modelOfClass:MCKObject.class fromJSONDictionary:representation error:NULL];
		expect(obj).notTo.beNil();
	});
    
	itShouldBehaveLike(MCKObjectArchivingSharedExamplesName, ^{
		return @{ MCKObjectKey: obj };
	});
    
	itShouldBehaveLike(MCKObjectExternalRepresentationSharedExamplesName, ^{
		return @{ MCKObjectKey: obj, MCKObjectExternalRepresentationKey: representation };
	});
    
	it(@"should have the same objectID", ^{
		expect(obj.objectID).to.equal(@"12345");
	});
    
    it(@"should have no server", ^{
		expect(obj.server).to.beNil();
	});
    
	it(@"should be equal to another object with the same objectID", ^{
		MCKObject *secondObject = [MTLJSONAdapter modelOfClass:MCKObject.class fromJSONDictionary:representation error:NULL];
		expect(obj).to.equal(secondObject);
	});
});

describe(@"with an objectID and a server", ^{
    NSDictionary *dictionary = @{@"objectID": @"12345", @"server": MCKServer.defaultServer};
    
    __block MCKObject *obj;
    
    before(^{
        obj = [[MCKObject alloc] initWithDictionary:dictionary error:NULL];
        expect(obj).toNot.beNil();
    });
    
    it(@"should have the same objectID", ^{
        expect(obj.objectID).to.equal(@"12345");
    });
    
    it(@"should be from the default server", ^{
        expect(obj.server).to.equal(MCKServer.defaultServer);
    });
    
    it(@"should be equal to another object with the same objectID from the same server", ^{
		MCKObject *secondObject = [[MCKObject alloc] initWithDictionary:dictionary error:NULL];
		expect(obj).to.equal(secondObject);
	});
    
    it(@"should not be equal to another object with the same objectID from another server", ^{
        MCKObject *secondObject = [[MCKObject alloc] initWithDictionary:@{@"objectID": @"12345",
                                                                          @"server": [[MCKServer alloc] initWithBaseURL:[NSURL URLWithString:@"https://localhost/"]]}
                                                                  error:NULL];
        expect(obj).toNot.equal(secondObject);
    });
});

it(@"should initialize with a null objectID", ^{
	MCKObject *obj = [MCKObject modelWithDictionary:@{
        @keypath(obj, objectID): NSNull.null
    } error:NULL];
    
	expect(obj).notTo.beNil();
	expect(obj.objectID).to.beNil();
});

SpecEnd
