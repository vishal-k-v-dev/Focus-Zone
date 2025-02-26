package com.lock.focus

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
}

// abstract class Loop() {
//     private var remainingDuration: Long = 0
//     private var loop: Thread? = null
//     private var running: Boolean = false

//     fun start(duration: Long, interval: Long) {
//         remainingDuration = duration
//         loop = Thread {
//             while (remainingDuration > 0) {
//                 Thread.sleep(interval)
//                 remainingDuration -= interval
//                 onLoop(remainingDuration)
//             }
            
//             onFinish()
//         }
//         loop?.start()
//         running = true
//     }

//     fun finish() {
//         if(running == true){
//             loop?.interrupt()
//             running = false
//             onFinish()
//         }
//     }

//     fun stop() {
//         if(running == true){
//             running = false
//             loop?.interrupt()
//         }
//     }

//     fun isRunning(): Boolean {
//         return running
//     }

//     abstract fun onLoop(remainingDuration: Long)

//     abstract fun onFinish()
// } 