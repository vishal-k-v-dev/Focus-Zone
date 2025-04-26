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
            // Calculate the actual elapsed time since start
            val elapsedTime = SystemClock.elapsedRealtime() - startTime

            // Correct remaining duration by elapsed time
            remainingDuration = (remainingDuration - elapsedTime).coerceAtLeast(0L)

            // If elapsed time is less than 500ms (or any small number), just subtract interval normally
            if (elapsedTime < 500) {
                remainingDuration -= interval
            }

            // Call loop callback
            onLoop(remainingDuration)

            // Recursively call scheduleLoop for next iteration
            scheduleLoop(interval)
        }, interval)
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
