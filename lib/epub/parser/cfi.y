# EPUB::Parser::CFI is prefered but cannot be used.
# Racc automatically declare module EPUB::Parser
# but EPUB::Parser have been declared as a class.
class EPUB::CFIParser
rule

  fragment : 'epubcfi' opening_parenthesis path range_zero_or_one closing_parenthesis
    {result = CFI.new(val[2], val[3])}

  range_zero_or_one : range
                    |

  path : step local_path
           {result = CFI::Path.new(val[0], val[1])}

  range : comma local_path comma local_path
            {result = CFI::Range.new(val[1], val[3])}

  local_path : step_zero_or_more redirected_path
                 {result = CFI::LocalPath.new(val[0], val[1], nil)}
             | step_zero_or_more offset_zero_or_one
                 {result = CFI::LocalPath.new(val[0], nil, val[1])}

  step_zero_or_more : step_zero_or_more step
                        {result = val[0] + [val[1]]}
                    | step
                        {result = [val[0]]}
                    |
                        {result = []}

  redirected_path : EXCLAMATION_MARK offset
                      {result = CFI::RedirectedPath.new(val[1], nil)}
                  | EXCLAMATION_MARK path
                      {result = CFI::RedirectedPath.new(nil, val[1])}

  step : SOLIDUS integer assertion_part_zero_or_one
           {
             assertion = val[2] ? CFI::IDAssertion.new(val[2][0], val[2][2]) : nil
             result = CFI::Step.new(val[1].to_i, assertion)
           }

  offset_zero_or_one : offset
                     |

  offset : COLON integer assertion_part_zero_or_one
             {
               assertion = val[2] ? CFI::TextLocationAssertion.new(*val[2]) : nil
               result = CFI::CharacterOffset.new(val[1].to_i, assertion)
             }
         | spatial_offset assertion_part_zero_or_one
             {result = CFI::SpatialOffset.new(val[0][0].to_f, val[0][1].to_f, nil, val[2])}
         | TILDE number spatial_offset_zero_or_one assertion_part_zero_or_one
             {
               result = CFI::SpatialOffset.new(nil, nil, val[1].to_f, val[3])
               if val[2]
                 result.x = val[2][0].to_f
                 result.y = val[2][1].to_f
               end
             }

  spatial_offset_zero_or_one : spatial_offset
                             |

  spatial_offset : ATMARK number COLON number
                     {result = [val[1], val[3]]}

  assertion_part_zero_or_one : opening_square_bracket assertion closing_square_bracket
                                 {result = val[1]}
                             |

  number : digit_non_zero digit_zero_or_more fractional_portion_zero_or_one
             {result = val.join}
         | zero fractional_portion_zero_or_one
             {result = val.join}

  fractional_portion_zero_or_one : fractional_portion
                                 |

  fractional_portion : DOT digit_zero_or_more digit_non_zero
                         {result = val.join}
                     | DOT digit_non_zero
                         {result = val.join}

  integer : zero
          | digit_non_zero digit_zero_or_more
              {result = val.join}

  digit_zero_or_more : digit_zero_or_more digit
                         {result = val.join}
                     | digit
                     |

  assertion : value_csv_one_or_two parameter_zero_or_more
                {result = [val[0][0], val[0][1], val[1]]} # Cannot see id assertion or text location assertion when val[0]'s length is 1. It can be done by context.
            | comma value parameter_zero_or_more
                {result = [nil, val[1], val[2]]}
            | parameter parameter_zero_or_more
                {result = [nil, nil, val[0].merge(val[1])]} # Cannot see id assertion or text location assertion when val[0]'s length is 1. It can be done by context. In EPUBCFI 3.0.1 spec, only side-bias parameter is defined and we can say it's text location assertion of the assertion has parameters. But when the spec is extended and other parameter definitions added, we might become not able to say so.

  value_csv_one_or_two : value comma value
                           {result = [val[0], val[2]]}
                       | value
                           {result = [val[0]]}

  parameter_zero_or_more : parameter_zero_or_more parameter
                             {result = val[0].merge(val[1])}
                         | parameter
                             {result = val[0]}
                         |
                             {result = {}}

  parameter : semicolon value_no_space equal csv
                {result = {val[1] => val[3]}}

  csv : csv comma value
          {result = val[0] + [val[2]]}
      | value
          {result = [val[0]]}

  value : string_escaped_special_chars
            {result = val[0]}

  value_no_space: string_escaped_special_chars_excluding_space

  escaped_special_chars : circumflex circumflex
                            {result = val[1]}
                        | circumflex square_brackets
                            {result = val[1]}
                        | circumflex parentheses
                            {result = val[1]}
                        | circumflex comma
                            {result = val[1]}
                        | circumflex semicolon
                            {result = val[1]}
                        | circumflex equal
                            {result = val[1]}

  character_escaped_special : character_excluding_special_chars
                            | escaped_special_chars

  string_escaped_special_chars : string_escaped_special_chars character_escaped_special
                                   {result = val.join}
                               | character_escaped_special
                                   {result = val[0]}

  string_escaped_special_chars_excluding_space : string_escaped_special_chars_excluding_space character_escaped_special_excluding_space
                                               | character_escaped_special_excluding_space

  character_escaped_special_excluding_space : character_excluding_special_chars_and_space
                                            | escaped_special_chars

  digit : ZERO
        | digit_non_zero

  digit_non_zero : DIGIT_NON_ZERO

  zero : ZERO

  space : SPACE

  circumflex : CIRCUMFLEX

  square_brackets : opening_square_bracket
                  | closing_square_bracket

  opening_square_bracket : OPENING_SQUARE_BRACKET

  closing_square_bracket : CLOSING_SQUARE_BRACKET

  parentheses : opening_parenthesis
              | closing_parenthesis

  opening_parenthesis : OPENING_PARENTHESIS

  closing_parenthesis : CLOSING_PARENTHESIS

  comma : COMMA

  semicolon : SEMICOLON

  equal : EQUAL

  character_excluding_special_chars : character_excluding_special_chars_and_space
                                    | space

  character_excluding_special_chars_and_space : character_excluding_special_chars_and_space_and_dot_and_colon_and_tilde_and_atmark_and_solidus_and_exclamation_mark
                                              | DOT
                                              | COLON
                                              | TILDE
                                              | ATMARK
                                              | SOLIDUS
                                              | EXCLAMATION_MARK

  character_excluding_special_chars_and_space_and_dot_and_colon_and_tilde_and_atmark_and_solidus_and_exclamation_mark : UNICODE_CHARACTER_EXCLUDING_SPECIAL_CHARS_AND_SPACE_AND_DOT_AND_COLON_AND_TILDE_AND_ATMARK_AND_SOLIDUS_AND_EXCLAMATION_MARK
                                              | digit

end
