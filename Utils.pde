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
      float freq = k / (float)fftBufferSize * input.sampleRate();
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