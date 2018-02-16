#!/usr/bin/gawk

/xfs:xfs_ilock:/ {
    inode = $9
    pid = $2
    time = $4
    sub(/:/, "", time)
    nr = locks_acquiring[pid]++
    lock_acquire_time[pid, nr] = time
}

/xfs:xfs_ilock_ret:/ {
    proc = $1
    pid = $2
    time = $4
    sub(/:/, "", time)

    if (locks_acquiring[pid] > 0) {
	nr = --locks_acquiring[pid]
	acquire_time = lock_acquire_time[pid, nr]
	stall = time - acquire_time
	if (stall >= 0.010000 && proc ~ /reactor-.*|scylla/) {
	    printf("pid %s (%s) time %12.6f delta: %10.6f\n", pid, proc, time, stall)
	}
	del lock_acquire_time[pid, nr]
    }
}
