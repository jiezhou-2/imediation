#' @title Internal function for function \code{beffect()}
#' @param \code{mcov} is the variance matrix of error in
#' mediator model
#' @param \code{mintercept}is the estimated intercept
#'  in mediator model
#' @param \code{BB} is the estimated state transition matrix
#' @param \code{index} is the mediator of interest
#' @param \code{u} is the state vector
#' @param \code{size} is the number of observations to simulate.
#' @import MASS
#' @return A list with length 2. The first element is a size-by-p
#' matrix representing the observations of mediators with treatment; the second represents
#' the observations of mediators without treatment.
mcsample=function(mcov,mintercept,BB,index,u,size){
  ##size is the number of mc samples
  ##u is the state vector
  ##index is the mediator of interest
  ##B is the estimated causal matrix
  ##mcoe is 2 by p matrix, in which the first row are the intercepts, the
  ##second row are the coefficients of treatment
  ##mcov is the covariance matrix of error in mediator model
  p=ncol(BB)-2
  des=kids(BB=BB,index=index)
  des=as.matrix(des[,-which(des[1,]==p+2)])
   mcoe_treatment=BB[2:(p+1),1]
  ocoe_treatment=BB[p+2,1]
  ocoe_mediator=BB[p+2,2:(p+1)]
B=BB[2:(p+1),2:(p+1)]
  if (index==1){
    u1=c(1, u[-1])
    u0=c(0,u[-1])
  }
  if (index==p){
    u1=c(u[-1], 1)
    u0=c(u[-1],0)
  }
  if (1<index & index<p){
    u1=c(u[c(2:index)], 1, u[-c(1:index)])
    u0=c(u[c(2:index)], 0, u[-c(1:index)])
  }

  B[,index]=0 #cut off the path
  omega=diag(p)-B
  intercept0=mintercept
  intercept1=mintercept+mcoe_treatment
  D0=matrix(nrow = size,ncol = p)
  D1=matrix(nrow = size,ncol = p)
  for (i in 1:size) {
  error=MASS::mvrnorm(n=1, mu=rep(0,p), Sigma = mcov)
  d0=solve(omega)%*%(intercept0+error)
  d1=solve(omega)%*%(intercept1+error)
  mediators1=d1*u1+(1-u1)*d0
  mediators0=d1*u0+(1-u0)*d0
  if (ncol(des)>0){
    aa=des[1,]-1
    bb=des[2,]
    mediators1[aa]=mediators1[aa]+bb*mediators1[index]
    mediators0[aa]=mediators0[aa]+bb*mediators0[index]
  }
  D0[i,]=mediators0
  D1[i,]=mediators1
  }
  return(list(D0=D0,D1=D1))
}
