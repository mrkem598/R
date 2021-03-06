
library("caret")
library(doMC)
registerDoMC(6)

#dev.off()

regData = read.csv("~/Downloads/regdata.csv")

regData = transform(regData, NCallOILag1 = c(NCallOI[-1], NA))
regData = transform(regData, NCallOILag2 = c(NCallOILag1[-1], NA))
regData = transform(regData, NCallOILag3 = c(NCallOILag2[-1], NA))
regData = transform(regData, NPutOILag1 = c(NPutOI[-1], NA))
regData = transform(regData, NVolLag1 = c(NVol[-1], NA))
regData = transform(regData, PutCallOIRatioLag1 = c(PutCallOIRatio[-1], NA))
regData = transform(regData, NMeanIVLag1 = c(NMeanIV[-1], NA))
regData = transform(regData, NMeanIVLag2 = c(NMeanIVLag1[-1], NA))
regData = transform(regData, MeanIVLag1 = c(MeanIV[-1], NA))
regData = transform(regData, CallIVLag1 = c(CallIV[-1], NA))
regData = transform(regData, PutIVLag1 = c(PutIV[-1], NA))
regData = transform(regData, Excess.ReturnLag1 = c(Excess.Return[-1], NA))
regData = transform(regData, PositiveReturn = c((Excess.Return > 0.02)*1))

nnBase = regData[regData$DateDiff >= -139 & regData$DateDiff <= -31 ,]

trainIndex <- createDataPartition(nnBase$PositiveReturn, p=.7, list=F)
nnmodel.train <- nnBase[trainIndex, ]
nnmodel.test <- nnBase[-trainIndex, ]


nnmodel.grid <- expand.grid(.layer1=c(20), .layer2=c(20), .layer3=c(20))
nnmodel.fit <- train(PositiveReturn ~ NMeanIVLag1 + NCallOILag1 + NMeanIVLag2 + NCallOILag2, 
                     data = nnmodel.train, method = "neuralnet", tuneGrid = nnmodel.grid,
                     rep=5)  


#neuralnet(
#  formula = case~age+parity+induced+spontaneous,
#  data = infert, hidden = 2, err.fct = "ce",
#  linear.output = FALSE)

nnmodel.predict <- predict(nnmodel.fit, newdata = nnmodel.test)
nnmodel.rmse <- sqrt(mean((nnmodel.predict - nnmodel.test$PositiveReturn)^2)) 

print(nnmodel.rmse)

t1 = nnmodel.test$PositiveReturn > 0
t2 = nnmodel.predict > 0.5
t3 = summary(t1 == t2)
print(t3)

plot(nnmodel.fit$finalModel)

