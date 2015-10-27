PROGRAM foo(input, output, error) ;
   // variable declaraions
   var a, b, c: integer;
   // a very long variable name 
   var d123456789d123456789d123456789d123456789d123456789d123456789d123456789d123456789d123456789d123456789: integer;  

   var d, e: array [ 1 .. 10 ] of integer; 
   var g, h: real;

   // multi-dimensional array
   var g: array [ 23 .. 57 ] of array [ 23 .. 57 ] of array [ 23 .. 57 ] of array [ 23 .. 57 ] of array [ 23 .. 57 ] of real; 
 
   var k: array [ 23 .. 57 ] of array [ 23 .. 57 ] of real; 

   begin
      a := a + 1;  // un-initialized variable
      k[25][26] := k[25][26] + 3;     // un-initialized variable
                                      // wrong element type
      k[25][20] := k[25][20] + 3.14  // un-initialized variable
   end.   // this is the end of the program
