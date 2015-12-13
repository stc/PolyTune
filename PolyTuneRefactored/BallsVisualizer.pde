import java.util.*;

class BallsVisualizer implements Visualizer {
  class Sprite {
    Note note;
    float x, y;
    float vx, vy;
    float ax, ay;
    
    Sprite(Note note) {
      this.note = note;
      
      ax = 0;
      ay = 0.2;
    }
    
    void move() {
      x += vx;
      y += vy;
      vx += ax;
      vy += ay;
    }
    
    void draw() {
      ellipseMode(CENTER);
      ellipse(x, y, 20, 20);
    }
    
    boolean isVisible() {
      return y < height;
    }
  }
  
  Vector<Sprite> sprites;
  
  BallsVisualizer() {
    sprites = new Vector<Sprite>();
  }
  
  void drawBackground() {
    background(0);
  }
 
  private void removeNonVisibles() {
    Vector<Sprite> notVisibles = new Vector<Sprite>();
    for (Sprite sprite: sprites) {
      if (!sprite.isVisible())
        notVisibles.add(sprite);
    }
    
    for (Sprite sprite: notVisibles) {
      sprites.remove(sprite);
    }
  }
  
  private void printNotes(int frameCount, Note[] notes) {
    StringBuilder sb = new StringBuilder();
    sb.append(frameCount + ": ");
    
    for (Note note:notes) {
      sb.append("" + note.noteOnFrame);
    }
    
    println(sb);
  }
  
  void drawNotes(String channelName, int frameCount, Note[] notes) {
    this.printNotes(frameCount, notes);
    for(Note note:notes) {
      if (note.noteOnFrame == frameCount) {
        Sprite sprite = new Sprite(note);
        sprite.y = height;
        sprite.x = map(note.pitch, 50, 120, 100, width - 100);
        sprite.vx = 0;
        sprite.vy = -5;
        sprites.add(sprite);
      }
    }
    
    for (Sprite sprite: sprites) {
      sprite.move();
      sprite.draw();
    }
    
    removeNonVisibles();
    
    //Iterable<Note> missing = getMissingSprites(notes);
    //for (Note note: missing) {
    //    Sprite sprite = new Sprite(note);
    //    sprite.y = height;
    //    sprite.x = map(note.pitch, 50, 120, 100, width - 100);
    //    sprite.vx = 0;
    //    sprite.vy = 0;
        
    //    sprites.add(sprite);
    //}
    
    //for(Note note: sprites.keySet()) {
    //  Sprite sprite = sprites.get(note);
      
    //}
    
  }
}