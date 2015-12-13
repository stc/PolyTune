

// MIDI notes span from 0 - 128, octaves -1 -> 9. Specify start and end for piano
int keyboardStart = 12; // 12 is octave C0
int keyboardEnd = 108;
  
class PolyListener {
  int frames; // total horizontal audio frames / 1 s
  int frameNumber = -1;
  
  int bufferSize = 1024;
  int ZERO_PAD_MULTIPLIER = 4; //  // zero padding adds interpolation resolution to the FFT, it also dilutes the magnitude of the bins
  
  int fftBufferSize = bufferSize * ZERO_PAD_MULTIPLIER;
  int fftSize = fftBufferSize/2;
  int PEAK_THRESHOLD = 5; // default peak threshold
 
  AudioInput input;
  Sampler sampler;
  Window window;
  Smooth smoother;
  
  FFT fft;
  //  used to determine ~timbre
  int peaknum = 0;
  
  boolean showUI = true;
  
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
  
  ArrayList<MIDIBar> midibars; 
  boolean autoPeak = false;
  int numOns = 0;
  String channelName = "";
  
  PolyListener(String _channelName) {
    controlP5.hide();
    channelName = _channelName;
    sampler = new Sampler(this, channelName);
    window = new Window();
    smoother = new Smooth();
    rectMode(CORNERS);
    midibars= new ArrayList<MIDIBar>();
    initSound();
    initGui();
  }
  
  void draw() {
    try {
      sampler.draw();
    } catch (Exception e) {
      println(e);
    }
  }
  
  void initSound() {
    if(!testSound) {
      input = minim.getLineIn();
      fft = new FFT(fftBufferSize, input.sampleRate());
      frames = round((float)input.sampleRate() / (float)bufferSize);
      notes = new Note[frames][0];
      pcp = new float[frames][12];
      precomputeOctaveRegions();
      frameNumber = -1;
      input.addListener(sampler);
    }else {
      fft = new FFT(fftBufferSize, player.sampleRate());
      frames = round((float)player.sampleRate() / (float)bufferSize);
      notes = new Note[frames][0];
      pcp = new float[frames][12];
      precomputeOctaveRegions();
      frameNumber = -1;
      player.addListener(sampler);
    }
  }
  // GUI ---------------------------------------------------------------------------------------------------------------------------------------------
  void initGui() {
    controlP5.setColorForeground(0xffaa0000);
    controlP5.setColorBackground(0xff660000);
    controlP5.setColorCaptionLabel(0xffdddddd);
    controlP5.setColorValueLabel(0xffff88ff);
    controlP5.setColorActive(0xffff0000);
  
    RadioButton radioWindow = controlP5.addRadio("radioWindow", 240, height-100);
    radioWindow.add("RECTANGULAR", Window.RECTANGULAR);
    radioWindow.add("HAMMING", Window.HAMMING);
    radioWindow.add("HANN", Window.HANN);
    radioWindow.add("COSINE", Window.COSINE);
    radioWindow.add("TRIANGULAR", Window.TRIANGULAR);
    radioWindow.add("BLACKMAN", Window.BLACKMAN);
    radioWindow.add("GAUSS", Window.GAUSS);
    radioWindow.activate(Window.HANN);
  
    RadioButton radioWeight = controlP5.addRadio("radioWeight", 320, height - 100);
    radioWeight.add("UNIFORM (OFF)", UNIFORM); // default
    radioWeight.add("DISCRETE", DISCRETE);
    radioWeight.add("LINERAR", LINEAR);
    radioWeight.add("QUADRATIC", QUADRATIC);
    radioWeight.add("EXPONENTIAL", EXPONENTIAL);
    radioWeight.activate(UNIFORM);
  
    togglePCP = controlP5.addToggle("togglePCP", PCP_TOGGLE, 400, height-100, 10, 10);
    togglePCP.setLabel("Pitch Class Profile");
    
    toggleLinearEQ = controlP5.addToggle("toggleLinearEQ", LINEAR_EQ_TOGGLE, 400, height-80, 10, 10);
    toggleLinearEQ.setLabel("Linear EQ");
    
    toggleHarmonics = controlP5.addToggle("toggleHarmonics", HARMONICS_TOGGLE, 400, height-60, 10, 10);
    toggleHarmonics.setLabel("Harmonics Filter");
    
    sliderThreshold = controlP5.addSlider("Threshold", 0, 255, PEAK_THRESHOLD, 400, height - 40, 75, 10);
    sliderThreshold.setId(1);
  }

  void radioWindow(int mode) {
    window.setMode(mode);
  }

  void radioWeight(int type) {
    WEIGHT_TYPE = type;
  }

  // ControlP5 events
  void controlEvent(ControlEvent event) {
    if ( event.isController() ) {
      if(event.getName().equals("Threshold")) {
        PEAK_THRESHOLD = (int)(event.getValue());
      }
    }
  }
  
  // MIDI ---------------------------------------------------------------------------------------------------------------------------------------------
  Note[] notesOpen = new Note[128];

  void outputMIDINotes() {
    // send NoteOns
    for ( int i = 0; i < notes[frameNumber].length; i++ ) {
      Note note = notes[frameNumber][i];
      if ( OCTAVE_TOGGLE[note.octave] && notesOpen[note.pitch] == null) {
        //  NOTE ON
        //  we have <note.channel> <note.pitch> <note.velocity>
        notesOpen[note.pitch] = note;
        //note.noteOnFrame = frameNumber;
        // println("ON: " + note.label() + " at " + frameCount);
        midibars.add(new MIDIBar(note));
      }
    }
  
    // send NoteOffs   
    for ( int i = 0; i < notesOpen.length; i++ ) {
      boolean isOpen = false;
      if ( notesOpen[i] != null ) {
        for ( int j = 0; j < notes[frameNumber].length; j++ ) {
          if ( notes[frameNumber][j].pitch == i ) {
            isOpen = true;
          }
        }
        if ( !isOpen ) {
          //println("OFF: " + notesOpen[i].pitch);
  
          for (int j=0; j<midibars.size(); j++) {
            if (midibars.get(j).note.pitch == notesOpen[i].pitch) {
              midibars.get(j).on = false;
              midibars.get(j).note.noteLength = frameNumber - midibars.get(j).note.noteOnFrame;
            }
          }
          notesOpen[i] = null;
        }
      }
    }
  }
  
  void closeMIDINotes() {  
    for ( int i = 0; i < notesOpen.length; i++ ) {
      if ( notesOpen[i] != null ) {
        //  close all active notes here if needed
        notesOpen[i] = null;
      }
    }
  }
  
  //  RENDER ---------------------------------------------------------------------------------------------------------------------------------------
  void render() {
    if (showUI) {
      if(channelName.equals("right")) {
        pushMatrix();
        translate(width/2,0);
        renderUI();
        popMatrix();
      }else {
        renderUI();
      }
    }
  
    // clean old 
    numOns = 0;
    for (int i=0; i<midibars.size (); i++) {
      if (midibars.get(i).on) numOns++;
      if ((midibars.get(i).x>width) || (midibars.get(i).x < - midibars.get(i).w * 4)) {
        midibars.remove(midibars.get(i));
      }
    }
  
    if (autoPeak) {
      int fresh = 0;
      for (int i=0; i<midibars.size (); i++) {
        if (frameCount - midibars.get(i).note.noteOnFrame < 20) fresh++;
      }
      if (fresh == 0) PEAK_THRESHOLD = max(3, PEAK_THRESHOLD-1);
      if (fresh > 5) PEAK_THRESHOLD += 1;
    }
  
    // notes 
    for (int i=0; i<midibars.size (); i++) {
      midibars.get(i).display();
    }
  }
  
  void renderUI() {
    renderWindowCurve();
    renderFFT();
    renderPeaks();
  }    
  
  boolean checkForHarmonics(MIDIBar m) {
    Note h = m.note;
    for (int i=0; i<midibars.size (); i++) {
      Note base = midibars.get(i).note;
      if (h != base &&
        h.semitone == base.semitone &&
        h.pitch >= base.pitch && 
        h.velocity <= base.velocity &&
        abs(h.noteOnFrame - base.noteOnFrame) < 30) {
          return true;
      }
    }
    return false;
  }
  
  void renderPeaks() {
    int keyHeight = height / (keyboardEnd - keyboardStart);
  
    // render detected peaks
    noStroke();
    int keyLength = 10;
    int scroll = (frameNumber * keyLength > width) ? frameNumber - width/keyLength: 0;
  
    for ( int x = frameNumber; x >= scroll; x-- ) {
      if (x>-1) {
        for ( int i = 0; i < notes[x].length; i++ ) {
          Note note = notes[x][i];
  
          color noteColor;
  
          if ( pcp[x][note.pitch % 12] == 1.0 ) {
            noteColor = color(100 * note.amplitude / 400);
          } else {
            noteColor = color(255 * note.amplitude / 400);
          }
  
          fill(red(noteColor)/4, green(noteColor)/4, blue(noteColor)/4);
          rect(abs(x - frameNumber) * keyLength + 24, height - ((note.pitch - keyboardStart) * keyHeight), abs(x - frameNumber) * keyLength + keyLength + 25, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight));
  
          fill(noteColor);
          rect(abs(x - frameNumber) * keyLength + 24, height - ((note.pitch - keyboardStart) * keyHeight) - 1, abs(x - frameNumber) * keyLength + keyLength + 24, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight));
        }
      }
    }
    
    // output semitone text labels 
    textSize(10);
    if (frameNumber>-1) {
      for ( int i = 0; i < notes[frameNumber].length; i++ ) {
        Note note = notes[frameNumber][i];
  
        fill(220);
        // text(note.label(), 24 + 1, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight + 1));
  
        fill(140);
        //text(note.label(), 24, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight + 2));
      }
    }
  }
  
  void renderWindowCurve() {
    int windowX = 100;
    int windowY = height-20;
    int windowHeight = 80;
    float[] windowCurve = window.drawCurve();
    noStroke();
    fill(60);
    rectMode(CORNER);
    rect(windowX, windowY, windowCurve.length, -windowHeight);
    strokeWeight(2);
    stroke(255, 255, 255, 150);
    rectMode(CORNERS);
    for (int i = 0; i < windowCurve.length - 1; i++) {
      line(i + windowX, windowY - windowCurve[i] * windowHeight, i+1 + windowX, windowY - windowCurve[i+1] * windowHeight);
    }
    noStroke();
  }
  
  void renderFFT() {  
    noStroke();
  
    int keyHeight = height / (keyboardEnd - keyboardStart);
    color noteColor;
    float[] amp = new float[128];
  
    int previousPitch = -1;
    int currentPitch;
    float amplitudeTotal = 0f;
  
    for ( int k = 0; k < spectrum.length; k++ ) {
      float freq;
      if(!testSound) {
        freq = k / (float)fftBufferSize * input.sampleRate();
      } else {
        freq = k / (float)fftBufferSize * player.sampleRate();
      }
      currentPitch = freqToPitch(freq);
  
      if ( currentPitch == previousPitch ) {
        amp[currentPitch] = amp[currentPitch] > spectrum[k] ? amp[currentPitch] : spectrum[k];
      } else {
        amp[currentPitch] = spectrum[k]; 
        previousPitch = currentPitch;
      }
    }
  
    for ( int i = keyboardStart; i < keyboardEnd; i++) {
      //noteColor = color(255, 100 * amp[i] / 400, 0);
      noteColor = color(0, 255, 240);
  
      fill(red(noteColor)/4, green(noteColor)/4, blue(noteColor)/4);
      rect(24, height - ((i - keyboardStart) * keyHeight), 25 + amp[i], height - ((i - keyboardStart) * keyHeight + keyHeight)); // shadow
  
      fill(noteColor);
      rect(24, height - ((i - keyboardStart) * keyHeight) - 1, 24 + amp[i], height - ((i - keyboardStart) * keyHeight + keyHeight));
    }
    stroke(255, 0, 0);
    strokeWeight(1);
    line(PEAK_THRESHOLD + 24, 0, PEAK_THRESHOLD + 24, height);
    noStroke();
  }
  
  // UTILS -------------------------------------------------------------------------------------------------------------------------------------
  int freqToPitch(float f) {
    int p = round(69.0 + 12.0 *(log(f/440.0) / log(2.0)));
    if ( p > 0 && p < 128 ) {
      return p;
    } else {
      return 0;
    }
  }
  
  float pitchToFreq(int p) {
    return 440.0 * pow(2, (p - 69) / 12.0);
  }
  
  // Applies FFT bin weighting. x is the distance from a real semi-tone
  float binWeight(int type, float x) {
    switch(type) {
    case DISCRETE:
      return (x <= 0.2) ? 1.0 : 0.0;
    case LINEAR:
      return 1 - x;
    case QUADRATIC:
      return 1.0 - pow(x, 2);
    case EXPONENTIAL: 
      return pow(exp(1.0), 1.0 - x)/exp(1.0);
    case UNIFORM:
    default: 
      return 1.0;
    }
  }
  
  void normalizePCP() {
    float pcpMax = max(pcp[frameNumber]);
    for ( int k = 0; k < 12; k++ ) {
      pcp[frameNumber][k] /= pcpMax;
    }
  }
  
  // Types of FFT bin weighting algorithms 
  public static final int UNIFORM = 0;
  public static final int DISCRETE = 1;
  public static final int LINEAR = 2;
  public static final int QUADRATIC = 3;
  public static final int EXPONENTIAL = 4;
  
  int WEIGHT_TYPE = UNIFORM; // default
  
  void precomputeOctaveRegions() {
    for ( int j = 0; j < 8; j++) {
      fftBinStart[j] = 0;
      fftBinEnd[j] = 0;
      for ( int k = 0; k < fftSize; k++) {
        float freq;
        if(testSound) {
          freq = k / (float)fftBufferSize * player.sampleRate();
        }else {
          freq = k / (float)fftBufferSize * input.sampleRate();
        }
        if ( freq >= octaveLowRange(j) && fftBinStart[j] == 0 ) {
          fftBinStart[j] = k;
        } else if ( freq > octaveHighRange(j) && fftBinEnd[j] == 0 ) {
          fftBinEnd[j] = k;
          break;
        }
      }
    }
    println("Start: " + fftBinStart[0] + " End: " + fftBinEnd[7] + " (" + fftSize + " total)");
  }
  
  // Find the lowest frequency in an octave range
  float octaveLowRange(int octave) {
    // find C - C0 is MIDI note 12
    return pitchToFreq(12 + octave * 12);
  }
  
  // Find the highest frequency in an octave range
  float octaveHighRange(int octave) {
    // find B - B0 is MIDI note 23
    return pitchToFreq(23 + octave * 12);
  }
}