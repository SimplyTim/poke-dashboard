# Poké-DashBoard
This is a dashboard made with Shiny in R. It serves as a PokeDex to give information about all Pokemon (up to Generation 8)! 😄

----

# Motivation

Target audience: Pokémon Novices

Pokémon is a franchise that has existed since 1996 and is well-loved by all ages. As per Generation 8, there were **close to 900** different Pokémon, which could be a bit intimidating to new-comers of the franchise. A **PokéDex** is a device in the Pokémon world that gives information about each Pokémon. This dashboard seeks to achieve this, aimed at novices of the franchise to learn a bit about the different types Pokémon and motivating them to dive deeper into the video games and even trading cards. Even Pokémon experts can enjoy this fun dashboard, which gives a GIF, brief description, basic information, base stats and type matchups for each Pokémon!

Gotta catch 'em all!

----

# App Description

<INSERT VIDEO HERE>

----

# Installation Instructions

This application is deployed online [here](https://poke-dashboard.onrender.com/), but if you would like to run it locally, follow these steps:

1. Clone this repository into a folder by using the following command in the desired directory:

```bash
git clone https://github.com/SimplyTim/poke-dashboard.git
```

2. Open [R Studio](https://posit.co/download/rstudio-desktop/) then
    * Go to **File**
    * Select **New Project**, then **Existing Directory**
    * Navigate to the newly cloned `poke-dashboard` folder and click **Create Project**

3. Now that you have opened the project, you now need to install the dependencies. Use these commands in the R console to install these:

```R
install.packages("shiny")
install.packages("bslib")
install.packages("tidyverse")
install.packages("plotly")
```

4. Once these dependencies are installed, we can now simply run the app! To do this, use this command in the R console:

```R
shiny::runApp('src')
```

Alternatively, you can navigate to the `src` folder, open the `app.R` file and click "Run App" on the R Studio GUI.

5. That's it! Your app should now pop-up in a window or your browser!

----

# Attributions

The dataset obtained for this project was downloaded from [Kaggle](https://www.kaggle.com/datasets/rounakbanik/pokemon).
The sprites were obtained from [PokeAPI GitHub Repository](https://github.com/PokeAPI/sprites/tree/master/sprites/pokemon).


