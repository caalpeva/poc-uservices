package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;
import java.util.UUID;

public class GreetingSideEffectWorkflow implements IGreetingQueryableWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private String greeting;

    @Override
    public void createGreeting(String name) {
        greeting = Workflow.sideEffect(String.class, () -> UUID.randomUUID().toString());
    }

    @Override
    public String queryGreeting() {
        return greeting;
    }
}