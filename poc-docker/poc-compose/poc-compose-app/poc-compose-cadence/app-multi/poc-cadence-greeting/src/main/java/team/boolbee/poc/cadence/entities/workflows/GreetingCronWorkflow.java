package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

public class GreetingCronWorkflow implements IGreetingCronWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingCronWorkflow.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public void greetPeriodically(String name) {
        // This is a blocking call that returns only after the activity has completed.
        activities.composeGreeting("Hello", name);
    }
}