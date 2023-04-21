# ShadowRift
KoLmafia scripting for Shadow Rifts in Kingdom of Loathing

Shadow Rifts in the Kingdom of Loathing grant access to a strange realm, populated by fearsome shadowy horrors. They are an ongoing world event, but will be permanently accessible in the Avatar of Shadows over Loathing path - or to those who have purchased a closed-circuit telephone system, which allows them to call Rufus and accept chores (quests, if you prefer) for him, for which he grants valuable rewards.

This script automates accepting/fulfilling/redeeming Rufus's quests.

You don't need a script for simply adventuring through the Shadow Rifts, although you might find the included consult script useful for combats there, for inspiration, if nothing else.

### What can ShadowRift do for me?

Rufus offers three kinds of quest:

1) artifact - fight 10 shadow monsters and traverse the Labyrinth of Shadows to retrieve an artifact.
2) entity - fight 10 shadow monsters and then defeat a difficult shadow boss with special powers
3) items - retrieve three of a particular shadow item that is dropped by particular shadow monster.

Since the first quest you accept each day grants 11 turns of Shadow Affinity - which makes combats through a Shadow Rift free - any of the quests can be accomplished with no turns used.

Additionally, an items quest can be fulfilled without even adventuring, if you happen to already have the desired item.

If you complete his chore, Rufus will reward you with a shadow lodestone. Adventuring through a Shadow Rift with that item will give you three possible rewards:

1) forge - access to the Shadow Forge (until you spend an adventure) where you can craft stuff from shadow items.
2) fountain - 30 turns of Shadow Waters, which grants +100 to Initiative, Meat Drop, and Item Drop
3) forest - 2-3 each of three different shadow items, determined by which Shadow Rift you entered. You can get this reward once per day.

You can accept as many quests per day as you want from Rusus (although only the first will not use turns), with the caveat that every combat you have in the Shadow Rift makes all subsequent fights that same day harder; shadow monster Attack, Defense, HP, and Elemental Resistance scale.

ShadowRift will do everything you need to handle all three kinds of quest:

1) Accepting the desired quest type.
2) Adventuring (or buying items, if requested) to accomplish the quest.
3) Returning to Rufus to report success and accept a lodestone.
4) Using the lodestone to gain the reward of your choice

It will work with free turns (first quest) or non-free turns (subsequent quests).

### How do I install ShadowRift?

Super easy. You can find it in KoLmafia's Script Manager, or you can type the following into KoLmafia's gCLI:

```
git install Veracity0/shadow-rift
```

### What do I need to do to run ShadowRift?

First of all, decide what kind of quest you are interested in.
- artifact is the easiest; regular shadow monsters have no special abilities.
- entity is more difficult and more profitable: each shadow boss drops two guarenteed items if you beat it.
- items is **probably** of interest only if you are already have the items (or are willing to buy them), since Item Drop is reduced by 80% in the Shadow Rifts and hoping to farm them in 11 free turns is problematic. But trading in items - and getting a reward - without farming takes no turns and leaves Shadow Affinity untouched, ready for another quest (and reward).

What about Shadow Affinity?
- If you want to use ONLY free turns, cool.
- If you have extra turns - perhaps because you extended the effect - we can use them up for you in free fights.
- If you want to spend non-free turns, also cool.

How are you going to defeat shadow monsters (and perhaps shadow bosses?
- Since ShadowRift automates combats, your CCS needs to understand how to defeat any shadow monster you encounter - and any shadow boss, if you select an "entity" quest.
- We supply ShadowRiftConsult, a consult script which, given some configuration, can handle all shadow monsters and shadow bosses. Up to a point; after many quests with combats in the same day, the monsters may have scaled up too high to handle, depending on your character level.
- ShadowRift & ShadowRiftConsult understand certain skills and items which can make combats much easier, and (configurably) can use them before (ShadowRift) or during (ShadowRiftConsult) combats. In particular, the Space Tourist Phaser, Silent Treatment, and/or Bend Hell can send you far.

### Use Cases

1) See what quests Rufus is looking for. If you are on a quest (and possibly are ready to fulfill it), report that.
```
ShadowRift check
```
2) If you happen to have a Rufus's shadow lodestone in inventory (because you have fulfilled at least one quest without using it), open the Shadow Forge.
```
ShadowRift forge
```
3) Accept a quest to collect 3 items, buy them (if necessary), and get the Shadow Waters reward.
This will not require any combats (or turns), and therefore will not consume Shadow Affinity - although it will grant it, if it is the first quest you accepted of the day.
If it did, in fact, grant you that effect, do not use up the turns, leaving them available for another quest.
```
ShadowRift items waters notallfree
```
4) Accept a quest to collect an artifact using only free turns, turn it in, get the "forest" reward from the Ancient Pyramid, and use up any remaining turns of Shadow Affinity.
```
ShadowRift artifact pyramid forest onlyfree allfree
```
5) Accept a quest to fight a shadow boss, regardless of whether it takes turns, adventuring through any Shadow Rift whose monsters drop shadow fluid, collecting the Shadow Waters reward.
```
ShadowRift entity fluid waters notonlyfree
```
6) Take an items quest and attempt to farm what is needed, regardless of free turns. If you get the Shadow Labyrinth, get Moxie substats. Open the Shadow Forge, if you succeed in fulfilling the quest before then.
I don't recommend this, since, contrary to what you might have intended, even though you are using not-free turns, it limits your liability to 10 turns spent by stopping after the Labyrinth of Shadows.
You can simply repeat the command and try again.
```
Shadowrift check
(Rufus wants 3 shadow flames)
ShadowRift items shadow flame moxie forge notonlyfree
```

### Non-Use Cases (for now)

1) Accepting a quest, fulfilling it, gaining the shadow lodestone, and NOT using it to collect the reward.
This is how you would accumulate multiple shadow lodestones.
I'm not sure why you would want to do that, since the next quest you take and try to fulfill will use the lodestone first. The one exception would be accepting and fulfilling an items quest by buying items.

2) Running turns in the Shadow Rift without accepting a quest.
I suppose you might want to farm specific items, and perhaps ShadowRift's item drop maximization, equipment usage, etc., would be useful.
And perhaps ShadowRiftConsult charms you - in which case you could just use it in your own CCS. But I suspect that people might have other techniques in mind for combats, if they are farming, rather than doing quests.

### How do I configure the above stuff?

ShadowRift uses ```vprops```. This means that you set preferences in the gCLI to configure things as you desire. All properties used by ShadowRift and ShadowRiftConsult start with "VSR.", for "Veracity's Shadow Rift".

```
set VSR.<name>=<value>
```

ShadowRift also accepts parameters on the command line which can override some of those preferences; you can configure defaults, but change which quest to accept, which Shadow Rift to adventure in, which reward you wamt, and so on. This will be discussed in detail in the next section.

Here are the configuration properties.

| property | values | default | purpose |
| :--- | :--- | :--- | :--- |
| ```VSR.QuestGoal``` | artifact, entities, items | artifact | Which quest to accept from Rufus
| ```VSR.QuestReward``` | forge, fountain (waters), forest | forest | Which reward from the shadow lodestone
| ```VSR.LabyrinthGoal``` | (reward) | effects | Which reward from the Shadow Labyrinth, if you are not seeking an artifact.
| ```VSR.RiftIngress``` | (ingress) or random | random | Which Shadow Rift ingress to use.
| ```VSR.FreeTurnsOnly``` | true or false | true | Whether to spend turns on combat
| ```VSR.BuyShadowItems``` | true or false | true | Whether to buy items to fulfill "items" quest
| ```VSR.UseUpShadowAffinity``` | true or false | true | Whether to use up Shadow Affinity after fulfilling quest
| ```VSR.UsePYEC``` | true or false | true | Whether to use Platinum Yendorian Express Card to extand Shadow Affinity by 5 turns
| ```VSR.ChosenFamiliar``` | (familiar) or none | none | If not "none", which familiar to bring with you
| ```VSR.ExtraMaximizerParameters``` | (string) | "" | Extra parameters to usewhen maximizing for item drop
| ```VSR.UseShadowRiftConsult``` | true or false | true | Whether to automatically use ShadowRiftConsult for combats
| ```VSR.UseSpaceTouristPhaser``` | true or false | false | Whether to acquire and equip Space Tourist Phaser for use in combats
| ```VSR.CastSteelyEyedSquint``` | true or false | true | Whether to cast Steely-eyed Squint before free-only combats
| ```VSR.CastBendHell``` | true or false | true | Whether to cast Bend Hell before free-only combats
| ```VSR.CombatSpell``` | (spell) or none | Saucegeyser | Which spell to use in combat against shadow critters
| ```VSR.CombatItem``` | (item) or none | gas can | Which item to use in combat against shadow orrery

The ingress you use determines which monsters you fight and which items will drop.

| ingress | zone | monsters | items |
| :--- | :--- | :--- | :--- |
| desertbeach | Desert Beach | devil, orb, snake | flame, fluid, sinew
| forestvillage | Forest Village | guy, hexagon, spider | bread, ice, venom
| mclargehuge | Mt. McLargeHuge | cow, hexagon, tree | skin, ice, stick
| beanstalk | Somewhere Over the Beanstalk | orb, prism, stalk | fluid, glass, nectar
| manor3 | Spookyraven Manor Third Floor | bat, devil, spider | sausage, flame, venom
| 8bit | The 8-Bit Realm | hexagon, orb, prism | ice, fluid, glass
| pyramid | The Ancient Buried Pyramid | bat, slab, snake | sausage, brick, sinew
| giantcastle | The Castle in the Clouds in the Sky | bat, guy, orb | sausage, bread, fluid
| woods | The Distant Woods | devil, stalk, tree | flame, nectar, stick
| hiddencity | The Hidden City | slab, snake, stalk | brick, sinew, nectar
| cemetery | The Misspelled Cemetary | guy, slab, tree | bread, brick, stick
| plains | The Nearby Plains | bat, cow, spider | sausage, skin, venom
| town_right | The Right Side of the Tracks | cow, guy, prism | skin, bread, glass

The Labyrinth of Shadows contains the artifact you need (if on an artifact quest) and various little rewards (if on an ```items``` - or no - quest)

| reward | description |
| :--- | :--- |
| muscle | 90-100 Muscle substats
| mysticality | 90-100 Mysticality substats
| moxie | 90-100 Moxie substats
| (mainstat) | (whichever of the above corresponds to your class's mainstat)
| effects | +3 turns to 3 random effects
| maxHP | 30 Shadow's Heart: Maximum HP +300%
| maxMP | 30 Shadow's Chill: Maximum MP +300%
| resistance | 30 Shadow's Thickness: +5 Spooky, Hot, Sleaze resistance

### Command Line options

You invoke ShadowRift from the gCLI (or via ```cli_execute``` from another script) with a set of keywords separated by spaces.
Order does not matter.

Most of the keywords override configuration values, as documented above.
Some of them perform a calculation to override a value.

Some of them are essentially stand-alone commands:
```
ShadowRift help
```
Print a help message with this information.
```
ShadowRift check
```
Visit Rufus and see what chores he has in mind for you. This will print out the results and also save them in properties for use in scripts:
| property | values |
| :-- | :-- |
| ```rufusDesiredArtifact``` | ```shadow bucket``` ```shadow heart``` ```shadow heptahedron``` ```shadow lighter``` ```shadow snowflake``` ```shadow wave``` |
| ```rufusDesiredEntity``` | ```shadow cauldron``` ```shadow matrix``` ```shadow orrery``` ```shadow scythe``` ```shadow spire``` ```shadow tongue``` |
| ```rufusDesiredItems``` | ```shadow bread``` ```shadow brick``` ```shadow flame``` ```shadow fluid``` ```shadow glass``` ```shadow ice``` ```shadow nectar``` ```shadow sausage``` ```shadow sinew``` ```shadow skin``` ```shadow stick``` ```shadow venom``` |
```
ShadowRift default
```
If an ASH script's ```main``` function has parameters, KoLmafia requires you to put them on the command line or it will pop up a prompt.
If all of your configuration variables are acceptable as-is and you don't want to give them as command-line arguments, this avoids the prompt.

Others let you override configuration preferences:

| property | values | comments |
| :-- | :-- | :-- |
| ```VSR.QuestGoal``` | artifact entity items |
| ```VSR.QuestReward``` | forge fountain forest |
|  | waters | synonym for fountain |
| ```VSR.LabyrinthGoal``` | muscle mysticality moxie effects maxHP maxMP resistance |
|  | mainstat | your class's prime stat |
| ```VSR.RiftIngress``` | desertbeach forestvillage mclargehuge beanstalk manor3 8bit pyramid giantcastle woods hiddencity cemetery plains town_right |
|  | [shadow] bread brick flame fluid glass ice nectar sausage sinew skin stick venom | shadow is optional. A random rift where the item can be found.|
|  | random | A random rift. For ```items``` quest, one with desired item |
| ```VSR.FreeTurnsOnly``` | onlyfree | Combats must be free |
| | notonlyfree | Combats need not be free |
| ```VSR.BuyShadowItems``` | buy | Buy shadow items for ```items``` quest |
| | nobuy | Adventure for shadow items |
| ```VSR.UseUpShadowAffinity``` | allfree | Use up remaining Shadow Affinity |
| | notallfree | Do not use up Shadow Affinity |

### ShadowRiftConsult strategy

ShadowRift maximizes for Item Drops, optionally equips a Space Tourist Phaser, and optionally casts Steely-Eyed Squint and Bend Hell before automating visits to the Shadow Rifts.

During automation, KoLmafia will invoke ShadowRiftConsult for each fight.

In a Shadow Rift, you can encounter mundane shadow monsters (three types per rift ingress) and, on an entity quest, one of six kinds of shadow bosses. All of these have base values of Attack/Defense/HP, which scale up with the number of combats you've had today with Shadow Rift monsters. All of them are 100% Physical reistant, and have some amount of Elemental resistance, which similarly scales.

ShadowRiftConsult is a consult script, so all it can do is whatever you can do in combat: steal, use combat skills, cast combat spells, use combat items, and so on.

1) For mundane shadow monsters (less dangerous), if you can pickpocket, do so. Item Drops are reduced by 80% in the Shadow Rifts, but that doesn't apply to pickpocket.
2) If you have the "Silent Treatment" skill, which negates physical and elemental resistances, cast it. (Except for the shadow scythe, which will kill you on the second round.)
3) Then repeat, doing your configured choice of action.
   - If you have a combat spell configured, cast it
   - Otherwise, attack
4) Exception: shadow orrery reflects combat spells
   - If you have a combat item configured, throw (or funksling) the item
   - If you have no items configured or are out of items, attack
5) Exception: shadow matrix blocks attacks
   - If you have a combat spell configured, cast it
   - If you have no spell configured, use configured item
   - With no spell or items, abort combat

Note that the consult script has no control over what equipment you are using, but ShadowRift will let you configure a Space Tourist Phaser, which converts physical damage to elemental damage, which lets you effectively attack, even with no combat spells. You will still need items for the shadow matrix.

Two of the above preferences are used by ShadowRiftConsult, as opposed to ShadowRift, to be used as described.

| property | values | default |
| :--- | :--- | :--- |
| ```VSR.CombatSpell``` | (spell) or none | Saucegeyser |
| ```VSR.CombatItem``` | (item) or none | gas can |


### History of Shadow Rifts

1) February 11, 2023: Shadow Rifts appear all over the Kingdom as a (seeming) World Event, a temporary tie-in to Asymmetric's Shadows over Loathing game.

2) February 15, 2023:  KoL's Spring Challenge Path '23 rolls out: Avatar of Shadows over Loathing.

Shadow Rifts become a permanent part of the game, as long as your character is on that Challenge Path.

3)  March 3, 2023: A new turn-free choice adventure - The Shadow Labyrinth - appears every 11 turns spent adventuring in a Shadow Rift.

4)  March 3, 2023: The March Item of the Month, the "closed-circuit phone system" rolls out to Subscribers.

Shadow Rifts become a permanent part of the game, regardless of your character class, for owners of this IOTM.

The IOTM also allows the character to call Rufus and accept quests, as often as you please, and gain access to new content.

The first such quest you accept each day grants you 11 turns of Shadow Affinity, which makes all combats in a Shadow Rift turn-free.
