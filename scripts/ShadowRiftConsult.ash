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
// This script will use those skills and items.

static skill SILENT_TREATMENT = $skill[ Silent Treatment ];
static skill SAUCEGEYSER = $skill[ Saucegeyser ];
static skill FUNKSLINGING = $skill[ Ambidextrous Funkslinging ];
static item GAS_CAN = $item[ gas can ];

void main(int initround, monster foe, string page)
{
    if (!have_skill(SAUCEGEYSER)) {
	abort("You need to have Saucegeyser");
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
	if (can_still_steal()) {
	    page = steal();
	}
	// Saucegeyser should do enough elemental damage by itself,
	// until the monsters have scaled too much, but Silent Treatment
	// will make it effect for even heavily scaled monsters.
	if (have_skill(SILENT_TREATMENT)) {
	    page = use_skill(SILENT_TREATMENT);
	}
	// Finish the monster off with Saucegeyser!
	while (page.contains_text("fight.php")) {
	    page = use_skill(SAUCEGEYSER);
	}
	return;
    case $monster[ shadow scythe ]:
	// This boss does 90% of your Maximum HP every round. Since it
	// always gets the drop, unless you have equipment or a skill
	// that makes it miss or skip its first attack, you need to
	// one-shot it. Fortunately, it has relatively few HP.
	while (page.contains_text("fight.php")) {
	    page = use_skill(SAUCEGEYSER);
	}
	return;
    case $monster[ shadow orrery ]:
	// This boss reflects spells and has enhanced Elemental
	// resistance. It is worth eliminating its resistances.
	if (have_skill(SILENT_TREATMENT)) {
	    page = use_skill(SILENT_TREATMENT);
	}
	// If you eliminated its resistances, you could probably just
	// fight it with your weapon. However, it's easier to simply
	// throw gas cans at it until it burns up.
	while (page.contains_text("fight.php")) {
	    // You don't NEED Funkslinging, but it will finish off the
	    // monster in fewer rounds.
	    if (have_skill(FUNKSLINGING)) {
		page = throw_items(GAS_CAN, GAS_CAN);
	    } else {
		page = throw_item(GAS_CAN);
	    }
	}
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
	// it with good old Saucegeyser.
	if (have_skill(SILENT_TREATMENT)) {
	    page = use_skill(SILENT_TREATMENT);
	}
	// Finish the monster off with Saucegeyser!
	while (page.contains_text("fight.php")) {
	    page = use_skill(SAUCEGEYSER);
	}
	return;
    }

    // We don't expect to see any other monsters through a Shadow Rift;
    // I don't believe wanderers show up there. If we do see one, just
    // beat it into submission.
    while (page.contains_text("fight.php")) {
	attack();
    }
}