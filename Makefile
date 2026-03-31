# Makefile for project 1
#
# CMSC 22600 --- Compilers for Computer Languages
# Spring 2026
# University of Chicago
#
# COPYRIGHT (c) 2026 John Reppy (https://cs.uchicago.edu/~jhr)
# All rights reserved.
#
# targets:
#	make soolc	-- Build Project 1
#	make clean	-- remove generated files
#

SHELL =         /bin/sh
OS =            $(shell uname -s)

# we assume that sml (and thus ml-build is in the path)
#
ML_BUILD =	ml-build

HEAP_SUFFIX =	$(shell sml @SMLsuffix)

CM_FILES =	$(wildcard */sources.cm)
SRCS =		common/binop.sml \
		common/error.sml \
		driver/main.sml \
		parse-tree/parse-tree.sml \
		parse-tree/print-parse-tree.sml \
		parser/parser.sml \
		parser/sool.grm \
		parser/sool.lex

.PHONY:		soolc
soolc:		bin/soolc.$(HEAP_SUFFIX)

# build rule for compiler
bin/soolc.$(HEAP_SUFFIX):	$(CM_FILES) $(SRCS)
	$(ML_BUILD) driver/sources.cm Main.main soolc
	mv soolc.$(HEAP_SUFFIX) bin

.PHONY:		clean
clean:
		rm -rf bin/*.$(HEAP_SUFFIX)
		rm -rf .cm */.cm
		rm -f parser/sool.grm.sml parser/sool.lex.sml
