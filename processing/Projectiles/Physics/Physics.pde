
int tSize = 18;

SpecialText t;

MainScreen ms;
Projectiles projectiles;
MyIncline myIncline;
ShowSprings showSprings;
MyPhysicsGravity g;
ShowSystem ss;
Point[] p = new Point[30];
Link link;

void setup() {
  textFont (createFont("Palatino Linotype", tSize));
  t = new SpecialText(tSize);
  noStroke();
  size(680, 680);

  ms = new MainScreen(tSize);
  projectiles = new Projectiles();
  myIncline = new MyIncline();
  showSprings = new ShowSprings();
  g = new MyPhysicsGravity();
  ss = new ShowSystem();

  for (int i = 0; i < p.length; i++) {
    p[i] = new Point();
  }
  link = new Link(p);
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
  if (ms.scrn == 1) {
    myIncline.display();
  }
  if (ms.scrn == 2) {
    showSprings.displayHorizontal();
    showSprings.displayVertical();
  }
  if (ms.scrn == 3) {
    link.display();
  }
  if (ms.scrn == 4) {
    g.display();
  }
  if (ms.scrn == 5) {
    ss.display();
  }
}

void mouseReleased() {  //  all mouseReleased events have to happen here - unless you use some Java stuff... :(
  if (showSprings.mouseIsDragging) {
    showSprings.mouseIsDragging = false;
  }
  if (showSprings.vmouseIsDragging) {
    showSprings.vmouseIsDragging = false;
  }
  if (ms.scrn == 4) {
    for (int i = 0; i < g.planetsList.size(); i++) {
      PlanetObject p = (PlanetObject) g.planetsList.get(i);
      p.isDragging = false;
      p.okToDrag = true;
    }
    g.okToChangePlanets = true;
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

  Point() {
  }

  void move(boolean pin) {
    if (pin == false) {
      velX = x - lastX;  //  this is where velocity is calculated with verlet integration
      velY = y - lastY;

      velX *= .97;
      velY *= .97;

      nextX = x + velX;
      nextY = y + velY;  //  add .1 to add gravity

      lastX = x;
      lastY = y;

      x = nextX;
      y = nextY;
    }  
    else {
      if (followMouse == false) {  //  the tether travels in a circle, normally
        circlePath();
        deltaTScale = slider(deltaTScale, 600, 40, "Orbit Speed");
        // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
        deltaT = .01 + ((deltaTScale + 40 - 600)/80)*(.2 - .01);
      }  
      else {
        x = mouseX;  //  ...or it follows the mouse
        y = mouseY;
      }
    }
  }

  void circlePath() {  //  create the circular path
    strokeWeight(1);
    stroke(0);
    ellipse(340, 340, 10, 10);
    noFill();
    ellipse(340, 340, 260, 260);
    t += deltaT;
    x = cos(t)*130 + 340;
    y = sin(t)*130 + 340;
    if (t > 2*PI) {
      t = 0;
    }
  }

  float slider(float a, float x, float y, String title) {  //  creates sliding scales where 'a' is the location of the slider
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

class Link {
  float restingDistance = 2;  //  how far apart each link wants to be
  float[] diffX;
  float[] diffY;
  float[] distance;
  float[] difference;
  float[] translateX;
  float[] translateY;
  Point[] p;
  PVector velVector = new PVector(0, 0);
  PVector centripAccel = new PVector(0, 0);
  float deltaTheta;
  float omega;
  float prettyOmega;
  float mouseTimer = 0;
  SpecialText t;

  Link(Point[] point) {
    p = point;
    diffX = new float[p.length];
    diffY = new float[p.length];
    distance = new float[p.length];
    difference = new float[p.length];
    translateX = new float[p.length];
    translateY = new float[p.length];
    t = new SpecialText(14);
  }
  void solve() {
    for (int i = 0; i < p.length-1; i++) {
      // calculate the distance
      diffX[i] = p[i].x - p[i+1].x;
      diffY[i] = p[i].y - p[i+1].y;
      distance[i] = sqrt(diffX[i] * diffX[i] + diffY[i] * diffY[i]) ;

      // difference scalar
      difference[i] = (restingDistance - distance[i]) / distance[i];

      // translation for each Point. They'll be pushed 1/2 the required distance to match their resting distances.
      translateX[i] = diffX[i] * 0.5 * difference[i];
      translateY[i] = diffY[i] * 0.5 * difference[i];

      p[i].x += translateX[i];
      p[i].y += translateY[i];

      p[i+1].x -= translateX[i];
      p[i+1].y -= translateY[i];
    }
  }

  void display() {
    p[0].move(true);  //  pin = true for the first point only
    for (int i = 1; i < p.length; i++) {
      p[i].move(false);
    }
    solve();
    for (int i = 0; i < p.length-1; i++) {
      stroke(0);
      line(p[i].x, p[i].y, p[i+1].x, p[i+1].y);
      noStroke();
      fill(0);
      ellipse(p[i].x, p[i].y, 2, 2);
      ellipse(p[i+1].x, p[i+1].y, 2, 2);
    }
    noStroke();
    ellipse(p[p.length-1].x, p[p.length-1].y, 20, 20);

    PVector last = new PVector(p[p.length-1].lastX - width/2, p[p.length-1].lastY - height/2);  //  angle between last and next locations (from the screen's center)
    PVector next = new PVector(p[p.length-1].nextX - width/2, p[p.length-1].nextY - height/2);
    deltaTheta = PVector.angleBetween(last, next);
    omega = deltaTheta*frameRate;  //  angular velocity = rad/sec, frameRate is 60 loops per sec, so the angle changes by 60*theta radians per sec
    prettyOmega = int(omega/PI * 100);
    textSize(14);
    if (p[0].followMouse == false) {
      text("Angular velocity ω = " + prettyOmega/100 + "π radians/sec", 40, 120);
      float prettyCA = int(centripAccel.mag()*100)/100;
      text("Centripetal acceleration      =          = " + prettyCA, 40, 80);
      t.createVectorWithSubscript("a", "c", 192, 80);
      t.createDivision("v^2", "r", 237, 80);
      stroke(255, 0, 0);
      line (350, 60, 350, 100);
      line(350, 60, 345, 65);
      line(350, 60, 355, 65);
    }
    stroke(0, 255, 0);
    line (190, 20, 190, 60);
    line(190, 20, 185, 25);
    line(190, 20, 195, 25);
    float prettyV = int(velVector.mag()*100)/100;
    text("Velocity = " + prettyV, 40, 40);
    fill(200, 206, 250);
    noStroke();
    rect(500, 70, 170, 35, 10);
    rect(560, 120, 55, 35, 10);
    if (mouseX >= 560 && mouseX <= 615 && mouseY >= 120 && mouseY <=155 && mousePressed == true) {  //  BACK button
      ms.scrn = 999;
    }
    mouseTimer++;
    if (mouseX >= 500 && mouseX <= 670 && mouseY >= 70 && mouseY <= 105 && mousePressed == true) {  //  TOGGLE MOUSE CONTROL button
      if (p[0].followMouse == false && mouseTimer > 7) {
        p[0].followMouse = true;
        mouseTimer = 0;
      }  
      if (p[0].followMouse == true && mouseTimer > 7) {
        p[0].followMouse = false;
        mouseTimer = 0;
      }
    }
    fill(0);
    text("Toggle Mouse Control", 515, 92);
    text("Back", 560+textWidth("Back")/2, 142);


    pushMatrix();  //  draw the velocity vector
    translate(p[p.length-1].x, p[p.length-1].y);
    strokeWeight(2);
    stroke(0, 255, 0);
    velVector.x = p[p.length-1].nextX - p[p.length-1].lastX;  //  velocity angle is the secant between the last and next locations of the last Point
    velVector.y = p[p.length-1].nextY - p[p.length-1].lastY;
    velVector.normalize();
    velVector.mult(8*sqrt(p[p.length-1].velX*p[p.length-1].velX + p[p.length-1].velY*p[p.length-1].velY));
    line (0, 0, velVector.x, velVector.y);

    if (p[0].followMouse == false) {
      stroke(255, 0, 0);  //  centripetal acceleration magnitude = V^2 / r
      centripAccel.x = velVector.x;
      centripAccel.y = velVector.y;
      centripAccel.normalize();
      centripAccel.mult(velVector.mag()*velVector.mag() / dist(width/2, height/2, p[p.length-1].x, p[p.length-1].y));
      pushMatrix();
      rotate(PI/2);
      line (0, 0, centripAccel.x, centripAccel.y);
      popMatrix();

      pushMatrix();
      stroke(255, 0, 0);  //  the arrowhead for the centripetal acceleration vector
      rotate(PI/2);
      translate(centripAccel.x, centripAccel.y);
      centripAccel.div(8);
      rotate(3*PI/4);
      line (0, 0, centripAccel.x, centripAccel.y);
      rotate(PI/2);
      line (0, 0, centripAccel.x, centripAccel.y);
      popMatrix();
    }

    pushMatrix();
    stroke(0, 255, 0);  //  the arrowhead for the velocity vector
    translate(velVector.x, velVector.y);
    velVector.div(8);
    rotate(3*PI/4);
    line (0, 0, velVector.x, velVector.y);
    rotate(PI/2);
    line (0, 0, velVector.x, velVector.y);
    popMatrix();

    popMatrix();
    strokeWeight(1);
  }
}


class Descriptions {  //  this class simply provides the descriptions when you mouse over each menu box

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

  void inclineDescription() {
    textSize(14);
    textAlign(LEFT);
  }
  void springsDescription() {
    textSize(14);
    textAlign(LEFT);
  }
  void curvedDescription() {
    textSize(14);
    textAlign(LEFT);
  }
  void gravityDescription() {
    textSize(14);
    textAlign(LEFT);
    
  }
  void thermoDescription() {
    textSize(14);
    textAlign(LEFT);
    
  }
}


class MainScreen {
  int tSize;
  int numBoxes;
  boolean[] clicked;
  boolean[] mouseIsHovering;
  String[] boxTitle = {
    "Proyectiles", "Friction and Incline", "Springs", "Curved Motion", "Gravity", "Thermodynamics"
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
      fill(200, 206, 250);
      noStroke();
      rect(380, 130, 250, 450, 10);
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
  boolean hovering(float x, float y, float w, float h) {  //  method to show the descriptions if mouse over
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
    text("Physics", 340, 70);
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
    if (mouseIsHovering[1]) {
      d.inclineDescription();
    }
    if (mouseIsHovering[2]) {
      d.springsDescription();
    }
    if (mouseIsHovering[3]) {
      d.curvedDescription();
    }
    if (mouseIsHovering[4]) {
      d.gravityDescription();
    }
    if (mouseIsHovering[5]) {
      d.thermoDescription();
    }
    textAlign(CENTER);
    textSize(tSize);
    text("TrevPhil", 630, 665);
    textAlign(LEFT);
  }
}


class MyIncline {

  float iHeightScale = 340;
  float frictionScale = 340;
  float massScale = 380;
  float iHeight = 250;
  float inclineAngle = 0;
  float rotateAngle = 0;
  float x = 650;
  float y = 600;
  int timer = 0;

  float mass = 1700;

  float frictionLevel;
  float frictionLine;

  float grav = -.07*mass;  //  -.07 is the acceleration due to gravity
  PVector velocity = new PVector(0, 0);
  PVector position = new PVector(x, y);

  PVector gravPerp = new PVector(-sin(radians(36.3))*grav*cos(radians(36.3)), cos(radians(36.3))*grav*cos(radians(36.3)));
  PVector gravParallel = new PVector(cos(radians(36.3))*grav*sin(radians(36.3)), sin(radians(36.3))*grav*sin(radians(36.3)));
  PVector gravForce = new PVector(gravPerp.x + gravParallel.x, gravPerp.y + gravParallel.y);
  PVector normalForce = new PVector(gravPerp.x*-1, gravPerp.y*-1);
  PVector friction = new PVector(gravParallel.x*-1, gravParallel.y*-1);

  SpecialText t;

  MyIncline() {
    t = new SpecialText(14);
  } 

  void display() {
    iHeightScale = slider(iHeightScale, 340, 40, "Incline Height");  //  sliding scales and their relative values
    frictionScale = slider(frictionScale, 340, 80, "Friction");
    massScale = slider(massScale, 340, 120, "Mass of Block");

    velocity.x += gravForce.x/mass;  //  add acceleration
    velocity.y += gravForce.y/mass;
    position.add(velocity);

    inclineAngle = degrees(atan(iHeight/340));  //  find the angle of the incline
    gravPerp.x = -sin(radians(inclineAngle))*grav*cos(radians(inclineAngle));  //  readjust vectors when incline height changes
    gravPerp.y = cos(radians(inclineAngle))*grav*cos(radians(inclineAngle));
    normalForce.x = gravPerp.x*-1;  //  normal force counteracts the gravity component perpendicular to the incline
    normalForce.y = gravPerp.y*-1;
    gravParallel.x = cos(radians(inclineAngle))*grav*sin(radians(inclineAngle));
    gravParallel.y = sin(radians(inclineAngle))*grav*sin(radians(inclineAngle));
    friction.x = gravParallel.x*-1;
    friction.y = gravParallel.y*-1;
    friction.normalize();
    friction.mult(frictionLevel);
    if (friction.mag() > gravParallel.mag()) {  //  we don't want friction to move the block UP the ramp!
      friction.normalize();
      friction.mult(gravParallel.mag());
    }
    gravForce.x = gravPerp.x + gravParallel.x;  //  gravity is the sum of its perpendicular and parallel components to the incline
    gravForce.y = gravPerp.y + gravParallel.y;

    fill(200, 206, 250);  //  RESET button
    noStroke();
    rect(22.5, 220, 55, 35, 10);
    rect(22.5, 170, 55, 35, 10);
    if (mouseX >= 22.5 && mouseX <= 77.5 && mouseY >= 220 && mouseY <= 255 && mousePressed == true) {
      init();
    }
    if (mouseX >= 22.5 && mouseX <= 77.5 && mouseY >= 170 && mouseY <= 192 && mousePressed == true) {
      init();
      ms.scrn = 999;
    }
    fill(0);
    textSize(14);
    text("Reset", 34, 242);
    text("Back", 36, 192);
    text(int(iHeight), 390, 40);
    text(frictionLevel, 390, 80);
    text(int(mass), 390, 120);
    grav = -.07*mass;
    fill(0);
    stroke(0);
    text("Force of gravity     (where    = -.07)", 100, 300);
    t.createVectorWithSubscript("F", "g", 100+textWidth("Force of gravity "), 300);
    t.createVector("a", 100+textWidth("Force of gravity     (where "), 300);
    fill(255, 0, 0);
    stroke(255, 0, 0);
    text("Perpendicular component =     cos Ө", 100, 420);
    t.createVectorWithSubscript("F", "g", 100+textWidth("Perpendicular component = "), 420);
    fill(0, 0, 255);
    stroke(0, 0, 255);
    text("Parallel component =     sin Ө", 100, 460);
    t.createVectorWithSubscript("F", "g", 100+textWidth("Parallel component = "), 460);
    fill(150, 40, 180);
    text("Normal Force", 100, 500);
    fill(0, 255, 0);
    text("Force of Friction", 100, 540);
    fill(0);
    float prettyAngle = int(inclineAngle*100)/100;
    text("Incline Angle (Ө) = " + prettyAngle + "°", 100, 340);
    text("Ө", 153, 158);
    float prettyNum = int(100*friction.mag()/normalForce.mag())/100;
    text("Coefficient of friction μ =                                 = " + prettyNum, 100, 380);
    t.createDivision("|force of friction|", "|normal force|", 100+textWidth("Coefficient of static friction =          "), 380);
    pushMatrix();
    scale(1, -1);  //  sets coordinates to standard system (origin at bottom left)
    translate(0, -height);

    // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
    iHeight = 0 + ((iHeightScale + 40 - 340)/80)*(500 - 0);
    frictionLevel = 0 + ((frictionScale + 40 - 340)/80)*(60 - 0);
    frictionLine = frictionLevel/25;
    mass = 800 + ((massScale + 40 - 340)/80)*(1700 - 800);

    if (position.y < (iHeight/340)*(position.x-340)) {  //  if the block hits the incline
      if (timer < 1) {  //  resets vertical velocity to zero
        velocity.y = 0;
        timer++;
      }
      velocity.x += normalForce.x/mass;  //  add normal force if a collision occurs
      velocity.y += normalForce.y/mass;
      velocity.x += friction.x/mass;  //  add friction if a collision occurs
      velocity.y += friction.y/mass;

      if (rotateAngle < inclineAngle) {
        rotateAngle += 5;
      }
    }

    pushMatrix();  //  draw falling block
    translate(position.x, position.y);
    rotate(radians(rotateAngle));
    fill(0);
    rect(-50, 0, 50, 50);
    popMatrix();
    stroke(0);
    noFill();
    rect(x-50, 600, 50, 50);

    pushMatrix();  //  draw force of gravity vector and components
    translate(150, 550);
    line(0, 0, gravForce.x, gravForce.y);
    line(gravForce.x, gravForce.y, gravForce.x - 5, gravForce.y + 5);
    line(gravForce.x, gravForce.y, gravForce.x + 5, gravForce.y + 5);
    stroke(150, 40, 180);
    line(0, 0, normalForce.x, normalForce.y);
    stroke(255, 0, 0);
    line(0, 0, gravPerp.x, gravPerp.y);
    stroke(0, 0, 255);
    pushMatrix();
    translate(gravPerp.x, gravPerp.y);
    line(0, 0, gravParallel.x, gravParallel.y);
    stroke(0, 255, 0);
    line(0, 0, friction.x, friction.y);
    popMatrix();
    popMatrix();

    stroke(0);  //  draw incline
    fill(0);
    beginShape();
    vertex(340, 0);
    vertex(680, 0);
    vertex(680, iHeight);
    vertex(340, 0);
    endShape();
    for (int i = 0; i < sqrt(iHeight*iHeight + 340*340); i += 3) {
      float yBump = (iHeight/340)*(i - 340);
      line(680-i, -yBump, 680-i, -yBump+frictionLine);
    }

    popMatrix();
  }

  void init() {  //  reset to beginning conditions
    rotateAngle = 0;
    timer = 0;
    mass = 1700;
    grav = -.07*mass;
    velocity.x = 0;
    velocity.y = 0;
    position.x = x;
    position.y = y;
  }

  float slider(float a, float x, float y, String title) {  //  creates sliding scales where 'a' is the location of the slider
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


class MyPhysicsGravity {
  ArrayList planetsList;
  float redMassScale = 640;
  float blueMassScale = 560;
  float redMass;
  float blueMass;
  boolean okToChangePlanets = true;
  SpecialText t;

  MyPhysicsGravity() {
    planetsList = new ArrayList();
    planetsList.add(new PlanetObject(100, 340, 100, color(255, 0, 0)));
    planetsList.add(new PlanetObject(300, 500, 30, color(0, 0, 255)));
    t = new SpecialText(14);
  }

  void display() {
    redMassScale = slider (redMassScale, 600, 40, "Red Mass");  //  you can only control the mass of the red and blue planets
    blueMassScale = slider (blueMassScale, 600, 80, "Blue Mass");
    // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
    redMass = 30 + ((redMassScale + 40 - 600)/80)*(500 - 30);
    blueMass = 30 + ((blueMassScale + 40 - 600)/80)*(500 - 30);

    for (int i = 0; i < planetsList.size(); i++) {
      PlanetObject p = (PlanetObject) planetsList.get(i);
      p.display(planetsList);
      if (i == 0) {
        p.mass = redMass;
      }
      if (i == 1) {
        p.mass = blueMass;
      }
      p.r = p.mass/5;
      if (p.r < 20) {
        p.r = 20;
      }
    }

    fill(200, 206, 250);
    noStroke();
    rect(550, 120, 100, 35, 10);  //  buttons
    rect(540, 170, 120, 35, 10);
    rect(530, 220, 140, 35, 10);
    rect(572.5, 270, 55, 35, 10);
    if (mouseX >= 550 && mouseX <= 650 && mouseY >= 120 && mouseY <= 155 && mousePressed) {  //  ADD PLANET button
      if (okToChangePlanets) {
        planetsList.add(new PlanetObject(random(100, 500), random(100, 500), 160, color(random(255), random(255), random(255))));
        okToChangePlanets = false;
      }
    }
    if (mouseX >= 540 && mouseX <= 660 && mouseY >= 170 && mouseY <= 205 && mousePressed) {  //  REMOVE PLANET button
      if (okToChangePlanets && planetsList.size() > 2) {
        planetsList.remove(2);
        okToChangePlanets = false;
      }
    }
    if (mouseX >= 530 && mouseX <= 670 && mouseY >= 220 && mouseY <= 255 && mousePressed) {  //  RESET VELOCITIES button
      for (int i = 0; i < planetsList.size(); i++) {
        PlanetObject p = (PlanetObject) planetsList.get(i);
        p.velocity.mult(0);
      }
    }
    if (mouseX >= 572.5 && mouseX <= 627.5 && mouseY >= 270 && mouseY <= 305 && mousePressed) {  //  BACK button
       ms.scrn = 999;
    }
    fill(0);
    textSize(14);
    text("Add Planet", 564, 142);
    text("Remove Planet", 554, 192);
    text("Reset Velocities", 554, 242);
    text("Back", 585, 292);
    text("Drag a planet", 600-textWidth("Drag a planet")/2, 342);
    text("to move it", 600-textWidth("to move it")/2, 362);
    t.createVector("F", 40, 40);
    text("=", 60, 40);
    t.createDivision("mass 1 × mass 2", "distance^2", 130, 40);
    text(int(redMass), 530, 40);
    text(int(blueMass), 530, 80);
  }

  float slider(float a, float x, float y, String title) {  //  creates sliding scales where 'a' is the location of the slider
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

class PlanetObject {
  float G = 5;
  float mass;
  float r;
  boolean okToDrag = true;  //  this dragging stuff was a pain in the butt
  boolean isDragging = false;

  float force = 0;
  PVector accel = new PVector(0, 0);
  PVector velocity = new PVector(0, 0);
  PVector position = new PVector(0, 0);

  color c;

  PlanetObject(float initialX, float initialY, float mass, color c) {
    position.x = initialX;
    position.y = initialY;
    this.mass = mass;
    this.c = c;
  }

  void display(ArrayList planetsList) {    
    if (position.x >= width-r || position.x <= r) {  //  edge check
      velocity.x *= -1;
    }
    if (position.y >= height-r || position.y <= r) {
      velocity.y *= -1;
    }

    pushMatrix();
    translate(0, height);
    scale(1, -1);

    translate(position.x, position.y);
    fill(c);
    for (int i = 0; i < planetsList.size(); i++) {
      PlanetObject p = (PlanetObject) planetsList.get(i);
      if (p.isDragging && p != this) {
        okToDrag = false;
      }
    }
    if (dist(position.x, position.y, mouseX, 680-mouseY) <= r && mousePressed && okToDrag) {
      isDragging = true;
    }
    if (isDragging) {  //  planet follows mouse if it's being dragged
      fill(160);
      position.x = mouseX;
      position.y = 680-mouseY;
      velocity.mult(0);
    }
    ellipse(0, 0, 2*r, 2*r);
    popMatrix();

    float cumX = 0;  //  cumulative distances determine which overall direction a planet should move in
    float cumY = 0;
    float cumMass = 0;
    float cumDistance = 0;
    for (int i = 0; i < planetsList.size(); i++) {
      PlanetObject p = (PlanetObject) planetsList.get(i);
      if (p != this) {
        cumDistance += dist(position.x, position.y, p.position.x, p.position.y);
        cumX += p.position.x - position.x;
        cumY += p.position.y - position.y;
        cumMass += p.mass;
      }
    } 
    force = G * ( (mass * (cumMass/planetsList.size()) )/( (cumDistance/planetsList.size())*(cumDistance/planetsList.size()) ));  //  f = G * m1 * m2 / d^2
    accel.x = cumX;
    accel.y = cumY;
    accel.normalize();
    accel.mult(force/mass);
    for (int i = 0; i < planetsList.size(); i++) {
      PlanetObject p = (PlanetObject) planetsList.get(i);
      if (p != this) {
        if (dist(position.x, position.y, p.position.x, p.position.y) < (r + p.r)) {
          accel.mult(0);
        }
      }
    }
    velocity.add(accel);
    position.add(velocity);
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
    if (impact == false) {  //  the ball moves as long as it doesn't impact anything
      velocity.add(accel);
      position.add(velocity);
      time++;
    }

    fill(0);
    ellipse(position.x, position.y, 20, 20);

    fill(200, 206, 250);  //  FIRE button
    noStroke();
    rect(22.5, 220, 55, 35, 10);
    rect(22.5, 170, 55, 35, 10);
    fill(0);
    textSize(14);
    text("Fire", 39, 242);
    text("Back", 36, 192);
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

    beginShape();  //  right cannon support arm
    vertex(100, y + 10);
    vertex(100, y - 70);
    vertex(60, y - 70);
    vertex(60, y - 55);
    vertex(85, y - 55);
    vertex(85, y + 10);
    endShape();

    cannonHeightScale = slider(cannonHeightScale, 540, 40, "Cannon Height");  //  sliding scales and their relative values
    cannonAngleScale = slider(cannonAngleScale, 540, 80, "Cannon Angle");
    landingYScale = slider(landingYScale, 540, 120, "Platform Height");
    fill(0);
    t.createVectorWithSubscript("v", "i", 504, 150);
    text(int(680-y+62.5), 590, 40);
    text(270-angle + "°", 590, 80);
    text(int(680-landingY), 590, 120);
    text(initialV, 590, 160);
    initialVScale = slider(initialVScale, 540, 160, "     Magnitude");
    // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
    y = 660 + ((cannonHeightScale + 40 - 540)/80)*(380 - 660);
    angle = 255 + ((cannonAngleScale + 40 - 540)/80)*(20 - 75);
    landingY = 660 + ((landingYScale + 40 - 540)/80)*(380 - 660);
    initialV = 3 + ((initialVScale + 40 - 540)/80)*(6.2 - 3);

    stroke(0);
    for (int pointX = 0; pointX < 630; pointX++) {
      float beforePointY = sin(radians(angle-450))*initialV*(pointX-1) + (-.1/2)*(pointX-1)*(pointX-1);  //  points used to determine maximum height
      float pointY = sin(radians(angle-450))*initialV*pointX + (-.1/2)*pointX*pointX;
      float afterPointY = sin(radians(angle-450))*initialV*(pointX+1) + (-.1/2)*(pointX+1)*(pointX+1);
      point(pointX*initialV*-cos(radians(angle-450)) + 50, y-62.5-pointY);
      if (pointY > beforePointY && pointY > afterPointY) {
        fill(0, 255, 0);
        ellipse(pointX*initialV*-cos(radians(angle-450)) + 50, y-62.5-pointY, 10, 10);
        textSize(14);
        fill(0);
        text(pointY+62.5+(680-y), 40+textWidth("Max Height =    =  (     sin Ө )^2  /  2    = "), 120);
      }
      fill(150, 150, 150);
    }

    pushMatrix();  //  draw cannon
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

    fill(0);
    rect(0, y, 100, 680 - y);  //  draw the lefthand platform
    rect(0, 660, 680, 20);  //  draw the bottom rectangle
    rect(380, landingY, 300, 680 - landingY);  //  draw the righthand platform

    //  collision tests
    if (position.x+10 >= 380 && position.y-5 >= landingY && position.y+10 <= 660) {  //  if righthand side of ball hits wall
      impact = true;
      position.x = 370;
    }
    if (position.x-5 >= 380 && position.x <= 680 && position.y+10 >= landingY) {  //  if bottom of ball hits top of landing
      impact = true;
      position.y = landingY-10;
    }
    if (position.y >= 660) {  //  if bottom of ball hits base
      impact = true;
      position.y = 650;
    }

    beginShape();  //  left cannon support arm
    vertex(0, y + 10);
    vertex(0, y - 70);
    vertex(40, y - 70);
    vertex(40, y - 55);
    vertex(15, y - 55);
    vertex(15, y + 10);
    endShape();

    textSize(14);  //  ball's flight statistics
    text("Displacement = (    +  .5    Δt ) Δt =  ", 40, 40);
    t.createVectorWithSubscript("v", "i", 40+textWidth("Displacement = ( "), 40);
    t.createVector("a", 40+textWidth("Displacement = (    +  .5 "), 40);
    if (position.x > 50) {
      text(dist(position.x, position.y, 50, y - 62.5), 40+textWidth("Displacement = (    +  .5    Δt ) Δt = "), 40);
    }  else  {
      time = 0;
    }
    text("Air Time = ", 40, 80);
    text(time, 40+textWidth("Air Time = "), 80);
    text("Max Height =    =  (     sin Ө )^2  /  2    =  ", 40, 120);
    t.createVectorWithSubscript("s", "y", 40+textWidth("Max Height = "), 120);
    t.createVectorWithSubscript("v", "i", 40+textWidth("Max Height =    =  ( "), 120);
    t.createVector("a", 40+textWidth("Max Height =    =  (     sin Ө )^2  /  2 "), 120);
  }

  float slider(float a, float x, float y, String title) {  //  creates sliding scales where 'a' is the location of the slider
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


class ShowSprings {
  int numCoils = 10;  //  horizontal spring variables
  float kScale = 70;
  float restScale = 210;
  float massScale = 250;
  float w;
  float time = 0;
  float restPos = 50;
  float initialPos = 300;
  float A = abs(initialPos - restPos);
  float K = .7;
  float dampen = .99;
  float mass = 100;
  float displacement;
  float restorativeForce;
  boolean mouseIsDragging = false;

  float vh;  //  vertical spriing variables
  float vkScale = 400;
  float vrestScale = 400;
  float vmassScale = 380;
  float vtime = 0;
  float vacceleration = 2;
  float vmass = 100;
  float vdisplacement;
  float vrestorativeForce;
  float vrestPos = vmass*vacceleration;
  float vinitialPos = 250;
  float vA = abs(vinitialPos - vrestPos);
  float vK = .7;
  float vdampen = .99;
  boolean vmouseIsDragging = false;

  ShowSprings() {
  }

  void displayHorizontal() {   
    rectMode(CENTER); 
    kScale = slider(kScale, 70, 500, "k Value");  //  sliding scales and their relative values
    restScale = slider(restScale, 170, 500, "Rest Position");
    massScale = slider(massScale, 270, 500, "Mass of Block");
    // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
    K = .1 + ((kScale + 40 - 70)/80)*(.9 - .1);
    restPos = -100 + ((restScale + 40 - 170)/80)*(200 - -100);
    mass = 10 + ((massScale + 40 - 270)/80)*(500 - 10);
    fill(200, 206, 250);  //  BACK button
    noStroke();
    rect(50, 400, 55, 35, 10);
    fill(0);
    stroke(0);
    textAlign(CENTER);  //  screen text, equations, and real-time values
    text(K, 70, 470);
    text(int(restPos), 170, 470);
    text(int(mass), 270, 470);
    text("0", 340, 473);
    textAlign(CORNER);
    textSize(14);
    text("Displacement = A cos( √(k / mass) × time) = ", 30, 200);
    float prettyVD = int(vdisplacement*100)/100;
    text("(vertical spring) " + prettyVD, 30, 225);
    float prettyD = int(displacement*100)/100;
    text("(horizontal spring) " + prettyD, 30, 250);
    text("Restorative force = -k × displacement = ", 30, 290);
    float prettyVR = int(vrestorativeForce*100)/100;
    text("(vertical spring) " + -prettyVR, 30, 315);
    float prettyR = int(restorativeForce*100)/100;
    text("(horizontal spring) " + prettyR, 30, 340);
    text("Click and drag to move blocks", 40, 650);
    text("Back", 50-textWidth("Back")/2, 404);
    textSize(12);
    text("Given one-dimensional motion, assume", 40, 40);
    text("that positive values represent vector", 40, 65);
    text("directions to the right/downwards and", 40, 90);
    text("negative values to the left/upwards", 40, 115);
    if (mouseX >= 22.5 && mouseX <= 77.5 && mouseY >= 382.5 && mouseY <= 417.5 && mousePressed == true) {  //  BACK button
      ms.scrn = 999;
    }

    if (mouseIsDragging == false) {  //  the amplitude decreases when the user isn't dragging blocks
      time++;
      if (abs(A) < .1) {
        A = 0;
      } else {
        A *= dampen;
      }
      displacement = A*cos(sqrt(K/mass)*time);
      restorativeForce = -1 * K * displacement;
    }

    pushMatrix();
    translate(340, 580);
    rect(0, 10, 680, 20);
    line(0, 0, 0, -100);
    line(restPos, 60, restPos, -60);
    text("Rest Position", restPos-textWidth("Rest Position")/2, 75);
    rectMode(CORNER);
    w = displacement + restPos;
    noFill();
    for (int i = 0; i < numCoils; i++) {  //  draws the spring (for aesthetics only)
      bezier(i*(w/numCoils), -15, i*(w/numCoils)+5, -45, (i+1)*(w/numCoils)-5, -45, (i+1)*(w/numCoils), -15);
    }
    rectMode(CENTER);

    translate(restPos, 0);
    fill(0);
    if (mouseX >= displacement+restPos-25+340 && mouseX <= displacement+restPos+25+340 && mouseY >= -50+600 && mouseY <= 0+600 && mousePressed) {
      mouseIsDragging = true;
    }
    if (mouseIsDragging) {  //  when the user drags the blocks
      time = 0;
      displacement = mouseX - 340 - restPos;
      A = displacement;
    }
    rect(displacement, -25, 50, 50);  //  draw the block
    popMatrix();
  }

  void displayVertical() {  //  this is exactly the same as displayHorizontal() except inverted visually (x, y) -> (y, x)
    rectMode(CENTER);  
    vkScale = slider(vkScale, 400, 40, "k Value");  //  sliding scales and their relative values
    vrestScale = slider(vrestScale, 400, 80, "Rest Position");
    vmassScale = slider(vmassScale, 400, 120, "Mass of Block");
    // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound); (or does it?)
    vK = -.9 + ((vkScale + 40 - 480)/80)*(.1 - .9);
    vrestPos = 300 + ((vrestScale + 40 - 480)/80)*(550 - 300) - vmass/30;  //  the mass slightly affects the resting position (aesthetics only)
    vmass = -500 + ((vmassScale + 40 - 480)/80)*(10 - 500);
    fill(0);
    stroke(0);
    textAlign(CENTER);
    text(-vK, 335, 40);
    text(int(vrestPos), 335, 80);
    text(-int(vmass), 335, 120);
    textAlign(CORNER);

    if (vmouseIsDragging == false) {
      vtime++;
      if (abs(vA) < .1) {
        vA = 0;
      } else {
        vA *= vdampen;
      }
      vdisplacement = vA*cos(sqrt(vK/vmass)*vtime);
      vrestorativeForce = -1 * vK * vdisplacement;
    }

    line(490, vrestPos, 610, vrestPos);
    text("Rest", 620, vrestPos-10);
    text("Position", 620, vrestPos+10);
    rectMode(CORNER);
    vh = vdisplacement + vrestPos;
    noFill();
    for (int i = 0; i < numCoils; i++) {
      bezier(540, i*(vh/numCoils), 555, i*(vh/numCoils)+5, 585, (i+1)*(vh/numCoils)-5, 540, (i+1)*(vh/numCoils));
    }
    rectMode(CENTER);

    translate(0, vrestPos);
    fill(0);
    if (mouseY >= vdisplacement+vrestPos-25 && mouseY <= vdisplacement+vrestPos+25 && mouseX >= 550-25 && mouseX <= 550+25 && mousePressed) {
      vmouseIsDragging = true;
    }
    if (vmouseIsDragging) {
      vtime = 0;
      vdisplacement = mouseY - vrestPos;
      vA = vdisplacement;
    }
    rect(550, vdisplacement, 50, 50);
    rectMode(CORNER);
  }

  float slider(float a, float x, float y, String title) {  //  creates sliding scales where 'a' is the location of the slider
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


class SpecialText {  //  class for all those fancy vectors and subscripts
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


class ShowSystem {
  int col = 30;
  int row = 30;
  Particle[][] p = new Particle[col][row];

  int timer = 0;  //  variables to determine the system's state
  float avgKE;
  float avgPressure;
  float avgVelocity;
  float initialAvgKE;
  float initialMass;
  float lidHeight;
  float lidLength = 260;
  float r;
  float temp;
  float totalVelocity = 0;
  float velocityMag;
  float volume;

  SpecialText t;

  ShowSystem() {
    t = new SpecialText(14);
    for (int i = 0; i < col; i++) {
      for (int j = 0; j < row; j++) {
        p[i][j] = new Particle(random(130, 360), random(220, 580));
        totalVelocity += p[i][j].velocity.mag();
      }
    }
    avgVelocity = totalVelocity / (col*row);
    initialMass = (p[0][0].r*p[0][0].r*PI);
    avgKE = .5 * initialMass * avgVelocity * avgVelocity;  //  KE = 1/2 m v^2
    initialAvgKE = avgKE;
  }

  void display() {
    float totalParticleMomentum = 0;
    float lidPos = p[0][0].displayOtherFeatures(totalParticleMomentum);
    velocityMag = p[0][0].velocitySlider();
    r = p[0][0].rSlider();
    totalVelocity = 0;
    for (int i = 0; i < col; i++) {
      for (int j = 0; j < row; j++) {
        totalParticleMomentum += p[i][j].display(lidPos, velocityMag, r);
        totalVelocity += p[i][j].velocity.mag();
      }
    }
    lidPos = p[0][0].displayOtherFeatures(totalParticleMomentum);
    avgVelocity = totalVelocity / (col*row);
    timer++;
    if (timer > 50) {
      //  pressure = (mass * velocity^2)/volume * (numberOfParticles / 2)
      avgPressure = ((r*r*PI * avgVelocity*avgVelocity) / volume) * ((col*row) / 2);
      lidHeight = 580 - lidPos;
      volume = lidLength * lidHeight;
      //  temperature = PV / nR
      temp = (avgPressure * volume)/(col*row*8.31);
      avgKE = (r*r*PI * avgVelocity*avgVelocity) / 2;
      timer = 0;
    }

    fill(200, 206, 250);
    noStroke();
    rect(560, 560, 55, 35, 10);
    fill(0);
    t.createSubscript("P", "i", 440, 200);
    t.createSubscript("V", "i", 452, 200);
    t.createSubscript("P", "f", 480, 200);
    t.createSubscript("V", "f", 495, 200);
    text("       =         = nRT", 440, 200);
    float prettyPressure = int(avgPressure*100)/100;
    text("P = " + prettyPressure, 440, 230);
    text("V = " + int(volume), 440, 260);
    text("n = 900", 440, 290);
    text("R = 8.31 (arbitrary)", 440, 320);
    float prettyTemp = int(temp*100)/100;
    text("T = " + prettyTemp, 440, 350);
    float prettyPV = int(avgPressure*volume*100)/100;
    text("PV = " + prettyPV, 440, 380);
    text("internal energy U = 3/2 PV = " + int((3/2)*avgPressure*volume), 440, 410);
    text("average KE = 1/2 m v^2 = " + int(avgKE), 440, 440);
    text(velocityMag, 510, 80);
    text(r*r*PI, 510, 120);
    text("Back", 558+textWidth("Back")/2, 582);
    stroke(0);
    line(90, 200, 100, 200);
    line(90, 510, 100, 510);
    noStroke();
    text("max", 55, 204);
    text("min", 55, 514);

    if (mouseX >= 560 && mouseX <= 615 && mouseY >= 560 && mouseY <= 595 && mousePressed) {  //  BACK button
      ms.scrn = 999;
    }
  }
}

class Particle {
  float rScale = 632.727;
  float r;
  float velocityScale = 592.94118;
  float velocityMag;
  PVector velocity = new PVector(0, 0);
  float initialVx;
  float initialVy;
  PVector position = new PVector(0, 0);

  float lidMassScale = 580;
  float lidMass = 1000;
  float grav = .07;
  float lidForce;
  float lidAccel;
  float lidVelocity;
  float lidPos = 220;
  float lidMomentum;

  Particle(float x, float y) {
    velocity.x = random(-5, 5);
    initialVx = velocity.x;
    velocity.y = random(-5, 5);
    initialVy = velocity.y;
    position.x = x;
    position.y = y;
  } 

  float display(float lidTop, float vMag, float r) {
    velocity.x = initialVx * vMag;
    velocity.y = initialVy * vMag;
    this.r = r;
    float particleMomentum = 0;
    fill(0); 
    ellipse(position.x, position.y, r, r); 
    position.add(velocity);
    if (position.x-r < 120) {
      position.x = r+120;
      velocity.x *= -1;
      initialVx *= -1;
    }
    if (position.x+r > 380) {
      position.x = 380-r;
      velocity.x *= -1;
      initialVx *= -1;
    }
    if (position.y-r < lidTop-20) {
      position.y = r+lidTop-20;
      particleMomentum = (PI*r*r) * velocity.y;
      velocity.y *= -1;
      initialVy *= -1;
    }
    if (position.y+r > 580) {
      position.y = 580-r;
      velocity.y *= -1;
      initialVy *= -1;
    }
    return particleMomentum;
  }
  float displayOtherFeatures(float totalParticleMomentum) {
    lidForce = lidMass * grav;
    lidAccel = lidForce / lidMass;
    lidVelocity += lidAccel;
    lidMomentum = lidVelocity * lidMass;
    lidMomentum += totalParticleMomentum;
    lidVelocity = lidMomentum / lidMass;
    lidPos += lidVelocity;
    if (lidPos < 220) {
      lidPos = 220;
      lidVelocity = 0;
    }
    if (lidPos > 530) {
      lidPos = 530;
      lidVelocity = 0;
    }
    fill(0); 
    rect(100, 200, 20, 400);
    rect(100, 580, 300, 20);
    rect(380, 200, 20, 400);
    beginShape();
    vertex(120, lidPos-20);
    vertex(380, lidPos-20);
    vertex(350, lidPos-50);
    vertex(150, lidPos-50);
    vertex(120, lidPos-20);
    endShape();
    ellipse(250, lidPos-70, 50, 50);
    fill(255);
    ellipse(250, lidPos-70, 30, 30);

    lidMassScale = slider(lidMassScale, 600, 40, "Lid Mass");
    // this follows the format: lowerBound + ((whateverScale + 40 - x)/80)*(upperBound - lowerBound);
    lidMass = 1000 + ((lidMassScale + 40 - 600)/80)*(2000 - 1000);
    stroke(0);
    fill(0);
    textSize(14);
    text(int(lidMass), 515, 40);

    return lidPos;
  }

  float velocitySlider() {
    velocityScale = slider(velocityScale, 600, 80, "Velocity Scalar");
    velocityMag = .3 + ((velocityScale + 40 - 600)/80)*(2 - .3);
    stroke(0);
    return velocityMag;
  }
  float rSlider() {
    rScale = slider(rScale, 600, 120, "Particle Mass");
    r = .3 + ((rScale + 40 - 600)/80)*(2.5 - .3);
    stroke(0);
    return r;
  }

  float slider(float a, float x, float y, String title) {  //  creates sliding scales where 'a' is the location of the slider
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
