package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.common.RetryOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;

import java.time.Duration;

public class GreetingWorkflow implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public String getGreeting(String name) {
        //return "Hello " + name + "!";
        // This is a blocking call that returns only after the activity has completed.
        return activities.composeGreeting("Hello", name);
    }
}