### Disparo de proyectiles
#### Este programa permite conocer estadísticas del lanzamiento de proyectiles cuando se lanza en diferentes ángulos, velocidades iniciales y alturas. También permite manipular los valores entre la altura de la plataforma y el cañón.

#### Ello supone que que dentro del lanzamiento no hay resistencia al viento, la fuerza es aplicada al centro de masa, la aceleración se debe a la gravedad = -.1 y que no se pierde energía por el calor.


- - - - - - 
#### Código
```

//Tamaño de la fuente
int tSize = 18;

SpecialText t;

MainScreen ms;
Projectiles projectiles;
Point[] p = new Point[30];

//Método para la configuración de la interfaz
void setup() {
  textFont (createFont("Palatino Linotype", tSize));
  t = new SpecialText(tSize);
  noStroke();
  size(680, 680);

  ms = new MainScreen(tSize);
  projectiles = new Projectiles();

  for (int i = 0; i < p.length; i++) {
    p[i] = new Point();
  }
}

void draw() {
  background(255);
  fill(0);

  if (ms.scrn == 999) {
    ms.display();
  }
  if (ms.scrn == 0) {
    projectiles.display();
  }

}

class Point {
  float x;
  float y;
  float lastX;
  float lastY;
  float nextX;
  float nextY;
  float velX;
  float velY;
  float t;
  float deltaTScale = 570;
  float deltaT = .05;
  boolean followMouse = false;

  //  Crea escalas deslizantes donde 'a' es la ubicación del control deslizante
  float slider(float a, float x, float y, String title) {  
    stroke(0);
    line(x - 40, y, x + 40, y);
    line(x - 40, y - 5, x - 40, y + 5);
    line(x + 40, y - 5, x + 40, y + 5);
    noStroke();
    fill(0);
    textSize(12);
    textAlign(CENTER);
    text(title, x, y - 10);
    textAlign(LEFT);
    if (mouseX >= x - 40 && mouseX <= x + 40 && mouseY >= y - 5 && mouseY <= y + 5 && mousePressed) {
      a = mouseX;
      if (a < x - 40) {
        a = x - 40;
      }
      if (a > x + 40) {
        a = x + 40;
      }
    }
    fill(150, 150, 150);
    ellipse(a, y + 1, 10, 10);
    return a;
  }
}

class Descriptions {  //  Esta clase muestra las descripciones cuando el usuario pasa el cursor sobre la caja "Proyectiles" 

  SpecialText t;

  Descriptions() {
    fill(0);
    t = new SpecialText(14);
  }

  void projectilesDescription() {
    textSize(13);
    textAlign(LEFT);
    text("Observa la trayectoria de un proyectil", 400, 160);
    text("cuando se lanza en diferentes ángulos,", 400, 178);
    text("velocidades iniciales y alturas.", 400, 196);
    text("También puedes cambiar la altura ", 400, 214);
    text("de la plataforma de aterrizaje y exa-", 400, 232);
    text("mina el tiempo en el aire del proyectil,", 400, 250);
    text("la altura máxima y el desplazamiento.", 400, 268);
    t.createDivision("Supuestos", " ", 505, 340);
    t.createBullet("Sin resistencia al viento", 400, 360);
    t.createBullet("Fuerza aplicada al centro de masa", 400, 378);
    t.createBullet("Aceleración debido a la gravedad = -.1", 400, 396);
    t.createBullet("No se pierde energía por el calor.", 400, 414);
  }
}


class MainScreen {
  int tSize;
  int numBoxes;
  boolean[] clicked;
  boolean[] mouseIsHovering;
  String[] boxTitle = {
    "Proyectiles"
  };
  float scrn = 999;
  Descriptions d;

  MainScreen(int tSize) {
    this.tSize = tSize;
    numBoxes = boxTitle.length;
    clicked = new boolean[numBoxes];
    mouseIsHovering = new boolean[numBoxes];
    for (int i = 0; i < clicked.length; i++) {
      clicked[i] = false;
      mouseIsHovering[i] = false;
    }
    d = new Descriptions();
  }

  boolean menuBox(float x, float y, float w, float h, String label) {  //  method to draw each menu box
    boolean selected = false;
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY < y + h) {
      //Color del fondo de la descripción
      fill(250, 218, 94);
      noStroke();
      //Tamaño y ubicación del cuadro de la descripción
      rect(380, 130, 280, 450, 10);
      triangle(x + w, y + h/2, 381, y + h/2 - 22, 381, y + h/2 + 22);
      if (mousePressed == true) {
        selected = true;
      }
    } 
    else {
      noFill();
    }
    stroke(0);
    rect(x, y, w, h);
    textSize(24);
    fill(0);
    text(label, x + w/2, y + h/2 + 8);

    return selected;
  }
  boolean hovering(float x, float y, float w, float h) {  // Este método permite mostrar la descripción cuando se pase el cursor
    boolean hover;
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY < y + h) {
      hover = true;
    }  
    else {
      hover = false;
    }
    return hover;
  }

  void display() {
    textAlign(CENTER);
    textSize(30);
    //Título del menú
    text("Proyectiles", 340, 70);
    for (int i = 0; i < numBoxes; i++) {
      mouseIsHovering[i] = hovering(100, i*80 + 130, 250, 50);
      clicked[i] = menuBox(100, i*80 + 130, 250, 50, boxTitle[i]);
      if (clicked[i]) {
        scrn = i;
      }
    }
    if (mouseIsHovering[0]) {
      d.projectilesDescription();
    }
    
    textAlign(CENTER);
    textSize(tSize);
    text("Autor: TrevPhil - Traducido por: Brayan Angarita", 330, 665);
    textAlign(LEFT);
  }
}

class Projectiles {

  float y;
  float angle;
  float landingY;
  float initialV;
  float cannonHeightScale = 540;
  float cannonAngleScale = 520;
  float landingYScale = 540;
  float initialVScale = 580;
  boolean impact = false;

  PVector accel = new PVector(0, .1);
  PVector velocity = new PVector(0, 0);
  PVector position = new PVector(0, 680);

  int time = 0;

  SpecialText t;

  Projectiles() {
    y = 480;
    t = new SpecialText(14);
  }

  void display() {
    if (impact == false) {  //  La pelota se mueve siempre que no haya impactado
      velocity.add(accel);
      position.add(velocity);
      time++;
    }

    fill(0);
    ellipse(position.x, position.y, 20, 20);

    fill(250, 218, 94);  //  Botón "Lanzar"
    noStroke();
    rect(22.5, 220, 65, 35, 10);
    rect(22.5, 170, 65, 35, 10);
    fill(0);
    textSize(14);
    text("Lanzar", 32, 242);
    text("Volver", 32, 192);
    if (mouseX >= 22.5 && mouseX <= 77.5 && mouseY >= 220 && mouseY <= 255 && mousePressed == true) {
      velocity.x = -cos(radians(angle-450))*initialV;
      velocity.y = -sin(radians(angle-450))*initialV;
      position.x = 50;
      position.y = y - 62.5;
      impact = false;
      time = 0;
    }
    if (mouseX >= 22.5 && mouseX <= 77.5 && mouseY >= 170 && mouseY <= 192 && mousePressed == true) {
      ms.scrn = 999;
    }

    beginShape();  //  Brazo derecho de soporte del canon
    vertex(100, y + 10);
    vertex(100, y - 70);
    vertex(60, y - 70);
    vertex(60, y - 55);
    vertex(85, y - 55);
    vertex(85, y + 10);
    endShape();

    cannonHeightScale = slider(cannonHeightScale, 540, 40, "Altura del cañón");  //  Desplazamiento de la altura del cañón
    cannonAngleScale = slider(cannonAngleScale, 540, 80, "Ángulo del cañón");    //  Desplazamiento del ángulo del cañón
    landingYScale = slider(landingYScale, 540, 110, "Altura de la plataforma");  //  Desplazamiento de la altura de la plataforma
    fill(0);
    t.createVectorWithSubscript("v", "i", 504, 150);
    text(int(680-y+62.5), 590, 40);
    text(270-angle + "°", 590, 80);
    text(int(680-landingY), 590, 120);
    text(initialV, 590, 160);
    initialVScale = slider(initialVScale, 540, 160, "     Magnitud");
    // Esto sigue el formato: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
    y = 660 + ((cannonHeightScale + 40 - 540)/80)*(380 - 660);
    angle = 255 + ((cannonAngleScale + 40 - 540)/80)*(20 - 75);
    landingY = 660 + ((landingYScale + 40 - 540)/80)*(380 - 660);
    initialV = 3 + ((initialVScale + 40 - 540)/80)*(6.2 - 3);

    stroke(0);
    for (int pointX = 0; pointX < 630; pointX++) {
      float beforePointY = sin(radians(angle-450))*initialV*(pointX-1) + (-.1/2)*(pointX-1)*(pointX-1);  // Puntos usados para determinar la máxima altura
      float pointY = sin(radians(angle-450))*initialV*pointX + (-.1/2)*pointX*pointX;
      float afterPointY = sin(radians(angle-450))*initialV*(pointX+1) + (-.1/2)*(pointX+1)*(pointX+1);
      point(pointX*initialV*-cos(radians(angle-450)) + 50, y-62.5-pointY);
      if (pointY > beforePointY && pointY > afterPointY) {
        fill(0, 255, 0);
        ellipse(pointX*initialV*-cos(radians(angle-450)) + 50, y-62.5-pointY, 10, 10);
        textSize(14);
        fill(0);
        text(pointY+62.5+(680-y), 40+textWidth("Altura máx. =    =  (     sin Ө )^2  /  2    = "), 120);
      }
      fill(150, 150, 150);
    }

    pushMatrix();  //  Dibujar el cañón
    stroke(0);
    translate(50, y - 62.5);
    rotate(radians(angle));
    beginShape();
    vertex(-10, 15);
    vertex(10, 15);
    vertex(10, 20);
    vertex(-10, 20);
    vertex(-15, -40);
    bezierVertex(-10, -60, 10, -60, 15, -40);
    vertex(10, 20);
    endShape();
    noStroke();
    popMatrix();

    fill(0); //Color del texo
    rect(0, y, 100, 680 - y);  //  Dibuja la plataforma izquierda
    rect(0, 660, 680, 20);  //  Dibuja el rectángulo inferior
    rect(380, landingY, 300, 680 - landingY);  //  Dibuja la plataforma derecha

    //  collision tests
    if (position.x+10 >= 380 && position.y-5 >= landingY && position.y+10 <= 660) {  //  Si el lado derecho de la pelota golpea la pared
      impact = true;
      position.x = 370;
    }
    if (position.x-5 >= 380 && position.x <= 680 && position.y+10 >= landingY) {  //  Si la parte inferior de la pelota golpea la parte superior del aterrizaje
      impact = true;
      position.y = landingY-10;
    }
    if (position.y >= 660) {  //  si la parte inferior de la pelota golpea la base
      impact = true;
      position.y = 650;
    }

    beginShape();  //  Brazo de soporte del cañón izquierdo
    vertex(0, y + 10);
    vertex(0, y - 70);
    vertex(40, y - 70);
    vertex(40, y - 55);
    vertex(15, y - 55);
    vertex(15, y + 10);
    endShape();

    // Estadísticas de vuelo de la pelota
    textSize(14);  
    text("Desplazamiento = (    +  .5    Δt ) Δt =  ", 40, 40);
    t.createVectorWithSubscript("v", "i", 40+textWidth("Desplazamiento = ( "), 40);
    t.createVector("a", 40+textWidth("Desplazamiento = (    +  .5 "), 40);
    if (position.x > 50) {
      text(dist(position.x, position.y, 50, y - 62.5), 40+textWidth("Desplazamiento = (    +  .5    Δt ) Δt = "), 40);
    }  else  {
      time = 0;
    }
    text("Tiempo en el aire = ", 40, 80);
    text(time, 40+textWidth("Tiempo en el aire = "), 80);
    text("Altura máx. =    =  (     sin Ө )^2  /  2    =  ", 40, 120);
    t.createVectorWithSubscript("s", "y", 40+textWidth("Altura máx. = "), 120);
    t.createVectorWithSubscript("v", "i", 40+textWidth("Altura máx. =    =  ( "), 120);
    t.createVector("a", 40+textWidth("Max Height =    =  (     sin Ө )^2  /  2 "), 120);
  }

  //Crea escalas deslizantes donde 'a' es la ubicación del control deslizante
  float slider(float a, float x, float y, String title) {  
    stroke(0);
    line(x - 40, y, x + 40, y);
    line(x - 40, y - 5, x - 40, y + 5);
    line(x + 40, y - 5, x + 40, y + 5);
    noStroke();
    fill(0);
    textSize(12);
    textAlign(CENTER);
    text(title, x, y - 10);
    textAlign(LEFT);
    if (mouseX >= x - 40 && mouseX <= x + 40 && mouseY >= y - 5 && mouseY <= y + 5 && mousePressed) {
      a = mouseX;
      if (a < x - 40) {
        a = x - 40;
      }
      if (a > x + 40) {
        a = x + 40;
      }
    }
    fill(150, 150, 150);
    ellipse(a, y + 1, 10, 10);
    return a;
  }
}

// Clase para los vectores y subíndices
class SpecialText {  
  int tSize;

  SpecialText(int tSize) {
    this.tSize = tSize;
  }

  void createBullet(String writing, float x, float y) {
    fill(0);
    ellipse(x, y, 6, 6);
    text(writing, x + 11, y + 5);
  }

  void createSubscript(String bigLetter, String subscript, float x, float y) {
    text(bigLetter, x, y);
    float sw = textWidth(bigLetter);
    textFont (createFont("Palatino Linotype Italic", tSize - 5));
    text(subscript, x + sw, y + 5);
    textFont (createFont("Palatino Linotype", tSize));
  }

  void createDivision(String top, String bottom, float x, float y) {
    textAlign(CENTER);
    text(top, x, y - tSize);
    text(bottom, x, y + tSize);
    float topWidth = textWidth(top);
    float bottomWidth = textWidth(bottom);
    if (topWidth >= bottomWidth) {
      stroke(0);
      line (x - topWidth/2, y - 5, x + topWidth/2, y - 5);
      noStroke();
    } else {
      stroke(0);
      line (x - bottomWidth/2, y - 5, x + bottomWidth/2, y - 5);
      noStroke();
    }
    textAlign(LEFT);
  }

  void createVector(String vec, float x, float y) {
    text(vec, x, y);
    float vecWidth = textWidth(vec);
    stroke(0);
    line(x, y - tSize + 2, x + vecWidth, y - tSize + 2);
    line(x + vecWidth, y - tSize + 2, x + vecWidth - 2, y - tSize);
    noStroke();
  }
  
  void createVectorWithSubscript(String vec, String subscript, float x, float y)  {
    text(vec, x, y);
    float vecWidth = textWidth(vec);
    line(x, y - tSize + 2, x + vecWidth, y - tSize + 2);
    line(x + vecWidth, y - tSize + 2, x + vecWidth - 2, y - tSize);
    noStroke();
    textFont (createFont("Palatino Linotype Italic", tSize - 5));
    text(subscript, x + vecWidth, y + 5);
    textFont (createFont("Palatino Linotype", tSize));
  }
}

```
- - - - - - 
Video interesante: [Explicación del lanzamiento de proyectiles][2]

[2]: https://www.youtube.com/watch?v=1b_3rncl4fU
- - - - - -
### Contexto

Lanzamiento de proyectiles (movimiento parabólico):

Dividimos este tipo de movimientos en dos casos: lanzamiento horizontal y lanzamiento no horizontal. En esta lección empezamos estudiando el lanzamiento horizontal:

El lanzamiento horizontal consiste en lanzar un objeto horizontalmente desde cierta altura con cierta velocidad inicial. Se puede dividir en dos movimientos: uno horizontal rectilíneo uniforme, con velocidad constante igual a la velocidad inicial de lanzamiento, y uno vertical de caída libre desde la altura del lanzamiento con velocidad inicial cero. Tratándose de una fusión entre movimiento rectilíneo uniforme y movimiento rectilíneo uniformemente acelerado, usamos pues las ecuaciones ya definidas para estos dos tipos de movimiento, tratando cada uno por separado.

En el lanzamiento no horizontal, se lanza el proyectil con un ángulo de inclinación mayor que cero grados 0º y menor que noventa grados 90º por encima de la horizontal. El cuerpo describe entonces un movimiento parabólico en cuya primera mitad asciende y en la otra mitad desciende. Al igual que en el caso anterior, dividimos el movimiento en uno horizontal rectilíneo uniforme, con velocidad constante igual a la componente X de la velocidad inicial, y uno vertical de caída libre con velocidad inicial igual a la componente Y de la velocidad inicial de lanzamiento y altura inicial igual a la altura desde la que se hizo el lanzamiento. El movimiento vertical se divide a su vez en un ascenso y un descenso (caída), como en las dos últimas lecciones de la unidad anterior. Igualmente aquí, como se trata de una fusión entre movimiento rectilíneo uniforme y movimiento rectilíneo uniformemente acelerado, usamos las ecuaciones ya definidas para estos dos tipos de movimiento, tratando cada uno por separado.

Terminamos la lección introduciendo la ecuación de la trayectoria para el movimiento parabólico, que relaciona los dos movimientos, el horizontal rectilíneo uniforme y el vertical de caída libre, y en la que no interviene el tiempo.

Fuente: [TareasPlus][1]

[1]: https://www.tareasplus.com/Cinematica/Lanzamiento-de-proyectiles-movimiento-parabolico/Cristian-Giraldo370

- - - - - -

Fecha de creación: 04/09/2019
Creado por: Brayan Angarita