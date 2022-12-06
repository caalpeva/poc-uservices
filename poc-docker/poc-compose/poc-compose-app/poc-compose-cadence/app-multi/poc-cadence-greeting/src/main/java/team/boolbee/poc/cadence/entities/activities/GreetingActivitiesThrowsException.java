package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

public class GreetingActivitiesThrowsException implements IGreetingActivities {

    private static Logger logger = LoggerFactory.getLogger(GreetingActivitiesThrowsException.class);

    @Override
    public synchronized String composeGreeting(String greeting, String name) {
        try {
            throw new IOException(greeting + " " + name + "!, this is an exception.");
        } catch (IOException e) {
            // Wrapping the exception as checked exceptions in activity and workflow interface methods are prohibited.
            // It will be unwrapped and attached as a cause to the ActivityFailureException.
            throw Workflow.wrap(e);
        }
    }
}