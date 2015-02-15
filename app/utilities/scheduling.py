def periodic_scheduler(timer, interval, action, actionargs=(), doFirstRun=True):
    from threading import Timer
    if doFirstRun:
        print('>> Executing Periodic Task')
        action(*actionargs)
        print('>> Completed Periodic Task. Next in ' + str(interval / 3600) + ' hours. \n')
        
    timer = Timer(
      interval, 
      periodic_scheduler, 
      (
        timer,
        interval,
        action,
        actionargs,
        True
      ),
    )
    timer.daemon = True
    timer.start()