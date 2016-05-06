/*
  THis class represents a Vertex in a mesh.
  It holds the x, y, z coordinates for this vertex
*/
public class Vertex{
  public float x, y, z;
  PVector normal;
  
 Vertex(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
 }
}