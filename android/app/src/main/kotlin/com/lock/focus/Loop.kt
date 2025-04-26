package com.lock.focus

import android.os.Handler
import android.os.Looper
import android.os.SystemClock

abstract class Loop {
    private var remainingDuration: Long = 0
    private var running: Boolean = false
    private var startTime: Long = 0
    private val handler = Handler(Looper.getMainLooper())

    private fun scheduleLoop(interval: Long) {
        if (remainingDuration <= 0 || !running) {
            onFinish()
            running = false
            return
        }

        handler.postDelayed({
            val now = SystemClock.elapsedRealtime()
            val drift = (now - startTime) - (intervalUsedSoFar())

            if (drift > 10_000L) {
                // Correct the remaining duration to match actual time passed
                val actualPassed = now - startTime
                remainingDuration = ((remainingDuration + intervalUsedSoFar()) - actualPassed).coerceAtLeast(0L)
                // Round it to nearest lower 500ms
                remainingDuration -= remainingDuration % 500
            } else {
                remainingDuration -= interval
            }

            onLoop(remainingDuration)
            scheduleLoop(interval)
        }, interval)
    }

    private fun intervalUsedSoFar(): Long {
        return (SystemClock.elapsedRealtime() - startTime).coerceAtLeast(0L)
    }

    fun start(duration: Long, interval: Long) {
        if (running) return
        remainingDuration = duration
        startTime = SystemClock.elapsedRealtime()
        running = true
        scheduleLoop(interval)
    }

    fun finish() {
        if (running) {
            running = false
            handler.removeCallbacksAndMessages(null)
            onFinish()
        }
    }

    fun stop() {
        if (running) {
            running = false
            handler.removeCallbacksAndMessages(null)
        }
    }

    fun isRunning(): Boolean = running

    fun getRemainingDuration(): Long = remainingDuration

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
