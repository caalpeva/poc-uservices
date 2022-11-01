package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Async;
import com.uber.cadence.workflow.Promise;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

public class GreetingWorkflowWithChildWorkflow implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(IGreetingActivities.class);

    @Override
    public String getGreeting(String name) {
        // Workflows are stateful. So a new stub must be created for each new child.
        IGreetingChildWorkflow child = Workflow.newChildWorkflowStub(IGreetingChildWorkflow.class);

        // This is a non blocking call that returns immediately.
        // Use child.composeGreeting("Hello", name) to call synchronously.
        Promise<String> greeting = Async.function(child::composeGreeting, "Hello", name);
        // Do something else here.
        return greeting.get(); // blocks waiting for the child to complete.
    }
}