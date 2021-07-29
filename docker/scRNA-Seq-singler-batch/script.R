rm(list=ls())

# SingleR() expects log-counts, this script expects normalized counts
# Log transformations automatically done at the end of the script
library(BiocParallel)
library(SingleR)
library(dplyr)
library(tibble)
library(purrr)
library(tidyr)
library(arrow)

cargs <- commandArgs(trailingOnly=TRUE)

print('* NOTE * Input data is expected NOT log-transformed')

print(paste('Reading reference', cargs[1], sep=' '))
ref <- as.data.frame(read_feather(cargs[1]))
rownames(ref) <- ref[,1]
ref <- ref[,-1]

print(paste('Reading sample', cargs[2], sep=' '))
mat <- as.data.frame(read_feather(cargs[2]))
rownames(mat) <- mat[,1]
mat <- mat[,-1]

print(paste('Reading labels', cargs[3], sep=' '))
labels <- read.table(
    sep=',', header=TRUE, check.names=FALSE, cargs[3], row.names=1,
)

print('Keeping only cells with label')
cells <- intersect(rownames(ref), rownames(labels))
ref <- ref[cells,]
labels <- subset(labels, rownames(labels) %in% cells)

print('Log transforming and transposing')
ref <- log1p(t(ref))
mat <- log1p(t(mat))

labels.full <- labels[colnames(ref),]

print('Starting prediction')
pred <- SingleR(
    test=mat,
    ref=ref,
    labels=labels.full,
    de.method='wilcox',
    BPPARAM=MulticoreParam(workers=4+1),
)

print(paste('Writing results to file', cargs[4], sep=' '))
write.table(pred, file=cargs[4], sep=',', quote=FALSE)

# cells.ref <- colnames(ref)
# n <- length(cells.ref)

set.seed(42)

pred.bs <- NULL
start <- 0

min_cells <- min(table(labels))
print(paste('Minimum cell type size is', min_cells, sep=' '))
frac <- as.integer(cargs[5]) / min_cells
print(paste('Using frac:', frac, sep=' '))

n.iter <- as.integer(cargs[6])
print(paste('Starting iterations: n=', cargs[6], sep=' '))
for(i in start+1:n.iter) {
    if (i %% 10 == 0) {
        cat('\n')
    } else {
        cat('.')
    }
    # NOTE Select stratified random fraction
    cells <- rownames(labels %>%
        rownames_to_column('Cell') %>%
        group_by(cargs[7]) %>%
        sample_frac(frac, replace=F) %>%
        column_to_rownames('Cell'))
    ref.bs <- ref[, cells]
    # Only genes expressed in at least 3 cells
    ref.bs <- ref.bs[rowSums(ref.bs > 0) >= 3,]
    mat.bs <- mat[rownames(ref.bs),]
    labels.bs <- labels[colnames(ref.bs),]
    pred.bs.run <- SingleR(
        test=mat.bs,
        ref=ref.bs,
        labels=labels.bs,
        de.method='wilcox',
        BPPARAM=MulticoreParam(workers=4+1),
    )
    pred.bs.run <- pred.bs.run['labels']
    colnames(pred.bs.run) <- paste(i, colnames(pred.bs.run), sep='.')
    if (is.null(pred.bs)) {
        pred.bs <- pred.bs.run
    } else {
        pred.bs <- cbind(pred.bs, pred.bs.run)
    }
    if (i %% 10 == 0) {
        write.table(
            pred.bs,
            file=cargs[8],
            sep=',',
            quote=FALSE,
        )
    }
}