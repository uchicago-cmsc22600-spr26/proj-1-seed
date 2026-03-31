(* sool.lex
 *
 * COPYRIGHT (c) 2026 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Sample code
 * CMSC 22600
 * Spring 2026
 * University of Chicago
 *
 * ml-ulex specification for SooL
 *)

%name SoolLex;

%arg (lexErr);

%defs(

    structure T = SoolTokens

  (* some type lex_result is necessitated by ml-ulex *)
    type lex_result = T.token

(* MORE DEFINITIONS HERE *)

);

(* Minimal lexer that rejects all input; replace with your code *)
<INITIAL>.              => (lexErr((yypos, yypos), ["bad character `", String.toString yytext, "'"]);
                            continue());
<INITIAL> <<EOF>>       => (T.EOF);
