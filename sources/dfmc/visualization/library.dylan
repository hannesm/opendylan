module: dylan-user
author: Hannes Mehnert
copyright: 2009, all rights reversed
synopsis: Dylan side of graphical visualization of DFM control flow graphs

define library dfmc-visualization
  use dylan;
  use common-dylan;
  use io;
  use network;
  use lisp-reader;

  use dfmc-core;
  use dfmc-management;
  use dfmc-optimization;
  use dfmc-typist;
  use dfmc-debug-back-end;
  use projects;
  use dfmc-environment-projects;

  export dfmc-visualization;
end;

define module dfmc-visualization
  use dylan;
  use common-dylan, exclude: { format-to-string };
  use threads, import: { dynamic-bind };
  use format;
  use streams;
  use standard-io;
  use print, import: { print-object };
  use sockets;
  use lisp-reader;

  use dfmc-core;
  use dfmc-management;
  use dfmc-optimization;
  use dfmc-typist;
  use dfmc-debug-back-end;
  use projects-implementation, import: { project-current-compilation-context };
  use dfmc-environment-projects; //for with-progress-reporting

  export <dfmc-graph-visualization>,
    report-enabled?, report-enabled?-setter,
    dfm-report-enabled?, dfm-report-enabled?-setter,
    dfm-index, dfm-index-setter,
    connect-to-server,
    read-from-visualizer,
    write-to-visualizer;

  export visualizing-compiler;
end;