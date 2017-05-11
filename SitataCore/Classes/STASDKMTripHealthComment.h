//
//  STASDKMTripHealthComment.h
//  Pods
//
//  Created by Adam St. John on 2017-05-03.
//
//

#import <Realm/Realm.h>

@class STASDKMTrip;

@interface STASDKMTripDiseaseComment : RLMObject

@property (assign) NSString *identifier;
@property (assign) NSString *comment;
@property (assign) NSString *countryId;
@property (assign) NSString *diseaseId;
@property (assign) NSString *diseaseName;

+(RLMResults<STASDKMTripDiseaseComment*>*)commentsForDisease:(NSString*)diseaseId trip:(STASDKMTrip*)trip;

@end




@interface STASDKMTripMedicationComment : RLMObject

@property (assign) NSString *identifier;
@property (assign) NSString *comment;
@property (assign) NSString *countryId;
@property (assign) NSString *medicationId;
@property (assign) NSString *medicationName;

+(RLMResults<STASDKMTripMedicationComment*>*)commentsForMedication:(NSString*)medicationId trip:(STASDKMTrip*)trip;

@end


@interface STASDKMTripVaccinationComment : RLMObject

@property (assign) NSString *identifier;
@property (assign) NSString *comment;
@property (assign) NSString *countryId;
@property (assign) NSString *vaccinationId;
@property (assign) NSString *vaccinationName;

+(RLMResults<STASDKMTripVaccinationComment*>*)commentsForVaccination:(NSString*)vaccinationId trip:(STASDKMTrip*)trip;

@end



// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMTripDiseaseComment *><STASDKMTripDiseaseComment>
RLM_ARRAY_TYPE(STASDKMTripDiseaseComment)
RLM_ARRAY_TYPE(STASDKMTripMedicationComment)
RLM_ARRAY_TYPE(STASDKMTripVaccinationComment)
