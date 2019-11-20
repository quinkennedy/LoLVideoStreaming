A project to be able to stream video and pictures over the serial connection to an Arduino with the LoL shield attached.

## Setup

* Install LoLShield_VideoStream on an Arduino
* Run LoLProcessing_VideoStream in Processing
* Connect Arduino to computer (for serial communication)

## Usage

LOLProcessing_VideoStream will start up in camera capture mode.
Shortly after starting it will present a number of camera options for streaming.
Currently you can only select single-digit options (0-9).

### Commands

* __C__ : toggle camera capture mode
  - When not in capture mode, you will be prompted to select a video file
* __S__ : open serial stream
  - This will present you with a list of serial ports to choose from using the numeric keys
* __N__ : stop the current movie and prompt for another

#### Image Control

* __I__ : invert the image
* __R__ : rotate 90 degrees clockwise (TODO)
* __l__/__L__ : crop in/out left side (TODO)
* __r__/__R__ : crop in/out right side (TODO)
* __t__/__T__ : crop in/out top edge (TODO)
* __b__/__B__ : crop in/out bottom edge (TODO)

#### RGB to Greyscale Methods

* __A__ : Linear
* __E__ : Exponential
* __M__ : Moving Histogram
* __H__ : Per-Frame Histogram
* __O__ : Overall (Full-Movie) Histogram

## Dev Details

Tested with:

* Arduino Leonardo
* OSX 10.14.6
* Processing 3.5.3

References:
http://www.cibomahto.com/2010/08/lol-processing/
