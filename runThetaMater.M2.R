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
		default=30,
		help="shape parameter for gamma distribution",
		metavar="double"
	),
	make_option(
		c("-b", "--scale"),
		type="double",
		default=0.0001,
		help="scale parameter for gamma distribution",
		metavar="double"
	),
	make_option(
		c("-g", "--generations"),
		type="integer",
		default=100000,
		help="Number of MCMC generations",
		metavar="integer"
	),
	make_option(
		c("-d", "--burnin"),
		type="integer",
		default=10000,
		help="Number of MCMC generations to discard as burnin",
		metavar="integer"
	),
	make_option(
		c("-t", "--thin"),
		type="integer",
		default=2,
		help="Thinning interval for MCMC sampling",
		metavar="integer"
	),
	make_option(
		c("-k", "--categories"),
		type="integer",
		default=4,
		help="Number of categories for rate parameter. Typically 4 to 20.",
		metavar="integer"
	),
	make_option(
		c("-r", "--rate"),
		type="double",
		default=0.1,
		help="Rate parameter for among-locus rate variation",
		metavar="double"
	)
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

#read input file in fasta format from STACKS
data <- Read.InterleavedFasta(fasta.file = opt$file)

#display vectors
data$k.vec
data$l.vec
data$n.vec

#run MCMC
data.MCMC <- ThetaMater.M2(
	k.vec = data$k.vec,
	l.vec = data$l.vec,
	n.vec = data$n.vec,
	c.vec = data$c.vec,
	ngens = opt$gen,
	burnin = opt$burn,
	theta.shape = opt$shape,
	theta.scale = opt$scale,
	thin = opt$thin,
	K = opt$categories,
	alpha.param = opt$rate
)

#print trace plots
varnames(data.MCMC) <- "theta"
name=paste("tracePlot","M2","priors",opt$shape,opt$scale,opt$rate,"pdf",sep=".")
pdf(name)
plot(data.MCMC)
dev.off()

#summarize theta
summary(data.MCMC)

quit()
