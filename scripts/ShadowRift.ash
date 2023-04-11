import <vprops.ash>;

// ***************************
// *     Configuration       *
// ***************************

//-------------------------------------------------------------------------
// All of the configuration variables have default values, which apply
// to any character who does not override the variable using the
// appropriate property.
//
// You can edit the default here in the script and it will apply to all
// characters which do not override it.
//
// define_property( PROPERTY, TYPE, DEFAULT )
// define_property( PROPERTY, TYPE, DEFAULT, COLLECTION )
// define_property( PROPERTY, TYPE, DEFAULT, COLLECTION, DELIMITER )
//
// Otherwise, you can change the value for specific characters in the gCLI:
//
//     set PROPERTY=VALUE
//
// Both DEFAULT and a property VALUE will be normalized
//
// All properties used directly by this script start with "VMF."
//-------------------------------------------------------------------------

// What is our quest goal?
//
// artifact             Easiest.
//                      10 combats with normal shadow creatures; mundane shadow item
//                      non-combat offers a choice for the artifact.
// entity               Most profitable, but hardest.
//                      10 combats with normal shadow creatures
//                      non-combat replaced by shadow boss, with combat powers
//                      Each boss always drops two specific mundane shadow items
// items                10 combats with normal shadow creatures.
//                      non-combat offers buffs or stats
//                      costs 3 of a specific mundane shadow item

string quest_goal = define_property( "VSR.QuestGoal", "string", "artifact" );

// If we seek items, the Shadow Labyrinth will give us a buff or stats.
// Which one do you want?
//
// muscle               90-100 Muscle substats
// mysticality          90-100 Mysticality substats
// moxie                90-100 Moxie substats
// effects              +3 turns to 3 random effects
// maxHP                30 Shadow's Heart: Maximum HP +300%
// maxMP                30 Shadow's Chill: Maximum MP +300
// resistance           30 Shadow's Thickness: +5 Spooky, Hot, Sleaze resistance

string labyrinth_goal = define_property( "VSR.LabyrinthGoal", "string", "maxHP" );

// What is our quest reward?
//
// forge                Opens Shadow Forge until you use an adventure.
//                      You can craft special shadow items from mundane shadow items.
// waters               30 turns of Shadow Waters:
//                      Initiative: +100, Item Drop: +100, Meat Drop: +200, Combat Rate: -10
// forest               (Once per day) 2-3 each of the 3 mundane items from the
//                      specific ingress you used to enter the Shadow Rift

// Default is "forest" (or "waters" if already looted forest today).
string quest_reward = define_property( "VSR.QuestReward", "string", "forest" );

// Which shadow rift ingress to use?
//
// desertbeach          shadow flame    shadow fluid    shadow sinew
// forestvillage        shadow bread    shadow ice      shadow venom
// mclargehuge          shadow skin     shadow ice      shadow stick
// beanstalk            shadow fluid    shadow glass    shadow nectar
// manor3               shadow sausage  shadow flame    shadow venom
// 8bit                 shadow ice      shadow fluid    shadow glass
// pyramid              shadow sausage  shadow brick    shadow sinew
// giantcastle          shadow sausage  shadow bread    shadow fluid
// woods                shadow flame    shadow nectar   shadow stick
// hiddencity           shadow brick    shadow sinew    shadow nectar
// cemetery             shadow bread    shadow brick    shadow stick
// plains               shadow sausage  shadow skin     shadow venom
// town_right           shadow skin     shadow bread    shadow glass
//
// random               Pick one at random from the 13 possible
//
// This will be the rift we collect the reward from. If Rufus wants "items", we might
// have to pick a different one that has the specific mundane item that Rufus wants.

string rift_ingress = define_property( "VSR.RiftIngress", "string", "random" );

// Should we buy items to fulfill an "items" quest?

boolean buy_shadow_items = define_property( "VSR.BuyShadowItems", "boolean", "true" ).to_boolean();

// Should we use up turns of Shadow Affinity?

boolean use_up_shadow_affinity = define_property( "VSR.UseUpShadowAffinity", "boolean", "true" ).to_boolean();

// ***************************
// *     Shadow Rifts        *
// ***************************

record ShadowRift {
    string ingress;	// Keyword for ingress (as saved in "shadowRiftIngress"
    location loc;	// The location-via-ingress to adventure in
    item[3] items;	// The items you can find through this ingress
};

typedef ShadowRift[int] ShadowRiftArray;
boolean contains_rift(ShadowRiftArray rifts, ShadowRift rift)
{
    foreach n, r in rifts {
	if (r == rift) {
	    return true;
	}
    }
    return false;
}

static ShadowRift[string] ingress_to_rift;
static ShadowRiftArray[item] item_to_rifts;

ShadowRift makeShadowRift(string ingress, string container, string... types)
{
    if (count(types) != 3) {
	abort("ShadowRift(" + ingress +") has " + count(types) + " items.");
    }

    location loc = to_location("Shadow Rift (" + container + ")");
    item[] items = {
	to_item("shadow " + types[0]),
	to_item("shadow " + types[1]),
	to_item("shadow " + types[2]),
    };

    ShadowRift rift = new ShadowRift(ingress, loc, items);

    // Add to maps:
    ingress_to_rift[ingress] = rift;

    // Add to map: item -> ShadowRiftArray
    foreach n, it in items {
	ShadowRiftArray array = item_to_rifts[it];
	array[count(array)] = rift;
    }

    return rift;
}

static ShadowRift[] allRifts = {
    // These are sorted by container name. Not that it matters.
    makeShadowRift("desertbeach", "Desert Beach", "flame", "fluid", "sinew"),
    makeShadowRift("forestvillage", "Forest Village", "bread", "ice", "venom"),
    makeShadowRift("mclargehuge", "Mt. McLargeHuge", "skin", "ice", "stick"),
    makeShadowRift("beanstalk", "Somewhere Over the Beanstalk", "fluid", "glass", "nectar"),
    makeShadowRift("manor3", "Spookyraven Manor Third Floor", "sausage", "flame", "venom"),
    makeShadowRift("8bit", "The 8-Bit Realm", "ice", "fluid", "glass"),
    makeShadowRift("pyramid", "The Ancient Buried Pyramid", "sausage", "brick", "sinew"),
    makeShadowRift("giantcastle", "The Castle in the Clouds in the Sky", "sausage", "bread", "fluid"),
    makeShadowRift("woods", "The Distant Woods", "flame", "nectar", "stick"),
    makeShadowRift("hiddencity", "The Hidden City", "brick", "sinew", "nectar"),
    makeShadowRift("cemetery", "The Misspelled Cemetary", "bread", "brick", "stick"),
    makeShadowRift("plains", "The Nearby Plains", "sausage", "skin", "venom"),
    makeShadowRift("town_right", "The Right Side of the Tracks", "skin", "bread", "glass"),
};

string rift_name(string ingress)
{
    if (ingress == "random") {
	return "(a random ingress)";
    }
    if (ingress_to_rift contains ingress) {
	return ingress_to_rift[ingress].loc.to_string();
    }
    // An abort is harsh, but validation should have eliminated this.
    abort("Ingress '" + ingress + "' is unknown");
    // Really, ASH?
    exit;
}

ShadowRift ingress_to_rift(string ingress)
{
    if (ingress == "random") {
	return allRifts[random(count(allRifts))];
    }
    if (ingress_to_rift contains ingress) {
	return ingress_to_rift[ingress];
    }
    // An abort is harsh, but validation should have eliminated this.
    abort("Ingress '" + ingress + "' is unknown");
    // Really, ASH?
    exit;
}

string rift_items(ShadowRift rift)
{
    return rift.items[0] + ", " + rift.items[1] + ", " + rift.items[2];
}

// ***************************
// *      Constants          *
// ***************************

static item PAY_PHONE = $item[closed-circuit pay phone];
static item SHADOW_LODESTONE = $item[Rufus's shadow lodestone];
static effect SHADOW_AFFINITY = $effect[Shadow Affinity];
static location SHADOW_RIFT = $location[Shadow Rift];
static skill STEELY_EYED_SQUINT = $skill[Steely-Eyed Squint];

static int[string] rufus_option = {
    "entity": 1,
    "artifact": 2,
    "items": 3,
};

static int[string] reward_option = {
    "forge": 1,
    "waters": 2,
    "forest": 3,
};

// ***************************
// *      Validation         *
// ***************************

static string_set quest_goal_options = $strings[
    artifact,
    entity,
    items
];

static string_set labyrinth_goal_options = $strings[
    muscle,
    mysticality,
    moxie,
    effects,
    maxHP,
    maxMP,
    resistance
];

static string_set quest_reward_options = $strings[
    forge,
    waters,
    forest
];

void validate_configuration()
{
    boolean valid = true;

    print( "Validating configuration..." );

    if ( !( quest_goal_options contains quest_goal ) ) {
	print( "VSR.QuestGoal: '" + quest_goal + "' is invalid.", "red" );
	valid = false;
    }

    if ( !( labyrinth_goal_options contains labyrinth_goal ) ) {
	print( "VSR.LabyrinthGoal: '" + labyrinth_goal + "' is invalid.", "red" );
	valid = false;
    }

    if ( !( quest_reward_options contains quest_reward ) ) {
	print( "VSR.QuestReward: '" + quest_goal + "' is invalid.", "red" );
	valid = false;
    }

    if ( ( rift_ingress != "random" ) &&
	 !( ingress_to_rift contains rift_ingress ) ) {
	print( "VSR.RiftIngress: '" + rift_ingress + "' is invalid.", "red" );
	valid = false;
    }

    if ( !valid ) {
	abort( "Correct those errors and try again." );
    }

    print( "All is well!" );
}

// ***************************
// *      Action          *
// ***************************

boolean confirmed = false;

void parse_parameters(string parameters)
{
    print();
    print( "Checking arguments...." );

    foreach n, keyword in parameters.split_string(" ") {
	if (quest_goal_options contains keyword) {
	    quest_goal = keyword;
	    continue;
	}
	if (quest_reward_options contains keyword) {
	    quest_reward = keyword;
	    continue;
	}
	if (ingress_to_rift contains keyword) {
	    rift_ingress = keyword;
	    continue;
	}
	if (labyrinth_goal_options contains keyword) {
	    labyrinth_goal = keyword;
	    continue;
	}
	switch (keyword) {
	case "buy":
	    buy_shadow_items = true;
	    break;
	case "dontbuy":
	    buy_shadow_items = false;
	    break;
	case "useallfree":
	    use_up_shadow_affinity = true;
	    break;
	case "dontuseallfree":
	    use_up_shadow_affinity = false;
	    break;
	case "confirm":
	    confirmed = true;
	    break;
	case "default":
	    // Use this if you want to use whatever your configured
	    // properties are without being nagged.
	    break;
	case "random":
	    rift_ingress = keyword;
	    break;
	default:
	    abort("Unrecognized keyword: " + keyword);
	}
    }

    print( "Cool, cool." );
}

boolean confirmed_free_adventures()
{
    // If don't care if turns are free, ok
    if (confirmed) {
	return true;
    }

    // If we haven't gotten Shadow Affinity today, accepting a quest
    // gives us 11 free turns.
    if (!get_property("_shadowAffinityToday").to_boolean()) {
	return true;
    }

    // If Rufus's quest is ready to turn in, no turns are needed
    if (get_property("questRufus") == "step1") {
	return true;
    }

    // If we are willing to buy items for Rufus, no turns are neded
    if (quest_goal == "items" && buy_shadow_items) {
	return true;
    }

    // We already got Shadow Affinity today and we will be adventuring.
    // Do we have any left?
    int affinity_turns = have_effect(SHADOW_AFFINITY);

    // How soon will the labyrinth or boss appear?
    int turns_until_choice = get_property("encountersUntilSRChoice").to_int();

    // Both of those encounters are free, hence ">=" rather than ">"
    if (affinity_turns >= turns_until_choice) {
	return true;
    }

    string message =
	"You have " + affinity_turns + " of Shadow Affinity (and can't get any more today). " +
	"The labyrinth or shadow boss will arrive in " + turns_until_choice + " turns. " +
	"Are you sure you want to use non-free turns to fulfill a quest for Rufus?";
    return user_confirm(message);
}

void check_quest_state()
{
    print();
    print( "Checking quest state..." );

    int lodestones = item_amount(SHADOW_LODESTONE);
    if (lodestones > 0 ) {
	abort("You have " + lodestones + " shadow lodestones in inventory.");
    }

    string questState = get_property("questRufus");
    if (questState != "unstarted") {
	string type = get_property("rufusQuestType");
	string verb = "";
	string target = get_property("rufusQuestTarget");
	switch (type) {
	case "artifact":
	    verb = "get a ";
	    break;
	case "entity":
	    verb = "fight a ";
	    break;
	case "items":
	    verb = "get 3 ";
	    target = target.to_item().plural;
	    break;
	}
	print("You are already on an '" + type + "' quest to " + verb + target + " for Rufus");
	quest_goal = type;
    }

    if (questState == "step1") {
	print("You have fulfilled Rufus's request and just need to call him back!");
    } else if (!confirmed_free_adventures()) {
	exit;
    }

    print( "Clean. Ready to go!" );
}

void call_rufus()
{
    visit_url("inv_use.php?&whichitem=" + PAY_PHONE.to_int() + "&pwd");
}

void adventure_once(ShadowRift rift)
{
    // The first time you go through the rift to The 8-bit Realm, we
    // will equip the continuum transfunctioner. Subsequent adventures
    // do not need it, so restore item drop outfit.
    boolean checkpoint = rift.ingress != get_property("shadowRiftIngress");
    try {
	if (checkpoint) {
	    cli_execute( "checkpoint" );
	}
	adv1(rift.loc, 0);
    } finally {
	if (checkpoint) {
	    cli_execute( "outfit checkpoint" );
	}
    }
}

void fulfill_quest(ShadowRift rift)
{
    if (quest_goal == "items") {
	item it = get_property("rufusQuestTarget").to_item();
	if (buy_shadow_items) {
	    retrieve_item(3, it);
	    return;
	}
	// If we are adventuring for items, we need to adventure in a
	// rift that drops them.
	ShadowRiftArray rifts = item_to_rifts[it];
	if (!rifts.contains_rift(rift)) {
	    print(rift + " does not offer " + it.plural);
	    rift = rifts[random(count(rifts))];
	    print("We'll find them in " + rift.loc.to_string() + ".");
	}
    }

    // If the goal is "entity", the boss replaces the Shadow Labyrinth.
    // If the goal is "artifact", automation will find it in the Shadow Labyrinth.
    // If the goal is "items", automation will find the desired goal in the Shadow Labyrinth.
    // KoLmafia will not automate if the shadowLabyrinthGoal is "Manual Control".
    // So, set it for either "artifact" or "items".
    if (quest_goal == "artifact" || quest_goal == "items") {
	set_property("shadowLabyrinthGoal", labyrinth_goal);
    }

    try {
	cli_execute( "checkpoint" );
	// Use an item drop familiar?
	maximize("Item Drop, -equip broken champagne bottle", false);

	int affinity_turns = have_effect(SHADOW_AFFINITY);
	boolean free_turns_only = affinity_turns > 0;

	// If we are using only free turns, get Steely-Eyed Squint,
	// which doubles Item Drop bonuses for one turn.
	if (free_turns_only &&
	    have_skill(STEELY_EYED_SQUINT) &&
	    !get_property("_steelyEyedSquintUsed").to_boolean()) {
	    use_skill(1, STEELY_EYED_SQUINT);
	}

	while (get_property("encountersUntilSRChoice") > 0 &&
	       get_property("questRufus") != "step1") {
	    adventure_once(rift);
	}

	if (quest_goal == "entity") {
	    // *** Do special prep here?
	}

	// Fight the boss or traverse the Shadow Labyrinth
	adventure_once(rift);
    } finally {
	cli_execute( "outfit checkpoint" );
    }
}

void collect_reward(ShadowRift rift)
{
    string reward = quest_reward;
    if (reward == "forest" && get_property("_shadowForestLooted").to_boolean()) {
	reward = "waters";
    }
    set_property("choiceAdventure1500", reward_option[reward]);
    adventure_once(rift);
}    

void main(string parameters)
{
    // Check initial configuration
    validate_configuration();

    // Parse parameters and override configuration
    parse_parameters(parameters);

    // Check quest state to ensure we can handle this
    check_quest_state();

    print();
    print("You want to accept an " + quest_goal + " quest from Rufus.");
    print("You want the '" + quest_reward + "' reward for accomplishing that.");
    if (quest_goal == "items") {
	print("You want the '" + labyrinth_goal + "' result from the Shadow Labyrinth.");
    }
    if (quest_reward == "forest" && get_property("_shadowForestLooted").to_boolean()) {
	print("(You have already looted the forest today, so instead, you will get Shadow Waters.)");
    }

    print("You want to enter " + rift_name(rift_ingress) + ".");

    // Choose the rift you will actually enter.
    ShadowRift rift = ingress_to_rift(rift_ingress);
    if (rift_ingress == "random") {
	print("We chose " + rift.loc.to_string() + " for you.");
    }
    print("You will find the following items there: " + rift_items(rift));

    if (get_property("questRufus") == "unstarted") {
	// Accept a quest from Rufus.
	call_rufus();
	run_choice(rufus_option[quest_goal]);
	print("You accepted an '" + get_property("rufusQuestType") + "' quest to get " + get_property("rufusQuestTarget"));
    }

    // If our goal is not already fulfilled, buy items or
    // adventure for artifact, entity, or items
    if (get_property("questRufus") == "started") {
	fulfill_quest(rift);
    } 

    if (get_property("questRufus") != "step1") {
	// Perhaps you didn't have enough items and were counting on
	// free-turn adventuring to get them for you.  Or perhaps the
	// shadow boss beat you.
	abort("Could not fulfill Rufus's quest.");
    }

    if (use_up_shadow_affinity) {
	// If we have left over turns of Shadow Affinity, use them up by
	// adventuring in the Shadow Rift.
	while (have_effect(SHADOW_AFFINITY) > 0) {
	    adventure_once(rift);
	}
    }

    // Fulfill the quest with Rufus
    call_rufus();
    run_choice(1);

    // You should now have Rufus's shadow lodestone
    int lodestones = item_amount(SHADOW_LODESTONE);
    if (lodestones == 0 ) {
	abort("You didn't get a shadow lodestone!");
    }

    // Adventure once more to collect your reward
    collect_reward(rift);

    print("Done adventuring in the Shadow Rift!");
}