# Kyle Hernandez
# PlotQualityStats.R - Creates pdf figures of ReadStatistics output file.
# Requires ggplot2, grid, and reshape2
# Usage - Rscript PlotQualityStats.R <in.stat> <prefix of output image>

library(ggplot2)
library(grid)
library(reshape2)

# Read command line 
args<-commandArgs(TRUE)
dat<-read.delim(args[1], header=TRUE)
dat$A <- dat$A_ct / dat$N
dat$C <- dat$C_ct / dat$N
dat$G <- dat$G_ct / dat$N
dat$T <- dat$T_ct / dat$N

# To combine plots
vplayout<-function(x, y) viewport(layout.pos.row=x, layout.pos.col=y)

# Plot Quality-by-Index
p1 <- ggplot(dat, aes(x=Index, y=Mean)) +
  ylim(0, 50) +
  ylab(expression(paste("Mean Q " %+-% " 1", sigma))) +
  geom_errorbar(data = dat, aes(ymax = Mean + StdDev, ymin = Mean - StdDev), stat="identity", position="identity", col="grey40") +
  geom_point(aes(color="Mean"), size = 1.25) +
  geom_point(data=dat, aes(x = Index, y = Median, color="Median"), size = 1) +
  scale_color_manual(name = "Metric", labels=c("Mean", "Median"), values = c("black", "red")) +
  theme(legend.position=c(0.5, 0.2), legend.title=element_blank(),
        legend.key.size=unit(0.45, "cm"), legend.text=element_text(size=6), legend.direction="horizontal",
        axis.text=element_text(size=5), axis.title=element_text(size=7))

# Plot base distribution
bases <- melt(dat, id.vars="Index", measure.vars=c("A", "C", "G", "T"))
p2 <- ggplot(bases, aes(x=Index, y=value, group=variable)) +
  ylim(0, 1) +
  ylab("Base Distribution") +
  geom_bar(aes(fill=bases$variable), stat="identity") +
  theme(legend.position=c(0.99, 0.5), legend.title=element_blank(),
        legend.key.size=unit(0.45, "cm"), legend.text=element_text(size=6),
        axis.text=element_text(size=5), axis.title=element_text(size=7))

# Create output image 
pdf(paste(args[2], "-QR.pdf", sep = ""), width=7, height=4)
grid.newpage()
pushViewport(viewport(layout=grid.layout(4, 7)))
print(p1, vp=vplayout(1:2, 1:7))
print(p2, vp=vplayout(3:4, 1:7))
popViewport()
grid.text(paste(args[2], "-QR.pdf", sep=""), x=unit(0.5, "npc"), y=unit(0.975, "npc"), gp=gpar(fontsize=8))
dev.off()
