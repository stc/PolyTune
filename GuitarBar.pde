class GuitarBar extends MIDIBar {
  boolean diagonal = true; // fretboard mapped or diagonal
  boolean runningNotes = false; // short notes slide faster
  boolean colorByTimbre = true;
  float fretSize = 45;
  float stringSpace = 20;
  int moduloChange = 6;
  PVector neckStart;
  int startNotePitch = 45;    
  int timbreColor;

  GuitarBar( Note _note ) {
    super(_note); 
    neckStart = new PVector(820, 72);
    timbreColor = peaknum * 4;
    int string = floor(note.pitch / moduloChange) - 10;

    if (!diagonal)
    {
      x = neckStart.x + string * stringSpace;
      y =  neckStart.y + (note.pitch%moduloChange) * fretSize + (string * 2 * fretSize) ;
    } else
    {
      x = neckStart.x + (note.pitch - startNotePitch) * 2;
      y = neckStart.y + (note.pitch - startNotePitch) * 15;
    }

    ellipseMode(CENTER);
    rectMode(CENTER);
  }

  void grow() {
    if (colorByTimbre) fill(255-timbreColor, 155+timbreColor, 155+timbreColor);
    else fill(255);

    noStroke();
    float ew = max(w*2, 20);

    if (song == KISKECE)
    {
      ellipse(x, y, ew, ew);
      w+=2;
    } else if (song == NUTHSELL)  
    {
      pushMatrix();
      rotateZ(note.amplitude);  
      rect(x, y, ew, ew);
      w+=1.5f;
      popMatrix();
    }
  }

  public float normalizeY(float y)
  {
    //return y * 2 - 600 ;
    return y;
  }

  void scroll() {
    pushMatrix();
    noStroke();
    translate(x, y, z + 2);

    if (song == NUTHSELL)
      rotateZ(note.amplitude);

    float size = max(w-10, 5);
    if (colorByTimbre) fill(255-timbreColor, 155+timbreColor, 155+timbreColor, map(x, 820, 200, 222, 0));
    else fill(255, map(x, 820, 200, 222, 0));

    // for debugging bars to remove
    if (isHarmonic) fill(255, 0, 0, 255);
    float bloat = map(x, 820, 200, 2, 1);

    if (song == KISKECE)
      ellipse(0, 0, size * bloat, size * bloat);
    else if (song == NUTHSELL)
      rect(0, 0, size * bloat, size * bloat);

    fill(0, map(x, 820, 0, 256, 200) + note.amplitude);


    if (song == KISKECE)
      ellipse(0, 0, size, size);
    else if (song == NUTHSELL)  
      rect(0, 0, size, size);

    popMatrix();

    if (runningNotes)
      x -= max(5 - w/20, 0.5);
    else
      x -= 2;
    z += note.amplitude * 0.01;
  }
}