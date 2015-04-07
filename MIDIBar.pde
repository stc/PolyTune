class MIDIBar {
	int x, y, w, h;
	boolean on = true;
	int pitch;
	int keyHeight = height / (keyboardEnd - keyboardStart);
	Note note;
	String noteName = "";
	color noteColor;

	MIDIBar(Note _note){
		note = _note;
		h = keyHeight;
		w = 0;
		x = 24;
		y = height - (note.pitch - keyboardStart + 1) * keyHeight;

		//colorMode(HSB);
		//noteColor = color(map(note.pitch%12,0,12,0,255),255,100);
		//colorMode(RGB);
	}

	void grow(){
		rectMode(CORNER);
		fill(255,0,0);
		rect(x,y,w,h);
		w+=2;
	}

	void scroll(){
		//colorMode(HSB);
		//fill(noteColor);
		fill(255,0,0,note.amplitude * 4 + 40);
		rectMode(CORNER);
		rect(x,y,w,h);
		x+=2;
		fill(255);
		if(note.amplitude > 40){
			text(note.label(), x + 5, height - ((note.pitch - keyboardStart) * keyHeight));
		}
		if(w>40){
			text(note.label(), x + 5, height - ((note.pitch - keyboardStart) * keyHeight));
		}
		colorMode(RGB);
	}

	void display(){
		if(on){
			grow();
		}if(!on){
			scroll();
		}
	}
}