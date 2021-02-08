rm(list=ls())
library(MAST)
library(Matrix)
library(feather)
library(parallel)

cargs <- commandArgs(trailingOnly=TRUE)

options(mc.cores=strtoi(cargs[6]))

print(paste('Reading matrix', cargs[1], sep=' '))
mat <- as.data.frame(read_feather(cargs[1]))
rownames(mat) <- mat[,1]
mat <- mat[,-1]

print(paste('Reading cdat', cargs[2], sep=' '))
cdat <- read.csv(cargs[2], check.names=FALSE, row.names=1)
fdat <- as.data.frame(colnames(mat))
row.names(fdat) <- fdat[,1]

# NOTE: dense matrix replaced with sparse matrix support
# raw <- FromMatrix(t(mat), cdat, fdat)
raw <- FromMatrix(list(et=Matrix(t(mat), sparse=TRUE)), cdat, fdat)

de <- NULL
print(paste('Testing', cargs[3], sep=' '))
test <- cdat[,cargs[3]]

rm(mat, fdat, cdat)
gc()

for (g in factor(sort(unique(test)))) {
    print(paste('Analyzing group', g, sep=' '))
    group <- test
    levels(group) <- factor(c(levels(group), 'REST'))
    group[group != g] = 'REST'
    group <- as.factor(group)
    group <- relevel(group, 'REST')
    colData(raw)$group <- group

    print(paste('Model:', cargs[4], sep=' '))
    zlmCond <- zlm(as.formula(cargs[4]), raw)

    print('Preparing results')
    summaryCond <- summary(zlmCond, doLRT=paste('group', g, sep=''))

    summaryDT <- summaryCond$datatable
    fcHurdle <- merge(
        summaryDT[
            contrast==paste('group', g, sep='')
            & component=='H',.(primerid, `Pr(>Chisq)`)
        ],
        summaryDT[
            contrast==paste('group', g, sep='')
            & component=='logFC', .(primerid, coef, ci.hi, ci.lo)
        ],
        by='primerid'
    )
    fcHurdle[,fdr:=p.adjust(`Pr(>Chisq)`, 'fdr')]
    g_de <- fcHurdle[, c(
        'primerid', 'coef', 'ci.hi', 'ci.lo', 'Pr(>Chisq)', 'fdr'
    )]
    colnames(g_de) <- c(
        'primerid', paste(g, 'coef', sep='_'), paste(g, 'ci.hi', sep='_'),
        paste(g, 'ci.lo', sep='_'), paste(g, 'pval', sep='_'),
        paste(g, 'fdr', sep='_')
    )
    if (is.null(de)) {
        de <- g_de
    } else {
        de <- merge(de, g_de, by='primerid')
    }
    rm(zlmCond, summaryCond, summaryDT, fcHurdle, g_de, group)
    gc()
}
print(paste('Writing result', cargs[5], sep=' '))
write.csv(de, file=cargs[5], quote=FALSE, row.names=FALSE)
