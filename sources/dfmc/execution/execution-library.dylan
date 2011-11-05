module: dylan-user
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library dfmc-execution
  use functional-dylan;
  use variable-search;
  use system;
  use release-info;
  use dfmc-core;
  use dfmc-back-end;
  use dfmc-optimization;
  // Use the dfmc project-group
  use dfmc-management;

  // HACK: TEMPORARY
  // use dylan-script;
  use projects;

  use dfmc-typist;

  export dfmc-execution, dfmc-runtime-execution;
end library;

define module dfmc-execution
  use functional-dylan;
  use dfmc-core, export: { eval, &eval };
  use dfmc-imports;
  use dfmc-optimization;
  use dfmc-back-end;
  export 
    closure-offset, // !!! used by c-back-end
    closure-size    // !!! ditto
    // *** eval
    ;

end module;

define module dfmc-runtime-execution
  use functional-dylan;
  use dylan-internal;
  use dylan-extensions,
    exclude: { <ordered-object-set>, <ordered-object-table>, home-library },
    rename:  { namespace-name => library-name };
  use dylan-hygiene-glitches;
  use dylan-primitives;
  use operating-system;
  use release-info;
  use threads;
  use variable-search;
  use dfmc-core,
    exclude: { keyword-specifiers, xep, xep-setter, iep, 
	       <namespace>, <library>, <module> };
  use dfmc-imports;
  use dfmc-optimization;
  use dfmc-back-end;
  use dfmc-management, 
    export: { interpret-top-level-form, unregister-interpreter-transaction };
  use projects,
    exclude: { load-library };
  use dfmc-typist, import: { best-function-key? };

  export
    interpreter-transaction-value;
end module;
