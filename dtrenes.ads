with dcola;
with dpila;
with davl;
with d_open_hash;
with Ada.Containers;
generic
   numTrenes: Integer;
package dtrenes is
   
    type cTrenes is limited private;
   --type tcodigo is array (1..8) of Character;
   subtype tcodigo is String (1..8);
   --type key is limited private;
   
   aparcamiento_locomotoras_completo: exception;
   aparcamiento_vagones_completo: exception;
   locomotoras_agotadas: exception;
   vagones_agotadas: exception;
   inventario_trenes_completo: exception;
   tren_no_existe: exception;
   
   procedure vacio (cia: out cTrenes);
   procedure aparcaLocomotora(cia: in out cTrenes; k: in tcodigo);
   procedure aparcaVagon(cia: in out cTrenes; k: in tcodigo; pmax: in integer);
   procedure listarTrenes(cia: in cTrenes);
   procedure creaTren(cia: in out cTrenes; t: out tcodigo; numvagones: in Integer);
   procedure consultaTren(cia: in cTrenes; t: in tcodigo);
   procedure desmantelarTren(cia: in out cTrenes);
   function menor(x1,x2: in integer) return boolean;
   function major(x1,x2: in integer) return boolean;
   function hash(k: in tcodigo; b: in positive) return Natural;
   function igual(k: in tcodigo; l: in tcodigo) return Boolean;
   
private

   b: constant Ada.Containers.Hash_Type := Ada.Containers.Hash_Type(numTrenes);
   subtype hash_index is Ada.Containers.Hash_Type range 0..b;
   
   type vagon;
   type pvagon is access vagon;
   type vagon is record
      peso: Integer;
      codigoV: tcodigo;
      sig: pvagon;
   end record;
   
--     type lista is record
--        primero: pvagon;
--     end record;
   
   type locomotora;
   type plocomotora is access locomotora;
   type locomotora is record
      codigoL: tcodigo;
   end record;
   
   type tren;
   type ptren is access tren;
   type tren is record
      loc: plocomotora;
      listavagones: pvagon;
   end record;

   package davlT is new davl(key => integer , item => ptren, "<" => menor, ">" => major);
   use davlT;
   
   package colaL is new dcola(locomotora);
   use colaL;
   
   package pilaV is new dpila(vagon);
   use pilaV;
   
   
   package dhashT is new  d_open_hash(key => tcodigo, item => ptren, hash => hash,
                                     "=" => igual, size => numTrenes);
   use dhashT;
   
   
   type cTrenes is record
      locomotorasLibres: cola;
      vagonesLibres: pila;
      trenes: davlT.conjunto;
      inventarioTrenes: dhashT.conjunto;
   end record;


   

end dtrenes;
