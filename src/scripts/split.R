#!/usr/bin/env Rscript

install.packages('BiocManager')
BiocManager::install("snpStats")

library(tidyverse)
library(snpStats)

train_ids <- 'assets/train_ids.csv' %>% 
    read_csv(col_types='c')

test_ids <- 'assets/test_ids.csv' %>% 
    read_csv(col_types='c')

val_ids <- 'assets/val_ids.csv'%>% 
    read_csv(col_types='c')

phenotypes <- 'temp/phenotypes.csv' %>% 
    read_csv(col_types='cc')

plink <- "temp/ppmi_filtered.bed" %>%
    read.plink() 

plink$genotypes %>%
    write.SnpMatrix("temp/ppmi_filtered.txt")

g <- "temp/ppmi_filtered.txt" %>%
   read.table(row.names=1) %>%
   mutate(iid = row.names(.)) %>%
   as_tibble() %>%
   inner_join(phenotypes, by=('iid')) %>%
   mutate(
      y = case_when(
         pheno == "Healthy Control" ~ 0,
         pheno == "Parkinson's Disease" ~ 1,
      )
   )

train <- train_ids %>%
    inner_join(g) %>%
    select(-iid, -pheno) %>%
    write_csv('temp/train.csv')

val <- val_ids %>%
    inner_join(g) %>%
    select(-iid, -pheno) %>%
    write_csv('temp/val.csv')

test <- test_ids %>%
    inner_join(g) %>%
    select(-iid, -pheno) %>%
    write_csv('temp/test.csv')
