this.hidden_effect <- this.inherit("scripts/skills/skill", {
	m = {
		ToRemove = false
	},
	function create()
	{
		this.m.ID = "terrain.hidden";
		this.m.Name = "Hidden";
		this.m.Description = "This character is hidden by terrain and cannot be seen by opponents unless directly adjacent or attacking them first.";
		this.m.Icon = "skills/status_effect_08.png";
		this.m.IconMini = "status_effect_08_mini";
		this.m.Type = this.Const.SkillType.Terrain | this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function getDescription()
	{
		local ret = this.m.Description;
		return ret;
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			}
		];
		local actor = this.getContainer().getActor();

		if (actor.getSkills().hasSkill("perk.legend_assassinate"))
		{
			ret.extend([
				{
					id = 11,
					type = "text",
					icon = "ui/icons/regular_damage.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+50%[/color] Minimum and Maximum Damage from the Assassinate perk"
				}
			]);
		}

		if (actor.getSkills().hasSkill("background.legend_assassin") || actor.getSkills().hasSkill("background.assassin") || actor.getSkills().hasSkill("background.assassin_southern"))
		{
			ret.extend([
				{
					id = 13,
					type = "text",
					icon = "ui/icons/regular_damage.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+50%[/color] Maximum Damage from being an assassin"
				}
			]);
		}

		if (actor.getSkills().hasSkill("background.legend_commander_assassin"))
		{
			ret.extend([
				{
					id = 13,
					type = "text",
					icon = "ui/icons/regular_damage.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+75%[/color] Maximum Damage from being an experienced assassin"
				}
			]);
		}

		if (this.m.ToRemove)
		{
			ret.extend([
				{
					id = 15,
					type = "text",
					text = "Will be revealed at the end of the round"
				}
			]);
		}
		else
		{
			ret.extend([
				{
					id = 15,
					type = "text",
					text = "Will remain hidden"
				}
			]);
		}

		return ret;
	}

	function onMovementCompleted( _tile )
	{
		if (_tile.hasZoneOfControlOtherThan(this.getContainer().getActor().getAlliedFactions()))
		{
			this.getContainer().getActor().setHidden(false);
			this.m.ToRemove = true;
			return;
		}

		this.getContainer().getActor().setHidden(true);
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		this.getContainer().getActor().setHidden(false);
		this.m.ToRemove = true;
	}

	function onTargetMissed( _skill, _targetEntity )
	{
		this.getContainer().getActor().setHidden(false);
		this.m.ToRemove = true;
	}

	function onAdded()
	{
		local actor = this.getContainer().getActor();

		if (actor.getTile().IsVisibleForPlayer)
		{
			if (this.Const.Tactical.HideParticles.len() != 0)
			{
				for( local i = 0; i < this.Const.Tactical.HideParticles.len(); i = i )
				{
					this.Tactical.spawnParticleEffect(false, this.Const.Tactical.HideParticles[i].Brushes, actor.getTile(), this.Const.Tactical.HideParticles[i].Delay, this.Const.Tactical.HideParticles[i].Quantity, this.Const.Tactical.HideParticles[i].LifeTimeQuantity, this.Const.Tactical.HideParticles[i].SpawnRate, this.Const.Tactical.HideParticles[i].Stages);
					i = ++i;
				}
			}
		}
	}

	function onRemoved()
	{
		this.getContainer().getActor().setHidden(false);
		local actor = this.getContainer().getActor();

		if (!::Tactical.State.isBattleEnded() && actor.isPlacedOnMap())
		{
			if (actor.getTile().IsVisibleForPlayer)
			{
				if (this.Const.Tactical.HideParticles.len() != 0)
				{
					for( local i = 0; i < this.Const.Tactical.HideParticles.len(); i = i )
					{
						this.Tactical.spawnParticleEffect(false, this.Const.Tactical.HideParticles[i].Brushes, actor.getTile(), this.Const.Tactical.HideParticles[i].Delay, this.Const.Tactical.HideParticles[i].Quantity, this.Const.Tactical.HideParticles[i].LifeTimeQuantity, this.Const.Tactical.HideParticles[i].SpawnRate, this.Const.Tactical.HideParticles[i].Stages);
						i = ++i;
					}
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local actor = this.getContainer().getActor();

		if (actor.getSkills().hasSkill("perk.legend_assassinate"))
		{
			_properties.DamageRegularMin *= 1.2;
			_properties.DamageRegularMax *= 1.2;

			if (actor.getSkills().hasSkill("background.legend_assassin") || actor.getSkills().hasSkill("background.assassin") || actor.getSkills().hasSkill("background.assassin_southern"))
			{
				_properties.DamageRegularMax *= 1.3;
			}

			if (actor.getSkills().hasSkill("background.legend_commander_assassin"))
			{
				_properties.DamageRegularMax *= 1.5;
			}
		}
	}

	function onRoundEnd()
	{
		if (this.m.ToRemove)
		{
			this.getContainer().getActor().setHidden(false);
			this.removeSelf();
		}
	}

	function onCombatFinished()
	{
		this.removeSelf();
		this.m.IsHidden = true;
	}

});

