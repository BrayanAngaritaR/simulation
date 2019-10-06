#### Diferencia de imágenes basada en Histogramas
#### Este algoritmo permite comparar dos imágenes y como resultado dice si son iguales o diferentes basándose en el histograma de cada una de ellas


- - - - - - 
#### Código
```

   
PrintWriter output; //Get PrintWriter object and exports it to a new file
void setup(){
size(1280, 800);
//output = createWriter("histogram2.txt");
}
// Load an image from the data directory
// Load a different image by modifying the comments
void draw(){
PImage img = loadImage("pic1.jpg");
PImage img2 = loadImage("pic5.jpg");


image(img, 0, 0);
image(img2,640,0);


int[] hist = new int[256];

//New hist
int[] hist1 = new int[256];



// Calculate the histogram
for (int i = 0; i < img.width; i++) {
  for (int j = 0; j < img.height; j++) {
    int bright = int(brightness(get(i, j)));
    hist[bright]++; 
  }
}

//println(hist);


// Calculate the histogram
for (int i = 0; i < img2.width; i++) {
  for (int j = 0; j < img2.height; j++) {
    int bright = int(brightness(get(i, j)));
    hist1[bright]++; 
  }
}

// Find the largest value in the histogram
int histMax = max(hist);

int histMax1 = max(hist1);

stroke(255); //Change histogram color to white
// Draw half of the histogram (skip every second value)
for (int i = 0; i < img.width; i += 2) {
  // Map i (from 0..img.width) to a location in the histogram (0..255)
  int which = int(map(i, 0, img.width, 0, 255));
  // Convert the histogram value to a location between 
  // the bottom and the top of the picture
  int y = int(map(hist[which], 0, histMax, img.height, 0));
  line(i, img.height, i, y); //Display histogram
  
  //println(i,y);
  //output.println(i + "-" + y);
}


//stroke(255);
// Draw half of the histogram (skip every second value)
for (int i = 0; i < img2.width; i += 2) {
  // Map i (from 0..img.width) to a location in the histogram (0..255)
  int which = int(map(i, 0, img2.width, 0, 255));
  // Convert the histogram value to a location between 
  // the bottom and the top of the picture
  int y = int(map(hist1[which], 0, histMax1, img2.height, 0));
  line(i+img.width, img2.height, i+img.width, y); //Display histogram
  
  //println(i,y);
  //output.println(i + "-" + y);
}

if(histMax == histMax1){
  textSize(24); 
  text("Las imágenes son iguales", 500, 650); // Text wraps within text box
  fill(255);
  noLoop();
} else {
  textSize(24); 
  text("Las imágenes son diferentes", 500, 650); // Text wraps within text box
  fill(255);
  noLoop();
}
  //output.flush();
  //output.close(); 
  //exit();
}
```
- - - - - - 

Fecha de creación: 10/09/2019
Creado por: Brayan Angarita