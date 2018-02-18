# IKEA Tradfri COAP Docs

How can you communicate to your ikea tradfri gateway/hub through coap-client

## Install coap-client
Before you can talk to you Ikea gateway/hub you need to install the coap-client:
1. Download the `install-coap-client.sh` form github.
2. Chmod the file so you can run it.
3. Run the file as root.

## Authenticate
First we need to create a preshared key. This key can then be used to authenticate yourself:
```
coap-client -m put -u "$USERNAME" -k "$GATEWAYCODE" -e '{ "3311": [{ "5850": 0 }] }' "coaps://$GATEWAYIP:5684/15001/65537"
```

* $USERNAME: Can be a random name as long as you use it in the other requests you want to make
* $GATEWAYCODE: Is the code at the bottom of your Gateway/HUB
* $GATEWAYIP: Is the IP of your Gateway/HUB

## The URL
To control a bulb you need to know it's URL. This is very easy. The URL's all begin with `coaps://192.168.0.10:5684/15001`

The bulbs will have addresses beginning at `65537` for the first bulb, `65538` for the second, and so on. So, to control the first bulb, you would use the following url:
```
coaps://192.168.0.10:5684/15001/65537
```

## Your first bulb
To set the brightness of your first bulb to 50% use the following code:
```
coap-client -m put -u "$USERNAME" -k "$GATEWAYCODE" -e '{ "3311": [{ "5851": 127 }] }' "coaps://$GATEWAYIP:5684/15001/65537"
```

## Payload
Here is an example payload for coap-client with explanation what each field does:
```
{
  "3311": [
    {
      "5850": 1, // on / off
      "5851": 254, // dimmer (1 to 254)
      "5706": "f1e0b5", // color in HEX
      "5712": 10 // transition time (fade time)
    }
  ]
}
```

## Colors
The following colors where taken form the IKEA Android app (these could be used in field `"5706"`):

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
## License

MIT
