#' Main function
#'
#' @param \code{index} is the mediator of interest
#' @param \code{u} is the state vector
#' @param \code{AA} is the  transition matrix
#' @param \code{type} the type of outcome
#' @param \code{form} specify the regression form for outcome
#' @param \code{data} is the n by (p+2+q) data matrix
#' @return mediation effects
#' @export
#'
ime=function(index,u,AA,type,form,data){
  ##index-mediator you want to investigate
  ##u-the given enviroment vector
  ##size-the sampel size to compute the effect.
  size=2000
  p=nrow(AA)-2
  result=regression(form=form, type=type, data=data, C=AA)
  mcoe=result$mcoe
  mintercept =mcoe[1,]
  mcov=result$mcov
  ocoe_intercept=result$ocoe_intercept
  ocoe_confounder=result$ocoe_confounder
  ocoe_tm=result$ocoe_tm
  ocoe_mm=result$ocoe_mm
  B=result$B
  ocoe_mediator=result$ocoe_mediator
  ocoe_treatment=result$ocoe_treatment
  BB=B
  simdata=mcsample(mcov = mcov , mintercept = mintercept,
                   BB=BB,
                   index = index, u=u,size=size)
  D0=simdata[[1]]
  D1=simdata[[2]]
  if (type=="binomial"){
    p1=rep(0,size)
    p0=rep(0,size)
    for (i in 1:size) {
      mediators1=D1[i,]
      mediators0=D0[i,]
      m11=mediators1%*%t(mediators1)
      m11=m11[lower.tri(m11)]
      m00=mediators0%*%t(mediators0)
      m00=m00[lower.tri(m00)]
      x1=c(mediators1,u[1]*mediators1, m11)
      x0=c(mediators0,u[1]*mediators0, m00)
      b=rep(0,2*p+p*(p-1)/2)
      b[1:p]=ocoe_mediator
      b[(p+1):(2*p)]=ocoe_tm
      b[(2*p+1):(2*p+p*(p-1)/2)]=ocoe_mm
      p1[i]=exp(t(b)%*%x1)/(1+exp(t(b)%*%x1))
      p0[i]=exp(t(b)%*%x0)/(1+exp(t(b)%*%x0))
    }
    odds1=mean(p1, na.rm = T)/(1-mean(p1, na.rm=T))
    odds0=mean(p0, na.rm = T)/(1-mean(p0, na.rm=T))
    r=odds1/odds0
  }

  if (type=="normal"){
    meffect=rep(0, size)
    for (i in 1:size) {
      mediators1=D1[i,]
      mediators0=D0[i,]
      m11=mediators1%*%t(mediators1)
      m11=m11[lower.tri(m11)]
      m00=mediators0%*%t(mediators0)
      m00=m00[lower.tri(m00)]
      x1=c(mediators1,u[1]*mediators1, m11)
      x0=c(mediators0,u[1]*mediators0, m00)
      b=rep(0,2*p+p*(p-1)/2)
      b[1:p]=BB[p+2,2:(p+1)]
      b[(p+1):2*p]=ocoe_tm
      b[(2*p+1):(2*p+p*(p-1)/2)]=ocoe_mm
      meffect[i]=t(b)%*%(x1-x0)
    }
    r=mean(meffect, na.rm = T)
  }
  return(mediate=r)
}
