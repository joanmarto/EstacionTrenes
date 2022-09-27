with dtrenes;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;
procedure Main is
   package dtrene is new dtrenes(numTrenes => 53);
   use dtrene;

   f_entrada: File_Type;
   x: cTrenes;
   y: tcodigo;
   z: integer;

begin
   null;
   vacio(x);
   Open(f_entrada, mode => In_File, name => "locomotoras.txt");
   while not End_Of_File(f_entrada) loop
      Get(f_entrada, y);
      aparcaLocomotora(x, y);
   end loop;
   Close(f_entrada);
   Open(f_entrada, mode => In_File, name => "vagones.txt");
   while not End_Of_File(f_entrada) loop
      Get(f_entrada, y);
      Get(f_entrada, z);
      aparcaVagon(x, y, z);
   end loop;
   creaTren(x, y , 2);
   --consultaTren(x,y);
   listarTrenes(x);
end Main;
