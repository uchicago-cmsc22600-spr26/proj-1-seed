(* main.sml
 *
 * COPYRIGHT (c) 2026 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Sample code
 * CMSC 22600
 * Spring 2026
 * University of Chicago
 *
 * Driver for Project 1.
 *)

structure Main : sig

    val main : string * string list -> OS.Process.status

  end = struct

    fun err s = TextIO.output (TextIO.stdErr, s)
    fun err1 c =  TextIO.output1 (TextIO.stdErr, c)
    fun errnl s = (err s; err1 #"\n")

  (* check for errors and report them if there are any *)
    fun checkForErrors errStrm =
          if Error.anyErrors errStrm
            then raise Error.ERROR
            else ()

  (* check that an input file exists.  If it does not exist, then print an error message
   * and raise the ERROR exception.
   *)
    fun doesFileExist filename = if OS.FileSys.access(filename, [OS.FileSys.A_READ])
          then ()
          else (
            err(concat["source file \"", filename, "\" does not exist or is not readable\n"]);
            raise Error.ERROR)

  (* dump the parse tree to a file *)
    fun dumpPT (errStrm, base, prog) = let
          val outFile = OS.Path.joinBaseExt{base = base, ext = SOME "pt"}
          val outS = TextIO.openOut outFile
          in
            PrintParseTree.program (
              PrintParseTree.new{outS=outS, errS=errStrm, showMarks=false},
              prog);
            TextIO.closeOut outS
          end

  (* process an input file *)
    fun doFile (errStrm, filename) = let
        (* check that the input file exists *)
          val _ = doesFileExist filename
          val base = OS.Path.base filename
        (* parse the input file *)
          val parseTree = let
                val inS = TextIO.openIn filename
                val pt = Parser.parse (inS, errStrm)
                in
                  TextIO.closeIn inS;
                  checkForErrors errStrm;
                  valOf pt
                end
          in
          (* output parse tree *)
            dumpPT (errStrm, base, parseTree)
          end

    fun handleExn Error.ERROR = OS.Process.failure
      | handleExn exn = (
          err (concat [
              "uncaught exception ", General.exnName exn,
              " [", General.exnMessage exn, "]\n"
            ]);
          List.app (fn s => err (concat ["  raised at ", s, "\n"])) (SMLofNJ.exnHistory exn);
          OS.Process.failure)

    fun main (cmd, ["--test-scanner", filename]) = let
        (* scan the input and print the tokens to <file>.toks *)
          val errStrm = Error.mkErrStream filename
          val base = OS.Path.base filename
          val outFile = OS.Path.joinBaseExt{base = base, ext = SOME "toks"}
          val inS = TextIO.openIn filename
          val outS = TextIO.openOut outFile
          in
            Parser.lexer (inS, errStrm, outS);
            TextIO.closeIn inS; TextIO.closeOut outS;
            checkForErrors errStrm;
            OS.Process.success
          end
      | main (cmd, [filename]) = let
        (* parse the input and print the parse tree to <file>.pt *)
          val errStrm = Error.mkErrStream filename
          fun finish () = if Error.anyErrors errStrm
                then (Error.report (TextIO.stdErr, errStrm); OS.Process.failure)
                else (
                  if Error.anyWarnings errStrm
                    then Error.report (TextIO.stdErr, errStrm)
                    else ();
                  OS.Process.success)
          in
            (doFile (errStrm, filename); finish())
              handle ex => (ignore (finish()); handleExn ex)
          end
      | main (cmd, _) = (
          TextIO.output(TextIO.stdErr, concat["usage: [--test-scanner]", cmd, " <file>\n"]);
          OS.Process.failure)

  end
