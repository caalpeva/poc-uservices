package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.activity.ActivityMethod;

public interface IGreetingActivities {

    @ActivityMethod(scheduleToCloseTimeoutSeconds = 5)
    String composeGreeting(String greeting, String name);
}