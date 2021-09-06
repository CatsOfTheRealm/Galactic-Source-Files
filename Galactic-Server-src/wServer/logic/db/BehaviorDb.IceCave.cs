using wServer.logic.behaviors;
using wServer.logic.transitions;
using wServer.logic.loot;
using common.resources;

namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ IceCave = () => Behav()
        .Init("ic boss spawner live",
            new State(
                new TransformOnDeath("Inner Sanctum Portal"),
                new ConditionalEffect(ConditionEffectIndex.Invincible),
                new State("waiting",
                    new PlayerWithinTransition(1000, ":)")
                    ),
                new State(":)",
                    new Taunt("..kill the large ones....open the way....the are meaningless...."),
                    new EntitiesNotExistsTransition(1000, "suicide", "Big Yeti", "Snow Bat Mama")
                    ),
                new State("suicide",
                    new Taunt("Innocent souls. So delicious. You have sated me. Now come, I shall give you your reward."),
                    new TimedTransition(0, "suicide2")
                    ),
                new State("suicide2",
                    new Suicide()
                    )
                )
            )
        .Init("ic boss manager",
            new State(
                new ConditionalEffect(ConditionEffectIndex.Invincible)
                )
            )
        .Init("ic Esben the Unwilling",
            new State(
                new HPScale(12000),
                new TransformOnDeath("ic Loot Balloon"),
                new HpLessTransition(0.1, "die"),
                new State("start",
                    new PlayerWithinTransition(50, "idle", true)
                    ),
                new State("idle",
                    new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                    new OrderOnce(100, "ic boss purifier generator", "spawn crosses"),
                    new TimedTransition(0, "My cross never dead <3")
                    ),
                new State("My cross never dead <3",
                    new Taunt("Ah fresh meat.I must thank you for the souls..."),
                    new Taunt("Icicles, rend their flesh!"),
                    new SetAltTexture(0),
                    new Orbit(0.1, 1, 10, "ic boss manager"),
                    new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                    new EntitiesNotExistsTransition(20, "nooo!", "ic boss purifier"),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 0, coolDownOffset: 3000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 90, coolDownOffset: 3000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 180, coolDownOffset: 3000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 270, coolDownOffset: 3000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 45, coolDownOffset: 4000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 135, coolDownOffset: 4000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 225, coolDownOffset: 4000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 315, coolDownOffset: 4000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 0, coolDownOffset: 5000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 90, coolDownOffset: 5000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 180, coolDownOffset: 5000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 270, coolDownOffset: 5000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 45, coolDownOffset: 6000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 135, coolDownOffset: 6000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 225, coolDownOffset: 6000, coolDown: 15000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 315, coolDownOffset: 6000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 8000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 9000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 11000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 12000, coolDown: 15000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 12000, coolDown: 15000)
                    ),
                new State("nooo!",
                    new Taunt("LOOSING....CONTROL....NOOOO"),
                    new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                    new SetAltTexture(0),
                    new TimedTransition(250, "A")
                    ),
                new State("A",
                    new SetAltTexture(2),
                    new TimedTransition(250, "B")
                    ),
               new State("B",
                   new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                   new SetAltTexture(0),
                   new TimedTransition(250, "C")
                   ),
               new State("C",
                   new SetAltTexture(2),
                   new TimedTransition(250, "D")
                   ),
               new State("D",
                   new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                   new SetAltTexture(0),
                   new TimedTransition(250, "E")
                   ),
               new State("E",
                   new SetAltTexture(2),
                   new TimedTransition(250, "F")
                   ),
               new State("F",
                   new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                   new SetAltTexture(0),
                   new TimedTransition(250, "G")
                   ),
               new State("G",
                   new SetAltTexture(2),
                   new TimedTransition(250, "H")
                   ),
               new State("H",
                   new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                   new SetAltTexture(0),
                   new TimedTransition(250, "I")
                   ),
               new State("I",
                   new SetAltTexture(2),
                   new TimedTransition(250, "J")
                   ),
               new State("J",
                   new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                   new SetAltTexture(0),
                   new TimedTransition(250, "K")
                   ),
               new State("K",
                   new ConditionalEffect(ConditionEffectIndex.Invincible),
                   new SetAltTexture(1),
                   new Shoot(20, 8, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 1000, coolDown: 6000),
                   new Shoot(20, 10, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 2000, coolDown: 6000),
                   new Shoot(20, 12, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 3000, coolDown: 6000),
                   new Shoot(20, 14, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 4000, coolDown: 6000),
                   new Shoot(20, 16, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 5000, coolDown: 6000),
                   new Shoot(20, 18, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 6000, coolDown: 6000),
                   new Shoot(20, 20, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 7000, coolDown: 6000),
                   new TimedTransition(7000, "spawn minions")
                   ),
               new State("spawn minions",
                   new ConditionalEffect(ConditionEffectIndex.Invincible),
                   new Order(30, "ic boss purifier generator", "spawn minion plox <3"),
                   new SetAltTexture(1),
                   new TimedTransition(0, "spawn minions2")
                   ),
               new State("spawn minions2",
                   new ConditionalEffect(ConditionEffectIndex.Invincible),
                   new SetAltTexture(1),
                   new EntityNotExistsTransition("ic shielded king", 30, "kill me time...")
                   ),
               new State("kill me time...",
                   new Orbit(2.0, 1, 10, "ic boss manager"),
                   new SetAltTexture(2),
                   new TimedTransition(12000, "WTF HE DO...")
                   ),
               new State("WTF HE DO...",
                   new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                   new SetAltTexture(0),
                   new TimedTransition(250, "AA")
                   ),
               new State("AA",
                   new SetAltTexture(2),
                   new TimedTransition(250, "BB")
                   ),
              new State("BB",
                  new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                  new SetAltTexture(0),
                  new TimedTransition(250, "CC")
                  ),
              new State("CC",
                  new SetAltTexture(2),
                  new TimedTransition(250, "DD")
                  ),
              new State("DD",
                  new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                  new SetAltTexture(0),
                  new TimedTransition(250, "EE")
                   ),
              new State("EE",
                  new SetAltTexture(2),
                  new Order(30, "ic boss purifier generator", "spawn crosses"),
                  new TimedTransition(250, "FF")
                  ),
              new State("FF",
                    new SetAltTexture(0),
                    new Orbit(0.1, 1, 10, "ic boss manager"),
                    new Taunt("I can barely hold on. Please. Do it."),
                    new Taunt("HAHAHAHA"),
                    new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                    new EntitiesNotExistsTransition(20, "nooo!", "ic boss purifier"),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 0, coolDownOffset: 0, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 10, coolDownOffset: 200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 20, coolDownOffset: 400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 30, coolDownOffset: 600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 40, coolDownOffset: 800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 50, coolDownOffset: 1000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 60, coolDownOffset: 1200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 70, coolDownOffset: 1400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 80, coolDownOffset: 1600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 90, coolDownOffset: 1800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 100, coolDownOffset: 2000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 110, coolDownOffset: 2200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 120, coolDownOffset: 2400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 130, coolDownOffset: 2600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 140, coolDownOffset: 2800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 150, coolDownOffset: 3000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 160, coolDownOffset: 3200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 170, coolDownOffset: 3400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 180, coolDownOffset: 3600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 190, coolDownOffset: 3800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 200, coolDownOffset: 4000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 210, coolDownOffset: 4200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 220, coolDownOffset: 4400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 230, coolDownOffset: 4600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 240, coolDownOffset: 4800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 250, coolDownOffset: 5000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 260, coolDownOffset: 5200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 270, coolDownOffset: 5400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 280, coolDownOffset: 5600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 290, coolDownOffset: 5800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 300, coolDownOffset: 6000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 310, coolDownOffset: 6200, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 320, coolDownOffset: 6400, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 330, coolDownOffset: 6600, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 340, coolDownOffset: 6800, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 1, fixedAngle: 350, coolDownOffset: 7000, coolDown: 14000),
                    new Shoot(20, 100, projectileIndex: 0, fixedAngle: fixedAngle_RingAttack2, coolDownOffset: 3500, coolDown: 14000),
                    new Taunt("Icicles, rend their flesh!"),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 0, coolDownOffset: 8000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 90, coolDownOffset: 8000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 180, coolDownOffset: 8000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 270, coolDownOffset: 8000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 45, coolDownOffset: 9000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 135, coolDownOffset: 9000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 225, coolDownOffset: 9000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 315, coolDownOffset: 9000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 0, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 90, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 180, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 270, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 45, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 135, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 225, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 7, shootAngle: 10, projectileIndex: 3, fixedAngle: 315, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 10000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 11000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 12000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 13000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 0, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 90, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 180, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 1, projectileIndex: 2, fixedAngle: 270, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 330, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 30, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 60, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 120, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 150, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 210, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 240, coolDownOffset: 14000, coolDown: 14000),
                    new Shoot(20, 2, shootAngle: 10, projectileIndex: 2, fixedAngle: 300, coolDownOffset: 14000, coolDown: 14000)
                    ),
              new State("die",
                  new ConditionalEffect(ConditionEffectIndex.Invulnerable, duration: 2000),
                  new Taunt("You must destroy me. It is the only way to banish him."),
                  new Taunt("Noooo! Shades, come to me. Protect the cornus."),
                  new OrderOnce(100, "ic boss purifier generator", "die"),
                  new OrderOnce(100, "ic boss manager", "nothing"),
                  new SetAltTexture(3),
                  new Wander(1.5)
                    )
                )
            )
        .Init("ic boss purifier",
            new State(
                new State(":P",
                    new PlayerWithinTransition(5, ":D")
                    ),
                new State(":D",
                    new Spawn("ic Whirlwind", 1, 1, coolDown: 10000),
                    new Shoot(5, 1, 0, defaultAngle: 0, angleOffset: 0, projectileIndex: 0, predictive: 1,
                    coolDown: 5000)
                    )
                )
            )
        .Init("ic Whirlwind",
            new State(
                new Follow(0.5, 6, 1),
                new State("shoot1",
                    new Shoot(5, 7, projectileIndex: 0, fixedAngle: fixedAngle_RingAttack2, coolDown: 2000),
                    new TimedTransition(4000, "shoot2")
                    ),
                new State("shoot2",
                    new Shoot(5, 7, projectileIndex: 1, fixedAngle: fixedAngle_RingAttack2, coolDown: 2000),
                    new TimedTransition(4000, "shoot1")
                    )
                )
            )
        .Init("ic shielded king",
            new State(
                new State("idle",
                    new Taunt(probability: 0.3, text: "SKREEEEE"),
                    new Taunt(probability: 0.3, text: "SSSSSsssSsssssss"),
                    new Follow(1.0, 10, 4),
                    new Shoot(20, 1, projectileIndex: 0, coolDown: 500)
                    )
                )
            )
        .Init("ic CreepyTime",
            new State(
                new Protect(1, "ic Esben the Unwilling", 15, 5),
                new Wander(1)
            )
        )
        .Init("ic boss purifier generator",
            new State(
                new ConditionalEffect(ConditionEffectIndex.Invincible),
                new State("spawn crosses",
                    new Spawn("ic boss purifier", 1, 1, coolDown: 10000)
                    ),
                new State("spawn minion plox <3",
                    new Spawn("ic shielded king", maxChildren: 1, initialSpawn: 0)
                    ),
                new State("die",
                    new Spawn("ic CreepyTime", maxChildren: 1, initialSpawn: 0),
                    new Decay(1000)
                    )
                )
            )
        .Init("ic Loot Balloon",
            new State(
                new ScaleHP2(40,3,15),
                    new State("Idle",
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                        new TimedTransition(5000, "UnsetEffect")
                    ),
                    new State("UnsetEffect")
                ),
                new Threshold(0.00001,
                    new ItemLoot("Staff of Esben", 0.006, damagebased: true),
                    new ItemLoot("Skullish Remains of Esben", 0.004, damagebased: true),
                    new ItemLoot("Potion of Mana", 0.3, 3),
                    new ItemLoot("Potion of Dexterity", 0.3, 3),
                    new ItemLoot("50 Credits", 0.01),
                    new ItemLoot("The Holy Robe", 0.001, damagebased: true, threshold: 0.01),
                    new ItemLoot("Icy Frozen Tome", 0.001, damagebased: true, threshold: 0.01),
                    new ItemLoot("Ice Shard Blizzard Spell", 0.001, damagebased: true, threshold: 0.01),
                    new TierLoot(11, ItemType.Armor, 0.125),
                    new TierLoot(12, ItemType.Armor, 0.0625),
                    new TierLoot(13, ItemType.Armor, 0.03125),
                    new TierLoot(10, ItemType.Weapon, 0.0625),
                    new TierLoot(11, ItemType.Weapon, 0.0625),
                    new TierLoot(12, ItemType.Weapon, 0.03125),
                    new TierLoot(5, ItemType.Ability, 0.0625),
                    new TierLoot(6, ItemType.Ability, 0.03125),
                    new ItemLoot("Mark of Esben", 0, 1)
                )
            );
    }
}
