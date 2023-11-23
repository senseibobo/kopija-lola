# My humble attempt at making a League of Legends clone
This was an exercise to help me with a few things that I previously hadn't known.<br>
Features:
- Multiplayer lobby with one instance as administrator
- Pathfinding through polygons
- AI for minions and turrets
- Shop system with item merging to get discounts
- A lot of stats (AD, AP, Armor, Magic Resist, Movement Speed, Crticical Chance etc.)
- Effects (Slow, Speed, Stun, Fear, Charm etc.)
- 4 (and a half) different useable characters with different abilities
- Minimap that can be interacted with
- Leveling system (also leveling abilities)
- JSON files containing all ability descriptions (I made this to be able to change languages in the future)
- Terrible game design and balance :p

The game isn't as optimized as I'd like it to be, because minions, champions, turrets and basically everything else uses Godot physics instead of just actual pure pathfinding in some cases to finish the job. I made this when Godot didn't have dynamic pathfinding obstacles so I chose physics instead.<br>
Even though it isn't as optimized, it was way worse before I did some stuff. To optimize it, I split the game into quadrants and used only nearby quadrants for calculating stuff like what target a minion will chose.<br>
The art could have probably been done better if I had tried, but I was a little more focused on the programming aspect of the game.<br>
I really enjoyed working on this and it took me a few weeks to make. I'm probably going to do something like this again to see my progress.
