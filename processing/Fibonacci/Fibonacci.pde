

int F0 = 0;
int F1 = 1;
int T;
for( int i = 1; i <= 40; i++ ){
  println( "" + i + ": " + F1 );
  T = F0 + F1;
  F0 = F1;
  F1 = T;
}
