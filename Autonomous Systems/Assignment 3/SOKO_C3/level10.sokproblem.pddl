(define
	(problem sokoban_gen)
	(:domain sokoban_gen)
	(:objects
		box-612 box-88 box-138 box-148 box-54 box-1310 box-412 box-129 box-79 box-613 box-52 - box
		up down left right teleport - direction
		pos-0-0 pos-0-1 pos-0-2 pos-0-3 pos-0-4 pos-0-5 pos-0-6 pos-0-7 pos-0-8 pos-0-9 pos-0-10 pos-0-11 pos-0-12 pos-0-13 pos-0-14 pos-0-15 pos-0-16 pos-0-17 pos-1-0 pos-1-1 pos-1-2 pos-1-3 pos-1-4 pos-1-5 pos-1-6 pos-1-7 pos-1-8 pos-1-9 pos-1-10 pos-1-11 pos-1-12 pos-1-13 pos-1-14 pos-1-15 pos-1-16 pos-1-17 pos-2-0 pos-2-1 pos-2-2 pos-2-3 pos-2-4 pos-2-5 pos-2-6 pos-2-7 pos-2-8 pos-2-9 pos-2-10 pos-2-11 pos-2-12 pos-2-13 pos-2-14 pos-2-15 pos-2-16 pos-2-17 pos-3-0 pos-3-1 pos-3-2 pos-3-3 pos-3-4 pos-3-5 pos-3-6 pos-3-7 pos-3-8 pos-3-9 pos-3-10 pos-3-11 pos-3-12 pos-3-13 pos-3-14 pos-3-15 pos-3-16 pos-3-17 pos-4-0 pos-4-1 pos-4-2 pos-4-3 pos-4-4 pos-4-5 pos-4-6 pos-4-7 pos-4-8 pos-4-9 pos-4-10 pos-4-11 pos-4-12 pos-4-13 pos-4-14 pos-4-15 pos-4-16 pos-4-17 pos-5-0 pos-5-1 pos-5-2 pos-5-3 pos-5-4 pos-5-5 pos-5-6 pos-5-7 pos-5-8 pos-5-9 pos-5-10 pos-5-11 pos-5-12 pos-5-13 pos-5-14 pos-5-15 pos-5-16 pos-5-17 pos-6-0 pos-6-1 pos-6-2 pos-6-3 pos-6-4 pos-6-5 pos-6-6 pos-6-7 pos-6-8 pos-6-9 pos-6-10 pos-6-11 pos-6-12 pos-6-13 pos-6-14 pos-6-15 pos-6-16 pos-6-17 pos-7-0 pos-7-1 pos-7-2 pos-7-3 pos-7-4 pos-7-5 pos-7-6 pos-7-7 pos-7-8 pos-7-9 pos-7-10 pos-7-11 pos-7-12 pos-7-13 pos-7-14 pos-7-15 pos-7-16 pos-7-17 pos-8-0 pos-8-1 pos-8-2 pos-8-3 pos-8-4 pos-8-5 pos-8-6 pos-8-7 pos-8-8 pos-8-9 pos-8-10 pos-8-11 pos-8-12 pos-8-13 pos-8-14 pos-8-15 pos-8-16 pos-8-17 pos-9-0 pos-9-1 pos-9-2 pos-9-3 pos-9-4 pos-9-5 pos-9-6 pos-9-7 pos-9-8 pos-9-9 pos-9-10 pos-9-11 pos-9-12 pos-9-13 pos-9-14 pos-9-15 pos-9-16 pos-9-17 pos-10-0 pos-10-1 pos-10-2 pos-10-3 pos-10-4 pos-10-5 pos-10-6 pos-10-7 pos-10-8 pos-10-9 pos-10-10 pos-10-11 pos-10-12 pos-10-13 pos-10-14 pos-10-15 pos-10-16 pos-10-17 pos-11-0 pos-11-1 pos-11-2 pos-11-3 pos-11-4 pos-11-5 pos-11-6 pos-11-7 pos-11-8 pos-11-9 pos-11-10 pos-11-11 pos-11-12 pos-11-13 pos-11-14 pos-11-15 pos-11-16 pos-11-17 pos-12-0 pos-12-1 pos-12-2 pos-12-3 pos-12-4 pos-12-5 pos-12-6 pos-12-7 pos-12-8 pos-12-9 pos-12-10 pos-12-11 pos-12-12 pos-12-13 pos-12-14 pos-12-15 pos-12-16 pos-12-17 pos-13-0 pos-13-1 pos-13-2 pos-13-3 pos-13-4 pos-13-5 pos-13-6 pos-13-7 pos-13-8 pos-13-9 pos-13-10 pos-13-11 pos-13-12 pos-13-13 pos-13-14 pos-13-15 pos-13-16 pos-13-17 pos-14-0 pos-14-1 pos-14-2 pos-14-3 pos-14-4 pos-14-5 pos-14-6 pos-14-7 pos-14-8 pos-14-9 pos-14-10 pos-14-11 pos-14-12 pos-14-13 pos-14-14 pos-14-15 pos-14-16 pos-14-17 pos-15-0 pos-15-1 pos-15-2 pos-15-3 pos-15-4 pos-15-5 pos-15-6 pos-15-7 pos-15-8 pos-15-9 pos-15-10 pos-15-11 pos-15-12 pos-15-13 pos-15-14 pos-15-15 pos-15-16 pos-15-17 pos-16-0 pos-16-1 pos-16-2 pos-16-3 pos-16-4 pos-16-5 pos-16-6 pos-16-7 pos-16-8 pos-16-9 pos-16-10 pos-16-11 pos-16-12 pos-16-13 pos-16-14 pos-16-15 pos-16-16 pos-16-17 - location
		player-01 - player
	)
	(:goal (and (at-goal box-612) (at-goal box-88) (at-goal box-138) (at-goal box-148) (at-goal box-54) (at-goal box-1310) (at-goal box-412) (at-goal box-129) (at-goal box-79) (at-goal box-613) (at-goal box-52)))
)