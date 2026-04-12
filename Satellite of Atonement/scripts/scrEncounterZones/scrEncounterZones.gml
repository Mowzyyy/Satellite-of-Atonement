//========================ENCOUNTER STEP COUNTER========================
//called every leader step in oFollowerParent
//_map_id - current MAP enum
function scrStepEncounter(_map_id) {
	global.encounter_steps++;
	
	var zone = scrGetZoneData(_map_id);
	if (zone == undefined) return;//no encounters in this zone
	
	//calculate average steps adjusted by party level and plot stage
	var avg_level = 0;
	for (var i = 0; i < array_length(global.party); i++) {
		avg_level += global.party[i].level;
	}
	avg_level /= array_length(global.party);
	
	//adjust average - higher level - fewer encounters (floors at min)
	var adjusted_avg = zone.avg_steps + floor((avg_level -1) * 0.5);
	if (global.storyStep >= PLOT.CHAPTER_TWO) adjusted_avg -= 5;//example plot adjustment
	adjusted_avg = clamp(adjusted_avg, zone.min_steps, zone.max_steps);
	
	//probability curve - low chance early, peaks at avg, higher chance after
	var fraction = global.encounter_steps / adjusted_avg;
	var chance = 0;
	if (fraction < 1) {
		chance = fraction * 0.5;//ramps from 0 to 0.5 approaching avg
	} else {
		chance = 0.5 + (fraction - 1) * 0.5;//ramps from 0.5 to 1.0 after avg
	}
	chance = clamp(chance, 0, 1);

//hard clamp at max steps
if (global.encounter_steps >= zone.max_steps) chance = 1;

	if (random(1) < chance) {
		//trigger encounter
		var encounter = scrPickEncounter(zone);
		if (encounter != undefined) {
			global.encounter_steps = 0;
			scrStartBattle(encounter);
		}
	}
}

//returns zone data struct for a given map
function scrGetZoneData(_map_id) {
	switch (_map_id) {
		case MAP.DUNES:
		return {
			avg_steps	: 40,
			min_steps	: 15,
			max_steps	: 80,
			encounters	: [
			{ weight: 3, enemies: ["Slime", "Slime"] },
			{ weight: 2, enemies: ["Slime"] },
			{ weight: 1, enemies : ["Slime", "Slime", "Slime"] },
			]
		};
		//add more zones here
		default: return undefined;
	}
}

//Picks a weighted random encounter from the zone's encounter table
function scrPickEncounter(_zone) {
	var total = 0;
	for (var i = 0; i < array_length(_zone.encounters); i++) {
		total += _zone.encounters[i].weight;
	}
	var roll = random(total);
	var cumulative = 0;
	for (var i = 0; i < array_length(_zone.encounters); i++) {
		cumulative += _zone.encounters[i].weight;
		if (roll < cumulative) {
			//instantiate the enemies from their factory functions
			var enemy_list = [];
			for (var j = 0; j < array_length(_zone.encounters[i].enemies); j++) {
				var enemy_name = _zone.encounters[i].enemies[j];
				array_push(enemy_list, scrBuildEnemy(enemy_name));
			}
			return enemy_list;
		}
	}
	return undefined;
}