module: dfmc-typist

define method find-lambda (c :: <computation>) => (l :: <&lambda>)
  c.environment.lambda;
end;

define method find-lambda (t :: <temporary>) => (l :: false-or(<&lambda>))
  (t.generator & t.generator.find-lambda) | (t.environment & t.environment.lambda);
end;

define method find-lambda (o :: <object>) => (l == #f)
  #f
end;

define macro with-environment
  { with-environment (?:name) ?body:* end }
   => {
    begin
      let l = ?name.find-lambda;
      let env = element($lambda-type-caches, l, default: #f);
      dynamic-bind(*type-environment* = env.head, *graph* = env.tail.head, *constraints* = env.tail.tail)
        ?body
      end;
    end;
   }
end;

define method type-estimate (o :: <object>) => (te :: type-union(<collection>, <&type>))
  block()
    with-environment(o)
      *constraints*.size > 0 & solve(*graph*, *constraints*, *type-environment*);
      let node = element(*type-environment*, o, default: #f);
      if (node)
        node.model-type;
      else 
        make(<&top-type>);
      end;
    end;
  exception (e :: <condition>)
    o.type-estimate-object
  end;
end;

define compiler-sideways method re-optimize-type-estimate (c :: <computation>) => ()
  unless (*inferring?*)
    with-environment (c)
      //retract-computation-types(c) //(as done in old typist)
      //solve, re-type users
    end;
  end;
end method;

define compiler-sideways method re-type-computations
    (first :: false-or(<computation>), last :: false-or(<computation>)) => ()
  unless (*inferring?*)
    let e = (first & first) | last;
    with-environment (e)
      walk-computations(infer-computation-types, first, last.next-computation);
      //solve(*graph*, *constraints*, *type-environment*);
    end;
  end;
end;

define compiler-sideways method re-type-temporary (old, new) => ()
  *type-environment*[new] := element(*type-environment*, old, default: #f);
end;


define constant guaranteed-disjoint? = ^known-disjoint?;
