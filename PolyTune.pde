/*

	Java implementation of realtime polyphonic pitch tracking
	Based on Corban Brook's spectrotune code : https://github.com/corbanbrook/spectrotune

	stc@binaura.net / 2015

        messing with visuals: adam@prezi.com 

*/

boolean runFullscreen = false;
PShader blurShader;
PGraphics pgBars, pgBlurPass1, pgBlurPass2;
final int MAX_BLUR_ITERATIONS = 3;
boolean useBlur = false;
PImage back;

import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;

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

boolean[] OCTAVE_TOGGLE = {false, true, true, true, true, true, true, true};
int[] OCTAVE_CHANNEL = {0,0,0,0,0,0,0,0}; // set all octaves to channel 0 (0-indexed channel 1)

public static final int PEAK = 1;
public static final int VALLEY = 2;
public static final int HARMONIC = 3;
public static final int SLOPEUP = 4;
public static final int SLOPEDOWN = 5;

ArrayList<MIDIBar> midibars; 

boolean sketchFullScreen() {
  return runFullscreen;
}


void setup() {
	size(1200,800,P3D);
	minim = new Minim(this);
	controlP5 = new ControlP5(this);
        controlP5.hide();
	sampler = new Sampler();
	window = new Window();
	smoother = new Smooth();
	rectMode(CORNERS);
	initSound();
	initGui();

	midibars= new ArrayList<MIDIBar>();

        blurShader = loadShader( "shaders/blur.glsl" );
        blurShader.set( "blurSize", 9 );
        blurShader.set( "sigma", 5.f );
        pgBlurPass1 = createGraphics( width, height, P3D );
        pgBlurPass1.noSmooth();
        pgBlurPass2 = createGraphics( width, height, P3D );
        pgBlurPass2.noSmooth();
        
        pgBars = createGraphics( width, height, P3D );
        pgBars.noSmooth();
        
        float fov = PI/3.0;
        float cameraZ = (height/2.0) / tan(fov/2.0);
        perspective(fov, float(width)/float(height), 
            cameraZ/10.0, cameraZ*10.0);
        back = loadImage("er4.jpg");
}

void draw() {
    
    image(back, 0, 0);
    
    if (useBlur)
    {
        blurShader.set( "blur", map( mouseY, 0, height - 1, 0., 1. ) );
        //blurShader.set( "blur", 0.5 );
        for ( int i = 0; i < MAX_BLUR_ITERATIONS; i++ )
        {  
              blurShader.set( "horizontalPass", 0 );
              pgBlurPass1.beginDraw();
              pgBlurPass1.shader( blurShader );
              if ( i == 0 )
              {
                pgBlurPass1.image( pgBars, 0, 0 );
              }
              else
              {
                pgBlurPass1.image( pgBlurPass2, 0, 0 );
              }
              pgBlurPass1.endDraw();
        
              blurShader.set( "horizontalPass", 1 );
              pgBlurPass2.beginDraw();
              pgBlurPass2.shader( blurShader );
              pgBlurPass2.image( pgBlurPass1, 0, 0 );
              pgBlurPass2.endDraw();
        }   
    }
    
    if (useBlur) image( pgBlurPass2, 0, 0 );
    image( pgBars, 0, 0 );
    
    
   
    sampler.draw(pgBars); //<>//
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
	switch(keyCode) {
    	case RIGHT:
      		PEAK_THRESHOLD += 1;
      		break;
      
    	case LEFT:
      		PEAK_THRESHOLD -= 1;
      		break;
  	}

  	if(key == 'x') {
  		showUI = !showUI;
  		if(!showUI){
  			controlP5.hide();
  		}else{
  			controlP5.show();
  		}
  	}
}
