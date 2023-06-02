#!/usr/bin/env Rscript

install.packages(c('glmnet', 'ROCit'))

library(tidyverse)
library(data.table)
library(glmnet)
library(ROCit)

set.seed(82701)

lasso_term <- paste(
    "y ~ exm2261159", 
    "+ imm_14_68384769", 
    "+ rs13039769",
    "+ rs7722073", 
    "+ imm_14_68384769:rs13039769",
    "+ exm2261159:rs7722073", 
    "+ imm_14_68384769:rs7722073",
    "+ NeuroX_rs17510431 * exm1277297 * rs4561537",
    "+ NeuroX_rs6912707",
    "+ exm498917",
    "+ imm_14_68282638",
    "+ rs915085",
    "+ NeuroX_rs6912707:imm_14_68282638",
    "+ NeuroX_rs6912707:rs915085",
    "+ NeuroX_rs211622",
    "+ exm2260671",
    "+ imm_11_127839015",
    "+ imm_14_68381094",
    "+ NeuroX_rs211622:imm_14_68381094",
    "+ exm2260671:imm_14_68381094",
    "+ X1kg_19_18269222 * rs1397596",
    "+ exm2272734",
    "+ rs2200204",
    "+ rs7003556",
    "+ rs2200204:rs7003556",
    "+ exm206563 * exm2270252 * rs2523618",
    "+ X1kg_1_101145916",
    "+ exm1383281",
    "+ rs2269656",
    "+ X1kg_1_101145916:rs2269656",
    "+ exm1383281:rs2269656",
    "+ NeuroX_rs2002922",
    "+ exm2260076",
    "+ imm_14_68356690",
    "+ NeuroX_rs2002922:exm2260076",
    "+ NeuroX_rs2002922:imm_14_68356690",
    "+ exm2261819",
    "+ exm499014",
    "+ rs2278320",
    "+ exm2261819:exm499014",
    "+ exm2261819:rs2278320",
    "+ NeuroX_rs3822019",
    "+ rs17022452",
    "+ rs4443108",
    "+ NeuroX_rs3822019:rs17022452",
    "+ rs17022452:rs4443108",
    "+ NeuroX_rs34635954",
    "+ exm2267471",
    "+ imm_14_68302922",
    "+ NeuroX_rs34635954:imm_14_68302922",
    "+ X1kg_5_620246",
    "+ rs2074478",
    "+ rs6033554",
    "+ X1kg_8_10822436 * rs9267211",
    "+ rs281001",
    "+ rs442882",
    "+ rs9384970",
    "+ NeuroX_rs6597033",
    "+ imm_20_48088423", 
    "+ imm_1_170934963 * rs458006",
    "+ X1kg_20_43491994",
    "+ rs4977436",
    "+ NeuroX_rs6938649",
    "+ rs3775605",
    "+ X1kg_20_43499223",
    "+ X1kg_20_43503777",
    "+ NeuroX_rs2290402",
    "+ NeuroX_rs41286661",
    "+ exm2271044",
    "+ NeuroX_rs2290402:exm2271044",
    "+ NeuroX_rs41286661:exm2271044",
    "+ exm__rs7603514",
    "+ rs3822019",
    "+ exm2268948",
    "+ imm_14_68303820",
    "+ exm__rs2074478_ver4",
    "+ rs6854244",
    "+ exm__rs4809330",
    "+ rs2290402",
    "+ exm__rs7032940 * rs9673419",
    "+ rs4809330",
    "+ rs724078",
    "+ exm__rs724078",
    "+ imm_20_61818904",
    "+ exm1278123",
    "+ imm_14_68293117",
    "+ exm2268262",
    "+ NeuroX_rs7748217",
    "+ rs1719147",
    sep=" "
)


train <- "temp/train.csv" %>% 
    fread() %>%
    drop_na()

val <- "temp/val.csv" %>%
    fread() %>%
    drop_na()

test <- "temp/test.csv" %>%
    fread() %>%
    drop_na()

all <- rbind(train, val, test) %>%
    rename_all(gsub, pattern = "\\.", replacement = "__")


train_ids <- 1:nrow(train)

val_ids <- (nrow(train) + 1) : (nrow(train) + nrow(val))

test_ids <- ((nrow(train) + nrow(val)) + 1) : ((nrow(train) + nrow(val) + nrow(test)))


mm <- formula(lasso_term) %>%
    model.matrix(data = all)

glmmod <- cv.glmnet(
        mm[train_ids, 1:ncol(mm)],
        y = train$y,
        family = "binomial",
        type.measure = "class"
    )

pred_test <- as.numeric(
        predict(
            glmmod, 
            s = c("lambda.1se", "lambda.min"), 
            mm[test_ids, 1:ncol(mm)], 
            family="binomial", 
            type = 'response'
        )
    )

rocit_object <- rocit(
        score = pred_test, 
        class = test$y
    ) %>% print()

measure <- measureit(
        score = pred_test, 
        class = test$y, 
        measure = c('ACC', 'MIS', 'SENS', "SPEC")
    )

measure_df <- tibble(
        Cutoff = measure$Cutoff,
        Depth = measure$Depth,
        TP = measure$TP,
        FP= measure$FP,
        TN = measure$TN,
        FN= measure$FN,
        ACC = measure$ACC,
        MIS = measure$MISS,
        SENS = measure$SENS,
        SPEC = measure$SPEC
    ) %>%
    mutate(Youden = SENS + SPEC -1) %>%
    filter(Youden == max(Youden)) %>%
    print()
