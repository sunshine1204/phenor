#' Parallel M1 model as defined in
#' Basler et al. 2016 (Agr. For. Meteorlogy)
#' using a bell shaped chilling response
#'
#' @param data input data (see reference for detailed description),
#' data should be formatted using flat_format()
#' @param par a vector of parameter values, this is functions specific
#' @return raster or vector with estimated phenophase timing (in DOY)
#' @keywords phenology, model
#' @export
#' @examples
#'
#' \dontrun{
#' estimate = PM1(data = data, par = par)
#'}

# Basler parallel M1 b (bell shaped curve)
PM1b = function(par, data){

  # exit the routine as some parameters are missing
  if (length(par) != 8){
    stop("model parameter(s) out of range (too many, too few)")
  }

  # extract the parameter values from the
  # par argument
  t0 = round(par[1])
  T_base = par[2]
  C_a = par[3]
  C_b = par[4]
  C_c = par[5]
  C_ini = par[6]
  F_crit = par[7]
  C_req = par[8]

  # chilling
  Rc = 1 / ( 1 + exp( C_a * (data$Ti - C_c) ^ 2 + C_b * (data$Ti - C_c) ))
  Rc[1:t0,] = 0
  Rc[t0:nrow(Rc),] = 0
  Sc = apply(Rc,2, cumsum)

  # chilling requirement has to be met before
  # accumulation starts (binary choice)
  k = C_ini + Sc * (1 - C_ini)/C_req
  k[Sc >= C_req] = 1

  # forcing
  Rf = data$Ti - T_base
  Rf[Rf < 0] = 0
  Rf = ((data$Li / 24) ^ k) * Rf
  Rf[1:t0,] = 0

  # DOY of budburst criterium
  doy = apply(Rf,2, function(xt){
    doy = data$doy[which(cumsum(xt) >= F_crit)[1]]
    doy[is.na(doy)] = 9999
    return(doy)
  })

  # set export format, either a rasterLayer
  # or a vector
  shape_model_output(data = data, doy = doy)
}
