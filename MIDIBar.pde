class MIDIBar 
{
    boolean diagonal = true; // fretboard mapped or diagonal
    boolean runningNotes = true; // short notes slide faster
    float x, y, w, h, z;
    boolean on = true;
    boolean harmonic = false;
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

    MIDIBar(Note _note) 
    {

        neckStart = new PVector(820, 72);
        note = _note;
        h = keyHeight;
        w = 0;
        println("note.pitch " + note.pitch);
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
        fill(255);
        noStroke();
        float ew = max(w*2, 20);
        ellipse(x, normalizeY(y), ew, ew);
        w+=2;
    }

    public float normalizeY(float y)
    {
        //return y * 2 - 600 ;
        return y;
    }

    void scroll(PGraphics pg) {
        //colorMode(HSB);
        //fill(noteColor);
        pg.pushMatrix();
        pg.ellipseMode(CENTER);
        pg.noStroke();
        pg.translate(x, normalizeY(y), z);
        float size = max(w, 5);
        pg.fill(255, 222);
        pg.ellipse(0, 0, size * 2, size* 2);

        pg.fill(0, 200 + note.amplitude);
        pg.ellipse(0, 0, size, size);
        pg.popMatrix();

        if (runningNotes)
            x -= max(5 - w/20, 0.5);
        else
            x -= 1;
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
