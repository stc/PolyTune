class Sampler implements AudioListener {
  private float[] channel;
  String selectChannel = "";
  PolyListener p;

  Sampler(PolyListener _p, String _selectChannel) {
    channel = null;
    selectChannel = _selectChannel;
    p = _p;
  }

  public synchronized void samples(float[] sampleBuffer) {
    channel = sampleBuffer;
    process();
  }

  public synchronized void samples(float[] sampleBufferLeft, float[] sampleBufferRight) {  
    if(selectChannel.equals("left")) {
      channel = sampleBufferLeft;
    }else if(selectChannel.equals("right")) {
      channel = sampleBufferRight;
    }else {
      channel = null;
      println("Error, Couldn't find channel name. Make sure to name it 'left' or 'right'" );
    }
    //right = sampleBufferRight;
    
    //  We don't need monoism now
    /*
    // Apply balance to sample buffer storing in left mono buffer
    for ( int i = 0; i < p.bufferSize; i++ ) {
      int balanceValue = 0;
      if ( balanceValue > 0 ) {
        float balancePercent = (100 - balanceValue) / 100.0; 
        left[i] = (left[i] / 2f * balancePercent) + right[i] / 2f;
      } else if ( balanceValue < 0 ) {
        float balancePercent = (100 - balanceValue * -1) / 100.0; 
        left[i] = left[i] / 2f + (right[i] / 2f * balancePercent);
      } else {
        left[i] = (left[i] + right[i]) / 2f;
      }
    }*/
   
    process();
  }

  int counter;
  
  void process() {
    p.notes = new Note[p.frames][0];
    p.pcp = new float[p.frames][12];

    //if ( frameNumber < frames -1 ) {
    // need to apply the window transform before we zeropad
    p.window.transform(channel); // add window to samples
    arrayCopy(channel, 0, p.buffer, 0, channel.length);
    counter++;
    p.frameNumber = counter%p.frames;
    analyze(p.buffer);
    p.outputMIDINotes();
    //}
  }

  void analyze(float[] buffer) {
    p.fft.forward(buffer); // run fft on the buffer

    //smoother.apply(fft); // run the smoother on the fft spectra

    float[] binDistance = new float[p.fftSize];
    float[] freq = new float[p.fftSize];

    float freqLowRange = p.octaveLowRange(0);
    float freqHighRange = p.octaveHighRange(7);

    p.peaknum = 0;

    for (int k = 0; k < p.fftSize; k++) {
      if(testSound) {
        freq[k] = k / (float)p.fftBufferSize * player.sampleRate();
      }else{
        freq[k] = k / (float)p.fftBufferSize * p.input.sampleRate();
      }
      // skip FFT bins that lay outside of octaves 0-9 
      if ( freq[k] < freqLowRange || freq[k] > freqHighRange ) { 
        continue;
      }


      if (p.fft.getBand(k)>10) {
        p.peaknum++;
      }
      // Calculate fft bin distance and apply weighting to spectrum
      float closestFreq = p.pitchToFreq(p.freqToPitch(freq[k])); // Rounds FFT frequency to closest semitone frequency
      boolean filterFreq = false;

      // Filter out frequncies from disabled octaves    
      for ( int i = 0; i < 8; i ++ ) {
        if ( !p.OCTAVE_TOGGLE[i] ) {
          if ( closestFreq >= p.octaveLowRange(i) && closestFreq <= p.octaveHighRange(i) ) {
            filterFreq = true;
          }
        }
      }

      // Set spectrum 
      if ( !filterFreq ) {
        binDistance[k] = 2 * abs((12 * log(freq[k]/440.0) / log(2)) - (12 * log(closestFreq/440.0) / log(2)));

        p.spectrum[k] = p.fft.getBand(k) * p.binWeight(p.WEIGHT_TYPE, binDistance[k]);


        if ( p.LINEAR_EQ_TOGGLE ) {
          p.spectrum[k] *= (p.linearEQIntercept + k * p.linearEQSlope);
        }

        // Sum PCP bins
        p.pcp[p.frameNumber][p.freqToPitch(freq[k]) % 12] += pow(p.fft.getBand(k), 2) * p.binWeight(p.WEIGHT_TYPE, binDistance[k]);
      }
    }
    p.normalizePCP();

    if ( p.PCP_TOGGLE ) {
      for ( int k = 0; k < p.fftSize; k++ ) {
        if ( freq[k] < freqLowRange || freq[k] > freqHighRange ) { 
          continue;
        }

        p.spectrum[k] *= p.pcp[p.frameNumber][p.freqToPitch(freq[k]) % 12];
      }
    }

    float sprev = 0;
    float scurr = 0;
    float snext = 0;

    float[] foundPeak = new float[0];
    float[] foundLevel = new float[0];

    // find the peaks and valleys
    for (int k = 1; k < p.fftSize -1; k++) {
      if ( freq[k] < freqLowRange || freq[k] > freqHighRange ) { 
        continue;
      }

      sprev = p.spectrum[k-1];
      scurr = p.spectrum[k];
      snext = p.spectrum[k+1];

      if ( scurr > sprev && scurr > snext && (scurr > p.PEAK_THRESHOLD) ) { // peak
        // Parobolic Peak Interpolation to estimate the real peak frequency and magnitude
        float ym1 = sprev;
        float y0 = scurr;
        float yp1 = snext;

        float pp = (yp1 - ym1) / (2 * ( 2 * y0 - yp1 - ym1));
        float interpolatedAmplitude = y0 - 0.25 * (ym1 - yp1) * pp;
        float a = 0.5 * (ym1 - 2 * y0 + yp1);  

        float interpolatedFrequency;
        if(testSound) {
          interpolatedFrequency = (k + pp) * player.sampleRate() / p.fftBufferSize;
        }else {
          interpolatedFrequency = (k + pp) * p.input.sampleRate() / p.fftBufferSize;
        }
        
        if ( p.freqToPitch(interpolatedFrequency) != p.freqToPitch(freq[k]) ) {
          freq[k] = interpolatedFrequency;
          p.spectrum[k] = interpolatedAmplitude;
        }

        boolean isHarmonic = false;

        // filter harmonics from peaks
        if ( p.HARMONICS_TOGGLE ) {
          for ( int f = 0; f < foundPeak.length; f++ ) {
            //TODO: Cant remember why this is here
            if (foundPeak.length > 2 ) 
            {
              isHarmonic = true;
              break;
            }
            // If the current frequencies note has already peaked in a lower octave check to see if its level is lower probably a harmonic
            if ( p.freqToPitch(freq[k]) % 12 == p.freqToPitch(foundPeak[f]) % 12 && p.spectrum[k] < foundLevel[f] ) 
            {
              isHarmonic = true;
              break;
            }
          }
        }

        if ( isHarmonic ) 
        {        
          p.peak[k] = p.HARMONIC;
          //println("dont add harmonic");
        } else 
        {
          p.peak[k] = p.PEAK;

          Note n = new Note(p, freq[k], p.spectrum[k]);
          n.noteOnFrame = frameCount;
          p.notes[p.frameNumber] = (Note[])append(p.notes[p.frameNumber], n);

          // Track Peaks and Levels in this pass so we can detect harmonics 
          foundPeak = append(foundPeak, freq[k]);
          foundLevel = append(foundLevel, p.spectrum[k]);
        }
      }
    }
  }

  // draw routine needs to be synchronized otherwise it will run while buffers are being populated
  synchronized void draw() { 
    p.render();
  }
}