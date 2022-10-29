package team.boolbee.poc.cadence.workflows;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.common.RetryOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.Init;
import team.boolbee.poc.cadence.activities.IGreetingActivities;

import java.time.Duration;

public class GreetingWorkflow implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(Init.class);

//    private final IGreetingActivities activities =
//            Workflow.newActivityStub(IGreetingActivities.class);
    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class,
                    new ActivityOptions.Builder()
                        .setScheduleToCloseTimeout(Duration.ofSeconds(10))
                        .setRetryOptions(new RetryOptions.Builder()
                            .setInitialInterval(Duration.ofSeconds(1))
                            .setExpiration(Duration.ofMinutes(1))
                            .setDoNotRetry(IllegalArgumentException.class)
                            .build())
                        .build());

    @Override
    public String getGreeting(String name) {
        logger.info("Invoking activity...");
        // This is a blocking call that returns only after the activity has completed.
        return activities.composeGreeting("Hello", name);
    }
}