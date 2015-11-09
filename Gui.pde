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