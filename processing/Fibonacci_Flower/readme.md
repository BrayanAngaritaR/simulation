### Sucesión Fibonacci representada en Flor con Processing
#### Este algoritmo permite mostrar la sucesión de Fibonacci representada en una flor. Está situada en la parte superior izquiera del monitor para que se logre apreciar el alcance que tiene la flor.


- - - - - - 
#### Código
```

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
```
- - - - - - 
Video interesante: [La sucesión de Fibonacci y la razón aúrea][2]

[2]: https://www.youtube.com/watch?v=pNTkdGZ_mAU
- - - - - -
### Contexto

En matemáticas, la sucesión o serie de Fibonacci es la siguiente sucesión infinita de números naturales:

La espiral de Fibonacci: una aproximación de la espiral áurea generada dibujando arcos circulares conectando las esquinas opuestas de los cuadrados ajustados a los valores de la sucesión;1​ adosando sucesivamente cuadrados de lado 0, 1, 1, 2, 3, 5, 8, 13, 21 y 34.
La sucesión comienza con los números 0 y 1,2​ y a partir de estos, «cada término es la suma de los dos anteriores», es la relación de recurrencia que la define.

A los elementos de esta sucesión se les llama números de Fibonacci. Esta sucesión fue descrita en Europa por Leonardo de Pisa, matemático italiano del siglo XIII también conocido como Fibonacci. Tiene numerosas aplicaciones en ciencias de la computación, matemática y teoría de juegos. También aparece en configuraciones biológicas, como por ejemplo en las ramas de los árboles, en la disposición de las hojas en el tallo, en las flores de alcachofas y girasoles, en las inflorescencias del brécol romanesco, en la configuración de las piñas de las coníferas, en la reproducción de los conejos y en cómo el ADN codifica el crecimiento de formas orgánicas complejas. De igual manera, se encuentra en la estructura espiral del caparazón de algunos moluscos, como el nautilus.

Fuente: [Wikipedia][1]

[1]: https://es.wikipedia.org/wiki/Sucesión_de_Fibonacci

- - - - - -

Fecha de creación: 04/09/2019
Creado por: Brayan Angarita