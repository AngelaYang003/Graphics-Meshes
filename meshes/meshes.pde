/*
  CS3451 Spring 2016 
  Project 5 - Mesh and Dual
  Author: Angela Yang
  Date: 4/25/2016
*/

import processing.opengl.*;

float time = 0;  // keep track of passing of time (for automatic rotation)
boolean rotate_flag = true;       // automatic rotation of model?

Mesh currentMesh; //a mesh that stays in the memory for dual maker to work on
boolean polyhedraSelected = false;
boolean colorTheFaces = false;

//boolean smoothShade = false; //per face shading
boolean isFlatShaded = true; //per vertex shading
color[] randomColors;

// initialize stuff
void setup() {
  size(400, 400, OPENGL);  // must use OPENGL here !!!
  noStroke();     // do not draw the edges of polygons
}

// Draw the scene
void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1000.0);
  
  // place the camera in the scene (just like gluLookAt())
  camera (0.0, 0.0, 5.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
  
  scale (1.0, -1.0, 1.0);  // change to right-handed coordinate system
  
  // create an ambient light source
  ambientLight(102, 102, 102);
  
  // create two directional light sources
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, -0.7, -0.7, -1);
  directionalLight(152, 152, 152, 0, 0, -1);
  
  pushMatrix();

  fill(50, 50, 200);            // set polygon color to blue
  ambient (200, 200, 200);
  specular(0, 0, 0);
  shininess(1.0);
  
  rotate (time, 1.0, 0.0, 0.0);
  
  // THIS IS WHERE YOU SHOULD DRAW THE MESH
  
  if(polyhedraSelected){
    
    createNewMesh();
  
} else {
   
    beginShape();
    normal (0.0, 0.0, 1.0);
    vertex (-1.0, -1.0, 0.0);
    vertex ( 1.0, -1.0, 0.0);
    vertex ( 1.0,  1.0, 0.0);
    vertex (-1.0,  1.0, 0.0);
    endShape(CLOSE);
  
  }
  
  popMatrix();
 
  // maybe step forward in time (for object rotation)
  if (rotate_flag )
    time += 0.02;
}

// handle keyboard input
void keyPressed() {
  if (key == '1') {
    read_mesh ("tetra.ply");
    polyhedraSelected = true;
  }
  else if (key == '2') {
    read_mesh ("octa.ply");
    polyhedraSelected = true;
  }
  else if (key == '3') {
    read_mesh ("icos.ply");
    polyhedraSelected = true;
  }
  else if (key == '4') {
    read_mesh ("star.ply");
    polyhedraSelected = true;
  }
  else if (key == '5') {
    read_mesh ("torus.ply");
    polyhedraSelected = true;
  }
  else if (key == ' ') {
    rotate_flag = !rotate_flag;          // rotate the model?
  }
  else if (key == 'n' && polyhedraSelected) {
    //toggle per-vertex shading and per-face normal shading
    if(isFlatShaded == true){
      isFlatShaded = false;
    }
    else{
      isFlatShaded = true;
    }     
  }
  else if (key == 'r' && polyhedraSelected) {
    //randomly color faces
    colorTheFaces = true;
    int numOfFaces = currentMesh.faces.size();
    randomColors = generateRandomFaceColors(numOfFaces);
  }
  else if (key == 'w' && polyhedraSelected) {
    //color faces white
    colorTheFaces = false;
  }
  else if (key == 'd' && polyhedraSelected) {
    //calculate mesh dual
    makeDualMesh();         
  }
  else if (key == 'q' || key == 'Q') {
    exit();                               // quit the program
  }
  
}

// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.
void read_mesh (String filename)
{
  int i;
  String[] words;
  
  String lines[] = loadStrings(filename);
  
  words = split (lines[0], " ");
  int num_vertices = int(words[1]);
  println ("number of vertices = " + num_vertices);
  
  words = split (lines[1], " ");
  int num_faces = int(words[1]);
  println ("number of faces = " + num_faces);
  
  // read in the vertices store them in a list
  ArrayList<Vertex> vertexList = new ArrayList<Vertex>();
  for (i = 0; i < num_vertices; i++) {
    words = split (lines[i+2], " ");
    float x = float(words[0]);
    float y = float(words[1]);
    float z = float(words[2]);
    println ("vertex = " + x + " " + y + " " + z);
    vertexList.add(new Vertex(x,y,z));  
  }
  
  // read in the faces
  
  ArrayList<TriangleFace> faceList = new ArrayList<TriangleFace>();
  
  int[]  faces = new int[num_faces*3];
  
  for (i = 0; i < num_faces; i++) {
    
    int j = i + num_vertices + 2;
    words = split (lines[j], " ");
    
    int nverts = int(words[0]);
    if (nverts != 3) {
      println ("error: this face is not a triangle.");
      exit();
    }
    
    int index1 = int(words[1]);
    int index2 = int(words[2]);
    int index3 = int(words[3]);
    
    faces[3*i] = index1;
    faces[(3*i)+1] = index2;
    faces[(3*i)+2] = index3;
    println ("face = " + index1 + " " + index2 + " " + index3);
    
    TriangleFace newFace = new TriangleFace(index1, index2, index3);
    faceList.add(newFace);
  }
  
  // create the mesh object and put it in the memory for dual mesh method to work on
  currentMesh =  new Mesh(vertexList, faceList);
  //generate random face colors for later use
  randomColors = generateRandomFaceColors(faces.length);
}


/*
  This method creates a polyhedral mesh from the stored data structure
*/
void createNewMesh(){
  
  ArrayList<Vertex> vertexList = currentMesh.vertexList;
  ArrayList<TriangleFace> faces = currentMesh.faces;
  
  int faceCount = 0;
  for (TriangleFace face : faces) {
  
    Vertex v1 = vertexList.get(face.vertexIndice[0]);
    Vertex v2 = vertexList.get(face.vertexIndice[1]);
    Vertex v3 = vertexList.get(face.vertexIndice[2]);
    
    //2. calculate the normal for this triangle face
    PVector triangleFaceNormal = Triangle.calculateTriangleFaceNormal(v1, v2, v3);
    
    //3. set face to random colors or white
    fill(255); //default to white
    if (colorTheFaces) {
       fill(randomColors[faceCount]);
    }
    
    //4. create a triangle face
    beginShape(TRIANGLE);
    
       normal(triangleFaceNormal.x, triangleFaceNormal.y, triangleFaceNormal.z);
       
       if (isFlatShaded)
         normal(v1.x, v1.y, v1.z);
      
       //convert my Vertex object to Processing vertex
       vertex(v1.x, v1.y, v1.z);
      
       if (isFlatShaded) 
         normal(v2.x, v2.y, v2.z);
       
       vertex(v2.x, v2.y, v2.z);
     
       if (isFlatShaded) 
         normal(v3.x, v3.y, v3.z);
       
       vertex(v3.x, v3.y, v3.z);
     
    endShape(CLOSE);
   
    faceCount++;
  }
}



/*
  This method creates a triangle dual by the following steps
  step 1. Create first set of centroids from the mesh's triangle faces. 
  step 2. Create second set of centrois from the first set of centroids above by using
     the average of those centroids
     The avereage centroid is cacculated by using:
       - swing corners/opposite cornesr/next cornes/previous corners to get to the centroids on all faces that 
         a vertex is part of. 
     Add this second set of average centroids to new vertex list
  step 3. form new triangle faces from those new vertices 
*/

void makeDualMesh(){
  
    /* prepare data structures that will be used in the process */
  
    //get all vertices in current mesh
    ArrayList<Vertex> currentVertexList = currentMesh.vertexList;  
    
    //grab all faces from the current mesh
    ArrayList<TriangleFace> currentFaces = currentMesh.faces;
    //debugPrintVertexIndexList(currentFaces, "original");
    
    //a flat array that traces all vertex indices that form the faces
    int[] currentFaceVertexIndexList = Triangle.getVertexIndexListFromFaces(currentMesh.faces);
    //debugPrintVertexIndexList(currentFaceVertexIndexList, "vertex index list");
    
    //Arraylists for tracking new vertices and their triangle face indices 
    ArrayList<Vertex> centroidVertexList = new ArrayList<Vertex>(); 
    ArrayList<Integer> newFaceVertexIndexList = new ArrayList<Integer>();   
    
    //building the opposite corner list for getting to swing corners later
    int[] oppositeCorners = Triangle.figureOutOppositeCorners(currentFaceVertexIndexList);
    
    /* 
       step 1. Create first set of centroids from the mesh's triangle faces. 
          a. Loop thru each triangle face in the current mesh
          b. create a centroid vextex for each triangle face and add it to new centroid vertex list 
    */
    
    for (TriangleFace face : currentFaces) {
       
         Vertex v1 = currentVertexList.get(face.vertexIndice[0]);
         Vertex v2 = currentVertexList.get(face.vertexIndice[1]);
         Vertex v3 = currentVertexList.get(face.vertexIndice[2]);
         
         //Create a new vertex from the centroid of this triangle face and add it to collection
         Vertex centroidVertex = new Vertex((v1.x + v2.x + v3.x)/3,(v1.y + v2.y + v3.y)/3, (v1.z + v2.z + v3.z)/3);
         centroidVertexList.add(centroidVertex);
    }
    
    //debugPrintVertexList(centroidVertexList, "centroid");
    //println("new vextice size: " + centroidVertexList.size());
    
   
    /* 
       2. Create second set of centroids from the first set of centroids above by using
          average of centroids from each vertex. Those centroids are gathered by using swing corner
          method to go from one face to next for all faces a vertex is part of.
    */
    
    //loop thru each vertex to find average centroid from its connected faces
    int loopCount = 0;
    while(loopCount < currentVertexList.size()) {
      
        //This list holds vertex indices that are for each face/swing corner for a given vertex
        ArrayList<Integer> vertexIndiceForSwingCorners = new ArrayList<Integer>();
       
        /*
           pick a face as starting point then swinging around all faces for this vertx
           in tetra case: 
           vertex:  ( 1,2,3)(1,0,2)(3,2,0)(0,1,3)
           index :    0,1,2, 3,4,5, 6,7,8, 9,10,11
                      4,8, 9 point at the same vertex, 4 is the starting index, next faces should by 8, 9)
        */
        
        int startingIndex = Triangle.getStartingIndexForVertex(currentFaceVertexIndexList, loopCount);
         
        //add this starting index to the list and swing around to get other face indices for this vertex
        vertexIndiceForSwingCorners.add(startingIndex);
        
        //swing the corner to get to next face and get its index for the same vertex
        int nextSwingCornerVertexIndex = Triangle.swingCorner(oppositeCorners, startingIndex); 
        //println("nextSwingCornerVertexIndex : " + nextSwingCornerVertexIndex); //should be 8, then 9
        
        /* 
           Keep moving to next face and grab its vextex index. ( same vertex has different index on different face) 
           Use loop to get all faces that connect to this vertex and add those vertex indices to a list for calculating
           average 
        */
        while(nextSwingCornerVertexIndex != startingIndex){ 
          
           vertexIndiceForSwingCorners.add(nextSwingCornerVertexIndex);
           /* 
             The next face is found by using swing corner.
             Notes from class: A swing corner is figured out by using this formula 
             c.s = c.r.n = c.n.o.n
             (c.swing = c.right.next = c.next.opposite.next)
           */
           nextSwingCornerVertexIndex = Triangle.swingCorner(oppositeCorners, nextSwingCornerVertexIndex);
           //println("nextSwingCornerVertexIndex : " + nextSwingCornerVertexIndex);  //should be 9
        }
        
        //debugPrintCentroilList(vertexIndiceForSwingCorners, "indices from swing corners");
        
        /* 
           After gathering face centroids for this vertex, calculate a new centroid 
           that is the average of the face centroids for this vextex.
           This new centroid is going to be used to form the triangles with the first group
           of centroids to make sure all surfaces are triangle. This is required by this project.
           
        */
        
        //figure out the average from related centroids
        float averageVertexX = 0;
        float averageVertexY = 0;
        float averageVertexZ = 0;
        
        //An Arraylist to track the centriods that are used for creating the average centroid.
        //The arraylist will be used to form the triangle faces by using the centriods and the average centriod later
        ArrayList<Integer> centroidsForAverageCentroid = new ArrayList<Integer>();
        
        //add all related centroids for this vertex
        for(int k = 0; k < vertexIndiceForSwingCorners.size(); k++) {
            int indexOfVertex = vertexIndiceForSwingCorners.get(k);
            centroidsForAverageCentroid.add(indexOfVertex/3);
            Vertex currCentroid = centroidVertexList.get(indexOfVertex/3); 
   
            averageVertexX = averageVertexX + currCentroid.x;
            averageVertexY = averageVertexY + currCentroid.y;
            averageVertexZ = averageVertexZ + currCentroid.z;          
        }
        
        //figure out the average
        int numberOfCentroids = vertexIndiceForSwingCorners.size(); 
        averageVertexX = averageVertexX / numberOfCentroids;
        averageVertexY = averageVertexY / numberOfCentroids;
        averageVertexZ = averageVertexZ / numberOfCentroids;
        
        //create new centroid vertex from the average
        Vertex averageVertex = new Vertex(averageVertexX,averageVertexY,averageVertexZ);
        
        //add this average vertex to the centroid vertex list
        centroidVertexList.add(averageVertex);  //this one becomes the 5th, there are 4 original centroids
        
        /*
          form the triangle faces by using the centroids and the average centriod
          in tetra case: 
          the first average vertex is caluclated from the average of centroid 1, 3, 2 so it should form a triangles with 1,3,2
          (4,1,2) (4,2, 3), (4,1,3) (1,2,3) 
        */
        
        for(int ii = 0; ii < vertexIndiceForSwingCorners.size();  ii++) {
          //println("centroids for average :" + centroidsForAverageCentroid.get(ii));
          if ( ii == vertexIndiceForSwingCorners.size() - 1 ) {
              //last face is formed by ii-1, 0, and the average ceontroid
               newFaceVertexIndexList.add(centroidVertexList.size()-1);  //this the average centroid just created.
               newFaceVertexIndexList.add(centroidsForAverageCentroid.get(ii)); //one centroid contributed to the average centroid
               newFaceVertexIndexList.add(centroidsForAverageCentroid.get(0)); //anotehr centroid contributed to the avarge centroid
               //println("new face: " + (centroidVertexList.size() - 1) + " ," + centroidsForAverageCentroid.get(ii) + " ," + centroidsForAverageCentroid.get(0));
          } else {
              //the rest faces are formed by ii, ii + 1 and the average centroid
              newFaceVertexIndexList.add(centroidVertexList.size()-1);  //this the average centroid just created.
              newFaceVertexIndexList.add(centroidsForAverageCentroid.get(ii)); //one centroid contributed to the average centroid
              newFaceVertexIndexList.add(centroidsForAverageCentroid.get(ii+1)); //anotehr centroid contributed to the avarge centroid
              //println("new face: " + (centroidVertexList.size()-1) + " ," + centroidsForAverageCentroid.get(ii) + " ," + centroidsForAverageCentroid.get(ii+1));
          }
        }
        
        //debugPrintCentroilList(newFaceVertexIndexList, "newVertexIndexList");
        
        loopCount++;   
     }
     
     /* prepare to create new mesh */
     //set up new faces array
      ArrayList<TriangleFace> newFaceList = new ArrayList<TriangleFace>();
     for(int i = 0; i< newFaceVertexIndexList.size(); i = i + 3){
       TriangleFace newFace = new TriangleFace(newFaceVertexIndexList.get(i), 
                                               newFaceVertexIndexList.get(i+1), 
                                               newFaceVertexIndexList.get(i+2));
       newFaceList.add(newFace);
     }
     
     int newFaceNum = newFaceVertexIndexList.size()/3;
     int[] newFacesIndices = new int[newFaceVertexIndexList.size()];
     for(int i = 0; i< newFaceVertexIndexList.size(); i++){
        newFacesIndices[i] = newFaceVertexIndexList.get(i);
     }
      
     //Re-generate more random colors because the new mech has more triangle faces
     randomColors = generateRandomFaceColors(newFaceNum);
     
     /* create the new mesh with the new data structure */
     Mesh newMesh = new Mesh(centroidVertexList , newFaceList);
     currentMesh = newMesh; //replace the current mesh in memory with this new dual
  
} //end of makeDualMesh
  

/* must generate enough colors so one face gets one color */
color[] generateRandomFaceColors(int numOfFaces){
  //3 vertice form an triangle so number of faces = number of vertice / 3
  color[] tempColors = new color[numOfFaces];
  for(int num = 0; num < tempColors.length; num++){
    tempColors[num] = color(int(random(255)), int(random(255)), int(random(255)));
  }
  return tempColors;
}

/*  helper mehtodsfor debugging print*/
void debugPrintVertexList(ArrayList<Vertex> vertexList, String name) {
  for(int i = 0; i < vertexList.size(); i++) {
    println(name + ": " + vertexList.get(i).x + " " + vertexList.get(i).y + " " +  vertexList.get(i).z);
  }
}

void debugPrintCentroilList(ArrayList<Integer> centroidList, String name) {
  print(name + ": ");
  for(int i = 0; i < centroidList.size(); i++) {
    print(", " + centroidList.get(i));
  }
}

void debugPrintVertexIndexList(int[] vertexIndexList, String name) {
  print(name);
  for(int i = 0; i < vertexIndexList.length; i++) {
    print("," + vertexIndexList[i]);
  }
}
  
  

  