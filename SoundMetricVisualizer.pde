class SoundMetricVisualizer implements Visualizer {
  public static final int GRAY_BARS = 0;
  public static final int GRAY_CIRCLES = 1;
  public static final int COLORED_BACKGROUND = 2;
  
  int style;
  
  // == init
  // ==  
  SoundMetricVisualizer() {
    init(GRAY_BARS);
  }

  SoundMetricVisualizer(int style) {
    init(style);
  }
  
  private void init(int style) {
    this.style = style;
  }
  
  // == drawers
  // ==
  void drawBackground() {
    background(0);
  }
  
  void drawNotes(String channelName, int frameCount, Note[] notes) {
    int amplitude = (int) sumAmplitude(notes);
    int num = notes.length;
    int pitch = (int) maxPitch(notes);
    
    switch(style) {
      case GRAY_BARS: 
        drawBars(amplitude, num, pitch);
        break;
      case GRAY_CIRCLES: 
        drawCircles(amplitude, num, pitch);
        break;
      case COLORED_BACKGROUND:
        drawColoredBackground(amplitude, num, pitch);
        break;
    }
    
  }
  
  // == drawing styles
  // ==
  private void drawBars(int amplitude, int num, int pitch) {
    drawRect(0, amplitudeColor(amplitude));
    drawRect(1, numColor(num));
    drawRect(2, pitchColor(pitch));
  }

  private void drawCircles(int amplitude, int num, int pitch) {
    drawCircle(2, pitchColor(pitch));
    drawCircle(1, numColor(num));
    drawCircle(0, amplitudeColor(amplitude));
  }
  
  private void drawColoredBackground(int amplitude, int num, int pitch) {
    background(amplitude, num, pitch);
  }
  
  // == metrics to colors
  // ==
  private int amplitudeColor(int amplitude) {
    return (int) map(amplitude, 0, 200, 0, 255);
  }

  private int pitchColor(int pitch) {
    return (int) map(max(pitch, 50), 50, 120, 0, 255);
  }
  
  private int numColor(int num) {
    return (int) map(num, 0, 10, 0, 255);
  }

  // == drawing
  // ==
  private void drawRect(int index, int clr) {
    int w = width * 2 / 3;
    int h = height * 2;
    int x = index * w / 2;
    int y = 0;

    rectMode(CORNER);
    fill(clr);
    rect(x, y, width, h);
  }
  
  private void drawCircle(int index, int clr) {
    int r = (index + 1) * min(width, height) / 2 / 3;
    ellipseMode(CENTER);
    fill(clr);
    ellipse(width / 2, height / 2, r, r); 
  }

  // == calculating metrics
  // ==
  private int maxPitch(Note[] notes) {
    int max = 0;
    
    for (Note note: notes) {
      if (note.pitch > max)
        max = note.pitch;
    }
    
    return max;
  }

  private float sumAmplitude(Note[] notes) {
    float sum = 0;
    
    for (Note note: notes) {
      sum += note.amplitude;
    }
    
    return sum;
  }

  // == debugging
  // ==
  //private void printMidibars(ArrayList<GuitarBar> midibars) {
  //  String s = "";
    
  //  Iterator<GuitarBar> i = midibars.iterator();
    
  //  while(i.hasNext()) {
  //    GuitarBar b = i.next();
  //    s = s + "(" + b.note.frequency + ", " + b.on + "), ";
  //  }
    
  //  println(s);
  //}
  
  private void printNotes(Note[] notes) {
    String s = "";
    s += notes.length + ": ";
    
    //Iterator<Note> i = notes.iterator();
    
    for (Note note: notes) {
    //while(i.hasNext()) {
      //Note note = i.next();
      s += note.label() + ", ";
    }
    
    println(s);
  }

}