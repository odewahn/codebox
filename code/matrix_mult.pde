// Create a 2x3 matrix
float[][] A = {
  {1.0, 0.0, 0.0},
  {1.0, 0.5, 1.0}
};

// Create a 3x2 matrix
float[][] B = {
  {2.0, 0.0 },
  {1.0, 3.0},
  {3.0, 0.5}
};

// Create a 2x2 matrix to hold the product
float[][] C = new float[2][2];  //result matrix

//This section performs the actual multiplication
for (int i=0; i < C.length; i++) { //Loop through each row in C
   for (int j=0; j < C[0].length; j++) {  //Loop through each col in C
      for (int k=0; k < B.length; k++) { 
         //The element C[i][j] is the sum of the products of the row in A * the col in C  
         C[i][j] += A[i][k] * B[k][j];  // that row in A * that col in B
      }
   }
}

//Print out the results
for (int i=0; i < C.length; i++) {
  for (int j=0; j < C[0].length; j++) {
     println("[" + i + "][" + j + "] = " + C[i][j]);
  }
}
