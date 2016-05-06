/*
This Mesh class holds the entire data structure for a mesh.
There are 3 pieces of data a mesh knows:
1. The vertices it has
2. The faces it has
2. what vertices make up of each face (part of triangelFace object)
*/

public class Mesh{
  ArrayList<Vertex> vertexList; //store all vertices this mesh has
  ArrayList<TriangleFace> faces = new ArrayList<TriangleFace>(); // faces
  
    Mesh(ArrayList<Vertex> vertices, ArrayList<TriangleFace> faces){
      this.vertexList                   = vertices;
      this.faces                        = faces;    
  }
}