# IKEA Tradfri COAP Docs

How can you communicate to your ikea tradfri gateway/hub through coap-client

## Install coap-client
Before you can talk to you Ikea gateway/hub you need to install the coap-client:
1. Download the `install-coap-client.sh` from github.
2. Chmod the file so you can run it.
3. Run the file as root.

## Authenticate
First we need to create a preshared key. This key can then be used to authenticate yourself:
Please note: this key will expire if you don't use it in 6 weeks from activation. Every time you use this key the time will be extended accordingly.

```
coap-client -m post -u "Client_identity" -k "$GATEWAYCODE" -e '{"9090":"$USERNAME"}' "coaps://$GATEWAYIP:5684/15011/9063"
```

* $USERNAME: Can be a random name as long as you use it in the other requests you want to make
* $GATEWAYCODE: Is the code at the bottom of your Gateway/HUB
* $GATEWAYIP: Is the IP of your Gateway/HUB

This will then respond something like this:
```
{"9091":"$PRESHARED_KEY","9029":"1.3.0014"}
```

## The URL
To control a bulb you need to know it's URL. This is very easy. The URL's all begin with `coaps://$GATEWAYIP:5684/15001`

The bulbs will have addresses beginning at `65537` for the first bulb, `65538` for the second, and so on. So, to control the first bulb, you would use the following url:
```
coaps://$GATEWAYIP:5684/15001/65537
```

## Get a list of all devices
To get a complete list of all devices connected to your hub use the following command:
```
coap-client -m get -u "$USERNAME" -k "$PRESHARED_KEY" "coaps://$GATEWAYIP:5684/15001
```

## Bulbs

### Your first bulb
To set the brightness of your first bulb to 50% use the following command:
```
coap-client -m put -u "$USERNAME" -k "$PRESHARED_KEY" -e '{ "3311": [{ "5851": 127 }] }' "coaps://$GATEWAYIP:5684/15001/65537"
```

### Payload
Here is an example payload for coap-client with explanation what each field does:
```
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
The following colors where taken from the IKEA Android app (these could be used in field `"5706"`):
Please note: If you are using another HEX value then these the lamp will default to the Warm Glow color.

#### Cold / Warm Bulbs
```
'f5faf6': 'White',
'f1e0b5': 'Warm',
'efd275': 'Glow'
```

#### RGB Bulbs

```
'4a418a': 'Blue',
'6c83ba': 'Light Blue',
'8f2686': 'Saturated Purple',
'a9d62b': 'Lime',
'c984bb': 'Light Purple',
'd6e44b': 'Yellow',
'd9337c': 'Saturated Pink',
'da5d41': 'Dark Peach',
'dc4b31': 'Saturated Red',
'dcf0f8': 'Cold sky',
'e491af': 'Pink',
'e57345': 'Peach',
'e78834': 'Warm Amber',
'e8bedd': 'Light Pink',
'eaf6fb': 'Cool daylight',
'ebb63e': 'Candlelight',
'efd275': 'Warm glow',
'f1e0b5': 'Warm white',
'f2eccf': 'Sunrise',
'f5faf6': 'Cool white'
```

### More Colors
Ikea RGB bulbs can produce more colors then the list above.
They can produce all colors in the xyY color space.
To understand how this color space works take a look at the diagram below:

![xyY Color Space](https://user-images.githubusercontent.com/7496187/48645383-d4192380-e9e5-11e8-8466-5de1248720ca.png)

To create your own color you need define two values (x and y) from 0 to 65535 with this command:
```
coap-client -m put -u "$USERNAME" -k "$PRESHARED_KEY" -e '{ "3311": ["5709": 65535, "5710": 65535] }' "coaps://$GATEWAYIP:5684/15001/65537"
```

## Plug
The ikea plug was introduced around oktober 2018.
Also this device can be controlled with the same api.

### Your first plug
To turn on a plug use the following command:
```
coap-client -m put -u "$USERNAME" -k "$PRESHARED_KEY" -e '{ "3311": [{ "5850": 1 }] }' "coaps://$GATEWAYIP:5684/15001/65537"
```

### Payload
Here is an example payload for coap-client with explanation what each field does:
```
{
  "3311": [
    {
      "5850": 1, // on / off
      "5851": 254 // dimmer (0 to 254) (As of writing there arn't any dimmable plugs. Value's above 0 will simply turn on the plug)
    }
  ]
}
```

## License

MIT
