#' Create Model fit
#'
#' @param model_recipe a model recipe based on the predictors and target variable
#' @param model_spec a model specification that will eventually be fitted onto train/test data
#' @param df a dataframe that preferably consists ONLY the columns relevant to the entire regression model i.e, target variable and predictors 
#'
#' @return model fit
#' @export
#' 
#' @include 5.03-create_spec_kmin.R
#' @include 5.04-get_list_item.R
#' 
#' @examples
#' # Load data
#' data(mtcars)
#' 
#' # Create a target dataset
#' target_df <- target_df(mtcars, "gear", "wt", "qsec")
#' 
#' # Create recipe
#' model_recipe <- create_recipe(target_df, "gear")
#' 
#' # Create model specification with kmin
#' model_list <- list("mpg", "cyl", "disp", "hp", "am")
#' model_spec_kknn <- create_spec_kmin(target_df, model_recipe, "kknn", kmin=5, target_variable="gear")
#' model_spec_lm <- create_spec_kmin(target_df, model_recipe, "lm", target_variable="gear")
#' 
#' # Get first item from model_spec_kknn list
#' model_spec <- get_list_item(model_spec_kknn, 1)
#' 
#' # Fit model using kknn
#' model_fit_kknn <- create_fit(model_recipe, model_spec, target_df)
#' 
#' # Get first item from model_spec_lm list
#' model_spec <- get_list_item(model_spec_lm, 1)
#' 
#' # Fit model using lm
#' model_fit_lm <- create_fit(model_recipe, model_spec, target_df)
#' 
create_fit <- function(model_recipe, model_spec, df){
  model_fit <- workflows::workflow() %>%
    workflows::add_recipe(model_recipe) %>%
    workflows::add_model(model_spec) %>%
    fit(data=df)
  #print("model fit produced!")
  return(model_fit)
}
