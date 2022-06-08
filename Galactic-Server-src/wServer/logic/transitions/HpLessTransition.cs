using wServer.realm;
using wServer.realm.entities;

namespace wServer.logic.transitions
{
    class HpLessTransition : Transition
    {
        //State storage: none
        private readonly double Threshold;

        public HpLessTransition(double threshold, string targetState) : base(targetState)
        {
            Threshold = threshold;
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            double newhp = 0;
            Enemy Boss = host as Enemy;
            if (Boss.HP < Boss.MaximumHP * Threshold)
            {
                newhp = Boss.MaximumHP * Threshold;
                Boss.HP = (int)newhp;
            }
            return ((double)(host as Enemy).HP / (host as Enemy).MaximumHP) <= Threshold;
        }
    }
}
