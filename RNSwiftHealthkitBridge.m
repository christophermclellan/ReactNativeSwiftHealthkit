// RNSwiftHealthkitBridge.m

#import "RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(RNSwiftHealthKit, NSObject)

RCT_EXTERN_METHOD(authorizeHealthKit: (NSDictionary *)typesToWrite typesToRead:(NSDictionary *)typesToRead);

RCT_EXTERN_METHOD(readBiologicalSex: (RCTResponseSenderBlock)callback);

RCT_EXTERN_METHOD(readBirthDate: (RCTResponseSenderBlock)callback);

RCT_EXTERN_METHOD(readBloodType: (RCTResponseSenderBlock)callback);

RCT_EXTERN_METHOD(readWeight: (RCTResponseSenderBlock)NSObject);

RCT_EXTERN_METHOD(readHeight: (RCTResponseSenderBlock)NSObject);

@end
