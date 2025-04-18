target_names <- ["Scout", "Soldier", "Pyro", "Demoman", "Heavy", "Engineer", "Medic", "Sniper", "Spy"]
target_class <- RandomElement(target_names)

minigame <- Ware_MinigameData
({
	name           = "Shoot Target"
	author         = ["Gemidyne", "ficool2"]
	description    = format("Shoot the %s target!", target_class)
	location       = "targetrange"
	duration       = 5.0
	music          = "cheerful"
	custom_overlay = "shoot_target_" + target_class.tolower()
})

function OnPrecache()
{
	foreach (name in target_names)
	{
		PrecacheModel(format("models/props_training/target_%s.mdl", name.tolower()))
		PrecacheOverlay("hud/tf2ware_ultimate/minigames/shoot_target_" + name.tolower())
	}
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Sydney Sleeper")
		
	local angles = [QAngle(0, -90, 0), QAngle(0, -270, 0)]
	for (local side = 0; side < 2; side++)
	{
		local indices = [0, 1, 2, 3, 4]
		Shuffle(indices)
		
		local target_count = RandomInt(1, 5)
		for (local i = 0; i < target_count; i++)
		{
			local line = Ware_MinigameLocation.lines[indices[i]]
			local name = i == 0 ? target_class : RandomElement(target_names)
			Ware_SpawnEntity("prop_dynamic",
			{
				targetname = "class_target"
				model      = format("models/props_training/target_%s.mdl", name.tolower())
				origin     = Lerp(line[0], line[1], RandomFloat(0.0, 1.0))
				angles     = angles[side]
				solid      = SOLID_VPHYSICS
				skin       = side
			})
		}
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.GetName() == "class_target")
	{
		local attacker = params.attacker
		if (attacker && attacker.IsPlayer())	
		{
			local class_name = victim.GetModelName().slice(29)
			class_name = class_name.slice(0, class_name.find(".mdl"))
			
			if (class_name == target_class.tolower())
				Ware_PassPlayer(attacker, true)
			else
				Ware_SuicidePlayer(attacker)
			
			Ware_PlaySoundOnClient(attacker, class_name + ".PainSevere01")
		}
		
		return false
	}
}