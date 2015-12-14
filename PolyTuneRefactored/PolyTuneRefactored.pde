import ddf.minim.*; //<>//
import ddf.minim.analysis.*;
import controlP5.*;

/* 
	Java implementation of realtime polyphonic pitch tracking & custom visualization techniques
 	Based on Corban Brook's spectrotune code : https://github.com/corbanbrook/spectrotune
 
 	Agoston Nagy & Adam Somlai Fischer / 2015
 
 analysis & midi: stc@binaura.net
 messing with visuals: adam@prezi.com 
 
 */

Minim minim;
ControlP5 controlP5;

PolyListener leftPolyListener, rightPolyListener;
AudioPlayer player;
boolean testSound = true;

void setup() {
  size(1200, 800, P3D);
  minim = new Minim(this);
  controlP5 = new ControlP5(this);
  if(testSound) {
      player = minim.loadFile("pianoDrum.mp3", 2048);
      player.loop();
    }
    
  Vector<Visualizer> visualizers;
  
  visualizers = new Vector<Visualizer>();
  visualizers.add(new SoundMetricVisualizer(SoundMetricVisualizer.COLORED_BACKGROUND));
  leftPolyListener = new PolyListener("left", visualizers);

  visualizers = new Vector<Visualizer>();
  visualizers.add(new SoundMetricVisualizer(SoundMetricVisualizer.GRAY_CIRCLES));
  rightPolyListener = new PolyListener("right", visualizers);
}

void draw() {
  background(0);
  leftPolyListener.draw();
  rightPolyListener.draw();
}

void stop() {
  minim.stop();
  super.stop();
}

void keyPressed() {
  //if (key == ESC) key = 0; // trap ESC so it doesn't quit
  switch(keyCode) {
  case RIGHT:
  case 34:
    leftPolyListener.PEAK_THRESHOLD += 1;
    rightPolyListener.PEAK_THRESHOLD += 1;
    break;

  case LEFT:
  case 33:
    leftPolyListener.PEAK_THRESHOLD -= 1;
    rightPolyListener.PEAK_THRESHOLD -= 1;
    break;
  }
}