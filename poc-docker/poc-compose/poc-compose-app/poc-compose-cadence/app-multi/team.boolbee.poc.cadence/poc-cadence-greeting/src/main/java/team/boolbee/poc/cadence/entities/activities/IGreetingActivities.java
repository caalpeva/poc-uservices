package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.activity.ActivityMethod;

import static team.boolbee.poc.cadence.entities.CadenceConstants.TASK_LIST_GREETING;

public interface IGreetingActivities {

    @ActivityMethod(scheduleToCloseTimeoutSeconds = 2)
    String composeGreeting(String greeting, String name);
}