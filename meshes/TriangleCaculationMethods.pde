/*
This class provides several helper methods
that figure out the next corner, previous corner, swing corner, opposite corner and more.
They are all put here to make the main file cleaner and easier to read 
*/

public static class Triangle {
 
  /* 
    Helper methods that figure out the next and previous neighbor 
  */
  
  static int nextCorner(int cornerIndex){
    /*
       next is the CCW neighbor
       0's next is 1, 1's next is 2, 2's next is 0. The % operation helps figure out 
       next corner in the same triangle
    */
    int tempNext = (cornerIndex + 1) % 3;
    //this figure out the first corner's index of each triangle  
    int tempWhichTriangle = 3 * (cornerIndex/3);
    //add them together to get the real index number of the next corner
    int next = tempNext + tempWhichTriangle;
    return next;
  }

  //the previous corner is its next's corner's next
  static int previousCorner(int cornerIndex){
    int previous = nextCorner(nextCorner(cornerIndex));
    return previous;
  }
  
  /*
    A helper mehtod which figures out the swing corner
    
    Notes from class: A swing corner is figured out by using this formula 
           c.s = c.r.n = c.n.o.n
           (c.swing = c.right.next = c.next.opposite.next)
  */
  static int swingCorner( int[] oppositeCorners, int i){
    int nextCorner = nextCorner(i);
    int rightCorner = oppositeCorners[nextCorner];
    int swingCorner  = nextCorner(rightCorner);
    return swingCorner;
  }
  
 /*
   a helper method which figures out the opposite corner for each corner
 */
 static int[] figureOutOppositeCorners(int[] vertexIndexList){
   
     //make an empty array
     int[] tempOppositeCorners = new int[vertexIndexList.length];
   
     for(int a = 0; a< vertexIndexList.length; a++){
     
       for(int b = 0; b< vertexIndexList.length; b++){
        
         if(a != b){
          
           /*
            notes from class:
            if (a.n.v == b.p.v and a.p.v == b.n.v) then they are opposite
           */
           if((vertexIndexList[Triangle.nextCorner(a)] == vertexIndexList[Triangle.previousCorner(b)])
              && (vertexIndexList[Triangle.previousCorner(a)] == vertexIndexList[Triangle.nextCorner(b)])){
             tempOppositeCorners[a] = b;  //this ties two opposite corners
             tempOppositeCorners[b] = a;
           }
         }
       }
     }
     
     return tempOppositeCorners;
  }
  
  
  /* 
     Helper method which calculates a triangle's face normal.
     THe normal is used by per-face shading
  */
     
  static PVector calculateTriangleFaceNormal(Vertex v1, Vertex v2, Vertex v3){
    PVector V1 = new PVector((v2.x-v1.x),(v2.y-v1.y),(v2.z-v1.z));
    PVector V2 = new PVector((v3.x-v1.x),(v3.y-v1.y),(v3.z-v1.z));
    
    PVector N = V1.cross(V2);
    N.normalize();
    
    return N;
  }

  /*
    A help method which figures out the index of the first face of a vertex as a starting point
    for swing around to get to other faces
  */
  static int getStartingIndexForVertex( int [] vertexIndexListForTriangles, int count) {
         int firstIndex = 0;
         boolean notFound = true;
         int i = 0;
         while(notFound && i <  vertexIndexListForTriangles.length) {
            if(vertexIndexListForTriangles[i] == count){
               firstIndex = i;  // 4 is the first index for this vertex 
               notFound = false;
            }
            i++;
          }
          
          return firstIndex; 
  }


 
  /* this helper method puts face indices into a flat array for easy use looping */
  static int[] getVertexIndexListFromFaces(ArrayList<TriangleFace> faces) {
      int arraySize = faces.size() * 3;
      int[] vertexIndexList = new int[arraySize];
      int i = 0;
      for (TriangleFace face : faces) {
             //each face is made of 3 vertices
             vertexIndexList[i] = face.vertexIndice[0];
             i++;
             vertexIndexList[i] = face.vertexIndice[1];
             i++;
             vertexIndexList[i] = face.vertexIndice[2];
             i++;
      }
      return vertexIndexList;
  }
}