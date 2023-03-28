# Predicting Win Rate of Tennis Players

DSCI 310 Group 16 project on Predicting Win Rate of Tennis Players done in Jupyter Notebook using R.

### Table of Contents
=================

* [Predicting Win Rate of Tennis Players](#predicting-win-rate-of-tennis-players)
      * [Table of Contents](#table-of-contents)
   * [Authors/Contributors:](#authorscontributors)
   * [Summary of Project](#summary-of-project)
   * [Important Project Rules and Regulations](#important-project-rules-and-regulations)
   * [Detailed Analysis](#detailed-analysis)
   * [Dependencies required](#dependencies-required)
   * [How to reproduce this project's Analysis.](#how-to-reproduce-this-projects-analysis)
      * [1. Set Up Your Environment](#1-set-up-your-environment)
      * [2. Pull down docker image](#2-pull-down-docker-image)
      * [3. Run docker image](#3-run-docker-image)
      * [4. Reproduce Analysis](#4-reproduce-analysis)
   * [Licenses](#licenses)

=================

## Authors/Contributors:
* Ammar Bagharib  
* Miles Brodie  
* Sammy Gulipalli   

## Summary of Project
The goal of this project is to predict the win rate of tennis players using machine learning techniques. The motivation behind this project is to explore the relationship between various player statistics and their win rate, and to develop a model that can accurately predict a player's win rate based on these statistics. The analysis has been carried out in R using various packages from the tidyverse and tidymodels ecosystems.
    
## Important Project Rules and Regulations
- [Project Contributing Guide](https://github.com/mjbrodie/dsci-310-group-16/blob/main/CONTRIBUTING.md)
- [Code of Conduct](https://github.com/mjbrodie/dsci-310-group-16/blob/main/CODE_OF_CONDUCT.md)

## Detailed Analysis
The detailed analysis files can be found [**here**](https://github.com/mjbrodie/dsci-310-group-16/blob/main/Analysis)
    
## Dependencies required
The following are dependencies used within this project, and that which is necessary to reproduce an identical analysis.
| Package Name | Version |
| ------------ | ------- |
| R | 4.1.3   |
| data.table | 1.12.8   |
| GGally | 2.1.0   |
| here | 1.0.1 |
| kknn | 1.3.1 |
| tidymodels | 0.1.1 |
| tidyverse | 1.3.0 |
   see [Dockerfile](Dockerfile)
   
## How to reproduce this project's Analysis. 
### **1. Set Up Your Environment**

- Sign up/ Log in a [Docker](https://hub.docker.com) account.

- Install Docker in your computer.

Fork this project's repository on GitHub and then clone the fork to your local machine. For more details on forking see the [GitHub
Documentation](https://help.github.com/en/articles/fork-a-repo). Type in the following command in your Terminal.
```
$ git clone https://github.com/mjbrodie/dsci-310-group-16
```
To keep your fork up to date with changes in this repo, you can use the fetch upstream button on GitHub. More details regarding fork syncing, e.g., syncing from your terminal instead of directly on Github can be found [**here**](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork). 

Then, fire up your Terminal on your local machine, and using Docker, follow these steps to reproduce this analysis:

### **2. Pull down docker image**

Type in the following command in Terminal.
```
docker pull mjbrodie/dsci-310-group-project:latest
```

### **3. Run docker image**

Run the Docker appliation on your local machine. Then, run the following in your terminal. For now, we've set PASSWORD of the rstudio container to be "asdf". You can change it anytime you'd like.
```
docker run -e PASSWORD=asdf -p 8787:8787 mjbrodie/dsci-310-group-project:latest
```

### **4. Reproduce Analysis**

Run your preferred browser, (we used Chrome) and visit http://localhost:8787/

Once done, within the terminal in the Rstudio, hit:
```
make all
```

   
## Licenses
- MIT license for project analysis (completed in Rmarkdown)
