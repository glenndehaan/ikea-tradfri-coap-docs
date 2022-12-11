# Ikea Tradfri CoAP Docs

How can you communicate to your Ikea tradfri gateway/hub through coap-client. Tested with Tradfri hub version 1.3.0014, 1.8.0025 and 1.12.0.

> Note: After 3 Years of rocking Ikea tradfri hardware I gave up. After several bugs/crashes and even several hardware failures I switched to Philips Hue (yes yes I know you get what you paid for, but waking up in the middle of the night because all lights turned on since there was a firmware update running was not fun anymore). However, I will still try to maintain these docs as much as possible, and I will also still look at new issues created on this repository to help here I can. So if you have more information you want me to add into this guide don't hesitate to open an issue, And I'm happy to add it to the docs.

## Table of Contents
* [Ikea Tradfri CoAP Docs](#ikea-tradfri-coap-docs)
    * [Table of Contents](#table-of-contents)
    * [Install coap-client](#install-coap-client)
        * [Linux](#linux)
        * [Windows](#windows)
    * [Authenticate](#authenticate)
    * [The URL](#the-url)
    * [Devices](#devices)
        * [Get a list of all devices](#get-a-list-of-all-devices)
        * [Get info about a specific device](#get-info-about-a-specific-device)
    * [Groups](#groups)
        * [Get a list of all groups](#get-a-list-of-all-groups)
        * [Get info about a specific group](#get-info-about-a-specific-group)
        * [Add device to a specific group](#add-device-to-a-specific-group)
        * [Remove device from a specific group](#remove-device-from-a-specific-group)
        * [Turn on all devices in a specific group](#turn-on-all-devices-in-a-specific-group)
        * [Payload](#payload)
    * [Scenes](#scenes)
        * [Get a list of all scenes](#get-a-list-of-all-scenes)
        * [Get info about a specific scene](#get-info-about-a-specific-scene)
        * [Activating a scene](#activating-a-scene)
    * [Endpoints](#endpoints)
        * [List all available endpoints](#list-all-available-endpoints)
    * [Sensor](#sensor)
    * [Remote](#remote)
    * [Shortcut button](#shortcut-button)
    * [Bulbs](#bulbs)
        * [Your first bulb](#your-first-bulb)
        * [Payload](#payload-1)
        * [Colors](#colors)
            * [Cold / Warm Bulbs](#cold--warm-bulbs)
            * [RGB Bulbs](#rgb-bulbs)
        * [More Colors](#more-colors)
    * [Plug](#plug)
        * [Your first plug](#your-first-plug)
        * [Payload](#payload-2)
    * [Blind](#blind)
        * [Your first blind](#your-first-blind)
        * [Payload](#payload-3)
    * [Air Purifier](#air-purifier)
        * [Your first air purifier](#your-first-air-purifier)
        * [Payload](#payload-4)
    * [Endpoints](#endpoints-1)
        * [Global](#global)
        * [Gateway](#gateway)
    * [Codes](#codes)
        * [Devices](#devices-1)
        * [General parameters](#general-parameters)
        * [Group parameters](#group-parameters)
        * [Scene parameters](#scene-parameters)
        * [Bulb parameters](#bulb-parameters)
        * [Plug parameters](#plug-parameters)
        * [Blind parameters](#blind-parameters)
        * [Air Purifier parameters](#air-purifier-parameters)
    * [CoAP Protocol](#coap-protocol)
        * [CoAP Response Codes](#coap-response-codes)
        * [CoAP Method Codes](#coap-method-codes)
    * [More documentation](#more-documentation)
    * [License](#license)


## Install coap-client
Before you can talk to you Ikea gateway/hub you need to install the coap-client:

### Linux
1. Download the `install-coap-client.sh` from github (you find this script in the scripts folder of the repository).
2. Chmod the file, so you can run it.
3. Run the file as root.

### Windows
With thanks to Stefan Thoolen (@Garrcomm)

1. Download and install `Visual Studio 2019 CE with workload "Desktop development with C++"`
2. Download and install `OpenSSL v1.1.1k including development files`
3. Download the `build-libcoap-win-x64.cmd` from github (you find this script in the scripts folder of the repository).
4. Run the file as administrator.

## Authenticate
First we need to create a preshared key. This key can then be used to authenticate yourself:
Please note: this key will expire if you don't use it in 6 weeks from activation. Every time you use this key the time will be extended accordingly.

```
coap-client -m post -u "Client_identity" -k "$TF_GATEWAYCODE" -e "{\"9090\":\"$TF_USERNAME\"}" "coaps://$TF_GATEWAYIP:5684/15011/9063"
```

* $TF_USERNAME: Can be a random name as long as you use it in the other requests you want to make
* $TF_GATEWAYCODE: Is the security code at the bottom of your Gateway/HUB. It should be 16 characters long.
* $TF_GATEWAYIP: Is the IP of your Gateway/HUB

This will then respond something like this:
```json5
{
  "9091": "$TF_PRESHARED_KEY", // Preshared Key
  "9029": "1.3.0014" // Gateway Firmware version
}
```

## The URL
To control a bulb you need to know it's URL. This is very easy. The URL's all begin with `coaps://$TF_GATEWAYIP:5684/15001`

The bulbs will have addresses beginning at `65537` for the first bulb, `65538` for the second, and so on. So, to control the first bulb, you would use the following url:
```
coaps://$TF_GATEWAYIP:5684/15001/65537
```

## Devices

### Get a list of all devices
To get a complete list of all devices connected to your hub use the following command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/15001"
```

### Get info about a specific device
To check the current status of a connected device and to know which device is linked to a specified id, use this command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/15001/$TF_DEVICEID"
```

> `$TF_DEVICEID` is an id from the list generated by the previous command. Ids are 5 digits long.

The result will look something similar to this:

```json5
{
  "9001": "Warm white bulb",
  "9002": 429400800,
  "9003": 65561,
  "9020": 1619068199,
  "3311": [
    {
      "5850": 0,
      "5849": 2,
      "9003": 0,
      "5851": 1
    }
  ],
  "9019": 1,
  "3": {
    "0": "IKEA of Sweden",
    "1": "TRADFRI bulb E27 WW 806lm",
    "3": "2.3.050"
  },
  "5750": 2
}
```

The numbers translate to the following labels:

Numeric key | Type    | Description
----------- | ------- | -----------
3.0         | string  | Manufacturer name
3.1         | string  | Product name
3.3         | string  | Firmware version
3.9         | integer | Battery status, 0 to 100 (not available in the example above since bulbs don't have batteries)
3311        | array   | Bulb data, see also [Bulbs](#bulbs)
5750        | integer | Device type (2 stands for Bulb)
9001        | string  | Name of the device
9002        | integer | Creation timestamp
9003        | integer | Instance ID
9020        | integer | Last seen timestamp
9019        | boolean | Reachability state

## Groups

### Get a list of all groups
To get a complete list of all groups use the following command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/15004"
```

### Get info about a specific group
To check the current status of a group and to know which devices are linked to the specified id, use this command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/15004/$TF_GROUPID"
```

> `$TF_GROUPID` is an id from the list generated by the previous command. Ids are 6 digits long.

The result will look something similar to this:

```json5
{
  "9001": "Home office",
  "9018": {
    "15002": {
      "9003": [
        65558,
        65561,
        65563
      ]
    }
  },
  "5851": 254,
  "9003": 131087,
  "9002": 429400800,
  "5850": 1
}
```

The numbers translate to the following labels:

Numeric key | Type    | Description
----------- | ------- | -----------
5850        | boolean | On/off status of the group
5851        | integer | Brightness status of the group
9001        | string  | Name of the group
9002        | integer | Creation timestamp
9003        | integer | Instance ID
9018        | array   | List of items within the group

### Add device to a specific group
To add a member device to a group, use this command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "9038": $TF_GROUPID, "9003": [ $TF_DEVICEID ] }' "coaps://$TF_GATEWAYIP:5684/15004/add"
```

### Remove device from a specific group
To remove a member device from a group, use this command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "9038": $TF_GROUPID, "9003": [ $TF_DEVICEID ] }' "coaps://$TF_GATEWAYIP:5684/15004/remove"
```

### Turn on all devices in a specific group
To control a specific group, use this command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "5850": 1 }' "coaps://$TF_GATEWAYIP:5684/15004/$TF_GROUPID"
```

> `$TF_GROUPID` is an id from the list generated by the `Get a list of all groups` command. Ids are 6 digits long.

### Payload
Here is an example payload for coap-client with explanation what each field does:
```json5
{
  "5850": 1, // on / off (needs to be set to 1 to switch scenes)
  "5851": 254, // dimmer (1 to 254)
  "5712": 10, // transition time (fade time)
  "9039": 196621 // scene id for activating/switching scenes (id comes from the list generated by the `Get a list of all scenes` command. Ids are 6 digits long.)
}
```

## Scenes
Note: scenes where formerly known as moods inside the Ikea Tradfri app. This change was introduced at version 1.12.0

### Get a list of all scenes
To get a complete list of all scenes use the following command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/15005/$TF_GROUPID"
```

> `$TF_GROUPID` is an id from the list generated by the `Get a list of all groups` command. Ids are 6 digits long.

### Get info about a specific scene
To get the current configuration of a scene and to know which devices are linked to the specified id, use this command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/15005/$TF_GROUPID/$TF_SCENEID"
```

> `$TF_SCENEID` is an id from the list generated by the previous command. Ids are 6 digits long.

> `$TF_GROUPID` is an id from the list generated by the `Get a list of all groups` command. Ids are 6 digits long.

The result will look something similar to this:

```json5
{
  "9001": "Home office dimmed",
  "9109": 2,
  "9003": 196630,
  "9002": 429400800,
  "9057": 1,
  "15013": [
    {
      "5850": 0,
      "9003": 65544,
      "5851": 2
    },
    {
      "5850": 0,
      "9003": 65539
    },
    {
      "5850": 0,
      "9003": 65545
    },
    {
      "5850": 1,
      "9003": 65546,
      "5851": 2
    },
    {
      "5850": 1,
      "9003": 65557,
      "5851": 2
    }
  ]
}
```

The numbers translate to the following labels:

Numeric key | Type    | Description
----------- | ------- | -----------
9001        | string  | Name of the scene
9002        | integer | Creation timestamp
9003        | integer | Instance ID
9057        | integer | Scene index
9109        | integer | Icon index
15013       | array   | Light settings

### Activating a scene
A scene can be activated by controlling a specific group. From this endpoint you are able to set a scene on the specified group.
A detailed payload can be found in the `Groups > Payload` chapter.
The following command can be used to activate a scene in a group:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "5850": 1, "9039": $TF_SCENEID }' "coaps://$TF_GATEWAYIP:5684/15004/$TF_GROUPID"
```

> `$TF_GROUPID` is an id from the list generated by the `Get a list of all groups` command. Ids are 6 digits long.

> `$TF_SCENEID` is an id from the list generated by the `Get a list of all scenes` command. Ids are 6 digits long.

## Endpoints

### List all available endpoints
To get a complete list of available endpoints on your gateway use the following command:
```
coap-client -m get -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" "coaps://$TF_GATEWAYIP:5684/.well-known/core"
```

## Sensor
The (motion) sensor is **unsupported** at the moment, since the gateway doesn't receive any useful information from the sensor.
The cause of this could be since the device is running of batteries. And if the sensor needs to send data back constantly to the gateway it would run out of them pretty quickly.
If someone has more information about the sensor please open an issue of create a pull request to update the documentation.

## Remote
The remote is **unsupported** at the moment, since the gateway doesn't receive any useful information from the remote.
The cause of this could be since the device is running of batteries. And if the remote needs to send data back constantly to the gateway it would run out of them pretty quickly.
If someone has more information about the remote please open an issue of create a pull request to update the documentation.

## Shortcut button
The Ikea shortcut button was introduced around november 2020.

The button is **unsupported** at the moment, since the gateway doesn't receive any useful information from the button.
The cause of this could be since the device is running of batteries. And if the button needs to send data back constantly to the gateway it would run out of them pretty quickly.
If someone has more information about the button please open an issue of create a pull request to update the documentation.

## Bulbs

> Note: It seems that in bulb firmware v2.3.086 the default behaviour for a non-existing hue color changed. Previously the bulb would go to the default warm color, but now the bulb turns off while reporting it's still on. See more details in issue #31

### Your first bulb
To set the brightness of your first bulb to 50% use the following command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "3311": [{ "5851": 127 }] }' "coaps://$TF_GATEWAYIP:5684/15001/$TF_DEVICEID"
```

### Payload
Here is an example payload for coap-client with explanation what each field does:
```json5
{
  "3311": [
    {
      "5850": 1, // on / off
      "5851": 254, // dimmer (1 to 254)
      "5706": "f1e0b5", // color in HEX (Don't use in combination with: color X and/or color Y)
      "5709": 65535, // color X (Only use in combination with color Y)
      "5710": 65535, // color Y (Only use in combination with color X)
      "5712": 10 // transition time (fade time)
    }
  ]
}
```

### Colors
The following colors where taken from the Ikea Android app (these could be used in field `"5706"`):

Please note: If you are using another HEX value then these the lamp will default to the Warm Glow color.

#### Cold / Warm Bulbs
Lightbulbs running on firmware less then ±2.3.087
```
"f5faf6": "White",
"f1e0b5": "Warm",
"efd275": "Glow"
```

Lightbulbs running on firmware ±2.3.087 and up:
```
"efd275": "Glow"
"f1e0b5": "Warm"
"f2eccf": "LightWarm"
"f3f3e3": "LightWhite"
"f5faf6": "White"
```

#### RGB Bulbs
```
"4a418a": "Blue",
"6c83ba": "Light Blue",
"8f2686": "Saturated Purple",
"a9d62b": "Lime",
"c984bb": "Light Purple",
"d6e44b": "Yellow",
"d9337c": "Saturated Pink",
"da5d41": "Dark Peach",
"dc4b31": "Saturated Red",
"dcf0f8": "Cold sky",
"e491af": "Pink",
"e57345": "Peach",
"e78834": "Warm Amber",
"e8bedd": "Light Pink",
"eaf6fb": "Cool daylight",
"ebb63e": "Candlelight",
"efd275": "Warm glow",
"f1e0b5": "Warm white",
"f2eccf": "Sunrise",
"f5faf6": "Cool white"
```

### More Colors
Ikea RGB bulbs can produce more colors than the list above.

They can produce all colors in the xyY color space.

To understand how this color space works take a look at the diagram below:

![xyY Color Space](https://user-images.githubusercontent.com/7496187/48645383-d4192380-e9e5-11e8-8466-5de1248720ca.png)

To create your own color you need define two values (x and y) from 0 to 65535 with this command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "3311": ["5709": 65535, "5710": 65535] }' "coaps://$TF_GATEWAYIP:5684/15001/$TF_DEVICEID"
```

## Plug
The Ikea plug was introduced around October 2018.

Also this device can be controlled with the same api.

### Your first plug
To turn on a plug use the following command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "3312": [{ "5850": 1 }] }' "coaps://$TF_GATEWAYIP:5684/15001/$TF_DEVICEID"
```

### Payload
Here is an example payload for coap-client with explanation what each field does:
```json5
{
  "3312": [
    {
      "5850": 1, // on / off
      "5851": 254 // dimmer (0 to 254) (As of writing there arn't any dimmable plugs. Value's above 0 will simply turn on the plug)
    }
  ]
}
```

## Blind
The Ikea blinds where introduced around August 2019.

Also, this device can be controlled with the same api.

### Your first blind
To change position of a blind use the following command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "15015": [{ "5536": 0.0 }] }' "coaps://$TF_GATEWAYIP:5684/15001/$TF_DEVICEID"
```

### Payload
Here is an example payload for coap-client with explanation what each field does:
```json5
{
  "15015": [
    {
      "5536": 0.0 // position (0 to 100)
    }
  ]
}
```

## Air Purifier
The Ikea Air Purifier was introduced around April 2021.

Also, this device can be controlled with the same api.

### Your first air purifier
To change the fan mode of the air purifier use the following command:
```
coap-client -m put -u "$TF_USERNAME" -k "$TF_PRESHARED_KEY" -e '{ "15025": [{ "5900": 50 }] }' "coaps://$TF_GATEWAYIP:5684/15001/$TF_DEVICEID"
```

### Payload
Here is an example payload for coap-client with explanation what each field does:
```json5
{
  "15025": [
    {
      "5900": 50, // fan mode (0 = Off, 1 = Auto, 10 = Level 1, 20 = Level 2, 30 = Level 3, 40 = Level 4, 50 = Level 5)
      "5908": 10, // fan speed
      "5905": false, // lock/unlock control buttons
      "5906": false // enables/disables the status LED's
    }
  ]
}
```

## Endpoints

### Global
| URL                              | Description            |
|----------------------------------|------------------------|
| coaps://$TF_GATEWAYIP:5684/15001 | Devices endpoint       |
| coaps://$TF_GATEWAYIP:5684/15004 | Groups endpoint        |
| coaps://$TF_GATEWAYIP:5684/15005 | Scenes endpoint        |
| coaps://$TF_GATEWAYIP:5684/15006 | Notifications endpoint |
| coaps://$TF_GATEWAYIP:5684/15010 | Smart Tasks endpoint   |

### Gateway
| URL                                    | Description                     |
|----------------------------------------|---------------------------------|
| coaps://$TF_GATEWAYIP:5684/15011/9030  | Reboot gateway endpoint         |
| coaps://$TF_GATEWAYIP:5684/15011/9031  | Reset gateway endpoint          |
| coaps://$TF_GATEWAYIP:5684/15011/9034  | UpdateFirmware gateway endpoint |
| coaps://$TF_GATEWAYIP:5684/15011/15012 | Gateway details endpoint        |

Please note: You need to use `-m post` for the reboot command to work.
## Codes

### Devices
| Code  | Description   | Type  |
|-------|---------------|-------|
| 3300  | Motion Sensor | Array |
| 3311  | Light/Bulb    | Array |
| 3312  | Plug          | Array |
| 15015 | Blind         | Array |
| 15025 | Air Purifier  | Array |

### General parameters
| Code | Description   | Type   |
|------|---------------|--------|
| 9001 | Name          | String |
| 9002 | Creation date | Int    |
| 9003 | Instance ID   | Int    |

### Group parameters
| Code | Description             | Type    |
|------|-------------------------|---------|
| 5712 | Transition Time         | Int     |
| 5850 | On/Off                  | Boolean |
| 5851 | Brightness              | Int     |
| 9018 | Accessory Link (Remote) | Array   |
| 9039 | Scene ID                | Int     |

### Scene parameters
| Code  | Description         | Type    |
|-------|---------------------|---------|
| 9058  | Scene Active State  | Boolean |
| 9057  | Device Index ID     | Int     |
| 9068  | Is Scene Predefined | Boolean |
| 15013 | Light Settings      | Array   |

### Bulb parameters
| Code | Description       | Type       |
|------|-------------------|------------|
| 5706 | Color HEX String  | HEX String |
| 5707 | Hue               | Int        |
| 5708 | Saturation        | Int        |
| 5709 | colorX            | Int        |
| 5710 | colorY            | Int        |
| 5711 | Color Temperature | Int        |
| 5712 | Transition Time   | Int        |
| 5850 | On/Off            | Boolean    |
| 5851 | Brightness        | Int        |

### Plug parameters
| Code | Description | Type    |
|------|-------------|---------|
| 5850 | On/Off      | Boolean |
| 5851 | Brightness  | Int     |

### Blind parameters
| Code | Description | Type  |
|------|-------------|-------|
| 5536 | Position    | Float |

### Air Purifier parameters
| Code  | Description               | Type    |
|-------|---------------------------|---------|
| 5907  | Air Quality               | Number  |
| 5905  | Controls Locked           | Boolean |
| 5900  | Fan Mode                  | Number  |
| 5908  | Fan Speed                 | Number  |
| 5904  | Total Filter Lifetime     | Number  |
| 5902  | Filter Runtime            | Number  |
| 5910  | Filter Remaining Lifetime | Number  |
| 5903  | Filter Status             | Number  |
| 5906  | Status LEDs               | Boolean |
| 5909  | Total Motor Runtime       | Number  |

## CoAP Protocol

### CoAP Response Codes
Below is a snippet from https://tools.ietf.org/html/rfc7252 containing the default CoAP response codes:
```
+------+------------------------------+-----------+
| Code | Description                  | Reference |
+------+------------------------------+-----------+
| 2.01 | Created                      | [RFC7252] |
| 2.02 | Deleted                      | [RFC7252] |
| 2.03 | Valid                        | [RFC7252] |
| 2.04 | Changed                      | [RFC7252] |
| 2.05 | Content                      | [RFC7252] |
| 4.00 | Bad Request                  | [RFC7252] |
| 4.01 | Unauthorized                 | [RFC7252] |
| 4.02 | Bad Option                   | [RFC7252] |
| 4.03 | Forbidden                    | [RFC7252] |
| 4.04 | Not Found                    | [RFC7252] |
| 4.05 | Method Not Allowed           | [RFC7252] |
| 4.06 | Not Acceptable               | [RFC7252] |
| 4.12 | Precondition Failed          | [RFC7252] |
| 4.13 | Request Entity Too Large     | [RFC7252] |
| 4.15 | Unsupported Content-Format   | [RFC7252] |
| 5.00 | Internal Server Error        | [RFC7252] |
| 5.01 | Not Implemented              | [RFC7252] |
| 5.02 | Bad Gateway                  | [RFC7252] |
| 5.03 | Service Unavailable          | [RFC7252] |
| 5.04 | Gateway Timeout              | [RFC7252] |
| 5.05 | Proxying Not Supported       | [RFC7252] |
+------+------------------------------+-----------+
```

### CoAP Method Codes
Below is a snippet from https://tools.ietf.org/html/rfc7252 containing the default CoAP method codes:
```
+------+--------+-----------+
| Code | Name   | Reference |
+------+--------+-----------+
| 0.01 | GET    | [RFC7252] |
| 0.02 | POST   | [RFC7252] |
| 0.03 | PUT    | [RFC7252] |
| 0.04 | DELETE | [RFC7252] |
+------+--------+-----------+
```

## More documentation
[Debugging COAPS with IKEA Tradfri gateway | @Jan21493](https://github.com/Jan21493/Debugging-COAPS-with-IKEA-Tradfri-gateway/blob/main/README.md)

## License

MIT
