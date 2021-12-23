//
//  NSUserDefaults+SecureNSUserDefaults.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/26/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "NSUserDefaults+SecureNSUserDefaults.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSUserDefaults (SecureNSUserDefaults)

static NSString *const SECRET = @"<extracted_for_open_source_1234>"; // this must be 32 bytes in utf-8
static NSString *const STORED_OBJ_KEY = @"storedObject";
static float const DEF_FLOAT_VALUE = 0;
static int64_t const DEF_INT_VALUE = 0;

- (void)setSecureFloat:(float)f forKey:(NSString *)key {
    NSData *clearData = [NSData dataWithBytes:&f length:sizeof(f)];
    NSData *encryptedData = [self AES256EncryptData:clearData];
    [self setObject:encryptedData forKey:key];
}

- (float)secureFloatForKey:(NSString *)key {
    float retVal = DEF_FLOAT_VALUE;

    // get
    NSData *ecryptedData = [self objectForKey:key];
    if(ecryptedData == nil) {
        return retVal;
    }

    // decrypt
    NSData *clearData = [self AES256DecryptData:ecryptedData];

    // read bytes back to float
    [clearData getBytes:&retVal length:sizeof(retVal)];
    return retVal;
}

- (void)setSecureInt:(int64_t)i forKey:(NSString *)key {
    NSData *clearData = [NSData dataWithBytes:&i length:sizeof(i)];
    NSData *encryptedData = [self AES256EncryptData:clearData];
    [self setObject:encryptedData forKey:key];
}

- (int64_t)secureIntForKey:(NSString *)key {
    int64_t retVal = DEF_INT_VALUE;

    // get
    NSData *ecryptedData = [self objectForKey:key];
    if(ecryptedData == nil) {
        return retVal;
    }

    // decrypt
    NSData *clearData = [self AES256DecryptData:ecryptedData];

    // read bytes back to float
    [clearData getBytes:&retVal length:sizeof(retVal)];
    return retVal;
}

- (NSData *)AES256EncryptData:(NSData *)data {
    NSData *retVal = nil;

	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)

	// fetch key data
	[SECRET getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

	NSUInteger dataLength = data.length;

	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);

	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          data.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}

	free(buffer); //free the buffer;
	return retVal;
}

- (NSData *)AES256DecryptData:(NSData *)data {
    NSData *retVal = nil;

	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)

	// fetch key data
	[SECRET getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

	NSUInteger dataLength = data.length;

	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);

	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          data.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return retVal;
}


@end
