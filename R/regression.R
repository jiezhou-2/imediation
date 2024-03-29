#' Title
#'
#' @param \code{form} is the list having two elements. The first is
#' a vector representing the cofficients of interaction term between
#' treatment and mediator. The second element is the coefficients of
#' interaction term between mediator and mediator.
#' @param \code{type} indicate the type of outcome
#' @param \code{data} \code{n} by \code{p+2} observation matrix
#' on treatment, mediators and outcome.
#' @param \code{C} are the causal matrix
#'
#' @return all the estimates of unknown parameters.
#' @export
regression=function(form, type, data, C){
  n=nrow(data)
  p=ncol(C)-2
  q=ncol(data)-p-2
  res=matrix(nrow = n, ncol = p)
  B=C
  mcoe=matrix(nrow = 2, ncol = p)
  if (all(C==0)){
    for (j in 1:p) {
      m_j=data[,j+1]
      treatment=data[,1]
      a=lm(m_j~treatment)
      ll=summary(a)$coefficients
      mcoe[,j]=ll[,1]
      res[,j]=a$residuals
    }
    mcov=var(res)
    B[2:(p+1),1]=mcoe[2,]
  }else{
    for (j in 1:p) {
      m_j=data[,j+1]
      non=which(C[j+1,]!=0)
      if (length(non)==0){stop("there exist redundant mediators!")}
        parents=data[,non]
        a=lm(m_j~parents)
        ll=summary(a)$coefficients
        res[,j]=a$residuals
        b=summary(a)$coefficients[,1]
        B[j+1,non]=b[-1]
        mcoe[1,j]=b[1]
    }
    mcoe[2,]=B[2:(p+1),1]
    mcov=diag(diag(var(res)))
    }
  ##outcome model
  index1=which(form[[1]]!=0)
  p1=length(index1)
  MM=form[[2]]
  if (!isSymmetric(MM)){stop("Second order matrix should be symmetrical matrix")}
  MM[upper.tri(MM)]=0
  diag(MM)=0
  p2=length(which(MM!=0))
  outcome=data[,ncol(data)]
  treatment=data[,1]
  mediators=data[,2:(p+1)]
  if (q>0){
    confounders=data[,(p+2):(p+q+1)]
    fo=formula(outcome~treatment+mediators+confounders)
  }else{
    fo=formula(outcome~treatment+mediators)
  }

  if (length(index1)>0){
    fo=update(fo,~. + treatment:mediators[,index1])
  }
  index_mm=c()
  j=0
  for (i in 1:(p-1)) {
    index2=which(MM[,i]!=0)-1
    if (length(index2)==0) next()
    fo=update(fo, ~ . + mediators[,i]:mediators[,index2])
    index_mm=c(index_mm,index2+j)
    j=j+(p-i)
  }
  result=glm(formula = fo, family = type )
  ss=summary(result)$coefficients
  ocoe=ss[,1]
  ##ocoe_cov=vcov(result)
  ocoe_tm=rep(0,p)
  ocoe_mm=rep(0,p*(p-1)/2)
  ocoe_intercept=ocoe[1]
  ocoe_treatment=ocoe[2]
  ocoe_mediator=ocoe[3:(p+2)]
  B[p+2,1]=ocoe_treatment
  B[p+2,2:(p+1)]=ocoe_mediator
  if (q>0){
  ocoe_confounder=ocoe[(p+3):(p+q+2)]
  }else{
    ocoe_confounder=c()
  }
  if (length(index1)>0){
  ocoe_tm[index1]=ocoe[(p+q+3):(p+q+2+p1)]
  }

  if (length(index_mm)>0){
  ocoe_mm[index_mm]=ocoe[(p+q+2+p1+1):(p+q+2+p1+p2)]
  }

  aa1=list(mcov=mcov,
           mcoe=mcoe,
           B=B,
           ocoe_tm=ocoe_tm,
           ocoe_confounder=ocoe_confounder,
           ocoe_mediator=ocoe_mediator,
           ocoe_treatment=ocoe_treatment,
           ocoe_intercept=ocoe_intercept,
           ocoe_mm=ocoe_mm
           )
  return(aa1)
}
