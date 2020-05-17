#!/usr/bin/Rscript

# load library for command line parsing
library(optparse)

# load ThetaMater and dependencies
library(ThetaMater)
library(MCMCpack)
library(ape)
library(phangorn)

# load libraries for plotting
library(hexbin)
library(RColorBrewer)

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
		default=100000,
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
		default=12,
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
		default=2.2e-8,
		help="Mutation rate for calculating effective population size (Ne).",
		metavar="double"
	),
	make_option(
		c("-r", "--run"),
		type="integer",
		default=1,
		help="Run batch number",
		metavar="integer"
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

# write dataset to file
varnames(data.MCMC) <- c("theta", "alpha")
csvnamebase=paste(opt$file,"MCMCobj","M3","thetaPriors",opt$thetaShape,opt$thetaScale,"alphaPriors",opt$alphaShape,opt$alphaScale,"run",opt$run,sep="_")
csvname=paste(csvnamebase,"csv",sep=".")
write.csv(data.MCMC, csvname, row.names=F)

#print trace plots
namebase=paste(opt$file,"tracePlot","M3","thetaPriors",opt$thetaShape,opt$thetaScale,"alphaPriors",opt$alphaShape,opt$alphaScale,"run",opt$run,sep="_")
name=paste(namebase,"pdf",sep=".")
pdf(name)
plot(data.MCMC)
dev.off()

#print 3D hexbin plot. Colors indicate the number of MCMC steps in state (warmer colors show higher posterior probability
rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
h <- hexbin(data.MCMC)
hexnamebase=paste(opt$file,"hexbin","M3","thetaPriors",opt$thetaShape,opt$thetaScale,"alphaPriors",opt$alphaShape,opt$alphaScale,"run",opt$run,sep="_")
hexname=paste(hexnamebase,"pdf",sep=".")
pdf(hexname)
plot(h, colramp=rf, xlab='theta', ylab='alpha')
dev.off()

#calculate Ne
data.MCMC.Ne <- data.MCMC
data.MCMC.Ne[,1] = data.MCMC.Ne[,1]/(opt$mutationRate*4)
h <- hexbin(data.MCMC.Ne)
hexnamebaseNE=paste(opt$file,"hexbin","M3","Ne","thetaPriors",opt$thetaShape,opt$thetaScale,"alphaPriors",opt$alphaShape,opt$alphaScale,"run",opt$run,sep="_")
hexnameNE=paste(hexnamebaseNE,"pdf",sep=".")
pdf(hexnameNE)
plot(h, colramp=rf, xlab='Ne', ylab='alpha')
dev.off()


#summarize theta
summary(data.MCMC)

quit()
