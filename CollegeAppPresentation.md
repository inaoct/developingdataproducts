College Decision Application
========================================================
author: Hristina G
date: December 30, 2017
autosize: true


Objectives
========================================================

1. Identify college options based on SAT scores

2. Predict graduation probability based on SAT entry scores

DATA SOURCE (College Scorecard Data collegescorecard.ed.gov)

- Data was pre-processed to remove universities with median SAT scores below 400
- Geo coordinates were obtained for each college by using city and state info with ggmap::geocode()
- The app utilized only median SAT scores. Other parameters could be used for future expansions 


University Choices 
========================================================
The app allows the user to identify suitable colleges based on SAT scores

- Math, Verbal, and SAT scores can be selected by the user
- The app displays a map of the United States that marks all universities with scores higher than the user-provided scores
- By clicking on a marker, the user can see the specific median acceptance SAT scores for the selected school
- The user can also click on the name of the university and be taken to that university's web site

Prediction of Graduation Rate
========================================================
The app allows the user to predict probability of graduation based on entry SAT scores

The app uses three simplified linear models:

- Model 1: Simple linear regression using the Math SAT Score only (lm.fitA)
- Model 2: Simple linear regression using the Writing SAT score only (lm.fitB)
- Model 3: Linear regression on both Math and Writing SAT Scores (lm.fitC)

Note that linear regression including Verbal SAT scores was explored as well but the Verbal SAT scores were not statistically significant when used alongside Math and Writing Scores


Model Comparison
========================================================




```r
anova(lm.fitA, lm.fitB, lm.fitC)
```

```
Analysis of Variance Table

Model 1: CompletionRate ~ MedianMathSAT
Model 2: CompletionRate ~ MedianWritingSAT
Model 3: CompletionRate ~ MedianMathSAT + MedianWritingSAT
  Res.Df    RSS Df Sum of Sq      F    Pr(>F)    
1    685 6.8527                                  
2    685 6.7529  0  0.099837                     
3    684 6.4453  1  0.307578 32.642 1.654e-08 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
