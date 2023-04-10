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
// artifact		Easiest.
//			10 combats with normal shadow creatures; mundane shadow item
//			non-combat offers a choice for the artifact.
// entity		Most profitable, but hardest.
//			10 combats with normal shadow creatures
//			non-combat replaced by shadow boss, with combat powers
//			Each boss always drops two specific mundane shadow items
// items		10 combats with normal shadow creatures.
//			non-combat offers buffs or stats
//			costs 3 of a specific mundane shadow item

string quest_goal = define_property( "VSR.QuestGoal", "string", "artifact" );

// If we seek items, the Shadow Labyrinth will give us a buff or stats.
// Which one do you want?
//
// muscle		90-100 Muscle substats
// mysticality		90-100 Mysticality substats
// moxie		90-100 Moxie substats
// effects		+3 turns to 3 random effects
// maxHP		30 Shadow's Heart: Maximum HP +300%
// maxMP		30 Shadow's Chill: Maximum MP +300
// resistance		30 Shadow's Thickness: +5 Spooky, Hot, Sleaze resistance

string labyrinth_goal = define_property( "VSR.LabyrinthGoal", "string", "maxHP" );

// What is our quest reward?
//
// forge		Opens Shadow Forge until you use an adventure.
//			You can craft special shadow items from mundane shadow items.
// waters		30 turns of Shadow Waters:
//			Initiative: +100, Item Drop: +100, Meat Drop: +200, Combat Rate: -10
// forest		(Once per day) 2-3 each of the 3 mundane items from the
//			specific ingress you used to enter the Shadow Rift

// Default is "forest" (or "waters" if already looted forest today).
string quest_reward = define_property( "VSR.QuestReward", "string", "forest" );

// Which shadow rift ingress to use?
//
// desertbeach		shadow flame	shadow fluid	shadow sinew
// forestvillage	shadow bread	shadow ice	shadow venom
// mclargehuge		shadow skin	shadow ice	shadow stick
// beanstalk		shadow fluid	shadow glass	shadow nectar
// manor3		shadow sausage	shadow flame	shadow venom
// 8bit			shadow ice	shadow fluid	shadow glass
// pyramid		shadow sausage	shadow brick	shadow sinew
// giantcastle		shadow sausage	shadow bread	shadow fluid
// woods		shadow flame	shadow nectar	shadow stick
// hiddencity		shadow brick	shadow sinew	shadow nectar
// cemetery		shadow bread	shadow brick	shadow stick
// plains		shadow sausage	shadow skin	shadow venom
// town_right		shadow skin	shadow bread	shadow glass
//
// random		Pick one at random from the 13 possible
//			If looking for "items", pick one that has that mundane item.

string rift_ingress = define_property( "VSR.RiftIngress", "string", "random" );

static string[string] rift_name = {
    "desertbeach" : "Shadow Rift (Desert Beach)",
    "forestvillage" : "Shadow Rift (Forest Village)",
    "mclargehuge" : "Shadow Rift (Mt. McLargeHuge)",
    "beanstalk" : "Shadow Rift (Somewhere Over the Beanstalk)",
    "manor3" : "Shadow Rift (Spookyraven Manor Third Floor)",
    "8bit" : "Shadow Rift (The 8-Bit Realm)",
    "pyramid" : "Shadow Rift (The Ancient Buried Pyramid)",
    "giantcastle" : "Shadow Rift (The Castle in the Clouds in the Sky)",
    "woods" : "Shadow Rift (The Distant Woods)",
    "hiddencity" : "Shadow Rift (The Hidden City)",
    "cemetery" : "Shadow Rift (The Misspelled Cemetary)",
    "plains" : "Shadow Rift (The Nearby Plains)",
    "town_right" : "Shadow Rift (The Right Side of the Tracks)",

    "random" : "(a random ingress)"
};

static location[int] all_rifts = {
    0 : $location[ Shadow Rift (Desert Beach)],
    1 : $location[ Shadow Rift (Forest Village)],
    2 : $location[ Shadow Rift (Mt. McLargeHuge)],
    3 : $location[ Shadow Rift (Somewhere Over the Beanstalk)],
    4 : $location[ Shadow Rift (Spookyraven Manor Third Floor)],
    5 : $location[ Shadow Rift (The 8-Bit Realm)],
    6 : $location[ Shadow Rift (The Ancient Buried Pyramid)],
    7 : $location[ Shadow Rift (The Castle in the Clouds in the Sky)],
    8 : $location[ Shadow Rift (The Distant Woods)],
    9 : $location[ Shadow Rift (The Hidden City)],
    10 : $location[ Shadow Rift (The Misspelled Cemetary)],
    11 : $location[ Shadow Rift (The Nearby Plains)],
    12 : $location[ Shadow Rift (The Right Side of the Tracks)],
};

location ingress_to_location(string ingress)
{
    if (ingress == "random") {
	return all_rifts[random(count(all_rifts))];
    }
    return rift_name[ingress].to_location();
}

static string[string] rift_items = {
    $location[ Shadow Rift (The 8-Bit Realm)] : "shadow ice, shadow fluid, shadow glass",
    $location[ Shadow Rift (Desert Beach)] : "shadow flame, shadow fluid, shadow sinew",
    $location[ Shadow Rift (Somewhere Over the Beanstalk)] : "shadow fluid, shadow glass, shadow nectar",
    $location[ Shadow Rift (The Castle in the Clouds in the Sky)] : "shadow sausage, shadow bread, shadow fluid",
    $location[ Shadow Rift (The Misspelled Cemetary)] : "shadow bread, shadow brick, shadow stick",
    $location[ Shadow Rift (The Hidden City)] : "shadow brick, shadow sinew, shadow nectar",
    $location[ Shadow Rift (Mt. McLargeHuge)] : "shadow skin, shadow ice, shadow stick",
    $location[ Shadow Rift (The Nearby Plains)] : "shadow sausage, shadow skin, shadow venom",
    $location[ Shadow Rift (The Ancient Buried Pyramid)] : "shadow sausage, shadow brick, shadow sinew",
    $location[ Shadow Rift (Spookyraven Manor Third Floor)] : "shadow sausage, shadow flame, shadow venom",
    $location[ Shadow Rift (The Right Side of the Tracks)] : "shadow skin, shadow bread, shadow glass",
    $location[ Shadow Rift (Forest Village)] : "shadow bread, shadow ice, shadow venom",
    $location[ Shadow Rift (The Distant Woods)] : "shadow flame, shadow nectar, shadow stick",
};

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

void main(string parameters)
{
    void parse_parameters()
    {
	foreach n, keyword in parameters.split_string(" ") {
	    switch (keyword) {
	    case "artifact":
	    case "entity":
	    case "items":
		quest_goal = keyword;
	        break;
	    case "forge":
	    case "waters":
	    case "forest":
		quest_reward = keyword;
	        break;
	    case "desertbeach":
	    case "forestvillage":
	    case "mclargehuge":
	    case "beanstalk":
	    case "manor3":
	    case "8bit":
	    case "pyramid":
	    case "giantcastle":
	    case "woods":
	    case "hiddencity":
	    case "cemetery":
	    case "plains":
	    case "town_right":
	    case "random":
		rift_ingress = keyword;
	    	break;
	    case "muscle":
	    case "mysticality":
	    case "moxie":
	    case "effects":
	    case "maxHP":
	    case "maxMP":
	    case "resistance":
		labyrinth_goal = keyword;
	    	break;
	    default:
		abort("Unrecognized keyword: " + keyword);
	    }
	}
    }

    parse_parameters();

    if (get_property("questRufus") != "unstarted") {
	abort("You are already on a quest for Rufus: " +
	      get_property("rufusQuestType") +
	      " -> " +
	      get_property("rufusQuestTarget"));
    }

    if (get_property("_shadowAffinityToday").to_boolean() &&
	!user_confirm("You have already gained Shadow Affinity today, so this will take turns. Are you sure?")) {
	exit;
    }

    int lodestones = item_amount(SHADOW_LODESTONE);
    if (lodestones > 0 ) {
	abort("You already have " + lodestones + " shadow lodestones in inventory.");
    }

    print("You want to accept an " + quest_goal + " quest from Rufus.");
    print("You want the '" + quest_reward + "' reward for accomplishing that.");
    if (quest_goal == "items") {
	print("You want the '" + labyrinth_goal + "' result from the Shadow Labyrinth.");
    }
    if (quest_reward == "forest" && get_property("_shadowForestLooted").to_boolean()) {
	print("(You have already looted the forest today, so instead, you will get Shadow Waters.)");
    }
    print("You want to enter " + rift_name[rift_ingress] + ".");

    // Choose the rift you will enter.
    location rift = ingress_to_location(rift_ingress);
    string rift_name = rift.to_string();
    if (rift_ingress == "random") {
	print("We chose " + rift_name + " for you.");
    }

    // If the goal is "entity", the boss replaces the Shadow Labyrinth.
    // If the goal is "artifact", automation will find it in the Shadow Labyrinth.
    // Only if the goal is "items" does the user's desire matter.
    if (quest_goal == "items") {
	set_property("shadowLabyrinthGoal", labyrinth_goal);
    }

    void adventure_once()
    {
	// If we are visiting a new rift, we must go through place.php.
	// That is the url associated with the location we are using.
	// This will redirect to adventure.php
	//
	// Subsequent requests can go straight to adventure.php
	// If we used adventure or adv1, it would do that.
	//
	// However, we don't want KoLmafia to automate combat for us.
	// We'll do that ourself.

	if (rift_ingress != get_property("shadowRiftIngress")) {
	    catch visit_url( rift.to_url() );
	}
	rift = SHADOW_RIFT;

	string page = visit_url( rift.to_url() );
	if ( page.contains_text( "fight.php" ) ) {
	    // Your CCS had better be set up to handle this!
	    run_combat();
	    return;
	}
	if ( page.contains_text( "choice.php" ) ) {
	    // Take the default choice as configured in shadowLabyrinthGoal.
	    // This will get the artifact if you are getting one for Rufus
	    run_choice(-1);
	    return;
	}
	// What is this?
    }

    void collect_reward()
    {
    	string url = rift.to_url();
	string page = visit_url( url );
	if ( page.contains_text( "choice.php" ) ) {
	    int option = reward_option[quest_reward];
	    // You can only get the forest once per day.
	    if (!(available_choice_options() contains option)) {
		option = 2;
	    }
	    run_choice(option);
	    return;
	}

	// Say what? You have a shadow lodestone.
	if ( page.contains_text( "fight.php" ) ) {
	    // Your CCS had better be set up to handle this!
	    run_combat();
	    return;
	}
	// What is this?
	abort("What happened?");
    }

    // Accept a quest from Rufus.
    visit_url("inv_use.php?&whichitem=" + PAY_PHONE.to_int() + "&pwd");
    run_choice(rufus_option[quest_goal]);

    print("You accepted an '" + get_property("rufusQuestType") + "' quest to get " + get_property("rufusQuestTarget"));

    try {
	cli_execute( "checkpoint" );
	// use_familiar(fam);
	maximize("Item Drop, -equip broken champagne bottle", false);

	// If we have Shadow Affinity, get Steely-Eyed Squint, which
	// doubles Item Drop bonuses for one turn. 
	if (have_effect(SHADOW_AFFINITY) > 0 &&
	    have_skill(STEELY_EYED_SQUINT) &&
	    !get_property("_steelyEyedSquintUsed").to_boolean()) {
	    // use_skill(1, STEELY_EYED_SQUINT);
	}

	while (get_property("questRufus") == "started") {
	    // The first time you go through the rift to The 8-bit Realm,
	    // We will equip the continuum transfunctioner. Subsequent
	    // adventures do not need it, so restore item drop outfit.
	    try {
		cli_execute( "checkpoint" );
		adventure_once();
	    } finally {
		cli_execute( "outfit checkpoint" );
	    }
	}

	if (get_property("questRufus") != "step1") {
	    // This is unexpected. Perhaps you didn't have enough items
	    // and were counting on adventuring to get them for you?
	    abort("Could not fulfill Rufus's quest.");
	}

	// If we have left over turns of Shadow Affinity, use them up by
	// adventuring in the Shadow Rift.
	while (have_effect(SHADOW_AFFINITY) > 0) {
	    adventure_once();
	}
    } finally {
	cli_execute( "outfit checkpoint" );
    }

    // Fulfill the quest with Rufus
    visit_url("inv_use.php?&whichitem=" + PAY_PHONE.to_int() + "&pwd");
    run_choice(1);

    // You should now have Rufus's shadow lodestone
    lodestones = item_amount(SHADOW_LODESTONE);
    if (lodestones == 0 ) {
	abort("You didn't get a shadow lodestone!");
    }

    // Adventure once more to collect your reward
    collect_reward();

    print("Done adventuring in the Shadow Rift!");
}