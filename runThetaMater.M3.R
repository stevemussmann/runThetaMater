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
		help="File in fasta format.",
		metavar="character"
	),
	make_option(
		c("-a", "--thetaShape"),
		type="double",
		default=2,
		help="Shape parameter of the prior gamma distribution on theta.",
		metavar="double"
	),
	make_option(
		c("-b", "--thetaScale"),
		type="double",
		default=0.001,
		help="Scale parameter of the prior gamma distribution on theta.",
		metavar="double"
	),
	make_option(
		c("-g", "--generations"),
		type="integer",
		default=100000,
		help="Number of MCMC generations.",
		metavar="integer"
	),
	make_option(
		c("-d", "--burnin"),
		type="integer",
		default=10000,
		help="Number of MCMC generations to discard as burnin.",
		metavar="integer"
	),
	make_option(
		c("-t", "--thin"),
		type="integer",
		default=2,
		help="Thinning interval for MCMC sampling.",
		metavar="integer"
	),
	make_option(
		c("-k", "--classes"),
		type="integer",
		default=4,
		help="Number of rate categories for alpha. Typically 4 to 20.",
		metavar="integer"
	),
	make_option(
		c("-A", "--alphaShape"),
		type="double",
		default=5,
		help="Shape parameter of the prior gamma distribution on alpha.",
		metavar="double"
	),
	make_option(
		c("-B", "--alphaScale"),
		type="double",
		default=0.01,
		help="Scale parameter of the prior gamma distribution on alpha.",
		metavar="double"
	),
	make_option(
		c("-m", "--mutationRate"),
		type="double",
		default=0.1,
		help="Mutation rate for calculating effective population size (Ne).",
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
data.MCMC <- ThetaMater.M3(
	k.vec = data$k.vec,
	l.vec = data$l.vec,
	n.vec = data$n.vec,
	c.vec = data$c.vec,
	ngens = opt$gen,
	burnin = opt$burn,
	theta.shape = opt$thetaShape,
	theta.scale = opt$thetaScale,
	thin = opt$thin,
	K = opt$classes,
	alpha.shape = opt$alphaShape,
	alpha.scale = opt$alphaScale
)

#print trace plots
varnames(data.MCMC) <- c("theta", "alpha")
name=paste("tracePlot","M3","thetaPriors",opt$thetaShape,opt$thetaScale,"alphaPriors",opt$alphaShape,opt$alphaScale,"pdf",sep=".")
pdf(name)
plot(data.MCMC)
dev.off()

#summarize theta
summary(data.MCMC)

quit()
