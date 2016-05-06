/*
  This class represents a triangle face that is used to make ployhedral mesh.
  It stores 3 indices of vertice that make of that face.
*/
public class TriangleFace {
  
  int[] vertexIndice = new int[3];
  
  TriangleFace(int v1Index, int v2Index, int v3Index) {
      vertexIndice[0] = v1Index;
      vertexIndice[1] = v2Index;
      vertexIndice[2] = v3Index;
  }
  
}