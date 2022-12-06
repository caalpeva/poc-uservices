package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.common.RetryOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;

public class GreetingWorkflowWithRetries implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);
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