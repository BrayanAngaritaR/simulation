/*
  Autor: Brayan Angarita
  Fecha de creación: 04/09/2019
  Descripción: Este algoritmo calcula la sucesión Fibonacci hasta el número 40. 
  Este número puede ser modificado directamente en el código.
*/


int F0 = 0;
int F1 = 1;
int T;
for( int i = 1; i <= 40; i++ ){
  println( "" + i + ": " + F1 );
  T = F0 + F1;
  F0 = F1;
  F1 = T;
}
