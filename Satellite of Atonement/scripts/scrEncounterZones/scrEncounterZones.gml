//========================ENCOUNTER STEP COUNTER========================
//called every leader step in oFollowerParent
//_map_id - current MAP enum
function scrStepEncounter(_map_id) {
	global.encounter_steps++;
	
	//read current zone tile
	var tile_idx = scrGetCurrentZoneTile();
	var zone_number = scrTileToZoneNumber(tile_idx);
	global.current_zone_tile = zone_number;
	
	//get zone data for this map + zone combination
	var zone = scrGetZoneData(_map_id, zone_number);
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
			global.battle_background = scrGetBattleBackground(_map_id, zone_number);
			scrStartBattle(encounter);
		}
	}
}

//returns zone data struct for a given map
function scrGetZoneData(_map_id, _zone_number) {
	//default - no zone tile means no encounters
	if (_zone_number == 0) return undefined;
	
	switch (_map_id) {
		case MAP.DUNES:
			switch (_zone_number) {
				case 1: return {
					avg_steps	: 7,
					min_steps	: 5,
					max_steps	: 10,
					encounters	: [
					{ weight: 3, enemies: ["Cuetzpal", "Cuetzpal"]},
					{ weight: 3, enemies: ["Slime", "Slime"] },
					{ weight: 2, enemies: ["Slime", "Cuetzpal", "Cuetzpal"]},
					{ weight: 2, enemies: ["Slime"] },
					{ weight: 1, enemies: ["Cuetzpal"]},
					{ weight: 1, enemies: ["Cuetzpal", "Cuetzpal", "Slime", "Slime"]},
					{ weight: 1, enemies : ["Slime", "Slime", "Slime"] },
					]};
			
				case 2: return {
					avg_steps	: 5,
					min_steps	: 2,
					max_steps	: 10,
					encounters	: [
					{ weight: 3, enemies: ["Cuetzpal", "Cuetzpal", "Slime", "Slime"]},
					{ weight: 2, enemies: ["Slime", "Slime", "Slime"] },
					{ weight: 1, enemies : ["Slime", "Slime", "Slime", "Slime"] },
					]};
				
				case 3: return {
					avg_steps	: 5,
					min_steps	: 2,
					max_steps	: 7,
					encounters: [
					{ weight: 3, enemies: ["CapMage", "CapMage"]},
					{ weight: 3, enemies: ["Slime", "Slime", "Slime"] },
					{ weight: 2, enemies: ["Slime", "CapMage", "CapMage"] },
					{ weight: 2, enemies: ["CapMage"] },
					{ weight: 1, enemies: ["CapMage", "CapMage", "CapMage"] },
					]};
					
				case 4: return {
					avg_steps	: 5,
					min_steps	: 2,
					max_steps	: 7,
					encounters: [
					{ weight: 3, enemies: ["Cuetzpal", "CapMage"]},
					{ weight: 3, enemies: ["Cuetzpal", "Cuetzpal", "Slime"] },
					{ weight: 2, enemies: ["Cuetzpal", "CapMage", "CapMage"] },
					{ weight: 2, enemies: ["Cuetzpal", "Cuetzpal", "Cuetzpal", "Slime"] },
					{ weight: 1, enemies: ["Cuetzpal", "CapMage", "CapMage", "CapMage"] },
					]};
			//add more zone numbers per map as needed
			default: return undefined;
		}
		//add more maps here
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

//returns the zone tile index the leader is currently standing on, returns 0 if no zone tile
function scrGetCurrentZoneTile() {
	var _layer = layer_get_id("ZoneMap");
	if (_layer == -1) return 0;
	var _tilemap = layer_tilemap_get_id(_layer);
	if (_tilemap == -1) return 0;
	
	var _leader = instance_find(global.partyOrder[0], 0);
	if (_leader == noone || !instance_exists(_leader)) return 0;
	
	var _tile_idx = tilemap_get(_tilemap, _leader.x_pos, _leader.y_pos);
	_tile_idx = _tile_idx & tile_index_mask;
	return _tile_idx;//0 = no zone, 1-20 = zone numbers
}

//returns zone number 1-20 from tile index
function scrTileToZoneNumber(_tile_idx) {
	if (_tile_idx <= 0) return 0;
	return _tile_idx;
}
//========================COMBAT BACKGROUNDS========================
function scrGetBattleBackground(_map_id, _zone_number) {
	switch (_map_id) {
		case MAP.DUNES:
		//default dunes background for all zones, override per zone as needed
		switch (_zone_number) {
			case 1: return sDefaultBg;
			case 2: return sDefaultBg;
			default: return sDefaultBg;
		}
		//add more maps here
		default: return -1;
	}
}