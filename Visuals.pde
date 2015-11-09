class Visuals {
  PShader blurShader;
  PGraphics pgBars, pgBlurPass1, pgBlurPass2;
  final int MAX_BLUR_ITERATIONS = 3;
  boolean useBlur = false;
  PImage back, backSharp, backSoft;
  float backSharpAlpha = 255;

  Visuals() {
  }

  void setupGuitarVisual() {
    midibars= new ArrayList<GuitarBar>();

    blurShader = loadShader( "shaders/blur.glsl" );
    blurShader.set( "blurSize", 9 );
    blurShader.set( "sigma", 5.f );
    pgBlurPass1 = createGraphics( width, height, P3D );
    pgBlurPass1.noSmooth();
    pgBlurPass2 = createGraphics( width, height, P3D );
    pgBlurPass2.noSmooth();

    pgBars = createGraphics( width, height, P3D );
    pgBars.noSmooth();

    float fov = PI/3.0;
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), 
      cameraZ/10.0, cameraZ*10.0);

    if (blurredBack) {
      backSharp = loadImage("er4-sharp.jpg");
      backSoft = loadImage("er4-soft.jpg");
    } else 
    back = loadImage("er4.jpg");
  }

  void drawGuitarVisual() {
    if (blurredBack) {
      image(backSoft, 0, 0);

      backSharpAlpha = max(0, backSharpAlpha - numOns * 5);
      pushStyle();

      backSharpAlpha = min(255, backSharpAlpha + 3);
      tint(255, backSharpAlpha);
      image(backSharp, 0, 0);
      popStyle();
      //println("backSharpAlpha " + backSharpAlpha);
    } else 
    image(back, 0, 0);
  }
}