
# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

prog=$(basename $EXEC)

[ -f /etc/sysconfig/redis ] && . /etc/sysconfig/redis

start() {
    [ -x $EXEC ] || exit 5
    [ -f $CONF ] || exit 6
    echo -n $"Starting $prog: "
    $EXEC $CONF
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $PIDFILE
    return $retval
}

stop() {
    PID=$(cat $PIDFILE)
    echo -n $"Stopping $prog: "
    $CLIEXEC -p $REDISPORT shutdown
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $PIDFILE
    return $retval
}

restart() {
    stop
    start
}

reload() {
    echo -n $"Reloading $prog: "
    killproc $EXEC -HUP
    echo
}


rh_status() {
    status $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}


case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    status|status_q)
        rh_$1
        ;;
    condrestart|try-restart)
        rh_status_q || exit 7
        restart
            ;;
    *)
        echo $"Usage: $0 {start|stop|reload|status|restart}"
        exit 2
esac
