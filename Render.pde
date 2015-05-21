void render() 
{

    boolean mesh = true;
    boolean thinMesh = false;

    if (showUI) {
        renderWindowCurve();
        renderFFT();
        renderPeaks();
    }


    // clean old 
    numOns = 0;
    for (int i=0; i<midibars.size (); i++)
    {
        if (midibars.get(i).on) numOns++;
        if ((midibars.get(i).x>width) || (midibars.get(i).x < - midibars.get(i).w * 4)) {
            midibars.remove(midibars.get(i));
        }
    }
    
    if (autoPeak)
    {
        int fresh = 0;
        for (int i=0; i<midibars.size (); i++)
        {
            if (frameCount - midibars.get(i).note.noteOnFrame < 20) fresh++;
        }
        if (fresh == 0) PEAK_THRESHOLD = max(3, PEAK_THRESHOLD-1);
        if (fresh > 5) PEAK_THRESHOLD += 1;
    }

    // notes 
    for (int i=0; i<midibars.size (); i++)
    {
        midibars.get(i).display();
    }

    // lines
    if (mesh)
    {
        float xLimit = 30;
        float yLimit = 100;
        // calculate links
        for (int i=0; i<midibars.size ()-1; i++) 
        {
            if (midibars.get(i).x < 600 && !thinMesh) continue;
            if (midibars.get(i).after != null && !thinMesh) continue;

            for (int k = 0; k < midibars.size (); k++)
            {
                if (i==k || abs(midibars.get(i).y - midibars.get(k).y) > yLimit) continue;
                float diff = midibars.get(k).x - midibars.get(i).x;
                if ( diff < xLimit && diff > 0 && midibars.get(i).after == null)
                {
                    midibars.get(i).after = midibars.get(k);
                } else if (diff < xLimit && diff > 0 && midibars.get(i).after.x > midibars.get(k).x)
                {
                    midibars.get(i).after = midibars.get(k);
                }


                // thin mesh
                if (thinMesh)
                {
                    strokeWeight(1);
                    stroke(0, 50);
                    if (abs(midibars.get(i).x - midibars.get(k).x) < 50 &&
                        abs(midibars.get(i).y - midibars.get(k).y) < 100 )
                    {
                        line(midibars.get(i).x, midibars.get(i).y, midibars.get(i).z, 
                        midibars.get(k).x, midibars.get(k).y, midibars.get(k).z);
                    }
                }
            }
        }

        // draw links
        strokeWeight(8);
        stroke(255, 222);
        noFill();
        for (int i=0; i<midibars.size ()-1; i++) 
        {
            if (midibars.get(i).after != null)
            {
                if (song == NUTHSELL)
                {
                    line(midibars.get(i).x, midibars.get(i).y, midibars.get(i).z, 
                         midibars.get(i).after.x, midibars.get(i).after.y, midibars.get(i).after.z);
                } else if (song == KISKECE)
                {   
                    PVector p = new PVector(midibars.get(i).x, midibars.get(i).y, midibars.get(i).z);
                    PVector q = new PVector(midibars.get(i).after.x, midibars.get(i).after.y, midibars.get(i).after.z);
                    curve(p.x, p.y - q.y/2, p.z, p.x, p.y, p.z, q.x, q.y, q.z, q.x, q.y + p.y/2, q.z);
                }
            }
        }
    } else
    {
        strokeWeight(5);
        stroke(255, 222);
        for (int i=0; i<midibars.size ()-1; i++) 
        {
            if (abs(midibars.get(i).x - midibars.get(i+1).x) > 100 ||
                abs(midibars.get(i).y - midibars.get(i+1).y) > 100 )
            {
                continue;
            }      
            line(midibars.get(i).x, midibars.get(i).y, midibars.get(i).z, 
            midibars.get(i+1).x, midibars.get(i+1).y, midibars.get(i+1).z);
        }
    }
}

boolean checkForHarmonics(MIDIBar m)
{
    Note h = m.note;
    for (int i=0; i<midibars.size (); i++)
    {
        Note base = midibars.get(i).note;
        if (h != base &&
            h.semitone == base.semitone &&
            h.pitch >= base.pitch && 
            h.velocity <= base.velocity &&
            abs(h.noteOnFrame - base.noteOnFrame) < 30)
        {
            return true;
        }
    }
    return false;
}

void renderPeaks() {
    int keyHeight = height / (keyboardEnd - keyboardStart);

    // render detected peaks
    noStroke();
    int keyLength = 10;
    int scroll = (frameNumber * keyLength > width) ? frameNumber - width/keyLength: 0;

    for ( int x = frameNumber; x >= scroll; x-- ) {
        if (x>-1) {
            for ( int i = 0; i < notes[x].length; i++ ) {
                Note note = notes[x][i];

                color noteColor;

                if ( pcp[x][note.pitch % 12] == 1.0 ) {
                    noteColor = color(100 * note.amplitude / 400);
                } else {
                    noteColor = color(255 * note.amplitude / 400);
                }

                fill(red(noteColor)/4, green(noteColor)/4, blue(noteColor)/4);
                rect(abs(x - frameNumber) * keyLength + 24, height - ((note.pitch - keyboardStart) * keyHeight), abs(x - frameNumber) * keyLength + keyLength + 25, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight));

                fill(noteColor);
                rect(abs(x - frameNumber) * keyLength + 24, height - ((note.pitch - keyboardStart) * keyHeight) - 1, abs(x - frameNumber) * keyLength + keyLength + 24, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight));
            }
        }
    }



    // output semitone text labels 
    textSize(10);

    if (frameNumber>-1) {
        for ( int i = 0; i < notes[frameNumber].length; i++ ) {
            Note note = notes[frameNumber][i];

            fill(220);
            // text(note.label(), 24 + 1, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight + 1));

            fill(140);
            //text(note.label(), 24, height - ((note.pitch - keyboardStart) * keyHeight + keyHeight + 2));
        }
    }
}

void renderWindowCurve() {
    int windowX = 100;
    int windowY = height-20;
    int windowHeight = 80;
    float[] windowCurve = window.drawCurve();
    noStroke();
    fill(60);
    rectMode(CORNER);
    rect(windowX, windowY, windowCurve.length, -windowHeight);
    stroke(255, 255, 255, 150);
    rectMode(CORNERS);
    for (int i = 0; i < windowCurve.length - 1; i++) {
        line(i + windowX, windowY - windowCurve[i] * windowHeight, i+1 + windowX, windowY - windowCurve[i+1] * windowHeight);
    }

    noStroke();
}

void renderFFT() {  
    noStroke();

    int keyHeight = height / (keyboardEnd - keyboardStart);
    color noteColor;
    float[] amp = new float[128];

    int previousPitch = -1;
    int currentPitch;
    float amplitudeTotal = 0f;

    for ( int k = 0; k < spectrum.length; k++ ) {
        float freq = k / (float)fftBufferSize * input.sampleRate();

        currentPitch = freqToPitch(freq);

        if ( currentPitch == previousPitch ) {
            amp[currentPitch] = amp[currentPitch] > spectrum[k] ? amp[currentPitch] : spectrum[k];
        } else {
            amp[currentPitch] = spectrum[k]; 
            previousPitch = currentPitch;
        }
    }

    for ( int i = keyboardStart; i < keyboardEnd; i++) {
        //noteColor = color(255, 100 * amp[i] / 400, 0);
        noteColor = color(0, 255, 240);

        fill(red(noteColor)/4, green(noteColor)/4, blue(noteColor)/4);
        rect(24, height - ((i - keyboardStart) * keyHeight), 25 + amp[i], height - ((i - keyboardStart) * keyHeight + keyHeight)); // shadow

        fill(noteColor);
        rect(24, height - ((i - keyboardStart) * keyHeight) - 1, 24 + amp[i], height - ((i - keyboardStart) * keyHeight + keyHeight));
    }
    stroke(255, 0, 0);
    strokeWeight(1);
    line(PEAK_THRESHOLD + 24, 0, PEAK_THRESHOLD + 24, height);
    noStroke();
}
