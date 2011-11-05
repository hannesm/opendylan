module: dylan-user
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library dfmc-optimization
  use functional-dylan;
  use dfmc-core;
  use dfmc-reader;
  use dfmc-macro-expander;
  use dfmc-typist;
  use dfmc-conversion;
  use dfmc-back-end;
  export dfmc-optimization;
end library;

define module dfmc-optimization
  use functional-dylan;
  use dfmc-core;
  use dfmc-imports;
  use dfmc-reader;
  use dfmc-macro-expander;
  use dfmc-typist;
  use dfmc-conversion;
  use dfmc-back-end;
  export
    really-run-compilation-passes,
    <optimization-note>,

    // assignment.dylan
    eliminate-assignments,

    // constant-folding.dylan
    // constant?,

    // cse.dylan
    share-common-subexpressions,

    // dead.dylan
    delete-useless-computations,

    // entry-points.dylan
    analyze-calls,
    maybe-upgrade-call,

    // inlining.dylan
    *inlining?*,
    try-inlining,
    inline-call,

    // multiple-values.dylan
    single-value-propagation,

    // non-local-exit.dylan
    analyze-non-local-exits,

    // tail-call.dylan
    tail-position?,

    // for call statistics
    incf-static-dispatch-count,
    incf-dynamic-dispatch-count,

    *warn-about-bogus-upgrades*,
    *colorize-bogus-upgrades*,

    *profile-all-calls?*,
    *partial-dispatch?*,

    *trace-optimizations?*,
    *trace-optimizing-method*,
    *trace-optimizing-library*,
    *trace-optimizing-file*,
    *dump-dfm?*,
    *dump-dfm-method*,
    *dump-dfm-library*,
    *dump-dfm-file*,
    *call-upgrading?*;

  export
    best-function-key?,
    best-function-rest?,
    best-function-optionals?,
    best-function-all-keys?,
    best-function-number-keys,
    best-function-number-required;

  export <run-time-type-error>,
    <run-time-result-type-error>,
    <non-sequence-last-argument-in-apply>,
    <attempt-to-instantiate-abstract-class>,
    <ambiguous-copy-down-method>,
    <unknown-copy-down-method-domain>,
    <missing-copy-down-method>,
    <calling-inline-only-function-out-of-line>;
end module;
