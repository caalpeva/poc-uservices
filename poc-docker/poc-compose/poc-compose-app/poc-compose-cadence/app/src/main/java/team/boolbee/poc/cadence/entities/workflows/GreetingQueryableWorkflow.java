package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;

/** CreateGreetingWorkflow implementation that updates greeting after sleeping for 2 seconds. */
public class GreetingQueryableWorkflow implements IGreetingQueryableWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private String greeting;

    @Override
    public void createGreeting(String name) {
        greeting = "Hello " + name + "!";
        // Workflow code always uses WorkflowThread.sleep
        // and Workflow.currentTimeMillis instead of standard Java ones.
        Workflow.sleep(Duration.ofSeconds(2));
        greeting = "Bye " + name + "!";
    }

    @Override
    public String queryGreeting() {
        return greeting;
    }
}