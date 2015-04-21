class MIDIBar 
{
    boolean diagonal = true; // fretboard mapped or diagonal
    boolean runningNotes = false; // short notes slide faster
    boolean colorByTimbre = true;
    float x, y, w, h, z;
    boolean on = true;
    boolean isHarmonic = false;
    int pitch;
    int keyHeight = height / (keyboardEnd - keyboardStart);
    Note note;
    String noteName = "";
    color noteColor;
    float fretSize = 45;
    float stringSpace = 20;
    int moduloChange = 6;
    PVector neckStart;
    int startNotePitch = 45;    
    int timbreColor;
    MIDIBar after;
    
    MIDIBar(Note _note) 
    {

        neckStart = new PVector(820, 72);
        note = _note;
        h = keyHeight;
        w = 10;
        timbreColor = peaknum * 4;
        //println("TIMBRE: " + peaknum);
        //println("note.pitch " + note.pitch);
        int string = floor(note.pitch / moduloChange) - 10;
        
        if (!diagonal)
        {
            x = neckStart.x + string * stringSpace;
            y =  neckStart.y + (note.pitch%moduloChange) * fretSize + (string * 2 * fretSize) ;
        }
        else
        {
             x = neckStart.x + (note.pitch - startNotePitch) * 2;
             y = neckStart.y + (note.pitch - startNotePitch) * 15;   
        }
    }

    void grow() {
        ellipseMode(CENTER);
        if (colorByTimbre) fill(255-timbreColor,155+timbreColor,155+timbreColor);
        else fill(255);
        
        noStroke();
        float ew = max(w*2, 20);
        ellipse(x, y, ew, ew);
        w+=2;
    }

    public float normalizeY(float y)
    {
        //return y * 2 - 600 ;
        return y;
    }

    void scroll() {
    
        
        pushMatrix();
        ellipseMode(CENTER);
        noStroke();
        translate(x, y, z);
        float size = max(w-10, 5);
        if (colorByTimbre) fill(255-timbreColor,155+timbreColor,155+timbreColor, map(x, 820, 200, 222, 0));
        else fill(255, map(x, 820, 200, 222, 0));
 
        // for debugging bars to remove
        if (isHarmonic) fill(255, 0, 0, 255);
        float bloat = map(x, 820, 200, 2, 1);
        ellipse(0, 0, size * bloat, size * bloat);
        fill(0, map(x, 820, 0, 256, 200) + note.amplitude);
        ellipse(0, 0, size, size);
        popMatrix();
        
        if (runningNotes)
            x -= max(5 - w/20, 0.5);
        else
            x -= 2;
        z += note.amplitude * 0.01;
    }

    void display() {
        if (on) {
            grow();
        }
        if (!on) {
            scroll();
        }
    }
}
