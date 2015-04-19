class MIDIBar 
{
    boolean diagonal = true; // fretboard mapped or diagonal
    boolean runningNotes = false; // short notes slide faster
    boolean colorByTimbre = false;
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

    MIDIBar(Note _note) 
    {

        neckStart = new PVector(820, 72);
        note = _note;
        h = keyHeight;
        w = 0;
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
        
        if (isHarmonic) fill(255, 0, 0);
        
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

    void scroll(PGraphics pg) {
    
        float a = map(x, width/2, 0, 222, 0);
        pg.pushMatrix();
        pg.ellipseMode(CENTER);
        pg.noStroke();
        pg.translate(x, y, z);
        float size = max(w, 5);
        if (colorByTimbre) pg.fill(255-timbreColor,155+timbreColor,155+timbreColor);
        else pg.fill(255, a);
 
        // for debugging bars to remove
        if (isHarmonic) pg.fill(255, 0, 0, 255);

        pg.ellipse(0, 0, size * 2, size* 2);
        pg.fill(0, a + note.amplitude);
        if (isHarmonic) pg.fill(255, 0, 0, 255);
        pg.ellipse(0, 0, size, size);
        pg.popMatrix();

        if (runningNotes)
            x -= max(5 - w/20, 0.5);
        else
            x -= 2;
        z += note.amplitude * 0.01;
    }

    void display(PGraphics pg) {
        if (on) {
            grow();
        }
        if (!on) {
            scroll(pg);
        }
    }
}
