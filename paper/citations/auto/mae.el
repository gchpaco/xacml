(TeX-add-style-hook "mae"
 (function
  (lambda ()
    (LaTeX-add-bibliographies
     "mae")
    (LaTeX-add-environments
     "tablehere"
     "figurehere")
    (LaTeX-add-labels
     "fig:eraser"
     "fig:atomicfail"
     "fig:atomicsuccess"
     "fig:blockmoving"
     "fig:tree"
     "fig:invariants"
     "fig:bebop"
     "prog:f"
     "prog:h"
     "fig:tig"
     "fig:abstract"
     "fig:concrete")
    (TeX-run-style-hooks
     "amsmath"
     "splitbib"
     "epsfig"
     "times"
     "program"
     "multicol"
     "amsfonts"
     "latex2e"
     "art10"
     "article"))))

