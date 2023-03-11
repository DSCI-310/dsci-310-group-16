##  RScript that takes in data set and runs initial cleaning of data

player_career <- function(data_set) {
  
  #This function calculate player wins and mean match stats for winning matches
  
  player_wins <- data_set %>%
    
    group_by(player_id = winner_id) %>%
    
    summarize(w_height = mean(winner_ht, na.rm =TRUE),
              w_breakpoint_saved_pct = mean(w_bpSaved/w_bpFaced, na.rm =TRUE),
              w_second_serve_win_pct = mean(w_2ndWon / w_svpt,na.rm =TRUE),
              w_first_serve_pct = mean(w_1stWon / w_1stIn,na.rm =TRUE),
              w_first_serve_win_pct = mean(w_1stWon / w_svpt, na.rm = TRUE),
              n_wins = n(),
              mean_age_w  = mean(winner_age),
              mean_rank_points_w = mean(winner_rank_points),
              w_ace_point_pct = mean(w_ace/w_svpt,na.rm = TRUE)
    ) %>%
    drop_na() %>%
    
    mutate(player_id = as.character(player_id))
  
  # calculate player losses and mean match stats for losing matches
  player_lose <- data_set %>%
    group_by(player_id = loser_id) %>%
    
    summarize(l_height = mean(loser_ht, na.rm =TRUE),
              l_breakpoint_saved_pct = mean(l_bpSaved/l_bpFaced, na.rm =TRUE),
              l_second_serve_win_pct = mean(l_2ndWon / l_svpt,na.rm =TRUE),
              l_first_serve_pct = mean(l_1stWon / l_1stIn,na.rm =TRUE),
              l_first_serve_win_pct = mean(l_1stWon / l_svpt, na.rm = TRUE),
              n_lose = n(),
              mean_age_l  = mean(loser_age),
              mean_rank_points_l = mean(loser_rank_points),
              l_ace_point_pct = mean(l_ace/l_svpt,na.rm = TRUE)
    ) %>%
    
    drop_na() %>%
    
    mutate(player_id = as.character(player_id))
  
  # join datasets for wins and losses using unique player ids
  player_join <- left_join(player_wins, player_lose, by = NULL, copy = TRUE)
  
  # calculate career stats for all player matches
  player_career <- player_join %>%
    mutate(height = (w_height + l_height)/2,
           breakpoint_saved_pct = (w_breakpoint_saved_pct+l_breakpoint_saved_pct)/2,
           second_serve_win_pct = (w_second_serve_win_pct+l_second_serve_win_pct)/2,
           first_serve_pct = (w_first_serve_pct+l_first_serve_pct)/2,
           first_serve_win_pct = (w_first_serve_win_pct + l_first_serve_win_pct)/2,
           win_rate = (n_wins/(n_lose+n_wins)*100),
           age = (mean_age_w + mean_age_l) /2,
           mean_rank_points = (mean_rank_points_w + mean_rank_points_l)/2,
           ace_point_pct = (w_ace_point_pct+l_ace_point_pct)/2) %>%
    
    select(player_id,height,breakpoint_saved_pct,second_serve_win_pct,
           first_serve_pct,first_serve_win_pct, win_rate,age,mean_rank_points,
           ace_point_pct) %>%
    
    drop_na()
  
  return (player_career)
}