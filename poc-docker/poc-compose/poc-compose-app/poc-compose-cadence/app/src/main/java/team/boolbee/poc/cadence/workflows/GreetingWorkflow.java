package team.boolbee.poc.cadence.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.Init;

public class GreetingWorkflow implements IGreetingWorkflow {
    private static Logger logger = Workflow.getLogger(Init.class);

    @Override
    public String greeting(String username) {
        logger.info("Hello " + name + "!");
    }
}