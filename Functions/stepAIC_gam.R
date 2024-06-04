#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2024-05-23
#'@email : amael.dupaix@ens-lyon.fr
#'#*******************************************************************************************************************
#'@description :  Function to select a gam based on the lowest AIC
#'#*******************************************************************************************************************
#'@revisions
#'#*******************************************************************************************************************

stepAIC.gam <- function(gam, verbose = F){
  
  x <- unlist(strsplit(as.character(gam$formula)[3], " \\+ "))
  k=1
  l=length(x)
  
  while(k <= l){
    
    y <- as.character(gam$formula)[2]
    x <- unlist(strsplit(as.character(gam$formula)[3], " \\+ "))
    df <- as.character(gam$call)[3]
    
    AIC_init <- AIC(gam)
    
    formula <- paste("mgcv::gam(",y,"~",paste(x, collapse = " + "),", data =",df,")")
    if (verbose){
      cat("~~~ Iteration", k, "~~~\n\nInitial model:", formula)
      cat("\nAIC:", AIC_init, "\n\n")
    }
    
    remove.x <- rep(F, length(x))
    diff.AIC <- rep(0, length(x))
    
    if (length(x)>1){
      for (i in 1:length(x)){
        new_formula <- paste("mgcv::gam(",y,"~",paste(x[-i], collapse = " + "),", data =",df,")")
        AIC.i <- eval(parse(text = paste("AIC(",new_formula,")")))
        
        if(verbose){
          cat(new_formula)
          cat("\nAIC:", AIC.i, "\n\n")
        }
        
        diff.AIC[i] <- AIC.i - AIC_init
        
        if (AIC.i < AIC_init){
          remove.x[i] <- T
        }
      }
    } else {
      new_formula <- paste("mgcv::gam(",y,"~ 1, data =",df,")")
      AIC.i <- eval(parse(text = paste("AIC(",new_formula,")")))
      
      if(verbose){
        cat(new_formula)
        cat("\nAIC:", AIC.i, "\n\n")
      }
      
      if (AIC.i < AIC_init){
        remove.x <- T
      }
    }
    
    
    if(any(remove.x)){
      if(length(x)>1){
        if (length(which(remove.x)) == 1){
          x <- x[!remove.x]
        } else {
          x <- x[-which(diff.AIC == min(diff.AIC))]
        }
      } else {
        x <- 1
      }
      new_formula <- paste("mgcv::gam(",y,"~",paste(x, collapse = " + "),", data =",df,")")
      gam <- eval(parse(text = new_formula))
      k <- k+1
    } else {
      k=l+1
    }
  }
  
  return(gam)
}