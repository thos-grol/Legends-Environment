this.legend_helmet_cloth_cap <- this.inherit("scripts/items/legend_helmets/legend_helmet", {
	m = {},
	function create()
	{
		this.legend_helmet.create();
		this.m.ID = "armor.head.legend_helmet_cloth_cap";
		this.m.Name = "Cloth Cap";
		this.m.Description = "A piece of cloth covering the top of the head.";
		this.m.Variants = [
			1
		];
		this.m.Variant = this.m.Variants[this.Math.rand(0, this.m.Variants.len() - 1)];
		this.updateVariant();
		this.m.ImpactSound = this.Const.Sound.ArmorChainmailImpact;
		this.m.InventorySound = this.Const.Sound.ArmorChainmailImpact;
		this.m.Value = 10;
		this.m.Condition = 15;
		this.m.ConditionMax = 15;
		this.m.StaminaModifier = 0;
		this.m.Vision = 0;
		this.m.HideHair = true;
		this.m.HideBeard = false;
		this.m.ItemType = this.m.ItemType;
	}

	function updateVariant()
	{
		local variant = this.m.Variant > 9 ? this.m.Variant : "0" + this.m.Variant;
		this.m.Sprite = "legendhelms_cloth_cap" + "_" + variant;
		this.m.SpriteDamaged = "legendhelms_cloth_cap" + "_" + variant + "_damaged";
		this.m.SpriteCorpse = "legendhelms_cloth_cap" + "_" + variant + "_dead";
		this.m.Icon = "legend_helmets/inventory_cloth_cap" + "_" + variant + ".png";
		this.m.IconLarge = this.m.Icon;
	}

});

