Mover mover;
Boids boid;
Predator predator;

int visual_range = 240;
int neighborhood = 100;
float fov = 90;

void setup() {
  size(1080, 720);
  spawnLifeforms();
  mover = new Mover();
  boid = new Boids();
  predator = new Predator();
}

Mover[] lifeformsArr = new Mover[200];
void draw() {

  background(255, 255, 255);


  for (int i = 0; i < lifeformsArr.length; i++) {

    lifeformsArr[i].update(i);

    lifeformsArr[i].display(i);
    
  }
  predator.update();
  predator.display();
}


float distance(Mover b1, Mover b2) {

  float dist = sqrt(sq(b1.location.x - b2.location.x) + sq(b1.location.y - b2.location.y));
  return dist;
}

float angle(Mover b1, Mover b2) {
  float ang = 0;
  float b1_ang;
  float b2_ang;
  PVector comparativeVec = new PVector(b2.location.x-b1.location.x, b2.location.y-b1.location.y);
  b1_ang = atan2(b1.velocity.y, b1.velocity.x);
  b2_ang = atan2(comparativeVec.y, comparativeVec.x);

  ang = b1_ang - b2_ang;

  if (ang > +PI)
    ang = ang - 2*PI;
  if (ang < -PI)
    ang = ang + 2*PI;
  ang = abs(ang);
  return ang;
}

void spawnLifeforms() {

  for (int i = 0; i < lifeformsArr.length; i++) {
    lifeformsArr[i] = new Mover();
  }
}

class Lifeform {
  int xpos;
  int ypos;
  int size;
  PVector movementVec;
  PVector pos;
  Lifeform(int tempxpos, int tempypos, String type)
  {
    xpos = tempxpos;
    ypos = tempypos;
    size = 5;
    color myCol;
    movementVec = PVector.random2D();
  }

  void shape() {
    color(0, 0, 0);
    fill(0);
    triangle(pos.x, pos.y, pos.x + size, pos.y - size, pos.x + 2*size, pos.y);
    // print(xpos + " ");
  }
  void movement() {
    pos.add(movementVec);
  }
};


class Mover {
  PVector location;
  PVector velocity;
  float ang;
  int size = 10;

  Mover() {

    location = new PVector(random(width), random(height));
    velocity = new PVector(random(-1, 1), random(-1, 1));
  }
  void update(int i) {
    
    float m1, m2, m3, m4;

    m1 = 1;
    m2 = 1;
    m3 = 1;
    m4 = 1;
    
    PVector v1 = new PVector(0, 0);
    PVector v2 = new PVector(0, 0);
    PVector v3 = new PVector(0, 0);
    PVector v4 = new PVector(0, 0);

    v1 = (boid.coherence(i)).mult(m1);
    v2 = (boid.spacing(i)).mult(m2);
    v3 = (boid.velMatch(i)).mult(m3);
    v4 = checkEdges();
    
    lifeformsArr[i].velocity.add(v1).add(v2).add(v3).add(v4);
    //lifeformsArr[i].velocity.rotate(boid.aligment(i));
    //  print(boid.aligment(i));
    limitVel(i);
    location.add(velocity);

    ang = atan2(velocity.x, velocity.y);
  }

  void limitVel(int lifeform_) {
    int lifeform = lifeform_;
    int velLim = 15;
    float magnitude;
    PVector magnitudeasd = new PVector(0, 0);
    magnitude = lifeformsArr[lifeform].velocity.mag();
    if (magnitude > velLim) {
      lifeformsArr[lifeform].velocity = (lifeformsArr[lifeform].velocity.div(magnitude).mult(velLim));
    }
  }
  void display(int i) {

    int trigSize = 10;
    
    float velocityAng = atan2(lifeformsArr[i].velocity.y, lifeformsArr[i].velocity.x);
    
    PVector trilength1 = PVector.fromAngle(velocityAng-radians(20));
    PVector trilength2 = PVector.fromAngle(velocityAng+radians(20));
    PVector trilength = PVector.fromAngle(velocityAng);
    
    trilength.setMag(trigSize);
    trilength1.setMag(trigSize);
    trilength2.setMag(trigSize);
    
    pushMatrix();
    
    stroke(0);
    fill(255, 0, 0);
    beginShape(TRIANGLES);
    vertex(location.x, location.y);
    vertex(location.x-trilength1.x, location.y-trilength1.y);
    vertex(location.x-trilength2.x, location.y-trilength2.y);
    endShape();
    
    popMatrix();
  }

  PVector checkEdges() {
    int margin = 150;
    int turnfactor = 1;
    PVector v = new PVector(0, 0);
    if (location.x > width - margin) {
      v.x -= turnfactor;
    } else if (location.x < margin) {
      v.x  += turnfactor;
    }
    if (location.y > height - margin) {
      v.y  -= turnfactor;
    } else if (location.y < margin) {
      v.y  += turnfactor;
    }

    return v;
  }
}

class Predator extends Mover {
  PVector location;
  PVector velocity;
  Predator() {
    location = new PVector(random(width), random(height));
    velocity = new PVector(random(-2, 2), random(-2, 2));
  }
  
  void update() {
    
    float m1, m2, m3, m4;

    m1 = 1;
    m2 = 1;
    m3 = 1;
    m4 = 1;
    
    PVector v1 = new PVector(0, 0);
    PVector v2 = new PVector(0, 0);
    PVector v3 = new PVector(0, 0);
    PVector v4 = new PVector(0, 0);



    v4 = checkEdges();
    
    v1 = (boid.seekPrey()).mult(m1);
    v2 = (boid.alignPrey()).mult(m2);
    predator.velocity.add(v1).add(v2).add(v4);

   // limitVel(i);
    location.add(velocity);

  //  ang = atan2(velocity.x, velocity.y);
  }
  
  void display() {
     int trigSize = 25;
    
    float velocityAng = atan2(predator.velocity.y, predator.velocity.x);
    
    PVector trilength1 = PVector.fromAngle(velocityAng-radians(20));
    PVector trilength2 = PVector.fromAngle(velocityAng+radians(20));
    PVector trilength = PVector.fromAngle(velocityAng);
    
    trilength.setMag(trigSize);
    trilength1.setMag(trigSize);
    trilength2.setMag(trigSize);
    
    pushMatrix();
    
    stroke(0);
    fill(0, 255, 0);
    beginShape(TRIANGLES);
    vertex(location.x, location.y);
    vertex(location.x-trilength1.x, location.y-trilength1.y);
    vertex(location.x-trilength2.x, location.y-trilength2.y);
    endShape();
    
    popMatrix();
    
  }
  
   PVector checkEdges() {
    int margin = 150;
    int turnfactor = 1;
    PVector v = new PVector(0, 0);
    if (location.x > width - margin) {
      v.x -= turnfactor;
    } else if (location.x < margin) {
      v.x  += turnfactor;
    }
    if (location.y > height - margin) {
      v.y  -= turnfactor;
    } else if (location.y < margin) {
      v.y  += turnfactor;
    }

    return v;
  }
  
  
};

class Boids {


  PVector coherence(int lifeform_) {
    int lifeform = lifeform_;
    PVector centerMass = new PVector(0, 0);
    int neighborNum = 0;
    float massHolder;
    float avgDirX = 0;
    float avgDirY = 0;
    PVector movementCorrection = new PVector(0, 0);
    for (int i = 0; i<lifeformsArr.length; i++) {
      // avgDirX += lifeformsArr[i].velocity.x;
      // avgDirX += lifeformsArr[i].velocity.y;
      if (i != lifeform 
        && distance(lifeformsArr[lifeform], lifeformsArr[i])< neighborhood
        && angle(lifeformsArr[lifeform], lifeformsArr[i]) < fov) {
        centerMass.add(lifeformsArr[i].location);  
        neighborNum++;
        //    print(degrees(angle(lifeformsArr[lifeform], lifeformsArr[i])) + " ");
      }
    }

    centerMass.div(neighborNum);

    movementCorrection = centerMass.sub(lifeformsArr[lifeform].location);
    movementCorrection.div(100);
   
    return movementCorrection;
  }

  PVector spacing(int lifeform_) {
    int lifeform = lifeform_;
    float magnitude = 0;
    PVector c = new PVector(0, 0);
    PVector tempmag = new PVector(0, 0);



    for (int i = 0; i < lifeformsArr.length; i++) {
      if (i != lifeform 
        && distance(lifeformsArr[lifeform], lifeformsArr[i]) < neighborhood
        && angle(lifeformsArr[lifeform], lifeformsArr[i]) < fov) {
        // print(lifeformsArr[i].location + " ");
        PVector tempVec1 = new PVector(0, 0);
        PVector tempVec2 = new PVector(0, 0);
        tempVec1.add(lifeformsArr[i].location);
        // print(lifeformsArr[i].location + "1");
        tempVec2.add(lifeformsArr[lifeform].location);
        //   print(tempVec2+ "1");
        tempmag = tempVec1.sub(tempVec2);

        magnitude = tempmag.mag();

        if ( magnitude  < 7.0 ) {
          // print(tempVec2+ "2");
          c.sub(tempmag);
          //print(magnitude + " ");
          // print(c + " ");
        }
      }
    }
    //  print(c + " ");
    return c;
  }

  PVector velMatch(int lifeform_) {
    int lifeform = lifeform_;

    PVector perVel = new PVector(0, 0);
    PVector velCorrector = new PVector(0, 0);
    PVector outVec = new PVector(0, 0);
    int neighborNum = 0;
    for (int i = 0; i < lifeformsArr.length; i++) {
      if (i != lifeform 
        && distance(lifeformsArr[lifeform], lifeformsArr[i]) < neighborhood
        && angle(lifeformsArr[lifeform], lifeformsArr[i]) < fov) {
        perVel.add(lifeformsArr[i].velocity);
        //  print(perVel + " ");
        neighborNum++;
      }
    }
    //print(perVel + "1");
    perVel.div(neighborNum);
    // print(perVel + "2");
    perVel.sub(lifeformsArr[lifeform].velocity);
    perVel.div(8);
    return perVel;
  }

  float aligment(int lifeform_) {

    int lifeform = lifeform_;
    PVector alignmentVec = new PVector(0, 0);
    float direction = 0;
    for (int i = 0; i < lifeformsArr.length; i++) {
      if (i != lifeform) {
        direction += (lifeformsArr[i].velocity.heading());
      }
      direction = direction / (lifeformsArr.length - 1);
    }



    return direction;
  }

  PVector seekPrey() {

    int neighborNum = 0;
    PVector preyDir = new PVector(0, 0);
    for (int i = 0; i < lifeformsArr.length; i++) {
      if(angle(predator, lifeformsArr[i]) < fov) {
      preyDir.add(lifeformsArr[i].location);
      neighborNum++;
      }
    }

    preyDir.div(neighborNum);
    preyDir.sub(predator.location);
    print(preyDir);
    preyDir.div(100);
    
    
    return preyDir;
  }
    PVector alignPrey() {
    

    PVector perVel = new PVector(0, 0);
    PVector velCorrector = new PVector(0, 0);
    PVector outVec = new PVector(0, 0);
    int neighborNum = 0;
    for (int i = 0; i < lifeformsArr.length; i++) {
      if (angle(predator, lifeformsArr[i]) < fov) {
        perVel.add(lifeformsArr[i].velocity);
        //  print(perVel + " ");
        neighborNum++;
      }
    }
    //print(perVel + "1");
    perVel.div(neighborNum);
    // print(perVel + "2");
    perVel.sub(predator.velocity);
    perVel.div(8);
    return perVel;
  
    
  }
}
