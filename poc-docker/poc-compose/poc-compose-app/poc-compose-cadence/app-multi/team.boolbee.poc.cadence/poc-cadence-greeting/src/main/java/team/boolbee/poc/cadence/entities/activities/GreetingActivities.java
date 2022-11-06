package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.activity.Activity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class GreetingActivities implements IGreetingActivities {

    private static Logger logger = LoggerFactory.getLogger(GreetingActivities.class);

    private final List<String> invocations = new ArrayList<>();

    @Override
    public String composeGreeting(String greeting, String name) {
        logger.info("From " + Activity.getWorkflowExecution());
        invocations.add("composeGreeting");
        return greeting + " " + name + "!";
    }

    public List<String> getInvocations() {
        return invocations;
    }
}