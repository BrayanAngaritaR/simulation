### Sucesión Fibonacci en Processing
#### Este algoritmo calcula la sucesión Fibonacci hasta el número 40. Este número puede ser modificado directamente en el código.

- - - - - - 
#### Código
```
int F0 = 0;
int F1 = 1;
int T;
for( int i = 1; i <= 40; i++ ){
  println( "" + i + ": " + F1 );
  T = F0 + F1;
  F0 = F1;
  F1 = T;
}
```
- - - - - - 

- - - - - -
### Contexto

En matemáticas, la sucesión o serie de Fibonacci es la siguiente sucesión infinita de números naturales:

La espiral de Fibonacci: una aproximación de la espiral áurea generada dibujando arcos circulares conectando las esquinas opuestas de los cuadrados ajustados a los valores de la sucesión;1​ adosando sucesivamente cuadrados de lado 0, 1, 1, 2, 3, 5, 8, 13, 21 y 34.
La sucesión comienza con los números 0 y 1,2​ y a partir de estos, «cada término es la suma de los dos anteriores», es la relación de recurrencia que la define.

A los elementos de esta sucesión se les llama números de Fibonacci. Esta sucesión fue descrita en Europa por Leonardo de Pisa, matemático italiano del siglo XIII también conocido como Fibonacci. Tiene numerosas aplicaciones en ciencias de la computación, matemática y teoría de juegos. También aparece en configuraciones biológicas, como por ejemplo en las ramas de los árboles, en la disposición de las hojas en el tallo, en las flores de alcachofas y girasoles, en las inflorescencias del brécol romanesco, en la configuración de las piñas de las coníferas, en la reproducción de los conejos y en cómo el ADN codifica el crecimiento de formas orgánicas complejas. De igual manera, se encuentra en la estructura espiral del caparazón de algunos moluscos, como el nautilus.

Fuente: [Wikipedia][1]

[1]: https://es.wikipedia.org/wiki/Sucesión_de_Fibonacci

- - - - - -

Fecha de creación: 03/09/2019
Creado por: Brayan Angarita