import <vprops.ash>;

// This consult script handles all the monsters you can encounter
// through the Shadow Rift.
//
// Add this to your CCS to use it:
//
// [ shadow rift ]
// consult ShadowRiftConsult.ash
//
// Each ingress gives access to three different "normal" shadow
// monsters, each of which has a chance of dropping a particular mundane
// shadow item.
//
// Additionally, each time you call Rufus on your closed-circuit pay phone
// and accept his quest to defeat a shadow entity, one of six shadow bosses
// will appear after you have fought with 10 "normal" shadow monsters.
// The bosses each have guaranteed drops for two specific shadow items.
//
// All shadow monsters, normal and boss, have 100% physical resistance.
// Their Atk, Def, and HP each have a fixed base, but scale up for every
// combat you have in the Shadow Rift, win or lose.
// Their Elemental Resistance also scales up with each combat, capping at 90%.
//
// monster          Init    Atk (sc)    Def (sc)    HP (sc)    Elem (sc)  Special
// ---------------------------------------------------------------------------------
// shadow bat       300     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow cow       200     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow devil     400     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow guy       100     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow hexagon   lose    100 (+5)    100 (+5)     200 (+10)  0 (+1)
// shadow orb       100     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow prism     lose    100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow slab      200     100 (+5)    100 (+5)     200 (+10)  0 (+1)
// shadow snake     300     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow spider    300     100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow stalk     lose    100 (+5)    100 (+5)     100 (+10)  0 (+1)
// shadow tree      lose    100 (+5)    100 (+5)     200 (+10)  0 (+1)
//
// shadow cauldron  lose    300 (+5)    300 (+5)    1000 (+10)  0 (+1)    passive hot damage
// shadow matrix    1000    300 (+5)    300 (+5)     500 (+10)  0 (+1)    blocks physical attacks
// shadow orrery    lose    300 (+5)    300 (+5)     250 (+10) 50 (+1)    reflects skills
// shadow scythe    win     300 (+5)    300 (+5)      50 (+10)  0 (+1)    deals 90% Maximum HP
// shadow spire     lose    300 (+5)    300 (+5)     500 (+10)  0 (+1)    deals 30-35% Maximum HP
// shadow tongue    200     300 (+5)    300 (+5)     500 (+10)  0 (+1)    passive sleaze damage

// Observations:
//
// With 100% physical resistance, you need skills to do enough damage.
// The shadow orrery reflects skills, but combat items can provide elemental damage
// The shadow scythe will kill you on its second hit.
// The shadow spire will kill you in 3-4 hits
//
// Strategy:
//
// Silent Treatment is a skill which negates physical and elemental
// resistances. This skill makes these combats trivial, even after a lot
// of scaling. Caveat: you don't have time to use it on the shadow scythe.
//
// Saucegeyser does a lot of elemental damage. It suffices by itself for
// shadow monsters that have not scaled up their elemental resistance
// TOO much. Caveat: shadow orrery reflects skills.
//
// Elemental combat items work nicely, although scaling elemental
// resistance affects the damage. I've used love songs, for example, to
// good effect. However, there is (at least) one especially interesting
// combat item: the gas can does 25% of the monster's current HP when
// you throw it, and the same percentage at the end of the round. On top
// of that, it does a decaying amount of damage in subsequent rounds.
//
// This script will use those skills and items by default, although you
// can configure others, if desired.

// ***************************
// *     Configuration       *
// ***************************

// Which combat skill to use.
skill combat_spell = define_property( "VSR.CombatSpell", "skill", "Saucegeyser" ).to_skill();

// Which combat item to use.
item combat_item = define_property( "VSR.CombatItem", "item", "gas can" ).to_item();

// ***************************
// *      Validation         *
// ***************************

static skill NO_SKILL = $skill[ none ];
static item NO_ITEM = $item[ none ];

// You don't HAVE to use a combat spell or item, if your equipment adds
// enough elemental damage to your attack, but they'll speed up combat.

if ( !have_skill( combat_spell ) || ( combat_spell.type != "combat" ) ) {
    combat_spell = NO_SKILL;
 }

if ( !combat_item.combat ) {
    combat_item = NO_ITEM;
 }

// ***************************
// *        Action           *
// ***************************

// A combat skill which negates foe's physical and elemental resistances
static skill SILENT_TREATMENT = $skill[ Silent Treatment ];

// A passive skill which lets you throw two combat items at once.
static skill FUNKSLINGING = $skill[ Ambidextrous Funkslinging ];

// An item which forces you to attack, rather than use skills and items.
static item DRUNKULA = $item[ Drunkula's wineglass ];

void main(int initround, monster foe, string page)
{
    boolean must_attack = have_equipped( DRUNKULA );
    boolean no_combat_spells = ( foe == $monster[ shadow orrery ] );
    boolean can_funksling = have_skill(FUNKSLINGING);
    boolean have_silent_treatment = have_skill(SILENT_TREATMENT);

    // Mundane shadow monsters are worth pickpocketing
    void pickpocket()
    {
	if (can_still_steal()) {
	    page = steal();
	}
    }

    // Your combat spells should do enough elemental damage by itself,
    // until the monsters have scaled too much, but Silent Treatment
    // will make it effective for even heavily scaled monsters.
    void shun()
    {
	if ( !must_attack && have_silent_treatment ) {
	    page = use_skill( SILENT_TREATMENT );
	}
    }

    // Finish the monster off!
    void slay()
    {
	while ( page.contains_text("fight.php") ) {
	    if ( must_attack ) {
		page = attack();
	    } else if ( no_combat_spells ) {
		int items = item_amount( combat_item );
		// You don't NEED Funkslinging, but it will finish off
		// the monster in fewer rounds.
		if (items == 0) {
		    page = attack();
		} else if (items > 1 && can_funksling) {
		    page = throw_items( combat_item, combat_item );
		} else {
		    page = throw_item( combat_item );
		}
	    } else if ( combat_spell != NO_SKILL ) {
		page = use_skill( combat_spell );
	    } else {
		page = attack();
	    }
	}
    }

    switch ( foe ) {
    case $monster[ shadow bat ]:
    case $monster[ shadow cow ]:
    case $monster[ shadow devil ]:
    case $monster[ shadow guy ]:
    case $monster[ shadow hexagon ]:
    case $monster[ shadow orb ]:
    case $monster[ shadow prism ]:
    case $monster[ shadow slab ]:
    case $monster[ shadow snake ]:
    case $monster[ shadow spider ]:
    case $monster[ shadow stalk ]:
    case $monster[ shadow tree ]:
	// These are the mundane shadow monsters
	//
	// They each have a 10-20% base chance to drop a single item.
	// Item Drop is reduced by 80% in the Shadow Rift, but
	// pickpocket percentage is unreduced. It is well worth trying
	// to steal, since the monsters are not especially dangerous.
	pickpocket();
	shun();
	slay();
	return;
    case $monster[ shadow scythe ]:
	// This boss does 90% of your Maximum HP every round. Since it
	// always gets the drop, unless you have equipment or a skill
	// that makes it miss or skip its first attack, you need to
	// one-shot it. Fortunately, it has relatively few HP.
	slay();
	return;
    case $monster[ shadow orrery ]:
	// This boss reflects spells and has enhanced Elemental
	// resistance. It is worth eliminating its resistances.
	shun();
	slay();
	return;
    case $monster[ shadow cauldron ]:
    case $monster[ shadow tongue ]:
	// These bosses deal passive elemental damage, but otherwise are
	// not a problem, assuming you have enough HP.
    case $monster[ shadow matrix ]:
	// This boss blocks physical attacks. Fortunately, skills work.
    case $monster[ shadow spire ]:
	// This boss does 30-35% of your Maximum HP every time it hits
	// you.  We have time to negate its resistances before defeating
	// it with our combat spell.
	shun();
	slay();
	return;
    }

    // We don't expect to see any other monsters through a Shadow Rift;
    // I don't think wanderers show up there. If we do see one (perhaps
    // the user set this consult script for use elsewhere?), try to
    // steal something and then just beat the monster into submission.
    pickpocket();
    slay();
}