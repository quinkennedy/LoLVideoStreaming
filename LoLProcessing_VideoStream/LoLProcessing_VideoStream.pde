import processing.video.*;
import processing.serial.*;

PGraphics lowRes;
int lolWidth = 14;
int lolHeight = 9;
int numLevels = 8;
int numPixels = lolWidth * lolHeight;
Movie movie;
Capture cam;
boolean bUseCamera = true;
int screenWidth = 1200;
int screenHeight = 400;
Serial serial;
boolean bFirstFrame = true;
boolean bUseShield = false;
Translater trans = new Translater(TranslateType.Linear);
ConsoleNode consoleHead;
int InputType = 0;

public class LightType {
  static final int Exponential = 0;
  static final int Linear = 1;
  static final int Average = 2;
  static final int HistEqualization = 3;
}

public void setup() {
  size(screenWidth, screenHeight);
  printCamInstructions();
}

private void cPrint(String text) {
    ConsoleNode temp = new ConsoleNode(text);
    if (consoleHead != null){
      temp.Next = consoleHead;
    }
    consoleHead = temp;
}

private void drawConsole() {
  while (consoleHead != null && consoleHead.remove()){
    consoleHead = consoleHead.Next;
  }
  ConsoleNode consoleCurr = consoleHead;
  fill(255);
  int x = 20;
  int y = 20;
  while (consoleCurr != null) {
    text(consoleCurr.Text, x, y);
    y += 20;
    while (consoleCurr.Next != null && consoleCurr.Next.remove()){
      consoleCurr.Next = consoleCurr.Next.Next;
    }
    consoleCurr = consoleCurr.Next;
  }
}

private void printCamInstructions(){
        int i = 0;
        for (String s : Capture.list()) {
          cPrint(i++ + ":" + s);
        }
        InputType = 1;
}

private void printShieldInstructions(){
        int i = 0;
        for (String s : Serial.list()) {
          cPrint(i++ + ": " + s);
        }
        InputType = 2;
}

public void draw() {
  byte[] data = null;
  if (bUseCamera && cam != null) {
    image(cam, 0, 0);
    data = trans.Translate(cam);
  } else if (!bUseCamera) {
    if (movie == null) {
      String sFilename = selectInput();
      if (sFilename != null) {
        movie = new Movie(this, sFilename);
        movie.loop();
        noLoop();
      }
    } else {
      pushMatrix();
      scale((float)(screenWidth >> 1)/movie.width, (float)screenHeight/movie.height);
      image(movie, 0, 0);
      popMatrix();

      data = trans.Translate(movie);
    }
  }
  if (data != null){
      if (serial != null) {
        serial.write(data);
      }

      PImage lowRes = createImage(lolWidth, lolHeight, RGB);
      int i = 0;
      int value;
      for (int j = 1; j < data.length; j++) {
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
  drawConsole();
}

public void movieEvent(Movie m) {
  m.read();
  redraw();
}

public void captureEvent(Capture c){
  c.read();
  redraw();
}

public void keyPressed() {
  if (key >= '0' && key <= '9') {
    switch(InputType){
      case 1://cam input
        if (cam != null){
          cam.stop();
        }
        cam = new Capture(this, screenWidth/2, screenHeight, Capture.list()[key - '0']);
        break;
      case 2://serial input
        if (serial != null){
          serial.stop();
        }
        serial = new Serial(this, Serial.list()[key - '0'], 9600);
        break;
    }
    InputType = 0;
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
    case 'c'://toggle using a camera
    case 'C':
      bUseCamera = !bUseCamera;
      if (bUseCamera){
        printCamInstructions();
      }
      break;
    case 's'://request to use the shield
    case 'S':
      bUseShield = !bUseShield;
      if (bUseShield) {
        printShieldInstructions();
      }
      break;
    }
  }
}

