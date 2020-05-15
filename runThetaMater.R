#!/usr/bin/Rscript

library(ThetaMater)
library(MCMCpack)
library(ape)
library(phangorn)
library(optparse)

option_list = list(
	make_option(
		c("-f", "--file"),
		type="character",
		default=NULL,
		help="File in fasta format",
		metavar="character"
	),
	make_option(
		c("-a", "--shape"),
		type="double",
		default=10,
		help="shape parameter for gamma distribution",
		metavar="double"
	),
	make_option(
		c("-b", "--scale"),
		type="double",
		default=0.001,
		help="scale parameter for gamma distribution",
		metavar="double"
	)
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);



quit()
