library(argparser)
library(TopmedPipeline)
library(SeqVarTools)
library(SNPRelate)
sessionInfo()

argp <- arg_parser("PCA (assumes unrelated samples)")
argp <- add_argument(argp, "config", help="path to config file")
argp <- add_argument(argp, "--version", help="pipeline version number")
argv <- parse_args(argp)
cat(">>> TopmedPipeline version ", argv$version, "\n")
config <- readConfig(argv$config)

required <- c("gds_file",
              "variant_include_file")
optional <- c("n_pcs"=20,
              "out_file"="pca.RData",
              "sample_include_file"=NA)
config <- setConfigDefaults(config, required, optional)
print(config)

gds <- seqOpen(config["gds_file"])

if (!is.na(config["sample_include_file"])) {
    sample.id <- getobj(config["sample_include_file"])
    message("Using ", length(sample.id), " samples")
} else {
    sample.id <- NULL
    message("Using all samples")
}

variant.id <- getobj(config["variant_include_file"])
message("Using ", length(variant.id), " variants")

n_pcs <- min(as.integer(config["n_pcs"]), length(sample.id))
nt <- countThreads()
pca <- snpgdsPCA(gds, sample.id=sample.id, snp.id=variant.id,
                 eigen.cnt=n_pcs, num.thread=nt)

save(pca, file=config["out_file"])

seqClose(gds)

# mem stats
ms <- gc()
cat(">>> Max memory: ", ms[1,6]+ms[2,6], " MB\n")
