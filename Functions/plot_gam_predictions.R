library(cowplot)

plot.gam.prediction <- function(data, my_gam,
                                vars, var_to_predict,
                                xlabel = "Xi",
                                ylabel = "Y",
                                lims.y = c(NA,NA),
                                transformation = T,
                                trans.back = identity,
                                error.lines = T,
                                l = 200){
  df <- data.frame(seq(min(data[,var_to_predict]),max(data[,var_to_predict]), length.out = l))
  names(df) <- var_to_predict
  other_vars <- vars[!vars %in% var_to_predict]
  for (i in 1:length(other_vars)){
    nm <- names(df)
    df <- dplyr::bind_cols(df,
                           new = rep(median(data[,other_vars[i]]),
                                     l))
    names(df) <- c(nm, other_vars[i])
  }
  p <- mgcv::predict.gam(my_gam, df, type = "link", se.fit = TRUE)
  
  
  if (transformation){
    upr <- trans.back(p$fit + p$se.fit)
    lwr <- trans.back(p$fit - p$se.fit)
    p$fit <- trans.back(p$fit)
  } else {
    upr <- p$fit + (p$se.fit)
    lwr <- p$fit - (p$se.fit)
  }
  # if (all(lwr<0) & all(p$fit > 0)){
  #   lwr <- rep(0, length(lwr))
  # }
  
  if (!error.lines){
    g <-
      ggplot()+
      geom_line(aes(x = df[,var_to_predict],
                    y = p$fit))+
      scale_y_continuous(limits = lims.y)+
      xlab(xlabel)+ ylab(ylabel)+
      theme(panel.background = element_rect(fill = "white",
                                            color = "black"))
  } else {
    g <-
      ggplot()+
      geom_line(aes(x = df[,var_to_predict],
                    y = p$fit))+
      geom_line(aes(x = df[,var_to_predict],
                    y = upr),
                linetype = "dotted")+
      geom_line(aes(x = df[,var_to_predict],
                    y = lwr),
                linetype = "dotted")+
      scale_y_continuous(limits = lims.y)+
      xlab(xlabel)+ ylab(ylabel)+
      theme(panel.background = element_rect(fill = "white",
                                            color = "black"))
  }

  xhist <- 
    axis_canvas(g, axis = "x") + 
    geom_histogram(aes(x = data[,var_to_predict],
                       y = after_stat(count / max(count))),
                   bins = 100,
                   fill = 'white',
                   color = "black")
  return(
    g %>%
      insert_xaxis_grob(xhist, grid::unit(0.5, "in"), position = "top") %>%
      ggdraw()
  )
  
}
