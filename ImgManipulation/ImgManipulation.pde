PImage img;
IImage interactive;
String fileDest;
button save;
boolean wasSaveClicked;
  
void setup() {
  selectInput("Select a file to process:", "fileSelected");
  surface.setResizable(true);
  save = new button(50,25,100,50,"save");
  wasSaveClicked = false;
  fileDest = "";
}

void draw() {
  if(img != null){
    //image(img,-1,49);
    interactive.display();
    surface.setSize(interactive.imgWidth, interactive.imgHeight+50);
  }
  
  if(interactive != null)
    interactive.edit();//allows for editing of the picture
  
  //display save button
  save.display();
  if(wasSaveClicked){
    //create file dest text box
    fill(255);
    rect(int(width/2), int(height/2), width, 200);
    fill(0);
    String prompt = "Please type out a file destination to save to e.g. 'C:\\Pictures\\myPhoto.jpg'";
    text(prompt, (int(width)-textWidth(prompt))/2, int(height/2) - 15);
    text(fileDest, (int(width)-textWidth(fileDest))/2, int(height/2));
  }

}

void mousePressed(){
  if(save.check()){
    wasSaveClicked = true;
  }
}

void keyPressed(){
  if(wasSaveClicked){
    if(keyCode == BACKSPACE){
      if(fileDest.length()>0){
        fileDest = fileDest.substring(0, fileDest.length()-1);
      }
    } else if (keyCode == DELETE){
      fileDest = "";
    } else if (keyCode == ENTER && interactive.currentMode != 0){
      interactive.imgNew.save(fileDest);
      wasSaveClicked = false;
    } else if (keyCode == ENTER && interactive.currentMode == 0){
      interactive.imgOriginal.save(fileDest);
      wasSaveClicked = false;
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      fileDest = fileDest + key;
    }
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    img = loadImage(selection.getAbsolutePath());
    interactive = new IImage(0, 50, img);//move this line of code elsewhere if necessarry, supposed to create an IImage based on the new PImage
  }
}