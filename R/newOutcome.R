
#' @title Kids()
#' @description Find the descendants
#' @param \code{BB} represents the estimated coefficients
#' @param \code{index} is the mediator of interest.
#'
#' @return the descendants of given mediator and the related weights
#' @export
#'
kids=function(BB,index){
  p=nrow(BB)-2
  edgeindex=which(BB!=0,arr.ind = T)
  wei=BB[edgeindex]
  edgeindex=edgeindex[,c(2,1)]
  edgeindex=as.vector(t(edgeindex))
  GG=igraph::make_empty_graph(n=p+2)%>%add.edges(edgeindex)
  if (!is.dag(GG)) {stop("Not a DAG model!!!")}
  E(GG)$weights=wei
  descendants=unique(unlist(igraph::all_simple_paths(GG,from = index+1,to=p+2)))
  descendants=setdiff(descendants,c(index+1))
  if (length(descendants)==0){stop("node index have no descendants")}
  wei_nodewise=matrix(0,nrow=2,ncol=length(descendants))
    for (j in 1:length(descendants)) {
      wei_nodewise[1,j]=descendants[j]
        pps=igraph::all_simple_paths(GG,from = index+1,to=descendants[j])
        w=0
        for (k in 1:length(pps)) {
          w=w+prod(E(GG,path = pps[[k]])$weights)
        }
        wei_nodewise[2,j]=w
      }
  return(wei_nodewise)
}

