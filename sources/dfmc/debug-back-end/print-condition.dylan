Module: dfmc-debug-back-end
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define method program-note-to-ppml(o :: <program-note>)  => (ppml :: <ppml>)
  local method print-condition
          (o :: <program-note>, subnote? :: <boolean>) => (ppml :: <ppml>)
    let loc = o.condition-source-location;
    let location = 
      if (loc)
        let start-offset = source-location-start-offset(loc);
        let start-line = source-offset-line(start-offset);
        let sr = source-location-source-record(loc);
        let (name, line-number) = source-line-location(sr, start-line);
	let name = name | "interaction";
        ppml-block(vector(
          ppml-string(" at "),
          ppml-string(name), ppml-string(":"), as(<ppml>, line-number)))
      else
        ppml-string("")
      end;
    let classification = condition-classification(o);
    let ctxt = condition-context-id(o);
    let context = 
      if (ctxt)
        ppml-block(vector(
          ppml-string(" in "), ppml-string(ctxt), ppml-string(": ")));
      else
        ppml-string(": ");
      end;

    let body = apply(format-to-ppml, o.condition-format-string,
                                     o.condition-format-arguments);
    let notes = 
      ppml-block(map(method (o) print-condition(o, #t) end,
                     o.subnotes), offset: 0, type: #"consistent");
    if (subnote?)
      ppml-block(vector(
        ppml-block(vector(ppml-string("* "), body), offset: 2),
        ppml-break(offset: if (empty?(o.subnotes)) 0 else 2 end),
        notes), offset: 0)
    else
      ppml-block(vector(
        classification, 
        location, 
        ppml-break(offset: 2, space: 0), 
        context,
        ppml-break(offset: 2, space: 0), 
        body,
        ppml-break(offset: if (empty?(o.subnotes)) 0 else 2 end),
        notes), offset: 0);
    end;
  end method print-condition;

  print-condition(o, #f);
end method program-note-to-ppml;

define method condition-classification (o :: <program-note>)
  ppml-string("Note");
end method;

define method condition-classification (o :: <program-error>)
  // gts,98apr06: temporary fix: ppml-string("Error");
  next-method();
end method;

define method condition-classification (o :: <program-warning>)
  ppml-string("Warning");
end method;

define method condition-classification (o :: <serious-program-warning>)
  ppml-string("Serious warning");
end method;

define compiler-sideways method print-object
    (condition :: <program-note>, stream :: <stream>) => ()
  ppml-print(program-note-to-ppml(condition),
             make(<ppml-printer>, margin: 100,
                  output-function:
                    method (s :: <string>) write(stream, s) end,
                  newline-function: method () write(stream, "\n") end));
  let loc = condition.condition-source-location;
  if (loc)
    print-source-record-source-location
      (source-location-source-record(loc), loc, stream);
  end;
end method print-object;

// TODO: Rearrange to avoid some of this code duplication

define compiler-sideways method print-object
    (condition :: <simple-warning>, stream :: <stream>) => ()
  let body = apply(format-to-ppml, condition.condition-format-string,
                                   condition.condition-format-arguments);
  let ppml-condition = ppml-block(vector(ppml-string("Warning: "),
                                         ppml-break(offset: 2, space: 0), 
                                         body), 
                                  offset: 0);
  ppml-print(ppml-condition,
             make(<ppml-printer>, margin: 100,
                  output-function:
                    method (s :: <string>) write(stream, s) end,
                  newline-function: method () write(stream, "\n") end));
end method print-object;


define compiler-sideways method print-object
    (condition :: <simple-error>, stream :: <stream>) => ()
  let body = apply(format-to-ppml, condition.condition-format-string,
                                   condition.condition-format-arguments);
  let ppml-condition = ppml-block(vector(ppml-string("Error: "),
                                         ppml-break(offset: 2, space: 0), 
                                         body), 
                                  offset: 0);
  ppml-print(ppml-condition,
             make(<ppml-printer>, margin: 100,
                  output-function:
                    method (s :: <string>) write(stream, s) end,
                  newline-function: method () write(stream, "\n") end));
end method print-object;


// Now some methods to help produce slightly neater ppml
// TODO: remove some of this junk when I found out how to retrieve reasonable
//       print names from some of these objects.

define compiler-sideways method as (class == <ppml>, o :: <class>) => (ppml :: <ppml>)
  ppml-string(as(<string>, o.debug-name))
end method;

define compiler-sideways method debug-name(class == <boolean>) "<boolean>" end;
define compiler-sideways method debug-name(class == <integer>) "<integer>" end;
define compiler-sideways method debug-name(class == <string>) "<string>" end;
define compiler-sideways method debug-name(class == <byte-string>) "<byte-string>" end;

define method panic-debug-name(o :: <object>) => (dn :: <string>)
  // Last-ditch attempt: just print it to a string.
  let str = make(<byte-string-stream>, direction: #"output");
  format(str, "%s", o);
  stream-contents(str)
end;

define compiler-sideways method as (class == <ppml>, o :: <&object>)
    => (ppml :: <ppml>)
  ppml-string(format-to-string("%=", o))
end method;

define compiler-sideways method ^function-name (o :: <&callable-object>)
  // let name = o.^debug-name;
  // name & mapped-model(as-lowercase(as(<string>, name)))
  as(<string>, debug-string(o))
end method;

define compiler-sideways method as (class == <ppml>, o :: <&generic-function>) 
    => (ppml :: <ppml>)
  let sig = model-signature(o);
  if (sig)
    ppml-block(vector(
      ppml-string(o.^function-name),
      ppml-break(),
      as(<ppml>, sig)))
  else
    ppml-string(o.^function-name)
  end;
end method;

define compiler-sideways method as (class == <ppml>, o :: <&method>) 
    => (ppml :: <ppml>)
  let ppml = make(<stretchy-vector>);
  add!(ppml, ppml-string("method"));
  if (o.named?)
    add!(ppml, ppml-break());
    add!(ppml, ppml-string(o.^function-name));
  end if;
  let sig = model-signature(o);
  if (sig)
    add!(ppml, ppml-break());
    add!(ppml, as(<ppml>, sig));
  end;
  ppml-block(ppml)
end method;

define compiler-sideways method as (class == <ppml>, o :: <&class>) => (ppml :: <ppml>)
  ppml-string(o.^debug-name)
end method;

define compiler-sideways method as(class == <ppml>, sig-spec :: <signature-spec>)
    => (ppml :: <ppml>)
  let avl = #();
  if (spec-argument-rest-variable-spec(sig-spec))
    avl := pair(ppml-block(vector(
                 ppml-string("#rest "),
                 as(<ppml>, spec-argument-rest-variable-spec(sig-spec)))), avl)
  end;
  if (spec-argument-next-variable-spec(sig-spec))
    avl := pair(ppml-block(vector(
                 ppml-string("#next "),
                 as(<ppml>, spec-argument-next-variable-spec(sig-spec)))), avl)
  end;

  let vvl 
    = if (spec-value-rest-variable-spec(sig-spec))
	list(ppml-block(vector(
              ppml-string("#rest "),
              as(<ppml>, spec-value-rest-variable-spec(sig-spec)))))
      else
	#()
      end if;

  ppml-block(vector(
    ppml-string("("), 
    ppml-separator-block(
      concatenate-as(<vector>, map(curry(as, <ppml>), 
                                   spec-argument-required-variable-specs(sig-spec))
                             , avl)),
    ppml-string(")"),
    ppml-string(" =>"), ppml-break(),
    ppml-string("("), 
    ppml-separator-block(
      concatenate-as(<vector>, map(curry(as, <ppml>), 
                                   spec-value-required-variable-specs(sig-spec))
                             , vvl)),
    ppml-string(")")))
end;

define compiler-sideways method as(class == <ppml>, var :: <variable-spec>)
    => (ppml :: <ppml>)
  if (spec-type-expression(var))
    ppml-block(vector(as(<ppml>, spec-variable-name(var)),
                      ppml-string(" :: "),
                      as(<ppml>, spec-type-expression(var))))
  else
    as(<ppml>, spec-variable-name(var))
  end
end;

define compiler-sideways method as(class == <ppml>, o :: <variable-name-fragment>)
    => (ppml :: <ppml>)
  ppml-string(as(<string>, fragment-identifier(o)))
end;

define compiler-sideways method as(class == <ppml>, frag :: <function-call-fragment>)
    => (ppml :: <ppml>)
  ppml-block(vector(
    as(<ppml>, fragment-function(frag)),
    ppml-string("("),
    ppml-separator-block(map(curry(as, <ppml>), fragment-arguments(frag))),
    ppml-string(")")))
end;

define compiler-sideways method as(class == <ppml>, frag :: <literal-constant-fragment>)
    => (ppml :: <ppml>)
  as(<ppml>, fragment-value(frag))
end;

define compiler-sideways method as(class == <ppml>, o :: <module-binding>) => (ppml :: <ppml>)
  ppml-browser-aware-object(o)
end;

// eof
