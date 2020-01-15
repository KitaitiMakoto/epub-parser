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
