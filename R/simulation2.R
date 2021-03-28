#' Title
#'
#' @param \code{size} is sample size
#' @param \code{tc_m} coefficient of treatment in mediatior model
#' @param \code{mc_m} coefficient of mediator in mediator model
#' @param \code{tc_o} coefficient of treatment in outcome model
#' @param \code{mc_o} coefficient of mediator in outcome model
#' @param \code{sigma_m} variance of error in mediaor model
#' @param \code{sigma_o} variance of error in outcome model
#'
#' @return a size-by-12 matrix
#' @export
#'
#' @examples
#' data=binary()
binary=function(size=200,tc_m=0.5,mc_m=0.5,tc_o=0.5,mc_o=0.5,sigma_m=0.5, sigma_o=0.5){
  treatment=sample(x=c(0,1), size = size, replace = T,prob = c(0.5, 0.5))
  mediator=matrix(nrow = size, ncol = 10)
  error=matrix(nrow = size,ncol = 10)
  for (i in 1:size) {
    error[i,]=rnorm(n=10, mean=0, sd = sigma_m)
  }

  mediator[,1]=error[,1]+tc_m*treatment
  mediator[,2]=error[,2]+tc_m*treatment
  mediator[,3]=error[,3]+tc_m*treatment
  mediator[,4]=error[,4]+tc_m*treatment
  mediator[,5]=error[,5]+mc_m*mediator[,1]+tc_m*treatment
  mediator[,6]=error[,6]+mc_m*mediator[,2]+tc_m*treatment
  mediator[,7]=error[,7]+mc_m*mediator[,2]+tc_m*treatment
  mediator[,8]=error[,8]+mc_m*mediator[,3]+tc_m*treatment
  mediator[,9]=error[,9]+mc_m*mediator[,3]+tc_m*treatment
  mediator[,10]=error[,10]+mc_m*mediator[,4]+tc_m*treatment
      expp=rep(0,size)
      p=rep(0,size)
      outcome=rep(0,size)
      for (i in 1:size) {
        expp[i]=tc_o*treatment[i]+sum(mediator[i,])*mc_o
        p[i]=exp(expp[i])/(1+exp(expp[i]))
        outcome[i]=rbinom(n=1,size=1,p=p[i])
      }
  data=cbind(treatment,mediator,outcome)
  colnames(data)=c("treatment",paste("mediator",1:10, sep = ""), "outcome")
return(data)
}
