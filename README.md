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

#### General

* __C__ : toggle camera capture mode
  - When not in capture mode, you will be prompted to select a video file
* __S__ : open serial stream
  - This will present you with a list of serial ports to choose from using the numeric keys
* __N__ : stop the current movie and prompt for another
* __F__ : toggle writing bytes to file
  - During movie playback, this will start and end with the next loop
  - During camera capture, this will start immediately, and end when you press __F__ again
  - Saves to _out.json_

#### Image Control

* __I__ : invert the image
* __D__ : blend mode
  - Cycles through BLEND -> DARKEST -> LIGHTEST
* __l__/__L__ : crop in/out left side
* __r__/__R__ : crop in/out right side
* __t__/__T__ : crop in/out top edge
* __b__/__B__ : crop in/out bottom edge

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
