
<!-- README.md is generated from README.Rmd. Please edit that file -->

# imediation

<!-- badges: start -->

<!-- badges: end -->

The goal of imediation is to provide an easy access to the individual
mediation effects in complicated multivariates situation.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jiezhou-2/imediation")
```

The main function in this package is

ime(index,u,AA,data,form,type)

which outputs the individual mediation effects for given mediator.

1)  index specify the mediator of interest. The p mediators are indexed
    respectively by 1,2,…p.

2)  Vector u specify the state of treatment and other mediators, where 0
    stands for no treatment, 1 treatment.

3)  AA is a p by p (0,1)-matrix specifying the causal relationships
    among mediators. The parents of mediator i are represented by the
    nonzero entry in ith row of AA. If AA==0, which means no causality
    is available, then direct individual mediation effect is computed
    othewise total individual mediation effect is computed.

4)  data is a n by (p+q+2) matrix where the first column is treatment,
    the last column is the outcome, the 2 to (p+1) columns represent the
    mediators, the (p+2) to (p+q+1) columns represent the confounders.

5)  form is a list with 2 compoents. The first is a vector where 0 in
    entry j means no interaction between treatment and mediator j in the
    outcome model, 1 means there is interaction between treatment and
    mediator j in the outcome model. The second component is a
    symmetrical p by p matrix. If the (i,j) entry is 1, then there is
    interaction between mediator i and mediator j in the outcome model.
    If (i,j) entry is 0, then there is no interaction between mediator i
    and mediator j in the outcome model.

6)  type has two options, one is “continuous”, which means outcome will
    by modeled by normal regression, the other is “binomial”, which
    means outcome will by modeled by logistic regression. In formar
    case, mediation effect is measured by the difference. In later case,
    mediation effect is measured by odds ratio.

<!-- end list -->

``` r
library(imediation)
library(igraph)
#> 
#> Attaching package: 'igraph'
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union
```

### Causal relationships among mediators for the following examples.

``` r
#adjacency matrix
AA=matrix(0,nrow = 4,ncol =4)
A=matrix(c(0,1,0,0),nrow=2)
AA[c(2,3,4),1]=1
AA[4,c(1,2,3)]=1
AA[2:3,2:3]=A
#create graph
g1=graph_from_adjacency_matrix(adjmatrix = t(AA))
plot.igraph(g1)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

### Mediation model with 2 continuous mediators and binary treatment and outcome: Main-effect model

``` r
#data generation
size=200
 treatment=sample(x=c(0,1), size = size, replace = T,prob = c(0.5, 0.5))
  mediator=matrix(nrow = size, ncol = 2)
  error=matrix(nrow = size,ncol = 2)
  for (i in 1:size) {
    error[i,]=rnorm(n=2, mean=0, sd = 0.5)
  }

  mediator[,1]=0.5*treatment+error[,1]
  mediator[,2]=0.5*treatment+0.5*mediator[,1]+error[,2]
      expp=rep(0,size)
      p=rep(0,size)
      outcome=rep(0,size)
      for (i in 1:size) {
        expp[i]=0.5*treatment[i]+0.5*sum(mediator[i,])
        p[i]=exp(expp[i])/(1+exp(expp[i]))
        outcome[i]=rbinom(n=1,size=1,p=p[i])
      }
  data1=cbind(treatment,mediator,outcome)
  colnames(data1)=c("treatment",paste("mediator",1:2, sep = ""), "outcome")
```

``` r
#computation of mediation effects
form=vector( "list",2)
form[[1]]=rep(0,2)
form[[2]]=matrix(0,nrow = 2, ncol = 2)
ime(index=1,u=c(0,0),AA=AA,data = data1,form = form,type = "binomial")
#> [1] 1.865739
ime(index=2,u=c(0,0),AA=AA,data = data1,form = form,type = "binomial")
#> [1] 1.061723
```

### Mediation model with 2 continuous mediators and binary treatment and outcome: treatment-mediator-interaction-effect model

``` r
#data generation
size=200
 treatment=sample(x=c(0,1), size = size, replace = T,prob = c(0.5, 0.5))
  mediator=matrix(nrow = size, ncol = 2)
  error=matrix(nrow = size,ncol = 2)
  for (i in 1:size) {
    error[i,]=rnorm(n=2, mean=0, sd = 0.5)
  }

  mediator[,1]=0.5*treatment+error[,1]
  mediator[,2]=0.5*treatment+0.5*mediator[,1]+error[,2]
      expp=rep(0,size)
      p=rep(0,size)
      outcome=rep(0,size)
      for (i in 1:size) {
        expp[i]=0.5*treatment[i]+0.5*sum(mediator[i,])+0.5*treatment[i]*mediator[i,1]
        p[i]=exp(expp[i])/(1+exp(expp[i]))
        outcome[i]=rbinom(n=1,size=1,p=p[i])
      }
  data2=cbind(treatment,mediator,outcome)
  colnames(data2)=c("treatment",paste("mediator",1:2, sep = ""), "outcome")
  head(data2)
#>      treatment   mediator1   mediator2 outcome
#> [1,]         0  0.07066898  0.13328381       0
#> [2,]         1 -0.29599809  0.02333664       0
#> [3,]         0  0.16329735 -0.46634229       0
#> [4,]         0 -0.51862176  0.10820330       0
#> [5,]         0 -0.38525239 -0.50737046       1
#> [6,]         1  0.14907520  0.42526928       1
```

``` r
#computation of mediation effects
form=vector( "list",2)
form[[1]]=c(0,0)
form[[2]]=matrix(0,nrow = 2, ncol = 2)
ime(index=1,u=c(0,0),AA=AA,data = data1,form = form,type = "binomial")
#> [1] 1.866427
ime(index=2,u=c(0,0),AA=AA,data = data1,form = form,type = "binomial")
#> [1] 1.061074
```

### Mediation model with 2 continuous mediators and binary treatment and outcome: mediator-mediator-interaction-effect model

``` r
#data generation
size=200
 treatment=sample(x=c(0,1), size = size, replace = T,prob = c(0.5, 0.5))
  mediator=matrix(nrow = size, ncol = 2)
  error=matrix(nrow = size,ncol = 2)
  for (i in 1:size) {
    error[i,]=rnorm(n=2, mean=0, sd = 0.5)
  }

  mediator[,1]=0.5*treatment+error[,1]
  mediator[,2]=0.5*treatment+0.5*mediator[,1]+error[,2]
      expp=rep(0,size)
      p=rep(0,size)
      outcome=rep(0,size)
      for (i in 1:size) {
        expp[i]=0.5*treatment[i]+0.5*sum(mediator[i,])+0.5*mediator[i,2]*mediator[i,1]
        p[i]=exp(expp[i])/(1+exp(expp[i]))
        outcome[i]=rbinom(n=1,size=1,p=p[i])
      }
  data3=cbind(treatment,mediator,outcome)
  colnames(data3)=c("treatment",paste("mediator",1:2, sep = ""), "outcome")
  head(data3)
#>      treatment  mediator1  mediator2 outcome
#> [1,]         1  0.7361558  0.8103868       1
#> [2,]         0 -0.8554943 -0.0830664       1
#> [3,]         0  0.1729030  0.1795705       0
#> [4,]         0 -0.1121925 -0.3858314       0
#> [5,]         1  1.4901547  1.0287766       1
#> [6,]         0  1.1304708  0.1901864       1
```

``` r
#computation of mediation effects
form=vector( "list",2)
form[[1]]=c(0,0)
form[[2]]=matrix(c(0,1,1,0),nrow = 2, ncol = 2)
ime(index=1,u=c(0,0),AA=AA,data = data1,form = form,type = "binomial")
#> [1] 1.864117
ime(index=2,u=c(0,0),AA=AA,data = data1,form = form,type = "binomial")
#> [1] 1.06717
```
