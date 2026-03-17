class_name Settings
##

## Size of the smallest block, base size from which all else is determined
const MIN_BLOCK_SIZE = 0.5

## How much the blocks grow with each size increment
const GROW_RATIO = 1.2

## How height blocks remain off the ground
const HEIGHT_OFF_GROUND = MIN_BLOCK_SIZE / 2.0

## How long it takes for one block to merge into the one in front of it
const BLOCK_MERGE_DELAY = 1.0

## Distance between blocks when in a worm segment
const TOW_DISTANCE = 0.1

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
