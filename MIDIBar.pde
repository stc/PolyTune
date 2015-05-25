/*

  Base class for handling and storing MIDI note on & MIDI note off messages

*/

class MIDIBar
{
    
    float x, y, w, h, z;
    boolean on = true;
    boolean isHarmonic = false;
    int keyHeight = height / (keyboardEnd - keyboardStart);
    Note note;
    String noteName = "";
    MIDIBar after;

    MIDIBar(Note _note) {
        note = _note;
        noteName = note.label();
    }

    void grow() {
      //  we have a note on event
    }

    void scroll() {
      //  we have a note off event
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
