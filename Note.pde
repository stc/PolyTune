static final String[] semitones = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };

class Note {
  float frequency;
  float amplitude;

  int octave;
  int semitone;
  
  int channel;
  int pitch;
  int velocity;
  
  Note(float frequency, float amplitude) {
    this.frequency = frequency;   
    this.amplitude = amplitude;
    this.pitch = freqToPitch(frequency);
    this.octave = this.pitch / 12 - 1;
    this.semitone = this.pitch % 12;
    this.channel = OCTAVE_CHANNEL[this.octave];
    this.velocity = round((amplitude - PEAK_THRESHOLD) / (255f + PEAK_THRESHOLD) * 128f);
    
    if (this.velocity > 127 ) {
      this.velocity = 127;
    }
  }
  
  public String label() {
    return semitones[this.semitone] + this.octave;
  }
}
