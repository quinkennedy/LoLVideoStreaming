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

	public void setup() {
		lowRes = createGraphics(lolWidth, lolHeight, P2D);
		size(screenWidth,screenHeight);
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
			pushMatrix();
				scale(2,2);
				fill(0);
				rect(0,0,lolWidth + 1, lolHeight + 1);
				image(lowRes,.5f,.5f);
			popMatrix();
		}
	}
	
	public void movieEvent(Movie m){
		m.read();
		redraw();
	}
	
	public static void main(String _args[]) {
		PApplet.main(new String[] { lolvideostreaming.LoLVideoStreaming.class.getName() });
	}
}
