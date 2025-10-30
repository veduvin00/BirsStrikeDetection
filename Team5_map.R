# Install packages once (uncomment if needed)
# install.packages(c("readr","dplyr","stringr","purrr","sf","ggplot2","rnaturalearth","rnaturalearthdata","viridisLite","leaflet"))

library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(sf)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
library(viridisLite)
library(leaflet)

# ========= 1) Read and robustly parse the messy CSV =========

lines <- readr::read_lines("/Users/julia/Desktop/aircraft\ map\ 1/STRIKE_REPORTS.csv")

pair_regex <- "(-?\\d+\\.?\\d*)\\s*,\\s*(-?\\d+\\.?\\d*)"

coords <- map_dfr(
  str_match_all(lines, pair_regex),
  ~{
    if (is.null(.x) || nrow(.x) == 0) return(tibble(LATITUDE = numeric(0), LONGITUDE = numeric(0)))
    tibble(
      LATITUDE  = as.double(.x[,2]),
      LONGITUDE = as.double(.x[,3])
    )
  }
) %>%
  filter(!is.na(LATITUDE), !is.na(LONGITUDE),
         LATITUDE >= -90, LATITUDE <= 90,
         LONGITUDE >= -180, LONGITUDE <= 180)

# Optional: consolidate near-duplicates (same place with tiny numeric diffs)
# coords <- coords %>% mutate(LATITUDE = round(LATITUDE, 4), LONGITUDE = round(LONGITUDE, 4))

# ========= 2) Count duplicates and convert to sf =========
coords_counts <- coords %>%
  count(LATITUDE, LONGITUDE, name = "freq")

pts_sf <- st_as_sf(coords_counts, coords = c("LONGITUDE","LATITUDE"), crs = 4326, remove = FALSE)

# ========= 3) World basemap =========
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")

# View mode: full world or auto-zoom around points
view_full_world <- TRUE

if (!view_full_world && nrow(pts_sf) > 0) {
  bb <- st_bbox(pts_sf)
  x_rng <- max(1e-6, (bb["xmax"] - bb["xmin"]))
  y_rng <- max(1e-6, (bb["ymax"] - bb["ymin"]))
  xpad <- x_rng * 0.15
  ypad <- y_rng * 0.15
  xlim <- c(bb["xmin"] - xpad, bb["xmax"] + xpad)
  ylim <- c(bb["ymin"] - ypad, bb["ymax"] + ypad)
} else {
  # World-friendly extent (trim Antarctica for clarity)
  xlim <- c(-180, 180)
  ylim <- c(-60, 85)
}

# ========= 4) Static world map: points =========
p_world_points <- ggplot() +
  geom_sf(data = world, fill = "grey95", color = "grey70", linewidth = 0.2) +
  geom_sf(
    data = pts_sf,
    aes(size = freq),
    color = "#d81b60",
    alpha = 0.85,
    show.legend = TRUE
  ) +
  scale_size(range = c(1.5, 6), guide = "legend") +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  labs(
    title = "Locations from CSV (World Map)",
    subtitle = "Point size indicates duplicate count",
    x = NULL, y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.major = element_line(color = "grey90"))

print(p_world_points)

# ========= 5) Static world density heatmap =========
# Uses lon/lat directly; good for a quick view.
p_world_density <- ggplot() +
  geom_sf(data = world, fill = "grey95", color = "grey70", linewidth = 0.2) +
  stat_density_2d(
    data = coords,
    aes(x = LONGITUDE, y = LATITUDE, fill = after_stat(level)),
    geom = "polygon",
    color = NA,
    alpha = 0.7,
    contour = TRUE
  ) +
  scale_fill_viridis_c(option = "magma", direction = -1, name = "Density") +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  labs(title = "Spatial Density of Locations (World View)", x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.major = element_line(color = "grey90"))

print(p_world_density)

# ========= 6) Interactive Leaflet world map (with clustering) =========
lf <- leaflet(coords_counts) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(
    lng = ~LONGITUDE, lat = ~LATITUDE,
    radius = ~pmin(10, 3 + log1p(freq)),
    fillColor = "#2c7fb8", fillOpacity = 0.85, stroke = FALSE,
    clusterOptions = markerClusterOptions(),
    label = ~paste0("Lat: ", LATITUDE, ", Lon: ", LONGITUDE, " (n=", freq, ")")
  )

if (nrow(coords_counts) > 0) {
  lf <- lf %>% fitBounds(lng1 = min(coords_counts$LONGITUDE), lat1 = min(coords_counts$LATITUDE),
                         lng2 = max(coords_counts$LONGITUDE), lat2 = max(coords_counts$LATITUDE))
} else {
  lf <- lf %>% setView(lng = 0, lat = 20, zoom = 2)
}

lf
