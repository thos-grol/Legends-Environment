local gt = this.getroottable();

if (!("World" in gt.Const))
{
	gt.Const.World <- {};
}

gt.Const.World.Common.assignTroops = function ( _party, _partyList, _resources, _weightMode = 1 )
{
	local p;

	if (typeof _partyList == "table")
	{
		p = this.Const.World.Common.buildDynamicTroopList(_partyList, _resources);
	}
	else
	{
		if (_partyList[_partyList.len() - 1].Cost < _resources * 0.7)
		{
			_resources = _partyList[_partyList.len() - 1].Cost;
		}

		local total_weight = 0;
		local best;
		local bestCost = _weightMode == this.WeightMode.Strongest ? -9000.0 : 9000;
		local potential = [];

		foreach( party in _partyList )
		{
			if (party.Cost < _resources * 0.7)
			{
				continue;
			}

			if (party.Cost > _resources)
			{
				break;
			}

			if (_weightMode == this.WeightMode.Weighted || _weightMode == this.WeightMode.Random)
			{
				potential.push(party);
				total_weight = total_weight + party.Cost;
			}
			else if (_weightMode == this.WeightMode.Strongest)
			{
				if (party.Cost > bestCost)
				{
					best = party;
					bestCost = party.Cost;
				}
			}
			else if (_weightMode == this.WeightMode.Weakest)
			{
				if (party.Cost < bestCost)
				{
					best = party;
					bestCost = party.Cost;
				}
			}
		}

		if (potential.len() == 0 && best == null)
		{
			bestCost = 9000;

			foreach( party in _partyList )
			{
				best = party;

				if (this.Math.abs(_resources - party.Cost) > bestCost)
				{
					break;
				}

				bestCost = this.Math.abs(_resources - party.Cost);
			}

			p = best;
		}
		else if (_weightMode == this.WeightMode.Random)
		{
			p = potential[this.Math.rand(0, potential.len() - 1)];
		}
		else if (_weightMode == this.WeightMode.Strongest || _weightMode == this.WeightMode.Weakest)
		{
			p = best;
		}
		else if (_weightMode == this.WeightMode.Weighted)
		{
			p = best;
			local pick = this.Math.rand(1, total_weight);

			foreach( party in potential )
			{
				p = party;

				if (pick <= party.Cost)
				{
					break;
				}

				pick = pick - party.Cost;
			}
		}
	}

	_party.setMovementSpeed(p.MovementSpeedMult * this.Const.World.MovementSettings.Speed);
	_party.setVisibilityMult(p.VisibilityMult);
	_party.setVisionRadius(this.Const.World.Settings.Vision * p.VisionMult);
	_party.getSprite("body").setBrush(p.Body);
	local troopMbMap = {};

	foreach( t in p.Troops )
	{
		local key = "Enemy" + t.Type.ID;

		if (!(key in troopMbMap))
		{
			troopMbMap[key] <- this.Const.LegendMod.GetFavEnemyBossChance(t.Type.ID);
		}

		local mb = troopMbMap[key];

		for( local i = 0; i != t.Num; i = i )
		{
			this.addTroop(_party, t, false, mb);
			i = ++i;
		}
	}

	_party.updateStrength();
	return p;
};
gt.Const.World.Common.addTroop = function ( _party, _troop, _updateStrength = true, _minibossify = 0 )
{
	local troop = clone _troop.Type;
	troop.Party <- this.WeakTableRef(_party);
	troop.Faction <- _party.getFaction();
	troop.Name <- "";

	if (troop.Variant > 0)
	{
		_minibossify = _minibossify + this.World.Assets.m.ChampionChanceAdditional;
		local upperBound = "DieRoll" in troop ? troop.DieRoll : 100;

		if (!this.Const.DLC.Wildmen || this.Math.rand(1, upperBound) > troop.Variant + _minibossify + (this.World.getTime().Days > 90 ? 0 : -1))
		{
			troop.Variant = 0;
		}
		else
		{
			troop.Strength = this.Math.round(troop.Strength * 1.35);
			troop.Variant = this.Math.rand(1, 255);

			if ("NameList" in _troop.Type)
			{
				troop.Name = this.generateName(_troop.Type.NameList) + (_troop.Type.TitleList != null ? " " + _troop.Type.TitleList[this.Math.rand(0, _troop.Type.TitleList.len() - 1)] : "");
			}
		}
	}

	_party.getTroops().push(troop);

	if (_updateStrength)
	{
		_party.updateStrength();
	}

	return troop;
};
gt.Const.World.Common.addUnitsToCombat = function ( _into, _partyList, _resources, _faction, _minibossify = 0 )
{
	local p;

	if (typeof _partyList == "table")
	{
		p = this.Const.World.Common.buildDynamicTroopList(_partyList, _resources);
	}
	else
	{
		local total_weight = 0;
		local potential = [];

		foreach( party in _partyList )
		{
			if (party.Cost < _resources * 0.7)
			{
				continue;
			}

			if (party.Cost > _resources)
			{
				break;
			}

			potential.push(party);
			total_weight = total_weight + party.Cost;
		}

		if (potential.len() == 0)
		{
			local best;
			local bestCost = 9000;

			foreach( party in _partyList )
			{
				if (this.Math.abs(_resources - party.Cost) <= bestCost)
				{
					best = party;
					bestCost = this.Math.abs(_resources - party.Cost);
				}
			}

			p = best;
		}
		else
		{
			local pick = this.Math.rand(1, total_weight);

			foreach( party in potential )
			{
				if (pick <= party.Cost)
				{
					p = party;
					break;
				}

				pick = pick - party.Cost;
			}
		}
	}

	local troopMbMap = {};

	foreach( t in p.Troops )
	{
		local key = "Enemy" + t.Type.ID;

		if (!(key in troopMbMap))
		{
			troopMbMap[key] <- this.Const.LegendMod.GetFavEnemyBossChance(t.Type.ID);
		}

		local mb = troopMbMap[key];
		mb = mb + _minibossify;

		for( local i = 0; i != t.Num; i = i )
		{
			local unit = clone t.Type;
			unit.Faction <- _faction;
			unit.Name <- "";

			if (unit.Variant > 0)
			{
				local upperBound = "DieRoll" in unit ? unit.DieRoll : 100;

				if (!this.Const.DLC.Wildmen || this.Math.rand(1, upperBound) > unit.Variant + mb + (this.World.getTime().Days > 100 ? 0 : -1))
				{
					unit.Variant = 0;
				}
				else
				{
					unit.Strength = this.Math.round(unit.Strength * 1.35);
					unit.Variant = this.Math.rand(1, 255);

					if ("NameList" in unit)
					{
						unit.Name = this.generateName(unit.NameList) + (unit.TitleList != null ? " " + unit.TitleList[this.Math.rand(0, unit.TitleList.len() - 1)] : "");
					}
				}
			}

			_into.push(unit);
			i = ++i;
		}
	}
};
gt.Const.World.Common.dynamicSelectTroop <- function ( _list, _resources, _scale, _map, _credits )
{
	local candidates = [];
	local T = [];
	local totalWeight = 0;
	local dateToSkip = 0;

	switch(this.World.Assets.getCombatDifficulty())
	{
	case this.Const.Difficulty.Easy:
		dateToSkip = 120;
		break;

	case this.Const.Difficulty.Normal:
		dateToSkip = 90;
		break;

	case this.Const.Difficulty.Hard:
		dateToSkip = 60;
		break;

	case this.Const.Difficulty.Legendary:
		dateToSkip = 30;
		break;
	}

	dateToSkip = 90;

	foreach( t in _list )
	{
		if (("MaxR" in t) && _resources > t.MaxR)
		{
			continue;
		}

		if ("MinR" in t)
		{
			local minr = 0;

			if (typeof t.MinR == "function")
			{
				minr = t.MinR();
			}
			else
			{
				minr = t.MinR;
			}

			if (_resources < minr && this.World.getTime().Days <= dateToSkip)
			{
				continue;
			}
		}

		local w = 0;

		if (typeof t.Weight == "function")
		{
			w = t.Weight(_scale);
		}
		else
		{
			w = t.Weight;
		}

		if (w == 0)
		{
			T.push(t);
			continue;
		}

		totalWeight = totalWeight + w;
		candidates.push(t);
	}

	local r = this.Math.rand(1, totalWeight);

	foreach( t in candidates )
	{
		local w = 0;

		if (typeof t.Weight == "function")
		{
			w = t.Weight(_scale);
		}
		else
		{
			w = t.Weight;
		}

		r = r - w;

		if (r > 0)
		{
			continue;
		}

		T.push(t);
		break;
	}

	foreach( troop in T )
	{
		if ("Type" in troop)
		{
			local key = troop.Type.Script;

			if (!(key in _map))
			{
				_map[key] <- {
					Type = troop.Type,
					Num = 0
				};
			}

			if ("Roll" in troop)
			{
				if (typeof troop.Roll == "function")
				{
					if (!troop.Roll(_map[key].Num))
					{
						continue;
					}
				}
				else
				{
					local chance = 1.0 / (1.0 + this.Math.pow(_map[key].Num, 0.5)) * 100;

					for( ; this.Math.rand(1, 100) > chance;  )
					{
					}
				}
			}

			_credits = _credits - troop.Cost;
			_map[key].Num += 1;

			if ("MaxCount" in troop)
			{
				for( local i = 1; i < troop.MaxCount; i = i )
				{
					if (_credits < 0)
					{
						break;
					}

					local w = 100;

					if (typeof troop.Weight == "function")
					{
						w = troop.Weight(_scale);
					}
					else
					{
						w = troop.Weight;
					}

					if (this.Math.rand(0, 100) < w)
					{
						_credits = _credits - troop.Cost;
						local key = troop.Type.Script;

						if (!(key in _map))
						{
							_map[key] <- {
								Type = troop.Type,
								Num = 0
							};
						}

						_map[key].Num += 1;
					}

					i = ++i;
				}
			}
		}

		if ("Guards" in troop)
		{
			local maxCount = "MaxGuards" in troop ? troop.MaxGuards : 1;
			local minCount = "MinGuards" in troop ? troop.MinGuards : 1;

			for( local i = 0; i < maxCount; i = i )
			{
				local weight = 100;

				if ("MaxGuardsWeight" in troop)
				{
					weight = troop.MaxGuardsWeight;
				}

				local r = this.Math.rand(0, 100);

				if (weight < r && i >= minCount)
				{
				}
				else
				{
					_credits = this.Const.World.Common.dynamicSelectTroop(troop.Guards, _resources, _scale, _map, _credits);

					if (_credits < 0)
					{
						break;
					}
				}

				i = ++i;
			}
		}

		if (_credits < 0)
		{
			return _credits;
		}

		if (!("SortedTypes" in troop))
		{
			continue;
		}

		local points = troop.SortedTypes[0].Cost;

		if (troop.SortedTypes.len() > 1)
		{
			local meanScaled = troop.MinMean + _scale * (troop.MaxMean - troop.MinMean);
			points = this.Math.max(points, this.Const.LegendMod.BoxMuller.BoxMuller(meanScaled, troop.Deviation));
		}

		for( local i = troop.SortedTypes.len() - 1; i >= 0; i = i )
		{
			if (troop.SortedTypes[i].Cost > points)
			{
			}
			else
			{
				local index = this.Math.rand(0, troop.SortedTypes[i].Types.len() - 1);

				if (("MaxR" in troop.SortedTypes[i].Types[index]) && _resources > troop.SortedTypes[i].Types[index].MaxR)
				{
				}
				else
				{
					if ("MinR" in troop.SortedTypes[i].Types[index])
					{
						local minr = 0;

						if (typeof troop.SortedTypes[i].Types[index].MinR == "function")
						{
							minr = troop.SortedTypes[i].Types[index].MinR();
						}
						else
						{
							minr = troop.SortedTypes[i].Types[index].MinR;
						}

						if (_resources < minr && this.World.getTime().Days <= dateToSkip)
						{
							continue;
						}
					}

					local key = troop.SortedTypes[i].Types[index].Type.Script;

					if (!(key in _map))
					{
						_map[key] <- {
							Type = troop.SortedTypes[i].Types[index].Type,
							Num = 0
						};
					}

					if ("Roll" in troop)
					{
						if (typeof troop.Roll == "function")
						{
							if (!troop.Roll(_map[key].Num))
							{
								continue;
							}
						}
						else
						{
							local chance = 1.0 / (1.0 + this.Math.pow(_map[key].Num, 0.5)) * 100;

							if (this.Math.rand(1, 100) > chance)
							{
							}
						}
					}
					else if ("Roll" in troop.SortedTypes[i].Types[index])
					{
						if (typeof troop.SortedTypes[i].Types[index].Roll == "function")
						{
							if (!troop.SortedTypes[i].Types[index].Roll(_map[key].Num))
							{
								continue;
							}
						}
						else
						{
							local chance = 1.0 / (1.0 + this.Math.pow(_map[key].Num, 0.5)) * 100;

							if (this.Math.rand(1, 100) > chance)
							{
							}
						}
					}

					_credits = _credits - troop.SortedTypes[i].Types[index].Cost;
					_map[key].Num += 1;

					if ("Guards" in troop.SortedTypes[i].Types[index])
					{
						_credits = this.Const.World.Common.dynamicSelectTroop(troop.SortedTypes[i].Types[index].Guards, _resources, _scale, _map, _credits);
					}

					break;
				}
			}

			i = --i;
		}
	}

	return _credits;
};
gt.Const.World.Common.buildDynamicTroopList <- function ( _template, _resources )
{
	local credits = _resources;

	if ("MinR" in _template)
	{
		credits = this.Math.max(_template.MinR, credits);
	}

	local scale = "MaxR" in _template ? _resources * 1.0 / (_template.MaxR * 1.0) : 1.0;
	local troopMap = {};
	local prevPoints = 0;

	if ("Fixed" in _template)
	{
		credits = this.Const.World.Common.dynamicSelectTroop(_template.Fixed, _resources, scale, troopMap, credits);
	}

	if (("Troops" in _template) && _template.Troops.len() > 0)
	{
		while (credits > 0)
		{
			credits = this.Const.World.Common.dynamicSelectTroop(_template.Troops, _resources, scale, troopMap, credits);
		}
	}

	local T = [];

	foreach( k, v in troopMap )
	{
		T.push(v);
	}

	return {
		MovementSpeedMult = _template.MovementSpeedMult,
		VisibilityMult = _template.VisibilityMult,
		VisionMult = _template.VisionMult,
		Body = _template.Body,
		Troops = T
	};
};
gt.Const.World.Common.pickLegendArmor <- function ( _list )
{
	return this.Const.World.Common.pickItem(_list, "scripts/items/legend_armor/");
};
gt.Const.World.Common.pickLegendHelmet <- function ( _list )
{
	return this.Const.World.Common.pickItem(_list, "scripts/items/legend_helmets/");
};
gt.Const.World.Common.pickItem <- function ( _list, _script = "" )
{
	local candidates = [];
	local totalWeight = 0;
	local w = 0;

	foreach( t in _list )
	{
		if (t[0] == 0)
		{
			continue;
		}

		candidates.push(t);
		totalWeight = totalWeight + t[0];
	}

	local r = this.Math.rand(0, totalWeight);

	foreach( t in candidates )
	{
		r = r - t[0];

		if (r > 0)
		{
			continue;
		}

		if (_script == "")
		{
			return t[1];
		}

		if (t[1] == "")
		{
			return null;
		}

		local ret = this.new(_script + t[1]);

		if (t.len() == 3)
		{
			ret.setVariant(t[2]);
		}

		return ret;
	}

	return null;
};
gt.Const.World.Common.pickHelmet <- function ( _helms )
{
	local candidates = [];
	local totalWeight = 0;

	foreach( t in _helms )
	{
		if (t[0] == 0)
		{
			continue;
		}

		candidates.push(t);
		totalWeight = totalWeight + t[0];
	}

	local r = this.Math.rand(0, totalWeight);
	local helm = "";
	local variant;

	foreach( t in candidates )
	{
		r = r - t[0];

		if (r > 0)
		{
			continue;
		}

		helm = t[1];

		if (t.len() == 3)
		{
			variant = t[2];
		}

		break;
	}

	if (helm == "")
	{
		return null;
	}

	local layersObj = this.Const.LegendMod.Helmets[helm];

	if (layersObj.Script != "")
	{
		local helmet = this.new(layersObj.Script);

		if (variant != null)
		{
			helmet.setupArmor(variant);
		}

		return helmet;
	}

	local set = layersObj.Sets[this.Math.rand(0, layersObj.Sets.len() - 1)];
	local helmet = this.Const.World.Common.pickLegendHelmet(set.Hoods);

	if (helmet != null)
	{
		if (variant != null)
		{
			if (helm == "greatsword_faction_helm")
			{
				helmet.setupArmor(variant);
			}
		}

		local helm = this.Const.World.Common.pickLegendHelmet(set.Helms);

		if (helm != null)
		{
			helmet.setUpgrade(helm);
		}

		local top = this.Const.World.Common.pickLegendHelmet(set.Tops);

		if (top != null)
		{
			helmet.setUpgrade(top);
		}

		local van = this.Const.World.Common.pickLegendHelmet(set.Vanity);

		if (van != null)
		{
			helmet.setUpgrade(van);
		}

		if ("Vanity2" in set)
		{
			local van2 = this.Const.World.Common.pickLegendHelmet(set.Vanity2);

			if (van2 != null)
			{
				helmet.setUpgrade(van2);
			}
		}
	}

	return helmet;
};
gt.Const.World.Common.pickArmor <- function ( _armors )
{
	local candidates = [];
	local totalWeight = 0;

	foreach( t in _armors )
	{
		if (t[0] == 0)
		{
			continue;
		}

		candidates.push(t);
		totalWeight = totalWeight + t[0];
	}

	local r = this.Math.rand(0, totalWeight);
	local armorID = "";
	local variant;
	local faction;

	foreach( t in candidates )
	{
		r = r - t[0];

		if (r > 0)
		{
			continue;
		}

		armorID = t[1];

		if (t.len() == 3)
		{
			variant = t[2];
		}

		if (t.len() == 4)
		{
			faction = t[3];
		}

		break;
	}

	if (armorID == "")
	{
		return null;
	}

	if (!(armorID in this.Const.LegendMod.Armors))
	{
		return this.new("scripts/items/armor/" + armorID);
	}

	local layersObj = this.Const.LegendMod.Armors[armorID];

	if (layersObj.Script != "")
	{
		local item = this.new(layersObj.Script);

		if (faction != null)
		{
			item.setupArmor(faction);
		}

		return item;
	}

	local set = layersObj.Sets[this.Math.rand(0, layersObj.Sets.len() - 1)];
	local armor = this.Const.World.Common.pickLegendArmor(set.Cloth);

	if (armor == null)
	{
		return this.new("scripts/items/armor/" + armorID);
	}

	if (faction != null)
	{
		armor.setupArmor(faction);
	}

	local chain = this.Const.World.Common.pickLegendArmor(set.Chain);

	if (chain != null)
	{
		armor.setUpgrade(chain);
	}

	local plate = this.Const.World.Common.pickLegendArmor(set.Plate);

	if (plate != null)
	{
		armor.setUpgrade(plate);
	}

	local cloak = this.Const.World.Common.pickLegendArmor(set.Cloak);

	if (cloak != null)
	{
		armor.setUpgrade(cloak);
	}

	local tab = this.Const.World.Common.pickLegendArmor(set.Tabard);

	if (tab != null)
	{
		armor.setUpgrade(tab);
	}

	local att = this.Const.World.Common.pickLegendArmor(set.Attachments);

	if (att != null)
	{
		armor.setUpgrade(att);
	}

	return armor;
};
gt.Const.World.Common.pickArmorUpgrade <- function ( _armors )
{
	local candidates = [];
	local totalWeight = 0;

	foreach( t in _armors )
	{
		if (t[0] == 0)
		{
			continue;
		}

		candidates.push(t);
		totalWeight = totalWeight + t[0];
	}

	local r = this.Math.rand(0, totalWeight);
	local armorID = "";
	local variant;
	local faction;

	foreach( t in candidates )
	{
		r = r - t[0];

		if (r > 0)
		{
			continue;
		}

		armorID = t[1];

		if (t.len() == 3)
		{
			variant = t[2];
		}

		if (t.len() == 4)
		{
			faction = t[3];
		}

		break;
	}

	if (!(armorID in this.Const.LegendMod.Armors))
	{
		return this.new("scripts/items/armor_upgrades/" + armorID);
	}

	local layersObj = this.Const.LegendMod.Armors[armorID];

	if (layersObj.Script != "")
	{
		return this.new(layersObj.Script);
	}

	return null;
};
gt.Const.World.Common.pickOutfit <- function ( _outfitArr, _armorArr = null, _helmetArr = null, _chance = 0 )
{
	if (_chance != 0)
	{
		if (this.Math.rand(1, 100) >= _chance)
		{
			return [
				this.Const.World.Common.pickArmor(_armorArr),
				this.Const.World.Common.pickHelmet(_helmetArr)
			];
		}
	}
	else if (_armorArr != null && _helmetArr != null && _armorArr.len() > 0 && _helmetArr.len() > 0)
	{
		local armorCount = 0;
		local helmCount = 0;
		local outfitCount = 0;

		foreach( t in _armorArr )
		{
			if (t[0] > 0)
			{
				armorCount = armorCount + 1;
			}
		}

		foreach( t in _helmetArr )
		{
			if (t[0] > 0)
			{
				helmCount = helmCount + 1;
			}
		}

		foreach( t in _outfitArr )
		{
			if (t[0] > 0)
			{
				outfitCount = outfitCount + 1;
			}
		}

		if (this.Math.rand(1, armorCount * helmCount) > outfitCount)
		{
			return [
				this.Const.World.Common.pickArmor(_armorArr),
				this.Const.World.Common.pickHelmet(_helmetArr)
			];
		}
	}

	local candidates = [];
	local totalWeight = 0;

	foreach( t in _outfitArr )
	{
		if (t[0] == 0)
		{
			continue;
		}

		candidates.push(t);
		totalWeight = totalWeight + t[0];
	}

	local r = this.Math.rand(0, totalWeight);
	local outfitID = "";

	foreach( t in candidates )
	{
		r = r - t[0];

		if (r > 0)
		{
			continue;
		}

		outfitID = t[1];
		break;
	}

	local layersObj = this.Const.LegendMod.Outfits[outfitID];
	return [
		this.Const.World.Common.pickArmor(layersObj.Body),
		this.Const.World.Common.pickHelmet(layersObj.Helmet)
	];
};
gt.Const.World.Common.convNameToList <- function ( _named )
{
	local findString = [
		"helmets/",
		"armor/",
		"legend_armor/",
		"legend_helmets/"
	];
	local retArr = [];

	foreach( search in findString )
	{
		if (_named[0].find(search) != null)
		{
			foreach( item in _named )
			{
				retArr.push([
					1,
					item.slice(item.find(search) + search.len())
				]);
			}

			break;
		}
	}

	return retArr;
};
gt.Const.World.Common.getArenaBros <- function ()
{
	local ret = [];
	local roster = this.World.getPlayerRoster().getAll();

	foreach( bro in roster )
	{
		local item = bro.getItems().getItemAtSlot(this.Const.ItemSlot.Accessory);

		if (item != null && item.getID() == "accessory.legend_arena_collar")
		{
			ret.push(bro);
		}
	}

	return ret;
};

if (!("LegendMod" in gt.Const))
{
	gt.Const.LegendMod <- {};
}

gt.Const.LegendMod.BoxMuller <- {
	UseLast = false,
	NextValue = 0.0,
	function generate()
	{
		if (this.UseLast)
		{
			this.UseLast = false;
			return this.NextValue;
		}

		local s = 0.0;
		local v1 = 0.0;
		local v2 = 0.0;

		while (s >= 1.0 || s == 0.0)
		{
			v1 = 2.0 * this.Math.rand(0, 1000) / 1000 - 1.0;
			v2 = 2.0 * this.Math.rand(0, 1000) / 1000 - 1.0;
			s = v1 * v1 + v2 * v2;
		}

		s = this.Math.pow(-2.0 * this.log(s) / s, 0.5);
		this.NextValue = v2 * s;
		this.UseLast = true;
		return v1 * s;
	}

	function BoxMuller( _mean, _deviation )
	{
		local g = this.generate();
		return _mean + g * _deviation;
	}

	function Next( _min, _max )
	{
		local deviations = 3.5;
		local r = _max + 1;

		while (r > _max || r < _min)
		{
			r = this.BoxMuller(_min + (_max - _min) / 2.0, (_max - _min) / 2.0 / deviations);
		}

		return r;
	}

};
function onCostCompare( _t1, _t2 )
{
	if (_t1.Cost < _t2.Cost)
	{
		return -1;
	}
	else if (_t1.Cost > _t2.Cost)
	{
		return 1;
	}

	return 0;
}


foreach( k, v in this.Const.World.Spawn )
{
	if (k == "Troops" || k == "Unit" || k == "TroopsMap")
	{
		continue;
	}

	if (typeof v != "table")
	{
		continue;
	}

	foreach( i, _t in v.Troops )
	{
		local costMap = {};

		foreach( tt in _t.Types )
		{
			if (!(tt.Cost in costMap))
			{
				costMap[tt.Cost] <- [];
			}

			costMap[tt.Cost].append(tt);
		}

		_t.SortedTypes <- [];

		foreach( k, v in costMap )
		{
			_t.SortedTypes.append({
				Cost = k,
				Types = v
			});
		}

		if (_t.SortedTypes.len() == 1)
		{
			continue;
		}

		_t.SortedTypes.sort(this.onCostCompare);
		local mean = 0;
		local variance = 0;
		local deviation = 0;

		foreach( o in v.Troops[i].SortedTypes )
		{
			mean = mean + o.Cost;
		}

		mean = mean * 1.0 / (v.Troops[i].SortedTypes.len() * 1.0);

		foreach( o in v.Troops[i].SortedTypes )
		{
			local d = o.Cost - mean;
			variance = variance + d * d;
		}

		variance = variance * 1.0 / (v.Troops[i].SortedTypes.len() * 1.0);
		deviation = this.Math.pow(variance, 0.5);
		v.Troops[i].Mean <- mean;
		v.Troops[i].Variance <- variance;
		v.Troops[i].Deviation <- deviation;
		v.Troops[i].MinMean <- v.Troops[i].SortedTypes[0].Cost - deviation;
		v.Troops[i].MaxMean <- v.Troops[i].Types[v.Troops[i].SortedTypes.len() - 1].Cost + deviation;
	}
}

gt.Const.World.Common.pickPerks <- function ( _perks, _power )
{
	if (_perks.len() == 0)
	{
		return [];
	}

	if (_power == 0)
	{
		return [];
	}

	local candidates = [];
	local totalWeight = 0;

	foreach( t in _perks )
	{
		if (t[0] == 0)
		{
			continue;
		}

		if (t[2] > _power)
		{
			continue;
		}

		candidates.push(t);
		totalWeight = totalWeight + t[0];
	}

	local ret = [];

	while (_power > 0)
	{
		if (candidates.len() == 0)
		{
			return ret;
		}

		local r = this.Math.rand(0, totalWeight);

		foreach( i, t in candidates )
		{
			r = r - t[0];

			if (r > 0)
			{
				continue;
			}

			local skill;

			if (typeof t[1] == "string")
			{
				skill = this.new("scripts/skills/perks/" + t[1]);
				ret.push(skill);
			}
			else if (typeof t[1] == "array")
			{
				foreach( s in t[1] )
				{
					skill = this.new("scripts/skills/perks/" + s);
					ret.push(skill);
				}
			}
			else
			{
				this.logWarning("Attempted to select perks from something that isn\'t a string or an array");
			}

			totalWeight = totalWeight - t[0];
			_power = _power - t[2];
			candidates.remove(i);
		}

		local garbage = [];

		foreach( i, t in candidates )
		{
			if (t[2] > _power)
			{
				garbage.push(i);
			}
		}

		garbage.reverse();

		foreach( i in garbage )
		{
			candidates.remove(i);
		}
	}

	return ret;
};

