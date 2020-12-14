
data %>% group_by(zone, swingtakewhiff) %>%
    summarize(value = n()) %>%
    drop_na() %>%
    ggplot(aes(x = zone, fill = swingtakewhiff, y = value)) +
    geom_bar(position = "fill", stat="identity") +
    xlab("Zone") +
    ylab("Percentage") +
    labs(fill = "")



data %>% 
    filter( pitch_type %in% c("CU")) %>%
    mutate( velo_int = cut(release_speed, 
                           breaks = seq(from = 70, to = 90, by = 2),
                           # labels = FALSE,
                           dig.lab = 10),
            spin_int = cut(release_spin_rate,
                           breaks = seq(from = 1600, to = 3600, by = 200),
                           # labels = FALSE,
                           dig.lab = 10)) %>%
    group_by( velo_int, spin_int ) %>%
    summarize( whiff_count = sum(swingtakewhiff %in% c("whiff")),
               total_count = n(),
               whiff_rate = whiff_count / total_count ) %>%
    drop_na() %>%
    ggplot(aes(x = velo_int, y = spin_int)) + 
    geom_raster(aes(fill = whiff_rate)) +
    scale_fill_viridis_c(option = "inferno") +
    geom_text(aes(label = percent(whiff_rate, accuracy = 0.1)),
              color = "white") +
    xlab("Curveball Velocity (MPH)") + 
    ylab("Curveball Spin Rate (RPM)") + 
    labs(fill = "Whiff rate")


data %>% filter(plate_x >= -3 & plate_x <= 3 & plate_z <= 6 & plate_z >= -2) %>%
    mutate(swing_int = as.numeric(swingtakewhiff %in% c("swing", "whiff"))) %>%
ggplot(aes(x = plate_x, y = plate_z, z = swing_int)) + 
    scale_fill_viridis_c(option = "inferno") +
    stat_summary_hex(bins = 30) + 
    geom_rect(aes(xmin = -1.41, xmax = 1.41, ymin = 0, ymax = 3.80),
              fill = NA, color = 'white') +
    xlab("Pitch Horizontal Position (Catcher's Perspective)") + 
    ylab("Pitch Vertical Position (Catcher's Perspective)") + 
    labs(fill = "Swing+Whiff Rate")

    

data %>% 
    filter( pitch_type %in% c("CU")) %>%
    mutate( pfxx_int = cut(pfx_x, 
                           breaks = seq(from = -2, to = 2, by = 0.4),
                           # labels = FALSE,
                           dig.lab = 10),
            pfxz_int = cut(pfx_z,
                           breaks = seq(from = -2, to = 2, by = 0.4),
                           # labels = FALSE,
                           dig.lab = 10)) %>%
    group_by( pfxx_int, pfxz_int ) %>%
    summarize( whiff_count = sum(swingtakewhiff %in% c("whiff")),
               total_count = n(),
               whiff_rate = whiff_count / total_count ) %>%
    drop_na() %>%
    ggplot(aes(x = pfxx_int, y = pfxz_int)) + 
    geom_raster(aes(fill = whiff_rate)) +
    scale_fill_viridis_c(option = "inferno") +
    geom_text(aes(label = percent(whiff_rate, accuracy = 0.1)),
              color = "white") +
    xlab("Curveball Horizontal Movement") + 
    ylab("Curveball Vertical Movement") + 
    labs(fill = "Whiff rate")


ggplot(testset, aes(x = plate_x, y = plate_z, z = as.numeric(stw_correct)))  + 
    # scale_fill_gradient2(low = "#000000", mid = "#D22020", high = "#27FF00", midpoint = 0.5) +
    scale_fill_viridis_c(option = "inferno") +
    stat_summary_hex(bins = 40) + 
    geom_rect(aes(xmin = -1.41, xmax = 1.41, ymin = 0, ymax = 3.80),
              fill = NA, color = 'black') +
    xlab("Pitch Horizontal Position (Catcher's Perspective)") + 
    ylab("Pitch Vertical Position (Catcher's Perspective)") + 
    labs(fill = "Prediction\nAccuracy Rate")
    