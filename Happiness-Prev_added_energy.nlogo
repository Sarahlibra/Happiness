


;;======================================GLOBAL VARUABLES=========================================
globals
[
  ;; Globals in the interface ;;
  ;Population
  ;inspiring-egos
  ;Happy-possibility
  ;max-happiness-level
  ;neighbor-capacity
  ;min-neighbor-count
  ;neighbor-capacity


  death-number                               ;;keeps the number of agents died till now
  max-initial-energy
  max-patch-energy
  e-step-length                              ;;as energy increases, the length of step one can have can be grown
  e-radius-of-sight                           ;;radious of neighborhood
]

;;========================================MULTIPLE RUN===========================================
to multi-run                                   ;; This part is only for the multiple run (uses two top parameters input: number of inspiring agents and run!)
  ;set inspiring-egos 1

  ;loop [
    let counter 1
    let avg-success 0
    ;set inspiring-egos inspiring-egos * 2
    print (inspiring-egos)

    while[counter <= number-of-run]
    [
      set counter counter + 1

      setup
      go

      ;print ("Run ")
      ;print (counter - 1)
      ;print ("- : ")
      ;print (count egos with [p-happinessLevel > 0 ]) / Population

      set avg-success avg-success + ((count egos with [e-happinessLevel > 0 ]) / Population)

      if (counter > number-of-run) [
        print (avg-success / number-of-run)
        stop
      ]
    ;]
    ;if (inspiring-egos > 470) [
     ;   stop
    ;]

  ]
end
;;========================================INITIALIZATION=========================================
breed [egos ego]

;;basic info
egos-own [
  e-happinessLevel                            ;;ego happiness-level - initialized by a random number between -10 and 10
  e-suicide-threshold                         ;;the sadness after which the ego would suicide

  e-energy                                    ;;ego energy affected by happiness

  ;;personality info
  e-sensitivity                            ;;the fact of being likely or liable to be influenced by peers
  e-convincing                            ;;the ability of influencing others
  ;;====> there should be an inverse-relation between these two parameters

  ;e-extend-threshold                          ;;when the energy raises to the threshold the step-length would become twice
]

patches-own [
 energy-capacity                               ;;average capacity of energy that a location can give people
]

;;===========================================SETUP===============================================
to setup                                      ;;initial settings would be written here
  clear-all                                   ;;clear all the previous agents and setting
  setup-global-vars
  setup-patches                               ;;initialize the setting of the patches
  setup-egos                                  ;;initialize the setting of the egos' feature
  ;setup-labels
  setup-inspiring-people inspiring-egos
  reset-ticks                                 ;;reset the tick count to zero
end

;;-------------------------------------------Sub procedures-------------------------------------

to setup-global-vars
  set max-patch-energy 100
  set max-initial-energy 100
  set e-step-length 1                          ;;the length of each step of the agent (step-length)
  set e-radius-of-sight 1                      ;;
end

;;-----------------------------initialize the setting of the patches-------------------------------
to setup-patches                              ;;initialize the patches apperance
  draw-background-color                       ;;color the background of the patches
  draw-gridlines                              ;;draw gridlines between patches
  setup-patches-energy                        ;;
  ;setup-patches-normal-energy
  setup-patch-color
end

to setup-patch-color
  ask patches
  [
    set pcolor (((energy-capacity / 100.0) * 10.0) + 60)
    if energy-capacity = 100 [set pcolor 69]
  ]
end

to setup-patch-label
  ask patches
  [
    set plabel-color black
    set plabel energy-capacity
  ]
end
to setup-patches-energy
  ask patches[
    set energy-capacity random max-patch-energy;;set the amount of energy this location is able to give agents
    ;set energy-capacity 0;;set the amount of energy this location is able to give agents
    ;set plabel-color black
    ;set plabel energy-capacity

  ]
end
to setup-patches-normal-energy
  let inc max-patch-energy / (max-pxcor / 2)

  ask patches
  [
    let x abs ((max-pxcor / 2) - pxcor)
    let y abs ((max-pycor / 2) - pycor)

    ifelse x > y
    [
      set energy-capacity max-patch-energy - (x * inc)
      ;if x = 15 [set energy-capacity 0]
    ]
    [
      set energy-capacity 100 - (y * inc)
      ;if y = 15 [set energy-capacity 0]
    ]
  ]
end

;;----------------------coloring the background of the environment (white)-------------------------
to draw-background-color                      ;;set the background color of the patches
  ask patches[
    set pcolor white                          ;;make the main background color white
  ]
end

;;----------------------------to draw a grid lines for the patches--------------------------------
;;Reference of this snippet for drawing gridline is: http://complexityblog.com/blog/index.php?itemid=69
to draw-gridlines                             ;;This method is drawing the grids using new turtles

  ;;drawing vertical lines
  crt world-width [                           ;;the number of turtles that are created are equals to the length of the world width
    set ycor min-pycor                        ;;start from the bottom of the page
    set xcor who + .5                         ;;put turtles in the sequence of .5 from each other
    set color grey                            ;;set the color of the gridlines
    set heading 0                             ;;look to the top
    pd                                        ;;pen down!
    fd world-height                           ;;go forward to the top to draw the lines
    die                                       ;;in order to prevent interfere of these turtles with others, we kill them after usign!
  ]
  ;;drawing horizontal lines:similar to the above part
  crt world-height [
    set xcor min-pxcor
    set ycor who + .5
    set color grey
    set heading 90
    pd
    fd world-width
    die
  ]
end

;;----------------------------initialize the setting of the egos----------------------------------
to setup-egos
    create-egos Population ;; create "population" numbers of egos
    ask egos [

      setxy random-xcor random-ycor           ;; randomly spread egos in the world
      ;move-to one-of patches with [ not any? turtles-here ]

      let rnd_num random-float 1
      if (rnd_num < (Happy-possibility / 100.0))[
         set e-happinessLevel (random (max_happiness_level) + 1)  ;;make their happiness random number between -10 to +10
      ]
      if (rnd_num > (Happy-possibility / 100.0))
      [
         set e-happinessLevel (random (max_happiness_level) - (max_happiness_level))  ;;make their happiness random number between -10 to +10
                                              ;;each agent level of happiness
      ]
      if (rnd_num = (Happy-possibility / 100.0))
      [
        set e-happinessLevel 0
      ]

      ;;convincing and sensitivity
      ifelse (negative-convincing)
      [
        set e-convincing random-float 2 - 1
      ]
      [
        set e-convincing random-float 1
      ]
      ifelse (negative-sensitivity)
      [
        set e-sensitivity random-float 2 - 1
      ]
      [
        set e-sensitivity random-float 1
      ]

      set e-energy max-initial-Energy             ;;initialize egos energy
      ;set p-homophily-desire-threshold homophily-desire-threshold ;;the desire to be near a person similar to itself!

      ;;not used yet
      ;set p-extend-threshold (max_happiness_level - 1)
      set e-suicide-threshold (max_happiness_level - 1) * (-1)
      ;set e-energy random max-initial-energy

      color-emotion ;;set their appearance based on their happiness level
   ]
end
;;----------------------------initialize the setting of the labels----------------------------------
to setup-labels
  ask egos [
    set label-color black
  ]
end
;;----------------------------create and setup the inspiring people----------------------------------
to setup-inspiring-people [numbers]
  ask n-of numbers egos[
    set e-convincing 1
    set e-sensitivity 0
    set e-happinessLevel max_happiness_level
    ]
end
;;============================================GO================================================
to go
  while[ticks < Tick-limit]
  [
    ask egos [
      move                                       ;;this function checks if the place is not satisfying, the agent would move!
      ;; constraint of energy ==> prevent ranning out of energy!
      socialize                                  ;;this function would simulate socialization among ago and its alter!

      update-energy                             ;;this function would update the energy depends on the emotional state
      check-death                              ;;this function would kill the agents who ran out of energy
      color-emotion                              ;;depend on the emotional state (positive or negative) the shape and color of agents would change in this method
    ]

    ;ask patches
    ;[
      ;update-energy                              ;;this function would update the energy depends on the Location state
    ;]

    ;check-end
    tick
  ]                                         ;;set counter to the next tick
end

;;==========================================PROCEDURES==========================================

;;--------------------------------------------Move----------------------------------------------
;;moving an ego when s/he is not fine with the location
to move                                       ;;the more difference, the more possible to move
  ;if (e-energy > ((energy-per-step) * e-step-length) and not-satisfying-place = 1)               ;;check if the location is the place it wants, change the place!
  ;[change-place]                              ;;change the place to a random cell around
  if (e-energy > ((energy-per-step) * e-step-length))
  [
    ifelse not-satisfying-place = 1
    [
      change-place
    ]
    [
      consider-opportunities
    ]
  ]
  ;; eventhough, it is satisfying patch, but there is a tempting neighbor patch move to there



  ;; the nature of the relationship can prevent individual from moving!
  ;; energy-level also should effect moving (if energy is less than s.th it cannot move, the priority of energy and the nature of relationship can be competetitive!!)
  ;; energy-level of individual = society - my_unhappiness
  ;; moving consumes energy but a satisfying state can increase the energy
  ;; how to compute satisfaction of a state
  ;; what is the computation relation of statisfaction, agents' dependency (relation), energy and movement and happiensss =))
  ;; witness for the computation that we propose!


end

;;moving to a random place
to change-place
  ;move-to one-of neighbors with [ not any? turtles-here ]
  right random 360
  if count turtles-on patch-ahead e-step-length < neighbor-capacity
  [
    forward e-step-length
    set e-energy e-energy - ((energy-per-step) * e-step-length)
  ]

end

;;check if the agent is not satisfied with the place it stays
to-report not-satisfying-place                 ;;depends on the difference between agent happiness and the average of the neighbor, and the agents' homophily, agent would satisfies or not
  let neighbor-count 0

  ask egos in-radius e-radius-of-sight         ;;calculate the difference of agents with the neighbors
  [
    set neighbor-count neighbor-count + 1
  ]

  ifelse (neighbor-count < min-neighbor-count) ;; if its a too sparce or crowded or too different neighbor => move!
  [report 1]
  [report 0]

end

to consider-opportunities

  ;find the patch neighbors
  let current-patch patch-here
  let max-patch current-patch
  let max-energy 0

  let rnd-decision random-float 1

  if rnd-decision < greed-factor
  [
    ask current-patch
    [
      let neighbor-patches patches in-radius 1
      set max-energy energy-capacity

      ;find the neighbor with the max energy-capacity
      ask neighbor-patches
      [
        if energy-capacity > max-energy
        [
          set max-patch myself
          set max-energy energy-capacity
        ]
      ]
    ]
  ]

  ;if the energy is higher than the current patch => change to that max
  if (max-patch != current-patch) and (count turtles-on max-patch < neighbor-capacity)
  [
    move-to max-patch
    set e-energy e-energy - ((energy-per-step) * e-step-length)
  ]


end
;;------------------------------------------Socialize
to socialize
  ;; each agent set its happiness based on the neighbors!
  ;; select one neighbor and exchange happiness! :D

  let ego-neighbors egos in-radius e-radius-of-sight
  let ego-happiness e-happinessLevel

  let ego-sensitivity e-sensitivity                            ;;the fact of being likely or liable to be influenced by peers
  let ego-convincing e-convincing                            ;;the fact of being likely or liable to be influenced by peers
  let ego-happinessLevel e-happinessLevel

  ask one-of ego-neighbors[                                          ;;the paper calls them alter
                                                                     ;;based on the susceptibility of the ego and persuasiveness of the alter we update the ego happiness
    ;;Two way influence and socialization
    ;;
    ;if (e-convincing + ego-susceptibility != 0) [set ego-happiness ((e-convincing * e-happinessLevel) + (ego-susceptibility * ego-happiness))/ (e-convincing + ego-susceptibility)]
    if ((ego-sensitivity * e-convincing * e-happinessLevel) != 0)
    [
      set ego-happiness (((ego-sensitivity + e-convincing) * e-happinessLevel) + ego-happiness) / (ego-sensitivity + e-convincing + 1)
    ]
    if ((e-sensitivity * ego-convincing * ego-happinessLevel) != 0)
    [
      set e-happinessLevel (((e-sensitivity + ego-convincing) * ego-happinessLevel) + e-happinessLevel) / (e-sensitivity + ego-convincing + 1)
    ]

  ]

  set e-happinessLevel ego-happiness
  if (e-happinessLevel > max_happiness_level) [set e-happinessLevel max_happiness_level]
  if (e-happinessLevel < (-1 * max_happiness_level)) [set e-happinessLevel (max_happiness_level * -1)]

end


;;check if the agent is dead
to check-death
  ask egos [
    if (e-happinessLevel < e-suicide-threshold)
    ;if (e-energy < 0) or (e-happinessLevel < e-suicide-threshold)
    [
      ;;we consider a threshold of happiness as a suicide threshold where the person cannot tolerate the life and kill itself!
      set death-number death-number + 1     ;;counting the number of dead people
      die                                   ;;kill the agent
    ]
  ]
end

;;------------------------------------------Interface Design

to color-emotion                            ;;this method change the shape and color of the face depend on happiness level

  let div-parts max_happiness_level / 6
  let factor e-happinessLevel / div-parts

  ifelse e-happinessLevel > 0               ;;show happy people with red happy face and sadness with blue sad face
  [
    set color 19 - factor                   ;;the happier, the darker red => 12-19
    set shape "face happy"
    if color > 19 [set color 19]
    if color < 12 [set color 12]
  ]
  [
    set color 99 - (-1 * factor)            ;;the sader, the darker blue => 92-99
    set shape "face sad"
    if color > 99 [set color 99]
    if color < 92 [set color 92]
  ]
  if e-happinessLevel = 0
  [
    set color 9.9
  ]

end

;;-----------------------------------------Check The End of Simulation
to check-end
  if (ticks > Tick-limit)
  [stop]
end

;;-----------------------------------------Energy and happiness
;;---------------update-energy-----------------------
to update-energy
  let ego-count count egos-here
  let sum-of-happiness 0.0

  ;let random-from-loc random [energy-capacity] of patch xcor ycor
  ask egos-here
  [
    set sum-of-happiness sum-of-happiness + e-happinessLevel + max_happiness_level
  ]
  ask egos-here
  [
    if (sum-of-happiness != 0)
    [
      let happy-ratio (e-happinessLevel + max_happiness_level) / sum-of-happiness
      set e-energy e-energy + (happy-ratio * (energy-capacity))
      ;let happy-ratio ( + max_happiness_level) / (2 * max_happiness_level)
      ;set label e-energy
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
709
11
1052
375
-1
-1
10.765
1
10
1
1
1
0
1
1
1
0
30
0
30
1
1
1
ticks
20.0

BUTTON
24
71
89
106
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
24
108
89
142
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
87
148
156
193
NIL
count egos
17
1
11

MONITOR
24
148
81
193
NIL
ticks
17
1
11

SLIDER
177
84
349
117
Population
Population
0
6000
500
1
1
NIL
HORIZONTAL

MONITOR
24
246
156
291
Average Happiness
mean [e-happinessLevel] of egos
17
1
11

MONITOR
24
196
157
241
NIL
death-number
17
1
11

PLOT
29
413
279
561
Happy - Sad pop
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"happy" 1.0 0 -2674135 true "" "plot count egos with [e-happinessLevel > 0 ]"
"sad" 1.0 0 -13345367 true "" "plot count egos with [e-happinessLevel < 0 ]"

SLIDER
176
120
349
153
Happy-possibility
Happy-possibility
0
100
50
1
1
NIL
HORIZONTAL

BUTTON
91
71
154
106
clear
clear-all\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
352
10
524
43
energy-per-step
energy-per-step
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
179
265
352
298
min-neighbor-count
min-neighbor-count
0
10
4
1
1
NIL
HORIZONTAL

SLIDER
175
156
349
189
max_happiness_level
max_happiness_level
0
100
100
1
1
NIL
HORIZONTAL

SWITCH
354
72
523
105
negative-convincing
negative-convincing
1
1
-1000

SLIDER
178
228
350
261
neighbor-capacity
neighbor-capacity
1
20
4
1
1
NIL
HORIZONTAL

PLOT
548
413
795
560
Average Energy Level
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Average-Energy" 1.0 0 -16777216 true "" "if (count egos > 2) [plot mean [e-energy] of egos]"
"pen-1" 1.0 0 -5298144 true "" "if (count egos with [e-happinessLevel > 0 ] > 2) [plot mean [e-energy] of egos with [e-happinessLevel > 0 ]]"
"pen-2" 1.0 0 -14454117 true "" "if (count egos with [e-happinessLevel < 0 ] > 2) [plot mean [e-energy] of egos with [e-happinessLevel < 0 ]]"

MONITOR
24
295
158
340
Variance Happiness
variance [e-happinessLevel] of egos
17
1
11

SLIDER
181
355
353
388
Tick-limit
Tick-limit
0
5000
1500
1
1
NIL
HORIZONTAL

PLOT
286
413
538
561
Average Happiness Level of Society
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (count egos > 2) [plot mean [e-happinessLevel] of egos]"
"Happy" 1.0 0 -5298144 true "" "if (count egos with [e-happinessLevel > 0 ] > 0) [plot mean [e-happinessLevel] of egos with [e-happinessLevel > 0 ] ]"
"Sad" 1.0 0 -14454117 true "" "if (count egos with [e-happinessLevel < 0 ] > 2 ) [plot mean [e-happinessLevel] of egos with [e-happinessLevel < 0 ] ]"

PLOT
803
409
1039
559
Variance of Happiness Level
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if (count egos > 0) [plot variance [e-happinessLevel] of egos ]"
"Happy" 1.0 0 -2674135 true "" "if (count egos with [e-happinessLevel > 0 ] > 2) [plot variance [e-happinessLevel] of egos with [e-happinessLevel > 0 ] ]"
"pen-2" 1.0 0 -13791810 true "" "if (count egos with [e-happinessLevel < 0 ] > 2 ) [plot variance [e-happinessLevel] of egos with [e-happinessLevel < 0 ] ]"

BUTTON
24
16
159
49
Multiple Run
multi-run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
176
45
348
78
number-of-run
number-of-run
0
1000
0
1
1
NIL
HORIZONTAL

SLIDER
176
11
348
44
inspiring-egos
inspiring-egos
0
475
0
1
1
NIL
HORIZONTAL

BUTTON
92
109
155
142
stop
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
23
348
159
393
Average Energy
mean [e-energy] of egos
17
1
11

PLOT
1050
408
1250
558
Happiness-Ratio
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count egos with [e-happinessLevel > 0 ] / (count egos with [e-happinessLevel < 0 ] + count egos with [e-happinessLevel > 0 ])\n\n;(/((count egos with [p-happinessLevel > 0 ]) + (count egos with [p-happinessLevel < 0 ])))"
"pen-1" 1.0 0 -14454117 true "" "plot count egos with [e-happinessLevel < 0 ] / (count egos with [e-happinessLevel < 0 ] + count egos with [e-happinessLevel > 0 ])"

SWITCH
355
110
523
143
negative-sensitivity
negative-sensitivity
1
1
-1000

SLIDER
356
154
528
187
greed-factor
greed-factor
0
1
0
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This world is a model of a society with the focus on their level of happiness and the contingency of the emotional status in one society. The idea behind this model is that emotional status can flow through the people through their social interactions. The happiness level of one person can influence others who are in contact with that person. This effect has been studied in [1], where it shows the happiness of a near friend (within a mile) can increase the probability of one’s happiness by 25%. Similar effect has been seen in coresident spouses, siblings who live within a mile, and nextdoor neighbors.

## HOW IT WORKS

Basically the story of this simulation starts with a randomly distributed socializing agents, who tend to live in a satisfying environment. If the place is too sparse or crowded, or the neighbors are too different from their emotional status, they probably change their spot. Also, each person can socialize with its neighbor in the radius of its sight. During the socialization process the emotional signals transfer between agents through either effecting on someone or influencing by other agent. For limiting the model, the energy can put constraint on the agents' freedom, which is optional for now.

## HOW TO USE IT
There are 12 sliders and three switches that should be set at the beginning of the simulation. Then the "setup" button should be pressed and finally by pressing “Go” you can run and stop the simulation.
The sliders and switches and their goal are as bellow:
-	Population: the numbers of agents at the beginning of the simulation. Since there is no birth in this simulation the agent numbers wont exceed this number.
-	Happy-possibility: the possibility of being happy for an agent.
-	Min-neighbor-count: an agent doesn’t like a sparse neighbor because of both safety and physical needs of a human. Actually in this situation the body would go to the survival mode and tend to change the situation immediately [4].
-	Homophily-desire: the tendency of the agent to be near the people who are similar to itself. This number shows how much differences is acceptable for an agent.
-	Max-happiness-level: this number modifies the interval that happiness can change. The happinessLevel of an agent would be a number between (- Max-happiness-level and + Max-happiness-level)
-	Step-length: the number of block an agent move in each step (in the random direction!)
-	Radius-of-sight: this number shows how far an agent can socialize. Here we assume that each block demonstrates a 1 * 1 square-mile of a real world.
-	Neighbor-capacity: There is a capacity of living in a limited land. This limitation depends highly on the society, their resources and their culture. (For example it’s very different for the U.S. and India!)
-	Tick-limit: This number can say when to stop the simulation
-	Consider-energy?: this switch decides to either consider energy in the model and kill the agents based on their energy or not
-	Initial_energy: the amount of energy we give to the agent in the beginning of the simulation (this amount also limits the number of ticks an agent can stay alive actively by moving rather than searching forever!)
-	Energy-per-step: the amount of energy an agent consume in each step
-	Influential-possibility: the possibility of influencing other agents
-	Susceptible-possibility: the possibility of being influenced by other agents in socialization
-	normal-distribution? The random distribution of two above parameter be normal or uniform
-	negative-value? Whether consider negative value for those two parameters or not
## THINGS TO NOTICE
The first thing to notice is the agents' behavior. The way they create cluster or move chaotically. The second thing to notice is the changing color of the agent, which shows the level of happiness. The red color is related to happy egos. If the agent is darker in the color, it means that it is happier the agent. This is true for the blue color and sadness.

## THINGS TO TRY

There are few interesting things that worth trying (and this list would be completed in the report part):
- moving the happiness-possibility slider
- Turning "on" the negative-value for the influential and susceptible possibility, this makes the model behave in the chaotic way.
- moving the influential and susceptible possibility slider

## EXTENDING THE MODEL
There are some recommendation for extending the model
- adding different type of link, with different level of influence would make the model closer to the real experiment in the paper [1]. Each family, friend and sibling has different type of effect. Links can simulate these differences.
- detecting the clusters by algorithms like K-means and studying the features of each cluster. This can make our understanding of dynamics of emotion clearer.
- adding possibility of effect


## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)
The fact that Netlogo can support all turtle, patch and observer view was very helpful. Also there were some predefined function that worked with neighbor agents that simplified our work.

## CREDITS AND REFERENCES
[1] Fowler, James H., and Nicholas A. Christakis. "Dynamic spread of happiness in a large social network: longitudinal analysis over 20 years in the Framingham Heart Study." Bmj 337 (2008): a2338.
[2] Barsade, Sigal G. "The ripple effect: Emotional contagion and its influence on group behavior." Administrative Science Quaterly 47.4 (2002): 644-675.
[3] http://complexityblog.com/blog/index.php?itemid=69
[4] http://www.psychologytoday.com/blog/the-embodied-mind/201212/survival-mode-and-evolutionary-mismatch
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
