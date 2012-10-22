// This example is based on a subset of the Face94 data set from Math-Intersect-Programming
// The original data can be found here: http://code.google.com/p/math-intersect-programming/downloads/list
// M-I-P's blog post on the topic can be found here: http://jeremykun.wordpress.com/2011/07/27/eigenfaces/
// Download the P-Eigenface library for Processing here: https://code.google.com/p/p-eigenface/

import cern.colt.*;
import peigenface.*;
import java.lang.reflect.Field;

PEigenface face;

int imgW = 180;
int imgH = 200;

String[] testFilenames;
String[] trainingFilenames;

PImage[] trainingImages;
PImage[] eigenfaces;

PImage matchingImage;
String matchingImageFilename;
PImage testImage;
String testImageFilename;

int mostInfluentialEigenface;
PImage currentEigenface;


public void setup() {
  size(imgW*3, imgH + 54 * 3);

  // load all the sample face images for training
  java.io.File trainingFolder = new java.io.File(dataPath("faces94/samples"));
  trainingFilenames = trainingFolder.list();
  trainingImages = new PImage[trainingFilenames.length];

  for (int i = 0; i < trainingFilenames.length; i++) {
    println("faces94/samples/" + trainingFilenames[i]);
    trainingImages[i] = loadImage("faces94/samples/" + trainingFilenames[i]);
  }

  println(trainingImages.length + " training Images"); 

  // initialize our eigenface recognizer with the training images
  face = new PEigenface(this);
  face.initEigenfaces(trainingImages);

  // get our actual eigenface images
  // (these are the visual representation of what
  // is unique about each face relative to the others.)
  eigenfaces = getEigenfaces();

  // load up our test images
  java.io.File folder = new java.io.File(dataPath("faces94/tests"));
  testFilenames = folder.list();

  // test a new image
  testNewImage();
}
public void draw() {
  image(currentEigenface, 0, 0);

  image(testImage, imgW, 0);
  text("TEST:\n" + testImageFilename, imgW, imgH - 25);

  image(matchingImage, imgW * 2, 0);
  text("MATCH:\n" + matchingImageFilename, imgW * 2, imgH - 25);
  
  drawAllEigenfaces();
}

// draw the eigenfaces in a grid
// with a red rectangle around the
// one that makes up the principle component
// for the current test image
void drawAllEigenfaces() {
  int i = 0;
  int col = 0;
  int row = 0;
  while (i < eigenfaces.length) {
    image(eigenfaces[i], col*54, imgH + row*54, 54, 54);    

    if (i == mostInfluentialEigenface) {
      stroke(255, 0, 0);
      noFill();
      rect(col*54, imgH + row*54, 54, 54);
    }

    i++;
    col++;
    if (col > 9) {
      col = 0;
      row++;
    }
  }
}

void testNewImage() {
  // load a random image from the test folder
  int testImageNum = int(random(0, testFilenames.length-1));
  testImage = loadImage("faces94/tests/" + testFilenames[testImageNum]);
  testImageFilename = testFilenames[testImageNum];

  // find the matching image for our test image from the training images
  int resultImageNum = face.findMatchResult(testImage, trainingImages.length);
  matchingImage = trainingImages[resultImageNum];
  matchingImageFilename = trainingFilenames[resultImageNum];

  // measure the weights: how much did each eigenface
  // contribute to the current test image
  double[] weights = face.getWeights(face.getBrightnessArray(testImage), trainingImages.length);   

  // find the index of the one that contributed the most
  // (i.e. with the max weight)
  double maxWeight = -10000;
  for(int i = 0; i < weights.length; i++){
    if(weights[i] > maxWeight){
      mostInfluentialEigenface = i;
      maxWeight = weights[i];
    }
  }
  currentEigenface = eigenfaces[mostInfluentialEigenface];

}

void keyPressed() {
  testNewImage();
}

// This funciton gets the array of eigenface images 
// out of PEigenface. It is ugly because it uses some java
// magic to extract a non-public variable.
PImage[] getEigenfaces() {
  PImage[] result = new PImage[trainingImages.length];
  try {
    Class c = face.getClass();
    Field field = c.getDeclaredField("imagesEigen");
    field.setAccessible(true);
    result = (PImage[])field.get(face);
  } 
  catch(Exception e) {
    println(e.toString());
  }
  return result;
}

