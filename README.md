# react-native-image2d

Image 2D processing module for React Native.

## Getting started

`npm install https://github.com/Reaction-Framework/react-native-image2d.git --save`

## iPhone setup 

* In XCode, add contents of `ios` directory to your main project

* [Create Objective-C bridging header](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-ID156) if not already created, and add missing headers:
```
...
#import "RCTBridgeModule.h"
#import "RCTUtils.h"
```

## Android setup 

* Run:
```
npm install https://github.com/Reaction-Framework/rction-image-android.git --save
```

* Add to your `settings.gradle`:
```
include ':io.reactionframework.android.image'
project(':io.reactionframework.android.image').projectDir = new File(settingsDir, '../node_modules/rction-image-android')

include ':io.reactionframework.android.react.image.image2d'
project(':io.reactionframework.android.react.image.image2d').projectDir = new File(settingsDir, '../node_modules/react-native-image2d/android')
```

* Add to your `app/build.gradle`:
```
dependencies {
	...
	compile project(':io.reactionframework.android.react.image.image2d')
}
```

* Add to your `MainActivity.java`:
  * `import io.reactionframework.android.react.image.image2d.Image2DPackage;`
  * in `onCreate`:
  ```
  mReactInstanceManager = ReactInstanceManager.builder()
	...
	.addPackage(new Image2DPackage())
	...
  ```

## Usage

```javascript
'use strict';

import React, { AppRegistry, StyleSheet, Text, View, TouchableHighlight, Image } from 'react-native';
import { Image2DContext } from 'react-native-image2d';

let image2DContext = null;

const Image2DExperiments = React.createClass({
    getInitialState() {
        return {
            base64String: 'INSERT_IMAGE_BASE64_STRING_HERE',
            size: {
                width: '?',
                height: '?'
            },
            operation: 'Create'
        }
    },
    render: function() {
        let base64String = 'data:image/jpeg;base64,' + this.state.base64String;
        return (
            <View style={styles.container}>
                <Image style={styles.image}
                       source={{uri: base64String}}/>
                <Text>
                    {this.state.size.width} x {this.state.size.height}
                </Text>
                <TouchableHighlight onPress={this.start}>
                    <Text>
                        {this.state.operation}
                    </Text>
                </TouchableHighlight>
            </View>
        );
    },
    start: async function() {
        let state = this.state;

        if(image2DContext === null) {
            image2DContext = await Image2DContext.create({
                base64String: state.base64String,
                maxWidth: 2000,
                maxHeight: 2000
            });

            state.size = await image2DContext.getSize();
            state.operation = 'Crop';

            this.setState(state);

            return;
        }

        let size = await image2DContext.getSize();

        if (state.operation === 'Crop') {
            state.operation = 'Add border';

            if(size.width > size.height) {
                let subtract = size.width - size.height;

                await image2DContext.crop({
                    left: Math.floor(subtract / 2),
                    top: 0,
                    right: Math.ceil(subtract / 2),
                    bottom: 0
                });
            } else if(size.width < size.height) {
                let subtract = size.height - size.width;

                await image2DContext.crop({
                    left: 0,
                    top: Math.floor(subtract / 2),
                    right: 0,
                    bottom: Math.ceil(subtract / 2)
                });
            }

            state.base64String = await image2DContext.getAsBase64String();
            state.size = await image2DContext.getSize();

            this.setState(state);
            return;
        }

        if (state.operation === 'Add border') {
            state.operation = 'Release';
            await image2DContext.drawBorder({
                left: 100,
                top: 100,
                right: 100,
                bottom: 100,
                color: '#e1ff3d'
            });

            state.base64String = await image2DContext.getAsBase64String();
            state.size = await image2DContext.getSize();

            this.setState(state);
            return;
        }

        await image2DContext.release();
        image2DContext = null;
        state.base64String = '';
        state.size = {};
        state.operation = 'Everything done';

        this.setState(state);
    }
});

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF'
    },
    image: {
        width: 200,
        height: 200,
        margin: 10
    }
});

AppRegistry.registerComponent('Image2DExperiments', () => Image2DExperiments);
```

Full example at [React Native Image2D Experiments](https://github.com/Reaction-Framework/react-native-image2d-experiments/)

## Image2DContext Class

Context for 2D drawing and image processing.

### Methods

#### `static async create(options)`

Creates and returns new instance of Image2DContext class. New Image2DContext is created from image with `fileUrl` or `base64String` to fit inside `maxWidth` and `maxHeight` dimensions. If image dimensions are smaller than `maxWidth` and `maxHeight`, image will keep its original dimensions.

Supported options:

 - `base64String` - Base64 string encoded image
 - `fileUrl` - Local device path of an image
 - `maxWidth` - Integer >= 0 max width of loaded image
 - `maxHeight` - Integer >= 0 max height of loaded image

Required options: `base64String` or `fileUrl`, `maxWidth`, `maxHeight`

#### `async save(options)`

Saves image from context on disk under `fileName` name. Return path to saved file.

Supported options:

 - `fileName` - Name of the file inside which image will be saved

Required options: `fileName`

#### `async getAsBase64String()`

Returns image from context as base64 encoded string.

#### `async getSize()`

Returns size of image from context. Size contains `width` and `height`.

#### `async crop(options)`

Crops image. Image is croped from the left by `left`, from the top by `top`, from the right by `right` and from the bottom by `bottom` pixels.

Supported options:

 - `left` - Integer >= 0 pixels to crop from the left
 - `top` - Integer >= 0 pixels to crop from the top
 - `right` - Integer >= 0 pixels to crop from the right
 - `bottom` - Integer >= 0 pixels to crop from the bottom

Required options: `left`, `top`, `right`, `bottom`

#### `async drawBorder(options)`

Draws border around image in context. Border width in pixels around image is defined by `left`, `top`, `right` and `bottom` options.

Supported options:

 - `left` - Integer >= 0 border width on the left
 - `top` - Integer >= 0 border width on the top
 - `right` - Integer >= 0 border width on the right
 - `bottom` - Integer >= 0 border width on the bottom
 - `color` - Color of the border, default is `black`
     - iOS supports:
         - formats: #RGB, #ARGB, #RRGGBB, #AARRGGBB;
         - names, [used from here](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIColor_Class/#//apple_ref/doc/uid/TP40006892-CH3-SW18): 'black', 'darkGray', 'lightGray', 'white', 'gray', 'red', 'green', 'blue', 'cyan', 'yellow', 'magenta', 'orange', 'purple', 'brown', 'clear'.
     - Android supports as [stated here](http://developer.android.com/reference/android/graphics/Color.html#parseColor(java.lang.String)):
         - formats: #RRGGBB, #AARRGGBB;
         - names: 'red', 'blue', 'green', 'black', 'white', 'gray', 'cyan', 'magenta', 'yellow', 'lightgray', 'darkgray', 'grey', 'lightgrey', 'darkgrey', 'aqua', 'fuchsia', 'lime', 'maroon', 'navy', 'olive', 'purple', 'silver', 'teal'.

Required options: `left`, `top`, `right`, `bottom`

#### `async release()`

Releses context. Context should not be reused after it is released.
