# Mocafe

Mocafe is a fully automated cafe.

## Area of Investigation
The usage of machine learning for decision-making in an autonomic system is being investigated. More specifically, the model has to make decisions with competing priorities.

### What Is An Autonomic System
An autonomic system has the following **properties**:
- self-configuring
- self-healing
- self-optimising
- self-protecting

Also, its **main objective** is to render computing systems as self-managed. In other words, it aims to minimise the need for human intervention. In the autonomic computing vision, human administrators merely specify the computer system’s high-level business goals. These goals subsequently serve as guidance to the underlying autonomic processes. In such settings, human administrators can more readily concentrate on defining high-level business objectives, or policies, and are freed from dealing with the lower-level technical details necessary to achieve such objectives, as these tasks are now performed by the autonomic system.

### What Is Decision-Making With Competing Priorities
When multiple goals are specified for an autonomic system, some goals may often come into conflict with one another, as optimising towards one goal might hinder progress towards another. The autonomic system has to be able to take a decision at any given moment that optimises this tradeoff.

## Problem Modelling
The problem situation is modelled by Mocafe, a cafe looking to use autonomic systems in our processes. The rest of the problem will be layed out in this client-vendor relationship. The goal is to build an ML model that Mocafe can use to streamline one part of our operations.

More specifically, the part that we want to focus on is our drink pricing. We would like the price of the drink, $P$, to vary based on demand. Based on the volume of customers, we would like to maximise profits, $\pi$ over each episode (20 000 timesteps), which is modelled by:


$$
\pi = \sum_{t=0}^{20 000} N \cdot P
$$

where:
- $t$ is the current timestep
- $N$ is the number of customers(defined in the following section)
- $P$ is the price of the drink

### Varying Number of Customers, $N$

The number of customers will vary according to a linear demand curve defined as:

$$
P = -0.5N + 8
$$

Thus, the number of customers at a given drink price will be:

$$
N = 16-2P
$$

### Parameters
State:
- number of customers at current timestep
- current price of drink

Actions possible:
- increaseDrinkPrice(10, 20, 30, 40, 50, 100)
- decreaseDrinkPrice(10, 20, 30, 40, 50, 100)

### Reward Function
At each timestep, the agent receives a reward to signal the efficiency of his actions. The reward, $R$, at timestep $t$, is given as the profits made in that timestep:

$$
R_t= \pi_{t}
   = N_t \cdot P_t
$$

