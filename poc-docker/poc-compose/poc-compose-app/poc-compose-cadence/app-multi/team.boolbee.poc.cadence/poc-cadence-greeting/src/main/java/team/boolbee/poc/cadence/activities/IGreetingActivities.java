package team.boolbee.poc.cadence.activities;

import com.uber.cadence.activity.ActivityMethod;

public interface IGreetingActivities {

    @ActivityMethod(scheduleToCloseTimeoutSeconds = 2)
    String composeGreeting(String greeting, String name);
  }