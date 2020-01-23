args<-commandArgs(TRUE)
library(Seurat)
library(dplyr)
rdsfilepath <- args[1]
print(rdsfilepath)
dat_2 <- readRDS(rdsfilepath)
dat_2 <-FindClusters(dat_2, resolution=0.5)
jpeg("TSNE_SNN.jpg", height = 1200, width = 1600)
DimPlot(dat_2)
dev.off()
All_Markers <- FindAllMarkers(dat_2, only.pos = TRUE, min.pct=0.25, logfc.threshold=0.25)
head(All_Markers)
write.table(All_Markers, file = "all_markers.csv", quote = FALSE, sep =",")
dat_2$cluster.idents <- Idents(object=dat_2)
Idents (object = dat_2) <- dat_2@meta.data$orig.ident
VST_Markers <- FindMarkers(dat_2, ident.1="VST", min.pct=0.25)
ATC_Markers <- FindMarkers(dat_2, ident.1="ATC", min.pct=0.25)
write.table(ATC_Markers, file = "ATC_markers.csv", quote = FALSE, sep =",")
write.table(VST_Markers, file = "VST_markers.csv", quote = FALSE, sep =",")
FeaturePlot(object=dat_2, features="CD8A", col=c("gray","darkblue"))
FeaturePlot(object=dat_2, features="CD4", col=c("gray","darkblue"))
head(FetchData(object=dat_2, vars= "CD4"))
range((FetchData(object=dat_2, vars= "CD4"))$CD4)
quantile((FetchData(object=dat_2, vars= "CD4"))$CD4)
saveRDS(dat_2, file="Seurat2.rds")

#output
#TSNE_SNN.jpg
#all_markers.csv
#ATC_markers.csv
#VST_markers.csv
#Seurat2.rds

#create directory CD4_renorm
### Zooming in on CD4s here
dat_3 <- subset(x=dat_2, subset = CD4 > 0 )
str(dat_3)
length(dat_3$orig.ident)
Idents (object = dat_3) <- dat_3@meta.data$orig.ident
dat_3 <- NormalizeData(dat_3)
dat_3 <- FindVariableFeatures(dat_3)
plot1 <- VariableFeaturePlot(dat_3)
top10 <- head(VariableFeatures(dat_3), 10)
plot2 <- LabelPoints(plot=plot1, points=top10, repel=TRUE)
dev.off()
jpeg("CD4_renorm/CD4_renorm_Highly_Var_genes.jpg")
CombinePlots(plots=list(plot1,plot2))
dev.off()
dat_3 <- ScaleData(dat_3)
#dat_3 <- Run PCA (dat_3)
dat_3 <- RunPCA (dat_3)
ElbowPlot(dat_3, ndims =50)
dev.off()
jpeg("CD4_renorm/CD4_renorm_ElbowPlot.jpg")
ElbowPlot(dat_3, ndims =50)
dev.off()
dat_3 <- FindNeighbors(dat_3, dims=1:30)
dat_3 <- RunTSNE(dat_3, dims=1:30, method ="FIt-SNE")
DimPlot(dat_3)
Idents (object = dat_3) <- dat_3@meta.data$orig.ident
dev.off()
jpeg("CD4_renorm/CD4_renorm_TSNE.jpg", height = 1200, width = 1600)
DimPlot(dat_3)
dev.off()
CD4_VST_Markers <- FindMarkers(dat_3, ident.1="VST", min.pct=0.25)
CD4_ATC_Markers <- FindMarkers(dat_3, ident.1="ATC", min.pct=0.25)
write.table(CD4_VST_Markers, file = "CD4_renorm/CD4_renorm_VST_markers.csv", quote = FALSE, sep =",")
write.table(CD4_ATC_Markers, file = "CD4_renorm/CD4_renorm_ATC_markers.csv", quote = FALSE, sep =",")
dat_3 <- FindClusters(dat_3, resolution=0.5)
jpeg("CD4_renorm/TSNE_CD4s_SNN.jpg", height = 1200, width = 1600)
DimPlot(dat_3)
dev.off()
jpeg("CD4_renorm/CD4_renorm_TSNE_SNN.jpg", height = 1200, width = 1600)
dev.off()
CD4_All_Markers <- FindAllMarkers(dat_3, only.pos = TRUE, min.pct=0.25, logfc.threshold=0.25)
write.table(CD4_All_Markers, file = "CD4_renorm/CD4_renorm_All_markers.csv", quote = FALSE, sep =",")
jpeg("CD4_renorm/CD4_renorm_TSNE_SNN.jpg", height = 1200, width = 1600)
DimPlot(dat_3)
dev.off()
saveRDS(dat_3, file="CD4_renorm/CD4_renorm.rds")
#savehistory("CD4_renorm/20191011_Taka_2.Rlog")

#output
#CD4_renorm/CD4_renorm_Highly_Var_genes.jpg
#CD4_renorm/CD4_renorm_ElbowPlot.jpg
#CD4_renorm/CD4_renorm_TSNE.jpg
#CD4_renorm/CD4_renorm_VST_markers.csv
#CD4_renorm/CD4_renorm_ATC_markers.csv
#CD4_renorm/TSNE_CD4s_SNN.jpg
#CD4_renorm/CD4_renorm_TSNE_SNN.jpg
#CD4_renorm/CD4_renorm_All_markers.csv
#CD4_renorm/CD4_renorm_TSNE_SNN.jpg
#CD4_renorm/CD4_renorm.rds
