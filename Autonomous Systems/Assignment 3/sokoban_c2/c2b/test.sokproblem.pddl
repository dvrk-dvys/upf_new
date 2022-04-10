(define
	(problem sokoban_gen)
	(:domain sokoban_gen)
	(:objects
		box-14 - box
		up down left right teleport - direction
		pos-0-0 pos-0-1 pos-0-2 pos-0-3 pos-0-4 pos-0-5 pos-0-6 pos-1-0 pos-1-1 pos-1-2 pos-1-3 pos-1-4 pos-1-5 pos-1-6 pos-2-0 pos-2-1 pos-2-2 pos-2-3 pos-2-4 pos-2-5 pos-2-6 - location
		player-01 - player
	)
	(:init (is-goal pos-1-5) (is-nongoal pos-0-0) (is-nongoal pos-0-1) (is-nongoal pos-0-2) (is-nongoal pos-0-3) (is-nongoal pos-0-4) (is-nongoal pos-0-5) (is-nongoal pos-0-6) (is-nongoal pos-1-0) (is-nongoal pos-1-1) (is-nongoal pos-1-2) (is-nongoal pos-1-3) (is-nongoal pos-1-4) (is-nongoal pos-1-6) (is-nongoal pos-2-0) (is-nongoal pos-2-1) (is-nongoal pos-2-2) (is-nongoal pos-2-3) (is-nongoal pos-2-4) (is-nongoal pos-2-5) (is-nongoal pos-2-6) (at box-14 pos-1-4) (at player-01 pos-1-1) (clear pos-1-1) (clear pos-1-3) (clear pos-1-4) (clear pos-1-5) (move-dir pos-1-1 pos-1-3 teleport) (move-dir pos-1-1 pos-1-4 teleport) (move-dir pos-1-1 pos-1-5 teleport) (move-dir pos-1-3 pos-1-1 teleport) (move-dir pos-1-3 pos-1-4 teleport) (move-dir pos-1-3 pos-1-5 teleport) (move-dir pos-1-4 pos-1-1 teleport) (move-dir pos-1-4 pos-1-3 teleport) (move-dir pos-1-4 pos-1-5 teleport) (move-dir pos-1-5 pos-1-1 teleport) (move-dir pos-1-5 pos-1-3 teleport) (move-dir pos-1-5 pos-1-4 teleport) (move-dir pos-1-3 pos-1-4 right) (move-dir pos-1-4 pos-1-3 left) (move-dir pos-1-4 pos-1-5 right) (move-dir pos-1-5 pos-1-4 left))
	(:goal (at-goal box-14))
)