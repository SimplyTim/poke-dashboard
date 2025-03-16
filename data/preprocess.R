library(tidyverse)

# Load data
pokemon <- read.delim("raw/pokemon.csv",
                      sep="\t",
                      fileEncoding = "UTF-16LE",
                      encoding = "UTF-8")

# Preprocessing
# Create column that gives capture rate in percentage.
# In some cases, the primary and secondary types were the same.
# In this case, the secondary type column was changed to blank

pokemon <- pokemon |> 
  mutate(capture_rate_perc = round(as.numeric(capture_rate)/255 * 100, 2),
         secondary_type = if_else(primary_type == secondary_type, 
                                  "", 
                                  secondary_type))

write_delim(pokemon, 
            delim = "\t", 
            "processed/pokemon_cleaned.csv",
            eol = "\n")
