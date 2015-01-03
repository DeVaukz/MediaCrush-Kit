//---------------------------------------------------------------------------//
//|
//|             MediaCrushKit - The Objective-C SDK for MediaCrush
//|             MCKResponseProcessor.m
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

#import "MCKResponseProcessor.h"
#import <Mantle/Mantle.h>
#import <objc/runtime.h>
#import "MCKConstants.h"
#import "MCKClient.h"
#import "MCKObject_Private.h"
#import "MCKRequestStatus_Private.h"

NSString * const MCKResponseProcessorCodingTargetClassKey = @"MCKResponseProcessorCodingTargetClassKey";
NSString * const MCKResponseProcessorCodingSelectorKey = @"MCKResponseProcessorCodingSelectorKey";
NSString * const MCKResponseProcessorCodingContextKey = @"MCKResponseProcessorCodingContextKey";

NSString * const MCKResponseProcesorOptionErrorDescription = @"MCKResponseProcesorOptionErrorDescription";
NSString * const MCKResponseProcesorOptionFailureReasonsForErrorCodes = @"MCKResponseProcesorOptionFailureReasonsForErrorCodes";
NSString * const MCKResponseProcesorOptionKey = @"MCKResponseProcesorOptionKey";
NSString * const MCKResponseProcesorOptionClassName = @"MCKResponseProcesorOptionClassName";


//---------------------------------------------------------------------------//
//  If you're curious, signal chaining would have been a much better way to
//  handle processing the responses.  The problem with that approach is
//  the app may be terminated while a request is on-going, and re-launched
//  when it completes.  Since signals can't be serialized, a way to
//  serialize the processing step was needed, hence MCKResponseProcessor.
@implementation MCKResponseProcessor
{
    Class _targetClass;
    SEL _targetSelector;
    id<NSCoding> _context;
}

//|++++++++++++++++++++++++++++++++++++|//
- (id)init
{ NSAssert(NO, @"Use one of the convenience methods instead."); return nil; }

//|++++++++++++++++++++++++++++++++++++|//
- (id)initWithTarget:(Class)target selector:(SEL)selector context:(id<NSCoding>)context
{
    self = [super init];
    if (self == nil) return nil;
    
    _targetClass = target;
    _targetSelector = selector;
    _context = context;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)processorWithTarget:(Class)target selector:(SEL)selector context:(id<NSCoding>)context
{ return [[self alloc] initWithTarget:target selector:selector context:context]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nopProcessor
{ return [self processorWithTarget:self selector:@selector(_passthroughStatus:fromClient:) context:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)responseProcessorThatChecksForErrorsWithOptions:(NSDictionary*)options
{ return [self processorWithTarget:self selector:@selector(_processErrorsInRequestStatus:fromClient:context:) context:options]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)jsonResponseProcessorThatExtractsKey:(NSString*)key andParsesItIntoClass:(Class)resultClass withOptions:(NSDictionary*)options
{
    NSMutableDictionary *context = [NSMutableDictionary dictionaryWithCapacity:4];
    if (key) [context setObject:key forKey:MCKResponseProcesorOptionKey];
    if (resultClass) [context setObject:NSStringFromClass(resultClass) forKey:MCKResponseProcesorOptionClassName];
    if (options) [context addEntriesFromDictionary:options];
    
    return [self processorWithTarget:self selector:@selector(_processJSONDataRequestStatus:fromClient:context:) context:context];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSCoding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self == nil) return nil;
    
    _targetClass = NSClassFromString([aDecoder decodeObjectForKey:MCKResponseProcessorCodingTargetClassKey]);
    _targetSelector = NSSelectorFromString([aDecoder decodeObjectForKey:MCKResponseProcessorCodingSelectorKey]);
    _context = [aDecoder decodeObjectForKey:MCKResponseProcessorCodingContextKey];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Always record the version number.
    [aCoder encodeObject:[NSString stringWithUTF8String:metamacro_stringify(MCK_VERSION)] forKey:@"Version"];
    
    [aCoder encodeObject:NSStringFromClass(_targetClass) forKey:MCKResponseProcessorCodingTargetClassKey];
    [aCoder encodeObject:NSStringFromSelector(_targetSelector) forKey:MCKResponseProcessorCodingSelectorKey];
    [aCoder encodeObject:_context forKey:MCKResponseProcessorCodingContextKey];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Invoking a Processor
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MCKResponseSender)processStatusUpdate:(id /*_MCKRequestStatus*/)requestStatus fromClient:(MCKClient*)client
{
    NSMethodSignature *targetMethodSignature = [_targetClass methodSignatureForSelector:_targetSelector];
    NSAssert(targetMethodSignature, @"+[%@ %@], method does not exist.", NSStringFromClass(_targetClass), NSStringFromSelector(_targetSelector));
    NSAssert(*[targetMethodSignature methodReturnType] == '@', @"+[%@ %@] does not return a block", NSStringFromClass(_targetClass), NSStringFromSelector(_targetSelector));
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:targetMethodSignature];
    [invocation setTarget:_targetClass];
    [invocation setSelector:_targetSelector];
    [invocation setArgument:&requestStatus atIndex:2];
    [invocation setArgument:&client atIndex:3];
    if (targetMethodSignature.numberOfArguments > 4)
        [invocation setArgument:&_context atIndex:4];
    
    [invocation invoke];
    
    __unsafe_unretained id retValue = nil;
    [invocation getReturnValue:&retValue];
    
    return retValue;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Utility
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (id)parseJSONData:(NSData*)JSONData ofResponse:(NSHTTPURLResponse*)response expectedClass:(Class)expectedClass client:(MCKClient*)client error:(NSError**)error
{
    NSParameterAssert(expectedClass == NSDictionary.class || expectedClass == NSArray.class);
    NSParameterAssert(client);
    
    if (JSONData.length == 0) {
        if (error) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse the server's response.", @""),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Response was empty", @"")
            };
            *error = [NSError errorWithDomain:MCKErrorDomain code:MCKErrorEmptyResponse userInfo:userInfo];
        }
        return nil;
    }
    
    /* Parse jsonData into Foundation objects. */
    NSError *localError = nil;
    id responseObject = [client.responseSerializer responseObjectForResponse:response data:JSONData error:&localError];
    if (!responseObject) {
        if (error) {
            NSDictionary *userInfo;
            if (localError)
                userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse the server's response.", @""),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Parsing the returned JSON data failed.", @""),
                    NSUnderlyingErrorKey: localError
                };
            else
                userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse the server's response.", @""),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Parsing the returned JSON data failed.", @"")
                };
            *error = [NSError errorWithDomain:MCKErrorDomain code:MCKErrorJSONParsingFailed userInfo:userInfo];
        }
        return nil;
    }
    
    if (![responseObject isKindOfClass:expectedClass]) {
        if (error) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse the server's response.", @""),
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an %@, got %@", @""), NSStringFromClass(expectedClass), [responseObject class]]
            };
            *error = [NSError errorWithDomain:MCKErrorDomain code:MCKErrorInvalidJSON userInfo:userInfo];
        }
        return nil;
    }
    
    return responseObject;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (id)parseJSONDictionary:(NSDictionary*)JSONDictionary resultClass:(Class)resultClass client:(MCKClient*)client error:(NSError**)error
{
    NSParameterAssert(resultClass);
    if (!JSONDictionary)
        return nil;
    
    id surrogate = client.surrogateClasses[NSStringFromClass(resultClass)];
    if (surrogate)
        resultClass = surrogate;
    
    NSError *localError = nil;
    MTLModel *parsedObject = [MTLJSONAdapter modelOfClass:resultClass fromJSONDictionary:JSONDictionary error:&localError];
    if (parsedObject == nil) {
        /* Don't treat "no class found" errors as real parsing failures.
         * In theory, this makes parsing code forward-compatible with
         * API additions. */
        if (![localError.domain isEqual:MTLJSONAdapterErrorDomain] || localError.code != MTLJSONAdapterErrorNoClassFound) {
            if (error) *error = localError;
        }
        
        return nil;
    }
    
    NSAssert([parsedObject isKindOfClass:MTLModel.class], @"Parsed model object is not a MTLModel: %@", parsedObject);
    
    /* Record the server that this object has come from. */
    if ([parsedObject isKindOfClass:[MCKObject class]])
        [(MCKObject*)parsedObject setServer:client.server];
    
    return parsedObject;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Template Processors
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

NSError* errorForResponse(NSHTTPURLResponse *response, NSDictionary *context)
{
    NSNumber *responseCode = @(response.statusCode);
    NSString *errorDescription = context[MCKResponseProcesorOptionErrorDescription];
    NSDictionary *failureReasons = context[MCKResponseProcesorOptionFailureReasonsForErrorCodes];
    
    if (failureReasons[responseCode] == NSNull.null || (responseCode.intValue == 200 && !failureReasons[responseCode]))
        return nil; /* No error here */
    
    if (!errorDescription)
        errorDescription = NSLocalizedString(@"Request failed.", @"");
    
    NSDictionary *userInfo;
    if (failureReasons[responseCode])
        userInfo = @{NSLocalizedDescriptionKey: errorDescription, NSLocalizedFailureReasonErrorKey: failureReasons[responseCode]};
    else
        userInfo = @{NSLocalizedDescriptionKey: errorDescription};
    
    return [NSError errorWithDomain:MCKAPIErrorDomain code:response.statusCode userInfo:userInfo];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_passthroughStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client
{
#pragma unused (client)
    
    if (status.responseContents)
        status.result = [RACSignal return:status.responseContents];
    
    return ^(RACSubject *subject) { [subject sendNext:status]; };
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processErrorsInRequestStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client context:(NSDictionary*)context
{
#pragma unused (client)
    
    if (status.state != MCKRequestStateComplete)
        return nil;
    
    return ^(RACSubject *subject) {
        NSError *e = errorForResponse(status.response, context);
        if (e)
            [subject sendError:e];
    };
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MCKResponseSender)_processJSONDataRequestStatus:(_MCKRequestStatus*)status fromClient:(MCKClient*)client context:(NSDictionary*)context
{
    if (status.state != MCKRequestStateComplete)
        return nil;
    
    return ^(RACSubject *subject) {
        NSDictionary *JSONDictionary;
        NSError *error = nil;
        
        // Check for response errors
        error = errorForResponse(status.response, context);
        if (error) {
            [subject sendError:error];
            return;
        }
        
        // Parse jsonData into Foundation objects.
        JSONDictionary = [MCKResponseProcessor parseJSONData:status.responseContents ofResponse:status.response expectedClass:NSDictionary.class client:client error:&error];
        if (!JSONDictionary) {
            [subject sendError:error];
            return;
        }
        
        NSString *key = context[MCKResponseProcesorOptionKey];
        if (key) {
            JSONDictionary = JSONDictionary[key];
            
            if (JSONDictionary == nil) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"The server returned an invalid response.", @""),
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Response did not contain an '%@' key", @""), key]
                };
                [subject sendError:[NSError errorWithDomain:MCKErrorDomain code:MCKErrorInvalidJSON userInfo:userInfo]];
                return;
            }
        }
        
        id finalResult = JSONDictionary;
        
        Class resultClass = NSClassFromString(context[MCKResponseProcesorOptionClassName]);
        if (resultClass) {
            finalResult = [MCKResponseProcessor parseJSONDictionary:JSONDictionary resultClass:resultClass client:client error:&error];
            if (error) {
                [subject sendError:error];
                return;
            }
        }
        
        [subject sendNext:finalResult];
    };
}

@end
