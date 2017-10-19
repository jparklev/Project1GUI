class IImage {//Interactive Image
  float x;
  float y;
  PImage imgOriginal;
  PImage imgNew;
  private final PImage imgOriginalReset; // the original image preserved and unmodified
  private PImage imgNewReset; // an unresized version of imgNew, will be filtered along with imgNew but never resized.

  color c;
  float red;
  float green;
  float blue;

  int index;
  int imgWidth;
  int imgHeight;
  int currentMode = 0;
  boolean firstLoop = true; //used to draw the initial image once so that unspecified keys do not reset the image

  IImage(int x, int y, PImage img) {
    println("constructing " + currentMode);
    this.x = x;
    this.y = y;
    assert img != null: "img is null in Iimage constructor";
    imgOriginal = img.copy();
    imgOriginalReset = img.copy();
    imgWidth = img.width;
    imgHeight = img.height;
  }

  IImage(PImage img) {
    this.x = 0;
    this.y = 0;
    imgOriginal = img.copy();
    imgOriginalReset = img.copy();
    imgWidth = img.width;
    imgHeight = img.height;
    imgWidth = img.width;
    imgHeight = img.height;
  }

  void display() {
    PImage imgCurrent;
    if(currentMode == 0)
      imgCurrent = imgOriginal;
    else
      imgCurrent = imgNew;

    image(imgCurrent, x, y);
    setLabels(imgCurrent,x,y);
    //setLabels(imgNew, 100, height/2-(imgNew.height/2));
  }

  void display(float xPos, float yPos) {
    x = xPos;
    y = yPos;
    PImage imgCurrent;
    if(currentMode == 0)
      imgCurrent = imgOriginal;
    else
      imgCurrent = imgNew;

    image(imgCurrent, x, y);
    setLabels(imgCurrent,x,y);
  }

//------------------------------------------------------------------------------------
//Filters
  void changeFilter() {
    if (firstLoop) {
      image(imgOriginal, x, y);
      firstLoop = false;
    }
    if (key == '1' && currentMode != 1) {
      currentMode = 1;
      imgNew = createImage(imgWidth, imgHeight, ARGB);
      imgNewReset = createImage(imgOriginalReset.width, imgOriginalReset.height, ARGB);
      greyscale(imgOriginal, imgNew);
      greyscale(imgOriginalReset, imgNewReset);
      image(imgNew, x, y);
    }
    if (key == '2' && currentMode != 2) {
      currentMode = 2;
      imgNew = createImage(imgWidth, imgHeight, ARGB);
      imgNewReset = createImage(imgOriginalReset.width, imgOriginalReset.height, ARGB);
      contrast(imgOriginal, imgNew);
      contrast(imgOriginalReset, imgNewReset);
      image(imgNew, x, y);
    }
    if (key == '3' && currentMode != 3) {
      currentMode = 3;
      imgNew = createImage(imgWidth, imgHeight, ARGB);
      imgNewReset = createImage(imgOriginalReset.width, imgOriginalReset.height, ARGB);
      blur(imgOriginal, imgNew);
      blur(imgOriginalReset, imgNewReset);
      image(imgNew, x, y);
    }
    if (key == '4' && currentMode != 4) {
      currentMode = 4;
      imgNew = createImage(imgWidth, imgHeight, ARGB);
      imgNewReset = createImage(imgOriginalReset.width, imgOriginalReset.height, ARGB);
      edgeDetection(imgOriginal, imgNew);
      edgeDetection(imgOriginalReset, imgNewReset);
      image(imgNew, x, y);
    }
    if (key == '5' && currentMode != 5) {
      currentMode = 5;
      imgNew = createImage(imgWidth, imgHeight, ARGB);
      imgNewReset = createImage(imgOriginalReset.width, imgOriginalReset.height, ARGB);
      sharpen(imgOriginal, imgNew);
      sharpen(imgOriginalReset, imgNewReset);
      image(imgNew, x, y);
    }
    if (key == '0' && currentMode != 0) {
      currentMode = 0;
      image(imgOriginal, x, y);
    }
  }

  private void greyscale(PImage imgO, PImage imgN) {//private method to perform the greyscale function on an image
    loadPixels();
    float grey;
    for (int i = 0; i < imgO.height; i++) {
      for (int j = 0; j < imgO.width; j++) {
        index = i + j*imgO.height;
        c = imgO.pixels[index];
        red = red(c);
        green = green(c);
        blue = blue(c);
        grey = (red + green + blue) / 3;
        c = color(grey, grey, grey);
        imgN.pixels[index] = c;
      }
    }
    updatePixels();
  }

  private void contrast(PImage imgO, PImage imgN) {
    loadPixels();
    for (int i = 0; i < imgO.height; i++) {
      for (int j = 0; j < imgO.width; j++) {
        index = i + j*imgO.height;
        c = imgO.pixels[index];
        red = contrastHelp(red(c));
        green = contrastHelp(green(c));
        blue = contrastHelp(blue(c));
        c = color(red, green, blue);
        imgN.pixels[index] = c;
      }
    }
    updatePixels();
  }

  private float contrastHelp(float rgb) {
    if (rgb >= 128) {//128-225
      if (rgb >= 192) {//192-225
        if (rgb >= 224) {//224-255
          //change nothing
        } else {//192-223
          rgb+=10;
        }
      } else {//128-191
        rgb+=20;
      }
    } else {//0-127
      if (rgb < 64) {//0-63
        if (rgb < 32) {//0-31
          //change nothing
        } else {//31-63
          rgb-=10;
        }
      } else {//63-127
        rgb-=20;
      }
    }
    return rgb;
  }

  private void blur(PImage imgO, PImage imgN) {
    float[][] blurKernel = {{.0625, .125, .0625}, {.125, .25, .125}, {.0625, .125, .0625}};
    useKernel(blurKernel, imgO, imgN);
  }

  private void edgeDetection(PImage imgO, PImage imgN) {
    float[][] edgeVert = {{1, 2, 1}, {0, 0, 0}, {-1, -2, -1}};
    float[][] edgeHor = {{1, 0, -1}, {2, 0, -2}, {1, 0, -1}};
    color c1, c2;
    PImage imgBuffer = createImage(imgO.width, imgO.height, ARGB);
    useKernel(edgeVert, imgO, imgBuffer);
    useKernel(edgeHor, imgO, imgN);
    for (int i = 0; i < imgO.height; i++) {
      for (int j = 0; j < imgO.width; j++) {
        index = i + j*imgO.height;
        c1 = imgBuffer.pixels[index];
        c2 = imgN.pixels[index];
        red = sqrt(pow(red(c1), 2) + pow(red(c2), 2));
        green = sqrt(pow(green(c1), 2) + pow(green(c2), 2));
        blue = sqrt(pow(blue(c1), 2) + pow(blue(c2), 2));
        red = constrain(abs(red), 0, 255);
        green = constrain(abs(green), 0, 255);
        blue = constrain(abs(blue), 0, 255);
        c = color(red, green, blue);
        imgN.pixels[index] = c;
      }
    }
  }

  private void sharpen(PImage imgO, PImage imgN) {
    float[][] sharpen = {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}};
    useKernel(sharpen, imgO, imgN);
  }

  private void useKernel(float[][] kernel, PImage imgO, PImage imgN) {
    loadPixels();
    for (int i = 0; i < imgO.height; i++) {
      for (int j = 0; j < imgO.width; j++) {
        index = i + j*imgO.height;
        c = imgO.pixels[index];
        red = 0;
        green = 0;
        blue = 0;
        for (int x = -1*kernel.length/2; x <= kernel.length/2; x++) {
          for (int y = -1*kernel.length/2; y <= kernel.length/2; y++) {
            if (index + (x + y*imgO.width) >= 0 && index + (x + y*imgO.width) < imgO.pixels.length) {
              red += red(imgO.pixels[index + (x + y*imgO.width)]) * kernel [x+1][y+1];
              green += green(imgO.pixels[index + (x + y*imgO.width)]) * kernel [x+1][y+1];
              blue += blue(imgO.pixels[index + (x + y*imgO.width)]) * kernel [x+1][y+1];
            }
          }
        }
        red = constrain(abs(red), 0, 255);
        green = constrain(abs(green), 0, 255);
        blue = constrain(abs(blue), 0, 255);
        c = color(red, green, blue);
        imgN.pixels[index] = c;
      }
    }
    updatePixels();
  }


//------------------------------------------------------------------------------------
//Resizing

  // code from imgResize for text, intructions, labels
  void setLabels(PImage img, float imgXPos, float imgYPos) {
  
    fill(255);
    noStroke();
  
    // Image Dimension Title
    textAlign(CENTER);
    textSize(30);
    //text("Image Dimensions", width-200, height*.15);
  
    // Instructions
    text("Instructions", width-200, height*.15);
    textSize(16);
    textAlign(LEFT);
    text("Press 0 for the original image", width-300, 200);
    text("Press 1-5 for various filters", width-300, 240);
    text("Press Resize button to toggle size", width-300, 280);
  
    // Height and Width subLabels
    textAlign(LEFT);
    textSize(15);
    text(("H: " + img.height + " W: " + img.width), imgXPos, imgYPos + img.height + 15);
  }
  
  // resizing will reset imgOriginal and imgNew to their original size/resolution, and then resize
  // this will keep the picture from losing quality with each resize
  // resizing with fixed aspect ratio
  public void resizeByWidth(float w) {
    float ratio = (float(imgOriginal.width)/float(imgOriginal.height));
    imgOriginal = imgOriginalReset.copy();
    imgOriginal.resize(int(w), int(w/ratio));
    if(imgNew != null) {
      imgNew = imgNewReset.copy();
      imgNew.resize(int(w), int(w/ratio));
    }
    imgWidth = imgOriginal.width;
    imgHeight = imgOriginal.height;
  }
  
  public void resizeByHeight(float h) {
    float ratio = (float(imgOriginal.width)/float(imgOriginal.height));
    imgOriginal = imgOriginalReset.copy();
    imgOriginal.resize(int(h*ratio), int(h));
    if(imgNew != null) {
      imgNew = imgNewReset.copy();
      imgNew.resize(int(h*ratio), int(h));
    }
    imgWidth = imgOriginal.width;
    imgHeight = imgOriginal.height;
  }
  
  // just resize
  public void resizeImg(float w, float h){
    imgOriginal = imgOriginalReset.copy();
    imgOriginal.resize(int(w), int(h));
    if(imgNew != null) {
      imgNew = imgNewReset.copy();
      imgNew.resize(int(w), int(h));
    }
    imgWidth = imgOriginal.width;
    imgHeight = imgOriginal.height;
  }
}