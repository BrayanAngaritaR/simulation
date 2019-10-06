   
PrintWriter output; //Get PrintWriter object and exports it to a new file
void setup(){
  size(1280, 800);
}
void draw(){
  PImage img = loadImage("lake.png");
  PImage img2 = loadImage("lake2.png");
  
  
  image(img, 0, 0);
  image(img2,640,0);


  int[] hist = new int[256];
  

  // Calculate the histogram
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      int bright = int(brightness(get(i, j)));
      hist[bright]++; 
      img.get(i,j);
    }
  }
  
  // Find the largest value in the histogram
  int histMax = max(hist);


  // Draw half of the histogram (skip every second value)
  for (int i = 0; i < img.width; i += 2) {
    
    int which = int(map(i, 0, img.width, 0, 255));
    int y = int(map(hist[which], 0, histMax, img.height, 0));
    line(i, img.height, i, y); //Display histogram
  
  }


// Draw half of the histogram (skip every second value)
  for (int i = 0; i < img.width; i += 2) {
    // Map i (from 0..img.width) to a location in the histogram (0..255)
    int which = int(map(i, 0, img.width, 125, 0));
    // Convert the histogram value to a location between 
    // the bottom and the top of the picture
    int y = int(map(hist[which], 0, histMax, img2.height, 0));
    stroke(125, 125, 0);
    line(i, img.height, i, y);
  }

  for (int i = 0; i < img.width; i++) {
    for (int j =0; j < img.height; j++) {
   
      
      if(img.get(i,j) != img2.get(i,j)){
      color c2= color(img2.get(i,j)); 
      set(i, j, c2);
      }
      else{
      color c= color(0);
      set(i,j,c);
      }
  
    }
  }
}
