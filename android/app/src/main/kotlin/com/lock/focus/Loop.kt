package com.lock.focus

import android.os.Handler
import android.os.Looper
import android.os.SystemClock

abstract class Loop {
    private var running = false
    private var startTime: Long = 0L
    private var duration: Long = 0L
    private var interval: Long = 0L
    private val handler = Handler(Looper.getMainLooper())

    private val loopRunnable = object : Runnable {
        override fun run() {
            if (!running) return

            val elapsed = SystemClock.elapsedRealtime() - startTime
            val remaining = duration - elapsed

            if (remaining <= 0) {
                running = false
                onFinish()
            } else {
                onLoop(remaining)
                handler.postDelayed(this, interval)
            }
        }
    }

    fun start(duration: Long, interval: Long) {
        if (running) return

        this.duration = duration
        this.interval = interval
        this.startTime = SystemClock.elapsedRealtime()
        running = true

        handler.post(loopRunnable)
    }

    fun finish() {
        if (running) {
            running = false
            handler.removeCallbacks(loopRunnable)
            onFinish()
        }
    }

    fun stop() {
        if (running) {
            running = false
            handler.removeCallbacks(loopRunnable)
        }
    }

    fun isRunning(): Boolean = running

    fun getRemainingDuration(): Long {
        return if (running) {
            val elapsed = SystemClock.elapsedRealtime() - startTime
            (duration - elapsed).coerceAtLeast(0L)
        } else 0L
    }

    abstract fun onLoop(remainingDuration: Long)
    abstract fun onFinish()
}


/*package com.lock.focus

import java.lang.*
import android.os.Handler
import android.os.Looper

abstract class Loop {
    private var remainingDuration: Long = 0
    private var running: Boolean = false
    private val handler = Handler() 

    private fun scheduleLoop(interval: Long) {
        if (remainingDuration <= 0 || !running) {
            onFinish()
            running = false
            return
        }

        handler.postDelayed(
            {
                remainingDuration -= interval
                onLoop(remainingDuration)
                scheduleLoop(interval) // Recursively call for next iteration
            },
            interval
        )
    }

    public fun start(duration: Long, interval: Long) {
        if (running) return
        remainingDuration = duration
        running = true
        scheduleLoop(interval)
    }
    
    public fun finish() {
        if (running) {
            running = false
            handler.removeCallbacksAndMessages(null)
            onFinish()
        }
    }

    public fun stop() {
        if (running) {
            running = false
            handler.removeCallbacksAndMessages(null)
        }
    }

    public fun isRunning(): Boolean {
        return running
    }

    public fun getRemainingDuration(): Long {
        return remainingDuration
    }

    abstract fun onLoop(remainingDuration: Long)

    abstract fun onFinish()
}*/
