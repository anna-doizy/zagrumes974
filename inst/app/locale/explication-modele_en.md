Here we present the results of a **model for the development of an HBL epidemic in a fictitious citrus plot**. 

### Setting up and definition

The fictitious plot is 67 km square. It contains 500 plots with areas ranging from 0 to 7 hectares.

Despite the choice of representation with large dots, note that the plots do not touch each other. They are at least 60 metres apart.

We define the **health status** of a plot as follows:

- **healthy**: HLB is not present in the plot (green / saine)
- **infected**: HLB is present in the plot, but has not yet spread to other plots in the vicinity (orange / infectée)
- **infective**: the disease present in the plot is spreading to the surrounding plots (red / infectieuse)
- **uprooted**: the plot has been uprooted (black / arrachée)

NB: An infected tree will eventually die, whether it takes several months or a few years. 
Here, the simulation times are too short for the possibility of death other than by uprooting to be observed.


### Initialization of the model

A plot is infected with HLB on day 1.


### Model evolution

Every day, each plot containing a diseased tree will infect others. 

- The **R0** parameter ([basic reproduction number](https://en.wikipedia.org/wiki/Basic_reproduction_number)) is used to determine how many plots are contaminated on average by a diseased tree. We chose `R0 = 1` by default.

- The **Transmission threshold** allows to modulate the maximum distance of transmission of the disease by an infected tree. By default, there is `no limit` to the transmission distance.

- The **Removal frequency** represents the effort of disease management. These measurements are actually carried out either by the state services or by the farmer. By default, a plot containing an infected tree is randomly uprooted every `30 days`.

- The **Simulation duration** sets the end of the simulation. By default, it stops after `100 days`.


### Representation of the model results

- The first graph shows the evolution of the health status of the 500 plots during the simulation.

- Below, you can see the map of the plot that evolves over the days.
  Each point represents a citrus plot.

***

> Have fun playing around with some of the model parameters to see how this affects the spread of the disease!
