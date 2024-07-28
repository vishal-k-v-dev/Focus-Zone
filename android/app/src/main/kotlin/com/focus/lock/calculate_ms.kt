import java.util.Calendar

fun getMillisecondsRemaining(targetTime: String): Long {
    // Parse the input time
    val parts = targetTime.split(":")
    if (parts.size != 2) {
        throw IllegalArgumentException("Time must be in the format HH:mm")
    }
    val targetHour = parts[0].toInt()
    val targetMinute = parts[1].toInt()

    // Get current time
    val now = Calendar.getInstance()

    // Set target time today
    val target = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, targetHour)
        set(Calendar.MINUTE, targetMinute)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }

    // If the target time has already passed today, set it for tomorrow
    if (target.before(now)) {
        target.add(Calendar.DAY_OF_YEAR, 1)
    }

    // Calculate the difference in milliseconds
    return target.timeInMillis - now.timeInMillis
}