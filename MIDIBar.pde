class MIDIBar {
	float x, y, w, h, z;
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
		x = width / 1.7;
		y = height - (note.pitch - keyboardStart + 1) * keyHeight;

		//colorMode(HSB);
		//noteColor = color(map(note.pitch%12,0,12,0,255),255,100);
		//colorMode(RGB);
	}

	void grow(){
		rectMode(CORNER);
		fill(0,0, 50);
		ellipse(x,normalizeY(y),w,w);
		w+=2;
	}

        public float normalizeY(float y)
        {
            return y * 2 - 300;
        }

	void scroll(PGraphics pg){
		//colorMode(HSB);
		//fill(noteColor);
                pg.pushMatrix();
                pg.rectMode(CORNER);
                pg.noStroke();
                pg.translate(x, normalizeY(y), z);
                float size = note.amplitude *1;
		pg.fill(255,note.amplitude * 2);
		pg.ellipse(0,0,size * 2,size* 2);

                pg.fill(0,note.amplitude * 4 + 60);
                pg.ellipse(0,0,size,size);
                pg.popMatrix();
        
		x-=2;
                z -= 0.5;

                /*
		fill(255);
		if(note.amplitude > 40){
			//text(note.label(), x + 5, height - ((note.pitch - keyboardStart) * keyHeight));
		}
		if(w>40){
		//	text(note.label(), x + 5, height - ((note.pitch - keyboardStart) * keyHeight));
		}
                */
		
	}

	void display(PGraphics pg){
		if(on){
			grow();
		}if(!on){
			scroll(pg);
		}
	}
}
