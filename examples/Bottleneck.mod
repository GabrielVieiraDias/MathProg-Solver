/* # Machine Bottleneck

The task is to schedule a set of jobs on a single machine given the release
time, duration, and due time for each job. 

| JOBS | Release | Dur. | Due |
| :--: | :-----: | :--: | :-: |
| A | 2 | 5 | 10 |
| B | 5 | 6 | 21 |
| C | 4 | 8 | 15 |
| D | 0 | 4 | 10 |
| E | 0 | 2 |  5 |
| F | 8 | 3 | 15 |
| G | 9 | 2 | 22 |

*/

set JOBS;

param rel{JOBS} default 0;   # Time a job is available to the machine
param dur{JOBS};             # Job duration
param due{JOBS};             # Job due time

/* Data Checks */
check {k in JOBS}: rel[k] + dur[k] <= due[k];

/* The model uses a 'Big M' implementation of disjunctive constraints
to avoid conflicts for a single machine.  Big M should be larger than
the longest time horizon for the completion of all jobs. A bound
on the longest horizon is the maximum release plus the sum of
durations for all jobs. */

param BigM := (max {k in JOBS} rel[k] ) + sum{k in JOBS} dur[k];

/* Decision variables are the start times for each job, and a
disjunctive variable y[j,k] which is 1 if job j precedes job k on
the machine. */

var start{JOBS} >= 0;
var pastdue{JOBS} >= 0;
var y{JOBS,JOBS} binary;

/* There are many possible objectives, including total pastdue, maximum
pastdue (i.e., tardiness), number of jobs pastdue.  */

minimize OBJ : sum {k in JOBS} pastdue[k];

/* Order Constraints */

s.t. START {k in JOBS}: start[k] >= rel[k];
s.t. FINIS {k in JOBS}: start[k] + dur[k] <= due[k] + pastdue[k];

/* Machine Conflict Constraints */

s.t. DA {j in JOBS, k in JOBS : j < k}:
   start[j] + dur[j] <= start[k] + BigM*(1-y[j,k]);
s.t. DB {j in JOBS, k in JOBS : j < k}:
   start[k] + dur[k] <= start[j] + BigM*y[j,k];

solve;

/* Create Tables */

table tout {k in JOBS} OUT "GCHART" "Schedule" "ColumnChart":
    k~Job, rel[k]~Release, start[k]~Start, start[k]+dur[k]~Finish, due[k]~Due;

table tout {k in JOBS} OUT "GCHART" "Schedule":
    k~Job, rel[k]~Release, start[k]~Start, start[k]+dur[k]~Finish, due[k]~Due;

/* Print Report */

printf " Task     Rel     Dur     Due   Start  Finish Pastdue\n";
printf {k in JOBS} "%5s %7g %7g %7g %7g %7g %7g\n",
   k,rel[k],dur[k],due[k],start[k],start[k]+dur[k],pastdue[k];

data;

/* Machine Bottleneck Example from Christelle Gueret, Christian Prins,
Marc Sevaux, "Applications of Optimization with Xpress-MP," Chapter 5,
Dash Optimization, 2000. */

param: JOBS : rel   dur   due :=
         A      2     5    10
         B      5     6    21
         C      4     8    15
         D      0     4    10
         E      0     2     5
         F      8     3    15
         G      9     2    22 ;

end;