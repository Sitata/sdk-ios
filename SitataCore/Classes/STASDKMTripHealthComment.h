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

@property NSString *identifier;
@property NSString *comment;
@property NSString *countryId;
@property NSString *diseaseId;
@property NSString *diseaseName;

+(RLMResults<STASDKMTripDiseaseComment*>*)commentsForDisease:(NSString*)diseaseId trip:(STASDKMTrip*)trip;

@end




@interface STASDKMTripMedicationComment : RLMObject

@property NSString *identifier;
@property NSString *comment;
@property NSString *countryId;
@property NSString *medicationId;
@property NSString *medicationName;

+(RLMResults<STASDKMTripMedicationComment*>*)commentsForMedication:(NSString*)medicationId trip:(STASDKMTrip*)trip;

@end


@interface STASDKMTripVaccinationComment : RLMObject

@property NSString *identifier;
@property NSString *comment;
@property NSString *countryId;
@property NSString *vaccinationId;
@property NSString *vaccinationName;

+(RLMResults<STASDKMTripVaccinationComment*>*)commentsForVaccination:(NSString*)vaccinationId trip:(STASDKMTrip*)trip;

@end



// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMTripDiseaseComment *><STASDKMTripDiseaseComment>
RLM_ARRAY_TYPE(STASDKMTripDiseaseComment)
RLM_ARRAY_TYPE(STASDKMTripMedicationComment)
RLM_ARRAY_TYPE(STASDKMTripVaccinationComment)
