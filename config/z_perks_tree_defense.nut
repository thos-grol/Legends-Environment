local gt = this.getroottable();

if (!("Perks" in gt.Const))
{
	gt.Const.Perks <- {};
}

gt.Const.Perks.ShieldTree <- {
	ID = "ShieldTree",
	Name = "Shield",
	Descriptions = [
		"shields"
	],
	Tree = [
		[],
		[
			gt.Const.Perks.PerkDefs.ShieldBash
		],
		[
			gt.Const.Perks.PerkDefs.LegendSpecialistShieldPush
		],
		[
			gt.Const.Perks.PerkDefs.ShieldExpert
		],
		[
			gt.Const.Perks.PerkDefs.LegendSpecialistShieldSkill
		],
		[],
		[]
	]
};
gt.Const.Perks.HeavyArmorTree <- {
	ID = "HeavyArmorTree",
	Name = "Heavy Armor",
	Descriptions = [
		"heavy armor"
	],
	Tree = [
		[],
		[
			gt.Const.Perks.PerkDefs.SteelBrow
		],
		[
			gt.Const.Perks.PerkDefs.Brawny
		],
		[],
		[],
		[
			gt.Const.Perks.PerkDefs.BattleForged
		],
		[
			gt.Const.Perks.PerkDefs.LegendFullForce
		]
	]
};
gt.Const.Perks.MediumArmorTree <- {
	ID = "MediumArmorTree",
	Name = "Medium Armor",
	Descriptions = [
		"medium armor"
	],
	Tree = [
		[],
		[
			gt.Const.Perks.PerkDefs.LegendBalance
		],
		[
			gt.Const.Perks.PerkDefs.LegendPerfectFit
		],
		[],
		[],
		[
			gt.Const.Perks.PerkDefs.LegendLithe
		],
		[
			gt.Const.Perks.PerkDefs.LegendInTheZone
		]
	]
};
gt.Const.Perks.LightArmorTree <- {
	ID = "LightArmorTree",
	Name = "Light Armor",
	Descriptions = [
		"light armor"
	],
	Tree = [
		[],
		[
			gt.Const.Perks.PerkDefs.Dodge
		],
		[
			gt.Const.Perks.PerkDefs.Relentless
		],
		[],
		[],
		[
			gt.Const.Perks.PerkDefs.Nimble
		],
		[
			gt.Const.Perks.PerkDefs.LegendFreedomOfMovement
		]
	]
};
gt.Const.Perks.DefenseTrees <- {
	Tree = [
		gt.Const.Perks.ShieldTree,
		gt.Const.Perks.HeavyArmorTree,
		gt.Const.Perks.MediumArmorTree,
		gt.Const.Perks.LightArmorTree
	],
	function getRandom( _exclude )
	{
		local L = [];

		foreach( i, t in this.Tree )
		{
			if (_exclude != null && _exclude.find(t.ID))
			{
				continue;
			}

			L.push(i);
		}

		local r = this.Math.rand(0, L.len() - 1);
		return this.Tree[L[r]];
	}

	function getRandomPerk()
	{
		local tree = this.getRandom(null);
		local L = [];

		foreach( row in tree.Tree )
		{
			foreach( p in row )
			{
				L.push(p);
			}
		}

		local r = this.Math.rand(0, L.len() - 1);
		return L[r];
	}

};

