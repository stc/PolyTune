import java.awt.Color; //<>//
/*
	Java implementation of realtime polyphonic pitch tracking & custom visualization techniques
 	Based on Corban Brook's spectrotune code : https://github.com/corbanbrook/spectrotune
 
 	Agoston Nagy & Adam Somlai Fischer / 2015
 
 analysis & midi: stc@binaura.net
 messing with visuals: adam@prezi.com 
 
 */

import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;

boolean runFullscreen = true;
boolean blurredBack = true;
boolean autoPeak = false;

int frames; // total horizontal audio frames / 1 s
int frameNumber = -1;

int bufferSize = 1024;
int ZERO_PAD_MULTIPLIER = 4; //	// zero padding adds interpolation resolution to the FFT, it also dilutes the magnitude of the bins

int fftBufferSize = bufferSize * ZERO_PAD_MULTIPLIER;
int fftSize = fftBufferSize/2;
int PEAK_THRESHOLD = 5; // default peak threshold

// MIDI notes span from 0 - 128, octaves -1 -> 9. Specify start and end for piano
int keyboardStart = 12; // 12 is octave C0
int keyboardEnd = 108;

Minim minim;
ControlP5 controlP5;
AudioInput input;
Sampler sampler;
Window window;
Smooth smoother;
Visuals visuals;

FFT fft;

//  used to determine ~timbre
int peaknum = 0;

boolean showUI = false;

float[] buffer = new float[fftBufferSize];
float[] spectrum = new float[fftSize];
int[] peak = new int[fftSize];

float[][] pcp;

Note[][] notes;

int[] fftBinStart = new int[8]; 
int[] fftBinEnd = new int[8];

float[] scaleProfile = new float[12];

float linearEQIntercept = 1f; // default no eq boost
float linearEQSlope = 0f; // default no slope boost

Toggle toggleHarmonics;
Toggle toggleLinearEQ;
Toggle togglePCP;
Slider sliderThreshold;

boolean LINEAR_EQ_TOGGLE = false;
boolean PCP_TOGGLE = true;
boolean HARMONICS_TOGGLE = true;
int SMOOTH_POINTS = 3;

boolean UNIFORM_TOGGLE = true;
boolean DISCRETE_TOGGLE = false;
boolean LINEAR_TOGGLE = false;
boolean QUADRATIC_TOGGLE = false;
boolean EXPONENTIAL_TOGGLE = false;

boolean[] OCTAVE_TOGGLE = {
  false, true, true, true, true, true, true, true
};
int[] OCTAVE_CHANNEL = {
  0, 0, 0, 0, 0, 0, 0, 0
}; // set all octaves to channel 0 (0-indexed channel 1)

public static final int PEAK = 1;
public static final int VALLEY = 2;
public static final int HARMONIC = 3;
public static final int SLOPEUP = 4;
public static final int SLOPEDOWN = 5;

int song = 1;
final static int NUTHSELL = 0;
final static int KISKECE = 1;
ArrayList<GuitarBar> midibars; 
int numOns = 0;

void setup() {
  size(1200, 800, P3D);

  minim = new Minim(this);
  controlP5 = new ControlP5(this);
  controlP5.hide();
  sampler = new Sampler();
  window = new Window();
  smoother = new Smooth();
  rectMode(CORNERS);
  initSound();
  initGui();
  visuals = new Visuals();
  visuals.setupGuitarVisual();
}

void draw() {
  background(0);
  //visuals.drawGuitarVisual();
  try {
    sampler.draw();
  } catch (Exception e) {
    println(e);
  }
}

void stop() {
  minim.stop();
  super.stop();
}

void initSound() {
  input = minim.getLineIn();
  fft = new FFT(fftBufferSize, input.sampleRate());
  frames = round((float)input.sampleRate() / (float)bufferSize);
  notes = new Note[frames][0];
  pcp = new float[frames][12];
  precomputeOctaveRegions();
  frameNumber = -1;
  input.addListener(sampler);
}

void keyPressed() {
  if (key == ESC) key = 0; // trap ESC so it doesn't quit
  //println(keyCode);
  switch(keyCode) {
  case RIGHT:
  case 34:
    PEAK_THRESHOLD += 1;
    break;

  case LEFT:
  case 33:
    PEAK_THRESHOLD -= 1;
    break;
  }

  if (key == 'x' || key == 46) {
    showUI = !showUI;
    if (!showUI) {
      controlP5.hide();
    } else {
      controlP5.show();
    }
  }
}