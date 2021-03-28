#' Title
#'
#' @param \code{index} is the mediator of interest
#' @param \code{u} is the state vector
#' @param \code{mintercept} the estimated intercept in mediator model
#' @param \code{BB} is the estimated state transition matrix
#' @param \code{type} the type of outcome
#' @param \code{ocoe_tm} the coefficients of treatment-mediator
#' interaction in outcome model
#' @param \code{ocoe_confounder} is the coefficient of confounder
#' in outcome model
#' @param \code{ocoe_intercept} is the estiamted intercept in
#' outcome model
#' @param \code{ocoe_mm} is the coefficient of mediator-mediator interaction
#' in outcome model
#'
#' @return mediation effects
#' @export
#'
beffect=function(index,u, mintercept,BB,type,ocoe_tm,ocoe_confounder
                 ,ocoe_intercept,ocoe_mm){
  ##index-mediator you want to investigate
  ##u-the given enviroment vector
  ##size-the sampel size to compute the effect.
  size=200
  simdata=mcsample(mcov = mcov , mintercept = mintercept,
                   BB=BB,
                   index = index, u=u,size=size)
  p=ncol(BB)-2
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
    b[1:p]=BB[p+2,2:(p+1)]
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
