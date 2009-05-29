module: dfmc-typist

define thread variable *typist-visualize* :: false-or(<function>) = #f;

define function debug-types (key :: <symbol>, #rest args)
  *typist-visualize* & apply(*typist-visualize*, key, map(get-id, args))
end;

define method get-id (c :: <computation>)
  c.computation-id;
end;

define method get-id (l :: <&arrow-type>)
  #"arrow"
end;

define method get-id (l :: <&tuple-type>)
  #"tuple"
end;

define method get-id (l :: <&tuple-type-with-optionals>)
  #"tuple-rest"
end;

define method get-id (l :: <&limited-coll-type>)
  #"limited-collection"
end;

define method get-id (o :: <object-reference>)
  o.temporary-id;
end;

define method get-id (t :: <temporary>)
  t.temporary-id;
end;

define constant $tv-id-map :: <table> = make(<table>);

define method get-id (tv :: <&type-variable>)
  element($tv-id-map, tv, default: #f) |
    ($tv-id-map[tv] := next-computation-id());
end;

define method get-id (n :: <node>)
  n.node-id;
end;

define method get-id (s :: <string>)
  s
end;

define method get-id (i :: <integer>)
  i
end;

define method get-id (s :: <symbol>)
  s
end;

define method get-id (c :: <collection>)
  map(get-id, c)
end;

define method get-id (o :: <object>)
  format-to-string("%=", o);
end;
