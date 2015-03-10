//
//  SPGooglePlacesPlacemark.h
//  SPGooglePlacesAutocomplete
//
//  Created by Eric Wolfe on 4/11/13.
//  Copyright (c) 2013 Eric Wolfe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/*!
 Mirror of Apple's CLPlacemark that can be initialized with Google Place API data. See CLPlacemark documentation for additional information.
 */
@interface SPGooglePlacesPlacemark : NSObject <NSCopying, NSCoding>

/*!
 Initializes a SPGooglePlacesPlacemark with the data from a native CLPlacemark.
 */
- (id)initWithCLPlacemark:(CLPlacemark *)placemark;

/*!
 Initializes a SPGooglePlacesPlacemark with the JSON data from a Google Places API request.
 */
- (id)initWithPlaceDictionary:(NSDictionary *)placeDictionary;

/*!
 Returns the geographic location associated with the placemark.
 */
@property (nonatomic, readonly) CLLocation *location;

/*!
 Returns the geographic region associated with the placemark.
 */
@property (nonatomic, readonly) CLCircularRegion *region;

/*
 *  addressDictionary
 *
 *  Discussion:
 *    This dictionary can be formatted as an address using ABCreateStringWithAddressDictionary,
 *    defined in the AddressBookUI framework.
 */
@property (nonatomic, readonly) NSDictionary *addressDictionary;
@property (nonatomic, readonly) NSString *addressString;

// address dictionary properties
@property (nonatomic, readonly) NSString *name; // eg. Apple Inc.
@property (nonatomic, readonly) NSString *thoroughfare; // street address, eg. 1 Infinite Loop
@property (nonatomic, readonly) NSString *subThoroughfare; // eg. 1
@property (nonatomic, readonly) NSString *locality; // city, eg. Cupertino
@property (nonatomic, readonly) NSString *subLocality; // neighborhood, common name, eg. Mission District
@property (nonatomic, readonly) NSString *administrativeArea; // state, eg. CA
@property (nonatomic, readonly) NSString *subAdministrativeArea; // county, eg. Santa Clara
@property (nonatomic, readonly) NSString *postalCode; // zip code, eg. 95014
@property (nonatomic, readonly) NSString *ISOcountryCode; // eg. US
@property (nonatomic, readonly) NSString *country; // eg. United States
@property (nonatomic, readonly) NSString *inlandWater; // eg. Lake Tahoe
@property (nonatomic, readonly) NSString *ocean; // eg. Pacific Ocean
@property (nonatomic, readonly) NSArray *areasOfInterest; // eg. Golden Gate Park

@property (nonatomic, readonly) NSArray *placeTypes; // eg. restaurant, aquarium, etc.: https://developers.google.com/places/documentation/supported_types


@end
