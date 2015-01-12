//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesPlaceDetailQuery.h"
#import "SPGooglePlacesPlacemark.h"

#define kNSCodingKeyName @"name"
#define kNSCodingKeyReference @"reference"
#define kNSCodingKeyIdentifier @"id"
#define kNSCodingKeyType @"type"
#define kNSCodingKeyMatchedRangeLoc @"matchedRangeLocation"
#define kNSCodingKeyMatchedRangeLen @"matchedRangeLength"
#define kNSCodingKeyComponents @"components"

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *reference;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSRange matchedRange;
@property (nonatomic, strong, readwrite) NSArray *components;
@property (nonatomic, readwrite) SPGooglePlacesAutocompletePlaceType type;
@end

@implementation SPGooglePlacesAutocompletePlace

@synthesize name, reference, identifier, type, matchedRange, components;

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary {
    SPGooglePlacesAutocompletePlace *place = [[self alloc] init];
    place.name = placeDictionary[@"description"];
    place.reference = placeDictionary[@"reference"];
    place.identifier = placeDictionary[@"id"];
    place.type = SPPlaceTypeFromDictionary(placeDictionary);
    place.matchedRange = [placeDictionary[@"matched_substrings"] count]?NSMakeRange([placeDictionary[@"matched_substrings"][0][@"offset"] intValue], [placeDictionary[@"matched_substrings"][0][@"length"] intValue]):NSMakeRange(0, 0);
    place.components = [placeDictionary valueForKeyPath:@"terms.value"];
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Reference: %@, Identifier: %@, Type: %@",
            name, reference, identifier, SPPlaceTypeStringForPlaceType(type)];
}

- (CLGeocoder *)geocoder {
    if (!geocoder) {
        geocoder = [[CLGeocoder alloc] init];
    }
    return geocoder;
}

- (void)resolveEstablishmentPlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [SPGooglePlacesPlaceDetailQuery query];
    query.reference = self.reference;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            SPGooglePlacesPlacemark *placemark = [[SPGooglePlacesPlacemark alloc] initWithPlaceDictionary:placeDictionary];
            if (placemark.location) {
                block(placemark, self.name, error);
            } else {
                [[self geocoder] geocodeAddressString:placemark.addressString completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (error) {
                        block(nil, nil, error);
                    } else {
                        SPGooglePlacesPlacemark *newPlacemark = [[SPGooglePlacesPlacemark alloc] initWithCLPlacemark:[placemarks onlyObject]];
                        block(newPlacemark, self.name, error);
                    }
                }];
            }
        }
    }];
}

- (void)resolveGecodePlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    [[self geocoder] geocodeAddressString:self.name completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            [self resolveEstablishmentPlaceToPlacemark:block];
        } else {
            SPGooglePlacesPlacemark *placemark = [[SPGooglePlacesPlacemark alloc] initWithCLPlacemark:[placemarks onlyObject]];
            block(placemark, self.name, error);
        }
    }];
}

- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    if (type == SPPlaceTypeGeocode) {
        // Geocode places already have their address stored in the 'name' field.
        [self resolveGecodePlaceToPlacemark:block];
    } else {
        [self resolveEstablishmentPlaceToPlacemark:block];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    SPGooglePlacesAutocompletePlace *place = [[SPGooglePlacesAutocompletePlace alloc] init];
    place.name = [aDecoder decodeObjectForKey:kNSCodingKeyName];
    place.reference = [aDecoder decodeObjectForKey:kNSCodingKeyReference];
    place.identifier = [aDecoder decodeObjectForKey:kNSCodingKeyIdentifier];
    place.type = [aDecoder decodeIntForKey:kNSCodingKeyType];
    place.matchedRange = NSMakeRange([[aDecoder decodeObjectForKey:kNSCodingKeyMatchedRangeLoc] unsignedIntegerValue], [[aDecoder decodeObjectForKey:kNSCodingKeyMatchedRangeLen] unsignedIntegerValue]);
    place.components = [aDecoder decodeObjectForKey:kNSCodingKeyComponents];
    return place;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:name forKey:kNSCodingKeyName];
    [aCoder encodeObject:reference forKey:kNSCodingKeyReference];
    [aCoder encodeObject:identifier forKey:kNSCodingKeyIdentifier];
    [aCoder encodeInt:type forKey:kNSCodingKeyType];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:matchedRange.location] forKey:kNSCodingKeyMatchedRangeLoc];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:matchedRange.length] forKey:kNSCodingKeyMatchedRangeLen];
    [aCoder encodeObject:components forKey:kNSCodingKeyComponents];
}


@end
