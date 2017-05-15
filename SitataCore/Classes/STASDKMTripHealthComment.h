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

@property (retain) NSString *identifier;
@property (retain) NSString *comment;
@property (retain) NSString *countryId;
@property (retain) NSString *diseaseId;
@property (retain) NSString *diseaseName;

+(RLMResults<STASDKMTripDiseaseComment*>*)commentsForDisease:(NSString*)diseaseId trip:(STASDKMTrip*)trip;

@end




@interface STASDKMTripMedicationComment : RLMObject

@property (retain) NSString *identifier;
@property (retain) NSString *comment;
@property (retain) NSString *countryId;
@property (retain) NSString *medicationId;
@property (retain) NSString *medicationName;

+(RLMResults<STASDKMTripMedicationComment*>*)commentsForMedication:(NSString*)medicationId trip:(STASDKMTrip*)trip;

@end


@interface STASDKMTripVaccinationComment : RLMObject

@property (retain) NSString *identifier;
@property (retain) NSString *comment;
@property (retain) NSString *countryId;
@property (retain) NSString *vaccinationId;
@property (retain) NSString *vaccinationName;

+(RLMResults<STASDKMTripVaccinationComment*>*)commentsForVaccination:(NSString*)vaccinationId trip:(STASDKMTrip*)trip;

@end



// This protocol enables typed collections. i.e.:
// RLMArray<STASDKMTripDiseaseComment *><STASDKMTripDiseaseComment>
RLM_ARRAY_TYPE(STASDKMTripDiseaseComment)
RLM_ARRAY_TYPE(STASDKMTripMedicationComment)
RLM_ARRAY_TYPE(STASDKMTripVaccinationComment)
