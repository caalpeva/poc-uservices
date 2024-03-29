package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;

public class GreetingQueryableAndConsistentWorkflow implements IGreetingQueryableAndConsistentWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private int counter;

    @Override
    public void createGreeting(String name) {
        // Workflow code always uses WorkflowThread.sleep
        // and Workflow.currentTimeMillis instead of standard Java ones.
        Workflow.sleep(Duration.ofDays(2));
    }

    @Override
    public void increase() {
        this.counter++;
    }

    @Override
    public int getCounter() {
        return counter;
    }
}