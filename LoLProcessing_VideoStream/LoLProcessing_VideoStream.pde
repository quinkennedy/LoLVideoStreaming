import processing.video.*;
import processing.serial.*;

PGraphics lowRes;
int lolWidth = 14;
int lolHeight = 9;
int numLevels = 8;
int numPixels = lolWidth * lolHeight;
Movie movie;
int screenWidth = 1200;
int screenHeight = 400;
Serial serial;
boolean bFirstFrame = true;
Translater trans = new Translater(TranslateType.Linear);

//        public enum LightType{
public class LightType {
  static final int Exponential = 0;
  static final int Linear = 1;
  static final int Average = 2;
  static final int HistEqualization = 3;
}
//          Exponential, Linear, Average
//        }

public void setup() {
  size(screenWidth,screenHeight);
  int i = 0;
  for (String s : Serial.list()) {
    println(i++ + ": " + s);
  }
}

public void draw() {
  if (movie == null) {
    String sFilename = selectInput();
    if (sFilename != null) {
      movie = new Movie(this, sFilename);
      movie.loop();
      noLoop();
    }
  } 
  else {
    pushMatrix();
      scale((float)(screenWidth >> 1)/movie.width, (float)screenHeight/movie.height);
      image(movie, 0, 0);
    popMatrix();
    
    byte[] data = trans.Translate(movie);
    
    if (serial != null) {
      serial.write(data);
    }
    
    PImage lowRes = createImage(lolWidth, lolHeight, RGB);
    int i = 0;
    int value;
    for(int j = 1; j < data.length; j++){
      value = data[j]*255/8;
      lowRes.pixels[i++] = value | (value << 8) | (value << 16);
    }
    lowRes.updatePixels();
    pushMatrix();
      translate(screenWidth >> 1, 0);
      scale((float)(screenWidth >> 1)/lolWidth, (float)screenHeight/lolHeight);
      image(lowRes, 0, 0);
    popMatrix();
    //ideally, draw grayscale image
//    fill(0);
//    rect(0, 0, (lolWidth + 1) << 2, (lolHeight + 1) << 2);
//    pushMatrix();
//    translate(1, 1);
//    scale(4, 4);
//    image(lowRes, 0, 0);
//    popMatrix();
  }
}

public void movieEvent(Movie m) {
  m.read();
  redraw();
}

public void keyPressed() {
  if (key >= '0' && key <= '9') {
    serial = new Serial(this, Serial.list()[key - '0'], 9600);
  } 
  else {
    switch (key) {
    case 'n':
    case 'N':
      movie.stop();
      movie = null;
      loop();
      break;
    case 'l':
    case 'L':
      trans.SetType(TranslateType.Linear);
      break;
    case 'e':
    case 'E':
      trans.SetType(TranslateType.Exponential);
      break;
    case 'm':
    case 'M':
      trans.SetType(TranslateType.MovingHist);
      break;
    case 'h':
    case 'H':
      trans.SetType(TranslateType.FrameHist);
      break;
    case 'o':
    case 'O':
      trans.SetType(TranslateType.OverallHist);
      break;
    }
  }
}

