//
//  Constants.h
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#ifndef Ramble_Constants_h
#define Ramble_Constants_h

// Below, define constants to be used throughout the application
// This header file is included in every other app header file

#ifdef DEBUG

// Debugging specific definitions here
#define uploadServerURL @"http://localhost/~tnbeatty/strabotest/ramble/mobileapi/v1/upload.php"
#define loginServerURL @"http://localhost/~tnbeatty/strabotest/ramble/mobileapi/v1/login.php"

#endif
#ifdef RELEASE

// Release specific definitions here
#define uploadServerURL @"http://production.strabogis.com/mobile-upload.php"
#define loginServerURL @"http://production.strabogis.com/login.php"

#endif

// Non build-specific definitions here

// Facebook NSUserDefaults Constants
#define FBAccessTokenKey @"FBAccessTokenKey"
#define FBExpirationDateKey @"FBExpirationDateKey"

// Local NSUserDefaults Constants
#define STRAccessTokenKey @"STRAccessTokenKey"
#define STRSaltHash @"123456"
#define STRUUIDKey @"STRUUIDKey"

// Preferences NSUserDefaults Constants
#define STRPrecisionLocationModeOnKey @"STRPrecisionLocationModeOnKey"
#define STRCompassModeMagneticKey @"STRCompassModeMagneticKey"
#define STRLaunchToCaptureModeKey @"STRLaunchToCaptureModeKey"

// Keychain constants here
#define keychainIdentifier @"StraboGISLoginData"

// Table Cell constants here


#endif
