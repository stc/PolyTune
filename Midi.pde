Note[] notesOpen = new Note[128];

void outputMIDINotes() {
  // send NoteOns
  for ( int i = 0; i < notes[frameNumber].length; i++ ) {
    Note note = notes[frameNumber][i];
    if ( OCTAVE_TOGGLE[note.octave] && notesOpen[note.pitch] == null) {
      //  NOTE ON
      //  we have <note.channel> <note.pitch> <note.velocity>
      notesOpen[note.pitch] = note;
      //note.noteOnFrame = frameNumber;
      // println("ON: " + note.label() + " at " + frameCount);
      midibars.add(new GuitarBar(note));
    }
  }

  // send NoteOffs   
  for ( int i = 0; i < notesOpen.length; i++ ) {
    boolean isOpen = false;
    if ( notesOpen[i] != null ) {
      for ( int j = 0; j < notes[frameNumber].length; j++ ) {
        if ( notes[frameNumber][j].pitch == i ) {
          isOpen = true;
        }
      }
      if ( !isOpen ) {
        //println("OFF: " + notesOpen[i].pitch);

        for (int j=0; j<midibars.size(); j++) {
          if (midibars.get(j).note.pitch == notesOpen[i].pitch) {
            midibars.get(j).on = false;
            midibars.get(j).note.noteLength = frameNumber - midibars.get(j).note.noteOnFrame;
          }
        }
        notesOpen[i] = null;
      }
    }
  }
}

void closeMIDINotes() {  
  for ( int i = 0; i < notesOpen.length; i++ ) {
    if ( notesOpen[i] != null ) {
      //  close all active notes here if needed
      notesOpen[i] = null;
    }
  }
}