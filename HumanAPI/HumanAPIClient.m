//
//  HumanAPIClient.m
//  HumanAPI client implementation
//

#import "HumanAPIClient.h"

// Human API root URL
static NSString * const API_ROOT = @"https://api.humanapi.co/v1/human";

// ----  ----  ----  ----
// CLIENT
// ----  ----  ----  ----

@implementation HumanAPIClient

+ (HumanAPIClient *)sharedHumanAPIClient
{
    static HumanAPIClient *_sharedClient = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });

    return _sharedClient;
}

- (instancetype)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:API_ROOT]];
    return self;
}

- (void)execute:(NSString *)path
    onSuccess:(void (^)(id responseObject))success
    onFailure:(void (^)(NSError *error))failure;
{
    NSMutableDictionary *empty = [NSMutableDictionary dictionary];
    [self execute:path withParameters:empty onSuccess:success onFailure:failure];
}

- (void)execute:(NSString *)path withParameters:(NSMutableDictionary *)parameters
    onSuccess:(void (^)(id responseObject))success
    onFailure:(void (^)(NSError *error))failure;
{
    NSMutableDictionary *myParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    myParams[@"access_token"] = self.accessToken;
    NSString *fullPath = [NSString stringWithFormat:@"%@?", path];
    //NSString *fullPath = [NSString stringWithFormat:@"%@/?access_token=%@", path, self.accessToken];
    [self GET:fullPath parameters:myParams
      success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

//Wellness
- (HumanAPIClientActivityEntity *)activity
{
    return [[HumanAPIClientActivityEntity alloc] initWithClient:self];
}

- (HumanAPIClientBloodGlucoseEntity *)bloodGlucose
{
    return [[HumanAPIClientBloodGlucoseEntity alloc] initWithClient:self];
}

- (HumanAPIClientBloodOxygenEntity *)bloodOxygen
{
    return [[HumanAPIClientBloodOxygenEntity alloc] initWithClient:self];
}

- (HumanAPIClientBloodPressureEntity *)bloodPressure
{
    return [[HumanAPIClientBloodPressureEntity alloc] initWithClient:self];
}

- (HumanAPIClientBMIEntity *)bmi
{
    return [[HumanAPIClientBMIEntity alloc] initWithClient:self];
}

- (HumanAPIClientBodyFatEntity *)bodyFat
{
    return [[HumanAPIClientBodyFatEntity alloc] initWithClient:self];
}

- (HumanAPIClientGeneticTraitEntity *)geneticTrait
{
    return [[HumanAPIClientGeneticTraitEntity alloc] initWithClient:self];
}

- (HumanAPIClientHeartRateEntity *)heartRate
{
    return [[HumanAPIClientHeartRateEntity alloc] initWithClient:self];
}

- (HumanAPIClientHeightEntity *)height
{
    return [[HumanAPIClientHeightEntity alloc] initWithClient:self];
}

- (HumanAPIClientHumanEntity *)human
{
    return [[HumanAPIClientHumanEntity alloc] initWithClient:self];
}

- (HumanAPIClientLocationEntity *)location
{
    return [[HumanAPIClientLocationEntity alloc] initWithClient:self];
}

- (HumanAPIClientMealEntity *)meal
{
    return [[HumanAPIClientMealEntity alloc] initWithClient:self];
}

- (HumanAPIClientProfileEntity *)profile
{
    return [[HumanAPIClientProfileEntity alloc] initWithClient:self];
}

- (HumanAPIClientSleepEntity *)sleep
{
    return [[HumanAPIClientSleepEntity alloc] initWithClient:self];
}

- (HumanAPIClientWeightEntity *)weight
{
    return [[HumanAPIClientWeightEntity alloc] initWithClient:self];
}

@end


// ----  ----  ----  ----
// ENTITIES
// ----  ----  ----  ----

// AbstractEntity
@implementation HumanAPIClientAbstractEntity

- (instancetype)initWithClient:(HumanAPIClient *)client
                 andMasterPath:(NSString *)masterPath
{
    self = [super init];
    self.client = client;
    self.masterPath = masterPath;
    return self;
}

@end

// AbstractObjectEntity
@implementation HumanAPIClientAbstractObjectEntity

- (void)getWithOnSuccess:(void (^)(id responseObject))success
               onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@""]
               onSuccess:success onFailure:failure];
}

@end

// Abstract Measurement Entity
@implementation HumanAPIClientAbstractMeasurementEntity

- (void)latestWithOnSuccess:(void (^)(id responseObject))success
                  onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@""]
               onSuccess:success onFailure:failure];
}

- (void)readingsWithOnSuccess:(void (^)(id responseObject))success
                    onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@"/readings"]
               onSuccess:success onFailure:failure];
}

- (void)readingsWithParameters:(NSMutableDictionary *)params
                  onSuccess:(void (^)(id responseObject))success
                  onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@"/readings"]
          withParameters: params
               onSuccess:success onFailure:failure];
}

- (void)reading:(NSString *)objId
      onSuccess:(void (^)(id responseObject))success
      onFailure:(void (^)(NSError *error))failure
{
    NSString *rdpath = [@"/readings/" stringByAppendingString:objId];
    [self.client execute:[self.masterPath stringByAppendingString:rdpath]
               onSuccess:success onFailure:failure];
}

- (void)dailyWithOnSuccess:(void (^)(id responseObject))success
                 onFailure:(void (^)(NSError *error))failure
{
    [self dailyForDay:[NSDate date] onSuccess:success onFailure:failure];
}

- (void)dailyForDay:(NSDate *)day
          onSuccess:(void (^)(id responseObject))success
          onFailure:(void (^)(NSError *error))failure
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *iso = [dateFormat stringFromDate:day];
    NSString *dpath = [@"/readings/daily/" stringByAppendingString:iso];
    [self.client execute:[self.masterPath stringByAppendingString:dpath]
               onSuccess:success onFailure:failure];
}

@end

// Abstract Listable Entity
@implementation HumanAPIClientAbstractListableEntity

- (void)listWithOnSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@""]
               onSuccess:success onFailure:failure];
}

- (void)listWithParameters:(NSMutableDictionary *)params
                onSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@""]
               withParameters: params
               onSuccess:success onFailure:failure];
}


- (void)get:(NSString *)objId
  onSuccess:(void (^)(id responseObject))success
  onFailure:(void (^)(NSError *error))failure
{
    NSString *acpath = [@"/" stringByAppendingString:objId];
    [self.client execute:[self.masterPath stringByAppendingString:acpath]
               onSuccess:success onFailure:failure];
}

@end

// Abstract Periodical Entity
@implementation HumanAPIClientAbstractPeriodicalEntity

- (void)listWithOnSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@""]
               onSuccess:success onFailure:failure];
}

- (void)listWithParameters:(NSMutableDictionary *)params
                onSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@""]
               withParameters: params
               onSuccess:success onFailure:failure];
}

- (void)get:(NSString *)objId
  onSuccess:(void (^)(id responseObject))success
  onFailure:(void (^)(NSError *error))failure
{
    NSString *acpath = [@"/" stringByAppendingString:objId];
    [self.client execute:[self.masterPath stringByAppendingString:acpath]
               onSuccess:success onFailure:failure];
}

- (void)dailyWithOnSuccess:(void (^)(id responseObject))success
                 onFailure:(void (^)(NSError *error))failure
{
    [self dailyForDay:[NSDate date] onSuccess:success onFailure:failure];
}

- (void)dailyForDay:(NSDate *)day
          onSuccess:(void (^)(id responseObject))success
          onFailure:(void (^)(NSError *error))failure
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *iso = [dateFormat stringFromDate:day];
    NSString *dpath = [@"/daily/" stringByAppendingString:iso];
    [self.client execute:[self.masterPath stringByAppendingString:dpath]
               onSuccess:success onFailure:failure];
}

- (void)summaryWithOnSuccess:(void (^)(id responseObject))success
                   onFailure:(void (^)(NSError *error))failure
{
    [self summaryForDay:[NSDate date] onSuccess:success onFailure:failure];
}

- (void)summaryForDay:(NSDate *)day
            onSuccess:(void (^)(id responseObject))success
            onFailure:(void (^)(NSError *error))failure
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *iso = [dateFormat stringFromDate:day];
    NSString *spath = [@"/summary/" stringByAppendingString:iso];
    [self.client execute:[self.masterPath stringByAppendingString:spath]
               onSuccess:success onFailure:failure];
}

- (void)summaryForID:(NSString *)objId
           onSuccess:(void (^)(id responseObject))success
           onFailure:(void (^)(NSError *error))failure
{
  NSString *acpath = [@"/summaries/" stringByAppendingString:objId];
  [self.client execute:[self.masterPath stringByAppendingString:acpath]
             onSuccess:success onFailure:failure];
}

- (void)summariesWithOnSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@"/summaries"]
               onSuccess:success onFailure:failure];
}

- (void)summariesWithParameters:(NSMutableDictionary *)params
                onSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure
{
    [self.client execute:[self.masterPath stringByAppendingString:@"/summaries"]
          withParameters: params
               onSuccess:success
               onFailure:failure];
}

@end

//WELLNESS ENTITIES

// Activity Entity
@implementation HumanAPIClientActivityEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"activities"];
}
@end

// Blood Glucose Entity
@implementation HumanAPIClientBloodGlucoseEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"blood_glucose"];
}
@end

// Blood Oxygen Entity
@implementation HumanAPIClientBloodOxygenEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"blood_oxygen"];
}
@end

// Blood Pressure Entity
@implementation HumanAPIClientBloodPressureEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"blood_pressure"];
}
@end

// BMI Entity
@implementation HumanAPIClientBMIEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"bmi"];
}
@end

// Body Fat Entity
@implementation HumanAPIClientBodyFatEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"body_fat"];
}
@end

// Genetic Trait Entity
@implementation HumanAPIClientGeneticTraitEntity

- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"genetic/traits"];
}

- (void)listWithOnSuccess:(void (^)(id responseObject))success
                onFailure:(void (^)(NSError *error))failure;
{
    [self.client execute:self.masterPath onSuccess:success onFailure:failure];
}

@end

// Heart Rate Entity
@implementation HumanAPIClientHeartRateEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"heart_rate"];
}
@end

// Height Entity
@implementation HumanAPIClientHeightEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"height"];
}
@end

// Human Entity
@implementation HumanAPIClientHumanEntity

- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@""];
}
@end

// Location Entity
@implementation HumanAPIClientLocationEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"locations"];
}
@end

// Meal Entity
@implementation HumanAPIClientMealEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"food/meals"];
}
@end

// Profile Entity
@implementation HumanAPIClientProfileEntity

- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"profile"];
}
@end


// Sleep Entity
@implementation HumanAPIClientSleepEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"sleeps"];
}
@end

// Weight Entity
@implementation HumanAPIClientWeightEntity
- (instancetype)initWithClient:(HumanAPIClient *)client
{
    return [super initWithClient:client andMasterPath:@"weight"];
}
@end
