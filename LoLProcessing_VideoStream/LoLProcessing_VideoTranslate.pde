import java.util.LinkedList;

public class Translater {
  private TranslateType currType;

  public Translater(TranslateType type) {
    currType = type;
  }

  public void SetType(TranslateType type) {
    if (currType != type){
      currType = type;
      if (type == TranslateType.OverallHist){
        splits = null;
      }
    }
  }
  
  public byte[] Translate(PImage p){
    if (currType == TranslateType.Linear) {
      return Linear(p);
    } 
    else if (currType == TranslateType.Exponential) {
      return Exponential(p);
    } 
    else if (currType == TranslateType.FrameHist) {
      return FrameHist(p);
    } 
    else{
      return MovingHist(p);
    }
  }
  
  public byte[] Translate(Capture c){
    return Translate(GetImage(c));
  }

  public byte[] Translate(Movie m) {
    if (currType == TranslateType.OverallHist){
      return OverallHist(m);
    } else {
    return Translate(GetImage(m));
    }
  }

  private byte[] DownSample(byte[] original) {
    return new byte[0];
  }

  private PImage DownSample(PImage original) {
    return createImage(1,1,RGB);
  }

  private PImage GetImage(Movie m) {
    PGraphics lowRes = createGraphics(lolWidth, lolHeight, P2D);
    lowRes.beginDraw();
    lowRes.pushMatrix();
    lowRes.scale((float)lolWidth/m.width, (float)lolHeight/m.height);
    lowRes.image(m, 0, 0);
    lowRes.popMatrix();
    lowRes.endDraw();
    return lowRes;
  }
  
  private PImage GetImage(Capture c){
    PGraphics lowRes = createGraphics(lolWidth, lolHeight, P2D);
    lowRes.beginDraw();
    lowRes.pushMatrix();
    lowRes.scale((float)lolWidth/(screenWidth/2), (float)lolHeight/screenHeight);
    lowRes.image(c, 0, 0);
    lowRes.popMatrix();
    lowRes.endDraw();
    return lowRes;
  }

  private byte[] GetResult(byte[] original) {
    return original;
  }

  private byte[] Exponential(PImage img) {
    byte[] data = new byte[img.width * img.height + 1];
    data[0] = 10;

    int i = 1;
    int sumMax = 255*3;
    sumMax *= sumMax;
    int sum;
    for (int p : img.pixels) {
      sum = ((p&255) + ((p >> 8)&255) + ((p >> 16)&255));
      sum *= sum;
      data[i++] = (byte)(sum*numLevels/sumMax);
    }
    return GetResult(data);
  }

  private byte[] Linear(PImage img) {
    byte[] data = new byte[img.width * img.height + 1];
    data[0] = 10;

    int i = 1;
    int sumMax = 255*3;
    int sum;
    for (int p : img.pixels) {
      sum = ((p&255) + ((p >> 8)&255) + ((p >> 16)&255));
      data[i++] = (byte)(sum*numLevels/sumMax);
    }
    return GetResult(data);
  }

  private byte[] FrameHist(PImage img) {
    byte[] data = new byte[numPixels + 1];
    int[] intermediate = new int[numPixels];
    int[] distribution = new int[numPixels];
    int[] splits = new int[numLevels];
    data[0] = 10;

    int i = 1;
    int h = 0;
    int sumMax = 255*3;
    int sum;
    for (int p : img.pixels) {
      sum = ((p&255) + ((p >> 8)&255) + ((p >> 16)&255));
      intermediate[h] = sum;
      distribution[h++] = sum;
    }

    Arrays.sort(distribution);
    for (int j = 0; j < splits.length - 1; j++) {
      splits[j] = distribution[(int)((float)numPixels/numLevels*(j+1))];
    }
    splits[numLevels - 1] = distribution[numPixels - 1];
    boolean added = false;
    for (int j : intermediate) {
      for (int k = 0; k < splits.length; k++) {
        if (j <= splits[k]) {
          data[i++] = (byte)k;
          added = true;
          break;
        }
      }
      if (!added) {//we should never get here
        data[i++] = (byte)(numLevels - 1);
      }
      added = false;
    }

    return GetResult(data);
  }

  LinkedList movingWindow = new LinkedList();
  int windowSize = 100 * numPixels;//one second? we could also use DelayQueue to ensure 1 second..
  private byte[] MovingHist(PImage img) {
    byte[] data = new byte[numPixels + 1];
    int[] intermediate = new int[numPixels];
    Integer[] distribution;
    int[] splits = new int[numLevels];
    data[0] = 10;

    int i = 1;
    int h = 0;
    int sumMax = 255*3;
    int sum;
    for (int p : img.pixels) {
      sum = ((p&255) + ((p >> 8)&255) + ((p >> 16)&255));
      movingWindow.add(sum);
      if (movingWindow.size() > windowSize){
        movingWindow.poll();
      }
      intermediate[h++] = sum;
    }
    distribution = (Integer[])movingWindow.toArray(new Integer[movingWindow.size()]);

    Arrays.sort(distribution);
    for (int j = 0; j < splits.length - 1; j++) {
      splits[j] = distribution[(int)((float)distribution.length/numLevels*(j+1))];
    }
    splits[numLevels - 1] = distribution[numPixels - 1];
    boolean added = false;
    for (int j : intermediate) {
      for (int k = 0; k < splits.length; k++) {
        if (j <= splits[k]) {
          data[i++] = (byte)k;
          added = true;
          break;
        }
      }
      if (!added) {//we should never get here
        data[i++] = (byte)(numLevels - 1);
      }
      added = false;
    }

    return GetResult(data);
  }

  int[] splits;
  private byte[] OverallHist(Movie m) {
    PImage currImg = GetImage(m);
    int sum;
      
    if (splits == null){
      splits = new int[numLevels];
      float currTime = m.time();
      int[] distribution = new int[numPixels * ((int)(m.duration() * 2) + 1)];//sample two frames for every second of video
      int dIndex = 0;
      int sumMax = 255*3;
      PImage img;
      println("total duration is "+m.duration());
      for(float t = 0; t < m.duration(); t += 0.5f){
        m.jump(t);
        while(!m.available());
        println("sampling time " + t);
        m.read();

        img = GetImage(m);
        for (int p : img.pixels) {
          sum = ((p&255) + ((p >> 8)&255) + ((p >> 16)&255));
          distribution[dIndex++] = sum;
        }
      }
      m.jump(currTime);
      
      Arrays.sort(distribution);
      for (int j = 0; j < splits.length - 1; j++) {
        splits[j] = distribution[(int)((float)distribution.length/numLevels*(j+1))];
      }
      splits[numLevels - 1] = distribution[numPixels - 1];
    }
    
    boolean added = false;
    byte[] data = new byte[numPixels + 1];
    data[0] = 10;
    int i = 1;
    for (int p : currImg.pixels) {
      sum = ((p&255) + ((p >> 8)&255) + ((p >> 16)&255));
      for (int k = 0; k < splits.length; k++) {
        if (sum <= splits[k]) {
          data[i++] = (byte)k;
          added = true;
          break;
        }
      }
      if (!added) {//we should never get here
        data[i++] = (byte)(numLevels - 1);
      }
      added = false;
    }

    return GetResult(data);
  }
}

public static class TranslateType {
  public static final TranslateType Exponential = new TranslateType();
  public static final TranslateType Linear = new TranslateType();
  public static final TranslateType FrameHist = new TranslateType();
  public static final TranslateType MovingHist = new TranslateType();
  public static final TranslateType OverallHist = new TranslateType();

  private TranslateType() {
  }
}

