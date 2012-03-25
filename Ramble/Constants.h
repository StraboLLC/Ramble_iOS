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
//#define uploadServerURL @"http://localhost/~tnbeatty/strabotest/ramble/mobileapi/v1/upload.php"
//#define loginServerURL @"http://localhost/~tnbeatty/strabotest/ramble/mobileapi/v1/login.php"
#define uploadServerURL @"https://ramble.strabogis.com/mobileapi/v1/upload.php"
#define loginServerURL @"http://ramble.strabogis.com/mobileapi/v1/login.php"

// Authentication Challenge Constants
#define STRUserName @"team"
#define STRPassword @"strabogus"

#endif
#ifdef RELEASE

// Release specific definitions here
#define uploadServerURL @"http://production.strabogis.com/mobile-upload.php"
#define loginServerURL @"http://production.strabogis.com/login.php"

#endif

// Non build-specific definitions here

// UUID NSUserDefaults Key
#define STRUUIDKey @"STRUUIDKey"
#define STRSaltHash @"str480GUS"    

// Facebook NSUserDefaults Constants
#define FBAccessTokenKey @"FBAccessTokenKey"
#define FBUserIDKey @"FBUserIDKey"
#define FBExpirationDateKey @"FBExpirationDateKey"

// Local NSUserDefaults Constants
#define STRAccessTokenKey @"STRAccessTokenKey"

// Preferences NSUserDefaults Constants
#define STRPrecisionLocationModeOnKey @"STRPrecisionLocationModeOnKey"
#define STRCompassModeMagneticKey @"STRCompassModeMagneticKey"
#define STRLaunchToCaptureModeKey @"STRLaunchToCaptureModeKey"
#define STRVideoModeHighKey @"STRVideoModeHighKey"

// Keychain Constants ** UNUSED FOR NOW
#define keychainIdentifier @"StraboGISLoginData"

// Video Quality Constants
#define STRVideoQualityLow AVCaptureSessionPreset352x288
#define STRVideoQualityHigh AVCaptureSessionPreset640x480

// User experience stuff here

#define UntitledTrackTitle @"Untitled Track"

#endif
