package com.lock.focus

import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import java.lang.*

class Loop {
    private var interval: Long = 0L
    private var initialDuration: Long = 0L
    private var remainingDuration: Long = 0L
    private var startTime: Long = 0L
    private var running = false
    private val handler = Handler(Looper.getMainLooper())
    private val loopRunnable = object : Runnable {
        override fun run() { scheduleLoop() }
    }

    fun start(duration: Long, interval: Long) {
        if (running) return
        this.interval = interval
        initialDuration = duration
        remainingDuration = duration
        startTime = SystemClock.elapsedRealtime()
        running = true
        handler.postDelayed(loopRunnable, interval)
    }

    fun stop() {
        running = false
        handler.removeCallbacks(loopRunnable)
    }

    fun finish() {
        if (!running) return
        running = false
        handler.removeCallbacks(loopRunnable)
        onFinish()
    }

    fun isRunning() = running
    fun getRemainingDuration() = remainingDuration

    private fun scheduleLoop() {
        if (!running) return
        if (remainingDuration <= 0L) {
            running = false
            onFinish()
            return
        }
        val now = SystemClock.elapsedRealtime()
        val elapsed = now - startTime
        val expectedRemaining = initialDuration - elapsed
        val drift = remainingDuration - expectedRemaining
        if (drift > 10_000L) {
            remainingDuration = expectedRemaining
        } else {
            remainingDuration -= interval
        }
        onLoop(remainingDuration)
        handler.postDelayed(loopRunnable, interval)
    }

    /** Called each tick with the updated remaining time. */
    open fun onLoop(remaining: Long) {}

    /** Called when the countdown finishes. */
    open fun onFinish() {}
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
