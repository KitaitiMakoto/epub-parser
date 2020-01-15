{file:docs/Home} > **{file:docs/Epubinfo.markdown}**

`epubinfo` command-line tool
============================

`epubinfo` command-line tool shows metadata of specified epub file.

Usage
-----

    epubinfo path/to/book.epub

Example:

    % epubinfo ./linear-algebra.epub
    Title:              A First Course in Linear Algebra
    Identifiers:        code.google.com.epub-samples.linear-algebra
    Titles:             A First Course in Linear Algebra
    Languages:          en
    Contributors:
    Coverages:
    Creators:           Robert A. Beezer
    Dates:
    Descriptions:
    Formats:
    Publishers:
    Relations:
    Rights:             This work is shared with the public using the GNU Free Documentation License, Version 1.2., © 2004 by Robert A. Beezer.
    Sources:
    Subjects:
    Types:
    Modified:           2012-03-05T12:47:00Z
    Unique identifier:  code.google.com.epub-samples.linear-algebra
    Epub version:       3.0
    Navigations:        toc, landmarks

To see help:

    % epubinfo -h
    Show metadata of an EPUB file
    
    Usage: epubinfo [options] EPUBFILE
    
        -f, --format=FORMAT              format of output(line, json or yaml), defaults to line(for console)
            --words                      count words of content documents
            --chars                      count charactors of content documents
            --navigation[=TYPE]          show specified type of navigation(toc, page-list or landmarks)
                                         If TYPE is omitted, show all types of navigations.
                                         Can specify multiple times.
            --toc                        show table of contents navigation(in line format only)
            --page-list                  show page list navigation(in line format only)
            --landmarks                  show landmarks navigation(in line format only)

Output formats
--------------

`epubinfo` can output in three formats: line, JSON and YAML. You can specify format by `--format`(`-f`) command-line option

### JSON ###

    $ epubinfo --format=json ~/Documebts/Books/build_awesome_command_line_applications_in_ruby_fo.epub | jq .
    {
      "title": "Build Awesome Command-Line Applications in Ruby (for KITAITI MAKOTO)",
      "identifiers": "978-1-934356-91-3",
      "titles": "Build Awesome Command-Line Applications in Ruby (for KITAITI MAKOTO)",
      "languages": "en",
      "contributors": "",
      "coverages": "",
      "creators": "David Bryant Copeland",
      "dates": "",
      "descriptions": "",
      "formats": "",
      "publishers": "The Pragmatic Bookshelf, LLC (338304)",
      "relations": "",
      "rights": "Copyright © 2012 Pragmatic Programmers, LLC",
      "sources": "",
      "subjects": "Pragmatic Bookshelf",
      "types": "",
      "modified": "",
      "unique identifier": "978-1-934356-91-3",
      "epub version": "2.0"
    }

### YAML ###

    $ epubinfo --format=yaml ~/Documebts/Books/build_awesome_command_line_applications_in_ruby_fo.epub
    ---
    title: Build Awesome Command-Line Applications in Ruby (for KITAITI MAKOTO)
    :identifiers: 978-1-934356-91-3
    :titles: Build Awesome Command-Line Applications in Ruby (for KITAITI MAKOTO)
    :languages: en
    :contributors: ''
    :coverages: ''
    :creators: David Bryant Copeland
    :dates: ''
    :descriptions: ''
    :formats: ''
    :publishers: The Pragmatic Bookshelf, LLC (338304)
    :relations: ''
    :rights: Copyright © 2012 Pragmatic Programmers, LLC
    :sources: ''
    :subjects: Pragmatic Bookshelf
    :types: ''
    modified: ''
    unique identifier: 978-1-934356-91-3
    epub Version: '2.0'

Character and word count
------------------------

`epubinfo` can count characters and words(space perarated) in EPUB document. Pass `--chars` and `--words` options to the command.

Note that this makes process slower because it will read all the document.

    $ epubinfo --chars --words ~/Documebts/Books/build_awesome_command_line_applications_in_ruby_fo.epub
    Title:              Build Awesome Command-Line Applications in Ruby (for IKEDA TATSUNOBU)
    Identifiers:        978-1-934356-91-3
    Titles:             Build Awesome Command-Line Applications in Ruby (for IKEDA TATSUNOBU)
    Languages:          en
    Contributors:       
    Coverages:          
    Creators:           David Bryant Copeland
    Dates:              
    Descriptions:       
    Formats:            
    Publishers:         The Pragmatic Bookshelf, LLC (338304)
    Relations:          
    Rights:             Copyright © 2012 Pragmatic Programmers, LLC
    Sources:            
    Subjects:           Pragmatic Bookshelf
    Types:              
    Modified:           
    Unique identifier:  978-1-934356-91-3
    Epub version:       2.0
    Words:              65006
    Characters:         445924

Navigations
-----------

`epubinfo` can coutput navigations in EPUB document such as table of contents and landmarks. Pass `--navigation` option to the command. This option is available only in line format, for now.

    % epubinfo --navigation ./linear-algebra.epub
    (snip)
    === table of contents ===
    Table of Contents
      A First Course in Linear Algebra
      Copyright
      Author Biography
      Edition
      Publisher
      Table of Contents
      Dedication
      Chapter 1. Theorems
      Chapter 2. Notation
      Chapter 3. Diagrams
      Chapter 4. Examples
      Preface
      Acknowledgements
      Part I. Part C  Core
        Chapter 1. Chapter SLE  Systems of Linear Equations
          Section WILA  What is Linear Algebra?
          Section SSLE  Solving Systems of Linear Equations
          Section RREF  Reduced Row-Echelon Form
          Section HSE  Homogeneous Systems of Equations
          Section NM  Nonsingular Matrices
        Chapter 2. Chapter V  Vectors
          Section SS  Spanning Sets
          Section O  Orthogonality
        Chapter 3. Chapter M  Matrices
          Section MM  Matrix Multiplication
          Section MISLE  Matrix Inverses and Systems of Linear Equations
          Section MINM  Matrix Inverses and Nonsingular Matrices
          Section CRS  Column and Row Spaces
        Chapter 4. Chapter VS  Vector Spaces
        Chapter 5. Chapter D  Determinants
          Section PDM  Properties of Determinants of Matrices
        Chapter 6. Chapter E  Eigenvalues
          Section PEE  Properties of Eigenvalues and Eigenvectors
        Chapter 7. Chapter LT  Linear Transformations
          Section ILT  Injective Linear Transformations
          Section SLT  Surjective Linear Transformations
          Section IVLT  Invertible Linear Transformations
        Chapter 8. Chapter R  Representations
          Section CB  Change of Basis
          Section OD  Orthonormal Diagonalization
          Section NLT  Nilpotent Linear Transformations
          Section IS  Invariant Subspaces
          Section JCF  Jordan Canonical Form
        Chapter 9. Appendix CN  Computation Notes
          Section MMA  Mathematica
          Section TI86  Texas Instruments 86
          Section TI83  Texas Instruments 83
          Section SAGE  SAGE: Open Source Mathematics Software
        Chapter 10. Appendix P  Preliminaries
          Section CNO  Complex Number Operations
          Section SET  Sets
          Section PT  Proof Techniques
        Chapter 11. Appendix A  Archetypes
          Archetype A
          Archetype B
          Archetype C
          Archetype D
          Archetype E
          Archetype F
          Archetype G
          Archetype H
          Archetype I
          Archetype J
          Archetype K
          Archetype L
          Archetype M
          Archetype N
          Archetype O
          Archetype P
          Archetype Q
          Archetype R
          Archetype S
          Archetype T
          Archetype U
          Archetype V
          Archetype W
          Archetype X
        Chapter 12. Appendix GFDL  GNU Free Documentation License
      Part II. Part T  Topics
        Chapter 14. Section T  Trace
        Chapter 15. Section HP  Hadamard Product
        Chapter 16. Section VM  Vandermonde Matrix
        Chapter 17. Section PSM  Positive Semi-definite Matrices
        Chapter 18. Chapter MD  Matrix Decompositions
          Section ROD  Rank One Decomposition
          Section TD  Triangular Decomposition
          Section SVD  Singular Value Decomposition
          Section SR  Square Roots
          Section POD  Polar Decomposition
      Part III. Part A  Applications
        Chapter 19. Section CF  Curve Fitting
        Chapter 20. Section SAS  Sharing A Secret
        Chapter 21. Contributors
        Chapter 22. Definitions
    
    === page list ===
    (No page list)
    
    === landmarks ===
    (No heading)
      Part I. Part C  Core

If you need only one type of navigation, tell it to `navigation` option:

    % epubinfo --navigation=toc ./linear-algebra.epub

You can specify multiple typs by pass the option multiple times:

    % epubinfo --navigation=toc --navigation=landmarks ./linear-algebra.epub

Short cut options `--toc`, `--page-list` and `--landmarks` are also available. `--toc` is, for example, equivalent to `--navigation=toc`:

    % epubinfo --toc ./linear-algebra.epub
