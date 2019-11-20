import processing.video.*;
import processing.serial.*;
import java.util.Arrays;

PGraphics lowRes;
PGraphics scratchpad;
int lolWidth = 14;
int lolHeight = 9;
int numLevels = 8;
int numPixels = lolWidth * lolHeight;
Movie movie;
boolean bWaitingForMovie = false;
float prevMovieTime = -1;
Capture cam;
boolean bUseCamera = true;
int vizWidth = 1400;
int vizHeight = 450;
Serial serial;
boolean bFirstFrame = true;
boolean bUseShield = false;
boolean bInvert = false;
boolean bWriteFile = false;
int blendMode = 0;
Translater trans = new Translater(TranslateType.Linear);
ConsoleNode consoleHead;
int InputType = 0;
int offsetLeft = 0;
int offsetRight = 0;
int offsetTop = 0;
int offsetBottom = 0;
JSONArray fileData;

public class LightType {
  static final int Exponential = 0;
  static final int Linear = 1;
  static final int Average = 2;
  static final int HistEqualization = 3;
}

void settings(){
  size(vizWidth, vizHeight);//, P2D);
}

public void setup() {
  //size(vizWidth, vizHeight);
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

public void choseVideo(File video){
  if (video != null) {
    movie = new Movie(this, video.getAbsolutePath());
    movie.loop();
  }
  bWaitingForMovie = false;
}

public void draw() {
  byte[] data = null;
  if (bUseCamera && cam != null) {
    image(cam, 0, 0);
    if (bInvert){
      filter(INVERT);
    }
    data = trans.Translate(cam);
  } else if (!bUseCamera) {
    if (movie == null) {
      if (!bWaitingForMovie){
        bWaitingForMovie = true;
        selectInput("choose a video", "choseVideo");
        noLoop();
      }
    } else {
      ingestMovie();
      if (scratchpad != null){
        pushMatrix();
        scale((float)(vizWidth >> 1)/scratchpad.width, (float)vizHeight/scratchpad.height);
        image(scratchpad, 0, 0);
        popMatrix();
        if (bInvert){
          filter(INVERT);
        }
        data = trans.Translate(scratchpad);
      }
    }
  }
  if (data != null){
      if (serial != null) {
        serial.write(data);
      }
      formatFileData(data);
      PImage lowRes = createImage(lolWidth, lolHeight, RGB);
      int i = 0;
      int value;
      for (int j = 1; j < data.length; j++) {
        value = data[j]*255/8;
        lowRes.pixels[i++] = value | (value << 8) | (value << 16);
      }
      lowRes.updatePixels();
      pushMatrix();
      translate(vizWidth >> 1, 0);
      scale((float)(vizWidth >> 1)/lolWidth, (float)vizHeight/lolHeight);
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

void formatFileData(byte[] data){
  if (bWriteFile && fileData != null){
    JSONArray frame = new JSONArray();
    //first byte is a frame reset command
    // which we don't need in this case
    for(int i = 1; i < data.length; i++){
      frame.append(data[i]);
    }
    fileData.append(frame);
  }
}

void ingestMovie(){
  if (scratchpad == null){
    scratchpad = createGraphics(movie.width, movie.height);
  }
  int mode = BLEND;
  switch (blendMode){
    case 1:
      mode = DARKEST;
      break;
    case 2:
      mode = LIGHTEST;
      break;
  }
  scratchpad.beginDraw();
  
  //defaults
  int sx = 0;
  int sy = 0;
  int sw = movie.width;
  int sh = movie.height;
  int dx = 0;
  int dy = 0;
  int dw = scratchpad.width;
  int dh = scratchpad.height;
  
  //adjust according to offsets
  if (offsetLeft < 0){
    sx = -offsetLeft;
    sw += offsetLeft;
  } else if (offsetLeft > 0){
    dx = offsetLeft;
    dw -= offsetLeft;
  }
  if (offsetTop < 0){
    sy = -offsetTop;
    sh += offsetTop;
  } else if (offsetTop > 0){
    dy = offsetTop;
    dh -= offsetTop;
  }
  if (offsetRight < 0){
    sw += offsetRight;
  } else if (offsetRight > 0){
    dw -= offsetRight;
  }
  if (offsetBottom < 0){
    sh += offsetBottom;
  } else if (offsetBottom > 0){
    dh -= offsetBottom;
  }
  
  scratchpad.blend(movie, sx, sy, sw, sh, dx, dy, dw, dh, mode);
  scratchpad.endDraw();
}

public void movieEvent(Movie m) {
  m.read();
  if (bWriteFile && movie.time() < prevMovieTime){
    //in file mode and movie just looped
    if (fileData == null){
      cPrint("starting recording");
      fileData = new JSONArray();
    } else {
      saveJSONArray(fileData, "out.json", "compact");
      cPrint("stopping recording, saved data");
      bWriteFile = false;
      fileData = null;
    }
  }
  redraw();
  prevMovieTime = movie.time();
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
        cam = new Capture(this, vizWidth/2, vizHeight, Capture.list()[key - '0']);
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
    case 'f':
    case 'F':
      if (bWriteFile){
        saveJSONArray(fileData, "out.json", "compact");
        cPrint("manually stopped recording, saved file");
        bWriteFile = false;
        fileData = null;
      } else {
        bWriteFile = true;
        if (bUseCamera){
          //when using the camera, start recording right away
          cPrint("starting recording");
          fileData = new JSONArray();
        } else {
          //when playing a video, 
          // let the video playback logic start recording when the video loops
        }
      }
      break;
    case 'i':
    case 'I':
      bInvert = !bInvert;
      break;
    case 'n':
    case 'N':
      movie.stop();
      movie = null;
      scratchpad = null;
      loop();
      break;
    case 'a':
    case 'A':
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
    case 'd'://change blend mode
    case 'D':
      blendMode = ((blendMode + 1) % 3);
      break;
    case 't':
      offsetTop -= 1;
      break;
    case 'T':
      offsetTop += 1;
      break;
    case 'b':
      offsetBottom -= 1;
      break;
    case 'B':
      offsetBottom += 1;
      break;
    case 'l':
      offsetLeft -= 1;
      break;
    case 'L':
      offsetLeft += 1;
      break;
    case 'r':
      offsetRight -= 1;
      break;
    case 'R':
      offsetRight += 1;
      break;
    }
  }
}
