# EPUB::Parser::CFI is prefered but cannot be used.
# Racc automatically declare module EPUB::Parser
# but EPUB::Parser have been declared as a class.
class EPUB::CFIParser
rule

  fragment : 'epubcfi' opening_parenthesis path range_zero_or_one closing_parenthesis

  range_zero_or_one : range
                    |

  path : step local_path

  range : comma local_path comma local_path

  local_path : step_zero_or_more redirected_path
             | step_zero_or_more offset_zero_or_one

  step_zero_or_more : step_zero_or_more step
                    | step
                    |

  redirected_path : EXCLAMATION_MARK offset
                  | EXCLAMATION_MARK path

  step : SOLIDUS integer assertion_part_zero_or_one

  offset_zero_or_one : offset
                     |

  offset : COLON integer assertion_part_zero_or_one
         | spatial_offset assertion_part_zero_or_one
         | TILDE number spatial_offset_zero_or_one assertion_part_zero_or_one

  spatial_offset_zero_or_one : spatial_offset
                             |

  spatial_offset : ATMARK number COLON number

  assertion_part_zero_or_one : opening_square_bracket assertion closing_square_bracket
                             |

  number : digit_non_zero digit_zero_or_more fractional_portion_zero_or_one
         | zero fractional_portion_zero_or_one

  fractional_portion_zero_or_one : fractional_portion
                                 |

  fractional_portion : DOT digit_zero_or_more digit_non_zero
                     | DOT digit_non_zero

  integer : zero
          | digit_non_zero digit_zero_or_more

  digit_zero_or_more : digit_zero_or_more digit
                     | digit
                     |

  assertion : value_csv_one_or_two parameter_zero_or_more
            | comma value parameter_zero_or_more
            | parameter parameter_zero_or_more

  value_csv_one_or_two : value comma value
                       | value

  parameter_zero_or_more : parameter_zero_or_more parameter
                         | parameter
                         |

  parameter : semicolon value_no_space equal csv

  csv : csv comma value
      | value

  value : string_escaped_special_chars

  value_no_space: string_escaped_special_chars_excluding_space

  special_chars : circumflex
                | square_brackets
                | parentheses
                | comma
                | semicolon
                | equal

  escaped_special_chars : circumflex circumflex
                        | circumflex square_brackets
                        | circumflex parentheses
                        | circumflex comma
                        | circumflex semicolon
                        | circumflex equal

  character_escaped_special : character_excluding_special_chars
                            | escaped_special_chars

  string_escaped_special_chars : string_escaped_special_chars character_escaped_special
                               | character_escaped_special

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

  character : character_excluding_special_chars
            | UNICODE_CHARACTER

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
