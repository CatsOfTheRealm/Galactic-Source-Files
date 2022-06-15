using System;
using System.Linq;
using System.Diagnostics;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using log4net;
using System.Collections.Generic;
using wServer.realm.entities;

namespace wServer.realm
{
    public class FLLogicTicker
    {
        public static TaskScheduler TaskScheduler { get; } = new LogicThreadTaskScheduler();

        private static readonly ILog Log = LogManager.GetLogger(typeof(FLLogicTicker));

        private readonly RealmManager _manager;
        private readonly ConcurrentQueue<Action<RealmTime>>[] _pendings;

        public readonly int TPS;
        public readonly int MsPT;
        public static bool lockdown;
        private readonly ManualResetEvent _mre;
        private RealmTime _worldTime;

        public FLLogicTicker(RealmManager manager)
        {
            _manager = manager;
            MsPT = 1000 / manager.TPS;
            _mre = new ManualResetEvent(false);
            _worldTime = new RealmTime();

            _pendings = new ConcurrentQueue<Action<RealmTime>>[5];
            for (int i = 0; i < 5; i++)
                _pendings[i] = new ConcurrentQueue<Action<RealmTime>>();
        }

        public void TickLoop()
        {
            Log.Info("Logic loop started.");
            
            var loopTime = 0;
            int[] x = { 0, 0, 0, 0, 0 };
            int v = 0;
            var t = new RealmTime();
            var watch = Stopwatch.StartNew();
            do
            {
                t.TotalElapsedMs = watch.ElapsedMilliseconds;
                t.TickDelta = loopTime / MsPT;
                t.TickCount += t.TickDelta;
                t.ElaspedMsDelta = t.TickDelta * MsPT;

                DoLogic(t);

                var logicTime = (int)(watch.ElapsedMilliseconds - t.TotalElapsedMs);
                _mre.WaitOne(Math.Max(0, MsPT - logicTime));
                loopTime += (int)(watch.ElapsedMilliseconds - t.TotalElapsedMs) - t.ElaspedMsDelta;
            } 
            while (true);
            Log.Info("Logic loop stopped.");
        }

        private void DoLogic(RealmTime t)
        {
            var clients = _manager.Clients.Keys;

            foreach (var i in _pendings)
            {
                Action<RealmTime> callback;
                while (i.TryDequeue(out callback))
                    try
                    {
                        callback(t);
                    }
                    catch (Exception e)
                    {
                        Log.Error(e);
                    }
            }
            
            _manager.Monitor.Tick(t);
            _manager.ConMan.Tick(t);
           _manager.InterServer.Tick(t.ElaspedMsDelta);
          //(TaskScheduler as LogicThreadTaskScheduler)?.RunPendingTasks();

            TickWorlds1(t);

            foreach (var client in clients)
                if (client.Player != null && client.Player.Owner != null)
                    client.Player.Flush();
        }

        void TickWorlds1(RealmTime t)    //Continous simulation
        {
            _worldTime.TickDelta += t.TickDelta;

            // tick essentials
            try
            {
                foreach (var w in _manager.Worlds.Values.Distinct())
                    w.TickLogic(t);
            }
            catch (Exception e)
            {
                Log.Error(e);
            }
            //Log.Info("Time of Day: " + _manager.CurrentDatetime);
            // tick world every 200 ms
            t.TickDelta = _worldTime.TickDelta;
            t.ElaspedMsDelta = t.TickDelta * MsPT;

            if (_manager.CurrentDatetime >= 96000)
                _manager.CurrentDatetime = 0;
            else
                _manager.CurrentDatetime += t.TickDelta * 5;

            if (t.ElaspedMsDelta < 200)
                return;

            _worldTime.TickDelta = 0;
            foreach (var i in _manager.Worlds.Values.Distinct())
                i.Tick(t);
        }



        public void AddPendingAction(Action<RealmTime> callback,
            PendingPriority priority = PendingPriority.Normal)
        {
            _pendings[(int)priority].Enqueue(callback);
        }

        private class LogicThreadTaskScheduler : TaskScheduler
        {
            [ThreadStatic]
            private static bool isExecuting;

            private readonly BlockingCollection<Task> taskQueue;

            public LogicThreadTaskScheduler()
            {
                taskQueue = new BlockingCollection<Task>();
            }

            private void internalRunOnCurrentThread()
            {
                isExecuting = true;

                try
                {
                    if (taskQueue.Count == 0) return;
                    foreach (var task in taskQueue.GetConsumingEnumerable())
                    {
                        TryExecuteTask(task);
                    }
                }
                catch (OperationCanceledException)
                { }
                finally
                {
                    isExecuting = false;
                }
            }

            public void Complete() { taskQueue.CompleteAdding(); }
            protected override IEnumerable<Task> GetScheduledTasks() { return null; }

            protected override void QueueTask(Task task)
            {
                try
                {
                    taskQueue.Add(task);
                }
                catch (OperationCanceledException) { }
            }

            protected override bool TryExecuteTaskInline(Task task, bool taskWasPreviouslyQueued)
            {
                if (taskWasPreviouslyQueued) return false;
                return isExecuting && TryExecuteTask(task);
            }

            public void RunPendingTasks()
            {
                if (Thread.CurrentThread.Name != "Logic Thread")
                    throw new InvalidOperationException("Method can only be called from the logic thread.");
                internalRunOnCurrentThread();
            }
        }

    }
}