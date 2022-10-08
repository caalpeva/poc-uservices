package team.boolbee.poc.cadence.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.Init;

public class PocWorkflowImpl implements PocWorkflow {
    private static Logger logger = Workflow.getLogger(Init.class);

    @Override
    public void greeting(String name) {
        logger.info("Hello " + name + "!");
    }
}