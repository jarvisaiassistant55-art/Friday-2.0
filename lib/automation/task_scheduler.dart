class TaskScheduler { final List<DateTime> tasks=[]; void schedule(DateTime when)=>tasks.add(when); List<DateTime> upcoming()=>tasks.where((t)=>t.isAfter(DateTime.now())).toList()..sort(); }
