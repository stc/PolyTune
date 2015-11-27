public class Window {
  public static final int RECTANGULAR = 0; // equivilent to no window
  public static final int HAMMING = 1;
  public static final int HANN = 2;
  public static final int COSINE = 3;
  public static final int TRIANGULAR = 4;
  public static final int BLACKMAN = 5;
  public static final int GAUSS = 6;

  private int mode = HANN;

  void setMode(int window) {
    this.mode = window;
  }

  void transform(float[] samples) {
    switch(mode) {
    case HAMMING:
      hammingWindow(samples);
      break;
    case HANN:
      hannWindow(samples);
      break;
    case COSINE:
      cosineWindow(samples);
      break;
    case TRIANGULAR:
      triangularWindow(samples);
      break;
    case BLACKMAN:
      blackmanWindow(samples);
      break;
    case GAUSS:
      gaussWindow(samples);
      break;
    }
  }

  float[] drawCurve() {
    float[] samples = new float[128];

    for (int i = 0; i < samples.length; i++ ) {
      samples[i] = 1; // 1 out samples
    }

    switch(mode) {
    case HAMMING:
      hammingWindow(samples);
      break;
    case HANN:
      hannWindow(samples);
      break;
    case COSINE:
      cosineWindow(samples);
      break;
    case TRIANGULAR:
      triangularWindow(samples);
      break;
    case BLACKMAN:
      blackmanWindow(samples);
      break;
    case GAUSS:
      gaussWindow(samples);
      break;
    }
    return samples;
  }

  void hammingWindow(float[] samples) {
    for (int n = 0; n < samples.length; n++) {
      samples[n] *= (0.54f - 0.46f * Math.cos(TWO_PI * n / (samples.length - 1)));
    }
  }

  void hannWindow(float[] samples) {
    for (int n = 0; n < samples.length; n++) {
      samples[n] *= (0.5f * (1 - Math.cos(TWO_PI * n / (samples.length - 1))));
    }
  }

  void cosineWindow(float[] samples) {
    for (int n = 0; n < samples.length; n++) {
      samples[n] *= Math.cos((Math.PI * n) / (samples.length - 1) - (Math.PI / 2));
    }
  }

  void triangularWindow(float[] samples) {
    for (int n = 0; n < samples.length; n++) {
      samples[n] *= ((2.0f / samples.length) * ((samples.length / 2.0f) - Math.abs(n - (samples.length - 1) / 2.0f)));
    }
  }

  void blackmanWindow(float[] samples) {
    for (int n = 0; n < samples.length; n++) {
      samples[n] *= (0.42f - 0.5f * Math.cos(TWO_PI * n / (samples.length - 1))) + (0.08f * Math.cos(4 * PI * n / (samples.length -1)));
    }
  }

  void gaussWindow(float[] samples) {
    double a = 2.5;
    for (int n = 0; n < samples.length; n++ ) {
      samples[n] *= Math.pow(Math.E, -0.5 * Math.pow((n - (samples.length - 1) / 2) / (0.1 * (samples.length - 1) / 2), 2));
    }
  }
}