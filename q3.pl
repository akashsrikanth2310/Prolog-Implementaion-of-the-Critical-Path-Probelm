duration(a, 3).
duration(b, 4).
duration(c, 2).
duration(e, 1).
duration(d, 5).
duration(f, 2).
duration(h, 3).
duration(g, 4).

prerequisite(b, a).
prerequisite(d, b).
prerequisite(g, d).
prerequisite(h, g).
prerequisite(h, f).
prerequisite(f, c).
prerequisite(c, a).
prerequisite(e, c).
prerequisite(g, e).


isPathValid([]).
isPathValid([_]).
isPathValid([V1,V2|T]) :-
    prerequisite(V2,V1),
    isPathValid([V2|T]).

costOfThePath([X], C) :-
      duration(X, C).
costOfThePath([H|T], C) :-                
      duration(H, C1),
      costOfThePath(T, C2),
      C is C1 + C2.
                 
findLastElement([X], X).
findLastElement([_|T], X) :-
                 findLastElement(T,X).
                 
gettingAllPaths(X, [], 0) :-
                 not(prerequisite(X, _)).
gettingAllPaths(X, [P|T], C) :-
                 prerequisite(X, P),
                 duration(P, D),
                 gettingAllPaths(P, T, C1),
                 C is C1 + D.
 
gettingAllPaths(X, [], 0, _) :-
                 not(prerequisite(X, _)).
gettingAllPaths(X, [P|T],C, M) :-
                 prerequisite(X, P),
                 duration(P, D),
                 gettingAllPaths(P, T, C1),
                 C is C1 + D,
                 C > M.                  
                  
                 
criticalPath(T, P) :-
                 isPathValid(P),
                 costOfThePath(P, C),
                 findLastElement(P, L),
                 prerequisite(T, L),
                 not(gettingAllPaths(T, _, _, C)).

earlyFinish(T, Time) :-
                 not(prerequisite(T,_)),
                 duration(T,Time).

earlyFinish(T, Time):-
                 gettingAllPaths(T, P, C),
                 reverse(P, ReversePath),
                 criticalPath(T, ReversePath),
                 duration(T, D),
                 Time is C + D.    
                 
 lateStart(T, Time):-
                earlyFinish(T, D),
                duration(T, E),
                Time is D - E.

graph1(LIST) :-
    findall(VALUE, duration(VALUE,_), LIST).

graph2(VALUE,LIST):-
    findall(TEMPLATE, prerequisite(VALUE,TEMPLATE), LIST).

graph3(VALUE):-
    graph1(LIST),
    include(graph4,LIST,VALUE).

graph4(VALUE):-
    not(prerequisite(VALUE,_)).

graph5(X):-
    not(prerequisite(_,X)).

graph6(VALUE):-
        graph3(LIST),
    member(VALUE,LIST).

graph7(VALUE):-
    graph8(LIST),
    member(VALUE,LIST).

graph8(VALUE):-
    graph1(LIST),
    include(graph5,LIST,VALUE).

graph9(VALUE,LIST):-
    findall(TEMP,prerequisite(TEMP,VALUE),LIST).

graph10(VALUE,Time):-
    graph6(VALUE),
    duration(VALUE,Time).

graph10(VALUE,Time):-
    duration(VALUE,Time_1),
    not(graph6(VALUE)),
    graph2(VALUE,LIST),
    graph11(LIST,Time_2),
    Time is Time_1 + Time_2.

graph11([],0).

graph11([VALUE|LIST],Time):-
        graph10(VALUE,Time_1),
    graph11(LIST,Time_2),
    Time_1 > Time_2,
    Time is Time_1.

graph11([VALUE|LIST],Time):-
        graph10(VALUE,Time_1),
    graph11(LIST,Time_2),
    Time_1 =< Time_2,
    Time is Time_2.


graph12(VALUE,TIME):-
    graph10(VALUE,TIME),
    !.


graph13(VALUE,TIME):-
    graph12(VALUE,TIME_1),
    duration(VALUE,TIME_2),
    TIME is TIME_1-TIME_2.

graph14(TIME):-
    findall(TIME,graph10(_,TIME),LIST),
    graph15(LIST,TIME),
    !.


graph15([],0).


graph15([VALUE|OTHER],MAXVALUE) :-
    graph15(OTHER,OTHERMAX),
    VALUE > OTHERMAX,
    MAXVALUE is VALUE.

graph15([VALUE|OTHER],MAXVALUE) :-
    graph15(OTHER,OTHERMAX),
    VALUE =< OTHERMAX,
    MAXVALUE is OTHERMAX.

graph16(VALUE,TIME):-
    graph18(VALUE,TIME_1),
    duration(VALUE,TIME_2),
    TIME is TIME_1-TIME_2.

graph17(VALUE,TIME):-
    graph7(VALUE),
    graph14(TIME).


graph17(VALUE,TIME):-
    not(graph7(VALUE)),
    graph9(VALUE,TEMP),
    graph19(TEMP,TIME).


graph18(VALUE,TIME):-
    graph17(VALUE,TIME),
    !.

graph19([],inf).


graph19([VALUE|OTHER],TIME):-
        graph16(VALUE,TIME_1),
    graph19(OTHER,TIME_2),
    TIME_1 < TIME_2,
    TIME is TIME_1.


graph19([VALUE|OTHER],TIME):-
        graph16(VALUE,TIME_1),
    graph19(OTHER,TIME_2),
    TIME_1 >= TIME_2,
    TIME is TIME_2.

utilstack(VALUE,TIME):-
    graph16(VALUE,TIME_1),
    graph13(VALUE,TIME_2),
    TIME is TIME_1-TIME_2.

graphstack(VALUE,TIME):-
    duration(VALUE,_),
    utilstack(VALUE,TIME).


maximumslackvalue(TIME):-
    findall(TIME,graphstack(_,TIME),LIST),
    graph15(LIST,TIME),
    !.

maxSlack(VALUE,TIME_1):-
    graphstack(VALUE,TIME_1);
    graphstack(VALUE,TIME_3),
    maximumslackvalue(TIME_2),
    TIME_3 is TIME_2.