# RNSwiftHealthkit
A rough React Native module with bare bones functionality for iOS Healthkit

### Objective ###

I recently worked on a project where we had to tap into some of the info stored in iOS Healthkit from a React Native front end. Finding a module that worked straight off the bat was a challenge. My objective with this mini-module is to allow you to get working with iOS Healthkit from React Native **quickly**. I provide some sample functions that allow you to request access to the user's info and show you how to read certain data types, but atm this is more of a template for you to go and expand yourself to access the info you desire. 


### Set-up 

1. In XCODE right click on your project folder and select 'New file'. Select the 'Swift file' option and name it 'RNSwiftHealthkit'. You will be asked if you would like to configure an Objective C bridging header. Select the 'Create Bridging Header' option.

2. Right click on the project folder and once again select 'New file', though this time choose the 'Objective-C file' option. Name the file 'RNSwiftHealthkitBridge'.

3. Time for some good old copy and pasting (I apologise). 

  * Open your new 'RNSwiftHealthkit.swift' and paste in the contents of RNSwiftHealthkit.swift from this repo.
  * Open your new 'RNSwiftHealthkitBridge.m' and paste in the contents of RNSwiftHealthkitBridge.m from this repo.
  * Open your new Bridging Header file and yes, you guessed it, paste in the contents of RNSwiftHealthkit-Bridging-Header.h from this repo.
  
4. Test that everything has been integrated correctly by re-building your project in XCODE.


### Usage ###

1. In a JS file within your build, require React Native as follows:

    ```var ReactNative = require('react-native');```
    
2. Decide what data you would like to read and write from the users Healthkit store. Checkout out the Apple Docs (https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/) to see what kind of data types are available. 

  In this example we will choose to read the following:
  
  * HKCharacteristicTypeIdentifierDateOfBirth
  * HKCharacteristicTypeIdentifierBloodType
  * HKCharacteristicTypeIdentifierBiologicalSex
  * HKCharacteristicTypeIdentifierFitzpatrickSkinType
  * HKQuantityTypeIdentifierBodyMass
  * HKQuantityTypeIdentifierHeight
  * User workouts (does not have type identifier)
  
  And we will choose to write the following:
  
  * HKQuantityTypeIdentifierBodyMassIndex
  * HKQuantityTypeIdentifierActiveEnergyBurned
  
  We will place our data types into relevant 'read' and 'write' objects:
  
  ```
  var typesToRead = {
    "characteristic": [
      'HKCharacteristicTypeIdentifierDateOfBirth',
      'HKCharacteristicTypeIdentifierBloodType',
      'HKCharacteristicTypeIdentifierBiologicalSex',
      'HKCharacteristicTypeIdentifierFitzpatrickSkinType'
    ],
    "quantity": [
      'HKQuantityTypeIdentifierBodyMass',
      'HKQuantityTypeIdentifierHeight'
    ],
    "workout": []
  };

  var typesToWrite = {
      "quantity": [
        'HKQuantityTypeIdentifierBodyMassIndex',
        'HKQuantityTypeIdentifierActiveEnergyBurned'
      ]
  };
  ```
  
  ### Functions
  
  1. **authorizeHealthKit(typesToWrite, typesToRead)**
  
    ```authorizeHealthKit``` requests access to the user's data types that you have decided that you need access to for your application. This has to be ran before anything else.
    
  2.  **readCharacteristics(callback)**
  
      returns the users DOB, blood type and skin colour.
    
  3. **readWeight(callback)** and **readHeight(callback)** do what they say on the tin.
  
  To call these functions:
  
  ```
  ReactNative.NativeModules.RNSwiftHealthKit.authorizeHealthKit(typesToWrite, typesToRead);

  ReactNative.NativeModules.RNSwiftHealthKit.readCharacteristics(function(characteristics) {
      console.log(characteristics);
  });
  
  ReactNative.NativeModules.RNSwiftHealthKit.readWeight(function(weight) {
      console.log(weight);
  });
  
  ReactNative.NativeModules.RNSwiftHealthKit.readHeight(function(height) {
      console.log(height);
  });
  ```
  
  ### Where to next
  
  I'd love to continue working on this and am very happy for people to submit PR's to enhance the small amount of functionality that we currently have here. Particularly:
  
    1. It would be great to figure out how to just ``rnpm link`` this into a user's project after installing as a node module but I wasn't able to get that working.
    2. Very happy to hear from people more adept at Swift who have pointers on how things could work more efficiently in 'RNSwiftHealthkit.swift'
    
  ### Sources
  
    1. This is very heavily based on code written by Ernesto Garcia in an article on the Ray Wenderlich tutorials site:
  
    https://www.raywenderlich.com/86336/ios-8-healthkit-swift-getting-started
  
    2. Similarly, some of the logic has been taken from Grabbou's 'react-native-healthkit' library:
  
    https://github.com/grabbou/react-native-healthkit
  
    Other sources include:
  
    http://moduscreate.com/swift-modules-for-react-native/
    https://facebook.github.io/react-native/docs/native-modules-ios.html
  

  
  





