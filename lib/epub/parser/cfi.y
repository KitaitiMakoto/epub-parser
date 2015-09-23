# EPUB::Parser::CFI is prefered but cannot be used.
# Racc automatically declare module EPUB::Parser
# but EPUB::Parser have been declared as a class.
class EPUB::CFIParser
rule

  fragment : path range_zero_or_one
             {
               if val[1]
                 result = CFI::Range.from_parent_and_start_and_end(val[0], *val[1])
               else
                 result = CFI::Location.new(val[0])
               end
             }

  range_zero_or_one : range
                    |

  path : step local_path
           {
             path, redirected_path = *val[1]
             path.steps.unshift val[0]
             result = val[1]
           }

  range : COMMA local_path COMMA local_path
            {result = [val[1], val[3]]}

  local_path : step_zero_or_more redirected_path
                 {result = [CFI::Path.new(val[0])] + val[1]}
             | step_zero_or_more offset_zero_or_one
                 {result = [CFI::Path.new(val[0], val[1])]}

  step_zero_or_more : step_zero_or_more step
                        {result = val[0] + [val[1]]}
                    | step
                        {result = [val[0]]}
                    |
                        {result = []}

  redirected_path : EXCLAMATION_MARK offset
                      {result = [CFI::Path.new([], val[1])]}
                  | EXCLAMATION_MARK path
                      {result = val[1]}

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
         {result = CFI::TemporalSpatialOffset.new(nil, val[0][0].to_f, val[0][1].to_f, val[2])}
         | TILDE number spatial_offset_zero_or_one assertion_part_zero_or_one
             {
               x = val[2] ? val[2][0].to_f : nil
               y = val[2] ? val[2][1].to_f : nil
               result = CFI::TemporalSpatialOffset.new(val[1].to_f, x, y, val[3])
             }

  spatial_offset_zero_or_one : spatial_offset
                             |

  spatial_offset : ATMARK number COLON number
                     {result = [val[1], val[3]]}

  assertion_part_zero_or_one : opening_square_bracket assertion closing_square_bracket
                                 {result = val[1]}
                             |

  number : DIGIT_NON_ZERO digit_zero_or_more fractional_portion_zero_or_one
             {result = val.join}
         | ZERO fractional_portion_zero_or_one
             {result = val.join}

  fractional_portion_zero_or_one : fractional_portion
                                 |

  fractional_portion : DOT digit_zero_or_more DIGIT_NON_ZERO
                         {result = val.join}
                     | DOT DIGIT_NON_ZERO
                         {result = val.join}

  integer : ZERO
          | DIGIT_NON_ZERO digit_zero_or_more
              {result = val.join}

  digit_zero_or_more : digit_zero_or_more digit
                         {result = val.join}
                     | digit
                     |

  assertion : value_csv_one_or_two parameter_zero_or_more
                {result = [val[0][0], val[0][1], val[1]]} # Cannot see id assertion or text location assertion when val[0]'s length is 1. It can be done by context.
            | COMMA value parameter_zero_or_more
                {result = [nil, val[1], val[2]]}
            | parameter parameter_zero_or_more
                {result = [nil, nil, val[0].merge(val[1])]} # Cannot see id assertion or text location assertion when val[0]'s length is 1. It can be done by context. In EPUBCFI 3.0.1 spec, only side-bias parameter is defined and we can say it's text location assertion of the assertion has parameters. But when the spec is extended and other parameter definitions added, we might become not able to say so.

  value_csv_one_or_two : value COMMA value
                           {result = [val[0], val[2]]}
                       | value
                           {result = [val[0]]}

  parameter_zero_or_more : parameter_zero_or_more parameter
                             {result = val[0].merge(val[1])}
                         | parameter
                             {result = val[0]}
                         |
                             {result = {}}

  parameter : SEMICOLON value_no_space EQUAL csv
                {result = {val[1] => val[3]}}

  csv : csv COMMA value
          {result = val[0] + [val[2]]}
      | value
          {result = [val[0]]}

  value : string_escaped_special_chars
            {result = val[0]}

  value_no_space: string_escaped_special_chars_excluding_space

  escaped_special_chars : CIRCUMFLEX CIRCUMFLEX
                            {result = val[1]}
                        | CIRCUMFLEX square_brackets
                            {result = val[1]}
                        | CIRCUMFLEX parentheses
                            {result = val[1]}
                        | CIRCUMFLEX COMMA
                            {result = val[1]}
                        | CIRCUMFLEX SEMICOLON
                            {result = val[1]}
                        | CIRCUMFLEX EQUAL
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
        | DIGIT_NON_ZERO

  square_brackets : opening_square_bracket
                  | closing_square_bracket

  opening_square_bracket : OPENING_SQUARE_BRACKET

  closing_square_bracket : CLOSING_SQUARE_BRACKET

  parentheses : OPENING_PARENTHESIS
              | CLOSING_PARENTHESIS

  character_excluding_special_chars : character_excluding_special_chars_and_space
                                    | SPACE

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
