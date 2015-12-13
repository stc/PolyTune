static class VisualizerHelpers {
  static void visalizeBackground(Vector<Visualizer> visualizers) {
    Iterator<Visualizer> i = visualizers.iterator();
    while (i.hasNext()) {
      i.next().drawBackground();
    }
  }
  
  static void visualizeNotes(String channelName, Vector<Visualizer> visualizers, int frameCount, Note[] notes) {
    Iterator<Visualizer> i = visualizers.iterator();
    while (i.hasNext()) {
      i.next().drawNotes(channelName, frameCount, notes);
    }
  }
}