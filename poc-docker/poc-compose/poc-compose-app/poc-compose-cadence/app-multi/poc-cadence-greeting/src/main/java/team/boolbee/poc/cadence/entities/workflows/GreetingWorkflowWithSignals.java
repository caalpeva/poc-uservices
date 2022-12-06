package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class GreetingWorkflowWithSignals implements IGreetingWorkflowWithSignals {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    List<String> messages = new ArrayList<>(10);
    boolean exit = false;

    @Override
    public List<String> getGreetings() {
        logger.info(Workflow.getWorkflowInfo().getWorkflowId());
        while (true) {
            Workflow.await(() -> exit);
            return messages;
        }
    }

    @Override
    public void waitForName(String name) {
        messages.add("Hello " + name + "!");
    }

    @Override
    public void exit() {
        exit = true;
    }
}