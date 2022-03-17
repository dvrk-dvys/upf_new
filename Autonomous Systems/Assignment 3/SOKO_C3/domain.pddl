(define
	(domain sokoban_gen)
	(:requirements :strips :typing)
	(:types
		box player - thing
		direction location thing - object
	)
	(:predicates
		(at ?t - thing ?l - location)
		(at-goal ?b - box)
		(clear ?l - location)
		(is-goal ?l - location)
		(is-nongoal ?l - location)
		(move-dir ?frm - location ?to - location ?dir - direction)
		(teleported ?t - thing ?l - location)
	)
	(:action move
		:parameters (?p - player ?frm - location ?to - location ?dir - direction)
		:precondition (and (at ?p ?frm) (clear ?to) (move-dir ?frm ?to ?dir))
		:effect (and (not (at ?p ?frm)) (not (clear ?to)) (at ?p ?to) (clear ?frm))
	)
	(:action push-to-goal
		:parameters (?p - player ?b - box ?p_pos - location ?frm - location ?to - location ?dir - direction)
		:precondition (and (at ?p ?p_pos) (at ?b ?frm) (clear ?to) (move-dir ?p_pos ?frm ?dir) (move-dir ?frm ?to ?dir) (is-goal ?to))
		:effect (and (not (at ?p ?p_pos)) (not (at ?b ?frm)) (not (clear ?to)) (at ?p ?frm) (at ?b ?to) (clear ?p_pos) (at-goal ?b))
	)
	(:action push-to-nongoal
		:parameters (?p - player ?b - box ?p_pos - location ?frm - location ?to - location ?dir - direction)
		:precondition (and (at ?p ?p_pos) (at ?b ?frm) (clear ?to) (move-dir ?p_pos ?frm ?dir) (move-dir ?frm ?to ?dir) (is-nongoal ?to))
		:effect (and (not (at ?p ?p_pos)) (not (at ?b ?frm)) (not (clear ?to)) (at ?p ?frm) (at ?b ?to) (clear ?p_pos) (not (at-goal ?b)))
	)
	(:action teleport
		:parameters (?p - player ?frm - location ?to - location ?dir - direction)
		:precondition (and (at ?p ?frm) (clear ?to) (move-dir ?frm ?to ?dir) (not (teleported ?p ?to)))
		:effect (and (not (at ?p ?frm)) (not (clear ?to)) (at ?p ?to) (clear ?frm) (teleported ?p ?to))
	)
)