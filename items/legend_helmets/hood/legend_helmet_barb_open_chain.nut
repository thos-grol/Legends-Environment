this.legend_helmet_barb_open_chain <- this.inherit("scripts/items/legend_helmets/legend_helmet", {
	m = {},
	function create()
	{
		this.legend_helmet.create();
		this.m.ID = "armor.head.legend_helmet_barb_open_chain";
		this.m.Name = "Rusted Open Chain";
		this.m.Description = "A rusty open faced mail chain patched together by the northern tribes.";
		this.m.Variants = [
			1
		];
		this.m.Variant = this.m.Variants[this.Math.rand(0, this.m.Variants.len() - 1)];
		this.updateVariant();
		this.m.ImpactSound = this.Const.Sound.ArmorChainmailImpact;
		this.m.InventorySound = this.Const.Sound.ArmorChainmailImpact;
		this.m.Value = 225;
		this.m.Condition = 65;
		this.m.ConditionMax = 65;
		this.m.StaminaModifier = -3;
		this.m.Vision = 0;
		this.m.HideHair = true;
		this.m.HideBeard = false;
		this.m.ItemType = this.m.ItemType;
	}

	function updateVariant()
	{
		local variant = this.m.Variant > 9 ? this.m.Variant : "0" + this.m.Variant;
		this.m.Sprite = "legendhelms_barb_open_chain" + "_" + variant;
		this.m.SpriteDamaged = "legendhelms_barb_open_chain" + "_" + variant + "_damaged";
		this.m.SpriteCorpse = "legendhelms_barb_open_chain" + "_" + variant + "_dead";
		this.m.Icon = "legend_helmets/inventory_barb_open_chain" + "_" + variant + ".png";
		this.m.IconLarge = this.m.Icon;
	}

});

