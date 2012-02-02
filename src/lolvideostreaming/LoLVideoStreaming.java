package lolvideostreaming;

import processing.core.PApplet;
import processing.serial.*;
import processing.video.*;
import processing.core.PGraphics;


public class LoLVideoStreaming extends PApplet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	PGraphics lowRes;
	int lolWidth = 14;
	int lolHeight = 9;
	Movie movie;
	int screenWidth = 600;
	int screenHeight = 400;
	Serial serial;
	byte[] frame = new byte[lolWidth * lolHeight];

	public void setup() {
		lowRes = createGraphics(lolWidth, lolHeight, P2D);
		size(screenWidth,screenHeight);
		int i = 0;
		for(String s : Serial.list()){
			println(i++ + ": " + s);
		}
	}

	public void draw() {
		if (movie == null){
			String sFilename = selectInput();
			if (sFilename != null){
				movie = new Movie(this, sFilename);
				movie.loop();
				noLoop();
			}
		} else {
			pushMatrix();
				scale((float)screenWidth/movie.width, (float)screenHeight/movie.height);
				image(movie, 0, 0);
			popMatrix();
			lowRes.beginDraw();
				lowRes.pushMatrix();
					lowRes.scale((float)lolWidth/movie.width, (float)lolHeight/movie.height);
					lowRes.image(movie, 0, 0);
				lowRes.popMatrix();
			lowRes.endDraw();
			int i = 0;
			for(int p : lowRes.pixels){
				frame[i++] = (byte)((p|255)*8/255);
			}
			if (serial != null){
				serial.write(frame);
			}
			fill(0);
			rect(0,0,(lolWidth + 1) << 1, (lolHeight + 1) << 1);
			pushMatrix();
				translate(1,1);
				scale(2,2);
				image(lowRes,0,0);
			popMatrix();
		}
	}
	
	public void movieEvent(Movie m){
		m.read();
		redraw();
	}
	
	public void keyPressed(){
		serial = new Serial(this, Serial.list()[key - '0'], 9600);
	}
	
	public static void main(String _args[]) {
		PApplet.main(new String[] { lolvideostreaming.LoLVideoStreaming.class.getName() });
	}
}
