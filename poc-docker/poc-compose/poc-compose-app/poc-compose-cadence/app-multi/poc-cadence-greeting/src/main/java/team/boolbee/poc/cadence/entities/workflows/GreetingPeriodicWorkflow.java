package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;

import java.time.Duration;

public class GreetingPeriodicWorkflow implements IGreetingPeriodicWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingPeriodicWorkflow.class);

    /**
     * This value is so low just to make the example interesting to watch. In real life you would
     * use something like 100 or a value that matches a business cycle. For example if it runs once
     * an hour 24 would make sense.
     */
    private final int CONTINUE_AS_NEW_FREQUENCEY = 10;

    private final IGreetingActivities activities =
            Workflow.newActivityStub(
                    IGreetingActivities.class,
                    new ActivityOptions.Builder()
                            .setScheduleToCloseTimeout(Duration.ofSeconds(10))
                            .build());

    /**
     * Stub used to terminate this workflow run and create the next one with the same ID atomically.
     */
    private final IGreetingPeriodicWorkflow continueAsNew =
            Workflow.newContinueAsNewStub(IGreetingPeriodicWorkflow.class);

    @Override
    public void greetPeriodically(String name, Duration delay) {
        // Loop the predefined number of times then continue this workflow as new.
        // This is needed to periodically truncate the history size.
        for (int i = 0; i < CONTINUE_AS_NEW_FREQUENCEY; i++) {
            activities.composeGreeting("Hello", name);
            Workflow.sleep(delay);
        }

        // Current workflow run stops executing after this call.
        continueAsNew.greetPeriodically(name, delay);
        // unreachable line
    }
}