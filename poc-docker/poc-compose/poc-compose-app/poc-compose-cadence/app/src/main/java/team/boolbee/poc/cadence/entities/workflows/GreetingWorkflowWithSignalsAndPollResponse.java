package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GreetingWorkflowWithSignalsAndPollResponse implements IGreetingWorkflowWithSignals {
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
        Map<String, Object> upsertedMap = new HashMap<>();
        // Because we are going to get the response after signal, make sure first thing to do in the
        // signal method is to upsert search attribute with the response.
        // Use CustomKeywordField for response, in real code you may use other fields
        // If there are multiple signals processed in paralell, consider returning a map of message
        // to each status/result so that they won't overwrite each other
        upsertedMap.put("CustomKeywordField", name + ":" + "No_Error");
        Workflow.upsertSearchAttributes(upsertedMap);

        messages.add("Hello " + name + "!");
    }

    @Override
    public void exit() {
        exit = true;
    }
}