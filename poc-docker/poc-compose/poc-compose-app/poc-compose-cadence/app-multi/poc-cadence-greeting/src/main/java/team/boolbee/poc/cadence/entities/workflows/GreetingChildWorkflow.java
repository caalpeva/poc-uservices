package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.activity.ActivityOptions;
import com.uber.cadence.workflow.Workflow;
import org.slf4j.Logger;
import team.boolbee.poc.cadence.entities.activities.IGreetingActivities;
import team.boolbee.poc.cadence.starters.GreetingWorkflowStarter;

import java.time.Duration;

public class GreetingChildWorkflow implements IGreetingChildWorkflow {
    private static Logger logger = Workflow.getLogger(GreetingWorkflowStarter.class);

    private final IGreetingActivities activities =
            Workflow.newActivityStub(
                    IGreetingActivities.class,
                    new ActivityOptions.Builder()
                            .setScheduleToCloseTimeout(Duration.ofSeconds(10))
                            .build());
    @Override
    public String composeGreeting(String greeting, String name) {
        //return greeting + " " + name + "!";
        return activities.composeGreeting(greeting, name);
    }
}