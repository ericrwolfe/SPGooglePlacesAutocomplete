//
//  SPGooglePlacesPlacemark.m
//  Footpath
//
//  Created by Eric Wolfe on 4/11/13.
//  Copyright (c) 2013 Eric Wolfe. All rights reserved.
//

#import "SPGooglePlacesPlacemark.h"

#define kNSCodingKeyLocation @"kNSCodingKeyLocation"
#define kNSCodingKeyRegion @"kNSCodingKeyRegion"
#define kNSCodingKeyAddressDictionary @"kNSCodingKeyAddressDictionary"
#define kNSCodingKeyAddressString @"kNSCodingKeyAddressString"
#define kNSCodingKeyName @"kNSCodingKeyName"
#define kNSCodingKeyThoroughfare @"kNSCodingKeyThoroughfare"
#define kNSCodingKeySubThoroughfare @"kNSCodingKeySubThoroughfare"
#define kNSCodingKeyLocality @"kNSCodingKeyLocality"
#define kNSCodingKeySubLocality @"kNSCodingKeySubLocality"
#define kNSCodingKeyAdministrativeArea @"kNSCodingKeyAdministrativeArea"
#define kNSCodingKeySubAdministrativeArea @"kNSCodingKeySubAdministrativeArea"
#define kNSCodingKeyPostalCode @"kNSCodingKeyPostalCode"
#define kNSCodingKeyISOCountryCode @"kNSCodingKeyISOCountryCode"
#define kNSCodingKeyCountry @"kNSCodingKeyCountry"
#define kNSCodingKeyInlandWater @"kNSCodingKeyInlandWater"
#define kNSCodingKeyOcean @"kNSCodingKeyOcean"
#define kNSCodingKeyAreasOfInterest @"kNSCodingKeyAreasOfInterest"

@implementation SPGooglePlacesPlacemark

- (id)initWithCLPlacemark:(CLPlacemark *)placemark {
    self = [super init];
    if (self) {
        _location = placemark.location;
        _region = (CLCircularRegion *)placemark.region;
        _addressDictionary = placemark.addressDictionary;
        _name = placemark.name;
        _thoroughfare = placemark.thoroughfare;
        _locality = placemark.locality;
        _subLocality = placemark.subLocality;
        _administrativeArea = placemark.administrativeArea;
        _subAdministrativeArea = placemark.subAdministrativeArea;
        _postalCode = placemark.postalCode;
        _ISOcountryCode = placemark.ISOcountryCode;
        _country = placemark.country;
        _inlandWater = placemark.inlandWater;
        _ocean = placemark.ocean;
        _areasOfInterest = placemark.areasOfInterest;
        
#ifdef ABCreateStringWithAddressDictionary
        _addressString = ABCreateStringWithAddressDictionary(_addressDictionary, YES);
#endif
    }
    return self;
}

- (id)initWithPlaceDictionary:(NSDictionary *)placeDictionary {
    self = [super init];
    if (self) {
        
        if ([placeDictionary valueForKeyPath:@"geometry.location"]) {
            _location = [[CLLocation alloc] initWithLatitude:[[placeDictionary valueForKeyPath:@"geometry.location.lat"] doubleValue] longitude:[[placeDictionary valueForKeyPath:@"geometry.location.lng"] doubleValue]];
            
        }
        
        if ([placeDictionary valueForKeyPath:@"geometry.viewport"]) {
            CLLocation *northeast = [[CLLocation alloc] initWithLatitude:[[placeDictionary valueForKeyPath:@"geometry.viewport.northeast.lat"] doubleValue] longitude:[[placeDictionary valueForKeyPath:@"geometry.viewport.northeast.lng"] doubleValue]];
            CLLocation *southwest = [[CLLocation alloc] initWithLatitude:[[placeDictionary valueForKeyPath:@"geometry.viewport.southwest.lat"] doubleValue] longitude:[[placeDictionary valueForKeyPath:@"geometry.viewport.southwest.lng"] doubleValue]];
            
            CLLocationDistance radius = [northeast distanceFromLocation:southwest]/2.0;
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake((northeast.coordinate.latitude+southwest.coordinate.latitude)/2.0, (northeast.coordinate.longitude+southwest.coordinate.longitude)/2.0);
            
            _region = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:[NSString stringWithFormat:@"(%f, %f) Radius: %fm",center.latitude, center.longitude, radius]];
        }
        
        _name = placeDictionary[@"name"];
        _addressString = placeDictionary[@"formatted_address"];
        
        for (NSDictionary *component in [placeDictionary[@"address_components"] reverseObjectEnumerator]) {
            
            NSArray *types = component[@"types"];
            
            if ([types containsObject:@"street_number"]) {
                _subThoroughfare = component[@"long_name"];
            }
            
            if ([types containsObject:@"street_address"]) {
                _thoroughfare = component[@"long_name"];
            }
            
            if ([types containsObject:@"locality"]) {
                _locality = component[@"long_name"];
            }
            
            if ([types containsObject:@"neighborhood"]||[component[@"types"] containsObject:@"sublocality"]) {
                _subLocality = component[@"long_name"];
            }
            
            if ([types containsObject:@"locality"]) {
                _locality = component[@"long_name"];
            }
            
            if ([types containsObject:@"administrative_area_level_2"]) {
                _subAdministrativeArea = component[@"long_name"];
            }
            
            if ([types containsObject:@"administrative_area_level_1"]) {
                _administrativeArea = component[@"short_name"];
            }
            
            if ([types containsObject:@"postal_code"]) {
                _postalCode = component[@"long_name"];
            }
            
            if ([types containsObject:@"country"]) {
                _country = component[@"long_name"];
                _ISOcountryCode = component[@"short_name"];
            }
            
        }
    }
    return self;
}

#pragma mark - NSCoding/Copying

- (id)initWithCoder:(NSCoder *)aDecoder {
    SPGooglePlacesPlacemark *placemark = [[SPGooglePlacesPlacemark alloc] init];
    
    placemark->_location = [aDecoder decodeObjectForKey:kNSCodingKeyLocation];
    placemark->_region = [aDecoder decodeObjectForKey:kNSCodingKeyRegion];
    placemark->_addressDictionary = [aDecoder decodeObjectForKey:kNSCodingKeyAddressDictionary];
    placemark->_name = [aDecoder decodeObjectForKey:kNSCodingKeyName];
    placemark->_thoroughfare = [aDecoder decodeObjectForKey:kNSCodingKeyThoroughfare];
    placemark->_locality = [aDecoder decodeObjectForKey:kNSCodingKeyLocality];
    placemark->_subLocality = [aDecoder decodeObjectForKey:kNSCodingKeySubLocality];
    placemark->_administrativeArea = [aDecoder decodeObjectForKey:kNSCodingKeyAdministrativeArea];
    placemark->_subAdministrativeArea = [aDecoder decodeObjectForKey:kNSCodingKeySubAdministrativeArea];
    placemark->_postalCode = [aDecoder decodeObjectForKey:kNSCodingKeyPostalCode];
    placemark->_ISOcountryCode = [aDecoder decodeObjectForKey:kNSCodingKeyISOCountryCode];
    placemark->_inlandWater = [aDecoder decodeObjectForKey:kNSCodingKeyInlandWater];
    placemark->_ocean = [aDecoder decodeObjectForKey:kNSCodingKeyOcean];
    placemark->_areasOfInterest = [aDecoder decodeObjectForKey:kNSCodingKeyAreasOfInterest];
    placemark->_addressString = [aDecoder decodeObjectForKey:kNSCodingKeyAddressString];

    return placemark;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_location forKey:kNSCodingKeyLocation];
    [aCoder encodeObject:_region forKey:kNSCodingKeyRegion];
    [aCoder encodeObject:_addressDictionary forKey:kNSCodingKeyAddressDictionary];
    [aCoder encodeObject:_addressString forKey:kNSCodingKeyAddressString];
    [aCoder encodeObject:_name forKey:kNSCodingKeyName];
    [aCoder encodeObject:_thoroughfare forKey:kNSCodingKeyThoroughfare];
    [aCoder encodeObject:_subThoroughfare forKey:kNSCodingKeySubThoroughfare];
    [aCoder encodeObject:_locality forKey:kNSCodingKeyLocality];
    [aCoder encodeObject:_subLocality forKey:kNSCodingKeySubLocality];
    [aCoder encodeObject:_administrativeArea forKey:kNSCodingKeyAdministrativeArea];
    [aCoder encodeObject:_subAdministrativeArea forKey:kNSCodingKeySubAdministrativeArea];
    [aCoder encodeObject:_postalCode forKey:kNSCodingKeyPostalCode];
    [aCoder encodeObject:_ISOcountryCode forKey:kNSCodingKeyISOCountryCode];
    [aCoder encodeObject:_country forKey:kNSCodingKeyCountry];
    [aCoder encodeObject:_inlandWater forKey:kNSCodingKeyInlandWater];
    [aCoder encodeObject:_ocean forKey:kNSCodingKeyOcean];
    [aCoder encodeObject:_areasOfInterest forKey:kNSCodingKeyAreasOfInterest];

}


- (id)copyWithZone:(NSZone *)zone {
    SPGooglePlacesPlacemark *placemark = [[SPGooglePlacesPlacemark alloc] init];
    
    placemark->_location = [_location copyWithZone:zone];
    placemark->_region = [_region copyWithZone:zone];
    placemark->_addressDictionary = [_addressDictionary copyWithZone:zone];
    placemark->_name = [_name copyWithZone:zone];
    placemark->_thoroughfare = [_thoroughfare copyWithZone:zone];
    placemark->_locality = [_locality copyWithZone:zone];
    placemark->_subLocality = [_subLocality copyWithZone:zone];
    placemark->_administrativeArea = [_administrativeArea copyWithZone:zone];
    placemark->_subAdministrativeArea = [_subAdministrativeArea copyWithZone:zone];
    placemark->_postalCode = [_postalCode copyWithZone:zone];
    placemark->_ISOcountryCode = [_ISOcountryCode copyWithZone:zone];
    placemark->_country = [_country copyWithZone:zone];
    placemark->_inlandWater = [_inlandWater copyWithZone:zone];
    placemark->_ocean = [_ocean copyWithZone:zone];
    placemark->_areasOfInterest = [_areasOfInterest copyWithZone:zone];
    placemark->_addressString = [_addressString copyWithZone:zone];

    return placemark;
}

@end
