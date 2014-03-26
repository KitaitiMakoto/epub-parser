{file:docs/Home.markdown} > **{file:docs/Navigation.markdown}**

Traversing
==========

Example to show tree of Table of Contents:

    nav = book.manifest.navs.first.content_document # => EPUB::ContentDocument::Navigation
    toc = nav.toc # => EPUB::ContentDocument::Navigation::Navigation
    toc_tree = ''
    toc.traverse do |item, depth|
      toc_tree << "#{' ' * depth * 2}#{item.text}\n"
    end
    puts toc_tree
    THE CONTENTS
      SECTION IV FAIRY STORIES—MODERN FANTASTIC TALES
        BIBLIOGRAPHY
        INTRODUCTORY
        Abram S. Isaacs
          190 A FOUR-LEAVED CLOVER
            
    												I. The Rabbi and the Diadem
    											
            
    												II. Friendship
    											
            
    												III. True Charity
    											
            
    												IV. An Eastern Garden
    											
        Samuel Taylor Coleridge
          191 THE LORD HELPETH MAN AND BEAST
        Hans Christian Andersen
          192 THE REAL PRINCESS
          193 THE EMPEROR'S NEW CLOTHES
          194 THE NIGHTINGALE
          195 THE FIR TREE
          196 THE TINDER-BOX
          197 THE HARDY TIN SOLDIER
          198 THE UGLY DUCKLING
        Frances Browne
          199 THE STORY OF FAIRYFOOT
        Oscar Wilde
          200 THE HAPPY PRINCE
        Raymond MacDonald Alden
          201 THE KNIGHTS OF THE SILVER SHIELD
        Jean Ingelow
          202 THE PRINCE'S DREAM
        Frank R. Stockton
          203 OLD PIPES AND THE DRYAD
        John Ruskin
          204 THE KING OF THE GOLDEN RIVER OR THE BLACK BROTHERS

**NOTE**: This API is not stable.

Bugs
====

* `hidden?` doesn't consider ancestors' `hidden?`
