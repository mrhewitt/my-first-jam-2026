class_name Settings
##


const MIN_BLOCK_SIZE = 0.5

## How long it takes for one block to merge into the one in front of it
const BLOCK_MERGE_DELAY = 1.0


const CUBE_SPAWN_PROB = [
		0.7,		# 70% for first level,2 block
		0.2,		# 20% for seond level, 4 block
		0.075,		# 7.5% for thrid level, 8 block
		0.025		# 2.5% for foruth level, 16 block	
	 ]


const MAX_POWERUPS_ON_MAP = 5

## Minimum time until a new AI agent comes into the game 
const MIN_AI_RESPAWN_TIME = 5.0

## Maximum time until an agent is replaced
const MAX_AI_RESPAWN_TIME = 30.0
