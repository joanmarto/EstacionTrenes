with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;
with Ada.Text_IO;
use Ada.Text_IO;
with dcola;
with d_open_hash;
with dpila;
with davl;
with Ada.Strings.Hash;
with Ada.Containers;
use Ada.Containers;

package body dtrenes is

   function hash(k: in tcodigo; b: in positive) return Natural is
   begin
      return Natural(Ada.Strings.Hash(k) mod Hash_Type(b));
   end hash;
   
   
   function igual(k: in tcodigo; l: in tcodigo) return Boolean is
   begin
      return k = l;
   end igual;
   
   
   function menor(x1,x2: in integer) return boolean is
      
   begin
      
      return x1 < x2;
   end menor;
     
   
   function major(x1,x2: in integer) return boolean is
      
   begin
      return x1 > x2;
   end major;  
   
   
   procedure insertarloc(primero: in out plocomotora; x: in locomotora) is
      r: plocomotora;
      
   begin
      r:= new locomotora;
      r.codigoL:= (x.codigoL);
      primero := r;    
   end insertarloc;
   
   
   procedure borrarloc(primero: in out plocomotora) is
      
   begin
      primero:= null;
   end borrarloc;
   
   
   function cogerloc(primero: in out plocomotora) return locomotora is
      p: plocomotora;
      locom: locomotora;
   begin
      p := primero;
      locom := p.all;
      return locom;
   end cogerloc;
   
   
   procedure insertarvag(primero: in out pvagon; x: in vagon) is
      p,r: pvagon;
   begin
      p:= primero.sig;
      r:= new vagon; 
      r.all:= (x.peso,x.codigoV,null);
      if p = null then
         primero := r;
      else
         r.sig:= p;
         primero:= r;
      end if;
   end insertarvag;
   
   
   procedure borrarvag(primero: in out pvagon) is      
      p: pvagon;
   begin 
      if primero /= null then
         p:= primero.sig;
         primero.all.sig := null;
         primero := p;
      end if;
   end borrarvag;
   
   
   function cogerprimervag(primero: in out pvagon) return vagon is      
      p: pvagon;
      vago: vagon;
   begin 
      if primero /= null then
         p:= primero;
         vago := p.all;
         --return vago;
      end if;
     return vago;
   end cogerprimervag;

   
   procedure vacio (cia: out cTrenes) is
   begin
      colaL.cvacia(cia.locomotorasLibres);
      pilaV.pvacia(cia.vagonesLibres);
      davlT.cvacio(cia.trenes);
      dhashT.cvacio(cia.inventarioTrenes);
   end vacio;
   
   
   procedure aparcaLocomotora (cia: in out cTrenes; k: in tcodigo) is
      locomot: locomotora;
   begin
      locomot.codigoL := k;
      colaL.poner(cia.locomotorasLibres,locomot);
      exception
      when colaL.espacio_desbordado => raise aparcamiento_locomotoras_completo; 
   end aparcaLocomotora;
   
   
   procedure aparcaVagon (cia: in out cTrenes; k: in tcodigo; pmax: in integer) is
      vago: vagon;
   begin
      vago.peso := pmax;
      vago.codigoV := k;
      pilaV.empila(cia.vagonesLibres,vago);
   exception
      when pilaV.espacio_desbordado => raise aparcamiento_vagones_completo;
   end aparcaVagon;
   
   
   procedure creaTren (cia: in out cTrenes; t: out tcodigo; numvagones: in Integer) is
      trenesito: tren;
      punteroTren : ptren;
      locom: locomotora;
      --plocom :plocomotora;
      --codi: tcodigo;
      va: vagon;
      peso_total: Integer := 0;
      --list: lista;
   begin
      locom := coger_primero(cia.locomotorasLibres);
      colaL.borrar_primero(cia.locomotorasLibres);
      t := locom.codigoL;
      --Put_Line(locom.codigoL);
      t(1) := 'T';
      locom.codigoL := t;
      Put_Line(locom.codigoL);
      insertarloc(trenesito.loc, locom);
      trenesito.listavagones := new vagon;
      for i in 1..numvagones loop
         va := cima(cia.vagonesLibres);
         pilaV.desempila(cia.vagonesLibres);
         peso_total := peso_total + va.peso;
         Put(peso_total);
         insertarvag(trenesito.listavagones, va);
      end loop;
      -- Insertamos el peso total en el AVL
      punteroTren := new tren;
      punteroTren.all := trenesito;
      davlT.poner(cia.trenes, peso_total, punteroTren);
      
      -- Insertamos el código en el hasing
      dhashT.poner(cia.inventarioTrenes, t, punteroTren);
   exception
      when colaL.mal_uso => raise locomotoras_agotadas;
      when pilaV.mal_uso => raise vagones_agotadas;
      when dhashT.espacio_desbordado => raise inventario_trenes_completo;   
   end creaTren;
   
   
   procedure desmantelarTren(cia: in out cTrenes) is
      l: locomotora;
      v: vagon;
      tr: tren;
      codi: tcodigo;
      peso_total: Integer := 0;
   begin
      while tr.listavagones.sig /= null loop
         v := cogerprimervag(tr.listavagones.sig);
         peso_total := peso_total + v.peso;
         borrarvag(tr.listavagones.sig);
         empila(cia.vagonesLibres, v);  
      end loop;
      l := cogerloc(tr.loc);
      codi := l.codigoL;
      codi(1) := 'T';
      poner(cia.locomotorasLibres, l);
      -- Borramos el nodo del AVL
      borrar(cia.trenes, peso_total);
      
      -- Borramos el nodo del hash
      borrar(cia.inventarioTrenes, codi);
   exception
      when colaL.mal_uso => raise aparcamiento_locomotoras_completo;
      when pilaV.mal_uso => raise aparcamiento_vagones_completo;
      when dhashT.no_existe => raise tren_no_existe;
   end desmantelarTren;
   
   
   procedure listarTrenes(cia: in cTrenes) is
      it: iterator;
      clave: Integer;
      valor: ptren;
      l: plocomotora;
      vp: pvagon;
      v: vagon; 
      cl,ct: tcodigo;
   begin         
      first(cia.trenes,it);    
      while is_valid(it) loop   
         get(cia.trenes, it, clave, valor);
         --l:= new locomotora;
         l:= valor.all.loc;
         ct := valor.all.loc.all.codigoL;
         --ct:= l.all.codigoL;
         ct(1) := 'T';
         Put_Line(ct);
         New_Line;
         Put_Line("Peso_max tren: ");
         Put(clave);
         New_Line;
         cl := valor.all.loc.all.codigoL;
         Put_Line(cl);
         New_Line;
         vp := valor.listavagones;
         v := vp.all;
         while vp /= null loop
            Put_Line(v.codigoV);
            New_Line;
            Put(v.peso);
            v := vp.all;
            vp := vp.sig;    
         end loop;
         next(cia.trenes,it);       
      end loop;    
   end listarTrenes;
   
   
   procedure consultaTren(cia: in cTrenes; t: in tcodigo) is
      valor: ptren;
      --l: plocomotora;
      vp: pvagon;
      v: vagon; 
      --cl: tcodigo;
   begin
      dhashT.consultar(cia.inventarioTrenes,t,valor);
      --Put_Line(t);
      New_Line;
      --l:= new locomotora;
      --l := valor.all.loc;
      --l := valor.all.loc;
      --cl:= l.all.codigoL;
      --Put_Line(cl);
      New_Line;
      vp := new vagon;
      vp := valor.listavagones;
      --v := vp.all;
      while vp /= null loop --asi no peta pq no entra en el bucle
         v := vp.all;
         Put_Line(v.codigoV);
         New_Line;
         Put(v.peso);
         New_Line;
         vp := vp.sig;    
      end loop;
   exception
      when dhashT.no_existe => raise tren_no_existe;  
   end consultaTren;
   

end dtrenes;
