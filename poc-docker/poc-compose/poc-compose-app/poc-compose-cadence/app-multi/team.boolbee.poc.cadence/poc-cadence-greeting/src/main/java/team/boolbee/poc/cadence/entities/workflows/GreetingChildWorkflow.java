package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

public class GreetingChildWorkflow implements IGreetingChildWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    @Override
    public String composeGreeting(String greeting, String name) {
        return greeting + " " + name + "!";
    }
}