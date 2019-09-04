  /*
  Autor: Brayan Angarita
  Fecha de creación: 04/09/2019
  Descripción: Este algoritmo permite mostrar la sucesión de Fibonacci representada en una flor. 
  Está situada en la parte superior izquiera del monitor para que se logre apreciar el alcance que tiene la flor.
*/

class Petal {
   float x = 0.0;
   float y = 0.0;
   float rotation = 0.0;
   float scaleVar = 1;
  
   color lineColor = color(255, 255, 0, 150);
   color elipseColor = color(0, 0, 0);
   color fillColor = color(255, 255, 0);

void render (){
    pushMatrix();
    translate(this.x, this.y);
    fill(this.lineColor);
    rotate(this.rotation);
    scale(this.scaleVar, this.scaleVar);
    rect(-10, -1, 20, 2);
    ellipse(0, 0, 10, 10);
    fill(this.elipseColor);
    ellipse(0, 0, 8, 8);
    fill(this.fillColor);
    ellipse(0, 0, 5, 5);
    popMatrix();
  }
}


float ToRadians = PI / 180.0;
float gAngle = 137.5077640844293;
float rotation = 0.60;
float initialRotation = 0.2;
int width, height;
 
int totalPetals = 10;
Petal[] petals = new Petal[totalPetals];
float radiusGrowth = 1.00049;
float radius = 50;

void setup(){
  size(1000,800);
    width = 340;
    height = 350;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
    noStroke();
    smooth();
    background(0,0,0);
}
                                                                              
void draw() {
    
  for (int i = 0; i < totalPetals; i++) {
      rotation += gAngle;
      radius *= radiusGrowth;
      Petal newPetal = new Petal();
      newPetal.x = width / 2 + cos(rotation * ToRadians) * radius;
      newPetal.y = height / 2 + sin(rotation * ToRadians) * radius;
      newPetal.rotation = rotation * ToRadians;
      newPetal.render();
      petals[i] = newPetal;
  }

};
